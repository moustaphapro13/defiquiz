-- Défi Quiz · phase 25 : parties à plusieurs (2 à 10 joueurs), salon privé avec code + parties publiques
begin;

create table if not exists public.parties (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  host uuid not null,
  theme text not null,
  n int not null default 10,
  is_public boolean not null default false,
  status text not null default 'lobby' check (status in ('lobby','playing','done')),
  question_ids bigint[],
  started_at timestamptz,
  q_secs int not null default 12,
  gap_secs int not null default 5,
  rewarded boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists parties_public_idx on public.parties(theme, n) where status = 'lobby' and is_public;

create table if not exists public.party_players (
  party_id uuid,
  user_id uuid,
  score int not null default 0,
  correct int not null default 0,
  joined_at timestamptz not null default now(),
  seen_at timestamptz not null default now(),
  left_at timestamptz,
  primary key (party_id, user_id)
);
alter table public.party_players add column if not exists left_at timestamptz;

create table if not exists public.party_answers (
  party_id uuid,
  user_id uuid,
  idx int not null,
  choice text,
  ok boolean not null default false,
  points int not null default 0,
  answered_at timestamptz not null default now(),
  primary key (party_id, user_id, idx)
);

alter table public.parties enable row level security;
alter table public.party_players enable row level security;
alter table public.party_answers enable row level security;
-- tout passe par les fonctions ci-dessous : aucun accès direct aux tables

create or replace function public.party_new_code() returns text
language sql volatile set search_path = public, pg_temp as $$
  select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', 1 + floor(random() * 32)::int, 1), '') from generate_series(1, 5);
$$;

create or replace function public.party_create_row(p_theme text, p_n int, p_public boolean, me uuid) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare pid uuid; c text; v_n int := greatest(5, least(coalesce(p_n, 10), 20)); tries int := 0;
begin
  if not exists (select 1 from public.questions where theme = any(public.theme_family(p_theme)) and active offset 6 limit 1) then
    raise exception 'pas assez de questions pour ce thème';
  end if;
  loop
    c := public.party_new_code(); tries := tries + 1;
    exit when not exists (select 1 from public.parties where code = c) or tries > 20;
  end loop;
  insert into public.parties(code, host, theme, n, is_public) values (c, me, p_theme, v_n, coalesce(p_public, false)) returning id into pid;
  insert into public.party_players(party_id, user_id) values (pid, me);
  return pid;
end $$;

create or replace function public.create_party(p_theme text, p_n int, p_public boolean) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'non connecté'; end if;
  return public.party_create_row(p_theme, p_n, p_public, me);
end $$;

create or replace function public.join_party(p_code text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties;
begin
  if me is null then raise exception 'non connecté'; end if;
  select * into p from public.parties where code = upper(trim(p_code)) for update;
  if p.id is null then raise exception 'code de salon introuvable'; end if;
  if exists (select 1 from public.party_players where party_id = p.id and user_id = me and left_at is null) then return p.id; end if;
  if p.status <> 'lobby' then raise exception 'la partie a déjà commencé'; end if;
  if (select count(*) from public.party_players where party_id = p.id and left_at is null) >= 10 then raise exception 'salon complet (10 joueurs)'; end if;
  insert into public.party_players(party_id, user_id) values (p.id, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  return p.id;
end $$;

create or replace function public.quick_party(p_theme text, p_n int) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); pid uuid; v_n int := greatest(5, least(coalesce(p_n, 10), 20));
begin
  if me is null then raise exception 'non connecté'; end if;
  select p.id into pid from public.parties p
   where p.status = 'lobby' and p.is_public and p.theme = p_theme and p.n = v_n
     and p.created_at > now() - interval '3 minutes'
     and (select count(*) from public.party_players x where x.party_id = p.id and x.left_at is null) < 10
   order by p.created_at limit 1 for update skip locked;
  if pid is null then return public.party_create_row(p_theme, v_n, true, me); end if;
  insert into public.party_players(party_id, user_id) values (pid, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  return pid;
end $$;

create or replace function public.party_begin(pid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare p public.parties; qids bigint[];
begin
  select * into p from public.parties where id = pid for update;
  if p.status <> 'lobby' then return; end if;
  qids := public.pick_questions(p.theme, p.host, p.n);
  if qids is null or array_length(qids, 1) < 5 then raise exception 'pas assez de questions pour ce thème'; end if;
  update public.parties set status = 'playing', question_ids = qids, n = array_length(qids, 1),
         started_at = now() + interval '4 seconds' where id = pid;
end $$;

create or replace function public.start_party(p_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid();
begin
  if not exists (select 1 from public.parties where id = p_id and host = me) then raise exception 'seul l''hôte peut lancer la partie'; end if;
  if (select count(*) from public.party_players where party_id = p_id and left_at is null) < 2 then raise exception 'il faut au moins 2 joueurs'; end if;
  perform public.party_begin(p_id);
end $$;

create or replace function public.leave_party(p_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; nxt uuid;
begin
  select * into p from public.parties where id = p_id for update;
  if p.id is null or p.status <> 'lobby' then return; end if;
  update public.party_players set left_at = now() where party_id = p_id and user_id = me;
  if p.host = me then
    select user_id into nxt from public.party_players where party_id = p_id and left_at is null order by joined_at limit 1;
    if nxt is null then update public.parties set status = 'done', rewarded = true where id = p_id;
    else update public.parties set host = nxt where id = p_id; end if;
  end if;
end $$;

-- État complet du salon ; fait aussi avancer la partie (démarrage auto des parties publiques, fin, récompenses)
create or replace function public.party_state(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; cnt int; age interval; slot int; r record; rk int := 0;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  update public.party_players set seen_at = now() where party_id = p_id and user_id = me;
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' then
    -- les joueurs partis sans prévenir (plus de 20 s sans nouvelles) quittent le salon
    update public.party_players set left_at = now() where party_id = p_id and user_id <> me and left_at is null and seen_at < now() - interval '20 seconds';
    if not exists (select 1 from public.party_players where party_id = p_id and user_id = p.host and left_at is null) then
      update public.parties set host = me where id = p_id; p.host := me;
    end if;
    select count(*) into cnt from public.party_players where party_id = p_id and left_at is null;
    age := now() - p.created_at;
    if p.is_public and (cnt >= 10 or (cnt >= 3 and age > interval '25 seconds') or (cnt >= 2 and age > interval '60 seconds')) then
      perform public.party_begin(p_id);
      select * into p from public.parties where id = p_id;
    end if;
  end if;
  slot := p.q_secs + p.gap_secs;
  if p.status = 'playing' and now() > p.started_at + make_interval(secs => p.n * slot) then
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
    'created_at', p.created_at,
    'players', coalesce((select jsonb_agg(jsonb_build_object(
        'id', pp.user_id, 'pseudo', pr.pseudo, 'avatar', pr.avatar, 'avatar_url', pr.avatar_url, 'frame', pr.frame,
        'score', pp.score, 'correct', pp.correct,
        'last', (select max(a.idx) from public.party_answers a where a.party_id = p_id and a.user_id = pp.user_id))
        order by pp.score desc, pp.joined_at)
      from public.party_players pp join public.profiles pr on pr.id = pp.user_id where pp.party_id = p_id and pp.left_at is null), '[]'::jsonb));
end $$;

-- Question n° p_idx (0-based) : choix mélangés, bonne réponse seulement une fois le temps écoulé
create or replace function public.party_question(p_id uuid, p_idx int) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; t0 timestamptz;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' or p_idx < 0 or p_idx >= p.n then raise exception 'question indisponible'; end if;
  t0 := p.started_at + make_interval(secs => p_idx * (p.q_secs + p.gap_secs));
  if now() < t0 - interval '1 second' then raise exception 'trop tôt'; end if;
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  return jsonb_build_object('idx', p_idx, 'question', q.question, 'theme', q.theme, 'difficulty', q.difficulty,
    'options', (select jsonb_agg(o order by md5(o || p_id::text)) from unnest(q.wrong || q.answer) o),
    'answer', case when now() >= t0 + make_interval(secs => p.q_secs) then q.answer end,
    'mine', (select choice from public.party_answers where party_id = p_id and user_id = me and idx = p_idx));
end $$;

create or replace function public.submit_party_answer(p_id uuid, p_idx int, p_choice text) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; q public.questions; t0 timestamptz; el numeric; ok boolean; pts int;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  select * into p from public.parties where id = p_id;
  if p.status <> 'playing' or p_idx < 0 or p_idx >= p.n then raise exception 'réponse refusée'; end if;
  t0 := p.started_at + make_interval(secs => p_idx * (p.q_secs + p.gap_secs));
  el := extract(epoch from now() - t0);
  if el < -0.5 or el > p.q_secs + 1.5 then raise exception 'temps écoulé'; end if;
  select * into q from public.questions where id = p.question_ids[p_idx + 1];
  ok := p_choice = q.answer;
  pts := case when ok then round(20 - least(10, greatest(0.3, el * 10.0 / p.q_secs)))::int * case when p_idx = p.n - 1 then 2 else 1 end else 0 end;
  insert into public.party_answers(party_id, user_id, idx, choice, ok, points) values (p_id, me, p_idx, p_choice, ok, pts)
    on conflict do nothing;
  if not found then raise exception 'déjà répondu'; end if;
  update public.party_players set score = score + pts, correct = correct + ok::int, seen_at = now() where party_id = p_id and user_id = me;
  return jsonb_build_object('ok', ok, 'points', pts, 'answer', q.answer);
end $$;

revoke execute on function public.party_new_code(), public.party_create_row(text, int, boolean, uuid), public.party_begin(uuid) from public, anon, authenticated;
grant execute on function public.create_party(text, int, boolean), public.join_party(text), public.quick_party(text, int),
  public.start_party(uuid), public.leave_party(uuid), public.party_state(uuid), public.party_question(uuid, int),
  public.submit_party_answer(uuid, int, text) to authenticated;
commit;

