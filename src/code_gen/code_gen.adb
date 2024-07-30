with EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
use  EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
with CODAGE_INTERMEDIAIRE;
use  CODAGE_INTERMEDIAIRE;
					--------
			procedure		CODE_GEN
					--------
is

  procedure CODE_ROOT ( ROOT :TREE );
  procedure CODE_CONTEXT_PRAGMA ( CONTEXT_PRAGMA :TREE );
--  procedure CODE_ALL_DECL ( ALL_DECL :TREE );
  procedure CODE_BLOCK_MASTER ( BLOCK_MASTER :TREE );
  procedure CODE_TASK_BODY ( TASK_BODY :TREE );
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
--  procedure CODE_UNIT_DESC ( UNIT_DESC :TREE );
  procedure CODE_DERIVED_SUBPROG ( DERIVED_SUBPROG :TREE );
  procedure CODE_IMPLICIT_NOT_EQ ( IMPLICIT_NOT_EQ :TREE );
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
  procedure CODE_LABEL_NAME ( LABEL_NAME :TREE );
  procedure CODE_LABEL_ID ( LABEL_ID :TREE );
  procedure CODE_OBJECT ( OBJECT :TREE );
  procedure CODE_ADRESSE ( ADRESSE :TREE );
  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE );
  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE );
  procedure CODE_ITERATION_ID ( ITERATION_ID :TREE );
  procedure CODE_NON_TASK_NAME ( NON_TASK_NAME :TREE );
  procedure CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :TREE );
  procedure CODE_SUBPROG_NAME ( SUBPROG_NAME :TREE );
  procedure CODE_PROCEDURE_ID ( PROCEDURE_ID :TREE );
  procedure CODE_FUNCTION_ID ( FUNCTION_ID :TREE );
  procedure CODE_OPERATOR_ID ( OPERATOR_ID :TREE );
  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE );
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
  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE );
  procedure CODE_TEST_CLAUSE_ELEM_S ( TEST_CLAUSE_ELEM_S :TREE );
  procedure CODE_SELECT_ALTERNATIVE ( SELECT_ALTERNATIVE :TREE );
  procedure CODE_SELECT_ALT_PRAGMA ( SELECT_ALT_PRAGMA :TREE );
  procedure CODE_NAME_S ( NAME_S :TREE );
  procedure CODE_EXCEPTION_ID ( EXCEPTION_ID :TREE );
  procedure CODE_GENERIC_ID ( GENERIC_ID :TREE );
  --|-------------------------------------------------------------------------------------------



				-----------
 	package			EXPRESSIONS
				-----------
  is

    procedure CODE_EXP		( EXP :TREE );
    procedure CODE_INDEXED		( INDEXED :TREE );
    procedure CODE_NAME		( NAME :TREE );


  private

    procedure CODE_EXP_EXP		( EXP_EXP :TREE );
    procedure CODE_DESIGNATOR		( DESIGNATOR :TREE );
    procedure CODE_NAME_EXP		( NAME_EXP :TREE );
    procedure CODE_USED_NAME		( USED_NAME :TREE );
    procedure CODE_USED_OP		( USED_OP :TREE );
    procedure CODE_USED_NAME_ID	( USED_NAME_ID :TREE );
    procedure CODE_USED_OBJECT	( USED_OBJECT :TREE );
    procedure CODE_USED_CHAR		( USED_CHAR :TREE );
    procedure CODE_USED_OBJECT_ID	( USED_OBJECT_ID :TREE );
    procedure CODE_SLICE		( SLICE :TREE );
    procedure CODE_ALL		( ADA_ALL :TREE );
    procedure CODE_AGGREGATE		( AGGREGATE :TREE );
    procedure CODE_SHORT_CIRCUIT	( SHORT_CIRCUIT :TREE );
    procedure CODE_MEMBERSHIP		( MEMBERSHIP :TREE );
    procedure CODE_RANGE_MEMBERSHIP	( RANGE_MEMBERSHIP :TREE );
    procedure CODE_TYPE_MEMBERSHIP	( TYPE_MEMBERSHIP :TREE );
    procedure CODE_EXP_VAL		( EXP_VAL :TREE );
    procedure CODE_EXP_VAL_EXP	( EXP_VAL_EXP :TREE );
    procedure CODE_AGG_EXP		( AGG_EXP :TREE );
    procedure CODE_PARENTHESIZED	( PARENTHESIZED :TREE );
    procedure CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL :TREE );
    procedure CODE_STRING_LITERAL	( STRING_LITERAL :TREE );
    procedure CODE_NULL_ACCESS	( NULL_ACCESS :TREE );
    procedure CODE_QUAL_CONV		( QUAL_CONV :TREE );
    procedure CODE_CONVERSION		( CONVERSION :TREE );
    procedure CODE_QUALIFIED		( QUALIFIED :TREE );
    procedure CODE_QUALIFIED_ALLOCATOR	( QUALIFIED_ALLOCATOR :TREE );
    procedure CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR :TREE );

	-----------
  end	EXPRESSIONS;
	-----------




				------------
 	package			DECLARATIONS
				------------
  is

    procedure CODE_HEADER		( HEADER :TREE );
    procedure CODE_DECL_S		( DECL_S :TREE );
    procedure CODE_DECL		( DECL :TREE );
    procedure CODE_PACKAGE_DECL	( PACKAGE_DECL :TREE );
    procedure CODE_PACKAGE_SPEC	( PACKAGE_SPEC :TREE );


  private

    procedure CODE_SUBP_ENTRY_HEADER	( SUBP_ENTRY_HEADER :TREE );

	------------
  end	DECLARATIONS;
	------------

  package body DECLARATIONS is separate;
  package body EXPRESSIONS  is separate;




				------------
 	package			INSTRUCTIONS
				------------
  is

    procedure CODE_STM_S		( STM_S :TREE );
    procedure CODE_STM		( STM :TREE );


  private

    procedure CODE_STM_ELEM		( STM_ELEM :TREE );
    procedure CODE_STM_PRAGMA		( STM_PRAGMA :TREE );
    procedure CODE_LABELED		( LABELED :TREE );
    procedure CODE_NULL_STM		( NULL_STM :TREE );
    procedure CODE_STM_WITH_EXP	( STM_WITH_EXP :TREE );
    procedure CODE_STM_WITH_EXP_NAME	( STM_WITH_EXP_NAME :TREE );
    procedure CODE_STM_WITH_NAME	( STM_WITH_NAME :TREE );
    procedure CODE_CALL_STM		( CALL_STM :TREE );
    procedure CODE_BLOCK_LOOP		( BLOCK_LOOP :TREE );
    procedure CODE_ITERATION		( ITERATION :TREE );
    procedure CODE_LOOP		( ADA_LOOP :TREE );
    procedure CODE_FOR_REV		( FOR_REV :TREE );
    procedure CODE_FOR		( ADA_FOR :TREE );
    procedure CODE_REVERSE		( ADA_REVERSE :TREE );
    procedure CODE_ASSIGN		( ASSIGN :TREE );
    procedure CODE_IF		( ADA_IF :TREE );
    procedure CODE_CASE		( ADA_CASE :TREE );
    procedure CODE_WHILE		( ADA_WHILE :TREE );
    procedure CODE_BLOCK		( BLOCK :TREE );
    procedure CODE_EXIT		( ADA_EXIT :TREE );
    procedure CODE_RETURN		( ADA_RETURN :TREE );
    procedure CODE_GOTO		( ADA_GOTO :TREE );
    procedure CODE_ACCEPT		( ADA_ACCEPT :TREE );
    procedure CODE_DELAY		( ADA_DELAY :TREE );
    procedure CODE_SELECTIVE_WAIT	( SELECTIVE_WAIT :TREE );
    procedure CODE_TERMINATE		( ADA_TERMINATE :TREE );
    procedure CODE_ENTRY_STM		( ENTRY_STM :TREE );
    procedure CODE_COND_ENTRY		( COND_ENTRY :TREE );
    procedure CODE_TIMED_ENTRY	( TIMED_ENTRY :TREE );
    procedure CODE_ABORT		( ADA_ABORT :TREE );
    procedure CODE_CLAUSES_STM	( CLAUSES_STM :TREE );
    procedure CODE_RAISE		( ADA_RAISE :TREE );
    procedure CODE_CODE		( CODE :TREE );

	------------
  end	INSTRUCTIONS;
	------------





				----------
 	package			STRUCTURES
				----------
  is

    procedure CODE_COMPILATION_UNIT	( COMPILATION_UNIT :TREE );
    procedure CODE_BLOCK_BODY		( BLOCK_BODY :TREE );


  private

    procedure CODE_WITH_CONTEXT	( CONTEXT_ELEM_S  :TREE );
    procedure CODE_SUBPROGRAM_BODY	( SUBPROGRAM_BODY :TREE );
    procedure CODE_PACKAGE_BODY	( PACKAGE_BODY :TREE );
    procedure CODE_SUBUNIT_BODY	( SUBUNIT_BODY :TREE );
    procedure CODE_BODY		( ADA_BODY :TREE );
    procedure CODE_ITEM_S		( ITEM_S :TREE );
    procedure CODE_ITEM		( ITEM :TREE );

	----------
  end	STRUCTURES;
	----------

  package body STRUCTURES    is separate;
  package body INSTRUCTIONS  is separate;








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

        STRUCTURES.CODE_COMPILATION_UNIT ( COMPLTN_UNIT );

        EMITS.CLOSE_OUTPUT_FILE;
      end loop;
    end;

  end	CODE_ROOT;
	---------



  --|-------------------------------------------------------------------------------------------
  procedure CODE_CONTEXT_PRAGMA ( CONTEXT_PRAGMA :TREE ) is
  begin
    null;
  end;



  --|-------------------------------------------------------------------------------------------
