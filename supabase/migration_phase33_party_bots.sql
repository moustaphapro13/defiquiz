-- Kwiz · phase 33 : bots dans les parties publiques, dosés automatiquement
-- 1 ou 2 vrais joueurs qui attendent → des bots complètent le salon petit à petit ;
-- un vrai joueur arrive → un bot lui laisse sa place ; 3 vrais joueurs ou plus → plus aucun bot.
begin;

create table if not exists public.party_bots (
  party_id uuid,
  bot int,
  pseudo text not null,
  avatar text not null,
  skill real not null,      -- probabilité de bonne réponse
  speed real not null,      -- 0 = très rapide, 1 = lent
  score int not null default 0,
  correct int not null default 0,
  joined_at timestamptz not null default now(),
  left_at timestamptz,
  primary key (party_id, bot)
);
create table if not exists public.party_bot_answers (
  party_id uuid,
  bot int,
  idx int,
  ok boolean not null,
  points int not null,
  primary key (party_id, bot, idx)
);
alter table public.party_bots enable row level security;
alter table public.party_bot_answers enable row level security;

-- nombre de vrais joueurs présents
create or replace function public.party_humans(pid uuid) returns int
language sql stable security definer set search_path = public, pg_temp as $$
  select count(*)::int from public.party_players where party_id = pid and left_at is null;
$$;

