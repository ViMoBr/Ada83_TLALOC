with TEXT_IO;           use TEXT_IO;

procedure LEX_ECHO
is
  F : FILE_TYPE;
  BDY   : STRING( 1..255 );
  LEN   : NATURAL;
  N : NATURAL := 0;
begin
  OPEN( F, IN_FILE, "null_prog.adb" );
  while  not END_OF_FILE( F )  loop         -- meme motif que GET_SOURCE_LINE
    N := N + 1;
    GET_LINE( F, BDY, LEN );
    PUT( "LIGNE" & NATURAL'IMAGE( N ) & " LEN" & NATURAL'IMAGE( LEN ) & " [" );
    if  LEN > 0  then
      PUT( BDY( 1..LEN ) );
    end if;
    PUT_LINE( "]" );
  end loop;
  CLOSE( F );
  PUT_LINE( "LEX_ECHO FIN" );
end LEX_ECHO;
