with TEXT_IO;
use TEXT_IO;

procedure ARM_CALL_TEST3 is

   A : INTEGER;

   function F (X : INTEGER) return INTEGER is
   begin
      return X + 1;
   end F;

begin
   A := F( 41 );
   PUT_LINE ("DIRECT =" & INTEGER'IMAGE (A));
end ARM_CALL_TEST3;
