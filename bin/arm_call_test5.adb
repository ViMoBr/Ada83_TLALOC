with TEXT_IO;
use TEXT_IO;

procedure ARM_CALL_TEST5 is

   function INC (X : INTEGER) return INTEGER is
   begin
      return X + 1;
   end INC;


   generic
      with function F (X : INTEGER) return INTEGER is <>;
   procedure APPLY;


   procedure APPLY is
      A : INTEGER;
   begin
      A := F (99);
      PUT_LINE ("INDIRECT =" & INTEGER'IMAGE (A));
   end APPLY;


   procedure APPLY_INC is new APPLY (INC);

begin
   APPLY_INC;
end ARM_CALL_TEST5;
