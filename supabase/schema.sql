-- 성동필한방병원 초진 통계 · Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에 전체를 붙여넣고 Run 하세요.
-- 맨 아래 staff 이메일은 Authentication 에서 만든 직원 계정 이메일로 바꾸세요.

create table if not exists public.visits (
  id            uuid primary key default gen_random_uuid(),
  visit_date    date not null,
  visit_type    text not null check (visit_type in ('외래','입원')),
  region_group  text not null,
  region_detail text not null default '',
  motives       text[] not null default '{}',
  clinics       text[] not null default '{}',
  created_at    timestamptz not null default now(),
  created_by    uuid default auth.uid()
);
create index if not exists visits_visit_date_idx on public.visits (visit_date);

-- 접속을 허용할 계정 목록 (비밀번호 로그인한 계정만 데이터 접근)
create table if not exists public.staff (
  email text primary key
);
alter table public.staff enable row level security;  -- 정책 없음 = 외부에서 읽기/쓰기 불가

create or replace function public.is_staff()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from public.staff where email = (auth.jwt() ->> 'email'));
$$;

alter table public.visits enable row level security;

drop policy if exists "staff read"   on public.visits;
drop policy if exists "staff insert" on public.visits;
drop policy if exists "staff delete" on public.visits;
create policy "staff read"   on public.visits for select to authenticated using (public.is_staff());
create policy "staff insert" on public.visits for insert to authenticated with check (public.is_staff());
create policy "staff delete" on public.visits for delete to authenticated using (public.is_staff());

-- ▼ 직원 계정 이메일 (index.html 의 STAFF_EMAIL 과 같아야 함)
insert into public.staff (email) values ('staff@sdphil.local')
on conflict do nothing;
