-- Défi Quiz · phase 26 : nombre de joueurs au choix (2 à 10), l'hôte lance quand il veut
begin;
alter table public.parties add column if not exists max_players int not null default 10;

create or replace function public.party_create_row2(p_theme text, p_n int, p_public boolean, me uuid, p_max int) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare pid uuid;
begin
  pid := public.party_create_row(p_theme, p_n, p_public, me);
  update public.parties set max_players = greatest(2, least(coalesce(p_max, 10), 10)) where id = pid;
  return pid;
end $$;

create or replace function public.create_party(p_theme text, p_n int, p_public boolean, p_max int) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'non connecté'; end if;
  return public.party_create_row2(p_theme, p_n, p_public, me, p_max);
end $$;

create or replace function public.quick_party(p_theme text, p_n int, p_max int) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); pid uuid; v_n int := greatest(5, least(coalesce(p_n, 10), 20)); v_m int := greatest(2, least(coalesce(p_max, 10), 10));
begin
  if me is null then raise exception 'non connecté'; end if;
  select p.id into pid from public.parties p
   where p.status = 'lobby' and p.is_public and p.theme = p_theme and p.n = v_n and p.max_players = v_m
     and p.created_at > now() - interval '3 minutes'
     and (select count(*) from public.party_players x where x.party_id = p.id and x.left_at is null) < p.max_players
   order by p.created_at limit 1 for update skip locked;
  if pid is null then return public.party_create_row2(p_theme, v_n, true, me, v_m); end if;
  insert into public.party_players(party_id, user_id) values (pid, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  return pid;
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
  if (select count(*) from public.party_players where party_id = p.id and left_at is null) >= p.max_players then
    raise exception 'salon complet (% joueurs)', p.max_players;
  end if;
  insert into public.party_players(party_id, user_id) values (p.id, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  return p.id;
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
    if cnt >= p.max_players or (p.is_public and ((cnt >= 3 and age > interval '25 seconds') or (cnt >= 2 and age > interval '60 seconds'))) then
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
    'created_at', p.created_at, 'max', p.max_players,
    'players', coalesce((select jsonb_agg(jsonb_build_object(
        'id', pp.user_id, 'pseudo', pr.pseudo, 'avatar', pr.avatar, 'avatar_url', pr.avatar_url, 'frame', pr.frame,
        'score', pp.score, 'correct', pp.correct,
        'last', (select max(a.idx) from public.party_answers a where a.party_id = p_id and a.user_id = pp.user_id))
        order by pp.score desc, pp.joined_at)
      from public.party_players pp join public.profiles pr on pr.id = pp.user_id where pp.party_id = p_id and pp.left_at is null), '[]'::jsonb));
end $$;

revoke execute on function public.party_create_row2(text, int, boolean, uuid, int) from public, anon, authenticated;
grant execute on function public.create_party(text, int, boolean, int), public.quick_party(text, int, int) to authenticated;
commit;
