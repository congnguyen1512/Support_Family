-- Drops the redundant fall snapshot columns from public.notification.
-- Keep only: fall_latitude and fall_longitude.

alter table public.notification
  drop column if exists fall_uid,
  drop column if exists fall_name,
  drop column if exists fall_role,
  drop column if exists fall_avatar,
  drop column if exists fall_phone,
  drop column if exists fall_email,
  drop column if exists fall_accuracy,
  drop column if exists fall_speed,
  drop column if exists fall_address,
  drop column if exists fall_street,
  drop column if exists fall_ward,
  drop column if exists fall_district,
  drop column if exists fall_city,
  drop column if exists fall_country,
  drop column if exists fall_place_name,
  drop column if exists fall_updated_at,
  drop column if exists fall_created_at;