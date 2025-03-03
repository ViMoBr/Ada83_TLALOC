--	TEST_JSON.ADB	VINCENT MORIN	26/2/2025		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


with TEXT_IO, JSON;
use  TEXT_IO, JSON;
				---------
procedure				TEST_JSON
				---------
is
		-------------
  function	GET_FILE_NAME	return STRING
		-------------
  is
    BUFFER	: STRING( 1 .. 255 );
    LENGTH	: NATURAL;

  begin
    PUT( "Filename (without .json extension) ? " );
    GET_LINE( BUFFER, LENGTH );
    return  BUFFER( 1 .. LENGTH );

  end	GET_FILE_NAME;
	-------------


begin

  declare
    JSON_FILE_NAME		:constant STRING	:= GET_FILE_NAME;
    THE_ITEM		: JSON.ITEM;
    INPUT, OUTPUT		: TEXT_IO.FILE_TYPE;

  begin

    OPEN( INPUT, IN_FILE, JSON_FILE_NAME & ".json" );
    JSON.GET( INPUT, THE_ITEM );
    CLOSE( INPUT );

    CREATE( OUTPUT, OUT_FILE, JSON_FILE_NAME & "_out.json" );
    JSON.PUT( OUTPUT, THE_ITEM );
    CLOSE( OUTPUT );
    PUT( STRING_OF( THE_ITEM ) );
  end;

  declare
    THE_ITEM	: ITEM := ITEM_OF( "{ }" );
  begin
    PUT( STRING_OF( THE_ITEM ) );
  end;

  PUT_LINE( "Done" );

exception
    when PROGRAM_ERROR
         =>
         PUT_LINE( "Program terminated with error" );

end	TEST_JSON;
	---------
