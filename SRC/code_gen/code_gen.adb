with EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
use  EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
					--------
			procedure		CODE_GEN
					--------
is

  procedure CODE_ROOT ( ROOT :TREE );
  procedure CODE_CONTEXT_PRAGMA ( CONTEXT_PRAGMA :TREE );
  procedure CODE_ALL_DECL ( ALL_DECL :TREE );
  procedure CODE_SUBUNIT ( SUBUNIT :TREE );
  procedure CODE_BLOCK_MASTER ( BLOCK_MASTER :TREE );
  procedure CODE_ITEM_S ( ITEM_S :TREE );
  procedure CODE_ITEM ( ITEM :TREE );
  procedure CODE_SUBUNIT_BODY ( SUBUNIT_BODY :TREE );
  procedure CODE_SUBPROGRAM_BODY ( SUBPROGRAM_BODY :TREE );
  procedure CODE_PACKAGE_BODY ( PACKAGE_BODY :TREE );
  procedure CODE_TASK_BODY ( TASK_BODY :TREE );
  procedure CODE_DECL ( DECL :TREE );
  procedure CODE_NULL_COMP_DECL ( NULL_COMP_DECL :TREE );
  procedure CODE_ID_DECL ( ID_DECL :TREE );
  procedure CODE_TYPE_DECL ( TYPE_DECL :TREE );
  procedure CODE_SUBTYPE_DECL ( SUBTYPE_DECL :TREE );
  procedure CODE_TASK_DECL ( TASK_DECL :TREE );
  procedure CODE_SIMPLE_RENAME_DECL ( SIMPLE_RENAME_DECL :TREE );
  procedure CODE_RENAMES_OBJ_DECL ( RENAMES_OBJ_DECL :TREE );
  procedure CODE_RENAMES_EXC_DECL ( RENAMES_EXC_DECL :TREE );
  procedure CODE_UNIT_DECL ( UNIT_DECL :TREE );
  procedure CODE_GENERIC_DECL ( GENERIC_DECL :TREE );
  procedure CODE_NON_GENERIC_DECL ( NON_GENERIC_DECL :TREE );
  procedure CODE_SUBPROG_ENTRY_DECL ( SUBPROG_ENTRY_DECL :TREE );
  procedure CODE_PACKAGE_DECL ( PACKAGE_DECL :TREE );
  procedure CODE_USE_PRAGMA ( USE_PRAGMA :TREE );
  procedure CODE_USE ( ADA_USE :TREE );
  procedure CODE_PRAGMA ( ADA_PRAGMA :TREE );
  procedure CODE_ID_S_DECL ( ID_S_DECL :TREE );
  procedure CODE_EXCEPTION_DECL ( EXCEPTION_DECL :TREE );
  procedure CODE_DEFERRED_CONSTANT_DECL ( DEFERRED_CONSTANT_DECL :TREE );
  procedure CODE_EXP_DECL ( EXP_DECL :TREE );
  procedure CODE_NUMBER_DECL ( NUMBER_DECL :TREE );
  procedure CODE_OBJECT_DECL ( OBJECT_DECL :TREE );
  procedure CODE_CONSTANT_DECL ( CONSTANT_DECL :TREE );
  procedure CODE_VARIABLE_DECL ( VARIABLE_DECL :TREE );
  procedure CODE_REP ( REP :TREE );
  procedure CODE_RECORD_REP ( RECORD_REP :TREE );
  procedure CODE_ALIGNMENT_CLAUSE ( ALIGNMENT_CLAUSE :TREE );
  procedure CODE_ALIGNMENT ( ALIGNMENT :TREE );
  procedure CODE_NAMED_REP ( NAMED_REP :TREE );
  procedure CODE_ADDRESS ( ADDRESS :TREE );
  procedure CODE_LENGTH_ENUM_REP ( LENGTH_ENUM_REP :TREE );
  procedure CODE_DSCRMT_DECL_S ( DSCRMT_DECL_S :TREE );
  procedure CODE_DSCRMT_DECL ( DSCRMT_DECL :TREE );
  procedure CODE_PARAM_S ( PARAM_S :TREE );
  procedure CODE_PARAM ( PARAM :TREE );
  procedure CODE_IN ( ADA_IN :TREE );
  procedure CODE_IN_OUT ( ADA_IN_OUT :TREE );
  procedure CODE_OUT ( ADA_OUT :TREE );
  procedure CODE_HEADER ( HEADER :TREE );
  procedure CODE_PACKAGE_SPEC ( PACKAGE_SPEC :TREE );
  procedure CODE_DECL_S ( DECL_S :TREE );
  procedure CODE_SUBP_ENTRY_HEADER ( SUBP_ENTRY_HEADER :TREE );
  procedure CODE_PROCEDURE_SPEC ( PROCEDURE_SPEC :TREE );
  procedure CODE_FUNCTION_SPEC ( FUNCTION_SPEC :TREE );
  procedure CODE_UNIT_DESC ( UNIT_DESC :TREE );
  procedure CODE_DERIVED_SUBPROG ( DERIVED_SUBPROG :TREE );
  procedure CODE_IMPLICIT_NOT_EQ ( IMPLICIT_NOT_EQ :TREE );
  procedure CODE_BODY ( ADA_BODY :TREE );
  procedure CODE_BLOCK_BODY ( BLOCK_BODY :TREE );
  procedure CODE_ALTERNATIVE_S ( ALTERNATIVE_S :TREE );
  procedure CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM :TREE );
  procedure CODE_ALTERNATIVE ( ALTERNATIVE :TREE );
  procedure CODE_ALTERNATIVE_PRAGMA ( ALTERNATIVE_PRAGMA :TREE );
  procedure CODE_CHOICE_S ( CHOICE_S :TREE );
  procedure CODE_CHOICE ( CHOICE :TREE );
  procedure CODE_CHOICE_EXP ( CHOICE_EXP :TREE );
  procedure CODE_CHOICE_RANGE ( CHOICE_RANGE :TREE );
  procedure CODE_CHOICE_OTHERS ( CHOICE_OTHERS :TREE );
  procedure CODE_STUB ( STUB :TREE );
  procedure CODE_UNIT_KIND ( UNIT_KIND :TREE );
  procedure CODE_RENAME_INSTANT ( RENAME_INSTANT :TREE );
  procedure CODE_RENAMES_UNIT ( RENAMES_UNIT :TREE );
  procedure CODE_INSTANTIATION ( INSTANTIATION :TREE );
  procedure CODE_GENERIC_PARAM ( GENERIC_PARAM :TREE );
  procedure CODE_NAME_DEFAULT ( NAME_DEFAULT :TREE );
  procedure CODE_BOX_DEFAULT ( BOX_DEFAULT :TREE );
  procedure CODE_NO_DEFAULT ( NO_DEFAULT :TREE );
  procedure CODE_TYPE_DEF ( TYPE_DEF, TYPE_DECL :TREE );
  procedure CODE_ENUMERATION_DEF ( ENUMERATION_DEF :TREE );
  procedure CODE_ENUM_LITERAL_S ( ENUM_LITERAL_S :TREE );
  procedure CODE_ENUM_LITERAL ( ENUM_LITERAL :TREE );
  procedure CODE_ENUMERATION_ID ( ENUMERATION_ID :TREE );
  procedure CODE_CHARACTER_ID ( CHARACTER_ID :TREE );
  procedure CODE_FORMAL_INTEGER_DEF ( FORMAL_INTEGER_DEF :TREE );
  procedure CODE_FORMAL_FIXED_DEF ( FORMAL_FIXED_DEF :TREE );
  procedure CODE_FORMAL_FLOAT_DEF ( FORMAL_FLOAT_DEF :TREE );
  procedure CODE_FORMAL_DSCRT_DEF ( FORMAL_DSCRT_DEF :TREE );
  procedure CODE_PRIVATE_DEF ( PRIVATE_DEF :TREE );
  procedure CODE_L_PRIVATE_DEF ( L_PRIVATE_DEF :TREE );
  procedure CODE_RECORD_DEF ( RECORD_DEF :TREE );
  procedure CODE_CONSTRAINED_DEF ( CONSTRAINED_DEF, TYPE_DECL :TREE );
  procedure CODE_SUBTYPE_INDICATION ( SUBTYPE_INDICATION :TREE );
  procedure CODE_INTEGER_DEF ( INTEGER_DEF, TYPE_DECL :TREE );
  procedure CODE_FIXED_DEF ( FIXED_DEF :TREE );
  procedure CODE_FLOAT_DEF ( FLOAT_DEF :TREE );
  procedure CODE_ARR_ACC_DER_DEF ( ARR_ACC_DER_DEF :TREE );
  procedure CODE_CONSTRAINED_ARRAY_DEF ( CONSTRAINED_ARRAY_DEF :TREE );
  procedure CODE_UNCONSTRAINED_ARRAY_DEF ( UNCONSTRAINED_ARRAY_DEF :TREE );
  procedure CODE_ACCESS_DEF ( ACCESS_DEF :TREE );
  procedure CODE_DERIVED_DEF ( DERIVED_DEF :TREE );
  procedure CODE_SOURCE_NAME ( SOURCE_NAME :TREE );
  procedure CODE_OBJECT_NAME ( OBJECT_NAME :TREE );
  procedure CODE_UNIT_NAME ( UNIT_NAME :TREE );
  procedure CODE_VC_NAME ( VC_NAME :TREE );
  procedure CODE_VARIABLE_ID ( VARIABLE_ID :TREE );
  procedure CODE_CONSTANT_ID ( CONSTANT_ID :TREE );
  procedure CODE_NUMBER_ID ( NUMBER_ID :TREE );
  procedure CODE_SOURCE_NAME_S ( SOURCE_NAME_S :TREE );
  procedure CODE_TYPE_NAME ( TYPE_NAME :TREE );
  procedure CODE_TYPE_ID ( TYPE_ID :TREE );
  procedure CODE_SUBTYPE_ID ( SUBTYPE_ID :TREE );
  procedure CODE_COMP_NAME ( COMP_NAME :TREE );
  procedure CODE_COMPONENT_ID ( COMPONENT_ID :TREE );
  procedure CODE_DISCRIMINANT_ID ( DISCRIMINANT_ID :TREE );
  procedure CODE_NAME ( NAME :TREE );
  procedure CODE_NAME_EXP ( NAME_EXP :TREE );
  procedure CODE_DESIGNATOR ( DESIGNATOR :TREE );
  procedure CODE_USED_NAME ( USED_NAME :TREE );
  procedure CODE_USED_OP ( USED_OP :TREE );
  procedure CODE_USED_NAME_ID ( USED_NAME_ID :TREE );
  procedure CODE_USED_OBJECT ( USED_OBJECT :TREE );
  procedure CODE_USED_CHAR ( USED_CHAR :TREE );
  procedure CODE_USED_OBJECT_ID ( USED_OBJECT_ID :TREE );
  procedure CODE_INDEXED ( INDEXED :TREE );
  procedure CODE_SLICE ( SLICE :TREE );
  procedure CODE_ALL ( ADA_ALL :TREE );
  procedure CODE_AGGREGATE ( AGGREGATE :TREE );
  procedure CODE_SHORT_CIRCUIT ( SHORT_CIRCUIT :TREE );
  procedure CODE_MEMBERSHIP ( MEMBERSHIP :TREE );
  procedure CODE_RANGE_MEMBERSHIP ( RANGE_MEMBERSHIP :TREE );
  procedure CODE_TYPE_MEMBERSHIP ( TYPE_MEMBERSHIP :TREE );
  procedure CODE_EXP ( EXP :TREE );
  procedure CODE_EXP_EXP ( EXP_EXP :TREE );
  procedure CODE_EXP_VAL ( EXP_VAL :TREE );
  procedure CODE_EXP_VAL_EXP ( EXP_VAL_EXP :TREE );
  procedure CODE_AGG_EXP ( AGG_EXP :TREE );
  procedure CODE_PARENTHESIZED ( PARENTHESIZED :TREE );
  procedure CODE_NUMERIC_LITERAL ( NUMERIC_LITERAL :TREE );
  procedure CODE_STRING_LITERAL ( STRING_LITERAL :TREE );
  procedure CODE_NULL_ACCESS ( NULL_ACCESS :TREE );
  procedure CODE_QUAL_CONV ( QUAL_CONV :TREE );
  procedure CODE_CONVERSION ( CONVERSION :TREE );
  procedure CODE_QUALIFIED ( QUALIFIED :TREE );
  procedure CODE_QUALIFIED_ALLOCATOR ( QUALIFIED_ALLOCATOR :TREE );
  procedure CODE_SUBTYPE_ALLOCATOR ( SUBTYPE_ALLOCATOR :TREE );
  procedure CODE_STM_S ( STM_S :TREE );
  procedure CODE_STM_ELEM ( STM_ELEM :TREE );
  procedure CODE_STM_PRAGMA ( STM_PRAGMA :TREE );
  procedure CODE_STM ( STM :TREE );
  procedure CODE_LABELED ( LABELED :TREE );
  procedure CODE_STM_WITH_EXP ( STM_WITH_EXP :TREE );
  procedure CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP_NAME :TREE );
  procedure CODE_STM_WITH_NAME ( STM_WITH_NAME :TREE );
  procedure CODE_CALL_STM ( CALL_STM :TREE );
  procedure CODE_CLAUSES_STM ( CLAUSES_STM :TREE );
  procedure CODE_LABEL_NAME ( LABEL_NAME :TREE );
  procedure CODE_LABEL_ID ( LABEL_ID :TREE );
  procedure CODE_NULL_STM ( NULL_STM :TREE );
  procedure CODE_OBJECT ( OBJECT :TREE );
  procedure CODE_ADRESSE ( ADRESSE :TREE );
  procedure CODE_ASSIGN ( ASSIGN :TREE );
  procedure CODE_IF ( ADA_IF :TREE );
  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE );
  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE );
  procedure CODE_CASE ( ADA_CASE :TREE );
  procedure CODE_BLOCK_LOOP ( BLOCK_LOOP :TREE );
  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE );
  procedure CODE_ITERATION ( ITERATION :TREE );
  procedure CODE_LOOP ( ADA_LOOP :TREE );
  procedure CODE_FOR_REV ( FOR_REV :TREE );
  procedure CODE_FOR ( ADA_FOR :TREE );
  procedure CODE_REVERSE ( ADA_REVERSE :TREE );
  procedure CODE_ITERATION_ID ( ITERATION_ID :TREE );
  procedure CODE_WHILE ( ADA_WHILE :TREE );
  procedure CODE_BLOCK ( BLOCK :TREE );
  procedure CODE_EXIT ( ADA_EXIT :TREE );
  procedure CODE_RETURN ( ADA_RETURN :TREE );
  procedure CODE_GOTO ( ADA_GOTO :TREE );
  procedure CODE_NON_TASK_NAME ( NON_TASK_NAME :TREE );
  procedure CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :TREE );
  procedure CODE_SUBPROG_NAME ( SUBPROG_NAME :TREE );
  procedure CODE_PROCEDURE_ID ( PROCEDURE_ID :TREE );
  procedure CODE_FUNCTION_ID ( FUNCTION_ID :TREE );
  procedure CODE_OPERATOR_ID ( OPERATOR_ID :TREE );
  procedure CODE_INIT_OBJECT_NAME ( INIT_OBJECT_NAME :TREE );
  procedure CODE_PARAM_NAME ( PARAM_NAME :TREE );
  procedure CODE_PARAM_IO_O ( PARAM_IO_O :TREE );
  procedure CODE_IN_ID ( IN_ID :TREE );
  procedure CODE_IN_OUT_ID ( IN_OUT_ID :TREE );
  procedure CODE_OUT_ID ( OUT_ID :TREE );
  procedure CODE_PROCEDURE_CALL ( PROCEDURE_CALL :TREE );
  procedure CODE_FUNCTION_CALL ( FUNCTION_CALL :TREE );
  procedure CODE_PACKAGE_ID ( PACKAGE_ID :TREE );
  procedure CODE_PRIVATE_TYPE_ID ( PRIVATE_TYPE_ID :TREE );
  procedure CODE_L_PRIVATE_TYPE_ID ( L_PRIVATE_TYPE_ID :TREE );
  procedure CODE_TASK_BODY_ID ( TASK_BODY_ID :TREE );
  procedure CODE_ENTRY_ID ( ENTRY_ID :TREE );
  procedure CODE_ENTRY_CALL ( ENTRY_CALL :TREE );
  procedure CODE_ACCEPT ( ADA_ACCEPT :TREE );
  procedure CODE_DELAY ( ADA_DELAY :TREE );
  procedure CODE_SELECTIVE_WAIT ( SELECTIVE_WAIT :TREE );
  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE );
  procedure CODE_TEST_CLAUSE_ELEM_S ( TEST_CLAUSE_ELEM_S :TREE );
  procedure CODE_SELECT_ALTERNATIVE ( SELECT_ALTERNATIVE :TREE );
  procedure CODE_SELECT_ALT_PRAGMA ( SELECT_ALT_PRAGMA :TREE );
  procedure CODE_TERMINATE ( ADA_TERMINATE :TREE );
  procedure CODE_ENTRY_STM ( ENTRY_STM :TREE );
  procedure CODE_COND_ENTRY ( COND_ENTRY :TREE );
  procedure CODE_TIMED_ENTRY ( TIMED_ENTRY :TREE );
  procedure CODE_NAME_S ( NAME_S :TREE );
  procedure CODE_ABORT ( ADA_ABORT :TREE );
  procedure CODE_EXCEPTION_ID ( EXCEPTION_ID :TREE );
  procedure CODE_RAISE ( ADA_RAISE :TREE );
  procedure CODE_GENERIC_ID ( GENERIC_ID :TREE );
  procedure CODE_CODE ( CODE :TREE );
  --|-------------------------------------------------------------------------------------------



  procedure CODE_COMPILATION_UNIT ( COMPILATION_UNIT :TREE );

				---------
  procedure			CODE_ROOT			( ROOT :TREE )
  is
    USER_ROOT	:constant TREE	:= D( XD_USER_ROOT, ROOT );
    COMPILATION	:constant TREE	:= D( XD_STRUCTURE, USER_ROOT );
    COMPLTN_UNIT_S	:constant TREE	:= D( AS_COMPLTN_UNIT_S, COMPILATION );
  begin
    declare
      COMPLTN_UNIT_SEQ	: SEQ_TYPE	:= LIST ( COMPLTN_UNIT_S );
      COMPLTN_UNIT		: TREE;
    begin
      while not IS_EMPTY( COMPLTN_UNIT_SEQ ) loop
        POP( COMPLTN_UNIT_SEQ, COMPLTN_UNIT );
        EMITS.OPEN_OUTPUT_FILE( GET_LIB_PREFIX & PRINT_NAME( D( XD_LIB_NAME, COMPLTN_UNIT ) ) );

        CODE_COMPILATION_UNIT ( COMPLTN_UNIT );

        EMITS.CLOSE_OUTPUT_FILE;
      end loop;
    end;

  end	CODE_ROOT;
	---------



  procedure CODE_WITH_CONTEXT ( CONTEXT_ELEM_S :TREE );

				---------------------
  procedure			CODE_COMPILATION_UNIT	( COMPILATION_UNIT :TREE )
  is
  begin
    EMITS.TOP_ACT	     := 0;
    EMITS.TOP_MAX	     := 0;
    EMITS.OFFSET_ACT     := 0;
    EMITS.OFFSET_MAX     := 0;
    EMITS.CUR_LEVEL          := 0;
    EMITS.GENERATE_CODE  := FALSE;
    EMITS.CUR_COMP_UNIT  := 2;
    EMITS.ENCLOSING_BODY := TREE_VOID;

    CODE_WITH_CONTEXT( D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT ) );

    EMITS.CUR_COMP_UNIT  := 0;
    EMITS.GENERATE_CODE  := TRUE;

    declare
      UNIT_ALL_DECL		: TREE	:= D( AS_ALL_DECL, COMPILATION_UNIT );
    begin
      case UNIT_ALL_DECL.TY is
      when DN_SUBPROGRAM_BODY	=> CODE_SUBPROGRAM_BODY( UNIT_ALL_DECL );
      when DN_PACKAGE_DECL	=> CODE_PACKAGE_DECL( UNIT_ALL_DECL );
      when DN_PACKAGE_BODY	=> CODE_PACKAGE_BODY( UNIT_ALL_DECL );
      when others => raise PROGRAM_ERROR;
      end case;
