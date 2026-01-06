-- Create custom_radios table
CREATE TABLE IF NOT EXISTS public.custom_radios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for custom_radios
ALTER TABLE public.custom_radios ENABLE ROW LEVEL SECURITY;

-- Drop existing restrictive policies if they exist
DROP POLICY IF EXISTS "Allow public read for active custom radios" ON public.custom_radios;
DROP POLICY IF EXISTS "Allow all for authenticated users on custom_radios" ON public.custom_radios;
DROP POLICY IF EXISTS "Allow any for dashboard on custom_radios" ON public.custom_radios;

-- Allow anyone to read radios
CREATE POLICY "Allow public read for active custom radios" ON public.custom_radios
    FOR SELECT USING (true);

-- Allow all for everyone (using anon/authenticated) on custom_radios
-- This is needed because the dashboard uses the anon key
CREATE POLICY "Allow any for dashboard on custom_radios" ON public.custom_radios
    FOR ALL USING (true);

-- Insert initial support links and prayer offsets into app_settings if they don't exist
INSERT INTO public.app_settings (key, value) VALUES 
('link_facebook', 'https://www.facebook.com/taher.salah.7927'),
('link_whatsapp', 'https://wa.me/+201094529752'),
('link_appstore', 'https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338'),
('link_playstore', 'https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily'),
('link_appgallery', 'https://appgallery.huawei.com/app/C114956477'),
('prayer_offset_fajr', '0'),
('prayer_offset_sunrise', '0'),
('prayer_offset_dhuhr', '0'),
('prayer_offset_asr', '0'),
('prayer_offset_maghrib', '0'),
('prayer_offset_isha', '0')
ON CONFLICT (key) DO NOTHING;
