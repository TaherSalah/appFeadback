-- ══════════════════════════════════════════════════════════════════════════
-- Push Tokens Table — Supabase Schema
-- ══════════════════════════════════════════════════════════════════════════
-- الغرض: تخزين Push Tokens لجميع أجهزة المستخدمين
--        يدعم FCM (Android + iOS) و HMS (Huawei)
--
-- كيفية الاستخدام:
-- 1. شغّل هذا SQL في Supabase SQL Editor
-- 2. سيُنشئ الجدول مع الـ Policies المناسبة
-- ══════════════════════════════════════════════════════════════════════════

-- جدول Push Tokens
CREATE TABLE IF NOT EXISTS push_tokens (
    id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- معرّف المستخدم من auth.users
    user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- الـ Token الفعلي (FCM أو HMS)
    token        TEXT NOT NULL,

    -- نوع الـ Provider: 'fcm' | 'hms' | 'apns'
    provider     TEXT NOT NULL CHECK (provider IN ('fcm', 'hms', 'apns')),

    -- المنصة: 'android' | 'ios' | 'huawei'
    platform     TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'huawei')),

    -- إصدار التطبيق (للتحقق من التوافق)
    app_version  TEXT,

    -- هل هذا الـ Token نشط؟ (يُعيَّن false عند تسجيل الخروج)
    is_active    BOOLEAN NOT NULL DEFAULT true,

    -- توقيتات
    created_at   TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at   TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ──────────────────────────────────────────────────────────────────────────
-- Indexes للأداء
-- ──────────────────────────────────────────────────────────────────────────

-- البحث السريع عن tokens لمستخدم معين
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id
    ON push_tokens(user_id)
    WHERE is_active = true;

-- منع تكرار نفس الـ token لنفس المستخدم
CREATE UNIQUE INDEX IF NOT EXISTS idx_push_tokens_user_token
    ON push_tokens(user_id, token);

-- فهرسة بالـ token مباشرة (للبحث من الـ Backend)
CREATE INDEX IF NOT EXISTS idx_push_tokens_token
    ON push_tokens(token)
    WHERE is_active = true;

-- ──────────────────────────────────────────────────────────────────────────
-- Function: تحديث updated_at تلقائياً
-- ──────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_push_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_push_tokens_updated_at
    BEFORE UPDATE ON push_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_push_tokens_updated_at();

-- ──────────────────────────────────────────────────────────────────────────
-- Row Level Security (RLS)
-- ──────────────────────────────────────────────────────────────────────────
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- المستخدم يستطيع رؤية tokens الخاصة به فقط
CREATE POLICY "Users can view own tokens"
    ON push_tokens FOR SELECT
    USING (auth.uid() = user_id);

-- المستخدم يستطيع إضافة token جديد
CREATE POLICY "Users can insert own token"
    ON push_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- المستخدم يستطيع تحديث token الخاص به فقط
CREATE POLICY "Users can update own token"
    ON push_tokens FOR UPDATE
    USING (auth.uid() = user_id);

-- المستخدم يستطيع حذف token الخاص به
CREATE POLICY "Users can delete own token"
    ON push_tokens FOR DELETE
    USING (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────────────────────
-- Function: Upsert Token (يُستخدم من التطبيق)
-- ──────────────────────────────────────────────────────────────────────────
-- هذه الـ Function تتجنب الإدخال المكرر:
-- - إذا الـ token موجود → يُحدِّث updated_at
-- - إذا الـ token جديد → يُدخل
CREATE OR REPLACE FUNCTION upsert_push_token(
    p_user_id    UUID,
    p_token      TEXT,
    p_provider   TEXT,
    p_platform   TEXT,
    p_app_version TEXT DEFAULT NULL
)
RETURNS push_tokens AS $$
DECLARE
    result push_tokens;
BEGIN
    INSERT INTO push_tokens (user_id, token, provider, platform, app_version, is_active)
    VALUES (p_user_id, p_token, p_provider, p_platform, p_app_version, true)
    ON CONFLICT (user_id, token)
    DO UPDATE SET
        provider    = EXCLUDED.provider,
        platform    = EXCLUDED.platform,
        app_version = EXCLUDED.app_version,
        is_active   = true,
        updated_at  = NOW()
    RETURNING * INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ──────────────────────────────────────────────────────────────────────────
-- Function: إلغاء تفعيل Token عند تسجيل الخروج
-- ──────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION deactivate_push_token(
    p_user_id UUID,
    p_token   TEXT
)
RETURNS VOID AS $$
BEGIN
    UPDATE push_tokens
    SET is_active = false, updated_at = NOW()
    WHERE user_id = p_user_id
      AND token = p_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
