    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	STM_WALK
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY STM_WALK IS
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE SET_UTIL;
      USE REQ_UTIL;
      USE EXP_TYPE, EXPRESO;
      USE SEM_GLOB;
      USE NOD_WALK;
      USE MAKE_NOD;
      USE RED_SUBP;
      USE DEF_WALK;
   
        -- COUNT USED TO GENERATE UNIQUE NAMES FOR BLOCKS AND LOOPS WITHOUT NAMES
      GEN_BLOCK_LOOP_COUNT: NATURAL := 0;
   
        ------------------------------------------------------------------------
        --		DECLARE_LABEL_BLOCK_LOOP_IDS				  --
        ------------------------------------------------------------------------
   
       PROCEDURE DECLARE_ONE_LABEL_BLOCK_LOOP_ID
                ( SOURCE_NAME:	TREE
                ; STM:		TREE
                ; H:		H_TYPE );
   
   
       PROCEDURE CHECK_DUMMY_BLOCK_LOOP_NAME(ID: TREE; PREFIX_TEXT:
                STRING);
       FUNCTION TRIM(A: STRING) RETURN STRING;
   
       PROCEDURE DECLARE_LABEL_BLOCK_LOOP_IDS(STM_S: TREE; H: H_TYPE) IS
                -- FOR A SEQUENCE OF STATEMENTS, SCAN FOR LABEL_ID'S AND
                -- ... BLOCK_LOOP_ID'S AND CREATE DEF NODES FOR THEM. (LABEL_IS'S
                -- ... AND BLOCK_LOOP_ID'S ARE IMPLICITLY DECLARED AT THE END
                -- ... OF THE DECLARATIVE PART OF A BLOCK OR UNIT)
      
         STM_LIST:	SEQ_TYPE := LIST(STM_S);
         STM:		TREE;
      BEGIN
      
                -- FOR EACH STATEMENT IN THE STM_S
         WHILE NOT IS_EMPTY(STM_LIST) LOOP
            POP(STM_LIST, STM);
         
                        -- IF THIS STATEMENT HAS LABELS
            IF STM.TY = DN_LABELED THEN
               DECLARE
                  SOURCE_NAME_S: CONSTANT TREE := D(
                                                AS_SOURCE_NAME_S, STM);
                  STM_NODE: CONSTANT TREE := D(
                                                AS_STM, STM);
               
                  SOURCE_NAME_LIST: SEQ_TYPE := LIST(
                                                SOURCE_NAME_S);
                  SOURCE_NAME: TREE;
               BEGIN
                                        -- FOR EACH LABEL ON THIS STATEMENT
                  WHILE NOT IS_EMPTY(
                                                        SOURCE_NAME_LIST) LOOP
                     POP(SOURCE_NAME_LIST,
                                                        SOURCE_NAME);
                  
                                                -- DEFINE THE LABEL
                     DECLARE_ONE_LABEL_BLOCK_LOOP_ID
                                                        (SOURCE_NAME,
                                                        STM_NODE, H);
                  END LOOP;
               
                                        -- STRIP LABELS FROM THE STATEMENT
                  STM := STM_NODE;
               END;
            END IF;
         
                        -- STM NOW HAS LABELS STRIPPED OFF
                        -- DEFINE BLOCK AND LOOP NAMES
                        --	 AND SCAN SUBORDINATE STATEMENTS FOR LABELS AND NAMES
         
            CASE STM.TY IS
            
                                -- FOR A CASE STATEMENT
               WHEN DN_CASE =>
                  DECLARE
                     ALTERNATIVE_S: CONSTANT
                                                        TREE := D(
                                                        AS_ALTERNATIVE_S,
                                                        STM);
                  
                     ALTERNATIVE_LIST: SEQ_TYPE :=
                                                        LIST(
                                                        ALTERNATIVE_S);
                     ALTERNATIVE: TREE;
                  BEGIN
                  
                                                -- FOR EACH ALTERNATIVE
                     WHILE NOT IS_EMPTY(
                                                                ALTERNATIVE_LIST) LOOP
                        POP(
                                                                ALTERNATIVE_LIST,
                                                                ALTERNATIVE);
                     
                                                        -- IF IT IS AN ALTERNATIVE (RATHER THAN A PRAGMA)
                        IF ALTERNATIVE.TY =
                                                                        DN_ALTERNATIVE THEN
                        
                                                                -- SCAN FOR LABELS IN THE SEQUENCE OF STATEMENTS
                           DECLARE_LABEL_BLOCK_LOOP_IDS
                                                                        (
                                                                        D(
                                                                                AS_STM_S,
                                                                                ALTERNATIVE),
                                                                        H);
                        END IF;
                     END LOOP;
                  END;
            
                                -- FOR AN ACCEPT STATEMENT
               WHEN DN_ACCEPT =>
                  DECLARE
                     STM_S: CONSTANT TREE := D(
                                                        AS_STM_S, STM);
                  BEGIN
                                                -- SCAN FOR LABELS IN THE SEQUENCE OF STATEMENTS
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S, H);
                  END;
            
                                -- FOR A LOOP STATEMENT
               WHEN DN_LOOP =>
                  DECLARE
                     SOURCE_NAME: CONSTANT TREE :=
                                                        D(AS_SOURCE_NAME,
                                                        STM);
                     SOURCE_DEF: TREE;
                     STM_S: CONSTANT TREE := D(
                                                        AS_STM_S, STM);
                  BEGIN
                                                -- MAKE SURE THERE IS A NAME
                     CHECK_DUMMY_BLOCK_LOOP_NAME(
                                                        SOURCE_NAME,
                                                        "LOOP__");
                  
                                                -- DEFINE THE LABEL
                     DECLARE_ONE_LABEL_BLOCK_LOOP_ID(
                                                        SOURCE_NAME, STM,
                                                        H);
                     SOURCE_DEF :=
                                                        GET_DEF_FOR_ID(
                                                        SOURCE_NAME);
                  
                                                -- SCAN FOR LABELS IN THE SEQUENCE OF STATEMENTS
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S, H);
                  END;
            
                                -- FOR A BLOCK STATEMENT
               WHEN DN_BLOCK =>
                  DECLARE
                     SOURCE_NAME: CONSTANT TREE :=
                                                        D(AS_SOURCE_NAME,
                                                        STM);
                     BLOCK_BODY: CONSTANT TREE :=
                                                        D(AS_BLOCK_BODY,
                                                        STM);
                  BEGIN
                                                -- MAKE SURE THERE IS A NAME
                     CHECK_DUMMY_BLOCK_LOOP_NAME(
                                                        SOURCE_NAME,
                                                        "BLOCK__");
                  
                                                -- DEFINE THE LABEL
                     DECLARE_ONE_LABEL_BLOCK_LOOP_ID(
                                                        SOURCE_NAME, STM,
                                                        H);
                  END;
            
                                -- FOR A CONDITIONAL ENTRY CALL OR TIMED ENTRY CALL
               WHEN DN_COND_ENTRY | DN_TIMED_ENTRY =>
                  DECLARE
                     STM_S1: CONSTANT TREE := D(
                                                        AS_STM_S1, STM);
                     STM_S2: CONSTANT TREE := D(
                                                        AS_STM_S2, STM);
                  BEGIN
                                                -- SCAN FOR LABELS IN BOTH SEQUENCES OF STATEMENTS
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S1, H);
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S2, H);
                  END;
            
                                -- FOR AN IF STATEMENT OR A SELECTIVE WAIT STATEMENT
               WHEN DN_IF | DN_SELECTIVE_WAIT =>
                  DECLARE
                     TEST_CLAUSE_ELEM_S: CONSTANT
                                                        TREE
                                                        := D(
                                                        AS_TEST_CLAUSE_ELEM_S,
                                                        STM);
                     STM_S: CONSTANT TREE := D(
                                                        AS_STM_S, STM);
                  
                     TEST_CLAUSE_ELEM_LIST:
                                                        SEQ_TYPE := LIST(
                                                        TEST_CLAUSE_ELEM_S);
                     TEST_CLAUSE_ELEM: TREE;
                  BEGIN
                  
                                                -- FOR EACH TEST_CLAUSE_ELEM
                     WHILE NOT IS_EMPTY(
                                                                TEST_CLAUSE_ELEM_LIST) LOOP
                        POP(
                                                                TEST_CLAUSE_ELEM_LIST,
                                                                TEST_CLAUSE_ELEM);
                     
                                                        -- IF IT IS A TEST_CLAUSE (RATHER THAN A PRAGMA)
                        IF TEST_CLAUSE_ELEM.TY IN
                                                                        CLASS_TEST_CLAUSE THEN
                        
                                                                -- SCAN FOR LABELS IN THE SEQUENCE OF STATEMENTS
                           DECLARE_LABEL_BLOCK_LOOP_IDS
                                                                        (
                                                                        D(
                                                                                AS_STM_S,
                                                                                TEST_CLAUSE_ELEM),
                                                                        H);
                        END IF;
                     END LOOP;
                  
                                                -- SCAN FOR LABELS IN THE IF/WAIT SEQUENCE OF STATEMENTS
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S, H);
                  END;
            
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END LOOP;
      END DECLARE_LABEL_BLOCK_LOOP_IDS;
   
   
       PROCEDURE DECLARE_ONE_LABEL_BLOCK_LOOP_ID
                        ( SOURCE_NAME:	TREE
                        ; STM:		TREE
                        ; H:		H_TYPE )
                        IS
                -- (CALLED ONLY BY DECLARE_LABEL_BLOCK_LOOP_IDS)
                -- CREATES DEF NODE FOR THE SOURCE NAME AND SETS ITS SM_STM
                -- ... ATTRIBUTE TO THE STATEMENT REFERRED TO
      
         SOURCE_DEF: TREE := MAKE_DEF_FOR_ID(SOURCE_NAME, H);
      BEGIN
         MAKE_DEF_VISIBLE(SOURCE_DEF);
         D(SM_STM, SOURCE_NAME, STM);
      END DECLARE_ONE_LABEL_BLOCK_LOOP_ID;
   
       PROCEDURE CHECK_DUMMY_BLOCK_LOOP_NAME(ID: TREE; PREFIX_TEXT:
                        STRING) IS
      BEGIN
         IF D(LX_SYMREP, ID) = TREE_VOID THEN
            GEN_BLOCK_LOOP_COUNT := GEN_BLOCK_LOOP_COUNT + 1;
            D(LX_SYMREP, ID,
                                STORE_SYM (  PREFIX_TEXT
                                        & TRIM(INTEGER'IMAGE(
                                                        GEN_BLOCK_LOOP_COUNT)) ) );
         END IF;
      END CHECK_DUMMY_BLOCK_LOOP_NAME;
   
       FUNCTION TRIM(A: STRING) RETURN STRING IS
         FIRST: NATURAL := A'FIRST;
         LAST: NATURAL := A'LAST;
      BEGIN
         WHILE LAST > 0 AND THEN (A(LAST) = ' ' OR A(LAST) =
                                ASCII.HT) LOOP
            LAST := LAST - 1;
         END LOOP;
         IF LAST >= FIRST THEN
            WHILE A(FIRST) = ' ' OR A(FIRST) = ASCII.HT LOOP
               FIRST := FIRST + 1;
            END LOOP;
         END IF;
         DECLARE
            RESULT: STRING(1 .. LAST - FIRST + 1) := A(FIRST ..
                                LAST);
         BEGIN
            RETURN RESULT;
         END;
      END TRIM;
   
        ------------------------------------------------------------------------
        --		WALK_STM_S						  --
        ------------------------------------------------------------------------
   
       PROCEDURE WALK_STM_S(STM_S: TREE; H: H_TYPE) IS
         STM_LIST: SEQ_TYPE := LIST(STM_S);
         STM: TREE;
      
         NEW_STM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      BEGIN
                -- FOR EACH STM IN THE SEQUENCE OF STATEMENTS
         WHILE NOT IS_EMPTY(STM_LIST) LOOP
            POP(STM_LIST, STM);
         
                        -- WALK THE STATEMENT AND ADD TO NEW STATEMENT LIST
            NEW_STM_LIST := APPEND(NEW_STM_LIST, WALK_STM(STM,
                                        H));
         END LOOP;
      
                -- REPLACE STATEMENT LIST WITH NEW STATEMENT LIST
         LIST(STM_S, NEW_STM_LIST);
      END WALK_STM_S;
   
        ------------------------------------------------------------------------
        --		WALK_ALTERNATIVE_S					  --
        ------------------------------------------------------------------------
   
       PROCEDURE WALK_ALTERNATIVE_S(ALTERNATIVE_S: TREE; H: H_TYPE) IS
         ALTERNATIVE_LIST: SEQ_TYPE;
         ALTERNATIVE_ELEM: TREE;
      
         CHOICE_S: TREE;
         CHOICE_LIST: SEQ_TYPE;
         CHOICE: TREE;
         CHOICE_EXP: TREE;
         STM_S: TREE;
      BEGIN
                -- IF THERE IS NO EXCEPTION PART
         IF ALTERNATIVE_S = TREE_VOID THEN
         
                        -- DO NOTHING AND RETURN
            RETURN;
         END IF;
      
                -- FOR EACH ELEMENT OF THE ALTERNATIVE LIST
         ALTERNATIVE_LIST := LIST(ALTERNATIVE_S);
         WHILE NOT IS_EMPTY(ALTERNATIVE_LIST) LOOP
            POP(ALTERNATIVE_LIST, ALTERNATIVE_ELEM);
         
                        -- IF IT IS AN ALTERNATIVE
            IF ALTERNATIVE_ELEM.TY = DN_ALTERNATIVE THEN
            
                                -- FOR EACH CHOICE
               CHOICE_S := D(AS_CHOICE_S,
                                        ALTERNATIVE_ELEM);
               CHOICE_LIST := LIST(CHOICE_S);
               WHILE NOT IS_EMPTY(CHOICE_LIST) LOOP
                  POP(CHOICE_LIST, CHOICE);
               
                                        -- IF IT IS AN OTHERS CHOICE
                  IF CHOICE.TY = DN_CHOICE_OTHERS THEN
                  
                                                -- NOTHING TO DO
                     NULL;
                  
                                                -- ELSE IF IT IS AN EXPRESSION CHOICE
                  ELSIF CHOICE.TY = DN_CHOICE_EXP THEN
                  
                                                -- RESOLVE EXCEPTION NAME
                     CHOICE_EXP := D(AS_EXP,
                                                        CHOICE);
                     CHOICE_EXP := WALK_NAME(
                                                        DN_EXCEPTION_ID,
                                                        CHOICE_EXP);
                     D(AS_EXP, CHOICE,
                                                        CHOICE_EXP);
                  
                                                -- ELSE
                  ELSE
                  
                                                -- IT CANNOT BE A VALID CHOICE
                     ERROR(D(LX_SRCPOS,CHOICE),
                                                        "INVALID CHOICE");
                  END IF;
               
                                        -- WALK THE STATEMENT SEQUENCE
               END LOOP;
               STM_S := D(AS_STM_S, ALTERNATIVE_ELEM);
               WALK_STM_S(STM_S, H);
            
                                -- ELSE -- SINCE IT MUST BE A PRAGMA
            ELSE
            
                                -- WALK THE PRAGMA
               WALK(D(AS_PRAGMA, ALTERNATIVE_ELEM), H);
            
            END IF;
         END LOOP;
      
      END WALK_ALTERNATIVE_S;
   
        ------------------------------------------------------------------------
        --		WALK_STM						  --
        ------------------------------------------------------------------------
   
       FUNCTION WALK_STM (STM_IN: TREE; H: H_TYPE) RETURN TREE IS
         STM: TREE := STM_IN;
         STM_KIND: NODE_NAME := STM.TY;
      BEGIN
      
         IF STM_KIND NOT IN CLASS_STM_ELEM THEN
            PUT_LINE ( "WALK_STM: NOT A STM_ELEM NODE" );
            RAISE PROGRAM_ERROR;
         END IF;
      
      
         CASE CLASS_STM_ELEM'(STM_KIND) IS
         
                        -- FOR TERMINATE OR NULL STATEMENT
            WHEN  DN_TERMINATE | DN_NULL_STM =>
            
                                -- NOTHING NEEDS TO BE DONE
               NULL;
         
         
                        -- FOR A LABELED STATEMENT
            WHEN DN_LABELED =>
               DECLARE
                                        --SOURCE_NAME_S: CONSTANT TREE := D(AS_SOURCE_NAME_S, STM);
                  PRAGMA_S: CONSTANT TREE := D(
                                                AS_PRAGMA_S, STM);
                  STM_NODE: TREE := D(AS_STM, STM);
               BEGIN
                                        -- $$$$ NEED TO CHECK FOR DUPLICATE DEF IN UNIT
                                        --WALK(SOURCE_NAME_S, H);
               
                                        -- WALK PRAGMAS BETWEEN THE LABELS AND THE STATEMENT
                  WALK_ITEM_S(PRAGMA_S, H);
               
                                        -- WALK THE STATEMENT
                  STM_NODE := WALK_STM(STM_NODE, H);
                  D(AS_STM, STM, STM_NODE);
               END;
         
         
                        -- FOR AN ABORT STATEMENT
            WHEN DN_ABORT =>
               DECLARE
                  NAME_S: CONSTANT TREE := D(
                                                AS_NAME_S, STM);
               
                  NAME_LIST: SEQ_TYPE := LIST(
                                                NAME_S);
                  NAME: TREE;
                  TYPESET: TYPESET_TYPE;
                  NEW_NAME_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
               BEGIN
                                        -- FOR EACH NAME IN THE SEQUENCE OF NAMES
                  WHILE NOT IS_EMPTY(NAME_LIST) LOOP
                     POP(NAME_LIST, NAME);
                  
                                                -- PROCESS THE NAME
                     EVAL_EXP_TYPES(NAME,
                                                        TYPESET);
                     REQUIRE_TASK_TYPE(NAME,
                                                        TYPESET);
                     REQUIRE_UNIQUE_TYPE(NAME,
                                                        TYPESET);
                     NAME := RESOLVE_EXP(NAME,
                                                        TYPESET);
                  
                                                -- ADD TO NEW NAME LIST
                     NEW_NAME_LIST := APPEND(
                                                        NEW_NAME_LIST,
                                                        NAME);
                  
                                                -- REPLACE NAME LIST WITH NEW NAME LIST
                  END LOOP;
                  LIST(NAME_S, NEW_NAME_LIST);
               END;
         
         
                        -- FOR A RETURN STATEMENT
            WHEN DN_RETURN =>
               DECLARE
                  EXP: TREE := D(AS_EXP, STM);
               
                  TYPESET: TYPESET_TYPE;
               BEGIN
               
                                        -- IF AN EXPRESSION IS GIVEN
                  IF EXP /= TREE_VOID THEN
                  
                                                -- $$$$ CHECK THAT IT IS WITHIN A FUNCTION
                  
                                                -- RESOLVE THE EXPRESSION
                     EVAL_EXP_TYPES(EXP,
                                                        TYPESET);
                     REQUIRE_TYPE(
                                                        H.RETURN_TYPE, EXP,
                                                        TYPESET);
                     EXP := RESOLVE_EXP(EXP,
                                                        TYPESET);
                     D(AS_EXP, STM, EXP);
                  
                                                -- $$$$ ELSE -- SINCE THERE IS NO EXPRESSION GIVEN
                  
                                                -- $$$$ CHECK THAT IT IS NOT WITHIN A FUNCTION
                  
                  END IF;
               END;
         
         
                        -- FOR A DELAY STATEMENT
            WHEN DN_DELAY =>
               DECLARE
                  EXP: TREE := D(AS_EXP, STM);
               
                  TYPESET: TYPESET_TYPE;
               BEGIN
               
                                        -- REQUIRE EXPRESSION TO BE OF TYPE DURATION
                  EVAL_EXP_TYPES(EXP, TYPESET);
                  REQUIRE_TYPE(GET_BASE_TYPE(
                                                        PREDEFINED_DURATION),
                                                EXP, TYPESET);
                  EXP := RESOLVE_EXP(EXP, TYPESET);
                  D(AS_EXP, STM, EXP);
               END;
         
         
                        -- FOR AN ASSIGNMENT STATEMENT
            WHEN DN_ASSIGN =>
               DECLARE
                  EXP: TREE := D(AS_EXP, STM);
                  NAME: TREE := D(AS_NAME, STM);
               
                  NAME_TYPESET: TYPESET_TYPE;
                  EXP_TYPESET: TYPESET_TYPE;
                  TYPESET: TYPESET_TYPE;
               BEGIN
                                        -- REQUIRE SAME NONLIMITED TYPE
                  EVAL_EXP_TYPES(NAME, NAME_TYPESET);
                  EVAL_EXP_TYPES(EXP, EXP_TYPESET);
                  REQUIRE_NONLIMITED_TYPE(NAME,
                                                NAME_TYPESET);
                  REQUIRE_SAME_TYPES
                                                ( NAME, NAME_TYPESET
                                                , EXP, EXP_TYPESET
                                                , TYPESET );
               
                                        -- RESOLVE EXP
                  EXP := RESOLVE_EXP(EXP, TYPESET);
                  D(AS_EXP, STM, EXP);
               
                                        -- RESOLVE NAME
                  NAME := RESOLVE_EXP(NAME, TYPESET);
                  D(AS_NAME, STM, NAME);
               
                                        -- $$$$ NEED TO CHECK THAT NAME CAN BE ASSIGNED TO
               END;
         
         
                        -- FOR AN EXIT STATEMENT
            WHEN DN_EXIT =>
               DECLARE
                  EXP: TREE := D(AS_EXP, STM);
                  NAME: TREE := D(AS_NAME, STM);
               
                  TYPESET: TYPESET_TYPE;
                  LOOP_ID: TREE;
               BEGIN
                                        -- IF AN EXPRESSION IS GIVEN
                  IF EXP /= TREE_VOID THEN
                  
                                                -- REQUIRE SOME BOOLEAN TYPE
                     EVAL_EXP_TYPES(EXP,
                                                        TYPESET);
                     REQUIRE_BOOLEAN_TYPE(EXP,
                                                        TYPESET);
                     EXP := RESOLVE_EXP(EXP,
                                                        TYPESET);
                     D(AS_EXP, STM, EXP);
                  END IF;
               
                                        -- IF A LOOP NAME IS GIVEN
                  IF NAME /= TREE_VOID THEN
                  
                                                -- REQUIRE A BLOCK_LOOP_ID FOR ENCLOSING LOOP
                     NAME := WALK_NAME(
                                                        DN_BLOCK_LOOP_ID,
                                                        NAME);
                     LOOP_ID := D(SM_DEFN, NAME);
                  
                                                -- $$$$ CHECK THAT IT IS AN ENCLOSING LOOP
                  
                                                -- ELSE -- SINCE NO LOOP NAME IS GIVEN
                  ELSE
                  
                                                -- USE ID OF ENCLOSING LOOP
                     LOOP_ID :=
                                                        H.ENCLOSING_LOOP_ID;
                  
                                                -- CHECK THAT THERE IS ONE
                     IF LOOP_ID = TREE_VOID THEN
                        ERROR(D(LX_SRCPOS,
                                                                        STM)
                                                                ,
                                                                "EXIT STATEMENT NOT IN A LOOP" );
                     END IF;
                  END IF;
               
                                        -- IF THE PROPER ENCLOSING LOOP HAS BEEN FOUND
                  IF LOOP_ID /= TREE_VOID THEN
                  
                                                -- COPY POINTER TO THE LOOP STM INTO THE EXIT STM
                     D(SM_STM, STM, D(SM_STM,
                                                                LOOP_ID));
                  END IF;
               END;
         
         
                        -- FOR A CODE STATEMENT
            WHEN DN_CODE =>
               DECLARE
               BEGIN
               
                                        -- ERROR -- NOT SUPPORTED
                  ERROR(D(LX_SRCPOS, STM),
                                                "CODE STATEMENT NOT SUPPORTED");
               END;
         
         
                        -- FOR A CASE STATEMENT
            WHEN DN_CASE =>
               DECLARE
                  EXP: TREE := D(AS_EXP, STM);
                  ALTERNATIVE_S: CONSTANT TREE := D(
                                                AS_ALTERNATIVE_S, STM);
               
                  TYPESET: TYPESET_TYPE;
                  REQUIRED_TYPE: TREE;
               
                  ALTERNATIVE_LIST: SEQ_TYPE := LIST(
                                                ALTERNATIVE_S);
                  ALTERNATIVE: TREE;
               
               BEGIN
               
                                        -- RESOLVE CASE EXPRESSION (A COMPLETE CONTEXT)
                  EVAL_EXP_TYPES(EXP, TYPESET);
                  REQUIRE_DISCRETE_TYPE(EXP, TYPESET);
                                        -- $$$$ REQUIRE_NOT_GENERIC_FORMAL_TYPE(EXP, TYPESET);
                                        -- ???? IS THIS USED IN OVERLOAD RESOLUTION?
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  REQUIRED_TYPE := GET_THE_TYPE(
                                                TYPESET);
                  EXP := RESOLVE_EXP(EXP,
                                                REQUIRED_TYPE);
                  D(AS_EXP, STM, EXP);
               
                                        -- FOR EACH ELEMENT OF THE ALTERNATIVE LIST
                  WHILE NOT IS_EMPTY(
                                                        ALTERNATIVE_LIST) LOOP
                     POP(ALTERNATIVE_LIST,
                                                        ALTERNATIVE);
                  
                                                -- IF IT IS A PRAGMA
                     IF ALTERNATIVE.TY =
                                                                DN_ALTERNATIVE_PRAGMA THEN
                     
                                                        -- WALK THE PRAGMA
                        WALK(D(AS_PRAGMA,
                                                                        ALTERNATIVE),
                                                                H);
                     
                                                        -- ELSE -- SINCE IT MUST BE AN ALTERNATIVE
                     ELSE
                     
                                                        -- WALK THE LIST OF CHOICES
                        WALK_DISCRETE_CHOICE_S
                                                                ( D(
                                                                        AS_CHOICE_S,
                                                                        ALTERNATIVE)
                                                                ,
                                                                REQUIRED_TYPE );
                     
                                                        -- WALK THE SEQUENCE OF STATEMENTS FOR THIS CHOICE
                        WALK_STM_S( D(
                                                                        AS_STM_S,
                                                                        ALTERNATIVE),
                                                                H);
                     END IF;
                  END LOOP;
               
                                        -- $$$$ CHECK THAT CHOICES ARE COMPLETE AND NOT OVERLAPPING
               END;
         
         
                        -- FOR A GOTO STATEMENT
            WHEN DN_GOTO =>
               DECLARE
                  NAME: TREE := D(AS_NAME, STM);
               
               BEGIN
               
                                        -- EVALUATE THE LABEL NAME
                  NAME := WALK_NAME(DN_LABEL_ID,
                                                NAME);
                  D(AS_NAME, STM, NAME);
               
                                        -- $$$$ CHECK THAT GOTO TARGET IS LEGAL
               END;
         
         
                        -- FOR A RAISE STATEMENT
            WHEN DN_RAISE =>
               DECLARE
                  NAME: TREE := D(AS_NAME, STM);
               BEGIN
               
                                        -- IF AN EXCEPTION NAME IS GIVEN
                  IF NAME /= TREE_VOID THEN
                  
                                                -- EVALUATE THE EXCEPTION NAME
                     NAME := WALK_NAME(
                                                        DN_EXCEPTION_ID,
                                                        NAME);
                     D(AS_NAME, STM, NAME);
                  END IF;
               END;
         
         
                        -- FOR AN ENTRY CALL OR A PROCEDURE CALL
            WHEN DN_PROCEDURE_CALL | DN_ENTRY_CALL =>
               DECLARE
                  NAME: TREE := D(AS_NAME, STM);
                  GENERAL_ASSOC_S: CONSTANT TREE :=
                                                D(AS_GENERAL_ASSOC_S, STM);
               
                  INDEX_LIST: SEQ_TYPE;
                  INDEX: TREE := TREE_VOID;
                  INDEX_TYPESET: TYPESET_TYPE;
                  DISCRETE_RANGE: TREE;
               
                  NAME_DEFSET: DEFSET_TYPE;
                  NAME_ID: TREE;
               BEGIN
                                        -- IF CALL IS OF THE FORM ...(...)(...)
                  IF NAME.TY = DN_FUNCTION_CALL THEN
                  
                                                -- SYNTAX ONLY ALLOWS CALL OF MEMBER OF ENTRY FAMILY
                                                -- SEPARATE THE INDEX FROM THE NAME
                     INDEX_LIST := LIST(D(
                                                                AS_GENERAL_ASSOC_S,
                                                                NAME));
                     POP(INDEX_LIST, INDEX);
                     NAME := D(AS_NAME, NAME);
                  
                                                -- IF THE INDEX HAS NAMED NOTATION
                     IF INDEX.TY = DN_ASSOC THEN
                     
                                                        -- REPORT ERROR
                        ERROR(D(LX_SRCPOS,
                                                                        INDEX),
                                                                "NAMED NOTATION FOR INDEX");
                     
                                                        -- EVALUATE EXPRESSION TYPES ANYWAY
                        INDEX := D(AS_EXP,
                                                                INDEX);
                        EVAL_EXP_TYPES(
                                                                INDEX,
                                                                INDEX_TYPESET);
                     
                                                        -- AND THROW AWAY ALL INTERPRETATIONS OF THE INDEX
                        INDEX_TYPESET :=
                                                                EMPTY_TYPESET;
                     
                                                        -- ELSE -- SINCE INDEX DOES NOT HAVE NAMED NOTATION
                     ELSE
                     
                                                        -- EVALUATE EXPRESSION TYPES
                        EVAL_EXP_TYPES(
                                                                INDEX,
                                                                INDEX_TYPESET);
                     END IF;
                  
                                                -- IF THERE IS MORE THAN ONE INDEX EXPRESSION
                     IF NOT IS_EMPTY(
                                                                INDEX_LIST) THEN
                     
                                                        -- REPORT ERROR
                        ERROR(D(LX_SRCPOS,
                                                                        INDEX),
                                                                "MORE THAN ONE ENTRY INDEX");
                     
                                                        -- AND THROW AWAY ALL INTERPRETATIONS OF THE INDEX
                        INDEX_TYPESET :=
                                                                EMPTY_TYPESET;
                     END IF;
                  
                                                -- SAVE INDEX INTERPRETATIONS
                     STASH_TYPESET(INDEX,
                                                        INDEX_TYPESET);
                  END IF;
               
                                        -- GET VISIBLE PROCEDURE OR ENTRY NAMES
                  FIND_VISIBILITY(NAME, NAME_DEFSET);
                  IF STM.TY = DN_ENTRY_CALL
                                                        OR INDEX /=
                                                        TREE_VOID THEN
                     REQUIRE_ENTRY_DEF(NAME,
                                                        NAME_DEFSET);
                  ELSE
                     REQUIRE_PROC_OR_ENTRY_DEF(
                                                        NAME, NAME_DEFSET);
                  END IF;
               
                                        -- CHECK PARAMETERS OF VISIBLE NAMES
                  REDUCE_APPLY_NAMES(NAME,
                                                NAME_DEFSET,
                                                GENERAL_ASSOC_S, INDEX);
               
                                        -- REQUIRE UNIQUE NAME
                  REQUIRE_UNIQUE_DEF(NAME,
                                                NAME_DEFSET);
                  NAME_ID := GET_THE_ID(NAME_DEFSET);
               
                                        -- IF IT IS AN ENTRY NAME
                  IF NAME_ID.TY = DN_ENTRY_ID THEN
                  
                                                -- FORCE STATEMENT TO BE AN ENTRY CALL
                     IF STM.TY /=
                                                                DN_ENTRY_CALL THEN
                        STM :=
                                                                MAKE_ENTRY_CALL
                                                                (
                                                                LX_SRCPOS =>
                                                                D(
                                                                        LX_SRCPOS,
                                                                        STM)
                                                                , AS_NAME =>
                                                                NAME
                                                                ,
                                                                AS_GENERAL_ASSOC_S =>
                                                                GENERAL_ASSOC_S );
                     END IF;
                  
                                                -- IF IT IS THE NAME OF AN ENTRY FAMILY
                     DISCRETE_RANGE := D(
                                                        AS_DISCRETE_RANGE,
                                                        D(SM_SPEC, NAME_ID));
                     IF DISCRETE_RANGE /=
                                                                TREE_VOID THEN
                     
                                                        -- IF THERE WAS NOT AN EXPLICIT PARAMETER LIST
                        IF INDEX =
                                                                        TREE_VOID THEN
                        
                                                                -- THE (ONLY) PARAMETER IS THE INDEX
                           INDEX :=
                                                                        HEAD(
                                                                        LIST(
                                                                                GENERAL_ASSOC_S));
                           LIST(
                                                                        GENERAL_ASSOC_S,
                                                                        (TREE_NIL,TREE_NIL));
                        END IF;
                     
                                                        -- RESOLVE THE INDEX
                        INDEX  :=
                                                                RESOLVE_EXP
                                                                ( INDEX
                                                                ,
                                                                GET_BASE_TYPE(
                                                                        DISCRETE_RANGE) );
                     END IF;
                  END IF;
               
                                        -- RESOLVE THE NAME
                  IF NAME_ID.TY = DN_ENTRY_ID
                                                        AND THEN 
                                                        NAME.TY =
                                                        DN_SELECTED
                                                        AND THEN D(
                                                                XD_REGION,
                                                                NAME_ID).TY =
                                                        DN_TYPE_ID
                                                        AND THEN DI(
                                                        XD_LEX_LEVEL,
                                                        GET_DEF_FOR_ID(
                                                                NAME_ID)) >
                                                        0 THEN
                                                -- DO NOT USE RESOLVE_NAME BECAUSE PREFIX MIGHT BE A
                                                -- FUNCTION CALL, INDICATING A MEMBER OF AN ARRAY OF TASKS
                     DECLARE
                        PREFIX: TREE := D(
                                                                AS_NAME,
                                                                NAME);
                        DESIGNATOR: TREE :=
                                                                D(
                                                                AS_DESIGNATOR,
                                                                NAME);
                        TASK_SPEC: TREE :=
                                                                D(
                                                                SM_TYPE_SPEC,
                                                                D(
                                                                        XD_REGION,
                                                                        NAME_ID));
                        TYPESET:
                                                                TYPESET_TYPE :=
                                                                FETCH_TYPESET(
                                                                PREFIX);
                        TYPEINTERP:
                                                                TYPEINTERP_TYPE;
                        PREFIX_STRUCT:
                                                                TREE;
                        NEW_TYPESET:
                                                                TYPESET_TYPE :=
                                                                EMPTY_TYPESET;
                     BEGIN
                        WHILE NOT IS_EMPTY(
                                                                        TYPESET) LOOP
                           POP(
                                                                        TYPESET,
                                                                        TYPEINTERP);
                           PREFIX_STRUCT :=
                                                                        GET_BASE_STRUCT
                                                                        (
                                                                        GET_TYPE(
                                                                                TYPEINTERP) );
                           IF
                                                                                PREFIX_STRUCT =
                                                                                TASK_SPEC
                                                                                OR ELSE (
                                                                                
                                                                                        PREFIX_STRUCT.TY =
                                                                                DN_ACCESS
                                                                                AND THEN
                                                                                GET_BASE_STRUCT
                                                                                (
                                                                                        D(
                                                                                                SM_DESIG_TYPE,
                                                                                                PREFIX_STRUCT) )
                                                                                =
                                                                                TASK_SPEC)
                                                                                THEN
                              ADD_TO_TYPESET(
                                                                                NEW_TYPESET,
                                                                                TYPEINTERP);
                           END IF;
                        END LOOP;
                        REQUIRE_UNIQUE_TYPE(
                                                                PREFIX,
                                                                NEW_TYPESET);
                        PREFIX :=
                                                                RESOLVE_EXP (
                                                                PREFIX,
                                                                NEW_TYPESET);
                        D(AS_NAME, NAME,
                                                                PREFIX);
                        DESIGNATOR :=
                                                                RESOLVE_NAME(
                                                                DESIGNATOR,
                                                                NAME_ID);
                        D(AS_DESIGNATOR,
                                                                NAME,
                                                                DESIGNATOR);
                        D(SM_EXP_TYPE,
                                                                NAME,
                                                                TREE_VOID);
                     END;
                  ELSE
                     NAME := RESOLVE_NAME(NAME,
                                                        NAME_ID);
                  END IF;
               
                  IF INDEX /= TREE_VOID THEN
                     NAME := MAKE_INDEXED
                                                        ( AS_NAME => NAME
                                                        , AS_EXP_S =>
                                                        MAKE_EXP_S
                                                        ( LIST =>
                                                                SINGLETON(
                                                                        INDEX)
                                                                ,
                                                                LX_SRCPOS
                                                                => D(
                                                                        LX_SRCPOS,
                                                                        INDEX) )
                                                        , SM_EXP_TYPE =>
                                                        TREE_VOID
                                                        , LX_SRCPOS => D(
                                                                LX_SRCPOS,
                                                                NAME) );
                  END IF;
                  D(AS_NAME, STM, NAME);
               
                                        -- RESOLVE PARAMETERS AND STORE NORMALIZED LIST
                  IF IS_EMPTY(NAME_DEFSET) THEN
                     RESOLVE_ERRONEOUS_PARAM_S(
                                                        GENERAL_ASSOC_S);
                  ELSE
                     D(SM_NORMALIZED_PARAM_S
                                                        , STM
                                                        ,
                                                        RESOLVE_SUBP_PARAMETERS
                                                        ( GET_DEF(HEAD(
                                                                                NAME_DEFSET))
                                                                ,
                                                                GENERAL_ASSOC_S) );
                  END IF;
               END;
         
         
                        -- FOR AN ACCEPT STATEMENT
            WHEN DN_ACCEPT =>
               DECLARE
                  NAME: CONSTANT TREE := D(AS_NAME,
                                                STM);
                  PARAM_S: TREE := D(AS_PARAM_S, STM);
                  STM_S: CONSTANT TREE := D(
                                                AS_STM_S, STM);
               
                  DESIGNATOR: TREE := NAME;
                  INDEX: TREE := TREE_VOID;
                  INDEX_TYPESET: TYPESET_TYPE;
                  TEMP_ENTRY_DEF: TREE;
                  UNIT_DEF: TREE := H.REGION_DEF;
               
                  PRIOR_ENTRY_DEF: TREE;
               
                  H: H_TYPE := WALK_STM.H;
                  S: S_TYPE;
               BEGIN
                                        -- $$$$ MAKE SURE THERE IS A PARAM_S (SHOULD CHANGE DIANA.IDL)
                  IF PARAM_S = TREE_VOID THEN
                     PARAM_S := MAKE_PARAM_S(
                                                        LIST => (TREE_NIL,TREE_NIL));
                     D(AS_PARAM_S, STM, PARAM_S);
                  END IF;
               
                  IF NAME.TY = DN_INDEXED THEN
                     INDEX := HEAD(LIST(D(
                                                                        AS_EXP_S,
                                                                        NAME)));
                     D(SM_EXP_TYPE, NAME,
                                                        TREE_VOID);
                     DESIGNATOR := D(AS_NAME,
                                                        NAME);
                     EVAL_EXP_TYPES(INDEX,
                                                        INDEX_TYPESET);
                  END IF;
               
                  WHILE D(XD_SOURCE_NAME, UNIT_DEF).TY = DN_BLOCK_LOOP_ID 
                    OR ELSE D( XD_SOURCE_NAME, UNIT_DEF).TY = DN_ENTRY_ID LOOP
                     UNIT_DEF := D(
                                                        XD_REGION_DEF,
                                                        UNIT_DEF);
                  END LOOP;
               
                  H.REGION_DEF := UNIT_DEF;
                  TEMP_ENTRY_DEF := MAKE_DEF_FOR_ID
                                                ( MAKE_ENTRY_ID(LX_SYMREP =>
                                                        D(LX_SYMREP,
                                                                DESIGNATOR))
                                                , H );
                  ENTER_REGION(TEMP_ENTRY_DEF, H, S);
                                        --WALK_ITEM_S(PARAM_S, H);
                  FINISH_PARAM_S(PARAM_S, H);
                  IF INDEX = TREE_VOID THEN
                     PRIOR_ENTRY_DEF :=
                                                        GET_PRIOR_HOMOGRAPH_DEF
                                                        ( TEMP_ENTRY_DEF
                                                        , PARAM_S );
                  ELSE
                     PRIOR_ENTRY_DEF :=
                                                        GET_PRIOR_DEF(
                                                        TEMP_ENTRY_DEF);
                     IF PRIOR_ENTRY_DEF /=
                                                                TREE_VOID
                                                                AND THEN
                                                                D(
                                                                        XD_SOURCE_NAME,
                                                                        PRIOR_ENTRY_DEF).TY
                                                                =
                                                                DN_ENTRY_ID
                                                                THEN
                        DECLARE
                           SOURCE_NAME:
                                                                        TREE
                                                                        :=
                                                                        D(
                                                                        XD_SOURCE_NAME,
                                                                        PRIOR_ENTRY_DEF);
                           DISCRETE_RANGE:
                                                                        TREE
                                                                        :=
                                                                        D(
                                                                        AS_DISCRETE_RANGE
                                                                        ,
                                                                        D(
                                                                                SM_SPEC,
                                                                                SOURCE_NAME) );
                        BEGIN
                           IF
                                                                                DISCRETE_RANGE /=
                                                                                TREE_VOID THEN
                              REQUIRE_TYPE(
                                                                                GET_BASE_TYPE(
                                                                                        DISCRETE_RANGE)
                                                                                ,
                                                                                INDEX,
                                                                                INDEX_TYPESET );
                              INDEX :=
                                                                                RESOLVE_EXP(
                                                                                INDEX,
                                                                                INDEX_TYPESET);
                           ELSE
                              ERROR(
                                                                                D(
                                                                                        LX_SRCPOS,
                                                                                        INDEX),
                                                                                "ENTRY MUST BE AN ENTRY FAMILY");
                              INDEX :=
                                                                                RESOLVE_EXP(
                                                                                INDEX,
                                                                                TREE_VOID);
                           END IF;
                        END;
                        LIST(D(AS_EXP_S,
                                                                        NAME),
                                                                SINGLETON(
                                                                        INDEX));
                     ELSE
                        PRIOR_ENTRY_DEF :=
                                                                TREE_VOID;
                     END IF;
                  END IF;
                  IF PRIOR_ENTRY_DEF = TREE_VOID
                                                        OR ELSE D(
                                                                XD_SOURCE_NAME,
                                                                PRIOR_ENTRY_DEF).TY /=
                                                        DN_ENTRY_ID
                                                        THEN
                     ERROR(D(LX_SRCPOS,
                                                                DESIGNATOR),
                                                        "NO ENTRY FOR ACCEPT");
                     MAKE_DEF_IN_ERROR(
                                                        TEMP_ENTRY_DEF);
                     PRIOR_ENTRY_DEF :=
                                                        TEMP_ENTRY_DEF;
                  ELSIF D(SM_SPEC,(D(XD_SOURCE_NAME,
                                                                        PRIOR_ENTRY_DEF)))
                                                        = TREE_VOID
                                                        THEN
                     WARNING(D(LX_SRCPOS,STM), "$$$$ SM-SPEC IS VOID - " & NODE_REP(D( XD_SOURCE_NAME, PRIOR_ENTRY_DEF)) );
                     REMOVE_DEF_FROM_ENVIRONMENT(
                                                        TEMP_ENTRY_DEF);
                  ELSE
                     D(SM_DEFN, DESIGNATOR, D(
                                                                XD_SOURCE_NAME,
                                                                PRIOR_ENTRY_DEF));
                     CONFORM_PARAMETER_LISTS
                                                        ( D(AS_PARAM_S
                                                                , D(
                                                                        SM_SPEC,
                                                                        D(
                                                                                XD_SOURCE_NAME,
                                                                                PRIOR_ENTRY_DEF)))
                                                        , PARAM_S );
                     REMOVE_DEF_FROM_ENVIRONMENT(
                                                        TEMP_ENTRY_DEF);
                  END IF;
                  LEAVE_REGION(TEMP_ENTRY_DEF, S);
                  H := WALK_STM.H;
               
                  ENTER_BODY(PRIOR_ENTRY_DEF, H, S);
                  WALK_STM_S(STM_S, H);
                  LEAVE_BODY(PRIOR_ENTRY_DEF, S);
               END;
         
         
                        -- FOR A LOOP STATEMENT
            WHEN DN_LOOP =>
               DECLARE
                  SOURCE_NAME: CONSTANT TREE := D(
                                                AS_SOURCE_NAME, STM);
                  ITERATION: CONSTANT TREE := D(
                                                AS_ITERATION, STM);
                  STM_S: CONSTANT TREE := D(
                                                AS_STM_S, STM);
               
                  SOURCE_DEF: TREE := GET_DEF_FOR_ID(
                                                SOURCE_NAME);
               
                  H: H_TYPE := WALK_STM.H;
                  S: S_TYPE;
               BEGIN
               
                                        -- $$$$ CHECK THAT LABEL IS NOT DUPLICATE IN UNIT
               
                  ENTER_BODY(SOURCE_DEF, H, S);
                  H.RETURN_TYPE :=
                                                WALK_STM.H.RETURN_TYPE;
                  IF ITERATION.TY IN
                                                        CLASS_FOR_REV THEN
                     DECLARE
                        ITERATION_ID: TREE :=
                                                                D(
                                                                AS_SOURCE_NAME,
                                                                ITERATION);
                        DISCRETE_RANGE:
                                                                TREE := D(
                                                                AS_DISCRETE_RANGE,
                                                                ITERATION);
                     
                        ITERATION_ID_DEF:
                                                                TREE
                                                                :=
                                                                MAKE_DEF_FOR_ID(
                                                                ITERATION_ID,
                                                                H);
                        RANGE_TYPESET:
                                                                TYPESET_TYPE;
                     BEGIN
                        EVAL_NON_UNIVERSAL_DISCRETE_RANGE
                                                                (
                                                                DISCRETE_RANGE
                                                                ,
                                                                RANGE_TYPESET );
                        DISCRETE_RANGE :=
                                                                RESOLVE_DISCRETE_RANGE
                                                                (
                                                                DISCRETE_RANGE
                                                                ,
                                                                GET_THE_TYPE(
                                                                        RANGE_TYPESET) );
                        D(
                                                                AS_DISCRETE_RANGE,
                                                                ITERATION,
                                                                DISCRETE_RANGE);
                     
                        IF NOT IS_EMPTY(
                                                                        RANGE_TYPESET) THEN
                           MAKE_DEF_VISIBLE(
                                                                        ITERATION_ID_DEF);
                           D(
                                                                        SM_OBJ_TYPE,
                                                                        ITERATION_ID
                                                                        ,
                                                                        GET_SUBTYPE_OF_DISCRETE_RANGE
                                                                        (
                                                                                DISCRETE_RANGE ) );
                        ELSE
                           MAKE_DEF_IN_ERROR(
                                                                        ITERATION_ID_DEF);
                        END IF;
                     END;
                  
                  ELSIF ITERATION.TY = DN_WHILE THEN
                     DECLARE
                        EXP: TREE := D(
                                                                AS_EXP,
                                                                ITERATION);
                        EXP_TYPESET:
                                                                TYPESET_TYPE;
                     BEGIN
                        EVAL_EXP_TYPES(
                                                                EXP,
                                                                EXP_TYPESET);
                        REQUIRE_BOOLEAN_TYPE(
                                                                EXP,
                                                                EXP_TYPESET);
                        REQUIRE_UNIQUE_TYPE(
                                                                EXP,
                                                                EXP_TYPESET);
                        EXP := RESOLVE_EXP(
                                                                EXP,
                                                                GET_THE_TYPE(
                                                                        EXP_TYPESET));
                        D(AS_EXP,
                                                                ITERATION,
                                                                EXP);
                     END;
                  END IF;
               
                                        -- MAKE THIS THE ENCLOSING LOOP STATEMENT
                  H.ENCLOSING_LOOP_ID := SOURCE_NAME;
               
                                        -- WALK THE SEQUENCE OF STATEMENTS
                  WALK_STM_S(STM_S, H);
               
                                        -- LEAVE THE DECLARATIVE REGION
                  LEAVE_BODY(SOURCE_DEF, S);
               END;
         
         
                        -- FOR A BLOCK STATEMENT
            WHEN DN_BLOCK =>
               DECLARE
                  SOURCE_NAME: CONSTANT TREE := D(
                                                AS_SOURCE_NAME, STM);
                  BLOCK_BODY: CONSTANT TREE := D(
                                                AS_BLOCK_BODY, STM);
               
                  ITEM_S: TREE := D(AS_ITEM_S,
                                                BLOCK_BODY);
                  STM_S: TREE := D(AS_STM_S,
                                                BLOCK_BODY);
                  ALTERNATIVE_S: TREE := D(
                                                AS_ALTERNATIVE_S,
                                                BLOCK_BODY);
                  ALTERNATIVE_LIST: SEQ_TYPE;
                  ALTERNATIVE: TREE;
               
                  SOURCE_DEF: TREE := GET_DEF_FOR_ID(
                                                SOURCE_NAME);
                  H: H_TYPE := WALK_STM.H;
                  S: S_TYPE;
               BEGIN
                                        -- $$$$ CHECK THAT LABEL IS NOT DUPLICATE IN UNIT
               
                  ENTER_BODY(SOURCE_DEF, H, S);
                  H.RETURN_TYPE :=
                                                WALK_STM.H.RETURN_TYPE;
                  WALK_ITEM_S(ITEM_S, H);
                  IF STM_S /= TREE_VOID THEN
                     DECLARE_LABEL_BLOCK_LOOP_IDS(
                                                        STM_S, H);
                  END IF;
                  IF ALTERNATIVE_S = TREE_VOID THEN
                     ALTERNATIVE_LIST := (TREE_NIL,TREE_NIL);
                  ELSE
                     ALTERNATIVE_LIST := LIST(
                                                        ALTERNATIVE_S);
                  END IF;
                  WHILE NOT IS_EMPTY(
                                                        ALTERNATIVE_LIST) LOOP
                     POP(ALTERNATIVE_LIST,
                                                        ALTERNATIVE);
                     IF ALTERNATIVE.TY =
                                                                DN_ALTERNATIVE THEN
                        DECLARE_LABEL_BLOCK_LOOP_IDS
                                                                ( D(
                                                                        AS_STM_S,
                                                                        ALTERNATIVE),
                                                                H);
                     END IF;
                  END LOOP;
                  IF STM_S /= TREE_VOID THEN
                     WALK_STM_S(STM_S, H);
                  END IF;
                  WALK_ALTERNATIVE_S(ALTERNATIVE_S,
                                                H);
                  LEAVE_BODY(SOURCE_DEF, S);
               END;
         
         
                        -- FOR A CONDITIONAL ENTRY CALL OR A TIMED ENTRY CALL
            WHEN DN_COND_ENTRY | DN_TIMED_ENTRY =>
               DECLARE
                  STM_S1: CONSTANT TREE := D(
                                                AS_STM_S1, STM);
                  STM_S2: CONSTANT TREE := D(
                                                AS_STM_S2, STM);
               BEGIN
                                        -- WALK THE TWO SEQUENCES OF STATEMENTS
                  WALK_STM_S(STM_S1, H);
                  WALK_STM_S(STM_S2, H);
               END;
         
         
                        -- FOR AN IF STATEMENT
            WHEN DN_IF =>
               DECLARE
                  TEST_CLAUSE_ELEM_S: CONSTANT TREE
                                                := D(
                                                AS_TEST_CLAUSE_ELEM_S, STM);
                  STM_S: CONSTANT TREE := D(
                                                AS_STM_S, STM);
               
                  COND_CLAUSE_LIST: SEQ_TYPE := LIST(
                                                TEST_CLAUSE_ELEM_S);
                  COND_CLAUSE: TREE;
                  EXP: TREE;
                  TYPESET: TYPESET_TYPE;
               BEGIN
                                        -- FOR EACH COND_CLAUSE
                  WHILE NOT IS_EMPTY(
                                                        COND_CLAUSE_LIST) LOOP
                     POP(COND_CLAUSE_LIST,
                                                        COND_CLAUSE);
                  
                                                -- RESOLVE THE CONDITIONAL EXPRESSION
                     EXP := D(AS_EXP,
                                                        COND_CLAUSE);
                     EVAL_EXP_TYPES(EXP,
                                                        TYPESET);
                     REQUIRE_BOOLEAN_TYPE(EXP,
                                                        TYPESET);
                     REQUIRE_UNIQUE_TYPE(EXP,
                                                        TYPESET);
                     EXP := RESOLVE_EXP(EXP,
                                                        GET_THE_TYPE(
                                                                TYPESET));
                     D(AS_EXP, COND_CLAUSE, EXP);
                  
                                                -- WALK THE SEQUENCE OF STATEMENTS
                     WALK_STM_S(D(AS_STM_S,
                                                                COND_CLAUSE),
                                                        H);
                  
                                                -- WALK THE (ELSE) SEQUENCE OF STATEMENTS
                  END LOOP;
                  WALK_STM_S(STM_S, H);
               END;
         
         
                        -- FOR A SELECTIVE WAIT
            WHEN DN_SELECTIVE_WAIT =>
               DECLARE
                  TEST_CLAUSE_ELEM_S: CONSTANT TREE
                                                := D(
                                                AS_TEST_CLAUSE_ELEM_S, STM);
                  STM_S: TREE := D(AS_STM_S, STM);
               
                  TEST_CLAUSE_LIST: SEQ_TYPE := LIST(
                                                TEST_CLAUSE_ELEM_S);
                  TEST_CLAUSE: TREE;
                  NEW_TEST_CLAUSE_LIST: SEQ_TYPE :=
                                                (TREE_NIL,TREE_NIL);
                  EXP: TREE;
                  TYPESET: TYPESET_TYPE;
                  SELECT_ALT_PRAGMA : TREE;
               BEGIN
                                        -- FOR EACH TEST_CLAUSE
                  WHILE NOT IS_EMPTY(
                                                        TEST_CLAUSE_LIST) LOOP
                     POP(TEST_CLAUSE_LIST,
                                                        TEST_CLAUSE);
                  
                                                -- IF IT IS A SELECT ALTERNATIVE
                     IF TEST_CLAUSE.TY =
                                                                DN_SELECT_ALTERNATIVE THEN
                     
                                                        -- IF THERE IS A WHEN CLAUSE
                        EXP := D(AS_EXP,
                                                                TEST_CLAUSE);
                        IF EXP /=
                                                                        TREE_VOID THEN
                        
                                                                -- RESOLVE THE CONDITIONAL EXPRESSION
                           EVAL_EXP_TYPES(
                                                                        EXP,
                                                                        TYPESET);
                           REQUIRE_BOOLEAN_TYPE(
                                                                        EXP,
                                                                        TYPESET);
                           REQUIRE_UNIQUE_TYPE(
                                                                        EXP,
                                                                        TYPESET);
                           EXP :=
                                                                        RESOLVE_EXP(
                                                                        EXP,
                                                                        GET_THE_TYPE(
                                                                                TYPESET));
                           D(AS_EXP,
                                                                        TEST_CLAUSE,
                                                                        EXP);
                        END IF;
                     
                                                        -- WALK THE SEQUENCE OF STATEMENTS
                        WALK_STM_S(D(
                                                                        AS_STM_S,
                                                                        TEST_CLAUSE),
                                                                H);
                     
                                                        -- ADD SELECT_ALTERNATIVE TO NEW LIST
                        NEW_TEST_CLAUSE_LIST :=
                                                                APPEND
                                                                (
                                                                NEW_TEST_CLAUSE_LIST
                                                                ,
                                                                TEST_CLAUSE );
                     
                                                        -- ELSE -- SINCE IT IS A STM PRAGMA
                     ELSE
                     
                                                        -- NOTE: PARSER GENERATES STM_PRAGMA INSTEAD
                                                        -- ... OF SELECT_ALT PRAGMA TO AVOID LR(1) CONFLICT
                     
                                                        -- CHANGE THE STM_PRAGMA TO A SELECT_ALT_PRAGMA
                        SELECT_ALT_PRAGMA :=
                                                                MAKE_SELECT_ALT_PRAGMA
                                                                (
                                                                LX_SRCPOS =>
                                                                D(
                                                                        LX_SRCPOS,
                                                                        TEST_CLAUSE)
                                                                ,
                                                                AS_PRAGMA =>
                                                                D(
                                                                        AS_PRAGMA,
                                                                        TEST_CLAUSE) );
                     
                                                        -- PROCESS THE PRAGMA
                        WALK(D(AS_PRAGMA,
                                                                        SELECT_ALT_PRAGMA),
                                                                H);
                     
                                                        -- ADD SELECT_ALT_PRAGMA TO NEW LIST
                        NEW_TEST_CLAUSE_LIST :=
                                                                APPEND
                                                                (
                                                                NEW_TEST_CLAUSE_LIST
                                                                ,
                                                                SELECT_ALT_PRAGMA );
                     END IF;
                  
                                                -- REPLACE TEST_CLAUSE_LIST WITH NEW LIST
                  END LOOP;
                  LIST(TEST_CLAUSE_ELEM_S,
                                                NEW_TEST_CLAUSE_LIST);
               
                                        -- WALK THE (ELSE) SEQUENCE OF STATEMENTS
                  WALK_STM_S(STM_S, H);
               END;
         
         
                        -- FOR A PRAGMA IN A SEQUENCE OF STATEMENTS
            WHEN DN_STM_PRAGMA =>
               DECLARE
                  PRAGMA_NODE: CONSTANT TREE := D(
                                                AS_PRAGMA, STM);
               BEGIN
               
                                        -- WALK THE PRAGMA
                  WALK(PRAGMA_NODE, H);
               END;
         
         
            WHEN OTHERS =>
               PUT_LINE ( "INVALID AS STM NODE" );
               RAISE PROGRAM_ERROR;
         END CASE;
      
      
                -- RETURN THE NEW STATEMENT (MAYBE PROCEDURE CHANGED TO ENTRY)
         RETURN STM;
      END WALK_STM;
   
   --|----------------------------------------------------------------------------------------------
   END STM_WALK;
