    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	REQ_UTIL
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY REQ_UTIL IS
      USE SET_UTIL;
      USE DEF_UTIL;
   
    --|----------------------------------------------------------------------------------------------
    --|	REQ_GENE
    --|----------------------------------------------------------------------------------------------
       PACKAGE BODY REQ_GENE IS
      
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
          PROCEDURE REQ_DEF_XXX(EXP: TREE; DEFSET: IN OUT DEFSET_TYPE) IS
                -- REMOVE FROM DEFSET THOSE INTERPRETATIONS FOR WHICH IS_XXX FALSE
         
             FUNCTION REQUIRE_XXX(DEFSET: DEFSET_TYPE) RETURN DEFSET_TYPE IS
               SET_TAIL:	    DEFSET_TYPE;
               SET_HEAD:	    DEFINTERP_TYPE;
               NEW_TAIL:	    DEFSET_TYPE;
            BEGIN
               SET_TAIL := DEFSET;
               POP(SET_TAIL, SET_HEAD);
               IF IS_EMPTY(SET_TAIL) THEN
                  NEW_TAIL := SET_TAIL;
               ELSE
                  NEW_TAIL := REQUIRE_XXX(SET_TAIL);
               END IF;
               IF IS_XXX(GET_DEF(SET_HEAD)) THEN
                  IF NEW_TAIL = SET_TAIL THEN
                     RETURN DEFSET;
                  ELSE
                     NEW_TAIL := INSERT(NEW_TAIL, SET_HEAD);
                     RETURN NEW_TAIL;
                  END IF;
               ELSE
                  RETURN NEW_TAIL;
               END IF;
            
            END REQUIRE_XXX;
         
         BEGIN
            IF IS_EMPTY(DEFSET) THEN
               RETURN;
            END IF;
            DEFSET := REQUIRE_XXX(DEFSET);
            IF IS_EMPTY(DEFSET) THEN
               ERROR(D(LX_SRCPOS,EXP), MESSAGE);
            END IF;
         END REQ_DEF_XXX;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
          PROCEDURE REQ_TYPE_XXX(EXP: TREE; TYPESET: IN OUT TYPESET_TYPE) IS		--| ENLÈVE DE TYPESET LES INTERPRETATIONS QUI ONT IS_XXX FAUSSE
         
             FUNCTION REQUIRE_XXX(TYPESET: TYPESET_TYPE) RETURN TYPESET_TYPE IS
               SET_TAIL:	    TYPESET_TYPE;
               SET_HEAD:	    TYPEINTERP_TYPE;
               NEW_TAIL:	    TYPESET_TYPE;
            BEGIN
               SET_TAIL := TYPESET;
               POP(SET_TAIL, SET_HEAD);
               IF IS_EMPTY(SET_TAIL) THEN
                  NEW_TAIL := SET_TAIL;
               ELSE
                  NEW_TAIL := REQUIRE_XXX(SET_TAIL);
               END IF;
               IF IS_XXX(GET_TYPE(SET_HEAD)) THEN
                  IF NEW_TAIL = SET_TAIL THEN
                     RETURN TYPESET;
                  ELSE
                     NEW_TAIL := INSERT(NEW_TAIL, SET_HEAD);
                     RETURN NEW_TAIL;
                  END IF;
               ELSE
                  RETURN NEW_TAIL;
               END IF;
            
            END REQUIRE_XXX;
         
         BEGIN
            IF IS_EMPTY(TYPESET) THEN
               RETURN;
            END IF;
            TYPESET := REQUIRE_XXX(TYPESET);
            IF IS_EMPTY(TYPESET) THEN
               ERROR(D(LX_SRCPOS,EXP), MESSAGE);
            END IF;
         END REQ_TYPE_XXX;
      
      END REQ_GENE;
   
   
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_BASE_STRUCT(TYPE_SPEC: TREE) RETURN TREE IS
         BASE_STRUCT:	TREE;
         BASE_ID:	TREE;
         BASE_REGION:	TREE;
      BEGIN
      
                -- AS A FIRST APPROXIMATION, BASE STRUCTURE IS THE BASE TYPE
         BASE_STRUCT := GET_BASE_TYPE(TYPE_SPEC);
      
                -- IF IT'S A POSSIBLE FULL TYPE FOR A PRIVATE TYPE
         IF BASE_STRUCT.TY IN CLASS_DERIVABLE_SPEC OR ELSE BASE_STRUCT.TY = DN_INCOMPLETE THEN
         
                        -- GET THE IDENTIFIER ASSOCIATED WITH THE TYPE DECLARATION
            BASE_ID := D(XD_SOURCE_NAME, BASE_STRUCT);
         
                        -- IF IT'S AN [L_]PRIVATE_TYPE_ID
                        -- AND WE'RE NOT ALREADY LOOKING AT THE PRIVATE SPEC
                        -- (NOTE: FULL TYPE SPEC COULD BE A DIFFERENT PRIVATE)
            IF BASE_ID.TY IN DN_PRIVATE_TYPE_ID ..
                                        DN_L_PRIVATE_TYPE_ID
                                        AND THEN D(SM_TYPE_SPEC, BASE_ID) /=
                                        BASE_STRUCT THEN
            
                                -- IF IT WAS NOT DEFINED IN AN ENCLOSING PACKAGE
                                -- (NOTE: LX_SYMREP(BASE_REGION) --> NOT ENCLOSING)
               BASE_REGION := D(XD_REGION, BASE_ID);
               IF ( BASE_REGION.TY /= DN_PACKAGE_ID
                                                AND THEN ( BASE_REGION.TY /=
                                                        DN_GENERIC_ID
                                                        OR ELSE D( SM_SPEC, BASE_REGION).TY
                                                        /= DN_PACKAGE_SPEC ) )
                                                OR ELSE D(LX_SYMREP, BASE_REGION).TY /= DN_SYMBOL_REP
                                                OR ELSE DI(XD_LEX_LEVEL,
                                                GET_DEF_FOR_ID(
                                                        BASE_REGION)) <= 0
                                                THEN
               
                                        -- THE STRUCTURE IS THE PRIVATE NODE
                  BASE_STRUCT := D(SM_TYPE_SPEC,
                                                BASE_ID);
               END IF;
            END IF;
         END IF;
      
                -- RETURN THE BASE STRUCTURE
         RETURN BASE_STRUCT;
      
      END GET_BASE_STRUCT;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_ANCESTOR_TYPE(TYPE_SPEC: TREE) RETURN TREE IS
         TYPE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
      BEGIN
         WHILE TYPE_STRUCT.TY IN CLASS_DERIVABLE_SPEC
                                AND THEN D(SM_DERIVED, TYPE_STRUCT) /=
                                TREE_VOID LOOP
            TYPE_STRUCT := GET_BASE_STRUCT(D(SM_DERIVED,
                                        TYPE_STRUCT));
         END LOOP;
         RETURN GET_BASE_TYPE(TYPE_STRUCT);
      END GET_ANCESTOR_TYPE;
   
   
       FUNCTION IS_MEMBER_OF_UNSPECIFIED
                        ( SPEC_TYPE: TREE
                        ; UNSPEC_TYPE: TREE )
                        RETURN BOOLEAN
                        IS
         UNSPEC_KIND:	    NODE_NAME := UNSPEC_TYPE.TY;
         SPEC_STRUCT:	    TREE;
         SPEC_KIND:	    NODE_NAME;
      BEGIN
         IF UNSPEC_KIND NOT IN CLASS_UNSPECIFIED_TYPE THEN
            RETURN FALSE;
         END IF;
      
         SPEC_STRUCT := GET_BASE_STRUCT(SPEC_TYPE);
         SPEC_KIND := SPEC_STRUCT.TY;
         CASE CLASS_UNSPECIFIED_TYPE'(UNSPEC_KIND) IS
            WHEN DN_ANY_ACCESS =>
               RETURN SPEC_KIND = DN_ACCESS OR SPEC_KIND =
                                        DN_ANY_ACCESS_OF;
            WHEN DN_ANY_ACCESS_OF =>
               IF SPEC_KIND = DN_ANY_ACCESS_OF THEN
                  RETURN D(XD_ITEM, UNSPEC_TYPE) = D(
                                                XD_ITEM, SPEC_TYPE);
               ELSIF SPEC_KIND = DN_ACCESS THEN
                  RETURN D(XD_ITEM, UNSPEC_TYPE)
                                                = GET_BASE_TYPE(D(
                                                        SM_DESIG_TYPE,
                                                        SPEC_STRUCT));
               ELSE
                                        -- (FALSE IF SPEC_TYPE IS ACCESS)
                  RETURN FALSE;
               END IF;
            WHEN DN_ANY_COMPOSITE =>
               RETURN IS_NONLIMITED_COMPOSITE_TYPE(
                                        SPEC_TYPE);
            WHEN DN_ANY_STRING =>
               RETURN IS_STRING_TYPE(SPEC_TYPE);
            WHEN DN_ANY_INTEGER =>
               RETURN SPEC_KIND = DN_INTEGER
                                        OR SPEC_KIND =
                                        DN_UNIVERSAL_INTEGER;
            WHEN DN_ANY_REAL =>
               RETURN SPEC_KIND = DN_FLOAT
                                        OR SPEC_KIND = DN_FIXED
                                        OR SPEC_KIND = DN_UNIVERSAL_REAL;
         
         END CASE;
      END IS_MEMBER_OF_UNSPECIFIED;
   
   
       FUNCTION IS_NONLIMITED_COMPOSITE_TYPE (TYPE_SPEC: TREE) RETURN
                        BOOLEAN IS
         TYPE_KIND: NODE_NAME;
      BEGIN
         TYPE_KIND := GET_BASE_STRUCT(TYPE_SPEC).TY;
         IF TYPE_KIND = DN_ANY_STRING THEN
            RETURN TRUE;
         ELSIF TYPE_KIND = DN_ARRAY OR ELSE TYPE_KIND = DN_RECORD THEN
            RETURN IS_NONLIMITED_TYPE(TYPE_SPEC);
         ELSE
            RETURN FALSE;
         END IF;
      END IS_NONLIMITED_COMPOSITE_TYPE;
   
   
       FUNCTION IS_STRING_TYPE (TYPE_SPEC: TREE) RETURN BOOLEAN IS
         TYPE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
      BEGIN
         IF TYPE_STRUCT.TY = DN_ANY_STRING THEN
            RETURN TRUE;
         ELSIF TYPE_STRUCT.TY = DN_ARRAY
                                AND THEN IS_EMPTY(TAIL(LIST(D(SM_INDEX_S,
                                                        TYPE_STRUCT)))) THEN
            RETURN IS_CHARACTER_TYPE
                                (GET_BASE_TYPE(D(SM_COMP_TYPE,TYPE_STRUCT)));
         ELSE
            RETURN FALSE;
         END IF;
      END IS_STRING_TYPE;
   
   
       FUNCTION IS_CHARACTER_TYPE (TYPE_SPEC: TREE) RETURN BOOLEAN IS
         TYPE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
         ENUM_LIST:	SEQ_TYPE;
         ENUM_ID:	TREE;
      BEGIN
         IF TYPE_STRUCT.TY /= DN_ENUMERATION THEN
            RETURN FALSE;
         END IF;
      
                -- $$$$ NEED A FASTER TEST FOR TYPE DERIV FROM PREDEF CHARACTER
         ENUM_LIST := LIST(D(SM_LITERAL_S, TYPE_SPEC));
         WHILE NOT IS_EMPTY(ENUM_LIST) LOOP
            POP(ENUM_LIST, ENUM_ID);
            IF ENUM_ID.TY = DN_CHARACTER_ID THEN
               RETURN TRUE;
            END IF;
         END LOOP;
      
         RETURN FALSE;
      END IS_CHARACTER_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REQUIRE_SAME_TYPES
                        ( EXP_1:	TREE
                        ; TYPESET_1:	TYPESET_TYPE
                        ; EXP_2:	TREE
                        ; TYPESET_2:	TYPESET_TYPE
                        ; TYPESET_OUT:	OUT TYPESET_TYPE )
                        IS
         TYPESET_1_WORK: 	TYPESET_TYPE := TYPESET_1;
         TYPEINTERP_1:		TYPEINTERP_TYPE;
         TYPE_SPEC_1:		TREE;
         TYPESET_2_WORK: 	TYPESET_TYPE;
         TYPEINTERP_2:		TYPEINTERP_TYPE;
         TYPE_SPEC_2:		TREE;
         NEW_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
      
      BEGIN -- REQUIRE_SAME_TYPES
         IF IS_EMPTY(TYPESET_1) OR ELSE IS_EMPTY(TYPESET_2) THEN
            TYPESET_OUT := EMPTY_TYPESET;
            RETURN;
         END IF;
      
         WHILE NOT IS_EMPTY(TYPESET_1_WORK) LOOP
            POP(TYPESET_1_WORK, TYPEINTERP_1);
            TYPE_SPEC_1 := GET_TYPE(TYPEINTERP_1);
            TYPESET_2_WORK := TYPESET_2;
            WHILE NOT IS_EMPTY(TYPESET_2_WORK) LOOP
               POP(TYPESET_2_WORK, TYPEINTERP_2);
               TYPE_SPEC_2 := GET_TYPE(TYPEINTERP_2);
               IF TYPE_SPEC_1 = TYPE_SPEC_2
                                                OR ELSE
                                                IS_MEMBER_OF_UNSPECIFIED
                                                (TYPE_SPEC_1, TYPE_SPEC_2)
                                                THEN
                  ADD_EXTRAINFO(TYPEINTERP_1,
                                                TYPEINTERP_2);
                  ADD_TO_TYPESET(NEW_TYPESET,
                                                TYPEINTERP_1);
               ELSIF IS_MEMBER_OF_UNSPECIFIED
                                                (TYPE_SPEC_2, TYPE_SPEC_1)
                                                THEN
                  ADD_EXTRAINFO(TYPEINTERP_2,
                                                TYPEINTERP_1);
                  ADD_TO_TYPESET(NEW_TYPESET,
                                                TYPEINTERP_2);
               END IF;
            END LOOP;
         END LOOP;
      
         IF IS_EMPTY(NEW_TYPESET) THEN
            ERROR(D(LX_SRCPOS,EXP_1),
                                "EXPRESSIONS MUST BE OF THE SAME TYPE");
         END IF;
         TYPESET_OUT := NEW_TYPESET;
      END REQUIRE_SAME_TYPES;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REQUIRE_TYPE
                        ( TYPE_SPEC:	TREE
                        ; EXP:		TREE
                        ; TYPESET:	IN OUT TYPESET_TYPE )
                        IS
         TYPE_STRUCT:	TREE;
         TYPEINTERP:	TYPEINTERP_TYPE;
         TYPE_NODE:	TREE;
         TYPE_KIND:	NODE_NAME;
         NEW_TYPESET:	TYPESET_TYPE := EMPTY_TYPESET;
      BEGIN
         IF IS_EMPTY(TYPESET) THEN
            RETURN;
         END IF;
      
         WHILE NOT IS_EMPTY(TYPESET) LOOP
            POP(TYPESET, TYPEINTERP);
            TYPE_NODE := GET_TYPE(TYPEINTERP);
            IF TYPE_NODE = TYPE_SPEC THEN
               ADD_TO_TYPESET(NEW_TYPESET, TYPEINTERP);
            ELSE
               TYPE_KIND := TYPE_NODE.TY;
               IF TYPE_KIND IN CLASS_UNSPECIFIED_TYPE THEN
                  TYPE_STRUCT := GET_BASE_STRUCT(
                                                TYPE_SPEC);
                  CASE CLASS_UNSPECIFIED_TYPE'(
                                                                TYPE_KIND) IS
                     WHEN DN_ANY_ACCESS =>
                        IF TYPE_STRUCT.TY =
                                                                        DN_ACCESS THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                     WHEN DN_ANY_COMPOSITE =>
                        IF
                                                                        IS_NONLIMITED_COMPOSITE_TYPE(
                                                                        TYPE_SPEC) THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                     WHEN DN_ANY_STRING =>
                        IF IS_STRING_TYPE(
                                                                        TYPE_SPEC) THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                     WHEN DN_ANY_ACCESS_OF =>
                        IF TYPE_STRUCT.TY =
                                                                        DN_ACCESS
                                                                        AND THEN
                                                                        GET_BASE_TYPE(
                                                                        D(
                                                                                SM_DESIG_TYPE,
                                                                                TYPE_STRUCT))
                                                                        =
                                                                        GET_BASE_TYPE(
                                                                        D(
                                                                                XD_ITEM,
                                                                                TYPE_NODE))
                                                                        THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                     WHEN DN_ANY_INTEGER =>
                        IF IS_INTEGER_TYPE(
                                                                        TYPE_SPEC) THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                     WHEN DN_ANY_REAL =>
                        IF IS_REAL_TYPE(
                                                                        TYPE_SPEC) THEN
                           ADD_TO_TYPESET
                                                                        (
                                                                        NEW_TYPESET
                                                                        ,
                                                                        TYPE_SPEC
                                                                        ,
                                                                        GET_EXTRAINFO(
                                                                                TYPEINTERP) );
                        END IF;
                  END CASE;
               END IF;
            END IF;
         END LOOP;
      
         TYPESET := NEW_TYPESET;
         IF IS_EMPTY(TYPESET) THEN
            ERROR(D(LX_SRCPOS,EXP), "EXP NOT OF REQUIRED TYPE");
         END IF;
      END REQUIRE_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_NONLIMITED_TYPE(ITEM: TREE) RETURN BOOLEAN IS
      
         TYPE_SPEC:	CONSTANT TREE := GET_BASE_STRUCT(ITEM);
      
      
          FUNCTION GET_VARIABLE_TYPE_SPEC(VARIABLE_DECL: TREE) RETURN
                                TREE IS
            SOURCE_NAME_LIST: SEQ_TYPE
                                := LIST(D(AS_SOURCE_NAME_S,VARIABLE_DECL));
         BEGIN
            RETURN GET_BASE_TYPE(D(SM_OBJ_TYPE, HEAD(
                                                SOURCE_NAME_LIST)));
         END GET_VARIABLE_TYPE_SPEC;
      
      
          FUNCTION IS_NONLIMITED_COMP_LIST(COMP_LIST: TREE) RETURN
                                BOOLEAN IS
            ITEM_LIST:		SEQ_TYPE := LIST(COMP_LIST);
            ITEM:		TREE;
            DECL_LIST:		SEQ_TYPE;
            DECL:		TREE;
            VARIANT_PART:	TREE;
            VARIANT_LIST:	SEQ_TYPE;
            VARIANT:		TREE;
         BEGIN
            WHILE NOT IS_EMPTY(ITEM_LIST) LOOP
               POP(ITEM_LIST, ITEM);
               DECL_LIST := LIST(D(AS_DECL_S,ITEM));
               WHILE NOT IS_EMPTY(DECL_LIST) LOOP
                  POP(DECL_LIST, DECL);
                  IF DECL.TY = DN_VARIABLE_DECL THEN
                     IF NOT IS_NONLIMITED_TYPE(
                                                                GET_VARIABLE_TYPE_SPEC(
                                                                        DECL))
                                                                THEN
                        RETURN FALSE;
                     END IF;
                  END IF;
               END LOOP;
               VARIANT_PART := D(AS_VARIANT_PART, ITEM);
               IF VARIANT_PART.TY = DN_VARIANT_PART THEN
                  VARIANT_LIST := LIST(D(
                                                        AS_VARIANT_S,
                                                        VARIANT_PART));
                  WHILE NOT IS_EMPTY(VARIANT_LIST) LOOP
                     POP(VARIANT_LIST, VARIANT);
                     IF VARIANT.TY =
                                                                DN_VARIANT THEN
                        IF NOT
                                                                        IS_NONLIMITED_COMP_LIST
                                                                        (
                                                                        D(
                                                                                AS_COMP_LIST,
                                                                                VARIANT) )
                                                                        THEN
                           RETURN
                                                                        FALSE;
                        
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
            RETURN TRUE;
         END IS_NONLIMITED_COMP_LIST;
      
      BEGIN -- IS_NONLIMITED_TYPE
      
         IF TYPE_SPEC = TREE_VOID THEN
            RETURN TRUE;
         END IF;
      
         CASE CLASS_TYPE_SPEC'(TYPE_SPEC.TY) IS
            WHEN DN_TASK_SPEC | DN_L_PRIVATE | DN_INCOMPLETE =>
               RETURN FALSE;
            WHEN DN_RECORD =>
               IF NOT DB(SM_IS_LIMITED, TYPE_SPEC) THEN
                  RETURN TRUE;
               ELSE
                  RETURN IS_NONLIMITED_COMP_LIST(D(
                                                        SM_COMP_LIST,
                                                        TYPE_SPEC));
               END IF;
            WHEN DN_ARRAY =>
               IF DB(SM_IS_LIMITED, TYPE_SPEC) THEN
                  RETURN FALSE;
               ELSE
                  RETURN IS_NONLIMITED_TYPE(D(
                                                        SM_COMP_TYPE,
                                                        TYPE_SPEC));
               END IF;
            WHEN OTHERS =>
               RETURN TRUE;
         END CASE;
      END IS_NONLIMITED_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_LIMITED_TYPE(ITEM: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN NOT IS_NONLIMITED_TYPE(ITEM);
      END IS_LIMITED_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_PRIVATE_TYPE(ITEM: TREE) RETURN BOOLEAN IS
                -- RETURNS TRUE IF ITEM IS PRIVATE
                -- $$$$ WORRY ABOUT WHAT THIS MEANS
         TYPE_SPEC:	CONSTANT TREE := GET_BASE_STRUCT(ITEM);
      
      BEGIN -- IS_PRIVATE_TYPE
      
         CASE CLASS_TYPE_SPEC'(TYPE_SPEC.TY) IS
            WHEN DN_TASK_SPEC | DN_L_PRIVATE | DN_INCOMPLETE |
                                        DN_PRIVATE =>
               RETURN TRUE;
            WHEN DN_ARRAY =>
               CASE CLASS_TYPE_SPEC( GET_BASE_STRUCT( D( SM_COMP_TYPE, TYPE_SPEC ) ).TY ) IS
                  WHEN DN_TASK_SPEC | DN_L_PRIVATE |
                                                        DN_INCOMPLETE |
                                                        DN_PRIVATE =>
                     RETURN TRUE;
                  WHEN OTHERS =>
                     RETURN FALSE;
               END CASE;
            WHEN OTHERS =>
               RETURN FALSE;
         END CASE;
      END IS_PRIVATE_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_INTEGER_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         TYPE_SPEC:	CONSTANT TREE := GET_BASE_STRUCT(ITEM);
         TYPE_KIND:	CONSTANT NODE_NAME := TYPE_SPEC.TY;
      BEGIN
         RETURN TYPE_KIND = DN_INTEGER
                        OR TYPE_KIND = DN_UNIVERSAL_INTEGER
                        OR TYPE_KIND = DN_ANY_INTEGER;
      END IS_INTEGER_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_REAL_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         TYPE_SPEC:	CONSTANT TREE := GET_BASE_STRUCT(ITEM);
         TYPE_KIND:	CONSTANT NODE_NAME := TYPE_SPEC.TY;
      BEGIN
         RETURN TYPE_KIND = DN_FLOAT
                        OR TYPE_KIND = DN_FIXED
                        OR TYPE_KIND = DN_UNIVERSAL_REAL
                        OR TYPE_KIND = DN_ANY_REAL;
      END IS_REAL_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_SCALAR_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         TYPE_SPEC:	CONSTANT TREE := GET_BASE_STRUCT(ITEM);
         TYPE_KIND:	CONSTANT NODE_NAME := TYPE_SPEC.TY;
      BEGIN
         RETURN TYPE_KIND IN CLASS_SCALAR
                        OR TYPE_KIND = DN_UNIVERSAL_INTEGER
                        OR TYPE_KIND = DN_UNIVERSAL_REAL
                        OR TYPE_KIND IN DN_ANY_INTEGER .. DN_ANY_REAL;
      END IS_SCALAR_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_BOOLEAN_TYPE(ITEM: TREE) RETURN BOOLEAN IS
      BEGIN
                -- TYPE IS BOOLEAN IF IT IS DERIVED FROM PREDEFINED BOOLEAN
         RETURN GET_ANCESTOR_TYPE(ITEM) = PREDEFINED_BOOLEAN;
      END IS_BOOLEAN_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_UNIVERSAL_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         ITEM_KIND: NODE_NAME := ITEM.TY;
      BEGIN
         RETURN ITEM_KIND = DN_UNIVERSAL_INTEGER
                        OR ITEM_KIND = DN_UNIVERSAL_REAL
                        OR ITEM_KIND = DN_ANY_INTEGER
                        OR ITEM_KIND = DN_ANY_REAL;
      END IS_UNIVERSAL_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_NON_UNIVERSAL_TYPE(ITEM: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN NOT IS_UNIVERSAL_TYPE(ITEM);
      END IS_NON_UNIVERSAL_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_DISCRETE_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         BASE_STRUCT: TREE := GET_BASE_STRUCT(ITEM);
      BEGIN
         CASE BASE_STRUCT.TY IS
            WHEN DN_ENUMERATION | DN_INTEGER |
                                        DN_UNIVERSAL_INTEGER
                                        | DN_ANY_INTEGER =>
               RETURN TRUE;
            WHEN OTHERS =>
               RETURN FALSE;
         END CASE;
      END IS_DISCRETE_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_TASK_TYPE(ITEM: TREE) RETURN BOOLEAN IS
         BASE_STRUCT: TREE := GET_BASE_STRUCT(ITEM);
      BEGIN
         RETURN BASE_STRUCT.TY = DN_TASK_SPEC;
      END IS_TASK_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REQUIRE_ID
                        ( ID_KIND:	NODE_NAME
                        ; EXP:		TREE
                        ; DEFSET:	IN OUT DEFSET_TYPE )
                        IS
         DEFINTERP: DEFINTERP_TYPE;
         NEW_DEFSET: DEFSET_TYPE := EMPTY_DEFSET;
      BEGIN
         IF IS_EMPTY(DEFSET) THEN
            RETURN;
         END IF;
      
         WHILE NOT IS_EMPTY(DEFSET) LOOP
            POP(DEFSET, DEFINTERP);
            IF D(XD_SOURCE_NAME, GET_DEF(DEFINTERP)).TY =
                                        ID_KIND THEN
               ADD_TO_DEFSET(NEW_DEFSET, DEFINTERP);
            END IF;
         END LOOP;
      
         DEFSET := NEW_DEFSET;
         IF IS_EMPTY(DEFSET) THEN
            ERROR(D(LX_SRCPOS, EXP), "NAME IS NOT "
                                & NODE_NAME'IMAGE(ID_KIND) );
         END IF;
      END REQUIRE_ID;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_TYPE_DEF(ITEM: TREE) RETURN BOOLEAN IS
         ITEM_KIND: NODE_NAME := D(XD_SOURCE_NAME,ITEM).TY;
      BEGIN
         RETURN ITEM_KIND IN CLASS_TYPE_NAME;
      END IS_TYPE_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_ENTRY_DEF(ITEM: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN D(XD_SOURCE_NAME, ITEM).TY = DN_ENTRY_ID;
      END IS_ENTRY_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_PROC_OR_ENTRY_DEF(ITEM: TREE) RETURN BOOLEAN IS
         SOURCE_NAME_KIND: NODE_NAME := D(XD_SOURCE_NAME, ITEM ).TY;
      BEGIN
         IF SOURCE_NAME_KIND = DN_PROCEDURE_ID
                                OR ELSE SOURCE_NAME_KIND = DN_ENTRY_ID THEN
            RETURN TRUE;
         ELSIF SOURCE_NAME_KIND = DN_GENERIC_ID
                                AND THEN D(XD_HEADER, ITEM).TY =
                                DN_PROCEDURE_SPEC
                                THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IS_PROC_OR_ENTRY_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_FUNCTION_OR_ARRAY_DEF(ITEM: TREE) RETURN BOOLEAN IS
         ITEM_KIND: NODE_NAME := D(XD_SOURCE_NAME,ITEM).TY;
         ITEM_STRUCT: TREE;
      BEGIN
         IF ITEM_KIND = DN_FUNCTION_ID OR ITEM_KIND =
                                DN_OPERATOR_ID
                                OR ITEM_KIND = DN_BLTN_OPERATOR_ID
                                THEN
            RETURN TRUE;
         ELSIF ITEM_KIND = DN_GENERIC_ID
                                AND THEN D(XD_HEADER, ITEM).TY =
                                DN_FUNCTION_SPEC THEN
            RETURN TRUE;
         ELSIF ITEM_KIND IN CLASS_OBJECT_NAME THEN
            ITEM_STRUCT := GET_BASE_STRUCT(D(XD_SOURCE_NAME,
                                        ITEM));
            IF ITEM_STRUCT.TY = DN_ACCESS THEN
               ITEM_STRUCT := GET_BASE_STRUCT(D(
                                                SM_DESIG_TYPE, ITEM_STRUCT));
            END IF;
            RETURN ITEM_STRUCT.TY = DN_ARRAY;
         ELSE
            RETURN FALSE;
         END IF;
      END IS_FUNCTION_OR_ARRAY_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_FUNCTION_OR_ENUMERATION_DEF(ITEM: TREE) RETURN BOOLEAN IS
         ITEM_KIND: NODE_NAME := D(XD_SOURCE_NAME,ITEM).TY;
      BEGIN
         IF ITEM_KIND = DN_FUNCTION_ID OR ITEM_KIND =
                                DN_OPERATOR_ID
                                OR ITEM_KIND = DN_BLTN_OPERATOR_ID
                                OR ITEM_KIND = DN_ENUMERATION_ID
                                THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IS_FUNCTION_OR_ENUMERATION_DEF;
   
       PROCEDURE REQUIRE_NONLIMITED_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_NONLIMITED_TYPE	IS NEW REQ_TYPE_XXX ( IS_NONLIMITED_TYPE, "NONLIMITED TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_NONLIMITED_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_INTEGER_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_INTEGER_TYPE	IS NEW REQ_TYPE_XXX ( IS_INTEGER_TYPE, "INTEGER TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_INTEGER_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_BOOLEAN_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_BOOLEAN_TYPE	IS NEW REQ_TYPE_XXX ( IS_BOOLEAN_TYPE, "BOOLEAN TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_BOOLEAN_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_REAL_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_REAL_TYPE		IS NEW REQ_TYPE_XXX ( IS_REAL_TYPE, "REAL TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_REAL_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_SCALAR_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_SCALAR_TYPE		IS NEW REQ_TYPE_XXX ( IS_SCALAR_TYPE, "SCALAR TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_SCALAR_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_UNIVERSAL_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_UNIVERSAL_TYPE	IS NEW REQ_TYPE_XXX ( IS_UNIVERSAL_TYPE, "UNIVERSAL TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_UNIVERSAL_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_NON_UNIVERSAL_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_NON_UNIVERSAL_TYPE	IS NEW REQ_TYPE_XXX ( IS_NON_UNIVERSAL_TYPE, "NON-UNIVERSAL TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_NON_UNIVERSAL_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_DISCRETE_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_DISCRETE_TYPE	IS NEW REQ_TYPE_XXX ( IS_DISCRETE_TYPE, "DISCRETE TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_DISCRETE_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_TASK_TYPE ( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE ) IS
          PROCEDURE N_REQUIRE_TASK_TYPE		IS NEW REQ_TYPE_XXX ( IS_TASK_TYPE, "TASK TYPE REQUIRED" );
      BEGIN
         N_REQUIRE_TASK_TYPE ( EXP, TYPESET );
      END;
       PROCEDURE REQUIRE_TYPE_DEF ( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE ) IS
          PROCEDURE N_REQUIRE_TYPE_DEF		IS NEW REQ_DEF_XXX ( IS_TYPE_DEF, "TYPE OR SUBTYPE NAME REQUIRED" );
      BEGIN
         N_REQUIRE_TYPE_DEF ( EXP, DEFSET );
      END;
       PROCEDURE REQUIRE_ENTRY_DEF ( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE ) IS
          PROCEDURE N_REQUIRE_ENTRY_DEF		IS NEW REQ_DEF_XXX ( IS_ENTRY_DEF, "ENTRY NAME REQUIRED" );
      BEGIN
         N_REQUIRE_ENTRY_DEF ( EXP, DEFSET );
      END;
       PROCEDURE REQUIRE_PROC_OR_ENTRY_DEF ( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE ) IS
          PROCEDURE N_REQUIRE_PROC_OR_ENTRY_DEF	IS NEW REQ_DEF_XXX ( IS_PROC_OR_ENTRY_DEF, "PROCEDURE OR ENTRY NAME REQUIRED" );
      BEGIN
         N_REQUIRE_PROC_OR_ENTRY_DEF ( EXP, DEFSET );
      END;
       PROCEDURE REQUIRE_FUNCTION_OR_ARRAY_DEF ( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE ) IS
          PROCEDURE N_REQUIRE_FUNCTION_OR_ARRAY_DEF	IS NEW REQ_DEF_XXX ( IS_FUNCTION_OR_ARRAY_DEF, "FUNCTION OR ARRAY OR ACCESS ARRAY REQUIRED" );
      BEGIN
         N_REQUIRE_FUNCTION_OR_ARRAY_DEF ( EXP, DEFSET );
      END;
       PROCEDURE REQUIRE_FUNCTION_OR_ENUMERATION_DEF ( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE ) IS
          PROCEDURE N_REQUIRE_FUNCTION_OR_ENUMERATION_DEF	IS NEW REQ_DEF_XXX ( IS_FUNCTION_OR_ENUMERATION_DEF, "FUNCTION OR ENUMERATION LITERAL REQUIRED" );
      BEGIN
         N_REQUIRE_FUNCTION_OR_ENUMERATION_DEF ( EXP, DEFSET );
      END;
   
   
    --|----------------------------------------------------------------------------------------------
   END REQ_UTIL;
