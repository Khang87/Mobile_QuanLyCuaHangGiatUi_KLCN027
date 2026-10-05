BEGIN;
GRANT INSERT ON TABLE public."ThongBao" TO "authenticated";
CREATE POLICY "laundry_compat_notification_insert" ON "public"."ThongBao" 
FOR INSERT TO "authenticated" 
WITH CHECK ("TaiKhoanID" = (SELECT private.current_account_id()));
COMMIT;
