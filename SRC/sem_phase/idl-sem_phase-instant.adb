    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	INSTANT
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY INSTANT IS
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE MAKE_NOD;
      USE GEN_SUBS;
      USE HOM_UNIT;
      USE EXP_TYPE, EXPRESO;
      USE REQ_UTIL;
      USE SET_UTIL;
      USE NOD_WALK;
   
      TYPE FORMAL_ARRAY_DATA IS
         RECORD
            ID:	  	TREE;
            SYM:	TREE;
            ACTUAL:     TREE;
         END RECORD;
   
      TYPE FORMAL_ARRAY_TYPE
                IS ARRAY (POSITIVE RANGE <>) OF FORMAL_ARRAY_DATA;
   
   
       PROCEDURE RESOLVE_GENERIC_FORMALS
                ( NODE_HASH: IN OUT NODE_HASH_TYPE
                ; GENERIC_PARAM_S: TREE
                ; GENERAL_ASSOC_S: TREE
                ; NEW_DECL_S: OUT TREE
                ; H: H_TYPE );
   
       FUNCTION COUNT_GENERIC_FORMALS (ITEM_S: TREE) RETURN NATURAL;
   
       PROCEDURE SPREAD_GENERIC_FORMALS
                ( ITEM_S:	TREE
                ; FORMAL:	OUT FORMAL_ARRAY_TYPE );
   
       PROCEDURE WALK_GENERIC_ACTUAL
                ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                ; FORMAL_ID:	TREE
                ; ACTUAL_EXP:	IN OUT TREE
                ; H: H_TYPE );
   
       PROCEDURE CONSTRUCT_INSTANCE_DECL
                ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                ; FORMAL_ID:	TREE
                ; ACTUAL_EXP:	TREE
                ; NEW_DECL_LIST:IN OUT SEQ_TYPE
                ; H: H_TYPE );
   
       PROCEDURE FIX_DECLS_AND_SUBSTITUTE
                (DECL_S: TREE; NODE_HASH: IN OUT NODE_HASH_TYPE; H: H_TYPE);
   
      --|-------------------------------------------------------------------------------------------
      --|
        -- $$$$ SHOULDN'T BE HERE
       FUNCTION LENGTH(L: SEQ_TYPE) RETURN NATURAL IS
         TEMP: SEQ_TYPE := L;
         COUNT: NATURAL := 0;
      BEGIN
         WHILE NOT IS_EMPTY(TEMP) LOOP
            COUNT := COUNT + 1;
            TEMP := TAIL(TEMP);
         END LOOP;
         RETURN COUNT;
      END LENGTH;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE WALK_INSTANTIATION
                        ( UNIT_ID: TREE
                        ; INSTANTIATION: TREE
                        ; H: H_TYPE )
                        IS
         GEN_ASSOC_S:	CONSTANT TREE := D(AS_GENERAL_ASSOC_S,
                        INSTANTIATION);
         NAME:		TREE := D(AS_NAME, INSTANTIATION);
      
         UNIT_DEF:	CONSTANT TREE := GET_DEF_FOR_ID(UNIT_ID);
         GENERIC_ID:	TREE;
         NODE_HASH:	NODE_HASH_TYPE;
         NEW_DECL_S:	TREE;
         UNIT_SPEC:	TREE;
      BEGIN
      
                -- RESOLVE THE GENERIC UNIT NAME
         NAME := WALK_NAME(DN_GENERIC_ID, NAME);
         D(AS_NAME, INSTANTIATION, NAME);
         GENERIC_ID := GET_NAME_DEFN(NAME);
      
                -- QUIT IF NO GENERIC UNIT WAS FOUND
         IF GENERIC_ID = TREE_VOID THEN
            RETURN;
         END IF;
      
                -- SUBSTITUTE INSTANCE NAME FOR GENERIC NAME
         INSERT_NODE_HASH(NODE_HASH, UNIT_ID, GENERIC_ID);
      
                -- WITHIN THE NEW REGION
         DECLARE
            H: H_TYPE := WALK_INSTANTIATION.H;
            S: S_TYPE;
         BEGIN
            ENTER_REGION(UNIT_DEF, H, S);
            H.IS_IN_SPEC := FALSE;
         
                        -- BUT REGION NAME NOT VISIBLE AS ENCLOSING REGION WHILE
                        -- ... RESOLVING FORMALS
            DI(XD_LEX_LEVEL, UNIT_DEF, 0);
         
                        -- RESOLVE FORMAL PARAMETERS
            RESOLVE_GENERIC_FORMALS
                                ( NODE_HASH
                                , D(SM_GENERIC_PARAM_S, GENERIC_ID)
                                , GEN_ASSOC_S
                                , NEW_DECL_S
                                , H );
            D(SM_DECL_S, INSTANTIATION, NEW_DECL_S );
         
                        -- CONSTRUCT NEW UNIT SPEC
            UNIT_SPEC := D(SM_SPEC, GENERIC_ID);
            IF UNIT_SPEC.TY = DN_PACKAGE_SPEC THEN
               DECLARE
                  DECL_S1: TREE := D(AS_DECL_S1,
                                                UNIT_SPEC);
                  DECL_S2: TREE := D(AS_DECL_S2,
                                                UNIT_SPEC);
               BEGIN
                                        -- RESTORE VISIBILITY OF NEW UNIT
                  DI(XD_LEX_LEVEL, UNIT_DEF,
                                                H.LEX_LEVEL);
                  MAKE_DEF_VISIBLE(UNIT_DEF);
               
                  H.IS_IN_SPEC := TRUE;
                  FIX_DECLS_AND_SUBSTITUTE(DECL_S1,
                                                NODE_HASH, H);
                  H.IS_IN_SPEC := FALSE;
                  FIX_DECLS_AND_SUBSTITUTE(DECL_S2,
                                                NODE_HASH, H);
               END;
            ELSIF UNIT_SPEC.TY = DN_TASK_SPEC THEN
               H.IS_IN_SPEC := TRUE;
            END IF;
            SUBSTITUTE(UNIT_SPEC, NODE_HASH, H);
            D(SM_SPEC, UNIT_ID, UNIT_SPEC);
         
            LEAVE_REGION(UNIT_DEF, S);
         END;
      END WALK_INSTANTIATION;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE RESOLVE_GENERIC_FORMALS
                        ( NODE_HASH: IN OUT NODE_HASH_TYPE
                        ; GENERIC_PARAM_S: TREE
                        ; GENERAL_ASSOC_S: TREE
                        ; NEW_DECL_S: OUT TREE
                        ; H: H_TYPE )
                        IS
      
         FORMAL_COUNT:	    CONSTANT NATURAL
                        := COUNT_GENERIC_FORMALS(GENERIC_PARAM_S);
      
         ACTUAL_LIST: SEQ_TYPE := LIST(GENERAL_ASSOC_S);
         ACTUAL: TREE;
         ACTUAL_SYM: TREE;
         ACTUAL_EXP: TREE;
         NEW_ACTUAL_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      
         ACTUAL_SUB: NATURAL := 0;
         FORMAL_SUB: NATURAL := 0;
         FIRST_NAMED_SUB: NATURAL := 0;
         NEW_DECL_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         UNIT_DESC: TREE;
      
         FORMAL:     FORMAL_ARRAY_TYPE(1 .. FORMAL_COUNT);
         ACTUAL_TO_FORMAL: ARRAY (1 .. LENGTH(ACTUAL_LIST)) OF
                        NATURAL
                        := (OTHERS => 0);
      BEGIN
      
                -- SPREAD THE FORMAL PARAMETERS
         SPREAD_GENERIC_FORMALS(GENERIC_PARAM_S, FORMAL);
      
                -- FOR EACH POSITIONAL ACTUAL
         WHILE NOT IS_EMPTY(ACTUAL_LIST)
                                AND THEN HEAD(ACTUAL_LIST).TY /=
                                DN_ASSOC LOOP
            POP(ACTUAL_LIST, ACTUAL);
         
                        -- IF THERE ARE TOO MANY POSITIONALS
            ACTUAL_SUB := ACTUAL_SUB + 1;
            IF ACTUAL_SUB > FORMAL'LAST THEN
            
                                -- PUT OUT ERROR
               ERROR(D(LX_SRCPOS,ACTUAL),
                                        "TOO MANY ACTUALS");
            
                                -- ELSE
            ELSE
            
                                -- SAVE ACTUAL
               ACTUAL_TO_FORMAL(ACTUAL_SUB) := ACTUAL_SUB;
               FORMAL(ACTUAL_SUB).ACTUAL := ACTUAL;
            END IF;
         END LOOP;
         FIRST_NAMED_SUB := ACTUAL_SUB + 1;
      
                -- FOR EACH ACTUAL FOLLOWING THE POSITIONALS
         WHILE NOT IS_EMPTY(ACTUAL_LIST) LOOP
            POP(ACTUAL_LIST, ACTUAL);
            ACTUAL_SUB := ACTUAL_SUB + 1;
         
                        -- CHECK THAT IT IS NAMED AND GET SYMBOL
            IF ACTUAL.TY /= DN_ASSOC THEN
               ERROR(D(LX_SRCPOS, ACTUAL),
                                        "POSITIONAL PARAMETER AFTER NAMED");
            ELSE
               ACTUAL_SYM := D(LX_SYMREP, D(AS_USED_NAME,
                                                ACTUAL));
            
                                -- SEARCH FORMALS FOR (UNIQUE) MATCHING ID
               FORMAL_SUB := 0;
               FOR I IN FIRST_NAMED_SUB .. FORMAL'LAST LOOP
                  IF ACTUAL_SYM = FORMAL(I).SYM THEN
                     IF FORMAL_SUB = 0 THEN
                        FORMAL_SUB := I;
                     ELSE
                        ERROR(D(LX_SRCPOS,
                                                                        ACTUAL)
                                                                ,
                                                                "AMBIGUOUS GENERIC ARGUMENT ASSOC");
                        FORMAL_SUB := 0;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            
                                -- IF OK MATCH, SAVE ACTUAL
               IF FORMAL_SUB = 0 THEN
                  ERROR(D(LX_SRCPOS, ACTUAL),
                                                "NO MATCHING GENERIC FORMAL");
               ELSE
                  ACTUAL_TO_FORMAL(ACTUAL_SUB) :=
                                                FORMAL_SUB;
                  FORMAL(FORMAL_SUB).ACTUAL :=
                                                ACTUAL;
               END IF;
            END IF;
         END LOOP;
      
                -- RESOLVE THE ACTUAL PARAMETERS
                -- FOR EACH FORMAL
         FOR I IN FORMAL'RANGE LOOP
            ACTUAL := FORMAL(I).ACTUAL;
         
                        -- IF AN ACTUAL WAS EXPLICITLY GIVEN
            IF ACTUAL /= TREE_VOID THEN
            
                                -- STRIP NAME FROM ARGUMENT ASSOCIATION
               IF ACTUAL.TY = DN_ASSOC THEN
                  ACTUAL_EXP := D(AS_EXP, ACTUAL);
                                        -- FIXUP USED_NAME_ID
                  DECLARE
                     USED_NAME: TREE := D(
                                                        AS_USED_NAME,
                                                        ACTUAL);
                  BEGIN
                     IF USED_NAME.TY =
                                                                DN_USED_OBJECT_ID THEN
                        D(AS_USED_NAME
                                                                , ACTUAL
                                                                ,
                                                                MAKE_USED_NAME_ID_FROM_OBJECT
                                                                (
                                                                        USED_NAME ));
                     ELSIF USED_NAME.TY =
                                                                DN_STRING_LITERAL THEN
                        D(AS_USED_NAME
                                                                , ACTUAL
                                                                ,
                                                                MAKE_USED_OP_FROM_STRING
                                                                (
                                                                        USED_NAME ));
                     END IF;
                  END;
                  D(SM_DEFN, D(AS_USED_NAME, ACTUAL),
                                                TREE_VOID);
               ELSE
                  ACTUAL_EXP := ACTUAL;
               END IF;
            
                                -- AND RESOLVE THE ACTUAL
               IF ACTUAL_EXP.TY = DN_STRING_LITERAL
                                                AND THEN FORMAL(I).
                                                ID.TY IN CLASS_SUBPROG_NAME THEN
                  ACTUAL_EXP :=
                                                MAKE_USED_OP_FROM_STRING(
                                                ACTUAL_EXP);
               END IF;
               WALK_GENERIC_ACTUAL
                                        (NODE_HASH, FORMAL(I).ID,
                                        ACTUAL_EXP, H);
            
                                -- ELSE -- SINCE NO ACTUAL WAS GIVEN
            ELSE
            
                                -- IN CASE NO DEFAULT, USE VOID ACTUAL_EXP
               ACTUAL_EXP := TREE_VOID;
            
                                -- IF PARAMETER IS OBJECT WITH DEFAULT
               IF FORMAL(I).ID.TY = DN_IN_ID
                                                AND THEN D(SM_INIT_EXP,
                                                FORMAL(I).ID) /=
                                                TREE_VOID THEN
               
                                        -- USE THE DEFAULT
                  ACTUAL_EXP := D(SM_INIT_EXP,
                                                FORMAL(I).ID);
                  SUBSTITUTE(ACTUAL_EXP, NODE_HASH,
                                                H);
               
                                        -- ELSE IF PARAMETER IS SUBPROGRAM WITH DEFAULT
               ELSIF FORMAL(I).ID.TY IN
                                                CLASS_SUBPROG_NAME
                                                AND THEN D(
                                                        SM_UNIT_DESC,
                                                        FORMAL(I).ID).TY /=
                                                DN_NO_DEFAULT
                                                THEN
               
                                        -- IF IT IS A NAME DEFAULT
                  UNIT_DESC := D(SM_UNIT_DESC,
                                                FORMAL(I).ID);
                  IF UNIT_DESC.TY =
                                                        DN_NAME_DEFAULT THEN
                  
                                                -- USE THE (ALREADY RESOLVED) NAME
                     ACTUAL_EXP := D(AS_NAME,
                                                        UNIT_DESC);
                     SUBSTITUTE(ACTUAL_EXP,
                                                        NODE_HASH, H);
                  
                                                -- ELSE -- SINCE IT IS A BOX DEFAULT
                  ELSE
                  
                                                -- CONSTRUCT NAME TO RESOLVE
                     IF FORMAL(I).ID.TY =
                                                                DN_OPERATOR_ID THEN
                        ACTUAL_EXP :=
                                                                MAKE_USED_OP
                                                                (
                                                                LX_SYMREP =>
                                                                D(
                                                                        LX_SYMREP,
                                                                        FORMAL(
                                                                                I).
                                                                        ID)
                                                                ,
                                                                LX_SRCPOS
                                                                => D(
                                                                        LX_SRCPOS,
                                                                        GENERAL_ASSOC_S) );
                     ELSE
                        ACTUAL_EXP :=
                                                                MAKE_USED_OBJECT_ID
                                                                (
                                                                LX_SYMREP =>
                                                                D(
                                                                        LX_SYMREP,
                                                                        FORMAL(
                                                                                I).
                                                                        ID)
                                                                ,
                                                                LX_SRCPOS
                                                                => D(
                                                                        LX_SRCPOS,
                                                                        GENERAL_ASSOC_S) );
                     END IF;
                  
                                                -- AND RESOLVE IT
                     WALK_GENERIC_ACTUAL
                                                        (NODE_HASH, FORMAL(
                                                                I).ID,
                                                        ACTUAL_EXP, H);
                  END IF;
               
                                        -- ELSE -- SINCE NO DEFAULT GIVEN
               ELSE
                  ERROR(D(LX_SRCPOS, GENERAL_ASSOC_S)
                                                ,
                                                "NO VALUE GIVEN FOR GENERIC PARAMETER - "
                                                & PRINT_NAME ( FORMAL(I).SYM) );
               END IF;
            END IF;
         
                        -- CONSTRUCT DECLARATION FOR GENERIC ACTUAL
            CONSTRUCT_INSTANCE_DECL
                                ( NODE_HASH, FORMAL(I).ID, ACTUAL_EXP,
                                NEW_DECL_LIST ,H );
         
                        -- AND UPDATE ACTUAL
            ACTUAL := FORMAL(I).ACTUAL;
            IF ACTUAL.TY = DN_ASSOC THEN
               D(AS_EXP, ACTUAL, ACTUAL_EXP);
            ELSE
               FORMAL(I).ACTUAL := ACTUAL_EXP;
            END IF;
         END LOOP;
      
                -- CONSTRUCT AND SAVE LIST OF RESOLVED ACTUALS
         FOR I IN ACTUAL_TO_FORMAL'RANGE LOOP
            IF ACTUAL_TO_FORMAL(I) /= 0 THEN
               NEW_ACTUAL_LIST := APPEND
                                        ( NEW_ACTUAL_LIST
                                        , FORMAL(ACTUAL_TO_FORMAL(I)).
                                        ACTUAL );
            END IF;
         END LOOP;
         LIST(GENERAL_ASSOC_S, NEW_ACTUAL_LIST);
      
         NEW_DECL_S := MAKE_DECL_S (LIST => NEW_DECL_LIST);
      END RESOLVE_GENERIC_FORMALS;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION COUNT_GENERIC_FORMALS (ITEM_S: TREE) RETURN NATURAL IS
         ITEM_LIST: SEQ_TYPE := LIST(ITEM_S);
         ITEM: TREE;
         ITEM_KIND: NODE_NAME;
         ITEM_COUNT: NATURAL := 0;
      BEGIN
      
                -- FOR EACH ELEMENT OF GENERIC FORMAL DECLARATION LIST
         WHILE NOT IS_EMPTY(ITEM_LIST) LOOP
            POP(ITEM_LIST, ITEM);
         
                        -- IF IT IS AN IN OR AN IN OUT DECLARATION
            ITEM_KIND := ITEM.TY;
            IF ITEM_KIND = DN_IN OR ITEM_KIND = DN_IN_OUT THEN
            
                                -- ADD THE NUMBER OF DECLARED IDENTIFIERS
               ITEM_COUNT
                                        := ITEM_COUNT + LENGTH(LIST(D(
                                                        AS_SOURCE_NAME_S,
                                                        ITEM)));
            
                                -- ELSE IF IT IS ANYTHING ELSE OTHER THAN A PRAGMA
            ELSIF ITEM_KIND /= DN_PRAGMA THEN
            
                                -- ADD ONE DECLARATION
               ITEM_COUNT := ITEM_COUNT + 1;
            END IF;
         END LOOP;
      
                -- RETURN THE COUNT
         RETURN ITEM_COUNT;
      END COUNT_GENERIC_FORMALS;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE SPREAD_GENERIC_FORMALS
                        ( ITEM_S:	TREE
                        ; FORMAL:	OUT FORMAL_ARRAY_TYPE )
                        IS
         ITEM_LIST: SEQ_TYPE := LIST(ITEM_S);
         ITEM: TREE;
         ITEM_KIND: NODE_NAME;
         ID_LIST: SEQ_TYPE;
         ID: TREE;
         ITEM_COUNT: NATURAL := 0;
      
      BEGIN
      
                -- FOR EACH ELEMENT OF GENERIC FORMAL DECLARATION LIST
         WHILE NOT IS_EMPTY(ITEM_LIST) LOOP
            POP(ITEM_LIST, ITEM);
         
                        -- IF IT IS AN IN OR AN IN-OUT DECLARATION
            ITEM_KIND := ITEM.TY;
            IF ITEM_KIND = DN_IN OR ITEM_KIND = DN_IN_OUT THEN
            
                                -- FOR EACH DECLARED IDENTIFIER
               ID_LIST := LIST(D(AS_SOURCE_NAME_S, ITEM));
               WHILE NOT IS_EMPTY(ID_LIST) LOOP
                  POP(ID_LIST, ID);
               
                                        -- FILL IN DATA FOR IN OR IN-OUT PARAMETER
                  ITEM_COUNT := ITEM_COUNT + 1;
                  FORMAL(ITEM_COUNT).ID := ID;
                  FORMAL(ITEM_COUNT).SYM := D(
                                                LX_SYMREP,ID);
                  FORMAL(ITEM_COUNT).ACTUAL :=
                                                TREE_VOID;
               END LOOP;
            
                                -- ELSE IF IT IS ANYTHING ELSE OTHER THAN A PRAGMA
            ELSIF ITEM_KIND /= DN_PRAGMA THEN
            
                                -- FILL IN DATA FOR FORMAL TYPE OR FORMAL SUBPROGRAM
               ITEM_COUNT := ITEM_COUNT + 1;
               ID := D(AS_SOURCE_NAME, ITEM);
               FORMAL(ITEM_COUNT).ID := ID;
               FORMAL(ITEM_COUNT).SYM := D(LX_SYMREP,ID);
               FORMAL(ITEM_COUNT).ACTUAL := TREE_VOID;
            END IF;
         END LOOP;
      END SPREAD_GENERIC_FORMALS;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE WALK_GENERIC_ACTUAL
                        ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; FORMAL_ID:	TREE
                        ; ACTUAL_EXP:	IN OUT TREE
                        ; H: H_TYPE )
                        IS
         BASE_TYPE: TREE;
         TYPESET: TYPESET_TYPE;
         HEADER: TREE;
      BEGIN
         CASE FORMAL_ID.TY IS
            WHEN DN_IN_ID | DN_IN_OUT_ID =>
               BASE_TYPE := GET_BASE_TYPE(FORMAL_ID);
               SUBSTITUTE(BASE_TYPE, NODE_HASH, H);
               EVAL_EXP_TYPES(ACTUAL_EXP, TYPESET);
               REQUIRE_TYPE(GET_BASE_TYPE(BASE_TYPE),
                                        ACTUAL_EXP, TYPESET);
               ACTUAL_EXP := RESOLVE_EXP(ACTUAL_EXP,
                                        TYPESET);
         
            WHEN DN_TYPE_ID =>
               ACTUAL_EXP := WALK_TYPE_MARK(ACTUAL_EXP);
                        -- $$$$ NEED TO CHECK COMPATIBILITY
         
            WHEN DN_PRIVATE_TYPE_ID | DN_L_PRIVATE_TYPE_ID =>
               ACTUAL_EXP := WALK_TYPE_MARK(ACTUAL_EXP);
                        -- $$$$ NEED TO CHECK COMPATIBILITY FOR PRIVATE
         
            WHEN CLASS_SUBPROG_NAME =>
               HEADER := D(SM_SPEC, FORMAL_ID);
               SUBSTITUTE(HEADER, NODE_HASH, H);
               ACTUAL_EXP := WALK_HOMOGRAPH_UNIT(
                                        ACTUAL_EXP, HEADER);
         
            WHEN OTHERS =>
               PUT_LINE ( "!! BAD GENERIC ACTUAL ID");
               RAISE PROGRAM_ERROR;
         END CASE;
      END WALK_GENERIC_ACTUAL;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE CONSTRUCT_INSTANCE_DECL
                        ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; FORMAL_ID:	TREE
                        ; ACTUAL_EXP:	TREE
                        ; NEW_DECL_LIST:IN OUT SEQ_TYPE
                        ; H: H_TYPE )
                        IS
         SYMREP: TREE := D(LX_SYMREP, FORMAL_ID);
         SRCPOS: TREE;
         NEW_ID: TREE;
         NEW_DEF: TREE;
         NEW_DECL: TREE;
         DEFN: TREE;
         SUBTYPE_NODE: TREE;
         HEADER: TREE;
      BEGIN
         IF ACTUAL_EXP /= TREE_VOID THEN
            SRCPOS := D(LX_SRCPOS, ACTUAL_EXP);
         ELSE
            SRCPOS := TREE_VOID;
         END IF;
         IF SYMREP.TY = DN_TXTREP THEN
            SYMREP := STORE_SYM ( PRINT_NAME ( SYMREP));
            D(LX_SYMREP, FORMAL_ID, SYMREP);
         END IF;
      
         CASE FORMAL_ID.TY IS
            WHEN DN_IN_ID =>
               SUBTYPE_NODE := D(SM_OBJ_TYPE, FORMAL_ID);
               SUBSTITUTE(SUBTYPE_NODE, NODE_HASH, H);
               NEW_ID := MAKE_CONSTANT_ID
                                        ( SM_OBJ_TYPE => SUBTYPE_NODE
                                        , SM_INIT_EXP => ACTUAL_EXP );
               D(SM_FIRST, NEW_ID, NEW_ID);
               NEW_DECL := MAKE_CONSTANT_DECL
                                        ( LX_SRCPOS => SRCPOS
                                        , AS_SOURCE_NAME_S =>
                                        MAKE_SOURCE_NAME_S
                                        ( LX_SRCPOS => SRCPOS
                                                , LIST => SINGLETON(
                                                        NEW_ID) )
                                        , AS_TYPE_DEF => TREE_VOID
                                        , AS_EXP => ACTUAL_EXP );
         
            WHEN DN_IN_OUT_ID =>
               SUBTYPE_NODE := D(SM_OBJ_TYPE, FORMAL_ID);
               SUBSTITUTE(SUBTYPE_NODE, NODE_HASH, H);
               NEW_ID := MAKE_VARIABLE_ID
                                        ( SM_OBJ_TYPE => SUBTYPE_NODE
                                        , SM_INIT_EXP => ACTUAL_EXP
                                        , SM_RENAMES_OBJ => TRUE );
               NEW_DECL := MAKE_RENAMES_OBJ_DECL
                                        ( LX_SRCPOS => SRCPOS
                                        , AS_SOURCE_NAME => NEW_ID
                                        , AS_TYPE_MARK_NAME => TREE_VOID
                                        , AS_NAME => ACTUAL_EXP );
         
            WHEN CLASS_TYPE_NAME =>
               DEFN := GET_NAME_DEFN(ACTUAL_EXP);
               IF DEFN /= TREE_VOID THEN
                  SUBTYPE_NODE := D(SM_TYPE_SPEC,
                                                DEFN);
                  INSERT_NODE_HASH
                                                ( NODE_HASH
                                                , GET_BASE_TYPE(
                                                        SUBTYPE_NODE)
                                                , GET_BASE_STRUCT(D(
                                                                SM_TYPE_SPEC,
                                                                FORMAL_ID)) );
                  SUBSTITUTE(SUBTYPE_NODE, NODE_HASH,
                                                H);
                                        -- $$$$ CHECK THAT DIMENSION, INDEX TYPES AND COMPONENT TYPE OK
               ELSE
                  SUBTYPE_NODE := TREE_VOID;
               END IF;
            
               NEW_ID := MAKE_SUBTYPE_ID
                                        ( SM_TYPE_SPEC => SUBTYPE_NODE );
               NEW_DECL := MAKE_SUBTYPE_DECL
                                        ( LX_SRCPOS => SRCPOS
                                        , AS_SOURCE_NAME => NEW_ID
                                        , AS_SUBTYPE_INDICATION =>
                                        ACTUAL_EXP );
         
            WHEN DN_PROCEDURE_ID =>
               HEADER := D(SM_SPEC, FORMAL_ID);
               SUBSTITUTE (HEADER, NODE_HASH, H);
               NEW_ID := MAKE_PROCEDURE_ID
                                        ( SM_SPEC => HEADER
                                        , SM_UNIT_DESC => TREE_VOID );
               D(SM_FIRST, NEW_ID, NEW_ID);
               NEW_DECL := MAKE_SUBPROG_ENTRY_DECL
                                        ( LX_SRCPOS => SRCPOS
                                        , AS_SOURCE_NAME => NEW_ID
                                        , AS_HEADER => HEADER
                                        , AS_UNIT_KIND =>
                                        MAKE_RENAMES_UNIT
                                        ( LX_SRCPOS => SRCPOS
                                                , AS_NAME => ACTUAL_EXP ) );
         
            WHEN DN_FUNCTION_ID | DN_OPERATOR_ID =>
               HEADER := D(SM_SPEC, FORMAL_ID);
               SUBSTITUTE (HEADER, NODE_HASH, H);
               NEW_ID := MAKE_FUNCTION_ID
                                        ( SM_SPEC => HEADER
                                        , SM_UNIT_DESC => TREE_VOID );
               D(SM_FIRST, NEW_ID, NEW_ID);
               NEW_DECL := MAKE_SUBPROG_ENTRY_DECL
                                        ( LX_SRCPOS => SRCPOS
                                        , AS_SOURCE_NAME => NEW_ID
                                        , AS_HEADER => HEADER
                                        , AS_UNIT_KIND =>
                                        MAKE_RENAMES_UNIT
                                        ( LX_SRCPOS => SRCPOS
                                                , AS_NAME => ACTUAL_EXP ) );
         
            WHEN OTHERS =>
               PUT_LINE ( "!! BAD GENERIC ACTUAL ID" );
               RAISE PROGRAM_ERROR;
         END CASE;
      
         D(LX_SRCPOS, NEW_ID, SRCPOS);
         D(LX_SYMREP, NEW_ID, SYMREP);
         NEW_DEF := MAKE_DEF_FOR_ID(NEW_ID, H);
         IF NEW_ID.TY IN CLASS_SUBPROG_NAME THEN
            MAKE_DEF_VISIBLE(NEW_DEF, HEADER);
         ELSE
            MAKE_DEF_VISIBLE(NEW_DEF);
         END IF;
         INSERT_NODE_HASH(NODE_HASH, NEW_ID, FORMAL_ID);
         NEW_DECL_LIST := APPEND(NEW_DECL_LIST, NEW_DECL);
      END CONSTRUCT_INSTANCE_DECL;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE FIX_DECLS_AND_SUBSTITUTE
                        (DECL_S: TREE; NODE_HASH: IN OUT NODE_HASH_TYPE; H:
                        H_TYPE)
                        IS
         DECL_LIST: SEQ_TYPE := LIST(DECL_S);
         DECL: TREE;
         TYPE_ID: TREE;
         TYPE_SPEC: TREE;
         BASE_TYPE: TREE;
      BEGIN
         WHILE NOT IS_EMPTY(DECL_LIST) LOOP
            POP(DECL_LIST, DECL);
            SUBSTITUTE(DECL, NODE_HASH, H);
            IF DECL.TY = DN_TYPE_DECL THEN
               TYPE_ID := D(AS_SOURCE_NAME, DECL);
               TYPE_SPEC := D(SM_TYPE_SPEC, TYPE_ID);
               IF TYPE_SPEC.TY = DN_ENUMERATION
                                                AND THEN D(SM_RANGE,
                                                TYPE_SPEC) = TREE_VOID THEN
                  BASE_TYPE := GET_BASE_TYPE(
                                                TYPE_SPEC);
                  IF D(SM_RANGE, BASE_TYPE) =
                                                        TREE_VOID
                                                        AND THEN D(
                                                        SM_DERIVED,
                                                        BASE_TYPE) /=
                                                        TREE_VOID
                                                        AND THEN D(
                                                        SM_RANGE, D(
                                                                SM_DERIVED,
                                                                BASE_TYPE))
                                                        /= TREE_VOID
                                                        THEN
                     DECLARE
                        THE_RANGE: TREE
                                                                := D(
                                                                SM_RANGE,
                                                                D(
                                                                        SM_DERIVED,
                                                                        BASE_TYPE));
                        ENUM_S: TREE
                                                                := D(
                                                                SM_LITERAL_S
                                                                , D(
                                                                        SM_DERIVED,
                                                                        BASE_TYPE) );
                        ENUM_LIST:
                                                                SEQ_TYPE :=
                                                                LIST(
                                                                ENUM_S);
                        ENUM: TREE;
                        NEW_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                     BEGIN
                        WHILE NOT IS_EMPTY(
                                                                        ENUM_LIST) LOOP
                           POP(
                                                                        ENUM_LIST,
                                                                        ENUM);
                           NEWSNAM.REPLACE_SOURCE_NAME
                                                                        (
                                                                        ENUM,
                                                                        NODE_HASH,
                                                                        H);
                           NEW_LIST :=
                                                                        INSERT(
                                                                        NEW_LIST,
                                                                        ENUM);
                        END LOOP;
                        SUBSTITUTE(ENUM_S,
                                                                NODE_HASH,
                                                                H);
                        SUBSTITUTE(
                                                                THE_RANGE,
                                                                NODE_HASH,
                                                                H);
                        D(SM_LITERAL_S,
                                                                BASE_TYPE,
                                                                ENUM_S);
                        D(SM_RANGE,
                                                                BASE_TYPE,
                                                                THE_RANGE);
                        DI(CD_IMPL_SIZE,
                                                                BASE_TYPE
                                                                , DI(
                                                                        CD_IMPL_SIZE,
                                                                        D(
                                                                                SM_DERIVED,
                                                                                BASE_TYPE)));
                     END;
                  END IF;
                  IF TYPE_SPEC /= BASE_TYPE THEN
                     D(SM_RANGE, TYPE_SPEC, D(
                                                                SM_RANGE,
                                                                BASE_TYPE));
                     D(SM_LITERAL_S, TYPE_SPEC
                                                        , D(SM_LITERAL_S,
                                                                BASE_TYPE) );
                     DI(CD_IMPL_SIZE, TYPE_SPEC,
                                                        DI(CD_IMPL_SIZE,
                                                                BASE_TYPE));
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END;
   
    --|----------------------------------------------------------------------------------------------
   END INSTANT;
