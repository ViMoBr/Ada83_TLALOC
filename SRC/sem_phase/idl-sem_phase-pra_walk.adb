    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	PRA_WALK
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY PRA_WALK IS
      USE PRENAME;
      USE VIS_UTIL;
      USE REQ_UTIL;
      USE DEF_UTIL;
      USE EXP_TYPE;
      USE EXPRESO;
      USE SET_UTIL;
      USE NOD_WALK;
   
      PRAGMA_ERROR: EXCEPTION;
   
       PROCEDURE WALK_PRAGMA_ARGUMENTS(USED_NAME_ID, GEN_ASSOC_S: TREE; H:
                H_TYPE);
   
       PROCEDURE GET_ARGUMENT_NAME
                ( USED_NAME_ID: 	TREE
                ; ASSOC_LIST:		IN OUT SEQ_TYPE
                ; ASSOC_OUT:		OUT TREE
                ; NEW_ASSOC_LIST:	IN OUT SEQ_TYPE
                ; ARGUMENT_LIST:	SEQ_TYPE );
   
       PROCEDURE GET_ARGUMENT_EXP
                ( USED_NAME_ID: 	TREE
                ; ASSOC_LIST:		IN OUT SEQ_TYPE
                ; ASSOC_OUT:		OUT TREE );
   
       PROCEDURE MUST_BE_SIMPLE_NAME (EXP: TREE);
   
       PROCEDURE MUST_BE_NAME (EXP: TREE);
   
   
       PROCEDURE WALK_PRAGMA
                        ( USED_NAME_ID: TREE
                        ; GEN_ASSOC_S:	TREE
                        ; H:		H_TYPE )
                        IS
         DEFLIST: SEQ_TYPE := LIST(D(LX_SYMREP,USED_NAME_ID));
         DEF: TREE;
         PRAGMA_DEFN: TREE := TREE_VOID;
      BEGIN
      
                -- FIND THE PRAGMA_ID
         WHILE NOT IS_EMPTY(DEFLIST) LOOP
            POP(DEFLIST, DEF);
            PRAGMA_DEFN := D(XD_SOURCE_NAME, DEF);
            IF PRAGMA_DEFN.TY = DN_PRAGMA_ID THEN
               EXIT;
            ELSE
               PRAGMA_DEFN := TREE_VOID;
            END IF;
         END LOOP;
      
                -- STORE THE PRAGMA_ID (OR VOID)
         D(SM_DEFN, USED_NAME_ID, PRAGMA_DEFN);
      
                -- IF PRAGMA_ID FOUND
         IF PRAGMA_DEFN /= TREE_VOID THEN
         
                        -- SUPPRESS FATAL ERRORS
            PRAGMA_CONTEXT := USED_NAME_ID;
         
                        -- WALK THE ARGUMENTS
            WALK_PRAGMA_ARGUMENTS(USED_NAME_ID, GEN_ASSOC_S, H);
         
                        -- ENABLE FATAL ERRORS
            PRAGMA_CONTEXT := TREE_VOID;
         
                        -- IF ERROR IN PRAGMA, PUT OUT IGNORED MESSAGE
            IF D(SM_DEFN, USED_NAME_ID) = TREE_VOID THEN
               RAISE PRAGMA_ERROR;
            END IF;
         
                        -- ELSE -- SINCE PRAGMA_ID NOT FOUND
         ELSE
         
                        -- PUT OUT ERROR
            WARNING(D(LX_SRCPOS,USED_NAME_ID)
                                , "PRAGMA NOT KNOWN TO IMPLEMENTATION - "
                                & PRINT_NAME ( D(LX_SYMREP,USED_NAME_ID)) );
         END IF;
      
          EXCEPTION
         
                -- IN CASE OF ERROR IN ARGUMENT EVALUATION
            WHEN PRAGMA_ERROR =>
            
                        -- CLEAR THE PRAGMA_ID
               D(SM_DEFN, USED_NAME_ID, TREE_VOID);
            
                        -- ENABLE FATAL ERRORS
               PRAGMA_CONTEXT := TREE_VOID;
            
               WARNING(D(LX_SRCPOS,USED_NAME_ID)
                                , "PRAGMA IGNORED - "
                                & PRINT_NAME ( D(LX_SYMREP,USED_NAME_ID)) );
      END WALK_PRAGMA;
   
   
       PROCEDURE WALK_PRAGMA_ARGUMENTS(USED_NAME_ID, GEN_ASSOC_S: TREE; H:
                        H_TYPE)
                        IS
         PRAGMA_ID:	TREE := D(SM_DEFN, USED_NAME_ID);
         ARGUMENT_ID_LIST: SEQ_TYPE := LIST(D(SM_ARGUMENT_ID_S,
                                PRAGMA_ID));
         ASSOC_LIST:	SEQ_TYPE := LIST(GEN_ASSOC_S);
         ASSOC_NODE:	TREE;
         ASSOC_EXP:	TREE;
         ASSOC_TYPE:	TREE;
         DEFSET: 	DEFSET_TYPE;
         DEFINTERP:	DEFINTERP_TYPE;
         TYPESET:	TYPESET_TYPE;
         DEF:		TREE;
         ID:		TREE;
         IDLIST: 	SEQ_TYPE := (TREE_NIL,TREE_NIL);
         NEW_ASSOC_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      BEGIN
      
         CASE DEFINED_PRAGMAS'VAL ( DI(XD_POS,D(SM_DEFN,USED_NAME_ID)) ) IS
         
            WHEN CONTROLLED =>
                                -- $$$$ IMMEDIATELY WITHIN DECLARATIVE PART OR PACKAGE SPECIFICATION
               GET_ARGUMENT_EXP(USED_NAME_ID,ASSOC_LIST,
                                        ASSOC_EXP);
               MUST_BE_SIMPLE_NAME(ASSOC_EXP);
               ASSOC_EXP := WALK_TYPE_MARK(ASSOC_EXP);
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        ASSOC_EXP);
               ASSOC_TYPE := GET_BASE_STRUCT(ASSOC_EXP);
               IF ASSOC_TYPE.TY /= DN_ACCESS
                                                OR ELSE D(SM_DERIVED,
                                                ASSOC_TYPE) /= TREE_VOID THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "CONTROLLED NOT ALLOWED FOR TYPE");
               ELSIF D(XD_REGION, D(XD_SOURCE_NAME,
                                                        ASSOC_TYPE))
                                                /= D(XD_SOURCE_NAME,
                                                H.REGION_DEF)
                                                THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "CONTROLLED NOT ALLOWED HERE");
               ELSE
                  DB(SM_IS_CONTROLLED, ASSOC_TYPE,
                                                TRUE);
               END IF;
         
            WHEN ELABORATE =>
                                -- $$$$ ONLY AFTER CONTEXT CLAUSE; MUST BE IN CONTEXT CLAUSE
               LOOP
                  GET_ARGUMENT_EXP(USED_NAME_ID,
                                                ASSOC_LIST,ASSOC_EXP);
                  MUST_BE_SIMPLE_NAME(ASSOC_EXP);
                  FIND_DIRECT_VISIBILITY(ASSOC_EXP,
                                                DEFSET);
                  REQUIRE_UNIQUE_DEF(ASSOC_EXP,
                                                DEFSET);
                  ASSOC_EXP := RESOLVE_NAME(
                                                ASSOC_EXP, GET_THE_ID(
                                                        DEFSET));
                  NEW_ASSOC_LIST := APPEND(
                                                NEW_ASSOC_LIST, ASSOC_EXP);
                  IF D(SM_DEFN,ASSOC_EXP).TY NOT IN
                                                        CLASS_NON_TASK_NAME
                                                        AND D(SM_DEFN,
                                                        ASSOC_EXP) /=
                                                        TREE_VOID
                                                        THEN
                     ERROR(D(LX_SRCPOS,
                                                                ASSOC_EXP)
                                                        ,
                                                        "LIBRARY UNIT NAME REQUIRED");
                  END IF;
                  EXIT
                                                WHEN IS_EMPTY(ASSOC_LIST);
               END LOOP;
         
            WHEN INLINE =>
                                -- $$$$ AT PLACE OF DECLARATIVE ITEM OR FOLLOWING LIBRARY UNIT
               LOOP
                  GET_ARGUMENT_EXP(USED_NAME_ID,
                                                ASSOC_LIST,ASSOC_EXP);
                  MUST_BE_SIMPLE_NAME(ASSOC_EXP);
                  FIND_DIRECT_VISIBILITY(ASSOC_EXP,
                                                DEFSET);
                  WHILE NOT IS_EMPTY(DEFSET) LOOP
                     POP(DEFSET, DEFINTERP);
                     DEF := GET_DEF(DEFINTERP);
                     ID := D(XD_SOURCE_NAME,
                                                        DEF);
                     IF D(XD_REGION_DEF,DEF) =
                                                                H.REGION_DEF
                                                                AND THEN (
                                                                ID.TY IN
                                                                CLASS_SUBPROG_NAME
                                                                OR ELSE (
                                                                        
                                                                                ID.TY =
                                                                        DN_GENERIC_ID
                                                                        AND THEN
                                                                        
                                                                                D(
                                                                                        SM_SPEC,
                                                                                        ID).TY
                                                                        IN
                                                                        DN_PROCEDURE_SPEC
                                                                        ..
                                                                        DN_FUNCTION_SPEC))
                                                                THEN
                        IDLIST := APPEND(
                                                                IDLIST, ID);
                        DB(SM_IS_INLINE,
                                                                ID, TRUE);
                     END IF;
                  END LOOP;
                  IF IS_EMPTY(IDLIST) THEN
                     ERROR(D(LX_SRCPOS,
                                                                ASSOC_EXP),
                                                        "NO SUCH SUBPROGRAM");
                  END IF;
                  D(SM_DEFN,ASSOC_EXP,CAST_TREE(
                                                        IDLIST));
                  ASSOC_EXP :=
                                                MAKE_USED_NAME_ID_FROM_OBJECT(
                                                ASSOC_EXP);
                  NEW_ASSOC_LIST := APPEND(
                                                NEW_ASSOC_LIST, ASSOC_EXP);
                  EXIT
                                                WHEN IS_EMPTY(ASSOC_LIST);
               END LOOP;
         
            WHEN INTERFACE =>
                                -- $$$$ AT PLACE OF DECLARATIVE ITEM OR FOLLOWING LIBRARY UNIT SPEC
               GET_ARGUMENT_NAME
                                        ( USED_NAME_ID
                                        , ASSOC_LIST
                                        , ASSOC_EXP
                                        , NEW_ASSOC_LIST
                                        , ARGUMENT_ID_LIST );
               GET_ARGUMENT_EXP(USED_NAME_ID,ASSOC_LIST,
                                        ASSOC_EXP);
               MUST_BE_NAME(ASSOC_EXP);
               FIND_VISIBILITY(ASSOC_EXP, DEFSET);
               WHILE NOT IS_EMPTY(DEFSET) LOOP
                  POP(DEFSET, DEFINTERP);
                  DEF := GET_DEF(DEFINTERP);
                  ID := D(XD_SOURCE_NAME, DEF);
                  IF D(XD_REGION_DEF,DEF) =
                                                        H.REGION_DEF
                                                        AND THEN ID.TY IN
                                                        CLASS_SUBPROG_NAME
                                                        THEN
                     IDLIST := APPEND(IDLIST,
                                                        ID);
                     IF D(XD_BODY,ID) /=
                                                                TREE_VOID
                                                                OR ELSE D(
                                                                XD_STUB,
                                                                ID) /=
                                                                TREE_VOID THEN
                        ERROR(D(LX_SRCPOS,
                                                                        ASSOC_EXP),
                                                                "BODY ALREADY GIVEN");
                        RAISE PRAGMA_ERROR;
                     END IF;
                  END IF;
               END LOOP;
               IF IS_EMPTY(IDLIST) THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "NO SUCH SUBPROGRAM");
               END IF;
               D(SM_DEFN,ASSOC_EXP,CAST_TREE(IDLIST));
               ASSOC_EXP := MAKE_USED_NAME_ID_FROM_OBJECT(
                                        ASSOC_EXP);
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        ASSOC_EXP);
               WHILE NOT IS_EMPTY(IDLIST) LOOP
                  POP(IDLIST,ID);
                  D(SM_INTERFACE, ID, D(SM_DEFN,
                                                        HEAD(
                                                                NEW_ASSOC_LIST)));
               END LOOP;
         
            WHEN LIST =>
                                -- $$$$ NOT GENERATING LISTING
               GET_ARGUMENT_NAME
                                        ( USED_NAME_ID
                                        , ASSOC_LIST
                                        , ASSOC_EXP
                                        , NEW_ASSOC_LIST
                                        , ARGUMENT_ID_LIST );
         
            WHEN MEMORY_SIZE =>
               ERROR(D(LX_SRCPOS,USED_NAME_ID),
                                        "PRAGMA MEMORY_SIZE NOT SUPPORTED");
               GET_ARGUMENT_EXP( USED_NAME_ID, ASSOC_LIST,
                                        ASSOC_EXP );
         
            WHEN OPTIMIZE =>
               GET_ARGUMENT_NAME
                                        ( USED_NAME_ID
                                        , ASSOC_LIST
                                        , ASSOC_EXP
                                        , NEW_ASSOC_LIST
                                        , ARGUMENT_ID_LIST );
         
            WHEN PACK =>
                                -- $$$$ POSITIONS AS FOR REPRESENTATION CLAUSE; BEFORE REP ATTR
               GET_ARGUMENT_EXP(USED_NAME_ID,ASSOC_LIST,
                                        ASSOC_EXP);
               MUST_BE_SIMPLE_NAME(ASSOC_EXP);
               ASSOC_EXP := WALK_TYPE_MARK(ASSOC_EXP);
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        ASSOC_EXP);
               ASSOC_TYPE := GET_BASE_STRUCT(ASSOC_EXP);
               IF ASSOC_TYPE.TY NOT IN DN_ARRAY ..
                                                DN_RECORD THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "PACK NOT ALLOWED FOR TYPE");
               ELSIF D(XD_REGION, D(XD_SOURCE_NAME,
                                                        ASSOC_TYPE))
                                                /= D(XD_SOURCE_NAME,
                                                H.REGION_DEF)
                                                THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "PACK NOT ALLOWED HERE");
               ELSE
                  DB(SM_IS_PACKED, ASSOC_TYPE, TRUE);
               END IF;
         
            WHEN PAGE =>
               NULL;
         
            WHEN PRIORITY =>
                                -- $$$$ TASK OR MAIN PROGRAM
               GET_ARGUMENT_EXP(USED_NAME_ID,ASSOC_LIST,
                                        ASSOC_EXP);
               EVAL_EXP_TYPES(ASSOC_EXP, TYPESET);
               REQUIRE_TYPE(PREDEFINED_INTEGER, ASSOC_EXP,
                                        TYPESET);
               ASSOC_EXP := RESOLVE_EXP(ASSOC_EXP,
                                        TYPESET);
               IF GET_STATIC_VALUE(ASSOC_EXP) =
                                                TREE_VOID THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "PRIORITY MUST BE STATIC");
               END IF;
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        ASSOC_EXP);
         
            WHEN SHARED =>
                                -- $$$$ SAME DECLARATIVE PART OR PACKAGE SPECIFICATION
               GET_ARGUMENT_EXP(USED_NAME_ID,ASSOC_LIST,
                                        ASSOC_EXP);
               MUST_BE_SIMPLE_NAME(ASSOC_EXP);
               ASSOC_EXP := WALK_NAME(DN_VARIABLE_ID,
                                        ASSOC_EXP);
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        ASSOC_EXP);
               ASSOC_TYPE := GET_BASE_STRUCT(ASSOC_EXP);
               IF D(SM_DEFN,ASSOC_EXP) = TREE_VOID THEN
                  NULL;
               ELSIF ASSOC_TYPE.TY IN CLASS_SCALAR
                                                OR ASSOC_TYPE.TY =
                                                DN_ACCESS THEN
                  IF D(SM_RENAMES_OBJ,D(SM_DEFN,
                                                                ASSOC_EXP)) =
                                                        TREE_VOID THEN
                     DB(SM_IS_SHARED, D(
                                                                SM_DEFN,
                                                                ASSOC_EXP),
                                                        TRUE);
                  ELSE
                     ERROR(D(LX_SRCPOS,
                                                                ASSOC_EXP),
                                                        "MAY NOT BE SHARED");
                  END IF;
               ELSIF ASSOC_TYPE /= TREE_VOID THEN
                  ERROR(D(LX_SRCPOS,ASSOC_EXP),
                                                "MUST BE SCALAR OR ACCESS TYPE");
               END IF;
         
            WHEN STORAGE_UNIT =>
               ERROR(D(LX_SRCPOS,USED_NAME_ID)
                                        ,
                                        "PRAGMA STORAGE_UNIT NOT SUPPORTED");
               GET_ARGUMENT_EXP( USED_NAME_ID, ASSOC_LIST,
                                        ASSOC_EXP );
         
            WHEN SUPPRESS =>
                                -- $$$$ IMMEDIATELY WITHIN DECL PART OR PACKAGE SPEC
               GET_ARGUMENT_NAME
                                        ( USED_NAME_ID
                                        , ASSOC_LIST
                                        , ASSOC_EXP
                                        , NEW_ASSOC_LIST
                                        , TAIL(ARGUMENT_ID_LIST) );
               IF NOT IS_EMPTY(ASSOC_LIST) THEN
                  POP(ASSOC_LIST, ASSOC_NODE);
                  IF ASSOC_NODE.TY = DN_ASSOC THEN
                     IF D(LX_SYMREP,D(
                                                                        AS_USED_NAME,
                                                                        ASSOC_NODE))
                                                                /= D(
                                                                LX_SYMREP,
                                                                HEAD(
                                                                        ARGUMENT_ID_LIST))
                                                                THEN
                        ERROR(D(LX_SRCPOS,
                                                                        ASSOC_NODE)
                                                                ,
                                                                "SELECTOR MUST BE ON =>");
                        RAISE PRAGMA_ERROR;
                     END IF;
                     D(SM_DEFN,D(AS_USED_NAME,
                                                                ASSOC_NODE),
                                                        HEAD(
                                                                ARGUMENT_ID_LIST));
                     ASSOC_EXP := D(AS_EXP,
                                                        ASSOC_NODE);
                  ELSE
                     ASSOC_EXP := ASSOC_NODE;
                  END IF;
                  IF ASSOC_EXP.TY =
                                                        DN_STRING_LITERAL THEN
                     ASSOC_EXP :=
                                                        MAKE_USED_OP_FROM_STRING(
                                                        ASSOC_EXP);
                  END IF;
                  MUST_BE_NAME(ASSOC_EXP);
                  FIND_VISIBILITY(ASSOC_EXP, DEFSET);
                  REQUIRE_UNIQUE_DEF(ASSOC_EXP,
                                                DEFSET);
                  ID := GET_THE_ID(DEFSET);
                  ASSOC_EXP := RESOLVE_NAME(
                                                ASSOC_EXP, ID);
                  IF ID.TY IN CLASS_OBJECT_NAME'
                                                        FIRST ..
                                                        DN_GENERIC_ID
                                                        AND THEN ID.TY /=
                                                        DN_PACKAGE_ID THEN
                     NULL;
                  ELSIF ID /= TREE_VOID THEN
                     ERROR(D(LX_SRCPOS,
                                                                ASSOC_EXP)
                                                        ,
                                                        "SUPPRESS NOT ALLOWED ON THIS");
                  END IF;
                  IF ASSOC_NODE.TY = DN_ASSOC THEN
                     D(AS_EXP, ASSOC_NODE,
                                                        ASSOC_EXP);
                  ELSE
                     ASSOC_NODE := ASSOC_EXP;
                  END IF;
                  NEW_ASSOC_LIST := APPEND(
                                                NEW_ASSOC_LIST, ASSOC_NODE);
               END IF;
         
            WHEN SYSTEM_NAME =>
               ERROR(D(LX_SRCPOS,USED_NAME_ID)
                                        ,
                                        "PRAGMA SYSTEM_NAME NOT SUPPORTED");
               GET_ARGUMENT_EXP( USED_NAME_ID, ASSOC_LIST,
                                        ASSOC_EXP );
         
            WHEN PRENAME.DEBUG =>
               GET_ARGUMENT_NAME
                                        ( USED_NAME_ID
                                        , ASSOC_LIST
                                        , ASSOC_EXP
                                        , NEW_ASSOC_LIST
                                        , ARGUMENT_ID_LIST );
               CASE LIST_ARGUMENTS'VAL(DI(XD_POS,D(
                                                                        SM_DEFN,
                                                                        ASSOC_EXP))) IS
                  WHEN OFF =>
                     IDL.DEBUG := FALSE;
                  WHEN ON =>
                     IDL.DEBUG := TRUE;
               END CASE;
         
         END CASE;
         IF NOT IS_EMPTY(ASSOC_LIST) THEN
            WARNING(D(LX_SRCPOS, USED_NAME_ID),
                                "TOO MANY PRAGMA ARGUMENTS");
            RAISE PRAGMA_ERROR;
         END IF;
      
         LIST(GEN_ASSOC_S, NEW_ASSOC_LIST);
      
      END WALK_PRAGMA_ARGUMENTS;
   
       PROCEDURE GET_ARGUMENT_NAME
                        ( USED_NAME_ID: 	TREE
                        ; ASSOC_LIST:		IN OUT SEQ_TYPE
                        ; ASSOC_OUT:		OUT TREE
                        ; NEW_ASSOC_LIST:	IN OUT SEQ_TYPE
                        ; ARGUMENT_LIST:	SEQ_TYPE )
                        IS
         TEMP_ARGUMENT_LIST:	SEQ_TYPE := ARGUMENT_LIST;
         ARGUMENT_ID:		TREE;
         ACTUAL_SYM:		TREE;
         ASSOC_EXP:		TREE;
      BEGIN
         GET_ARGUMENT_EXP(USED_NAME_ID, ASSOC_LIST, ASSOC_EXP);
