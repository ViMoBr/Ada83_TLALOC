SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	MAKE_NOD
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY MAKE_NOD IS
   
       PACKAGE DA RENAMES DIANA_NODE_ATTR_CLASS_NAMES;
   
       FUNCTION MAKE_VARIABLE_ID
	             ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_RENAMES_OBJ: BOOLEAN := FALSE;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_IS_SHARED: BOOLEAN := FALSE;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIABLE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         DB( DA.SM_RENAMES_OBJ, NODE, SM_RENAMES_OBJ);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         DB( DA.SM_IS_SHARED, NODE, SM_IS_SHARED);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_VARIABLE_ID;
   
       FUNCTION MAKE_CONSTANT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_RENAMES_OBJ: BOOLEAN := FALSE;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTANT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         DB( DA.SM_RENAMES_OBJ, NODE, SM_RENAMES_OBJ);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_CONSTANT_ID;
   
       FUNCTION MAKE_NUMBER_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NUMBER_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_NUMBER_ID;
   
       FUNCTION MAKE_COMPONENT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_COMP_REP: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMPONENT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.SM_COMP_REP, NODE, SM_COMP_REP);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_COMPONENT_ID;
   
       FUNCTION MAKE_DISCRIMINANT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_COMP_REP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DISCRIMINANT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.SM_COMP_REP, NODE, SM_COMP_REP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_DISCRIMINANT_ID;
   
       FUNCTION MAKE_IN_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IN_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_IN_ID;
   
       FUNCTION MAKE_IN_OUT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IN_OUT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_IN_OUT_ID;
   
       FUNCTION MAKE_OUT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_INIT_EXP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_OUT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.SM_INIT_EXP, NODE, SM_INIT_EXP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_OUT_ID;
   
       FUNCTION MAKE_ENUMERATION_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_POS: INTEGER := 0;
                        SM_REP: INTEGER := 0;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENUMERATION_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         DI (DA.SM_POS, NODE, SM_POS);
         DI (DA.SM_REP, NODE, SM_REP);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_ENUMERATION_ID;
   
       FUNCTION MAKE_CHARACTER_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        SM_POS: INTEGER := 0;
                        SM_REP: INTEGER := 0;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CHARACTER_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         DI (DA.SM_POS, NODE, SM_POS);
         DI (DA.SM_REP, NODE, SM_REP);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_CHARACTER_ID;
   
       FUNCTION MAKE_ITERATION_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_OBJ_TYPE: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ITERATION_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_OBJ_TYPE, NODE, SM_OBJ_TYPE);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_ITERATION_ID;
   
       FUNCTION MAKE_TYPE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TYPE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_TYPE_ID;
   
       FUNCTION MAKE_SUBTYPE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBTYPE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_SUBTYPE_ID;
   
       FUNCTION MAKE_PRIVATE_TYPE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PRIVATE_TYPE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_PRIVATE_TYPE_ID;
   
       FUNCTION MAKE_L_PRIVATE_TYPE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_L_PRIVATE_TYPE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_L_PRIVATE_TYPE_ID;
   
       FUNCTION MAKE_PROCEDURE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_UNIT_DESC: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_IS_INLINE: BOOLEAN := FALSE;
                        SM_INTERFACE: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID;
                        XD_STUB: TREE := TREE_VOID;
                        XD_BODY: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PROCEDURE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE);
         D ( DA.SM_INTERFACE, NODE, SM_INTERFACE);
         D ( DA.XD_REGION, NODE, XD_REGION);
         D ( DA.XD_STUB, NODE, XD_STUB);
         D ( DA.XD_BODY, NODE, XD_BODY);
         RETURN NODE;
      END MAKE_PROCEDURE_ID;
   
       FUNCTION MAKE_FUNCTION_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_UNIT_DESC: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_IS_INLINE: BOOLEAN := FALSE;
                        SM_INTERFACE: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID;
                        XD_STUB: TREE := TREE_VOID;
                        XD_BODY: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FUNCTION_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE);
         D ( DA.SM_INTERFACE, NODE, SM_INTERFACE);
         D ( DA.XD_REGION, NODE, XD_REGION);
         D ( DA.XD_STUB, NODE, XD_STUB);
         D ( DA.XD_BODY, NODE, XD_BODY);
         RETURN NODE;
      END MAKE_FUNCTION_ID;
   
       FUNCTION MAKE_OPERATOR_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_UNIT_DESC: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_IS_INLINE: BOOLEAN := FALSE;
                        SM_INTERFACE: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID;
                        XD_STUB: TREE := TREE_VOID;
                        XD_BODY: TREE := TREE_VOID;
                        XD_NOT_EQUAL: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_OPERATOR_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE);
         D ( DA.SM_INTERFACE, NODE, SM_INTERFACE);
         D ( DA.XD_REGION, NODE, XD_REGION);
         D ( DA.XD_STUB, NODE, XD_STUB);
         D ( DA.XD_BODY, NODE, XD_BODY);
         D ( DA.XD_NOT_EQUAL, NODE, XD_NOT_EQUAL);
         RETURN NODE;
      END MAKE_OPERATOR_ID;
   
       FUNCTION MAKE_PACKAGE_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_UNIT_DESC: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID;
                        XD_STUB: TREE := TREE_VOID;
                        XD_BODY: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PACKAGE_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_UNIT_DESC, NODE, SM_UNIT_DESC);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         D ( DA.XD_REGION, NODE, XD_REGION);
         D ( DA.XD_STUB, NODE, XD_STUB);
         D ( DA.XD_BODY, NODE, XD_BODY);
         RETURN NODE;
      END MAKE_PACKAGE_ID;
   
       FUNCTION MAKE_GENERIC_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_GENERIC_PARAM_S: TREE := TREE_VOID;
                        SM_BODY: TREE := TREE_VOID;
                        SM_IS_INLINE: BOOLEAN := FALSE;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_GENERIC_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_GENERIC_PARAM_S, NODE, SM_GENERIC_PARAM_S);
         D ( DA.SM_BODY, NODE, SM_BODY);
         DB( DA.SM_IS_INLINE, NODE, SM_IS_INLINE);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_GENERIC_ID;
   
       FUNCTION MAKE_TASK_BODY_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_FIRST: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        SM_BODY: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TASK_BODY_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_FIRST, NODE, SM_FIRST);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.SM_BODY, NODE, SM_BODY);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_TASK_BODY_ID;
   
       FUNCTION MAKE_LABEL_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_STM: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_LABEL_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_STM, NODE, SM_STM);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_LABEL_ID;
   
       FUNCTION MAKE_BLOCK_LOOP_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_STM: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_BLOCK_LOOP_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_STM, NODE, SM_STM);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_BLOCK_LOOP_ID;
   
       FUNCTION MAKE_ENTRY_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_SPEC: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        XD_REGION: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENTRY_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_SPEC, NODE, SM_SPEC);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_ENTRY_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_EXCEPTION_ID
       FUNCTION MAKE_EXCEPTION_ID ( LX_SRCPOS, LX_SYMREP, SM_RENAMES_EXC, XD_REGION :TREE := TREE_VOID ) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_EXCEPTION_ID );
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_RENAMES_EXC, NODE, SM_RENAMES_EXC);
         D ( DA.XD_REGION, NODE, XD_REGION);
         RETURN NODE;
      END MAKE_EXCEPTION_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_ATTRIBUTE_ID
       FUNCTION MAKE_ATTRIBUTE_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER ) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_ATTRIBUTE_ID );
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         D ( DA.LX_SYMREP, NODE, LX_SYMREP );
         DI ( DA.XD_POS,   NODE, XD_POS );
         RETURN NODE;
      END MAKE_ATTRIBUTE_ID;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_PRAGMA_ID
       FUNCTION MAKE_PRAGMA_ID ( LX_SRCPOS, LX_SYMREP, SM_ARGUMENT_ID_S :TREE := TREE_VOID; XD_POS :INTEGER ) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_PRAGMA_ID );
      BEGIN
         D  ( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         D  ( DA.LX_SYMREP, NODE, LX_SYMREP );
         DI ( DA.XD_POS,    NODE, XD_POS );
         D  ( DA.SM_ARGUMENT_ID_S, NODE, SM_ARGUMENT_ID_S );
         RETURN NODE;
      END;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_ARGUMENT_ID
       FUNCTION MAKE_ARGUMENT_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER ) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_ARGUMENT_ID );
      BEGIN
         D  ( DA.LX_SRCPOS, NODE, LX_SRCPOS );
         D  ( DA.LX_SYMREP, NODE, LX_SYMREP );
         DI ( DA.XD_POS,    NODE, XD_POS );
         RETURN NODE;
      END;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_BLTN_OPERATOR_ID
       FUNCTION MAKE_BLTN_OPERATOR_ID ( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; SM_OPERATOR :INTEGER ) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_BLTN_OPERATOR_ID );
      BEGIN
         D  ( DA.LX_SRCPOS,   NODE, LX_SRCPOS);
         D  ( DA.LX_SYMREP,   NODE, LX_SYMREP);
         DI ( DA.SM_OPERATOR, NODE, SM_OPERATOR);
         RETURN NODE;
      END;
   
       FUNCTION MAKE_BLOCK_MASTER
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        SM_STM: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_BLOCK_MASTER);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_STM, NODE, SM_STM);
         RETURN NODE;
      END MAKE_BLOCK_MASTER;
   
       FUNCTION MAKE_DSCRMT_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DSCRMT_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DSCRMT_DECL;
   
       FUNCTION MAKE_IN
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        LX_DEFAULT: BOOLEAN := FALSE)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IN);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         DB( DA.LX_DEFAULT, NODE, LX_DEFAULT);
         RETURN NODE;
      END MAKE_IN;
   
       FUNCTION MAKE_OUT
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_OUT);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_OUT;
   
       FUNCTION MAKE_IN_OUT
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IN_OUT);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_IN_OUT;
   
       FUNCTION MAKE_CONSTANT_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        AS_TYPE_DEF: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTANT_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CONSTANT_DECL;
   
       FUNCTION MAKE_VARIABLE_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        AS_TYPE_DEF: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIABLE_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_VARIABLE_DECL;
   
       FUNCTION MAKE_NUMBER_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NUMBER_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NUMBER_DECL;
   
       FUNCTION MAKE_EXCEPTION_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_EXCEPTION_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_EXCEPTION_DECL;
   
       FUNCTION MAKE_DEFERRED_CONSTANT_DECL
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DEFERRED_CONSTANT_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DEFERRED_CONSTANT_DECL;
   
       FUNCTION MAKE_TYPE_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_DSCRMT_DECL_S: TREE := TREE_VOID;
                        AS_TYPE_DEF: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TYPE_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_DSCRMT_DECL_S, NODE, AS_DSCRMT_DECL_S);
         D ( DA.AS_TYPE_DEF, NODE, AS_TYPE_DEF);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TYPE_DECL;
   
       FUNCTION MAKE_SUBTYPE_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBTYPE_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SUBTYPE_DECL;
   
       FUNCTION MAKE_TASK_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_DECL_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TASK_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_DECL_S, NODE, AS_DECL_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TASK_DECL;
   
       FUNCTION MAKE_GENERIC_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_HEADER: TREE := TREE_VOID;
                        AS_ITEM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_GENERIC_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_HEADER, NODE, AS_HEADER);
         D ( DA.AS_ITEM_S, NODE, AS_ITEM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_GENERIC_DECL;
   
       FUNCTION MAKE_SUBPROG_ENTRY_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_HEADER: TREE := TREE_VOID;
                        AS_UNIT_KIND: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBPROG_ENTRY_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_HEADER, NODE, AS_HEADER);
         D ( DA.AS_UNIT_KIND, NODE, AS_UNIT_KIND);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SUBPROG_ENTRY_DECL;
   
       FUNCTION MAKE_PACKAGE_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_HEADER: TREE := TREE_VOID;
                        AS_UNIT_KIND: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID )
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PACKAGE_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_HEADER, NODE, AS_HEADER);
         D ( DA.AS_UNIT_KIND, NODE, AS_UNIT_KIND);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PACKAGE_DECL;
   
       FUNCTION MAKE_RENAMES_OBJ_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        AS_TYPE_MARK_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RENAMES_OBJ_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_TYPE_MARK_NAME, NODE, AS_TYPE_MARK_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RENAMES_OBJ_DECL;
   
       FUNCTION MAKE_RENAMES_EXC_DECL
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RENAMES_EXC_DECL);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RENAMES_EXC_DECL;
   
       FUNCTION MAKE_NULL_COMP_DECL
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NULL_COMP_DECL);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NULL_COMP_DECL;
   
       FUNCTION MAKE_LENGTH_ENUM_REP
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_LENGTH_ENUM_REP);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_LENGTH_ENUM_REP;
   
       FUNCTION MAKE_ADDRESS
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ADDRESS);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ADDRESS;
   
       FUNCTION MAKE_RECORD_REP
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_ALIGNMENT_CLAUSE: TREE := TREE_VOID;
                        AS_COMP_REP_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RECORD_REP);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_ALIGNMENT_CLAUSE, NODE, AS_ALIGNMENT_CLAUSE);
         D ( DA.AS_COMP_REP_S, NODE, AS_COMP_REP_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RECORD_REP;
   
       FUNCTION MAKE_USE
                        ( AS_NAME_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USE);
      BEGIN
         D ( DA.AS_NAME_S, NODE, AS_NAME_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_USE;
   
       FUNCTION MAKE_PRAGMA
                        ( AS_USED_NAME_ID: TREE := TREE_VOID;
                        AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PRAGMA);
      BEGIN
         D ( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID);
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PRAGMA;
   
       FUNCTION MAKE_SUBPROGRAM_BODY
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_BODY: TREE := TREE_VOID;
                        AS_HEADER: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBPROGRAM_BODY);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_BODY, NODE, AS_BODY);
         D ( DA.AS_HEADER, NODE, AS_HEADER);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SUBPROGRAM_BODY;
   
       FUNCTION MAKE_PACKAGE_BODY
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_BODY: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PACKAGE_BODY);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_BODY, NODE, AS_BODY);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PACKAGE_BODY;
   
       FUNCTION MAKE_TASK_BODY
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_BODY: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TASK_BODY);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_BODY, NODE, AS_BODY);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TASK_BODY;
   
       FUNCTION MAKE_SUBUNIT
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_SUBUNIT_BODY: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBUNIT);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_SUBUNIT_BODY, NODE, AS_SUBUNIT_BODY);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SUBUNIT;
   
       FUNCTION MAKE_ENUMERATION_DEF
                        ( AS_ENUM_LITERAL_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENUMERATION_DEF);
      BEGIN
         D ( DA.AS_ENUM_LITERAL_S, NODE, AS_ENUM_LITERAL_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ENUMERATION_DEF;
   
       FUNCTION MAKE_SUBTYPE_INDICATION
                        ( AS_CONSTRAINT: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBTYPE_INDICATION);
      BEGIN
         D ( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SUBTYPE_INDICATION;
   
       FUNCTION MAKE_INTEGER_DEF
                        ( AS_CONSTRAINT: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INTEGER_DEF);
      BEGIN
         D ( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_INTEGER_DEF;
   
       FUNCTION MAKE_FLOAT_DEF
                        ( AS_CONSTRAINT: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FLOAT_DEF);
      BEGIN
         D ( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FLOAT_DEF;
   
       FUNCTION MAKE_FIXED_DEF
                        ( AS_CONSTRAINT: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FIXED_DEF);
      BEGIN
         D ( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FIXED_DEF;
   
       FUNCTION MAKE_CONSTRAINED_ARRAY_DEF
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        AS_CONSTRAINT: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTRAINED_ARRAY_DEF);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.AS_CONSTRAINT, NODE, AS_CONSTRAINT);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CONSTRAINED_ARRAY_DEF;
   
       FUNCTION MAKE_UNCONSTRAINED_ARRAY_DEF
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        AS_INDEX_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_UNCONSTRAINED_ARRAY_DEF);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.AS_INDEX_S, NODE, AS_INDEX_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_UNCONSTRAINED_ARRAY_DEF;
   
       FUNCTION MAKE_ACCESS_DEF
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ACCESS_DEF);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ACCESS_DEF;
   
       FUNCTION MAKE_DERIVED_DEF
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL))
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DERIVED_DEF);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         IDL_MAN.LIST(NODE, LIST);
         RETURN NODE;
      END MAKE_DERIVED_DEF;
   
       FUNCTION MAKE_RECORD_DEF
                        ( AS_COMP_LIST: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RECORD_DEF);
      BEGIN
         D ( DA.AS_COMP_LIST, NODE, AS_COMP_LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RECORD_DEF;
   
       FUNCTION MAKE_PRIVATE_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PRIVATE_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PRIVATE_DEF;
   
       FUNCTION MAKE_L_PRIVATE_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_L_PRIVATE_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_L_PRIVATE_DEF;
   
       FUNCTION MAKE_FORMAL_DSCRT_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FORMAL_DSCRT_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FORMAL_DSCRT_DEF;
   
       FUNCTION MAKE_FORMAL_INTEGER_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FORMAL_INTEGER_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FORMAL_INTEGER_DEF;
   
       FUNCTION MAKE_FORMAL_FIXED_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FORMAL_FIXED_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FORMAL_FIXED_DEF;
   
       FUNCTION MAKE_FORMAL_FLOAT_DEF
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FORMAL_FLOAT_DEF);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FORMAL_FLOAT_DEF;
   
       FUNCTION MAKE_ALTERNATIVE_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ALTERNATIVE_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ALTERNATIVE_S;
   
       FUNCTION MAKE_ARGUMENT_ID_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ARGUMENT_ID_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ARGUMENT_ID_S;
   
       FUNCTION MAKE_CHOICE_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CHOICE_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CHOICE_S;
   
       FUNCTION MAKE_COMP_REP_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMP_REP_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMP_REP_S;
   
       FUNCTION MAKE_COMPLTN_UNIT_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMPLTN_UNIT_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMPLTN_UNIT_S;
   
       FUNCTION MAKE_CONTEXT_ELEM_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONTEXT_ELEM_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CONTEXT_ELEM_S;
   
       FUNCTION MAKE_DECL_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DECL_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DECL_S;
   
       FUNCTION MAKE_DSCRMT_DECL_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DSCRMT_DECL_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DSCRMT_DECL_S;
   
       FUNCTION MAKE_GENERAL_ASSOC_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_GENERAL_ASSOC_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_GENERAL_ASSOC_S;
   
       FUNCTION MAKE_DISCRETE_RANGE_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DISCRETE_RANGE_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DISCRETE_RANGE_S;
   
       FUNCTION MAKE_ENUM_LITERAL_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENUM_LITERAL_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ENUM_LITERAL_S;
   
       FUNCTION MAKE_EXP_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_EXP_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_EXP_S;
   
       FUNCTION MAKE_ITEM_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ITEM_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ITEM_S;
   
       FUNCTION MAKE_INDEX_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INDEX_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_INDEX_S;
   
       FUNCTION MAKE_NAME_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NAME_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NAME_S;
   
       FUNCTION MAKE_PARAM_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PARAM_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PARAM_S;
   
       FUNCTION MAKE_PRAGMA_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PRAGMA_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PRAGMA_S;
   
       FUNCTION MAKE_SCALAR_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SCALAR_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SCALAR_S;
   
       FUNCTION MAKE_SOURCE_NAME_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SOURCE_NAME_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SOURCE_NAME_S;
   
       FUNCTION MAKE_STM_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_STM_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_STM_S;
   
       FUNCTION MAKE_TEST_CLAUSE_ELEM_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TEST_CLAUSE_ELEM_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TEST_CLAUSE_ELEM_S;
   
       FUNCTION MAKE_USE_PRAGMA_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USE_PRAGMA_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_USE_PRAGMA_S;
   
       FUNCTION MAKE_VARIANT_S
                        ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIANT_S);
      BEGIN
         IDL_MAN.LIST(NODE, LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_VARIANT_S;
   
       FUNCTION MAKE_LABELED
                        ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                        AS_PRAGMA_S: TREE := TREE_VOID;
                        AS_STM: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_LABELED);
      BEGIN
         D ( DA.AS_SOURCE_NAME_S, NODE, AS_SOURCE_NAME_S);
         D ( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S);
         D ( DA.AS_STM, NODE, AS_STM);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_LABELED;
   
       FUNCTION MAKE_NULL_STM
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NULL_STM);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NULL_STM;
   
       FUNCTION MAKE_ABORT
                        ( AS_NAME_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ABORT);
      BEGIN
         D ( DA.AS_NAME_S, NODE, AS_NAME_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ABORT;
   
       FUNCTION MAKE_RETURN
                        ( AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RETURN);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RETURN;
   
       FUNCTION MAKE_DELAY
                        ( AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DELAY);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DELAY;
   
       FUNCTION MAKE_ASSIGN
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ASSIGN);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ASSIGN;
   
       FUNCTION MAKE_EXIT
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_STM: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_EXIT);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_STM, NODE, SM_STM);
         RETURN NODE;
      END MAKE_EXIT;
   
       FUNCTION MAKE_CODE
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CODE);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CODE;
   
       FUNCTION MAKE_CASE
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_ALTERNATIVE_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CASE);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_ALTERNATIVE_S, NODE, AS_ALTERNATIVE_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CASE;
   
       FUNCTION MAKE_GOTO
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_GOTO);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_GOTO;
   
       FUNCTION MAKE_RAISE
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RAISE);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RAISE;
   
       FUNCTION MAKE_ENTRY_CALL
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENTRY_CALL);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S);
         RETURN NODE;
      END MAKE_ENTRY_CALL;
   
       FUNCTION MAKE_PROCEDURE_CALL
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PROCEDURE_CALL);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S);
         RETURN NODE;
      END MAKE_PROCEDURE_CALL;
   
       FUNCTION MAKE_ACCEPT
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_PARAM_S: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ACCEPT);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_PARAM_S, NODE, AS_PARAM_S);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ACCEPT;
   
       FUNCTION MAKE_LOOP
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_ITERATION: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_LOOP);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_ITERATION, NODE, AS_ITERATION);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_LOOP;
   
       FUNCTION MAKE_BLOCK
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_BLOCK_BODY: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_BLOCK);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_BLOCK_BODY, NODE, AS_BLOCK_BODY);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_BLOCK;
   
       FUNCTION MAKE_COND_ENTRY
                        ( AS_STM_S1: TREE := TREE_VOID;
                        AS_STM_S2: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COND_ENTRY);
      BEGIN
         D ( DA.AS_STM_S1, NODE, AS_STM_S1);
         D ( DA.AS_STM_S2, NODE, AS_STM_S2);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COND_ENTRY;
   
       FUNCTION MAKE_TIMED_ENTRY
                        ( AS_STM_S1: TREE := TREE_VOID;
                        AS_STM_S2: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TIMED_ENTRY);
      BEGIN
         D ( DA.AS_STM_S1, NODE, AS_STM_S1);
         D ( DA.AS_STM_S2, NODE, AS_STM_S2);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TIMED_ENTRY;
   
       FUNCTION MAKE_IF
                        ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IF);
      BEGIN
         D ( DA.AS_TEST_CLAUSE_ELEM_S, NODE, AS_TEST_CLAUSE_ELEM_S);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_IF;
   
       FUNCTION MAKE_SELECTIVE_WAIT
                        ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SELECTIVE_WAIT);
      BEGIN
         D ( DA.AS_TEST_CLAUSE_ELEM_S, NODE, AS_TEST_CLAUSE_ELEM_S);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SELECTIVE_WAIT;
   
       FUNCTION MAKE_TERMINATE
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TERMINATE);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_TERMINATE;
   
       FUNCTION MAKE_STM_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_STM_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_STM_PRAGMA;
   
       FUNCTION MAKE_NAMED
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_CHOICE_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NAMED);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_CHOICE_S, NODE, AS_CHOICE_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NAMED;
   
       FUNCTION MAKE_ASSOC
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_USED_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ASSOC);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_USED_NAME, NODE, AS_USED_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ASSOC;
   
       FUNCTION MAKE_USED_CHAR
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_DEFN: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USED_CHAR);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_DEFN, NODE, SM_DEFN);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_USED_CHAR;
   
       FUNCTION MAKE_USED_OBJECT_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_DEFN: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USED_OBJECT_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_DEFN, NODE, SM_DEFN);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_USED_OBJECT_ID;
   
       FUNCTION MAKE_USED_OP
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_DEFN: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USED_OP);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_DEFN, NODE, SM_DEFN);
         RETURN NODE;
      END MAKE_USED_OP;
   
       FUNCTION MAKE_USED_NAME_ID
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_DEFN: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_USED_NAME_ID);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_DEFN, NODE, SM_DEFN);
         RETURN NODE;
      END MAKE_USED_NAME_ID;
   
       FUNCTION MAKE_ATTRIBUTE
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_USED_NAME_ID: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ATTRIBUTE);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_ATTRIBUTE;
   
       FUNCTION MAKE_SELECTED
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_DESIGNATOR: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SELECTED);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_DESIGNATOR, NODE, AS_DESIGNATOR);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_SELECTED;
   
       FUNCTION MAKE_FUNCTION_CALL
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        LX_PREFIX: BOOLEAN := FALSE;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID;
                        SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FUNCTION_CALL);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         DB( DA.LX_PREFIX, NODE, LX_PREFIX);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         D ( DA.SM_NORMALIZED_PARAM_S, NODE, SM_NORMALIZED_PARAM_S);
         RETURN NODE;
      END MAKE_FUNCTION_CALL;
   
       FUNCTION MAKE_INDEXED
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_EXP_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INDEXED);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP_S, NODE, AS_EXP_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         RETURN NODE;
      END MAKE_INDEXED;
   
       FUNCTION MAKE_SLICE
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_DISCRETE_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SLICE);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         RETURN NODE;
      END MAKE_SLICE;
   
       FUNCTION MAKE_ALL
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ALL);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         RETURN NODE;
      END MAKE_ALL;
   
       FUNCTION MAKE_SHORT_CIRCUIT
                        ( AS_EXP1: TREE := TREE_VOID;
                        AS_SHORT_CIRCUIT_OP: TREE := TREE_VOID;
                        AS_EXP2: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SHORT_CIRCUIT);
      BEGIN
         D ( DA.AS_EXP1, NODE, AS_EXP1);
         D ( DA.AS_SHORT_CIRCUIT_OP, NODE, AS_SHORT_CIRCUIT_OP);
         D ( DA.AS_EXP2, NODE, AS_EXP2);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_SHORT_CIRCUIT;
   
       FUNCTION MAKE_NUMERIC_LITERAL
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_NUMREP: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NUMERIC_LITERAL);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_NUMREP, NODE, LX_NUMREP);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_NUMERIC_LITERAL;
   
       FUNCTION MAKE_NULL_ACCESS
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NULL_ACCESS);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_NULL_ACCESS;
   
       FUNCTION MAKE_RANGE_MEMBERSHIP
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                        AS_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RANGE_MEMBERSHIP);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_MEMBERSHIP_OP, NODE, AS_MEMBERSHIP_OP);
         D ( DA.AS_RANGE, NODE, AS_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_RANGE_MEMBERSHIP;
   
       FUNCTION MAKE_TYPE_MEMBERSHIP
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TYPE_MEMBERSHIP);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_MEMBERSHIP_OP, NODE, AS_MEMBERSHIP_OP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_TYPE_MEMBERSHIP;
   
       FUNCTION MAKE_CONVERSION
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONVERSION);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_CONVERSION;
   
       FUNCTION MAKE_QUALIFIED
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_QUALIFIED);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_QUALIFIED;
   
       FUNCTION MAKE_PARENTHESIZED
                        ( AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_VALUE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PARENTHESIZED);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_VALUE, NODE, SM_VALUE);
         RETURN NODE;
      END MAKE_PARENTHESIZED;
   
       FUNCTION MAKE_AGGREGATE
                        ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_DISCRETE_RANGE: TREE := TREE_VOID;
                        SM_NORMALIZED_COMP_S: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_AGGREGATE);
      BEGIN
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_DISCRETE_RANGE, NODE, SM_DISCRETE_RANGE);
         D ( DA.SM_NORMALIZED_COMP_S, NODE, SM_NORMALIZED_COMP_S);
         RETURN NODE;
      END MAKE_AGGREGATE;
   
       FUNCTION MAKE_STRING_LITERAL
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        LX_SYMREP: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_DISCRETE_RANGE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_STRING_LITERAL);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.LX_SYMREP, NODE, LX_SYMREP);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_DISCRETE_RANGE, NODE, SM_DISCRETE_RANGE);
         RETURN NODE;
      END MAKE_STRING_LITERAL;
   
       FUNCTION MAKE_QUALIFIED_ALLOCATOR
                        ( AS_QUALIFIED: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_QUALIFIED_ALLOCATOR);
      BEGIN
         D ( DA.AS_QUALIFIED, NODE, AS_QUALIFIED);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         RETURN NODE;
      END MAKE_QUALIFIED_ALLOCATOR;
   
       FUNCTION MAKE_SUBTYPE_ALLOCATOR
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_EXP_TYPE: TREE := TREE_VOID;
                        SM_DESIG_TYPE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SUBTYPE_ALLOCATOR);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EXP_TYPE, NODE, SM_EXP_TYPE);
         D ( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE);
         RETURN NODE;
      END MAKE_SUBTYPE_ALLOCATOR;
   
       FUNCTION MAKE_RANGE
                        ( AS_EXP1: TREE := TREE_VOID;
                        AS_EXP2: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RANGE);
      BEGIN
         D ( DA.AS_EXP1, NODE, AS_EXP1);
         D ( DA.AS_EXP2, NODE, AS_EXP2);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         RETURN NODE;
      END MAKE_RANGE;
   
       FUNCTION MAKE_RANGE_ATTRIBUTE
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_USED_NAME_ID: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RANGE_ATTRIBUTE);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_USED_NAME_ID, NODE, AS_USED_NAME_ID);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         RETURN NODE;
      END MAKE_RANGE_ATTRIBUTE;
   
       FUNCTION MAKE_DISCRETE_SUBTYPE
                        ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DISCRETE_SUBTYPE);
      BEGIN
         D ( DA.AS_SUBTYPE_INDICATION, NODE, AS_SUBTYPE_INDICATION);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DISCRETE_SUBTYPE;
   
       FUNCTION MAKE_FLOAT_CONSTRAINT
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FLOAT_CONSTRAINT);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_RANGE, NODE, AS_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         RETURN NODE;
      END MAKE_FLOAT_CONSTRAINT;
   
       FUNCTION MAKE_FIXED_CONSTRAINT
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FIXED_CONSTRAINT);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_RANGE, NODE, AS_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         RETURN NODE;
      END MAKE_FIXED_CONSTRAINT;
   
       FUNCTION MAKE_INDEX_CONSTRAINT
                        ( AS_DISCRETE_RANGE_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INDEX_CONSTRAINT);
      BEGIN
         D ( DA.AS_DISCRETE_RANGE_S, NODE, AS_DISCRETE_RANGE_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_INDEX_CONSTRAINT;
   
       FUNCTION MAKE_DSCRMT_CONSTRAINT
                        ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DSCRMT_CONSTRAINT);
      BEGIN
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_DSCRMT_CONSTRAINT;
   
       FUNCTION MAKE_CHOICE_EXP
                        ( AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CHOICE_EXP);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CHOICE_EXP;
   
       FUNCTION MAKE_CHOICE_RANGE
                        ( AS_DISCRETE_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CHOICE_RANGE);
      BEGIN
         D ( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CHOICE_RANGE;
   
       FUNCTION MAKE_CHOICE_OTHERS
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CHOICE_OTHERS);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CHOICE_OTHERS;
   
       FUNCTION MAKE_PROCEDURE_SPEC
                        ( AS_PARAM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PROCEDURE_SPEC);
      BEGIN
         D ( DA.AS_PARAM_S, NODE, AS_PARAM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PROCEDURE_SPEC;
   
       FUNCTION MAKE_FUNCTION_SPEC
                        ( AS_PARAM_S: TREE := TREE_VOID;
                        AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FUNCTION_SPEC);
      BEGIN
         D ( DA.AS_PARAM_S, NODE, AS_PARAM_S);
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FUNCTION_SPEC;
   
       FUNCTION MAKE_ENTRY
                        ( AS_PARAM_S: TREE := TREE_VOID;
                        AS_DISCRETE_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENTRY);
      BEGIN
         D ( DA.AS_PARAM_S, NODE, AS_PARAM_S);
         D ( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ENTRY;
   
       FUNCTION MAKE_PACKAGE_SPEC
                        ( AS_DECL_S1: TREE := TREE_VOID;
                        AS_DECL_S2: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        XD_BODY_IS_REQUIRED: BOOLEAN := FALSE)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PACKAGE_SPEC);
      BEGIN
         D ( DA.AS_DECL_S1, NODE, AS_DECL_S1);
         D ( DA.AS_DECL_S2, NODE, AS_DECL_S2);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_PACKAGE_SPEC;
   
       FUNCTION MAKE_RENAMES_UNIT
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RENAMES_UNIT);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_RENAMES_UNIT;
   
       FUNCTION MAKE_INSTANTIATION
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_DECL_S: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INSTANTIATION);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_GENERAL_ASSOC_S, NODE, AS_GENERAL_ASSOC_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_DECL_S, NODE, SM_DECL_S);
         RETURN NODE;
      END MAKE_INSTANTIATION;
   
       FUNCTION MAKE_NAME_DEFAULT
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NAME_DEFAULT);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NAME_DEFAULT;
   
       FUNCTION MAKE_BOX_DEFAULT
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_BOX_DEFAULT);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_BOX_DEFAULT;
   
       FUNCTION MAKE_NO_DEFAULT
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NO_DEFAULT);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NO_DEFAULT;
   
       FUNCTION MAKE_BLOCK_BODY
                        ( AS_ITEM_S: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        AS_ALTERNATIVE_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_BLOCK_BODY);
      BEGIN
         D ( DA.AS_ITEM_S, NODE, AS_ITEM_S);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.AS_ALTERNATIVE_S, NODE, AS_ALTERNATIVE_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_BLOCK_BODY;
   
       FUNCTION MAKE_STUB
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_STUB);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_STUB;
   
       FUNCTION MAKE_IMPLICIT_NOT_EQ
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        SM_EQUAL: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IMPLICIT_NOT_EQ);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_EQUAL, NODE, SM_EQUAL);
         RETURN NODE;
      END MAKE_IMPLICIT_NOT_EQ;
   
       FUNCTION MAKE_DERIVED_SUBPROG
                        ( LX_SRCPOS: TREE := TREE_VOID;
                        SM_DERIVABLE: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_DERIVED_SUBPROG);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_DERIVABLE, NODE, SM_DERIVABLE);
         RETURN NODE;
      END MAKE_DERIVED_SUBPROG;
   
       FUNCTION MAKE_COND_CLAUSE
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COND_CLAUSE);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COND_CLAUSE;
   
       FUNCTION MAKE_SELECT_ALTERNATIVE
                        ( AS_EXP: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SELECT_ALTERNATIVE);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SELECT_ALTERNATIVE;
   
       FUNCTION MAKE_SELECT_ALT_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_SELECT_ALT_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_SELECT_ALT_PRAGMA;
   
       FUNCTION MAKE_IN_OP
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_IN_OP);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_IN_OP;
   
       FUNCTION MAKE_NOT_IN
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_NOT_IN);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_NOT_IN;
   
       FUNCTION MAKE_AND_THEN
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_AND_THEN);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_AND_THEN;
   
       FUNCTION MAKE_OR_ELSE
                        ( LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_OR_ELSE);
      BEGIN
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_OR_ELSE;
   
       FUNCTION MAKE_FOR
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_DISCRETE_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FOR);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_FOR;
   
       FUNCTION MAKE_REVERSE
                        ( AS_SOURCE_NAME: TREE := TREE_VOID;
                        AS_DISCRETE_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_REVERSE);
      BEGIN
         D ( DA.AS_SOURCE_NAME, NODE, AS_SOURCE_NAME);
         D ( DA.AS_DISCRETE_RANGE, NODE, AS_DISCRETE_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_REVERSE;
   
       FUNCTION MAKE_WHILE
                        ( AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_WHILE);
      BEGIN
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_WHILE;
   
       FUNCTION MAKE_ALTERNATIVE
                        ( AS_CHOICE_S: TREE := TREE_VOID;
                        AS_STM_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ALTERNATIVE);
      BEGIN
         D ( DA.AS_CHOICE_S, NODE, AS_CHOICE_S);
         D ( DA.AS_STM_S, NODE, AS_STM_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ALTERNATIVE;
   
       FUNCTION MAKE_ALTERNATIVE_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ALTERNATIVE_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ALTERNATIVE_PRAGMA;
   
       FUNCTION MAKE_COMP_REP
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        AS_RANGE: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMP_REP);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.AS_RANGE, NODE, AS_RANGE);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMP_REP;
   
       FUNCTION MAKE_COMP_REP_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMP_REP_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMP_REP_PRAGMA;
   
       FUNCTION MAKE_CONTEXT_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONTEXT_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_CONTEXT_PRAGMA;
   
       FUNCTION MAKE_WITH
                        ( AS_NAME_S: TREE := TREE_VOID;
                        AS_USE_PRAGMA_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_WITH);
      BEGIN
         D ( DA.AS_NAME_S, NODE, AS_NAME_S);
         D ( DA.AS_USE_PRAGMA_S, NODE, AS_USE_PRAGMA_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_WITH;
   
       FUNCTION MAKE_VARIANT
                        ( AS_CHOICE_S: TREE := TREE_VOID;
                        AS_COMP_LIST: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIANT);
      BEGIN
         D ( DA.AS_CHOICE_S, NODE, AS_CHOICE_S);
         D ( DA.AS_COMP_LIST, NODE, AS_COMP_LIST);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_VARIANT;
   
       FUNCTION MAKE_VARIANT_PRAGMA
                        ( AS_PRAGMA: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIANT_PRAGMA);
      BEGIN
         D ( DA.AS_PRAGMA, NODE, AS_PRAGMA);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_VARIANT_PRAGMA;
   
       FUNCTION MAKE_ALIGNMENT
                        ( AS_PRAGMA_S: TREE := TREE_VOID;
                        AS_EXP: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ALIGNMENT);
      BEGIN
         D ( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S);
         D ( DA.AS_EXP, NODE, AS_EXP);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_ALIGNMENT;
   
       FUNCTION MAKE_VARIANT_PART
                        ( AS_NAME: TREE := TREE_VOID;
                        AS_VARIANT_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_VARIANT_PART);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.AS_VARIANT_S, NODE, AS_VARIANT_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_VARIANT_PART;
   
       FUNCTION MAKE_COMP_LIST
                        ( AS_DECL_S: TREE := TREE_VOID;
                        AS_VARIANT_PART: TREE := TREE_VOID;
                        AS_PRAGMA_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMP_LIST);
      BEGIN
         D ( DA.AS_DECL_S, NODE, AS_DECL_S);
         D ( DA.AS_VARIANT_PART, NODE, AS_VARIANT_PART);
         D ( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMP_LIST;
   
       FUNCTION MAKE_COMPILATION
                        ( AS_COMPLTN_UNIT_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMPILATION);
      BEGIN
         D ( DA.AS_COMPLTN_UNIT_S, NODE, AS_COMPLTN_UNIT_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         RETURN NODE;
      END MAKE_COMPILATION;
   
       FUNCTION MAKE_COMPILATION_UNIT
                        ( AS_CONTEXT_ELEM_S: TREE := TREE_VOID;
                        AS_ALL_DECL: TREE := TREE_VOID;
                        AS_PRAGMA_S: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        XD_TIMESTAMP: INTEGER := 0;
                        LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        XD_NBR_PAGES: INTEGER := 0;
                        XD_LIB_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_COMPILATION_UNIT);
      BEGIN
         D ( DA.AS_CONTEXT_ELEM_S, NODE, AS_CONTEXT_ELEM_S);
         D ( DA.AS_ALL_DECL, NODE, AS_ALL_DECL);
         D ( DA.AS_PRAGMA_S, NODE, AS_PRAGMA_S);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         DI (DA.XD_TIMESTAMP, NODE, XD_TIMESTAMP);
         IDL_MAN.LIST(NODE, LIST);
         DI (DA.XD_NBR_PAGES, NODE, XD_NBR_PAGES);
         D ( DA.XD_LIB_NAME, NODE, XD_LIB_NAME);
         RETURN NODE;
      END MAKE_COMPILATION_UNIT;
   
       FUNCTION MAKE_INDEX
                        ( AS_NAME: TREE := TREE_VOID;
                        LX_SRCPOS: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INDEX);
      BEGIN
         D ( DA.AS_NAME, NODE, AS_NAME);
         D ( DA.LX_SRCPOS, NODE, LX_SRCPOS);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         RETURN NODE;
      END MAKE_INDEX;
   
       FUNCTION MAKE_TASK_SPEC
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_DECL_S: TREE := TREE_VOID;
                        SM_BODY: TREE := TREE_VOID;
                        SM_ADDRESS: TREE := TREE_VOID;
                        SM_SIZE: TREE := TREE_VOID;
                        SM_STORAGE_SIZE: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID;
                        XD_STUB: TREE := TREE_VOID;
                        XD_BODY: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_TASK_SPEC);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_DECL_S, NODE, SM_DECL_S);
         D ( DA.SM_BODY, NODE, SM_BODY);
         D ( DA.SM_ADDRESS, NODE, SM_ADDRESS);
         D ( DA.SM_SIZE, NODE, SM_SIZE);
         D ( DA.SM_STORAGE_SIZE, NODE, SM_STORAGE_SIZE);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         D ( DA.XD_STUB, NODE, XD_STUB);
         D ( DA.XD_BODY, NODE, XD_BODY);
         RETURN NODE;
      END MAKE_TASK_SPEC;
   
       FUNCTION MAKE_ENUMERATION
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_RANGE: TREE := TREE_VOID;
                        SM_LITERAL_S: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID;
                        CD_IMPL_SIZE: INTEGER := 0)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ENUMERATION);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_RANGE, NODE, SM_RANGE);
         D ( DA.SM_LITERAL_S, NODE, SM_LITERAL_S);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE);
         RETURN NODE;
      END MAKE_ENUMERATION;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_INTEGER
       FUNCTION MAKE_INTEGER ( SM_DERIVED, SM_BASE_TYPE, SM_RANGE, XD_SOURCE_NAME :TREE := TREE_VOID;
          		CD_IMPL_SIZE: INTEGER := 0; SM_IS_ANONYMOUS :BOOLEAN := FALSE
                	) RETURN TREE IS
         NODE	: TREE := MAKE ( DN_INTEGER );
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_RANGE, NODE, SM_RANGE);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE);
         RETURN NODE;
      END;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION MAKE_FLOAT
       FUNCTION MAKE_FLOAT
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_RANGE: TREE := TREE_VOID;
                        SM_ACCURACY: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID;
                        CD_IMPL_SIZE: INTEGER := 0)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FLOAT);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_RANGE, NODE, SM_RANGE);
         D ( DA.SM_ACCURACY, NODE, SM_ACCURACY);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE);
         RETURN NODE;
      END MAKE_FLOAT;
   
       FUNCTION MAKE_FIXED
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_RANGE: TREE := TREE_VOID;
                        SM_ACCURACY: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID;
                        CD_IMPL_SIZE: INTEGER := 0;
                        CD_IMPL_SMALL: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_FIXED);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_RANGE, NODE, SM_RANGE);
         D ( DA.SM_ACCURACY, NODE, SM_ACCURACY);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         DI (DA.CD_IMPL_SIZE, NODE, CD_IMPL_SIZE);
         D ( DA.CD_IMPL_SMALL, NODE, CD_IMPL_SMALL);
         RETURN NODE;
      END MAKE_FIXED;
   
       FUNCTION MAKE_ARRAY
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_SIZE: TREE := TREE_VOID;
                        SM_IS_LIMITED: BOOLEAN := FALSE;
                        SM_IS_PACKED: BOOLEAN := FALSE;
                        SM_INDEX_S: TREE := TREE_VOID;
                        SM_COMP_TYPE: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ARRAY);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_SIZE, NODE, SM_SIZE);
         DB( DA.SM_IS_LIMITED, NODE, SM_IS_LIMITED);
         DB( DA.SM_IS_PACKED, NODE, SM_IS_PACKED);
         D ( DA.SM_INDEX_S, NODE, SM_INDEX_S);
         D ( DA.SM_COMP_TYPE, NODE, SM_COMP_TYPE);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_ARRAY;
   
       FUNCTION MAKE_RECORD
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_SIZE: TREE := TREE_VOID;
                        SM_IS_LIMITED: BOOLEAN := FALSE;
                        SM_IS_PACKED: BOOLEAN := FALSE;
                        SM_DISCRIMINANT_S: TREE := TREE_VOID;
                        SM_COMP_LIST: TREE := TREE_VOID;
                        SM_REPRESENTATION: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_RECORD);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_SIZE, NODE, SM_SIZE);
         DB( DA.SM_IS_LIMITED, NODE, SM_IS_LIMITED);
         DB( DA.SM_IS_PACKED, NODE, SM_IS_PACKED);
         D ( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S);
         D ( DA.SM_COMP_LIST, NODE, SM_COMP_LIST);
         D ( DA.SM_REPRESENTATION, NODE, SM_REPRESENTATION);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_RECORD;
   
       FUNCTION MAKE_ACCESS
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_SIZE: TREE := TREE_VOID;
                        SM_STORAGE_SIZE: TREE := TREE_VOID;
                        SM_IS_CONTROLLED: BOOLEAN := FALSE;
                        SM_DESIG_TYPE: TREE := TREE_VOID;
                        SM_MASTER: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_ACCESS);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         D ( DA.SM_SIZE, NODE, SM_SIZE);
         D ( DA.SM_STORAGE_SIZE, NODE, SM_STORAGE_SIZE);
         DB( DA.SM_IS_CONTROLLED, NODE, SM_IS_CONTROLLED);
         D ( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE);
         D ( DA.SM_MASTER, NODE, SM_MASTER);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_ACCESS;
   
       FUNCTION MAKE_CONSTRAINED_ARRAY
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                        SM_INDEX_SUBTYPE_S: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTRAINED_ARRAY);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT);
         D ( DA.SM_INDEX_SUBTYPE_S, NODE, SM_INDEX_SUBTYPE_S);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_CONSTRAINED_ARRAY;
   
       FUNCTION MAKE_CONSTRAINED_RECORD
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                        SM_NORMALIZED_DSCRMT_S: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTRAINED_RECORD);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT);
         D ( DA.SM_NORMALIZED_DSCRMT_S, NODE, SM_NORMALIZED_DSCRMT_S);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_CONSTRAINED_RECORD;
   
       FUNCTION MAKE_CONSTRAINED_ACCESS
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_BASE_TYPE: TREE := TREE_VOID;
                        SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                        SM_DESIG_TYPE: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_CONSTRAINED_ACCESS);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_BASE_TYPE, NODE, SM_BASE_TYPE);
         DB( DA.SM_DEPENDS_ON_DSCRMT, NODE, SM_DEPENDS_ON_DSCRMT);
         D ( DA.SM_DESIG_TYPE, NODE, SM_DESIG_TYPE);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_CONSTRAINED_ACCESS;
   
       FUNCTION MAKE_PRIVATE
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_DISCRIMINANT_S: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_PRIVATE);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_PRIVATE;
   
       FUNCTION MAKE_L_PRIVATE
                        ( SM_DERIVED: TREE := TREE_VOID;
                        SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                        SM_DISCRIMINANT_S: TREE := TREE_VOID;
                        SM_TYPE_SPEC: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_L_PRIVATE);
      BEGIN
         D ( DA.SM_DERIVED, NODE, SM_DERIVED);
         DB( DA.SM_IS_ANONYMOUS, NODE, SM_IS_ANONYMOUS);
         D ( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S);
         D ( DA.SM_TYPE_SPEC, NODE, SM_TYPE_SPEC);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_L_PRIVATE;
   
       FUNCTION MAKE_INCOMPLETE
                        ( SM_DISCRIMINANT_S: TREE := TREE_VOID;
                        XD_SOURCE_NAME: TREE := TREE_VOID;
                        XD_FULL_TYPE_SPEC: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_INCOMPLETE);
      BEGIN
         D ( DA.SM_DISCRIMINANT_S, NODE, SM_DISCRIMINANT_S);
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         D ( DA.XD_FULL_TYPE_SPEC, NODE, XD_FULL_TYPE_SPEC);
         RETURN NODE;
      END MAKE_INCOMPLETE;
   
       FUNCTION MAKE_UNIVERSAL_INTEGER
                        ( XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_UNIVERSAL_INTEGER);
      BEGIN
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_UNIVERSAL_INTEGER;
   
       FUNCTION MAKE_UNIVERSAL_FIXED
                        ( XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_UNIVERSAL_FIXED);
      BEGIN
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_UNIVERSAL_FIXED;
   
       FUNCTION MAKE_UNIVERSAL_REAL
                        ( XD_SOURCE_NAME: TREE := TREE_VOID)
                        RETURN TREE IS
         NODE: TREE := MAKE ( DN_UNIVERSAL_REAL);
      BEGIN
         D ( DA.XD_SOURCE_NAME, NODE, XD_SOURCE_NAME);
         RETURN NODE;
      END MAKE_UNIVERSAL_REAL;
   
    --|----------------------------------------------------------------------------------------------
   END MAKE_NOD;
