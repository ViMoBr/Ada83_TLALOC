separate ( CODE_GEN )
				----------
 	package body		STRUCTURES
				----------
is


  package CODI renames CODAGE_INTERMEDIAIRE;


				--=================--
  procedure			CODE_COMPILATION_UNIT	( COMPILATION_UNIT :TREE )
  is
  begin
    CODI.CUR_LEVEL      := 0;
--    CODI.GENERATE_CODE  := FALSE;
    CODI.ENCLOSING_BODY := TREE_VOID;

    CODE_WITH_CONTEXT( D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT ) );

--    CODI.GENERATE_CODE  := TRUE;

    declare
      UNIT_ALL_DECL		: TREE	:= D( AS_ALL_DECL, COMPILATION_UNIT );
    begin
      case UNIT_ALL_DECL.TY is
      when DN_SUBPROGRAM_BODY	=> CODE_SUBPROGRAM_BODY( UNIT_ALL_DECL );
      when DN_PACKAGE_DECL	=> DECLARATIONS.CODE_PACKAGE_DECL( UNIT_ALL_DECL );
      when DN_PACKAGE_BODY	=> CODE_PACKAGE_BODY( UNIT_ALL_DECL );
      when others		=> raise PROGRAM_ERROR;
      end case;
    end;

  end	CODE_COMPILATION_UNIT;
	--=================--



				-----------------
  procedure			CODE_WITH_CONTEXT		( CONTEXT_ELEM_S :TREE )
  is

    procedure	CODE_WITHED_PKG	( DEFN :TREE )
    is
    begin
      PUT_LINE( "include '" & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & ".FINC'" );
--      EMIT( RFP, CUR_COMP_UNIT, S=> PRINT_NAME( D( LX_SYMREP, DEFN ) ) );
      DB( CD_COMPILED, DEFN, TRUE );
--      CODI.GENERATE_CODE := FALSE;
--      declare
--        SPEC	: TREE		:= D( SM_SPEC, DEFN );
--        DECL_SEQ	: SEQ_TYPE	:= LIST( D( AS_DECL_S1, SPEC ) );
--        DECL	: TREE;
--      begin
--        while not IS_EMPTY( DECL_SEQ ) loop
--	POP( DECL_SEQ, DECL );
--	DECLARATIONS.CODE_DECL( DECL );
--        end loop;
--      end;
    end	CODE_WITHED_PKG;

  begin

--    CUR_COMP_UNIT := 1;
-- CODE_WITHED_PKG( STANDARD_DEF );

    declare
      CONTEXT_ELEM_SEQ	: SEQ_TYPE	:= LIST( CONTEXT_ELEM_S );
      CONTEXT_ELEM		: TREE;
    begin
      while not IS_EMPTY( CONTEXT_ELEM_SEQ ) loop
        POP( CONTEXT_ELEM_SEQ, CONTEXT_ELEM );

        if CONTEXT_ELEM.TY = DN_WITH then
	declare
	  NAME_S		:constant TREE	:= D( AS_NAME_S, CONTEXT_ELEM );
	  NAME_SEQ	: SEQ_TYPE	:= LIST( NAME_S );
	  NAME		: TREE;
	begin
	  while not IS_EMPTY( NAME_SEQ ) loop
	    POP( NAME_SEQ, NAME );

	    declare
	      DEFN	: TREE	:= D( SM_DEFN, NAME );
--	      COMPILED	: BOOLEAN	:= DB( CD_COMPILED, DEFN );
	    begin
--	      CODI.GENERATE_CODE := TRUE;
	      if DEFN.TY = DN_PACKAGE_ID then
null;
	        CODE_WITHED_PKG( DEFN );
--	        CUR_COMP_UNIT := CUR_COMP_UNIT + 1;

	      elsif DEFN.TY = DN_PROCEDURE_ID then
	        if not DB( CD_COMPILED, DEFN ) then
--      PUT_LINE( "include '" & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & ".fas'" );
	          declare
		  SUBP_LBL	:constant STRING	:= NEW_LABEL;
	          begin
