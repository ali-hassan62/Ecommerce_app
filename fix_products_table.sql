-- Run this in the Supabase SQL Editor to fix the "new row violates RLS policy" error for products.

-- 1. Enable RLS on the table (good practice, ensuring no accidental open access if policies are dropped)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 2. Allow everyone to VIEW products
DROP POLICY IF EXISTS "Public View Products" ON public.products;
CREATE POLICY "Public View Products"
ON public.products FOR SELECT
USING ( true );

-- 3. Allow authenticated users (Admins/Sellers) to INSERT products
DROP POLICY IF EXISTS "Auth Insert Products" ON public.products;
CREATE POLICY "Auth Insert Products"
ON public.products FOR INSERT
WITH CHECK ( auth.role() = 'authenticated' );

-- 4. Allow authenticated users to UPDATE products
DROP POLICY IF EXISTS "Auth Update Products" ON public.products;
CREATE POLICY "Auth Update Products"
ON public.products FOR UPDATE
USING ( auth.role() = 'authenticated' );

-- 5. Allow authenticated users to DELETE products
DROP POLICY IF EXISTS "Auth Delete Products" ON public.products;
CREATE POLICY "Auth Delete Products"
ON public.products FOR DELETE
USING ( auth.role() = 'authenticated' );
