------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	EXPANDER.DECLARATIONS.ADB	VINCENT MORIN	6/5/2025	UNIVERSITE DE BRETAGNE OCCIDENTALE
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1


separate ( EXPANDER )
				------------
 	package body		DECLARATIONS
				------------
is


  package CODI	renames EXPANDER.UTILS;
  use CODI;

  -------			-----------
  package			TYPES_DECLS
  -------			-----------
  is

    procedure CODE_TYPE_DECL			( TYPE_DECL :TREE );
    procedure CODE_SUBTYPE_DECL		( SUBTYPE_DECL :TREE );
    procedure PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC	( TYPE_SPEC :TREE );

  ---	-----------
  end	TYPES_DECLS;
  ---	-----------
  package body TYPES_DECLS is separate;



			--=========--
  procedure		  CODE_DECL		( DECL :TREE )
  is			--=========--
  begin
    if	 DECL.TY = DN_NULL_COMP_DECL	then  CODE_NULL_COMP_DECL( DECL );
    elsif  DECL.TY in CLASS_ID_DECL	then  CODE_ID_DECL	     ( DECL );
    elsif  DECL.TY in CLASS_ID_S_DECL	then  CODE_ID_S_DECL     ( DECL );
    elsif  DECL.TY in CLASS_REP	then  CODE_REP	     ( DECL );
    elsif  DECL.TY in CLASS_USE_PRAGMA	then  CODE_USE_PRAGMA    ( DECL );
    end if;

  end	  CODE_DECL;
	--=========--



			--===========--
  procedure		  CODE_DECL_S		( DECL_S :TREE )
  is			--===========--

    DECL_SEQ	: SEQ_TYPE	:= LIST( DECL_S );
    DECL		: TREE;
  begin
    while  not IS_EMPTY( DECL_SEQ )  loop
      POP( DECL_SEQ, DECL );
      CODE_DECL( DECL );
    end loop;

  end	  CODE_DECL_S;
	--===========--



			-------------------
  procedure		CODE_NULL_COMP_DECL		( NULL_COMP_DECL :TREE )
  is
  begin
    null;
  end	CODE_NULL_COMP_DECL;
	-------------------



			------------
  procedure		CODE_ID_DECL		( ID_DECL :TREE )
  is
  begin
    if	 ID_DECL.TY = DN_TYPE_DECL		then  TYPES_DECLS.CODE_TYPE_DECL   ( ID_DECL );
    elsif  ID_DECL.TY = DN_SUBTYPE_DECL		then  TYPES_DECLS.CODE_SUBTYPE_DECL( ID_DECL );
    elsif  ID_DECL.TY = DN_TASK_DECL		then  CODE_TASK_DECL         ( ID_DECL );
    elsif  ID_DECL.TY in CLASS_UNIT_DECL	then  CODE_UNIT_DECL         ( ID_DECL );
    elsif  ID_DECL.TY in CLASS_SIMPLE_RENAME_DECL	then  CODE_SIMPLE_RENAME_DECL( ID_DECL );

    end if;

  end	CODE_ID_DECL;
	------------



			--------------
  procedure		CODE_ID_S_DECL		( ID_S_DECL :TREE )
  is
  begin
    if	 ID_S_DECL.TY in CLASS_EXP_DECL		then  CODE_EXP_DECL		   ( ID_S_DECL );
    elsif  ID_S_DECL.TY = DN_EXCEPTION_DECL		then  CODE_EXCEPTION_DECL	   ( ID_S_DECL );
    elsif  ID_S_DECL.TY = DN_DEFERRED_CONSTANT_DECL	then  CODE_DEFERRED_CONSTANT_DECL( ID_S_DECL );
    end if;

  end	CODE_ID_S_DECL;
	--------------



			--===================--
  procedure		CODE_SUBPROG_ENTRY_DECL	( SUBPROG_ENTRY_DECL :TREE )

  is
    SOURCE_NAME	: TREE        := D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
  begin
    if  not (SOURCE_NAME.TY in CLASS_SUBPROG_NAME)  then
      PUT_LINE( "ANOMALIE : CODE_GEN.DECLARATIONS.CODE_SUBPROG_ENTRY_DECL ; SOURCE_NAME.TY pas dans CLASS_SUBPROG_NAME" );
      raise PROGRAM_ERROR;
    else
      if  CODI.IN_SPEC_UNIT
      then DB( CD_COMPILED, SOURCE_NAME, TRUE );
      else
        if  not IN_GENERIC_INSTANTIATION  and then  DB( CD_COMPILED, SOURCE_NAME )  then
          return;
        end if;
      end if;
    end if;

    INC_LEVEL;
    declare
      HEADER	: TREE	        := D( AS_HEADER, SUBPROG_ENTRY_DECL );
      LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin

      if  CODI.IN_SPEC_UNIT  or else  not DB( CD_COMPILED, SOURCE_NAME )
      then  DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );
      end if;
 --     if  not DB( CD_COMPILED, SOURCE_NAME )  then DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) ); end if;

      DI( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
      DB( CD_COMPILED, SOURCE_NAME, TRUE );

      if  not IN_GENERIC_INSTANTIATION  then CODI.OUTPUT_CODE := FALSE; end if;					-- ne pas coder les parametres (le body fera ca)

      if  IN_GENERIC_INSTANTIATION  then
        declare
	SOURCE_NAME	: TREE		:= D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
	SUB_NAME		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, SOURCE_NAME ) );
	LBL		: LABEL_TYPE	:= LABEL_TYPE( DI( CD_LABEL, SOURCE_NAME ) );
        begin
	PUT_LINE( "if defined " & SUB_NAME & '_' & LABEL_STR( LBL ) & '_' );
	PUT( "PRO" & tab & SUB_NAME & '_' & LABEL_STR( LBL ) );
	if  CODI.DEBUG  then PUT( tab50 & ";---------- PRO " & SUB_NAME ); end if;
	NEW_LINE;
	CODE_HEADER( HEADER );

	PUT_LINE( "ELB" & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );
	PUT_LINE( "begin:" );

	PUT_LINE( tab & "LVA" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ", GFP_disp" );

	declare
	  PRM_SECTIONS_S	: SEQ_TYPE	:= LIST( D( AS_PARAM_S, D( SM_SPEC, SOURCE_NAME ) ) );

	  procedure INVERSE_RECURSE_PRM_SECTIONS ( REMAIN_SECTIONS :in out SEQ_TYPE )
	  is
	    PRM_SECTION		: TREE;
	  begin
	    if  IS_EMPTY( REMAIN_SECTIONS )  then return; end if;
	    POP( REMAIN_SECTIONS, PRM_SECTION );
	    INVERSE_RECURSE_PRM_SECTIONS( REMAIN_SECTIONS );

	    declare
	      NAME_S		: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, PRM_SECTION ) );

	      procedure INVERSE_RECURSE_NAMES ( NAMES :in out SEQ_TYPE )
	      is
	        NAME	: TREE;
	      begin
	        if  IS_EMPTY( NAMES )  then return; end if;
	        POP( NAMES, NAME );
	        INVERSE_RECURSE_NAMES( NAMES );
	        PUT_LINE( tab & "Lq" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL )
		        & ", -" & PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_ofs" );
	      end	INVERSE_RECURSE_NAMES;

	    begin
	      INVERSE_RECURSE_NAMES( NAME_S );
	    end;
	  end	INVERSE_RECURSE_PRM_SECTIONS;

	begin
	  INVERSE_RECURSE_PRM_SECTIONS( PRM_SECTIONS_S );
	end;

	PUT( tab & "CALL" & tab );
	REGIONS_PATH( D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME ) );

	PUT( PRINT_NAME( D( LX_SYMREP, CODI.INSTANTIATION_MODEL_NAME ) ) & ". ," );
	declare
	  MODEL_DECL	: TREE;
	begin
	  while  not( IS_EMPTY( CODI.GENERIC_MODEL_DECL_SEQ ) )  loop
	    POP( CODI.GENERIC_MODEL_DECL_SEQ, MODEL_DECL );
	    if  MODEL_DECL.TY = DN_SUBPROG_ENTRY_DECL  then
	      declare
	        NAME	: TREE	:= D( AS_SOURCE_NAME, MODEL_DECL );
	        LBL	: INTEGER	:= DI( CD_LABEL, NAME );
	      begin
	        PUT_LINE( PRINT_NAME( D( LX_SYMREP, NAME ) ) & "_L" & IMAGE( LBL ) );
	        exit;
	      end;
	    end if;
	  end loop;
 	end;

	PUT_LINE( tab & "UNLINK" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) );
	PUT_LINE( tab & "RTD" & tab & "prm_siz" );

	PUT( "endPRO" );
	if  CODI.DEBUG  then PUT( tab50 & ";---------- end PRO " & SUB_NAME); end if;
	NEW_LINE;
	PUT_LINE( "end if" );
        end;

      else
        CODI.OUTPUT_CODE := FALSE;						-- ne pas coder les parametres (le body fera ca)
        CODE_HEADER( HEADER );
        CODI.OUTPUT_CODE := TRUE;
      end if;

      if  SOURCE_NAME.TY = DN_FUNCTION_ID or SOURCE_NAME.TY = DN_OPERATOR_ID  then
        declare
          USED_OBJECT_ID	: TREE := D( AS_NAME, HEADER );
          RESULT_TYPE_ID	: TREE := D( SM_DEFN, USED_OBJECT_ID );
          RESULT_TYPE_SPEC	: TREE := D( SM_TYPE_SPEC, RESULT_TYPE_ID );
        begin
