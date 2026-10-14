-- Adds the retained fall-location snapshot columns to public.notification

alter table public.notification
  add column if not exists fall_latitude double precision,
  add column if not exists fall_longitude double precision;