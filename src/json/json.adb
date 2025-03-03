--	JSON.ADB	VINCENT MORIN	25/2/2025		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


with UNCHECKED_DEALLOCATION, DIRECT_IO;

						----
			package body		JSON
						----
is

  DEBUG		: BOOLEAN		:= FALSE;


			---
  procedure		GET		( FILE :in JSON.FILE_TYPE; THE_ITEM :out ITEM )
  			---
  is
    use TEXT_IO;

		------
  package		PARSER
		------
  is

    function  READ_OBJECT		return JSON.ITEM;

	------
  end	PARSER;
	------

  package body				PARSER
					------
  is


    type TOKEN_TYPE		is ( END_TOKEN, LEFT_ACCOLADE, RIGHT_ACCOLADE, LEFT_CROCHET, RIGHT_CROCHET,
			     COMMA, COLON, CHAINE, ENTIER, FLOTTANT );

    type TOKEN (KIND :TOKEN_TYPE := END_TOKEN)	is record
			  case KIND is
			  when CHAINE	=> STR_LENGTH	: NATURAL;
			  when ENTIER	=> INT_VALUE	: INTEGER;
			  when FLOTTANT	=> FLOAT_VALUE	: LONG_FLOAT;
			  when others	=> null;
			  end case;
			end record;

    TOKEN_BUFFER		: STRING( 1 .. 512 );



			--------------------
  procedure		PROCESS_SYNTAX_ERROR		( ENCOUNTERED, EXPECTED : TOKEN_TYPE := END_TOKEN )
  			--------------------
  is
    use TEXT_IO;
  begin
    PUT( "syntax error ! (" & COUNT'IMAGE( TEXT_IO.LINE( FILE ) )
		  & ':' & COUNT'IMAGE( TEXT_IO.COL( FILE )-1 ) & ") : " );

    if  ENCOUNTERED = END_TOKEN  and  EXPECTED = END_TOKEN
    then
      PUT_LINE( "unexpected end of file " );

    else
      if  EXPECTED /= END_TOKEN
      then
        PUT( "expected " & TOKEN_TYPE'IMAGE( EXPECTED ) );
      end if;

      if  ENCOUNTERED /= END_TOKEN
      then
        PUT_LINE( " encountered " & TOKEN_TYPE'IMAGE( ENCOUNTERED ) );
      else
        NEW_LINE;
      end if;

    end if;

    raise PROGRAM_ERROR;

  end	PROCESS_SYNTAX_ERROR;
	--------------------



			---
  procedure		GET			( THE_TOKEN :out TOKEN )
			---
  is
    use TEXT_IO;
    C	: CHARACTER;
  begin
    THE_TOKEN := ( KIND=> END_TOKEN );

			-----------
			SKIP_BLANKS:
    loop
      if  END_OF_FILE( FILE )  then  return;  end if;
      GET( FILE, C );
      exit when  not (C = ' '  or  C = ASCII.HT);
      if  END_OF_FILE( FILE )  then  return;  end if;

    end loop	SKIP_BLANKS;
		-----------

    if  DEBUG
    then
      PUT( C & TEXT_IO.COUNT'IMAGE( TEXT_IO.LINE( FILE ) ) & ':'
	   & TEXT_IO.COUNT'IMAGE( TEXT_IO.COL(FILE )-1 ) & '.' );
    end if;

    case  C  is

      when  '{'
	  => THE_TOKEN := ( KIND=> LEFT_ACCOLADE  );

      when  '}'
	  => THE_TOKEN := ( KIND=> RIGHT_ACCOLADE );

      when  '['
	  => THE_TOKEN := ( KIND=> LEFT_CROCHET   );

      when  ']'
	  => THE_TOKEN := ( KIND=> RIGHT_CROCHET  );

      when  ','
	  => THE_TOKEN := ( KIND=> COMMA );

      when  ':'
	  => THE_TOKEN := ( KIND=> COLON );

      when  '"'
	  =>		------------
			GET_A_STRING:
        declare
	LEN		: NATURAL		:= 0;
	INDEX_BUFFER	: POSITIVE	:= 1;
        begin
	loop
	  GET( FILE, C );

	  if  DEBUG
	  then
	    PUT( C & TEXT_IO.COUNT'IMAGE( TEXT_IO.LINE( FILE ) ) & ':'
		 & TEXT_IO.COUNT'IMAGE( TEXT_IO.COL( FILE )-1 ) & '.' );
	  end if;

            exit when  C = '"';
	  TOKEN_BUFFER( INDEX_BUFFER ) := C;
	  LEN := LEN + 1;
	  INDEX_BUFFER := INDEX_BUFFER + 1;
	end loop;
	THE_TOKEN := ( KIND=> CHAINE, STR_LENGTH=> LEN );

        end	GET_A_STRING;
		------------

      when  others
	  => raise SYNTAX_ERROR;

    end case;

    if  DEBUG
    then
      PUT( "token " & TOKEN_TYPE'IMAGE( THE_TOKEN.KIND ) & " at"
	 & TEXT_IO.COUNT'IMAGE( TEXT_IO.LINE( FILE ) ) & ':'
	 & TEXT_IO.COUNT'IMAGE( TEXT_IO.COL( FILE )-1 )
         );
      if THE_TOKEN.KIND = CHAINE
      then  PUT_LINE( "  " & '"' & TOKEN_BUFFER( 1 .. THE_TOKEN.STR_LENGTH ) & '"' );
      else  NEW_LINE;
      end if;
    end if;

  exception
    when END_ERROR | SYNTAX_ERROR => PROCESS_SYNTAX_ERROR;

  end	GET;
	---



			----------
  procedure		GET_VERIFY	( WHAT_IS_EXPECTED :TOKEN_TYPE; THE_TOKEN :out TOKEN )
			----------
  is
  begin
    GET( THE_TOKEN );
    if  THE_TOKEN.KIND /= WHAT_IS_EXPECTED
    then
      PROCESS_SYNTAX_ERROR( ENCOUNTERED=> THE_TOKEN.KIND, EXPECTED=> WHAT_IS_EXPECTED );
    end if;

  end	GET_VERIFY;
	----------



  function  GET_OBJECT	return JSON.ITEM;
  function  GET_ARRAY	return JSON.ITEM;



			--------
  function		GET_ITEM		( THE_TOKEN :TOKEN )	return JSON.ITEM
			--------
  is
  begin

    case  THE_TOKEN.KIND  is

      when  LEFT_ACCOLADE
	  => return GET_OBJECT;

      when  LEFT_CROCHET
	  => return GET_ARRAY;

      when  CHAINE
 	  => return new ITEM_DEFINITION'( KIND=> STRING_ITEM,
				    STR_ACCESS=> new STRING'(TOKEN_BUFFER( 1 .. THE_TOKEN.STR_LENGTH )) );

      when  ENTIER
	  => return new ITEM_DEFINITION'( KIND=> INTEGER_ITEM, INT_VAL=> THE_TOKEN.INT_VALUE );

      when  FLOTTANT
	  => return new ITEM_DEFINITION'( KIND=> FLOAT_ITEM, FLOAT_VAL=> THE_TOKEN.FLOAT_VALUE );

      when  others
	  => raise SYNTAX_ERROR;

    end case;

  exception
    when SYNTAX_ERROR
         => PROCESS_SYNTAX_ERROR( THE_TOKEN.KIND );
	  raise PROGRAM_ERROR;

  end	GET_ITEM;
	--------



			----------
    function		GET_OBJECT		return JSON.ITEM
			----------
    is
      THE_TOKEN		: TOKEN;
      FIELDS_LIST_HEAD,
      FIELDS_LIST_LAST	: OBJECT_FIELD_ACCESS	:= null;

    begin
      GET( THE_TOKEN );
      if  THE_TOKEN.KIND = RIGHT_ACCOLADE  then  return new ITEM_DEFINITION'( OBJECT_ITEM, null );  end if;
      if  THE_TOKEN.KIND /= CHAINE  then  PROCESS_SYNTAX_ERROR;  end if;

      loop

        declare
	KEY	: STRING_ACCESS		:= new STRING'(TOKEN_BUFFER( 1 .. THE_TOKEN.STR_LENGTH ));
	OFA	: OBJECT_FIELD_ACCESS;
        begin
	GET_VERIFY( COLON, THE_TOKEN );
	GET( THE_TOKEN );
	OFA := new OBJECT_FIELD'( KEY, GET_ITEM( THE_TOKEN ), null );

	if  FIELDS_LIST_HEAD = null  then
	  FIELDS_LIST_HEAD := OFA; FIELDS_LIST_LAST := OFA;
	else
	  FIELDS_LIST_LAST.all.NEXT := OFA; FIELDS_LIST_LAST := OFA;
	end if;
        end;

        GET( THE_TOKEN );
        if  THE_TOKEN.KIND = COMMA
        then
	GET_VERIFY( CHAINE, THE_TOKEN );
        else
	if  THE_TOKEN.KIND /= RIGHT_ACCOLADE
	then
	  PROCESS_SYNTAX_ERROR( ENCOUNTERED=> THE_TOKEN.KIND, EXPECTED=> RIGHT_ACCOLADE );
	end if;
	exit;
        end if;

      end loop;

      return new ITEM_DEFINITION'( OBJECT_ITEM, FIELDS_LIST_HEAD );

    end	GET_OBJECT;
	----------


			---------
    function		GET_ARRAY			return JSON.ITEM
			---------
    is
      THE_TOKEN		: TOKEN;
      STRUC_LIST_HEAD,
      STRUC_LIST_LAST	: LIST_OF_ITEMS	:= null;

    begin
      GET( THE_TOKEN );
      if  THE_TOKEN.KIND = RIGHT_CROCHET  then  return new ITEM_DEFINITION'( ARRAY_ITEM, null );  end if;

			-------------
			PROCESS_ITEMS:
      loop

        declare
	LOI	: LIST_OF_ITEMS	:= new ITEM_LIST_ELEMENT'( GET_ITEM( THE_TOKEN ), null );
        begin
	if  STRUC_LIST_HEAD = null  then
	  STRUC_LIST_HEAD := LOI; STRUC_LIST_LAST := LOI;
	else
	  STRUC_LIST_LAST.all.NEXT := LOI; STRUC_LIST_LAST := LOI;
	end if;
        end;

        GET( THE_TOKEN );
        if  THE_TOKEN.KIND = COMMA
        then
	GET( THE_TOKEN );
        else
	if  THE_TOKEN.KIND = RIGHT_CROCHET
	then  exit PROCESS_ITEMS;
	else  PROCESS_SYNTAX_ERROR( ENCOUNTERED=> THE_TOKEN.KIND, EXPECTED=> RIGHT_CROCHET );
	end if;
        end if;

      end loop	PROCESS_ITEMS;
		-------------

      return new ITEM_DEFINITION'( ARRAY_ITEM, STRUC_LIST_HEAD );

    end	GET_ARRAY;
	----------



			-----------
    function		READ_OBJECT		return JSON.ITEM
  			-----------
    is
      THE_TOKEN	: TOKEN;
    begin
      GET( THE_TOKEN );
      if  THE_TOKEN.KIND = LEFT_ACCOLADE  then
        return GET_OBJECT;
      else  raise SYNTAX_ERROR;
      end if;

    exception
      when SYNTAX_ERROR
	  => PROCESS_SYNTAX_ERROR;
	     raise PROGRAM_ERROR;

    end	READ_OBJECT;
	-----------


		------
  end		PARSER;
		------

--	1	2	3	4	5	6	7	8	9	0	1	2
-------------------------------------------------------------------------------------------------------------------------


  begin
    THE_ITEM := PARSER.READ_OBJECT;

  end	GET;
	---

			---
  procedure		PUT		( FILE :in out JSON.FILE_TYPE; THE_ITEM :ITEM )
			---
  is
			  -------
    procedure		  LAY_ONE		( ITEM :JSON.ITEM; AT_COL :TEXT_IO.COUNT )
			  -------
    is
      use TEXT_IO;
			    -----------------
      procedure		    PUT_OBJECT_FIELDS	( OF_OBJECT :JSON.ITEM )
			    -----------------
      is
			      -----------------
        procedure		      PROCESS_ONE_FIELD	( KEY	     :STRING;
						  ITEM	     :in out JSON.ITEM;
						  LAST_ONE     :in BOOLEAN;
						  STOP_PROCESS :out BOOLEAN )
			      -----------------
        is
        begin
	SET_COL( AT_COL+2 );
	PUT( '"' & KEY & '"' & " : " );

	LAY_ONE( ITEM, TEXT_IO.COL );

	if  not LAST_ONE  then  PUT( ',' );  end if; NEW_LINE;
	STOP_PROCESS := FALSE;

        end	  PROCESS_ONE_FIELD;
		  -----------------

        procedure PUT_FOR_EACH_FIELD is new FOR_EACH_JSON_FIELD( PROCESS_ONE_FIELD );

      begin
	PUT_FOR_EACH_FIELD( OF_OBJECT );

      end	PUT_OBJECT_FIELDS;
	-----------------

			    ---------------
      procedure		    PUT_ARRAY_ITEMS	(THE_ITEM :JSON.ITEM )
			    ---------------
      is
        START_COL	: TEXT_IO.COUNT	:= TEXT_IO.COL;

			      ----------------
	procedure		      PROCESS_ONE_ITEM	( ITEM	     :in out JSON.ITEM;
						  LAST_ONE     :in BOOLEAN;
						  STOP_PROCESS :out BOOLEAN )
			      ----------------
	is
	begin
	  NEW_LINE;

	  LAY_ONE( ITEM, START_COL+2 );

	  if  not LAST_ONE  then  PUT( ',' );  end if;
	  STOP_PROCESS := FALSE;

	end	    PROCESS_ONE_ITEM;
		    ----------------

	procedure PUT_FOR_EACH_ITEM is new FOR_EACH_JSON_ITEM( PROCESS_ONE_ITEM );

      begin
        PUT_FOR_EACH_ITEM( ITEM );

      end	PUT_ARRAY_ITEMS;
	---------------

    begin
      SET_COL( AT_COL );

      case KIND( ITEM ) is

      when OBJECT_ITEM
	 =>
	 PUT( '{' );
	 PUT_OBJECT_FIELDS( ITEM );
	 SET_COL( AT_COL+1 );
	 PUT( '}' );

      when ARRAY_ITEM
	 =>
	 PUT( '[' );
	 PUT_ARRAY_ITEMS( ITEM );
	 SET_COL( AT_COL+1 );
	 PUT( ']' );

      when STRING_ITEM
	 =>
	 PUT( '"' & ITEM.all.STR_ACCESS.all & '"' );

      when INTEGER_ITEM
	 =>
	 PUT( INTEGER'IMAGE( ITEM.all.INT_VAL ) );

      when FLOAT_ITEM
	 =>
	 declare
	  package LONG_FLOAT_IO	is new FLOAT_IO( LONG_FLOAT );
	  begin
	    LONG_FLOAT_IO.PUT( ITEM.all.FLOAT_VAL );
	  end;

      when BOOLEAN_ITEM
	 =>
	 PUT( BOOLEAN'IMAGE( ITEM.all.BOOL_VAL ) );

      when NULL_ITEM
	 =>
	 PUT( "null" );

      end case;

    end	  LAY_ONE;
	  -------

  begin
    TEXT_IO.SET_OUTPUT( FILE );
    LAY_ONE( THE_ITEM, AT_COL=> 1 );
    TEXT_IO.SET_OUTPUT( TEXT_IO.STANDARD_OUTPUT );

  end	PUT;
	---


			---------
  function		STRING_OF		( THE_ITEM : ITEM)			return STRING
			---------
  is
    TEMP_FILE_NAME	:constant STRING	:= "JSON$$$.tmp";
  begin
		------------------
		WRITE_ITEM_TO_FILE:
    declare
      TEMP_FILE	: TEXT_IO.FILE_TYPE;
      use TEXT_IO;
    begin
      CREATE( TEMP_FILE, OUT_FILE, TEMP_FILE_NAME );
      JSON.PUT( TEMP_FILE, THE_ITEM );
      CLOSE( TEMP_FILE );

    end	WRITE_ITEM_TO_FILE;
	------------------

		-------------------
		READ_FILE_TO_STRING:
    declare
      package CHAR_IO is new DIRECT_IO( CHARACTER );
      use CHAR_IO;
      TEMP_FILE	: CHAR_IO.FILE_TYPE;
    begin
      CHAR_IO.OPEN( TEMP_FILE, IN_FILE, TEMP_FILE_NAME );
      declare
        ITEM_STRING_LENGTH	:constant INTEGER	:= INTEGER( CHAR_IO.SIZE( TEMP_FILE ) );
        ITEM_STRING		: STRING( 1 .. ITEM_STRING_LENGTH );
      begin
        for I in ITEM_STRING'RANGE loop
	READ( TEMP_FILE, ITEM_STRING( I ) );
        end loop;
        DELETE( TEMP_FILE );
        return  ITEM_STRING;
      end;

    end	READ_FILE_TO_STRING;
	-------------------

  end	STRING_OF;
	---------



			-------
  function		ITEM_OF		( THE_STRING :STRING)		return ITEM
  			-------
  is
    TEMP_FILE_NAME	:constant STRING	:= "JSON$$$.tmp";
    OUT_ITEM	: ITEM;

  begin
    declare
      package CHAR_IO is new DIRECT_IO( CHARACTER );
      use CHAR_IO;
      TEMP_FILE	: CHAR_IO.FILE_TYPE;
    begin
      CREATE( TEMP_FILE, OUT_FILE, TEMP_FILE_NAME );
      for I in THE_STRING'RANGE loop
        WRITE( TEMP_FILE, THE_STRING( I ) );
      end loop;
      CLOSE( TEMP_FILE );
    end;

    declare
      use TEXT_IO;
      TEMP_FILE	: JSON.FILE_TYPE;
    begin
      TEXT_IO.OPEN( TEMP_FILE, IN_FILE, TEMP_FILE_NAME );
      JSON.GET( TEMP_FILE, OUT_ITEM );
      OPEN( TEMP_FILE, IN_FILE, TEMP_FILE_NAME );
      DELETE( TEMP_FILE );
    end;
    return  OUT_ITEM;

  end	ITEM_OF;
	-------



			--  J S O N   S T R U C T U R E   I N T E R A C T I O N


			----
  function 		KIND		( OF_ITEM :ITEM )		return ITEM_TYPE
  is
  begin
    return  OF_ITEM.all.KIND;

  end	KIND;
	----



			----------
  function 		IS_PRESENT	( KEY :STRING; IN_OBJECT :ITEM )	return BOOLEAN
  			----------
  is
    SEARCH_KEY	: STRING		renames KEY;
    KEY_SEEN	: BOOLEAN		:= FALSE;

		-------
    procedure	PROCESS	( THE_KEY	     :STRING;
			  THE_ITEM     :in out ITEM;
			  LAST_ONE     :in BOOLEAN;
			  STOP_PROCESS :out BOOLEAN )
    is		-------
    begin
      if  THE_KEY = SEARCH_KEY  then  KEY_SEEN := TRUE;  end if;
      STOP_PROCESS := KEY_SEEN;

    end	PROCESS;
	-------

    procedure SCAN is new FOR_EACH_JSON_FIELD( PROCESS );


  begin
    if  IN_OBJECT.all.KIND /= OBJECT_ITEM  then  raise BAD_ITEM_TYPE;  end if;

    SCAN( IN_OBJECT );
    return  KEY_SEEN;

  end	IS_PRESENT;
	----------



			-----------
  function		ITEM_BY_KEY	( KEY :STRING; IN_OBJECT :ITEM )	return ITEM
			-----------
  is
    SEARCH_KEY		: STRING		renames KEY;
    FOUND_ITEM		: ITEM		:= null;

		-------
    procedure	PROCESS	( THE_KEY	     :STRING;
			  THE_ITEM     :in out ITEM;
			  LAST_ONE     :in BOOLEAN;
			  STOP_PROCESS :out BOOLEAN )
    is		-------
    begin
      if  THE_KEY = SEARCH_KEY  then  FOUND_ITEM := THE_ITEM;  end if;
      STOP_PROCESS := (FOUND_ITEM /= null);

    end	PROCESS;
	-------

    procedure SCAN is new FOR_EACH_JSON_FIELD( PROCESS );


  begin
    if  IN_OBJECT.all.KIND /= OBJECT_ITEM  then  raise BAD_ITEM_TYPE;  end if;

    SCAN( IN_OBJECT );
    if  FOUND_ITEM = null  then  raise VALUE_NOT_FOUND;  end if;
    return  FOUND_ITEM;

  end	ITEM_BY_KEY;
	------------



			----------
  function		ITEM_VALUE		( OF_ITEM :ITEM )		return VALUE_DATA
			----------
  is
  begin
    case KIND( OF_ITEM ) is

      when OBJECT_ITEM | ARRAY_ITEM
	 =>
	  raise BAD_ITEM_TYPE;

      when STRING_ITEM
	 =>
	  declare
	    THE_STRING	: STRING	renames	OF_ITEM.all.STR_ACCESS.all;
	    STRING_LENGTH	:constant NATURAL	:= THE_STRING'LENGTH;
	  begin
	    return ( STRING_ITEM, STRING_LENGTH, THE_STRING );
	  end;

      when INTEGER_ITEM
	 =>
	  return ( INTEGER_ITEM, 0, OF_ITEM.all.INT_VAL );

      when FLOAT_ITEM
	 =>
	  return ( FLOAT_ITEM, 0, OF_ITEM.all.FLOAT_VAL );

      when BOOLEAN_ITEM
	 =>
	  return ( BOOLEAN_ITEM, 0, OF_ITEM.all.BOOL_VAL );

      when NULL_ITEM
	 =>
	  return ( NULL_ITEM, 0 );

      end case;

  end	ITEM_VALUE;
	----------



			-------------------
  function		NUMBER_OF_SUB_ITEMS		( IN_ITEM :ITEM )		return NATURAL
			-------------------
  is
    COUNT		: NATURAL	:= 0;
  begin
     case KIND( IN_ITEM ) is

      when OBJECT_ITEM
	 =>
	  declare
	    THE_LIST	: OBJECT_FIELD_ACCESS	:= IN_ITEM.all.FIELDS_LIST;
	  begin
	    while  THE_LIST /= null  loop
	      COUNT := COUNT + 1;
	      THE_LIST := THE_LIST.all.NEXT;
	    end loop;
	  end;

      when ARRAY_ITEM
	 =>
	  declare
	    THE_LIST	: LIST_OF_ITEMS	:= IN_ITEM.all.ITEMS_LIST;
	  begin
	    while  THE_LIST /= null  loop
	      COUNT := COUNT + 1;
	      THE_LIST := THE_LIST.all.NEXT;
	    end loop;
	  end;

      when others => null;

      end case;
      return COUNT;

  end	NUMBER_OF_SUB_ITEMS;
	-------------------



			----
  procedure		FREE			( THE_ITEM :in out ITEM )
			----
  is
    procedure FREE is new UNCHECKED_DEALLOCATION( ITEM_DEFINITION, ITEM );
    procedure FREE is new UNCHECKED_DEALLOCATION( OBJECT_FIELD, OBJECT_FIELD_ACCESS );
    procedure FREE is new UNCHECKED_DEALLOCATION( ITEM_LIST_ELEMENT, LIST_OF_ITEMS );
    procedure FREE is new UNCHECKED_DEALLOCATION( STRING, STRING_ACCESS );
  begin
     case KIND( THE_ITEM ) is

      when OBJECT_ITEM
	 =>
	  declare
	    THE_LIST	: OBJECT_FIELD_ACCESS	:= THE_ITEM.all.FIELDS_LIST;
	    SUITE		: OBJECT_FIELD_ACCESS;
	  begin
	    while  THE_LIST /= null  loop
	      FREE( THE_LIST.all.FIELD_KEY );
	      FREE( THE_LIST.all.FIELD_ITEM );
	      SUITE := THE_LIST.all.NEXT;
	      FREE( THE_LIST );
	      THE_LIST := SUITE;
	    end loop;
	  end;

      when ARRAY_ITEM
	 =>
	  declare
	    THE_LIST	: LIST_OF_ITEMS	:= THE_ITEM.all.ITEMS_LIST;
	    SUITE		: LIST_OF_ITEMS;
	  begin
	    while  THE_LIST /= null  loop
	      FREE( THE_LIST.all.LIST_ITEM );
	      SUITE := THE_LIST.all.NEXT;
	      FREE( THE_LIST );
	      THE_LIST := SUITE;
	    end loop;
	  end;

      when others => null;

      end case;

      THE_ITEM.all := ( KIND=> NULL_ITEM );

  end	FREE;
	----



			------------------
  procedure		FOR_EACH_JSON_ITEM		( OF_ARRAY :JSON.ITEM )
			------------------
  is
  begin
    if  OF_ARRAY = null  or else  OF_ARRAY.all.KIND /= ARRAY_ITEM  then  raise BAD_ITEM_TYPE;  end if;

    declare
      STOP_PROCESS		: BOOLEAN;
      ITEM_LIST		: LIST_OF_ITEMS	:= OF_ARRAY.all.ITEMS_LIST;
      LAST_ONE		: BOOLEAN;
    begin
      loop
        exit when  ITEM_LIST = null;
        LAST_ONE := (ITEM_LIST.all.NEXT = null);
        APPLY_PROCESS( ITEM_LIST.all.LIST_ITEM, LAST_ONE, STOP_PROCESS );
        exit when  STOP_PROCESS;
        ITEM_LIST := ITEM_LIST.all.NEXT;
      end loop;
    end;

  end	FOR_EACH_JSON_ITEM;
	------------------



			-------------------
  procedure		FOR_EACH_JSON_FIELD		( OF_OBJECT :JSON.ITEM )
			-------------------
  is
  begin
    if  OF_OBJECT = null  or else  OF_OBJECT.all.KIND /= OBJECT_ITEM  then  raise BAD_ITEM_TYPE;  end if;

    declare
      FIELDS		: OBJECT_FIELD_ACCESS	:= OF_OBJECT.all.FIELDS_LIST;
      STOP_PROCESS		: BOOLEAN;
      LAST_ONE		: BOOLEAN;
    begin
      while  FIELDS /= null  loop
        LAST_ONE := (FIELDS.all.NEXT = null);
        APPLY_PROCESS( FIELDS.all.FIELD_KEY.all, FIELDS.all.FIELD_ITEM, LAST_ONE, STOP_PROCESS );
        exit when  STOP_PROCESS;
        FIELDS := FIELDS.all.NEXT;
      end loop;
    end;

  end	FOR_EACH_JSON_FIELD;
	-------------------



	----
end	JSON;
	----

--	1	2	3	4	5	6	7	8	9	0	1	2
-------------------------------------------------------------------------------------------------------------------------

