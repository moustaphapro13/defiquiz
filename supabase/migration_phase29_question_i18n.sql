-- Défi Quiz · phase 29 : traductions des questions
begin;
create table if not exists public.question_i18n (
  question_id bigint not null,
  lang text not null,
  question text not null,
  answer text not null,
  wrong text[] not null,
  primary key (question_id, lang)
);
alter table public.question_i18n enable row level security;

-- Traductions d'une liste de questions : { "id": {"q":…, "a":…, "w":[…]} }
create or replace function public.get_question_i18n(p_ids bigint[], p_lang text) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_object_agg(t.question_id::text, jsonb_build_object('q', t.question, 'a', t.answer, 'w', to_jsonb(t.wrong), 'oa', q.answer, 'ow', to_jsonb(q.wrong))), '{}'::jsonb)
    from public.question_i18n t join public.questions q on q.id = t.question_id
   where t.lang = p_lang and t.question_id = any(p_ids[1:60]);
$$;
grant execute on function public.get_question_i18n(bigint[], text) to anon, authenticated;

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
  return jsonb_build_object('idx', p_idx, 'id', q.id, 'question', q.question, 'theme', q.theme, 'difficulty', q.difficulty,
    'options', (select jsonb_agg(o order by md5(o || p_id::text)) from unnest(q.wrong || q.answer) o),
    'answer', case when now() >= t0 + make_interval(secs => p.q_secs) then q.answer end,
    'mine', (select choice from public.party_answers where party_id = p_id and user_id = me and idx = p_idx));
end $$;

commit;
