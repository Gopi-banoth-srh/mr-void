-- MR VOID database schema v1 (Supabase / PostgreSQL)
-- Run in Supabase: SQL Editor > New query > paste > Run

-- 1. User profile (one row per logged-in user)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  sex text check (sex in ('male', 'female')),
  birth_date date,
  height_cm numeric check (height_cm between 100 and 250),
  activity_level text check (activity_level in
    ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  goal text check (goal in ('fat_loss', 'lean_bulk', 'maintain')),
  created_at timestamptz default now()
);

-- 2. Foods (nutrition values are per 100 g)
create table foods (
  id bigint generated always as identity primary key,
  name text not null,
  name_local text,                      -- e.g. Hindi / Gujarati name
  source text not null default 'manual', -- 'usda', 'openfoodfacts', 'manual'
  calories_kcal numeric not null check (calories_kcal >= 0),
  protein_g numeric not null default 0,
  carbs_g numeric not null default 0,
  fat_g numeric not null default 0,
  fiber_g numeric default 0,
  verified boolean not null default false,
  created_at timestamptz default now()
);
create index foods_name_idx on foods (lower(name));

-- 3. Portion helpers, e.g. "1 roti" = 40 g, "1 katori dal" = 150 g
create table food_portions (
  id bigint generated always as identity primary key,
  food_id bigint not null references foods(id) on delete cascade,
  label text not null,
  grams numeric not null check (grams > 0)
);

-- 4. Meal logs
create table meal_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  food_id bigint not null references foods(id),
  grams numeric not null check (grams > 0),
  meal_type text not null check (meal_type in
    ('breakfast', 'lunch', 'dinner', 'snack')),
  logged_at timestamptz not null default now()
);
create index meal_logs_user_time_idx on meal_logs (user_id, logged_at);

-- 5. Weight and water logs
create table weight_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  weight_kg numeric not null check (weight_kg between 20 and 400),
  logged_at timestamptz not null default now()
);

create table water_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount_ml integer not null check (amount_ml > 0),
  logged_at timestamptz not null default now()
);

-- 6. Row Level Security: users can only see and edit their own data
alter table profiles enable row level security;
alter table meal_logs enable row level security;
alter table weight_logs enable row level security;
alter table water_logs enable row level security;
alter table foods enable row level security;
alter table food_portions enable row level security;

create policy "own profile" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);
create policy "own meals" on meal_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own weight" on weight_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own water" on water_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Food data is shared: any logged-in user can read it, nobody can edit it from the app
create policy "read foods" on foods
  for select using (auth.role() = 'authenticated');
create policy "read portions" on food_portions
  for select using (auth.role() = 'authenticated');

-- 7. A few sample foods to test with (values per 100 g, approximate)
insert into foods (name, name_local, source, calories_kcal, protein_g, carbs_g, fat_g, fiber_g)
values
  ('Roti (wheat chapati)', 'रोटी', 'manual', 297, 9.8, 51, 6.7, 11),
  ('Cooked white rice', 'चावल', 'manual', 130, 2.7, 28, 0.3, 0.4),
  ('Boiled egg', 'अंडा', 'manual', 155, 13, 1.1, 11, 0);

insert into food_portions (food_id, label, grams)
select id, '1 roti', 40 from foods where name like 'Roti%'
union all
select id, '1 katori', 150 from foods where name like 'Cooked white rice%'
union all
select id, '1 egg', 50 from foods where name = 'Boiled egg';