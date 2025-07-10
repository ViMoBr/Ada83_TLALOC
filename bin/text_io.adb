with MACHINE_CODE;
use  MACHINE_CODE;
					-------
	package body			TEXT_IO
is					-------

  STDOUT_PAGE_LENGTH	: COUNT		:= 72;
  STDOUT_LINE_LENGTH	: COUNT		:= 256;
  STDOUT_PAGE		: POSITIVE_COUNT	:= 1;
  STDOUT_LINE		: POSITIVE_COUNT	:= 1;
  STDOUT_COL		: POSITIVE_COUNT	:= 1;


			--   F I L E   M A N A G E M E N T

			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE := OUT_FILE;
					  NAME :in STRING := "";
					  FORM :in STRING := ""
					)
  is			------

    ERR_OR_ID	: INTEGER;

		------------------
    function	CREATE_SYSTEM_CALL	( NAME :in STRING )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_CREATE );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );

    end	CREATE_SYSTEM_CALL;
	------------------

  begin
    ERR_OR_ID := CREATE_SYSTEM_CALL( NAME );
    if  ERR_OR_ID >= 0  then
      FILE.ID := ERR_OR_ID;
      FILE.NAME( 1 .. NAME'LENGTH ) := NAME;
      FILE.NAME_LEN := NAME'LENGTH;
      FILE.MODE := MODE;
      FILE.PAGE_LENGTH := STDOUT_PAGE_LENGTH;
      FILE.LINE_LENGTH := STDOUT_LINE_LENGTH;
      FILE.PAGE := 1;
      FILE.LINE := 1;
      FILE.COL  := 1;
    end if;

  end	CREATE;
	------


			----
  procedure		OPEN		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE;
					  NAME :in STRING;
					  FORM :in STRING := ""
					)
  is			----

    ERR_OR_ID	: INTEGER;

		----------------
    function	OPEN_SYSTEM_CALL	( NAME :in STRING )	return INTEGER
    is		----------------
    begin
      ASM_OP_2'( OPCODE => LA, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_OPEN );
      ASM_OP_2'( OPCODE => SD, LVL => 2, OFS => -16 );							-- Retour du File ID

    end	OPEN_SYSTEM_CALL;
	----------------

  begin
    ERR_OR_ID := OPEN_SYSTEM_CALL( NAME );
    if  ERR_OR_ID >= 0  then
      FILE.ID := OPEN_SYSTEM_CALL( NAME );
      FILE.NAME( 1 .. NAME'LENGTH ) := NAME;
      FILE.NAME_LEN := NAME'LENGTH;
      FILE.MODE := MODE;
      FILE.PAGE_LENGTH := STDOUT_PAGE_LENGTH;
      FILE.LINE_LENGTH := STDOUT_LINE_LENGTH;
      FILE.PAGE := 1;
      FILE.LINE := 1;
      FILE.COL  := 1;
    end if;

  end	OPEN;
	----


			-----
  procedure		CLOSE		( FILE :in out FILE_TYPE )
  is			-----

    ERR_CODE	: INTEGER;

 		-----------------
    function	CLOSE_SYSTEM_CALL	( FILE_ID :in INTEGER )	return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_CLOSE );

    end	CLOSE_SYSTEM_CALL;
    -----------------

  begin
    ERR_CODE := CLOSE_SYSTEM_CALL( FILE.ID );
    FILE.ID := -1;

  end	CLOSE;
	-----


			------
  procedure		DELETE		( FILE :in out FILE_TYPE )
  is			------

    ERR_CODE	: INTEGER;

		------------------
    function	DELETE_SYSTEM_CALL	( NAME : STRING )	return INTEGER
    is		------------------

    begin
      ASM_OP_2'( OPCODE => La, LVL => 2, OFS => -8 );
      ASM_OP_0'( OPCODE => SYS_FILE_DELETE );

    end	DELETE_SYSTEM_CALL;
	------------------

  begin
    ERR_CODE := DELETE_SYSTEM_CALL( FILE.NAME( 1 .. FILE.NAME_LEN ) );

  end	DELETE;
	------


			-----
  procedure		RESET		( FILE :in out FILE_TYPE; MODE :in FILE_MODE )
  is			-----
  begin null;

  end	RESET;
	-----

			-----
  procedure		RESET		( FILE :in out FILE_TYPE )
  is			-----
  begin null;

  end	RESET;
	-----

			----
  function		MODE		( FILE :in FILE_TYPE )		return FILE_MODE
  is			----
  begin
    return FILE.MODE;
  end	MODE;
	----

			----
  function		NAME		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    return FILE.NAME( 1 .. FILE.NAME_LEN );
  end	NAME;
	----

			----
  function		FORM		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    return "";
  end	FORM;
	----

			-------
  function		IS_OPEN		( FILE :in FILE_TYPE )		return BOOLEAN
  is			-------
  begin null;
    return FILE.ID = -1;
  end	IS_OPEN;
	-------

           -- Control of default input and output files

			---------
  procedure		SET_INPUT		( FILE :in FILE_TYPE )
  is			---------
  begin null;

  end	SET_INPUT;
	---------

			----------
  procedure		SET_OUTPUT	( FILE :in FILE_TYPE )
  is			----------
  begin null;

  end	SET_OUTPUT;
	----------

			--------------
  function		STANDARD_INPUT					return FILE_TYPE
  is			--------------
  begin null;

  end	STANDARD_INPUT;
	--------------

			---------------
  function		STANDARD_OUTPUT					return FILE_TYPE
  is			---------------
  begin null;

  end	STANDARD_OUTPUT;
	---------------

			-------------
  function		CURRENT_INPUT					return FILE_TYPE
  is			-------------
  begin null;

  end	CURRENT_INPUT;
	-------------

			--------------
  function		CURRENT_OUTPUT					return FILE_TYPE
  is			--------------
  begin null;

  end	CURRENT_OUTPUT;
	--------------

           -- Specification of line and page lengths

			---------------
  procedure		SET_LINE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is			---------------
  begin
    FILE.LINE_LENGTH := TO;
  end	SET_LINE_LENGTH;
	---------------

			---------------
  procedure		SET_LINE_LENGTH	( TO   :in COUNT)
  is			---------------
  begin
    STDOUT_LINE_LENGTH := TO;
  end	SET_LINE_LENGTH;
	---------------

			---------------
  procedure		SET_PAGE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is			---------------
  begin
    FILE.PAGE_LENGTH := TO;
  end	SET_PAGE_LENGTH;
	---------------

			---------------
  procedure		SET_PAGE_LENGTH	( TO   :in COUNT)
  is			---------------
  begin
    STDOUT_PAGE_LENGTH := TO;
  end	SET_PAGE_LENGTH;
	---------------

			-----------
  function		LINE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is			-----------
  begin
    return FILE.LINE_LENGTH;
  end	LINE_LENGTH;
	-----------

			-----------
  function		LINE_LENGTH					return COUNT
  is			-----------
  begin
    return STDOUT_LINE_LENGTH;
  end	LINE_LENGTH;
	-----------

			-----------
  function		PAGE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is			-----------
  begin
    return FILE.PAGE_LENGTH;
  end	PAGE_LENGTH;
	-----------

			-----------
  function		PAGE_LENGTH					return COUNT
  is			-----------
  begin
    return STDOUT_PAGE_LENGTH;
  end	PAGE_LENGTH;
	-----------

           -- Column, Line, and Page Control

			--------
  procedure		NEW_LINE		( FILE    :in FILE_TYPE;
					  SPACING :in POSITIVE_COUNT := 1 )
  is			--------
  begin
    PUT( FILE, ASCII.CR );
    FILE.COL := 1;											-- LRM 14.3.4(3) col := 1
    for  N in 1 .. SPACING  loop
      PUT( FILE, ASCII.LF );
    end loop;
    FILE.LINE := FILE.LINE + SPACING;
    if  FILE.LINE > FILE.PAGE_LENGTH  then
      PUT( FILE,ASCII.FF );
      FILE.PAGE := FILE.PAGE + 1;
      FILE.LINE := 1;
    end if;

  end	NEW_LINE;
	--------

			--------
  procedure		NEW_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is			--------
  begin
    PUT( ASCII.CR );
    STDOUT_COL := 1;										-- LRM 14.3.4(3) col := 1
    for  N in 1 .. SPACING  loop
      PUT( ASCII.LF );
    end loop;
    STDOUT_LINE := STDOUT_LINE + SPACING;
    if  STDOUT_LINE > STDOUT_PAGE_LENGTH  then
      PUT( ASCII.FF );
      STDOUT_PAGE := STDOUT_PAGE + 1;
      STDOUT_LINE := 1;
    end if;

  end	NEW_LINE;
	--------

			---------
  procedure		SKIP_LINE		( FILE    :in FILE_TYPE;
					  SPACING :in POSITIVE_COUNT := 1 )
  is			---------
  begin
    null;

  end	SKIP_LINE;
	---------

			---------
  procedure		SKIP_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is			---------
  begin
    STDOUT_LINE := STDOUT_LINE + SPACING;

  end	SKIP_LINE;
	---------

			-----------
  function		END_OF_LINE	( FILE :in FILE_TYPE)		return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_LINE;
	-----------

			-----------
  function		END_OF_LINE					return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_LINE;
	-----------

			--------
  procedure		NEW_PAGE		( FILE :in FILE_TYPE )
  is			--------
  begin null;

  end	NEW_PAGE;
	--------
			--------
  procedure		NEW_PAGE
  is			--------
  begin null;

  end	NEW_PAGE;
	----

			---------
  procedure		SKIP_PAGE		( FILE :in FILE_TYPE )
  is			---------
  begin null;

  end	SKIP_PAGE;
	---------

			---------
  procedure		SKIP_PAGE
  is			---------
  begin null;

  end	SKIP_PAGE;
	---------

			-----------
  function		END_OF_PAGE	( FILE :in FILE_TYPE ) 		return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_PAGE;
	-----------

			-----------
  function		END_OF_PAGE 					return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_PAGE;
	-----------

			-----------
  function		END_OF_FILE	( FILE :in FILE_TYPE )		return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_FILE;
	-----------

			-----------
  function		END_OF_FILE					return BOOLEAN
  is			-----------
  begin null;

  end	END_OF_FILE;
	-----------

			-------
  procedure		SET_COL		( FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is			-------
  begin
    FILE.COL := TO;
  end	SET_COL;
	-------

			-------
  procedure		SET_COL		( TO   :in POSITIVE_COUNT )
  is			-------
  begin
    STDOUT_COL := TO;
  end	SET_COL;
	-------

			--------
  procedure 		SET_LINE		(FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is			--------
  begin
    FILE.LINE := TO;
  end	SET_LINE;
	--------

			--------
  procedure		SET_LINE		(TO   :in POSITIVE_COUNT )
  is			--------
  begin
    STDOUT_LINE := TO;
  end	SET_LINE;
	--------

			---
  function		COL		(FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			---
  begin
    return FILE.COL;
  end	COL;
	---

			---
  function		COL						return POSITIVE_COUNT
  is			---
  begin
    return STDOUT_COL;
  end	COL;
	---

			----
  function		LINE		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			----
  begin
    return FILE.LINE;
  end	LINE;
	----

			----
  function		LINE						return POSITIVE_COUNT
  is			----
  begin null;
    return STDOUT_LINE;
  end	LINE;
	----

			----
  function		PAGE		(FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			----
  begin null;
    return FILE.PAGE;
  end	PAGE;
	----

			----
  function		PAGE 						return POSITIVE_COUNT
  is			----
  begin null;
    return STDOUT_PAGE;
  end	PAGE;
	----

           -- Character Input-Output

			---
  procedure		GET		( FILE :in FILE_TYPE; ITEM :out CHARACTER )
  is			---
  begin null;

  end	GET;
	----

			---
  procedure		GET		( ITEM :out CHARACTER )
  is			---
  begin
    ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -8 );
    ASM_OP_0'( OPCODE => SYS_GET_CHAR );

  end	GET;
	----

			---
  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in CHARACTER )
  is			---

    ERR_CODE	: INTEGER;

  		-----------------
    function	WRITE_SYSTEM_CALL		( ID : INTEGER )		return INTEGER
    is		-----------------
    begin
      ASM_OP_1'( OPCODE => LI, VAL => 1 );					-- LENGTH en -24
      ASM_OP_2'( OPCODE => LVa, LVL => 1, OFS => -16 );				-- @CHAR sur parametre de PUT
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );				-- ID
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );

    end	WRITE_SYSTEM_CALL;
	-----------------
  begin
    ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID );

  end	PUT;
	----

			---
  procedure		PUT		( ITEM :in CHARACTER )
  is			---
  begin
    ASM_OP_2'( OPCODE => LB, LVL => 1, OFS => -8 );
    ASM_OP_0'( OPCODE => SYS_PUT_CHAR );

  end	PUT;
	----


           -- String Input-Output

			---
  procedure		GET		( FILE :in FILE_TYPE; ITEM :out STRING )
  is			--
  begin null;

  end	GET;
	----

			---
  procedure		GET		( ITEM :out STRING )
  is			---
  begin null;

  end	GET;
	----

			---
  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in STRING )
  is			---

    ERR_CODE	: INTEGER;

  		-----------------
    function	WRITE_SYSTEM_CALL		( FILE_ID :INTEGER; LENGTH :POSITIVE )		return INTEGER
    is		-----------------
    begin
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -16 );				-- LENGTH en -16
      ASM_OP_2'( OPCODE => LIa, LVL => 1, OFS => -16 );				-- @CHARS sur parametre ITEM de PUT
      ASM_OP_2'( OPCODE => Ld, LVL => 2, OFS => -8 );				-- ID
      ASM_OP_0'( OPCODE => SYS_FILE_WRITE );

    end	WRITE_SYSTEM_CALL;
	-----------------
  begin
    ERR_CODE := WRITE_SYSTEM_CALL( FILE.ID, ITEM'LENGTH );

  end	PUT;
	----

			---
  procedure		PUT		( ITEM :in STRING )
  is			---
  begin
    ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -8 );
    ASM_OP_0'( OPCODE => SYS_PUT_STR );

  end	PUT;
	----

			--------
  procedure		GET_LINE		( FILE :in FILE_TYPE;
					  ITEM :out STRING;
					  LAST :out NATURAL
					)
  is			--------
  begin null;

  end	GET_LINE;
	--------

			--------
  procedure		GET_LINE		( ITEM :out STRING;   LAST :out NATURAL )
  is			--------
  begin
    ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -16 );		-- adresse de LAST
    ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -8 );		-- adresse du descripteur de la chaine ITEM
    ASM_OP_0'( OPCODE => SYS_GET_STR );

  end	GET_LINE;
	--------

			--------
  procedure		PUT_LINE		( FILE :in FILE_TYPE; ITEM :in STRING )
  is			--------
  begin
    PUT( FILE, ITEM );
    NEW_LINE( FILE );

  end	PUT_LINE;
	--------

			--------
  procedure		PUT_LINE		( ITEM :in STRING )
  is			--------
  begin
    PUT( ITEM );
    NEW_LINE;

  end	PUT_LINE;
	--------


          	 -- Generic package for Input-Output of Integer Types

  				----------
  package	body			INTEGER_IO
  is				----------

			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD := 0
					)
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH : in FIELD := 0)
    is			---

      CHN	: STRING( 1 .. 40 );
      LEN	: NATURAL		:= 40;
      VAL	: NUM		:= 0;

    begin
      GET_LINE( CHN, LEN );
      for  I in 1 .. LEN  loop
        VAL := 10 * VAL + CHARACTER'POS( CHN( I ) ) - CHARACTER'POS( '0' );
      end loop;
      ITEM := VAL;
      PUT( CHN );
    end	GET;
	----

			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---
    begin null;

    end	PUT;
	----

			---
    procedure		PUT		( ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---

      QUOTIENT, RESTE	: NUM;
      STR			: STRING( 1 .. 68 );
      INDEX		: POSITIVE		:= STR'LAST;
      MIN_WIDTH		: POSITIVE;

    begin
      null;
--    if BASE /= 10 then STR( STR'LAST ) := '#'; INDEX := INDEX - 1; end if;

--    loop
--      RESTE := ITEM mod NUM( BASE );
--      if RESTE < 10 then
--        STR( INDEX ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + RESTE );
--      else 
--        STR( INDEX ) := CHARACTER'VAL( CHARACTER'POS( 'A' ) + RESTE - 10 );
--      end if;
--      QUOTIENT := ITEM / NUM( BASE );
--      exit when QUOTIENT = 0;
--      INDEX := INDEX - 1;
--    end loop;

--    if BASE /= 10 then
--      STR( INDEX ) := '#'; INDEX := INDEX - 1;
--      STR( INDEX ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE mod 10 ); INDEX := INDEX - 1;
--      if BASE >= 10 then STR( INDEX ) := '1'; INDEX := INDEX - 1; end if;
--    end if;

--    if ITEM < 0 then STR( INDEX ) := '-'; end if;
--    MIN_WIDTH := STR'LAST - INDEX - 1;

--    if WIDTH > MIN_WIDTH then null; end if;

    end	PUT;
	----

			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  BASE :in NUMBER_BASE	:= DEFAULT_BASE
					)
    is			---
    begin null;

    end	PUT;
	----

  end	INTEGER_IO;
	----------


		-- Generic package for Input-Output of Real Types

				--------
  package	body			FLOAT_IO
  is				--------

    			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD		:= 0
					)
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH :in FIELD := 0)
    is			---
    begin null;

    end	GET;
	----

    			---
    procedure		PUT		( FILE :in FILE_TYPE;
					  ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
    ----

    			---
    procedure		PUT		( ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
	----


    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
	----

	--------
  end	FLOAT_IO;
	--------


				--------
  package	body			FIXED_IO
  is				--------

			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD		:= 0
					)
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH :in FIELD := 0 )
    is			---
    begin null;

    end	GET;
	----

			---
    procedure		PUT		( FILE :in FILE_TYPE;
					  ITEM :in NUM;
					  FORE :in FIELD 		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
	----

			---
    procedure		PUT		( ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---
  begin null;

  end	PUT;
	----

			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out NUM;
					  LAST :out POSITIVE
					)
    is			---
  begin null;

  end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
    is			---
    begin null;

    end	PUT;
	----

	--------
  end	FIXED_IO;
	--------


           -- Generic package for Input-Output of Enumeration types


			--------------
  package	body		ENUMERATION_IO
  is			--------------

    			---
    procedure		GET		( FILE :in FILE_TYPE; ITEM :out ENUM)
    is			---
    begin null;

    end	GET;
	---

			---
    procedure		GET		( ITEM :out ENUM)
    is			---
    begin null;

    end	GET;
	---

			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
    is			---
    begin null;

    end	PUT;
	---

			---
    procedure		PUT		( ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
    is			---
    begin null;

    end	PUT;
	----

			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out ENUM;
					  LAST :out POSITIVE
					)
    is			---
    begin null;

    end	GET;
	---

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in ENUM;
					  SET  :in TYPE_SET		:= DEFAULT_SETTING
					)
    is			---
    begin null;

    end	PUT;
	----

  end	ENUMERATION_IO;
	--------------


 end	TEXT_IO;
	-------
