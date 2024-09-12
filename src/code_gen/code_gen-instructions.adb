separate ( CODE_GEN )
				------------
 	package body		INSTRUCTIONS
				------------
  is


  package CODI renames CODAGE_INTERMEDIAIRE;


  procedure			CODE_STM_S		( STM_S :TREE )
  is
  begin
    declare
      STM_SEQ : SEQ_TYPE := LIST ( STM_S );
      STM_ELEM : TREE;
    begin
      while not IS_EMPTY ( STM_SEQ ) loop
        POP( STM_SEQ, STM_ELEM );
        CODE_STM_ELEM( STM_ELEM );
      end loop;
    end;
  end	CODE_STM_S;


  procedure			CODE_STM_ELEM		( STM_ELEM :TREE )
  is
  begin

    if STM_ELEM.TY in CLASS_STM then
      CODE_STM( STM_ELEM );

    elsif STM_ELEM.TY = DN_STM_PRAGMA then
      CODE_STM_PRAGMA( STM_ELEM );

    end if;
  end	CODE_STM_ELEM;



  procedure			CODE_STM_PRAGMA		( STM_PRAGMA :TREE )
  is
  begin
    null;
  end;



				--====--
  procedure			CODE_STM			( STM :TREE )
  is
  begin

    if STM.TY = DN_LABELED
    then
      CODE_LABELED( STM );

    elsif STM.TY = DN_NULL_STM
    then
      CODE_NULL_STM( STM );

    elsif STM.TY = DN_ACCEPT
    then
      CODE_ACCEPT( STM );

    elsif STM.TY = DN_TERMINATE
    then
      CODE_TERMINATE( STM );

    elsif STM.TY = DN_ABORT
    then
      CODE_ABORT( STM );

    elsif STM.TY in CLASS_CLAUSES_STM
    then
      CODE_CLAUSES_STM( STM );

    elsif STM.TY in CLASS_BLOCK_LOOP
    then
      CODE_BLOCK_LOOP( STM );

    elsif STM.TY in CLASS_ENTRY_STM
    then
      CODE_ENTRY_STM( STM );

    elsif STM.TY in CLASS_STM_WITH_NAME
    then
      CODE_STM_WITH_NAME( STM );

    elsif STM.TY in CLASS_STM_WITH_EXP
    then
      CODE_STM_WITH_EXP( STM );

    end if;
  end	CODE_STM;
	--====--



  procedure			CODE_LABELED		( LABELED :TREE )
  is
  begin
    null;
  end	CODE_LABELED;



  procedure			CODE_NULL_STM		( NULL_STM :TREE )
  is
  begin
    null;
  end	CODE_NULL_STM;



  procedure			CODE_ACCEPT		( ADA_ACCEPT :TREE )
  is
  begin
    null;
  end	CODE_ACCEPT;



  procedure			CODE_TERMINATE		( ADA_TERMINATE :TREE )
  is
  begin
    null;
  end	CODE_TERMINATE;



  procedure			CODE_ABORT		( ADA_ABORT :TREE )
  is
  begin
    null;
  end	CODE_ABORT;



  procedure			CODE_CLAUSES_STM		( CLAUSES_STM :TREE )
  is
  begin
    if CLAUSES_STM.TY = DN_IF
    then
      CODE_IF( CLAUSES_STM );

    elsif CLAUSES_STM.TY = DN_SELECTIVE_WAIT
    then
      CODE_SELECTIVE_WAIT( CLAUSES_STM );

    end if;
  end	CODE_CLAUSES_STM;



  procedure			CODE_IF			( ADA_IF :TREE )
  is
    AFTER_IF_LBL	:constant STRING	:= NEW_LABEL;
  begin
    CODE_TEST_CLAUSE_ELEM_S ( D ( AS_TEST_CLAUSE_ELEM_S, ADA_IF ), AFTER_IF_LBL );
    PUT_LINE( AFTER_IF_LBL & ':' );

  end	CODE_IF;



  procedure			CODE_SELECTIVE_WAIT		( SELECTIVE_WAIT :TREE )
  is
  begin
    null;
  end	CODE_SELECTIVE_WAIT;



  procedure			CODE_BLOCK_LOOP		( BLOCK_LOOP :TREE )
  is
  begin

    if BLOCK_LOOP.TY = DN_LOOP
    then
      CODE_LOOP( BLOCK_LOOP );

    elsif BLOCK_LOOP.TY = DN_BLOCK
    then
      CODE_BLOCK( BLOCK_LOOP );

    end if;
  end	CODE_BLOCK_LOOP;


				---------
  procedure			CODE_LOOP			( ADA_LOOP :TREE )
  is
    LOOP_STM_S		: TREE		:= D( AS_STM_S,       ADA_LOOP );
    LOOP_NAME_ID		: TREE		:= D( AS_SOURCE_NAME, ADA_LOOP );
    ITERATION		: TREE		:= D( AS_ITERATION,   ADA_LOOP );
    LOOP_LBL_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, LOOP_NAME_ID ) );
    AFTER_LOOP_LBL		: LABEL_TYPE	:= NEW_LABEL;
    AFTER_LOOP_LBL_STR	:constant STRING	:= LABEL_STR( AFTER_LOOP_LBL );
  begin
    DI( CD_AFTER_LOOP, ADA_LOOP, INTEGER( AFTER_LOOP_LBL ) );
    DI( CD_LEVEL,      ADA_LOOP, INTEGER( CODI.CUR_LEVEL ) );