--          IF ASSOC_EXP.TY = DN_USED_OBJECT_ID THEN
--          
--          PUT_LINE ( "USED NAME ID : " & PRINT_NAME ( D(LX_SYMREP, USED_NAME_ID) ) );
--          PUT_LINE ( "ASSOC EXP : " & PRINT_NAME ( D(LX_SYMREP,ASSOC_EXP) ) );
--          
--          
--             WARNING(D(LX_SRCPOS,USED_NAME_ID),
--                                 "ARGUMENT ID REQUIRED");
--             RAISE PRAGMA_ERROR;
--          END IF;
      
         ACTUAL_SYM := D(LX_SYMREP, ASSOC_EXP);
         ARGUMENT_ID := TREE_VOID;
         WHILE NOT IS_EMPTY(TEMP_ARGUMENT_LIST) LOOP
            IF D(LX_SYMREP, HEAD(TEMP_ARGUMENT_LIST)) =
                                        ACTUAL_SYM THEN
               ARGUMENT_ID := HEAD(TEMP_ARGUMENT_LIST);
               EXIT;
            END IF;
            TEMP_ARGUMENT_LIST := TAIL(TEMP_ARGUMENT_LIST);
         END LOOP;
         IF ARGUMENT_ID = TREE_VOID THEN
            WARNING(D(LX_SRCPOS,USED_NAME_ID),
                                "ARGUMENT ID INVALID");
            RAISE PRAGMA_ERROR;
         END IF;
      
         D(SM_DEFN, ASSOC_EXP, ARGUMENT_ID);
         NEW_ASSOC_LIST := APPEND
                        ( NEW_ASSOC_LIST, MAKE_USED_NAME_ID_FROM_OBJECT(
                                ASSOC_EXP) );
      
         ASSOC_OUT := ASSOC_EXP;
      END GET_ARGUMENT_NAME;
   
   
       PROCEDURE GET_ARGUMENT_EXP
                        ( USED_NAME_ID: 	TREE
                        ; ASSOC_LIST:           IN OUT SEQ_TYPE
                        ; ASSOC_OUT:		OUT TREE )
                        IS
         ASSOC_EXP: TREE;
      BEGIN
         IF IS_EMPTY(ASSOC_LIST) THEN
            WARNING(D(LX_SRCPOS,USED_NAME_ID),
                                "ARGUMENT REQUIRED");
            RAISE PRAGMA_ERROR;
         END IF;
      
         POP(ASSOC_LIST, ASSOC_EXP);
         IF ASSOC_EXP.TY = DN_STRING_LITERAL THEN
            ASSOC_EXP := MAKE_USED_OP_FROM_STRING(ASSOC_EXP);
         END IF;
      
         ASSOC_OUT := ASSOC_EXP;
      END GET_ARGUMENT_EXP;
   
   
       PROCEDURE MUST_BE_SIMPLE_NAME (EXP: TREE) IS
      BEGIN
         IF EXP.TY /= DN_USED_OBJECT_ID THEN
            WARNING(D(LX_SRCPOS, EXP), "SIMPLE NAME REQUIRED");
            RAISE PRAGMA_ERROR;
         END IF;
      END MUST_BE_SIMPLE_NAME;
   
   
       PROCEDURE MUST_BE_NAME (EXP: TREE) IS
      BEGIN
         IF EXP.TY NOT IN CLASS_DESIGNATOR
                                AND THEN EXP.TY /= DN_SELECTED THEN
            WARNING(D(LX_SRCPOS, EXP), "NAME REQUIRED");
            RAISE PRAGMA_ERROR;
         END IF;
      END MUST_BE_NAME;
   
    --|----------------------------------------------------------------------------------------------
   END PRA_WALK;
