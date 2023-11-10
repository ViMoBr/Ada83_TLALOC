    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	GEN_SUBS
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY GEN_SUBS IS
      USE NEWSNAM;
      USE VIS_UTIL;
      USE PRE_FCNS;
   
       PROCEDURE SUBSTITUTE_GENERAL_NODE
                ( NODE: 	IN OUT TREE
                ; NODE_HASH:	IN OUT NODE_HASH_TYPE
                ; H:		H_TYPE );
   
       FUNCTION HASH_NODE_HASH
                ( NODE_HASH:	NODE_HASH_TYPE
                ; NODE: 	TREE )
                RETURN NATURAL;
   
       PROCEDURE SEARCH_NODE_HASH
                ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                ; NODE:		IN OUT TREE );
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REPLACE_NODE
                        ( NODE: 	IN OUT TREE
                        ; NODE_HASH:	IN OUT NODE_HASH_TYPE )
                        IS
         OLD_NODE: CONSTANT TREE := NODE;
      BEGIN
         NODE := COPY_NODE(NODE);
         INSERT_NODE_HASH(NODE_HASH, NODE, OLD_NODE);
      END REPLACE_NODE;
   
   
       PROCEDURE SUBSTITUTE_GENERAL_NODE
                        ( NODE: 	IN OUT TREE
                        ; NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; H:		H_TYPE )
                        IS
         USE IDL_TBL;
      
         OLD_NODE: CONSTANT TREE := NODE;
         OLD_ATTRIBUTE: TREE;
         ATTRIBUTE: TREE;
      BEGIN
      
                -- FOR EACH ATTRIBUTE OF THE GIVEN NODE
         FOR I IN 1 .. N_SPEC(NODE.TY).NS_SIZE LOOP
            ATTRIBUTE := DABS(I, NODE);
            OLD_ATTRIBUTE := ATTRIBUTE;
         
                        -- SUBSTITUTE FOR IT
            SUBSTITUTE(ATTRIBUTE, NODE_HASH, H);
         
                        -- IF IT WAS CHANGED BY THE SUBSTITUTION
            IF ATTRIBUTE /= OLD_ATTRIBUTE THEN
            
                                -- IF THIS IS THE FIRST CHANGE
               IF NODE = OLD_NODE THEN
               
                                        -- CREATE A NEW NODE
                  NODE := COPY_NODE(NODE);
               END IF;
            
                                -- REPLACE THE CHANGED ATTRIBUTE
               DABS(I, NODE, ATTRIBUTE);
            END IF;
         END LOOP;
      END SUBSTITUTE_GENERAL_NODE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE SUBSTITUTE_ATTRIBUTES
                        ( NODE: 	IN OUT TREE
                        ; NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; H_IN: 	H_TYPE )
                        IS
         USE IDL_TBL;
         H: H_TYPE RENAMES H_IN;
      
         OLD_ATTRIBUTE: TREE;
         ATTRIBUTE: TREE;
      BEGIN
      
                -- FOR EACH ATTRIBUTE OF THE GIVEN NODE
         FOR I IN 1 .. N_SPEC(NODE.TY).NS_SIZE LOOP
            ATTRIBUTE := DABS(I, NODE);
            OLD_ATTRIBUTE := ATTRIBUTE;
         
                        -- SUBSTITUTE FOR IT
            SUBSTITUTE(ATTRIBUTE, NODE_HASH, H);
         
                        -- IF IT WAS CHANGED BY THE SUBSTITUTION
            IF ATTRIBUTE /= OLD_ATTRIBUTE THEN
            
                                -- REPLACE THE CHANGED ATTRIBUTE
               DABS(I, NODE, ATTRIBUTE);
            END IF;
         END LOOP;
      END SUBSTITUTE_ATTRIBUTES;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|
PROCEDURE SUBSTITUTE ( NODE :IN OUT TREE; NODE_HASH :IN OUT NODE_HASH_TYPE; H_IN :H_TYPE ) IS
  OLD_NODE	: CONSTANT TREE	:= NODE;
  H		: H_TYPE		RENAMES H_IN;
