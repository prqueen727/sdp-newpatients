-- 성동필한방병원 · 소개 관리 표
-- schema.sql 을 먼저 실행한 뒤, 이 파일 전체를 SQL Editor 에 붙여넣고 Run 하세요.

-- 사람 (소개자와 소개받은 환자 모두): 차트번호 1개 = 1명
create table if not exists public.people (
  id         uuid primary key default gen_random_uuid(),
  chart_no   text not null unique,
  name       text not null,
  created_at timestamptz not null default now()
);

-- 소개 기록: 소개받은 환자 1명당 소개자 1명
create table if not exists public.referrals (
  id            uuid primary key default gen_random_uuid(),
  referrer_id   uuid not null references public.people(id) on delete restrict,
  referred_id   uuid not null unique references public.people(id) on delete cascade,
  relation      text not null,
  referred_date date not null,
  visit_id      uuid references public.visits(id) on delete set null,
  memo          text not null default '',
  created_at    timestamptz not null default now(),
  check (referrer_id <> referred_id)
);
create index if not exists referrals_referrer_idx on public.referrals (referrer_id);
create index if not exists referrals_date_idx on public.referrals (referred_date);

alter table public.people    enable row level security;
alter table public.referrals enable row level security;

drop policy if exists "staff all" on public.people;
drop policy if exists "staff all" on public.referrals;
create policy "staff all" on public.people    for all to authenticated using (public.is_staff()) with check (public.is_staff());
create policy "staff all" on public.referrals for all to authenticated using (public.is_staff()) with check (public.is_staff());

-- 소개 등록 (사람 등록 + 소개 기록을 한 번에). 이미 있는 차트번호는 이름을 바꾸지 않고 그 사람을 씀
create or replace function public.add_referral(
  p_referred_chart text, p_referred_name text,
  p_referrer_chart text, p_referrer_name text,
  p_relation text, p_date date,
  p_visit_id uuid default null, p_memo text default ''
) returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_referrer uuid; v_referred uuid; v_id uuid;
begin
  if not public.is_staff() then raise exception 'NOT_ALLOWED'; end if;
  p_referred_chart := trim(p_referred_chart); p_referrer_chart := trim(p_referrer_chart);
  if p_referred_chart = '' or p_referrer_chart = '' then raise exception 'MISSING'; end if;
  if p_referred_chart = p_referrer_chart then raise exception 'SELF'; end if;

  insert into people (chart_no, name) values (p_referrer_chart, trim(p_referrer_name))
    on conflict (chart_no) do update set chart_no = excluded.chart_no
    returning id into v_referrer;
  insert into people (chart_no, name) values (p_referred_chart, trim(p_referred_name))
    on conflict (chart_no) do update set chart_no = excluded.chart_no
    returning id into v_referred;

  if exists (select 1 from referrals where referred_id = v_referred) then raise exception 'DUP_REFERRED'; end if;

  insert into referrals (referrer_id, referred_id, relation, referred_date, visit_id, memo)
    values (v_referrer, v_referred, p_relation, p_date, p_visit_id, coalesce(p_memo, ''))
    returning id into v_id;
  return v_id;
end;
$$;
