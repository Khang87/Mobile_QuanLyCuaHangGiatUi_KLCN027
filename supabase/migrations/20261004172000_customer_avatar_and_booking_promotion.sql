BEGIN;

ALTER TABLE public."KhachHang" ADD COLUMN IF NOT EXISTS "AvatarUrl" text;
ALTER TABLE public."Booking" ADD COLUMN IF NOT EXISTS "KhuyenMaiID" integer
  REFERENCES public."KhuyenMai"("KhuyenMaiID");

CREATE OR REPLACE VIEW public.khachhang WITH (security_invoker = true) AS
SELECT "KhachHangID" AS khachhangid, "HoTen" AS hoten, "SoDienThoai" AS sodienthoai,
  "Email" AS email, "DiaChi" AS diachi,
  "NgayTao" AS ngaytao, "TrangThai" AS trangthai,
  "AvatarUrl" AS avatarurl
FROM public."KhachHang";
GRANT SELECT ON public.khachhang TO authenticated;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET public = true, file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "avatar owners upload" ON storage.objects;
DROP POLICY IF EXISTS "avatar owners update" ON storage.objects;
DROP POLICY IF EXISTS "avatar owners read" ON storage.objects;
CREATE POLICY "avatar owners upload" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = (SELECT auth.uid()::text));
CREATE POLICY "avatar owners update" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text))
  WITH CHECK (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text));
CREATE POLICY "avatar owners read" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'avatars' AND owner_id = (SELECT auth.uid()::text));

CREATE OR REPLACE FUNCTION public.update_customer_profile_with_avatar(
  p_full_name text, p_email text DEFAULT NULL, p_phone text DEFAULT NULL,
  p_address text DEFAULT NULL, p_avatar_url text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE customer_id bigint := (SELECT private.current_customer_id()); account_id bigint;
BEGIN
  IF customer_id IS NULL OR nullif(btrim(p_full_name), '') IS NULL THEN RAISE EXCEPTION 'Invalid customer profile'; END IF;
  SELECT "TaiKhoanID" INTO account_id FROM public."TaiKhoan" WHERE "KhachHangID" = customer_id AND "UserAuthId" = (SELECT auth.uid());
  UPDATE public."KhachHang" SET "HoTen"=left(btrim(p_full_name),150), "Email"=nullif(left(btrim(p_email),255),''), "SoDienThoai"=nullif(left(btrim(p_phone),20),''), "DiaChi"=nullif(left(btrim(p_address),255),''), "AvatarUrl"=coalesce(nullif(btrim(p_avatar_url),''), "AvatarUrl") WHERE "KhachHangID"=customer_id;
  UPDATE public."TaiKhoan" SET "Email"=nullif(left(btrim(p_email),255),''), "SoDienThoai"=nullif(left(btrim(p_phone),20),'') WHERE "TaiKhoanID"=account_id;
  RETURN jsonb_build_object('khachhangid', customer_id);
END; $$;
REVOKE ALL ON FUNCTION public.update_customer_profile_with_avatar(text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.update_customer_profile_with_avatar(text,text,text,text,text) TO authenticated;

CREATE OR REPLACE FUNCTION public.set_booking_promotion(p_bookingid bigint, p_makhuyenmai text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE customer_id bigint := (SELECT private.current_customer_id()); promotion_id integer;
BEGIN
  SELECT "KhuyenMaiID" INTO promotion_id FROM public."KhuyenMai" WHERE upper("MaKhuyenMai")=upper(btrim(p_makhuyenmai)) AND "TrangThai"='Hoạt động' AND "NgayBatDau"<=current_date AND "NgayKetThuc">=current_date;
  IF promotion_id IS NULL THEN RAISE EXCEPTION 'Promotion code is invalid or expired'; END IF;
  UPDATE public."Booking" SET "KhuyenMaiID"=promotion_id WHERE "BookingID"=p_bookingid AND "KhachHangID"=customer_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Booking not found'; END IF;
END; $$;
REVOKE ALL ON FUNCTION public.set_booking_promotion(bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.set_booking_promotion(bigint,text) TO authenticated;
CREATE OR REPLACE FUNCTION private.apply_booking_promotion_to_order()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE promotion public."KhuyenMai"%ROWTYPE; promotion_id integer; discount_amount numeric(18,2);
BEGIN
  IF NEW."BookingID" IS NULL THEN RETURN NEW; END IF;
  SELECT "KhuyenMaiID" INTO promotion_id FROM public."Booking" WHERE "BookingID" = NEW."BookingID";
  IF promotion_id IS NULL THEN RETURN NEW; END IF;
  SELECT * INTO promotion FROM public."KhuyenMai" WHERE "KhuyenMaiID" = promotion_id;
  IF NOT FOUND OR promotion."TrangThai" <> 'Hoạt động' OR promotion."NgayKetThuc" < current_date OR (promotion."GiaTriDonToiThieu" IS NOT NULL AND NEW."TongTien" < promotion."GiaTriDonToiThieu") THEN RETURN NEW; END IF;
  discount_amount := CASE WHEN promotion."LoaiKhuyenMai" = 'Phần trăm' THEN NEW."TongTien" * promotion."GiaTriGiam" / 100 ELSE promotion."GiaTriGiam" END;
  IF promotion."MucGiamToiDa" IS NOT NULL THEN discount_amount := least(discount_amount, promotion."MucGiamToiDa"); END IF;
  NEW."KhuyenMaiID" := promotion_id; NEW."TienGiamKhuyenMai" := greatest(least(discount_amount, NEW."TongTien"), 0);
  NEW."ThanhTien" := greatest(NEW."TongTien" + NEW."PhiGiaoHang" - NEW."TienGiamDoDiem" - NEW."TienGiamKhuyenMai", 0);
  RETURN NEW;
END; $$;
DROP TRIGGER IF EXISTS apply_booking_promotion_to_order ON public."DonHang";
CREATE TRIGGER apply_booking_promotion_to_order BEFORE INSERT OR UPDATE ON public."DonHang" FOR EACH ROW EXECUTE FUNCTION private.apply_booking_promotion_to_order();
COMMIT;
