BEGIN;

DO $migration$
DECLARE
	notification_oid oid;
	notification_kind "char";
BEGIN
	notification_oid := to_regclass('public.thongbao');
	IF notification_oid IS NOT NULL THEN
		EXECUTE 'GRANT DELETE ON TABLE public.thongbao TO authenticated';
		SELECT relkind INTO notification_kind
		FROM pg_class
		WHERE oid = notification_oid;
		IF notification_kind IN ('r', 'p') THEN
			EXECUTE 'DROP POLICY IF EXISTS thongbao_owner_delete ON public.thongbao';
			EXECUTE $policy$
				CREATE POLICY thongbao_owner_delete ON public.thongbao
				FOR DELETE TO authenticated
				USING (taikhoanid = (SELECT private.current_account_id()))
			$policy$;
		END IF;
	END IF;

	notification_oid := to_regclass('public."ThongBao"');
	IF notification_oid IS NOT NULL THEN
		EXECUTE 'GRANT DELETE ON TABLE public."ThongBao" TO authenticated';
		SELECT relkind INTO notification_kind
		FROM pg_class
		WHERE oid = notification_oid;
		IF notification_kind IN ('r', 'p') THEN
			EXECUTE 'DROP POLICY IF EXISTS laundry_compat_notification_delete ON public."ThongBao"';
			EXECUTE $policy$
				CREATE POLICY laundry_compat_notification_delete
				ON public."ThongBao" FOR DELETE TO authenticated
				USING ("TaiKhoanID" = (SELECT private.current_account_id()))
			$policy$;
		END IF;
	END IF;
END;
$migration$;

COMMIT;