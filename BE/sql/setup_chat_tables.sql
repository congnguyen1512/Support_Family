begin;

create table if not exists public.chat_message (
  id bigserial primary key,
  relationship_id bigint not null,
  sender_uid uuid not null,
  receiver_uid uuid not null,
  content text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_chat_message_pair_created
  on public.chat_message (sender_uid, receiver_uid, created_at desc);

create table if not exists public.chat_presence (
  uid uuid primary key,
  active_peer_uid uuid null,
  updated_at timestamptz not null default now()
);

alter table public.chat_message enable row level security;
alter table public.chat_presence enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='chat_message' and policyname='chat_message_select_own'
  ) then
    create policy chat_message_select_own on public.chat_message
      for select to authenticated
      using (sender_uid = auth.uid() or receiver_uid = auth.uid());
  end if;
end $$;

do $$
begin
  begin
    alter publication supabase_realtime add table public.chat_message;
  exception when duplicate_object then null;
  end;
end $$;

commit;
