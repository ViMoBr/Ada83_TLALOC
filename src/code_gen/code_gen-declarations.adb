separate ( CODE_GEN )
				------------
 	package body		DECLARATIONS
				------------
  is

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
      EMITS.PARAM_SIZE := EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET;

    elsif SUBP_ENTRY_HEADER.TY = DN_FUNCTION_SPEC
    then
      INC_OFFSET( EMITS.RELATIVE_RESULT_OFFSET );
      EMITS.PARAM_SIZE := EMITS.OFFSET_ACT - EMITS.FIRST_PARAM_OFFSET;
      DI( CD_RESULT_SIZE, D( AS_NAME, SUBP_ENTRY_HEADER ), EMITS.RESULT_SIZE );
      INC_OFFSET( EMITS.RESULT_SIZE );
      ALIGN( STACK_AL );
      DI( CD_RESULT_OFFSET, SUBP_ENTRY_HEADER, EMITS.OFFSET_ACT );
      EMITS.FUN_RESULT_OFFSET := EMITS.OFFSET_ACT;

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
      CODE_NULL_COMP_DECL ( DECL );

    elsif DECL.TY in CLASS_ID_DECL then
      CODE_ID_DECL ( DECL );

    elsif DECL.TY in CLASS_ID_S_DECL then
      CODE_ID_S_DECL ( DECL );

    elsif DECL.TY in CLASS_REP then
      CODE_REP ( DECL );

    elsif DECL.TY in CLASS_USE_PRAGMA then
      CODE_USE_PRAGMA ( DECL );

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
      OLD_OFFSET_ACT : OFFSET_TYPE := EMITS.OFFSET_ACT;
      OLD_OFFSET_MAX : OFFSET_TYPE := EMITS.OFFSET_MAX;
      SOURCE_NAME    : TREE        := D ( AS_SOURCE_NAME, SUBPROG_ENTRY_DECL );
      HEADER         : TREE        := D ( AS_HEADER, SUBPROG_ENTRY_DECL );
    begin
      EMITS.OFFSET_ACT := EMITS.FIRST_PARAM_OFFSET;
      EMITS.OFFSET_MAX := EMITS.OFFSET_ACT;
      INC_LEVEL;
      if SOURCE_NAME.TY in CLASS_SUBPROG_NAME then
        declare
          LBL : LABEL_TYPE := NEW_LABEL;
        begin
          DI ( CD_LABEL, SOURCE_NAME, INTEGER ( LBL ) );
          DI ( CD_LEVEL, SOURCE_NAME, EMITS.CUR_LEVEL );
          DB ( CD_COMPILED, SOURCE_NAME, TRUE );
          if not EMITS.GENERATE_CODE then
            EMITS.GENERATE_CODE := TRUE;
            EMIT ( RFL, LBL );
            EMITS.GENERATE_CODE := FALSE;
          end if;

	CODE_HEADER( D( AS_HEADER, SUBPROG_ENTRY_DECL ) );

          DI( CD_PARAM_SIZE, SOURCE_NAME, OFFSET_ACT - FIRST_PARAM_OFFSET );
        end;
        if SOURCE_NAME.TY = DN_FUNCTION_ID or SOURCE_NAME.TY = DN_OPERATOR_ID then
          declare
            USED_OBJECT_ID   : TREE := D ( AS_NAME, HEADER );
            RESULT_TYPE_SPEC : TREE := D ( SM_EXP_TYPE, USED_OBJECT_ID );
          begin
            DI ( CD_RESULT_SIZE, SOURCE_NAME, EMITS.TYPE_SIZE( RESULT_TYPE_SPEC ));
          end;
        end if;
      end if;
      DEC_LEVEL;
      EMITS.OFFSET_MAX := OLD_OFFSET_MAX;
      EMITS.OFFSET_ACT := OLD_OFFSET_ACT;
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
      EMITS.OFFSET_ACT := 0;
      EMITS.OFFSET_MAX := 0;

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