--    CODE_ALL_DECL( D( AS_ALL_DECL, COMPILATION_UNIT ) );
    end;
    EMIT( QUIT );

  end	CODE_COMPILATION_UNIT;
	---------------------


				--------------------
  procedure			CODE_SUBPROGRAM_BODY	( SUBPROGRAM_BODY :TREE )
  is
  begin
    declare
       OLD_OFFSET_ACT	: OFFSET_TYPE	:= EMITS.OFFSET_ACT;
       OLD_OFFSET_MAX	: OFFSET_TYPE	:= EMITS.OFFSET_MAX;
       SOURCE_NAME		: TREE		:= D( AS_SOURCE_NAME, SUBPROGRAM_BODY );
       START_LABEL		: LABEL_TYPE	:= NEW_LABEL;
    begin
      if EMITS.ENCLOSING_BODY = TREE_VOID then
        EMIT( PRO, S=> PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) ) );
      end if;
      EMITS.OFFSET_ACT := EMITS.FIRST_PARAM_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      INC_LEVEL;
      DI( CD_LABEL, SOURCE_NAME, INTEGER ( START_LABEL ) );
      DI( CD_LEVEL, SOURCE_NAME, EMITS.CUR_LEVEL );
      WRITE_LABEL( START_LABEL, "ETIQUETTE ENTREE" );

      CODE_HEADER( D( AS_HEADER, SUBPROGRAM_BODY ) );

      DI( CD_PARAM_SIZE, SOURCE_NAME, PARAM_SIZE );
      EMITS.OFFSET_ACT := EMITS.FIRST_LOCAL_VAR_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;

      CODE_BODY( D( AS_BODY, SUBPROGRAM_BODY ) );

      DEC_LEVEL;
      EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
    end;
  end	CODE_SUBPROGRAM_BODY;
	--------------------



				-----------------
  procedure			CODE_PACKAGE_DECL		( PACKAGE_DECL :TREE )
  is
  begin
    EMIT( PKG, S=> PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) ) );
    WRITE_LABEL ( 1 );
    declare
      MAX_OFS_LBL		: LABEL_TYPE	:= NEW_LABEL;
      TOP_OFS_LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin
      EMIT( ENT, INTEGER( 1 ), MAX_OFS_LBL );
      EMIT( ENT, INTEGER( 2 ), TOP_OFS_LBL );
      EMITS.OFFSET_ACT := 0;
      EMITS.OFFSET_MAX := 0;

      CODE_HEADER( D( AS_HEADER, PACKAGE_DECL ) );

      declare
        EXC_LBL		: LABEL_TYPE	:= NEW_LABEL;
      begin
        EMIT( EXH, EXC_LBL, COMMENT=> "ETIQUETTE EXCEPTION HANDLE DU PACKAGE" );
        EMIT( RET, RELATIVE_RESULT_OFFSET );
        WRITE_LABEL( EXC_LBL );
      end;
      EMIT( EEX );
      GEN_LBL_ASSIGNMENT( MAX_OFS_LBL, OFFSET_MAX );
      GEN_LBL_ASSIGNMENT( TOP_OFS_LBL, TOP_MAX + OFFSET_MAX );
    end;

  end	CODE_PACKAGE_DECL;
	-----------------



				-----------------
  procedure			CODE_PACKAGE_BODY		( PACKAGE_BODY :TREE )
  is
  begin
    EMIT( PKB, S=> PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, PACKAGE_BODY ) ) ) );
    EMITS.GENERATE_CODE := FALSE;

    CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_BODY ) ) );

    EMITS.GENERATE_CODE := TRUE;
    WRITE_LABEL( 1 );

    CODE_BODY( D( AS_BODY, PACKAGE_BODY ) );

  end	CODE_PACKAGE_BODY;
	-----------------



				-----------------
  procedure			CODE_WITH_CONTEXT		( CONTEXT_ELEM_S :TREE )
  is

    procedure	CODE_WITHED_PKG	( DEFN :TREE )
    is
    begin
      EMIT( RFP, CUR_COMP_UNIT, S=> PRINT_NAME( D( LX_SYMREP, DEFN ) ) );
      DB( CD_COMPILED, DEFN, TRUE );
      EMITS.GENERATE_CODE := FALSE;
      declare
        SPEC	: TREE		:= D( SM_SPEC, DEFN );
        DECL_SEQ	: SEQ_TYPE	:= LIST( D( AS_DECL_S1, SPEC ) );
        DECL	: TREE;
      begin
        while not IS_EMPTY( DECL_SEQ ) loop
	POP( DECL_SEQ, DECL );
