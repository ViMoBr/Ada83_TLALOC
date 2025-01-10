with MACHINE_CODE;
use  MACHINE_CODE;
					-------
	package body			TEXT_IO
is					-------

           -- File Management

			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE := OUT_FILE;
					  NAME :in STRING := "";
					  FORM :in STRING := ""
					)
  is
    I	: INTEGER	:= 0;
  begin null;

  end	CREATE;
	------

			----
  procedure		OPEN		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE;
					  NAME :in STRING;
					  FORM :in STRING := ""
					)
is
  begin null;

  end	OPEN;
	----

			-----
  procedure		CLOSE		( FILE :in out FILE_TYPE )
is
  begin null;

  end	CLOSE;
	-----

			------
  procedure		DELETE		( FILE :in out FILE_TYPE )
  is
  begin null;

  end	DELETE;
	------

			-----
  procedure		RESET		( FILE :in out FILE_TYPE; MODE :in FILE_MODE )
  is
  begin null;

  end	RESET;
	-----

			-----
  procedure		RESET		( FILE :in out FILE_TYPE )
  is
  begin null;

  end	RESET;
	-----

			----
  function		MODE		( FILE :in FILE_TYPE )		return FILE_MODE
  is
  begin null;

  end	MODE;
	----

			----
  function		NAME		( FILE :in FILE_TYPE )		return STRING
  is
  begin null;

  end	NAME;
	----

			----
  function		FORM		( FILE :in FILE_TYPE )		return STRING
  is
  begin null;

  end	FORM;
	----

			-------
  function		IS_OPEN		( FILE :in FILE_TYPE )		return BOOLEAN
  is
  begin null;

  end	IS_OPEN;
	-------

           -- Control of default input and output files

			---------
  procedure		SET_INPUT		( FILE :in FILE_TYPE )
  is
  begin null;

  end	SET_INPUT;
	---------

			----------
  procedure		SET_OUTPUT	( FILE :in FILE_TYPE )
  is
  begin null;

  end	SET_OUTPUT;
	----------

			--------------
  function		STANDARD_INPUT					return FILE_TYPE
  is
  begin null;

  end	STANDARD_INPUT;
	--------------

			---------------
  function		STANDARD_OUTPUT					return FILE_TYPE
  is
  begin null;

  end	STANDARD_OUTPUT;
	---------------

			-------------
  function		CURRENT_INPUT					return FILE_TYPE
  is
  begin null;

  end	CURRENT_INPUT;
	-------------

			--------------
  function		CURRENT_OUTPUT					return FILE_TYPE
  is
  begin null;

  end	CURRENT_OUTPUT;
	--------------

           -- Specification of line and page lengths

			---------------
  procedure		SET_LINE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is
  begin null;

  end	SET_LINE_LENGTH;
	---------------

			---------------
  procedure		SET_LINE_LENGTH	( TO   :in COUNT)
  is
  begin null;

  end	SET_LINE_LENGTH;
	---------------

			---------------
  procedure		SET_PAGE_LENGTH	( FILE :in FILE_TYPE; TO :in COUNT )
  is
  begin null;

  end	SET_PAGE_LENGTH;
	---------------

			---------------
  procedure		SET_PAGE_LENGTH	( TO   :in COUNT)
  is
  begin null;

  end	SET_PAGE_LENGTH;
	---------------

			-----------
  function		LINE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is
  begin null;

  end	LINE_LENGTH;
	-----------

			-----------
  function		LINE_LENGTH					return COUNT
  is
  begin null;

  end	LINE_LENGTH;
	-----------

			-----------
  function		PAGE_LENGTH	( FILE :in FILE_TYPE )		return COUNT
  is
  begin null;

  end	PAGE_LENGTH;
	-----------

			-----------
  function		PAGE_LENGTH					return COUNT
  is
  begin null;

  end	PAGE_LENGTH;
	-----------

           -- Column, Line, and Page Control

			--------
  procedure		NEW_LINE		( FILE    :in FILE_TYPE;
					  SPACING :in POSITIVE_COUNT := 1 )
  is
  begin null;

  end	NEW_LINE;
	--------

			--------
  procedure		NEW_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is
  begin
    for N in 1 .. SPACING loop
      PUT( ASCII.LF );
    end loop;
  end	NEW_LINE;
	--------

			---------
  procedure		SKIP_LINE		( FILE    :in FILE_TYPE;
					  SPACING :in POSITIVE_COUNT := 1 )
  is
  begin null;

  end	SKIP_LINE;
	---------

			---------
  procedure		SKIP_LINE		( SPACING :in POSITIVE_COUNT := 1 )
  is
  begin null;

  end	SKIP_LINE;
	---------

			-----------
  function		END_OF_LINE	( FILE :in FILE_TYPE)		return BOOLEAN
  is
  begin null;

  end	END_OF_LINE;
	-----------

			-----------
  function		END_OF_LINE					return BOOLEAN
  is
  begin null;

  end	END_OF_LINE;
	-----------

			--------
  procedure		NEW_PAGE		( FILE :in FILE_TYPE )
  is
  begin null;

  end	NEW_PAGE;
	--------
			--------
  procedure		NEW_PAGE
  is
  begin null;

  end	NEW_PAGE;
	----

			---------
  procedure		SKIP_PAGE		( FILE :in FILE_TYPE )
  is
  begin null;

  end	SKIP_PAGE;
	---------

			---------
  procedure		SKIP_PAGE
  is
  begin null;

  end	SKIP_PAGE;
	---------

			-----------
  function		END_OF_PAGE	( FILE :in FILE_TYPE ) 		return BOOLEAN
  is
  begin null;

  end	END_OF_PAGE;
	-----------

			-----------
  function		END_OF_PAGE 					return BOOLEAN
  is
  begin null;

  end	END_OF_PAGE;
	-----------

			-----------
  function		END_OF_FILE	(FILE :in FILE_TYPE )		return BOOLEAN
  is
  begin null;

  end	END_OF_FILE;
	-----------

			-----------
  function		END_OF_FILE					return BOOLEAN
  is
  begin null;

  end	END_OF_FILE;
	-----------


  procedure		SET_COL		(FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is
  begin null;

  end	SET_COL;
	-------

			-------
  procedure		SET_COL		(TO   :in POSITIVE_COUNT )
  is
  begin null;

  end	SET_COL;
	-------

			--------
  procedure 		SET_LINE		(FILE :in FILE_TYPE; TO :in POSITIVE_COUNT )
  is
  begin null;

  end	SET_LINE;
	--------

			--------
  procedure		SET_LINE		(TO   :in POSITIVE_COUNT )
  is
  begin null;

  end	SET_LINE;
	--------

			---
  function		COL		(FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is
  begin null;

  end	COL;
	---

			---
  function		COL						return POSITIVE_COUNT
  is
  begin null;

  end	COL;
	---

			----
  function		LINE		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is
  begin null;

  end	LINE;
	----

			----
  function		LINE						return POSITIVE_COUNT
  is
  begin null;

  end	LINE;
	----

			----
  function		PAGE		(FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is
  begin null;

  end	PAGE;
	----

			----
  function		PAGE 						return POSITIVE_COUNT
  is
  begin null;

  end	PAGE;
	----

           -- Character Input-Output

  procedure		GET		( FILE :in FILE_TYPE; ITEM :out CHARACTER )
  is
  begin null;

  end	GET;
	----


  procedure		GET		( ITEM :out CHARACTER )
  is
  begin null;

  end	GET;
	----


  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in CHARACTER )
  is
  begin null;

  end	PUT;
	----


  procedure		PUT		( ITEM :in CHARACTER )
  is
  begin
       ASM_OP_2'( OPCODE => LB, LVL => 1, OFS => -16 );
       ASM_OP_0'( OPCODE => PUT_CHAR );

  end	PUT;
	----


           -- String Input-Output

  procedure		GET		( FILE :in FILE_TYPE; ITEM :out STRING )
  is
  begin null;

  end	GET;
	----


  procedure		GET		( ITEM :out STRING )
  is
  begin null;

  end	GET;
	----


  procedure		PUT		( FILE :in FILE_TYPE; ITEM :in STRING )
  is
  begin null;

  end	PUT;
	----


  procedure		PUT		( ITEM :in STRING )
  is
  begin
       ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -16 );
       ASM_OP_0'( OPCODE => PUT_STR );

  end	PUT;
	----

			--------
  procedure		GET_LINE		( FILE :in FILE_TYPE;
					  ITEM :out STRING;
					  LAST :out NATURAL
					)
  is
  begin null;

  end	GET_LINE;
	--------

			--------
  procedure		GET_LINE		( ITEM :out STRING;   LAST :out NATURAL )
  is
  begin null;

  end	GET_LINE;
	--------

			--------
  procedure		PUT_LINE		( FILE :in FILE_TYPE; ITEM :in STRING )
  is
  begin null;

  end	PUT_LINE;
	--------

			--------
  procedure		PUT_LINE		( ITEM :in STRING )
  is
  begin
       ASM_OP_2'( OPCODE => LA, LVL => 1, OFS => -16 );
       ASM_OP_0'( OPCODE => PUT_STR );

  end	PUT_LINE;
	--------

           -- Generic package for Input-Output of Integer Types

  package	body		INTEGER_IO
  is			----------

			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD := 0
					)
  is
  begin null;

  end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH : in FIELD := 0)
  is
  begin null;

  end	GET;
	----

    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
  is
  begin null;

  end	PUT;
	----

			---
    procedure		PUT		( ITEM  :in NUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  BASE  :in NUMBER_BASE	:= DEFAULT_BASE
					)
  is
    QUOTIENT, RESTE	: NUM;
    STR		: STRING( 1 .. 68 );
    INDEX		: POSITIVE		:= STR'LAST;
    MIN_WIDTH	: POSITIVE;

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
  is
  begin null;

  end	GET;
	----

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  BASE :in NUMBER_BASE	:= DEFAULT_BASE
					)
  is
  begin null;

  end	GET;
	----

  end	INTEGER_IO;
	----------

           -- Generic package for Input-Output of Real Types

			--------
  package	body		FLOAT_IO
  is			--------

    procedure GET		( FILE  :in FILE_TYPE;
			  ITEM  :out NUM;
			  WIDTH :in FIELD		:= 0
			)
  is
  begin null;

  end	GET;
	----
    procedure GET		( ITEM  :out NUM; WIDTH :in FIELD := 0)
  is
  begin null;

  end	GET;
	----

    procedure PUT		( FILE :in FILE_TYPE;
			  ITEM :in NUM;
			  FORE :in FIELD		:= DEFAULT_FORE;
			  AFT  :in FIELD		:= DEFAULT_AFT;
			  EXP  :in FIELD		:= DEFAULT_EXP
			)
  is
  begin null;

  end	PUT;
	----
    procedure PUT		( ITEM :in NUM;
			  FORE :in FIELD		:= DEFAULT_FORE;
			  AFT  :in FIELD		:= DEFAULT_AFT;
			  EXP  :in FIELD		:= DEFAULT_EXP
			)
  is
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


    procedure		PUT		( TO   :out STRING;
					  ITEM :in NUM;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in INTEGER		:= DEFAULT_EXP
					)
  is
  begin null;

  end	PUT;
	----

	--------
  end	FLOAT_IO;
	--------


			--------
  package	body		FIXED_IO
  is			--------

			---
    procedure		GET		( FILE  :in FILE_TYPE;
					  ITEM  :out NUM;
					  WIDTH :in FIELD		:= 0
					)
  is
  begin null;

  end	GET;
	----

			---
    procedure		GET		( ITEM  :out NUM; WIDTH :in FIELD := 0 )
  is
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
  is
  begin null;

  end	PUT;
	----

			---
    procedure		PUT		( ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
  is
  begin null;

  end	PUT;
	----

			---
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
			)  is
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

    procedure		GET		( FILE :in FILE_TYPE; ITEM :out ENUM)
  is
  begin null;

  end	GET;
	---

			---
    procedure		GET		( ITEM :out ENUM)  is
  begin null;

  end	GET;
	---

			---
    procedure		PUT		( FILE  :in FILE_TYPE;
					  ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
  is
  begin null;

  end	PUT;
	---

			---
    procedure		PUT		( ITEM  :in ENUM;
					  WIDTH :in FIELD		:= DEFAULT_WIDTH;
					  SET   :in TYPE_SET	:= DEFAULT_SETTING
					)
  is
  begin null;

  end	PUT;
	----

			---
    procedure		GET		( FROM :in STRING;
					  ITEM :out ENUM;
					  LAST :out POSITIVE
					)
  is
  begin null;

  end	GET;
	---

			---
    procedure		PUT		( TO   :out STRING;
					  ITEM :in ENUM;
					  SET  :in TYPE_SET		:= DEFAULT_SETTING
					)
  is
  begin null;

  end	PUT;
	----

  end	ENUMERATION_IO;
	--------------


 end	TEXT_IO;
	-------
