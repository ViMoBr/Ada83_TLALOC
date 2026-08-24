with TEXT_IO;			use TEXT_IO;

procedure GETREC
is
  type LIGNE	is record
		  LEN	: NATURAL;
		  BDY	: STRING( 1..255 );
		end record;

  F	: FILE_TYPE;
  SL	: LIGNE;
  N	: NATURAL := 0;
begin
  OPEN( F, IN_FILE, "null_prog.adb" );
  while  not END_OF_FILE( F )  loop
    N := N + 1;
    GET_LINE( F, SL.BDY, SL.LEN );
    PUT( "LIGNE" & NATURAL'IMAGE( N ) & " LEN" & NATURAL'IMAGE( SL.LEN ) & " [" );
    if  SL.LEN > 0  then
      PUT( SL.BDY( 1..SL.LEN ) );
    end if;
    PUT_LINE( "]" );
  end loop;
  CLOSE( F );
  PUT_LINE( "GETREC FIN" );
end GETREC;