BEGIN      
                -- $$$$ FOR TESTING -- AVOID RUNAWAY SUBSTITUTION
  IF NODE_HASH.LIMIT > 0 THEN
    NODE_HASH.LIMIT := NODE_HASH.LIMIT - 1;
  ELSE
    PUT_LINE ( "!! RUNAWAY LOOP IN GENERIC SUBSTITUTION");
    RAISE PROGRAM_ERROR;
  END IF;
      
                -- CHECK FOR NODE WITH NO ATTRIBUTES
  IF NODE.PT = HI OR NODE.PT = S THEN RETURN;						--| ENTETE/INTEGER OU SRCPOS
  ELSIF NODE.PG = 0 OR ELSE DABS( 0, NODE ).NSIZ = 0 THEN RETURN;				--| POINTEUR P NIL OU VOID OU VIRGIN OU SANS ATTRIBUT
  END IF;
                -- IF NODE HAS ALREADY BEEN CONSIDERED
  SEARCH_NODE_HASH( NODE_HASH, NODE );
      
                -- IF IT WAS ACTUALLY CHANGED
  IF NODE /= OLD_NODE THEN
         
                        -- RETURN RESULT FROM HASH TABLE
    RETURN;
  END IF;
      
      
  CASE NODE.TY IS
       
  WHEN DN_ROOT =>
               PUT_LINE ( "!! INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
  WHEN DN_TXTREP | DN_NUM_VAL =>
               NULL;
         
  WHEN CLASS_BOOLEAN | DN_NIL =>
              PUT_LINE ( "INVALID NODE IN GENERIC COPY" );
               RAISE PROGRAM_ERROR;
         
  WHEN DN_LIST =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
        
  WHEN DN_SOURCELINE | DN_ERROR =>
               PUT_LINE ( "!! INVALID NODE IN GENERIC COPY" );
         
  WHEN DN_SYMBOL_REP =>
               NULL;
         
  WHEN DN_HASH | DN_VOID =>
               PUT_LINE ( "!! INVALID NODE IN GENERIC COPY" );
               RAISE PROGRAM_ERROR;
         
  WHEN CLASS_DEF_NAME =>
                                -- (ONLY SUBSTITUTED IF FOUND IN HASH TABLE)
               NULL;
         
         
  WHEN DN_BLOCK_MASTER =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
  WHEN CLASS_DSCRMT_PARAM_DECL | DN_NUMBER_DECL |
                                        DN_EXCEPTION_DECL
                                        | DN_DEFERRED_CONSTANT_DECL =>
    DECLARE
                  SOURCE_NAME_S: TREE := D(
                                                AS_SOURCE_NAME_S, NODE);
                  SOURCE_NAME_LIST: SEQ_TYPE := LIST(
                                                SOURCE_NAME_S);
                  SOURCE_NAME: TREE;
    BEGIN
      WHILE NOT IS_EMPTY( SOURCE_NAME_LIST ) LOOP
        POP( SOURCE_NAME_LIST, SOURCE_NAME );
        REPLACE_SOURCE_NAME( SOURCE_NAME, NODE_HASH, H, NODE );
      END LOOP;
      SUBSTITUTE_GENERAL_NODE( NODE, NODE_HASH, H );
    END;
         
         
  WHEN CLASS_OBJECT_DECL =>
               DECLARE
                  SOURCE_NAME_S: TREE := D(
                                                AS_SOURCE_NAME_S, NODE);
                  SOURCE_NAME_LIST: SEQ_TYPE := LIST(
                                                SOURCE_NAME_S);
                  SOURCE_NAME: TREE;
                  TYPE_DEF_KIND: NODE_NAME := D(AS_TYPE_DEF, NODE).TY;
               BEGIN
                  WHILE NOT IS_EMPTY(
                                                        SOURCE_NAME_LIST) LOOP
                     POP(SOURCE_NAME_LIST,
                                                        SOURCE_NAME);
                  
                     REPLACE_SOURCE_NAME(
                                                        SOURCE_NAME,
                                                        NODE_HASH, H, NODE);
                     IF TYPE_DEF_KIND =
                                                                DN_CONSTRAINED_ARRAY_DEF THEN
                        GEN_PREDEFINED_OPERATORS
                                                                ( D(
                                                                        SM_OBJ_TYPE,
                                                                        SOURCE_NAME),
                                                                H);
                     END IF;
                  END LOOP;
               
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               END;
         
         
            WHEN DN_TYPE_DECL =>
               DECLARE
                  SOURCE_NAME: TREE := D(
                                                AS_SOURCE_NAME, NODE);
                  DERIVED_ID_LIST: SEQ_TYPE;
                  DERIVED_ID: TREE;
               BEGIN
                  REPLACE_SOURCE_NAME(SOURCE_NAME,
                                                NODE_HASH, H, NODE);
                  GEN_PREDEFINED_OPERATORS
                                                ( D(SM_TYPE_SPEC,
                                                        SOURCE_NAME), H);
                  IF D(AS_TYPE_DEF, NODE).TY =
                                                        DN_DERIVED_DEF THEN
                     DERIVED_ID_LIST := LIST(D(
                                                                AS_TYPE_DEF,
                                                                NODE));
                     WHILE NOT IS_EMPTY(
                                                                DERIVED_ID_LIST) LOOP
                        POP(
                                                                DERIVED_ID_LIST,
                                                                DERIVED_ID);
                        REPLACE_SOURCE_NAME(
                                                                DERIVED_ID,
                                                                NODE_HASH,
                                                                H);
                     END LOOP;
                  END IF;
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               END;
         
         
            WHEN DN_SUBTYPE_DECL =>
               DECLARE
                  SOURCE_NAME: TREE := D(
                                                AS_SOURCE_NAME, NODE);
               BEGIN
                  REPLACE_SOURCE_NAME(SOURCE_NAME,
                                                NODE_HASH, H);
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               END;
         
         
            WHEN DN_TASK_DECL | CLASS_SIMPLE_RENAME_DECL =>
               DECLARE
                  SOURCE_NAME: TREE := D(
                                                AS_SOURCE_NAME, NODE);
               BEGIN
                  REPLACE_SOURCE_NAME(SOURCE_NAME,
                                                NODE_HASH, H, NODE);
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               END;
         
         
            WHEN CLASS_UNIT_DECL =>
               DECLARE
                  SOURCE_NAME: TREE := D(
                                                AS_SOURCE_NAME, NODE);
               BEGIN
                  REPLACE_SOURCE_NAME(SOURCE_NAME,
                                                NODE_HASH, H, NODE);
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               END;
         
         
            WHEN DN_NULL_COMP_DECL =>
               NULL;
         
         
            WHEN CLASS_NAMED_REP | DN_RECORD_REP | DN_USE =>
                                -- $$$$ WORRY ABOUT FORWARD REFS TO ADDRESS CLAUSES
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN DN_PRAGMA =>
               DECLARE
                  USED_NAME_ID: TREE := D(
                                                AS_USED_NAME_ID, NODE);
               BEGIN
                  USED_NAME_ID := COPY_NODE(
                                                USED_NAME_ID);
                  IF D(SM_DEFN, USED_NAME_ID) /=
                                                        TREE_VOID THEN
                     SUBSTITUTE_GENERAL_NODE(
                                                        NODE, NODE_HASH, H);
                  END IF;
               END;
         
         
            WHEN DN_SUBPROGRAM_BODY | DN_PACKAGE_BODY |
                                        DN_TASK_BODY | DN_SUBUNIT =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
            WHEN CLASS_TYPE_DEF =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN CLASS_SEQUENCES =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN CLASS_STM_ELEM =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
            WHEN CLASS_NAMED_ASSOC =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN CLASS_USED_OBJECT =>
               DECLARE
                  OLD_DEFN: CONSTANT TREE := D(
                                                SM_DEFN, NODE);
                  DEFN: TREE := OLD_DEFN;
                  EXP_TYPE: TREE := D(SM_EXP_TYPE,
                                                NODE);
               BEGIN
                  SUBSTITUTE(DEFN, NODE_HASH, H);
                  IF DEFN /= OLD_DEFN THEN
                     SUBSTITUTE(EXP_TYPE,
                                                        NODE_HASH, H);
                     NODE := COPY_NODE(NODE);
                     D(SM_DEFN, NODE, DEFN);
                     D(SM_EXP_TYPE, NODE,
                                                        EXP_TYPE);
                  END IF;
               END;
         
         
            WHEN CLASS_USED_NAME | CLASS_NAME_EXP |
                                        CLASS_EXP_EXP
                                        | CLASS_CONSTRAINT | CLASS_CHOICE
                                        | CLASS_HEADER | CLASS_UNIT_DESC
                                        | CLASS_MEMBERSHIP_OP |
                                        CLASS_SHORT_CIRCUIT_OP =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN CLASS_TEST_CLAUSE_ELEM
                                        | CLASS_ITERATION |
                                        CLASS_ALTERNATIVE_ELEM =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
            WHEN CLASS_COMP_REP_ELEM =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN CLASS_CONTEXT_ELEM =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
            WHEN CLASS_VARIANT_ELEM | DN_ALIGNMENT |
                                        DN_VARIANT_PART
                                        | DN_COMP_LIST =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN DN_COMPILATION | DN_COMPILATION_UNIT =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
         
            WHEN DN_INDEX =>
               SUBSTITUTE_GENERAL_NODE(NODE, NODE_HASH, H);
         
         
            WHEN DN_TASK_SPEC =>
               NULL;
         
         
            WHEN CLASS_NON_TASK =>
               IF D(SM_BASE_TYPE, NODE) /= NODE THEN
                  SUBSTITUTE_GENERAL_NODE(NODE,
                                                NODE_HASH, H);
               ELSE
                  NULL;
               END IF;
         
         
            WHEN CLASS_PRIVATE_SPEC | DN_INCOMPLETE =>
               NULL;
         
         
            WHEN DN_REAL_VAL =>
               NULL;
         
         
            WHEN DN_UNIVERSAL_INTEGER | DN_UNIVERSAL_FIXED |
                                        DN_UNIVERSAL_REAL
                                        | DN_USER_ROOT | DN_TRANS_WITH ..
                                        DN_NULLARY_CALL =>
               PUT_LINE ( "INVALID NODE IN GENERIC COPY");
               RAISE PROGRAM_ERROR;
            WHEN DN_VIRGIN =>
               PUT_LINE ( "!! UN NOEUD NON INITIALISE" );
               RAISE PROGRAM_ERROR;
         END CASE;
      
      
                -- IF A CHANGE WAS MADE
         IF NODE /= OLD_NODE THEN
         
                        -- ENTER CHANGE IN HASH TABLE
            INSERT_NODE_HASH(NODE_HASH, NODE, OLD_NODE);
         END IF;
      END;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION HASH_NODE_HASH
                        ( NODE_HASH:	NODE_HASH_TYPE
                        ; NODE: 	TREE )
                        RETURN NATURAL
                        IS
         HASH_CODE: NATURAL := ABS(INTEGER(NODE.PG) - 79 * INTEGER(
                                NODE.LN));
      BEGIN
         HASH_CODE := HASH_CODE MOD NODE_HASH.A'LENGTH;
         RETURN HASH_CODE;
      END HASH_NODE_HASH;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE INSERT_NODE_HASH
                        ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; NEW_NODE:	TREE
                        ; OLD_NODE:	TREE )
                        IS
         HASH_INDEX		: NATURAL	:= HASH_NODE_HASH (NODE_HASH, OLD_NODE);
         HASH_CHAIN		: TREE	:= NODE_HASH.A(HASH_INDEX);
         NEW_HASH_CHAIN	: TREE	:= MAKE(DN_LIB_INFO);
      BEGIN
         D(XD_SHORT, NEW_HASH_CHAIN, HASH_CHAIN);
         D(XD_PRIMARY, NEW_HASH_CHAIN, OLD_NODE);
         D(XD_SECONDARY, NEW_HASH_CHAIN, NEW_NODE);
         NODE_HASH.A(HASH_INDEX) := NEW_HASH_CHAIN;
      END INSERT_NODE_HASH;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE SEARCH_NODE_HASH
                        ( NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; NODE:		IN OUT TREE )
                        IS
         HASH_INDEX: NATURAL := HASH_NODE_HASH (NODE_HASH, NODE);
         HASH_CHAIN: TREE := NODE_HASH.A(HASH_INDEX);
      BEGIN
         WHILE HASH_CHAIN /= TREE_VOID LOOP
            IF D(XD_PRIMARY, HASH_CHAIN) = NODE THEN
               NODE := D(XD_SECONDARY, HASH_CHAIN);
               EXIT;
            END IF;
            HASH_CHAIN := D(XD_SHORT, HASH_CHAIN);
         END LOOP;
      END SEARCH_NODE_HASH;
   
    --|----------------------------------------------------------------------------------------------
   END GEN_SUBS;
