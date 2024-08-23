separate ( CODE_GEN )
				------------
 	package body		DECLARATIONS
				------------
is


  package CODI	renames CODAGE_INTERMEDIAIRE;



			-----------
  procedure		CODE_HEADER		( HEADER :TREE )
  is
  begin
    if HEADER.TY in CLASS_SUBP_ENTRY_HEADER
    then
      CODE_PARAM_S( D( AS_PARAM_S, HEADER ) );
      CODE_SUBP_ENTRY_HEADER( HEADER );

    elsif HEADER.TY = DN_PACKAGE_SPEC then
      CODE_PACKAGE_SPEC( HEADER );

    end if;

  end	CODE_HEADER;
	-----------


			----------------------
  procedure		CODE_SUBP_ENTRY_HEADER	( SUBP_ENTRY_HEADER :TREE )
  is
  begin
    if SUBP_ENTRY_HEADER.TY = DN_PROCEDURE_SPEC
    then
      CODI.PARAM_SIZE := CODI.OFFSET_ACT - CODI.FIRST_PARAM_OFFSET;

    elsif SUBP_ENTRY_HEADER.TY = DN_FUNCTION_SPEC
    then
      ALTER_OFFSET( CODI.RELATIVE_RESULT_OFFSET );
      CODI.PARAM_SIZE := CODI.OFFSET_ACT - CODI.FIRST_PARAM_OFFSET;
      DI( CD_RESULT_SIZE, D( AS_NAME, SUBP_ENTRY_HEADER ), CODI.RESULT_SIZE );
      ALTER_OFFSET( CODI.RESULT_SIZE );
      ALIGN( STACK_AL );
      DI( CD_RESULT_OFFSET, SUBP_ENTRY_HEADER, CODI.OFFSET_ACT );
      CODI.FUN_RESULT_OFFSET := CODI.OFFSET_ACT;

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
      begin
        ALIGN( INTG_AL );
        declare
	SEG	: SEGMENT_NUM	renames CODI.CUR_COMP_UNIT;
	LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
	OFS	: OFFSET_VAL	:= CODI.OFFSET_ACT;
	INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
        begin
          DI( CD_COMP_UNIT, VC_NAME, INTEGER( SEG ) );
          DI( CD_LEVEL,     VC_NAME, INTEGER( LVL ) );
          DI( CD_OFFSET,    VC_NAME, OFS );
          DB( CD_COMPILED,  VC_NAME, TRUE );
          ALTER_OFFSET( INTG_SIZE );
          if INIT_EXP /= TREE_VOID then
	  declare
	    INIT_EXP_RESULT		: OPERAND_REF	:= EXPRESSIONS.CODE_EXP( INIT_EXP );
	  begin
	    STORE( VC_NAME, WORD_TYP, INIT_EXP_RESULT );
	  end;
          end if;
        end;
      end	COMPILE_VC_NAME_INTEGER;
	-----------------------

		---------------------------
      procedure	COMPILE_VC_NAME_ENUMERATION	( VC_NAME, TYPE_SPEC :TREE )
      is
        NAME	:constant STRING	:= PRINT_NAME( CODI.TYPE_SYMREP );

		-------------------------
        procedure	COMPILE_VC_NAME_BOOL_CHAR	( VC_NAME :TREE; OTYPE :OPERAND_TYPE; SIZ, ALI :NATURAL ) is
        begin
          ALIGN( ALI );
          declare
	  SEG		: SEGMENT_NUM	renames CODI.CUR_COMP_UNIT;
	  LVL		: LEVEL_NUM	renames CODI.CUR_LEVEL;
	  OFS		: OFFSET_VAL	:= CODI.OFFSET_ACT;
	  INIT_EXP	: TREE		:= D( SM_INIT_EXP, VC_NAME );
          begin
            DI( CD_COMP_UNIT, VC_NAME, SEG );
            DI( CD_LEVEL,     VC_NAME, INTEGER( LVL ) );
            DI( CD_OFFSET,    VC_NAME, OFS );
            DB( CD_COMPILED,  VC_NAME, TRUE );
            ALTER_OFFSET( SIZ );
            if INIT_EXP /= TREE_VOID then
	    declare
	      INIT_EXP_RESULT	: OPERAND_REF	:= EXPRESSIONS.CODE_EXP( INIT_EXP );
	    begin
                STORE( VC_NAME, OTYPE, INIT_EXP_RESULT );
	    end;
            end if;
          end;
        end	COMPILE_VC_NAME_BOOL_CHAR;
		-------------------------

      begin
        if NAME = "BOOLEAN" then
          COMPILE_VC_NAME_BOOL_CHAR( VC_NAME, BYTE_TYP, BOOL_SIZE, BOOL_AL );
        elsif NAME = "CHARACTER" then
          COMPILE_VC_NAME_BOOL_CHAR( VC_NAME, BYTE_TYP, CHAR_SIZE, CHAR_AL );
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
	SEG	: SEGMENT_NUM	renames CODI.CUR_COMP_UNIT;
	LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
	OFS	: OFFSET_VAL	:= CODI.OFFSET_ACT;
        begin
	DI( CD_COMP_UNIT, VAR_ID, SEG );
	DI( CD_LEVEL,     VAR_ID, INTEGER( LVL ) );
	DI( CD_OFFSET,    VAR_ID, OFS );
          DB( CD_COMPILED,  VAR_ID, TRUE );
          ALTER_OFFSET( ADDR_SIZE );
          declare
            INIT_EXP	: TREE	:= D( SM_INIT_EXP, VAR_ID );
	  PTR_VAL		: OPERAND_REF	:= NO_OPERAND;
          begin
            if INIT_EXP = TREE_VOID then
	    PTR_VAL := LOAD_IMM( -1 );
