-- FamilyGuard location + safe zone setup
-- Run this script in Supabase SQL Editor.

begin;

create table if not exists public.user_locations (
  uid uuid primary key references public.user_info(uid) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy double precision,
  speed double precision,
  address text,
  street text,
  ward text,
  district text,
  city text,
  country text,
  place_name text,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.location_history (
  id bigint generated always as identity primary key,
  uid uuid not null references public.user_info(uid) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  accuracy double precision,
  speed double precision,
  address text,
  street text,
  ward text,
  district text,
  city text,
  country text,
  place_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.safe_zones (
  id bigint generated always as identity primary key,
  owner_uid uuid not null references public.user_info(uid) on delete cascade,
  target_uid uuid not null references public.user_info(uid) on delete cascade,
  name text not null,
  center_latitude double precision not null,
  center_longitude double precision not null,
  radius_meters integer not null check (radius_meters > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.safe_zone_states (
  id bigint generated always as identity primary key,
  safe_zone_id bigint not null references public.safe_zones(id) on delete cascade,
  uid uuid not null references public.user_info(uid) on delete cascade,
  is_inside boolean not null,
  last_checked_at timestamptz not null default now(),
  last_notified_at timestamptz,
  unique (safe_zone_id, uid)
);

create index if not exists idx_location_history_uid_created_at
  on public.location_history(uid, created_at desc);

create index if not exists idx_safe_zones_owner_uid
  on public.safe_zones(owner_uid);

create index if not exists idx_safe_zones_target_uid
  on public.safe_zones(target_uid);

create index if not exists idx_safe_zones_target_uid_active
  on public.safe_zones(target_uid, is_active);

create index if not exists idx_safe_zone_states_uid
  on public.safe_zone_states(uid);

alter table public.user_locations replica identity full;
alter table public.safe_zones replica identity full;

alter table public.user_locations enable row level security;
alter table public.location_history enable row level security;
alter table public.safe_zones enable row level security;
alter table public.safe_zone_states enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_locations'
      and policyname = 'user_locations_select_own_uid'
  ) then
    create policy user_locations_select_own_uid
      on public.user_locations
      for select
      to authenticated
      using (uid = auth.uid());
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'location_history'
      and policyname = 'location_history_select_own_uid'
  ) then
    create policy location_history_select_own_uid
      on public.location_history
      for select
      to authenticated
      using (uid = auth.uid());
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'safe_zones'
      and policyname = 'safe_zones_select_owner_or_target'
  ) then
    create policy safe_zones_select_owner_or_target
      on public.safe_zones
      for select
      to authenticated
      using (owner_uid = auth.uid() or target_uid = auth.uid());
  end if;
end
$$;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'safe_zone_states'
      and policyname = 'safe_zone_states_select_own_uid'
  ) then
    create policy safe_zone_states_select_own_uid
      on public.safe_zone_states
      for select
      to authenticated
      using (uid = auth.uid());
  end if;
end
$$;

do $$
begin
  begin
    alter publication supabase_realtime add table public.user_locations;
  exception
    when duplicate_object then
      null;
  end;

  begin
    alter publication supabase_realtime add table public.safe_zones;
  exception
    when duplicate_object then
      null;
  end;
end
$$;

commit;

-- Optional:
-- If location_history grows too quickly, stop inserting into it from backend
-- instead of dropping the table.
