with DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
use  DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
with CODAGE_INTERMEDIAIRE;
use  CODAGE_INTERMEDIAIRE;
					--------
			procedure		CODE_GEN
					--------
is


  package CODI	renames CODAGE_INTERMEDIAIRE;


  procedure CODE_ENUMERATION_ID	( ENUMERATION_ID :TREE );
  procedure CODE_ITERATION_ID		( ITERATION_ID :TREE );
  function  CODE_NAME		( NAME		:TREE )		return OPERAND_REF;
  function  CODE_DESIGNATOR		( DESIGNATOR	:TREE )		return OPERAND_REF;

  procedure CODE_ROOT ( ROOT :TREE );
  procedure CODE_CONTEXT_PRAGMA ( CONTEXT_PRAGMA :TREE );
--  procedure CODE_ALL_DECL ( ALL_DECL :TREE );
  procedure CODE_BLOCK_MASTER ( BLOCK_MASTER :TREE );
  procedure CODE_TASK_BODY ( TASK_BODY :TREE );
  procedure CODE_USE_PRAGMA ( USE_PRAGMA :TREE );
  procedure CODE_USE ( ADA_USE :TREE );
  procedure CODE_PRAGMA ( ADA_PRAGMA :TREE );
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
  procedure CODE_UNIT_NAME ( UNIT_NAME :TREE );
  procedure CODE_NUMBER_ID ( NUMBER_ID :TREE );
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
  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE; LBL :STRING );
  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE; AFTER_IF_LBL :STRING );
  procedure CODE_NON_TASK_NAME ( NON_TASK_NAME :TREE );
  procedure CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :TREE );
  procedure CODE_SUBPROG_NAME ( SUBPROG_NAME :TREE );
  procedure CODE_PROCEDURE_ID ( PROCEDURE_ID :TREE );
  procedure CODE_FUNCTION_ID ( FUNCTION_ID :TREE );
  procedure CODE_OPERATOR_ID ( OPERATOR_ID :TREE );
  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE );
  procedure CODE_PARAM_NAME ( PARAM_NAME :TREE );
  procedure CODE_PARAM_IO_O ( PARAM_IO_O :TREE );
  procedure CODE_IN_ID ( IN_ID :TREE );
  procedure CODE_IN_OUT_ID ( IN_OUT_ID :TREE );
  procedure CODE_OUT_ID ( OUT_ID :TREE );
  procedure CODE_PROCEDURE_CALL ( PROCEDURE_CALL :TREE );
  procedure CODE_PACKAGE_ID ( PACKAGE_ID :TREE );
  procedure CODE_PRIVATE_TYPE_ID ( PRIVATE_TYPE_ID :TREE );
  procedure CODE_L_PRIVATE_TYPE_ID ( L_PRIVATE_TYPE_ID :TREE );
  procedure CODE_TASK_BODY_ID ( TASK_BODY_ID :TREE );
  procedure CODE_ENTRY_ID ( ENTRY_ID :TREE );
  procedure CODE_ENTRY_CALL ( ENTRY_CALL :TREE );
  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE; LBL :STRING );
  procedure CODE_TEST_CLAUSE_ELEM_S ( TEST_CLAUSE_ELEM_S :TREE; LBL :STRING );
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

    procedure CODE_EXP		( EXP		:TREE );
    procedure CODE_INDEXED		( INDEXED		:TREE );


  private

    procedure CODE_EXP_EXP		( EXP_EXP		:TREE );
    procedure CODE_VC_ID		( CONSTANT_ID	:TREE );
    procedure CODE_NAME_EXP		( NAME_EXP	:TREE );
    procedure CODE_FUNCTION_CALL	( FUNCTION_CALL	:TREE );
    procedure CODE_USED_NAME		( USED_NAME	:TREE );
    procedure CODE_USED_OP		( USED_OP		:TREE );
    procedure CODE_USED_NAME_ID	( USED_NAME_ID	:TREE );
    procedure CODE_USED_OBJECT_ID	( USED_OBJECT_ID	:TREE );
    procedure CODE_SLICE		( SLICE		:TREE );
    procedure CODE_ALL		( ADA_ALL		:TREE );
    procedure CODE_AGGREGATE		( AGGREGATE	:TREE );
    procedure CODE_SHORT_CIRCUIT	( SHORT_CIRCUIT	:TREE );
    procedure CODE_MEMBERSHIP		( MEMBERSHIP	:TREE );
    procedure CODE_RANGE_MEMBERSHIP	( RANGE_MEMBERSHIP	:TREE );
    procedure CODE_TYPE_MEMBERSHIP	( TYPE_MEMBERSHIP	:TREE );
    procedure CODE_EXP_VAL		( EXP_VAL		:TREE );
    procedure CODE_EXP_VAL_EXP	( EXP_VAL_EXP	:TREE );
    procedure CODE_AGG_EXP		( AGG_EXP		:TREE );
    procedure CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL	:TREE );
    procedure CODE_STRING_LITERAL	( STRING_LITERAL	:TREE );
    procedure CODE_NULL_ACCESS	( NULL_ACCESS	:TREE );
    procedure CODE_QUAL_CONV		( QUAL_CONV	:TREE );
    procedure CODE_CONVERSION		( CONVERSION	:TREE );
    procedure CODE_QUALIFIED		( QUALIFIED	:TREE );
    procedure CODE_QUALIFIED_ALLOCATOR	( QUALIFIED_ALLOCATOR:TREE );
    procedure CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR :TREE );

    procedure CODE_USED_CHAR		( USED_CHAR :TREE );

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
    procedure CODE_VC_NAME		( VC_NAME :TREE );
    procedure CODE_ID_S_DECL		( ID_S_DECL :TREE );
    procedure CODE_EXCEPTION_DECL	( EXCEPTION_DECL :TREE );
    procedure CODE_DEFERRED_CONSTANT_DECL ( DEFERRED_CONSTANT_DECL :TREE );
    procedure CODE_EXP_DECL		( EXP_DECL :TREE );
    procedure CODE_NUMBER_DECL	( NUMBER_DECL :TREE );
    procedure CODE_OBJECT_DECL	( OBJECT_DECL :TREE );
    procedure CODE_INIT_OBJECT_NAME	( INIT_OBJECT_NAME :TREE );
    procedure CODE_OBJECT_NAME	( OBJECT_NAME :TREE );

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
        CODI.OPEN_OUTPUT_FILE( GET_LIB_PREFIX & PRINT_NAME( D( XD_LIB_NAME, COMPLTN_UNIT ) ) );

        STRUCTURES.CODE_COMPILATION_UNIT ( COMPLTN_UNIT );

        CODI.CLOSE_OUTPUT_FILE;
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

  --|-------------------------------------------------------------------------------------------

  --|-------------------------------------------------------------------------------------------




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
      SKIP_LBL		:constant STRING	:= NEW_LABEL;
      HANDLER_BEGIN_LBL	:constant STRING	:= NEW_LABEL;
      CHOICE_S		: TREE		:= D( AS_CHOICE_S, ALTERNATIVE );
    begin
