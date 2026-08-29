-- SF9 CLOUD DATABASE
-- Run this in Supabase SQL Editor.
-- This design stores each learner as one JSONB record, so it maps cleanly
-- to the current HTML data model while keeping every user's rows isolated.

create table if not exists public.sf9_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  school_name text not null default 'LOOC II NATIONAL HIGH SCHOOL',
  principal text not null default 'LENIN P. RODRIGUEZ',
  cluster text not null default '3',
  adviser text not null default 'RAZHEL T. DELOS SANTOS',
  section text not null default 'Maxwell',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sf9_records (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  record jsonb not null,
  updated_at timestamptz not null default now()
);

create index if not exists sf9_records_user_id_idx on public.sf9_records(user_id);

alter table public.sf9_profiles enable row level security;
alter table public.sf9_records enable row level security;

drop policy if exists "profiles owner select" on public.sf9_profiles;
create policy "profiles owner select"
on public.sf9_profiles for select to authenticated
using ((select auth.uid()) = id);

drop policy if exists "profiles owner insert" on public.sf9_profiles;
create policy "profiles owner insert"
on public.sf9_profiles for insert to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "profiles owner update" on public.sf9_profiles;
create policy "profiles owner update"
on public.sf9_profiles for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "records owner select" on public.sf9_records;
create policy "records owner select"
on public.sf9_records for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "records owner insert" on public.sf9_records;
create policy "records owner insert"
on public.sf9_records for insert to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "records owner update" on public.sf9_records;
create policy "records owner update"
on public.sf9_records for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "records owner delete" on public.sf9_records;
create policy "records owner delete"
on public.sf9_records for delete to authenticated
using ((select auth.uid()) = user_id);

-- Allow the authenticated client role to use these tables through the Data API.
grant select, insert, update, delete on public.sf9_profiles to authenticated;
grant select, insert, update, delete on public.sf9_records to authenticated;

-- Create a profile automatically when a new auth user registers.
create or replace function public.handle_new_sf9_profile()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.sf9_profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_sf9 on auth.users;
create trigger on_auth_user_created_sf9
after insert on auth.users
for each row execute procedure public.handle_new_sf9_profile();

-- Optional: keep updated_at current when a profile is edited.
create or replace function public.touch_sf9_profile()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists sf9_profiles_touch on public.sf9_profiles;
create trigger sf9_profiles_touch
before update on public.sf9_profiles
for each row execute procedure public.touch_sf9_profile();
