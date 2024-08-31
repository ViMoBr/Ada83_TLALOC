separate ( CODE_GEN )
				-----------
 	package body		EXPRESSIONS
				-----------ldlw
is


  package CODI	renames CODAGE_INTERMEDIAIRE;


				--====--
  procedure			CODE_EXP			( EXP :TREE )
  is
  begin

--put_line( "EXP.TY " & NODE_NAME'IMAGE( EXP.TY ) );

    if EXP.TY = DN_NUMERIC_LITERAL	then CODE_NUMERIC_LITERAL( EXP );

    elsif EXP.TY = DN_USED_OBJECT_ID	then CODE_USED_OBJECT_ID( EXP );

    elsif EXP.TY = DN_PARENTHESIZED	then CODE_EXP( D( AS_EXP, EXP ) );

    elsif EXP.TY = DN_INDEXED		then CODE_INDEXED ( EXP );

    elsif EXP.TY = DN_FUNCTION_CALL	then CODE_FUNCTION_CALL( EXP );

    elsif EXP.TY = DN_USED_OP		then CODE_USED_OP( EXP );

    elsif EXP.TY = DN_USED_CHAR	then CODE_USED_CHAR( EXP );

-- elsif EXP.TY in CLASS_EXP_EXP
--     then
--       return CODE_EXP_EXP( EXP );

    end if;

  end	CODE_EXP;
	--====--


				--------------------
  procedure			CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL :TREE )
  is
    VAL	: TREE	:= D( SM_VALUE, NUMERIC_LITERAL );
  begin
    if VAL.PT = HI and then VAl.NOTY = DN_NUM_VAL
    then
      PUT_LINE( tab & "LDI" & tab & INTEGER'IMAGE( DI( SM_VALUE, NUMERIC_LITERAL ) ) );

    elsif VAL.TY = DN_REAL_VAL
    then
      PUT_LINE( ';' & tab & "CODE_GEN-EXPRESSIONS.CODE_NUMERIC_LITERAL : DN_REAL_VAL (TODO)" );

    end if;

  end	CODE_NUMERIC_LITERAL;
	--------------------


				-------------------
  procedure			CODE_USED_OBJECT_ID		( USED_OBJECT_ID :TREE )
  is
    DEFN		: TREE		:= D( SM_DEFN, USED_OBJECT_ID ) ;
  begin
    case DEFN.TY is
    when DN_CONSTANT_ID | DN_VARIABLE_ID	=> CODE_VC_ID( DEFN );
    when DN_ITERATION_ID			=> LOAD_MEM( DEFN );
    when DN_ENUMERATION_ID | DN_CHARACTER_ID	=> PUT_LINE( ASCII.HT & "LDI" & ASCII.HT & INTEGER'IMAGE( DI( SM_REP, DEFN ) ) );
    when DN_IN_ID | DN_IN_OUT_ID		=> LOAD_MEM( DEFN );
--    when DN_OUT_ID				=> CODE_PRM_ID( DEFN );
    when others => raise PROGRAM_ERROR;
    end case;
 
  end	CODE_USED_OBJECT_ID;
	-------------------


				----------
  procedure			CODE_VC_ID		( CONSTANT_ID :TREE )
  is
    CST_TYPE	: TREE	:= D( SM_OBJ_TYPE, CONSTANT_ID );
  begin
    case CST_TYPE.TY is
    when DN_ARRAY => null;
    when DN_INTEGER | DN_ACCESS | DN_ENUMERATION
    =>
      LOAD_MEM( CONSTANT_ID );
--      PUT_LINE( tab & "LDW" & ' ' & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & tab & PRINT_NAME( D(LX_SYMREP, CONSTANT_ID ) ) & "_disp" );
    when others
    =>
      PUT_LINE( ';' & tab & "CODE_VC_ID ERROR " & NODE_NAME'IMAGE( CST_TYPE.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	CODE_VC_ID;
	----------


				------------------
  procedure			CODE_FUNCTION_CALL		( FUNCTION_CALL :TREE )
  is
    NAME		: TREE		:= D( AS_NAME,		FUNCTION_CALL );
    PARAMS	: TREE		:= D( SM_NORMALIZED_PARAM_S,	FUNCTION_CALL );
    DEFN		: TREE		:= D( SM_DEFN,		NAME );
    OPER		: OPERAND_REF	:= NO_OPERAND;

  begin

    if DEFN.TY = DN_BLTN_OPERATOR_ID then
      declare
        OP_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, DEFN ) );
        PRM_S	: SEQ_TYPE	:= LIST( PARAMS );
        PRM	: TREE;
      begin
        POP( PRM_S, PRM );
        CODE_EXP( PRM );
        if IS_EMPTY( PRM_S ) then goto UNARY; end if;
        POP( PRM_S, PRM );
        CODE_EXP( PRM );
        if OP_STR = """+""" then  PUT_LINE( ASCII.HT & "ADD" ); end if;
        if OP_STR = """-""" then  PUT_LINE( ASCII.HT & "SUB" ); end if;
        if OP_STR = """*""" then  PUT_LINE( ASCII.HT & "MUL" ); end if;
        if OP_STR = """/""" then  PUT_LINE( ASCII.HT & "DIV" ); end if;
        return;
<<UNARY>>
        if OP_STR = """-""" then PUT_LINE( ASCII.HT & "NEG" ); end if;
      end;

    end if;

  end	CODE_FUNCTION_CALL;
	------------------



				------------
  procedure			CODE_INDEXED	( INDEXED :TREE )
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


				--------------
  procedure			CODE_USED_NAME		( USED_NAME :TREE )
  is
  begin

    if USED_NAME.TY = DN_USED_OP
    then CODE_USED_OP ( USED_NAME );

    elsif USED_NAME.TY = DN_USED_NAME_ID
    then CODE_USED_NAME_ID ( USED_NAME );

    end if;
  end	CODE_USED_NAME;
	--------------


				------------
  procedure			CODE_USED_OP		( USED_OP :TREE )
  is
    DEFN		: TREE		:= D( SM_DEFN, USED_OP ) ;
    SYM		: TREE		:= D( LX_SYMREP, DEFN );
  begin
    put_line( "; used op " & PRINT_NAME( SYM ) );
  end	CODE_USED_OP;
	------------



				--------------
  procedure			CODE_USED_CHAR		( USED_CHAR :TREE )
  is
  begin
    PUT_LINE( tab & "LDI" & tab & INTEGER'IMAGE( DI( SM_VALUE, USED_CHAR ) ) );
  end	CODE_USED_CHAR;
	--------------



				-----------------
  procedure			CODE_USED_NAME_ID		( USED_NAME_ID :TREE )
  is
  begin
    declare
      DEFN	: TREE	:= D( SM_DEFN,   USED_NAME_ID );
      SYMREP	: TREE	:= D( LX_SYMREP, USED_NAME_ID );
    begin
      if DEFN.TY = DN_EXCEPTION_ID then
        declare
	LABEL	: TREE := D( CD_LABEL, DEFN );
--	LBL	: LABEL_TYPE;
        begin
--	if LABEL.TY /= DN_NUM_VAL then
--	  LBL := NEW_LABEL;
--	  DI( CD_LABEL, DEFN, INTEGER( LBL ) );
--	  EMIT( EXL, LBL, S=> PRINT_NAME( SYMREP ),
--			COMMENT=> "NUM D EXCEPTION EXTERNE ATTRIBUE SUR USED_NAME_ID" );
--	end if;
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
--	  EMIT( RFP, CODI.CUR_COMP_UNIT, S=> PRINT_NAME( SYMREP ) );
	  PUT_LINE( "; RFP" & PRINT_NAME( SYMREP ) );
	  CODI.GENERATE_CODE := FALSE;
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
	  CODI.GENERATE_CODE := TRUE;
	  EMIT( RFP, INTEGER( 0 ), S=> PRINT_NAME ( SYMREP ) );
--	  DI  ( CD_LABEL,      DEFN, INTEGER ( PROC_LBL ) );
	  DI  ( CD_LEVEL,      DEFN, 1 );
	  DI  ( CD_PARAM_SIZE, DEFN, 0 );
	  DB  ( CD_COMPILED,   DEFN, TRUE );
PUT_LINE( "; RFP" & tab & PROC_LBL );
--	  EMIT( RFL, PROC_LBL );
	end;
        end if;
      end if;
    end;
  end	CODE_USED_NAME_ID;
	-----------------



				-------------
  procedure			CODE_NAME_EXP		( NAME_EXP :TREE )
  is
  begin

    if NAME_EXP.TY = DN_INDEXED then
      CODE_INDEXED ( NAME_EXP );

    elsif NAME_EXP.TY = DN_FUNCTION_CALL
    then CODE_FUNCTION_CALL( NAME_EXP );

    elsif NAME_EXP.TY = DN_SLICE
    then CODE_SLICE ( NAME_EXP );

    elsif NAME_EXP.TY = DN_ALL
    then CODE_ALL ( NAME_EXP );

    end if;
  end	CODE_NAME_EXP;
	-------------





				----------
  procedure			CODE_SLICE		( SLICE :TREE )
  is
  begin
    null;
  end	CODE_SLICE;
	----------


				--------
  procedure			CODE_ALL			( ADA_ALL :TREE )
  is
  begin
    null;
  end	CODE_ALL;
	--------


				------------
  procedure			CODE_EXP_EXP		( EXP_EXP :TREE )
  is
  begin

    if EXP_EXP.TY in CLASS_EXP_VAL
    then CODE_EXP_VAL ( EXP_EXP );

    elsif EXP_EXP.TY in CLASS_AGG_EXP
    then CODE_AGG_EXP ( EXP_EXP );

    elsif EXP_EXP.TY = DN_QUALIFIED_ALLOCATOR
    then CODE_QUALIFIED_ALLOCATOR ( EXP_EXP );

    elsif EXP_EXP.TY = DN_SUBTYPE_ALLOCATOR
    then CODE_SUBTYPE_ALLOCATOR ( EXP_EXP );

    end if;

  end	CODE_EXP_EXP;
	------------


				------------
  procedure			CODE_EXP_VAL		( EXP_VAL :TREE )
  is
  begin

    if EXP_VAL.TY in CLASS_EXP_VAL_EXP
    then CODE_EXP_VAL_EXP( EXP_VAL );

--    elsif EXP_VAL.TY = DN_NUMERIC_LITERAL then
--      return CODE_NUMERIC_LITERAL( EXP_VAL );

    elsif EXP_VAL.TY = DN_NULL_ACCESS
    then CODE_NULL_ACCESS( EXP_VAL );

    elsif EXP_VAL.TY = DN_SHORT_CIRCUIT
    then CODE_SHORT_CIRCUIT( EXP_VAL );

    end if;
  end	CODE_EXP_VAL;
	------------

				----------------
  procedure			CODE_EXP_VAL_EXP		( EXP_VAL_EXP :TREE )
  is
  begin

    if EXP_VAL_EXP.TY in CLASS_QUAL_CONV then
      CODE_QUAL_CONV( EXP_VAL_EXP );

    elsif EXP_VAL_EXP.TY in CLASS_MEMBERSHIP then
      CODE_MEMBERSHIP( EXP_VAL_EXP );

--    elsif EXP_VAL_EXP.TY = DN_PARENTHESIZED then
--      return CODE_PARENTHESIZED( EXP_VAL_EXP );

    end if;

  end	CODE_EXP_VAL_EXP;
	----------------


				---------------
  procedure			CODE_MEMBERSHIP		( MEMBERSHIP :TREE )
  is
  begin

    if MEMBERSHIP.TY = DN_RANGE_MEMBERSHIP
    then
      CODE_RANGE_MEMBERSHIP( MEMBERSHIP );

    elsif MEMBERSHIP.TY = DN_TYPE_MEMBERSHIP
    then
      CODE_TYPE_MEMBERSHIP( MEMBERSHIP );

    end if;
  end	CODE_MEMBERSHIP;
	---------------



				---------------------
  procedure			CODE_RANGE_MEMBERSHIP	( RANGE_MEMBERSHIP :TREE )
  is
  begin
    null;
  end	CODE_RANGE_MEMBERSHIP;
	---------------------


				--------------------
  procedure			CODE_TYPE_MEMBERSHIP	( TYPE_MEMBERSHIP :TREE )
  is
  begin
    null;
  end	CODE_TYPE_MEMBERSHIP;
	--------------------





				----------------
  procedure			CODE_NULL_ACCESS		( NULL_ACCESS :TREE )
  is
  begin
    null;
  end	CODE_NULL_ACCESS;
	----------------


				------------------
  procedure			CODE_SHORT_CIRCUIT		( SHORT_CIRCUIT :TREE )
  is
  begin
    null;
  end	CODE_SHORT_CIRCUIT;
	------------------


				--------------
  procedure			CODE_QUAL_CONV		( QUAL_CONV :TREE )
  is
  begin

    if QUAL_CONV.TY = DN_CONVERSION then
      CODE_CONVERSION ( QUAL_CONV );

    elsif QUAL_CONV.TY = DN_QUALIFIED then
      CODE_QUALIFIED ( QUAL_CONV );

    end if;
  end	CODE_QUAL_CONV;
	--------------


				---------------
  procedure			CODE_CONVERSION		( CONVERSION :TREE )
  is
  begin
    null;
  end	CODE_CONVERSION;
	---------------


				--------------
  procedure			CODE_QUALIFIED		( QUALIFIED :TREE )
  is
  begin
    null;
  end	CODE_QUALIFIED;
	--------------


				------------
  procedure			CODE_AGG_EXP		( AGG_EXP :TREE )
  is
  begin

    if AGG_EXP.TY = DN_AGGREGATE
    then
      CODE_AGGREGATE( AGG_EXP );

    elsif AGG_EXP.TY = DN_STRING_LITERAL
    then
      CODE_STRING_LITERAL( AGG_EXP );

    end if;
  end	CODE_AGG_EXP;
	------------


				--------------
  procedure			CODE_AGGREGATE		( AGGREGATE :TREE )
  is
  begin
    null;
  end	CODE_AGGREGATE;
	--------------


				-------------------
  procedure			CODE_STRING_LITERAL		( STRING_LITERAL :TREE )
  is
  begin
    null;
  end	CODE_STRING_LITERAL;
	-------------------


				------------------------
  procedure			CODE_QUALIFIED_ALLOCATOR	( QUALIFIED_ALLOCATOR :TREE )
  is
  begin
    null;
  end	CODE_QUALIFIED_ALLOCATOR;
	------------------------


				----------------------
  procedure			CODE_SUBTYPE_ALLOCATOR	( SUBTYPE_ALLOCATOR :TREE )
  is
  begin
    null;
  end	CODE_SUBTYPE_ALLOCATOR;
	----------------------


	-----------
end	EXPRESSIONS;
	-----------