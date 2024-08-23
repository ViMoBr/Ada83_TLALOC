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
  begin
    declare
      OLD_AFTER_IF_LBL	: LABEL_TYPE	:= CODI.AFTER_IF_LBL;
    begin
      CODI.AFTER_IF_LBL := NEW_LABEL;
      CODE_TEST_CLAUSE_ELEM_S ( D ( AS_TEST_CLAUSE_ELEM_S, ADA_IF ) );
      WRITE_LABEL( CODI.AFTER_IF_LBL, COMMENT=> "ETIQUETTE END IF" );
      CODI.AFTER_IF_LBL := OLD_AFTER_IF_LBL;
    end;
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



  procedure			CODE_LOOP			( ADA_LOOP :TREE )
  is
  begin
    declare
      OLD_LOOP_STM_S	: TREE		:= CODI.LOOP_STM_S;
      OLD_BEFORE_LOOP_LBL	: LABEL_TYPE	:= CODI.BEFORE_LOOP_LBL;
      OLD_AFTER_LOOP_LBL	: LABEL_TYPE	:= CODI.AFTER_LOOP_LBL;
    begin
      LOOP_STM_S := D ( AS_STM_S, ADA_LOOP );
      CODI.BEFORE_LOOP_LBL := NEW_LABEL;
      CODI.AFTER_LOOP_LBL := NEW_LABEL;
      DI( CD_AFTER_LOOP, ADA_LOOP, INTEGER( AFTER_LOOP_LBL) );
      DI( CD_LEVEL, ADA_LOOP, INTEGER( CODI.CUR_LEVEL ) );
      declare
        ITERATION : TREE := D( AS_ITERATION, ADA_LOOP );
      begin
        if ITERATION = TREE_VOID then
          WRITE_LABEL( BEFORE_LOOP_LBL );
          CODE_STM_S( LOOP_STM_S );
          EMIT( JMP, BEFORE_LOOP_LBL );
        else
          CODE_ITERATION( D( AS_ITERATION, ADA_LOOP ) );
        end if;
      end;
      WRITE_LABEL( AFTER_LOOP_LBL );
      CODI.BEFORE_LOOP_LBL := OLD_BEFORE_LOOP_LBL;
      CODI.AFTER_LOOP_LBL := OLD_AFTER_LOOP_LBL;
      CODI.LOOP_STM_S := OLD_LOOP_STM_S;
    end;
  end	CODE_LOOP;



  procedure			CODE_ITERATION		( ITERATION :TREE )
  is
  begin
    if ITERATION.TY in CLASS_FOR_REV
    then
      CODE_FOR_REV( ITERATION );

    elsif ITERATION.TY = DN_WHILE
    then
      CODE_WHILE( ITERATION );

    end if;
  end;


  procedure			CODE_FOR_REV		( FOR_REV :TREE )
  is
  begin
    declare
      OLD_LOOP_OP_INC_DEC   : OP_CODE      := CODI.LOOP_OP_INC_DEC;
      OLD_LOOP_OP_GT_LT     : OP_CODE      := CODI.LOOP_OP_GT_LT;
      COUNTER, TEMP         : INTEGER;
      OLD_OFFSET_ACT        : OFFSET_VAL  := CODI.OFFSET_ACT;
      ITERATION_ID          : TREE         := D ( AS_SOURCE_NAME, FOR_REV );
      ACT                   : CODE_DATA_TYPE    := CODI.CODE_DATA_TYPE_OF ( D ( SM_OBJ_TYPE, ITERATION_ID ) );
      procedure LOAD_DSCRT_RANGE ( DSCRT_RANGE : TREE ) is
      begin
        null;
      end;
    begin
      CODI.BEFORE_LOOP_LBL := NEW_LABEL;
      CODI.AFTER_LOOP_LBL := NEW_LABEL;

    if FOR_REV.TY = DN_FOR then
      CODE_FOR ( FOR_REV );

    elsif FOR_REV.TY = DN_REVERSE then
      CODE_REVERSE ( FOR_REV );

    end if;
      case ACT is
      when B =>
        ALIGN ( BOOL_AL );
        COUNTER := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( BOOL_SIZE);
        ALIGN ( BOOL_AL);
        TEMP := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( BOOL_SIZE );
      when C =>
        ALIGN ( CHAR_AL );
        COUNTER := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( CHAR_SIZE );
        ALIGN ( CHAR_AL);
        TEMP := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( CHAR_SIZE );
      when I =>
        ALIGN ( INTG_AL );
        COUNTER := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( INTG_SIZE );
        ALIGN ( INTG_AL );
        TEMP := -CODI.OFFSET_ACT;
        ALTER_OFFSET ( INTG_SIZE );
      when A =>
        PUT_LINE ( "!!! COMPILE_STM_LOOP_REVERSE ACT ILLICITE " & CODE_DATA_TYPE'IMAGE ( ACT ) );
        raise PROGRAM_ERROR;
      end case;
      DI ( CD_LEVEL, ITERATION_ID, INTEGER( CODI.CUR_LEVEL ) );
      DI ( CD_OFFSET, ITERATION_ID, COUNTER );
      LOAD_DSCRT_RANGE ( D ( AS_DISCRETE_RANGE, FOR_REV ) );
      EMIT ( SLD, ACT, 0, TEMP );
      WRITE_LABEL ( CODI.BEFORE_LOOP_LBL );
      EMIT ( SLD, ACT, 0, COUNTER );
      EMIT ( PLD, ACT, 0, COUNTER );
      EMIT ( PLD, ACT, 0, TEMP );
      EMIT ( CODI.LOOP_OP_GT_LT, ACT );
      EMIT ( JMPT, CODI.AFTER_LOOP_LBL );
      CODE_STM_S ( LOOP_STM_S );
      EMIT ( PLD, ACT, 0, COUNTER );
      EMIT ( CODI.LOOP_OP_INC_DEC, ACT, 1 );
      EMIT ( JMP, CODI.BEFORE_LOOP_LBL );
      WRITE_LABEL ( CODI.AFTER_LOOP_LBL );
      CODI.OFFSET_ACT := OLD_OFFSET_ACT;
      CODI.LOOP_OP_INC_DEC := OLD_LOOP_OP_INC_DEC;
      CODI.LOOP_OP_GT_LT := OLD_LOOP_OP_GT_LT;
    end;
  end	CODE_FOR_REV;



  procedure			CODE_FOR			( ADA_FOR :TREE )
  is
  begin
    LOOP_OP_INC_DEC := INC;
    LOOP_OP_GT_LT := GT;
  end	CODE_FOR;



  procedure			CODE_REVERSE		( ADA_REVERSE :TREE )
  is
  begin
    LOOP_OP_INC_DEC := DEC;
    LOOP_OP_GT_LT := LT;
  end	CODE_REVERSE;



  procedure			CODE_WHILE		( ADA_WHILE :TREE )
  is
    OPER		: OPERAND_REF;
  begin
    BEFORE_LOOP_LBL := NEW_LABEL;
    AFTER_LOOP_LBL := NEW_LABEL;
    WRITE_LABEL( BEFORE_LOOP_LBL );
    OPER := EXPRESSIONS.CODE_EXP( D ( AS_EXP, ADA_WHILE ) );
    EMIT( JMPF, AFTER_LOOP_LBL );
    CODE_STM_S ( LOOP_STM_S );
    EMIT( JMP, BEFORE_LOOP_LBL );

  end	CODE_WHILE;



  procedure			CODE_BLOCK		( BLOCK :TREE )
  is
  begin
    declare
      AFTER_BLOCK_LBL : LABEL_TYPE := NEW_LABEL;
      PROC_LBL        : LABEL_TYPE := NEW_LABEL;
    begin
      EMIT ( MST, INTEGER ( 0 ), INTEGER( 0 ), COMMENT=> "POUR BLOC" );
      EMIT ( CALL, CODI.RELATIVE_RESULT_OFFSET, PROC_LBL,
             COMMENT=> "APPEL DE BLOC" );
      EMIT ( JMP, AFTER_BLOCK_LBL, COMMENT=> "SAUT POST BLOC" );
      WRITE_LABEL ( PROC_LBL);
      declare
        OLD_OFFSET_ACT : OFFSET_VAL := CODI.OFFSET_ACT;
        OLD_OFFSET_MAX : OFFSET_VAL := CODI.OFFSET_MAX;
      begin
        CODI.OFFSET_ACT := FIRST_LOCAL_VAR_OFFSET;
        CODI.OFFSET_MAX := FIRST_LOCAL_VAR_OFFSET;
        INC_LEVEL;
        STRUCTURES.CODE_BLOCK_BODY ( D ( AS_BLOCK_BODY, BLOCK ) );
        DEC_LEVEL;
        CODI.OFFSET_ACT := OLD_OFFSET_ACT;
        CODI.OFFSET_MAX := OLD_OFFSET_MAX;
      end;
      WRITE_LABEL ( AFTER_BLOCK_LBL );
    end;

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



  procedure			CODE_CALL_STM		( CALL_STM :TREE )
  is
  begin

    if CALL_STM.TY = DN_PROCEDURE_CALL then
      CODE_PROCEDURE_CALL ( CALL_STM );

    elsif CALL_STM.TY = DN_ENTRY_CALL then
      CODE_ENTRY_CALL ( CALL_STM );

    end if;
  end	CODE_CALL_STM;



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
	OPER		: OPERAND_REF;
        begin
          if EXPR_TYPE.TY = DN_ARRAY then
            EMIT( PLA, INTEGER( LEVEL_NUM( ENCLOSING_LEVEL ) - CODI.CUR_LEVEL ), RESULT_OFFSET );
            OPER := EXPRESSIONS.CODE_EXP( EXP );
            EMIT( LDC, I, CODI.NUMBER_OF_DIMENSIONS ( EXP ) );
            EMIT( PUA );
          elsif EXPR_TYPE.TY = DN_ENUM_LITERAL_S then
            OPER := EXPRESSIONS.CODE_EXP ( EXP );
            EMIT( SLD, CODI.CODE_DATA_TYPE_OF ( EXP ), INTEGER( LEVEL_NUM( ENCLOSING_LEVEL) - CODI.CUR_LEVEL ), RESULT_OFFSET );
	elsif EXPR_TYPE.TY = DN_INTEGER then
	  OPER := EXPRESSIONS.CODE_EXP ( EXP );
            EMIT( SLD, I, INTEGER( LEVEL_NUM( ENCLOSING_LEVEL) - CODI.CUR_LEVEL ), RESULT_OFFSET );
          end if;
        end STORE_FUNCTION_RESULT;
      end if;
      CODI.PERFORM_RETURN ( CODI.ENCLOSING_BODY );
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



  procedure			CODE_CODE			( CODE :TREE )
  is
  begin
    null;
  end	CODE_CODE;



				-----------
  procedure			CODE_ASSIGN		( ASSIGN :TREE )
  is
  begin
    declare
      NAME	: TREE	:= D ( AS_NAME, ASSIGN );
      OPER	: OPERAND_REF;

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
          OPER := LOAD_ADR( TYPE_SPEC );
          EMIT( CVB );
          EMIT( STO, I );
        when others =>
          PUT_LINE ( "!!! STORE_VAL TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end	STORE_VAL;
	---------

    begin

      if NAME.TY = DN_ALL then
--        CODE_ADRESSE( D( AS_NAME,     NAME ) );
        OPER := EXPRESSIONS.CODE_EXP( D( AS_EXP,      ASSIGN ) );
--CODI.ARG1_OP( RESULT, TRSF, OPER );
        STORE_VAL   ( D( SM_EXP_TYPE, NAME ) );

      elsif NAME.TY = DN_INDEXED then
        EXPRESSIONS.CODE_INDEXED( NAME );
        OPER := EXPRESSIONS.CODE_EXP    ( D( AS_EXP, ASSIGN ) );
        STORE_VAL   ( D( SM_EXP_TYPE, NAME ) );


      elsif NAME.TY = DN_USED_OBJECT_ID then

        declare
	NAMEXP	: TREE		:= D( SM_EXP_TYPE, NAME );
	DEFN	: TREE		:= D( SM_DEFN, NAME );
        begin

          if NAMEXP.TY = DN_ACCESS then
	  OPER := EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
	  CODI.STORE( DEFN, ADR_TYP, OPER );

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
	      OPER := EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
	      EMIT( LDC, I, NUMBER_OF_DIMENSIONS ( NAMEXP ), COMMENT=>"NB DIM" );
	      EMIT( PUA );
              end if;
            end;

	elsif NAMEXP.TY = DN_ENUMERATION then
	  OPER := EXPRESSIONS.CODE_EXP ( D ( AS_EXP, ASSIGN ) );
	  declare
	    OTYPE	: OPERAND_TYPE	:= OPERAND_TYPE_OF( NAMEXP );
	  begin
	    STORE( DEFN, OTYPE, OPER );
	  end;

	elsif NAMEXP.TY = DN_INTEGER then
	  OPER := EXPRESSIONS.CODE_EXP( D( AS_EXP, ASSIGN ) );
            CODI.STORE( DEFN, WORD_TYP, OPER );
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
      LVB_LBL		: LABEL_TYPE;
      EXP			: TREE		:= D ( AS_EXP, ADA_EXIT );
      LOOP_STM		: TREE		:= D ( SM_STM, ADA_EXIT );
      LOOP_LEVEL		: LEVEL_NUM	:= LEVEL_NUM( DI( CD_LEVEL, LOOP_STM ) );
      AFTER_LOOP_LABEL	: LABEL_TYPE	:= LABEL_TYPE( DI( CD_AFTER_LOOP, LOOP_STM ) );
      OPER		: OPERAND_REF;
    begin
      if EXP = TREE_VOID then
        if LOOP_LEVEL /= CODI.CUR_LEVEL then
             LVB_LBL := NEW_LABEL;
--             EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
--             GEN_LBL_ASSIGNMENT ( LVB_LBL, INTEGER(CODI.CUR_LEVEL - LOOP_LEVEL) );
        end if;
        EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
      else
        OPER := EXPRESSIONS.CODE_EXP ( EXP );
        if LOOP_LEVEL /= CODI.CUR_LEVEL then
          declare
            SKIP_LBL : LABEL_TYPE := NEW_LABEL;
          begin
            EMIT ( JMPF, SKIP_LBL, COMMENT=> "PAS D EXIT SI CONDITION FAUSSE" );
            LVB_LBL := NEW_LABEL;
            EMIT ( LVB, LVB_LBL, COMMENT=> "NOMBRE DE NIVEAUX REMONTES" );
--            GEN_LBL_ASSIGNMENT ( LVB_LBL, INTEGER(CODI.CUR_LEVEL - LOOP_LEVEL) );
            EMIT ( JMP, AFTER_LOOP_LABEL, COMMENT=> "SORTIE DE BOUCLE" );
            WRITE_LABEL ( SKIP_LBL, COMMENT=> "LABEL NO EXIT" );
          end;
        else
          EMIT ( JMPT, AFTER_LOOP_LABEL );
        end if;
      end if;
    end;
  end	CODE_EXIT;


	------------
end	INSTRUCTIONS;
	------------