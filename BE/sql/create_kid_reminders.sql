create table if not exists kid_reminder (
  id bigserial primary key,
  owner_uid uuid not null,
  member_uid uuid not null,
  title text not null,
  reminder_time text not null,
  schedule_type text not null default 'daily',
  schedule_date date,
  weekdays int[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists kid_reminder_owner_member_idx
  on kid_reminder (owner_uid, member_uid);

create index if not exists kid_reminder_member_idx
  on kid_reminder (member_uid);

alter table kid_reminder
  add column if not exists schedule_type text not null default 'daily',
  add column if not exists schedule_date date,
  add column if not exists weekdays int[] not null default '{}';