--		  DI( CD_LABEL,      DEFN,  INTEGER( SUBP_LBL ) );
		  DI( CD_LEVEL,      DEFN,  1 );
		  DI( CD_PARAM_SIZE, DEFN,  0 );
		  DB( CD_COMPILED,   DEFN,  TRUE );
--		  CODI.GENERATE_CODE := FALSE;
	          end;
	        end if;
	      end if;
	    end;

	  end loop;
	end;
        end if;
      end loop;
    end;

  end	CODE_WITH_CONTEXT;
	-----------------



				--------------------
  procedure			CODE_SUBPROGRAM_BODY	( SUBPROGRAM_BODY :TREE )
  is
    LBL	: LABEL_TYPE;
    SOURCE_NAME		: TREE		:= D( AS_SOURCE_NAME, SUBPROGRAM_BODY );
    SUB_NAME		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) );
    DECL_ID		: TREE		:= D( SM_FIRST, SOURCE_NAME );
    SAVE_ENCLOSING		: TREE		:= ENCLOSING_BODY;
  begin

    INC_LEVEL;

    if DECL_ID = SOURCE_NAME then
      LBL := NEW_LABEL;
      DI( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
    else
      LBL := LABEL_TYPE( DI( CD_LABEL, DECL_ID ) );
      DI( CD_LEVEL, SOURCE_NAME, DI( CD_LEVEL, DECL_ID ) );
    end if;
    DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );

    if ENCLOSING_BODY /= TREE_VOID then
      PUT_LINE( "if defined " & SUB_NAME & '_' & LABEL_STR( LBL ) & '_' );
    end if;

    PUT( "SUBP " & SUB_NAME & '_' & LABEL_STR( LBL ) );
    if CODI.DEBUG then PUT( tab50 & ";---------- SUB" ); end if;
    NEW_LINE;

    DECLARATIONS.CODE_HEADER( D( AS_HEADER, SUBPROGRAM_BODY ) );

    ENCLOSING_BODY := SUBPROGRAM_BODY;

    CODE_BODY( D( AS_BODY, SUBPROGRAM_BODY ) );

    PUT_LINE( tab & "UNLINK" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );
    PUT( tab & "RTD" );
    if CODI.NO_SUBP_PARAMS = FALSE then PUT( tab & "prm_siz" ); end if;
    NEW_LINE;
    PUT_LINE( "excep:" );

    PUT( "endSUBP" );
    if CODI.DEBUG then PUT( tab50 & ";---------- end SUB " & SUB_NAME); end if;
    NEW_LINE;

    DEC_LEVEL;
    ENCLOSING_BODY := SAVE_ENCLOSING;
    if ENCLOSING_BODY /= TREE_VOID then
      PUT_LINE( "end if" );
    end if;

  end	CODE_SUBPROGRAM_BODY;
	--------------------



				-----------------
  procedure			CODE_PACKAGE_BODY		( PACKAGE_BODY :TREE )
  is
    PACK_ID	: TREE		:= D( AS_SOURCE_NAME, PACKAGE_BODY );
    PACK_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, PACK_ID ) );
    PACK_DEF	: TREE		:= D( SM_FIRST, PACK_ID );
  begin
    if PACK_DEF.TY = DN_GENERIC_ID then return; end if;

    if CODI.DEBUG then PUT_LINE( tab50 & ";---------- PACKAGE" ); end if;
    PUT_LINE( "namespace " & PACK_NAME );
    PUT_LINE( "elab_spec:" );

    DECLARATIONS.CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_BODY ) ) );

    ENCLOSING_BODY := PACKAGE_BODY;
    CODE_BODY( D( AS_BODY, PACKAGE_BODY ) );

    PUT( "end namespace " );
    if CODI.DEBUG then
      PUT( tab50 & ";---------- end package BDY " & PACK_NAME );
    end if;
    NEW_LINE;

  end	CODE_PACKAGE_BODY;
	-----------------



				---------
  procedure			CODE_BODY		( ADA_BODY :TREE )
  is
  begin

    if ADA_BODY.TY = DN_BLOCK_BODY
    then
      CODE_BLOCK_BODY( ADA_BODY );
    elsif ADA_BODY.TY = DN_STUB
    then
      CODE_STUB( ADA_BODY );
    end if;

  end	CODE_BODY;
	---------


				---------------
  procedure			CODE_BLOCK_BODY	( BLOCK_BODY :TREE )
  is
  begin
    DI( CD_LEVEL, BLOCK_BODY, INTEGER( CODI.CUR_LEVEL ) );

    PUT( "ELAB" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );
    if CODI.DEBUG then PUT( tab50 & ";    vars" ); end if;
    NEW_LINE;

