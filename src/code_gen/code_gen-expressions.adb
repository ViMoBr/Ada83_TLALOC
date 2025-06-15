-------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	EXPRESSIONS.ADB	VINCENT MORIN	21/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


separate ( CODE_GEN )
				-----------
 	package body		EXPRESSIONS
				-----------
is


  package CODI	renames CODAGE_INTERMEDIAIRE;

  				--====--
  procedure			CODE_EXP			( EXP :TREE )
  is
  begin
    if EXP.TY in CLASS_NAME  then
      CODE_NAME( EXP );

    elsif  EXP.TY in CLASS_EXP_EXP  then
      CODE_EXP_EXP( EXP );

    end if;
  end	CODE_EXP;
	--====--


				---------
  procedure			CODE_NAME			( NAME : TREE )
  is				---------

  			---------------
    procedure		CODE_DESIGNATOR		( DESIGNATOR : TREE )
    is
    		--------------
      procedure	CODE_USED_NAME		( USED_NAME :TREE )
      is
      begin

        if USED_NAME.TY = DN_USED_OP  then
	CODE_USED_OP( USED_NAME );

        elsif USED_NAME.TY = DN_USED_NAME_ID  then
	CODE_USED_NAME_ID( USED_NAME );

        end if;
      end	CODE_USED_NAME;
	--------------

        		----------------
      procedure	CODE_USED_OBJECT		( USED_OBJECT :TREE )
      is
      begin

        if USED_OBJECT.TY = DN_USED_CHAR  then
	CODE_USED_CHAR( USED_OBJECT );

        elsif USED_OBJECT.TY = DN_USED_OBJECT_ID  then
	CODE_USED_OBJECT_ID( USED_OBJECT );

        end if;
      end	CODE_USED_OBJECT;
	----------------

    begin
      if  DESIGNATOR.TY in CLASS_USED_NAME  then
        CODE_USED_NAME(  NAME );

      elsif  DESIGNATOR.TY in CLASS_USED_OBJECT  then
        CODE_USED_OBJECT( NAME );

      end if;
    end	CODE_DESIGNATOR;
  	---------------

  			-------------
    procedure		CODE_NAME_EXP		( NAME_EXP :TREE )
    is

		-------------
      procedure	CODE_NAME_VAL		( NAME_VAL : TREE )
      is
      begin
        if  NAME_VAL.TY = DN_SELECTED  then
	CODE_SELECTED( NAME_VAL );

        elsif  NAME_VAL.TY = DN_ATTRIBUTE  then
	CODE_ATTRIBUTE( NAME_VAL );

        elsif  NAME_VAL.TY = DN_FUNCTION_CALL  then
	CODE_FUNCTION_CALL( NAME_VAL );

        end if;
      end	CODE_NAME_VAL;
	-------------


    begin
      if  NAME_EXP.TY in CLASS_NAME_VAL  then
        CODE_NAME_VAL(  NAME_EXP );

      elsif NAME_EXP.TY = DN_ALL  then
        CODE_ALL( NAME_EXP );

      elsif  NAME_EXP.TY = DN_INDEXED  then
        CODE_INDEXED( NAME_EXP );									-- LAISSE UNE ADRESSE
        declare
	NAME		: TREE		:= D( AS_NAME, NAME_EXP );
	ARRAY_BASE_TYPE	: TREE		:= D( SM_BASE_TYPE, D( SM_EXP_TYPE, NAME) );
	ARRAY_COMP_TYPE	: TREE		:= D( SM_COMP_TYPE, ARRAY_BASE_TYPE );
	COMP_SIZE		: CHARACTER	:= OPER_SIZ_CHAR( ARRAY_COMP_TYPE );
        begin
	PUT( tab & 'L' & COMP_SIZE );
	if CODI.DEBUG then PUT( tab50 & "; charge depuis adresse empilee " ); end if;
	NEW_LINE;
        end;

      elsif  NAME_EXP.TY = DN_SLICE  then
        CODE_SLICE( NAME_EXP );

      end if;
    end	CODE_NAME_EXP;
	-------------

  begin
    if  NAME.TY in CLASS_DESIGNATOR  then
      CODE_DESIGNATOR(  NAME );

    elsif  NAME.TY in CLASS_NAME_EXP  then
      CODE_NAME_EXP( NAME );

    end if;
  end	CODE_NAME;
	---------


  				------------
  procedure			CODE_EXP_EXP		( EXP_EXP :TREE )
  is				------------

    			------------
    procedure		CODE_EXP_VAL		( EXP_VAL :TREE )
    is
		----------------
      procedure	CODE_EXP_VAL_EXP		( EXP_VAL_EXP :TREE )
      is
 	        --------------
        procedure CODE_QUAL_CONV	( QUAL_CONV :TREE )
        is
        begin

	if  QUAL_CONV.TY = DN_CONVERSION  then
	  CODE_CONVERSION( QUAL_CONV );

	elsif  QUAL_CONV.TY = DN_QUALIFIED  then
	  CODE_QUALIFIED( QUAL_CONV );

	end if;
        end	CODE_QUAL_CONV;
		--------------

        	        ---------------
        procedure CODE_MEMBERSHIP	( MEMBERSHIP :TREE )
        is
        begin

	if  MEMBERSHIP.TY = DN_RANGE_MEMBERSHIP  then
	  CODE_RANGE_MEMBERSHIP( MEMBERSHIP );

	elsif  MEMBERSHIP.TY = DN_TYPE_MEMBERSHIP  then
	  CODE_TYPE_MEMBERSHIP( MEMBERSHIP );

	end if;
        end	CODE_MEMBERSHIP;
		---------------

      begin
        if EXP_VAL_EXP.TY in CLASS_QUAL_CONV then
	CODE_QUAL_CONV( EXP_VAL_EXP );

        elsif EXP_VAL_EXP.TY in CLASS_MEMBERSHIP then
	CODE_MEMBERSHIP( EXP_VAL_EXP );

        elsif EXP_VAL_EXP.TY = DN_PARENTHESIZED then
	CODE_PARENTHESIZED( EXP_VAL_EXP );

        end if;

      end	CODE_EXP_VAL_EXP;
      ----------------

    begin
      if  EXP_VAL.TY in CLASS_EXP_VAL_EXP  then
        CODE_EXP_VAL_EXP( EXP_VAL );

      elsif  EXP_VAL.TY = DN_NUMERIC_LITERAL then
        CODE_NUMERIC_LITERAL( EXP_VAL );

      elsif EXP_VAL.TY = DN_NULL_ACCESS  then
        CODE_NULL_ACCESS( EXP_VAL );

      elsif  EXP_VAL.TY = DN_SHORT_CIRCUIT  then
        CODE_SHORT_CIRCUIT( EXP_VAL );

      end if;
    end	CODE_EXP_VAL;
	------------

			------------
    procedure		CODE_AGG_EXP		( AGG_EXP :TREE )
    is
    begin
      if AGG_EXP.TY = DN_AGGREGATE  then
        CODE_AGGREGATE( AGG_EXP );

      elsif AGG_EXP.TY = DN_STRING_LITERAL  then
        CODE_STRING_LITERAL( AGG_EXP, "A VOIR !" );

      end if;
    end	CODE_AGG_EXP;
	------------

  begin
    if EXP_EXP.TY in CLASS_EXP_VAL  then
      CODE_EXP_VAL ( EXP_EXP );

    elsif EXP_EXP.TY in CLASS_AGG_EXP  then
      CODE_AGG_EXP( EXP_EXP );

    elsif EXP_EXP.TY = DN_QUALIFIED_ALLOCATOR  then
      CODE_QUALIFIED_ALLOCATOR( EXP_EXP );

    elsif EXP_EXP.TY = DN_SUBTYPE_ALLOCATOR  then
      CODE_SUBTYPE_ALLOCATOR( EXP_EXP );

    end if;

  end	CODE_EXP_EXP;
	------------


				------------
  procedure			CODE_USED_OP		( USED_OP :TREE )
  is				------------
    DEFN		: TREE		:= D( SM_DEFN, USED_OP ) ;
    SYM		: TREE		:= D( LX_SYMREP, DEFN );
  begin
    put_line( "; used op " & PRINT_NAME( SYM ) );
  end	CODE_USED_OP;
	------------


				-----------------
  procedure			CODE_USED_NAME_ID		( USED_NAME_ID :TREE )
  is				-----------------
  begin
    declare
      DEFN	: TREE	:= D( SM_DEFN,   USED_NAME_ID );
      SYMREP	: TREE	:= D( LX_SYMREP, USED_NAME_ID );
    begin
      if DEFN.TY = DN_EXCEPTION_ID then
