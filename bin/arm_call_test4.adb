with TEXT_IO;
use TEXT_IO;

procedure ARM_CALL_TEST4 is

   function FACT (N : INTEGER) return INTEGER is
   begin
      if N <= 1 then
         return 1;
      else
         return N * FACT (N - 1);
      end if;
   end FACT;

begin
   PUT_LINE (INTEGER'IMAGE (FACT (6)));
end ARM_CALL_TEST4;
