package PACK_1 is
  I	: INTEGER;
end PACK_1;

package PACK_2 is
  J : INTEGER;
  procedure XP;
end PACK_2;

package body PACK_2 is
  procedure XP is
  begin
    null;
  end;
end PACK_2;

with PACK_1;
with PACK_2;
procedure TEST_MULTI is
begin
  null;

end	TEST_MULTI;