null;--        declare
--	LABEL	: TREE := D( CD_LABEL, DEFN );
--	LBL	: LABEL_TYPE;
--        begin
--	if LABEL.TY /= DN_NUM_VAL then
--	  LBL := NEW_LABEL;
--	  DI( CD_LABEL, DEFN, INTEGER( LBL ) );
--	  EMIT( EXL, LBL, S=> PRINT_NAME( SYMREP ),
--			COMMENT=> "NUM D EXCEPTION EXTERNE ATTRIBUE SUR USED_NAME_ID" );
--	end if;
--	EMIT( DPL, I,	COMMENT=> "CODE D EXCEPTION EMPILE" );
--	EMIT( LDC, I, DI( CD_LABEL, DEFN ),
--			COMMENT=> "EXCEPTION " & PRINT_NAME ( SYMREP ));
--	EMIT( EQ, I );
--        end;

      elsif DEFN.TY = DN_PACKAGE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PACKAGE_SPEC	: TREE	:= D( SM_SPEC, DEFN );
	begin
--	  EMIT( RFP, CODI.CUR_COMP_UNIT, S=> PRINT_NAME( SYMREP ) );
	  PUT_LINE( "; RFP" & PRINT_NAME( SYMREP ) );
--	  CODI.GENERATE_CODE := FALSE;
	  DB( CD_COMPILED, DEFN, TRUE );
	  DECLARATIONS.CODE_DECL_S( D( AS_DECL_S1, PACKAGE_SPEC ) );
	end;
        end if;