null;
--          DI( CD_RESULT_SIZE, SOURCE_NAME, DI( CD_IMPL_SIZE, RESULT_TYPE_SPEC ) );
        end;
      end if;
    end;
    DEC_LEVEL;

   end	CODE_SUBPROG_ENTRY_DECL;
	--===================--



			--=======--
  procedure		CODE_HEADER		( HEADER :TREE )
  is
  begin

    if  HEADER.TY in CLASS_SUBP_ENTRY_HEADER
    then
      CODE_PARAM_S( D( AS_PARAM_S, HEADER ), (HEADER.TY = DN_FUNCTION_SPEC) );
      CODE_SUBP_ENTRY_HEADER( HEADER );

    elsif  HEADER.TY = DN_PACKAGE_SPEC
    then  CODE_PACKAGE_SPEC( HEADER );

    end if;

  end	CODE_HEADER;
	--=======--


			------------
  procedure		CODE_PARAM_S	( PARAM_S :TREE; FOR_FUNCTION :BOOLEAN := FALSE )
  is
  begin
    declare
      PARAM_SEQ		: SEQ_TYPE	:= LIST( PARAM_S );
      PARAM		: TREE;
    begin
      CODI.NO_SUBP_PARAMS := IS_EMPTY( PARAM_SEQ );
      if  CODI.NO_SUBP_PARAMS  then return; end if;

      if  CODI.OUTPUT_CODE  then
        PUT( "PRMS" );
        if  CODI.DEBUG  then  PUT( tab50 & ";    debut parametrage" ); end if;
        NEW_LINE;
        if  FOR_FUNCTION  then
	PUT( tab & "PRM result__ofs" );
	if  CODI.DEBUG  then  PUT( tab50 & "; resutat de fonction" ); end if;
	NEW_LINE;
        end if;
      end if;

      while  not IS_EMPTY( PARAM_SEQ )  loop
        POP( PARAM_SEQ, PARAM );
        CODE_PARAM( PARAM );
      end loop;

      if  CODI.OUTPUT_CODE  then
        if  CODI.IN_GENERIC_BODY  then
	PUT_LINE( tab & "PRM GFP_ofs" );
        end if;
        PUT( "endPRMS" );
        if CODI.DEBUG then PUT( tab50 & ";    fin parametrage" ); end if;
        NEW_LINE;
      end if;
    end;

  end	CODE_PARAM_S;
	------------


			----------
  procedure		CODE_PARAM	( PARAM :TREE )
  is
    ID_LIST	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, PARAM ) );
    ID		: TREE;
  begin
    while  not IS_EMPTY( ID_LIST )  loop
      POP( ID_LIST, ID );

      DI( CD_LEVEL, ID, INTEGER( CODI.CUR_LEVEL ) );

      if  CODI.OUTPUT_CODE  then
        if  D( SM_OBJ_TYPE, ID ).TY in CLASS_SCALAR and PARAM.TY = DN_IN  then
	PUT( tab & "PRM " & PRINT_NAME( D( LX_SYMREP, ID ) ) & "_ofs" );
        else
	PUT( tab & "PRM " & PRINT_NAME( D( LX_SYMREP, ID ) ) & "_ofs" );
        end if;
      end if;

      if  PARAM.TY = DN_IN
      then  CODE_IN ( PARAM );

      elsif  PARAM.TY = DN_OUT
      then  CODE_OUT ( PARAM );

      elsif  PARAM.TY = DN_IN_OUT
      then  CODE_IN_OUT ( PARAM );

      end if;
      if  CODI.OUTPUT_CODE  then NEW_LINE; end if;
    end loop;

  end	CODE_PARAM;
	----------


  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN ( ADA_IN :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if  CODI.DEBUG  then PUT( tab50 & "; in" ); end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_OUT ( ADA_IN_OUT :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if  CODI.DEBUG  then PUT( tab50 & "; in out" ); end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OUT ( ADA_OUT :TREE ) is
  begin
    if  CODI.OUTPUT_CODE  then
      if  CODI.DEBUG  then PUT( tab50 & "; out" ); end if;
    end if;
  end;

			----------------------
  procedure		CODE_SUBP_ENTRY_HEADER	( SUBP_ENTRY_HEADER :TREE )
  is
  begin
    if SUBP_ENTRY_HEADER.TY = DN_PROCEDURE_SPEC
    then
null;
    elsif SUBP_ENTRY_HEADER.TY = DN_FUNCTION_SPEC
    then
null;
    end if;
  end	CODE_SUBP_ENTRY_HEADER;
	----------------------



			-----------------
  procedure		CODE_PACKAGE_SPEC		( PACKAGE_SPEC :TREE )
  is
  begin
    CODE_DECL_S( D( AS_DECL_S1, PACKAGE_SPEC ) );
    CODE_DECL_S( D( AS_DECL_S2, PACKAGE_SPEC ) );

  end	CODE_PACKAGE_SPEC;
	-----------------



			-------------
  procedure		CODE_EXP_DECL		( EXP_DECL :TREE )
  is

  begin
    if  EXP_DECL.TY in CLASS_OBJECT_DECL
    then  CODE_OBJECT_DECL ( EXP_DECL );

    elsif  EXP_DECL.TY = DN_NUMBER_DECL
    then  CODE_NUMBER_DECL ( EXP_DECL );

    end if;

  end	CODE_EXP_DECL;
	-------------


			----------------
  procedure		CODE_OBJECT_DECL		( OBJECT_DECL :TREE )
  is

    SRC_NAME_SEQ	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, OBJECT_DECL ) );
    SRC_NAME	: TREE;
    TYPE_DEF	: TREE		:= D( AS_TYPE_DEF, OBJECT_DECL );
    TYPE_NAME	: TREE		:= D( AS_NAME, TYPE_DEF );

  begin
    if  TYPE_NAME.TY = DN_SELECTED  then
      TYPE_NAME := D( AS_DESIGNATOR, TYPE_NAME );
    end if;

    CODI.TYPE_SYMREP := D( LX_SYMREP, TYPE_NAME );
    while  not IS_EMPTY( SRC_NAME_SEQ )  loop
      POP( SRC_NAME_SEQ, SRC_NAME );
      CODE_VC_NAME( SRC_NAME );
    end loop;

  end	CODE_OBJECT_DECL;
	----------------


			----------------
  procedure		CODE_NUMBER_DECL		( NUMBER_DECL :TREE ) is
  begin
    null;
  end	CODE_NUMBER_DECL;
	----------------


			-------------------
  procedure		CODE_EXCEPTION_DECL		( EXCEPTION_DECL :TREE )
  is			-------------------

			------------------
    procedure		CODE_SOURCE_NAME_S		( SOURCE_NAME_S :TREE )
    is

      SOURCE_NAME_SEQ	: SEQ_TYPE	:= LIST( SOURCE_NAME_S );
      SOURCE_NAME		: TREE;

    begin
      while  not IS_EMPTY( SOURCE_NAME_SEQ )  loop
        POP( SOURCE_NAME_SEQ, SOURCE_NAME );

        if  SOURCE_NAME.TY		in CLASS_OBJECT_NAME	then CODE_OBJECT_NAME  ( SOURCE_NAME );
        elsif  SOURCE_NAME.TY 	in CLASS_TYPE_NAME		then CODE_TYPE_NAME    ( SOURCE_NAME );
        elsif  SOURCE_NAME.TY	in CLASS_UNIT_NAME		then CODE_UNIT_NAME    ( SOURCE_NAME );
        elsif  SOURCE_NAME.TY	in CLASS_LABEL_NAME		then CODE_LABEL_NAME   ( SOURCE_NAME );
        elsif  SOURCE_NAME.TY	=  DN_ENTRY_ID		then CODE_ENTRY_ID     ( SOURCE_NAME );
        elsif  SOURCE_NAME.TY	=  DN_EXCEPTION_ID		then CODE_EXCEPTION_ID ( SOURCE_NAME );
        end if;

      end loop;

    end	CODE_SOURCE_NAME_S;
	------------------

  begin
    CODE_SOURCE_NAME_S( D( AS_SOURCE_NAME_S, EXCEPTION_DECL ) );

  end	CODE_EXCEPTION_DECL;
	-------------------



			---------------------------
  procedure		CODE_DEFERRED_CONSTANT_DECL	( DEFERRED_CONSTANT_DECL :TREE )
  is			---------------------------
  begin
    null;
  end	CODE_DEFERRED_CONSTANT_DECL;
	---------------------------



			------------
  procedure		CODE_VC_NAME		( VC_NAME :TREE )
  is
  begin
    declare
      TYPE_SPEC	: TREE	:= D( SM_OBJ_TYPE, VC_NAME );


		-----------------------
      procedure	COMPILE_VC_NAME_INTEGER	( VC_NAME :TREE )
      is

        OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, VC_NAME ) );
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

      begin
        PUT( "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, " & OPER_TYPE );
        if  CODI.DEBUG  then PUT( tab50 & "; variable entiere" ); end if;
        NEW_LINE;
        DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