--      DI( CD_LABEL, CHOICE_S, INTEGER ( HANDLER_BEGIN_LBL ) );
      CODE_CHOICE_S( CHOICE_S );
      if not CHOICE_OTHERS_FLAG
      then
        PUT_LINE( tab & "BRA" & tab & SKIP_LBL );
        PUT_LINE( HANDLER_BEGIN_LBL & ':' );
      end if;
      INSTRUCTIONS.CODE_STM_S( D( AS_STM_S, ALTERNATIVE ) );
      if not CHOICE_OTHERS_FLAG
      then
        PUT_LINE( SKIP_LBL & ':' );
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

  procedure			CODE_ENUMERATION_ID		( ENUMERATION_ID :TREE )
  is
  begin
    null;
  end	CODE_ENUMERATION_ID;

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
      TYPE_ID		: TREE		:= D( AS_SOURCE_NAME, TYPE_DECL );
      INTEGER_SPEC		: TREE		:= D( SM_TYPE_SPEC, TYPE_ID );
      LOWER_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, TYPE_DECL ) ) ) & "_lower_disp";
      UPPER_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, TYPE_DECL ) ) ) & "_upper_disp";
      INT_RANGE		: TREE		:= D( AS_CONSTRAINT, INTEGER_DEF );
      EXP_BORNE		: TREE;
    begin
      PUT_LINE( "  virtual VAR" );
      PUT_LINE( "    align_d" );
      PUT_LINE( "    " & LOWER_STR & " = $" );
      PUT_LINE( "    dd" & " ?" );
      PUT_LINE( "    " & UPPER_STR & " = $" );
      PUT_LINE( "    dd" & " ?" );
      PUT_LINE( "  end virtual" );

      DI( CD_LEVEL,     INTEGER_SPEC, INTEGER( CODI.CUR_LEVEL ) );

      DB( CD_COMPILED,  INTEGER_SPEC, TRUE );
      EXP_BORNE := D( AS_EXP1, INT_RANGE );
      EXPRESSIONS.CODE_EXP( EXP_BORNE );
      PUT_LINE( tab & "ST" & 'd' & ' ' & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & LOWER_STR );
      EXP_BORNE := D( AS_EXP2, INT_RANGE );
      EXPRESSIONS.CODE_EXP( EXP_BORNE );
      PUT_LINE( tab & "ST" & 'd' & ' ' & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ',' & tab & UPPER_STR );
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





  procedure			CODE_ITERATION_ID		( ITERATION_ID :TREE )
  is
  begin
    null;
  end	CODE_ITERATION_ID;




  procedure CODE_UNIT_NAME ( UNIT_NAME :TREE ) is
  begin

    if UNIT_NAME.TY = DN_TASK_BODY_ID then
      CODE_TASK_BODY_ID ( UNIT_NAME );

    elsif UNIT_NAME.TY in CLASS_NON_TASK_NAME then
      CODE_NON_TASK_NAME ( UNIT_NAME );

    end if;
  end;





  procedure CODE_NUMBER_ID ( NUMBER_ID :TREE ) is
  begin
    null;
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
         LOAD_ADR( OBJECT );
       when DN_IN_ID =>