--     if FUNCTION_RESULT /= TREE_VOID then
--       if FUNCTION_RESULT.TY = DN_ARRAY then
--         LOAD_ADR( FUNCTION_RESULT );
--         EMIT( DPL, A );
--         EMIT( SLD, A, 0, FUN_RESULT_OFFSET - CODI.ADDR_SIZE );
--         EMIT( IND, I, 0 );
--         EMIT( ALO, INTEGER( -1 ) );
--         EMIT( SLD, A, 0, FUN_RESULT_OFFSET );
--       end if;
--     end if;


    declare
      SAVE_ENCLOSING	: TREE	:= ENCLOSING_BODY;
    begin
      CODE_ITEM_S ( D ( AS_ITEM_S, BLOCK_BODY ) );
      ENCLOSING_BODY := SAVE_ENCLOSING;
    end;

    if ENCLOSING_BODY.TY = DN_SUBPROGRAM_BODY then

      PUT( "endELAB" );
      if CODI.DEBUG then PUT( tab50 & ";    end vars" ); end if;
      NEW_LINE;

    end if;

    PUT( "begin:" );
    if CODI.DEBUG then
      PUT( tab50 & ";---------- " );
      if ENCLOSING_BODY.TY = DN_SUBPROGRAM_BODY then PUT( "BDY" );
      elsif ENCLOSING_BODY.TY = DN_PACKAGE_BODY then PUT( "package BDY" );
      end if;
    end if;
    NEW_LINE;

    INSTRUCTIONS.CODE_STM_S( D ( AS_STM_S, BLOCK_BODY ) );

    if not IS_EMPTY( LIST( D( AS_ALTERNATIVE_S, BLOCK_BODY ) ) )
    then
      CODE_ALTERNATIVE_S( D( AS_ALTERNATIVE_S, BLOCK_BODY ) );
    end if;

  end	CODE_BLOCK_BODY;
	---------------


				-----------
  procedure			CODE_ITEM_S		( ITEM_S :TREE )
  is
  begin
    declare
      ITEM_SEQ	: SEQ_TYPE	:= LIST ( ITEM_S );
      ITEM	: TREE;
    begin
      while not IS_EMPTY( ITEM_SEQ ) loop
        POP( ITEM_SEQ, ITEM );

        if ITEM.TY in CLASS_DECL
        then
	DECLARATIONS.CODE_DECL( ITEM );

        elsif ITEM.TY in CLASS_SUBUNIT_BODY
        then
	CODE_SUBUNIT_BODY( ITEM );

        end if;

      end loop;
    end;

  end	CODE_ITEM_S;
	-----------


			-----------------
  procedure		CODE_SUBUNIT_BODY		( SUBUNIT_BODY :TREE )
  is
  begin

    if SUBUNIT_BODY.TY = DN_SUBPROGRAM_BODY then
      CODE_SUBPROGRAM_BODY ( SUBUNIT_BODY );

    elsif SUBUNIT_BODY.TY = DN_PACKAGE_BODY then
      CODE_PACKAGE_BODY ( SUBUNIT_BODY );

    elsif SUBUNIT_BODY.TY = DN_TASK_BODY then
      CODE_TASK_BODY ( SUBUNIT_BODY );

    end if;

  end	CODE_SUBUNIT_BODY;
	-----------------


			------------
  procedure		CODE_SUBUNIT		( SUBUNIT :TREE )
  is
  begin
      CODE_SUBUNIT_BODY ( D ( AS_SUBUNIT_BODY, SUBUNIT ) );

  end	CODE_SUBUNIT;
	------------


	----------
end	STRUCTURES;
	----------