CREATE OR REPLACE FUNCTION public.get_laundry_order_status_history(
  p_donhangid bigint
)
RETURNS TABLE (
  trangthaicu text,
  trangthaimoi text,
  lydo text,
  thoigian timestamp without time zone
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    event."DuLieuCu" ->> 'TrangThai',
    event."DuLieuMoi" ->> 'TrangThai',
    event."LyDo"::text,
    event."ThoiGian"
  FROM public."NhatKyHeThong" AS event
  WHERE (SELECT private.can_access_order(p_donhangid))
    AND event."BangDuLieu" = 'DonHang'
    AND event."BanGhiID" = p_donhangid
    AND event."HanhDong" = 'Thay đổi trạng thái đơn hàng'
  ORDER BY event."ThoiGian";
$$;

REVOKE ALL ON FUNCTION public.get_laundry_order_status_history(bigint)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_laundry_order_status_history(bigint)
  TO authenticated;
