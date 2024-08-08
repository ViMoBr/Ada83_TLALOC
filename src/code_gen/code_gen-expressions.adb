separate ( CODE_GEN )
				-----------
 	package body		EXPRESSIONS
				-----------
is


  package CODI	renames CODAGE_INTERMEDIAIRE;


				--====--
  function			CODE_EXP			( EXP :TREE )		return OPERAND_REF
  is
  begin

    if EXP.TY in CLASS_NAME
    then
      CODE_NAME( EXP );

    elsif EXP.TY in CLASS_EXP_EXP
    then
      return CODE_EXP_EXP( EXP );

    end if;
    return NO_OPERAND;

  end	CODE_EXP;
	--====--


				---------
  procedure			CODE_NAME			( NAME :TREE )
  is
  begin
    if NAME.TY in CLASS_DESIGNATOR
    then
      CODE_DESIGNATOR( NAME );

    elsif NAME.TY in CLASS_NAME_EXP
    then
      CODE_NAME_EXP( NAME );

    end if;
  end	CODE_NAME;
	---------


				---------------
  procedure			CODE_DESIGNATOR		( DESIGNATOR :TREE )
  is
  begin
    if DESIGNATOR.TY in CLASS_USED_OBJECT
    then
      CODE_USED_OBJECT( DESIGNATOR );

    elsif DESIGNATOR.TY in CLASS_USED_NAME
    then
      CODE_USED_NAME( DESIGNATOR );

    end if;
  end	CODE_DESIGNATOR;
	---------------


				----------------
  procedure			CODE_USED_OBJECT		( USED_OBJECT :TREE )
  is
  begin

    if USED_OBJECT.TY = DN_USED_CHAR
    then
      CODE_USED_CHAR( USED_OBJECT );

    elsif USED_OBJECT.TY = DN_USED_OBJECT_ID
    then
      CODE_USED_OBJECT_ID( USED_OBJECT );

    end if;
  end	CODE_USED_OBJECT;
	----------------


				--------------
  procedure			CODE_USED_CHAR		( USED_CHAR :TREE )
  is
  begin
    null;
  end	CODE_USED_CHAR;
	--------------


				-------------------
  procedure			CODE_USED_OBJECT_ID		( USED_OBJECT_ID :TREE )
  is
    DEFN		: TREE		:= D( SM_DEFN, USED_OBJECT_ID ) ;
  begin
    case DEFN.TY is
    when DN_CONSTANT_ID =>                  CODE_CONSTANT_ID( DEFN );
