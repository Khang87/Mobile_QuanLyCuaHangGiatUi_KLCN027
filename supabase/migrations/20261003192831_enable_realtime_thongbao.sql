-- Add ThongBao to supabase_realtime publication
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'ThongBao'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE "public"."ThongBao";
  END IF;
END
$$;
