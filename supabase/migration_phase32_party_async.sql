-- Kwiz · phase 32 : parties à plusieurs, tous ensemble sur la même question ;
-- dès que tous les joueurs ont répondu, on passe à la correction puis à la question suivante (sans attendre la fin du chrono)
begin;

alter table public.parties add column if not exists cur_idx int not null default 0;
alter table public.parties add column if not exists q_start timestamptz;
alter table public.parties add column if not exists q_closed timestamptz;

-- Fait avancer la partie : clôture anticipée quand tout le monde a répondu, correction de 4 s, question suivante, fin
create or replace function public.party_tick(pid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare p public.parties; qend timestamptz; gap interval := interval '4 seconds';
begin
  select * into p from public.parties where id = pid for update;
  if p.id is null or p.status <> 'playing' then return; end if;
  if p.q_start is null then
    p.q_start := p.started_at; p.cur_idx := 0; p.q_closed := null;
    update public.parties set q_start = p.q_start, cur_idx = 0, q_closed = null where id = pid;
  end if;
  loop
    qend := coalesce(p.q_closed, p.q_start + make_interval(secs => p.q_secs));
    if p.q_closed is null and now() >= p.q_start and now() < qend
       and exists (select 1 from public.party_answers a where a.party_id = pid and a.idx = p.cur_idx)
       and not exists (select 1 from public.party_players pp
                        where pp.party_id = pid and pp.left_at is null and pp.seen_at > now() - interval '15 seconds'
                          and not exists (select 1 from public.party_answers a
                                           where a.party_id = pid and a.user_id = pp.user_id and a.idx = p.cur_idx)) then
      p.q_closed := now(); qend := p.q_closed;
      update public.parties set q_closed = p.q_closed where id = pid;
    end if;
    exit when now() < qend + gap;
    if p.cur_idx + 1 >= p.n then
      update public.parties set status = 'done' where id = pid;
      return;
    end if;
    p.cur_idx := p.cur_idx + 1; p.q_start := qend + gap; p.q_closed := null;
    update public.parties set cur_idx = p.cur_idx, q_start = p.q_start, q_closed = null where id = pid;
  end loop;
end $$;

-- Question n° p_idx (la question en cours ou une précédente) ; la bonne réponse n'est donnée qu'une fois la question close
create or replace function public.party_question(p_id uuid, p_idx int) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; qend timestamptz;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  perform public.party_tick(p_id);
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' or p_idx < 0 or p_idx >= p.n or p_idx > p.cur_idx then raise exception 'question indisponible'; end if;
  if p_idx = p.cur_idx and now() < p.q_start - interval '1 second' then raise exception 'trop tôt'; end if;
  qend := coalesce(p.q_closed, p.q_start + make_interval(secs => p.q_secs));
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  return jsonb_build_object('idx', p_idx, 'id', q.id, 'question', q.question, 'theme', q.theme, 'difficulty', q.difficulty,
    'options', (select jsonb_agg(o order by md5(o || p_id::text)) from unnest(q.wrong || q.answer) o),
    'answer', case when p_idx < p.cur_idx or p.status = 'done' or now() >= qend then q.answer end,
    'mine', (select choice from public.party_answers where party_id = p_id and user_id = me and idx = p_idx));
end $$;

create or replace function public.submit_party_answer(p_id uuid, p_idx int, p_choice text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; el numeric; ok boolean; pts int;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  perform public.party_tick(p_id);
  select * into p from public.parties where id = p_id;
  if p.status <> 'playing' or p_idx <> p.cur_idx then raise exception 'réponse refusée'; end if;
  el := extract(epoch from now() - p.q_start);
  if el < -0.5 or el > p.q_secs + 1.5 or (p.q_closed is not null and now() > p.q_closed + interval '1 second') then raise exception 'temps écoulé'; end if;
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  ok := coalesce(p_choice = q.answer, false);
  pts := case when ok then round(20 - least(10, greatest(0.3, el * 10.0 / p.q_secs)))::int * case when p_idx = p.n - 1 then 2 else 1 end else 0 end;
  insert into public.party_answers(party_id, user_id, idx, choice, ok, points) values (p_id, me, p_idx, p_choice, ok, pts)
    on conflict do nothing;
  if not found then raise exception 'déjà répondu'; end if;
  update public.party_players set score = score + pts, correct = correct + ok::int, seen_at = now() where party_id = p_id and user_id = me;
  perform public.party_tick(p_id);   -- dernier à répondre : la question se clôt tout de suite
  return jsonb_build_object('ok', ok, 'points', pts);
end $$;

-- État du salon et de la manche en cours (phase count / q / reveal, secondes restantes, qui a répondu)
create or replace function public.party_state(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; cnt int; r record; qend timestamptz; ph text; lft numeric;
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
    if cnt >= p.max_players then perform public.party_begin(p_id); end if;
  end if;
  perform public.party_tick(p_id);
  select * into p from public.parties where id = p_id;
  if p.status = 'playing' then
    qend := coalesce(p.q_closed, p.q_start + make_interval(secs => p.q_secs));
    if now() < p.q_start then ph := 'count'; lft := extract(epoch from p.q_start - now());
    elsif now() < qend then ph := 'q'; lft := extract(epoch from qend - now());
    else ph := 'reveal'; lft := extract(epoch from qend + interval '4 seconds' - now()); end if;
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
    'host', p.host, 'me', me, 'now', now(), 'started_at', p.started_at, 'q_secs', p.q_secs, 'gap_secs', 4,
    'created_at', p.created_at, 'max', p.max_players,
    'idx', p.cur_idx, 'phase', ph, 'left', lft,
    'players', coalesce((select jsonb_agg(x order by x.score desc, x.joined_at) from (
        select pp.user_id as id, pr.pseudo, pr.avatar, pr.avatar_url, pr.frame, pp.joined_at, pp.correct,
               -- pendant la question, les points de la manche en cours restent cachés
               pp.score - case when ph = 'q' then coalesce(a.points, 0) else 0 end as score,
               a.idx is not null as answered,
               case when ph = 'reveal' then a.points end as pts,
               case when ph = 'reveal' then a.ok end as ok,
               p.status = 'playing' and pp.seen_at < now() - interval '15 seconds' as away
          from public.party_players pp join public.profiles pr on pr.id = pp.user_id
          left join public.party_answers a on a.party_id = pp.party_id and a.user_id = pp.user_id and a.idx = p.cur_idx
         where pp.party_id = p_id and pp.left_at is null) x), '[]'::jsonb));
end $$;

revoke execute on function public.party_tick(uuid) from public, anon, authenticated;
commit;
