-- Sam Solar — canonical Supabase schema
-- 12 core application tables + 2 auxiliary tables required by implemented features.
create extension if not exists pgcrypto;

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name_ar text not null,
  image_url text,
  sort_order integer not null default 0
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name_ar text not null,
  description_ar text,
  logo_url text,
  phone text,
  address_ar text,
  is_active boolean not null default true,
  sort_order integer not null default 0
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name_ar text not null,
  description_ar text,
  price numeric not null default 0,
  category_id uuid references public.categories(id) on delete set null,
  image_url text,
  brand_ar text,
  model text,
  specifications_ar text,
  warranty_ar text,
  is_available boolean not null default true,
  is_featured boolean not null default false,
  is_best_seller boolean not null default false,
  sort_order integer not null default 0,
  supplier_id uuid references public.suppliers(id) on delete set null
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  full_name_ar text,
  phone text,
  email text,
  user_id uuid unique references auth.users(id) on delete cascade,
  is_active boolean not null default true
);

create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null,
  phone text not null,
  city text not null,
  area text,
  street_address text not null,
  details text,
  is_default boolean not null default false
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid references auth.users(id) on delete set null,
  address_id uuid references public.addresses(id) on delete set null,
  total_amount numeric not null default 0,
  status text not null default 'pending' check(status in ('pending','confirmed','shipped','delivered','cancelled')),
  payment_method text,
  payment_status text,
  notes text,
  cod_approved boolean not null default false
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  quantity integer not null default 1 check(quantity > 0),
  unit_price numeric not null default 0
);

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  quantity integer not null default 1 check(quantity > 0),
  unique(user_id, product_id)
);

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  unique(user_id, product_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid references auth.users(id) on delete cascade,
  title_ar text not null,
  message_ar text,
  is_read boolean not null default false,
  order_id uuid references public.orders(id) on delete set null,
  type text
);

create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  sort_order integer not null default 0
);

create table if not exists public.search_history (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  user_id uuid not null references auth.users(id) on delete cascade,
  query_text text not null
);

-- Required because the application has a real Offers section with its own old/offer price.
create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  product_id uuid not null references public.products(id) on delete cascade,
  old_price numeric not null check(old_price >= 0),
  offer_price numeric not null check(offer_price >= 0),
  title_ar text,
  description_ar text,
  start_at timestamptz not null,
  end_at timestamptz not null,
  is_active boolean not null default true,
  check(end_at > start_at)
);

-- Required only for secure database-side admin/editor/viewer permissions.
create table if not exists public.admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'viewer' check(role in ('admin_super','admin','editor','viewer')),
  created_at timestamptz not null default now()
);

create index if not exists products_category_id_idx on public.products(category_id);
create index if not exists products_supplier_id_idx on public.products(supplier_id);
create index if not exists orders_user_id_idx on public.orders(user_id);
create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists offers_product_id_idx on public.offers(product_id);
create index if not exists offers_active_dates_idx on public.offers(is_active,start_at,end_at);

alter table public.categories enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.customers enable row level security;
alter table public.addresses enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.cart_items enable row level security;
alter table public.favorites enable row level security;
alter table public.notifications enable row level security;
alter table public.product_images enable row level security;
alter table public.search_history enable row level security;
alter table public.offers enable row level security;
alter table public.admin_roles enable row level security;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$
  select exists(
    select 1 from public.admin_roles
    where user_id=auth.uid()
      and role in ('admin_super','admin','editor','viewer')
  );
$$;

create policy "public read categories" on public.categories for select using(true);
create policy "admin manage categories" on public.categories for all using(public.is_admin()) with check(public.is_admin());
create policy "public read products" on public.products for select using(true);
create policy "admin manage products" on public.products for all using(public.is_admin()) with check(public.is_admin());
create policy "public read suppliers" on public.suppliers for select using(true);
create policy "admin manage suppliers" on public.suppliers for all using(public.is_admin()) with check(public.is_admin());
create policy "public read product images" on public.product_images for select using(true);
create policy "admin manage product images" on public.product_images for all using(public.is_admin()) with check(public.is_admin());
create policy "public read active offers" on public.offers for select using(is_active=true and now() between start_at and end_at);
create policy "admin manage offers" on public.offers for all using(public.is_admin()) with check(public.is_admin());
create policy "own customer" on public.customers for select using(user_id=auth.uid() or public.is_admin());
create policy "own customer insert" on public.customers for insert with check(user_id=auth.uid());
create policy "own customer update" on public.customers for update using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
create policy "own addresses" on public.addresses for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "own cart" on public.cart_items for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "own favorites" on public.favorites for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "orders owner or admin" on public.orders for select using(user_id=auth.uid() or public.is_admin());
create policy "orders create" on public.orders for insert with check(user_id=auth.uid());
create policy "orders admin update" on public.orders for update using(public.is_admin()) with check(public.is_admin());
create policy "order items owner or admin" on public.order_items for select using(exists(select 1 from public.orders o where o.id=order_id and (o.user_id=auth.uid() or public.is_admin())));
create policy "order items create" on public.order_items for insert with check(exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()));
create policy "own notifications" on public.notifications for select using(user_id=auth.uid() or public.is_admin());
create policy "admin manage notifications" on public.notifications for all using(public.is_admin()) with check(public.is_admin());
create policy "own search history" on public.search_history for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "admin roles read" on public.admin_roles for select using(user_id=auth.uid() or public.is_admin());
create policy "admin roles manage" on public.admin_roles for all using(public.is_admin()) with check(public.is_admin());

insert into public.categories(name_ar,image_url,sort_order)
select v.name_ar,v.image_url,v.sort_order
from (values
  ('الألواح',null,1),
  ('المحولات',null,2),
  ('البطاريات',null,3),
  ('الملحقات',null,4),
  ('المنظومات الجاهزة',null,5)
) v(name_ar,image_url,sort_order)
where not exists(select 1 from public.categories);
