-- INITIALISATION COMPLÈTE ET SYNCHRONISÉE DE LA BASE DE DONNÉES - AKWABA INFO
-- Tous les noms de tables et colonnes sont en MINUSCULES.

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABLES FONDAMENTALES

-- Profils Utilisateurs (Source de vérité pour l'auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    displayname TEXT,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    photourl TEXT,
    cover_image TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'editor', 'admin')),
    bio TEXT,
    phone TEXT,
    phone_verified BOOLEAN DEFAULT false,
    whatsapp TEXT,
    address TEXT,
    city TEXT,
    country TEXT,
    website TEXT,
    social_links JSONB DEFAULT '{}'::jsonb,
    kyc_level INTEGER DEFAULT 0,
    kyc_status TEXT DEFAULT 'none' CHECK (kyc_status IN ('none', 'pending', 'verified', 'rejected', 'expired')),
    kyc_documents JSONB DEFAULT '[]'::jsonb,
    kyc_rejection_reason TEXT,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_method TEXT CHECK (two_factor_method IN ('sms', 'email', 'totp')),
    pin_code TEXT,
    language TEXT DEFAULT 'fr',
    currency TEXT DEFAULT 'XOF',
    timezone TEXT,
    font_size TEXT DEFAULT 'normal' CHECK (font_size IN ('small', 'normal', 'large')),
    accessibility JSONB DEFAULT '{"colorBlindMode": false, "highContrast": false, "reducedMotion": false}'::jsonb,
    notification_preferences JSONB DEFAULT '{"push": {}, "email": {}, "sms": {}}'::jsonb,
    privacy_settings JSONB DEFAULT '{"profile": "public", "status": true, "readingHistory": true, "followers": true, "following": true, "messages": "all"}'::jsonb,
    blocked_users UUID[] DEFAULT '{}',
    muted_keywords TEXT[] DEFAULT '{}',
    referral_code TEXT UNIQUE,
    referred_by UUID REFERENCES public.profiles(uid),
    streak_days INTEGER DEFAULT 0,
    last_active_date DATE,
    likedarticles TEXT[] DEFAULT '{}',
    bookmarkedarticles TEXT[] DEFAULT '{}',
    followedauthors TEXT[] DEFAULT '{}',
    followedcategories TEXT[] DEFAULT '{}',
    interests TEXT[] DEFAULT '{}',
    votedpolls TEXT[] DEFAULT '{}',
    badges TEXT[] DEFAULT '{}',
    points INTEGER DEFAULT 0,
    ispremium BOOLEAN DEFAULT false,
    premiumsince TIMESTAMPTZ,
    premiumuntil TIMESTAMPTZ,
    paymentmethod TEXT,
    history JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Articles
CREATE TABLE IF NOT EXISTS public.articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    date TIMESTAMPTZ DEFAULT now(),
    category TEXT DEFAULT 'Afrique',
    image TEXT,
    video TEXT,
    audiourl TEXT,
    gallery TEXT[] DEFAULT '{}',
    author TEXT DEFAULT 'Équipe Akwaba Info',
    authorrole TEXT DEFAULT 'Journaliste',
    excerpt TEXT,
    content TEXT NOT NULL,
    readingtime TEXT DEFAULT '4 min',
    imagecredit TEXT,
    source TEXT,
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    reactions JSONB DEFAULT '{}'::jsonb,
    commentscount INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    ispremium BOOLEAN DEFAULT false,
    premiumpreviewselection TEXT DEFAULT 'auto',
    manualpreview TEXT,
    scheduledat TIMESTAMPTZ,
    seotitle TEXT,
    seodescription TEXT,
    socialimage TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Événements
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    date TEXT NOT NULL,
    location TEXT NOT NULL,
    category TEXT DEFAULT 'Événement Culturel',
    image TEXT,
    imagecredit TEXT,
    gallery TEXT[] DEFAULT '{}',
    video TEXT,
    excerpt TEXT,
    content TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    scheduledat TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Histoire & Culture
