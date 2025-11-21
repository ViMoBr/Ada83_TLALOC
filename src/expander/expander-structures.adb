------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	EXPANDER-SRUCTURES.ADB	VINCENT MORIN	9/1/2025	UNIVERSITE DE BRETAGNE OCCIDENTALE
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1


separate ( EXPANDER )
				----------
 	package body		STRUCTURES
				----------
is


  package CODI	renames EXPANDER.UTILS;
  use CODI;


				--=================--
  procedure			CODE_COMPILATION_UNIT	( COMPILATION_UNIT :TREE )
  is
    UNIT_ALL_DECL		: TREE	:= D( AS_ALL_DECL, COMPILATION_UNIT );
  begin
    CODI.CUR_LEVEL      := 0;
    CODI.ENCLOSING_BODY := TREE_VOID;

    CODE_WITH_CONTEXT( D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT ) );

    case  UNIT_ALL_DECL.TY  is

    when  DN_SUBPROG_ENTRY_DECL	=>
      CODI.IN_SPEC_UNIT := TRUE;
      DECLARATIONS.CODE_SUBPROG_ENTRY_DECL( UNIT_ALL_DECL );						-- les instanciations génériques sont comprises  (unit_kind instantiation)

    when  DN_PACKAGE_DECL		=>
      CODI.IN_SPEC_UNIT := TRUE;
      DECLARATIONS.CODE_PACKAGE_DECL( UNIT_ALL_DECL );							-- les instanciations génériques sont comprises  (unit_kind instantiation)

    when  DN_GENERIC_DECL		=>
      DECLARATIONS.CODE_GENERIC_DECL( UNIT_ALL_DECL );

    when  DN_SUBPROGRAM_BODY		=>
      CODE_SUBPROGRAM_BODY( UNIT_ALL_DECL );

    when  DN_PACKAGE_BODY		=>
      CODI.IN_SPEC_UNIT := FALSE;
      CODE_PACKAGE_BODY( UNIT_ALL_DECL );

    when  DN_SUBUNIT		=>
      CODE_SUBUNIT( UNIT_ALL_DECL );

    when others			=> raise PROGRAM_ERROR;
    end case;

  end	CODE_COMPILATION_UNIT;
	--=================--



				-----------------
  procedure			CODE_WITH_CONTEXT		( CONTEXT_ELEM_S :TREE )
  is
    CONTEXT_ELEM_SEQ	: SEQ_TYPE	:= LIST( CONTEXT_ELEM_S );
    CONTEXT_ELEM		: TREE;
		-----------------
    procedure	INSERT_WITHED_PKG	( DEFN :TREE )
    is
    begin
      PUT_LINE( "include '" & PRINT_NAME( D( LX_SYMREP, DEFN ) ) & ".FINC'" );
      DB( CD_COMPILED, DEFN, TRUE );
    end	INSERT_WITHED_PKG;
	-----------------
  begin

    while  not IS_EMPTY( CONTEXT_ELEM_SEQ )  loop
      POP( CONTEXT_ELEM_SEQ, CONTEXT_ELEM );

      if  CONTEXT_ELEM.TY = DN_WITH  then
        declare
	NAME_S		:constant TREE	:= D( AS_NAME_S, CONTEXT_ELEM );
	NAME_SEQ		: SEQ_TYPE	:= LIST( NAME_S );
	NAME		: TREE;
        begin
	while  not IS_EMPTY( NAME_SEQ )  loop
	  POP( NAME_SEQ, NAME );

	  declare
	    DEFN	: TREE	:= D( SM_DEFN, NAME );
	  begin
	    if  DEFN.TY = DN_PACKAGE_ID
	    then  INSERT_WITHED_PKG( DEFN );

	    elsif  DEFN.TY = DN_PROCEDURE_ID  then
	      if  not DB( CD_COMPILED, DEFN )  then
	        declare
		SUBP_LBL	:constant STRING	:= NEW_LABEL;
	        begin
		DI( CD_LEVEL,      DEFN,  1 );
		DI( CD_PARAM_SIZE, DEFN,  0 );
		DB( CD_COMPILED,   DEFN,  TRUE );
	        end;
	      end if;
	    end if;
	  end;

	end loop;
        end;
      end if;
    end loop;

  end	CODE_WITH_CONTEXT;
	-----------------



				--------------------
  procedure			CODE_SUBPROGRAM_BODY	( SUBPROGRAM_BODY :TREE )
  is
    LBL			: LABEL_TYPE;
    SOURCE_NAME		: TREE		:= D( AS_SOURCE_NAME, SUBPROGRAM_BODY );
    SUB_NAME		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) );
    DECL_ID		: TREE		:= D( SM_FIRST, SOURCE_NAME );
    SAVE_ENCLOSING		: TREE		:= ENCLOSING_BODY;
    SAVE_NO_SUB_PARAM	: BOOLEAN		:= CODI.NO_SUBP_PARAMS;
  begin

    INC_LEVEL;

    if  DECL_ID = SOURCE_NAME  then									-- PREMIERE DEFINITION PAS DE SPEC DEJA ETIQUETEE
      LBL := NEW_LABEL;
      DI( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
      DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );

    else
      LBL := LABEL_TYPE( DI( CD_LABEL, DECL_ID ) );
      DI( CD_LEVEL, SOURCE_NAME, DI( CD_LEVEL, DECL_ID ) );
      DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );

    end if;

    if  ENCLOSING_BODY /= TREE_VOID  then
      NEW_LINE;
      PUT_LINE( "if defined " & SUB_NAME & '_' & LABEL_STR( LBL ) & '_' );
    end if;

    PUT( "PRO" & tab & SUB_NAME & '_' & LABEL_STR( LBL ) );
    if  CODI.DEBUG  then PUT( tab50 & ";---------- PRO " & SUB_NAME ); end if;
    NEW_LINE;

    DECLARATIONS.CODE_HEADER( D( SM_SPEC, SOURCE_NAME ) );

    ENCLOSING_BODY := SUBPROGRAM_BODY;

    CODE_BODY( D( AS_BODY, SUBPROGRAM_BODY ) );

    PUT_LINE( "ret_lbl:" );
    PUT_LINE( tab & "UNLINK" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );

    PUT( tab & "RTD" );
    if  CODI.NO_SUBP_PARAMS = FALSE  then  PUT( tab & "(prm_siz" );
      if  SOURCE_NAME.TY = DN_FUNCTION_ID  then
        PUT( INTEGER'IMAGE( - STACK_ELEMENT_SIZE ) );							-- POUR UNE FONCTION NE PAS LIBERER LE RESULTAT
      end if;
      PUT( ')' );
    end if;
    CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;
    NEW_LINE;
    PUT_LINE( "excep:" );

    PUT( "endPRO" );
    if  CODI.DEBUG  then PUT( tab50 & ";---------- end PRO " & SUB_NAME); end if;
    NEW_LINE;

    DEC_LEVEL;
    ENCLOSING_BODY := SAVE_ENCLOSING;
    if  ENCLOSING_BODY /= TREE_VOID  then
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
    CAS_NORMAL	: BOOLEAN		:= PACK_NAME /= "STANDARD" and PACK_NAME /= "_STANDRD";
  begin
    if  PACK_DEF.TY = DN_GENERIC_ID  then
      IN_GENERIC_BODY := TRUE;
      PUT_LINE( PACK_NAME & " = " & "'" & PACK_NAME & "'" );
      PUT( "namespace " & PACK_NAME );
      if  CODI.DEBUG  then PUT( tab50 & ";---------- GENERIC PACKAGE" ); end if;
      NEW_LINE;

      PUT_LINE( "PRMS" );

      declare
        GPRM_SEQ	: SEQ_TYPE	:= LIST( D( SM_GENERIC_PARAM_S, PACK_DEF ) );
        GPRM	: TREE;
      begin
        while  not IS_EMPTY( GPRM_SEQ )  loop
	POP( GPRM_SEQ, GPRM );
	if  GPRM.TY = DN_TYPE_DECL  then
	  declare
	    GTYPE_ID	: TREE		:= D( AS_SOURCE_NAME, GPRM );
	    GPRM_NAME	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, GTYPE_ID ) );
	    GTYPE_DEF	: TREE		:= D( AS_TYPE_DEF, GPRM );
	  begin
	    if  GTYPE_DEF.TY = DN_FORMAL_INTEGER_DEF  then
	      PUT_LINE( tab & "PRM " & GPRM_NAME & "_first_ofs" );
	      PUT_LINE( tab & "PRM " & GPRM_NAME & "_last_ofs" );
	    end if;
	  end;
	end if;
        end loop;
      end;

      PUT_LINE( "endPRMS" );

      DECLARATIONS.CODE_PACKAGE_SPEC( D( SM_SPEC, PACK_ID ) );						-- POUR LES EMPLACEMENTS DES VARS DE SPEC DE GENERIQUE
      ENCLOSING_BODY := PACKAGE_BODY;
      CODE_BODY( D( AS_BODY, PACKAGE_BODY ) );								-- POUR LES VARS ET LES SUBS DU CORPS DE GENERIQUE

      PUT( "end namespace " );
      if  CODI.DEBUG  then
        PUT( tab50 & ";---------- end generic package BDY " & PACK_NAME );
      end if;
      NEW_LINE;
      IN_GENERIC_BODY := FALSE;

    else

      if  CAS_NORMAL  then
        PUT_LINE( PACK_NAME & " = " & "'" & PACK_NAME & "'" );
        PUT( "namespace " & PACK_NAME );
        if  CODI.DEBUG  then PUT( tab50 & ";---------- PACKAGE" ); end if;
        NEW_LINE;
      end if;

      PUT( "elab_spec:" );
      if  CODI.DEBUG  then PUT_LINE( tab50 & ";    SPEC ELAB" ); end if;
      NEW_LINE;

      DECLARATIONS.CODE_PACKAGE_SPEC( D( SM_SPEC, PACK_ID ) );
      ENCLOSING_BODY := PACKAGE_BODY;
      CODE_BODY( D( AS_BODY, PACKAGE_BODY ) );

      if  CAS_NORMAL  then
        PUT( "end namespace " );
        if  CODI.DEBUG
        then  PUT_LINE( tab50 & ";---------- end package BDY " & PACK_NAME );
        end if;
      end if;
      NEW_LINE;

    end if;

  end	CODE_PACKAGE_BODY;
	-----------------



				---------
  procedure			CODE_BODY		( ADA_BODY :TREE )
  is
  begin

    if  ADA_BODY.TY = DN_BLOCK_BODY
    then  CODE_BLOCK_BODY( ADA_BODY );

    elsif  ADA_BODY.TY = DN_STUB
    then  CODE_STUB( ADA_BODY );
    end if;

  end	CODE_BODY;
	---------



				--===========--
  procedure			CODE_BLOCK_BODY	( BLOCK_BODY :TREE )
  is
  begin
    DI( CD_LEVEL, BLOCK_BODY, INTEGER( CODI.CUR_LEVEL ) );

    if  CODI.CUR_LEVEL /= 0
    then  PUT( "ELB" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );
    end if;

    if  CODI.DEBUG  then PUT( tab50 & ";    BODY ELAB" ); end if;
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
      CODE_ITEM_S( D( AS_ITEM_S, BLOCK_BODY ) );
      ENCLOSING_BODY := SAVE_ENCLOSING;
    end;

    if  ENCLOSING_BODY.TY = DN_SUBPROGRAM_BODY  then

      if  CODI.DEBUG  then PUT( tab50 & ";    end elab" ); end if;
      NEW_LINE;

    end if;

    PUT( "begin:" );
    if  CODI.DEBUG  then
      PUT( tab50 & ";---------- " );
      if  ENCLOSING_BODY.TY = DN_SUBPROGRAM_BODY  then PUT( "BDY INSTRUCTIONS" );
      elsif  ENCLOSING_BODY.TY = DN_PACKAGE_BODY  then PUT( "package BDY INSTRUCTIONS" );
      end if;
    end if;
    NEW_LINE;

    INSTRUCTIONS.CODE_STM_S( D( AS_STM_S, BLOCK_BODY ) );

    if  not IS_EMPTY( LIST( D( AS_ALTERNATIVE_S, BLOCK_BODY ) ) )
    then  CODE_ALTERNATIVE_S( D( AS_ALTERNATIVE_S, BLOCK_BODY ) );
    end if;

  end	CODE_BLOCK_BODY;
	--===========--



		------------
  procedure	CODE_SUBUNIT		( SUBUNIT :TREE )
  is
  begin
    CODE_SUBUNIT_BODY( D( AS_SUBUNIT_BODY, SUBUNIT ) );

  end	CODE_SUBUNIT;
	------------



			-----------------
  procedure		CODE_SUBUNIT_BODY		( SUBUNIT_BODY :TREE )
  is
  begin

    if  SUBUNIT_BODY.TY = DN_SUBPROGRAM_BODY
    then  CODE_SUBPROGRAM_BODY( SUBUNIT_BODY );

    elsif  SUBUNIT_BODY.TY = DN_PACKAGE_BODY
    then  CODE_PACKAGE_BODY( SUBUNIT_BODY );

    elsif  SUBUNIT_BODY.TY = DN_TASK_BODY
    then  CODE_TASK_BODY( SUBUNIT_BODY );

    end if;

  end	CODE_SUBUNIT_BODY;
	-----------------



				-----------
  procedure			CODE_ITEM_S		( ITEM_S :TREE )
  is
    ITEM_SEQ	: SEQ_TYPE	:= LIST ( ITEM_S );
    ITEM		: TREE;
  begin
    while  not IS_EMPTY( ITEM_SEQ )  loop
      POP( ITEM_SEQ, ITEM );

      if  ITEM.TY in CLASS_DECL
      then  DECLARATIONS.CODE_DECL( ITEM );

      elsif  ITEM.TY in CLASS_SUBUNIT_BODY
      then  CODE_SUBUNIT_BODY( ITEM );

      end if;

    end loop;

  end	CODE_ITEM_S;
	-----------



	----------
end	STRUCTURES;
	----------
