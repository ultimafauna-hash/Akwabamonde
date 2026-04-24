-- Add isadmin column to comments table
ALTER TABLE public.comments ADD COLUMN IF NOT EXISTS isadmin BOOLEAN DEFAULT false;

-- Add isadmin column to chats table
ALTER TABLE public.chats ADD COLUMN IF NOT EXISTS isadmin BOOLEAN DEFAULT false;
