-- Défi Quiz · phase 27 : liste des parties publiques ouvertes
create or replace function public.list_open_parties(p_theme text) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(x order by x.same desc, x.created_at desc), '[]'::jsonb) from (
    select p.code, p.theme, p.n, p.max_players as max, p.created_at,
           (p.theme = any(public.theme_family(coalesce(p_theme, '')))
             or p_theme = any(public.theme_family(p.theme))) as same,
           pr.pseudo as host_pseudo, pr.avatar, pr.avatar_url, pr.frame,
           (select count(*) from public.party_players x where x.party_id = p.id and x.left_at is null) as players
      from public.parties p join public.profiles pr on pr.id = p.host
     where p.status = 'lobby' and p.is_public and p.created_at > now() - interval '15 minutes'
       and exists (select 1 from public.party_players x where x.party_id = p.id and x.left_at is null and x.seen_at > now() - interval '20 seconds')
       and (select count(*) from public.party_players x where x.party_id = p.id and x.left_at is null) < p.max_players
     limit 30) x;
$$;
grant execute on function public.list_open_parties(text) to authenticated;

-- départ : quand le salon est plein ou quand l'hôte lance (plus de départ automatique au chrono)
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
    if cnt >= p.max_players then
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

