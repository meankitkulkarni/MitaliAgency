create or replace function public.mb_touch_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.mb_products (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_merchants (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_orders (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_expenses (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_stock_entries (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_trays (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_opening_balances (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.mb_daily_dsr_snapshots (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'mb_products',
    'mb_merchants',
    'mb_orders',
    'mb_expenses',
    'mb_stock_entries',
    'mb_trays',
    'mb_opening_balances',
    'mb_daily_dsr_snapshots'
  ]
  loop
    execute format('alter table public.%I replica identity full', table_name);
    execute format('alter table public.%I enable row level security', table_name);
    execute format('drop trigger if exists mb_touch_updated_at on public.%I', table_name);
    execute format('create trigger mb_touch_updated_at before update on public.%I for each row execute function public.mb_touch_updated_at()', table_name);
    execute format('grant select, insert, update on public.%I to anon, authenticated', table_name);
    execute format('revoke delete, truncate on public.%I from anon, authenticated', table_name);

    execute format('drop policy if exists "ModernBread read active rows" on public.%I', table_name);
    execute format('drop policy if exists "ModernBread insert rows" on public.%I', table_name);
    execute format('drop policy if exists "ModernBread update rows" on public.%I', table_name);

    execute format('create policy "ModernBread read active rows" on public.%I for select to anon, authenticated using (deleted_at is null)', table_name);
    execute format('create policy "ModernBread insert rows" on public.%I for insert to anon, authenticated with check (deleted_at is null)', table_name);
    if table_name = 'mb_daily_dsr_snapshots' then
      execute format('create policy "ModernBread update rows" on public.%I for update to anon, authenticated using (deleted_at is null and not (data ? ''lockedAt'')) with check (data is not null)', table_name);
    else
      execute format('create policy "ModernBread update rows" on public.%I for update to anon, authenticated using (deleted_at is null) with check (data is not null)', table_name);
    end if;

    if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
       and not exists (
         select 1
         from pg_publication_tables
         where pubname = 'supabase_realtime'
           and schemaname = 'public'
           and tablename = table_name
       ) then
      execute format('alter publication supabase_realtime add table public.%I', table_name);
    end if;
  end loop;
end;
$$;

grant delete on public.mb_orders to anon, authenticated;
grant delete on public.mb_expenses to anon, authenticated;

drop policy if exists "ModernBread delete active rows" on public.mb_orders;
drop policy if exists "ModernBread delete active rows" on public.mb_expenses;

create policy "ModernBread delete active rows" on public.mb_orders
  for delete to anon, authenticated
  using (deleted_at is null);

create policy "ModernBread delete active rows" on public.mb_expenses
  for delete to anon, authenticated
  using (deleted_at is null);

do $$
begin
  if exists (select 1 from information_schema.tables where table_schema = 'public' and table_name = 'mb_documents') then
    insert into public.mb_products (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'products'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_merchants (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'merchants'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_orders (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'orders'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_expenses (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'expenses'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_stock_entries (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'stockEntries'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_trays (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'trays'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;

    insert into public.mb_opening_balances (id, data, created_at, updated_at)
    select id, data, created_at, updated_at from public.mb_documents where collection = 'openingBal'
    on conflict (id) do update set data = excluded.data, updated_at = now(), deleted_at = null;
  end if;
end;
$$;
