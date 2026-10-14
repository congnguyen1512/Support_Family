alter table public.user_locations
add column if not exists address text,
add column if not exists street text,
add column if not exists ward text,
add column if not exists district text,
add column if not exists city text,
add column if not exists country text,
add column if not exists place_name text;

alter table public.location_history
add column if not exists address text,
add column if not exists street text,
add column if not exists ward text,
add column if not exists district text,
add column if not exists city text,
add column if not exists country text,
add column if not exists place_name text;