--
--				SIMPLE BOUCLE
--
    if ITERATION = TREE_VOID then
      PUT_LINE( LOOP_LBL_STR & ':' );
      CODE_STM_S( LOOP_STM_S );
      PUT_LINE( tab & "BRA" & tab & LOOP_LBL_STR );

--
--				BOUCLE WHILE
--
    elsif ITERATION.TY = DN_WHILE then
      PUT_LINE( LOOP_LBL_STR & ':' );
      EXPRESSIONS.CODE_EXP( D( AS_EXP, ITERATION ) );
      PUT_LINE( tab & "BRZ" & tab & LABEL_STR( AFTER_LOOP_LBL ) );
      CODE_STM_S( LOOP_STM_S );
      PUT_LINE( tab & "BRA" & tab & LOOP_LBL_STR );

    elsif ITERATION.TY in CLASS_FOR_REV then

				FOR_OR_REVERSE_LOOP:

      declare
        ITERATION_ID	: TREE		:= D( AS_SOURCE_NAME, ITERATION );
        ITERATION_RANGE	: TREE		:= D( AS_DISCRETE_RANGE, ITERATION );
        RANGE_LOW		: TREE		:= D( AS_EXP1, ITERATION_RANGE );
        RANGE_HIGH		: TREE		:= D( AS_EXP2, ITERATION_RANGE );
        TYPE_CHAR		: CHARACTER	:= OPER_TYPE_FROM( ITERATION_ID );
        ITERATION_ID_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, ITERATION_ID ) );
        ITERATION_ID_TAG	: LABEL_TYPE	:= NEW_LABEL;
        ITERATION_ID_VARSTR	:constant STRING	:= ITERATION_ID_STR & LABEL_STR( ITERATION_ID_TAG ) & "_disp";
      begin
        DI( CD_LEVEL,  ITERATION_ID, INTEGER( CODI.CUR_LEVEL   ) );
        DI( CD_OFFSET, ITERATION_ID, INTEGER( ITERATION_ID_TAG ) );

        PUT( "VAR" & tab & ITERATION_ID_VARSTR & ", " & TYPE_CHAR );
        if CODI.DEBUG then PUT( tab50 & "; compteur boucle " & LOOP_LBL_STR); end if;
        NEW_LINE;

        EXPRESSIONS.CODE_EXP( RANGE_LOW );

        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );

        PUT( "VAR" & tab & "LMT_" & ITERATION_ID_VARSTR & ", " & TYPE_CHAR );
        if CODI.DEBUG then PUT( tab50 & "; limite boucle " & LOOP_LBL_STR); end if;
        NEW_LINE;
        EXPRESSIONS.CODE_EXP( RANGE_HIGH );

        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );

