-- Défi Quiz · phase 30 : stories (24 h, visibles par les amis)
begin;
create table if not exists public.stories (
  id bigint generated always as identity primary key,
  user_id uuid not null,
  kind text not null check (kind in ('photo', 'text')),
  image text,
  body text check (char_length(body) <= 200),
  bg text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '24 hours'
);
create index if not exists stories_user_idx on public.stories(user_id, expires_at);
create table if not exists public.story_views (
  story_id bigint not null,
  user_id uuid not null,
  seen_at timestamptz not null default now(),
  primary key (story_id, user_id)
);
alter table public.stories enable row level security;
alter table public.story_views enable row level security;

create or replace function public.post_story(p_kind text, p_image text, p_body text, p_bg text) returns bigint
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); sid bigint;
begin
  perform public.assert_active(me);
  if p_kind not in ('photo', 'text') then raise exception 'story invalide'; end if;
  if p_kind = 'photo' and (p_image is null or p_image !~ ('^' || me::text || '/story_[A-Za-z0-9_.-]{1,60}\.(jpg|jpeg|png|webp)$')) then
    raise exception 'photo invalide';
  end if;
  if p_kind = 'text' and char_length(trim(coalesce(p_body, ''))) < 1 then raise exception 'écris quelque chose'; end if;
  if (select count(*) from public.stories where user_id = me and created_at > now() - interval '24 hours') >= 15 then
    raise exception 'maximum 15 stories par jour';
  end if;
  insert into public.stories(user_id, kind, image, body, bg)
  values (me, p_kind, case when p_kind = 'photo' then p_image end, left(nullif(trim(p_body), ''), 200), left(coalesce(p_bg, ''), 30))
  returning id into sid;
  return sid;
end $$;

-- Stories en cours : les miennes d'abord, puis celles des amis (non vues d'abord)
create or replace function public.story_feed() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  with me as (select auth.uid() as id),
  authors as (
    select (select id from me) as uid
    union
    select case when f.requester = (select id from me) then f.addressee else f.requester end
      from public.friendships f
     where f.status = 'accepted' and (select id from me) in (f.requester, f.addressee)
  ),
  s as (
    select st.*, exists (select 1 from public.story_views v where v.story_id = st.id and v.user_id = (select id from me)) as seen
      from public.stories st join authors a on a.uid = st.user_id
     where st.expires_at > now()
  ),
  g as (
    select s.user_id,
           jsonb_agg(jsonb_build_object('id', s.id, 'kind', s.kind, 'image', s.image, 'body', s.body, 'bg', s.bg,
                     'created_at', s.created_at, 'seen', s.seen) order by s.created_at) as items,
           bool_and(s.seen) as all_seen, max(s.created_at) as last
      from s group by s.user_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'user', jsonb_build_object('id', p.id, 'pseudo', p.pseudo, 'avatar', p.avatar, 'avatar_url', p.avatar_url, 'frame', p.frame),
           'mine', g.user_id = (select id from me), 'all_seen', g.all_seen, 'stories', g.items)
         order by (g.user_id = (select id from me)) desc, g.all_seen, g.last desc), '[]'::jsonb)
    from g join public.profiles p on p.id = g.user_id;
$$;

create or replace function public.view_story(p_id bigint) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare me uuid := auth.uid(); owner uuid;
begin
  select user_id into owner from public.stories where id = p_id and expires_at > now();
  if owner is null or owner = me then return; end if;
  if not public.are_friends(me, owner) then return; end if;
  insert into public.story_views(story_id, user_id) values (p_id, me) on conflict do nothing;
end $$;

create or replace function public.story_viewers(p_id bigint) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', p.id, 'pseudo', p.pseudo, 'avatar', p.avatar, 'avatar_url', p.avatar_url, 'frame', p.frame) order by v.seen_at desc), '[]'::jsonb)
    from public.story_views v join public.profiles p on p.id = v.user_id
   where v.story_id = p_id and exists (select 1 from public.stories s where s.id = p_id and s.user_id = auth.uid());
$$;

-- Retirer une story : elle expire tout de suite
create or replace function public.remove_story(p_id bigint) returns text
language plpgsql security definer set search_path = public, pg_temp as $$
declare img text;
begin
  update public.stories set expires_at = now() where id = p_id and user_id = auth.uid() returning image into img;
  return img;
end $$;

grant execute on function public.post_story(text, text, text, text), public.story_feed(), public.view_story(bigint),
  public.story_viewers(bigint), public.remove_story(bigint) to authenticated;
commit;
