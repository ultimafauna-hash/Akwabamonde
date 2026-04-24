-- SÉCURITÉ SUPABASE RLS SYNCHRONISÉE - AKWABA INFO
-- Tous les accès sont basés sur le schéma lowercase.

-- 1. CONFIGURATION GLOBALE
-- (Les tables ont déjà RLS activé dans init si possible, mais on le force ici pour être sûr)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- 2. POLITIQUES : ARTICLES (Public: Lecture seule, Admin: Tout)
DROP POLICY IF EXISTS "Articles: lecture publique" ON public.articles;
CREATE POLICY "Articles: lecture publique" ON public.articles FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS "Articles: admin full access" ON public.articles;
CREATE POLICY "Articles: admin full access" ON public.articles FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 3. POLITIQUES : PROFILS (Utilisateur: Soi-même, Admin: Tout)
DROP POLICY IF EXISTS "Profiles: lecture/modif par soi" ON public.profiles;
CREATE POLICY "Profiles: lecture/modif par soi" ON public.profiles FOR ALL USING (auth.uid() = uid);

DROP POLICY IF EXISTS "Profiles: admin full access" ON public.profiles;
CREATE POLICY "Profiles: admin full access" ON public.profiles FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 4. POLITIQUES : HISTOIRE & CULTURE (Public: Lecture seule, Admin: Tout)
DROP POLICY IF EXISTS "Culture: lecture publique" ON public.culture_posts;
CREATE POLICY "Culture: lecture publique" ON public.culture_posts FOR SELECT USING (status = 'published');

DROP POLICY IF EXISTS "Culture: admin full access" ON public.culture_posts;
CREATE POLICY "Culture: admin full access" ON public.culture_posts FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 5. POLITIQUES : COMMENTAIRES (Public: Lecture, Connectés: Insertion)
DROP POLICY IF EXISTS "Comments: lecture publique" ON public.comments;
CREATE POLICY "Comments: lecture publique" ON public.comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Comments: insertion connectés" ON public.comments;
CREATE POLICY "Comments: insertion connectés" ON public.comments FOR INSERT TO authenticated WITH CHECK (auth.uid() = userid);

DROP POLICY IF EXISTS "Comments: admin full access" ON public.comments;
CREATE POLICY "Comments: admin full access" ON public.comments FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 6. POLITIQUES : PARAMÈTRES (Public: Lecture, Admin: Tout)
DROP POLICY IF EXISTS "Settings: lecture publique" ON public.settings;
CREATE POLICY "Settings: lecture publique" ON public.settings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Settings: admin full access" ON public.settings;
CREATE POLICY "Settings: admin full access" ON public.settings FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 7. POLITIQUES : TRANSACTIONS (Utilisateur: Soi, Admin: Tout)
DROP POLICY IF EXISTS "Transactions: lecture propre" ON public.transactions;
CREATE POLICY "Transactions: lecture propre" ON public.transactions FOR SELECT USING (auth.uid() = userid);

DROP POLICY IF EXISTS "Transactions: insertion publique" ON public.transactions;
CREATE POLICY "Transactions: insertion publique" ON public.transactions FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Transactions: admin full access" ON public.transactions;
CREATE POLICY "Transactions: admin full access" ON public.transactions FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 8. POLITIQUES : LIVE BLOGS & WEB TV (Public: Lecture, Admin: Tout)
DROP POLICY IF EXISTS "LiveBlogs: lecture publique" ON public.live_blogs;
CREATE POLICY "LiveBlogs: lecture publique" ON public.live_blogs FOR SELECT USING (true);

DROP POLICY IF EXISTS "WebTV: lecture publique" ON public.web_tv;
CREATE POLICY "WebTV: lecture publique" ON public.web_tv FOR SELECT USING (true);

DROP POLICY IF EXISTS "LiveBlogs: admin full access" ON public.live_blogs;
CREATE POLICY "LiveBlogs: admin full access" ON public.live_blogs FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

DROP POLICY IF EXISTS "WebTV: admin full access" ON public.web_tv;
CREATE POLICY "WebTV: admin full access" ON public.web_tv FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 9. POLITIQUES : ADMIN LOGS (Admin uniquement)
DROP POLICY IF EXISTS "AdminLogs: admin only" ON public.admin_activity_log;
CREATE POLICY "AdminLogs: admin only" ON public.admin_activity_log FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 10. POLITIQUES : ABONNÉS NEWSLETTER (Public: Insertion, Admin: Tout)
DROP POLICY IF EXISTS "Subscribers: insertion publique" ON public.subscribers;
CREATE POLICY "Subscribers: insertion publique" ON public.subscribers FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Subscribers: admin full access" ON public.subscribers;
CREATE POLICY "Subscribers: admin full access" ON public.subscribers FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- 11. POLITIQUES : NOTIFICATIONS (Utilisateur/Global: Lecture)
DROP POLICY IF EXISTS "Notifications: lecture propre ou globale" ON public.notifications;
CREATE POLICY "Notifications: lecture propre ou globale" ON public.notifications FOR SELECT USING (userid = 'global' OR userid = auth.uid()::text);

-- 12. POLITIQUES : MÉDIAS (Public: Lecture, Admin: Tout)
DROP POLICY IF EXISTS "Media: lecture publique" ON public.media;
CREATE POLICY "Media: lecture publique" ON public.media FOR SELECT USING (true);

DROP POLICY IF EXISTS "Media: admin full access" ON public.media;
CREATE POLICY "Media: admin full access" ON public.media FOR ALL TO authenticated USING (auth.jwt() ->> 'email' = 'akwabanewsinfo@gmail.com' OR auth.jwt() ->> 'email' = 'kassiri.traore@gmail.com');

-- NOTE : 'akwabanewsinfo@gmail.com' est l'email administrateur de référence.