--			VERIFIER POUR NULL RANGE

        PUT( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
        if CODI.DEBUG then
	PUT( tab50 & "; test null range " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        PUT_LINE( tab & "CGT" );
        PUT_LINE( tab & "BT" & tab & AFTER_LOOP_LBL_STR );

--			INVERSER CNT LMT POUR REVERSE

        if ITERATION.TY = DN_REVERSE then
	PUT( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
	if CODI.DEBUG then
	  PUT( tab50 & "; inversion range " & LOOP_LBL_STR );
	end if;
	NEW_LINE;
	PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
	PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
	PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        end if;

--			DEBUT ET CORPS DE BOUCLE

        PUT( LOOP_LBL_STR & ':' );
        if CODI.DEBUG then
	PUT( tab50 & "; corps boucle " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        CODE_STM_S ( LOOP_STM_S );

--			TEST DE SORTIE

        PUT( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
        if CODI.DEBUG then
	PUT( tab50 & "; test de sortie " & LOOP_LBL_STR );
        end if;
        NEW_LINE;
        PUT_LINE( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & "LMT_" & ITERATION_ID_VARSTR );
        PUT_LINE( tab & "CEQ" );
        PUT_LINE( tab & "BT" & tab & AFTER_LOOP_LBL_STR );

--			MISE A JOUR DU COMPTEUR

        PUT( tab & "L" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );
        if CODI.DEBUG then
	PUT( tab50 & "; mise a jour compteur " & LOOP_LBL_STR );
        end if;
        NEW_LINE;

        if ITERATION.TY = DN_FOR then
          PUT_LINE( tab & "INC" );

        elsif ITERATION.TY = DN_REVERSE then
	PUT_LINE( tab & "DEC" );

        end if;
        PUT_LINE( tab & "S" & TYPE_CHAR & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, ITERATION_ID ) ) & ',' & tab & ITERATION_ID_VARSTR );

        PUT( tab & "BRA" & tab & LOOP_LBL_STR );
        if CODI.DEBUG then
	PUT( tab50 & "; iteration suivante " & LOOP_LBL_STR );
        end if;
        NEW_LINE;

      end		FOR_OR_REVERSE_LOOP;

    end if;

    PUT( AFTER_LOOP_LBL_STR & ':' );
    if CODI.DEBUG then
      PUT( tab50 & "; post loop " & LOOP_LBL_STR );
    end if;
    NEW_LINE;

  end	CODE_LOOP;
	---------

--   procedure			CODE_FOR_REV		( FOR_REV :TREE )
--   is
--   begin
--     declare
--       OLD_LOOP_OP_INC_DEC   : LOOP_CODE      := CODI.LOOP_OP_INC_DEC;
--       OLD_LOOP_OP_GT_LT     : LOOP_CODE      := CODI.LOOP_OP_GT_LT;
--       COUNTER, TEMP         : INTEGER	:= 0;
-- --      OLD_OFFSET_ACT        : OFFSET_VAL  := CODI.OFFSET_ACT;
--       ITERATION_ID          : TREE         := D ( AS_SOURCE_NAME, FOR_REV );
--       ACT                   : CHARACTER    := CODI.CODE_DATA_TYPE_OF ( D ( SM_OBJ_TYPE, ITERATION_ID ) );
-- 
--       procedure LOAD_DSCRT_RANGE ( DSCRT_RANGE : TREE ) is
--       begin
--         null;
--       end;
-- 
--     begin
-- --      CODI.BEFORE_LOOP_LBL := NEW_LABEL;
-- --      CODI.AFTER_LOOP_LBL := NEW_LABEL;
-- 
--     if FOR_REV.TY = DN_FOR then
--       CODE_FOR ( FOR_REV );
-- 
--     elsif FOR_REV.TY = DN_REVERSE then
--       CODE_REVERSE ( FOR_REV );
-- 
--     end if;
-- 
--       case ACT is
--       when 'B' =>
-- null;--        ALIGN ( BOOL_AL );
-- --        COUNTER := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( BOOL_SIZE);
-- --        ALIGN ( BOOL_AL);
-- --        TEMP := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( BOOL_SIZE );
--       when 'C' =>
-- null;--        ALIGN ( CHAR_AL );
-- --        COUNTER := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( CHAR_SIZE );
-- --        ALIGN ( CHAR_AL);
-- --        TEMP := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( CHAR_SIZE );
--       when 'I' =>
-- null;--        ALIGN ( INTG_AL );
-- --        COUNTER := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( INTG_SIZE );
-- --        ALIGN ( INTG_AL );
-- --        TEMP := -CODI.OFFSET_ACT;
-- --        ALTER_OFFSET ( INTG_SIZE );
--       when others =>
--         PUT_LINE ( "!!! COMPILE_STM_LOOP_REVERSE TYPE ILLICITE " & ACT );
--         raise PROGRAM_ERROR;
--       end case;
--       DI ( CD_LEVEL, ITERATION_ID, INTEGER( CODI.CUR_LEVEL ) );
--       DI ( CD_OFFSET, ITERATION_ID, COUNTER );
--       LOAD_DSCRT_RANGE ( D ( AS_DISCRETE_RANGE, FOR_REV ) );
-- --      EMIT ( SLD, ACT, 0, TEMP );
-- 
-- --      WRITE_LABEL ( CODI.BEFORE_LOOP_LBL );
-- 
-- --      EMIT ( SLD, ACT, 0, COUNTER );
-- --      EMIT ( PLD, ACT, 0, COUNTER );
-- --      EMIT ( PLD, ACT, 0, TEMP );
-- --      EMIT ( CODI.LOOP_OP_GT_LT, ACT );
-- --      EMIT ( JMPT, CODI.AFTER_LOOP_LBL );
--       CODE_STM_S ( LOOP_STM_S );
-- --      EMIT ( PLD, ACT, 0, COUNTER );
-- --      EMIT ( CODI.LOOP_OP_INC_DEC, ACT, 1 );
-- --      EMIT ( JMP, CODI.BEFORE_LOOP_LBL );
-- --      WRITE_LABEL ( CODI.AFTER_LOOP_LBL );
-- --      CODI.OFFSET_ACT := OLD_OFFSET_ACT;
--       CODI.LOOP_OP_INC_DEC := OLD_LOOP_OP_INC_DEC;
--       CODI.LOOP_OP_GT_LT := OLD_LOOP_OP_GT_LT;
--     end;
--   end	CODE_FOR_REV;
-- 
-- 
-- 
--   procedure			CODE_FOR			( ADA_FOR :TREE )
--   is
--   begin
--     LOOP_OP_INC_DEC := INC;
--     LOOP_OP_GT_LT := GT;
--   end	CODE_FOR;
-- 
-- 
-- 
--   procedure			CODE_REVERSE		( ADA_REVERSE :TREE )
--   is
--   begin
--     LOOP_OP_INC_DEC := DEC;
--     LOOP_OP_GT_LT := LT;
--   end	CODE_REVERSE;
-- 

-- 				----------
--   procedure			CODE_WHILE		( ADA_WHILE :TREE )
--   is
--     BEFORE_LOOP_LBL	:constant STRING	:= NEW_LABEL;
--     AFTER_LOOP_LBL	:constant STRING	:= NEW_LABEL;
--   begin
--     PUT_LINE( BEFORE_LOOP_LBL );
--     EXPRESSIONS.CODE_EXP( D ( AS_EXP, ADA_WHILE ) );
--     PUT_LINE( tab & "BRZ" & tab & AFTER_LOOP_LBL );
--     CODE_STM_S( LOOP_STM_S );
--     PUT_LINE( tab & "BRA" & tab & BEFORE_LOOP_LBL );
--   end	CODE_WHILE;
-- 	----------


				----------
  procedure			CODE_BLOCK		( BLOCK :TREE )
  is
    LOOP_NAME_ID	: TREE		:= D( AS_SOURCE_NAME, BLOCK );
    PROC_LBL        :constant STRING	:= PRINT_NAME( D( LX_SYMREP, LOOP_NAME_ID ) );
--    AFTER_BLOCK_LBL :constant STRING	:= NEW_LABEL;
  begin
    PUT_LINE( "namespace" & tab &  PROC_LBL );
    INC_LEVEL;
    STRUCTURES.CODE_BLOCK_BODY( D( AS_BLOCK_BODY, BLOCK ) );
    DEC_LEVEL;
--    PUT_LINE( AFTER_BLOCK_LBL & ':' );
    PUT_LINE( "end namespace" );

  end	CODE_BLOCK;



  procedure			CODE_ENTRY_STM		( ENTRY_STM :TREE )
  is
  begin

    if ENTRY_STM.TY = DN_COND_ENTRY then
      CODE_COND_ENTRY ( ENTRY_STM );

    elsif ENTRY_STM.TY = DN_TIMED_ENTRY then
      CODE_TIMED_ENTRY ( ENTRY_STM );

    end if;
  end	CODE_ENTRY_STM;



  procedure			CODE_COND_ENTRY		( COND_ENTRY :TREE )
  is
  begin
    null;
  end	CODE_COND_ENTRY;



  procedure			CODE_TIMED_ENTRY		( TIMED_ENTRY :TREE )
  is
  begin
    null;
  end	CODE_TIMED_ENTRY;



 procedure			CODE_STM_WITH_NAME		( STM_WITH_NAME :TREE )
  is
  begin
    if STM_WITH_NAME.TY = DN_GOTO
    then
      CODE_GOTO( STM_WITH_NAME );

    elsif STM_WITH_NAME.TY = DN_RAISE
    then
      CODE_RAISE( STM_WITH_NAME );

    elsif STM_WITH_NAME.TY in CLASS_CALL_STM
    then
      CODE_CALL_STM( STM_WITH_NAME );

    end if;
  end	CODE_STM_WITH_NAME;



  procedure			CODE_GOTO			( ADA_GOTO :TREE )
  is
  begin
    null;
  end;



				----------
  procedure			CODE_RAISE		( ADA_RAISE :TREE )
  is
  begin
    declare
      NAME	: TREE	:= D( AS_NAME, ADA_RAISE );
    begin
      if NAME = TREE_VOID then
null;--        EMIT( RAI );
      else
        declare
	EXCEPTION_ID	: TREE		:= D( SM_DEFN, NAME );
--	LBL		: LABEL_TYPE;
        begin
	if D( CD_LABEL, EXCEPTION_ID ).TY /= DN_NUM_VAL then
null;
--	  LBL := NEW_LABEL;
--	  DI  ( CD_LABEL, EXCEPTION_ID, INTEGER( LBL ) );
--	  EMIT( EXL, LBL, S=> PRINT_NAME( D( LX_SYMREP, NAME ) ),
--				COMMENT=> "NUMERO D EXCEPTION EXTERNE SUR RAISE" );
	end if;
--          EMIT( RAI, DI( CD_LABEL, EXCEPTION_ID ) );
        end;
      end if;
    end;
  end	CODE_RAISE;
	----------



  procedure			CODE_CALL_STM		( CALL_STM :TREE )
  is
  begin

    if CALL_STM.TY = DN_PROCEDURE_CALL then
      CODE_PROCEDURE_CALL ( CALL_STM );

    elsif CALL_STM.TY = DN_ENTRY_CALL then
      CODE_ENTRY_CALL ( CALL_STM );

    end if;
  end	CODE_CALL_STM;

				-------------------
  procedure			CODE_PROCEDURE_CALL		( PROCEDURE_CALL :TREE )
  is
    NORM_ACT_PRM_S	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_PARAM_S, PROCEDURE_CALL ) );
    USED_NAME_ID	: TREE		:= D( AS_NAME, PROCEDURE_CALL );
    SUB_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, USED_NAME_ID ) );

    PROC_ID	: TREE		:= D( SM_DEFN, USED_NAME_ID );
    LBL		: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, PROC_ID ) );

    procedure INVERSE_RECURSE
    is
      ACT_PRM	: TREE;
    begin

      while not IS_EMPTY( NORM_ACT_PRM_S ) loop
        POP( NORM_ACT_PRM_S, ACT_PRM );
        INVERSE_RECURSE;
        if ACT_PRM.TY = DN_USED_OBJECT_ID then
	declare
	  DEFN	: TREE	:= D( SM_DEFN, ACT_PRM );
	begin
	  PUT_LINE( tab & "LVA" & ' ' & INTEGER'IMAGE( DI( CD_LEVEL, DEFN ) ) & ',' & tab & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & "_disp" );
	end;
        else
	EXPRESSIONS.CODE_EXP( ACT_PRM );
        end if;
      end loop;
    end INVERSE_RECURSE;


  begin
    INVERSE_RECURSE;

    PUT_LINE( "  postpone" );
    declare
      REGION	: TREE	:= D( XD_REGION, PROC_ID );
      RGN_NAME :constant STRING	:= PRINT_NAME( D( LX_SYMREP, REGION ) );
    begin
      PUT_LINE( tab & SUB_NAME & '_' & LABEL_STR( LBL ) & "_ = " & RGN_NAME & '.' & SUB_NAME & '_' & LABEL_STR( LBL ) & ".elab" );
    end;
    PUT_LINE( "  end postpone" );
    PUT_LINE( tab & "CALL" & tab & SUB_NAME & '_' & LABEL_STR( LBL ) & '_' );

  end	CODE_PROCEDURE_CALL;
	-------------------



  procedure			CODE_STM_WITH_EXP		( STM_WITH_EXP :TREE )
  is
  begin

    if STM_WITH_EXP.TY = DN_RETURN
    then
      CODE_RETURN( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY = DN_DELAY
    then
      CODE_DELAY( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY = DN_CASE
    then
      CODE_CASE( STM_WITH_EXP );

    elsif STM_WITH_EXP.TY in CLASS_STM_WITH_EXP_NAME
    then
      CODE_STM_WITH_EXP_NAME( STM_WITH_EXP );

    end if;
  end	CODE_STM_WITH_EXP;


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
          ENCLOSING_LEVEL	: INTEGER		:= DI ( CD_LEVEL, CODI.ENCLOSING_BODY );
          RESULT_OFFSET	: INTEGER		:= DI ( CD_RESULT_OFFSET, CODI.ENCLOSING_BODY );
          EXPR_TYPE		: TREE		:= D ( SM_EXP_TYPE, EXP );
        begin
          if EXPR_TYPE.TY = DN_ARRAY then
--            EMIT( PLA, INTEGER( LEVEL_NUM( ENCLOSING_LEVEL ) - CODI.CUR_LEVEL ), RESULT_OFFSET );
            EXPRESSIONS.CODE_EXP( EXP );
--            EMIT( LDC, I, CODI.NUMBER_OF_DIMENSIONS ( EXP ) );
--            EMIT( PUA );
          elsif EXPR_TYPE.TY = DN_ENUM_LITERAL_S then
            EXPRESSIONS.CODE_EXP ( EXP );
--            EMIT( SLD, CODI.CODE_DATA_TYPE_OF ( EXP ), INTEGER( LEVEL_NUM( ENCLOSING_LEVEL) - CODI.CUR_LEVEL ), RESULT_OFFSET );
	elsif EXPR_TYPE.TY = DN_INTEGER then
	  EXPRESSIONS.CODE_EXP ( EXP );
--            EMIT( SLD, I, INTEGER( LEVEL_NUM( ENCLOSING_LEVEL) - CODI.CUR_LEVEL ), RESULT_OFFSET );
          end if;
        end STORE_FUNCTION_RESULT;
      end if;
--      CODI.PERFORM_RETURN ( CODI.ENCLOSING_BODY );
    end;

  end	CODE_RETURN;
	-----------



  procedure			CODE_DELAY		( ADA_DELAY :TREE )
  is
  begin
    null;
  end	CODE_DELAY;



  procedure			CODE_CASE			( ADA_CASE :TREE )
  is
  begin
    null;
  end	CODE_CASE;



  procedure			CODE_STM_WITH_EXP_NAME	( STM_WITH_EXP_NAME :TREE )
  is
  begin
    if STM_WITH_EXP_NAME.TY = DN_CODE
    then
      CODE_CODE( STM_WITH_EXP_NAME );

    elsif STM_WITH_EXP_NAME.TY = DN_ASSIGN
    then
      CODE_ASSIGN( STM_WITH_EXP_NAME );

    elsif STM_WITH_EXP_NAME.TY = DN_EXIT
    then
      CODE_EXIT( STM_WITH_EXP_NAME );

    end if;
  end	CODE_STM_WITH_EXP_NAME;


				---------
  procedure			CODE_CODE			( CODE :TREE )
  is
    OP_TYPE_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, D( AS_NAME, CODE ) ) );
    AGGREG		: TREE		:= D( AS_EXP, CODE );
    NAMED_ASSOC_LIST	: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, AGGREG ) );
    NAMED_ASSOC		: TREE;
  begin

    while not IS_EMPTY( NAMED_ASSOC_LIST ) loop
      POP( NAMED_ASSOC_LIST, NAMED_ASSOC );
      declare
        CHOICE_LIST		: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, NAMED_ASSOC ) );
        CHOICE_EXP		: TREE;
        USED_OBJECT_ID	: TREE		:= D( AS_EXP, NAMED_ASSOC );
      begin

				-- OPERATION ASM 0 PARAMETRE

        if OP_TYPE_STR = "ASM_OP_0" then
	POP( CHOICE_LIST, CHOICE_EXP );
	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE" then
	  PUT_LINE( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

				-- OPERATION ASM 1 PARAMETRE

        elsif OP_TYPE_STR = "ASM_OP_1" then
	POP( CHOICE_LIST, CHOICE_EXP );
	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE" then
	  PUT( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "VAL" then
	  declare
	    NUM_REP	:constant STRING	:= PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) );
	  begin
	    if NUM_REP'LENGTH >= 4 and then NUM_REP( NUM_REP'FIRST .. NUM_REP'FIRST+2) = "16#" then
	      PUT_LINE( tab & "0x" & NUM_REP( NUM_REP'FIRST+3 .. NUM_REP'LAST-1 ) );
	    else
	      PUT_LINE( tab & NUM_REP );
	    end if;
	  end;
	end if;

				-- OPERATION ASM 2 PARAMETRES

        elsif OP_TYPE_STR = "ASM_OP_2" then
	POP( CHOICE_LIST, CHOICE_EXP );
	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OPCODE" then
	  PUT( tab & PRINT_NAME( D( LX_SYMREP, USED_OBJECT_ID ) ) );
	end if;

	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "LVL" then
	  PUT( tab & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) & ',' );
	end if;

	if PRINT_NAME( D( LX_SYMREP, D( AS_EXP, CHOICE_EXP ) ) ) = "OFS" then
	  PUT_LINE( tab & PRINT_NAME( D( LX_NUMREP, USED_OBJECT_ID ) ) );
	end if;
        end if;

      end;
    end loop;

  end	CODE_CODE;
	---------


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
null;--          EMIT ( STO, A );
        when DN_ENUMERATION =>
          declare
            TYPE_SOURCE_NAME : TREE            := D ( XD_SOURCE_NAME, TYPE_SPEC );
            TYPE_SYMREP      : TREE            := D ( LX_SYMREP, TYPE_SOURCE_NAME );
            NAME             : constant STRING := PRINT_NAME ( TYPE_SYMREP );
          begin
            if NAME = "BOOLEAN" then null;--EMIT ( STO, B );
            elsif NAME = "CHARACTER" then null;--EMIT ( STO, C );
            else null; --EMIT ( STO, I );
            end if;
          end;
        when DN_INTEGER =>