--  procedure CODE_ALL_DECL ( ALL_DECL :TREE ) is
--  begin

--    if ALL_DECL.TY in CLASS_ITEM then
--      CODE_ITEM ( ALL_DECL );

--    elsif ALL_DECL.TY = DN_SUBUNIT then
--      CODE_SUBUNIT ( ALL_DECL );

--    elsif ALL_DECL.TY = DN_BLOCK_MASTER then
--      CODE_BLOCK_MASTER ( ALL_DECL );

--    end if;
--  end;


  procedure CODE_BLOCK_MASTER ( BLOCK_MASTER :TREE ) is
  begin
    null;
  end;

 

  procedure CODE_TASK_BODY ( TASK_BODY :TREE ) is
  begin
    null;
  end;



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
        CODE_VC_NAME( SRC_NAME );
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
      PARAM_SEQ	: SEQ_TYPE	:= LIST( PARAM_S );
      PARAM	: TREE;
    begin
      while not IS_EMPTY ( PARAM_SEQ ) loop
        POP( PARAM_SEQ, PARAM );
        CODE_PARAM( PARAM );
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

  --|-------------------------------------------------------------------------------------------

  --|-------------------------------------------------------------------------------------------

  --|-------------------------------------------------------------------------------------------
--   procedure CODE_UNIT_DESC ( UNIT_DESC :TREE ) is
--   begin
-- 
--     if UNIT_DESC.TY = DN_DERIVED_SUBPROG then
--       CODE_DERIVED_SUBPROG ( UNIT_DESC );
-- 
--     elsif UNIT_DESC.TY = DN_IMPLICIT_NOT_EQ then
--       CODE_IMPLICIT_NOT_EQ ( UNIT_DESC );
-- 
--     elsif UNIT_DESC.TY in CLASS_BODY then
--       CODE_BODY ( UNIT_DESC );
-- 
--     elsif UNIT_DESC.TY in CLASS_UNIT_KIND then
--       CODE_UNIT_KIND ( UNIT_DESC );
-- 
--     end if;
--   end;

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
  procedure CODE_ALTERNATIVE_S ( ALTERNATIVE_S :TREE ) is
  begin
    declare
      ALTERNATIVE_SEQ	: SEQ_TYPE	:= LIST ( ALTERNATIVE_S );
      ALTERNATIVE_ELEM	: TREE;
    begin
      while not IS_EMPTY( ALTERNATIVE_SEQ ) loop
        POP( ALTERNATIVE_SEQ, ALTERNATIVE_ELEM );
        CODE_ALTERNATIVE_ELEM( ALTERNATIVE_ELEM );
      end loop;
    end;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM :TREE ) is
  begin

    if ALTERNATIVE_ELEM.TY = DN_ALTERNATIVE
    then
      CODE_ALTERNATIVE( ALTERNATIVE_ELEM );
    elsif ALTERNATIVE_ELEM.TY = DN_ALTERNATIVE_PRAGMA
    then
      CODE_ALTERNATIVE_PRAGMA( ALTERNATIVE_ELEM );
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_ALTERNATIVE ( ALTERNATIVE :TREE ) is
  begin
    declare
      SKIP_LBL		: LABEL_TYPE	:= NEW_LABEL;
      HANDLER_BEGIN_LBL	: LABEL_TYPE	:= NEW_LABEL;
      CHOICE_S		: TREE		:= D( AS_CHOICE_S, ALTERNATIVE );
    begin
      DI( CD_LABEL, CHOICE_S, INTEGER ( HANDLER_BEGIN_LBL ) );
      CODE_CHOICE_S( CHOICE_S );
      if not CHOICE_OTHERS_FLAG
      then
        EMIT( JMP, SKIP_LBL,		COMMENT=> "SKIP ALTERNATIVE SUIVANTE"  );
        WRITE_LABEL( HANDLER_BEGIN_LBL,	COMMENT=> "LABEL DEBUT INSTRUCTIONS" );
      end if;
      INSTRUCTIONS.CODE_STM_S( D( AS_STM_S, ALTERNATIVE ) );
      if not CHOICE_OTHERS_FLAG
      then
        WRITE_LABEL( SKIP_LBL,	COMMENT=> "ALTERNATIVE SUIVANTE" );
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
      CHOICE_SEQ	: SEQ_TYPE	:= LIST( CHOICE_S );
      CHOICE	: TREE;
    begin
      while not IS_EMPTY( CHOICE_SEQ ) loop
        POP( CHOICE_SEQ, CHOICE );
        CODE_CHOICE( CHOICE );
        if not CHOICE_OTHERS_FLAG then
	EMIT( JMPT, LABEL_TYPE( DI( CD_LABEL, CHOICE_S ) ), COMMENT=> "TRAITE EXCEPTION" );
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
    EXPRESSIONS.CODE_EXP( D( AS_EXP, CHOICE_EXP ) );
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



  procedure CODE_SUBTYPE_INDICATION ( SUBTYPE_INDICATION :TREE ) is
  begin
    null;
  end;



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
      EXPRESSIONS.CODE_EXP ( EXP_BORNE );
      GEN_STORE( I, EMITS.CUR_COMP_UNIT, EMITS.CUR_LEVEL, LOWER, "BORNE BASSE" );
      EXP_BORNE := D( AS_EXP2, INT_RANGE );
      EXPRESSIONS.CODE_EXP ( EXP_BORNE );
      GEN_STORE( I, EMITS.CUR_COMP_UNIT, EMITS.CUR_LEVEL, UPPER, "BORNE HAUTE" );
    end;
  end;



  procedure CODE_FIXED_DEF ( FIXED_DEF :TREE ) is
  begin
    null;
  end;



  procedure CODE_FLOAT_DEF ( FLOAT_DEF :TREE ) is
  begin
    null;
  end;



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



  procedure CODE_CONSTRAINED_ARRAY_DEF ( CONSTRAINED_ARRAY_DEF :TREE ) is
  begin
    null;
  end;



  procedure CODE_UNCONSTRAINED_ARRAY_DEF ( UNCONSTRAINED_ARRAY_DEF :TREE ) is
  begin
    null;
  end;



  procedure CODE_ACCESS_DEF ( ACCESS_DEF :TREE ) is
  begin
    null;
  end;



  procedure CODE_DERIVED_DEF ( DERIVED_DEF :TREE ) is
  begin
    null;
  end;



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

