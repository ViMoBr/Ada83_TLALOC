separate (TEST_VIS_1.P3)

package body IMPL is

--  use TEST_VIS_1.P2;		-- gnat compile sans ça

  procedure TESTEUR is
    V1	:IP2	:= 0;
  begin if V1 /= 0 then V1 := 1; end if; end TESTEUR;


end IMPL;