PUT_LINE( tab & "LDA " & INTEGER'IMAGE( DI( CD_LEVEL, OBJECT ) ) & ',' & tab & PRINT_NAME( D( LX_SYMREP, OBJECT ) ) );
--         EMIT ( PLA, INTEGER( LEVEL_NUM( DI ( CD_LEVEL, OBJECT ) ) - CUR_LEVEL ), DI ( CD_OFFSET, OBJECT ),
--                      "EMPILE ADRESSE DE PARAM IN" );
       when DN_IN_OUT_ID | DN_OUT_ID =>
         EMIT ( PLA, INTEGER( LEVEL_NUM( DI ( CD_LEVEL, OBJECT ) ) - CUR_LEVEL), DI ( CD_VAL_OFFSET, OBJECT ),
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
      GEN_PUSH_DATA ( A, DI (CD_COMP_UNIT, ADRESSE ), LEVEL_NUM(DI ( CD_LEVEL, ADRESSE )), DI ( CD_OFFSET, ADRESSE ) );
    when DN_IN_ID =>
      GEN_PUSH_DATA ( A, 0,  LEVEL_NUM(DI ( CD_LEVEL, ADRESSE )), DI ( CD_OFFSET, ADRESSE ) );
    when DN_IN_OUT_ID | DN_OUT_ID =>
      GEN_PUSH_DATA ( A, 0, LEVEL_NUM(DI( CD_LEVEL, ADRESSE )), DI( CD_VAL_OFFSET, ADRESSE ) );
    when DN_INDEXED =>
      EXPRESSIONS.CODE_INDEXED ( ADRESSE );
    when DN_USED_OBJECT_ID =>
      CODE_ADRESSE ( D( SM_DEFN, ADRESSE ) );
    when others =>
    PUT_LINE ( "!!! CODE_ADRESSE : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( ADRESSE.TY ) );
      raise PROGRAM_ERROR;
    end case;
  end;



  procedure CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE; LBL :STRING ) is
  begin

    if TEST_CLAUSE.TY = DN_COND_CLAUSE then
      CODE_COND_CLAUSE ( TEST_CLAUSE, LBL );

    elsif TEST_CLAUSE.TY = DN_SELECT_ALTERNATIVE then
      CODE_SELECT_ALTERNATIVE ( TEST_CLAUSE );

    end if;
  end;



  procedure CODE_COND_CLAUSE ( COND_CLAUSE :TREE; AFTER_IF_LBL :STRING ) is
  begin
    declare
      EXP			: TREE		:= D( AS_EXP, COND_CLAUSE );
      NEXT_CLAUSE_LBL	:constant STRING	:= NEW_LABEL;
    begin
      EXPRESSIONS.CODE_EXP ( EXP );
      PUT_LINE( tab & "BRZ" & tab & NEXT_CLAUSE_LBL );
      INSTRUCTIONS.CODE_STM_S ( D ( AS_STM_S, COND_CLAUSE ) );
      PUT_LINE( tab & "BRZ" & tab & AFTER_IF_LBL );
      PUT_LINE( NEXT_CLAUSE_LBL & ':' );
    end;
  end;



  procedure CODE_BLOCK_LOOP_ID ( BLOCK_LOOP_ID :TREE ) is
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



  procedure CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE; LBL :STRING ) is
  begin

    if TEST_CLAUSE_ELEM.TY in CLASS_TEST_CLAUSE then
      CODE_TEST_CLAUSE ( TEST_CLAUSE_ELEM, LBL );

    elsif TEST_CLAUSE_ELEM.TY = DN_SELECT_ALT_PRAGMA then
      CODE_SELECT_ALT_PRAGMA ( TEST_CLAUSE_ELEM );

    end if;
  end;



  procedure CODE_TEST_CLAUSE_ELEM_S ( TEST_CLAUSE_ELEM_S :TREE; LBL :STRING ) is
  begin
    declare
      TEST_CLAUSE_ELEM_SEQ : SEQ_TYPE := LIST ( TEST_CLAUSE_ELEM_S );
      TEST_CLAUSE_ELEM : TREE;
    begin
      while not IS_EMPTY ( TEST_CLAUSE_ELEM_SEQ ) loop
        POP( TEST_CLAUSE_ELEM_SEQ, TEST_CLAUSE_ELEM );
        CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM, LBL );
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

				---------
  function			CODE_NAME			( NAME :TREE )		return OPERAND_REF
  is
  begin
    if NAME.TY in CLASS_DESIGNATOR
    then
      return CODE_DESIGNATOR( NAME );

