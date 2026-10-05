-- Create function to get taikhoanid from userauthid
create or replace function get_taikhoanid_from_auth()
returns bigint as $$
declare
  v_taikhoanid bigint;
begin
  select taikhoanid into v_taikhoanid
  from taikhoan
  where userauthid = auth.uid();
  
  return v_taikhoanid;
end;
$$ language plpgsql security definer;

-- Create function to get taikhoanid from a specific UUID
create or replace function get_taikhoanid_from_uuid(p_userauthid uuid)
returns bigint as $$
declare
  v_taikhoanid bigint;
begin
  select taikhoanid into v_taikhoanid
  from taikhoan
  where userauthid = p_userauthid;
  
  return v_taikhoanid;
end;
$$ language plpgsql security definer;