-- ajuste les bots d'un salon public en attente
create or replace function public.party_bots_dose(pid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare p public.parties; h int; b int; target int; last_in timestamptz; nb int;
  names text[] := array['Lina','Yanis','Sarah','Nolan','Inès','Hugo','Jade','Rayan','Chloé','Adam','Léa','Mehdi',
                        'Emma','Lucas','Nora','Ilyes','Manon','Théo','Maya','Sami','Zoé','Bilal','Camille','Nathan'];
begin
  select * into p from public.parties where id = pid;
  if p.id is null or p.status <> 'lobby' or not p.is_public then return; end if;
  h := public.party_humans(pid);
  select count(*), max(joined_at) into b, last_in from public.party_bots where party_id = pid and left_at is null;
  -- 3 vrais joueurs ou plus, ou personne : aucun bot
  if h >= 3 or h = 0 then
    update public.party_bots set left_at = now() where party_id = pid and left_at is null;
    return;
  end if;
  target := least(p.max_players, 4) - h;            -- salon complété à 4 joueurs (ou moins si le salon est plus petit)
  if h + b > p.max_players or b > target then        -- trop de bots : on retire les derniers arrivés
    update public.party_bots set left_at = now()
     where party_id = pid and left_at is null
       and bot in (select bot from public.party_bots where party_id = pid and left_at is null
                    order by joined_at desc limit greatest(b - target, h + b - p.max_players));
    return;
  end if;
  -- on attend d'abord 15 s de vrais joueurs, puis un bot arrive toutes les 3 à 6 s
  if b < target and now() - p.created_at > interval '15 seconds'
     and (last_in is null or now() - last_in > make_interval(secs => 3 + (abs(hashtext(pid::text || b)) % 4))) then
    select coalesce(max(bot), 0) + 1 into nb from public.party_bots where party_id = pid;
    insert into public.party_bots(party_id, bot, pseudo, avatar, skill, speed)
    values (pid, nb,
            names[1 + abs(hashtext(pid::text || 'n' || nb)) % array_length(names, 1)],
            'a' || lpad((1 + abs(hashtext(pid::text || 'a' || nb)) % 18)::text, 2, '0'),
            0.4 + (abs(hashtext(pid::text || 's' || nb)) % 40) / 100.0,
            (abs(hashtext(pid::text || 'v' || nb)) % 100) / 100.0);
  end if;
end $$;

-- réponses des bots à la question en cours ; p_all = true : ceux qui n'ont pas encore répondu répondent maintenant
create or replace function public.party_bots_play(pid uuid, p_all boolean) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare p public.parties; r record; delay numeric; el numeric; ok boolean; pts int;
begin
  select * into p from public.parties where id = pid;
  if p.status <> 'playing' or now() < p.q_start then return; end if;
  for r in select * from public.party_bots bb where bb.party_id = pid and bb.left_at is null
             and not exists (select 1 from public.party_bot_answers a where a.party_id = pid and a.bot = bb.bot and a.idx = p.cur_idx) loop
    delay := 1.5 + (r.speed * 0.6 + (abs(hashtext(pid::text || r.bot || 'd' || p.cur_idx)) % 100) / 250.0) * (p.q_secs - 4);
    if not p_all and now() < p.q_start + make_interval(secs => delay) then continue; end if;
    el := delay;   -- même s'il répond en avance (tout le monde a fini), un bot marque selon son propre temps de réflexion
    ok := (abs(hashtext(pid::text || r.bot || 'k' || p.cur_idx)) % 1000) < r.skill * 1000;
    pts := case when ok then round(20 - least(10, greatest(0.3, el * 10.0 / p.q_secs)))::int * case when p.cur_idx = p.n - 1 then 2 else 1 end else 0 end;
    insert into public.party_bot_answers(party_id, bot, idx, ok, points) values (pid, r.bot, p.cur_idx, ok, pts) on conflict do nothing;
    if found then update public.party_bots set score = score + pts, correct = correct + ok::int where party_id = pid and bot = r.bot; end if;
  end loop;
end $$;

-- avancement de la partie (phase 32) + réponses des bots
create or replace function public.party_tick(pid uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare p public.parties; qend timestamptz; gap interval := interval '4 seconds'; humans_done boolean;
begin
  select * into p from public.parties where id = pid for update;
  if p.id is null or p.status <> 'playing' then return; end if;
  if p.q_start is null then
    p.q_start := p.started_at; p.cur_idx := 0; p.q_closed := null;
    update public.parties set q_start = p.q_start, cur_idx = 0, q_closed = null where id = pid;
  end if;
  loop
    qend := coalesce(p.q_closed, p.q_start + make_interval(secs => p.q_secs));
    if p.q_closed is null and now() >= p.q_start and now() < qend then
      perform public.party_bots_play(pid, false);
      humans_done := not exists (select 1 from public.party_players pp
                        where pp.party_id = pid and pp.left_at is null and pp.seen_at > now() - interval '15 seconds'
                          and not exists (select 1 from public.party_answers a
                                           where a.party_id = pid and a.user_id = pp.user_id and a.idx = p.cur_idx));
      if humans_done and (exists (select 1 from public.party_answers a where a.party_id = pid and a.idx = p.cur_idx)
                          or not exists (select 1 from public.party_players pp where pp.party_id = pid and pp.left_at is null
                                           and pp.seen_at > now() - interval '15 seconds')) then
        perform public.party_bots_play(pid, true);   -- les bots encore en train de « réfléchir » répondent tout de suite
        p.q_closed := now(); qend := p.q_closed;
        update public.parties set q_closed = p.q_closed where id = pid;
      end if;
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

-- l'hôte peut lancer dès qu'il y a 2 participants, bots compris
create or replace function public.start_party(p_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid();
begin
  if not exists (select 1 from public.parties where id = p_id and host = me) then raise exception 'seul l''hôte peut lancer la partie'; end if;
  if public.party_humans(p_id) + (select count(*) from public.party_bots where party_id = p_id and left_at is null) < 2 then
    raise exception 'il faut au moins 2 joueurs';
  end if;
  perform public.party_begin(p_id);
end $$;

-- rejoindre : un bot libère sa place si le salon est plein
create or replace function public.join_party(p_code text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties;
begin
  if me is null then raise exception 'non connecté'; end if;
  select * into p from public.parties where code = upper(trim(p_code)) for update;
  if p.id is null then raise exception 'code de salon introuvable'; end if;
  if exists (select 1 from public.party_players where party_id = p.id and user_id = me and left_at is null) then return p.id; end if;
  if p.status <> 'lobby' then raise exception 'la partie a déjà commencé'; end if;
  if public.party_humans(p.id) >= p.max_players then
    raise exception 'salon complet (% joueurs)', p.max_players;
  end if;
  insert into public.party_players(party_id, user_id) values (p.id, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  perform public.party_bots_dose(p.id);
  return p.id;
end $$;

create or replace function public.quick_party(p_theme text, p_n int, p_max int) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); pid uuid; v_n int := greatest(5, least(coalesce(p_n, 10), 20)); v_m int := greatest(2, least(coalesce(p_max, 10), 10));
begin
  if me is null then raise exception 'non connecté'; end if;
  select p.id into pid from public.parties p
   where p.status = 'lobby' and p.is_public and p.theme = p_theme and p.n = v_n and p.max_players = v_m
     and p.created_at > now() - interval '3 minutes'
     and public.party_humans(p.id) < p.max_players
   order by p.created_at limit 1 for update skip locked;
  if pid is null then return public.party_create_row2(p_theme, v_n, true, me, v_m); end if;
  insert into public.party_players(party_id, user_id) values (pid, me)
    on conflict (party_id, user_id) do update set left_at = null, seen_at = now();
  perform public.party_bots_dose(pid);
  return pid;
end $$;

-- État du salon (phase 32) + bots : dosage en salle d'attente, démarrage auto au bout d'une minute avec des bots
create or replace function public.party_state(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); p public.parties; cnt int; nb int; r record; qend timestamptz; ph text; lft numeric;
begin
  if not exists (select 1 from public.party_players where party_id = p_id and user_id = me and left_at is null) then raise exception 'tu ne fais pas partie de ce salon'; end if;
  update public.party_players set seen_at = now() where party_id = p_id and user_id = me;
  select * into p from public.parties where id = p_id;
  if p.status = 'lobby' then
    update public.party_players set left_at = now() where party_id = p_id and user_id <> me and left_at is null and seen_at < now() - interval '20 seconds';
    if not exists (select 1 from public.party_players where party_id = p_id and user_id = p.host and left_at is null) then
      update public.parties set host = me where id = p_id; p.host := me;
    end if;
    perform public.party_bots_dose(p_id);
    cnt := public.party_humans(p_id);
    select count(*) into nb from public.party_bots where party_id = p_id and left_at is null;
    if cnt >= p.max_players or (nb > 0 and now() - p.created_at > interval '60 seconds') then
      perform public.party_begin(p_id);
    end if;
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
      for r in select x.uid, x.score, x.place, x.total from (
                 select pp.user_id as uid, pp.score,
                        rank() over (order by s.score desc) as place, count(*) over () as total, s.bot
                   from (select user_id::text as k, score, false as bot from public.party_players where party_id = p_id and left_at is null
                         union all select 'bot' || bot, score, true from public.party_bots where party_id = p_id and left_at is null) s
                   left join public.party_players pp on pp.party_id = p_id and pp.user_id::text = s.k) x
                where not x.bot loop
        perform public.add_stats(r.uid, p.theme,
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
        select pp.user_id::text as id, pr.pseudo, pr.avatar, pr.avatar_url, pr.frame, pp.joined_at, pp.correct, false as bot,
               pp.score - case when ph = 'q' then coalesce(a.points, 0) else 0 end as score,
               a.idx is not null as answered,
               case when ph = 'reveal' then a.points end as pts,
               case when ph = 'reveal' then a.ok end as ok,
               p.status = 'playing' and pp.seen_at < now() - interval '15 seconds' as away
          from public.party_players pp join public.profiles pr on pr.id = pp.user_id
          left join public.party_answers a on a.party_id = pp.party_id and a.user_id = pp.user_id and a.idx = p.cur_idx
         where pp.party_id = p_id and pp.left_at is null
        union all
        select 'bot' || bb.bot, bb.pseudo, bb.avatar, null, null, bb.joined_at, bb.correct, true,
               bb.score - case when ph = 'q' then coalesce(ba.points, 0) else 0 end,
               ba.idx is not null,
               case when ph = 'reveal' then ba.points end,
               case when ph = 'reveal' then ba.ok end,
               false
          from public.party_bots bb
          left join public.party_bot_answers ba on ba.party_id = bb.party_id and ba.bot = bb.bot and ba.idx = p.cur_idx
         where bb.party_id = p_id and bb.left_at is null) x), '[]'::jsonb));
end $$;

revoke execute on function public.party_humans(uuid), public.party_bots_dose(uuid), public.party_bots_play(uuid, boolean) from public, anon, authenticated;
commit;