null;--          EMIT ( STO, I );
        when DN_UNIVERSAL_INTEGER =>
null;--          LOAD_ADR( TYPE_SPEC );
--          EMIT( CVB );
--          EMIT( STO, I );
        when others =>
          PUT_LINE ( "!!! STORE_VAL TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end	STORE_VAL;
	---------

    begin

      if NAME.TY = DN_ALL then
--        CODE_ADRESSE( D( AS_NAME,     NAME ) );
        EXPRESSIONS.CODE_EXP( D( AS_EXP,      ASSIGN ) );
--CODI.ARG1_OP( RESULT, TRSF, OPER );
        STORE_VAL   ( D( SM_EXP_TYPE, NAME ) );

      elsif NAME.TY = DN_INDEXED then
        EXPRESSIONS.CODE_INDEXED( NAME );
        EXPRESSIONS.CODE_EXP    ( D( AS_EXP, ASSIGN ) );
        STORE_VAL( D( SM_EXP_TYPE, NAME ) );


      elsif NAME.TY = DN_USED_OBJECT_ID then

        declare
	NAMEXP	: TREE		:= D( SM_EXP_TYPE, NAME );
	DEFN	: TREE		:= D( SM_DEFN, NAME );
        begin

          if NAMEXP.TY = DN_ACCESS then
	  EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
	  CODI.STORE( DEFN );

	elsif NAMEXP.TY = DN_ARRAY then
	  CODE_OBJECT( DEFN );
	  declare
	    EXP	: TREE	:= D( AS_EXP, ASSIGN );
	  begin
	    if EXP.TY = DN_USED_OBJECT_ID then
	      CODE_OBJECT( D( SM_DEFN, EXP ) );
	      CODE_OBJECT( EXP );
--	      EMIT( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
--	      EMIT( CYA );
	    else
	      EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
--	      EMIT( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
--	      EMIT( PUA );
              end if;
            end;

	elsif NAMEXP.TY = DN_ENUMERATION then
	  EXPRESSIONS.CODE_EXP ( D ( AS_EXP, ASSIGN ) );
	  STORE( DEFN );

	elsif NAMEXP.TY = DN_INTEGER then
	  EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
            CODI.STORE( DEFN );
          end if;

        end;
      end if;
    end;
  end	CODE_ASSIGN;
	-----------



  procedure			CODE_EXIT			( ADA_EXIT :TREE )
  is
  begin
    declare
      LVB_LBL		:constant STRING	:= NEW_LABEL;
      EXP			: TREE		:= D ( AS_EXP, ADA_EXIT );
      LOOP_STM		: TREE		:= D ( SM_STM, ADA_EXIT );
      EXITED_LOOP_LEVEL	: LEVEL_NUM	:= LEVEL_NUM( DI( CD_LEVEL, LOOP_STM ) );
      AFTER_LOOP_LABEL	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_AFTER_LOOP, LOOP_STM ) );
    begin
      if EXP = TREE_VOID then
        if EXITED_LOOP_LEVEL /= CODI.CUR_LEVEL then
null;
--             EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
--             GEN_LBL_ASSIGNMENT ( LVB_LBL, INTEGER(CODI.CUR_LEVEL - LOOP_LEVEL) );
        end if;
        PUT_LINE( tab & "BRA" & tab & LABEL_STR( AFTER_LOOP_LABEL ) );
      else
        EXPRESSIONS.CODE_EXP ( EXP );
        if EXITED_LOOP_LEVEL /= CODI.CUR_LEVEL then
          declare
            SKIP_LBL	:constant STRING	:= NEW_LABEL;
          begin
--            EMIT ( JMPF, SKIP_LBL, COMMENT=> "PAS D EXIT SI CONDITION FAUSSE" );
--            LVB_LBL := NEW_LABEL;
--            EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
--            GEN_LBL_ASSIGNMENT ( LVB_LBL, INTEGER(CODI.CUR_LEVEL - LOOP_LEVEL) );
 --           EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
            PUT_LINE( SKIP_LBL & ':' );
          end;
        else
null;--          EMIT ( JMPT, AFTER_LOOP_LABEL );
        end if;
      end if;
    end;
  end	CODE_EXIT;


	------------
end	INSTRUCTIONS;
	------------