    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	VIS_UTIL
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY VIS_UTIL IS
      USE EXP_TYPE;
      USE DEF_UTIL;
      USE MAKE_NOD;
      USE REQ_UTIL;
   
       PROCEDURE REDUCE_NAME_TYPES
                ( DEFSET:		IN OUT DEFSET_TYPE
                ; TYPESET:		OUT TYPESET_TYPE );
   
       PROCEDURE FIND_SELECTED_DEFS
                ( NAME_TYPESET: 	IN OUT TYPESET_TYPE
                ; DESIGNATOR:		TREE
                ; DEFSET:		OUT DEFSET_TYPE );
   
       PROCEDURE DEBUG_PRINT_DEF (DEF: TREE) IS
         HEADER: TREE := D ( XD_HEADER, DEF);
         REGION: TREE := D ( XD_REGION_DEF, DEF);
         PARAM_CURSOR: PARAM_CURSOR_TYPE;
         PAREN_OR_COMMA: STRING(1..1) := "(";
      BEGIN
      
         PUT("    ");PUT(NODE_REP(DEF));
         PUT(" ");PUT(NODE_REP(D ( XD_SOURCE_NAME,DEF)));
         PUT(" IN "); PUT(NODE_REP(REGION));
         PUT(INTEGER'IMAGE(DI(XD_LEX_LEVEL,REGION)));
         PUT(" ");PUT_LINE(BOOLEAN'IMAGE(DB(XD_IS_USED,REGION)));
         IF HEADER.TY IN CLASS_SUBP_ENTRY_HEADER THEN
            PUT(ASCII.HT & "(");
            INIT_PARAM_CURSOR(PARAM_CURSOR,
                                LIST(D ( AS_PARAM_S,HEADER)) );
            LOOP
               PUT(PAREN_OR_COMMA);
               PAREN_OR_COMMA := ",";
               ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
               EXIT
                                        WHEN PARAM_CURSOR.ID = TREE_VOID;
               PUT(NODE_REP(GET_BASE_TYPE
                                                (D ( SM_OBJ_TYPE,
                                                                PARAM_CURSOR.ID))));
            END LOOP;
            PUT(")");
            IF HEADER.TY = DN_FUNCTION_SPEC THEN
               PUT("->");
               PUT(NODE_REP(GET_BASE_TYPE(D ( AS_NAME,
                                                                HEADER))));
            END IF;
            NEW_LINE;
         END IF;
      END DEBUG_PRINT_DEF;
   
       PROCEDURE FIND_VISIBILITY(EXP: TREE; DEFSET: OUT DEFSET_TYPE) IS
                -- FOR EXP, A USED_OBJECT_ID OR A SELECTED, RETURN SET
                -- OF DEF NODES FOR VISIBLE DECLARATIONS OF THE USED_OBJECT_ID
                -- OR OF THE DESIGNATOR OF THE SELECTED.  (NOTE: BUILTIN
                -- OPERATIONS ARE NOT CONSIDERED.)
      
      BEGIN
         CASE EXP.TY IS
            WHEN CLASS_DESIGNATOR =>
               FIND_DIRECT_VISIBILITY(EXP, DEFSET);
            WHEN DN_SELECTED =>
               FIND_SELECTED_VISIBILITY(EXP, DEFSET);
            WHEN OTHERS =>
               PUT_LINE ( "!! INVALID ARGUMENT FOR FIND_VISIBILITY" );
               RAISE PROGRAM_ERROR;
         END CASE;
      END FIND_VISIBILITY;
   
       PROCEDURE FIND_DIRECT_VISIBILITY(ID: TREE; DEFSET: OUT DEFSET_TYPE) IS
                -- RETURNS SET OF DIRECTLY-VISIBLE DEF'S FOR USED_OBJECT_ID
      
         NEST_UNIQUE, USED_UNIQUE: TREE := TREE_VOID;
         NEST_OVLOAD, USED_OVLOAD: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         NEST_UNIQUE_LEVEL:	  NATURAL := 0;
         USED_IS_OK:		  BOOLEAN := TRUE;
      
         DEFLIST:	SEQ_TYPE := LIST(D ( LX_SYMREP, ID));
         DEF:		TREE;
         LEVEL:		INTEGER;
         REGION_DEF:	TREE;
      
         DEFLIST_1, DEFLIST_2: SEQ_TYPE;
         DEF_1, DEF_2:	      TREE;
      
         NEW_DEFSET:	DEFSET_TYPE := EMPTY_DEFSET;
      BEGIN
      
                -- FOR EACH DEF FOR THIS NAME
         WHILE NOT IS_EMPTY(DEFLIST) LOOP
            POP(DEFLIST, DEF);
         
                        -- IF IT IS POTENTIALLY STILL VALID (I.E., REGION IS DEFINED)
            REGION_DEF := D ( XD_REGION_DEF, DEF);
            IF REGION_DEF /= TREE_VOID THEN
            
                                -- IF IT IS DEFINED IN CURRENT OR ENCLOSING REGION
               LEVEL := DI(XD_LEX_LEVEL, REGION_DEF);
               IF LEVEL > 0 THEN
               
                                        -- IF IT IS OVERLOADABLE
                  IF IS_OVERLOADABLE_HEADER(D ( 
                                                                XD_HEADER,
                                                                DEF)) THEN
                  
                                                -- ADD TO LIST OF OVERLOADABLE DEFS
                     NEST_OVLOAD := APPEND(
                                                        NEST_OVLOAD, DEF);
                  
                                                -- ELSE IF IT IS NOT OVERLOADABLE
                                                -- ... AND EITHER HIDES PRIOR NESTED NON-OVERLOADABLE
                                                -- ...     OR ERROR AT SAME LEVEL AS PRIOR NON-OVERLOADABLE
                  ELSIF (LEVEL > NEST_UNIQUE_LEVEL)
                                                        OR ELSE (LEVEL =
                                                        NEST_UNIQUE_LEVEL
                                                        AND THEN D ( 
                                                                XD_HEADER,
                                                                DEF) =
                                                        TREE_FALSE)
                                                        THEN
                  
                                                -- REMEMBER THIS DEF AS NON-OVERLOADABLE NESTED
                     NEST_UNIQUE_LEVEL := LEVEL;
                     NEST_UNIQUE := DEF;
                  
                                                -- DISALLOW USED DEFS
                     USED_IS_OK := FALSE;
                  END IF;
               
                                        -- ELSE IF IT USED DEFS ARE NOT KNOWN TO BE DISALLOWED
                                        -- ... AND THE REGION ENCLOSING THIS DEF HAS A USE CLAUSE
                                        -- ... AND THIS DEF IS FROM THE VISIBLE PART
               ELSIF USED_IS_OK
                                                AND THEN DB(XD_IS_USED,
                                                REGION_DEF)
                                                AND THEN DB(XD_IS_IN_SPEC,
                                                DEF) THEN
               
                                        -- IF THIS DEF IS OVERLOADABLE AND NOT ENTRY
                  IF IS_OVERLOADABLE_HEADER(D ( 
                                                                XD_HEADER,
                                                                DEF))
                                                        AND THEN D ( 
                                                                XD_SOURCE_NAME,
                                                                DEF).TY /=
                                                        DN_ENTRY THEN
                  
                                                -- ADD TO LIST OF OVERLOADABLE USED DEFS
                     USED_OVLOAD := APPEND(
                                                        USED_OVLOAD, DEF);
                  
                                                -- ELSE IF THIS IS FIRST NON-OVERLOADABLE USED ENTRY
                                                -- ... OR THERE WAS AN ERROR IN ITS DECLARATION
                  ELSIF USED_UNIQUE = TREE_VOID
                                                        OR ELSE D ( 
                                                        XD_HEADER, DEF) =
                                                        TREE_FALSE THEN
                  
                                                -- SAVE THIS DEF AS NON-OVERLOADABLE NESTED DEF
                     USED_UNIQUE := DEF;
                  
                                                -- ELSE -- SINCE THIS IS A DUPLICATE NON-OVERLOADABLE USED
                  ELSE
                  
                                                -- DISALLOW USED DEFS
                     USED_IS_OK := FALSE;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      
                -- IF THERE ARE BOTH NON-OVERLOADABLE AND OVERLOADABLE NESTED DEFS
         IF NEST_UNIQUE /= TREE_VOID
                                AND THEN NOT IS_EMPTY(NEST_OVLOAD) THEN
         
                        -- DISCARD HIDDEN NESTED DEFS
            DECLARE
               TEMP_OVLOAD:	TREE;
               NEW_DEFLIST:	SEQ_TYPE := (TREE_NIL,TREE_NIL);
            BEGIN
               WHILE NOT IS_EMPTY(NEST_OVLOAD) LOOP
                  POP(NEST_OVLOAD, TEMP_OVLOAD);
                  IF DI(XD_LEX_LEVEL, D ( 
                                                                XD_REGION_DEF,
                                                                TEMP_OVLOAD))
                                                        >
                                                        NEST_UNIQUE_LEVEL
                                                        THEN
                     NEW_DEFLIST := APPEND(
                                                        NEW_DEFLIST,
                                                        TEMP_OVLOAD);
                     NEST_UNIQUE := TREE_VOID;
                  END IF;
               END LOOP;
               NEST_OVLOAD := NEW_DEFLIST;
            END;
         
                        -- DISALLOW USED DEFS
            USED_IS_OK := FALSE;
         END IF;
      
      
                -- IF THERE IS A VISIBLE NON-OVERLOADABLE NESTED DEF
         IF NEST_UNIQUE /= TREE_VOID THEN
         
            DECLARE
               HEADER_KIND:	NODE_NAME := D ( 
                                                XD_HEADER,NEST_UNIQUE).TY;
            BEGIN
            
                                -- IF IT IS NOT YET FULLY DECLARED OR IN ERROR
               IF HEADER_KIND IN CLASS_BOOLEAN THEN
               
                                        -- EMPTY DEFSET IS TO BE RETURNED
                                        -- PUT OUT CORRECT ERROR OR WARNING MESSAGE
                  IF HEADER_KIND = DN_FALSE THEN
                     WARNING( D ( LX_SRCPOS, ID)
                                                        ,
                                                        "PRIOR ERROR IN DECLARATION - "
                                                        & PRINT_NAME ( D ( 
                                                                        LX_SYMREP,
                                                                        ID)) );
                  ELSE
                     ERROR( D ( LX_SRCPOS, ID)
                                                        ,
                                                        "NAME NOT YET VISIBLE - "
                                                        & PRINT_NAME ( D ( 
                                                                        LX_SYMREP,
                                                                        ID)) );
                  END IF;
               
                                        -- ELSE -- SINCE IT IS FULLY DECLARED AND NOT IN ERROR
               ELSE
               
                                        -- THIS IS THE CORRECT DEF
                  ADD_TO_DEFSET(NEW_DEFSET,
                                                NEST_UNIQUE);
               END IF;
            
                                -- RETURN NEW DEFSET
               DEFSET := NEW_DEFSET;
               RETURN;
            END;
         END IF;
      
      
                -- HERE, EITHER THERE ARE NO NESTED DEFS OR ALL ARE OVERLOADABLE
      
                -- IF USED DEFS HAVE BEEN DISALLOWED
                -- ... (BECAUSE NON-OVERLOADED NEST OR BECAUSE MULTIPLE NON-OVERLOADED)
         IF NOT USED_IS_OK THEN
         
                        -- CLEAR USED DEFS
            USED_UNIQUE := TREE_VOID;
            USED_OVLOAD := (TREE_NIL,TREE_NIL);
         END IF;
      
      
                -- IF THERE IS A NON-OVERLOADABLE USED DEF
         IF USED_UNIQUE /= TREE_VOID THEN
         
                        -- IF IT IS FROM A DECLARATION WHICH WAS IN ERROR
            IF D ( XD_HEADER, USED_UNIQUE) = TREE_FALSE THEN
            
                                -- PRINT WARNING
               WARNING( D ( LX_SRCPOS, ID)
                                        ,
                                        "PRIOR ERROR IN (USED) DECLARATION - "
                                        & PRINT_NAME ( D ( LX_SYMREP, ID)) );
            
                                -- RETURN EMPTY DEFSET
               DEFSET := EMPTY_DEFSET;
               RETURN;
            
                                -- ELSE IF THERE ARE NO OVERLOADABLE DEFS
            ELSIF IS_EMPTY(NEST_OVLOAD)
                                        AND THEN IS_EMPTY(USED_OVLOAD) THEN
            
                                -- RETURN THE (UNIQUE) NON-OVERLOADABLE USED DEF
               ADD_TO_DEFSET(NEW_DEFSET, USED_UNIQUE);
               DEFSET := NEW_DEFSET;
               RETURN;
            
                                -- ELSE -- SINCE (1) OVERLOADABLE AND (2) NON-OVERLOADABLE USED DEFS
            ELSE
            
                                -- DISCARD ALL USED DEFS
               USED_UNIQUE := TREE_VOID;
               USED_OVLOAD := (TREE_NIL,TREE_NIL);
            END IF;
         END IF;
      
                -- FIND NESTED DEFS WHICH ARE NOT HIDDEN
         DEFLIST_1 := NEST_OVLOAD;
         WHILE NOT IS_EMPTY(DEFLIST_1) LOOP
            POP(DEFLIST_1, DEF_1);
         
            DEFLIST_2 := NEST_OVLOAD;
            WHILE NOT IS_EMPTY(DEFLIST_2) LOOP
               DEF_2 := HEAD(DEFLIST_2);
               IF DEF_2 /= DEF_1
                                                AND THEN
                                                ARE_HOMOGRAPH_HEADERS
                                                ( D ( XD_HEADER, DEF_1)
                                                , D ( XD_HEADER, DEF_2) )
                                                THEN
                  IF DI(XD_LEX_LEVEL, D ( 
                                                                XD_REGION_DEF,
                                                                DEF_1))
                                                        > DI(XD_LEX_LEVEL,
                                                        D ( XD_REGION_DEF,
                                                                DEF_2))
                                                        THEN
                     NULL;
                  ELSIF DI(XD_LEX_LEVEL, D ( 
                                                                XD_REGION_DEF,
                                                                DEF_1))
                                                        < DI(XD_LEX_LEVEL,
                                                        D ( XD_REGION_DEF,
                                                                DEF_2))
                                                        THEN
                                                -- HIDDEN BY DEF_2
                     EXIT;
                  ELSIF D ( XD_SOURCE_NAME, DEF_1).TY =
                                                        DN_BLTN_OPERATOR_ID
                                                        OR ELSE D ( 
                                                                XD_SOURCE_NAME,
                                                                DEF_1).TY IN
                                                        CLASS_ENUM_LITERAL
                                                        THEN
                                                -- HIDDEN BY DEF_2
                     EXIT;
                  ELSIF D ( XD_SOURCE_NAME, DEF_2).TY =
                                                        DN_BLTN_OPERATOR_ID
                                                        OR ELSE D ( 
                                                                XD_SOURCE_NAME,
                                                                DEF_2).TY IN
                                                        CLASS_ENUM_LITERAL
                                                        THEN
                     NULL;
                  ELSIF D ( XD_SOURCE_NAME, DEF_1).TY IN
                                                        CLASS_SUBPROG_NAME
                                                        AND THEN ( D ( 
                                                                        SM_UNIT_DESC,
                                                                        D ( 
                                                                                XD_SOURCE_NAME,
                                                                                DEF_1)).TY
                                                        =
                                                        DN_DERIVED_SUBPROG
                                                        OR ELSE ( D ( 
                                                                                SM_UNIT_DESC
                                                                                ,
                                                                                D ( 
                                                                                        XD_SOURCE_NAME,
                                                                                        DEF_1)).TY
                                                                =
                                                                DN_IMPLICIT_NOT_EQ
                                                                AND THEN
                                                                D ( 
                                                                                SM_UNIT_DESC
                                                                                ,
                                                                                D ( 
                                                                                        SM_EQUAL,
                                                                                        D ( 
                                                                                                SM_UNIT_DESC
                                                                                                ,
                                                                                                D ( 
                                                                                                        XD_SOURCE_NAME,
                                                                                                        DEF_1)))).TY
                                                                =
                                                                DN_DERIVED_SUBPROG ) )
                                                        THEN
                                                -- HIDDEN BY DEF_2
                     EXIT;
                  ELSIF D ( XD_SOURCE_NAME, DEF_2).TY IN
                                                        CLASS_SUBPROG_NAME
                                                        AND THEN ( D ( 
                                                                        SM_UNIT_DESC,
                                                                        D ( 
                                                                                XD_SOURCE_NAME,
                                                                                DEF_2)).TY
                                                        =
                                                        DN_DERIVED_SUBPROG
                                                        OR ELSE ( D ( 
                                                                                SM_UNIT_DESC
                                                                                ,
                                                                                D ( 
                                                                                        XD_SOURCE_NAME,
                                                                                        DEF_2)).TY
                                                                =
                                                                DN_IMPLICIT_NOT_EQ
                                                                AND THEN
                                                                D ( 
                                                                                SM_UNIT_DESC
                                                                                ,
                                                                                D ( 
                                                                                        SM_EQUAL,
                                                                                        D ( 
                                                                                                SM_UNIT_DESC
                                                                                                ,
                                                                                                D ( 
                                                                                                        XD_SOURCE_NAME,
                                                                                                        DEF_1)))).TY
                                                                =
                                                                DN_DERIVED_SUBPROG ) )
                                                        THEN
                     NULL;
                  ELSE
                                                -- HIDDEN BY DEF_2
                     EXIT;
                  END IF;
               END IF;
               DEFLIST_2 := TAIL(DEFLIST_2);
            END LOOP;
            IF IS_EMPTY(DEFLIST_2) THEN
               ADD_TO_DEFSET(NEW_DEFSET, DEF_1);
            END IF;
         END LOOP;
      
                -- FIND USED DEFS WHICH ARE NOT HIDDEN
         DEFLIST_1 := USED_OVLOAD;
         WHILE NOT IS_EMPTY(DEFLIST_1) LOOP
            POP(DEFLIST_1, DEF_1);
         
                        -- CHECK FOR USED DEFS HIDDEN BY NESTED DEFS
            DEFLIST_2 := NEST_OVLOAD;
            WHILE NOT IS_EMPTY(DEFLIST_2) LOOP
               DEF_2 := HEAD(DEFLIST_2);
               IF ARE_HOMOGRAPH_HEADERS
                                                ( D ( XD_HEADER, DEF_1)
                                                , D ( XD_HEADER, DEF_2) )
                                                THEN
                                        -- HIDDEN BY DEF_2
                  EXIT;
               END IF;
               DEFLIST_2 := TAIL(DEFLIST_2);
            
            END LOOP;
         
                        -- IF NOT HIDDEN BY NESTED DEF
            IF IS_EMPTY(DEFLIST_2) THEN
            
                                -- CHECK IF HIDDEN BY ANOTHER USED DEF
               DEFLIST_2 := USED_OVLOAD;
               WHILE NOT IS_EMPTY(DEFLIST_2) LOOP
                  DEF_2 := HEAD(DEFLIST_2);
                  IF DEF_2 /= DEF_1
                                                        AND THEN
                                                        ARE_HOMOGRAPH_HEADERS
                                                        ( D ( XD_HEADER,
                                                                DEF_1)
                                                        , D ( XD_HEADER,
                                                                DEF_2) )
                                                        THEN
                  
                     IF D ( XD_REGION_DEF, DEF_1) /=
                                                                D ( 
                                                                XD_REGION_DEF,
                                                                DEF_2) THEN
                                                        -- BOTH ARE MADE VISIBLE (BUT WILL BE AMBIGUOUS)
                        NULL;
                     ELSIF D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_1).TY =
                                                                DN_BLTN_OPERATOR_ID
                                                                OR ELSE
                                                                D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_1).TY IN
                                                                CLASS_ENUM_LITERAL
                                                                THEN
                                                        -- HIDDEN BY DEF_2
                        EXIT;
                     ELSIF D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_2).TY =
                                                                DN_BLTN_OPERATOR_ID
                                                                OR ELSE
                                                                D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_2).TY IN
                                                                CLASS_ENUM_LITERAL
                                                                THEN
                        NULL;
                     ELSIF D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_1).TY IN
                                                                CLASS_SUBPROG_NAME
                                                                AND THEN ( D ( 
                                                                                SM_UNIT_DESC,
                                                                                D ( 
                                                                                        XD_SOURCE_NAME,
                                                                                        DEF_1)).TY
                                                                =
                                                                DN_DERIVED_SUBPROG
                                                                OR ELSE ( D ( 
                                                                                        SM_UNIT_DESC
                                                                                        ,
                                                                                        D ( 
                                                                                                XD_SOURCE_NAME,
                                                                                                DEF_1)).TY
                                                                        =
                                                                        DN_IMPLICIT_NOT_EQ
                                                                        AND THEN D ( 
                                                                                        SM_UNIT_DESC
                                                                                        ,
                                                                                        D ( 
                                                                                                SM_EQUAL,
                                                                                                D ( 
                                                                                                        SM_UNIT_DESC
                                                                                                        ,
                                                                                                        D ( 
                                                                                                                XD_SOURCE_NAME,
                                                                                                                DEF_1)))).TY
                                                                        =
                                                                        DN_DERIVED_SUBPROG ) )
                                                                THEN
                                                        -- HIDDEN BY DEF_2
                        EXIT;
                     ELSIF D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF_2).TY IN
                                                                CLASS_SUBPROG_NAME
                                                                AND THEN (
                                                                D ( 
                                                                                SM_UNIT_DESC,
                                                                                D ( 
                                                                                        XD_SOURCE_NAME,
                                                                                        DEF_2)).TY
                                                                =
                                                                DN_DERIVED_SUBPROG
                                                                OR ELSE ( D ( 
                                                                                        SM_UNIT_DESC
                                                                                        ,
                                                                                        D ( 
                                                                                                XD_SOURCE_NAME,
                                                                                                DEF_2)).TY
                                                                        =
                                                                        DN_IMPLICIT_NOT_EQ
                                                                        AND THEN D ( 
                                                                                        SM_UNIT_DESC
                                                                                        ,
                                                                                        D ( 
                                                                                                SM_EQUAL,
                                                                                                D ( 
                                                                                                        SM_UNIT_DESC
                                                                                                        ,
                                                                                                        D ( 
                                                                                                                XD_SOURCE_NAME,
                                                                                                                DEF_1)))).TY
                                                                        =
                                                                        DN_DERIVED_SUBPROG ) )
                                                                THEN
                        NULL;
                     ELSE
                                                        -- HIDDEN BY DEF_2
                        EXIT;
                     END IF;
                  END IF;
                  DEFLIST_2 := TAIL(DEFLIST_2);
               END LOOP;
            END IF;
            IF IS_EMPTY(DEFLIST_2) THEN
               ADD_TO_DEFSET(NEW_DEFSET, DEF_1);
            END IF;
         END LOOP;
      
         IF IS_EMPTY(NEW_DEFSET) THEN
            ERROR(D ( LX_SRCPOS, ID)
                                , "NO DIRECTLY VISIBLE DECLARATION - "
                                & PRINT_NAME ( D ( LX_SYMREP, ID)) );
         END IF;
         DEFSET := NEW_DEFSET;
      END FIND_DIRECT_VISIBILITY;
   
        ----------------------------------------------------------------
        ----------------------------------------------------------------
   
       PROCEDURE FIND_SELECTED_VISIBILITY(SELECTED: TREE; DEFSET: OUT
                        DEFSET_TYPE)
                        IS
                -- GIVEN A SELECTED NODE, FIND ALL VISIBLE DEF'S FOR THE DESIGNATOR
      
         NAME:		TREE := D ( AS_NAME, SELECTED);
         DESIGNATOR:	TREE := D ( AS_DESIGNATOR, SELECTED);
      
         NEW_DEFSET:		DEFSET_TYPE := EMPTY_DEFSET;
      
         NAME_DEFSET:		DEFSET_TYPE := EMPTY_DEFSET;
         NAME_DEFINTERP: 	DEFINTERP_TYPE;
         NAME_DEF:		TREE := TREE_VOID;
         NAME_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
      
         TEMP_LIST:		SEQ_TYPE;
         TEMP:			TREE;
      BEGIN
                -- IF DESIGNATOR IS A STRING, MAKE IT A USED_OP
         IF DESIGNATOR.TY = DN_STRING_LITERAL THEN
            DESIGNATOR := MAKE_USED_OP_FROM_STRING(DESIGNATOR);
            D ( AS_DESIGNATOR, SELECTED, DESIGNATOR);
         END IF;
      
                -- ACCORDING TO THE KIND OF PREFIX
         CASE CLASS_EXP'(NAME.TY) IS
         
            WHEN DN_USED_OBJECT_ID =>
                                -- FOR USED_OBJECT_ID, FIND DIRECT VISIBILITY
               FIND_DIRECT_VISIBILITY(NAME, NAME_DEFSET);
         
            WHEN DN_STRING_LITERAL =>
                                -- FOR STRING, MAKE IT A USED_OP AND FIND DIRECT VISIBILITY
               NAME := MAKE_USED_OP_FROM_STRING(NAME);
               D ( AS_NAME, SELECTED, NAME);
            
               FIND_DIRECT_VISIBILITY(NAME, NAME_DEFSET);
         
            WHEN DN_SELECTED =>
                                -- FOR SELECTED, FIND SELECTED VISIBILITY
               FIND_SELECTED_VISIBILITY(NAME
                                        , NAME_DEFSET );
         
            WHEN OTHERS =>
                                -- OTHERWISE, MUST BE EXPRESSION; FIND POSSIBLE TYPES
               EVAL_EXP_TYPES(NAME, NAME_TYPESET);
         END CASE;
      
                -- IF WE FOUND SOME NAME DEF'S
         IF NOT IS_EMPTY(NAME_DEFSET) THEN
         
                        -- IF THERE IS AN ENCLOSING REGION
            NAME_DEF := GET_ENCLOSING_DEF(NAME, NAME_DEFSET);
            IF NAME_DEF /= TREE_VOID THEN
            
                                -- IT'S THE ONLY INTERPRETATION OF THE NAME
                                -- LOOK FOR ENTITIES IMMEDIATELY WITHIN THE ENCLOSING REGION
                                -- (NOTE.  RM 4.1.3/10 HAS PREFERENCE RULE ONLY FOR
                                --  ... ENCLOSING SUBPROGRAM OR ACCEPT STATEMENT; HOWEVER
                                --  ... IF, E.G., ENCLOSING PACKAGE, ONLY ONE IS VISIBLE ANYWAY)
               TEMP_LIST := LIST(D ( LX_SYMREP, DESIGNATOR));
               WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
                  POP(TEMP_LIST, TEMP);
                  IF D ( XD_REGION_DEF, TEMP) =
                                                        NAME_DEF THEN
                     ADD_TO_DEFSET(NEW_DEFSET,
                                                        TEMP);
                  END IF;
               END LOOP;
            
            
                                -- ELSE IF PREFIX IS A PACKAGE NAME
            ELSIF GET_THE_ID(NAME_DEFSET).TY =
                                        DN_PACKAGE_ID THEN
            
                                -- IT'S THE ONLY INTERPRETATION OF THE NAME
                                -- CHECK FOR RENAMING; USE ORIGINAL PACKAGE
               NAME_DEFINTERP := HEAD(NAME_DEFSET);
               NAME_DEF := GET_DEF(NAME_DEFINTERP);
               IF D ( SM_UNIT_DESC,D ( XD_SOURCE_NAME,
                                                                NAME_DEF)).TY
                                                = DN_RENAMES_UNIT
                                                THEN
                  NAME_DEF := GET_DEF_FOR_ID(
                                                GET_BASE_PACKAGE
                                                ( D ( XD_SOURCE_NAME,
                                                                NAME_DEF) ) );
               END IF;
            
                                -- LOOK FOR ENTITIES DEFINED IMMEDIATELY WITHIN SPECIFICATION
               TEMP_LIST := LIST(D ( LX_SYMREP, DESIGNATOR));
               WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
                  POP(TEMP_LIST, TEMP);
                  IF D ( XD_REGION_DEF, TEMP) =
                                                        NAME_DEF
                                                        AND THEN DB(
                                                        XD_IS_IN_SPEC,
                                                        TEMP) THEN
                     ADD_TO_DEFSET(NEW_DEFSET,
                                                        TEMP);
                  END IF;
               END LOOP;
            END IF;
         END IF;
      
                -- IF IT IS AN EXPANDED NAME
         IF NAME_DEF /= TREE_VOID THEN
         
                        -- MAKE THE PREFIX A USED_NAME_ID IF IT IS AN IDENTIFIER
                        -- AND STORE THE DEFINITION
            IF NAME.TY = DN_SELECTED THEN
               IF D ( AS_DESIGNATOR, NAME).TY =
                                                DN_USED_OBJECT_ID THEN
                  D ( AS_DESIGNATOR, NAME, MAKE_USED_NAME_ID_FROM_OBJECT ( D ( AS_DESIGNATOR, NAME ) ) );
               END IF;
               D ( SM_DEFN, D ( AS_DESIGNATOR, NAME), D ( 
                                                XD_SOURCE_NAME, NAME_DEF));
            ELSE
               IF NAME.TY = DN_USED_OBJECT_ID THEN
                  NAME := MAKE_USED_NAME_ID_FROM_OBJECT ( NAME );
                  D ( AS_NAME, SELECTED, NAME );
               END IF;
               D ( SM_DEFN, NAME, D ( XD_SOURCE_NAME,
                                                NAME_DEF));
            END IF;
         
                        -- DISCARD HIDDEN IMPLICIT SUBPROGRAMS
            DECLARE
               OLD_DEFSET: DEFSET_TYPE := NEW_DEFSET;
               OLD_DEFINTERP: DEFINTERP_TYPE;
               OLD_ID: TREE;
               TEMP_DEFSET: DEFSET_TYPE;
               TEMP_DEFINTERP: DEFINTERP_TYPE;
               TEMP_ID: TREE;
               NEW_NEW_DEFSET: DEFSET_TYPE :=
                                        EMPTY_DEFSET;
            BEGIN
               WHILE NOT IS_EMPTY(OLD_DEFSET) LOOP
                  POP(OLD_DEFSET, OLD_DEFINTERP);
                  OLD_ID := D ( XD_SOURCE_NAME,
                                                GET_DEF(OLD_DEFINTERP));
                  IF OLD_ID.TY =
                                                        DN_BLTN_OPERATOR_ID
                                                        OR ELSE OLD_ID.TY IN
                                                        CLASS_ENUM_LITERAL
                                                        OR ELSE ( OLD_ID.TY IN
                                                        CLASS_SUBPROG_NAME
                                                        AND THEN D ( 
                                                                        SM_UNIT_DESC,
                                                                        OLD_ID).TY
                                                        = DN_INSTANTIATION )
                                                        THEN
                     TEMP_DEFSET := NEW_DEFSET;
                     WHILE NOT IS_EMPTY(
                                                                TEMP_DEFSET) LOOP
                        TEMP_DEFINTERP :=
                                                                HEAD(
                                                                TEMP_DEFSET);
                        IF TEMP_DEFINTERP /=
                                                                        OLD_DEFINTERP
                                                                        AND THEN
                                                                        ARE_HOMOGRAPH_HEADERS
                                                                        (
                                                                        D ( 
                                                                                XD_HEADER,
                                                                                GET_DEF(
                                                                                        OLD_DEFINTERP))
                                                                        ,
                                                                        D ( 
                                                                                XD_HEADER,
                                                                                GET_DEF(
                                                                                        TEMP_DEFINTERP)))
                                                                        THEN
                           IF OLD_ID.TY = DN_BLTN_OPERATOR_ID
                                                                                OR ELSE OLD_ID.TY IN
                                                                                CLASS_ENUM_LITERAL THEN
                              EXIT;
                           ELSE
                              TEMP_ID :=
                                                                                D ( 
                                                                                XD_SOURCE_NAME
                                                                                ,
                                                                                GET_DEF(
                                                                                        TEMP_DEFINTERP) );
                              IF
                                                                                        TEMP_ID.TY /=
                                                                                        DN_BLTN_OPERATOR_ID
                                                                                        AND THEN TEMP_ID.TY
                                                                                        NOT IN
                                                                                        CLASS_ENUM_LITERAL
                                                                                        THEN
                                 EXIT;
                              END IF;
                           END IF;
                        END IF;
                        POP(TEMP_DEFSET,
                                                                TEMP_DEFINTERP);
                     END LOOP;
                     IF IS_EMPTY(TEMP_DEFSET) THEN
                        ADD_TO_DEFSET(
                                                                NEW_NEW_DEFSET,
                                                                OLD_DEFINTERP);
                     END IF;
                  ELSE
                     ADD_TO_DEFSET(
                                                        NEW_NEW_DEFSET,
                                                        OLD_DEFINTERP);
                  END IF;
               END LOOP;
               NEW_DEFSET := NEW_NEW_DEFSET;
            END;
         
                        -- ELSE IF IT IS A DEFINED NAME OR A SELECTED, IT MUST BE AN EXPRESSION
         ELSIF NOT IS_EMPTY(NAME_DEFSET) THEN
            REDUCE_NAME_TYPES(NAME_DEFSET, NAME_TYPESET);
            STASH_DEFSET(NAME, NAME_DEFSET);
         END IF;
      
                -- IF EXPRESSION, ONLY CONSIDER TYPES WHICH HAVE SELECTED COMPONENTS
         IF NOT IS_EMPTY(NAME_TYPESET) THEN
            FIND_SELECTED_DEFS(NAME_TYPESET, DESIGNATOR,
                                NEW_DEFSET);
         END IF;
         IF NAME.TY /= DN_USED_NAME_ID THEN
            STASH_TYPESET(NAME, NAME_TYPESET);
         END IF;
      
                -- CHECK FOR NO DECLARATIONS FOUND
         IF IS_EMPTY(NEW_DEFSET)
                                AND THEN NOT (IS_EMPTY(NAME_DEFSET) AND THEN
                                IS_EMPTY(NAME_TYPESET))
                                THEN
            ERROR(D ( LX_SRCPOS,DESIGNATOR)
                                , "NOT VISIBLE BY SELECTION - "
                                & PRINT_NAME ( D ( LX_SYMREP,DESIGNATOR)) );
         
                        -- CHECK FOR ERROR OR NOT-YET-VISIBLE DECLARATION
         ELSE
            DECLARE
               TEMP_DEFSET:	DEFSET_TYPE := NEW_DEFSET;
               TEMP_DEFINTERP: DEFINTERP_TYPE;
               HEADER_KIND:	NODE_NAME;
            BEGIN
            
                                -- FOR EACH DEF
               WHILE NOT IS_EMPTY(TEMP_DEFSET) LOOP
                  POP(TEMP_DEFSET, TEMP_DEFINTERP);
               
                                        -- IF IT IS NOT YET FULLY DECLARED OR IN ERROR
                  HEADER_KIND := D ( XD_HEADER,
                                                        GET_DEF(
                                                                TEMP_DEFINTERP)).TY;
                  IF HEADER_KIND IN CLASS_BOOLEAN THEN
                  
                                                -- EMPTY DEFSET IS TO BE RETURNED
                     NEW_DEFSET := EMPTY_DEFSET;
                  
                                                -- PUT OUT CORRECT ERROR OR WARNING MESSAGE
                     IF HEADER_KIND = DN_FALSE THEN
                        WARNING( D ( 
                                                                        LX_SRCPOS,
                                                                        DESIGNATOR)
                                                                ,
                                                                "PRIOR ERROR IN DECLARATION - "
                                                                &
                                                                PRINT_NAME ( 
                                                                        D ( 
                                                                                LX_SYMREP,
                                                                                DESIGNATOR)) );
                     ELSE
                        ERROR( D ( 
                                                                        LX_SRCPOS,
                                                                        DESIGNATOR)
                                                                ,
                                                                "NAME NOT YET VISIBLE - "
                                                                &
                                                                PRINT_NAME ( 
                                                                        D ( 
                                                                                LX_SYMREP,
                                                                                DESIGNATOR)) );
                     END IF;
                  END IF;
               END LOOP;
            END;
         END IF;
      
                -- COPY RESULTS TO OUT ARGUMENT AND RETURN
         DEFSET := NEW_DEFSET;
      END FIND_SELECTED_VISIBILITY;
   
        ----------------------------------------------------------------
   
       FUNCTION GET_ENCLOSING_DEF(USED_NAME: TREE; DEFSET: DEFSET_TYPE)
                        RETURN TREE
                        IS
                -- GETS INNERMOST ENCLOSING NAME IN DEFSET
                -- DEFSET HAS NAMES DEFINED IN ENCLOSING REGIONS FIRST
                -- NOTE.  PARAMETER USED_NAME ONLY FOR ERROR MESSAGES
      
         TEMP_DEFSET:	DEFSET_TYPE := DEFSET;
         DEFINTERP:	DEFINTERP_TYPE;
         DEF:		TREE;
      
         ENCLOSING_DEF:	TREE := TREE_VOID;
         IS_MULTIPLE_DEF:BOOLEAN := FALSE;
      BEGIN
                -- FOR EACH DEF IN DEFSET
         WHILE NOT IS_EMPTY(TEMP_DEFSET) LOOP
            POP(TEMP_DEFSET, DEFINTERP);
            DEF := GET_DEF(DEFINTERP);
         
                        -- STOP LOOKING IF NOT DEFINED IN ENCLOSING REGION
            IF DI(XD_LEX_LEVEL, D ( XD_REGION_DEF, DEF)) = 0 THEN
               EXIT;
            END IF;
         
                        -- IF IT IS AN ENCLOSING REGION, HAVE FOUND ONE
            IF DI(XD_LEX_LEVEL, DEF) > 0 THEN
            
                                -- IF THIS IS THE FIRST ONE FOUND
               IF ENCLOSING_DEF = TREE_VOID THEN
               
                                        -- THEN REMEMBER IT
                  ENCLOSING_DEF := DEF;
               ELSE
                                        -- ELSE REMEMBER THAT ERROR OCCURRED
                  IS_MULTIPLE_DEF := TRUE;
               
                                        -- ALSO RETAIN MOST-DEEPLY-NESTED RESULT
                  IF DI(XD_LEX_LEVEL, DEF) > DI(
                                                        XD_LEX_LEVEL,
                                                        ENCLOSING_DEF)
                                                        THEN
                     ENCLOSING_DEF := DEF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      
                -- IF MULTIPLE DEFINITION WAS SEEN
         IF IS_MULTIPLE_DEF THEN
         
                        -- PUT OUT ERROR MESSAGE
            ERROR(D ( LX_SRCPOS, USED_NAME),
                                "AMBIGUOUS ENCLOSING REGION");
         END IF;
      
                -- RETURN MOST-DEEPLY-NESTED DEF, IF FOUND, OR VOID
         RETURN ENCLOSING_DEF;
      END GET_ENCLOSING_DEF;
      --|-------------------------------------------------------------------------------------------
      --|	MAKE_USED_NAME_ID_FROM_OBJECT
       FUNCTION MAKE_USED_NAME_ID_FROM_OBJECT ( USED_OBJECT_ID :TREE ) RETURN TREE IS
       SRC_POS	: TREE	:= D ( LX_SRCPOS, USED_OBJECT_ID );
       SYMREP	: TREE	:= D ( LX_SYMREP, USED_OBJECT_ID );
       DEFN	: TREE	:= D ( SM_DEFN, USED_OBJECT_ID );
      BEGIN
         RETURN MAKE_USED_NAME_ID ( LX_SRCPOS => SRC_POS, LX_SYMREP => SYMREP, SM_DEFN => DEFN );
      END;
   
        ----------------------------------------------------------------
   
       FUNCTION MAKE_USED_OP_FROM_STRING(STRING_NODE: TREE) RETURN TREE IS
      
          FUNCTION MAKE_UPPER_CASE (A: STRING) RETURN STRING IS
            A_WORK: STRING(1 .. A'LENGTH) := A;
            MAGIC: CONSTANT := CHARACTER'POS('A') - CHARACTER'
                                POS('A');
         BEGIN
            FOR I IN A_WORK'RANGE LOOP
               IF A_WORK(I) IN 'A' .. 'Z' THEN
                  A_WORK(I) := CHARACTER'VAL(
                                                CHARACTER'POS(A_WORK(I))-
                                                MAGIC);
               END IF;
            END LOOP;
            RETURN A_WORK;
         END MAKE_UPPER_CASE;
      
      BEGIN -- MAKE_USED_OP_FROM_STRING
         RETURN MAKE_USED_OP
                        ( LX_SRCPOS => D ( LX_SRCPOS, STRING_NODE)
                        , LX_SYMREP
                        => STORE_SYM ( MAKE_UPPER_CASE(PRINT_NAME
                                        (D ( LX_SYMREP,STRING_NODE)) )));
      END MAKE_USED_OP_FROM_STRING;
   
        ----------------------------------------------------------------
   
       PROCEDURE REDUCE_NAME_TYPES
                        ( DEFSET:		IN OUT DEFSET_TYPE
                        ; TYPESET:		OUT TYPESET_TYPE )
                        IS
                -- REDUCES DEFSET TO NAMES WHICH HAVE A TYPE (ARE EXPRESSIONS)
                -- (NOTE THAT FUNCTIONS REQUIRING PARAMETERS ARE DISCARDED HERE)
      
         DEFINTERP:		DEFINTERP_TYPE;
         DEF:			TREE;
      
         NEW_DEFSET:		DEFSET_TYPE := EMPTY_DEFSET;
         NEW_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
         TYPE_SPEC:		TREE;
      BEGIN
         WHILE NOT IS_EMPTY(DEFSET) LOOP
            POP(DEFSET, DEFINTERP);
            DEF := GET_DEF(DEFINTERP);
            TYPE_SPEC := EXPRESSION_TYPE_OF_DEF(DEF);
         
            IF TYPE_SPEC /= TREE_VOID THEN
               ADD_TO_DEFSET(NEW_DEFSET, DEFINTERP);
               ADD_TO_TYPESET(NEW_TYPESET, TYPE_SPEC
                                        , GET_EXTRAINFO(DEFINTERP) );
            END IF;
         END LOOP;
      
         DEFSET := NEW_DEFSET;
         TYPESET := NEW_TYPESET;
      END REDUCE_NAME_TYPES;
   
        ----------------------------------------------------------------
   
       FUNCTION EXPRESSION_TYPE_OF_DEF(DEF: TREE) RETURN TREE IS
                -- RETURNS BASE TYPE IF DEF REPRESENTS AN EXPRESSION
                -- OTHERWISE RETURNS VOID
      
         ID:		CONSTANT TREE := D ( XD_SOURCE_NAME, DEF);
         HEADER: 	CONSTANT TREE := D ( XD_HEADER, DEF);
      BEGIN
         IF ID.TY = DN_NUMBER_ID THEN
            IF D ( SM_OBJ_TYPE,ID).TY = DN_UNIVERSAL_REAL THEN
               RETURN MAKE(DN_ANY_REAL);
            ELSE
               RETURN MAKE(DN_ANY_INTEGER);
            END IF;
         ELSIF ID.TY IN CLASS_OBJECT_NAME THEN
            RETURN GET_BASE_TYPE(D ( SM_OBJ_TYPE, ID));
         ELSIF HEADER.TY = DN_FUNCTION_SPEC
                                AND THEN ALL_PARAMETERS_HAVE_DEFAULTS(
                                HEADER) THEN
            RETURN GET_BASE_TYPE(D ( AS_NAME, HEADER));
         ELSIF ID.TY IN CLASS_TYPE_NAME
                                AND THEN GET_BASE_TYPE(ID).TY =
                                DN_TASK_SPEC
                                AND THEN DI(XD_LEX_LEVEL, GET_DEF_FOR_ID
                                ( D ( XD_SOURCE_NAME, GET_BASE_TYPE(ID)) ))
                                > 0
                                THEN
            RETURN GET_BASE_TYPE(ID);
         ELSE
            RETURN TREE_VOID;
         END IF;
      END EXPRESSION_TYPE_OF_DEF;
   
        ----------------------------------------------------------------
   
       FUNCTION ALL_PARAMETERS_HAVE_DEFAULTS(HEADER: TREE) RETURN BOOLEAN IS
                -- GIVEN A SUBPROGRAM OR ENTRY HEADER, TEST IF ALL DECLARED
                -- PARAMETERS HAVE A DEFAULT VALUE (OR THERE ARE NO PARAMETERS)
      
         PARAM_LIST:	SEQ_TYPE := LIST(D ( AS_PARAM_S, HEADER));
         PARAM:		TREE;
      BEGIN
                -- FOR EACH PARAMETER DECLARATION
         WHILE NOT IS_EMPTY(PARAM_LIST) LOOP
            POP(PARAM_LIST, PARAM);
         
                        -- IF IT DOES NOT HAVE A DEFAULT VALUE
            IF D ( AS_EXP, PARAM) = TREE_VOID THEN
            
                                -- THEN ALL PARAMETERS DO NOT HAVE DEFAULTS; RETURN FALSE
               RETURN FALSE;
            END IF;
         END LOOP;
      
                -- NO PARAMETERS FOUND WITHOUT DEFAULT; RETURN TRUE
         RETURN TRUE;
      
      END ALL_PARAMETERS_HAVE_DEFAULTS;
   
        ----------------------------------------------------------------
   
        --- $$$$ TEMPORARY $$$$$$$$$$$$$$
       FUNCTION IS_OVERLOADABLE_HEADER(HEADER: TREE) RETURN BOOLEAN IS
      BEGIN
         IF HEADER.TY = DN_FUNCTION_SPEC
                                OR HEADER.TY = DN_PROCEDURE_SPEC
                                OR HEADER.TY = DN_ENTRY
                                THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IS_OVERLOADABLE_HEADER;
   
        ----------------------------------------------------------------
   
       FUNCTION CAST_TREE (ARG: SEQ_TYPE) RETURN TREE IS
      BEGIN
         RETURN ARG.FIRST;
      END CAST_TREE;
   
       FUNCTION CAST_SEQ_TYPE (ARG: TREE) RETURN SEQ_TYPE IS
      BEGIN
         RETURN SINGLETON(ARG);
      END CAST_SEQ_TYPE;
   
        ----------------------------------------------------------------
   
       FUNCTION COPY_NODE ( NODE : TREE ) RETURN TREE IS
         RESULT	: TREE;
         LENGTH	: ATTR_NBR;
      BEGIN
         IF NODE.LN = 0 THEN
            RETURN NODE;
         ELSE
            LENGTH := DABS( 0, NODE ).LN;
            RESULT := MAKE( NODE.TY, LENGTH );
            FOR I IN 1 .. LENGTH LOOP
               DABS( I, RESULT, DABS( I, NODE ) );
            END LOOP;
            RETURN RESULT;
         END IF;
      END COPY_NODE;
   
        ----------------------------------------------------------------
   
       PROCEDURE FIND_SELECTED_DEFS
                        ( NAME_TYPESET: 	IN OUT TYPESET_TYPE
                        ; DESIGNATOR:		TREE
                        ; DEFSET:		OUT DEFSET_TYPE )
                        IS
                -- GIVEN A LIST OF TYPES AND A DESIGNATOR, FIND THOSE
                -- DEFS FOR THE DESIGNATOR SUCH THAT SELECTED IS VALID EXPRESSION
      
         DESIGNATOR_DEFLIST:	CONSTANT SEQ_TYPE
                        := LIST(D ( LX_SYMREP, DESIGNATOR));
         TEMP_NAME_TYPESET	: TYPESET_TYPE := NAME_TYPESET;
         NAME_TYPEINTERP	: TYPEINTERP_TYPE;
         NAME_STRUCT	: TREE;
         NAME_TYPE_ID	: TREE;
         NAME_DEF		: TREE;
      
         TEMP_DEFLIST	: SEQ_TYPE;
         TEMP_DEF		: TREE;
      
         NEW_TYPESET	: TYPESET_TYPE	:= EMPTY_TYPESET;
         NEW_DEFSET		: DEFSET_TYPE	:= EMPTY_DEFSET;
      BEGIN
      
                -- FOR EACH POSSIBLE NAME TYPE
         WHILE NOT IS_EMPTY(TEMP_NAME_TYPESET) LOOP
            POP( TEMP_NAME_TYPESET, NAME_TYPEINTERP );
            NAME_STRUCT := GET_BASE_STRUCT( GET_TYPE( NAME_TYPEINTERP ) );
         
                        -- IF ACCESS TYPE, CONSIDER DESIGNATED TYPE
            IF NAME_STRUCT.TY = DN_ACCESS THEN
               NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE,NAME_STRUCT ) );
            END IF;
         
                        -- IF IT IS RECORD OR TASK TYPE
            IF NAME_STRUCT.TY = DN_RECORD
                                        OR NAME_STRUCT.TY =
                                        DN_TASK_SPEC
                                        OR NAME_STRUCT.TY IN
                                        CLASS_PRIVATE_SPEC THEN
            
                                -- GET REGION DEF
               NAME_TYPE_ID := D ( XD_SOURCE_NAME,
                                        NAME_STRUCT);
               IF NAME_TYPE_ID.TY = DN_TYPE_ID THEN
                  NAME_TYPE_ID := D ( SM_FIRST,
                                                NAME_TYPE_ID);
               END IF;
               NAME_DEF := GET_DEF_FOR_ID(NAME_TYPE_ID);
            
                                -- SEARCH DEFLIST FOR COMPONENTS OR ENTRIES IN THAT REGION
               TEMP_DEFLIST := DESIGNATOR_DEFLIST;
               WHILE NOT IS_EMPTY(TEMP_DEFLIST) LOOP
                  POP(TEMP_DEFLIST, TEMP_DEF);
                  IF NAME_DEF = D ( XD_REGION_DEF,
                                                        TEMP_DEF) THEN
                     IF D ( XD_HEADER,
                                                                        TEMP_DEF).TY IN
                                                                CLASS_BOOLEAN THEN
                                                        -- IN ERROR, RETURN THIS ONE AND QUIT LOOKING
                        NEW_DEFSET :=
                                                                EMPTY_DEFSET;
                        ADD_TO_DEFSET(
                                                                NEW_DEFSET,
                                                                TEMP_DEF);
                        DEFSET :=
                                                                NEW_DEFSET;
                        NAME_TYPESET :=
                                                                EMPTY_TYPESET;
                        RETURN;
                     END IF;
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET,
                                                        NAME_TYPEINTERP);
                     ADD_TO_DEFSET
                                                        ( NEW_DEFSET
                                                        , TEMP_DEF
                                                        , GET_EXTRAINFO(
                                                                NAME_TYPEINTERP) );
                  END IF;
               END LOOP;
            
                                -- RETURN NEW SETS
            END IF;
         END LOOP;
         NAME_TYPESET := NEW_TYPESET;
         DEFSET := NEW_DEFSET;
      
      END FIND_SELECTED_DEFS;
   
        ----------------------------------------------------------------
   
       PROCEDURE INIT_PARAM_CURSOR
                        ( CURSOR:		OUT PARAM_CURSOR_TYPE
                        ; PARAM_LIST:		SEQ_TYPE)
                        IS
      BEGIN
         CURSOR.PARAM_LIST := PARAM_LIST;
         CURSOR.ID_LIST := (TREE_NIL,TREE_NIL);
      END INIT_PARAM_CURSOR;
   
        ----------------------------------------------------------------
   
       PROCEDURE ADVANCE_PARAM_CURSOR (CURSOR: IN OUT PARAM_CURSOR_TYPE) IS
      BEGIN
         IF IS_EMPTY(CURSOR.ID_LIST) THEN
            IF IS_EMPTY(CURSOR.PARAM_LIST) THEN
               CURSOR.ID := TREE_VOID;
               RETURN;
            ELSE
               POP(CURSOR.PARAM_LIST, CURSOR.PARAM);
               IF CURSOR.PARAM.TY = DN_NULL_COMP_DECL THEN
                  CURSOR.ID := TREE_VOID;
                  RETURN;
               END IF;
               CURSOR.ID_LIST := LIST(D ( AS_SOURCE_NAME_S,
                                                CURSOR.PARAM));
            END IF;
         END IF;
         POP(CURSOR.ID_LIST, CURSOR.ID);
      END ADVANCE_PARAM_CURSOR;
   
   END VIS_UTIL;