--              EMIT( LDC, A, -1, "INIT NIL DE " & PRINT_NAME( D( LX_SYMREP, VAR_ID ) ) );
            else
              LOAD_TYPE_SIZE( TYPE_SPEC  );
              EMIT( ALO, INTEGER( LVL - LEVEL_NUM( DI( CD_LEVEL, TYPE_SPEC ) ) ) );
            end if;
            STORE( VAR_ID, ADR_TYP, PTR_VAL );
          end;
        end;
      end	COMPILE_ACCESS_VAR;
	------------------


		-----------------
      procedure	COMPILE_ARRAY_VAR	( VC_NAME, TYPE_SPEC :TREE )
      is
        DESCR_PTR	: OFFSET_VAL;
      begin
        ALIGN ( ADDR_AL );
        declare
	SEG	: SEGMENT_NUM	renames CODI.CUR_COMP_UNIT;
          LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
          VALUE_PTR	: OFFSET_VAL	:= CODI.OFFSET_ACT;
	OPER	: OPERAND_REF	:= NO_OPERAND;
        begin
	DI( CD_COMP_UNIT,	VC_NAME, SEG );
	DI( CD_LEVEL,	VC_NAME, INTEGER( LVL ) );
	DI( CD_OFFSET,	VC_NAME, VALUE_PTR );
	DB( CD_COMPILED,	VC_NAME, TRUE );
	ALTER_OFFSET( ADDR_SIZE );
	ALIGN       ( ADDR_AL );
	DESCR_PTR := CODI.OFFSET_ACT;
	ALTER_OFFSET( ADDR_SIZE );
	if DB( CD_COMPILED, TYPE_SPEC ) then
	  OPER := LOAD_ADR( TYPE_SPEC );
	  EMIT( DPL, A, "DUPLICATE " & PRINT_NAME ( D (LX_SYMREP, VC_NAME ) ) & " ARRAY DESCRIPTOR TYPE_SPEC" );
	  STORE( VC_NAME, ADR_TYP, OPER );
	  EMIT( IND, I, 0, "CHARGE INDEXE TAILLE TABLEAU DE DESCRIPTEUR" );
	  EMIT( ALO, INTEGER( 1 ), COMMENT=> "ALLOC TABLEAU" );
	  STORE( VC_NAME, ADR_TYP, OPER );
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
	SEG	: SEGMENT_NUM	renames CODI.CUR_COMP_UNIT;
	LVL	: LEVEL_NUM	renames CODI.CUR_LEVEL;
	OFS	: OFFSET_VAL	:= CODI.OFFSET_ACT;
        begin
	DI( CD_COMP_UNIT, VC_NAME, SEG );
	DI( CD_LEVEL,     VC_NAME, INTEGER( LVL ) );
	DI( CD_OFFSET,    VC_NAME, OFS );
          DB( CD_COMPILED,  VC_NAME, TRUE );
	if INIT_EXP.TY = DN_AGGREGATE then
	  declare
	    GENERAL_ASSOC_SEQ	: SEQ_TYPE	:= LIST( D( SM_NORMALIZED_COMP_S, INIT_EXP ) );
	    COMP_EXP		: TREE;
	    OPER			: OPERAND_REF;
	  begin
	    while not IS_EMPTY( GENERAL_ASSOC_SEQ ) loop
	      POP( GENERAL_ASSOC_SEQ, COMP_EXP );
	      OPER := EXPRESSIONS.CODE_EXP( COMP_EXP );
	    end loop;
	  end;
	end if;
        end;
      end	COMPILE_RECORD_VAR;
	------------------


    begin
      case TYPE_SPEC.TY is
      when DN_ENUMERATION	=> COMPILE_VC_NAME_ENUMERATION( VC_NAME, TYPE_SPEC );
      when DN_INTEGER	=> COMPILE_VC_NAME_INTEGER(	    VC_NAME );
      when DN_ACCESS	=> COMPILE_ACCESS_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_RECORD	=> COMPILE_RECORD_VAR(	    VC_NAME, TYPE_SPEC );
      when DN_ARRAY		=> COMPILE_ARRAY_VAR(	    VC_NAME, TYPE_SPEC );
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
  begin
    null;
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




  procedure CODE_SUBPROG_ENTRY_DECL	( SUBPROG_ENTRY_DECL :TREE );


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

			-----------------------
  procedure		CODE_SUBPROG_ENTRY_DECL	( SUBPROG_ENTRY_DECL :TREE )
  is
  begin
    declare
      OLD_OFFSET_ACT : OFFSET_VAL := CODI.OFFSET_ACT;
      OLD_OFFSET_MAX : OFFSET_VAL := CODI.OFFSET_MAX;
      SOURCE_NAME    : TREE        := D ( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
      HEADER         : TREE        := D ( AS_HEADER, SUBPROG_ENTRY_DECL );
    begin
      CODI.OFFSET_ACT := CODI.FIRST_PARAM_OFFSET;
      CODI.OFFSET_MAX := CODI.OFFSET_ACT;
      INC_LEVEL;
      if SOURCE_NAME.TY in CLASS_SUBPROG_NAME then
        declare
          LBL : LABEL_TYPE := NEW_LABEL;
        begin
          DI ( CD_LABEL, SOURCE_NAME, INTEGER( LBL ) );
          DI ( CD_LEVEL, SOURCE_NAME, INTEGER( CODI.CUR_LEVEL ) );
          DB ( CD_COMPILED, SOURCE_NAME, TRUE );
          if not CODI.GENERATE_CODE then
            CODI.GENERATE_CODE := TRUE;
            EMIT ( RFL, LBL );
            CODI.GENERATE_CODE := FALSE;
          end if;

		CODE_HEADER( D( AS_HEADER, SUBPROG_ENTRY_DECL ) );

          DI( CD_PARAM_SIZE, SOURCE_NAME, OFFSET_ACT - FIRST_PARAM_OFFSET );
        end;
        if SOURCE_NAME.TY = DN_FUNCTION_ID or SOURCE_NAME.TY = DN_OPERATOR_ID then
          declare
            USED_OBJECT_ID   : TREE := D ( AS_NAME, HEADER );
            RESULT_TYPE_SPEC : TREE := D ( SM_EXP_TYPE, USED_OBJECT_ID );
          begin
            DI( CD_RESULT_SIZE, SOURCE_NAME, CODI.TYPE_SIZE( RESULT_TYPE_SPEC ));
          end;
        end if;
      end if;
      DEC_LEVEL;
      CODI.OFFSET_MAX := OLD_OFFSET_MAX;
      CODI.OFFSET_ACT := OLD_OFFSET_ACT;
    end;

  end	CODE_SUBPROG_ENTRY_DECL;
	-----------------------


				-----------------
  procedure			CODE_PACKAGE_DECL		( PACKAGE_DECL :TREE )
  is
  begin
    EMIT( PKG, S=> PRINT_NAME( D( LX_SYMREP, D( AS_SOURCE_NAME, PACKAGE_DECL ) ) ) );
    WRITE_LABEL ( 1 );
    declare
      MAX_OFS_LBL		: LABEL_TYPE	:= NEW_LABEL;
      TOP_OFS_LBL		: LABEL_TYPE	:= NEW_LABEL;
    begin
      EMIT( ENT, INTEGER( 1 ), MAX_OFS_LBL );
      EMIT( ENT, INTEGER( 2 ), TOP_OFS_LBL );
      CODI.OFFSET_ACT := 0;
      CODI.OFFSET_MAX := 0;

	CODE_HEADER( D( AS_HEADER, PACKAGE_DECL ) );

      declare
        EXC_LBL		: LABEL_TYPE	:= NEW_LABEL;
      begin
        EMIT( EXH, EXC_LBL, COMMENT=> "ETIQUETTE EXCEPTION HANDLE DU PACKAGE" );
        EMIT( RET, RELATIVE_RESULT_OFFSET );
        WRITE_LABEL( EXC_LBL );
      end;
      EMIT( EEX );
      GEN_LBL_ASSIGNMENT( MAX_OFS_LBL, OFFSET_MAX );
      GEN_LBL_ASSIGNMENT( TOP_OFS_LBL, TOP_MAX + OFFSET_MAX );
    end;

  end	CODE_PACKAGE_DECL;
	-----------------


	------------
end	DECLARATIONS;
	------------