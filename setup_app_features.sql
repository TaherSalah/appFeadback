-- ============================================
-- Rafuiq Elmuslim - App Features Control Table (Updated with Status)
-- ============================================

-- 1. Create or Update the table
CREATE TABLE IF NOT EXISTS app_features (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  feature_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  emoji TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Add 'status' column and migrate data from 'is_enabled' if it exists
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='app_features' AND column_name='status') THEN
        ALTER TABLE app_features ADD COLUMN status TEXT DEFAULT 'active';
        
        -- If old column exists, migrate data
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='app_features' AND column_name='is_enabled') THEN
            UPDATE app_features SET status = 'active' WHERE is_enabled = true;
            UPDATE app_features SET status = 'hidden' WHERE is_enabled = false;
            ALTER TABLE app_features DROP COLUMN is_enabled;
        END IF;
    END IF;
END $$;

-- 3. Create index
CREATE INDEX IF NOT EXISTS idx_app_features_name ON app_features(feature_name);

-- 4. Initial/Missing Data (Synchronized with Flutter IDs)
INSERT INTO app_features (feature_name, display_name, emoji, status) VALUES
('timing', 'مواقيت الصلاة', '🕌', 'active'),
('quran', 'القرآن الكريم', '📖', 'active'),
('hadith', 'الأحاديث', '📚', 'active'),
('azkar', 'الأذكار', '🤲', 'active'),
('azan', 'الأذان', '🕌', 'active'),
('qibla', 'القبلة', '🧭', 'active'),
('sebha', 'المسبحة', '📿', 'active'),
('calendar', 'التقويم الهجري', '📅', 'active'),
('khatmah', 'الختمات الجماعية', '🕋', 'active'),
('radio', 'الراديو', '📻', 'active'),
('zakat', 'الزكاة', '💰', 'active'),
('charity', 'الصدقات', '🤲', 'active'),
('kids', 'ركن الأطفال', '👶', 'active'),
('mosques', 'المساجد القريبة', '🕌', 'active'),
('allah_names', 'أسماء الله الحسنى', '✨', 'active'),
('rokia', 'الرقية الشرعية', '🎧', 'active'),
('achievements', 'الإنجازات', '🏆', 'active'),
('wird', 'الورد اليومي', '📜', 'active'),
('fajr_alarm', 'منبه الفجر المتقدم', '⏰', 'active'),
('news', 'شريط الأخبار', '📢', 'active'),
('banners', 'البانرات الإعلانية', '🖼️', 'active'),
('friday_companion', 'رفيق الجمعة', '🕌', 'active'),
('quran_azkar', 'أذكار القرآن', '📖', 'active'),
('other_azkar', 'أذكار متنوعة', '🤲', 'active'),
('settings', 'الإعدادات', '⚙️', 'active')
ON CONFLICT (feature_name) DO UPDATE 
SET display_name = EXCLUDED.display_name, 
    emoji = EXCLUDED.emoji;

-- 5. Enable Row Level Security (RLS)
ALTER TABLE app_features ENABLE ROW LEVEL SECURITY;

-- 6. Re-create Policies (Drop first to avoid "already exists" errors)
DROP POLICY IF EXISTS "Allow public read access" ON app_features;
CREATE POLICY "Allow public read access" ON app_features FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow authenticated updates" ON app_features;
CREATE POLICY "Allow authenticated updates" ON app_features FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow authenticated inserts" ON app_features;
CREATE POLICY "Allow authenticated inserts" ON app_features FOR INSERT WITH CHECK (true);

-- 7. Trigger for updated_at
CREATE OR REPLACE FUNCTION update_app_features_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS app_features_updated_at_trigger ON app_features;
CREATE TRIGGER app_features_updated_at_trigger
  BEFORE UPDATE ON app_features
  FOR EACH ROW
  EXECUTE FUNCTION update_app_features_updated_at();