CREATE TABLE IF NOT EXISTS public.culture_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    date TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('patrimoine', 'traditions', 'personnages', 'civilisations', 'art', 'musique', 'gastronomie', 'langues')),
    image TEXT,
    video TEXT,
    gallery TEXT[] DEFAULT '{}',
    excerpt TEXT DEFAULT '',
    content TEXT NOT NULL,
    author TEXT DEFAULT 'Équipe Akwaba Info',
    period TEXT NOT NULL,
    region TEXT NOT NULL,
    readingtime TEXT DEFAULT '3 min',
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    createdat TIMESTAMPTZ DEFAULT now()
);

-- Commentaires
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid UUID REFERENCES auth.users(id),
    userphoto TEXT,
    username TEXT NOT NULL,
    date TIMESTAMPTZ DEFAULT now(),
    content TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    likedby UUID[] DEFAULT '{}',
    articleid UUID REFERENCES public.articles(id) ON DELETE CASCADE,
    isreported BOOLEAN DEFAULT false,
    reportedby UUID[] DEFAULT '{}',
    parentid UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Auteurs
CREATE TABLE IF NOT EXISTS public.authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    bio TEXT,
    image TEXT,
    socials JSONB DEFAULT '{}'::jsonb,
    specialties TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Paramètres
CREATE TABLE IF NOT EXISTS public.settings (
    id TEXT PRIMARY KEY DEFAULT 'global',
    abouttext TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    facebookurl TEXT,
    twitterurl TEXT,
    instagramurl TEXT,
    tiktokurl TEXT,
    linkedinurl TEXT,
    youtubeurl TEXT,
    urgentbannertext TEXT,
    urgentbanneractive BOOLEAN DEFAULT false,
    urgentbannerlink TEXT,
    flashnews TEXT,
    categories TEXT[] DEFAULT '{}',
    categories_icons JSONB DEFAULT '{}'::jsonb,
    maintenancemode BOOLEAN DEFAULT false,
    donationamounts INTEGER[] DEFAULT '{1000, 2000, 5000}',
    donationpaymentmethods TEXT[] DEFAULT '{}',
    premiumprice INTEGER DEFAULT 5000,
    isdonationactive BOOLEAN DEFAULT true,
    ispremiumactive BOOLEAN DEFAULT true,
    activepaymentmethods JSONB DEFAULT '{}'::jsonb,
    paymentlinks JSONB DEFAULT '{}'::jsonb,
    premiumdurationmonths INTEGER DEFAULT 1,
    orangemoneynumber TEXT,
    mtnmoneynumber TEXT,
    moovmoneynumber TEXT,
    wavenumber TEXT,
    paypalid TEXT,
    stripepublickey TEXT,
    adslotheader TEXT,
    adslotsidebar TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Sondages
CREATE TABLE IF NOT EXISTS public.polls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    startdate TIMESTAMPTZ DEFAULT now(),
    enddate TIMESTAMPTZ,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Table des Transactions
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid UUID REFERENCES auth.users(id),
    email TEXT NOT NULL,
    amount INTEGER NOT NULL,
    method TEXT NOT NULL,
    type TEXT CHECK (type IN ('subscription', 'donation')),
    status TEXT CHECK (status IN ('pending', 'success', 'failed')),
    transaction_reference TEXT,
    date TIMESTAMPTZ DEFAULT now()
);

-- Admin Activity Log
CREATE TABLE IF NOT EXISTS public.admin_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL,
    target_type TEXT,
    target_id TEXT,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Tables Complémentaires (History, Map, Quiz, Stories, Chats, Support)
