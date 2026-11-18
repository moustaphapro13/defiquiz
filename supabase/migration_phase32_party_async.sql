-- Kwiz · phase 32 : parties à plusieurs, chacun avance à son rythme (plus d'attente entre les tours) + progression en direct
begin;

alter table public.party_players add column if not exists cur_idx int not null default 0;
alter table public.party_players add column if not exists q_idx int not null default -1;
alter table public.party_players add column if not exists q_t0 timestamptz;

-- Question n° p_idx : uniquement la question en cours du joueur (ou une déjà jouée, avec la réponse).
-- Le chrono du joueur démarre au premier affichage de la question.
create or replace function public.party_question(p_id uuid, p_idx int) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; pp public.party_players;
begin
  select * into pp from public.party_players where party_id = p_id and user_id = me and left_at is null;
  if pp.user_id is null then raise exception 'tu ne fais pas partie de ce salon'; end if;
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' or p_idx < 0 or p_idx >= p.n or p_idx > pp.cur_idx then raise exception 'question indisponible'; end if;
  if now() < p.started_at - interval '1 second' then raise exception 'trop tôt'; end if;
  if p_idx = pp.cur_idx and pp.q_idx <> p_idx then
    update public.party_players set q_idx = p_idx, q_t0 = now(), seen_at = now() where party_id = p_id and user_id = me;
    pp.q_t0 := now();
  end if;
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  return jsonb_build_object('idx', p_idx, 'id', q.id, 'question', q.question, 'theme', q.theme, 'difficulty', q.difficulty,
    'options', (select jsonb_agg(o order by md5(o || p_id::text)) from unnest(q.wrong || q.answer) o),
    'left', case when p_idx = pp.cur_idx then greatest(0, p.q_secs - extract(epoch from now() - pp.q_t0)) end,
    'answer', case when p_idx < pp.cur_idx then q.answer end,
    'mine', (select choice from public.party_answers where party_id = p_id and user_id = me and idx = p_idx));
end $$;

-- Réponse à la question en cours ; p_choice null = temps écoulé. Passe aussitôt le joueur à la question suivante.
create or replace function public.submit_party_answer(p_id uuid, p_idx int, p_choice text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; pp public.party_players; el numeric; ok boolean; pts int;
begin
  select * into pp from public.party_players where party_id = p_id and user_id = me and left_at is null for update;
  if pp.user_id is null then raise exception 'tu ne fais pas partie de ce salon'; end if;
  select * into p from public.parties where id = p_id;
  if p.status <> 'playing' or p_idx <> pp.cur_idx or pp.q_idx <> p_idx then raise exception 'réponse refusée'; end if;
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  el := extract(epoch from now() - pp.q_t0);
  ok := coalesce(p_choice = q.answer, false) and el <= p.q_secs + 1.5;
  pts := case when ok then round(20 - least(10, greatest(0.3, el * 10.0 / p.q_secs)))::int * case when p_idx = p.n - 1 then 2 else 1 end else 0 end;
  insert into public.party_answers(party_id, user_id, idx, choice, ok, points) values (p_id, me, p_idx, p_choice, ok, pts)
    on conflict do nothing;
  update public.party_players set score = score + pts, correct = correct + ok::int, cur_idx = p_idx + 1, seen_at = now()
   where party_id = p_id and user_id = me;
  return jsonb_build_object('ok', ok, 'points', pts, 'answer', q.answer, 'cur', p_idx + 1);
end $$;

-- État du salon : la partie se termine quand tous les joueurs encore là ont fini (ou au bout du temps maximum)
create or replace function public.party_state(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; cnt int; r record;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  update public.party_players set seen_at = now() where party_id = p_id and user_id = me;
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' then
    update public.party_players set left_at = now() where party_id = p_id and user_id <> me and left_at is null and seen_at < now() - interval '20 seconds';
    if not exists (select 1 from public.party_players where party_id = p_id and user_id = p.host and left_at is null) then
      update public.parties set host = me where id = p_id; p.host := me;
    end if;
    select count(*) into cnt from public.party_players where party_id = p_id and left_at is null;
    if cnt >= p.max_players then
      perform public.party_begin(p_id);
      select * into p from public.parties where id = p_id;
    end if;
  end if;
  if p.status = 'playing' and (
       now() > p.started_at + make_interval(secs => p.n * (p.q_secs + p.gap_secs) + 20)
       or not exists (select 1 from public.party_players where party_id = p_id and left_at is null
                       and cur_idx < p.n and seen_at > now() - interval '30 seconds')) then
    update public.parties set status = 'done' where id = p_id and status = 'playing';
    p.status := 'done';
  end if;
  if p.status = 'done' and not p.rewarded then
    update public.parties set rewarded = true where id = p_id and not rewarded;
    if found then
      for r in select pp.user_id, pp.score, pp.correct,
                      rank() over (order by pp.score desc) as place,
                      count(*) over () as total
                 from public.party_players pp where pp.party_id = p_id and pp.left_at is null loop
        perform public.add_stats(r.user_id, p.theme,
          r.score / 2 + case when r.place = 1 and r.total > 1 then 40 when r.place = 2 then 20 when r.place = 3 then 10 else 0 end,
          r.score, 1, case when r.place = 1 and r.total > 1 then 1 else 0 end, 0, 0);
      end loop;
    end if;
  end if;
  return jsonb_build_object(
    'id', p.id, 'code', p.code, 'theme', p.theme, 'n', p.n, 'status', p.status, 'public', p.is_public,
    'host', p.host, 'me', me, 'now', now(), 'started_at', p.started_at, 'q_secs', p.q_secs, 'gap_secs', p.gap_secs,
    'created_at', p.created_at, 'max', p.max_players, 'async', true,
    'players', coalesce((select jsonb_agg(jsonb_build_object(
        'id', pp.user_id, 'pseudo', pr.pseudo, 'avatar', pr.avatar, 'avatar_url', pr.avatar_url, 'frame', pr.frame,
        'score', pp.score, 'correct', pp.correct, 'cur', pp.cur_idx,
        'away', p.status = 'playing' and pp.seen_at < now() - interval '30 seconds')
        order by pp.score desc, pp.cur_idx desc, pp.joined_at)
      from public.party_players pp join public.profiles pr on pr.id = pp.user_id where pp.party_id = p_id and pp.left_at is null), '[]'::jsonb));
end $$;

commit;
