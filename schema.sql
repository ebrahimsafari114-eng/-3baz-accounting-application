-- 3baz accounting v2: run in Supabase SQL Editor.
-- This starter schema enables row-level security but is NOT production-ready authentication.
-- For real deployment, add Supabase Auth and restrict rows by authenticated user/company_id.
create extension if not exists pgcrypto;
create table if not exists public.projects (
 id uuid primary key default gen_random_uuid(),
 name text not null, location text default '', partner text default '',
 share numeric(5,2) not null default 0 check (share >= 0 and share <= 100),
 setup numeric(16,2) not null default 0 check (setup >= 0),
 status text not null default 'فعال',
 created_at timestamptz not null default now()
);
create table if not exists public.contracts (
 id uuid primary key default gen_random_uuid(),
 title text not null, client text not null,
 project_id uuid references public.projects(id) on delete set null,
 amount numeric(16,2) not null default 0 check (amount >= 0),
 paid numeric(16,2) not null default 0 check (paid >= 0),
 start_date text default '', end_date text default '',
 created_at timestamptz not null default now()
);
create table if not exists public.transactions (
 id uuid primary key default gen_random_uuid(),
 kind text not null check (kind in ('income','expense')),
 amount numeric(16,2) not null check (amount > 0),
 description text not null, project_id uuid references public.projects(id) on delete set null,
 date text not null, category text not null default 'سایر',
 paid boolean not null default true,
 created_at timestamptz not null default now()
);
alter table public.projects enable row level security;
alter table public.contracts enable row level security;
alter table public.transactions enable row level security;
-- Demo-only policies for initial smoke test. They allow public access to data!
-- Replace these before putting any real company data online.
create policy "demo projects public read" on public.projects for select using (true);
create policy "demo projects public insert" on public.projects for insert with check (true);
create policy "demo projects public update" on public.projects for update using (true) with check (true);
create policy "demo projects public delete" on public.projects for delete using (true);
create policy "demo contracts public read" on public.contracts for select using (true);
create policy "demo contracts public insert" on public.contracts for insert with check (true);
create policy "demo contracts public update" on public.contracts for update using (true) with check (true);
create policy "demo contracts public delete" on public.contracts for delete using (true);
create policy "demo transactions public read" on public.transactions for select using (true);
create policy "demo transactions public insert" on public.transactions for insert with check (true);
create policy "demo transactions public update" on public.transactions for update using (true) with check (true);
create policy "demo transactions public delete" on public.transactions for delete using (true);