--        CODI.CUR_COMP_UNIT := CUR_COMP_UNIT + 1;

      elsif DEFN.TY = DN_PROCEDURE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PROC_LBL	:constant STRING	:= NEW_LABEL;
	begin
--	  CODI.GENERATE_CODE := TRUE;
--	  EMIT( RFP, INTEGER( 0 ), S=> PRINT_NAME ( SYMREP ) );
--	  DI  ( CD_LABEL,      DEFN, INTEGER ( PROC_LBL ) );
	  DI  ( CD_LEVEL,      DEFN, 1 );
	  DI  ( CD_PARAM_SIZE, DEFN, 0 );
	  DB  ( CD_COMPILED,   DEFN, TRUE );
--	  EMIT( RFL, PROC_LBL );
	end;
        end if;
      end if;
    end;
  end	CODE_USED_NAME_ID;
	-----------------


  				--------------
  procedure			CODE_USED_CHAR		( USED_CHAR :TREE )
  is				--------------
  begin
    PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( DI( SM_VALUE, USED_CHAR ) ) );
  end	CODE_USED_CHAR;
	--------------


				-------------------
  procedure			CODE_USED_OBJECT_ID		( USED_OBJECT_ID :TREE )
  is				-------------------
    DEFN		: TREE		:= D( SM_DEFN, USED_OBJECT_ID ) ;
  begin
    case DEFN.TY is
    when DN_CONSTANT_ID | DN_VARIABLE_ID	=> CODE_VC_ID( DEFN );
    when DN_ITERATION_ID			=>
      declare
        ITERATION_ID	: TREE		renames DEFN;
        ITERATION_ID_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, ITERATION_ID ) );
        ITERATION_ID_TAG	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_OFFSET, ITERATION_ID ) );
        ITERATION_ID_VARSTR	:constant STRING	:= ITERATION_ID_STR & LABEL_STR( ITERATION_ID_TAG ) & "_disp";
        TYPE_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, ITERATION_ID ) );
      begin
        PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
      end;

    when DN_ENUMERATION_ID | DN_CHARACTER_ID	=> PUT_LINE( ASCII.HT & "LI" & ASCII.HT & INTEGER'IMAGE( DI( SM_REP, DEFN ) ) );
    when DN_IN_ID | DN_IN_OUT_ID		=> LOAD_MEM( DEFN );
--    when DN_OUT_ID				=> CODE_PRM_ID( DEFN );
    when others => raise PROGRAM_ERROR;
    end case;

  end	CODE_USED_OBJECT_ID;
	-------------------


  				--------
  procedure			CODE_ALL			( ADA_ALL :TREE )
  is				--------
  begin
    null;
  end	CODE_ALL;
	--------


				------------
  procedure			CODE_INDEXED	( INDEXED :TREE )
  is				------------
    NAME		: TREE		:= D( AS_NAME, INDEXED );
    ARRAY_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, NAME) );
    ARRAY_LVL	: INTEGER		:= DI( CD_LEVEL, D( SM_DEFN, NAME ) );
    INDEX_NUM	: INTEGER		:= 1;
  begin
    declare
		-----
      procedure	INDEX	( EXP :TREE )
      is
        CHN		:constant STRING	:= tab & "LId" & INTEGER'IMAGE( ARRAY_LVL ) & ',' & tab & ARRAY_NAME & "__u";
        INDEX_NUM_IMG	:constant STRING	:= IMAGE( INDEX_NUM );
      begin
        CODE_EXP( EXP );
        PUT( CHN & ", " &  ARRAY_NAME & ".FST_" & INDEX_NUM_IMG );
        if CODI.DEBUG then PUT( tab50 & "; (index - FST_" & INDEX_NUM_IMG & ") * SIZ_" & INDEX_NUM_IMG ); end if;
        NEW_LINE;
        PUT_LINE( tab & "SUB" );
        PUT_LINE( CHN & ", " & ARRAY_NAME & ".COMP_SIZ" );
        PUT_LINE( tab & "MUL" );
        PUT( tab & "ADD" );
        if CODI.DEBUG then PUT( tab50 & "; add offset to start address" ); end if;
        NEW_LINE;
      end	INDEX;
      	-----

    begin
      PUT(  tab & "LIa" & INTEGER'IMAGE( ARRAY_LVL ) & ',' & tab & ARRAY_NAME & "_disp" );			-- EMPILE L ADRESSE DE BASE DU CONTENU DE TABLEAU
      if CODI.DEBUG then PUT( tab50 & "; array data start address on stack" ); end if;
      NEW_LINE;

      declare
        EXP_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
        EXP	: TREE;
      begin
        while not IS_EMPTY( EXP_SEQ ) loop
	POP( EXP_SEQ, EXP );
	INDEX( EXP );
	INDEX_NUM := INDEX_NUM + 1;
        end loop;
      end;

    end;
  end	CODE_INDEXED;
	------------


				----------
  procedure			CODE_SLICE		( SLICE :TREE )
  is				----------
  begin
    null;
  end	CODE_SLICE;
	----------


				-------------
  procedure			CODE_SELECTED		( SELECTED :TREE; IS_SOURCE :BOOLEAN := TRUE )
  is				-------------
    EXP_TYPE	: TREE	:= D( SM_EXP_TYPE, SELECTED );
    DEFN		: TREE	:= D( SM_DEFN, D( AS_DESIGNATOR, SELECTED ) );
    VAR_ID	: TREE;
		----------------
    function	RECURSE_SELECTED	( SELECTED :TREE )	return STRING
    is
      NAME		: TREE		:= D( AS_NAME, SELECTED );
      DESIGNATOR		: TREE		:= D( AS_DESIGNATOR, SELECTED );
      DESIGNATOR_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DESIGNATOR ) );
      DESIGNATOR_DEFN	: TREE		:= D( SM_DEFN, DESIGNATOR );
      PARENT_TYPE		: TREE		:= D( XD_REGION, DESIGNATOR_DEFN );
      PARENT_TYPE_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, PARENT_TYPE ) );
    begin
      if  NAME.TY = DN_SELECTED  then
        return RECURSE_SELECTED( NAME ) & " + " & PARENT_TYPE_STR & '.' & DESIGNATOR_STR;
      else
        VAR_ID := D( SM_DEFN, NAME );
        return PARENT_TYPE_STR & '.' & DESIGNATOR_STR;
      end if;
    end	RECURSE_SELECTED;
    	----------------

  begin
    if  EXP_TYPE.TY = DN_INTEGER  then
      if  DEFN.TY = DN_COMPONENT_ID  then
        declare
	OFFSET_STR	:constant STRING	:= RECURSE_SELECTED( SELECTED );
	VAR_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, VAR_ID ) );
	VAR_LVL_STR	:constant STRING	:= INTEGER'IMAGE( DI( CD_LEVEL, VAR_ID ) );
	SIZ_CHAR		: CHARACTER	:= OPER_SIZ_CHAR( EXP_TYPE );
        begin
	PUT( tab );
	if  IS_SOURCE  then
	  PUT( 'L' );
	else
	  PUT( 'S' );
	end if;
	PUT( 'I' & SIZ_CHAR & VAR_LVL_STR & ',' & tab );
	if  VAR_ID.TY = DN_IN_OUT_ID  or VAR_ID.TY = DN_OUT_ID  then
	  PUT( '-' & VAR_STR & "_ofs, " );
	else
	  PUT( VAR_STR & "_disp, " );
	end if;
	PUT_LINE( OFFSET_STR );
        end;

      else
        PUT_LINE( tab & 'L' &  OPER_SIZ_CHAR( EXP_TYPE )  & tab & RECURSE_SELECTED( SELECTED ) );
      end if;

    elsif  EXP_TYPE.TY = DN_ENUMERATION  then
      PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( SM_VALUE, SELECTED ) ) );

    else
      PUT_LINE( "; EXPRESSIONS.CODE_SELECTED TYPE PAS FAIT " & NODE_NAME'IMAGE( EXP_TYPE.TY ) );

    end if;
  end	CODE_SELECTED;
	-------------


				--------------
  procedure			CODE_ATTRIBUTE		( ATTRIBUTE :TREE )
  is				--------------
    PREFIX_NAME		: TREE		:= D( AS_NAME, ATTRIBUTE );
    CHN_PREFIX		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, PREFIX_NAME ) );
    CHN_ATTR_NAME		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_USED_NAME_ID, ATTRIBUTE ) ) );
    subtype CHN_STD		is STRING( 1 .. CHN_ATTR_NAME'LENGTH );
    CHN_ATTR		: CHN_STD		:= CHN_ATTR_NAME;						-- NORMALISER EN STRING A FIRST=1

    		---------------
    procedure	CODE_FIRST_LAST	( IS_LAST :BOOLEAN )
    is
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
    begin
      if  PREFIX_NAME.TY = DN_USED_OBJECT_ID  then							-- UNE VARIABLE TABLEAU
        if  ( D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_CONSTRAINED_ARRAY )
         or ( D( SM_EXP_TYPE, PREFIX_NAME ).TY = DN_ARRAY  and  D( SM_DEFN, PREFIX_NAME ).TY = DN_CONSTANT_ID )
        then
	declare
	  ARRAY_LVL	: INTEGER		:= DI( CD_LEVEL, PREFIX_DEFN );
	  DIM_EXP		: TREE		:= D( AS_EXP, ATTRIBUTE );
	  NUM_DIM		: INTEGER		:= 1;
	begin
	  if DIM_EXP /= TREE_VOID then
	    NUM_DIM := DI( SM_VALUE, DIM_EXP );
	  end if;
	  PUT( tab & "LId" & INTEGER'IMAGE( ARRAY_LVL ) & ',' & tab & CHN_PREFIX & "__u" & ", " & CHN_PREFIX );
	  if  IS_LAST  then
	    PUT( ".LST_"  );
	  else
	    PUT( ".FST_" );
	  end if;
	  PUT_LINE( IMAGE( NUM_DIM ) );

--	  PUT_LINE( tab & "LId" & INTEGER'IMAGE( ARRAY_LVL ) & ',' & tab & CHN_PREFIX & "_disp" & ','
--		    & INTEGER'IMAGE( 8 + 12*(NUM_DIM-1) + ATTR_VAL_OFS ) );
	end;
        end if;

      elsif  PREFIX_NAME.TY = DN_USED_NAME_ID  then			-- UN NOM DE TYPE
        if  PREFIX_DEFN.TY = DN_TYPE_ID  then
	declare
	  TYPE_RANGE	: TREE	:= D( SM_RANGE, D( SM_TYPE_SPEC, PREFIX_DEFN ) );
	begin
	  PUT( tab & "LI " );
	  if  IS_LAST  then
	    PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP2, TYPE_RANGE ) ) ) );
	  else
	    PUT_LINE( PRINT_NUM( D( SM_VALUE, D( AS_EXP1, TYPE_RANGE ) ) ) );
	  end if;
        end;
      end if;

      end if;

    end	CODE_FIRST_LAST;
	---------------

    		--------
    procedure	CODE_POS
    is
      PREFIX_DEFN		: TREE		:= D( SM_DEFN, PREFIX_NAME );
    begin
      null;
    end	CODE_POS;

  begin
    case  CHN_ATTR( 1 )  is
    when  'A' =>
      if  CHN_ATTR( 2 ) = 'D'  then null;			-- ADDRESS
      else null;						-- AFT
      end if;
    when  'B' => null;					-- BASE
    when  'C' =>
      if  CHN_ATTR( 2 ) = 'A'  then null;			-- CALLABLE
      elsif  CHN_ATTR( 2 .. 3 ) = "ON"  then null;		-- CONSTRAINED
      elsif  CHN_ATTR( 2 .. 3 ) = "OU"  then null;		-- COUNT
      end if;
    when  'D' =>
      if  CHN_ATTR( 2 ) = 'E'  then null;			-- DELTA
      else null;						-- DIGITS
      end if;
    when  'E' =>
      if  CHN_ATTR( 2 ) = 'M'  then null;			-- EMAX
      else null;						-- EPSILON
      end if;
    when  'F' =>
      if  CHN_ATTR( 2 ) = 'I'  then				-- FIRST
        CODE_FIRST_LAST( IS_LAST => FALSE );
      else null;						-- FORE
      end if;
    when  'I' => null;					-- IMAGE
    when  'L' =>
      if  CHN_ATTR( 2 .. 3 ) = "AR"  then null;			-- LARGE
      elsif  CHN_ATTR( 2 .. 3 ) = "AS"  then
        if  CHN_ATTR'LENGTH = 4  then				-- LAST
	CODE_FIRST_LAST( IS_LAST => TRUE );
        else null;						-- LAST_BIT
        end if;
      elsif  CHN_ATTR( 2 .. 3 ) = "EN"  then null;		-- LENGTH
      end if;
    when  'M' =>
      if  CHN_ATTR( 3 ) = 'N'  then null;			-- MANTISSA
      elsif  CHN_ATTR( 11 ) = 'A'  then	 null;			-- MACHINE_EMAX
      elsif  CHN_ATTR( 11 ) = 'I'  then	 null;			-- MACHINE_EMIN
      elsif  CHN_ATTR( 9 ) = 'M'   then	 null;			-- MACHINE_MANTISSA
      elsif  CHN_ATTR( 9 ) = 'O'   then	 null;			-- MACHINE_OVERFLOW
      elsif  CHN_ATTR( 10 ) = 'A'  then	 null;			-- MACHINE_RADIX
      elsif  CHN_ATTR( 10 ) = 'O'  then	 null;			-- MACHINE_ROUNDS
      end if;
    when  'P' =>
      if  CHN_ATTR'LENGTH = 8  then null;			-- POSITION
      elsif  CHN_ATTR( 2 ) = 'O'  then	 null;			-- POS
      elsif  CHN_ATTR( 2 ) = 'R'  then	 null;			-- PRED
      end if;
    when  'R' => null;					-- RANGE
    when  'S' =>
      if  CHN_ATTR( 2 ) = 'I'  then null;			-- SIZE
      elsif  CHN_ATTR( 2 ) = 'M'  then	 null;			-- SMALL
      elsif  CHN_ATTR( 2 ) = 'T'  then	 null;			-- STORAGE
      elsif  CHN_ATTR( 2 ) = 'U'  then	 null;			-- SUCC
      elsif  CHN_ATTR( 6 ) = 'E'  then	 null;			-- SAFE_EMAX
      elsif  CHN_ATTR( 6 ) = 'L'  then	 null;			-- SAFE_LARGE
      elsif  CHN_ATTR( 6 ) = 'S'  then	 null;			-- SAFE_SMALL
      end if;
    when  'T' =>	null;					-- TERMINATED
    when  'V' =>
      if  CHN_ATTR'LENGTH = 5  then null;			-- VALUE
      else  null;						-- VAL
      end if;
    when  'W' => null;					-- WIDTH
    when others => null;
    end case;
  end	CODE_ATTRIBUTE;
	--------------


				------------------
  procedure			CODE_FUNCTION_CALL		( FUNCTION_CALL :TREE )
  is				------------------
    NAME		: TREE		:= D( AS_NAME,		FUNCTION_CALL );
    PARAMS	: TREE		:= D( SM_NORMALIZED_PARAM_S,	FUNCTION_CALL );

    		------------------------
    procedure	CODE_DN_BLTN_OPERATOR_ID
    is
      DEFN		: TREE		:= D( SM_DEFN,		NAME );
    begin
    if DEFN.TY = DN_BLTN_OPERATOR_ID then
      declare
        OP_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        PRM_S		: SEQ_TYPE	:= LIST( PARAMS );
        PRM_1, PRM_2	: TREE;
      begin
        POP( PRM_S, PRM_1 );
        CODE_EXP( PRM_1 );
        if IS_EMPTY( PRM_S ) then goto UNARY; end if;
        POP( PRM_S, PRM_2 );
        CODE_EXP( PRM_2 );
        if OP_STR = """+""" then  PUT_LINE( ASCII.HT & "ADD" );
        elsif OP_STR = """-""" then  PUT_LINE( ASCII.HT & "SUB" );
        elsif OP_STR = """*""" then  PUT_LINE( ASCII.HT & "MUL" );
        elsif OP_STR = """/""" then  PUT_LINE( ASCII.HT & "DIV" );
        elsif OP_STR = """=""" then  PUT_LINE( ASCII.HT & "CEQ" );
        elsif OP_STR = """>""" then  PUT_LINE( ASCII.HT & "CGT" );
        elsif OP_STR = """<""" then  PUT_LINE( ASCII.HT & "CLT" );
        elsif OP_STR = """/=""" then  PUT_LINE( ASCII.HT & "CNE" );
        elsif OP_STR = """>=""" then  PUT_LINE( ASCII.HT & "CGE" );
        elsif OP_STR = """<=""" then  PUT_LINE( ASCII.HT & "CIE" );
        elsif OP_STR = """**""" then
	if  PRM_1.TY = DN_NUMERIC_LITERAL and then DI( SM_VALUE, PRM_1 ) = 2  then
	  PUT_LINE( ASCII.HT & "DEC" );
	  PUT_LINE( ASCII.HT & "SHL" );
	else
	  PUT_LINE( "; CODE_DN_BLTN_OPERATOR_ID : EXPONENTIATION DE BASE /= 2 A FAIRE" );
	end if;
        end if;
        return;
