separate ( CODE_GEN )
				------------
 	package body		DECLARATIONS
				------------
is


  package CODI	renames CODAGE_INTERMEDIAIRE;


			--===================--
  procedure		CODE_SUBPROG_ENTRY_DECL	( SUBPROG_ENTRY_DECL :TREE )
			--===================--

  is
    SOURCE_NAME	: TREE        := D( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
  begin
    if not (SOURCE_NAME.TY in CLASS_SUBPROG_NAME) then
      PUT_LINE( "ANOMALIE : CODE_GEN.DECLARATIONS.CODE_SUBPROG_ENTRY_DECL ; SOURCE_NAME.TY pas dans CLASS_SUBPROG_NAME" );
      raise PROGRAM_ERROR;
--    else
--      if DB( CD_COMPILED, SOURCE_NAME ) then return; end if;
    end if;

    INC_LEVEL;
    declare
      HEADER	: TREE	        := D( AS_HEADER, SUBPROG_ENTRY_DECL );
      LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin
      DI( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );
      DI( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
      DB( CD_COMPILED, SOURCE_NAME, TRUE );
				---------------------						-- HEADER de la specif (reference level pour le corps)
      CODI.OUTPUT_CODE := FALSE;	CODE_HEADER( HEADER );	CODI.OUTPUT_CODE := TRUE;			-- ne pas coder les parametres (le body fera ca)
				---------------------
      if SOURCE_NAME.TY = DN_FUNCTION_ID or SOURCE_NAME.TY = DN_OPERATOR_ID then
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
  is			--=======--
  begin

    if HEADER.TY in CLASS_SUBP_ENTRY_HEADER
    then
	CODE_PARAM_S( D( AS_PARAM_S, HEADER ) );
	CODE_SUBP_ENTRY_HEADER( HEADER );

    elsif HEADER.TY = DN_PACKAGE_SPEC
    then
	CODE_PACKAGE_SPEC( HEADER );

    end if;

  end	CODE_HEADER;
	--=======--


			------------
  procedure		CODE_PARAM_S	( PARAM_S :TREE )
  is
  begin
    declare
      PARAM_SEQ	: SEQ_TYPE	:= LIST( PARAM_S );
      PARAM	: TREE;
    begin
      CODI.NO_SUBP_PARAMS := IS_EMPTY( PARAM_SEQ );
      if CODI.NO_SUBP_PARAMS then return; end if;

      if CODI.OUTPUT_CODE then
        PUT( "PRMS" );
        if CODI.DEBUG then PUT( tab50 & ";    debut parametrage" ); end if;
        NEW_LINE;
      end if;

      while not IS_EMPTY( PARAM_SEQ ) loop
        POP( PARAM_SEQ, PARAM );
        CODE_PARAM( PARAM );
      end loop;

      if CODI.OUTPUT_CODE then
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
  begin


    declare
      ID_LIST	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, PARAM ) );
      ID		: TREE;
    begin
      while not IS_EMPTY( ID_LIST ) loop
        POP( ID_LIST, ID );

        DI( CD_LEVEL, ID, INTEGER( CODI.CUR_LEVEL ) );

        if CODI.OUTPUT_CODE then
	if D( SM_OBJ_TYPE, ID ).TY in CLASS_SCALAR and PARAM.TY = DN_IN then
	  PUT( tab & "PRM " & PRINT_NAME( D( LX_SYMREP, ID ) ) & "_ofs" );
	else
	  PUT( tab & "PRM " & PRINT_NAME( D( LX_SYMREP, ID ) ) & "_adrofs" );
	end if;
        end if;

        if PARAM.TY = DN_IN then
	CODE_IN ( PARAM );

        elsif PARAM.TY = DN_OUT then
	CODE_OUT ( PARAM );

        elsif PARAM.TY = DN_IN_OUT then
	CODE_IN_OUT ( PARAM );

        end if;
        if CODI.OUTPUT_CODE then NEW_LINE; end if;
      end loop;
    end;

  end	CODE_PARAM;
	----------


  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN ( ADA_IN :TREE ) is
  begin
    if CODI.OUTPUT_CODE then
      if CODI.DEBUG then PUT( tab50 & "; in" ); end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_IN_OUT ( ADA_IN_OUT :TREE ) is
  begin
    if CODI.OUTPUT_CODE then
      if CODI.DEBUG then PUT( tab50 & "; in out" ); end if;
    end if;
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_OUT ( ADA_OUT :TREE ) is
  begin
    if CODI.OUTPUT_CODE then
      if CODI.DEBUG then PUT( tab50 & "; out" ); end if;
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

  end	CODE_PACKAGE_SPEC;
	-----------------



			-----------
  procedure		CODE_DECL_S		( DECL_S :TREE )
  is
  begin
    declare
      DECL_SEQ	: SEQ_TYPE	:= LIST( DECL_S );
      DECL	: TREE;
    begin
      while not IS_EMPTY( DECL_SEQ ) loop
        POP( DECL_SEQ, DECL );
        CODE_DECL( DECL );
      end loop;
    end;

  end	CODE_DECL_S;
	-----------



  procedure CODE_NULL_COMP_DECL	( NULL_COMP_DECL :TREE );
  procedure CODE_ID_DECL		( ID_DECL :TREE );


			---------
  procedure		CODE_DECL			( DECL :TREE )
  is
  begin

    if DECL.TY = DN_NULL_COMP_DECL then
      CODE_NULL_COMP_DECL( DECL );

    elsif DECL.TY in CLASS_ID_DECL then
      CODE_ID_DECL( DECL );

    elsif DECL.TY in CLASS_ID_S_DECL then
      CODE_ID_S_DECL( DECL );

    elsif DECL.TY in CLASS_REP then
      CODE_REP( DECL );

    elsif DECL.TY in CLASS_USE_PRAGMA then
      CODE_USE_PRAGMA( DECL );

    end if;

  end	CODE_DECL;
	---------



  procedure CODE_NULL_COMP_DECL ( NULL_COMP_DECL :TREE ) is
  begin
    null;
  end;


  procedure CODE_TYPE_DECL		( TYPE_DECL :TREE );
  procedure CODE_SUBTYPE_DECL		( SUBTYPE_DECL :TREE );
  procedure CODE_TASK_DECL		( TASK_DECL :TREE );
  procedure CODE_UNIT_DECL		( UNIT_DECL :TREE );
  procedure CODE_SIMPLE_RENAME_DECL	( SIMPLE_RENAME_DECL :TREE );


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


				--------------
  procedure			CODE_ID_S_DECL		( ID_S_DECL :TREE )
  is
  begin

    if ID_S_DECL.TY in CLASS_EXP_DECL then
      CODE_EXP_DECL( ID_S_DECL );

    elsif ID_S_DECL.TY = DN_EXCEPTION_DECL then
      CODE_EXCEPTION_DECL( ID_S_DECL );

    elsif ID_S_DECL.TY = DN_DEFERRED_CONSTANT_DECL then
      CODE_DEFERRED_CONSTANT_DECL( ID_S_DECL );

    end if;
  end	CODE_ID_S_DECL;
	--------------


				-------------
  procedure			CODE_EXP_DECL		( EXP_DECL :TREE )
  is
  begin

    if EXP_DECL.TY in CLASS_OBJECT_DECL then
      CODE_OBJECT_DECL ( EXP_DECL );

    elsif EXP_DECL.TY = DN_NUMBER_DECL then
      CODE_NUMBER_DECL ( EXP_DECL );

    end if;
  end	CODE_EXP_DECL;
	-------------


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
      CODI.TYPE_SYMREP := D( LX_SYMREP, TYPE_NAME );
      while not IS_EMPTY( SRC_NAME_SEQ ) loop
        POP( SRC_NAME_SEQ, SRC_NAME );
        CODE_VC_NAME( SRC_NAME );
      end loop;
    end;
  end	CODE_OBJECT_DECL;
	----------------


				----------------
  procedure			CODE_NUMBER_DECL		( NUMBER_DECL :TREE ) is
  begin
    null;
  end	CODE_NUMBER_DECL;
	----------------



				-------------------
  procedure			CODE_EXCEPTION_DECL		( EXCEPTION_DECL :TREE )
  is

			------------------
    procedure		CODE_SOURCE_NAME_S		( SOURCE_NAME_S :TREE )
    is
    begin
      declare
        SOURCE_NAME_SEQ	: SEQ_TYPE	:= LIST( SOURCE_NAME_S );
        SOURCE_NAME		: TREE;
      begin
        while not IS_EMPTY( SOURCE_NAME_SEQ ) loop
	POP( SOURCE_NAME_SEQ, SOURCE_NAME );

	if SOURCE_NAME.TY		in CLASS_OBJECT_NAME	then CODE_OBJECT_NAME  ( SOURCE_NAME );
	elsif SOURCE_NAME.TY 	in CLASS_TYPE_NAME		then CODE_TYPE_NAME    ( SOURCE_NAME );
	elsif SOURCE_NAME.TY	in CLASS_UNIT_NAME		then CODE_UNIT_NAME    ( SOURCE_NAME );
	elsif SOURCE_NAME.TY	in CLASS_LABEL_NAME		then CODE_LABEL_NAME   ( SOURCE_NAME );
	elsif SOURCE_NAME.TY	=  DN_ENTRY_ID		then CODE_ENTRY_ID     ( SOURCE_NAME );
	elsif SOURCE_NAME.TY	=  DN_EXCEPTION_ID		then CODE_EXCEPTION_ID ( SOURCE_NAME );
	end if;

        end loop;
      end;

    end	CODE_SOURCE_NAME_S;
	------------------

  begin
      CODE_SOURCE_NAME_S( D( AS_SOURCE_NAME_S, EXCEPTION_DECL ) );

  end	CODE_EXCEPTION_DECL;
	-------------------



				---------------------------
  procedure			CODE_DEFERRED_CONSTANT_DECL	( DEFERRED_CONSTANT_DECL :TREE )
  is
  begin
    null;
  end	CODE_DEFERRED_CONSTANT_DECL;
	---------------------------





				------------
  procedure			CODE_VC_NAME		( VC_NAME :TREE )
  is
  begin
    declare
      TYPE_SPEC	: TREE	:= D( SM_OBJ_TYPE, VC_NAME );

		-----------------------
      procedure	COMPILE_VC_NAME_INTEGER	( VC_NAME :TREE )
      is
        OPER_TYPE	: CHARACTER	:= OPER_TYPE_FROM( VC_NAME );
        INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
      begin

        PUT( tab & "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, " & OPER_TYPE );
        if CODI.DEBUG then PUT( tab50 & "; variable entiere" ); end if;
        NEW_LINE;
        DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

        if INIT_EXP /= TREE_VOID then
	EXPRESSIONS.CODE_EXP( INIT_EXP );
	CODI.STORE( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_INTEGER;
	-----------------------

		-----------------------
      procedure	COMPILE_VC_NAME_FLOAT	( VC_NAME :TREE )
      is
        OPER_TYPE	: CHARACTER	:= OPER_TYPE_FROM( VC_NAME );
        INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
      begin

        PUT( tab & "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, " & OPER_TYPE );
        if CODI.DEBUG then PUT( tab50 & "; variable flottante" ); end if;
        NEW_LINE;
        DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );

        if INIT_EXP /= TREE_VOID then
	EXPRESSIONS.CODE_EXP( INIT_EXP );
	CODI.STORE( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_FLOAT;
	-----------------------

		---------------------------
      procedure	COMPILE_VC_NAME_ENUMERATION	( VC_NAME, TYPE_SPEC :TREE )
      is
        NAME	:constant STRING	:= PRINT_NAME( CODI.TYPE_SYMREP );

		-------------------------
        procedure	COMPILE_VC_NAME_BOOL_CHAR	( VC_NAME :TREE ) is
          OPER_TYPE	: CHARACTER	:= OPER_TYPE_FROM( VC_NAME );
	INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
        begin

	PUT( tab & "VAR " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp, b" );
          if CODI.DEBUG then PUT( tab50 & "; variable bool char" ); end if;
	NEW_LINE;

	DI( CD_LEVEL,     VC_NAME, INTEGER( CODI.CUR_LEVEL ) );
	DB( CD_COMPILED,  VC_NAME, TRUE );

          if INIT_EXP /= TREE_VOID then
	  EXPRESSIONS.CODE_EXP( INIT_EXP );
	  CODI.STORE( VC_NAME );
          end if;

        end	COMPILE_VC_NAME_BOOL_CHAR;
		-------------------------

      begin
        if NAME = "BOOLEAN"
        then COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        elsif NAME = "CHARACTER"
        then COMPILE_VC_NAME_BOOL_CHAR( VC_NAME );

        else COMPILE_VC_NAME_INTEGER( VC_NAME );
        end if;

      end	COMPILE_VC_NAME_ENUMERATION;
	---------------------------

		------------------
      procedure	COMPILE_ACCESS_VAR	( VAR_ID, TYPE_SPEC :TREE )
      is
      begin
        declare
	LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
        begin
	DI( CD_LEVEL,     VAR_ID, INTEGER( LVL ) );
          DB( CD_COMPILED,  VAR_ID, TRUE );
          declare
            INIT_EXP	: TREE	:= D( SM_INIT_EXP, VAR_ID );
          begin
            if INIT_EXP = TREE_VOID then
	    PUT_LINE( ASCII.HT & "LI" & ASCII.HT & INTEGER'IMAGE( -1 ) );

            else
null;--              LOAD_TYPE_SIZE( TYPE_SPEC  );
      --       EMIT( ALO, INTEGER( LVL - LEVEL_NUM( DI( CD_LEVEL, TYPE_SPEC ) ) ) );
            end if;
	  PUT_LINE( tab & "Sa" & ' ' & LEVEL_NUM'IMAGE( LVL ) & ',' & ASCII.HT & INTEGER'IMAGE( -1 ) );

          end;
        end;
      end	COMPILE_ACCESS_VAR;
	------------------


		-----------------
      procedure	COMPILE_ARRAY_VAR	( VC_NAME, TYPE_SPEC :TREE )
      is
        VC_STR		:constant STRING	:= PRINT_NAME( D( LX_SYMREP, VC_NAME ) );
        DIM_NBR		: NATURAL		:= 1;
        LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
        LVL_STR		:constant STRING	:= IMAGE( CODI.CUR_LEVEL );

		----------------------------
        procedure	COMPILE_ARRAY_TYPE_DIMENSION	( IDX_TYPE_LIST :in out SEQ_TYPE )
        is
	IDX_TYPE		: TREE;
	DIM_NBR_STR	:constant STRING	:= IMAGE( DIM_NBR );
        begin
	POP( IDX_TYPE_LIST, IDX_TYPE );
	PUT_LINE( tab & "VAR " & "SIZ_" & DIM_NBR_STR & ", d" );
	PUT_LINE( tab & "VAR " & "FST_" & DIM_NBR_STR & ", d" );
	PUT_LINE( tab & "VAR " & "LST_" & DIM_NBR_STR & ", d" );

	if IS_EMPTY( IDX_TYPE_LIST ) then
	  declare
	    TYPE_BASE		: TREE		:= D( SM_BASE_TYPE, TYPE_SPEC );
	    TYPE_ELEMENT		: TREE		:= D( SM_COMP_TYPE, TYPE_BASE );
	    ELEMENT_SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, TYPE_ELEMENT ) / 8;
	    ELEMENT_SIZ_STR		:constant STRING	:= IMAGE( ELEMENT_SIZ );
	  begin
	    PUT_LINE( tab & "LI" & tab & ELEMENT_SIZ_STR );
	    PUT_LINE( tab & "Sd" & ' ' & LVL_STR & ',' & tab & "SIZ_" & DIM_NBR_STR );
	    PUT_LINE( tab & "LI" & tab & ELEMENT_SIZ_STR );
	  end;
	  else
	    DIM_NBR := DIM_NBR + 1;
	    COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST );
	  end if;

	  if IDX_TYPE.TY = DN_INTEGER then
	    declare
	      IDX_RANGE   : TREE	:= D( SM_RANGE, IDX_TYPE );
	      RANGE_FIRST : TREE	:= D( AS_EXP1, IDX_RANGE );
	      RANGE_LAST  : TREE	:= D( AS_EXP2, IDX_RANGE );
	    begin
	      EXPRESSIONS.CODE_EXP( RANGE_FIRST );
	      PUT_LINE( tab & "Sd" & ' ' & LVL_STR & ',' & tab & "FST_" & DIM_NBR_STR );
	      EXPRESSIONS.CODE_EXP( RANGE_LAST );
	      PUT_LINE( tab & "Sd" & ' ' & LVL_STR & ',' & tab & "LST_" & DIM_NBR_STR );
	    end;
	  end if;

	end	COMPILE_ARRAY_TYPE_DIMENSION;
		----------------------------

      begin

        if TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY then
          PUT_LINE( "namespace " & VC_STR );
	declare
            IDX_TYPE_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_SUBTYPE_S, TYPE_SPEC ) );
	begin
	  COMPILE_ARRAY_TYPE_DIMENSION( IDX_TYPE_LIST );
	end;
	PUT_LINE( "end namespace " );
        end if;
        PUT( tab & "VAR " & VC_STR & "_disp, q" );
        if CODI.DEBUG then PUT( tab50 & "; variable ptr str" ); end if;
        NEW_LINE;

        DI( CD_LEVEL, VC_NAME, INTEGER( LVL ) );

	declare
	  INIT_EXP	: TREE	:= D( SM_INIT_EXP, VC_NAME );
	begin
            if INIT_EXP /= TREE_VOID then
	    if INIT_EXP.TY = DN_STRING_LITERAL then
	      declare
	        CST_CHN	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, INIT_EXP ) );
	      begin
	        if CODI.DEBUG then PUT_LINE( tab50 & "; constante string" ); end if;
	        PUT_LINE( "  postpone" );
	        PUT_LINE( "    dd" & tab & "1," & NATURAL'IMAGE( CST_CHN'LENGTH ) );
	        PUT_LINE( "    " & VC_STR & "_ptr = $" );
	        PUT_LINE( "    db" & tab & ''' & CST_CHN( CST_CHN'FIRST+1 .. CST_CHN'LAST-1 ) & ''' );
	        PUT_LINE( "  end postpone" );
	      end;

	      PUT_LINE( tab & "LCA" & tab & VC_STR & "_ptr" );						-- LOAD CONSTANT ADDRESS
	      PUT_LINE( tab & "Sa" & tab & LEVEL_NUM'IMAGE( LVL ) & ',' & tab & VC_STR & "_disp" );

	    end if;
	  end if;

	end;

	DI( CD_LEVEL,	VC_NAME, INTEGER( LVL ) );
	DB( CD_COMPILED,	VC_NAME, TRUE );
--	DESCR_PTR := CODI.OFFSET_ACT;
-- 	if DB( CD_COMPILED, TYPE_SPEC ) then
-- 	  OPER := LOAD_ADR( TYPE_SPEC );
-- 	  EMIT( DPL, A, "DUPLICATE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " ARRAY DESCRIPTOR TYPE_SPEC" );
-- 	  STORE( VC_NAME, ADR_TYP, OPER );
-- 	  EMIT( IND, I, 0, "CHARGE INDEXE TAILLE TABLEAU DE DESCRIPTEUR" );
-- 	  EMIT( ALO, INTEGER( 1 ), COMMENT=> "ALLOC TABLEAU" );
-- 	  STORE( VC_NAME, ADR_TYP, OPER );
-- 	else
-- 	  PUT_LINE( "!!! COMPILE_ARRAY_VAR : TYPE_SPEC NON COMPILE" );
-- 	  raise PROGRAM_ERROR;
-- 	end if;


      end	COMPILE_ARRAY_VAR;
	-----------------


		------------------
      procedure	COMPILE_RECORD_VAR		( VC_NAME, TYPE_SPEC :TREE )
      is
        INIT_EXP	: TREE	:= D( SM_INIT_EXP, VC_NAME );
      begin
        declare
	LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
        begin
          if CODI.DEBUG then PUT_LINE( tab50 & "; variable record" ); end if;

	PUT_LINE( "  virtual VARzone" );
	PUT_LINE( "    " & PRINT_NAME( D( LX_SYMREP, VC_NAME ) ) & "_disp = $" );
	PUT_LINE( "    db ? " & INTEGER'IMAGE( DI( CD_IMPL_SIZE, TYPE_SPEC ) ) & "dup" );
	PUT_LINE( "  end virtual" );

	DI( CD_LEVEL,     VC_NAME, INTEGER( LVL ) );
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
      when DN_ENUMERATION		=> COMPILE_VC_NAME_ENUMERATION( VC_NAME, TYPE_SPEC );
      when DN_INTEGER		=> COMPILE_VC_NAME_INTEGER(	    VC_NAME );
      when DN_FLOAT			=> COMPILE_VC_NAME_FLOAT(	    VC_NAME );
      when DN_ACCESS		=> COMPILE_ACCESS_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_RECORD		=> COMPILE_RECORD_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_CONSTRAINED_ARRAY
	| DN_ARRAY		=> COMPILE_ARRAY_VAR(	    VC_NAME, TYPE_SPEC );
      when others =>
        PUT_LINE( "ERREUR CODE_VC_NAME, TYPE_SPEC.TY = " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end case;
    end;
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
  end;

  --|-------------------------------------------------------------------------------------------
  procedure CODE_GENERIC_DECL ( GENERIC_DECL :TREE ) is

    GENERIC_ID	: TREE	:= D( AS_SOURCE_NAME, GENERIC_DECL );
  begin
    PUT_LINE( "; CODEGEN.DECLARATIONS.CODE_GENERIC_DECL : PAS ENCORE FAIT ! "
	    & PRINT_NAME( D( LX_SYMREP, GENERIC_ID ) ) );

  end;

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



				-----------------
  procedure			CODE_PACKAGE_DECL		( PACKAGE_DECL :TREE )
  is
  begin

    if D( AS_UNIT_KIND, PACKAGE_DECL ).TY = DN_INSTANTIATION then
      CODE_PACKAGE_SPEC( D( SM_SPEC, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) );

    else
      CODE_HEADER( D( AS_HEADER, PACKAGE_DECL ) );

    end if;

    declare
      EXC_LBL		:constant STRING	:= NEW_LABEL;
    begin
--        EMIT( EXH, EXC_LBL, COMMENT=> "ETIQUETTE EXCEPTION HANDLE DU PACKAGE" );
--        EMIT( RET, RELATIVE_RESULT_OFFSET );
PUT_LINE( "; EXC_LBL" & tab & EXC_LBL );
      end;
--      EMIT( EEX );

  end	CODE_PACKAGE_DECL;
	-----------------


	------------
end	DECLARATIONS;
	------------
