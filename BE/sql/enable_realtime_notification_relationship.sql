-- FamilyGuard Supabase realtime setup
-- Apply this in Supabase SQL Editor for the current project.

begin;

alter table public.notification replica identity full;
alter table public.relationship replica identity full;

alter table public.notification enable row level security;
alter table public.relationship enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'notification'
      and policyname = 'notification_select_own_uid'
  ) then
    create policy notification_select_own_uid
      on public.notification
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
      and tablename = 'relationship'
      and policyname = 'relationship_select_own_uid'
  ) then
    create policy relationship_select_own_uid
      on public.relationship
      for select
      to authenticated
      using (uid = auth.uid());
  end if;
end
$$;

do $$
begin
  begin
    alter publication supabase_realtime add table public.notification;
  exception
    when duplicate_object then
      null;
  end;

  begin
    alter publication supabase_realtime add table public.relationship;
  exception
    when duplicate_object then
      null;
  end;
end
$$;

commit;
