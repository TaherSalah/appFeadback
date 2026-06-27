-- ============================================
-- Rafuiq Elmuslim - إصلاح شامل لصلاحيات قاعدة البيانات
-- ============================================
-- هذا الملف يحل مشاكل RLS على كل الجداول المستخدمة في التطبيق

-- 1. إيقاف RLS على جداول الختمات الجماعية (الحل المؤقت)
ALTER TABLE IF EXISTS community_campaigns DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS community_progress DISABLE ROW LEVEL SECURITY;

-- 2. إيقاف RLS على باقي الجداول الأساسية
ALTER TABLE IF EXISTS app_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS banners DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS feedback DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS app_updates DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS app_features DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS error_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS app_usage DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS feature_usage DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notifications_log DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS app_content DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS charity_stories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS kids_stories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS custom_radios DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_mosques DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS pdf_books DISABLE ROW LEVEL SECURITY;

-- 3. مسح الجداول القديمة المكررة للختمات (اختياري - احذف التعليق لو عايز تنفذه)
-- DROP TABLE IF EXISTS community_khatmahs CASCADE;
-- DROP TABLE IF EXISTS khatmah_participations CASCADE;
-- DROP TABLE IF EXISTS khatmah_comments CASCADE;
-- DROP TABLE IF EXISTS community_khatmas CASCADE;
-- DROP TABLE IF EXISTS khatma_participants CASCADE;
-- DROP TABLE IF EXISTS profiles CASCADE;
-- DROP TABLE IF EXISTS community_comments CASCADE;
-- DROP TABLE IF EXISTS comment_likes CASCADE;
-- DROP TABLE IF EXISTS community_activities CASCADE;

-- 4. التأكد من وجود جدول community_campaigns بالشكل الصحيح
CREATE TABLE IF NOT EXISTS community_campaigns (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    target_total INTEGER NOT NULL DEFAULT 30,
    completed_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- 5. التأكد من وجود جدول community_progress
CREATE TABLE IF NOT EXISTS community_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    campaign_id UUID REFERENCES community_campaigns(id) ON DELETE CASCADE,
    part_number INTEGER NOT NULL,
    user_name TEXT NOT NULL,
    device_id TEXT NOT NULL,
    status TEXT DEFAULT 'reserved',
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(campaign_id, part_number)
);

-- 6. إعادة تفعيل الـ Trigger للختمات (لو كان موجود)
CREATE OR REPLACE FUNCTION reset_on_completion()
RETURNS TRIGGER AS $$
DECLARE
    total_needed INT;
    current_done INT;
BEGIN
    SELECT target_total INTO total_needed FROM community_campaigns WHERE id = NEW.campaign_id;
    SELECT COUNT(*) INTO current_done FROM community_progress WHERE campaign_id = NEW.campaign_id AND status = 'completed';

    IF current_done >= total_needed THEN
        UPDATE community_campaigns SET completed_count = completed_count + 1 WHERE id = NEW.campaign_id;
        DELETE FROM community_progress WHERE campaign_id = NEW.campaign_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_reset_khatmah ON community_progress;
CREATE TRIGGER tr_reset_khatmah
AFTER UPDATE ON community_progress
FOR EACH ROW
WHEN (NEW.status = 'completed')
EXECUTE FUNCTION reset_on_completion();

-- ✅ تم! الآن كل الجداول متاحة بدون قيود RLS