--     elsif NAME.TY in CLASS_NAME_EXP
--     then
--       return CODE_NAME_EXP( NAME );

    end if;
    return NO_OPERAND;
  end	CODE_NAME;
	---------


  procedure CODE_NAME_S ( NAME_S :TREE ) is
  begin
    declare
      NAME_SEQ	: SEQ_TYPE := LIST( NAME_S );
      NAME	: TREE;
      OPER	: OPERAND_REF;
    begin
      while not IS_EMPTY( NAME_SEQ ) loop
        POP( NAME_SEQ, NAME );
        OPER := CODE_NAME( NAME );
    end loop;
    end;
  end;



				---------------
  function			CODE_DESIGNATOR		( DESIGNATOR :TREE )	return OPERAND_REF
  is
  begin
--     if DESIGNATOR.TY in CLASS_USED_OBJECT
--     then
--       return CODE_USED_OBJECT( DESIGNATOR );
-- 
--     elsif DESIGNATOR.TY in CLASS_USED_NAME
--     then
--       return CODE_USED_NAME( DESIGNATOR );
-- 
--     end if;
    return NO_OPERAND;
  end	CODE_DESIGNATOR;
	---------------



  procedure CODE_EXCEPTION_ID ( EXCEPTION_ID :TREE ) is
  begin
    declare
      LBL :constant STRING := NEW_LABEL;
    begin
--      DI ( CD_LABEL, EXCEPTION_ID, INTEGER ( LBL ) );
PUT_LINE( "; EXL" & tab & LBL );
--      EMIT ( EXL, LBL, S=> PRINT_NAME ( D ( LX_SYMREP, EXCEPTION_ID ) ),
--             COMMENT=> "NUMERO D EXCEPTION SUR DECLARATION" );
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