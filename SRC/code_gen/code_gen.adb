WITH EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
USE  EMITS, DIANA_NODE_ATTR_CLASS_NAMES, IDL, TEXT_IO;
--|----------------------------------------------------------------------------------------------
--|	procedure Code_Gen
PROCEDURE CODE_GEN IS

  PROCEDURE CODE_root ( root :Tree );
  PROCEDURE CODE_SOURCE_NAME ( SOURCE_NAME :Tree );
  PROCEDURE CODE_OBJECT_NAME ( OBJECT_NAME :Tree );
  PROCEDURE CODE_UNIT_NAME ( UNIT_NAME :Tree );
  PROCEDURE CODE_DECL ( DECL :Tree );
  PROCEDURE CODE_ID_DECL ( ID_DECL :Tree );
  PROCEDURE CODE_ID_S_DECL ( ID_S_DECL :Tree );
  PROCEDURE CODE_EXP_DECL ( EXP_DECL :Tree );
  PROCEDURE CODE_OBJECT_DECL ( OBJECT_DECL :Tree );
  PROCEDURE CODE_VC_NAME ( VC_NAME :Tree );
  PROCEDURE CODE_variable_id ( variable_id :Tree );
  PROCEDURE CODE_constant_id ( constant_id :Tree );
  PROCEDURE CODE_number_decl ( number_decl :Tree );
  PROCEDURE CODE_number_id ( number_id :Tree );
  PROCEDURE CODE_source_name_s ( source_name_s :Tree );
  PROCEDURE CODE_type_decl ( type_decl :Tree );
  PROCEDURE CODE_TYPE_NAME ( TYPE_NAME :Tree );
  PROCEDURE CODE_type_id ( type_id :Tree );
  PROCEDURE CODE_subtype_decl ( subtype_decl :Tree );
  PROCEDURE CODE_subtype_id ( subtype_id :Tree );
  PROCEDURE CODE_ENUM_LITERAL ( ENUM_LITERAL :Tree );
  PROCEDURE CODE_enumeration_id ( enumeration_id :Tree );
  PROCEDURE CODE_character_id ( character_id :Tree );
  PROCEDURE CODE_COMP_NAME ( COMP_NAME :Tree );
  PROCEDURE CODE_component_id ( component_id :Tree );
  PROCEDURE CODE_discriminant_id ( discriminant_id :Tree );
  PROCEDURE CODE_choice_s ( choice_s :Tree );
  PROCEDURE CODE_CHOICE ( CHOICE :Tree );
  PROCEDURE CODE_choice_exp ( choice_exp :Tree );
  PROCEDURE CODE_choice_range ( choice_range :Tree );
  PROCEDURE CODE_choice_others ( choice_others :Tree );
  PROCEDURE CODE_ITEM ( ITEM :Tree );
  PROCEDURE CODE_item_s ( item_s :Tree );
  PROCEDURE CODE_UNIT_DECL ( UNIT_DECL :Tree );
  PROCEDURE CODE_NON_GENERIC_DECL ( NON_GENERIC_DECL :Tree );
  PROCEDURE CODE_NAME ( NAME :Tree );
  PROCEDURE CODE_NAME_EXP ( NAME_EXP :Tree );
  PROCEDURE CODE_DESIGNATOR ( DESIGNATOR :Tree );
  PROCEDURE CODE_USED_NAME ( USED_NAME :Tree );
  PROCEDURE CODE_used_op ( used_op :Tree );
  PROCEDURE CODE_used_name_id ( used_name_id :Tree );
  PROCEDURE CODE_USED_OBJECT ( USED_OBJECT :Tree );
  PROCEDURE CODE_used_char ( used_char :Tree );
  PROCEDURE CODE_used_object_id ( used_object_id :Tree );
  PROCEDURE CODE_INDEXED ( INDEXED :Tree );
  PROCEDURE CODE_slice ( slice :Tree );
  PROCEDURE CODE_all ( ada_all :Tree );
  PROCEDURE CODE_aggregate ( aggregate :Tree );
  PROCEDURE CODE_short_circuit ( short_circuit :Tree );
  PROCEDURE CODE_MEMBERSHIP ( MEMBERSHIP :Tree );
  PROCEDURE CODE_range_membership ( range_membership :Tree );
  PROCEDURE CODE_type_membership ( type_membership :Tree );
  PROCEDURE CODE_EXP ( EXP :Tree );
  PROCEDURE CODE_EXP_EXP ( EXP_EXP :Tree );
  PROCEDURE CODE_EXP_VAL ( EXP_VAL :Tree );
  PROCEDURE CODE_EXP_VAL_EXP ( EXP_VAL_EXP :Tree );
  PROCEDURE CODE_AGG_EXP ( AGG_EXP :Tree );
  PROCEDURE CODE_parenthesized ( parenthesized :Tree );
  PROCEDURE CODE_numeric_literal ( numeric_literal :Tree );
  PROCEDURE CODE_string_literal ( string_literal :Tree );
  PROCEDURE CODE_null_access ( null_access :Tree );
  PROCEDURE CODE_QUAL_CONV ( QUAL_CONV :Tree );
  PROCEDURE CODE_conversion ( conversion :Tree );
  PROCEDURE CODE_qualified ( qualified :Tree );
  PROCEDURE CODE_qualified_allocator ( qualified_allocator :Tree );
  PROCEDURE CODE_subtype_allocator ( subtype_allocator :Tree );
  PROCEDURE CODE_stm_s ( stm_s :Tree );
  PROCEDURE CODE_STM_ELEM ( STM_ELEM :Tree );
  PROCEDURE CODE_stm_pragma ( stm_pragma :Tree );
  PROCEDURE CODE_STM ( STM :Tree );
  PROCEDURE CODE_labeled ( labeled :Tree );
  PROCEDURE CODE_STM_WITH_EXP ( STM_WITH_EXP :Tree );
  PROCEDURE CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP_NAME :Tree );
  PROCEDURE CODE_STM_WITH_NAME ( STM_WITH_NAME :Tree );
  PROCEDURE CODE_CALL_STM ( CALL_STM :Tree );
  PROCEDURE CODE_CLAUSES_STM ( CLAUSES_STM :Tree );
  PROCEDURE CODE_LABEL_NAME ( LABEL_NAME :Tree );
  PROCEDURE CODE_label_id ( label_id :Tree );
  PROCEDURE CODE_null_stm ( null_stm :Tree );
  PROCEDURE CODE_OBJECT ( OBJECT :Tree );
  PROCEDURE CODE_ADRESSE ( ADRESSE :Tree );
  PROCEDURE CODE_assign ( assign :Tree );
  PROCEDURE CODE_if ( ada_if :Tree );
  PROCEDURE CODE_TEST_CLAUSE ( TEST_CLAUSE :Tree );
  PROCEDURE CODE_cond_clause ( cond_clause :Tree );
  PROCEDURE CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM :Tree );
  PROCEDURE CODE_case ( ada_case :Tree );
  PROCEDURE CODE_alternative_s ( alternative_s :Tree );
  PROCEDURE CODE_alternative ( alternative :Tree );
  PROCEDURE CODE_alternative_pragma ( alternative_pragma :Tree );
  PROCEDURE CODE_BLOCK_LOOP ( BLOCK_LOOP :Tree );
  PROCEDURE CODE_block_loop_id ( block_loop_id :Tree );
  PROCEDURE CODE_ITERATION ( ITERATION :Tree );
  PROCEDURE CODE_loop ( ada_loop :Tree );
  PROCEDURE CODE_FOR_REV ( FOR_REV :Tree );
  PROCEDURE CODE_for ( ada_for :Tree );
  PROCEDURE CODE_reverse ( ada_reverse :Tree );
  PROCEDURE CODE_iteration_id ( iteration_id :Tree );
  PROCEDURE CODE_while ( ada_while :Tree );
  PROCEDURE CODE_block ( block :Tree );
  PROCEDURE CODE_block_body ( block_body :Tree );
  PROCEDURE CODE_exit ( ada_exit :Tree );
  PROCEDURE CODE_return ( ada_return :Tree );
  PROCEDURE CODE_goto ( ada_goto :Tree );
  PROCEDURE CODE_subprog_entry_decl ( subprog_entry_decl :Tree );
  PROCEDURE CODE_NON_TASK_NAME ( NON_TASK_NAME :Tree );
  PROCEDURE CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :Tree );
  PROCEDURE CODE_SUBPROG_NAME ( SUBPROG_NAME :Tree );
  PROCEDURE CODE_procedure_id ( procedure_id :Tree );
  PROCEDURE CODE_function_id ( function_id :Tree );
  PROCEDURE CODE_operator_id ( operator_id :Tree );
  PROCEDURE CODE_HEADER ( HEADER :Tree );
  PROCEDURE CODE_SUBP_ENTRY_HEADER ( SUBP_ENTRY_HEADER :Tree );
  PROCEDURE CODE_procedure_spec ( procedure_spec :Tree );
  PROCEDURE CODE_function_spec ( function_spec :Tree );
  PROCEDURE CODE_param_s ( param_s :Tree );
  PROCEDURE CODE_PARAM ( PARAM :Tree );
  PROCEDURE CODE_in ( ada_in :Tree );
  PROCEDURE CODE_in_out ( ada_in_out :Tree );
  PROCEDURE CODE_out ( ada_out :Tree );
  PROCEDURE CODE_INIT_OBJECT_NAME ( INIT_OBJECT_NAME :Tree );
  PROCEDURE CODE_PARAM_NAME ( PARAM_NAME :Tree );
  PROCEDURE CODE_PARAM_IO_O ( PARAM_IO_O :Tree );
  PROCEDURE CODE_in_id ( in_id :Tree );
  PROCEDURE CODE_in_out_id ( in_out_id :Tree );
  PROCEDURE CODE_out_id ( out_id :Tree );
  PROCEDURE CODE_BODY ( ada_BODY :Tree );
  PROCEDURE CODE_subprogram_body ( subprogram_body :Tree );
  PROCEDURE CODE_procedure_call ( procedure_call :Tree );
  PROCEDURE CODE_function_call ( function_call :Tree );
  PROCEDURE CODE_package_decl ( package_decl :Tree );
  PROCEDURE CODE_package_id ( package_id :Tree );
  PROCEDURE CODE_package_spec ( package_spec :Tree );
  PROCEDURE CODE_decl_s ( decl_s :Tree );
  PROCEDURE CODE_package_body ( package_body :Tree );
  PROCEDURE CODE_private_type_id ( private_type_id :Tree );
  PROCEDURE CODE_l_private_type_id ( l_private_type_id :Tree );
  PROCEDURE CODE_deferred_constant_decl ( deferred_constant_decl :Tree );
  PROCEDURE CODE_task_decl ( task_decl :Tree );
  PROCEDURE CODE_task_body ( task_body :Tree );
  PROCEDURE CODE_task_body_id ( task_body_id :Tree );
  PROCEDURE CODE_entry_id ( entry_id :Tree );
  PROCEDURE CODE_entry_call ( entry_call :Tree );
  PROCEDURE CODE_accept ( ada_accept :Tree );
  PROCEDURE CODE_delay ( ada_delay :Tree );
  PROCEDURE CODE_selective_wait ( selective_wait :Tree );
  PROCEDURE CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :Tree );
  PROCEDURE CODE_test_clause_elem_s ( test_clause_elem_s :Tree );
  PROCEDURE CODE_select_alternative ( select_alternative :Tree );
  PROCEDURE CODE_select_alt_pragma ( select_alt_pragma :Tree );
  PROCEDURE CODE_terminate ( ada_terminate :Tree );
  PROCEDURE CODE_ENTRY_STM ( ENTRY_STM :Tree );
  PROCEDURE CODE_cond_entry ( cond_entry :Tree );
  PROCEDURE CODE_timed_entry ( timed_entry :Tree );
  PROCEDURE CODE_name_s ( name_s :Tree );
  PROCEDURE CODE_abort ( ada_abort :Tree );
  PROCEDURE CODE_compilation ( compilation :Tree );
  PROCEDURE CODE_compltn_unit_s ( compltn_unit_s :Tree );
  PROCEDURE CODE_compilation_unit ( compilation_unit :Tree );
  PROCEDURE CODE_CONTEXT_ELEM ( CONTEXT_ELEM :Tree );
  PROCEDURE CODE_context_pragma ( context_pragma :Tree );
  PROCEDURE CODE_context_elem_s ( context_elem_s :Tree );
  PROCEDURE CODE_with ( ada_with :Tree );
  PROCEDURE CODE_subunit ( subunit :Tree );
  PROCEDURE CODE_SUBUNIT_BODY ( SUBUNIT_BODY :Tree );
  PROCEDURE CODE_exception_decl ( exception_decl :Tree );
  PROCEDURE CODE_exception_id ( exception_id :Tree );
  PROCEDURE CODE_raise ( ada_raise :Tree );
  PROCEDURE CODE_generic_decl ( generic_decl :Tree );
  PROCEDURE CODE_generic_id ( generic_id :Tree );
  PROCEDURE CODE_code ( code :Tree );
  PROCEDURE CODE_ALL_DECL ( ALL_DECL :Tree );
  PROCEDURE CODE_user_root ( user_root :Tree );
  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_root ( root :TREE ) IS
  BEGIN
      CODE_user_root ( D ( xd_user_root, root ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_SOURCE_NAME ( SOURCE_NAME :TREE ) IS
  BEGIN

    IF SOURCE_NAME.TY IN CLASS_OBJECT_NAME then
      CODE_OBJECT_NAME ( SOURCE_NAME );

    ELSIF SOURCE_NAME.TY IN CLASS_TYPE_NAME then
      CODE_TYPE_NAME ( SOURCE_NAME );

    ELSIF SOURCE_NAME.TY IN CLASS_UNIT_NAME then
      CODE_UNIT_NAME ( SOURCE_NAME );

    ELSIF SOURCE_NAME.TY IN CLASS_LABEL_NAME then
      CODE_LABEL_NAME ( SOURCE_NAME );

    ELSIF SOURCE_NAME.TY = DN_entry_id then
      CODE_entry_id ( SOURCE_NAME );

    ELSIF SOURCE_NAME.TY = DN_exception_id then
      CODE_exception_id ( SOURCE_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_OBJECT_NAME ( OBJECT_NAME :TREE ) IS
  BEGIN

    IF OBJECT_NAME.TY = DN_iteration_id then
      CODE_iteration_id ( OBJECT_NAME );

    ELSIF OBJECT_NAME.TY IN CLASS_INIT_OBJECT_NAME then
      CODE_INIT_OBJECT_NAME ( OBJECT_NAME );

    ELSIF OBJECT_NAME.TY IN CLASS_ENUM_LITERAL then
      CODE_ENUM_LITERAL ( OBJECT_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_UNIT_NAME ( UNIT_NAME :TREE ) IS
  BEGIN

    IF UNIT_NAME.TY = DN_task_body_id then
      CODE_task_body_id ( UNIT_NAME );

    ELSIF UNIT_NAME.TY IN CLASS_NON_TASK_NAME then
      CODE_NON_TASK_NAME ( UNIT_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_DECL ( DECL :TREE ) IS
  BEGIN

    IF DECL.TY IN CLASS_ID_S_DECL then
      CODE_ID_S_DECL ( DECL );

    ELSIF DECL.TY IN CLASS_ID_DECL then
      CODE_ID_DECL ( DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ID_DECL ( ID_DECL :TREE ) IS
  BEGIN

    IF ID_DECL.TY = DN_type_decl then
      CODE_type_decl ( ID_DECL );

    ELSIF ID_DECL.TY = DN_subtype_decl then
      CODE_subtype_decl ( ID_DECL );

    ELSIF ID_DECL.TY = DN_task_decl then
      CODE_task_decl ( ID_DECL );

    ELSIF ID_DECL.TY IN CLASS_UNIT_DECL then
      CODE_UNIT_DECL ( ID_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ID_S_DECL ( ID_S_DECL :TREE ) IS
  BEGIN

    IF ID_S_DECL.TY IN CLASS_EXP_DECL then
      CODE_EXP_DECL ( ID_S_DECL );

    ELSIF ID_S_DECL.TY = DN_exception_decl then
      CODE_exception_decl ( ID_S_DECL );

    ELSIF ID_S_DECL.TY = DN_deferred_constant_decl then
      CODE_deferred_constant_decl ( ID_S_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_EXP_DECL ( EXP_DECL :TREE ) IS
  BEGIN

    IF EXP_DECL.TY IN CLASS_OBJECT_DECL then
      CODE_OBJECT_DECL ( EXP_DECL );

    ELSIF EXP_DECL.TY = DN_number_decl then
      CODE_number_decl ( EXP_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_OBJECT_DECL ( OBJECT_DECL :TREE ) IS
  BEGIN
    DECLARE
      SRC_NAME_SEQ : SEQ_TYPE := LIST ( D ( AS_SOURCE_NAME_S, OBJECT_DECL ) );
      SRC_NAME     : TREE;
      TYPE_DEF     : TREE     := D ( AS_TYPE_DEF, OBJECT_DECL );
      TYPE_NAME    : TREE     := D ( AS_NAME, TYPE_DEF );
    BEGIN
      EMITS.TYPE_SYMREP := D ( LX_SYMREP, TYPE_NAME );
      WHILE NOT IS_EMPTY ( SRC_NAME_SEQ ) LOOP
        POP ( SRC_NAME_SEQ, SRC_NAME );
      CODE_VC_NAME ( SRC_NAME );
      END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_VC_NAME ( VC_NAME :TREE ) IS
  BEGIN
    DECLARE
      TYPE_SPEC : TREE := D ( SM_OBJ_TYPE, VC_NAME );
      --|---------------------------------------------------------------------------
      PROCEDURE COMPILE_VC_NAME_INTEGER ( VC_NAME :TREE ) IS
      BEGIN
        ALIGN ( INTG_AL );
        DECLARE
          LVL      : LEVEL_TYPE    := EMITS.LEVEL;
          OFS      : OFFSET_TYPE   := - EMITS.OFFSET_ACT;
          CPU      : COMP_UNIT_NBR := EMITS.CUR_COMP_UNIT;
          INIT_EXP : TREE          := D ( SM_INIT_EXP, VC_NAME );
        BEGIN
          DI ( CD_LEVEL, VC_NAME, LVL );
          DI ( CD_OFFSET, VC_NAME, OFS );
          DI ( CD_COMP_UNIT, VC_NAME, CPU );
          DB ( CD_COMPILED, VC_NAME, TRUE );
          INC_OFFSET ( INTG_SIZE );
          IF INIT_EXP /= TREE_VOID THEN
            CODE_EXP ( INIT_EXP );
            GEN_STORE ( I, CPU, LVL, OFS,
                      "STO " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " VAL INIT" );
          END IF;
        END;
      END COMPILE_VC_NAME_INTEGER;
      --|---------------------------------------------------------------------------
      PROCEDURE COMPILE_VC_NAME_ENUMERATION ( VC_NAME, TYPE_SPEC :TREE ) IS
        NAME             : CONSTANT STRING := PRINT_NAME ( EMITS.TYPE_SYMREP );
        PROCEDURE COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME :TREE; CT :CODE_TYPE; SIZ, ALI :NATURAL ) IS
        BEGIN
          ALIGN ( ALI );
          DECLARE
            LVL      : LEVEL_TYPE    := EMITS.LEVEL;
            OFS      : OFFSET_TYPE   := - EMITS.OFFSET_ACT;
            CPU      : COMP_UNIT_NBR := EMITS.CUR_COMP_UNIT;
            INIT_EXP : TREE          := D ( SM_INIT_EXP, VC_NAME );
          BEGIN
            DI ( CD_LEVEL, VC_NAME, LVL );
            DI ( CD_OFFSET, VC_NAME, OFS );
            DI ( CD_COMP_UNIT, VC_NAME, CPU );
            DB ( CD_COMPILED, VC_NAME, TRUE );
            INC_OFFSET ( SIZ );
            IF INIT_EXP /= TREE_VOID THEN
      CODE_EXP ( INIT_EXP );
            END IF;
            GEN_STORE ( CT, CPU, LVL, OFS,
                   PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " := VAL INIT" );
          END;
        END COMPILE_VC_NAME_BOOL_CHAR;
      BEGIN
        IF NAME = "BOOLEAN" THEN
          COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME, B, BOOL_SIZE, BOOL_AL );
        ELSIF NAME = "CHARACTER" THEN
          COMPILE_VC_NAME_BOOL_CHAR ( VC_NAME, C, CHAR_SIZE, CHAR_AL );
        ELSE
          COMPILE_VC_NAME_INTEGER ( VC_NAME );
        END IF;
      END COMPILE_VC_NAME_ENUMERATION;
      --|---------------------------------------------------------------------------
      PROCEDURE COMPILE_ACCESS_VAR ( VAR_ID, TYPE_SPEC :TREE ) IS
      BEGIN
        ALIGN ( ADDR_AL );
        DECLARE
          LVL : LEVEL_TYPE    := EMITS.LEVEL;
          OFS : OFFSET_TYPE   := - EMITS.OFFSET_ACT;
          CPU : COMP_UNIT_NBR := EMITS.CUR_COMP_UNIT;
        BEGIN
          DI ( CD_LEVEL, VAR_ID, LVL );
          DI ( CD_OFFSET, VAR_ID, OFS );
          DI ( CD_COMP_UNIT, VAR_ID, CPU );
          DB ( CD_COMPILED, VAR_ID, TRUE );
          INC_OFFSET ( ADDR_SIZE );
          DECLARE
            INIT_EXP : TREE := D ( SM_INIT_EXP, VAR_ID );
          BEGIN
            IF INIT_EXP = TREE_VOID THEN
              EMIT ( LDC, A, -1, "INIT NIL DE " & PRINT_NAME ( D (LX_SYMREP, VAR_ID ) ) );
            ELSE
              LOAD_TYPE_SIZE ( TYPE_SPEC  );
              EMIT ( ALO, LVL - DI ( CD_LEVEL, TYPE_SPEC ) );
            END IF;
          END;
          GEN_STORE ( A, CPU, LVL, OFS,
                   "STO " & PRINT_NAME ( D (LX_SYMREP, VAR_ID ) ) & " VAL INIT" );
        END;
      END COMPILE_ACCESS_VAR;
      --|---------------------------------------------------------------------------
      PROCEDURE COMPILE_ARRAY_VAR ( VC_NAME, TYPE_SPEC :TREE ) IS
        DESCR_PTR : OFFSET_TYPE;
      BEGIN
        ALIGN ( ADDR_AL );
        DECLARE
          LVL       : LEVEL_TYPE := EMITS.LEVEL;
          VALUE_PTR : OFFSET_TYPE := - EMITS.OFFSET_ACT;
          CPU       : COMP_UNIT_NBR := EMITS.CUR_COMP_UNIT;
        BEGIN
          DI ( CD_LEVEL, VC_NAME, LVL );
          DI ( CD_OFFSET, VC_NAME, VALUE_PTR );
          DI ( CD_COMP_UNIT, VC_NAME, CPU );
          DB ( CD_COMPILED, VC_NAME, TRUE );
          INC_OFFSET ( ADDR_SIZE );
          ALIGN ( ADDR_AL );
          DESCR_PTR := - EMITS.OFFSET_ACT;
          INC_OFFSET ( ADDR_SIZE );
          IF DB ( CD_COMPILED, TYPE_SPEC ) THEN
            GEN_LOAD_ADDR ( DI ( CD_COMP_UNIT, TYPE_SPEC ) , DI ( CD_LEVEL, TYPE_SPEC ), DI ( CD_OFFSET, TYPE_SPEC ) );
            EMIT ( DPL, A, "DUPLICATE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " ARRAY DESCRIPTOR TYPE_SPEC" );
            GEN_STORE ( A, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, DESCR_PTR, "STO ADRESSE DESCRIPTEUR" );
            EMIT ( IND, I, 0, "CHARGE INDEXE TAILLE TABLEAU DE DESCRIPTEUR" );
            EMIT ( ALO, INTEGER ( 0 ), COMMENT=> "ALLOC TABLEAU" );
            GEN_STORE ( A, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, VALUE_PTR, "STO ADRESSE TABLEAU ALLOUE" );
          ELSE
            PUT_LINE ( "!!! COMPILE_ARRAY_VAR : TYPE_SPEC NON COMPILE" );
            RAISE PROGRAM_ERROR;
          END IF;
        END;
      END COMPILE_ARRAY_VAR;
      --|---------------------------------------------------------------------------
      PROCEDURE COMPILE_RECORD_VAR ( VC_NAME, TYPE_SPEC :TREE ) IS
        INIT_EXP : TREE := D ( SM_INIT_EXP, VC_NAME );
      BEGIN
        ALIGN ( RECORD_AL );
        DECLARE
          LVL : LEVEL_TYPE    := EMITS.LEVEL;
          OFS : OFFSET_TYPE   := - EMITS.OFFSET_ACT;
          CPU : COMP_UNIT_NBR := EMITS.CUR_COMP_UNIT;
        BEGIN
          DI ( CD_LEVEL, VC_NAME, LVL );
          DI ( CD_OFFSET, VC_NAME, OFS );
          DI ( CD_COMP_UNIT, VC_NAME, CPU );
          DB ( CD_COMPILED, VC_NAME, TRUE );
          IF INIT_EXP.TY = DN_AGGREGATE THEN
            DECLARE
              GENERAL_ASSOC_SEQ : SEQ_TYPE := LIST ( D ( SM_NORMALIZED_COMP_S, INIT_EXP ) );
              COMP_EXP          : TREE;
            BEGIN
              WHILE NOT IS_EMPTY ( GENERAL_ASSOC_SEQ ) LOOP
                POP ( GENERAL_ASSOC_SEQ, COMP_EXP );
      CODE_EXP ( COMP_EXP );
              END LOOP;
            END;
          END IF;
        END;
      END COMPILE_RECORD_VAR;
      --|---------------------------------------------------------------------------
    BEGIN
      CASE TYPE_SPEC.TY IS
      WHEN DN_INTEGER =>
        COMPILE_VC_NAME_INTEGER ( VC_NAME );
      WHEN DN_ENUMERATION =>
        COMPILE_VC_NAME_ENUMERATION ( VC_NAME, TYPE_SPEC );
      WHEN DN_ACCESS =>
        COMPILE_ACCESS_VAR ( VC_NAME, TYPE_SPEC );
      WHEN DN_CONSTRAINED_ARRAY =>
        COMPILE_ARRAY_VAR ( VC_NAME, TYPE_SPEC );
      WHEN DN_RECORD =>
        COMPILE_RECORD_VAR ( VC_NAME, TYPE_SPEC );
      WHEN OTHERS =>
        PUT_LINE ( "!!! CODE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
        RAISE PROGRAM_ERROR;
      END CASE;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_variable_id ( variable_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_constant_id ( constant_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_number_decl ( number_decl :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_number_id ( number_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_source_name_s ( source_name_s :TREE ) IS
  BEGIN
    DECLARE
      source_name_seq : Seq_Type := LIST ( source_name_s );
      source_name : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( source_name_seq ) LOOP
        POP ( source_name_seq, source_name );
      CODE_source_name ( source_name );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_type_decl ( type_decl :TREE ) IS
  BEGIN
    DECLARE
      TYPE_DEF  : TREE := D ( AS_TYPE_DEF, TYPE_DECL );
      TYPE_ID   : TREE := D ( AS_SOURCE_NAME, TYPE_DECL );
      TYPE_SPEC : TREE := D ( SM_TYPE_SPEC, TYPE_ID );
      ------------------------------------------------------------------------------
      PROCEDURE COMPILE_ENUMERATION_DEF ( ENUMERATION_DEF :TREE ) IS
        ENUM_LITERAL_S  : TREE     := D ( AS_ENUM_LITERAL_S, ENUMERATION_DEF );
        LITERAL_SEQ     : SEQ_TYPE := LIST ( ENUM_LITERAL_S );
        LITERAL         : TREE;
      BEGIN
        WHILE NOT IS_EMPTY ( LITERAL_SEQ ) LOOP
          POP ( LITERAL_SEQ, LITERAL );
        END LOOP;
        DI ( CD_LAST, ENUM_LITERAL_S, DI ( SM_REP, LITERAL ) );
      END;
      ------------------------------------------------------------------------------
      PROCEDURE COMPILE_INTEGER_DEF ( INTEGER_DEF, INTEGER_SPEC :TREE ) IS
        LOWER      : OFFSET_TYPE;
        UPPER      : OFFSET_TYPE;
        INT_RANGE  : TREE := D ( AS_CONSTRAINT, INTEGER_DEF );
        EXP_BORNE  : TREE;
      BEGIN
        ALIGN ( INTG_AL );
        LOWER := - EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
        UPPER := - EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
        DI ( CD_OFFSET, INTEGER_SPEC, LOWER );
        DI ( CD_LEVEL, INTEGER_SPEC, EMITS.LEVEL );
        DI ( CD_COMP_UNIT, INTEGER_SPEC, CUR_COMP_UNIT );
        DB ( CD_COMPILED, INTEGER_SPEC, TRUE );
        EXP_BORNE := D ( AS_EXP1, INT_RANGE );
      CODE_EXP ( EXP_BORNE );
        GEN_STORE ( I, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, LOWER, "BORNE BASSE" );
        EXP_BORNE := D ( AS_EXP2, INT_RANGE );
      CODE_EXP ( EXP_BORNE );
        GEN_STORE ( I, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, UPPER, "BORNE HAUTE" );
      END COMPILE_INTEGER_DEF;
      ------------------------------------------------------------------------------
      PROCEDURE COMPILE_CONSTRAINED_ARRAY_DEF ( TYPE_DEF, TYPE_SPEC :TREE ) IS
        DIMENSIONS_NBR     : NATURAL  := 0;
        SUBTYPE_INDICATION : TREE     := D ( AS_SUBTYPE_INDICATION, TYPE_DEF );
        USED_NAME_ID       : TREE     := D ( AS_NAME, SUBTYPE_INDICATION );
        COMP_TYPE_ID       : TREE     := D ( SM_DEFN, USED_NAME_ID );
        COMP_TYPE          : TREE     := D ( SM_TYPE_SPEC, COMP_TYPE_ID );
        INDEX_CONSTRAINT   : TREE     := D ( AS_CONSTRAINT, TYPE_DEF );
        DISCRETE_RANGE_S   : TREE     := D ( AS_DISCRETE_RANGE_S, INDEX_CONSTRAINT );
        DISCRETE_RANGE_SEQ : SEQ_TYPE := LIST ( DISCRETE_RANGE_S );
        --|-------------------------------------------------------------------------------------------
        --|
        PROCEDURE INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ :IN OUT SEQ_TYPE ) IS
          IDXFAC, FIRST, LAST : OFFSET_TYPE;
          DISCRETE_RANGE      : TREE;
        BEGIN
          DIMENSIONS_NBR := DIMENSIONS_NBR + 1;
          ALIGN ( INTG_AL );
          IDXFAC := - EMITS.OFFSET_ACT;
          FIRST := IDXFAC - INTG_SIZE;
          LAST := FIRST - INTG_SIZE;
          INC_OFFSET ( 3*INTG_SIZE );
          POP ( DISCRETE_RANGE_SEQ, DISCRETE_RANGE );
          IF IS_EMPTY ( DISCRETE_RANGE_SEQ ) THEN
            EMITS.LOAD_TYPE_SIZE ( COMP_TYPE );
            EMIT ( DPL, I, "DUPLICATE INDEX FACTOR" );
            GEN_STORE ( I, 0, EMITS.LEVEL, IDXFAC, "STORE INDEX FACTOR" );
          ELSE
            INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ );
            EMIT ( DPL, I, "DUPLICATE INDEX FACTOR" );
            GEN_STORE ( I, 0, EMITS.LEVEL, IDXFAC, "STORE INDEX FACTOR" );
          END IF;
          IF DISCRETE_RANGE.TY = DN_DISCRETE_SUBTYPE THEN
            DECLARE
              SUBTYPE_INDICATION : TREE := D ( AS_SUBTYPE_INDICATION, DISCRETE_RANGE );
            BEGIN
              DISCRETE_RANGE := D ( AS_CONSTRAINT, SUBTYPE_INDICATION );
              IF DISCRETE_RANGE.TY = DN_VOID THEN
                DECLARE
                  USED_NAME_ID : TREE := D ( AS_NAME, SUBTYPE_INDICATION );
                  DEF_NAME     : TREE := D ( SM_DEFN, USED_NAME_ID );
                  TYPE_SPEC    : TREE := D ( SM_TYPE_SPEC, DEF_NAME );
                BEGIN
                  DISCRETE_RANGE := D ( SM_RANGE, TYPE_SPEC );
                END;
              END IF;
            END;
          END IF;
          IF DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE THEN
            DECLARE
              TYPE_SPEC : TREE := D ( SM_TYPE_SPEC, DISCRETE_RANGE );
            BEGIN
              DISCRETE_RANGE := D ( SM_RANGE, TYPE_SPEC );
            END;
          END IF;
          IF DISCRETE_RANGE.TY = DN_RANGE THEN
            DECLARE
              EXP_BORNE : TREE := D ( AS_EXP1, DISCRETE_RANGE );
            BEGIN
      CODE_EXP ( EXP_BORNE );
              GEN_STORE ( I, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, FIRST, "FIRST" );
              EXP_BORNE := D ( AS_EXP2, DISCRETE_RANGE );
      CODE_EXP ( EXP_BORNE );
              GEN_STORE ( I, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, LAST, "LAST" );
            END;
            GEN_LOAD_ADDR ( 0, LEVEL, FIRST, "LOAD @FIRST" );
            EMIT ( LEN, "CALCULATE LENGTH" );
            EMIT ( MUL, I, "NEXT INDEX FACTOR = LEN * PREVIOUS FACTOR" );
          ELSIF DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE THEN
            NULL;
          ELSE
            NULL;      -- DN_RANGE_ATTRIBUTE -- DN_DISCRETE_SUBTYPE
            PUT_LINE ( "!!! COMPILE_TYPE_ARRAY_DIMENSION : DISCRETE_RANGE.TY ILLICITE " & NODE_NAME'IMAGE ( DISCRETE_RANGE.TY ) );
            RAISE PROGRAM_ERROR;
          END IF;
        END INSTALL_ARRAY_DIMENSION;
      BEGIN
        ALIGN ( INTG_AL );
        DI ( CD_LEVEL, TYPE_SPEC, EMITS.LEVEL );
        DI ( CD_COMP_UNIT, TYPE_SPEC, EMITS.CUR_COMP_UNIT );
        DB ( CD_COMPILED, TYPE_SPEC, TRUE );
        DECLARE
          OFFSET : INTEGER := - EMITS.OFFSET_ACT;
        BEGIN
          DI ( CD_OFFSET, TYPE_SPEC, OFFSET );
          INC_OFFSET ( INTG_SIZE );
          INSTALL_ARRAY_DIMENSION ( DISCRETE_RANGE_SEQ );
          GEN_STORE ( I, EMITS.CUR_COMP_UNIT, EMITS.LEVEL, OFFSET,
                 "STORE ARRAY SIZE (LAST INDEX FACTOR)" );
          DI ( CD_DIMENSIONS, TYPE_SPEC, DIMENSIONS_NBR );
        END;
      END COMPILE_CONSTRAINED_ARRAY_DEF;
      ------------------------------------------------------------------------------
      PROCEDURE COMPILE_ACCESS_DEF ( ACCESS_DEF, ACCESS_SPEC :TREE ) IS
        POINTED_TYPE_SPEC : TREE    := D ( SM_DESIG_TYPE, ACCESS_SPEC );
        CONTRAINT         : BOOLEAN := (POINTED_TYPE_SPEC.TY IN CLASS_CONSTRAINED);
      BEGIN
        DB ( CD_CONSTRAINED, ACCESS_SPEC, CONTRAINT );
        IF CONTRAINT THEN
          DI ( CD_LEVEL, ACCESS_SPEC, EMITS.LEVEL );
          ALIGN ( INTG_AL );
          DECLARE
            OFFSET : OFFSET_TYPE := EMITS.OFFSET_ACT;
          BEGIN
            DI ( CD_OFFSET, ACCESS_SPEC, OFFSET );
            INC_OFFSET ( INTG_SIZE );
            EMITS.LOAD_TYPE_SIZE ( POINTED_TYPE_SPEC );
            GEN_STORE ( I, 0, EMITS.LEVEL, OFFSET, "STORE POINTERD TYPE SIZE" );
          END;
        END IF;
      END;
      ------------------------------------------------------------------------------
    BEGIN
      IF EMITS.CUR_COMP_UNIT /= 1 THEN
        CASE TYPE_DEF.TY IS
        WHEN DN_ENUMERATION_DEF =>
          COMPILE_ENUMERATION_DEF ( TYPE_DEF );
        WHEN DN_INTEGER_DEF =>
          COMPILE_INTEGER_DEF ( TYPE_DEF, TYPE_SPEC );
        WHEN DN_FLOAT_DEF =>
          NULL;
        WHEN DN_FIXED_DEF =>
          NULL;
        WHEN DN_CONSTRAINED_ARRAY_DEF =>
          COMPILE_CONSTRAINED_ARRAY_DEF ( TYPE_DEF, TYPE_SPEC );
        WHEN DN_RECORD_DEF =>
          NULL;
        WHEN DN_ACCESS_DEF =>
          COMPILE_ACCESS_DEF ( TYPE_DEF, TYPE_SPEC );
        WHEN DN_DERIVED_DEF =>
          NULL;
        WHEN OTHERS =>
          NULL;
          RAISE PROGRAM_ERROR;
        END CASE;
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_TYPE_NAME ( TYPE_NAME :TREE ) IS
  BEGIN

    IF TYPE_NAME.TY = DN_type_id then
      CODE_type_id ( TYPE_NAME );

    ELSIF TYPE_NAME.TY = DN_subtype_id then
      CODE_subtype_id ( TYPE_NAME );

    ELSIF TYPE_NAME.TY = DN_private_type_id then
      CODE_private_type_id ( TYPE_NAME );

    ELSIF TYPE_NAME.TY = DN_l_private_type_id then
      CODE_l_private_type_id ( TYPE_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_type_id ( type_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subtype_decl ( subtype_decl :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subtype_id ( subtype_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ENUM_LITERAL ( ENUM_LITERAL :TREE ) IS
  BEGIN

    IF ENUM_LITERAL.TY = DN_enumeration_id then
      CODE_enumeration_id ( ENUM_LITERAL );

    ELSIF ENUM_LITERAL.TY = DN_character_id then
      CODE_character_id ( ENUM_LITERAL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_enumeration_id ( enumeration_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_character_id ( character_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_COMP_NAME ( COMP_NAME :TREE ) IS
  BEGIN

    IF COMP_NAME.TY = DN_component_id then
      CODE_component_id ( COMP_NAME );

    ELSIF COMP_NAME.TY = DN_discriminant_id then
      CODE_discriminant_id ( COMP_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_component_id ( component_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_discriminant_id ( discriminant_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_choice_s ( choice_s :TREE ) IS
  BEGIN
    DECLARE
      choice_seq : Seq_Type := LIST ( choice_s );
      choice : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( choice_seq ) LOOP
        POP ( choice_seq, choice );
      CODE_CHOICE ( choice );
    IF NOT CHOICE_OTHERS_FLAG THEN
       EMIT ( JMPT, LABEL_TYPE ( DI ( CD_LABEL, CHOICE_S ) ), COMMENT=> "TRAITE EXCEPTION" );
    END IF;
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_CHOICE ( CHOICE :TREE ) IS
  BEGIN

    IF CHOICE.TY = DN_choice_exp then
      CODE_choice_exp ( CHOICE );

    ELSIF CHOICE.TY = DN_choice_range then
      CODE_choice_range ( CHOICE );

    ELSIF CHOICE.TY = DN_choice_others then
      CODE_choice_others ( CHOICE );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_choice_exp ( choice_exp :TREE ) IS
  BEGIN
      CODE_EXP ( D ( as_EXP, choice_exp ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_choice_range ( choice_range :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_choice_others ( choice_others :TREE ) IS
  BEGIN
    choice_Others_Flag := true;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ITEM ( ITEM :TREE ) IS
  BEGIN

    IF ITEM.TY IN CLASS_DECL then
      CODE_DECL ( ITEM );

    ELSIF ITEM.TY IN CLASS_SUBUNIT_BODY then
      CODE_SUBUNIT_BODY ( ITEM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_item_s ( item_s :TREE ) IS
  BEGIN
    DECLARE
      item_seq : Seq_Type := LIST ( item_s );
      item : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( item_seq ) LOOP
        POP ( item_seq, item );
      CODE_ITEM ( item );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_UNIT_DECL ( UNIT_DECL :TREE ) IS
  BEGIN

    IF UNIT_DECL.TY = DN_generic_decl then
      CODE_generic_decl ( UNIT_DECL );

    ELSIF UNIT_DECL.TY IN CLASS_NON_GENERIC_DECL then
      CODE_NON_GENERIC_DECL ( UNIT_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_NON_GENERIC_DECL ( NON_GENERIC_DECL :TREE ) IS
  BEGIN

    IF NON_GENERIC_DECL.TY = DN_subprog_entry_decl then
      CODE_subprog_entry_decl ( NON_GENERIC_DECL );

    ELSIF NON_GENERIC_DECL.TY = DN_package_decl then
      CODE_package_decl ( NON_GENERIC_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_NAME ( NAME :TREE ) IS
  BEGIN

    IF NAME.TY IN CLASS_DESIGNATOR then
      CODE_DESIGNATOR ( NAME );

    ELSIF NAME.TY IN CLASS_NAME_EXP then
      CODE_NAME_EXP ( NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_NAME_EXP ( NAME_EXP :TREE ) IS
  BEGIN

    IF NAME_EXP.TY = DN_indexed then
      CODE_indexed ( NAME_EXP );

    ELSIF NAME_EXP.TY = DN_slice then
      CODE_slice ( NAME_EXP );

    ELSIF NAME_EXP.TY = DN_all then
      CODE_all ( NAME_EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_DESIGNATOR ( DESIGNATOR :TREE ) IS
  BEGIN

    IF DESIGNATOR.TY IN CLASS_USED_OBJECT then
      CODE_USED_OBJECT ( DESIGNATOR );

    ELSIF DESIGNATOR.TY IN CLASS_USED_NAME then
      CODE_USED_NAME ( DESIGNATOR );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_USED_NAME ( USED_NAME :TREE ) IS
  BEGIN

    IF USED_NAME.TY = DN_used_op then
      CODE_used_op ( USED_NAME );

    ELSIF USED_NAME.TY = DN_used_name_id then
      CODE_used_name_id ( USED_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_used_op ( used_op :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_used_name_id ( used_name_id :TREE ) IS
  BEGIN
    DECLARE
      DEFN   : TREE := D ( SM_DEFN, USED_NAME_ID );
      SYMREP : TREE := D ( LX_SYMREP, USED_NAME_ID );
    BEGIN
      IF DEFN.TY = DN_EXCEPTION_ID THEN
        DECLARE
          LABEL : TREE := D ( CD_LABEL, DEFN );
          LBL : LABEL_TYPE;
        BEGIN
          IF LABEL.TY /= DN_NUM_VAL THEN
            LBL := NEXT_LABEL;
            DI ( CD_LABEL, DEFN, INTEGER ( LBL ) );
            EMIT ( EXL, LBL, S=> PRINT_NAME ( SYMREP ),
    COMMENT=> "NUM D EXCEPTION EXTERNE ATTRIBUE SUR USED_NAME_ID" );
          END IF;
          EMIT ( DPL, I, COMMENT=> "CODE D EXCEPTION EMPILE" );
          EMIT ( LDC, I, DI ( CD_LABEL, DEFN ), COMMENT=> "EXCEPTION " & PRINT_NAME ( SYMREP ));
          EMIT ( EQ, I );
        END;
      ELSIF DEFN.TY = DN_PACKAGE_ID THEN
        IF NOT DB ( CD_COMPILED, DEFN ) THEN
          DECLARE
            PACKAGE_SPEC : TREE := D ( SM_SPEC, DEFN );
          BEGIN
            EMIT ( RFP, EMITS.CUR_COMP_UNIT, s=> PRINT_NAME ( SYMREP ) );
            EMITS.GENERATE_CODE := FALSE;
            DB ( CD_COMPILED, DEFN, TRUE );
      CODE_decl_s ( D ( as_DECL_S1, package_Spec ) );
          END;
        END IF;
        EMITS.CUR_COMP_UNIT := CUR_COMP_UNIT + 1;
      ELSIF DEFN.TY = DN_PROCEDURE_ID THEN
        IF NOT DB ( CD_COMPILED, DEFN ) THEN
          DECLARE
            PROC_LBL : LABEL_TYPE := NEXT_LABEL;
          BEGIN
            EMITS.GENERATE_CODE := TRUE;
            EMIT ( RFP, INTEGER( 0 ), s=> PRINT_NAME ( SYMREP ) );
            DI ( CD_LABEL, DEFN, INTEGER ( PROC_LBL ) );
            DI ( CD_LEVEL, DEFN, 1 );
            DI ( CD_PARAM_SIZE, DEFN, 0 );
            DB ( CD_COMPILED, DEFN, TRUE );
            EMIT ( RFL, PROC_LBL );
          END;
        END IF;
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_USED_OBJECT ( USED_OBJECT :TREE ) IS
  BEGIN

    IF USED_OBJECT.TY = DN_used_char then
      CODE_used_char ( USED_OBJECT );

    ELSIF USED_OBJECT.TY = DN_used_object_id then
      CODE_used_object_id ( USED_OBJECT );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_used_char ( used_char :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_used_object_id ( used_object_id :TREE ) IS
  BEGIN
        NULL;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_INDEXED ( INDEXED :TREE ) IS
  BEGIN
    DECLARE
      PROCEDURE INDEX ( EXP_SEQ :SEQ_TYPE ) IS
        EXP_S : SEQ_TYPE := EXP_SEQ;
        EXP   : TREE;
      BEGIN
        POP ( EXP_S, EXP );
      CODE_EXP ( EXP );
        IF IS_EMPTY ( EXP_S ) THEN
          EMIT ( AR2, "ADRESSE POUR LE DERNIER INDICE (RAPIDE)" );
        ELSE
          EMIT ( AR1, "ADRESSE POUR INDICE INTERMEDIAIRE" );
          EMIT ( DEC, A, 3*INTG_SIZE, "PTR DESCRIPTEUR AU TRIPLET INDICE SUIVANT" );
          INDEX ( EXP_S );
          EMIT ( ADD, I, "AJOUTER LE DECALAGE A L ADRESSE DES INDICES PRECEDENTS" );
        END IF;
      END INDEX;
    BEGIN
      CODE_OBJECT ( D ( AS_NAME, INDEXED ) );
      EMIT ( DPL, A, "DUP ADRESS OBJET" );
      EMIT ( IND, A, 0, "CHARGE INDEXE D ADRESSE TABLEAU" );
      EMIT ( SWP, A, "ADRESSE OBJET AU TOP" );
      EMIT ( IND, A, -addr_Size, "CHARGE INDEXE ADRESSE DU DESCRIPTEUR TABLEAU" );
      EMIT ( DEC, A, INTG_SIZE, "ADRESSE DESCRIPTEUR - TAILLE ENTIER" );
      DECLARE
        EXP_SEQ : SEQ_TYPE := LIST ( D ( AS_EXP_S, INDEXED ) );
      BEGIN
        IF NOT IS_EMPTY ( EXP_SEQ ) THEN
         INDEX ( EXP_SEQ );
        END IF;
      END;
      EMIT ( IXA, INTEGER ( 1 ) );
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_slice ( slice :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_all ( ADA_all :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_aggregate ( aggregate :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_short_circuit ( short_circuit :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_MEMBERSHIP ( MEMBERSHIP :TREE ) IS
  BEGIN

    IF MEMBERSHIP.TY = DN_range_membership then
      CODE_range_membership ( MEMBERSHIP );

    ELSIF MEMBERSHIP.TY = DN_type_membership then
      CODE_type_membership ( MEMBERSHIP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_range_membership ( range_membership :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_type_membership ( type_membership :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_EXP ( EXP :TREE ) IS
  BEGIN

    IF EXP.TY IN CLASS_NAME then
      CODE_NAME ( EXP );

    ELSIF EXP.TY IN CLASS_EXP_EXP then
      CODE_EXP_EXP ( EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_EXP_EXP ( EXP_EXP :TREE ) IS
  BEGIN

    IF EXP_EXP.TY IN CLASS_EXP_VAL then
      CODE_EXP_VAL ( EXP_EXP );

    ELSIF EXP_EXP.TY IN CLASS_AGG_EXP then
      CODE_AGG_EXP ( EXP_EXP );

    ELSIF EXP_EXP.TY = DN_qualified_allocator then
      CODE_qualified_allocator ( EXP_EXP );

    ELSIF EXP_EXP.TY = DN_subtype_allocator then
      CODE_subtype_allocator ( EXP_EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_EXP_VAL ( EXP_VAL :TREE ) IS
  BEGIN

    IF EXP_VAL.TY IN CLASS_EXP_VAL_EXP then
      CODE_EXP_VAL_EXP ( EXP_VAL );

    ELSIF EXP_VAL.TY = DN_numeric_literal then
      CODE_numeric_literal ( EXP_VAL );

    ELSIF EXP_VAL.TY = DN_null_access then
      CODE_null_access ( EXP_VAL );

    ELSIF EXP_VAL.TY = DN_short_circuit then
      CODE_short_circuit ( EXP_VAL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_EXP_VAL_EXP ( EXP_VAL_EXP :TREE ) IS
  BEGIN

    IF EXP_VAL_EXP.TY IN CLASS_QUAL_CONV then
      CODE_QUAL_CONV ( EXP_VAL_EXP );

    ELSIF EXP_VAL_EXP.TY IN CLASS_MEMBERSHIP then
      CODE_MEMBERSHIP ( EXP_VAL_EXP );

    ELSIF EXP_VAL_EXP.TY = DN_parenthesized then
      CODE_parenthesized ( EXP_VAL_EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_AGG_EXP ( AGG_EXP :TREE ) IS
  BEGIN

    IF AGG_EXP.TY = DN_aggregate then
      CODE_aggregate ( AGG_EXP );

    ELSIF AGG_EXP.TY = DN_string_literal then
      CODE_string_literal ( AGG_EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_parenthesized ( parenthesized :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_numeric_literal ( numeric_literal :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_string_literal ( string_literal :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_null_access ( null_access :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_QUAL_CONV ( QUAL_CONV :TREE ) IS
  BEGIN

    IF QUAL_CONV.TY = DN_conversion then
      CODE_conversion ( QUAL_CONV );

    ELSIF QUAL_CONV.TY = DN_qualified then
      CODE_qualified ( QUAL_CONV );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_conversion ( conversion :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_qualified ( qualified :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_qualified_allocator ( qualified_allocator :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subtype_allocator ( subtype_allocator :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_stm_s ( stm_s :TREE ) IS
  BEGIN
    DECLARE
      stm_seq : Seq_Type := LIST ( stm_s );
      stm_elem : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( stm_seq ) LOOP
        POP ( stm_seq, stm_elem );
      CODE_STM_ELEM ( stm_elem );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_STM_ELEM ( STM_ELEM :TREE ) IS
  BEGIN

    IF STM_ELEM.TY IN CLASS_STM then
      CODE_STM ( STM_ELEM );

    ELSIF STM_ELEM.TY = DN_stm_pragma then
      CODE_stm_pragma ( STM_ELEM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_stm_pragma ( stm_pragma :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_STM ( STM :TREE ) IS
  BEGIN

    IF STM.TY = DN_labeled then
      CODE_labeled ( STM );

    ELSIF STM.TY = DN_null_stm then
      CODE_null_stm ( STM );

    ELSIF STM.TY = DN_accept then
      CODE_accept ( STM );

    ELSIF STM.TY = DN_terminate then
      CODE_terminate ( STM );

    ELSIF STM.TY = DN_abort then
      CODE_abort ( STM );

    ELSIF STM.TY IN CLASS_CLAUSES_STM then
      CODE_CLAUSES_STM ( STM );

    ELSIF STM.TY IN CLASS_BLOCK_LOOP then
      CODE_BLOCK_LOOP ( STM );

    ELSIF STM.TY IN CLASS_ENTRY_STM then
      CODE_ENTRY_STM ( STM );

    ELSIF STM.TY IN CLASS_STM_WITH_NAME then
      CODE_STM_WITH_NAME ( STM );

    ELSIF STM.TY IN CLASS_STM_WITH_EXP then
      CODE_STM_WITH_EXP ( STM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_labeled ( labeled :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_STM_WITH_EXP ( STM_WITH_EXP :TREE ) IS
  BEGIN

    IF STM_WITH_EXP.TY = DN_return then
      CODE_return ( STM_WITH_EXP );

    ELSIF STM_WITH_EXP.TY = DN_delay then
      CODE_delay ( STM_WITH_EXP );

    ELSIF STM_WITH_EXP.TY = DN_case then
      CODE_case ( STM_WITH_EXP );

    ELSIF STM_WITH_EXP.TY IN CLASS_STM_WITH_EXP_NAME then
      CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_STM_WITH_EXP_NAME ( STM_WITH_EXP_NAME :TREE ) IS
  BEGIN

    IF STM_WITH_EXP_NAME.TY = DN_code then
      CODE_code ( STM_WITH_EXP_NAME );

    ELSIF STM_WITH_EXP_NAME.TY = DN_assign then
      CODE_assign ( STM_WITH_EXP_NAME );

    ELSIF STM_WITH_EXP_NAME.TY = DN_exit then
      CODE_exit ( STM_WITH_EXP_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_STM_WITH_NAME ( STM_WITH_NAME :TREE ) IS
  BEGIN

    IF STM_WITH_NAME.TY = DN_goto then
      CODE_goto ( STM_WITH_NAME );

    ELSIF STM_WITH_NAME.TY = DN_raise then
      CODE_raise ( STM_WITH_NAME );

    ELSIF STM_WITH_NAME.TY IN CLASS_CALL_STM then
      CODE_CALL_STM ( STM_WITH_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_CALL_STM ( CALL_STM :TREE ) IS
  BEGIN

    IF CALL_STM.TY = DN_procedure_call then
      CODE_procedure_call ( CALL_STM );

    ELSIF CALL_STM.TY = DN_entry_call then
      CODE_entry_call ( CALL_STM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_CLAUSES_STM ( CLAUSES_STM :TREE ) IS
  BEGIN

    IF CLAUSES_STM.TY = DN_if then
      CODE_if ( CLAUSES_STM );

    ELSIF CLAUSES_STM.TY = DN_selective_wait then
      CODE_selective_wait ( CLAUSES_STM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_LABEL_NAME ( LABEL_NAME :TREE ) IS
  BEGIN

    IF LABEL_NAME.TY = DN_label_id then
      CODE_label_id ( LABEL_NAME );

    ELSIF LABEL_NAME.TY = DN_block_loop_id then
      CODE_block_loop_id ( LABEL_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_label_id ( label_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_null_stm ( null_stm :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_OBJECT ( OBJECT :TREE ) IS
  BEGIN
      CASE OBJECT.TY IS
       WHEN DN_VARIABLE_ID =>
          GEN_LOAD_ADDR ( DI (CD_COMP_UNIT, OBJECT ), DI ( CD_LEVEL, OBJECT ), DI ( CD_OFFSET, OBJECT ),
                      "EMPILE ADRESSE DE VARIABLE" );
       WHEN DN_IN_ID =>
         EMIT ( LDA, LEVEL - DI ( CD_LEVEL, OBJECT ), DI ( CD_OFFSET, OBJECT ),
                      "EMPILE ADRESSE DE PARAM IN" );
       WHEN DN_IN_OUT_ID | DN_OUT_ID =>
         EMIT ( LDA, LEVEL - DI ( CD_LEVEL, OBJECT ), DI ( CD_VAL_OFFSET, OBJECT ),
                      "EMPILE ADRESSE PARAM IN_OUT/OUT" );
       WHEN DN_INDEXED =>
         CODE_INDEXED ( OBJECT );
       WHEN DN_USED_OBJECT_ID =>
         CODE_OBJECT ( D ( SM_DEFN, OBJECT ) );
       WHEN OTHERS =>
         PUT_LINE ( "!!! LOAD_OBJECT_ADDRESS : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( OBJECT.TY ) );
         RAISE PROGRAM_ERROR;
      END CASE;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ADRESSE ( ADRESSE :TREE ) IS
  BEGIN
    CASE ADRESSE.TY is
    WHEN DN_VARIABLE_ID =>
      GEN_LOAD ( A, DI (CD_COMP_UNIT, ADRESSE ), DI ( CD_LEVEL, ADRESSE ), DI ( CD_OFFSET, ADRESSE ) );
    WHEN DN_IN_ID =>
      GEN_LOAD ( A, 0,  DI ( CD_LEVEL, ADRESSE ), DI ( CD_OFFSET, ADRESSE ) );
    WHEN DN_IN_OUT_ID | DN_OUT_ID =>
      GEN_LOAD ( A, 0, DI ( CD_LEVEL, ADRESSE ), DI ( CD_VAL_OFFSET, ADRESSE ) );
    WHEN DN_INDEXED =>
      CODE_INDEXED ( ADRESSE );
    WHEN DN_USED_OBJECT_ID =>
      CODE_ADRESSE ( D ( SM_DEFN, ADRESSE ) );
    WHEN OTHERS =>
    PUT_LINE ( "!!! CODE_ADRESSE : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( ADRESSE.TY ) );
      RAISE PROGRAM_ERROR;
    END CASE;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_assign ( assign :TREE ) IS
  BEGIN
    DECLARE
      NAME : TREE := D ( AS_NAME, ASSIGN );
      PROCEDURE STORE_VAL ( TYPE_SPEC :TREE ) IS
      BEGIN
        CASE TYPE_SPEC.TY IS
        WHEN DN_ACCESS =>
          EMIT ( STO, A );
        WHEN DN_ENUMERATION =>
          DECLARE
            TYPE_SOURCE_NAME : TREE            := D ( XD_SOURCE_NAME, TYPE_SPEC );
            TYPE_SYMREP      : TREE            := D ( LX_SYMREP, TYPE_SOURCE_NAME );
            NAME             : CONSTANT STRING := PRINT_NAME ( TYPE_SYMREP );
          BEGIN
            IF NAME = "BOOLEAN" THEN EMIT ( STO, B );
            ELSIF NAME = "CHARACTER" THEN EMIT ( STO, C );
            ELSE EMIT ( STO, I );
            END IF;
          END;
        WHEN DN_INTEGER =>
          EMIT ( STO, I );
        WHEN DN_UNIVERSAL_INTEGER =>
          DECLARE
            COMP_UNIT : COMP_UNIT_NBR := DI ( CD_COMP_UNIT, TYPE_SPEC );
            LVL       : LEVEL_TYPE    := DI ( CD_LEVEL, TYPE_SPEC );
            OFS       : INTEGER       := DI ( CD_OFFSET, TYPE_SPEC );
          BEGIN
            GEN_LOAD_ADDR ( COMP_UNIT, LVL, OFS );
            EMIT ( CVB );
            EMIT ( STO, I );
          END;
        WHEN OTHERS =>
          PUT_LINE ( "!!! STORE_VAL TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
          RAISE PROGRAM_ERROR;
        END CASE;
      END STORE_VAL;
    BEGIN
      --|---------------------------------------------------------------------------
      IF NAME.TY = DN_ALL THEN
        CODE_ADRESSE ( D ( AS_NAME, NAME ) );
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
        STORE_VAL ( D ( SM_EXP_TYPE, NAME ) );
      --|---------------------------------------------------------------------------
      ELSIF NAME.TY = DN_INDEXED THEN
        CODE_INDEXED ( NAME );
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
        STORE_VAL ( D ( SM_EXP_TYPE, NAME ) );
      --|---------------------------------------------------------------------------
      ELSIF NAME.TY = DN_USED_OBJECT_ID THEN
        DECLARE
          NAMEXP    : TREE := D ( SM_EXP_TYPE, NAME );
          DEFN      : TREE := D ( SM_DEFN, NAME );
          COMP_UNIT : COMP_UNIT_NBR;
          LVL       : LEVEL_TYPE;
          OFS       : OFFSET_TYPE;
        BEGIN
          --|-----------------------------------------------------------------------
          IF NAMEXP.TY = DN_ACCESS THEN
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
            EMITS.GET_CLO ( DEFN, COMP_UNIT, LVL, OFS );
            EMITS.GEN_STORE ( A, COMP_UNIT, LVL, OFS );
          --|-----------------------------------------------------------------------
          ELSIF NAMEXP.TY = DN_ARRAY THEN
            CODE_OBJECT ( DEFN );
            DECLARE
              EXP : TREE := D ( AS_EXP, ASSIGN );
            BEGIN
              IF EXP.TY = DN_USED_OBJECT_ID THEN
                CODE_OBJECT ( D ( SM_DEFN, EXP ) );
                CODE_OBJECT( EXP );
                EMIT ( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
                EMIT ( CYA );
              ELSE
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
                EMIT ( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
                EMIT ( PUA );
              END IF;
            END;
          --|-----------------------------------------------------------------------
          ELSIF NAMEXP.TY = DN_ENUMERATION THEN
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
            EMITS.GET_CLO ( DEFN, COMP_UNIT, LVL, OFS );
            DECLARE
              CT : CODE_TYPE := CODE_TYPE_OF ( NAMEXP );
            BEGIN
              GEN_STORE ( CT, COMP_UNIT, LVL, OFS );
            END;
          --|-----------------------------------------------------------------------
          ELSIF NAMEXP.TY = DN_INTEGER THEN
      CODE_EXP ( D ( AS_EXP, ASSIGN ) );
            IF NAMEXP.TY /= DN_UNIVERSAL_INTEGER THEN
              EMITS.GET_CLO ( NAMEXP, COMP_UNIT, LVL, OFS );
              GEN_LOAD_ADDR ( COMP_UNIT, LVL, OFS );
              EMIT ( CVB );
            END IF;
            EMITS.GET_CLO ( DEFN, COMP_UNIT, LVL, OFS );
            EMITS.GEN_STORE ( I, COMP_UNIT, LVL, OFS );
          END IF;
        END;
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_if ( ADA_if :TREE ) IS
  BEGIN
    DECLARE
      OLD_AFTER_IF_LBL : LABEL_TYPE := EMITS.AFTER_IF_LBL;
    BEGIN
      EMITS.AFTER_IF_LBL := NEXT_LABEL;
      CODE_test_clause_elem_s ( D ( as_test_clause_elem_s, ADA_if ) );
      WRITE_LABEL ( EMITS.AFTER_IF_LBL, COMMENT=> "ETIQUETTE END IF" );
      EMITS.AFTER_IF_LBL := OLD_AFTER_IF_LBL;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_TEST_CLAUSE ( TEST_CLAUSE :TREE ) IS
  BEGIN

    IF TEST_CLAUSE.TY = DN_cond_clause then
      CODE_cond_clause ( TEST_CLAUSE );

    ELSIF TEST_CLAUSE.TY = DN_select_alternative then
      CODE_select_alternative ( TEST_CLAUSE );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_cond_clause ( cond_clause :TREE ) IS
  BEGIN
    DECLARE
      EXP : TREE := D ( AS_EXP, COND_CLAUSE );
      NEXT_CLAUSE_LBL : LABEL_TYPE;
    BEGIN
      CODE_exp ( exp );
      NEXT_CLAUSE_LBL := NEXT_LABEL;
      EMIT ( JMPF, NEXT_CLAUSE_LBL, COMMENT=> "NON CONDITION SAUT CLAUSE SUIVANTE" );
      CODE_stm_s ( D ( as_STM_S, cond_clause ) );
      EMIT ( JMP, EMITS.AFTER_IF_LBL, COMMENT=> "SAUT END IF" );
      WRITE_LABEL ( NEXT_CLAUSE_LBL, COMMENT=> "LBL CONDITION SUIVANTE" );
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ALTERNATIVE_ELEM ( ALTERNATIVE_ELEM :TREE ) IS
  BEGIN

    IF ALTERNATIVE_ELEM.TY = DN_alternative then
      CODE_alternative ( ALTERNATIVE_ELEM );

    ELSIF ALTERNATIVE_ELEM.TY = DN_alternative_pragma then
      CODE_alternative_pragma ( ALTERNATIVE_ELEM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_case ( ADA_case :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_alternative_s ( alternative_s :TREE ) IS
  BEGIN
    DECLARE
      alternative_seq : Seq_Type := LIST ( alternative_s );
      alternative_elem : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( alternative_seq ) LOOP
        POP ( alternative_seq, alternative_elem );
      CODE_ALTERNATIVE_ELEM ( alternative_elem );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_alternative ( alternative :TREE ) IS
  BEGIN
    DECLARE
      SKIP_LBL          : LABEL_TYPE := NEXT_LABEL;
      HANDLER_BEGIN_LBL : LABEL_TYPE := NEXT_LABEL;
      CHOICE_S          : TREE       := D ( AS_CHOICE_S, ALTERNATIVE );
    BEGIN
      DI ( CD_LABEL, CHOICE_S, INTEGER ( HANDLER_BEGIN_LBL ) );
      CODE_choice_s ( choice_s );
      IF NOT CHOICE_OTHERS_FLAG THEN
        EMIT ( JMP, SKIP_LBL, COMMENT=> "SKIP ALTERNATIVE SUIVANTE"  );
        WRITE_LABEL ( HANDLER_BEGIN_LBL, COMMENT=> "LABEL DEBUT INSTRUCTIONS" );
      END IF;
      CODE_stm_s ( D ( as_STM_S, alternative ) );
      IF NOT CHOICE_OTHERS_FLAG THEN
        WRITE_LABEL ( SKIP_LBL, COMMENT=> "ALTERNATIVE SUIVANTE" );
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_alternative_pragma ( alternative_pragma :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_BLOCK_LOOP ( BLOCK_LOOP :TREE ) IS
  BEGIN

    IF BLOCK_LOOP.TY = DN_loop then
      CODE_loop ( BLOCK_LOOP );

    ELSIF BLOCK_LOOP.TY = DN_block then
      CODE_block ( BLOCK_LOOP );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_block_loop_id ( block_loop_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ITERATION ( ITERATION :TREE ) IS
  BEGIN

    IF ITERATION.TY IN CLASS_FOR_REV then
      CODE_FOR_REV ( ITERATION );

    ELSIF ITERATION.TY = DN_while then
      CODE_while ( ITERATION );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_loop ( ADA_loop :TREE ) IS
  BEGIN
    DECLARE
      OLD_LOOP_STM_S          : TREE := EMITS.LOOP_STM_S;
      OLD_BEFORE_LOOP_LBL : LABEL_TYPE := EMITS.BEFORE_LOOP_LBL;
      OLD_AFTER_LOOP_LBL  : LABEL_TYPE := EMITS.AFTER_LOOP_LBL;
    BEGIN
      LOOP_STM_S := D ( as_STM_S, ADA_LOOP );
      EMITS.BEFORE_LOOP_LBL := NEXT_LABEL;
      EMITS.AFTER_LOOP_LBL := NEXT_LABEL;
      DI ( CD_AFTER_LOOP, ADA_LOOP, INTEGER( after_Loop_Lbl) );
      DI ( CD_LEVEL, ADA_LOOP, EMITS.LEVEL );
      DECLARE
        ITERATION : TREE := D ( AS_ITERATION, ADA_LOOP );
      BEGIN
        IF ITERATION = TREE_VOID then
          WRITE_LABEL ( BEFORE_LOOP_LBL );
      CODE_stm_s ( LOOP_STM_S );
          EMIT ( JMP, BEFORE_LOOP_LBL );
        ELSE
      CODE_ITERATION ( D ( as_iteration, ada_loop ) );
        END IF;
      END;
      WRITE_LABEL ( after_Loop_Lbl );
      EMITS.BEFORE_LOOP_LBL := OLD_BEFORE_LOOP_LBL;
      EMITS.AFTER_LOOP_LBL := OLD_AFTER_LOOP_LBL;
      EMITS.LOOP_STM_S := OLD_LOOP_STM_S;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_FOR_REV ( FOR_REV :TREE ) IS
  BEGIN
    DECLARE
      OLD_LOOP_OP_INC_DEC   : OP_CODE      := EMITS.LOOP_OP_INC_DEC;
      OLD_LOOP_OP_GT_LT     : OP_CODE      := EMITS.LOOP_OP_GT_LT;
      COUNTER, TEMP         : INTEGER;
      OLD_OFFSET_ACT        : OFFSET_TYPE  := EMITS.OFFSET_ACT;
      ITERATION_ID          : TREE         := D ( AS_SOURCE_NAME, FOR_REV );
      aCT                   : CODE_TYPE    := EMITS.CODE_TYPE_OF ( D ( SM_OBJ_TYPE, ITERATION_ID ) );
      PROCEDURE LOAD_DSCRT_RANGE ( DSCRT_RANGE : TREE ) IS
      BEGIN
        NULL;
      END;
    BEGIN
      EMITS.BEFORE_LOOP_LBL := NEXT_LABEL;
      EMITS.AFTER_LOOP_LBL := NEXT_LABEL;

    IF FOR_REV.TY = DN_for then
      CODE_for ( FOR_REV );

    ELSIF FOR_REV.TY = DN_reverse then
      CODE_reverse ( FOR_REV );

    END IF;
      CASE aCT IS
      WHEN B =>
        ALIGN ( Bool_Al );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( Bool_Size);
        ALIGN ( Bool_Al);
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( Bool_Size );
      WHEN C =>
        ALIGN ( Char_Al );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( Char_Size );
        ALIGN ( Char_Al);
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( Char_Size );
      WHEN I =>
        ALIGN ( INTG_Al );
        COUNTER := -EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
        ALIGN ( INTG_Al );
        TEMP := -EMITS.OFFSET_ACT;
        INC_OFFSET ( INTG_SIZE );
      WHEN A =>
        PUT_LINE ( "!!! compile_stm_loop_reverse aCT illicite " & Code_Type'IMAGE ( aCT ) );
        RAISE PROGRAM_ERROR;
      END CASE;
      DI ( CD_LEVEL, ITERATION_ID, EMITS.LEVEL );
      DI ( CD_OFFSET, ITERATION_ID, COUNTER );
      LOAD_DSCRT_RANGE ( D ( as_DISCRETE_RANGE, FOR_REV ) );
      EMIT ( STR, aCT, 0, TEMP );
      WRITE_LABEL ( EMITS.BEFORE_LOOP_LBL );
      EMIT ( STR, aCT, 0, COUNTER );
      EMIT ( LOD, aCT, 0, COUNTER );
      EMIT ( LOD, aCT, 0, TEMP );
      EMIT ( EMITS.LOOP_OP_GT_LT, aCT );
      EMIT ( JMPT, EMITS.AFTER_LOOP_LBL );
      CODE_stm_s ( LOOP_STM_S );
      EMIT ( LOD, aCT, 0, COUNTER );
      EMIT ( EMITS.LOOP_OP_INC_DEC, aCT, 1 );
      EMIT ( JMP, EMITS.BEFORE_LOOP_LBL );
      WRITE_LABEL ( EMITS.AFTER_LOOP_LBL );
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
      EMITS.LOOP_OP_INC_DEC := OLD_LOOP_OP_INC_DEC;
      EMITS.LOOP_OP_GT_LT := OLD_LOOP_OP_GT_LT;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_for ( ADA_for :TREE ) IS
  BEGIN
    LOOP_OP_INC_DEC := INC;
    LOOP_OP_GT_LT := GT;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_reverse ( ADA_reverse :TREE ) IS
  BEGIN
    LOOP_OP_INC_DEC := DEC;
    LOOP_OP_GT_LT := LT;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_iteration_id ( iteration_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_while ( ADA_while :TREE ) IS
  BEGIN
    BEFORE_LOOP_LBL := NEXT_LABEL;
    AFTER_LOOP_LBL := NEXT_LABEL;
    WRITE_LABEL ( BEFORE_LOOP_LBL );
      CODE_EXP ( D ( as_EXP, ADA_WHILE ) );
    EMIT ( JMPF, AFTER_LOOP_LBL );
      CODE_stm_s ( LOOP_STM_S );
    EMIT ( JMP, BEFORE_LOOP_LBL );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_block ( block :TREE ) IS
  BEGIN
    DECLARE
      AFTER_BLOCK_LBL : LABEL_TYPE := NEXT_LABEL;
      PROC_LBL        : LABEL_TYPE := NEXT_LABEL;
    BEGIN
      EMIT ( MST, INTEGER ( 0 ), INTEGER( 0 ), COMMENT=> "POUR BLOC" );
      EMIT ( CALL, EMITS.RELATIVE_RESULT_OFFSET, PROC_LBL,
             COMMENT=> "APPEL DE BLOC" );
      EMIT ( JMP, AFTER_BLOCK_LBL, COMMENT=> "SAUT POST BLOC" );
      WRITE_LABEL ( PROC_LBL);
      DECLARE
        OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
        OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
      BEGIN
        EMITS.OFFSET_ACT := FIRST_LOCAL_VAR_OFFSET;
        EMITS.OFFSET_MAX := FIRST_LOCAL_VAR_OFFSET;
        INC_LEVEL;
      CODE_block_body ( D ( as_block_body, block ) );
        DEC_LEVEL;
        EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
        EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      END;
      WRITE_LABEL ( AFTER_BLOCK_LBL );
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_block_body ( block_body :TREE ) IS
  BEGIN
    DECLARE
      SAVE_ENCLOSING_BODY : TREE := ENCLOSING_BODY;
      OLD_TOP_ACT         : OFFSET_TYPE := EMITS.TOP_ACT;
      OLD_TOP_MAX         : OFFSET_TYPE := EMITS.TOP_MAX;
    BEGIN
      ENCLOSING_BODY := BLOCK_BODY;
      EMITS.TOP_ACT := 0;
      EMITS.TOP_MAX := 0;
      DI ( CD_LEVEL, BLOCK_BODY, INTEGER ( EMITS.LEVEL ) );
      DI ( CD_RETURN_LABEL, BLOCK_BODY, INTEGER ( NEXT_LABEL ) );
      DECLARE
        ENT_1_LBL : LABEL_TYPE := NEXT_LABEL;
        ENT_2_LBL : LABEL_TYPE := NEXT_LABEL;
      BEGIN
        EMIT ( ENT, INTEGER ( 1 ), ENT_1_Lbl );
        EMIT ( ENT, INTEGER ( 2 ), ENT_2_Lbl );
        IF FUNCTION_RESULT /= TREE_VOID THEN
          IF FUNCTION_RESULT.TY = DN_ARRAY THEN
            GEN_LOAD_ADDR ( DI ( CD_COMP_UNIT, FUNCTION_RESULT ),
                            DI ( CD_LEVEL, FUNCTION_RESULT ),
                            DI ( CD_OFFSET, FUNCTION_RESULT )
                );
            EMIT ( DPL, A );
            EMIT ( STR, A, 0, FUN_RESULT_OFFSET - EMITS.ADDR_SIZE );
            EMIT ( IND, I, 0 );
            EMIT ( ALO, INTEGER ( -1 ) );
            EMIT ( STR, A, 0, FUN_RESULT_OFFSET );
          END IF;
        END IF;
      CODE_item_s ( D ( as_ITEM_S, block_body ) );
        DECLARE
          EXC_LBL : LABEL_TYPE := NEXT_LABEL;
        BEGIN
          EMIT ( EXH, EXC_LBL, COMMENT=> "EXCEPTION HANDLERS" );
      CODE_stm_s ( D ( as_STM_S, block_body ) );
          WRITE_LABEL ( LABEL_TYPE ( DI ( CD_RETURN_LABEL, BLOCK_BODY ) ) );
          EMIT ( RET, PARAM_SIZE );
          WRITE_LABEL ( EXC_LBL );
        END;
        IF NOT IS_EMPTY ( LIST ( D ( AS_ALTERNATIVE_S, BLOCK_BODY ) ) ) THEN
      CODE_alternative_s ( D ( as_ALTERNATIVE_S, block_body ) );
        ELSE
          EMIT ( EEX );
        END IF;
        GEN_LBL_ASSIGNMENT ( ENT_1_LBL, EMITS.OFFSET_MAX );
        GEN_LBL_ASSIGNMENT ( ENT_2_LBL, EMITS.OFFSET_MAX + EMITS.TOP_MAX );
      END;
      EMITS.TOP_MAX := OLD_TOP_MAX;
      EMITS.TOP_ACT := OLD_TOP_ACT;
      ENCLOSING_BODY := SAVE_ENCLOSING_BODY;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_exit ( ADA_exit :TREE ) IS
  BEGIN
    DECLARE
      LVB_LBL          : LABEL_TYPE;
      EXP              : TREE := D ( AS_EXP, ada_exit );
      LOOP_STM         : TREE := D ( SM_STM, ada_exit );
      LOOP_LEVEL       : LEVEL_TYPE := DI ( CD_LEVEL, LOOP_STM );
      AFTER_LOOP_LABEL : LABEL_TYPE := LABEL_TYPE( DI( CD_AFTER_LOOP, LOOP_STM ) );
    BEGIN
      IF EXP = TREE_VOID THEN
        IF LOOP_LEVEL /= EMITS.LEVEL THEN
             LVB_LBL := NEXT_LABEL;
             EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
             GEN_LBL_ASSIGNMENT ( LVB_LBL, EMITS.LEVEL - LOOP_LEVEL );
        END IF;
        EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
      ELSE
      CODE_exp ( exp );
        IF LOOP_LEVEL /= EMITS.LEVEL THEN
          DECLARE
            SKIP_LBL : LABEL_TYPE := NEXT_LABEL;
          BEGIN
            EMIT ( JMPF, SKIP_LBL, COMMENT=> "PAS D EXIT SI CONDITION FAUSSE" );
            LVB_LBL := NEXT_LABEL;
            EMIT ( LVB, LVB_lbl, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
            GEN_LBL_ASSIGNMENT ( LVB_LBL, EMITS.LEVEL - LOOP_LEVEL );
            EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
            WRITE_LABEL ( SKIP_LBL, COMMENT=> "LABEL NO EXIT" );
          END;
        ELSE
          EMIT ( JMPT, AFTER_LOOP_LABEL );
        END IF;
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_return ( ADA_return :TREE ) IS
  BEGIN
    DECLARE
      EXP : TREE := D ( AS_EXP, ADA_RETURN );
    BEGIN
      IF EXP /= TREE_VOID THEN
    STORE_FUNCTION_RESULT:
        DECLARE
          ENCLOSING_LEVEL : INTEGER := DI ( CD_LEVEL, EMITS.ENCLOSING_BODY );
          RESULT_OFFSET : INTEGER := DI ( CD_RESULT_OFFSET, EMITS.ENCLOSING_BODY );
          EXPR_TYPE     : TREE := D ( SM_EXP_TYPE, EXP );
        BEGIN
          IF EXPR_TYPE.TY = DN_ARRAY THEN
            EMIT ( LDA, EMITS.LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
      CODE_EXP ( exp );
            EMIT ( LDC, I, EMITS.NUMBER_OF_DIMENSIONS ( EXP ) );
            EMIT ( PUA );
           ELSIF EXPR_TYPE.TY = DN_ENUM_LITERAL_S THEN
      CODE_EXP ( exp );
             EMIT ( STR, EMITS.CODE_TYPE_OF ( EXP ), EMITS.LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
           ELSIF EXPR_TYPE.TY = DN_INTEGER THEN
      CODE_EXP ( exp );
             EMIT ( STR, I, EMITS.LEVEL - ENCLOSING_LEVEL, RESULT_OFFSET );
           END IF;
         END STORE_FUNCTION_RESULT;
       END IF;
       EMITS.PERFORM_RETURN ( EMITS.ENCLOSING_BODY );
    end;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_goto ( ADA_goto :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subprog_entry_decl ( subprog_entry_decl :TREE ) IS
  BEGIN
    DECLARE
      OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
      OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
      SOURCE_NAME    : TREE        := D ( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
      HEADER         : TREE        := D ( AS_HEADER, SUBPROG_ENTRY_DECL );
    BEGIN
      EMITS.OFFSET_ACT := EMITS.FIRST_PARAM_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      INC_LEVEL;
      IF SOURCE_NAME.TY IN CLASS_SUBPROG_NAME THEN
        DECLARE
          LBL : LABEL_TYPE := NEXT_LABEL;
        BEGIN
          DI ( CD_LABEL, SOURCE_NAME, INTEGER ( LBL ) );
          DI ( CD_LEVEL, SOURCE_NAME, EMITS.LEVEL );
          DB ( CD_COMPILED, SOURCE_NAME, TRUE );
          IF NOT EMITS.GENERATE_CODE THEN
            EMITS.GENERATE_CODE := TRUE;
            EMIT ( RFL, LBL );
            EMITS.GENERATE_CODE := FALSE;
          END IF;
      CODE_HEADER ( D ( as_header, subprog_entry_decl ) );
          DI ( CD_PARAM_SIZE, SOURCE_NAME, OFFSET_ACT - FIRST_PARAM_OFFSET );
        END;
        IF SOURCE_NAME.TY = DN_FUNCTION_ID OR SOURCE_NAME.TY = DN_OPERATOR_ID THEN
          DECLARE
            USED_OBJECT_ID   : TREE := D ( AS_NAME, HEADER );
            RESULT_TYPE_SPEC : TREE := D ( SM_EXP_TYPE, USED_OBJECT_ID );
          BEGIN
            DI ( CD_RESULT_SIZE, SOURCE_NAME, EMITS.TYPE_SIZE( RESULT_TYPE_SPEC ));
          END;
        END IF;
      END IF;
      DEC_LEVEL;
      EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_NON_TASK_NAME ( NON_TASK_NAME :TREE ) IS
  BEGIN

    IF NON_TASK_NAME.TY = DN_generic_id then
      CODE_generic_id ( NON_TASK_NAME );

    ELSIF NON_TASK_NAME.TY IN CLASS_SUBPROG_PACK_NAME then
      CODE_SUBPROG_PACK_NAME ( NON_TASK_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_SUBPROG_PACK_NAME ( SUBPROG_PACK_NAME :TREE ) IS
  BEGIN

    IF SUBPROG_PACK_NAME.TY = DN_package_id then
      CODE_package_id ( SUBPROG_PACK_NAME );

    ELSIF SUBPROG_PACK_NAME.TY IN CLASS_SUBPROG_NAME then
      CODE_SUBPROG_NAME ( SUBPROG_PACK_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_SUBPROG_NAME ( SUBPROG_NAME :TREE ) IS
  BEGIN

    IF SUBPROG_NAME.TY = DN_procedure_id then
      CODE_procedure_id ( SUBPROG_NAME );

    ELSIF SUBPROG_NAME.TY = DN_function_id then
      CODE_function_id ( SUBPROG_NAME );

    ELSIF SUBPROG_NAME.TY = DN_operator_id then
      CODE_operator_id ( SUBPROG_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_procedure_id ( procedure_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_function_id ( function_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_operator_id ( operator_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_HEADER ( HEADER :TREE ) IS
  BEGIN

    IF HEADER.TY IN CLASS_SUBP_ENTRY_HEADER then
      CODE_param_s ( D ( as_param_s, HEADER ) );
      CODE_SUBP_ENTRY_HEADER ( HEADER );

    ELSIF HEADER.TY = DN_package_spec then
      CODE_package_spec ( HEADER );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_SUBP_ENTRY_HEADER ( SUBP_ENTRY_HEADER :TREE ) IS
  BEGIN

    IF SUBP_ENTRY_HEADER.TY = DN_procedure_spec then
      CODE_procedure_spec ( SUBP_ENTRY_HEADER );

    ELSIF SUBP_ENTRY_HEADER.TY = DN_function_spec then
      CODE_function_spec ( SUBP_ENTRY_HEADER );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_procedure_spec ( procedure_spec :TREE ) IS
  BEGIN
    EMITS.PARAM_SIZE := (EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET + EMITS.RELATIVE_RESULT_OFFSET);
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_function_spec ( function_spec :TREE ) IS
  BEGIN
    INC_OFFSET ( EMITS.RELATIVE_RESULT_OFFSET );
    EMITS.PARAM_SIZE := ( EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET );
    DI ( CD_RESULT_SIZE, D ( AS_NAME, FUNCTION_SPEC ), EMITS.RESULT_SIZE );
    INC_OFFSET ( EMITS.RESULT_SIZE );
    ALIGN ( STACK_AL );
    DI ( CD_RESULT_OFFSET, FUNCTION_SPEC, EMITS.OFFSET_ACT );
    EMITS.FUN_RESULT_OFFSET := EMITS.OFFSET_ACT;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_param_s ( param_s :TREE ) IS
  BEGIN
    DECLARE
      param_seq : Seq_Type := LIST ( param_s );
      param : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( param_seq ) LOOP
        POP ( param_seq, param );
      CODE_param ( param );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_PARAM ( PARAM :TREE ) IS
  BEGIN

    IF PARAM.TY = DN_in then
      CODE_in ( PARAM );

    ELSIF PARAM.TY = DN_out then
      CODE_out ( PARAM );

    ELSIF PARAM.TY = DN_in_out then
      CODE_in_out ( PARAM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_in ( ADA_in :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_in_out ( ADA_in_out :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_out ( ADA_out :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_INIT_OBJECT_NAME ( INIT_OBJECT_NAME :TREE ) IS
  BEGIN

    IF INIT_OBJECT_NAME.TY = DN_number_id then
      CODE_number_id ( INIT_OBJECT_NAME );

    ELSIF INIT_OBJECT_NAME.TY IN CLASS_VC_NAME then
      CODE_VC_NAME ( INIT_OBJECT_NAME );

    ELSIF INIT_OBJECT_NAME.TY IN CLASS_COMP_NAME then
      CODE_COMP_NAME ( INIT_OBJECT_NAME );

    ELSIF INIT_OBJECT_NAME.TY IN CLASS_PARAM_NAME then
      CODE_PARAM_NAME ( INIT_OBJECT_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_PARAM_NAME ( PARAM_NAME :TREE ) IS
  BEGIN

    IF PARAM_NAME.TY = DN_in_id then
      CODE_in_id ( PARAM_NAME );

    ELSIF PARAM_NAME.TY IN CLASS_PARAM_IO_O then
      CODE_PARAM_IO_O ( PARAM_NAME );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_PARAM_IO_O ( PARAM_IO_O :TREE ) IS
  BEGIN

    IF PARAM_IO_O.TY = DN_in_out_id then
      CODE_in_out_id ( PARAM_IO_O );

    ELSIF PARAM_IO_O.TY = DN_out_id then
      CODE_out_id ( PARAM_IO_O );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_in_id ( in_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_in_out_id ( in_out_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_out_id ( out_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_BODY ( ADA_BODY :TREE ) IS
  BEGIN

    IF ADA_BODY.TY = DN_block_body then
      CODE_block_body ( ADA_BODY );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subprogram_body ( subprogram_body :TREE ) IS
  BEGIN
    DECLARE
       OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
       OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
       SOURCE_NAME    : TREE := D ( AS_SOURCE_NAME, SUBPROGRAM_BODY );
       START_LABEL    : LABEL_TYPE := NEXT_LABEL;
    BEGIN
      IF EMITS.ENCLOSING_BODY = TREE_VOID THEN
        EMIT ( PRO, S=> PRINT_NAME ( D ( LX_SYMREP, SOURCE_NAME ) ) );
      END IF;
      EMITS.OFFSET_ACT := EMITS.FIRST_PARAM_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      INC_LEVEL;
      DI ( CD_LABEL, SOURCE_NAME, INTEGER ( START_LABEL ) );
      DI ( CD_LEVEL, SOURCE_NAME, EMITS.LEVEL );
      WRITE_LABEL ( START_LABEL );
      CODE_HEADER ( D ( as_header, subprogram_body ) );
      DI ( CD_PARAM_SIZE, SOURCE_NAME, PARAM_SIZE );
      EMITS.OFFSET_ACT := EMITS.FIRST_LOCAL_VAR_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      CODE_BODY ( D ( as_BODY, subprogram_body ) );
      DEC_LEVEL;
      EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_procedure_call ( procedure_call :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_function_call ( function_call :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_package_decl ( package_decl :TREE ) IS
  BEGIN
    EMIT ( PKG, S=> PRINT_NAME ( D ( LX_SYMREP, D ( AS_SOURCE_NAME, PACKAGE_DECL ) ) ) );
    WRITE_LABEL ( 1 );
    DECLARE
      L1 : LABEL_TYPE := NEXT_LABEL;
      L2 : LABEL_TYPE := NEXT_LABEL;
    BEGIN
      EMIT ( ENT, Integer( 1 ), L1 );
      EMIT ( ENT, Integer( 2 ), L2 );
      EMITS.OFFSET_ACT := 0;
      EMITS.OFFSET_MAX := 0;
      CODE_HEADER ( D ( as_header, package_decl ) );
      DECLARE
        EXC_LBL : LABEL_TYPE := NEXT_LABEL;
      BEGIN
        EMIT ( EXH, EXC_LBL, COMMENT=> "ETIQUETTE EXCEPTION HANDLE DU PACKAGE" );
        EMIT ( RET, RELATIVE_RESULT_OFFSET );
        WRITE_LABEL ( EXC_LBL );
      END;
      EMIT ( EEX );
      GEN_LBL_ASSIGNMENT ( L1, OFFSET_MAX );
      GEN_LBL_ASSIGNMENT ( L2, TOP_MAX + OFFSET_MAX );
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_package_id ( package_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_package_spec ( package_spec :TREE ) IS
  BEGIN
      CODE_decl_s ( D ( as_decl_s1, package_spec ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_decl_s ( decl_s :TREE ) IS
  BEGIN
    DECLARE
      decl_seq : Seq_Type := LIST ( decl_s );
      decl : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( decl_seq ) LOOP
        POP ( decl_seq, decl );
      CODE_DECL ( decl );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_package_body ( package_body :TREE ) IS
  BEGIN
    EMIT ( PKB, S=> PRINT_NAME ( D ( LX_SYMREP, D ( AS_SOURCE_NAME, PACKAGE_BODY ) ) ) );
    EMITS.GENERATE_CODE := FALSE;
      CODE_package_spec ( D ( sm_spec, D ( as_source_name, package_body ) ) );
    EMITS.GENERATE_CODE := TRUE;
    WRITE_LABEL ( 1 );
      CODE_BODY ( D ( as_body, package_body ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_private_type_id ( private_type_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_l_private_type_id ( l_private_type_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_deferred_constant_decl ( deferred_constant_decl :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_task_decl ( task_decl :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_task_body ( task_body :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_task_body_id ( task_body_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_entry_id ( entry_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_entry_call ( entry_call :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_accept ( ADA_accept :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_delay ( ADA_delay :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_selective_wait ( selective_wait :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_TEST_CLAUSE_ELEM ( TEST_CLAUSE_ELEM :TREE ) IS
  BEGIN

    IF TEST_CLAUSE_ELEM.TY IN CLASS_TEST_CLAUSE then
      CODE_TEST_CLAUSE ( TEST_CLAUSE_ELEM );

    ELSIF TEST_CLAUSE_ELEM.TY = DN_select_alt_pragma then
      CODE_select_alt_pragma ( TEST_CLAUSE_ELEM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_test_clause_elem_s ( test_clause_elem_s :TREE ) IS
  BEGIN
    DECLARE
      test_clause_elem_seq : Seq_Type := LIST ( test_clause_elem_s );
      test_clause_elem : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( test_clause_elem_seq ) LOOP
        POP ( test_clause_elem_seq, test_clause_elem );
      CODE_TEST_CLAUSE_ELEM ( test_clause_elem );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_select_alternative ( select_alternative :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_select_alt_pragma ( select_alt_pragma :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_terminate ( ADA_terminate :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ENTRY_STM ( ENTRY_STM :TREE ) IS
  BEGIN

    IF ENTRY_STM.TY = DN_cond_entry then
      CODE_cond_entry ( ENTRY_STM );

    ELSIF ENTRY_STM.TY = DN_timed_entry then
      CODE_timed_entry ( ENTRY_STM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_cond_entry ( cond_entry :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_timed_entry ( timed_entry :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_name_s ( name_s :TREE ) IS
  BEGIN
    DECLARE
      name_seq : Seq_Type := LIST ( name_s );
      name : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( name_seq ) LOOP
        POP ( name_seq, name );
      CODE_NAME ( name );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_abort ( ADA_abort :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_compilation ( compilation :TREE ) IS
  BEGIN
      CODE_compltn_unit_s ( D ( as_compltn_unit_s, compilation ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_compltn_unit_s ( compltn_unit_s :TREE ) IS
  BEGIN
    DECLARE
      compltn_unit_seq : Seq_Type := LIST ( compltn_unit_s );
      compltn_unit : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( compltn_unit_seq ) LOOP
        POP ( compltn_unit_seq, compltn_unit );
    EMITS.OPEN_OUTPUT_FILE ( GET_LIB_PREFIX & PRINT_NAME ( D ( XD_LIB_NAME, COMPLTN_UNIT ) ) );
      CODE_compilation_unit ( compltn_unit );
    EMITS.CLOSE_OUTPUT_FILE;
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_compilation_unit ( compilation_unit :TREE ) IS
  BEGIN
    EMITS.TOP_ACT := 0;
    EMITS.TOP_MAX := 0;
    EMITS.OFFSET_ACT := 0;
    EMITS.OFFSET_MAX := 0;
    EMITS.LEVEL := 0;
    EMITS.GENERATE_CODE := FALSE;
    EMITS.CUR_COMP_UNIT := 2;
    EMITS.ENCLOSING_BODY := Tree_VOID;
      CODE_context_elem_s ( D ( as_context_elem_s, compilation_unit ) );
    EMITS.CUR_COMP_UNIT := 0;
    EMITS.GENERATE_CODE := TRUE;
      CODE_ALL_DECL ( D ( as_all_decl, compilation_unit ) );
    EMIT ( QUIT );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_CONTEXT_ELEM ( CONTEXT_ELEM :TREE ) IS
  BEGIN

    IF CONTEXT_ELEM.TY = DN_context_pragma then
      CODE_context_pragma ( CONTEXT_ELEM );

    ELSIF CONTEXT_ELEM.TY = DN_with then
      CODE_with ( CONTEXT_ELEM );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_context_pragma ( context_pragma :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_context_elem_s ( context_elem_s :TREE ) IS
  BEGIN
    DECLARE
      context_elem_seq : Seq_Type := LIST ( context_elem_s );
      context_elem : TREE;
    BEGIN
      WHILE NOT IS_EMPTY ( context_elem_seq ) LOOP
        POP ( context_elem_seq, context_elem );
      CODE_CONTEXT_ELEM ( context_elem );
    END LOOP;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_with ( ADA_with :TREE ) IS
  BEGIN
      CODE_name_s ( D ( as_NAME_S, ADA_with ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_subunit ( subunit :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_SUBUNIT_BODY ( SUBUNIT_BODY :TREE ) IS
  BEGIN
    DECLARE
       POST_LBL : LABEL_TYPE;
    BEGIN
      IF ENCLOSING_BODY /= TREE_VOID THEN
        POST_LBL := NEXT_LABEL;
        EMIT ( JMP, POST_LBL, COMMENT=> "CONTOURNEMENT" );
      END IF;

    IF SUBUNIT_BODY.TY = DN_subprogram_body then
      CODE_subprogram_body ( SUBUNIT_BODY );

    ELSIF SUBUNIT_BODY.TY = DN_package_body then
      CODE_package_body ( SUBUNIT_BODY );

    ELSIF SUBUNIT_BODY.TY = DN_task_body then
      CODE_task_body ( SUBUNIT_BODY );

    END IF;
      IF ENCLOSING_BODY /= TREE_VOID THEN
        WRITE_LABEL ( POST_LBL, COMMENT=> "FIN DE CONTOURNEMENT" );
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_exception_decl ( exception_decl :TREE ) IS
  BEGIN
      CODE_source_name_s ( D ( as_source_name_s, exception_decl ) );
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_exception_id ( exception_id :TREE ) IS
  BEGIN
    DECLARE
      LBL : LABEL_TYPE := NEXT_LABEL;
    BEGIN
      DI ( CD_LABEL, EXCEPTION_ID, INTEGER ( LBL ) );
      EMIT ( EXL, LBL, S=> PRINT_NAME ( D ( LX_SYMREP, EXCEPTION_ID ) ),
             COMMENT=> "NUMERO D EXCEPTION SUR DECLARATION" );
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_raise ( ADA_raise :TREE ) IS
  BEGIN
    DECLARE
      NAME : TREE := D ( AS_NAME, ADA_RAISE );
    BEGIN
      IF NAME = TREE_VOID THEN
        EMIT ( RAI );
      ELSE
        DECLARE
          EXCEPTION_ID : TREE := D ( SM_DEFN, NAME );
          LBL : LABEL_TYPE;
        BEGIN
          IF D ( CD_LABEL, EXCEPTION_ID ).TY /= DN_NUM_VAL THEN
            LBL := NEXT_LABEL;
            DI ( CD_LABEL, EXCEPTION_ID, INTEGER ( LBL ) );
            EMIT ( EXL, LBL, S=> PRINT_NAME ( D ( LX_SYMREP, NAME ) ),
    COMMENT=> "NUMERO D EXCEPTION EXTERNE SUR RAISE" );
          END IF;
          EMIT ( RAI, DI ( CD_LABEL, EXCEPTION_ID ) );
        END;
      END IF;
    END;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_generic_decl ( generic_decl :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_generic_id ( generic_id :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_code ( code :TREE ) IS
  BEGIN
    null;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_ALL_DECL ( ALL_DECL :TREE ) IS
  BEGIN

    IF ALL_DECL.TY IN CLASS_ITEM then
      CODE_ITEM ( ALL_DECL );

    ELSIF ALL_DECL.TY = DN_subunit then
      CODE_subunit ( ALL_DECL );

    END IF;
  END;

  --|-------------------------------------------------------------------------------------------
  PROCEDURE CODE_user_root ( user_root :TREE ) IS
  BEGIN
      CODE_compilation ( D ( xd_structure, user_root ) );
  END;

BEGIN
  OPEN_IDL_TREE_FILE ( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
  CODE_root ( Tree_Root );
  CLOSE_IDL_TREE_FILE;
END CODE_GEN;
