with TEXT_IO;
use TEXT_IO;

procedure ARM_CALL_TEST is

   procedure P is
   begin
      PUT_LINE ("P");
   end P;

begin
   PUT_LINE ("AVANT");
   P;
   PUT_LINE ("APRES");
end ARM_CALL_TEST;
