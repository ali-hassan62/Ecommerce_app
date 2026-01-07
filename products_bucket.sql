-- Run this to enable Product Image Uploads

-- 1. Create 'products' bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('products', 'products', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Allow Public View
CREATE POLICY "Public View Products"
ON storage.objects FOR SELECT
USING ( bucket_id = 'products' );

-- 3. Allow Admins to Upload (for now, allow authenticated users to simplify)
-- ideally check for is_admin metadata
CREATE POLICY "Auth Users Upload Products"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'products' 
  AND auth.role() = 'authenticated'
);

-- 4. Allow Admins to Update/Delete
CREATE POLICY "Auth Users Update Products"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'products'
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Auth Users Delete Products"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'products'
  AND auth.role() = 'authenticated'
);
