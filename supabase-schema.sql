-- SIGMA ROUTINE 2.0 - Supabase database schema
-- Run in Supabase: SQL Editor -> New query -> paste -> Run.
-- Passwords are handled by Supabase Auth; never store plain-text passwords here.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null unique,
  xp integer not null default 0 check (xp >= 0),
  level integer not null default 1 check (level >= 1),
  total_tasks integer not null default 0 check (total_tasks >= 0),
  streak integer not null default 0 check (streak >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.routine_days (
  user_id uuid not null references auth.users(id) on delete cascade,
  day date not null,
  checks jsonb not null default '[]'::jsonb,
  completed_tasks integer not null default 0 check (completed_tasks >= 0),
  xp_earned integer not null default 0 check (xp_earned >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, day),
  check (jsonb_typeof(checks) = 'array')
);

alter table public.profiles enable row level security;
alter table public.routine_days enable row level security;

drop policy if exists "Profiles are visible for leaderboard" on public.profiles;
create policy "Profiles are visible for leaderboard"
on public.profiles for select using (true);

drop policy if exists "Users can create own profile" on public.profiles;
create policy "Users can create own profile"
on public.profiles for insert to authenticated
with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles for update to authenticated
using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can read own routine days" on public.routine_days;
create policy "Users can read own routine days"
on public.routine_days for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can add own routine days" on public.routine_days;
create policy "Users can add own routine days"
on public.routine_days for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update own routine days" on public.routine_days;
create policy "Users can update own routine days"
on public.routine_days for update to authenticated
using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index if not exists profiles_leaderboard_xp_idx
on public.profiles (xp desc, level desc);