CREATE TABLE IF NOT EXISTS public.history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    date TEXT NOT NULL, -- Format standard pour matching
    content TEXT NOT NULL,
    image TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.map_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    questions JSONB NOT NULL,
    difficulty TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image TEXT,
    author TEXT,
    date TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    articleid UUID REFERENCES public.articles(id),
    userid UUID REFERENCES auth.users(id),
    username TEXT,
    userphoto TEXT,
    content TEXT NOT NULL,
    date TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.support_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid UUID NOT NULL,
    username TEXT,
    userphoto TEXT,
    content TEXT NOT NULL,
    date TIMESTAMPTZ DEFAULT now(),
    isadmin BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS public.blocked_users (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id),
    blocked_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.media (
    id TEXT PRIMARY KEY,
    url TEXT NOT NULL,
    type TEXT CHECK (type IN ('image', 'video')),
    date TIMESTAMPTZ DEFAULT now(),
    filename TEXT
);

CREATE TABLE IF NOT EXISTS public.subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    date TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.classifieds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    price TEXT,
    category TEXT CHECK (category IN ('emploi', 'immobilier', 'véhicules', 'services', 'divers')),
    location TEXT NOT NULL,
    contact TEXT NOT NULL,
    imageurl TEXT,
    userid UUID REFERENCES auth.users(id),
    username TEXT,
    date TIMESTAMPTZ DEFAULT now(),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'sold', 'expired'))
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    userid TEXT, -- Can be 'global' or UUID
    topic TEXT,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    date TIMESTAMPTZ DEFAULT now(),
    read BOOLEAN DEFAULT false,
    type TEXT CHECK (type IN ('article', 'event', 'urgent', 'system'))
);

CREATE TABLE IF NOT EXISTS public.live_blogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    articleid UUID,
    title TEXT NOT NULL,
    updates JSONB DEFAULT '[]'::jsonb,
    status TEXT CHECK (status IN ('live', 'ended')),
    createdat TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.web_tv (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    videourl TEXT NOT NULL,
    thumbnail TEXT,
    category TEXT,
    date TIMESTAMPTZ DEFAULT now(),
    views INTEGER DEFAULT 0,
    ispremium BOOLEAN DEFAULT false
);


-- 5. TRIGGERS D'AUTHENTIFICATION
-- Création automatique du profil lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (uid, email, displayname, role)
  VALUES (new.id, new.email, split_part(new.email, '@', 1), 'user');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. POLITIQUES DE SÉCURITÉ (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Profils: Visibles par tous, modifiables par le propriétaire ou admin
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = uid);
CREATE POLICY "Admins can update all profiles" ON public.profiles FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- Articles: Visibles si publiés, modifiables par admin/editor
CREATE POLICY "Published articles are viewable by everyone" ON public.articles FOR SELECT USING (status = 'published' OR EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role IN ('admin', 'editor')));
CREATE POLICY "Admins/Editors can modify articles" ON public.articles FOR ALL USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role IN ('admin', 'editor')));

-- Commentaires: Visibles par tous, modifiables par l'auteur ou admin
CREATE POLICY "Comments are viewable by everyone" ON public.comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can post comments" ON public.comments FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = userid);
CREATE POLICY "Admins can delete all comments" ON public.comments FOR DELETE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- Paramètres: Visibles par tous, modifiables par admin
CREATE POLICY "Settings are viewable by everyone" ON public.settings FOR SELECT USING (true);
CREATE POLICY "Only admins can update settings" ON public.settings FOR UPDATE USING (EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin'));

-- 3. INDEXATION POUR RECHERCHE
CREATE INDEX IF NOT EXISTS articles_title_idx ON public.articles USING gin (to_tsvector('french', title));
CREATE INDEX IF NOT EXISTS articles_category_idx ON public.articles (category);
CREATE INDEX IF NOT EXISTS culture_posts_category_idx ON public.culture_posts (category);

-- 4. FONCTION DE RECHERCHE AVANCÉE
CREATE OR REPLACE FUNCTION search_articles(search_query TEXT)
RETURNS SETOF public.articles AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.articles
    WHERE 
        (to_tsvector('french', title) @@ to_tsquery('french', search_query))
        OR (title ILIKE '%' || search_query || '%')
    ORDER BY date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
