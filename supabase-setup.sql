-- SOUZOUDO News Table Setup for Supabase
-- Run this in Supabase SQL Editor

-- Create news table
CREATE TABLE IF NOT EXISTS public.news (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date DATE NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'Info',
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    excerpt TEXT,
    body TEXT,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_news_date ON public.news(date DESC);
CREATE INDEX IF NOT EXISTS idx_news_slug ON public.news(slug);
CREATE INDEX IF NOT EXISTS idx_news_published ON public.news(is_published);

-- Enable Row Level Security
ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public read access for published articles
CREATE POLICY "Public can read published news" ON public.news
    FOR SELECT
    USING (is_published = true);

-- Policy: Allow authenticated users to manage all news
CREATE POLICY "Authenticated users can manage news" ON public.news
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_news_updated_at ON public.news;
CREATE TRIGGER update_news_updated_at
    BEFORE UPDATE ON public.news
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert initial article
INSERT INTO public.news (date, category, title, slug, excerpt, body, is_published)
VALUES (
    '2026-01-21',
    'Info',
    'HPをリニューアルしました。',
    '20260121-renewal',
    'SOUZOUDOのコーポレートサイトをリニューアルしました。より洗練されたデザインと使いやすさを追求し、私たちの想いやサービスをより分かりやすくお伝えできるようになりました。',
    'このたび、SOUZOUDOのコーポレートサイトを全面的にリニューアルいたしました。

新しいサイトでは、より洗練されたデザインと使いやすさを追求し、私たちのビジョンやサービス内容をより分かりやすくお伝えできるようになりました。

SOUZOUDOは「創造道」という社名に込めた想い—創造することへの道を切り拓く—を大切に、お客様のビジネスに貢献するサービスを提供してまいります。

今後とも、SOUZOUDOをよろしくお願いいたします。',
    true
) ON CONFLICT (slug) DO NOTHING;

-- Grant permissions
GRANT SELECT ON public.news TO anon;
GRANT ALL ON public.news TO authenticated;
