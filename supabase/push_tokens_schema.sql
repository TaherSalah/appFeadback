-- ================================================
-- جدول push_tokens لحفظ Push Tokens الخاصة بكل جهاز
-- يدعم FCM (Android/iOS) و HMS (Huawei)
-- ================================================

create table if not exists push_tokens (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  token         text not null,
  provider      text not null check (provider in ('fcm', 'hms', 'apns', 'none')),
  platform      text not null check (platform in ('android', 'huawei', 'ios')),
  app_version   text,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  -- يمنع تكرار نفس الـ Token لنفس المستخدم
  unique (user_id, token)
);

-- Index للبحث السريع بالـ user_id
create index if not exists idx_push_tokens_user_id
  on push_tokens (user_id)
  where is_active = true;

-- Index على الـ token للبحث الفعال
create index if not exists idx_push_tokens_token
  on push_tokens (token);

-- ================================================
-- RLS (Row Level Security)
-- المستخدم يرى ويعدل tokens الخاصة به فقط
-- ================================================

alter table push_tokens enable row level security;

-- المستخدم يقرأ tokens الخاصة به
create policy "users_read_own_tokens"
  on push_tokens for select
  using (auth.uid() = user_id);

-- المستخدم يُدرج token لنفسه
create policy "users_insert_own_tokens"
  on push_tokens for insert
  with check (auth.uid() = user_id);

-- المستخدم يُحدّث token الخاص به
create policy "users_update_own_tokens"
  on push_tokens for update
  using (auth.uid() = user_id);

-- ================================================
-- RPC Function: upsert_push_token
-- تُدرج token جديد أو تُحدّث الموجود
-- تُستدعى من التطبيق عند الحصول على Token
-- ================================================

create or replace function upsert_push_token(
  p_user_id    uuid,
  p_token      text,
  p_provider   text,
  p_platform   text,
  p_app_version text default null
)
returns void
language plpgsql
security definer  -- يتجاوز RLS ليعمل بشكل موثوق
as $$
begin
  insert into push_tokens (user_id, token, provider, platform, app_version, is_active, updated_at)
  values (p_user_id, p_token, p_provider, p_platform, p_app_version, true, now())
  on conflict (user_id, token)
  do update set
    provider    = excluded.provider,
    platform    = excluded.platform,
    app_version = excluded.app_version,
    is_active   = true,
    updated_at  = now();
end;
$$;

-- ================================================
-- RPC Function: deactivate_push_token
-- تُلغي تفعيل Token عند تسجيل الخروج
-- لا تحذفه — نحتفظ بالسجل
-- ================================================

create or replace function deactivate_push_token(
  p_user_id uuid,
  p_token   text
)
returns void
language plpgsql
security definer
as $$
begin
  update push_tokens
  set    is_active  = false,
         updated_at = now()
  where  user_id = p_user_id
    and  token   = p_token;
end;
$$;

-- ================================================
-- تحديث updated_at تلقائياً
-- ================================================

create or replace function update_push_tokens_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_push_tokens_updated_at
  before update on push_tokens
  for each row
  execute function update_push_tokens_updated_at();
