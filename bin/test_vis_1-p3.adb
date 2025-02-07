separate (TEST_VIS_1)

package body P3 is

  procedure IN_P3 ( PARAM :in out IP2 ) is
  begin if PARAM /= 0 then PARAM := 0; end if; end IN_P3;

  package IMPL is
  end IMPL;

  package body IMPL is separate;

end P3;
