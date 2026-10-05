BEGIN;

ALTER TABLE public."KhachHang"
  ADD COLUMN IF NOT EXISTS "AvatarUrl" text;

CREATE OR REPLACE VIEW public.khachhang WITH (security_invoker = true) AS
SELECT
  "KhachHangID" AS khachhangid,
  "HoTen" AS hoten,
  "SoDienThoai" AS sodienthoai,
  "Email" AS email,
  "DiaChi" AS diachi,
  "NgayTao" AS ngaytao,
  "TrangThai" AS trangthai,
  "AvatarUrl" AS avatarurl
FROM public."KhachHang";

GRANT SELECT ON public.khachhang TO authenticated;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE
SET public = true,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "avatar owners upload" ON storage.objects;
DROP POLICY IF EXISTS "avatar owners update" ON storage.objects;
DROP POLICY IF EXISTS "avatar owners read" ON storage.objects;

CREATE POLICY "avatar owners upload" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
);

CREATE POLICY "avatar owners update" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text))
WITH CHECK (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text));

CREATE POLICY "avatar owners read" ON storage.objects
FOR SELECT TO authenticated
USING (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text));

CREATE OR REPLACE FUNCTION public.update_customer_profile_with_avatar(
  p_full_name text,
  p_email text DEFAULT NULL,
  p_phone text DEFAULT NULL,
  p_address text DEFAULT NULL,
  p_avatar_url text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  customer_id bigint := (SELECT private.current_customer_id());
  account_id bigint;
BEGIN
  IF customer_id IS NULL OR nullif(btrim(p_full_name), '') IS NULL THEN
    RAISE EXCEPTION 'Invalid customer profile';
  END IF;

  SELECT "TaiKhoanID"
  INTO account_id
  FROM public."TaiKhoan"
  WHERE "KhachHangID" = customer_id
    AND "UserAuthId" = (SELECT auth.uid());

  UPDATE public."KhachHang"
  SET "HoTen" = left(btrim(p_full_name), 150),
      "Email" = nullif(left(btrim(p_email), 255), ''),
      "SoDienThoai" = nullif(left(btrim(p_phone), 20), ''),
      "DiaChi" = nullif(left(btrim(p_address), 255), ''),
      "AvatarUrl" = coalesce(nullif(btrim(p_avatar_url), ''), "AvatarUrl")
  WHERE "KhachHangID" = customer_id;

  UPDATE public."TaiKhoan"
  SET "Email" = nullif(left(btrim(p_email), 255), ''),
      "SoDienThoai" = nullif(left(btrim(p_phone), 20), '')
  WHERE "TaiKhoanID" = account_id;

  RETURN jsonb_build_object('khachhangid', customer_id);
END;
$$;

REVOKE ALL ON FUNCTION public.update_customer_profile_with_avatar(text, text, text, text, text)
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.update_customer_profile_with_avatar(text, text, text, text, text)
  TO authenticated;

COMMIT;