put_line( "COMPILE_VC_NAME_INTEGER init_exp" );

	  EXPRESSIONS.CODE_EXP ( INIT_EXP );
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
            DI( CD_COMP_UNIT, VC_NAME, CCU );
            DI( CD_LEVEL,     VC_NAME, LVL );
            DI( CD_OFFSET,    VC_NAME, OFS );
            DB( CD_COMPILED,  VC_NAME, TRUE );
            INC_OFFSET( SIZ );
            if INIT_EXP /= TREE_VOID then
	    EXPRESSIONS.CODE_EXP( INIT_EXP );
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
	      EXPRESSIONS.CODE_EXP( COMP_EXP );
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



  procedure CODE_VARIABLE_ID ( VARIABLE_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_CONSTANT_ID ( CONSTANT_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_NUMBER_ID ( NUMBER_ID :TREE ) is
  begin
    null;
  end;



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



  procedure CODE_TYPE_ID ( TYPE_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_SUBTYPE_ID ( SUBTYPE_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_COMP_NAME ( COMP_NAME :TREE ) is
  begin

    if COMP_NAME.TY = DN_COMPONENT_ID then
      CODE_COMPONENT_ID ( COMP_NAME );

    elsif COMP_NAME.TY = DN_DISCRIMINANT_ID then
      CODE_DISCRIMINANT_ID ( COMP_NAME );

    end if;
  end;



  procedure CODE_COMPONENT_ID ( COMPONENT_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_DISCRIMINANT_ID ( DISCRIMINANT_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_LABEL_NAME ( LABEL_NAME :TREE ) is
  begin

    if LABEL_NAME.TY = DN_LABEL_ID then
      CODE_LABEL_ID ( LABEL_NAME );

    elsif LABEL_NAME.TY = DN_BLOCK_LOOP_ID then
      CODE_BLOCK_LOOP_ID ( LABEL_NAME );

    end if;
  end;



  procedure CODE_LABEL_ID ( LABEL_ID :TREE ) is
  begin
    null;
  end;



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
         EXPRESSIONS.CODE_INDEXED ( OBJECT );
       when DN_USED_OBJECT_ID =>
         CODE_OBJECT ( D ( SM_DEFN, OBJECT ) );
       when others =>
         PUT_LINE ( "!!! LOAD_OBJECT_ADDRESS : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( OBJECT.TY ) );
         raise PROGRAM_ERROR;
      end case;
  end;



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
      EXPRESSIONS.CODE_INDEXED ( ADRESSE );
    when DN_USED_OBJECT_ID =>
      CODE_ADRESSE ( D ( SM_DEFN, ADRESSE ) );
    when others =>
    PUT_LINE ( "!!! CODE_ADRESSE : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( ADRESSE.TY ) );
      raise PROGRAM_ERROR;
    end case;
  end;



  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE ) is
  begin

    if TEST_CLAUSE.TY = DN_COND_CLAUSE then
      CODE_COND_CLAUSE ( TEST_CLAUSE );

    elsif TEST_CLAUSE.TY = DN_SELECT_ALTERNATIVE then
      CODE_SELECT_ALTERNATIVE ( TEST_CLAUSE );

    end if;
  end;



  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE ) is
  begin
    declare
      EXP : TREE := D ( AS_EXP, COND_CLAUSE );
      NEXT_CLAUSE_LBL : LABEL_TYPE;
    begin
      EXPRESSIONS.CODE_EXP ( EXP );
      NEXT_CLAUSE_LBL := NEW_LABEL;
      EMIT ( JMPF, NEXT_CLAUSE_LBL, COMMENT=> "NON CONDITION SAUT CLAUSE SUIVANTE" );
      INSTRUCTIONS.CODE_STM_S ( D ( AS_STM_S, COND_CLAUSE ) );
      EMIT ( JMP, EMITS.AFTER_IF_LBL, COMMENT=> "SAUT END IF" );
      WRITE_LABEL ( NEXT_CLAUSE_LBL, COMMENT=> "LBL CONDITION SUIVANTE" );
    end;
  end;



  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_ITERATION_ID ( ITERATION_ID :TREE ) is
  begin
    null;
  end;



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



  procedure CODE_TASK_BODY_ID ( TASK_BODY_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_ENTRY_ID ( ENTRY_ID :TREE ) is
  begin
    null;
  end;



  procedure CODE_ENTRY_CALL ( ENTRY_CALL :TREE ) is
  begin
    null;
  end;



  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE ) is
  begin

    if TEST_CLAUSE_ELEM.TY in CLASS_TEST_CLAUSE then
      CODE_TEST_CLAUSE ( TEST_CLAUSE_ELEM );

    elsif TEST_CLAUSE_ELEM.TY = DN_SELECT_ALT_PRAGMA then
      CODE_SELECT_ALT_PRAGMA ( TEST_CLAUSE_ELEM );

    end if;
  end;



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



  procedure CODE_NAME_S ( NAME_S :TREE ) is
  begin
    declare
      NAME_SEQ : SEQ_TYPE := LIST( NAME_S );
      NAME : TREE;
    begin
      while not IS_EMPTY( NAME_SEQ ) loop
        POP( NAME_SEQ, NAME );
        EXPRESSIONS.CODE_NAME( NAME );
    end loop;
    end;
  end;



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



  procedure CODE_GENERIC_ID ( GENERIC_ID :TREE ) is
  begin
    null;
  end;



begin
  OPEN_IDL_TREE_FILE( LIB_PATH(1..LIB_PATH_LENGTH) & "$$$.TMP" );
  if DI( XD_ERR_COUNT, TREE_ROOT ) = 0
  then
    CODE_ROOT( TREE_ROOT );
  end if;
  CLOSE_IDL_TREE_FILE;

	--------
end	CODE_GEN;
	--------