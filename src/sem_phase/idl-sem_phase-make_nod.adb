------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	MAKE_NOD.ADB	VINCENT MORIN	6/5/2025	UNIVERSITE DE BRETAGNE OCCIDENTALE
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


SEPARATE ( IDL.SEM_PHASE  )


					--------
package body				MAKE_NOD
is					--------
   
       package DA renames DIANA_NODE_ATTR_CLASS_NAMES;

		----------------
  function	MAKE_VARIABLE_ID		( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP :TREE := TREE_VOID;
					  SM_RENAMES_OBJ	:BOOLEAN	:= FALSE;
					  SM_ADDRESS	:TREE	:= TREE_VOID;
					  SM_IS_SHARED	:BOOLEAN	:= FALSE;
					  XD_REGION	:TREE	:= TREE_VOID )
					return TREE
  is		----------------

    NODE		 :TREE	:= MAKE( DN_VARIABLE_ID );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    DB( DA.SM_RENAMES_OBJ, NODE, SM_RENAMES_OBJ );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    DB( DA.SM_IS_SHARED, NODE, SM_IS_SHARED );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_VARIABLE_ID;
	----------------


		----------------
  function	MAKE_CONSTANT_ID		( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP :TREE := TREE_VOID;
					  SM_RENAMES_OBJ :BOOLEAN := FALSE;
					  SM_ADDRESS, SM_FIRST, XD_REGION :TREE := TREE_VOID )
					return TREE
  is		----------------

    NODE		 :TREE	:= MAKE( DN_CONSTANT_ID  );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    DB( DA.SM_RENAMES_OBJ, NODE, SM_RENAMES_OBJ );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_CONSTANT_ID;
	----------------


		--------------
  function	MAKE_NUMBER_ID		( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP,
					  XD_REGION :TREE := TREE_VOID  )
					return TREE
  is		--------------

    NODE		:TREE	:= MAKE( DN_NUMBER_ID );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_NUMBER_ID;
	--------------


		-----------------
  function	MAKE_COMPONENT_ID		( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP, SM_COMP_REP,
					  XD_REGION :TREE := TREE_VOID  )
					return TREE
  is		-----------------

    NODE		:TREE	:= MAKE( DN_COMPONENT_ID );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.SM_COMP_REP, NODE, SM_COMP_REP );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_COMPONENT_ID;
	-----------------


		--------------------
  function	MAKE_DISCRIMINANT_ID	( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP, SM_COMP_REP,
					  SM_FIRST, XD_REGION :TREE := TREE_VOID )
					return TREE
  is		--------------------

         NODE :TREE := MAKE( DN_DISCRIMINANT_ID );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.SM_COMP_REP, NODE, SM_COMP_REP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_DISCRIMINANT_ID;
	--------------------


		----------
  function	MAKE_IN_ID		( LX_SRCPOS, LX_SYMREP, SM_OBJ_TYPE, SM_INIT_EXP, SM_FIRST,
					  XD_REGION	:TREE	:= TREE_VOID )
					return TREE
  is		---------
         NODE :TREE := MAKE( DN_IN_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_IN_ID;
	----------


		--------------
  function	MAKE_IN_OUT_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_OBJ_TYPE :TREE := TREE_VOID;
		    SM_INIT_EXP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE
  is		--------------

    NODE		:TREE	:= MAKE( DN_IN_OUT_ID );

  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
    return NODE;

  end	MAKE_IN_OUT_ID;
	--------------


		-----------
  function	MAKE_OUT_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_OBJ_TYPE :TREE := TREE_VOID;
		    SM_INIT_EXP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_OUT_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.SM_INIT_EXP, NODE, SM_INIT_EXP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_OUT_ID;
   
  function	MAKE_ENUMERATION_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_OBJ_TYPE :TREE := TREE_VOID;
		    SM_POS :INTEGER := 0;
		    SM_REP :INTEGER := 0;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENUMERATION_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
         DI (DA.SM_POS, NODE, SM_POS );
         DI (DA.SM_REP, NODE, SM_REP );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_ENUMERATION_ID;
   
  function	MAKE_CHARACTER_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_OBJ_TYPE :TREE := TREE_VOID;
		    SM_POS :INTEGER := 0;
		    SM_REP :INTEGER := 0;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CHARACTER_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
         DI (DA.SM_POS, NODE, SM_POS );
         DI (DA.SM_REP, NODE, SM_REP );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_CHARACTER_ID;
   
  function	MAKE_ITERATION_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_OBJ_TYPE :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ITERATION_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_ITERATION_ID;
   
  function	MAKE_TYPE_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TYPE_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_TYPE_ID;
   
  function	MAKE_SUBTYPE_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBTYPE_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_SUBTYPE_ID;
   
  function	MAKE_PRIVATE_TYPE_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PRIVATE_TYPE_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_PRIVATE_TYPE_ID;
   
  function	MAKE_L_PRIVATE_TYPE_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_L_PRIVATE_TYPE_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_L_PRIVATE_TYPE_ID;
   
  function	MAKE_PROCEDURE_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_UNIT_DESC :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    SM_IS_INLINE :BOOLEAN := FALSE;
		    SM_INTERFACE :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID;
		    XD_STUB :TREE := TREE_VOID;
		    XD_body :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PROCEDURE_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE );
    D( DA.SM_INTERFACE, NODE, SM_INTERFACE );
    D( DA.XD_REGION, NODE, XD_REGION );
    D( DA.XD_STUB, NODE, XD_STUB );
    D( DA.XD_body, NODE, XD_body );
         return NODE;
  end	MAKE_PROCEDURE_ID;
   
  function	MAKE_FUNCTION_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_UNIT_DESC :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    SM_IS_INLINE :BOOLEAN := FALSE;
		    SM_INTERFACE :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID;
		    XD_STUB :TREE := TREE_VOID;
		    XD_body :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FUNCTION_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE );
    D( DA.SM_INTERFACE, NODE, SM_INTERFACE );
    D( DA.XD_REGION, NODE, XD_REGION );
    D( DA.XD_STUB, NODE, XD_STUB );
    D( DA.XD_body, NODE, XD_body );
         return NODE;
  end	MAKE_FUNCTION_ID;
   
  function	MAKE_OPERATOR_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_UNIT_DESC :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    SM_IS_INLINE :BOOLEAN := FALSE;
		    SM_INTERFACE :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID;
		    XD_STUB :TREE := TREE_VOID;
		    XD_body :TREE := TREE_VOID;
		    XD_NOT_EQUAL :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_OPERATOR_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE );
    D( DA.SM_INTERFACE, NODE, SM_INTERFACE );
    D( DA.XD_REGION, NODE, XD_REGION );
    D( DA.XD_STUB, NODE, XD_STUB );
    D( DA.XD_body, NODE, XD_body );
    D( DA.XD_NOT_EQUAL, NODE, XD_NOT_EQUAL );
         return NODE;
  end	MAKE_OPERATOR_ID;
   
  function	MAKE_package_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_UNIT_DESC :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID;
		    XD_STUB :TREE := TREE_VOID;
		    XD_body :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_package_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    D( DA.XD_REGION, NODE, XD_REGION );
    D( DA.XD_STUB, NODE, XD_STUB );
    D( DA.XD_body, NODE, XD_body );
         return NODE;
  end	MAKE_package_ID;
   
  function	MAKE_GENERIC_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_GENERIC_PARAM_S :TREE := TREE_VOID;
		    SM_body :TREE := TREE_VOID;
		    SM_IS_INLINE :BOOLEAN := FALSE;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_GENERIC_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_GENERIC_PARAM_S, NODE, SM_GENERIC_PARAM_S );
    D( DA.SM_body, NODE, SM_body );
    DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_GENERIC_ID;
   
  function	MAKE_TASK_body_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_FIRST :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    SM_body :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TASK_body_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_FIRST, NODE, SM_FIRST );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.SM_body, NODE, SM_body );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_TASK_body_ID;
   
  function	MAKE_LABEL_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_STM :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_LABEL_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_STM, NODE, SM_STM );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_LABEL_ID;
   
  function	MAKE_BLOCK_LOOP_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_STM :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_BLOCK_LOOP_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_STM, NODE, SM_STM );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_BLOCK_LOOP_ID;
   
  function	MAKE_ENTRY_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_SPEC :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    XD_REGION :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENTRY_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_SPEC, NODE, SM_SPEC );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_ENTRY_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_EXCEPTION_ID
  function	MAKE_EXCEPTION_ID ( LX_SRCPOS, LX_SYMREP, SM_RENAMES_EXC, XD_REGION :TREE := TREE_VOID  ) return TREE is
         NODE	 :TREE := MAKE( DN_EXCEPTION_ID  );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_RENAMES_EXC, NODE, SM_RENAMES_EXC );
    D( DA.XD_REGION, NODE, XD_REGION );
         return NODE;
  end	MAKE_EXCEPTION_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_ATTRIBUTE_ID
  function	MAKE_ATTRIBUTE_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER  ) return TREE is
         NODE	 :TREE := MAKE( DN_ATTRIBUTE_ID  );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS  );
    D( DA.LX_SYMREP, NODE, LX_SYMREP  );
         DI ( DA.XD_POS,   NODE, XD_POS  );
         return NODE;
  end	MAKE_ATTRIBUTE_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_PRAGMA_ID
  function	MAKE_PRAGMA_ID ( LX_SRCPOS, LX_SYMREP, SM_ARGUMENT_ID_S :TREE := TREE_VOID; XD_POS :INTEGER  ) return TREE is
         NODE	 :TREE := MAKE( DN_PRAGMA_ID  );
  begin
         D  ( DA.LX_SRCPOS, NODE, LX_SRCPOS  );
         D  ( DA.LX_SYMREP, NODE, LX_SYMREP  );
         DI ( DA.XD_POS,    NODE, XD_POS  );
         D  ( DA.SM_ARGUMENT_ID_S, NODE, SM_ARGUMENT_ID_S  );
         return NODE;
  end;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_ARGUMENT_ID
  function	MAKE_ARGUMENT_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER  ) return TREE is
         NODE	 :TREE := MAKE( DN_ARGUMENT_ID  );
  begin
         D  ( DA.LX_SRCPOS, NODE, LX_SRCPOS  );
         D  ( DA.LX_SYMREP, NODE, LX_SYMREP  );
         DI ( DA.XD_POS,    NODE, XD_POS  );
         return NODE;
  end;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_BLTN_OPERATOR_ID
  function	MAKE_BLTN_OPERATOR_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; SM_OPERATOR :INTEGER  ) return TREE is
         NODE	 :TREE := MAKE( DN_BLTN_OPERATOR_ID  );
  begin
         D  ( DA.LX_SRCPOS,   NODE, LX_SRCPOS );
         D  ( DA.LX_SYMREP,   NODE, LX_SYMREP );
         DI ( DA.SM_OPERATOR, NODE, SM_OPERATOR );
         return NODE;
  end;
   
  function	MAKE_BLOCK_MASTER
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    SM_STM :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_BLOCK_MASTER );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_STM, NODE, SM_STM );
         return NODE;
  end	MAKE_BLOCK_MASTER;
   
  function	MAKE_DSCRMT_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DSCRMT_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DSCRMT_DECL;
   
  function	MAKE_IN
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    LX_DEFAULT :BOOLEAN := FALSE )
		    return TREE is
         NODE :TREE := MAKE( DN_IN );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    DB( DA.LX_DEFAULT, NODE, LX_DEFAULT );
         return NODE;
  end	MAKE_IN;
   
  function	MAKE_OUT
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_OUT );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_OUT;
   
  function	MAKE_IN_OUT
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_IN_OUT );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_IN_OUT;
   
  function	MAKE_CONSTANT_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    AS_TYPE_DEF :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONSTANT_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CONSTANT_DECL;
   
  function	MAKE_VARIABLE_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    AS_TYPE_DEF :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_VARIABLE_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_VARIABLE_DECL;
   
  function	MAKE_NUMBER_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NUMBER_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NUMBER_DECL;
   
  function	MAKE_EXCEPTION_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_EXCEPTION_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_EXCEPTION_DECL;
   
  function	MAKE_DEFERRED_CONSTANT_DECL
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DEFERRED_CONSTANT_DECL );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DEFERRED_CONSTANT_DECL;
   
  function	MAKE_TYPE_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_DSCRMT_DECL_S :TREE := TREE_VOID;
		    AS_TYPE_DEF :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TYPE_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_DSCRMT_DECL_S, NODE, AS_DSCRMT_DECL_S );
    D( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TYPE_DECL;
   
  function	MAKE_SUBTYPE_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBTYPE_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SUBTYPE_DECL;
   
  function	MAKE_TASK_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_DECL_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TASK_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_DECL_S, NODE, AS_DECL_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TASK_DECL;
   
  function	MAKE_GENERIC_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_HEADER :TREE := TREE_VOID;
		    AS_ITEM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_GENERIC_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_HEADER, NODE, AS_HEADER );
    D( DA.AS_ITEM_S, NODE, AS_ITEM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_GENERIC_DECL;
   
  function	MAKE_SUBPROG_ENTRY_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_HEADER :TREE := TREE_VOID;
		    AS_UNIT_KIND :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBPROG_ENTRY_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_HEADER, NODE, AS_HEADER );
    D( DA.AS_UNIT_KIND, NODE, AS_UNIT_KIND );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SUBPROG_ENTRY_DECL;
   
  function	MAKE_package_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_HEADER :TREE := TREE_VOID;
		    AS_UNIT_KIND :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID  )
		    return TREE is
         NODE :TREE := MAKE( DN_package_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_HEADER, NODE, AS_HEADER );
    D( DA.AS_UNIT_KIND, NODE, AS_UNIT_KIND );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_package_DECL;
   
  function	MAKE_RENAMES_OBJ_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    AS_TYPE_MARK_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RENAMES_OBJ_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_TYPE_MARK_NAME, NODE, AS_TYPE_MARK_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RENAMES_OBJ_DECL;
   
  function	MAKE_RENAMES_EXC_DECL
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RENAMES_EXC_DECL );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RENAMES_EXC_DECL;
   
  function	MAKE_NULL_COMP_DECL
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NULL_COMP_DECL );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NULL_COMP_DECL;
   
  function	MAKE_LENGTH_ENUM_REP
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_LENGTH_ENUM_REP );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_LENGTH_ENUM_REP;
   
  function	MAKE_ADDRESS
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ADDRESS );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ADDRESS;
   
  function	MAKE_RECORD_REP
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_ALIGNMENT_CLAUSE :TREE := TREE_VOID;
		    AS_COMP_REP_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RECORD_REP );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_ALIGNMENT_CLAUSE, NODE, AS_ALIGNMENT_CLAUSE );
    D( DA.AS_COMP_REP_S, NODE, AS_COMP_REP_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RECORD_REP;
   
  function	MAKE_USE
		    ( AS_NAME_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USE );
  begin
    D( DA.AS_NAME_S, NODE, AS_NAME_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_USE;
   
  function	MAKE_PRAGMA
		    ( AS_USED_NAME_ID :TREE := TREE_VOID;
		    AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PRAGMA );
  begin
    D( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID );
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_PRAGMA;
   
  function	MAKE_SUBPROGRAM_body
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_body :TREE := TREE_VOID;
		    AS_HEADER :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBPROGRAM_body );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_body, NODE, AS_body );
    D( DA.AS_HEADER, NODE, AS_HEADER );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SUBPROGRAM_body;
   
  function	MAKE_package_body
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_body :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_package_body );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_body, NODE, AS_body );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_package_body;
   
  function	MAKE_TASK_body
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_body :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TASK_body );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_body, NODE, AS_body );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TASK_body;
   
  function	MAKE_SUBUNIT
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_SUBUNIT_body :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBUNIT );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_SUBUNIT_body, NODE, AS_SUBUNIT_body );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SUBUNIT;
   
  function	MAKE_ENUMERATION_DEF
		    ( AS_ENUM_LITERAL_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENUMERATION_DEF );
  begin
    D( DA.AS_ENUM_LITERAL_S, NODE, AS_ENUM_LITERAL_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ENUMERATION_DEF;
   
  function	MAKE_SUBTYPE_INDICATION
		    ( AS_CONSTRAINT :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBTYPE_INDICATION );
  begin
    D( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SUBTYPE_INDICATION;
   
  function	MAKE_INTEGER_DEF
		    ( AS_CONSTRAINT :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INTEGER_DEF );
  begin
    D( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_INTEGER_DEF;
   
  function	MAKE_FLOAT_DEF
		    ( AS_CONSTRAINT :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FLOAT_DEF );
  begin
    D( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FLOAT_DEF;
   
  function	MAKE_FIXED_DEF
		    ( AS_CONSTRAINT :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FIXED_DEF );
  begin
    D( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FIXED_DEF;
   
  function	MAKE_CONSTRAINED_ARRAY_DEF
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    AS_CONSTRAINT :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONSTRAINED_ARRAY_DEF );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CONSTRAINED_ARRAY_DEF;
   
  function	MAKE_UNCONSTRAINED_ARRAY_DEF
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    AS_INDEX_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_UNCONSTRAINED_ARRAY_DEF );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.AS_INDEX_S, NODE, AS_INDEX_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_UNCONSTRAINED_ARRAY_DEF;
   
  function	MAKE_ACCESS_DEF
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ACCESS_DEF );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ACCESS_DEF;
   
  function	MAKE_DERIVED_DEF
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL ) )
		    return TREE is
         NODE :TREE := MAKE( DN_DERIVED_DEF );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         IDL_MAN.LIST(NODE, LIST );
         return NODE;
  end	MAKE_DERIVED_DEF;
   
  function	MAKE_RECORD_DEF
		    ( AS_COMP_LIST :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RECORD_DEF );
  begin
    D( DA.AS_COMP_LIST, NODE, AS_COMP_LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RECORD_DEF;
   
  function	MAKE_PRIVATE_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PRIVATE_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_PRIVATE_DEF;
   
  function	MAKE_L_PRIVATE_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_L_PRIVATE_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_L_PRIVATE_DEF;
   
  function	MAKE_FORMAL_DSCRT_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FORMAL_DSCRT_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FORMAL_DSCRT_DEF;
   
  function	MAKE_FORMAL_INTEGER_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FORMAL_INTEGER_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FORMAL_INTEGER_DEF;
   
  function	MAKE_FORMAL_FIXED_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FORMAL_FIXED_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FORMAL_FIXED_DEF;
   
  function	MAKE_FORMAL_FLOAT_DEF
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FORMAL_FLOAT_DEF );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FORMAL_FLOAT_DEF;
   
  function	MAKE_ALTERNATIVE_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ALTERNATIVE_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ALTERNATIVE_S;
   
  function	MAKE_ARGUMENT_ID_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ARGUMENT_ID_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ARGUMENT_ID_S;
   
  function	MAKE_CHOICE_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CHOICE_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CHOICE_S;
   
  function	MAKE_COMP_REP_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMP_REP_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMP_REP_S;
   
  function	MAKE_COMPLTN_UNIT_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMPLTN_UNIT_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMPLTN_UNIT_S;
   
  function	MAKE_CONTEXT_ELEM_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONTEXT_ELEM_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CONTEXT_ELEM_S;
   
  function	MAKE_DECL_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DECL_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DECL_S;
   
  function	MAKE_DSCRMT_DECL_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DSCRMT_DECL_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DSCRMT_DECL_S;
   
  function	MAKE_GENERAL_ASSOC_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_GENERAL_ASSOC_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_GENERAL_ASSOC_S;
   
  function	MAKE_DISCRETE_RANGE_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DISCRETE_RANGE_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DISCRETE_RANGE_S;
   
  function	MAKE_ENUM_LITERAL_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENUM_LITERAL_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ENUM_LITERAL_S;
   
  function	MAKE_EXP_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_EXP_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_EXP_S;
   
  function	MAKE_ITEM_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ITEM_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ITEM_S;
   
  function	MAKE_INDEX_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INDEX_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_INDEX_S;
   
  function	MAKE_NAME_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NAME_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NAME_S;
   
  function	MAKE_PARAM_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PARAM_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_PARAM_S;
   
  function	MAKE_PRAGMA_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PRAGMA_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_PRAGMA_S;
   
  function	MAKE_SCALAR_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SCALAR_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SCALAR_S;
   
  function	MAKE_SOURCE_NAME_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SOURCE_NAME_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SOURCE_NAME_S;
   
  function	MAKE_STM_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_STM_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_STM_S;
   
  function	MAKE_TEST_CLAUSE_ELEM_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TEST_CLAUSE_ELEM_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TEST_CLAUSE_ELEM_S;
   
  function	MAKE_USE_PRAGMA_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USE_PRAGMA_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_USE_PRAGMA_S;
   
  function	MAKE_VARIANT_S
		    ( LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_VARIANT_S );
  begin
         IDL_MAN.LIST(NODE, LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_VARIANT_S;
   
  function	MAKE_LABELED
		    ( AS_SOURCE_NAME_S :TREE := TREE_VOID;
		    AS_PRAGMA_S :TREE := TREE_VOID;
		    AS_STM :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_LABELED );
  begin
    D( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S );
    D( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S );
    D( DA.AS_STM, NODE, AS_STM );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_LABELED;
   
  function	MAKE_NULL_STM
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NULL_STM );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NULL_STM;
   
  function	MAKE_ABORT
		    ( AS_NAME_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ABORT );
  begin
    D( DA.AS_NAME_S, NODE, AS_NAME_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ABORT;
   
  function	MAKE_RETURN
		    ( AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RETURN );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RETURN;
   
  function	MAKE_DELAY
		    ( AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DELAY );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DELAY;
   
  function	MAKE_ASSIGN
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ASSIGN );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ASSIGN;
   
  function	MAKE_EXIT
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_STM :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_EXIT );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_STM, NODE, SM_STM );
         return NODE;
  end	MAKE_EXIT;
   
  function	MAKE_CODE
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CODE );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CODE;
   
  function	MAKE_CASE
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_ALTERNATIVE_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CASE );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_ALTERNATIVE_S, NODE, AS_ALTERNATIVE_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CASE;
   
  function	MAKE_GOTO
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_GOTO );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_GOTO;
   
  function	MAKE_RAISE
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RAISE );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RAISE;
   
  function	MAKE_ENTRY_CALL
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_NORMALIZED_PARAM_S :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENTRY_CALL );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S );
         return NODE;
  end	MAKE_ENTRY_CALL;
   
  function	MAKE_PROCEDURE_CALL
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_NORMALIZED_PARAM_S :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PROCEDURE_CALL );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S );
         return NODE;
  end	MAKE_PROCEDURE_CALL;
   
  function	MAKE_ACCEPT
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_PARAM_S :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ACCEPT );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_PARAM_S, NODE, AS_PARAM_S );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ACCEPT;
   
  function	MAKE_LOOP
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_ITERATION :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_LOOP );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_ITERATION, NODE, AS_ITERATION );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_LOOP;
   
  function	MAKE_BLOCK
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_BLOCK_body :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_BLOCK );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_BLOCK_body, NODE, AS_BLOCK_body );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_BLOCK;
   
  function	MAKE_COND_ENTRY
		    ( AS_STM_S1 :TREE := TREE_VOID;
		    AS_STM_S2 :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COND_ENTRY );
  begin
    D( DA.AS_STM_S1, NODE, AS_STM_S1 );
    D( DA.AS_STM_S2, NODE, AS_STM_S2 );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COND_ENTRY;
   
  function	MAKE_TIMED_ENTRY
		    ( AS_STM_S1 :TREE := TREE_VOID;
		    AS_STM_S2 :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TIMED_ENTRY );
  begin
    D( DA.AS_STM_S1, NODE, AS_STM_S1 );
    D( DA.AS_STM_S2, NODE, AS_STM_S2 );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TIMED_ENTRY;
   
  function	MAKE_IF
		    ( AS_TEST_CLAUSE_ELEM_S :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_IF );
  begin
    D( DA.AS_TEST_CLAUSE_ELEM_S, NODE, AS_TEST_CLAUSE_ELEM_S );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_IF;
   
  function	MAKE_SELECTIVE_WAIT
		    ( AS_TEST_CLAUSE_ELEM_S :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SELECTIVE_WAIT );
  begin
    D( DA.AS_TEST_CLAUSE_ELEM_S, NODE, AS_TEST_CLAUSE_ELEM_S );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SELECTIVE_WAIT;
   
  function	MAKE_TERMINATE
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TERMINATE );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_TERMINATE;
   
  function	MAKE_STM_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_STM_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_STM_PRAGMA;
   
  function	MAKE_NAMED
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_CHOICE_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NAMED );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_CHOICE_S, NODE, AS_CHOICE_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NAMED;
   
  function	MAKE_ASSOC
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_USED_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ASSOC );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_USED_NAME, NODE, AS_USED_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ASSOC;
   
  function	MAKE_USED_CHAR
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_DEFN :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USED_CHAR );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_DEFN, NODE, SM_DEFN );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_USED_CHAR;
   
  function	MAKE_USED_OBJECT_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_DEFN :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USED_OBJECT_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_DEFN, NODE, SM_DEFN );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_USED_OBJECT_ID;
   
  function	MAKE_USED_OP
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_DEFN :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USED_OP );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_DEFN, NODE, SM_DEFN );
         return NODE;
  end	MAKE_USED_OP;
   
  function	MAKE_USED_NAME_ID
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_DEFN :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_USED_NAME_ID );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_DEFN, NODE, SM_DEFN );
         return NODE;
  end	MAKE_USED_NAME_ID;
   
  function	MAKE_ATTRIBUTE
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_USED_NAME_ID :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ATTRIBUTE );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_ATTRIBUTE;
   
  function	MAKE_SELECTED
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_DESIGNATOR :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SELECTED );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_DESIGNATOR, NODE, AS_DESIGNATOR );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_SELECTED;
   
  function	MAKE_FUNCTION_CALL
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    LX_PREFIX :BOOLEAN := FALSE;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID;
		    SM_NORMALIZED_PARAM_S :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FUNCTION_CALL );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    DB( DA.LX_PREFIX, NODE, LX_PREFIX );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
    D( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S );
         return NODE;
  end	MAKE_FUNCTION_CALL;
   
  function	MAKE_INDEXED
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_EXP_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INDEXED );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP_S, NODE, AS_EXP_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
         return NODE;
  end	MAKE_INDEXED;
   
  function	MAKE_SLICE
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_DISCRETE_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SLICE );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
         return NODE;
  end	MAKE_SLICE;
   
  function	MAKE_ALL
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ALL );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
         return NODE;
  end	MAKE_ALL;
   
  function	MAKE_SHORT_CIRCUIT
		    ( AS_EXP1 :TREE := TREE_VOID;
		    AS_SHORT_CIRCUIT_OP :TREE := TREE_VOID;
		    AS_EXP2 :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SHORT_CIRCUIT );
  begin
    D( DA.AS_EXP1, NODE, AS_EXP1 );
    D( DA.AS_SHORT_CIRCUIT_OP, NODE, AS_SHORT_CIRCUIT_OP );
    D( DA.AS_EXP2, NODE, AS_EXP2 );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_SHORT_CIRCUIT;
   
  function	MAKE_NUMERIC_LITERAL
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_NUMREP :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NUMERIC_LITERAL );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_NUMREP, NODE, LX_NUMREP );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_NUMERIC_LITERAL;
   
  function	MAKE_NULL_ACCESS
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NULL_ACCESS );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_NULL_ACCESS;
   
  function	MAKE_RANGE_MEMBERSHIP
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_MEMBERSHIP_OP :TREE := TREE_VOID;
		    AS_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RANGE_MEMBERSHIP );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_MEMBERSHIP_OP, NODE, AS_MEMBERSHIP_OP );
    D( DA.AS_RANGE, NODE, AS_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_RANGE_MEMBERSHIP;
   
  function	MAKE_TYPE_MEMBERSHIP
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_MEMBERSHIP_OP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TYPE_MEMBERSHIP );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_MEMBERSHIP_OP, NODE, AS_MEMBERSHIP_OP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_TYPE_MEMBERSHIP;
   
  function	MAKE_CONVERSION
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONVERSION );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_CONVERSION;
   
  function	MAKE_QUALIFIED
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_QUALIFIED );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_QUALIFIED;
   
  function	MAKE_PARENTHESIZED
		    ( AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_VALUE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PARENTHESIZED );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_VALUE, NODE, SM_VALUE );
         return NODE;
  end	MAKE_PARENTHESIZED;
   
  function	MAKE_AGGREGATE
		    ( AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_DISCRETE_RANGE :TREE := TREE_VOID;
		    SM_NORMALIZED_COMP_S :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_AGGREGATE );
  begin
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_DISCRETE_RANGE, NODE, SM_DISCRETE_RANGE );
    D( DA.SM_NORMALIZED_COMP_S, NODE, SM_NORMALIZED_COMP_S );
         return NODE;
  end	MAKE_AGGREGATE;
   
  function	MAKE_STRING_LITERAL
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    LX_SYMREP :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_DISCRETE_RANGE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_STRING_LITERAL );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.LX_SYMREP, NODE, LX_SYMREP );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_DISCRETE_RANGE, NODE, SM_DISCRETE_RANGE );
         return NODE;
  end	MAKE_STRING_LITERAL;
   
  function	MAKE_QUALIFIED_ALLOCATOR
		    ( AS_QUALIFIED :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_QUALIFIED_ALLOCATOR );
  begin
    D( DA.AS_QUALIFIED, NODE, AS_QUALIFIED );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
         return NODE;
  end	MAKE_QUALIFIED_ALLOCATOR;
   
  function	MAKE_SUBTYPE_ALLOCATOR
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_EXP_TYPE :TREE := TREE_VOID;
		    SM_DESIG_TYPE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SUBTYPE_ALLOCATOR );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE );
    D( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE );
         return NODE;
  end	MAKE_SUBTYPE_ALLOCATOR;
   
  function	MAKE_RANGE
		    ( AS_EXP1 :TREE := TREE_VOID;
		    AS_EXP2 :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RANGE );
  begin
    D( DA.AS_EXP1, NODE, AS_EXP1 );
    D( DA.AS_EXP2, NODE, AS_EXP2 );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
         return NODE;
  end	MAKE_RANGE;
   
  function	MAKE_RANGE_ATTRIBUTE
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_USED_NAME_ID :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RANGE_ATTRIBUTE );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
         return NODE;
  end	MAKE_RANGE_ATTRIBUTE;
   
  function	MAKE_DISCRETE_SUBTYPE
		    ( AS_SUBTYPE_INDICATION :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DISCRETE_SUBTYPE );
  begin
    D( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DISCRETE_SUBTYPE;
   
  function	MAKE_FLOAT_CONSTRAINT
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FLOAT_CONSTRAINT );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_RANGE, NODE, AS_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
         return NODE;
  end	MAKE_FLOAT_CONSTRAINT;
   
  function	MAKE_FIXED_CONSTRAINT
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FIXED_CONSTRAINT );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_RANGE, NODE, AS_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
         return NODE;
  end	MAKE_FIXED_CONSTRAINT;
   
  function	MAKE_INDEX_CONSTRAINT
		    ( AS_DISCRETE_RANGE_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INDEX_CONSTRAINT );
  begin
    D( DA.AS_DISCRETE_RANGE_S, NODE, AS_DISCRETE_RANGE_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_INDEX_CONSTRAINT;
   
  function	MAKE_DSCRMT_CONSTRAINT
		    ( AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DSCRMT_CONSTRAINT );
  begin
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_DSCRMT_CONSTRAINT;
   
  function	MAKE_CHOICE_EXP
		    ( AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CHOICE_EXP );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CHOICE_EXP;
   
  function	MAKE_CHOICE_RANGE
		    ( AS_DISCRETE_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CHOICE_RANGE );
  begin
    D( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CHOICE_RANGE;
   
  function	MAKE_CHOICE_OTHERS
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CHOICE_OTHERS );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CHOICE_OTHERS;
   
  function	MAKE_PROCEDURE_SPEC
		    ( AS_PARAM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PROCEDURE_SPEC );
  begin
    D( DA.AS_PARAM_S, NODE, AS_PARAM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_PROCEDURE_SPEC;
   
  function	MAKE_FUNCTION_SPEC
		    ( AS_PARAM_S :TREE := TREE_VOID;
		    AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FUNCTION_SPEC );
  begin
    D( DA.AS_PARAM_S, NODE, AS_PARAM_S );
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FUNCTION_SPEC;
   
  function	MAKE_ENTRY
		    ( AS_PARAM_S :TREE := TREE_VOID;
		    AS_DISCRETE_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ENTRY );
  begin
    D( DA.AS_PARAM_S, NODE, AS_PARAM_S );
    D( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ENTRY;
   
  function	MAKE_package_SPEC
		    ( AS_DECL_S1 :TREE := TREE_VOID;
		    AS_DECL_S2 :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    XD_body_IS_REQUIRED :BOOLEAN := FALSE )
		    return TREE is
         NODE :TREE := MAKE( DN_package_SPEC );
  begin
    D( DA.AS_DECL_S1, NODE, AS_DECL_S1 );
    D( DA.AS_DECL_S2, NODE, AS_DECL_S2 );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_package_SPEC;
   
  function	MAKE_RENAMES_UNIT
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RENAMES_UNIT );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_RENAMES_UNIT;
   
  function	MAKE_INSTANTIATION
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_GENERAL_ASSOC_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_DECL_S :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INSTANTIATION );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_DECL_S, NODE, SM_DECL_S );
         return NODE;
  end	MAKE_INSTANTIATION;
   
  function	MAKE_NAME_DEFAULT
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NAME_DEFAULT );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NAME_DEFAULT;
   
  function	MAKE_BOX_DEFAULT
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_BOX_DEFAULT );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_BOX_DEFAULT;
   
  function	MAKE_NO_DEFAULT
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NO_DEFAULT );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NO_DEFAULT;
   
  function	MAKE_BLOCK_body
		    ( AS_ITEM_S :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    AS_ALTERNATIVE_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_BLOCK_body );
  begin
    D( DA.AS_ITEM_S, NODE, AS_ITEM_S );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.AS_ALTERNATIVE_S, NODE, AS_ALTERNATIVE_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_BLOCK_body;
   
  function	MAKE_STUB
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_STUB );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_STUB;
   
  function	MAKE_IMPLICIT_NOT_EQ
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    SM_EQUAL :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_IMPLICIT_NOT_EQ );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_EQUAL, NODE, SM_EQUAL );
         return NODE;
  end	MAKE_IMPLICIT_NOT_EQ;
   
  function	MAKE_DERIVED_SUBPROG
		    ( LX_SRCPOS :TREE := TREE_VOID;
		    SM_DERIVABLE :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_DERIVED_SUBPROG );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_DERIVABLE, NODE, SM_DERIVABLE );
         return NODE;
  end	MAKE_DERIVED_SUBPROG;
   
  function	MAKE_COND_CLAUSE
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COND_CLAUSE );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COND_CLAUSE;
   
  function	MAKE_SELECT_ALTERNATIVE
		    ( AS_EXP :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SELECT_ALTERNATIVE );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SELECT_ALTERNATIVE;
   
  function	MAKE_SELECT_ALT_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_SELECT_ALT_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_SELECT_ALT_PRAGMA;
   
  function	MAKE_IN_OP
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_IN_OP );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_IN_OP;
   
  function	MAKE_NOT_IN
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_NOT_IN );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_NOT_IN;
   
  function	MAKE_AND_THEN
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_AND_THEN );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_AND_THEN;
   
  function	MAKE_OR_ELSE
		    ( LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_OR_ELSE );
  begin
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_OR_ELSE;
   
  function	MAKE_FOR
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_DISCRETE_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FOR );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_FOR;
   
  function	MAKE_REVERSE
		    ( AS_SOURCE_NAME :TREE := TREE_VOID;
		    AS_DISCRETE_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_REVERSE );
  begin
    D( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME );
    D( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_REVERSE;
   
  function	MAKE_WHILE
		    ( AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_WHILE );
  begin
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_WHILE;
   
  function	MAKE_ALTERNATIVE
		    ( AS_CHOICE_S :TREE := TREE_VOID;
		    AS_STM_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ALTERNATIVE );
  begin
    D( DA.AS_CHOICE_S, NODE, AS_CHOICE_S );
    D( DA.AS_STM_S, NODE, AS_STM_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ALTERNATIVE;
   
  function	MAKE_ALTERNATIVE_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ALTERNATIVE_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ALTERNATIVE_PRAGMA;
   
  function	MAKE_COMP_REP
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    AS_RANGE :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMP_REP );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.AS_RANGE, NODE, AS_RANGE );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMP_REP;
   
  function	MAKE_COMP_REP_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMP_REP_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMP_REP_PRAGMA;
   
  function	MAKE_CONTEXT_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONTEXT_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_CONTEXT_PRAGMA;
   
  function	MAKE_WITH
		    ( AS_NAME_S :TREE := TREE_VOID;
		    AS_USE_PRAGMA_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_WITH );
  begin
    D( DA.AS_NAME_S, NODE, AS_NAME_S );
    D( DA.AS_USE_PRAGMA_S, NODE, AS_USE_PRAGMA_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_WITH;
   
  function	MAKE_VARIANT
		    ( AS_CHOICE_S :TREE := TREE_VOID;
		    AS_COMP_LIST :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_VARIANT );
  begin
    D( DA.AS_CHOICE_S, NODE, AS_CHOICE_S );
    D( DA.AS_COMP_LIST, NODE, AS_COMP_LIST );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_VARIANT;
   
  function	MAKE_VARIANT_PRAGMA
		    ( AS_PRAGMA :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_VARIANT_PRAGMA );
  begin
    D( DA.AS_PRAGMA, NODE, AS_PRAGMA );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_VARIANT_PRAGMA;
   
  function	MAKE_ALIGNMENT
		    ( AS_PRAGMA_S :TREE := TREE_VOID;
		    AS_EXP :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ALIGNMENT );
  begin
    D( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S );
    D( DA.AS_EXP, NODE, AS_EXP );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_ALIGNMENT;
   
  function	MAKE_VARIANT_PART
		    ( AS_NAME :TREE := TREE_VOID;
		    AS_VARIANT_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_VARIANT_PART );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.AS_VARIANT_S, NODE, AS_VARIANT_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_VARIANT_PART;
   
  function	MAKE_COMP_LIST
		    ( AS_DECL_S :TREE := TREE_VOID;
		    AS_VARIANT_PART :TREE := TREE_VOID;
		    AS_PRAGMA_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMP_LIST );
  begin
    D( DA.AS_DECL_S, NODE, AS_DECL_S );
    D( DA.AS_VARIANT_PART, NODE, AS_VARIANT_PART );
    D( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMP_LIST;
   
  function	MAKE_COMPILATION
		    ( AS_COMPLTN_UNIT_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMPILATION );
  begin
    D( DA.AS_COMPLTN_UNIT_S, NODE, AS_COMPLTN_UNIT_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         return NODE;
  end	MAKE_COMPILATION;
   
  function	MAKE_COMPILATION_UNIT
		    ( AS_CONTEXT_ELEM_S :TREE := TREE_VOID;
		    AS_ALL_DECL :TREE := TREE_VOID;
		    AS_PRAGMA_S :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    XD_TIMESTAMP :INTEGER := 0;
		    LIST :SEQ_TYPE := (TREE_NIL,TREE_NIL );
		    XD_NBR_PAGES :INTEGER := 0;
		    XD_LIB_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_COMPILATION_UNIT );
  begin
    D( DA.AS_CONTEXT_ELEM_S, NODE, AS_CONTEXT_ELEM_S );
    D( DA.AS_ALL_DECL, NODE, AS_ALL_DECL );
    D( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         DI (DA.XD_TIMESTAMP, NODE, XD_TIMESTAMP );
         IDL_MAN.LIST(NODE, LIST );
         DI (DA.XD_NBR_PAGES, NODE, XD_NBR_PAGES );
    D( DA.XD_LIB_NAME, NODE, XD_LIB_NAME );
         return NODE;
  end	MAKE_COMPILATION_UNIT;
   
  function	MAKE_INDEX
		    ( AS_NAME :TREE := TREE_VOID;
		    LX_SRCPOS :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INDEX );
  begin
    D( DA.AS_NAME, NODE, AS_NAME );
    D( DA.LX_SRCPOS, NODE, LX_SRCPOS );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
         return NODE;
  end	MAKE_INDEX;
   
  function	MAKE_TASK_SPEC
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_DECL_S :TREE := TREE_VOID;
		    SM_body :TREE := TREE_VOID;
		    SM_ADDRESS :TREE := TREE_VOID;
		    SM_SIZE :TREE := TREE_VOID;
		    SM_STORAGE_SIZE :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID;
		    XD_STUB :TREE := TREE_VOID;
		    XD_body :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_TASK_SPEC );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_DECL_S, NODE, SM_DECL_S );
    D( DA.SM_body, NODE, SM_body );
    D( DA.SM_ADDRESS, NODE, SM_ADDRESS );
    D( DA.SM_SIZE, NODE, SM_SIZE );
    D( DA.SM_STORAGE_SIZE, NODE, SM_STORAGE_SIZE );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
    D( DA.XD_STUB, NODE, XD_STUB );
    D( DA.XD_body, NODE, XD_body );
         return NODE;
  end	MAKE_TASK_SPEC;
   
  function	MAKE_ENUMERATION
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_RANGE :TREE := TREE_VOID;
		    SM_LITERAL_S :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID;
		    CD_IMPL_SIZE :INTEGER := 0 )
		    return TREE is
         NODE :TREE := MAKE( DN_ENUMERATION );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_RANGE, NODE, SM_RANGE );
    D( DA.SM_LITERAL_S, NODE, SM_LITERAL_S );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE );
         return NODE;
  end	MAKE_ENUMERATION;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_INTEGER
  function	MAKE_INTEGER ( SM_DERIVED, SM_BASE_TYPE, SM_RANGE, XD_SOURCE_NAME :TREE := TREE_VOID;
          		CD_IMPL_SIZE :INTEGER := 0; SM_IS_ANONYMOUS :BOOLEAN := FALSE
                	 ) return TREE is
         NODE	 :TREE := MAKE( DN_INTEGER  );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_RANGE, NODE, SM_RANGE );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE );
         return NODE;
  end;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_FLOAT
  function	MAKE_FLOAT
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_RANGE :TREE := TREE_VOID;
		    SM_ACCURACY :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID;
		    CD_IMPL_SIZE :INTEGER := 0 )
		    return TREE is
         NODE :TREE := MAKE( DN_FLOAT );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_RANGE, NODE, SM_RANGE );
    D( DA.SM_ACCURACY, NODE, SM_ACCURACY );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE );
         return NODE;
  end	MAKE_FLOAT;
   
  function	MAKE_FIXED
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_RANGE :TREE := TREE_VOID;
		    SM_ACCURACY :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID;
		    CD_IMPL_SIZE :INTEGER := 0;
		    CD_IMPL_SMALL :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_FIXED );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_RANGE, NODE, SM_RANGE );
    D( DA.SM_ACCURACY, NODE, SM_ACCURACY );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE );
    D( DA.CD_IMPL_SMALL, NODE, CD_IMPL_SMALL );
         return NODE;
  end	MAKE_FIXED;
   
  function	MAKE_ARRAY
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_SIZE :TREE := TREE_VOID;
		    SM_IS_LIMITED :BOOLEAN := FALSE;
		    SM_IS_PACKED :BOOLEAN := FALSE;
		    SM_INDEX_S :TREE := TREE_VOID;
		    SM_COMP_TYPE :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ARRAY );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_SIZE, NODE, SM_SIZE );
    DB( DA.SM_IS_LIMITED, NODE, SM_IS_LIMITED );
    DB( DA.SM_IS_PACKED, NODE, SM_IS_PACKED );
    D( DA.SM_INDEX_S, NODE, SM_INDEX_S );
    D( DA.SM_COMP_TYPE, NODE, SM_COMP_TYPE );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_ARRAY;
   
  function	MAKE_RECORD
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_SIZE :TREE := TREE_VOID;
		    SM_IS_LIMITED :BOOLEAN := FALSE;
		    SM_IS_PACKED :BOOLEAN := FALSE;
		    SM_DISCRIMINANT_S :TREE := TREE_VOID;
		    SM_COMP_LIST :TREE := TREE_VOID;
		    SM_REPRESENTATION :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_RECORD );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_SIZE, NODE, SM_SIZE );
    DB( DA.SM_IS_LIMITED, NODE, SM_IS_LIMITED );
    DB( DA.SM_IS_PACKED, NODE, SM_IS_PACKED );
    D( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S );
    D( DA.SM_COMP_LIST, NODE, SM_COMP_LIST );
    D( DA.SM_REPRESENTATION, NODE, SM_REPRESENTATION );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_RECORD;
   
  function	MAKE_ACCESS
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_SIZE :TREE := TREE_VOID;
		    SM_STORAGE_SIZE :TREE := TREE_VOID;
		    SM_IS_CONTROLLED :BOOLEAN := FALSE;
		    SM_DESIG_TYPE :TREE := TREE_VOID;
		    SM_MASTER :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_ACCESS );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    D( DA.SM_SIZE, NODE, SM_SIZE );
    D( DA.SM_STORAGE_SIZE, NODE, SM_STORAGE_SIZE );
    DB( DA.SM_IS_CONTROLLED, NODE, SM_IS_CONTROLLED );
    D( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE );
    D( DA.SM_MASTER, NODE, SM_MASTER );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_ACCESS;
   
  function	MAKE_CONSTRAINED_ARRAY
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_DEPENDS_ON_DSCRMT :BOOLEAN := FALSE;
		    SM_INDEX_SUBTYPE_S :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONSTRAINED_ARRAY );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED  );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS  );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE  );
    DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT  );
    D( DA.SM_INDEX_SUBTYPE_S, NODE, SM_INDEX_SUBTYPE_S  );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME  );
    DB( DA.CD_COMPILED, NODE, FALSE  );
         return NODE;
  end	MAKE_CONSTRAINED_ARRAY;
   
  function	MAKE_CONSTRAINED_RECORD
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_DEPENDS_ON_DSCRMT :BOOLEAN := FALSE;
		    SM_NORMALIZED_DSCRMT_S :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONSTRAINED_RECORD );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT );
    D( DA.SM_NORMALIZED_DSCRMT_S, NODE, SM_NORMALIZED_DSCRMT_S );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_CONSTRAINED_RECORD;
   
  function	MAKE_CONSTRAINED_ACCESS
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_BASE_TYPE :TREE := TREE_VOID;
		    SM_DEPENDS_ON_DSCRMT :BOOLEAN := FALSE;
		    SM_DESIG_TYPE :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_CONSTRAINED_ACCESS );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE );
    DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT );
    D( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_CONSTRAINED_ACCESS;
   
  function	MAKE_PRIVATE
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_DISCRIMINANT_S :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_PRIVATE );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_PRIVATE;
   
  function	MAKE_L_PRIVATE
		    ( SM_DERIVED :TREE := TREE_VOID;
		    SM_IS_ANONYMOUS :BOOLEAN := FALSE;
		    SM_DISCRIMINANT_S :TREE := TREE_VOID;
		    SM_TYPE_SPEC :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_L_PRIVATE );
  begin
    D( DA.SM_DERIVED, NODE, SM_DERIVED );
    DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS );
    D( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S );
    D( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_L_PRIVATE;
   
  function	MAKE_INCOMPLETE
		    ( SM_DISCRIMINANT_S :TREE := TREE_VOID;
		    XD_SOURCE_NAME :TREE := TREE_VOID;
		    XD_FULL_TYPE_SPEC :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_INCOMPLETE );
  begin
    D( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S );
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
    D( DA.XD_FULL_TYPE_SPEC, NODE, XD_FULL_TYPE_SPEC );
         return NODE;
  end	MAKE_INCOMPLETE;
   
  function	MAKE_UNIVERSAL_INTEGER
		    ( XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_UNIVERSAL_INTEGER );
  begin
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_UNIVERSAL_INTEGER;
   
  function	MAKE_UNIVERSAL_FIXED
		    ( XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_UNIVERSAL_FIXED );
  begin
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_UNIVERSAL_FIXED;
   
  function	MAKE_UNIVERSAL_REAL
		    ( XD_SOURCE_NAME :TREE := TREE_VOID )
		    return TREE is
         NODE :TREE := MAKE( DN_UNIVERSAL_REAL );
  begin
    D( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME );
         return NODE;
  end	MAKE_UNIVERSAL_REAL;
   

end		MAKE_NOD;
		--------

--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
