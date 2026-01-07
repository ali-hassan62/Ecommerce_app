-- Run this in the Supabase SQL Editor to fix the "new row violates RLS policy" error.

-- 1. Ensure the 'avatars' bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Allow anyone to view avatars (Public Access)
DROP POLICY IF EXISTS "Public View Avatars" ON storage.objects;
CREATE POLICY "Public View Avatars"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- 3. Allow authenticated users to upload their own avatar
DROP POLICY IF EXISTS "Auth Users Upload Avatar" ON storage.objects;
CREATE POLICY "Auth Users Upload Avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.role() = 'authenticated'
);

-- 4. Allow users to update/delete their own avatar
DROP POLICY IF EXISTS "Users Update Own Avatar" ON storage.objects;
CREATE POLICY "Users Update Own Avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 5. Ensure Profiles table has avatar_url column
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS avatar_url text;

-- 6. Ensure Profiles table allows updates
-- (If you haven't enabled RLS on profiles, this might not be needed, but good to have)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public View Profiles" ON public.profiles;
CREATE POLICY "Public View Profiles"
ON public.profiles FOR SELECT
USING ( true );

DROP POLICY IF EXISTS "Users Update Own Profile" ON public.profiles;
CREATE POLICY "Users Update Own Profile"
ON public.profiles FOR UPDATE
USING ( auth.uid() = id );

DROP POLICY IF EXISTS "Users Insert Own Profile" ON public.profiles;
CREATE POLICY "Users Insert Own Profile"
ON public.profiles FOR INSERT
WITH CHECK ( auth.uid() = id );
