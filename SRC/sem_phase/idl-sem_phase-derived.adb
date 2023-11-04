    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	DERIVED
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY DERIVED IS
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE MAKE_NOD;
      USE REQ_UTIL; -- GET_BASE_STRUCT
   
      DERIVED_DECL_LIST: SEQ_TYPE;
   
       FUNCTION IS_OPERATION_OF_TYPE(DECL_ID, TYPE_SPEC: TREE) RETURN
                BOOLEAN;
       FUNCTION MAKE_DERIVED_SUBPROGRAM
                ( DECL_ID:	TREE
                ; PARENT_TYPE:	TREE
                ; DERIVED_TYPE: TREE
                ; H:		H_TYPE )
                RETURN TREE;
   
   
       FUNCTION MAKE_DERIVED_SUBPROGRAM_LIST
                        ( DERIVED_SUBTYPE: TREE
                        ; PARENT_SUBTYPE: TREE
                        ; H: H_TYPE )
                        RETURN SEQ_TYPE
                        IS
                -- RETURNS A LIST OF DERIVED SUBPROGRAMS FOR THE DERIVED TYPE
         PARENT_TYPE: TREE := GET_BASE_TYPE(PARENT_SUBTYPE);
      
         PARENT_ID: TREE := D(XD_SOURCE_NAME, PARENT_TYPE);
         PARENT_DEF: TREE := GET_DEF_FOR_ID(PARENT_ID);
         PARENT_REGION: TREE := D(XD_REGION, PARENT_ID);
      
         DERIVED_ID: TREE := D(XD_SOURCE_NAME, DERIVED_SUBTYPE);
      
         DECL_LIST: SEQ_TYPE;
         DECL: TREE;
         DECL_ID: TREE;
      
         DERIVED_SUBPROGRAM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      
         DERIVED_OF_PARENT_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         DERIVED_OF_PARENT: TREE;
         DERIVED_OF_PARENT_SYM: TREE;
         DERIVED_FIRST_KIND_LIST: SEQ_TYPE;
      
         TEMP_FIRST_KIND_LIST: SEQ_TYPE;
         TEMP_FIRST_KIND: TREE;
      BEGIN
      
                -- IF PARENT TYPE IS IN VISIBLE PART OF PACKAGE
                -- ... AND CURRENT LOCATION IS NOT IN SAME VISIBLE PART (ERROR)
         IF PARENT_REGION.TY = DN_PACKAGE_ID
                                AND THEN DB(XD_IS_IN_SPEC, PARENT_DEF)
                                AND THEN NOT (H.IS_IN_SPEC
                                AND THEN PARENT_REGION = D(XD_SOURCE_NAME,
                                        H.REGION_DEF) )
                                THEN
         
                        -- SCAN DECL LIST OF VISIBLE PART IN WHICH PARENT IS DEFINED
                        -- ... UNTIL PARENT DECLARATION IS PASSED
                        -- ... ALSO, REMEMBER LIST OF DERIVED SUBPROGRAMS OF PARENT
            DECL_LIST := LIST(D(AS_DECL_S1, D(SM_SPEC,
                                                PARENT_REGION)));
            LOOP
               POP ( DECL_LIST, DECL);
               IF DECL.TY = DN_TYPE_DECL
                                                OR ELSE DECL.TY =
                                                DN_TASK_DECL THEN
                  IF D(AS_SOURCE_NAME, DECL) =
                                                        PARENT_ID THEN
                     EXIT;
                  END IF;
               END IF;
            END LOOP;
         
                        -- FOR EACH REMAINING DECLARATION
            WHILE NOT IS_EMPTY(DECL_LIST) LOOP
               POP(DECL_LIST, DECL);
            
                                -- IF IT IS A SUBPROGRAM OR ENTRY DECLARATION
               IF DECL.TY = DN_SUBPROG_ENTRY_DECL THEN
               
                                        -- IF IT IS AN OPERATION OF THE TYPE (NOTE: ENTRY ISN'T)
                  DECL_ID := D(AS_SOURCE_NAME, DECL);
                  IF IS_OPERATION_OF_TYPE(DECL_ID,
                                                        PARENT_SUBTYPE) THEN
                  
                                                -- MAKE SURE NAME IS IN SYMBOL TABLE
                     IF D(LX_SYMREP,
                                                                        DECL_ID).TY =
                                                                DN_TXTREP THEN
                        D(LX_SYMREP
                                                                , DECL_ID
                                                                , STORE_SYM ( 
                                                                        PRINT_NAME ( 
                                                                                D(
                                                                                        LX_SYMREP,
                                                                                        DECL_ID))) );
                     END IF;
                  
                                                -- MAKE NEW SUBPROGRAM AND ADD TO LIST
                     DERIVED_SUBPROGRAM_LIST :=
                                                        APPEND
                                                        (
                                                        DERIVED_SUBPROGRAM_LIST
                                                        ,
                                                        MAKE_DERIVED_SUBPROGRAM
                                                        ( DECL_ID
                                                                ,
                                                                PARENT_SUBTYPE
                                                                ,
                                                                DERIVED_SUBTYPE
                                                                , H ) );
                  END IF;
               END IF;
            END LOOP;
         END IF;
      
                -- REMEMBER LIST OF DERIVED SUBPROGRAMS OF FIRST KIND
                -- ... (NOTE.  DERIVED OF SECOND KIND ARE INSERTED BEFORE IT)
         DERIVED_FIRST_KIND_LIST := DERIVED_SUBPROGRAM_LIST;
      
                -- GET LIST OF DERIVED SUBPROGRAMS OF PARENT
         IF PARENT_TYPE.TY IN CLASS_DERIVABLE_SPEC
                                AND THEN D(SM_DERIVED,PARENT_TYPE) /=
                                TREE_VOID
                                AND THEN PARENT_TYPE = GET_BASE_STRUCT(
                                PARENT_TYPE)
                                THEN
            DECLARE
               TEMP_DECL_LIST: SEQ_TYPE :=
                                        DERIVED_DECL_LIST;
               TEMP_DECL: TREE;
            BEGIN
               WHILE NOT IS_EMPTY(TEMP_DECL_LIST) LOOP
                  POP(TEMP_DECL_LIST, TEMP_DECL);
               
                  IF D(SM_FIRST,D(AS_SOURCE_NAME,
                                                                TEMP_DECL)) =
                                                        PARENT_ID THEN
                     DERIVED_OF_PARENT_LIST
                                                        := LIST(D(
                                                                AS_TYPE_DEF,
                                                                TEMP_DECL));
                     EXIT;
                  END IF;
               END LOOP;
            END;
         END IF;
      
                -- FOR EACH DERIVED SUBPROGRAM OF PARENT TYPE
         WHILE NOT IS_EMPTY(DERIVED_OF_PARENT_LIST) LOOP
            POP(DERIVED_OF_PARENT_LIST, DERIVED_OF_PARENT);
         
                        -- MAKE SURE NAME IS IN SYMBOL TABLE
            DERIVED_OF_PARENT_SYM := D(LX_SYMREP,
                                DERIVED_OF_PARENT);
            IF DERIVED_OF_PARENT_SYM.TY = DN_TXTREP THEN
               DERIVED_OF_PARENT_SYM
                                        := STORE_SYM ( PRINT_NAME ( D(LX_SYMREP,
                                                        DERIVED_OF_PARENT)));
               D(LX_SYMREP, DERIVED_OF_PARENT,
                                        DERIVED_OF_PARENT_SYM);
            END IF;
         
                        -- FOR EACH DERIVED SUBPROGRAM OF THE FIRST KIND
            TEMP_FIRST_KIND_LIST := DERIVED_FIRST_KIND_LIST;
            WHILE NOT IS_EMPTY(TEMP_FIRST_KIND_LIST) LOOP
               TEMP_FIRST_KIND := HEAD(
                                        TEMP_FIRST_KIND_LIST);
            
                                -- IF IT HIDES THE DERIVED SUBPROGRAM OF THE SECOND KIND
               IF D(LX_SYMREP, TEMP_FIRST_KIND) =
                                                DERIVED_OF_PARENT_SYM
                                                AND THEN
                                                ARE_HOMOGRAPH_HEADERS
                                                ( D(SM_SPEC,
                                                        DERIVED_OF_PARENT)
                                                , D(SM_SPEC
                                                        , D(SM_DERIVABLE
                                                                , D(
                                                                        SM_UNIT_DESC,
                                                                        TEMP_FIRST_KIND) )))
                                                THEN
               
                                        -- CAN'T BE DERIVED OF SECOND KIND (LIST NON-EMPTY AT EXIT)
                  EXIT;
               END IF;
            
               TEMP_FIRST_KIND_LIST := TAIL(
                                        TEMP_FIRST_KIND_LIST);
            END LOOP;
         
                        -- IF NO HIDING DERIVED SUBPROGRAM OF FIRST KIND WAS FOUND
            IF IS_EMPTY(TEMP_FIRST_KIND_LIST) THEN
            
                                -- MAKE NEW SUBPROGRAM AND ADD TO BEGINNING OF LIST
               DERIVED_SUBPROGRAM_LIST := INSERT
                                        ( DERIVED_SUBPROGRAM_LIST
                                        , MAKE_DERIVED_SUBPROGRAM
                                        ( DERIVED_OF_PARENT
                                                , PARENT_SUBTYPE
                                                , DERIVED_SUBTYPE
                                                , H ) );
            END IF;
         END LOOP;
      
                -- RETURN THE LIST OF DERIVED SUBPROGRAMS
         RETURN DERIVED_SUBPROGRAM_LIST;
      END MAKE_DERIVED_SUBPROGRAM_LIST;
   
   
       PROCEDURE REMEMBER_DERIVED_DECL (DECL: TREE) IS
         TYPE_DEF: TREE;
      BEGIN
         IF DECL = TREE_VOID THEN
                        -- (INITIALIZATION CALL -- FROM FIXWITH)
            DERIVED_DECL_LIST := (TREE_NIL,TREE_NIL);
            RETURN;
         END IF;
      
         TYPE_DEF := D(AS_TYPE_DEF, DECL);
         IF TYPE_DEF.TY = DN_DERIVED_DEF
                                AND THEN NOT IS_EMPTY(LIST(TYPE_DEF)) THEN
            DERIVED_DECL_LIST := INSERT(DERIVED_DECL_LIST,
                                DECL);
         END IF;
      END REMEMBER_DERIVED_DECL;
   
   
       FUNCTION IS_OPERATION_OF_TYPE(DECL_ID, TYPE_SPEC: TREE) RETURN
                        BOOLEAN IS
         BASE_TYPE: TREE := GET_BASE_TYPE(TYPE_SPEC);
         HEADER: TREE := D(SM_SPEC, DECL_ID);
         PARAM_CURSOR: PARAM_CURSOR_TYPE;
      BEGIN
      
                -- CHECK FOR ENTRY ID; IF SO, IT IS NOT OPERATION
                -- ... (WHILE WE'RE AT IT, MAKE SURE IT IS A SUBPROGRAM)
         IF DECL_ID.TY NOT IN CLASS_SUBPROG_NAME THEN
            RETURN FALSE;
         END IF;
      
                -- IF IT IS A FUNCTION OR OPERATOR AND RESULT IS OF THE GIVEN TYPE
         IF DECL_ID.TY /= DN_PROCEDURE_ID
                                -- ONLY OTHER POSSIBILITY
                                AND THEN GET_BASE_TYPE(D(AS_NAME, HEADER)) =
                                BASE_TYPE THEN
            RETURN TRUE;
         END IF;
      
                -- FOR EACH PARAMETER
         INIT_PARAM_CURSOR(PARAM_CURSOR, LIST(D(AS_PARAM_S,HEADER)));
         LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            EXIT
                                WHEN PARAM_CURSOR.ID = TREE_VOID;
         
                        -- IF IT IS OF THE PROPER TYPE
            IF GET_BASE_TYPE(PARAM_CURSOR.ID) = BASE_TYPE THEN
            
                                -- IT IS AN OPERATION; RETURN TRUE
               RETURN TRUE;
            END IF;
         END LOOP;
      
                -- NONE FOUND; IT IS NOT AN OPERATION
         RETURN FALSE;
      END IS_OPERATION_OF_TYPE;
   
   
       FUNCTION MAKE_DERIVED_SUBPROGRAM
                        ( DECL_ID:	TREE
                        ; PARENT_TYPE:	TREE
                        ; DERIVED_TYPE: TREE
                        ; H:		H_TYPE )
                        RETURN TREE
                        IS
         NEW_ID: TREE := COPY_NODE(DECL_ID);
         NEW_DEF: TREE := MAKE_DEF_FOR_ID(NEW_ID, H);
         HEADER: TREE := D(SM_SPEC, DECL_ID);
         NEW_HEADER: TREE := COPY_NODE(HEADER);
         NEW_TYPE_MARK: TREE := MAKE_USED_NAME_ID
                        ( LX_SYMREP => D(LX_SYMREP, D(XD_SOURCE_NAME,
                                        DERIVED_TYPE))
                        , SM_DEFN => D(XD_SOURCE_NAME,DERIVED_TYPE) );
         PARAM_CURSOR: PARAM_CURSOR_TYPE;
         NEW_PARAM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         NEW_PARAM_ID: TREE;
         NEW_PARAM_DECL: TREE;
         UNEQUAL_ID: TREE;
      BEGIN
         D(SM_FIRST, NEW_ID, NEW_ID);
         D(SM_UNIT_DESC, NEW_ID, MAKE_DERIVED_SUBPROG
                        ( SM_DERIVABLE => DECL_ID ) );
         D(XD_STUB, NEW_ID, TREE_VOID);
         D(XD_BODY, NEW_ID, TREE_VOID);
         D(SM_SPEC, NEW_ID, NEW_HEADER);
         D(SM_ADDRESS, NEW_ID, TREE_VOID);
      
         MAKE_DEF_VISIBLE(NEW_DEF, NEW_HEADER);
         IF HEADER.TY = DN_FUNCTION_SPEC
                                AND THEN GET_BASE_TYPE(D(AS_NAME,HEADER)) =
                                PARENT_TYPE THEN
            D(AS_NAME,NEW_HEADER,NEW_TYPE_MARK);
         END IF;
         INIT_PARAM_CURSOR(PARAM_CURSOR, LIST(D(AS_PARAM_S,HEADER)));
         LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            EXIT
                                WHEN PARAM_CURSOR.ID = TREE_VOID;
            NEW_PARAM_ID := COPY_NODE(PARAM_CURSOR.ID);
            D(SM_FIRST, NEW_PARAM_ID, NEW_PARAM_ID);
            NEW_PARAM_DECL := COPY_NODE(PARAM_CURSOR.PARAM);
            D(XD_REGION, NEW_PARAM_ID, NEW_ID);
            D(AS_SOURCE_NAME_S, NEW_PARAM_DECL
                                , MAKE_SOURCE_NAME_S(LIST => SINGLETON(
                                                NEW_PARAM_ID)) );
            IF GET_BASE_TYPE(PARAM_CURSOR.ID) = PARENT_TYPE THEN
               D(SM_OBJ_TYPE, NEW_PARAM_ID, DERIVED_TYPE);
               IF D(SM_INIT_EXP, PARAM_CURSOR.ID) /=
                                                TREE_VOID THEN
                  D(SM_INIT_EXP, NEW_PARAM_ID,
                                                MAKE_CONVERSION
                                                ( AS_NAME => NEW_TYPE_MARK
                                                        , AS_EXP => D(
                                                                SM_INIT_EXP,
                                                                PARAM_CURSOR.ID)
                                                        , SM_EXP_TYPE =>
                                                        DERIVED_TYPE ) );
               END IF;
            END IF;
            NEW_PARAM_LIST := APPEND (NEW_PARAM_LIST,
                                NEW_PARAM_DECL);
         END LOOP;
         D(AS_PARAM_S, NEW_HEADER, MAKE_PARAM_S (LIST =>
                                NEW_PARAM_LIST));
      
                -- ALSO DERIVE INEQUALITY IF THIS IS EQUALITY OPERATOR
         IF NEW_ID.TY = DN_OPERATOR_ID THEN
            UNEQUAL_ID := D(XD_NOT_EQUAL, NEW_ID);
            IF UNEQUAL_ID /= TREE_VOID THEN
               UNEQUAL_ID := COPY_NODE(UNEQUAL_ID);
               D(SM_FIRST, UNEQUAL_ID, UNEQUAL_ID);
               D(SM_SPEC, UNEQUAL_ID, NEW_HEADER);
               IF D(LX_SYMREP,UNEQUAL_ID).TY =
                                                DN_SYMBOL_REP THEN
                  MAKE_DEF_VISIBLE
                                                ( MAKE_DEF_FOR_ID(
                                                        UNEQUAL_ID, H)
                                                , NEW_HEADER );
               END IF;
               D(SM_UNIT_DESC
                                        , UNEQUAL_ID
                                        , MAKE_DERIVED_SUBPROG
                                        ( SM_DERIVABLE => D(XD_NOT_EQUAL,
                                                        NEW_ID) ) );
               D(XD_NOT_EQUAL, NEW_ID, UNEQUAL_ID);
            END IF;
         END IF;
      
         RETURN NEW_ID;
      END MAKE_DERIVED_SUBPROGRAM;
   
   --|----------------------------------------------------------------------------------------------
   END DERIVED;
