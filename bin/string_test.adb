			-----------
procedure			STRING_TEST
is			-----------
  S	: STRING( 1 .. 256 );
  type MAT is array( 1 .. 16, 1 ..32 ) of NATURAL;
  M	: MAT;
begin
  S( 1 ) := 'A';
  M( 1,1 ) := 0;
end	STRING_TEST;
	-----------