<<UNARY>>
        if OP_STR = """-""" then PUT_LINE( ASCII.HT & "NEG" ); end if;
        if OP_STR = """ABS""" then
	PUT_LINE( ASCII.HT & "ABS" );
        end if;
      end;

    end if;
    end	CODE_DN_BLTN_OPERATOR_ID;
    	------------------------

  begin


    if  NAME.TY = DN_ATTRIBUTE  then
      declare
        PRM_S	: SEQ_TYPE	:= LIST( PARAMS );
        PRM	: TREE;
      begin
        POP( PRM_S, PRM );
        CODE_EXP( PRM );
      end;
      CODE_ATTRIBUTE( NAME );

    elsif  NAME.TY = DN_USED_NAME_ID  then
      PUT( tab & "LI" & tab & "0" );
      if  CODI.DEBUG  then  PUT( tab50 & "; lieu resultat sur pile" ); end if;
      NEW_LINE;
      INSTRUCTIONS.CODE_PROCEDURE_CALL( FUNCTION_CALL, NAME );

    elsif  NAME.TY = DN_USED_OP  then
      CODE_DN_BLTN_OPERATOR_ID;

    else
      PUT_LINE( "; CODE_FUNCTION_CALL NAME.TY PAS GERE" );
    end if;
  end	CODE_FUNCTION_CALL;
	------------------


  				------------------------
  procedure			CODE_QUALIFIED_ALLOCATOR	( QUALIFIED_ALLOCATOR :TREE )
  is				------------------------
  begin
    null;
  end	CODE_QUALIFIED_ALLOCATOR;
	------------------------


				----------------------
  procedure			CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR :TREE )
  is				----------------------
  begin
    null;
  end	CODE_SUBTYPE_ALLOCATOR;
	----------------------


  				--------------
  procedure			CODE_AGGREGATE		( AGGREGATE :TREE )
  is				--------------
  begin
    null;
  end	CODE_AGGREGATE;
	--------------


				-------------------
  procedure			CODE_STRING_LITERAL		( STRING_LITERAL :TREE; STR_NAME :STRING )
  is				-------------------
    CST_CHN	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, STRING_LITERAL ) );
    STR_CONST	:STRING		renames	CST_CHN( CST_CHN'FIRST+1 .. CST_CHN'LAST-1 );
  begin
    PUT( "STR " & STR_NAME & ", '" & STR_CONST & ''' );
    if CODI.DEBUG then PUT( tab50 & "; constante string='" & STR_CONST & "'" ); end if;
    NEW_LINE;

  end	CODE_STRING_LITERAL;
	-------------------


  				--------------------
  procedure			CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL :TREE )
  is				--------------------
    VAL	: TREE	:= D( SM_VALUE, NUMERIC_LITERAL );
  begin
    if  VAL.PT = HI  and then  VAl.NOTY = DN_NUM_VAL
    then
      PUT_LINE( tab & "LI" & tab & INTEGER'IMAGE( DI( SM_VALUE, NUMERIC_LITERAL ) ) );

    elsif  VAL.TY = DN_NUM_VAL  then
      PUT_LINE( tab & "LI" & tab & PRINT_NUM( VAL ) );

    elsif  VAL.TY = DN_REAL_VAL  then
      PUT_LINE( tab & "LIF" & tab & PRINT_NAME( D( LX_NUMREP, NUMERIC_LITERAL ) ) );

    end if;

  end	CODE_NUMERIC_LITERAL;
	--------------------


  				----------------
  procedure			CODE_NULL_ACCESS		( NULL_ACCESS :TREE )
  is				----------------
  begin
    null;
  end	CODE_NULL_ACCESS;
	----------------


				------------------
  procedure			CODE_SHORT_CIRCUIT		( SHORT_CIRCUIT :TREE )
  is				------------------
  begin
    null;
  end	CODE_SHORT_CIRCUIT;
	------------------


  				------------------
  procedure			CODE_PARENTHESIZED	( PARENTHESIZED :TREE )
  is				------------------
  begin
    CODE_EXP( D( AS_EXP, PARENTHESIZED ) );
  end	CODE_PARENTHESIZED;
    	------------------


  				---------------
  procedure			CODE_CONVERSION		( CONVERSION :TREE )
  is				---------------
  begin
    null;
  end	CODE_CONVERSION;
	---------------


				--------------
  procedure			CODE_QUALIFIED		( QUALIFIED :TREE )
  is				--------------
  begin
    null;
  end	CODE_QUALIFIED;
	--------------


  				---------------------
  procedure			CODE_RANGE_MEMBERSHIP	( RANGE_MEMBERSHIP :TREE )
  is				---------------------
  begin
    null;
  end	CODE_RANGE_MEMBERSHIP;
	---------------------


				--------------------
  procedure			CODE_TYPE_MEMBERSHIP	( TYPE_MEMBERSHIP :TREE )
  is				--------------------
  begin
    null;
  end	CODE_TYPE_MEMBERSHIP;
	--------------------


				----------
  procedure			CODE_VC_ID		( CONSTANT_ID :TREE )
  is
    CST_TYPE	: TREE	:= D( SM_OBJ_TYPE, CONSTANT_ID );
  begin

    case CST_TYPE.TY is
    when DN_ARRAY => null;
    when DN_INTEGER | DN_ACCESS | DN_ENUMERATION | DN_FLOAT
    =>
      LOAD_MEM( CONSTANT_ID );
    when others
    =>
      PUT_LINE( ';' & tab & "CODE_VC_ID ERROR " & NODE_NAME'IMAGE( CST_TYPE.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	CODE_VC_ID;
	----------


	-----------
end	EXPRESSIONS;
	-----------
