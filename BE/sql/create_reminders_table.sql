-- ============================================================
-- Table: public.reminders
-- Feature: Lịch nhắc (General Family Reminders)
-- Supports: Medicine, Food, Health, Custom reminders for any member
-- ============================================================

begin;

create table if not exists public.reminders (
  id            bigserial primary key,
  owner_uid     uuid not null references public.user_info(uid) on delete cascade,
  member_uid    uuid not null references public.user_info(uid) on delete cascade,
  title         text not null,
  subtitle      text,
  category      text not null default 'other'
                check (category in ('medicine', 'food', 'health', 'other')),
  reminder_time text not null, -- 'HH:mm', e.g., '08:00'
  schedule_type text not null default 'daily'
                check (schedule_type in ('daily', 'weekly', 'once', 'custom')),
  schedule_date date,
  weekdays      int[] not null default '{}',
  is_active     boolean not null default true,
  voice_url     text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists idx_reminders_owner_uid on public.reminders (owner_uid);
create index if not exists idx_reminders_member_uid on public.reminders (member_uid);
create index if not exists idx_reminders_active on public.reminders (is_active);

-- Enable RLS (Service role and authenticated access)
alter table public.reminders enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'reminders' and policyname = 'reminders_all_authenticated'
  ) then
    create policy reminders_all_authenticated on public.reminders
      for all to authenticated
      using (true)
      with check (true);
  end if;
end $$;

-- Enable Supabase Realtime for reminders
do $$
begin
  begin
    alter publication supabase_realtime add table public.reminders;
  exception when duplicate_object then null;
  end;
end $$;

commit;