--        if  not IN_GENERIC_BODY  then
	if  INIT_EXP /= TREE_VOID  then
	  EXPRESSIONS.CODE_EXP( INIT_EXP );
	  CODI.STORE( VC_NAME );
	end if;
--        end if;

      end	COMPILE_VC_NAME_INTEGER;
	-----------------------


		---------------------
      procedure	COMPILE_VC_NAME_FLOAT	( VC_NAME :TREE )
      is

        OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, VC_NAME ) );
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

      begin
        PUT( "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, " & OPER_TYPE );
        if  CODI.DEBUG  then PUT( tab50 & "; variable flottante" ); end if;
        NEW_LINE;
        DI( CD_LEVEL, VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

        if  INIT_EXP /= TREE_VOID  then
	EXPRESSIONS.CODE_EXP( INIT_EXP );
	CODI.STORE( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_FLOAT;
	---------------------


			---------------------------
      procedure		COMPILE_VC_NAME_ENUMERATION	( VC_NAME, TYPE_SPEC :TREE )
      is

        NAME	:constant STRING	:= PRINT_NAME( CODI.TYPE_SYMREP );

		-------------------------
        procedure	COMPILE_VC_NAME_BOOL_CHAR	( VC_NAME :TREE )
        is	-------------------------

          OPER_TYPE		: CHARACTER	:= OPER_SIZ_CHAR( D( SM_OBJ_TYPE, VC_NAME ) );
	INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );

        begin
	PUT( "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, b" );
          if  CODI.DEBUG  then PUT( tab50 & "; variable bool char" ); end if;
	NEW_LINE;

	DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );
	DB( CD_COMPILED,  VC_NAME, TRUE );

          if  INIT_EXP /= TREE_VOID  then
	  EXPRESSIONS.CODE_EXP( INIT_EXP );
	  CODI.STORE( VC_NAME );
          end if;

        end	COMPILE_VC_NAME_BOOL_CHAR;
		-------------------------

      begin
        if  NAME = "BOOLEAN"
        then  COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        elsif  NAME = "CHARACTER"
        then  COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        else  COMPILE_VC_NAME_INTEGER( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_ENUMERATION;
	---------------------------


		------------------
      procedure	COMPILE_ACCESS_VAR	( VAR_ID, TYPE_SPEC :TREE )
      is

        LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;

      begin
        DI( CD_LEVEL,     VAR_ID, INTEGER( LVL ) );
        DB( CD_COMPILED,  VAR_ID, TRUE );
        declare
          INIT_EXP		: TREE	:= D( SM_INIT_EXP, VAR_ID );
        begin
	if  INIT_EXP = TREE_VOID  then
	  PUT_LINE( tab & "LI -1" );

	else
null;--     LOAD_TYPE_SIZE( TYPE_SPEC  );
	end if;
--	  PUT_LINE( tab & "Sa" & LEVEL_NUM'IMAGE( LVL ) & ',' & INTEGER'IMAGE( -1 ) );
        end;

      end	COMPILE_ACCESS_VAR;
	------------------


		-----------------
      procedure	COMPILE_ARRAY_VAR	( VC_NAME, TYPE_SPEC :TREE )
      is
        VC_STR		:constant STRING		:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
        TYPE_NAME		: TREE			:= D( XD_SOURCE_NAME, TYPE_SPEC );
        TYPE_LEVEL		: INTEGER;
        TYPE_NAME_STR	:constant STRING		:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );
        DIM_NBR		: NATURAL			:= 1;
        LVL		: LEVEL_NUM		renames CODI.CUR_LEVEL;
        LVL_STR		:constant STRING		:= IMAGE( CODI.CUR_LEVEL );
        ANONYMOUS_SUBTYPE	: BOOLEAN			:= FALSE;
      begin

        if  DB( CD_COMPILED, TYPE_SPEC ) = FALSE  then
	ANONYMOUS_SUBTYPE := TRUE;
	PUT_LINE( TYPE_NAME_STR & " = '" & TYPE_NAME_STR & "'" );
	PUT( "namespace " & TYPE_NAME_STR );
	if  CODI.DEBUG  then PUT( tab50 & "; array var constrained array type info" ); end if;
	NEW_LINE;
	TYPES_DECLS.PROCESS_CONSTRAINED_ARRAY_TYPE_SPEC( TYPE_SPEC );
        end if;

        TYPE_LEVEL := DI( CD_LEVEL, TYPE_SPEC );

        PUT( "VAR " & VC_STR & "_disp, q" );
        if  CODI.DEBUG  then PUT( tab50 & "; variable array : pointeur aux data" ); end if;
        NEW_LINE;
        PUT( "VAR " & VC_STR & "__u, q" );
        if  CODI.DEBUG  then PUT( tab50 & "; variable array : useinfo pointeur au rec info" ); end if;
        NEW_LINE;

        DI( CD_LEVEL, VC_NAME, INTEGER( LVL ) );

        declare
	INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );
        begin
          if  INIT_EXP /= TREE_VOID and then INIT_EXP.TY = DN_STRING_LITERAL					-- vraie constante chaine
	then
	  EXPRESSIONS.CODE_STRING_LITERAL( INIT_EXP, VC_STR );

	  PUT_LINE( tab & "LCA" & tab & VC_STR & ".data_ptr" );
	  PUT_LINE( tab & "La" );
	  PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );
	  if  CODI.DEBUG  then PUT( tab50 & "; array data ptr at _disp" ); end if;
	  NEW_LINE;

	  PUT_LINE( tab & "LCA" & tab & VC_STR & ".info_ptr" );						-- LOAD CONSTANT ADDRESS FOR INFO
	  PUT_LINE( tab & "La" );
	  PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "__u" );
	  if  CODI.DEBUG  then PUT( tab50 & "; array info ptr at __u" ); end if;
	  NEW_LINE;

	else
	  PUT( tab & "Ld" & tab & IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD SIZ FOR ALLOCATION
--	  if  ANONYMOUS_SUBTYPE  then
--	    PUT_LINE( VC_STR & ".SIZ" );
--	  else
	    PUT_LINE( TYPE_NAME_STR & ".SIZ" );
--	  end if;

	  PUT_LINE( tab & "CO_VAR" );
	  PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );
	  if  CODI.DEBUG  then PUT( tab50 & "; array data ptr at _disp" ); end if;
	  NEW_LINE;

	  PUT( tab & "LVA" & INTEGER'IMAGE( TYPE_LEVEL ) & ", " );						-- LOAD ADDRESS FOR INFO
--	  if  ANONYMOUS_SUBTYPE  then
--	    PUT_LINE( VC_STR & ".SIZ" );
--	  else
	    PUT_LINE( TYPE_NAME_STR & ".SIZ" );
--	  end if;

	  PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "__u" );
	  if  CODI.DEBUG  then PUT( tab50 & "; array info ptr at __u" ); end if;
	  NEW_LINE;

	end if;
        end;

        DI( CD_LEVEL,	VC_NAME, INTEGER( LVL ) );
        DB( CD_COMPILED,	VC_NAME, TRUE );

      end	COMPILE_ARRAY_VAR;
	-----------------


		------------------
      procedure	COMPILE_RECORD_VAR		( VC_NAME, TYPE_SPEC :TREE )
      is

        VC_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
        VC_ADDRESS		: TREE		:= D( SM_ADDRESS, VC_NAME );					-- adresse éventuelle
        INIT_EXP		: TREE		:= D( SM_INIT_EXP, VC_NAME );
        LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR		:constant STRING	:= IMAGE( LVL );
        TYPE_NAME		: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
        TYPE_NAME_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, TYPE_NAME ) );

      begin
        PUT( "VAR " & VC_STR & "_disp, q" );								-- Ptr to rec
        if  CODI.DEBUG  then  PUT( tab50 & "; variable record : pointeur aux data record" ); end if;
        NEW_LINE;
        PUT( "VAR " & VC_STR & "__u, q" );								-- Ptr to rec
        if  CODI.DEBUG  then  PUT( tab50 & "; variable record : pointeur aux useinfo" ); end if;
        NEW_LINE;

        if  VC_ADDRESS /= TREE_VOID  then								-- Clause adressage présente
	PUT_LINE( tab & "LI" & tab & PRINT_NUM( D( SM_VALUE, VC_ADDRESS ) ) );
	PUT_LINE( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );					-- Stocker l'adresse du rec dans le ptr

        else
	PUT( "VAR " & VC_STR & "__dat, " );								-- Espace data
	REGIONS_PATH( TYPE_NAME );
	PUT_LINE( TYPE_NAME_STR & ".size" );

	PUT_LINE( tab & "LVA" & tab & LVL_STR & ", " & VC_STR & "__dat" );
	PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "_disp" );					-- Stocker l'adresse du rec dans le ptr
	if  CODI.DEBUG   then  PUT( tab50 & "; record fin" ); end if;
	NEW_LINE;
        end if;

        PUT( tab & "LVA" & tab & LVL_STR & ", " );
        REGIONS_PATH( TYPE_NAME );
        PUT_LINE( TYPE_NAME_STR & ".SIZ" );
        PUT( tab & "Sa" & tab & LVL_STR & ", " & VC_STR & "__u" );

        DI( CD_LEVEL,     VC_NAME, INTEGER( LVL ) );
        DB( CD_COMPILED,  VC_NAME, TRUE );

        if  INIT_EXP.TY = DN_AGGREGATE  then
	declare
	  GENERAL_ASSOC_SEQ		: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, INIT_EXP ) );
	  COMP_EXP		: TREE;
	begin
	  while not IS_EMPTY( GENERAL_ASSOC_SEQ ) loop
	    POP( GENERAL_ASSOC_SEQ, COMP_EXP );
	    EXPRESSIONS.CODE_EXP( COMP_EXP );
	  end loop;
	end;
        end if;

      end	COMPILE_RECORD_VAR;
	------------------


    begin

      if  TYPE_SPEC.TY = DN_L_PRIVATE  then
	TYPE_SPEC := D( SM_TYPE_SPEC, TYPE_SPEC );
      end if;

      case TYPE_SPEC.TY is
      when DN_ENUMERATION		=> COMPILE_VC_NAME_ENUMERATION( VC_NAME, TYPE_SPEC );
      when DN_INTEGER		=> COMPILE_VC_NAME_INTEGER(	    VC_NAME );
      when DN_FLOAT			=> COMPILE_VC_NAME_FLOAT(	    VC_NAME );
      when DN_ACCESS		=> COMPILE_ACCESS_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_RECORD		=> COMPILE_RECORD_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_CONSTRAINED_ARRAY
        | DN_ARRAY			=> COMPILE_ARRAY_VAR(	    VC_NAME, TYPE_SPEC );
      when others =>
        PUT_LINE( "; ERREUR CODE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end case;
    end;
    NEW_LINE;
  end	CODE_VC_NAME;
	------------



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
  procedure CODE_TASK_DECL ( TASK_DECL :TREE ) is
  begin
    null;
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
  procedure CODE_SIMPLE_RENAME_DECL ( SIMPLE_RENAME_DECL :TREE ) is
  begin

    if SIMPLE_RENAME_DECL.TY = DN_RENAMES_OBJ_DECL then
      CODE_RENAMES_OBJ_DECL ( SIMPLE_RENAME_DECL );

    elsif SIMPLE_RENAME_DECL.TY = DN_RENAMES_EXC_DECL then
      CODE_RENAMES_EXC_DECL ( SIMPLE_RENAME_DECL );

    end if;
  end	CODE_SIMPLE_RENAME_DECL;


  			--=============--
  procedure		CODE_GENERIC_DECL		( GENERIC_DECL :TREE )
  is

    GENERIC_ID	: TREE		:= D( AS_SOURCE_NAME, GENERIC_DECL );
    G_PARAMS	: SEQ_TYPE	:= LIST( D( SM_GENERIC_PARAM_S, GENERIC_ID ) );
    G_PARAM	: TREE;
    DECL_S	: SEQ_TYPE	:= LIST( D( AS_DECL_S1, D( AS_HEADER, GENERIC_DECL ) ) );
    DECL		: TREE;
  begin

    while  not IS_EMPTY( G_PARAMS )  loop
      POP( G_PARAMS, G_PARAM );
      if  G_PARAM.TY = DN_TYPE_DECL  then
        if  D( AS_TYPE_DEF, G_PARAM ).TY = DN_FORMAL_INTEGER_DEF  then
	DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC, D( AS_SOURCE_NAME, G_PARAM ) ), INTG_SIZE * 8 );
        end if;
      end if;
    end loop;

    while  not IS_EMPTY( DECL_S )  loop
      POP( DECL_S, DECL );
      if  DECL.TY = DN_SUBPROG_ENTRY_DECL and then IN_SPEC_UNIT  then
        declare
	LBL	: LABEL_TYPE	:= NEW_LABEL;
	NAME	: TREE		:= D( AS_SOURCE_NAME, DECL );
        begin
	DI( CD_LABEL, NAME, INTEGER( LBL ) );
	DI( CD_LEVEL, NAME, INTEGER( CODI.CUR_LEVEL ) + 1 );
	DB( CD_COMPILED, D( AS_SOURCE_NAME, DECL ), TRUE );
        end;
      end if;
    end loop;

  end	CODE_GENERIC_DECL;
	--=============--


  procedure CODE_NON_GENERIC_DECL	( NON_GENERIC_DECL :TREE );

  --|-------------------------------------------------------------------------------------------
  procedure CODE_UNIT_DECL ( UNIT_DECL :TREE ) is
  begin

    if UNIT_DECL.TY = DN_GENERIC_DECL then
      CODE_GENERIC_DECL ( UNIT_DECL );

    elsif UNIT_DECL.TY in CLASS_NON_GENERIC_DECL then
      CODE_NON_GENERIC_DECL ( UNIT_DECL );

    end if;
  end;


  procedure		CODE_NON_GENERIC_DECL	( NON_GENERIC_DECL :TREE )
  is
  begin
    if NON_GENERIC_DECL.TY = DN_SUBPROG_ENTRY_DECL
    then
      CODE_SUBPROG_ENTRY_DECL( NON_GENERIC_DECL );

    elsif NON_GENERIC_DECL.TY = DN_PACKAGE_DECL
    then
      CODE_PACKAGE_DECL( NON_GENERIC_DECL );
    end if;
  end;



				--=============--
  procedure			CODE_PACKAGE_DECL		( PACKAGE_DECL :TREE )
  is

    PACK_ID		: TREE			:= D( AS_SOURCE_NAME, PACKAGE_DECL );
    PACK_NAME		:constant STRING		:= PRINT_NAME( D( LX_SYMREP, PACK_ID ) );
    UNIT_KIND		: TREE			:= D( AS_UNIT_KIND, PACKAGE_DECL );
    SAVE_NO_SUB_PARAM	: BOOLEAN			:= CODI.NO_SUBP_PARAMS;
    SAVE_MODEL_SEQ		: SEQ_TYPE		:= CODI.GENERIC_MODEL_DECL_SEQ;
    CAS_NORMAL		: BOOLEAN			:= PACK_NAME /= "STANDARD" and PACK_NAME /= "_STANDRD";

  begin
    if  CAS_NORMAL  then
      PUT_LINE( PACK_NAME & " = '" & PACK_NAME & "'" );
      PUT( "namespace " & PACK_NAME );
    end if;
    if  UNIT_KIND.TY = DN_INSTANTIATION
    then
      if  CODI.DEBUG  then PUT( tab50 & ";---------- GENERIC PACKAGE INSTANTIATION" ); end if;
      NEW_LINE;

      CODI.IN_GENERIC_INSTANTIATION := TRUE;
      CODI.INSTANTIATION_MODEL_NAME := D( AS_NAME, UNIT_KIND );
      CODI.GENERIC_MODEL_DECL_SEQ := LIST( D( AS_DECL_S1, D( SM_SPEC, D( SM_DEFN, CODI.INSTANTIATION_MODEL_NAME ) ) ) );

      PUT( "elab_spec:" );
      if  CODI.DEBUG  then PUT_LINE( tab50 & ";    SPEC ELAB" ); end if;
      NEW_LINE;

      declare
        GNAME_SEQ		: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, UNIT_KIND ) );
        GNAME		: TREE;
      begin
        while  not IS_EMPTY( GNAME_SEQ )  loop
	POP( GNAME_SEQ, GNAME );
	declare
	  DEFN		: TREE		:= D( SM_DEFN, GNAME );
	  DEFN_TYPE_RANGE	: TREE		:= D( SM_RANGE, D( SM_TYPE_SPEC, DEFN ) );
	  GNAME_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, GNAME ) );
	begin
	  if  DEFN.TY = DN_SUBTYPE_ID  then
	    if  D( SM_TYPE_SPEC, DEFN ).TY = DN_INTEGER  then
	      PUT_LINE( "VAR " & GNAME_STR & "_last_ofs, q" );
	      PUT_LINE( "LI" & tab & PRINT_NAME( D( LX_NUMREP, D( AS_EXP2, DEFN_TYPE_RANGE ) ) ) );
	      PUT_LINE( "Sd" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ", " & GNAME_STR & "_last_ofs" );

	      PUT_LINE( "VAR " & GNAME_STR & "_first_ofs, q" );
	      PUT_LINE( "LI" & tab & PRINT_NAME( D( LX_NUMREP, D( AS_EXP1, DEFN_TYPE_RANGE ) ) ) );
	      PUT_LINE( "Sd" & tab & LEVEL_NUM'IMAGE( CODI.CUR_LEVEL ) & ", " & GNAME_STR & "_first_ofs" );
	    end if;
	  end if;
	end;
        end loop;

        PUT_LINE( "VAR GFP_disp, q" );
        CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) );

        if  CODI.DEBUG  then
          PUT( tab50 & ";---------- end generic package instantiation " & PACK_NAME );
        end if;

        NEW_LINE;
      end;
      CODI.GENERIC_MODEL_DECL_SEQ := SAVE_MODEL_SEQ;
      CODI.IN_GENERIC_INSTANTIATION := FALSE;

    else
      if  CAS_NORMAL and CODI.DEBUG  then PUT( tab50 & ";---------- PACKAGE DECLARATION" ); end if;
      NEW_LINE;

      CODE_HEADER( D( AS_HEADER, PACKAGE_DECL ) );

      declare
        EXC_LBL		:constant STRING	:= NEW_LABEL;
      begin
        PUT_LINE( "; EXC_LBL" & tab & EXC_LBL );
      end;
    end if;

    if  CAS_NORMAL  then
      PUT_LINE( "end namespace" );
    end if;
    if  CODI.DEBUG  then  NEW_LINE; end if;

    CODI.NO_SUBP_PARAMS := SAVE_NO_SUB_PARAM;

  end	CODE_PACKAGE_DECL;
	--=============--


	------------
end	DECLARATIONS;
	------------

-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
