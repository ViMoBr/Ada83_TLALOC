procedure TEST_RECTYPE
is
  MAX_STRING	:constant POSITIVE := 255;								--| CHAINE DE 256 CARACTERES MAXIMUM

  type LINE_OF_SOURCE	is record
			  LEN	: NATURAL;
			  BDY	: STRING( 1 .. MAX_STRING );
			end record;
begin
  null;
end	TEST_RECTYPE;
