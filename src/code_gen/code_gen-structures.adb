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
    CODI.TOP_ACT	    := 0;
    CODI.TOP_MAX	    := 0;
    CODI.OFFSET_ACT	    := 0;
    CODI.OFFSET_MAX     := 0;
    CODI.CUR_LEVEL      := 1;
    CODI.GENERATE_CODE  := FALSE;
    CODI.CUR_COMP_UNIT  := 2;
    CODI.ENCLOSING_BODY := TREE_VOID;

    CODE_WITH_CONTEXT( D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT ) );

    CODI.CUR_COMP_UNIT  := 0;
    CODI.GENERATE_CODE  := TRUE;

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
    EMIT( QUIT );

  end	CODE_COMPILATION_UNIT;
	--=================--



				-----------------
  procedure			CODE_WITH_CONTEXT		( CONTEXT_ELEM_S :TREE )
  is

    procedure	CODE_WITHED_PKG	( DEFN :TREE )
    is
    begin
      EMIT( RFP, CUR_COMP_UNIT, S=> PRINT_NAME( D( LX_SYMREP, DEFN ) ) );
      DB( CD_COMPILED, DEFN, TRUE );
      CODI.GENERATE_CODE := FALSE;
      declare
        SPEC	: TREE		:= D( SM_SPEC, DEFN );
        DECL_SEQ	: SEQ_TYPE	:= LIST( D( AS_DECL_S1, SPEC ) );
        DECL	: TREE;
      begin
        while not IS_EMPTY( DECL_SEQ ) loop
	POP( DECL_SEQ, DECL );
	DECLARATIONS.CODE_DECL( DECL );
        end loop;
      end;
    end	CODE_WITHED_PKG;

  begin

    CUR_COMP_UNIT := 1;
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
	      COMPILED	: BOOLEAN	:= DB( CD_COMPILED, DEFN );
	    begin
	      CODI.GENERATE_CODE := TRUE;
	      if DEFN.TY = DN_PACKAGE_ID then
	        CODE_WITHED_PKG( DEFN );
	        CUR_COMP_UNIT := CUR_COMP_UNIT + 1;

	      elsif DEFN.TY = DN_PROCEDURE_ID then
	        if not DB( CD_COMPILED, DEFN ) then
	          EMIT( RFP, I=> 0, S=> PRINT_NAME( D( LX_SYMREP, DEFN ) ) );
	          declare
		  SUBP_LBL	: LABEL_TYPE	:= NEW_LABEL;
	          begin
		  DI( CD_LABEL,      DEFN,  INTEGER( SUBP_LBL ) );
		  DI( CD_LEVEL,      DEFN,  1 );
		  DI( CD_PARAM_SIZE, DEFN,  0 );
		  DB( CD_COMPILED,   DEFN,  TRUE );
		  EMIT( RFL, SUBP_LBL );
		  CODI.GENERATE_CODE := FALSE;
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
  begin
    declare
       OLD_OFFSET_ACT	: OFFSET_VAL	:= CODI.OFFSET_ACT;
       OLD_OFFSET_MAX	: OFFSET_VAL	:= CODI.OFFSET_MAX;
       SOURCE_NAME		: TREE		:= D( AS_SOURCE_NAME, SUBPROGRAM_BODY );
       START_LABEL		: LABEL_TYPE	:= NEW_LABEL;
    begin
      if CODI.ENCLOSING_BODY = TREE_VOID then
        EMIT( PRO, S=> PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) ) );
      end if;
      CODI.OFFSET_ACT := CODI.FIRST_PARAM_OFFSET;
      CODI.OFFSET_MAX := CODI.OFFSET_ACT;
      INC_LEVEL;
      DI( CD_LABEL, SOURCE_NAME, INTEGER( START_LABEL ) );
      DI( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
--      WRITE_LABEL( START_LABEL, "ETIQUETTE ENTREE" );

	DECLARATIONS.CODE_HEADER( D( AS_HEADER, SUBPROGRAM_BODY ) );

      DI( CD_PARAM_SIZE, SOURCE_NAME, PARAM_SIZE );
      CODI.OFFSET_ACT := CODI.FIRST_LOCAL_VAR_OFFSET;
      CODI.OFFSET_MAX := CODI.OFFSET_ACT;

	CODE_BODY( D( AS_BODY, SUBPROGRAM_BODY ) );

      DEC_LEVEL;
      CODI.OFFSET_MAX := OLD_OFFSET_MAX;
      CODI.OFFSET_ACT := OLD_OFFSET_ACT;
    end;
  end	CODE_SUBPROGRAM_BODY;
	--------------------



				-----------------
  procedure			CODE_PACKAGE_BODY		( PACKAGE_BODY :TREE )
  is
  begin
    EMIT( PKB, S=> PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, PACKAGE_BODY ) ) ) );
    CODI.GENERATE_CODE := FALSE;

	DECLARATIONS.CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_BODY ) ) );

    CODI.GENERATE_CODE := TRUE;
    WRITE_LABEL( 1 );

    CODE_BODY( D( AS_BODY, PACKAGE_BODY ) );

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
    declare
      SAVE_ENCLOSING_BODY	: TREE		:= ENCLOSING_BODY;
      OLD_TOP_ACT		: OFFSET_VAL	:= CODI.TOP_ACT;
      OLD_TOP_MAX		: OFFSET_VAL	:= CODI.TOP_MAX;
      ELAB_LBL		: TARGET_LBL_REF;
      ELAB_END_LBL		: TARGET_LBL_REF;
      BEGIN_LBL		: TARGET_LBL_REF;
      OPER		: OPERAND_REF;
    begin
      ENCLOSING_BODY := BLOCK_BODY;
      CODI.TOP_ACT  := -4;
      CODI.TOP_MAX  := 0;
      DI( CD_LEVEL,        BLOCK_BODY, INTEGER( CODI.CUR_LEVEL ) );
      DI( CD_RETURN_LABEL, BLOCK_BODY, INTEGER( NEW_LABEL ) );

      if FUNCTION_RESULT /= TREE_VOID then
        if FUNCTION_RESULT.TY = DN_ARRAY then
          OPER := LOAD_ADR( FUNCTION_RESULT );
          EMIT( DPL, A );
          EMIT( SLD, A, 0, FUN_RESULT_OFFSET - CODI.ADDR_SIZE );
          EMIT( IND, I, 0 );
          EMIT( ALO, INTEGER( -1 ) );
          EMIT( SLD, A, 0, FUN_RESULT_OFFSET );
        end if;
      end if;

      ELAB_END_LBL := NEW_LBL;
      CODI.FLOT1_OP( BRA, ELAB_END_LBL );

      ELAB_LBL := NEW_LBL;
      CODI.STOCK_CP( ELAB_LBL );

      CODI.OFFSET_ACT := - ADDR_SIZE;

		CODE_ITEM_S ( D ( AS_ITEM_S, BLOCK_BODY ) );

      BEGIN_LBL := NEW_LBL;
      CODI.FLOT1_OP( BRA, BEGIN_LBL );

      STOCK_CP( ELAB_END_LBL );
      CODI.FLOT1_OP( BRA, ELAB_LBL );

      STOCK_CP( BEGIN_LBL );
      CODI.FRAME_OP( LINK, CODI.OFFSET_MAX );

      declare
        EXC_LBL	: LABEL_TYPE	:= NEW_LABEL;
      begin
        EMIT( EXH, EXC_LBL, COMMENT=> "EXCEPTION HANDLERS" );

		INSTRUCTIONS.CODE_STM_S( D ( AS_STM_S, BLOCK_BODY ) );

        WRITE_LABEL( LABEL_TYPE( DI( CD_RETURN_LABEL, BLOCK_BODY ) ) );

        CODI.FRAME_OP( UNLINK );
        CODI.FLOT0_OP( RTD, CODI.PARAM_SIZE );

        WRITE_LABEL( EXC_LBL );
      end;
      if not IS_EMPTY( LIST( D( AS_ALTERNATIVE_S, BLOCK_BODY ) ) )
      then
        CODE_ALTERNATIVE_S( D( AS_ALTERNATIVE_S, BLOCK_BODY ) );
      else
        EMIT( EEX );
      end if;
      CODI.TOP_MAX  := OLD_TOP_MAX;
      CODI.TOP_ACT  := OLD_TOP_ACT;
      ENCLOSING_BODY := SAVE_ENCLOSING_BODY;
    end;

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
    declare
       POST_LBL : LABEL_TYPE;
    begin
      if ENCLOSING_BODY /= TREE_VOID then
        POST_LBL := NEW_LABEL;
        EMIT ( JMP, POST_LBL, COMMENT=> "CONTOURNEMENT" );
      end if;

    if SUBUNIT_BODY.TY = DN_SUBPROGRAM_BODY then
      CODE_SUBPROGRAM_BODY ( SUBUNIT_BODY );

    elsif SUBUNIT_BODY.TY = DN_PACKAGE_BODY then
      CODE_PACKAGE_BODY ( SUBUNIT_BODY );

    elsif SUBUNIT_BODY.TY = DN_TASK_BODY then
      CODE_TASK_BODY ( SUBUNIT_BODY );

    end if;
      if ENCLOSING_BODY /= TREE_VOID then
        WRITE_LABEL ( POST_LBL, COMMENT=> "FIN DE CONTOURNEMENT" );
      end if;
    end;

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