--               when CONST_ID =>                  Expr_used_object_id_const_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when VAR_ID =>                  Expr_used_object_id_var_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when DEF_CHAR =>                  Expr_used_object_id_def_char ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when ENUM_ID =>                  Expr_used_object_id_enum_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when ITERATION_ID =>                  Expr_used_object_id_iteration_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when IN_ID =>                  Expr_used_object_id_in_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when IN_OUT_ID =>                  Expr_used_object_id_in_out_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
--               when OUT_ID =>                  Expr_used_object_id_out_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
    when others => raise PROGRAM_ERROR;
    end case;

  end	CODE_USED_OBJECT_ID;
	-------------------



				----------------
  procedure			CODE_CONSTANT_ID		( CONSTANT_ID :TREE )
  is
    CST_TYPE	: TREE	:= D( SM_OBJ_TYPE, CONSTANT_ID );
  begin
    case CST_TYPE.TY is
    when DN_INTEGER => null;
    when DN_ARRAY => null;
    when DN_ACCESS => null;
    when DN_ENUM_LITERAL_S => null;
    when others => raise PROGRAM_ERROR;
    end case;
  end	CODE_CONSTANT_ID;
	----------------



				----------------
  procedure			CODE_VARIABLE_ID		( VARIABLE_ID :TREE )
  is
  begin
    null;
  end	CODE_VARIABLE_ID;
	----------------


				--------------
  procedure			CODE_USED_NAME		( USED_NAME :TREE )
  is
  begin

    if USED_NAME.TY = DN_USED_OP then
      CODE_USED_OP ( USED_NAME );

    elsif USED_NAME.TY = DN_USED_NAME_ID then
      CODE_USED_NAME_ID ( USED_NAME );

    end if;
  end	CODE_USED_NAME;
	--------------


				------------
  procedure			CODE_USED_OP		( USED_OP :TREE )
  is
  begin
    null;
  end	CODE_USED_OP;
	------------



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
	  EMIT( RFP, CODI.CUR_COMP_UNIT, S=> PRINT_NAME( SYMREP ) );
	  CODI.GENERATE_CODE := FALSE;
	  DB( CD_COMPILED, DEFN, TRUE );
	  DECLARATIONS.CODE_DECL_S( D( AS_DECL_S1, PACKAGE_SPEC ) );
	end;
        end if;
        CODI.CUR_COMP_UNIT := CUR_COMP_UNIT + 1;

      elsif DEFN.TY = DN_PROCEDURE_ID then
        if not DB( CD_COMPILED, DEFN ) then
	declare
	  PROC_LBL	: LABEL_TYPE	:= NEW_LABEL;
	begin
	  CODI.GENERATE_CODE := TRUE;
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
  end	CODE_USED_NAME_ID;
	-----------------



				-------------
  procedure			CODE_NAME_EXP		( NAME_EXP :TREE )
  is
  begin

    if NAME_EXP.TY = DN_INDEXED then
      CODE_INDEXED ( NAME_EXP );

    elsif NAME_EXP.TY = DN_FUNCTION_CALL then
      CODE_FUNCTION_CALL( NAME_EXP );

    elsif NAME_EXP.TY = DN_SLICE then
      CODE_SLICE ( NAME_EXP );

    elsif NAME_EXP.TY = DN_ALL then
      CODE_ALL ( NAME_EXP );

    end if;
  end	CODE_NAME_EXP;
	-------------

				------------------
  procedure			CODE_FUNCTION_CALL		( FUNCTION_CALL :TREE )
  is
  begin
    null;
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
        OPER	: OPERAND_REF;
      begin
        POP( EXP_S, EXP );
        OPER := CODE_EXP( EXP );
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
  function			CODE_EXP_EXP		( EXP_EXP :TREE )		return OPERAND_REF
  is
  begin

    if EXP_EXP.TY in CLASS_EXP_VAL
    then
      return CODE_EXP_VAL ( EXP_EXP );

    elsif EXP_EXP.TY in CLASS_AGG_EXP
    then
      CODE_AGG_EXP ( EXP_EXP );

    elsif EXP_EXP.TY = DN_QUALIFIED_ALLOCATOR
    then
      CODE_QUALIFIED_ALLOCATOR ( EXP_EXP );

    elsif EXP_EXP.TY = DN_SUBTYPE_ALLOCATOR
    then
      CODE_SUBTYPE_ALLOCATOR ( EXP_EXP );

    end if;
    return NO_OPERAND;

  end	CODE_EXP_EXP;
	------------


				------------
  function			CODE_EXP_VAL		( EXP_VAL :TREE )		return OPERAND_REF
  is
  begin

    if EXP_VAL.TY in CLASS_EXP_VAL_EXP
    then
      return CODE_EXP_VAL_EXP( EXP_VAL );

    elsif EXP_VAL.TY = DN_NUMERIC_LITERAL then
      return CODE_NUMERIC_LITERAL( EXP_VAL );

    elsif EXP_VAL.TY = DN_NULL_ACCESS then
      CODE_NULL_ACCESS( EXP_VAL );

    elsif EXP_VAL.TY = DN_SHORT_CIRCUIT then
      CODE_SHORT_CIRCUIT( EXP_VAL );

    end if;
    return NO_OPERAND;
  end	CODE_EXP_VAL;
	------------

				----------------
  function			CODE_EXP_VAL_EXP		( EXP_VAL_EXP :TREE )	return OPERAND_REF
  is
  begin

    if EXP_VAL_EXP.TY in CLASS_QUAL_CONV then
      CODE_QUAL_CONV( EXP_VAL_EXP );

    elsif EXP_VAL_EXP.TY in CLASS_MEMBERSHIP then
      CODE_MEMBERSHIP( EXP_VAL_EXP );

    elsif EXP_VAL_EXP.TY = DN_PARENTHESIZED then
      return CODE_PARENTHESIZED( EXP_VAL_EXP );

    end if;
    return NO_OPERAND;

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


				------------------
  function			CODE_PARENTHESIZED		( PARENTHESIZED :TREE )	return OPERAND_REF
  is
  begin
    return CODE_EXP( D( AS_EXP, PARENTHESIZED ) );

  end	CODE_PARENTHESIZED;
	------------------

				--------------------
  function			CODE_NUMERIC_LITERAL	( NUMERIC_LITERAL :TREE )	return OPERAND_REF
  is
    VAL	: TREE	:= D( SM_VALUE, NUMERIC_LITERAL );
  begin
    if VAL.PT = HI and then VAl.NOTY = DN_NUM_VAL then
      declare
        OPER	: OPERAND_REF	:= CODI.LOAD_IMM( DI( SM_VALUE, NUMERIC_LITERAL ) );
      begin
        return OPER;
      end;
    elsif VAL.TY = DN_REAL_VAL then
      null;			-- A FAIRE
    end if;
    return NO_OPERAND;

  end	CODE_NUMERIC_LITERAL;
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