-- CODE_DECL( DECL );
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
	      EMITS.GENERATE_CODE := TRUE;
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
		  EMITS.GENERATE_CODE := FALSE;
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



  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONTEXT_PRAGMA ( CONTEXT_PRAGMA :TREE ) is
  begin
    null;
  end;



  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALL_DECL ( ALL_DECL :TREE ) is
  begin

    if ALL_DECL.TY in CLASS_ITEM then
      CODE_ITEM ( ALL_DECL );

    elsif ALL_DECL.TY = DN_SUBUNIT then
      CODE_SUBUNIT ( ALL_DECL );

    elsif ALL_DECL.TY = DN_BLOCK_MASTER then
      CODE_BLOCK_MASTER ( ALL_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBUNIT ( SUBUNIT :TREE ) is
  begin
      CODE_SUBUNIT_BODY ( D ( AS_SUBUNIT_BODY, SUBUNIT ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BLOCK_MASTER ( BLOCK_MASTER :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ITEM_S ( ITEM_S :TREE ) is
  begin
    declare
      ITEM_SEQ : SEQ_TYPE := LIST ( ITEM_S );
      ITEM : TREE;
    begin
      while not IS_EMPTY ( ITEM_SEQ ) loop
        POP ( ITEM_SEQ, ITEM );
      CODE_ITEM ( ITEM );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ITEM ( ITEM :TREE ) is
  begin

    if ITEM.TY in CLASS_DECL then
      CODE_DECL ( ITEM );

    elsif ITEM.TY in CLASS_SUBUNIT_BODY then
      CODE_SUBUNIT_BODY ( ITEM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBUNIT_BODY ( SUBUNIT_BODY :TREE ) is
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
  end;






  --|-------------------------------------------------------------------------------------------

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TASK_BODY ( TASK_BODY :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DECL ( DECL :TREE ) is
  begin

    if DECL.TY = DN_NULL_COMP_DECL then
      CODE_NULL_COMP_DECL ( DECL );

    elsif DECL.TY in CLASS_ID_DECL then
      CODE_ID_DECL ( DECL );

    elsif DECL.TY in CLASS_ID_S_DECL then
      CODE_ID_S_DECL ( DECL );

    elsif DECL.TY in CLASS_REP then
      CODE_REP ( DECL );

    elsif DECL.TY in CLASS_USE_PRAGMA then
      CODE_USE_PRAGMA ( DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NULL_COMP_DECL ( NULL_COMP_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ID_DECL ( ID_DECL :TREE ) is
  begin

    if ID_DECL.TY = DN_TYPE_DECL then
      CODE_TYPE_DECL ( ID_DECL );

    elsif ID_DECL.TY = DN_SUBTYPE_DECL then
      CODE_SUBTYPE_DECL ( ID_DECL );

    elsif ID_DECL.TY = DN_TASK_DECL then
      CODE_TASK_DECL ( ID_DECL );

    elsif ID_DECL.TY in CLASS_UNIT_DECL then
      CODE_UNIT_DECL ( ID_DECL );

    elsif ID_DECL.TY in CLASS_SIMPLE_RENAME_DECL then
      CODE_SIMPLE_RENAME_DECL ( ID_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TYPE_DECL ( TYPE_DECL :TREE ) is
  begin

    if TYPE_DECL.TY = DN_TYPE_DECL then
      CODE_TYPE_DEF ( D ( AS_TYPE_DEF, TYPE_DECL ), TYPE_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBTYPE_DECL ( SUBTYPE_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TASK_DECL ( TASK_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SIMPLE_RENAME_DECL ( SIMPLE_RENAME_DECL :TREE ) is
  begin

    if SIMPLE_RENAME_DECL.TY = DN_RENAMES_OBJ_DECL then
      CODE_RENAMES_OBJ_DECL ( SIMPLE_RENAME_DECL );

    elsif SIMPLE_RENAME_DECL.TY = DN_RENAMES_EXC_DECL then
      CODE_RENAMES_EXC_DECL ( SIMPLE_RENAME_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RENAMES_OBJ_DECL ( RENAMES_OBJ_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RENAMES_EXC_DECL ( RENAMES_EXC_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNIT_DECL ( UNIT_DECL :TREE ) is
  begin

    if UNIT_DECL.TY = DN_GENERIC_DECL then
      CODE_GENERIC_DECL ( UNIT_DECL );

    elsif UNIT_DECL.TY in CLASS_NON_GENERIC_DECL then
      CODE_NON_GENERIC_DECL ( UNIT_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_GENERIC_DECL ( GENERIC_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NON_GENERIC_DECL ( NON_GENERIC_DECL :TREE ) is
  begin

    if NON_GENERIC_DECL.TY = DN_SUBPROG_ENTRY_DECL then
      CODE_SUBPROG_ENTRY_DECL ( NON_GENERIC_DECL );

    elsif NON_GENERIC_DECL.TY = DN_PACKAGE_DECL then
      CODE_PACKAGE_DECL ( NON_GENERIC_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBPROG_ENTRY_DECL ( SUBPROG_ENTRY_DECL :TREE ) is
  begin
    declare
      OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
      OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
      SOURCE_NAME    : TREE        := D ( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
      HEADER         : TREE        := D ( AS_HEADER, SUBPROG_ENTRY_DECL );
    begin
      EMITS.OFFSET_ACT := EMITS.FIRST_PARAM_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      INC_LEVEL;
      if SOURCE_NAME.TY in CLASS_SUBPROG_NAME then
        declare
          LBL : LABEL_TYPE := NEW_LABEL;
        begin
          DI ( CD_LABEL, SOURCE_NAME, INTEGER ( LBL ) );
          DI ( CD_LEVEL, SOURCE_NAME, EMITS.CUR_LEVEL );
          DB ( CD_COMPILED, SOURCE_NAME, TRUE );
          if not EMITS.GENERATE_CODE then
            EMITS.GENERATE_CODE := TRUE;
            EMIT ( RFL, LBL );
            EMITS.GENERATE_CODE := FALSE;
          end if;

	CODE_HEADER( D( AS_HEADER, SUBPROG_ENTRY_DECL ) );

          DI( CD_PARAM_SIZE, SOURCE_NAME, OFFSET_ACT - FIRST_PARAM_OFFSET );
        end;
        if SOURCE_NAME.TY = DN_FUNCTION_ID or SOURCE_NAME.TY = DN_OPERATOR_ID then
          declare
            USED_OBJECT_ID   : TREE := D ( AS_NAME, HEADER );
            RESULT_TYPE_SPEC : TREE := D ( SM_EXP_TYPE, USED_OBJECT_ID );
          begin
            DI ( CD_RESULT_SIZE, SOURCE_NAME, EMITS.TYPE_SIZE( RESULT_TYPE_SPEC ));
          end;
        end if;
      end if;
      DEC_LEVEL;
      EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
    end;
  end;

  --|-------------------------------------------------------------------------------------------

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USE_PRAGMA ( USE_PRAGMA :TREE ) is
  begin

    if USE_PRAGMA.TY = DN_USE then
      CODE_USE ( USE_PRAGMA );

    elsif USE_PRAGMA.TY = DN_PRAGMA then
      CODE_PRAGMA ( USE_PRAGMA );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USE ( ADA_USE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PRAGMA ( ADA_PRAGMA :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ID_S_DECL ( ID_S_DECL :TREE ) is
  begin

    if ID_S_DECL.TY in CLASS_EXP_DECL then
      CODE_EXP_DECL( ID_S_DECL );

    elsif ID_S_DECL.TY = DN_EXCEPTION_DECL then
      CODE_EXCEPTION_DECL( ID_S_DECL );

    elsif ID_S_DECL.TY = DN_DEFERRED_CONSTANT_DECL then
      CODE_DEFERRED_CONSTANT_DECL( ID_S_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXCEPTION_DECL ( EXCEPTION_DECL :TREE ) is
  begin
      CODE_SOURCE_NAME_S ( D ( AS_SOURCE_NAME_S, EXCEPTION_DECL ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DEFERRED_CONSTANT_DECL ( DEFERRED_CONSTANT_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXP_DECL ( EXP_DECL :TREE ) is
  begin

    if EXP_DECL.TY in CLASS_OBJECT_DECL then
      CODE_OBJECT_DECL ( EXP_DECL );

    elsif EXP_DECL.TY = DN_NUMBER_DECL then
      CODE_NUMBER_DECL ( EXP_DECL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NUMBER_DECL ( NUMBER_DECL :TREE ) is
  begin
    null;
  end;



				----------------
  procedure			CODE_OBJECT_DECL		( OBJECT_DECL :TREE )
  is
  begin
    declare
      SRC_NAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, OBJECT_DECL ) );
      SRC_NAME	: TREE;
      TYPE_DEF	: TREE		:= D( AS_TYPE_DEF, OBJECT_DECL );
      TYPE_NAME	: TREE		:= D( AS_NAME, TYPE_DEF );
    begin
      EMITS.TYPE_SYMREP := D( LX_SYMREP, TYPE_NAME );
      while not IS_EMPTY( SRC_NAME_SEQ ) loop
        POP( SRC_NAME_SEQ, SRC_NAME );
        CODE_VC_NAME ( SRC_NAME );
      end loop;
    end;
  end	CODE_OBJECT_DECL;
	----------------




  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONSTANT_DECL ( CONSTANT_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_VARIABLE_DECL ( VARIABLE_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_REP ( REP :TREE ) is
  begin

    if REP.TY in CLASS_NAMED_REP then
      CODE_NAMED_REP ( REP );

    elsif REP.TY = DN_RECORD_REP then
      CODE_RECORD_REP ( REP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RECORD_REP ( RECORD_REP :TREE ) is
  begin
      CODE_ALIGNMENT_CLAUSE ( D ( AS_ALIGNMENT_CLAUSE, RECORD_REP ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALIGNMENT_CLAUSE ( ALIGNMENT_CLAUSE :TREE ) is
  begin
      CODE_ALIGNMENT ( ALIGNMENT_CLAUSE );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALIGNMENT ( ALIGNMENT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NAMED_REP ( NAMED_REP :TREE ) is
  begin

    if NAMED_REP.TY = DN_ADDRESS then
      CODE_ADDRESS ( NAMED_REP );

    elsif NAMED_REP.TY = DN_LENGTH_ENUM_REP then
      CODE_LENGTH_ENUM_REP ( NAMED_REP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ADDRESS ( ADDRESS :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_LENGTH_ENUM_REP ( LENGTH_ENUM_REP :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DSCRMT_DECL_S ( DSCRMT_DECL_S :TREE ) is
  begin
    declare
      DSCRMT_DECL_SEQ : SEQ_TYPE := LIST ( DSCRMT_DECL_S );
      DSCRMT_DECL : TREE;
    begin
      while not IS_EMPTY ( DSCRMT_DECL_SEQ ) loop
        POP ( DSCRMT_DECL_SEQ, DSCRMT_DECL );
      CODE_DSCRMT_DECL ( DSCRMT_DECL );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DSCRMT_DECL ( DSCRMT_DECL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PARAM_S ( PARAM_S :TREE ) is
  begin
    declare
      PARAM_SEQ : SEQ_TYPE := LIST ( PARAM_S );
      PARAM : TREE;
    begin
      while not IS_EMPTY ( PARAM_SEQ ) loop
        POP ( PARAM_SEQ, PARAM );
      CODE_PARAM ( PARAM );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PARAM ( PARAM :TREE ) is
  begin

    if PARAM.TY = DN_IN then
      CODE_IN ( PARAM );

    elsif PARAM.TY = DN_OUT then
      CODE_OUT ( PARAM );

    elsif PARAM.TY = DN_IN_OUT then
      CODE_IN_OUT ( PARAM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN ( ADA_IN :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_OUT ( ADA_IN_OUT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OUT ( ADA_OUT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_HEADER ( HEADER :TREE ) is
  begin

    if HEADER.TY in CLASS_SUBP_ENTRY_HEADER then
      CODE_PARAM_S ( D ( AS_PARAM_S, HEADER ) );
      CODE_SUBP_ENTRY_HEADER ( HEADER );

    elsif HEADER.TY = DN_PACKAGE_SPEC then
      CODE_PACKAGE_SPEC ( HEADER );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PACKAGE_SPEC ( PACKAGE_SPEC :TREE ) is
  begin
      CODE_DECL_S ( D ( AS_DECL_S1, PACKAGE_SPEC ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DECL_S ( DECL_S :TREE ) is
  begin
    declare
      DECL_SEQ : SEQ_TYPE := LIST ( DECL_S );
      DECL : TREE;
    begin
      while not IS_EMPTY ( DECL_SEQ ) loop
        POP ( DECL_SEQ, DECL );
      CODE_DECL ( DECL );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBP_ENTRY_HEADER ( SUBP_ENTRY_HEADER :TREE ) is
  begin

    if SUBP_ENTRY_HEADER.TY = DN_PROCEDURE_SPEC then
      CODE_PROCEDURE_SPEC ( SUBP_ENTRY_HEADER );

    elsif SUBP_ENTRY_HEADER.TY = DN_FUNCTION_SPEC then
      CODE_FUNCTION_SPEC ( SUBP_ENTRY_HEADER );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PROCEDURE_SPEC ( PROCEDURE_SPEC :TREE ) is
  begin
    EMITS.PARAM_SIZE := (EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET + EMITS.RELATIVE_RESULT_OFFSET);
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FUNCTION_SPEC ( FUNCTION_SPEC :TREE ) is
  begin
    INC_OFFSET ( EMITS.RELATIVE_RESULT_OFFSET );
    EMITS.PARAM_SIZE := ( EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET );
    DI ( CD_RESULT_SIZE, D ( AS_NAME, FUNCTION_SPEC ), EMITS.RESULT_SIZE );
    INC_OFFSET ( EMITS.RESULT_SIZE );
    ALIGN ( STACK_AL );
    DI ( CD_RESULT_OFFSET, FUNCTION_SPEC, EMITS.OFFSET_ACT );
    EMITS.FUN_RESULT_OFFSET := EMITS.OFFSET_ACT;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNIT_DESC ( UNIT_DESC :TREE ) is
  begin

    if UNIT_DESC.TY = DN_DERIVED_SUBPROG then
      CODE_DERIVED_SUBPROG ( UNIT_DESC );

    elsif UNIT_DESC.TY = DN_IMPLICIT_NOT_EQ then
      CODE_IMPLICIT_NOT_EQ ( UNIT_DESC );

    elsif UNIT_DESC.TY in CLASS_BODY then
      CODE_BODY ( UNIT_DESC );

    elsif UNIT_DESC.TY in CLASS_UNIT_KIND then
      CODE_UNIT_KIND ( UNIT_DESC );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DERIVED_SUBPROG ( DERIVED_SUBPROG :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IMPLICIT_NOT_EQ ( IMPLICIT_NOT_EQ :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BODY ( ADA_BODY :TREE ) is
  begin

    if ADA_BODY.TY = DN_BLOCK_BODY then
      CODE_BLOCK_BODY ( ADA_BODY );

    elsif ADA_BODY.TY = DN_STUB then
      CODE_STUB ( ADA_BODY );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BLOCK_BODY ( BLOCK_BODY :TREE ) is
  begin
    declare
      SAVE_ENCLOSING_BODY : TREE := ENCLOSING_BODY;
      OLD_TOP_ACT         : OFFSET_TYPE := EMITS.TOP_ACT;
      OLD_TOP_MAX         : OFFSET_TYPE := EMITS.TOP_MAX;
    begin
      ENCLOSING_BODY := BLOCK_BODY;
      EMITS.TOP_ACT := 0;
      EMITS.TOP_MAX := 0;
      DI ( CD_LEVEL, BLOCK_BODY, INTEGER ( EMITS.CUR_LEVEL ) );
      DI ( CD_RETURN_LABEL, BLOCK_BODY, INTEGER ( NEW_LABEL ) );
      declare
        ENT_1_LBL : LABEL_TYPE := NEW_LABEL;
        ENT_2_LBL : LABEL_TYPE := NEW_LABEL;
      begin
        EMIT ( ENT, INTEGER ( 1 ), ENT_1_LBL );
        EMIT ( ENT, INTEGER ( 2 ), ENT_2_LBL );
        if FUNCTION_RESULT /= TREE_VOID then
          if FUNCTION_RESULT.TY = DN_ARRAY then
            GEN_PUSH_ADDR ( DI ( CD_COMP_UNIT, FUNCTION_RESULT ),
                            DI ( CD_LEVEL, FUNCTION_RESULT ),
                            DI ( CD_OFFSET, FUNCTION_RESULT )
                );
            EMIT ( DPL, A );
            EMIT ( SLD, A, 0, FUN_RESULT_OFFSET - EMITS.ADDR_SIZE );
            EMIT ( IND, I, 0 );
            EMIT ( ALO, INTEGER ( -1 ) );
            EMIT ( SLD, A, 0, FUN_RESULT_OFFSET );
          end if;
        end if;
      CODE_ITEM_S ( D ( AS_ITEM_S, BLOCK_BODY ) );
        declare
          EXC_LBL : LABEL_TYPE := NEW_LABEL;
        begin
          EMIT ( EXH, EXC_LBL, COMMENT=> "EXCEPTION HANDLERS" );
      CODE_STM_S ( D ( AS_STM_S, BLOCK_BODY ) );
          WRITE_LABEL ( LABEL_TYPE ( DI ( CD_RETURN_LABEL, BLOCK_BODY ) ) );
          EMIT ( RET, PARAM_SIZE );
          WRITE_LABEL ( EXC_LBL );
        end;
        if not IS_EMPTY ( LIST ( D ( AS_ALTERNATIVE_S, BLOCK_BODY ) ) ) then
      CODE_ALTERNATIVE_S ( D ( AS_ALTERNATIVE_S, BLOCK_BODY ) );
        else
          EMIT ( EEX );
        end if;
        GEN_LBL_ASSIGNMENT ( ENT_1_LBL, EMITS.OFFSET_MAX );
        GEN_LBL_ASSIGNMENT ( ENT_2_LBL, EMITS.OFFSET_MAX + EMITS.TOP_MAX );
      end;
      EMITS.TOP_MAX := OLD_TOP_MAX;
      EMITS.TOP_ACT := OLD_TOP_ACT;
      ENCLOSING_BODY := SAVE_ENCLOSING_BODY;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE_S ( ALTERNATIVE_S :TREE ) is
  begin
    declare
      ALTERNATIVE_SEQ : SEQ_TYPE := LIST ( ALTERNATIVE_S );
      ALTERNATIVE_ELEM : TREE;
    begin
      while not IS_EMPTY ( ALTERNATIVE_SEQ ) loop
        POP ( ALTERNATIVE_SEQ, ALTERNATIVE_ELEM );
      CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM :TREE ) is
  begin

    if ALTERNATIVE_ELEM.TY = DN_ALTERNATIVE then
      CODE_ALTERNATIVE ( ALTERNATIVE_ELEM );

    elsif ALTERNATIVE_ELEM.TY = DN_ALTERNATIVE_PRAGMA then
      CODE_ALTERNATIVE_PRAGMA ( ALTERNATIVE_ELEM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE ( ALTERNATIVE :TREE ) is
  begin
    declare
      SKIP_LBL          : LABEL_TYPE := NEW_LABEL;
      HANDLER_BEGIN_LBL : LABEL_TYPE := NEW_LABEL;
      CHOICE_S          : TREE       := D ( AS_CHOICE_S, ALTERNATIVE );
    begin
      DI ( CD_LABEL, CHOICE_S, INTEGER ( HANDLER_BEGIN_LBL ) );
      CODE_CHOICE_S ( CHOICE_S );
      if not CHOICE_OTHERS_FLAG then
        EMIT ( JMP, SKIP_LBL, COMMENT=> "SKIP ALTERNATIVE SUIVANTE"  );
        WRITE_LABEL ( HANDLER_BEGIN_LBL, COMMENT=> "LABEL DEBUT INSTRUCTIONS" );
      end if;
      CODE_STM_S ( D ( AS_STM_S, ALTERNATIVE ) );
      if not CHOICE_OTHERS_FLAG then
        WRITE_LABEL ( SKIP_LBL, COMMENT=> "ALTERNATIVE SUIVANTE" );
      end if;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE_PRAGMA ( ALTERNATIVE_PRAGMA :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHOICE_S ( CHOICE_S :TREE ) is
  begin
    declare
      CHOICE_SEQ : SEQ_TYPE := LIST ( CHOICE_S );
      CHOICE : TREE;
    begin
      while not IS_EMPTY ( CHOICE_SEQ ) loop
        POP ( CHOICE_SEQ, CHOICE );
      CODE_CHOICE ( CHOICE );
    if not CHOICE_OTHERS_FLAG then
       EMIT ( JMPT, LABEL_TYPE ( DI ( CD_LABEL, CHOICE_S ) ), COMMENT=> "TRAITE EXCEPTION" );
    end if;
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHOICE ( CHOICE :TREE ) is
  begin

    if CHOICE.TY = DN_CHOICE_EXP then
      CODE_CHOICE_EXP ( CHOICE );

    elsif CHOICE.TY = DN_CHOICE_RANGE then
      CODE_CHOICE_RANGE ( CHOICE );

    elsif CHOICE.TY = DN_CHOICE_OTHERS then
      CODE_CHOICE_OTHERS ( CHOICE );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHOICE_EXP ( CHOICE_EXP :TREE ) is
  begin
      CODE_EXP ( D ( AS_EXP, CHOICE_EXP ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHOICE_RANGE ( CHOICE_RANGE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHOICE_OTHERS ( CHOICE_OTHERS :TREE ) is
  begin
    CHOICE_OTHERS_FLAG := TRUE;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STUB ( STUB :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNIT_KIND ( UNIT_KIND :TREE ) is
  begin

    if UNIT_KIND.TY in CLASS_RENAME_INSTANT then
      CODE_RENAME_INSTANT ( UNIT_KIND );

    elsif UNIT_KIND.TY in CLASS_GENERIC_PARAM then
      CODE_GENERIC_PARAM ( UNIT_KIND );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RENAME_INSTANT ( RENAME_INSTANT :TREE ) is
  begin

    if RENAME_INSTANT.TY = DN_RENAMES_UNIT then
      CODE_RENAMES_UNIT ( RENAME_INSTANT );

    elsif RENAME_INSTANT.TY = DN_INSTANTIATION then
      CODE_INSTANTIATION ( RENAME_INSTANT );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RENAMES_UNIT ( RENAMES_UNIT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_INSTANTIATION ( INSTANTIATION :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_GENERIC_PARAM ( GENERIC_PARAM :TREE ) is
  begin

    if GENERIC_PARAM.TY = DN_NAME_DEFAULT then
      CODE_NAME_DEFAULT ( GENERIC_PARAM );

    elsif GENERIC_PARAM.TY = DN_BOX_DEFAULT then
      CODE_BOX_DEFAULT ( GENERIC_PARAM );

    elsif GENERIC_PARAM.TY = DN_NO_DEFAULT then
      CODE_NO_DEFAULT ( GENERIC_PARAM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NAME_DEFAULT ( NAME_DEFAULT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BOX_DEFAULT ( BOX_DEFAULT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NO_DEFAULT ( NO_DEFAULT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TYPE_DEF ( TYPE_DEF, TYPE_DECL :TREE ) is
  begin

    if TYPE_DEF.TY = DN_ENUMERATION_DEF then
      CODE_ENUMERATION_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_RECORD_DEF then
      CODE_RECORD_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_FORMAL_DSCRT_DEF then
      CODE_FORMAL_DSCRT_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_FORMAL_INTEGER_DEF then
      CODE_FORMAL_INTEGER_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_FORMAL_FIXED_DEF then
      CODE_FORMAL_FIXED_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_FORMAL_FLOAT_DEF then
      CODE_FORMAL_FLOAT_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_PRIVATE_DEF then
      CODE_PRIVATE_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY = DN_L_PRIVATE_DEF then
      CODE_L_PRIVATE_DEF ( TYPE_DEF );

    elsif TYPE_DEF.TY in CLASS_CONSTRAINED_DEF then
      CODE_CONSTRAINED_DEF ( TYPE_DEF, TYPE_DECL );

    elsif TYPE_DEF.TY in CLASS_ARR_ACC_DER_DEF then
      CODE_ARR_ACC_DER_DEF ( TYPE_DEF );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENUMERATION_DEF ( ENUMERATION_DEF :TREE ) is
  begin
      CODE_ENUM_LITERAL_S ( D ( AS_ENUM_LITERAL_S, ENUMERATION_DEF ) );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENUM_LITERAL_S ( ENUM_LITERAL_S :TREE ) is
  begin
    declare
      LAST_LITERAL :TREE;
    begin
    declare
      ENUM_LITERAL_SEQ : SEQ_TYPE := LIST ( ENUM_LITERAL_S );
      ENUM_LITERAL : TREE;
    begin
      while not IS_EMPTY ( ENUM_LITERAL_SEQ ) loop
        POP ( ENUM_LITERAL_SEQ, ENUM_LITERAL );
        LAST_LITERAL := ENUM_LITERAL;
    end loop;
    end;
    DI ( CD_LAST, ENUM_LITERAL_S, DI ( SM_REP, LAST_LITERAL ) );
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENUM_LITERAL ( ENUM_LITERAL :TREE ) is
  begin

    if ENUM_LITERAL.TY = DN_ENUMERATION_ID then
      CODE_ENUMERATION_ID ( ENUM_LITERAL );

    elsif ENUM_LITERAL.TY = DN_CHARACTER_ID then
      CODE_CHARACTER_ID ( ENUM_LITERAL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENUMERATION_ID ( ENUMERATION_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CHARACTER_ID ( CHARACTER_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FORMAL_INTEGER_DEF ( FORMAL_INTEGER_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FORMAL_FIXED_DEF ( FORMAL_FIXED_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FORMAL_FLOAT_DEF ( FORMAL_FLOAT_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FORMAL_DSCRT_DEF ( FORMAL_DSCRT_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PRIVATE_DEF ( PRIVATE_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_L_PRIVATE_DEF ( L_PRIVATE_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RECORD_DEF ( RECORD_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONSTRAINED_DEF ( CONSTRAINED_DEF, TYPE_DECL :TREE ) is
  begin

    if CONSTRAINED_DEF.TY = DN_SUBTYPE_INDICATION then
      CODE_SUBTYPE_INDICATION ( CONSTRAINED_DEF );

    elsif CONSTRAINED_DEF.TY = DN_INTEGER_DEF then
      CODE_INTEGER_DEF ( CONSTRAINED_DEF, TYPE_DECL );

    elsif CONSTRAINED_DEF.TY = DN_FIXED_DEF then
      CODE_FIXED_DEF ( CONSTRAINED_DEF );

    elsif CONSTRAINED_DEF.TY = DN_FLOAT_DEF then
      CODE_FLOAT_DEF ( CONSTRAINED_DEF );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBTYPE_INDICATION ( SUBTYPE_INDICATION :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_INTEGER_DEF ( INTEGER_DEF, TYPE_DECL :TREE ) is
  begin
    declare
      TYPE_ID      : TREE := D( AS_SOURCE_NAME, TYPE_DECL );
      INTEGER_SPEC : TREE := D( SM_TYPE_SPEC, TYPE_ID );
      LOWER        : OFFSET_TYPE;
      UPPER        : OFFSET_TYPE;
      INT_RANGE    : TREE := D( AS_CONSTRAINT, INTEGER_DEF );
      EXP_BORNE    : TREE;
     begin
      ALIGN( INTG_AL );
      LOWER := - EMITS.OFFSET_ACT;
      INC_OFFSET( INTG_SIZE );
      UPPER := - EMITS.OFFSET_ACT;
      INC_OFFSET( INTG_SIZE );
      DI( CD_OFFSET,    INTEGER_SPEC, LOWER );
      DI( CD_LEVEL,     INTEGER_SPEC, EMITS.CUR_LEVEL );
      DI( CD_COMP_UNIT, INTEGER_SPEC, CUR_COMP_UNIT );
      DB( CD_COMPILED,  INTEGER_SPEC, TRUE );
      EXP_BORNE := D( AS_EXP1, INT_RANGE );
      CODE_EXP ( EXP_BORNE );
      GEN_STORE( I, EMITS.CUR_COMP_UNIT, EMITS.CUR_LEVEL, LOWER, "BORNE BASSE" );
      EXP_BORNE := D( AS_EXP2, INT_RANGE );
      CODE_EXP ( EXP_BORNE );
      GEN_STORE( I, EMITS.CUR_COMP_UNIT, EMITS.CUR_LEVEL, UPPER, "BORNE HAUTE" );
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FIXED_DEF ( FIXED_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FLOAT_DEF ( FLOAT_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ARR_ACC_DER_DEF ( ARR_ACC_DER_DEF :TREE ) is
  begin

    if ARR_ACC_DER_DEF.TY = DN_CONSTRAINED_ARRAY_DEF then
      CODE_CONSTRAINED_ARRAY_DEF ( ARR_ACC_DER_DEF );

    elsif ARR_ACC_DER_DEF.TY = DN_UNCONSTRAINED_ARRAY_DEF then
      CODE_UNCONSTRAINED_ARRAY_DEF ( ARR_ACC_DER_DEF );

    elsif ARR_ACC_DER_DEF.TY = DN_ACCESS_DEF then
      CODE_ACCESS_DEF ( ARR_ACC_DER_DEF );

    elsif ARR_ACC_DER_DEF.TY = DN_DERIVED_DEF then
      CODE_DERIVED_DEF ( ARR_ACC_DER_DEF );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONSTRAINED_ARRAY_DEF ( CONSTRAINED_ARRAY_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNCONSTRAINED_ARRAY_DEF ( UNCONSTRAINED_ARRAY_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ACCESS_DEF ( ACCESS_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DERIVED_DEF ( DERIVED_DEF :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SOURCE_NAME ( SOURCE_NAME :TREE ) is
  begin

    if SOURCE_NAME.TY in CLASS_OBJECT_NAME then
      CODE_OBJECT_NAME ( SOURCE_NAME );

    elsif SOURCE_NAME.TY in CLASS_TYPE_NAME then
      CODE_TYPE_NAME ( SOURCE_NAME );

    elsif SOURCE_NAME.TY in CLASS_UNIT_NAME then
      CODE_UNIT_NAME ( SOURCE_NAME );

    elsif SOURCE_NAME.TY in CLASS_LABEL_NAME then
      CODE_LABEL_NAME ( SOURCE_NAME );

    elsif SOURCE_NAME.TY = DN_ENTRY_ID then
      CODE_ENTRY_ID ( SOURCE_NAME );

    elsif SOURCE_NAME.TY = DN_EXCEPTION_ID then
      CODE_EXCEPTION_ID ( SOURCE_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OBJECT_NAME ( OBJECT_NAME :TREE ) is
  begin

    if OBJECT_NAME.TY = DN_ITERATION_ID then
      CODE_ITERATION_ID ( OBJECT_NAME );

    elsif OBJECT_NAME.TY in CLASS_INIT_OBJECT_NAME then
      CODE_INIT_OBJECT_NAME ( OBJECT_NAME );

    elsif OBJECT_NAME.TY in CLASS_ENUM_LITERAL then
      CODE_ENUM_LITERAL ( OBJECT_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNIT_NAME ( UNIT_NAME :TREE ) is
  begin

    if UNIT_NAME.TY = DN_TASK_BODY_ID then
      CODE_TASK_BODY_ID ( UNIT_NAME );

    elsif UNIT_NAME.TY in CLASS_NON_TASK_NAME then
      CODE_NON_TASK_NAME ( UNIT_NAME );

    end if;
  end;



				------------
  procedure			CODE_VC_NAME		( VC_NAME :TREE )
  is
  begin
    declare
      TYPE_SPEC	: TREE	:= D( SM_OBJ_TYPE, VC_NAME );

		-----------------------
      procedure	COMPILE_VC_NAME_INTEGER	( VC_NAME :TREE )
      is
      begin
        ALIGN( INTG_AL );
        declare
	CCU	: COMP_UNIT_NBR	renames EMITS.CUR_COMP_UNIT;
	LVL	: LEVEL_TYPE	renames EMITS.CUR_LEVEL;
	OFS	: OFFSET_TYPE	:= - EMITS.OFFSET_ACT;
	INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
        begin
          DI( CD_COMP_UNIT, VC_NAME, CCU );
          DI( CD_LEVEL,     VC_NAME, LVL );
          DI( CD_OFFSET,    VC_NAME, OFS );
          DB( CD_COMPILED,  VC_NAME, TRUE );
          INC_OFFSET( INTG_SIZE );
          if INIT_EXP /= TREE_VOID then
	  CODE_EXP ( INIT_EXP );
	  GEN_STORE( I, CCU, LVL, OFS,
                      "STO " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " VAL INIT" );
          end if;
        end;
      end	COMPILE_VC_NAME_INTEGER;
	-----------------------

		---------------------------
      procedure	COMPILE_VC_NAME_ENUMERATION	( VC_NAME, TYPE_SPEC :TREE )
      is
        NAME	:constant STRING	:= PRINT_NAME( EMITS.TYPE_SYMREP );

		-------------------------
        procedure	COMPILE_VC_NAME_BOOL_CHAR	( VC_NAME :TREE; CT :CODE_DATA_TYPE; SIZ, ALI :NATURAL ) is
        begin
          ALIGN( ALI );
          declare
	  CCU		: COMP_UNIT_NBR	renames EMITS.CUR_COMP_UNIT;
	  LVL		: LEVEL_TYPE	renames EMITS.CUR_LEVEL;
	  OFS		: OFFSET_TYPE	:= - EMITS.OFFSET_ACT;
	  INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
          begin
            DI( CD_LEVEL, VC_NAME, LVL );
            DI( CD_OFFSET, VC_NAME, OFS );
            DI( CD_COMP_UNIT, VC_NAME, CCU );
            DB( CD_COMPILED, VC_NAME, TRUE );
            INC_OFFSET( SIZ );
            if INIT_EXP /= TREE_VOID then
	    CODE_EXP( INIT_EXP );
            end if;
            GEN_STORE( CT, CCU, LVL, OFS,
			PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & " := VAL INIT" );
          end;
        end	COMPILE_VC_NAME_BOOL_CHAR;
		-------------------------

      begin
        if NAME = "BOOLEAN" then
          COMPILE_VC_NAME_BOOL_CHAR( VC_NAME, B, BOOL_SIZE, BOOL_AL );
        elsif NAME = "CHARACTER" then
          COMPILE_VC_NAME_BOOL_CHAR( VC_NAME, C, CHAR_SIZE, CHAR_AL );
        else
          COMPILE_VC_NAME_INTEGER( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_ENUMERATION;
	---------------------------

		------------------
      procedure	COMPILE_ACCESS_VAR	( VAR_ID, TYPE_SPEC :TREE )
      is
      begin
        ALIGN( ADDR_AL );
        declare
	CCU	: COMP_UNIT_NBR	renames EMITS.CUR_COMP_UNIT;
	LVL	: LEVEL_TYPE	renames EMITS.CUR_LEVEL;
	OFS	: OFFSET_TYPE   := - EMITS.OFFSET_ACT;
        begin
	DI( CD_COMP_UNIT, VAR_ID, CCU );
	DI( CD_LEVEL,     VAR_ID, LVL );
	DI( CD_OFFSET,    VAR_ID, OFS );
          DB( CD_COMPILED, VAR_ID, TRUE );
          INC_OFFSET( ADDR_SIZE );
          declare
            INIT_EXP	: TREE	:= D( SM_INIT_EXP, VAR_ID );
          begin
            if INIT_EXP = TREE_VOID then
              EMIT( LDC, A, -1, "INIT NIL DE " & PRINT_NAME( D( LX_SYMREP, VAR_ID ) ) );
            else
              LOAD_TYPE_SIZE( TYPE_SPEC  );
              EMIT( ALO, LVL - DI( CD_LEVEL, TYPE_SPEC ) );
            end if;
          end;
          GEN_STORE( A, CCU, LVL, OFS,
                   COMMENT => "STO " & PRINT_NAME ( D (LX_SYMREP, VAR_ID ) ) & " VAL INIT" );
        end;
      end	COMPILE_ACCESS_VAR;
	------------------


		-----------------
      procedure	COMPILE_ARRAY_VAR	( VC_NAME, TYPE_SPEC :TREE )
      is
        DESCR_PTR	: OFFSET_TYPE;
      begin
        ALIGN ( ADDR_AL );
        declare
	CCU	: COMP_UNIT_NBR	renames EMITS.CUR_COMP_UNIT;
          LVL	: LEVEL_TYPE	renames EMITS.CUR_LEVEL;
          VALUE_PTR	: OFFSET_TYPE	:= - EMITS.OFFSET_ACT;
        begin
	DI( CD_COMP_UNIT, VC_NAME, CCU );
	DI( CD_LEVEL, VC_NAME, LVL );
	DI( CD_OFFSET, VC_NAME, VALUE_PTR );
	DB( CD_COMPILED, VC_NAME, TRUE );
	INC_OFFSET( ADDR_SIZE );
	ALIGN     ( ADDR_AL );
	DESCR_PTR := - EMITS.OFFSET_ACT;
	INC_OFFSET( ADDR_SIZE );
	if DB( CD_COMPILED, TYPE_SPEC ) then
	  GEN_PUSH_ADDR( DI( CD_COMP_UNIT, TYPE_SPEC ) , DI( CD_LEVEL, TYPE_SPEC ), DI( CD_OFFSET, TYPE_SPEC ) );
	  EMIT( DPL, A, "DUPLICATE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " ARRAY DESCRIPTOR TYPE_SPEC" );
	  GEN_STORE( A, CCU, LVL, DESCR_PTR, "STO ADRESSE DESCRIPTEUR" );
	  EMIT( IND, I, 0, "CHARGE INDEXE TAILLE TABLEAU DE DESCRIPTEUR" );
	  EMIT( ALO, INTEGER ( 0 ), COMMENT=> "ALLOC TABLEAU" );
	  GEN_STORE( A, EMITS.CUR_COMP_UNIT, EMITS.CUR_LEVEL, VALUE_PTR, "STO ADRESSE TABLEAU ALLOUE" );
	else
	  PUT_LINE( "!!! COMPILE_ARRAY_VAR : TYPE_SPEC NON COMPILE" );
	  raise PROGRAM_ERROR;
	end if;
        end;
      end	COMPILE_ARRAY_VAR;
	-----------------


		------------------
      procedure	COMPILE_RECORD_VAR		( VC_NAME, TYPE_SPEC :TREE )
      is
        INIT_EXP	: TREE	:= D( SM_INIT_EXP, VC_NAME );
      begin
        ALIGN( RECORD_AL );
        declare
	CCU	: COMP_UNIT_NBR	renames EMITS.CUR_COMP_UNIT;
	LVL	: LEVEL_TYPE	renames EMITS.CUR_LEVEL;
	OFS	: OFFSET_TYPE   := - EMITS.OFFSET_ACT;
        begin
	DI( CD_COMP_UNIT, VC_NAME, CCU );
	DI( CD_LEVEL,     VC_NAME, LVL );
	DI( CD_OFFSET,    VC_NAME, OFS );
          DB( CD_COMPILED,  VC_NAME, TRUE );
	if INIT_EXP.TY = DN_AGGREGATE then
	  declare
	    GENERAL_ASSOC_SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, INIT_EXP ) );
	    COMP_EXP		: TREE;
	  begin
	    while not IS_EMPTY( GENERAL_ASSOC_SEQ ) loop
	      POP( GENERAL_ASSOC_SEQ, COMP_EXP );
	      CODE_EXP( COMP_EXP );
	    end loop;
	  end;
	end if;
        end;
      end	COMPILE_RECORD_VAR;
	------------------


    begin
      case TYPE_SPEC.TY is
      when DN_ENUMERATION	  => COMPILE_VC_NAME_ENUMERATION( VC_NAME, TYPE_SPEC );
      when DN_INTEGER	  => COMPILE_VC_NAME_INTEGER(	    VC_NAME );
      when DN_ACCESS	  => COMPILE_ACCESS_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_RECORD	  => COMPILE_RECORD_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_CONSTRAINED_ARRAY => COMPILE_ARRAY_VAR(	    VC_NAME, TYPE_SPEC );
      when others =>
        PUT_LINE( "ERREUR CODE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end case;
    end;
  end	CODE_VC_NAME;
	------------



  --|-------------------------------------------------------------------------------------------
  procedure CODE_VARIABLE_ID ( VARIABLE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONSTANT_ID ( CONSTANT_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NUMBER_ID ( NUMBER_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SOURCE_NAME_S ( SOURCE_NAME_S :TREE ) is
  begin
    declare
      SOURCE_NAME_SEQ : SEQ_TYPE := LIST ( SOURCE_NAME_S );
      SOURCE_NAME : TREE;
    begin
      while not IS_EMPTY( SOURCE_NAME_SEQ ) loop
        POP( SOURCE_NAME_SEQ, SOURCE_NAME );
        CODE_SOURCE_NAME( SOURCE_NAME );
      end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TYPE_NAME ( TYPE_NAME :TREE ) is
  begin

    if TYPE_NAME.TY = DN_TYPE_ID then
      CODE_TYPE_ID ( TYPE_NAME );

    elsif TYPE_NAME.TY = DN_SUBTYPE_ID then
      CODE_SUBTYPE_ID ( TYPE_NAME );

    elsif TYPE_NAME.TY = DN_PRIVATE_TYPE_ID then
      CODE_PRIVATE_TYPE_ID ( TYPE_NAME );

    elsif TYPE_NAME.TY = DN_L_PRIVATE_TYPE_ID then
      CODE_L_PRIVATE_TYPE_ID ( TYPE_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TYPE_ID ( TYPE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBTYPE_ID ( SUBTYPE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_COMP_NAME ( COMP_NAME :TREE ) is
  begin

    if COMP_NAME.TY = DN_COMPONENT_ID then
      CODE_COMPONENT_ID ( COMP_NAME );

    elsif COMP_NAME.TY = DN_DISCRIMINANT_ID then
      CODE_DISCRIMINANT_ID ( COMP_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_COMPONENT_ID ( COMPONENT_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DISCRIMINANT_ID ( DISCRIMINANT_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NAME ( NAME :TREE ) is
  begin

    if NAME.TY in CLASS_DESIGNATOR then
      CODE_DESIGNATOR ( NAME );

    elsif NAME.TY in CLASS_NAME_EXP then
      CODE_NAME_EXP ( NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NAME_EXP ( NAME_EXP :TREE ) is
  begin

    if NAME_EXP.TY = DN_INDEXED then
      CODE_INDEXED ( NAME_EXP );

    elsif NAME_EXP.TY = DN_SLICE then
      CODE_SLICE ( NAME_EXP );

    elsif NAME_EXP.TY = DN_ALL then
      CODE_ALL ( NAME_EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DESIGNATOR ( DESIGNATOR :TREE ) is
  begin

    if DESIGNATOR.TY in CLASS_USED_OBJECT then
      CODE_USED_OBJECT ( DESIGNATOR );

    elsif DESIGNATOR.TY in CLASS_USED_NAME then
      CODE_USED_NAME ( DESIGNATOR );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USED_NAME ( USED_NAME :TREE ) is
  begin

    if USED_NAME.TY = DN_USED_OP then
      CODE_USED_OP ( USED_NAME );

    elsif USED_NAME.TY = DN_USED_NAME_ID then
      CODE_USED_NAME_ID ( USED_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USED_OP ( USED_OP :TREE ) is
  begin
    null;
  end;


		-----------------
  procedure	CODE_USED_NAME_ID		( USED_NAME_ID :TREE )
  is
  begin
    declare
      DEFN	: TREE	:= D( SM_DEFN,   USED_NAME_ID );
      SYMREP	: TREE	:= D( LX_SYMREP, USED_NAME_ID );
    begin
      if DEFN.TY = DN_EXCEPTION_ID then
        declare
	LABEL	: TREE := D( CD_LABEL, DEFN );
	LBL	: LABEL_TYPE;
        begin
	if LABEL.TY /= DN_NUM_VAL then
	  LBL := NEW_LABEL;
	  DI( CD_LABEL, DEFN, INTEGER( LBL ) );
	  EMIT( EXL, LBL, S=> PRINT_NAME( SYMREP ),
			COMMENT=> "NUM D EXCEPTION EXTERNE ATTRIBUE SUR USED_NAME_ID" );
	end if;
	EMIT( DPL, I,	COMMENT=> "CODE D EXCEPTION EMPILE" );
	EMIT( LDC, I, DI( CD_LABEL, DEFN ),
			COMMENT=> "EXCEPTION " & PRINT_NAME ( SYMREP ));
	EMIT( EQ, I );
        end;

      elsif DEFN.TY = DN_PACKAGE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PACKAGE_SPEC	: TREE	:= D( SM_SPEC, DEFN );
	begin
	  EMIT( RFP, EMITS.CUR_COMP_UNIT, S=> PRINT_NAME( SYMREP ) );
	  EMITS.GENERATE_CODE := FALSE;
	  DB( CD_COMPILED, DEFN, TRUE );
	  CODE_DECL_S( D( AS_DECL_S1, PACKAGE_SPEC ) );
	end;
        end if;
        EMITS.CUR_COMP_UNIT := CUR_COMP_UNIT + 1;

      elsif DEFN.TY = DN_PROCEDURE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PROC_LBL	: LABEL_TYPE	:= NEW_LABEL;
	begin
	  EMITS.GENERATE_CODE := TRUE;
	  EMIT( RFP, INTEGER( 0 ), S=> PRINT_NAME ( SYMREP ) );
	  DI  ( CD_LABEL,      DEFN, INTEGER ( PROC_LBL ) );
	  DI  ( CD_LEVEL,      DEFN, 1 );
	  DI  ( CD_PARAM_SIZE, DEFN, 0 );
	  DB  ( CD_COMPILED,   DEFN, TRUE );
	  EMIT( RFL, PROC_LBL );
	end;
        end if;
      end if;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USED_OBJECT ( USED_OBJECT :TREE ) is
  begin

    if USED_OBJECT.TY = DN_USED_CHAR then
      CODE_USED_CHAR ( USED_OBJECT );

    elsif USED_OBJECT.TY = DN_USED_OBJECT_ID then
      CODE_USED_OBJECT_ID ( USED_OBJECT );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USED_CHAR ( USED_CHAR :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_USED_OBJECT_ID ( USED_OBJECT_ID :TREE ) is
  begin
        null;
  end;



		------------
  procedure	CODE_INDEXED	( INDEXED :TREE )
  is
  begin
    declare

      procedure INDEX ( EXP_SEQ :SEQ_TYPE ) is
        EXP_S	: SEQ_TYPE	:= EXP_SEQ;
        EXP	: TREE;
      begin
        POP( EXP_S, EXP );
        CODE_EXP( EXP );
        if IS_EMPTY( EXP_S ) then
	EMIT ( AR2,		COMMENT => "ADRESSE POUR LE DERNIER INDICE (RAPIDE)" );
        else
	EMIT ( AR1,		COMMENT => "ADRESSE POUR INDICE INTERMEDIAIRE" );
	EMIT ( DEC, A, 3*INTG_SIZE,	COMMENT => "PTR DESCRIPTEUR AU TRIPLET INDICE SUIVANT" );
	INDEX( EXP_S );
	EMIT ( ADD, I,		COMMENT => "AJOUTER LE DECALAGE A L ADRESSE DES INDICES PRECEDENTS" );
        end if;
      end INDEX;

    begin
      CODE_OBJECT( D ( AS_NAME, INDEXED ) );
      EMIT( DPL, A,		  COMMENT => "DUP ADRESSE OBJET" );
      EMIT( IND, A, 0,	  COMMENT => "CHARGE INDEXE D ADRESSE TABLEAU" );
      EMIT( SWP, A,		  COMMENT => "ADRESSE OBJET AU TOP" );
      EMIT( IND, A, -ADDR_SIZE, COMMENT => "CHARGE INDEXE ADRESSE DU DESCRIPTEUR TABLEAU" );
      EMIT( DEC, A, INTG_SIZE,  COMMENT => "ADRESSE DESCRIPTEUR - TAILLE ENTIER" );
      declare
        EXP_SEQ	: SEQ_TYPE	:= LIST( D( AS_EXP_S, INDEXED ) );
      begin
        if not IS_EMPTY( EXP_SEQ ) then
	INDEX( EXP_SEQ );
        end if;
      end;
      EMIT( IXA, INTEGER( 1 ) );
    end;
  end	CODE_INDEXED;
	------------

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SLICE ( SLICE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALL ( ADA_ALL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_AGGREGATE ( AGGREGATE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SHORT_CIRCUIT ( SHORT_CIRCUIT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_MEMBERSHIP ( MEMBERSHIP :TREE ) is
  begin

    if MEMBERSHIP.TY = DN_RANGE_MEMBERSHIP then
      CODE_RANGE_MEMBERSHIP ( MEMBERSHIP );

    elsif MEMBERSHIP.TY = DN_TYPE_MEMBERSHIP then
      CODE_TYPE_MEMBERSHIP ( MEMBERSHIP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_RANGE_MEMBERSHIP ( RANGE_MEMBERSHIP :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TYPE_MEMBERSHIP ( TYPE_MEMBERSHIP :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXP ( EXP :TREE ) is
  begin

    if EXP.TY in CLASS_NAME then
      CODE_NAME( EXP );

    elsif EXP.TY in CLASS_EXP_EXP then
      CODE_EXP_EXP( EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXP_EXP ( EXP_EXP :TREE ) is
  begin

    if EXP_EXP.TY in CLASS_EXP_VAL then
      CODE_EXP_VAL ( EXP_EXP );

    elsif EXP_EXP.TY in CLASS_AGG_EXP then
      CODE_AGG_EXP ( EXP_EXP );

    elsif EXP_EXP.TY = DN_QUALIFIED_ALLOCATOR then
      CODE_QUALIFIED_ALLOCATOR ( EXP_EXP );

    elsif EXP_EXP.TY = DN_SUBTYPE_ALLOCATOR then
      CODE_SUBTYPE_ALLOCATOR ( EXP_EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXP_VAL ( EXP_VAL :TREE ) is
  begin

    if EXP_VAL.TY in CLASS_EXP_VAL_EXP then
      CODE_EXP_VAL_EXP( EXP_VAL );

    elsif EXP_VAL.TY = DN_NUMERIC_LITERAL then
      CODE_NUMERIC_LITERAL( EXP_VAL );

    elsif EXP_VAL.TY = DN_NULL_ACCESS then
      CODE_NULL_ACCESS( EXP_VAL );

    elsif EXP_VAL.TY = DN_SHORT_CIRCUIT then
      CODE_SHORT_CIRCUIT( EXP_VAL );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXP_VAL_EXP ( EXP_VAL_EXP :TREE ) is
  begin

    if EXP_VAL_EXP.TY in CLASS_QUAL_CONV then
      CODE_QUAL_CONV( EXP_VAL_EXP );

    elsif EXP_VAL_EXP.TY in CLASS_MEMBERSHIP then
      CODE_MEMBERSHIP( EXP_VAL_EXP );

    elsif EXP_VAL_EXP.TY = DN_PARENTHESIZED then
      CODE_PARENTHESIZED( EXP_VAL_EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_AGG_EXP ( AGG_EXP :TREE ) is
  begin

    if AGG_EXP.TY = DN_AGGREGATE then
      CODE_AGGREGATE( AGG_EXP );

    elsif AGG_EXP.TY = DN_STRING_LITERAL then
      CODE_STRING_LITERAL( AGG_EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PARENTHESIZED ( PARENTHESIZED :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NUMERIC_LITERAL ( NUMERIC_LITERAL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STRING_LITERAL ( STRING_LITERAL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NULL_ACCESS ( NULL_ACCESS :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_QUAL_CONV ( QUAL_CONV :TREE ) is
  begin

    if QUAL_CONV.TY = DN_CONVERSION then
      CODE_CONVERSION ( QUAL_CONV );

    elsif QUAL_CONV.TY = DN_QUALIFIED then
      CODE_QUALIFIED ( QUAL_CONV );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONVERSION ( CONVERSION :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_QUALIFIED ( QUALIFIED :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_QUALIFIED_ALLOCATOR ( QUALIFIED_ALLOCATOR :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBTYPE_ALLOCATOR ( SUBTYPE_ALLOCATOR :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_S ( STM_S :TREE ) is
  begin
    declare
      STM_SEQ : SEQ_TYPE := LIST ( STM_S );
      STM_ELEM : TREE;
    begin
      while not IS_EMPTY ( STM_SEQ ) loop
        POP ( STM_SEQ, STM_ELEM );
      CODE_STM_ELEM ( STM_ELEM );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_ELEM ( STM_ELEM :TREE ) is
  begin

    if STM_ELEM.TY in CLASS_STM then
      CODE_STM ( STM_ELEM );

    elsif STM_ELEM.TY = DN_STM_PRAGMA then
      CODE_STM_PRAGMA ( STM_ELEM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_PRAGMA ( STM_PRAGMA :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM ( STM :TREE ) is
  begin

    if STM.TY = DN_LABELED then
      CODE_LABELED ( STM );

    elsif STM.TY = DN_NULL_STM then
      CODE_NULL_STM ( STM );

    elsif STM.TY = DN_ACCEPT then
      CODE_ACCEPT ( STM );

    elsif STM.TY = DN_TERMINATE then
      CODE_TERMINATE ( STM );

    elsif STM.TY = DN_ABORT then
      CODE_ABORT ( STM );

    elsif STM.TY in CLASS_CLAUSES_STM then
      CODE_CLAUSES_STM ( STM );

    elsif STM.TY in CLASS_BLOCK_LOOP then
      CODE_BLOCK_LOOP ( STM );

    elsif STM.TY in CLASS_ENTRY_STM then
      CODE_ENTRY_STM ( STM );

    elsif STM.TY in CLASS_STM_WITH_NAME then
      CODE_STM_WITH_NAME ( STM );

    elsif STM.TY in CLASS_STM_WITH_EXP then
      CODE_STM_WITH_EXP ( STM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_LABELED ( LABELED :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_WITH_EXP ( STM_WITH_EXP :TREE ) is
  begin

    if STM_WITH_EXP.TY = DN_RETURN then
      CODE_RETURN ( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY = DN_DELAY then
      CODE_DELAY ( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY = DN_CASE then
      CODE_CASE ( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY in CLASS_STM_WITH_EXP_NAME then
      CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP_NAME :TREE ) is
  begin

    if STM_WITH_EXP_NAME.TY = DN_CODE then
      CODE_CODE ( STM_WITH_EXP_NAME );

    elsif STM_WITH_EXP_NAME.TY = DN_ASSIGN then
      CODE_ASSIGN ( STM_WITH_EXP_NAME );

    elsif STM_WITH_EXP_NAME.TY = DN_EXIT then
      CODE_EXIT ( STM_WITH_EXP_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_STM_WITH_NAME ( STM_WITH_NAME :TREE ) is
  begin

    if STM_WITH_NAME.TY = DN_GOTO then
      CODE_GOTO ( STM_WITH_NAME );

    elsif STM_WITH_NAME.TY = DN_RAISE then
      CODE_RAISE ( STM_WITH_NAME );

    elsif STM_WITH_NAME.TY in CLASS_CALL_STM then
      CODE_CALL_STM ( STM_WITH_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CALL_STM ( CALL_STM :TREE ) is
  begin

    if CALL_STM.TY = DN_PROCEDURE_CALL then
      CODE_PROCEDURE_CALL ( CALL_STM );

    elsif CALL_STM.TY = DN_ENTRY_CALL then
      CODE_ENTRY_CALL ( CALL_STM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CLAUSES_STM ( CLAUSES_STM :TREE ) is
  begin

    if CLAUSES_STM.TY = DN_IF then
      CODE_IF ( CLAUSES_STM );

    elsif CLAUSES_STM.TY = DN_SELECTIVE_WAIT then
      CODE_SELECTIVE_WAIT ( CLAUSES_STM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_LABEL_NAME ( LABEL_NAME :TREE ) is
  begin

    if LABEL_NAME.TY = DN_LABEL_ID then
      CODE_LABEL_ID ( LABEL_NAME );

    elsif LABEL_NAME.TY = DN_BLOCK_LOOP_ID then
      CODE_BLOCK_LOOP_ID ( LABEL_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_LABEL_ID ( LABEL_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NULL_STM ( NULL_STM :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OBJECT ( OBJECT :TREE ) is
  begin
      case OBJECT.TY is
       when DN_VARIABLE_ID =>
          GEN_PUSH_ADDR ( DI (CD_COMP_UNIT, OBJECT ), DI ( CD_LEVEL, OBJECT ), DI ( CD_OFFSET, OBJECT ),
                      "EMPILE ADRESSE DE VARIABLE" );
       when DN_IN_ID =>
         EMIT ( PLA, CUR_LEVEL - DI ( CD_LEVEL, OBJECT ), DI ( CD_OFFSET, OBJECT ),
                      "EMPILE ADRESSE DE PARAM IN" );
       when DN_IN_OUT_ID | DN_OUT_ID =>
         EMIT ( PLA, CUR_LEVEL - DI ( CD_LEVEL, OBJECT ), DI ( CD_VAL_OFFSET, OBJECT ),
                      "EMPILE ADRESSE PARAM IN_OUT/OUT" );
       when DN_INDEXED =>
         CODE_INDEXED ( OBJECT );
       when DN_USED_OBJECT_ID =>
         CODE_OBJECT ( D ( SM_DEFN, OBJECT ) );
       when others =>
         PUT_LINE ( "!!! LOAD_OBJECT_ADDRESS : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( OBJECT.TY ) );
         raise PROGRAM_ERROR;
      end case;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ADRESSE ( ADRESSE :TREE ) is
  begin
    case ADRESSE.TY is
    when DN_VARIABLE_ID =>
      GEN_PUSH_DATA ( A, DI (CD_COMP_UNIT, ADRESSE ), DI ( CD_LEVEL, ADRESSE ), DI ( CD_OFFSET, ADRESSE ) );
    when DN_IN_ID =>
      GEN_PUSH_DATA ( A, 0,  DI ( CD_LEVEL, ADRESSE ), DI ( CD_OFFSET, ADRESSE ) );
    when DN_IN_OUT_ID | DN_OUT_ID =>
      GEN_PUSH_DATA ( A, 0, DI ( CD_LEVEL, ADRESSE ), DI ( CD_VAL_OFFSET, ADRESSE ) );
    when DN_INDEXED =>
      CODE_INDEXED ( ADRESSE );
    when DN_USED_OBJECT_ID =>
      CODE_ADRESSE ( D ( SM_DEFN, ADRESSE ) );
    when others =>
    PUT_LINE ( "!!! CODE_ADRESSE : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( ADRESSE.TY ) );
      raise PROGRAM_ERROR;
    end case;
  end;



				-----------
  procedure			CODE_ASSIGN		( ASSIGN :TREE )
  is
  begin
    declare
      NAME	: TREE	:= D ( AS_NAME, ASSIGN );

		--------
      procedure	STORE_VAL		( TYPE_SPEC :TREE )
      is
      begin
        case TYPE_SPEC.TY is
        when DN_ACCESS =>
          EMIT ( STO, A );
        when DN_ENUMERATION =>
          declare
            TYPE_SOURCE_NAME : TREE            := D ( XD_SOURCE_NAME, TYPE_SPEC );
            TYPE_SYMREP      : TREE            := D ( LX_SYMREP, TYPE_SOURCE_NAME );
            NAME             : constant STRING := PRINT_NAME ( TYPE_SYMREP );
          begin
            if NAME = "BOOLEAN" then EMIT ( STO, B );
            elsif NAME = "CHARACTER" then EMIT ( STO, C );
            else EMIT ( STO, I );
            end if;
          end;
        when DN_INTEGER =>
          EMIT ( STO, I );
        when DN_UNIVERSAL_INTEGER =>
          declare
            COMP_UNIT : COMP_UNIT_NBR := DI ( CD_COMP_UNIT, TYPE_SPEC );
            LVL       : LEVEL_TYPE    := DI ( CD_LEVEL, TYPE_SPEC );
            OFS       : INTEGER       := DI ( CD_OFFSET, TYPE_SPEC );
          begin
            GEN_PUSH_ADDR( COMP_UNIT, LVL, OFS );
            EMIT( CVB );
            EMIT( STO, I );
          end;
        when others =>
          PUT_LINE ( "!!! STORE_VAL TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end	STORE_VAL;
	---------

    begin

      if NAME.TY = DN_ALL then
        CODE_ADRESSE( D( AS_NAME,     NAME ) );
        CODE_EXP    ( D( AS_EXP,      ASSIGN ) );
        STORE_VAL   ( D( SM_EXP_TYPE, NAME ) );

      elsif NAME.TY = DN_INDEXED then
        CODE_INDEXED( NAME );
        CODE_EXP    ( D( AS_EXP, ASSIGN ) );
        STORE_VAL   ( D( SM_EXP_TYPE, NAME ) );


      elsif NAME.TY = DN_USED_OBJECT_ID then

        declare
	NAMEXP	: TREE		:= D( SM_EXP_TYPE, NAME );
	DEFN	: TREE		:= D( SM_DEFN, NAME );
	COMP_UNIT	: COMP_UNIT_NBR;
	LVL	: LEVEL_TYPE;
	OFS	: OFFSET_TYPE;
        begin

          if NAMEXP.TY = DN_ACCESS then
	  CODE_EXP( D( AS_EXP, ASSIGN ) );
	  EMITS.GET_ULO  ( DEFN, COMP_UNIT, LVL, OFS );
	  EMITS.GEN_STORE( A, COMP_UNIT, LVL, OFS );

	elsif NAMEXP.TY = DN_ARRAY then
	  CODE_OBJECT( DEFN );
	  declare
	    EXP	: TREE	:= D( AS_EXP, ASSIGN );
	  begin
	    if EXP.TY = DN_USED_OBJECT_ID then
	      CODE_OBJECT( D( SM_DEFN, EXP ) );
	      CODE_OBJECT( EXP );
	      EMIT( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
	      EMIT( CYA );
	    else
	      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
	      EMIT( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
	      EMIT( PUA );
              end if;
            end;

	elsif NAMEXP.TY = DN_ENUMERATION then
	  CODE_EXP ( D ( AS_EXP, ASSIGN ) );
	  EMITS.GET_ULO ( DEFN, COMP_UNIT, LVL, OFS );
	  declare
	    CT	: CODE_DATA_TYPE	:= CODE_DATA_TYPE_OF( NAMEXP );
	  begin
	    GEN_STORE ( CT, COMP_UNIT, LVL, OFS );
	  end;

	elsif NAMEXP.TY = DN_INTEGER then
	  CODE_EXP( D( AS_EXP, ASSIGN ) );
	  if NAMEXP.TY /= DN_UNIVERSAL_INTEGER then
	    EMITS.GET_ULO( DEFN, COMP_UNIT, LVL, OFS );
	    GEN_PUSH_ADDR( COMP_UNIT, LVL, OFS );
	    EMIT( CVB );
	  end if;
	  EMITS.GET_ULO  ( DEFN, COMP_UNIT, LVL, OFS );
            EMITS.GEN_STORE( I,    COMP_UNIT, LVL, OFS );
          end if;

        end;
      end if;
    end;
  end	CODE_ASSIGN;
	-----------



  --|-------------------------------------------------------------------------------------------
  procedure CODE_IF ( ADA_IF :TREE ) is
  begin
    declare
      OLD_AFTER_IF_LBL : LABEL_TYPE := EMITS.AFTER_IF_LBL;
    begin
      EMITS.AFTER_IF_LBL := NEW_LABEL;
      CODE_TEST_CLAUSE_ELEM_S ( D ( AS_TEST_CLAUSE_ELEM_S, ADA_IF ) );
      WRITE_LABEL ( EMITS.AFTER_IF_LBL, COMMENT=> "ETIQUETTE END IF" );
      EMITS.AFTER_IF_LBL := OLD_AFTER_IF_LBL;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE ) is
  begin

    if TEST_CLAUSE.TY = DN_COND_CLAUSE then
      CODE_COND_CLAUSE ( TEST_CLAUSE );

    elsif TEST_CLAUSE.TY = DN_SELECT_ALTERNATIVE then
      CODE_SELECT_ALTERNATIVE ( TEST_CLAUSE );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE ) is
  begin
    declare
      EXP : TREE := D ( AS_EXP, COND_CLAUSE );
      NEXT_CLAUSE_LBL : LABEL_TYPE;
    begin
      CODE_EXP ( EXP );
      NEXT_CLAUSE_LBL := NEW_LABEL;
      EMIT ( JMPF, NEXT_CLAUSE_LBL, COMMENT=> "NON CONDITION SAUT CLAUSE SUIVANTE" );
      CODE_STM_S ( D ( AS_STM_S, COND_CLAUSE ) );
      EMIT ( JMP, EMITS.AFTER_IF_LBL, COMMENT=> "SAUT END IF" );
      WRITE_LABEL ( NEXT_CLAUSE_LBL, COMMENT=> "LBL CONDITION SUIVANTE" );
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CASE ( ADA_CASE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BLOCK_LOOP ( BLOCK_LOOP :TREE ) is
  begin

    if BLOCK_LOOP.TY = DN_LOOP then
      CODE_LOOP ( BLOCK_LOOP );

    elsif BLOCK_LOOP.TY = DN_BLOCK then
      CODE_BLOCK ( BLOCK_LOOP );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ITERATION ( ITERATION :TREE ) is
  begin

    if ITERATION.TY in CLASS_FOR_REV then
      CODE_FOR_REV ( ITERATION );

    elsif ITERATION.TY = DN_WHILE then
      CODE_WHILE ( ITERATION );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_LOOP ( ADA_LOOP :TREE ) is
  begin
    declare
      OLD_LOOP_STM_S          : TREE := EMITS.LOOP_STM_S;
      OLD_BEFORE_LOOP_LBL : LABEL_TYPE := EMITS.BEFORE_LOOP_LBL;
      OLD_AFTER_LOOP_LBL  : LABEL_TYPE := EMITS.AFTER_LOOP_LBL;
    begin
      LOOP_STM_S := D ( AS_STM_S, ADA_LOOP );
      EMITS.BEFORE_LOOP_LBL := NEW_LABEL;
      EMITS.AFTER_LOOP_LBL := NEW_LABEL;
      DI ( CD_AFTER_LOOP, ADA_LOOP, INTEGER( AFTER_LOOP_LBL) );
      DI ( CD_LEVEL, ADA_LOOP, EMITS.CUR_LEVEL );
      declare
        ITERATION : TREE := D ( AS_ITERATION, ADA_LOOP );
      begin
        if ITERATION = TREE_VOID then
          WRITE_LABEL ( BEFORE_LOOP_LBL );
      CODE_STM_S ( LOOP_STM_S );
          EMIT ( JMP, BEFORE_LOOP_LBL );
        else
      CODE_ITERATION ( D ( AS_ITERATION, ADA_LOOP ) );
        end if;
      end;
      WRITE_LABEL ( AFTER_LOOP_LBL );
      EMITS.BEFORE_LOOP_LBL := OLD_BEFORE_LOOP_LBL;
      EMITS.AFTER_LOOP_LBL := OLD_AFTER_LOOP_LBL;
      EMITS.LOOP_STM_S := OLD_LOOP_STM_S;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FOR_REV ( FOR_REV :TREE ) is
  begin
    declare
      OLD_LOOP_OP_INC_DEC   : OP_CODE      := EMITS.LOOP_OP_INC_DEC;
      OLD_LOOP_OP_GT_LT     : OP_CODE      := EMITS.LOOP_OP_GT_LT;
      COUNTER, TEMP         : INTEGER;
      OLD_OFFSET_ACT        : OFFSET_TYPE  := EMITS.OFFSET_ACT;
      ITERATION_ID          : TREE         := D ( AS_SOURCE_NAME, FOR_REV );
      ACT                   : CODE_DATA_TYPE    := EMITS.CODE_DATA_TYPE_OF ( D ( SM_OBJ_TYPE, ITERATION_ID ) );
      procedure LOAD_DSCRT_RANGE ( DSCRT_RANGE : TREE ) is
      begin
        null;
      end;
    begin
      EMITS.BEFORE_LOOP_LBL := NEW_LABEL;
      EMITS.AFTER_LOOP_LBL := NEW_LABEL;

    if FOR_REV.TY = DN_FOR then
      CODE_FOR ( FOR_REV );

    elsif FOR_REV.TY = DN_REVERSE then
      CODE_REVERSE ( FOR_REV );

    end if;
      case ACT is
      when B =>
        ALIGN ( BOOL_AL );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( BOOL_SIZE);
        ALIGN ( BOOL_AL);
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( BOOL_SIZE );
      when C =>
        ALIGN ( CHAR_AL );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( CHAR_SIZE );
        ALIGN ( CHAR_AL);
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( CHAR_SIZE );
      when I =>
        ALIGN ( INTG_AL );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
        ALIGN ( INTG_AL );
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
      when A =>
        PUT_LINE ( "!!! COMPILE_STM_LOOP_REVERSE ACT ILLICITE " & CODE_DATA_TYPE'IMAGE ( ACT ) );
        raise PROGRAM_ERROR;
      end case;
      DI ( CD_LEVEL, ITERATION_ID, EMITS.CUR_LEVEL );
      DI ( CD_OFFSET, ITERATION_ID, COUNTER );
      LOAD_DSCRT_RANGE ( D ( AS_DISCRETE_RANGE, FOR_REV ) );
      EMIT ( SLD, ACT, 0, TEMP );
      WRITE_LABEL ( EMITS.BEFORE_LOOP_LBL );
      EMIT ( SLD, ACT, 0, COUNTER );
      EMIT ( PLD, ACT, 0, COUNTER );
      EMIT ( PLD, ACT, 0, TEMP );
      EMIT ( EMITS.LOOP_OP_GT_LT, ACT );
      EMIT ( JMPT, EMITS.AFTER_LOOP_LBL );
      CODE_STM_S ( LOOP_STM_S );
      EMIT ( PLD, ACT, 0, COUNTER );
      EMIT ( EMITS.LOOP_OP_INC_DEC, ACT, 1 );
      EMIT ( JMP, EMITS.BEFORE_LOOP_LBL );
      WRITE_LABEL ( EMITS.AFTER_LOOP_LBL );
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
      EMITS.LOOP_OP_INC_DEC := OLD_LOOP_OP_INC_DEC;
      EMITS.LOOP_OP_GT_LT := OLD_LOOP_OP_GT_LT;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FOR ( ADA_FOR :TREE ) is
  begin
    LOOP_OP_INC_DEC := INC;
    LOOP_OP_GT_LT := GT;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_REVERSE ( ADA_REVERSE :TREE ) is
  begin
    LOOP_OP_INC_DEC := DEC;
    LOOP_OP_GT_LT := LT;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ITERATION_ID ( ITERATION_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_WHILE ( ADA_WHILE :TREE ) is
  begin
    BEFORE_LOOP_LBL := NEW_LABEL;
    AFTER_LOOP_LBL := NEW_LABEL;
    WRITE_LABEL ( BEFORE_LOOP_LBL );
      CODE_EXP ( D ( AS_EXP, ADA_WHILE ) );
    EMIT ( JMPF, AFTER_LOOP_LBL );
      CODE_STM_S ( LOOP_STM_S );
    EMIT ( JMP, BEFORE_LOOP_LBL );
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_BLOCK ( BLOCK :TREE ) is
  begin
    declare
      AFTER_BLOCK_LBL : LABEL_TYPE := NEW_LABEL;
      PROC_LBL        : LABEL_TYPE := NEW_LABEL;
    begin
      EMIT ( MST, INTEGER ( 0 ), INTEGER( 0 ), COMMENT=> "POUR BLOC" );
      EMIT ( CALL, EMITS.RELATIVE_RESULT_OFFSET, PROC_LBL,
             COMMENT=> "APPEL DE BLOC" );
      EMIT ( JMP, AFTER_BLOCK_LBL, COMMENT=> "SAUT POST BLOC" );
      WRITE_LABEL ( PROC_LBL);
      declare
        OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
        OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
      begin
        EMITS.OFFSET_ACT := FIRST_LOCAL_VAR_OFFSET;
        EMITS.OFFSET_MAX := FIRST_LOCAL_VAR_OFFSET;
        INC_LEVEL;
      CODE_BLOCK_BODY ( D ( AS_BLOCK_BODY, BLOCK ) );
        DEC_LEVEL;
        EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
        EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      end;
      WRITE_LABEL ( AFTER_BLOCK_LBL );
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXIT ( ADA_EXIT :TREE ) is
  begin
    declare
      LVB_LBL          : LABEL_TYPE;
      EXP              : TREE := D ( AS_EXP, ADA_EXIT );
      LOOP_STM         : TREE := D ( SM_STM, ADA_EXIT );
      LOOP_LEVEL       : LEVEL_TYPE := DI ( CD_LEVEL, LOOP_STM );
      AFTER_LOOP_LABEL : LABEL_TYPE := LABEL_TYPE( DI( CD_AFTER_LOOP, LOOP_STM ) );
    begin
      if EXP = TREE_VOID then
        if LOOP_LEVEL /= EMITS.CUR_LEVEL then
             LVB_LBL := NEW_LABEL;
             EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
             GEN_LBL_ASSIGNMENT ( LVB_LBL, EMITS.CUR_LEVEL - LOOP_LEVEL );
        end if;
        EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
      else
      CODE_EXP ( EXP );
        if LOOP_LEVEL /= EMITS.CUR_LEVEL then
          declare
            SKIP_LBL : LABEL_TYPE := NEW_LABEL;
          begin
            EMIT ( JMPF, SKIP_LBL, COMMENT=> "PAS D EXIT SI CONDITION FAUSSE" );
            LVB_LBL := NEW_LABEL;
            EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
            GEN_LBL_ASSIGNMENT ( LVB_LBL, EMITS.CUR_LEVEL - LOOP_LEVEL );
            EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
            WRITE_LABEL ( SKIP_LBL, COMMENT=> "LABEL NO EXIT" );
          end;
        else
          EMIT ( JMPT, AFTER_LOOP_LABEL );
        end if;
      end if;
    end;
  end;


				-----------
  procedure			CODE_RETURN		( ADA_RETURN :TREE )
  is
  begin
    declare
      EXP : TREE := D ( AS_EXP, ADA_RETURN );
    begin
      if EXP /= TREE_VOID then
    STORE_FUNCTION_RESULT:
        declare
          ENCLOSING_LEVEL : INTEGER := DI ( CD_LEVEL, EMITS.ENCLOSING_BODY );
          RESULT_OFFSET : INTEGER := DI ( CD_RESULT_OFFSET, EMITS.ENCLOSING_BODY );
          EXPR_TYPE     : TREE := D ( SM_EXP_TYPE, EXP );
        begin
          if EXPR_TYPE.TY = DN_ARRAY then
            EMIT( PLA, EMITS.CUR_LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
            CODE_EXP( EXP );
            EMIT( LDC, I, EMITS.NUMBER_OF_DIMENSIONS ( EXP ) );
            EMIT( PUA );
          elsif EXPR_TYPE.TY = DN_ENUM_LITERAL_S then
            CODE_EXP ( EXP );
            EMIT( SLD, EMITS.CODE_DATA_TYPE_OF ( EXP ), EMITS.CUR_LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
	elsif EXPR_TYPE.TY = DN_INTEGER then
	  CODE_EXP ( EXP );
            EMIT( SLD, I, EMITS.CUR_LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
          end if;
        end STORE_FUNCTION_RESULT;
      end if;
      EMITS.PERFORM_RETURN ( EMITS.ENCLOSING_BODY );
    end;

  end	CODE_RETURN;
	-----------



  --|-------------------------------------------------------------------------------------------
  procedure CODE_GOTO ( ADA_GOTO :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NON_TASK_NAME ( NON_TASK_NAME :TREE ) is
  begin

    if NON_TASK_NAME.TY = DN_GENERIC_ID then
      CODE_GENERIC_ID ( NON_TASK_NAME );

    elsif NON_TASK_NAME.TY in CLASS_SUBPROG_PACK_NAME then
      CODE_SUBPROG_PACK_NAME ( NON_TASK_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :TREE ) is
  begin

    if SUBPROG_PACK_NAME.TY = DN_PACKAGE_ID then
      CODE_PACKAGE_ID ( SUBPROG_PACK_NAME );

    elsif SUBPROG_PACK_NAME.TY in CLASS_SUBPROG_NAME then
      CODE_SUBPROG_NAME ( SUBPROG_PACK_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SUBPROG_NAME ( SUBPROG_NAME :TREE ) is
  begin

    if SUBPROG_NAME.TY = DN_PROCEDURE_ID then
      CODE_PROCEDURE_ID ( SUBPROG_NAME );

    elsif SUBPROG_NAME.TY = DN_FUNCTION_ID then
      CODE_FUNCTION_ID ( SUBPROG_NAME );

    elsif SUBPROG_NAME.TY = DN_OPERATOR_ID then
      CODE_OPERATOR_ID ( SUBPROG_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PROCEDURE_ID ( PROCEDURE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FUNCTION_ID ( FUNCTION_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OPERATOR_ID ( OPERATOR_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_INIT_OBJECT_NAME ( INIT_OBJECT_NAME :TREE ) is
  begin

    if INIT_OBJECT_NAME.TY = DN_NUMBER_ID then
      CODE_NUMBER_ID ( INIT_OBJECT_NAME );

    elsif INIT_OBJECT_NAME.TY in CLASS_VC_NAME then
      CODE_VC_NAME ( INIT_OBJECT_NAME );

    elsif INIT_OBJECT_NAME.TY in CLASS_COMP_NAME then
      CODE_COMP_NAME ( INIT_OBJECT_NAME );

    elsif INIT_OBJECT_NAME.TY in CLASS_PARAM_NAME then
      CODE_PARAM_NAME ( INIT_OBJECT_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PARAM_NAME ( PARAM_NAME :TREE ) is
  begin

    if PARAM_NAME.TY = DN_IN_ID then
      CODE_IN_ID ( PARAM_NAME );

    elsif PARAM_NAME.TY in CLASS_PARAM_IO_O then
      CODE_PARAM_IO_O ( PARAM_NAME );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PARAM_IO_O ( PARAM_IO_O :TREE ) is
  begin

    if PARAM_IO_O.TY = DN_IN_OUT_ID then
      CODE_IN_OUT_ID ( PARAM_IO_O );

    elsif PARAM_IO_O.TY = DN_OUT_ID then
      CODE_OUT_ID ( PARAM_IO_O );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_ID ( IN_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_OUT_ID ( IN_OUT_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OUT_ID ( OUT_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PROCEDURE_CALL ( PROCEDURE_CALL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_FUNCTION_CALL ( FUNCTION_CALL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PACKAGE_ID ( PACKAGE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_PRIVATE_TYPE_ID ( PRIVATE_TYPE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_L_PRIVATE_TYPE_ID ( L_PRIVATE_TYPE_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TASK_BODY_ID ( TASK_BODY_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENTRY_ID ( ENTRY_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENTRY_CALL ( ENTRY_CALL :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ACCEPT ( ADA_ACCEPT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_DELAY ( ADA_DELAY :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SELECTIVE_WAIT ( SELECTIVE_WAIT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE ) is
  begin

    if TEST_CLAUSE_ELEM.TY in CLASS_TEST_CLAUSE then
      CODE_TEST_CLAUSE ( TEST_CLAUSE_ELEM );

    elsif TEST_CLAUSE_ELEM.TY = DN_SELECT_ALT_PRAGMA then
      CODE_SELECT_ALT_PRAGMA ( TEST_CLAUSE_ELEM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TEST_CLAUSE_ELEM_S ( TEST_CLAUSE_ELEM_S :TREE ) is
  begin
    declare
      TEST_CLAUSE_ELEM_SEQ : SEQ_TYPE := LIST ( TEST_CLAUSE_ELEM_S );
      TEST_CLAUSE_ELEM : TREE;
    begin
      while not IS_EMPTY ( TEST_CLAUSE_ELEM_SEQ ) loop
        POP ( TEST_CLAUSE_ELEM_SEQ, TEST_CLAUSE_ELEM );
      CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SELECT_ALTERNATIVE ( SELECT_ALTERNATIVE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_SELECT_ALT_PRAGMA ( SELECT_ALT_PRAGMA :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TERMINATE ( ADA_TERMINATE :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ENTRY_STM ( ENTRY_STM :TREE ) is
  begin

    if ENTRY_STM.TY = DN_COND_ENTRY then
      CODE_COND_ENTRY ( ENTRY_STM );

    elsif ENTRY_STM.TY = DN_TIMED_ENTRY then
      CODE_TIMED_ENTRY ( ENTRY_STM );

    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_COND_ENTRY ( COND_ENTRY :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_TIMED_ENTRY ( TIMED_ENTRY :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_NAME_S ( NAME_S :TREE ) is
  begin
    declare
      NAME_SEQ : SEQ_TYPE := LIST ( NAME_S );
      NAME : TREE;
    begin
      while not IS_EMPTY ( NAME_SEQ ) loop
        POP ( NAME_SEQ, NAME );
      CODE_NAME ( NAME );
    end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ABORT ( ADA_ABORT :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_EXCEPTION_ID ( EXCEPTION_ID :TREE ) is
  begin
    declare
      LBL : LABEL_TYPE := NEW_LABEL;
    begin
      DI ( CD_LABEL, EXCEPTION_ID, INTEGER ( LBL ) );
      EMIT ( EXL, LBL, S=> PRINT_NAME ( D ( LX_SYMREP, EXCEPTION_ID ) ),
             COMMENT=> "NUMERO D EXCEPTION SUR DECLARATION" );
    end;
  end;


		----------
  procedure	CODE_RAISE ( ADA_RAISE :TREE ) is
  begin
    declare
      NAME	: TREE	:= D( AS_NAME, ADA_RAISE );
    begin
      if NAME = TREE_VOID then
        EMIT( RAI );
      else
        declare
	EXCEPTION_ID	: TREE		:= D( SM_DEFN, NAME );
	LBL		: LABEL_TYPE;
        begin
	if D( CD_LABEL, EXCEPTION_ID ).TY /= DN_NUM_VAL then
	  LBL := NEW_LABEL;
	  DI  ( CD_LABEL, EXCEPTION_ID, INTEGER( LBL ) );
	  EMIT( EXL, LBL, S=> PRINT_NAME( D( LX_SYMREP, NAME ) ),
				COMMENT=> "NUMERO D EXCEPTION EXTERNE SUR RAISE" );
	end if;
          EMIT( RAI, DI( CD_LABEL, EXCEPTION_ID ) );
        end;
      end if;
    end;
  end	CODE_RAISE;
	----------



  --|-------------------------------------------------------------------------------------------
  procedure CODE_GENERIC_ID ( GENERIC_ID :TREE ) is
  begin
    null;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_CODE ( CODE :TREE ) is
  begin
    null;
  end;

begin
  OPEN_IDL_TREE_FILE( LIB_PATH(1..LIB_PATH_LENGTH) & "$$$.TMP" );
  if DI( XD_ERR_COUNT, TREE_ROOT ) = 0 then

    CODE_ROOT( TREE_ROOT );

  end if;
  CLOSE_IDL_TREE_FILE;

	--------
end	CODE_GEN;
	--------