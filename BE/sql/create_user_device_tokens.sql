create table if not exists public.user_device_tokens (
  id bigserial primary key,
  uid uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text null,
  device_id text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_device_tokens_uid_idx
  on public.user_device_tokens(uid);

alter table public.user_device_tokens enable row level security;

drop policy if exists "Users can manage own device tokens" on public.user_device_tokens;
create policy "Users can manage own device tokens"
  on public.user_device_tokens
  for all
  using (auth.uid() = uid)
  with check (auth.uid() = uid);
