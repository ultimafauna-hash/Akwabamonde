-- SÉCURITÉ SUPABASE RLS SYNCHRONISÉE - AKWABA INFO
-- Tous les accès sont basés sur le schéma lowercase.

-- 1. CONFIGURATION GLOBALE
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- Helper pour vérifier si l'utilisateur est admin
-- On utilise soit l'email (plus sûr au début) soit le rôle dans le profil
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    auth.jwt() ->> 'email' = 'akwabanewinfo@gmail.com'
    OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. POLITIQUES : ARTICLES
DROP POLICY IF EXISTS "Articles: lecture publique" ON public.articles;
CREATE POLICY "Articles: lecture publique" ON public.articles FOR SELECT USING (status = 'published' OR public.is_admin());

DROP POLICY IF EXISTS "Articles: admin full access" ON public.articles;
CREATE POLICY "Articles: admin full access" ON public.articles FOR ALL USING (public.is_admin());

-- 3. POLITIQUES : PROFILS
DROP POLICY IF EXISTS "Profiles: lecture/modif par soi" ON public.profiles;
CREATE POLICY "Profiles: lecture/modif par soi" ON public.profiles FOR ALL USING (auth.uid() = uid);

DROP POLICY IF EXISTS "Profiles: visibilité publique" ON public.profiles;
CREATE POLICY "Profiles: visibilité publique" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Profiles: admin full access" ON public.profiles;
CREATE POLICY "Profiles: admin full access" ON public.profiles FOR ALL USING (public.is_admin());

-- 4. POLITIQUES : HISTOIRE & CULTURE (Culture, Histoire, Stories, Quizzes, Map)
-- Lecture publique pour tout le monde
CREATE POLICY "Public: lecture seule" ON public.culture_posts FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.history FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.stories FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.quizzes FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.map_points FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.events FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.authors FOR SELECT USING (true);
CREATE POLICY "Public: lecture seule" ON public.polls FOR SELECT USING (true);

-- Admin full access pour tout le contenu
CREATE POLICY "Admin: full access" ON public.culture_posts FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.history FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.stories FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.quizzes FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.map_points FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.events FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.authors FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access" ON public.polls FOR ALL USING (public.is_admin());

-- 5. POLITIQUES : COMMENTAIRES & CHATS
DROP POLICY IF EXISTS "Comments: lecture publique" ON public.comments;
CREATE POLICY "Comments: lecture publique" ON public.comments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Comments: insertion connectés" ON public.comments;
CREATE POLICY "Comments: insertion connectés" ON public.comments FOR INSERT TO authenticated WITH CHECK (auth.uid() = userid);

CREATE POLICY "Chats: lecture publique" ON public.chats FOR SELECT USING (true);
CREATE POLICY "Chats: insertion connectés" ON public.chats FOR INSERT TO authenticated WITH CHECK (auth.uid() = userid);

DROP POLICY IF EXISTS "Comments: admin full access" ON public.comments;
CREATE POLICY "Comments: admin full access" ON public.comments FOR ALL USING (public.is_admin());
CREATE POLICY "Admin: full access chats" ON public.chats FOR ALL USING (public.is_admin());

-- 6. POLITIQUES : SUPPORT & MESSAGES
-- L'utilisateur ne voit que ses propres messages de support
CREATE POLICY "Support: voir ses messages" ON public.support_messages FOR SELECT USING (auth.uid() = userid OR public.is_admin());
CREATE POLICY "Support: envoyer message" ON public.support_messages FOR INSERT WITH CHECK (auth.uid() = userid);
CREATE POLICY "Admin: full access support" ON public.support_messages FOR ALL USING (public.is_admin());

-- 7. POLITIQUES : PETITES ANNONCES (Classifieds)
CREATE POLICY "Classifieds: lecture publique" ON public.classifieds FOR SELECT USING (status = 'active' OR public.is_admin() OR auth.uid() = userid);
CREATE POLICY "Classifieds: insertion connectés" ON public.classifieds FOR INSERT TO authenticated WITH CHECK (auth.uid() = userid);
CREATE POLICY "Classifieds: modif propre annonce" ON public.classifieds FOR UPDATE USING (auth.uid() = userid);
CREATE POLICY "Admin: full access classifieds" ON public.classifieds FOR ALL USING (public.is_admin());

-- 8. POLITIQUES : RESTE (Settings, Media, Subscribers, etc.)
CREATE POLICY "Settings: lecture publique" ON public.settings FOR SELECT USING (true);
CREATE POLICY "Settings: admin only" ON public.settings FOR ALL USING (public.is_admin());

CREATE POLICY "Media: lecture publique" ON public.media FOR SELECT USING (true);
CREATE POLICY "Media: admin only" ON public.media FOR ALL USING (public.is_admin());

CREATE POLICY "Subscribers: insertion" ON public.subscribers FOR INSERT WITH CHECK (true);
CREATE POLICY "Subscribers: admin only" ON public.subscribers FOR ALL USING (public.is_admin());

CREATE POLICY "Notifications: voir les siennes ou globales" ON public.notifications FOR SELECT USING (userid = 'global' OR userid = auth.uid()::text);
CREATE POLICY "Admin: full access notifs" ON public.notifications FOR ALL USING (public.is_admin());

-- 9. POLITIQUES : LOGS & CONTACTS
CREATE POLICY "AdminLogs: admin only" ON public.admin_activity_log FOR ALL USING (public.is_admin());
CREATE POLICY "UserLogs: insertion propre" ON public.user_logs FOR INSERT WITH CHECK (auth.uid() = userid);
CREATE POLICY "UserLogs: admin only view" ON public.user_logs FOR SELECT USING (public.is_admin());
CREATE POLICY "ContactMessages: insertion publique" ON public.contact_messages FOR INSERT WITH CHECK (true);
CREATE POLICY "ContactMessages: admin only" ON public.contact_messages FOR ALL USING (public.is_admin());

-- NOTE : 'akwabanewinfo@gmail.com' est l'email administrateur unique.
