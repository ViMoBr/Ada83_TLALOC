with TEXT_IO;
use TEXT_IO;

procedure ARM_CALL_TEST2 is

   procedure P3 is
   begin
      PUT_LINE ("P3");
   end P3;

   procedure P2 is
   begin
      PUT_LINE ("P2-1");
      P3;
      PUT_LINE ("P2-2");
   end P2;

   procedure P1 is
   begin
      PUT_LINE ("P1-1");
      P2;
      PUT_LINE ("P1-2");
   end P1;

begin
   PUT_LINE ("DEBUT");
   P1;
   PUT_LINE ("FIN");
end ARM_CALL_TEST2;
