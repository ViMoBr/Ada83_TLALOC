    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	DEF_WALK
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY DEF_WALK IS
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE MAKE_NOD;
      USE NOD_WALK;
      USE EXP_TYPE, EXPRESO;
      USE REQ_UTIL;
      USE SET_UTIL;
      USE GEN_SUBS;
   
       FUNCTION COPY_COMP_LIST_IDS(COMP_LIST: TREE; H: H_TYPE) RETURN
                TREE;
       FUNCTION COPY_ITEM_S_IDS(ITEM_S: TREE; H: H_TYPE) RETURN TREE;
       PROCEDURE WALK_COMP_LIST (COMP_LIST: TREE; H: H_TYPE);
   
   
       PROCEDURE PRINT_REAL(R: TREE) IS -- $$$$ DEBUG ONLY
      BEGIN
         IF R.TY = DN_REAL_VAL THEN
            PRINT_TREE(D ( XD_NUMER,R));
            PUT("/");
            PRINT_TREE(D ( XD_DENOM,R));
         ELSE
            PRINT_TREE(R);
         END IF;
      END PRINT_REAL;
   
   
        -- $$$$ SHOULDN'T BE HERE
       FUNCTION GET_SUBSTRUCT(TYPE_SPEC: TREE) RETURN TREE IS
         SUBTYPE_SPEC: TREE;
      BEGIN
         IF TYPE_SPEC.TY IN CLASS_PRIVATE_SPEC THEN
            SUBTYPE_SPEC := D ( SM_TYPE_SPEC, TYPE_SPEC);
            IF SUBTYPE_SPEC /= TREE_VOID THEN
               RETURN SUBTYPE_SPEC;
            END IF;
         ELSIF TYPE_SPEC.TY = DN_INCOMPLETE THEN
            SUBTYPE_SPEC := D ( XD_FULL_TYPE_SPEC, TYPE_SPEC);
            IF SUBTYPE_SPEC /= TREE_VOID THEN
               RETURN SUBTYPE_SPEC;
            END IF;
         END IF;
         RETURN TYPE_SPEC;
      END GET_SUBSTRUCT;
   
       FUNCTION EVAL_TYPE_DEF
                        ( TYPE_DEF: TREE
                        ; ID: TREE
                        ; H: H_TYPE
                        ; DSCRMT_DECL_S: TREE := TREE_VOID )
                        RETURN TREE
                        IS
      
         TYPE_SPEC: TREE := TREE_VOID;
         BASE_TYPE: TREE := TREE_VOID;
         RECORD_REGION_DEF: TREE;
      BEGIN
      
         IF TYPE_DEF = TREE_VOID THEN
            RETURN TREE_VOID;
         END IF;
      
                -- GET BASE TYPE IN CASE IT IS PRIVATE, L_PRIVATE OR INCOMPLETE
         IF ID.TY = DN_TYPE_ID
                                AND THEN D ( SM_FIRST, ID) /= ID THEN
            BASE_TYPE := D ( SM_TYPE_SPEC, D ( SM_FIRST, ID));
         END IF;
      
         CASE CLASS_TYPE_DEF'(TYPE_DEF.TY) IS
         
                        -- FOR AN ENUMERATION_TYPE_DECLARATION
            WHEN DN_ENUMERATION_DEF =>
               DECLARE
                  ENUM_LITERAL_S: CONSTANT TREE := D ( 
                                                AS_ENUM_LITERAL_S,
                                                TYPE_DEF);
                  ENUM_LITERAL_LIST: SEQ_TYPE :=
                                                LIST(ENUM_LITERAL_S);
                  ENUM_LITERAL: TREE;
                  DEF, PRIOR_DEF: TREE;
                  ENUM_LITERAL_COUNT: INTEGER := 0;
                  ENUM_HEADER: TREE;
                  PRIVATE_SPEC: TREE := D ( 
                                                SM_TYPE_SPEC, ID);
               BEGIN
               
                                        -- CREATE THE ENUMERATION NODE
                  TYPE_SPEC := MAKE_ENUMERATION
                                                ( SM_LITERAL_S =>
                                                ENUM_LITERAL_S
                                                , XD_SOURCE_NAME => ID );
                  IF BASE_TYPE = TREE_VOID THEN
                     BASE_TYPE := TYPE_SPEC;
                  END IF;
                  D ( SM_BASE_TYPE, TYPE_SPEC,
                                                BASE_TYPE);
               
                                        -- INSERT NAMES IN ENVIRONMENT
                  WALK_SOURCE_NAME_S(ENUM_LITERAL_S,
                                                H);
               
                                        -- MAKE A HEADER FOR THE DEF NODES FOR THE ENUM LITERALS
                  ENUM_HEADER := MAKE_FUNCTION_SPEC
                                                ( AS_NAME =>
                                                MAKE_USED_NAME_ID
                                                ( LX_SYMREP => TREE_VOID
                                                        , SM_DEFN => ID )
                                                , AS_PARAM_S =>
                                                MAKE_PARAM_S (LIST => (TREE_NIL,TREE_NIL)) );
               
                                        -- STORE TYPE SPEC IN TYPE SPEC IN TYPE ID
                                        -- ... (NEEDED FOR GET_PRIOR_HOMOGRAPH_DEF)
                  D ( SM_TYPE_SPEC, ID, BASE_TYPE);
               
                                        -- FOR EACH ENUM_LITERAL
                  WHILE NOT IS_EMPTY ( 
                                                        ENUM_LITERAL_LIST) LOOP
                     POP ( ENUM_LITERAL_LIST,
                                                        ENUM_LITERAL);
                  
                                                -- STORE THE BASE TYPE
                     D ( SM_OBJ_TYPE,
                                                        ENUM_LITERAL,
                                                        BASE_TYPE);
                  
                                                -- ASSIGN SM_POS AND DEFAULT SM_REP ATTRIBUTES
                     DI(SM_POS, ENUM_LITERAL,
                                                        ENUM_LITERAL_COUNT);
                     DI(SM_REP, ENUM_LITERAL,
                                                        ENUM_LITERAL_COUNT);
                     ENUM_LITERAL_COUNT :=
                                                        ENUM_LITERAL_COUNT +
                                                        1;
                  
                                                -- MAKE DEF VISIBLE FOR THIS ENUM LITERAL
                     DEF := GET_DEF_FOR_ID(
                                                        ENUM_LITERAL);
                     MAKE_DEF_VISIBLE(DEF,
                                                        ENUM_HEADER);
                  
                                                -- CHECK FOR UNIQUENESS
                     PRIOR_DEF :=
                                                        GET_PRIOR_HOMOGRAPH_DEF(
                                                        DEF);
                     IF PRIOR_DEF /= TREE_VOID
                                                                AND THEN (NOT
                                                                IS_OVERLOADABLE_HEADER(
                                                                        D ( 
                                                                                XD_HEADER,
                                                                                DEF))
                                                                OR ELSE
                                                                EXPRESSION_TYPE_OF_DEF(
                                                                        DEF) =
                                                                TYPE_SPEC)
                                                                THEN
                        ERROR(D ( LX_SRCPOS,
                                                                        TYPE_DEF)
                                                                ,
                                                                "ENUM LITERAL IS DUPLICATE - "
                                                                &
                                                                PRINT_NAME(
                                                                        D ( 
                                                                                LX_SYMREP,
                                                                                ENUM_LITERAL)) );
                        MAKE_DEF_IN_ERROR(
                                                                DEF);
                     END IF;
                  END LOOP;
               
                                        -- CONSTRUCT SM_RANGE ATTRIBUTE FOR THE ENUMERATION NODE
                  D ( SM_RANGE, TYPE_SPEC, MAKE_RANGE
                                                ( SM_TYPE_SPEC =>
                                                        TYPE_SPEC
                                                        , AS_EXP1 =>
                                                        MAKE_USED_OBJECT_ID
                                                        ( SM_EXP_TYPE =>
                                                                TYPE_SPEC
                                                                , SM_DEFN =>
                                                                HEAD(LIST(
                                                                                ENUM_LITERAL_S))
                                                                ,
                                                                LX_SYMREP =>
                                                                D ( 
                                                                        LX_SYMREP
                                                                        ,
                                                                        HEAD(
                                                                                LIST(
                                                                                        ENUM_LITERAL_S)) )
                                                                , SM_VALUE =>
                                                                UARITH.U_VAL(
                                                                        0) )
                                                        , AS_EXP2 =>
                                                        MAKE_USED_OBJECT_ID
                                                        ( SM_EXP_TYPE =>
                                                                TYPE_SPEC
                                                                , SM_DEFN =>
                                                                ENUM_LITERAL
                                                                ,
                                                                LX_SYMREP =>
                                                                D ( 
                                                                        LX_SYMREP,
                                                                        ENUM_LITERAL)
                                                                , SM_VALUE =>
                                                                UARITH.U_VAL
                                                                (
                                                                        ENUM_LITERAL_COUNT -
                                                                        1 ))));
               
                                        -- COMPUTE SIZE AND STORE IN ENUMERATION NODE
                  IF ENUM_LITERAL_COUNT > 2 ** 8 THEN
                     DI(CD_IMPL_SIZE, TYPE_SPEC,
                                                        16);
                  ELSE
                     DI(CD_IMPL_SIZE, TYPE_SPEC,
                                                        8);
                  END IF;
               
                                        -- RESTORE TYPE SPEC IN TYPE SPEC IN TYPE ID
                                        -- ... (NO LONGER NEEDED FOR GET_PRIOR_HOMOGRAPH_DEF)
                  IF PRIVATE_SPEC /= TREE_VOID THEN
                     D ( SM_TYPE_SPEC, ID,
                                                        PRIVATE_SPEC);
                  END IF;
               END;
         
         
                        -- FOR A SUBTYPE INDICATION
            WHEN DN_SUBTYPE_INDICATION =>
               DECLARE
                  SUBTYPE_INDICATION: TREE :=
                                                TYPE_DEF;
                  BASE_TYPE: TREE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
               BEGIN
               
                                        -- RESOLVE SUBTYPE INDICATION AND GET ITS SUBTYPE
                  RESOLVE_SUBTYPE_INDICATION (
                                                SUBTYPE_INDICATION,
                                                TYPE_SPEC);
               
                                        -- RETURN WITHOUT MODIFYING BASE TYPE, ETC.
                  RETURN TYPE_SPEC;
               END;
         
         
                        -- FOR AN INTEGER_TYPE_DEFINITION
            WHEN DN_INTEGER_DEF =>
               DECLARE
                  USE UARITH;
               
                  RANGE_NODE:     CONSTANT TREE := D ( 
                                                AS_CONSTRAINT, TYPE_DEF);
                  EXP1:           TREE := D ( AS_EXP1,
                                                RANGE_NODE);
                  EXP2:           TREE := D ( AS_EXP2,
                                                RANGE_NODE);
               
                  TYPESET_1:      TYPESET_TYPE;
                  TYPESET_2:      TYPESET_TYPE;
                  LOWER_BOUND:    TREE;
                  UPPER_BOUND:    TREE;
               
                  ANCESTOR_TYPE:  TREE;
                  DERIVED_BASE:   TREE;
               BEGIN
               
                                        -- EVALUATE THE LOWER BOUND EXPRESSION
                  EVAL_EXP_TYPES(EXP1, TYPESET_1);
                  REQUIRE_INTEGER_TYPE(EXP1,
                                                TYPESET_1);
                  REQUIRE_UNIQUE_TYPE(EXP1,
                                                TYPESET_1);
                  EXP1 := RESOLVE_EXP(EXP1,
                                                TYPESET_1);
                  D ( AS_EXP1, RANGE_NODE, EXP1);
                  LOWER_BOUND := GET_STATIC_VALUE(
                                                EXP1);
               
                                        -- EVALUATE THE UPPER BOUND EXPRESSION
                  EVAL_EXP_TYPES(EXP2, TYPESET_2);
                  REQUIRE_INTEGER_TYPE(EXP2,
                                                TYPESET_2);
                  REQUIRE_UNIQUE_TYPE(EXP2,
                                                TYPESET_2);
                  EXP2 := RESOLVE_EXP(EXP2,
                                                TYPESET_2);
                  D ( AS_EXP2, RANGE_NODE, EXP2);
                  UPPER_BOUND := GET_STATIC_VALUE(
                                                EXP2);
               
                                        -- IF BOTH BOUNDS ARE STATIC
                  IF LOWER_BOUND /= TREE_VOID AND
                                                        UPPER_BOUND /=
                                                        TREE_VOID THEN
                  
                                                -- IF RANGE FITS WITHIN SHORT_INTEGER
                     IF LOWER_BOUND >=
                                                                PREDEFINED_SHORT_INTEGER_FIRST
                                                                AND
                                                                UPPER_BOUND <=
                                                                PREDEFINED_SHORT_INTEGER_LAST
                                                                AND
                                                                PREDEFINED_SHORT_INTEGER /=
                                                                TREE_VOID THEN
                                                        -- USE SHORT_INTEGER
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_SHORT_INTEGER;
                     
                                                        -- ELSE IF RANGE FITS WITHIN INTEGER
                     ELSIF LOWER_BOUND >=
                                                                PREDEFINED_INTEGER_FIRST
                                                                AND
                                                                UPPER_BOUND <=
                                                                PREDEFINED_INTEGER_LAST THEN
                     
                                                        -- USE INTEGER
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_INTEGER;
                     
                                                        -- ELSE IF RANGE FITS WITHIN LONG_INTEGER
                     ELSIF LOWER_BOUND >=
                                                                PREDEFINED_LONG_INTEGER_FIRST
                                                                AND
                                                                UPPER_BOUND <=
                                                                PREDEFINED_LONG_INTEGER_LAST THEN
                     
                                                        -- USE LONG_INTEGER
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_LONG_INTEGER;
                     
                                                        -- ELSE -- SINCE NOT WITHIN ANY PREDEFINED INTEGER TYPE
                     ELSE
                     
                                                        -- REPORT ERROR
                        ERROR( D ( 
                                                                        LX_SRCPOS,
                                                                        RANGE_NODE)
                                                                ,
                                                                "INTEGER TYPE TOO LARGE FOR IMPLEMENTATION" );
                     
                                                        -- ASSUME LARGEST INTEGER TYPE
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_LARGEST_INTEGER;
                     END IF;
                  
                                                -- ELSE -- SINCE AT LEAST ONE BOUND IS NOT STATIC
                  ELSE
                  
                                                -- ASSUME LARGEST INTEGER TYPE
                     ANCESTOR_TYPE :=
                                                        PREDEFINED_LARGEST_INTEGER;
                  
                                                -- IF LOWER BOUND IS NOT STATIC
                                                -- ... AND A TYPE WAS DETERMINED FOR IT
                     IF LOWER_BOUND =
                                                                TREE_VOID
                                                                AND THEN NOT
                                                                IS_EMPTY ( 
                                                                TYPESET_1) THEN
                     
                                                        -- INDICATE ERROR
                        ERROR(D ( LX_SRCPOS,
                                                                        EXP1),
                                                                "BOUNDS MUST BE STATIC");
                     END IF;
                  
                                                -- IF UPPER BOUND IS NOT STATIC
                                                -- ... AND A TYPE WAS DETERMINED FOR IT
                     IF UPPER_BOUND =
                                                                TREE_VOID
                                                                AND THEN NOT
                                                                IS_EMPTY ( 
                                                                TYPESET_2) THEN
                     
                                                        -- INDICATE ERROR
                        ERROR(D ( LX_SRCPOS,
                                                                        EXP2),
                                                                "BOUNDS MUST BE STATIC");
                     END IF;
                  END IF;
               
                                        -- CONSTRUCT ANONYMOUS DERIVED INTEGER TYPE
                  DERIVED_BASE := COPY_NODE(
                                                ANCESTOR_TYPE);
                  IF BASE_TYPE = TREE_VOID THEN
                     BASE_TYPE := DERIVED_BASE;
                  END IF;
                  D ( SM_BASE_TYPE, DERIVED_BASE,
                                                BASE_TYPE);
                  D ( XD_SOURCE_NAME, DERIVED_BASE, ID);
                  DB(SM_IS_ANONYMOUS, DERIVED_BASE,
                                                TRUE);
                  D ( SM_DERIVED, DERIVED_BASE,
                                                ANCESTOR_TYPE);
               
                                        -- CONSTRUCT SUBTYPE OF ANONYMOUS TYPE
                  TYPE_SPEC := COPY_NODE(
                                                DERIVED_BASE);
                  DB(SM_IS_ANONYMOUS, TYPE_SPEC,
                                                FALSE);
                  D ( SM_DERIVED, TYPE_SPEC,
                                                TREE_VOID);
                  D ( SM_RANGE, TYPE_SPEC, RANGE_NODE);
               
                                        -- MAKE RANGE TYPE THE NEW BASE TYPE
                  D ( SM_TYPE_SPEC, RANGE_NODE,
                                                BASE_TYPE);
               END;
         
         
                        -- FOR A FLOATING_POINT_CONSTRAINT USED AS REAL_TYPE_DEFINITION
            WHEN DN_FLOAT_DEF =>
               DECLARE
                  USE UARITH;
               
                  CONSTRAINT:     CONSTANT TREE := D ( 
                                                AS_CONSTRAINT, TYPE_DEF);
                  EXP:            TREE := D ( AS_EXP,
                                                CONSTRAINT);
                  RANGE_NODE:     CONSTANT TREE := D ( 
                                                AS_RANGE, CONSTRAINT);
                  EXP1:           TREE;
                  EXP2:           TREE;
               
                  TYPESET:        TYPESET_TYPE;
                  TYPESET_1:      TYPESET_TYPE;
                  TYPESET_2:      TYPESET_TYPE;
                  ACCURACY:       TREE;
                  LOWER_BOUND:    TREE;
                  UPPER_BOUND:    TREE;
               
                  ANCESTOR_TYPE:  TREE;
                  DERIVED_BASE:   TREE;
               BEGIN
               
                                        -- EVALUATE THE ACCURACY EXPRESSION
                  EVAL_EXP_TYPES(EXP, TYPESET);
                  REQUIRE_INTEGER_TYPE(EXP, TYPESET);
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  EXP := RESOLVE_EXP(EXP, TYPESET);
                  D ( AS_EXP, CONSTRAINT, EXP);
                  ACCURACY := GET_STATIC_VALUE(EXP);
               
                                        -- IF A RANGE IS GIVEN
                  IF RANGE_NODE /= TREE_VOID THEN
                  
                                                -- EVALUATE THE LOWER BOUND EXPRESSION
                     EXP1 := D ( AS_EXP1,
                                                        RANGE_NODE);
                     EVAL_EXP_TYPES(EXP1,
                                                        TYPESET_1);
                     REQUIRE_REAL_TYPE(EXP1,
                                                        TYPESET_1);
                     REQUIRE_UNIQUE_TYPE(EXP1,
                                                        TYPESET_1);
                     EXP1 := RESOLVE_EXP(EXP1,
                                                        TYPESET_1);
                     D ( AS_EXP1, RANGE_NODE,
                                                        EXP1);
                     LOWER_BOUND :=
                                                        GET_STATIC_VALUE(
                                                        EXP1);
                  
                                                -- EVALUATE THE UPPER BOUND EXPRESSION
                     EXP2 := D ( AS_EXP2,
                                                        RANGE_NODE);
                     EVAL_EXP_TYPES(EXP2,
                                                        TYPESET_2);
                     REQUIRE_REAL_TYPE(EXP2,
                                                        TYPESET_2);
                     REQUIRE_UNIQUE_TYPE(EXP2,
                                                        TYPESET_2);
                     EXP2 := RESOLVE_EXP(EXP2,
                                                        TYPESET_2);
                     D ( AS_EXP2, RANGE_NODE,
                                                        EXP2);
                     UPPER_BOUND :=
                                                        GET_STATIC_VALUE(
                                                        EXP2);
                  END IF;
               
                                        -- IF ACCURACY AND BOTH BOUNDS (IF GIVEN) ARE STATIC
                                        -- AND ACCURACY IS POSITIVE
                  IF ACCURACY /= TREE_VOID
                                                        AND THEN (
                                                        RANGE_NODE =
                                                        TREE_VOID
                                                        OR ELSE (
                                                                LOWER_BOUND /=
                                                                TREE_VOID
                                                                AND THEN
                                                                UPPER_BOUND /=
                                                                TREE_VOID))
                                                        AND THEN NOT (
                                                        ACCURACY <= U_VAL(
                                                                0))
                                                        THEN
                  
                                                -- IF RANGE FITS WITHIN FLOAT
                     IF ACCURACY <=
                                                                PREDEFINED_FLOAT_ACCURACY
                                                                AND THEN (
                                                                RANGE_NODE =
                                                                TREE_VOID
                                                                OR ELSE (
                                                                        LOWER_BOUND >=
                                                                        PREDEFINED_FLOAT_FIRST
                                                                        AND THEN
                                                                        UPPER_BOUND
                                                                        <=
                                                                        PREDEFINED_FLOAT_LAST))
                                                                THEN
                     
                                                        -- USE FLOAT
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_FLOAT;
                     
                                                        -- IF RANGE FITS WITHIN LONG_FLOAT
                     ELSIF ACCURACY <=
                                                                PREDEFINED_LONG_FLOAT_ACCURACY
                                                                AND THEN (
                                                                RANGE_NODE =
                                                                TREE_VOID
                                                                OR ELSE (
                                                                        LOWER_BOUND
                                                                        >=
                                                                        PREDEFINED_LONG_FLOAT_FIRST
                                                                        AND THEN
                                                                        UPPER_BOUND
                                                                        <=
                                                                        PREDEFINED_LONG_FLOAT_LAST))
                                                                THEN
                     
                                                        -- USE LONG_FLOAT
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_LONG_FLOAT;
                     
                                                        -- ELSE -- SINCE TOO LARGE FOR IMPLEMENTATION
                     ELSE
                     
                                                        -- REPORT ERROR
                        ERROR( D ( 
                                                                        LX_SRCPOS,
                                                                        CONSTRAINT)
                                                                ,
                                                                "FLOATING TYPE TOO LARGE FOR IMPLEMENTATION" );
                     
                                                        -- ASSUME LARGEST FLOATING TYPE
                        ANCESTOR_TYPE :=
                                                                PREDEFINED_LARGEST_FLOAT;
                     END IF;
                  
                                                -- ELSE -- SINCE ACCURACY OR AT LEAST ONE BOUND IS NOT STATIC
                  ELSE
                  
                                                -- ASSUME LARGEST FLOATING TYPE
                     ANCESTOR_TYPE :=
                                                        PREDEFINED_LARGEST_FLOAT;
                  
                                                -- IF ACCURACY IS NOT STATIC
                                                -- ... AND A TYPE WAS DETERMINED FOR IT
                     IF ACCURACY = TREE_VOID
                                                                AND THEN NOT
                                                                IS_EMPTY ( 
                                                                TYPESET) THEN
                     
                                                        -- INDICATE ERROR
                        ERROR(D ( LX_SRCPOS,
                                                                        EXP),
                                                                "ACCURACY MUST BE STATIC");
                     END IF;
                  
                                                -- IF A RANGE WAS GIVEN
                     IF RANGE_NODE /=
                                                                TREE_VOID THEN
                     
                                                        -- IF LOWER BOUND IS NOT STATIC
                                                        -- ... AND A TYPE WAS DETERMINED FOR IT
                        IF LOWER_BOUND =
                                                                        TREE_VOID
                                                                        AND THEN NOT
                                                                        IS_EMPTY ( 
                                                                        TYPESET_1) THEN
                        
                                                                -- INDICATE ERROR
                           ERROR(D ( 
                                                                                LX_SRCPOS,
                                                                                EXP1),
                                                                        "BOUNDS MUST BE STATIC");
                        END IF;
                     
                                                        -- IF UPPER BOUND IS NOT STATIC
                                                        -- ... AND A TYPE WAS DETERMINED FOR IT
                        IF UPPER_BOUND =
                                                                        TREE_VOID
                                                                        AND THEN NOT
                                                                        IS_EMPTY ( 
                                                                        TYPESET_2) THEN
                        
                                                                -- INDICATE ERROR
                           ERROR(D ( 
                                                                                LX_SRCPOS,
                                                                                EXP2),
                                                                        "BOUNDS MUST BE STATIC");
                        END IF;
                     END IF;
                  END IF;
               
                                        -- CONSTRUCT ANONYMOUS DERIVED FLOATING TYPE
                  DERIVED_BASE := COPY_NODE(
                                                ANCESTOR_TYPE);
                  IF BASE_TYPE = TREE_VOID THEN
                     BASE_TYPE := DERIVED_BASE;
                  END IF;
                  D ( SM_BASE_TYPE, DERIVED_BASE,
                                                BASE_TYPE);
                  D ( XD_SOURCE_NAME, DERIVED_BASE, ID);
                  DB(SM_IS_ANONYMOUS, DERIVED_BASE,
                                                TRUE);
                  D ( SM_DERIVED, DERIVED_BASE,
                                                ANCESTOR_TYPE);
               
                                        -- MAKE RANGE TYPE THE NEW BASE TYPE
                  D ( SM_TYPE_SPEC, CONSTRAINT,
                                                BASE_TYPE);
               
                                        -- CONSTRUCT SUBTYPE OF ANONYMOUS TYPE
                  TYPE_SPEC := COPY_NODE(
                                                DERIVED_BASE);
                  DB(SM_IS_ANONYMOUS, TYPE_SPEC,
                                                FALSE);
                  D ( SM_DERIVED, TYPE_SPEC,
                                                TREE_VOID);
                  D ( SM_ACCURACY, TYPE_SPEC, ACCURACY);
                  D ( SM_TYPE_SPEC, CONSTRAINT,
                                                BASE_TYPE);
                  IF RANGE_NODE /= TREE_VOID THEN
                     D ( SM_RANGE, TYPE_SPEC,
                                                        RANGE_NODE);
                     D ( SM_TYPE_SPEC, RANGE_NODE,
                                                        BASE_TYPE);
                  ELSE
                     D ( SM_RANGE, TYPE_SPEC, D ( 
                                                                SM_RANGE,
                                                                ANCESTOR_TYPE));
                  END IF;
               END;
         
         
                        -- FOR A FIXED_POINT_CONSTRAINT USED AS REAL_TYPE_DEFINITION
            WHEN DN_FIXED_DEF =>
               DECLARE
                  USE UARITH;
               
                  CONSTRAINT:     CONSTANT TREE := D ( 
                                                AS_CONSTRAINT, TYPE_DEF);
                  EXP:            TREE := D ( AS_EXP,
                                                CONSTRAINT);
                  RANGE_NODE:     CONSTANT TREE := D ( 
                                                AS_RANGE, CONSTRAINT);
                  EXP1:           TREE;
                  EXP2:           TREE;
               
                  TYPESET:        TYPESET_TYPE;
                  TYPESET_1:      TYPESET_TYPE;
                  TYPESET_2:      TYPESET_TYPE;
                  ACCURACY:       TREE;
                  LOWER_BOUND:    TREE;
                  UPPER_BOUND:    TREE;
               
                  --ANCESTOR_TYPE:  TREE;
                  DERIVED_BASE:   TREE;
                  POWER_31:       CONSTANT TREE :=
                                                U_VAL(2) ** U_VAL(31);
               BEGIN
               
                                        -- EVALUATE THE ACCURACY EXPRESSION
                  EVAL_EXP_TYPES(EXP, TYPESET);
                  REQUIRE_REAL_TYPE(EXP, TYPESET);
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  EXP := RESOLVE_EXP(EXP, TYPESET);
                  D ( AS_EXP, CONSTRAINT, EXP);
                  ACCURACY := GET_STATIC_VALUE(EXP);
               
                                        -- IF ACCURACY IS NOT STATIC
                  IF ACCURACY = TREE_VOID THEN
                  
                                                -- PUT OUT ERROR MESSAGE
                     ERROR(D ( LX_SRCPOS,EXP),
                                                        "FIXED ACCURACY MUST BE STATIC");
                  
                                                -- ELSE IF ACCURACY IS NOT POSITIVE
                  ELSIF D ( XD_NUMER,ACCURACY) <=
                                                        U_VAL(0) THEN
                  
                                                -- PUT OUT ERROR MESSAGE
                     ERROR(D ( LX_SRCPOS,EXP),
                                                        "FIXED ACCURACY MUST POSITIVE");
                  
                                                -- AND PRETEND IT WAS NOT STATIC (FOR LATER TESTS)
                     ACCURACY := TREE_VOID;
                  END IF;
               
               
                                        -- IF NO RANGE IS GIVEN
                  IF RANGE_NODE = TREE_VOID THEN
                  
                                                -- INDICATE ERROR
                     ERROR(D ( LX_SRCPOS,
                                                                CONSTRAINT),
                                                        "RANGE REQUIRED");
                  
                                                -- AND RETURN VOID TO INDICATE ERROR TO CALLER
                     RETURN TREE_VOID;
                  END IF;
               
                                        -- EVALUATE THE LOWER BOUND EXPRESSION
                  EXP1 := D ( AS_EXP1, RANGE_NODE);
                  EVAL_EXP_TYPES(EXP1, TYPESET_1);
                  REQUIRE_REAL_TYPE(EXP1, TYPESET_1);
                  REQUIRE_UNIQUE_TYPE(EXP1,
                                                TYPESET_1);
                  EXP1 := RESOLVE_EXP(EXP1,
                                                TYPESET_1);
                  D ( AS_EXP1, RANGE_NODE, EXP1);
                  LOWER_BOUND := GET_STATIC_VALUE(
                                                EXP1);
               
                                        -- EVALUATE THE UPPER BOUND EXPRESSION
                  EXP2 := D ( AS_EXP2, RANGE_NODE);
                  EVAL_EXP_TYPES(EXP2, TYPESET_2);
                  REQUIRE_REAL_TYPE(EXP2, TYPESET_2);
                  REQUIRE_UNIQUE_TYPE(EXP2,
                                                TYPESET_2);
                  EXP2 := RESOLVE_EXP(EXP2,
                                                TYPESET_2);
                  D ( AS_EXP2, RANGE_NODE, EXP2);
                  UPPER_BOUND := GET_STATIC_VALUE(
                                                EXP2);
               
                                        -- IF RANGE AND BOUNDS ARE NOT STATIC
                  IF ACCURACY = TREE_VOID
                                                        OR LOWER_BOUND =
                                                        TREE_VOID
                                                        OR UPPER_BOUND =
                                                        TREE_VOID THEN
                  
                                                -- IF LOWER BOUND IS NOT STATIC
                     IF LOWER_BOUND =
                                                                TREE_VOID THEN
                     
                                                        -- PUT OUT ERROR MESSAGE
                        ERROR(D ( LX_SRCPOS,
                                                                        EXP1),
                                                                "LOWER BOUND MUST BE STATIC");
                     
                                                        -- IF UPPER BOUND IS NOT STATIC
                     END IF;
                     IF UPPER_BOUND =
                                                                TREE_VOID THEN
                     
                                                        -- PUT OUT ERROR MESSAGE
                        ERROR(D ( LX_SRCPOS,
                                                                        EXP1),
                                                                "UPPER BOUND MUST BE STATIC");
                     
                                                        -- AND RETURN VOID TO INDICATE ERROR TO CALLER
                     END IF;
                     RETURN TREE_VOID;
                  END IF;
               
               
                                        -- IF BOUNDS FIT WITHIN 32-BIT FIXED TYPE
                  IF UPPER_BOUND <= ACCURACY *
                                                        POWER_31
                                                        AND LOWER_BOUND >= -
                                                        ACCURACY *
                                                        POWER_31 -
                                                        ACCURACY
                                                        THEN
                  
                                                -- USE GIVEN BOUNDS
                     NULL;
                  
                                                -- ELSE -- SINCE BOUNDS DO NOT FIT
                  ELSE
                  
                                                -- PUT OUT ERROR MESSAGE
                     ERROR(D ( LX_SRCPOS,
                                                                CONSTRAINT),
                                                        "FIXED TYPE TOO LARGE");
                  
                                                -- RETURN VOID TO INDICATE ERROR
                     RETURN TREE_VOID;
                  END IF;
               
               
                                        -- CONSTRUCT ANONYMOUS FIXED TYPE
                  DERIVED_BASE := MAKE_FIXED
                                                ( XD_SOURCE_NAME => ID
                                                , SM_IS_ANONYMOUS => TRUE
                                                , SM_RANGE => MAKE_RANGE
                                                ( SM_TYPE_SPEC =>
                                                        BASE_TYPE
                                                        , AS_EXP1 =>
                                                        MAKE_USED_OBJECT_ID
                                                        ( LX_SYMREP =>
                                                                TREE_VOID
                                                                , SM_VALUE => -
                                                                POWER_31 *
                                                                ACCURACY
                                                                ,
                                                                SM_EXP_TYPE =>
                                                                BASE_TYPE )
                                                        , AS_EXP2 =>
                                                        MAKE_USED_OBJECT_ID
                                                        ( LX_SYMREP =>
                                                                TREE_VOID
                                                                , SM_VALUE
                                                                =>
                                                                POWER_31 *
                                                                ACCURACY -
                                                                ACCURACY
                                                                ,
                                                                SM_EXP_TYPE =>
                                                                BASE_TYPE ) )
                                                , CD_IMPL_SIZE => 32
                                                , SM_ACCURACY => ACCURACY
                                                , CD_IMPL_SMALL =>
                                                ACCURACY );
                  IF BASE_TYPE = TREE_VOID THEN
                     BASE_TYPE := DERIVED_BASE;
                  END IF;
                  D ( SM_BASE_TYPE, DERIVED_BASE,
                                                BASE_TYPE);
               
                                        -- CONSTRUCT SUBTYPE OF ANONYMOUS TYPE
                  TYPE_SPEC := COPY_NODE(
                                                DERIVED_BASE);
                  DB(SM_IS_ANONYMOUS, TYPE_SPEC,
                                                FALSE);
                  D ( SM_DERIVED, TYPE_SPEC,
                                                TREE_VOID);
                  D ( SM_RANGE, TYPE_SPEC, RANGE_NODE);
                  D ( SM_ACCURACY, TYPE_SPEC, ACCURACY);
               
                                        -- MAKE RANGE TYPE THE NEW BASE TYPE
                  D ( SM_TYPE_SPEC, CONSTRAINT,
                                                BASE_TYPE);
                  D ( SM_TYPE_SPEC, RANGE_NODE,
                                                BASE_TYPE);
                  D ( SM_TYPE_SPEC, D ( SM_RANGE,
                                                        DERIVED_BASE),
                                                BASE_TYPE);
               END;
         
         
                        -- FOR A CONSTRAINED_ARRAY_DEFINITION
            WHEN DN_CONSTRAINED_ARRAY_DEF =>
               DECLARE
                  SUBTYPE_INDICATION: TREE := D ( 
                                                AS_SUBTYPE_INDICATION,
                                                TYPE_DEF);
                  CONSTRAINT: TREE := D ( 
                                                AS_CONSTRAINT, TYPE_DEF);
               
                  COMP_TYPE: TREE;
               
                  INDEX_EXP_LIST: SEQ_TYPE
                                                := LIST(D ( 
                                                        AS_DISCRETE_RANGE_S,
                                                        CONSTRAINT));
                  INDEX_EXP:      TREE;
                  INDEX_BASE_TYPE: TREE;
                  INDEX_SUBTYPE:  TREE;
                  --INDEX_TYPE_MARK:TREE;
               
                  TYPESET: TYPESET_TYPE;
               
                  DISCRETE_RANGE_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                  INDEX_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                  SCALAR_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
               BEGIN
                  COMP_TYPE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
                  RESOLVE_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION,
                                                COMP_TYPE);
               
                  WHILE NOT IS_EMPTY ( INDEX_EXP_LIST) LOOP
                     POP ( INDEX_EXP_LIST,
                                                        INDEX_EXP);
                     EVAL_NON_UNIVERSAL_DISCRETE_RANGE
                                                        ( INDEX_EXP,
                                                        TYPESET);
                     REQUIRE_UNIQUE_TYPE(
                                                        INDEX_EXP, TYPESET);
                     INDEX_BASE_TYPE :=
                                                        GET_THE_TYPE(
                                                        TYPESET);
                     INDEX_EXP :=
                                                        RESOLVE_DISCRETE_RANGE
                                                        ( INDEX_EXP,
                                                        INDEX_BASE_TYPE );
                     DISCRETE_RANGE_LIST :=
                                                        APPEND
                                                        (
                                                        DISCRETE_RANGE_LIST,
                                                        INDEX_EXP);
                  
                     IF INDEX_BASE_TYPE /=
                                                                TREE_VOID THEN
                        INDEX_SUBTYPE :=
                                                                GET_SUBTYPE_OF_DISCRETE_RANGE(
                                                                INDEX_EXP);
                     ELSE
                        INDEX_SUBTYPE :=
                                                                TREE_VOID;
                     END IF;
                  
                     SCALAR_LIST := APPEND ( 
                                                        SCALAR_LIST,
                                                        INDEX_SUBTYPE);
                     INDEX_LIST := APPEND ( 
                                                        INDEX_LIST,
                                                        MAKE_INDEX
                                                        ( AS_NAME =>
                                                                TREE_VOID
                                                                ,
                                                                SM_TYPE_SPEC =>
                                                                INDEX_SUBTYPE ) );
                  END LOOP;
                  LIST(D ( AS_DISCRETE_RANGE_S,
                                                        CONSTRAINT),
                                                DISCRETE_RANGE_LIST);
               
                  BASE_TYPE := MAKE_ARRAY
                                                ( SM_COMP_TYPE =>
                                                COMP_TYPE
                                                , SM_INDEX_S =>
                                                MAKE_INDEX_S
                                                ( LIST => INDEX_LIST )
                                                , SM_IS_ANONYMOUS => TRUE
                                                , XD_SOURCE_NAME => ID );
                  D ( SM_BASE_TYPE, BASE_TYPE,
                                                BASE_TYPE);
               
                  TYPE_SPEC :=
                                                MAKE_CONSTRAINED_ARRAY
                                                ( SM_INDEX_SUBTYPE_S =>
                                                MAKE_SCALAR_S
                                                ( LIST => SCALAR_LIST )
                                                , SM_BASE_TYPE =>
                                                BASE_TYPE );
               
                                        -- IF THIS DEF WAS PART OF A VARIABLE DECLARATION
                  IF ID.TY = DN_VARIABLE_ID THEN
                  
                                                -- MARK TYPE_SPEC ANONYMOUS
                     DB(SM_IS_ANONYMOUS,
                                                        TYPE_SPEC, TRUE);
                  END IF;
               END;
         
         
                        -- FOR AN UNCONSTRAINED ARRAY DEFINITION
            WHEN DN_UNCONSTRAINED_ARRAY_DEF =>
               DECLARE
                  SUBTYPE_INDICATION: TREE := D ( 
                                                AS_SUBTYPE_INDICATION,
                                                TYPE_DEF);
                  INDEX_S: TREE := D ( AS_INDEX_S,
                                                TYPE_DEF);
               
                  COMP_TYPE: TREE;
                  INDEX_LIST: SEQ_TYPE := LIST(
                                                INDEX_S);
                  INDEX: TREE;
                  TYPE_MARK: TREE;
                  --TYPE_DEFN: TREE;
               
                  ERROR_SEEN: BOOLEAN := FALSE;
               BEGIN
               
                                        -- EVALUATE COMPONENT TYPE
                  COMP_TYPE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
                  RESOLVE_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION,
                                                COMP_TYPE);
               
                                        -- REMEMBER IF IN ERROR
                  IF COMP_TYPE = TREE_VOID THEN
                     ERROR_SEEN := TRUE;
                  END IF;
               
                                        -- FOR EACH INDEX
                  WHILE NOT IS_EMPTY ( INDEX_LIST) LOOP
                     POP ( INDEX_LIST, INDEX);
                  
                                                -- EVALUATE THE TYPE MARK
                     TYPE_MARK := D ( AS_NAME,
                                                        INDEX);
                     TYPE_MARK :=
                                                        WALK_TYPE_MARK(
                                                        TYPE_MARK);
                     D ( AS_NAME, INDEX,
                                                        TYPE_MARK);
                  
                                                -- IF TYPE MARK WAS ACCEPTED
                     IF TYPE_MARK /= TREE_VOID THEN
                     
                                                        --STORE INDEX SUBTYPE IN INDEX NODE
                        D ( SM_TYPE_SPEC
                                                                , INDEX
                                                                , D ( 
                                                                        SM_TYPE_SPEC,
                                                                        GET_NAME_DEFN(
                                                                                TYPE_MARK)));
                                                        --$$$$ ???? CHECK THIS
                     
                                                        -- ELSE -- SINCE TYPE MARK WAS IN ERROR
                     ELSE
                     
                                                        -- REMEMBER THAT THERE WAS AN ERROR
                        ERROR_SEEN := TRUE;
                     END IF;
                  END LOOP;
               
                                        -- IF DEFINITION WAS CORRECT
                  IF NOT ERROR_SEEN THEN
                  
                                                -- MAKE ARRAY NODE
                     TYPE_SPEC := MAKE_ARRAY
                                                        ( SM_COMP_TYPE =>
                                                        COMP_TYPE
                                                        , SM_INDEX_S =>
                                                        INDEX_S );
                  
                                                -- MAKE SURE IT IS ITS OWN BASE TYPE
                     BASE_TYPE := TYPE_SPEC;
                  END IF;
               END;
         
         
                        -- FOR AN ACCESS TYPE DEFINITION
            WHEN DN_ACCESS_DEF =>
               DECLARE
                  SUBTYPE_INDICATION: TREE := D ( 
                                                AS_SUBTYPE_INDICATION,
                                                TYPE_DEF);
               
                  DESIG_TYPE: TREE;
               BEGIN
                                        -- EVALUATE THE DESIGNATED TYPE
                  DESIG_TYPE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
                  RESOLVE_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION,
                                                DESIG_TYPE);
               
                                        -- IF DESIGNATED TYPE DECLARATION WAS CORRECT
                  IF DESIG_TYPE /= TREE_VOID THEN
                  
                                                -- CONSTRUCT AN ACCESS NODE
                     TYPE_SPEC := MAKE_ACCESS
                                                        ( SM_DESIG_TYPE =>
                                                        DESIG_TYPE
                                                        , XD_SOURCE_NAME =>
                                                        ID );
                     BASE_TYPE := TYPE_SPEC;
                     D ( SM_BASE_TYPE, TYPE_SPEC,
                                                        TYPE_SPEC);
                  
                                                -- IF SUBTYPE INDICATION CONTAINS A CONSTRAINT
                                                -- $$$$ WORRY ABOUT CONSTRAINED DESIG TYPE
                  
                     IF SUBTYPE_INDICATION.TY =
                                                                DN_SUBTYPE_INDICATION
                                                                AND THEN D ( 
                                                                AS_CONSTRAINT,
                                                                SUBTYPE_INDICATION) /=
                                                                TREE_VOID
                                                                THEN
                     
                                                        -- CONSTRUCT A CONSTRAINED_ACCESS NODE
                        TYPE_SPEC :=
                                                                MAKE_CONSTRAINED_ACCESS
                                                                (
                                                                SM_DESIG_TYPE =>
                                                                DESIG_TYPE
                                                                ,
                                                                SM_BASE_TYPE =>
                                                                TYPE_SPEC
                                                                ,
                                                                XD_SOURCE_NAME =>
                                                                ID );
                     
                     END IF;
                  END IF;
               END;
         
         
            WHEN DN_DERIVED_DEF =>
               DECLARE
                  SUBTYPE_INDICATION: TREE := D ( 
                                                AS_SUBTYPE_INDICATION,
                                                TYPE_DEF);
               
                  PARENT_SUBTYPE: TREE;
                  PARENT_TYPE: TREE;
               
                  SUBTYPE_SPEC: TREE;
               BEGIN
                                        -- EVALUATE THE PARENT TYPE
                  PARENT_TYPE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
                  PARENT_TYPE := GET_BASE_STRUCT(
                                                PARENT_TYPE);
                  RESOLVE_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION,
                                                PARENT_SUBTYPE);
               
                                        -- CHECK THAT PARENT TYPE IS DERIVABLE AT THIS POINT
                  IF PARENT_TYPE.TY NOT IN
                                                        CLASS_DERIVABLE_SPEC THEN
                     IF PARENT_TYPE.TY = DN_INCOMPLETE
                                                                AND THEN D ( 
                                                                XD_FULL_TYPE_SPEC,
                                                                PARENT_TYPE) /=
                                                                TREE_VOID
                                                                THEN
                        NULL;
                     ELSE
                        ERROR(D ( LX_SRCPOS,
                                                                        SUBTYPE_INDICATION),
                                                                "TYPE IS NOT DERIVABLE HERE");
                        PARENT_TYPE :=
                                                                TREE_VOID;
                     END IF;
                  END IF;
               
                                        -- IF PARENT TYPE DECLARATION WAS NOT CORRECT
                  IF PARENT_TYPE = TREE_VOID THEN
                  
                                                -- RETURN VOID TO INDICATE ERROR
                     RETURN TREE_VOID;
                  END IF;
               
                                        -- MAKE DERIVED TYPE SPEC
                  TYPE_SPEC := COPY_NODE(
                                                GET_BASE_STRUCT(
                                                        PARENT_TYPE));
                  D ( XD_SOURCE_NAME, TYPE_SPEC, ID);
                  IF BASE_TYPE = TREE_VOID THEN
                     BASE_TYPE := TYPE_SPEC;
                  END IF;
                  D ( SM_DERIVED, TYPE_SPEC,
                                                PARENT_TYPE);
               
                                        -- IF TYPE IS AN ENUMERATION TYPE (AND NOT GENERIC (<>))
                  IF TYPE_SPEC.TY =
                                                        DN_ENUMERATION
                                                        AND THEN D ( 
                                                        SM_LITERAL_S,
                                                        TYPE_SPEC) /=
                                                        TREE_VOID THEN
                  
                                                -- COPY THE ENUMERATION LITERALS
                     DECLARE
                        ENUM_LITERAL_LIST:
                                                                SEQ_TYPE
                                                                := LIST(D ( 
                                                                        SM_LITERAL_S,
                                                                        TYPE_SPEC));
                        ENUM_LITERAL: TREE;
                        NEW_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                        TEMP_DEF: TREE;
                     
                        ENUM_HEADER: TREE;
                     BEGIN
                                                        -- MAKE A HEADER FOR THE DEF NODES FOR THE ENUM LITERALS
                        ENUM_HEADER :=
                                                                MAKE_FUNCTION_SPEC
                                                                ( AS_NAME =>
                                                                MAKE_USED_NAME_ID
                                                                (
                                                                        LX_SYMREP =>
                                                                        TREE_VOID
                                                                        ,
                                                                        SM_DEFN =>
                                                                        ID )
                                                                ,
                                                                AS_PARAM_S =>
                                                                MAKE_PARAM_S ( LIST => (TREE_NIL,TREE_NIL)) );
                     
                                                        -- FOR EACH LITERAL
                        WHILE NOT IS_EMPTY ( 
                                                                        ENUM_LITERAL_LIST) LOOP
                           POP ( 
                                                                        ENUM_LITERAL_LIST,
                                                                        ENUM_LITERAL);
                        
                                                                -- MAKE A NEW COPY OF IT
                           ENUM_LITERAL :=
                                                                        COPY_NODE(
                                                                        ENUM_LITERAL);
                           IF D (  LX_SYMREP, ENUM_LITERAL).TY = DN_SYMBOL_REP THEN
                              TEMP_DEF :=
                                                                                MAKE_DEF_FOR_ID(
                                                                                ENUM_LITERAL,
                                                                                H);
                              MAKE_DEF_VISIBLE(
                                                                                TEMP_DEF,
                                                                                ENUM_HEADER);
                           ELSE
                              D ( 
                                                                                XD_REGION,
                                                                                ENUM_LITERAL
                                                                                ,
                                                                                D ( 
                                                                                        XD_SOURCE_NAME,
                                                                                        H.REGION_DEF));
                           END IF;
                           D ( 
                                                                        LX_SRCPOS,
                                                                        ENUM_LITERAL,
                                                                        TREE_VOID);
                           D ( 
                                                                        SM_OBJ_TYPE,
                                                                        ENUM_LITERAL,
                                                                        BASE_TYPE);
                           NEW_LIST :=
                                                                        APPEND ( 
                                                                        NEW_LIST,
                                                                        ENUM_LITERAL);
                        END LOOP;
                     
                        D ( SM_LITERAL_S
                                                                ,
                                                                TYPE_SPEC
                                                                ,
                                                                MAKE_ENUM_LITERAL_S(
                                                                        LIST =>
                                                                        NEW_LIST) );
                     END;
                  
                                                -- ELSE IF TYPE IS A RECORD OR TASK TYPE
                  ELSIF TYPE_SPEC.TY = DN_RECORD
                                                        OR ELSE TYPE_SPEC.TY =
                                                        DN_TASK_SPEC THEN
                  
                     DECLARE
                        H: H_TYPE :=
                                                                EVAL_TYPE_DEF.H;
                        S: S_TYPE;
                        NODE_HASH:
                                                                NODE_HASH_TYPE;
                     
                     BEGIN
                     
                                                        -- ENTER RECORD DECLARATIVE REGION
                        RECORD_REGION_DEF :=
                                                                GET_DEF_FOR_ID(
                                                                ID);
                        ENTER_REGION(
                                                                RECORD_REGION_DEF,
                                                                H, S);
                     
                                                        -- COPY THE RECORD STRUCTURE USING GENERIC SUBSTITUTION
                        SUBSTITUTE_ATTRIBUTES(
                                                                TYPE_SPEC,
                                                                NODE_HASH,
                                                                H);
                     
                                                        -- LEAVE RECORD DECLARATIVE REGION
                        LEAVE_REGION(
                                                                RECORD_REGION_DEF,
                                                                S);
                     END;
                  
                                                -- ELSE IF TYPE IS [LIMITED] PRIVATE
                  ELSIF TYPE_SPEC.TY IN
                                                        CLASS_PRIVATE_SPEC THEN
                  
                     DECLARE
                        H: H_TYPE :=
                                                                EVAL_TYPE_DEF.H;
                        S: S_TYPE;
                     BEGIN
                     
                                                        -- KILL FULL TYPE SPEC (SINCE DERIVED IS PRIVATE)
                        D ( SM_TYPE_SPEC,
                                                                TYPE_SPEC,
                                                                TREE_VOID);
                     
                                                        -- ENTER RECORD DECLARATIVE REGION
                        RECORD_REGION_DEF :=
                                                                GET_DEF_FOR_ID(
                                                                ID);
                        ENTER_REGION(
                                                                RECORD_REGION_DEF,
                                                                H, S);
                     
                                                        -- COPY THE DISCRIMINANT NAMES
                        D ( 
                                                                SM_DISCRIMINANT_S
                                                                ,
                                                                TYPE_SPEC
                                                                ,
                                                                COPY_ITEM_S_IDS
                                                                ( D ( 
                                                                                SM_DISCRIMINANT_S,
                                                                                TYPE_SPEC)
                                                                        ,
                                                                        H ) );
                     
                                                        -- LEAVE RECORD DECLARATIVE REGION
                        LEAVE_REGION(
                                                                RECORD_REGION_DEF,
                                                                S);
                     END;
                  
                                                -- ELSE IF TYPE IS ARRAY
                  ELSIF TYPE_SPEC.TY = DN_ARRAY THEN
                  
                                                -- USE TYPE AS BASE TYPE, EVEN FOR PRIVATE
                     BASE_TYPE := TYPE_SPEC;
                  END IF;
               
               
                                        -- IF PARENT TYPE HAS A CONSTRAINT
                  IF PARENT_SUBTYPE /= PARENT_TYPE THEN
                  
                                                -- MAKE THE NEW BASE TYPE ANONYMOUS
                     DB(SM_IS_ANONYMOUS,
                                                        TYPE_SPEC, TRUE);
                  
                                                -- FIX UP BASE TYPE OF TYPE SPEC
                     IF BASE_TYPE.TY IN
                                                                CLASS_NON_TASK THEN
                        D ( SM_BASE_TYPE,
                                                                TYPE_SPEC,
                                                                BASE_TYPE);
                     END IF;
                  
                                                -- COPY THE PARENT SUBTYPE
                     SUBTYPE_SPEC := COPY_NODE(
                                                        PARENT_SUBTYPE);
                  
                                                -- FIX UP SUBTYPE NODE
                     D ( XD_SOURCE_NAME,
                                                        SUBTYPE_SPEC, ID);
                  
                                                -- REPLACE RESULT WITH SUBTYPE
                     TYPE_SPEC := SUBTYPE_SPEC;
                  END IF;
               
                                        -- ADD BASE TYPE AND SOURCE NAME
                                        -- (DONE AGAIN AFTER THE CASE STATEMENT; NEEDED FOR DERIV SUBP)
                  IF TYPE_SPEC.TY IN
                                                        CLASS_NON_TASK THEN
                     D ( SM_BASE_TYPE, TYPE_SPEC,
                                                        BASE_TYPE);
                  END IF;
                  D ( XD_SOURCE_NAME, TYPE_SPEC, ID);
               
                                        -- CREATE DERIVED SUBPROGRAMS
                  LIST(TYPE_DEF,
                                                DERIVED.MAKE_DERIVED_SUBPROGRAM_LIST
                                                ( GET_BASE_TYPE(TYPE_SPEC)
                                                        , GET_BASE_TYPE(
                                                                PARENT_SUBTYPE)
                                                        , H ) );
               END;
         
         
            WHEN DN_RECORD_DEF =>
               DECLARE
                  COMP_LIST: CONSTANT TREE := D ( 
                                                AS_COMP_LIST, TYPE_DEF);
               
                  H: H_TYPE := EVAL_TYPE_DEF.H;
                  S: S_TYPE;
               BEGIN
                  TYPE_SPEC := MAKE_RECORD
                                                ( XD_SOURCE_NAME => ID
                                                , SM_DISCRIMINANT_S =>
                                                DSCRMT_DECL_S
                                                , SM_COMP_LIST =>
                                                COMP_LIST );
               
                                        -- ENTER RECORD DECLARATIVE REGION
                  RECORD_REGION_DEF :=
                                                GET_DEF_FOR_ID(ID);
                  ENTER_REGION(RECORD_REGION_DEF, H,
                                                S);
               
                                        -- WALK THE COMPONENT LIST
                  WALK_COMP_LIST(COMP_LIST, H);
               
                                        -- LEAVE RECORD DECLARATIVE REGION
                  LEAVE_REGION(RECORD_REGION_DEF, S);
               END;
         
         
            WHEN DN_PRIVATE_DEF =>
               TYPE_SPEC := MAKE_PRIVATE;
               D ( SM_DISCRIMINANT_S, TYPE_SPEC,
                                        DSCRMT_DECL_S);
         
         
            WHEN DN_L_PRIVATE_DEF =>
               TYPE_SPEC := MAKE_L_PRIVATE;
               D ( SM_DISCRIMINANT_S, TYPE_SPEC,
                                        DSCRMT_DECL_S);
         
         
            WHEN DN_FORMAL_DSCRT_DEF =>
               TYPE_SPEC := MAKE_ENUMERATION
                                        ( SM_LITERAL_S =>
                                        MAKE_ENUM_LITERAL_S((TREE_NIL,TREE_NIL)) );
         
            WHEN DN_FORMAL_INTEGER_DEF =>
               TYPE_SPEC := MAKE_INTEGER;
         
         
            WHEN DN_FORMAL_FIXED_DEF =>
               TYPE_SPEC := MAKE_FIXED;
         
         
            WHEN DN_FORMAL_FLOAT_DEF =>
               TYPE_SPEC := MAKE_FLOAT;
         
         END CASE;
      
      
                -- IF TYPE DEFINITION WAS IN ERROR
         IF TYPE_SPEC = TREE_VOID THEN
         
                        -- RETURN VOID TO INDICATE ERROR
            RETURN TREE_VOID;
         END IF;
      
                -- ADD BASE TYPE AND SOURCE NAME
         IF BASE_TYPE = TREE_VOID THEN
            BASE_TYPE := TYPE_SPEC;
         END IF;
         IF TYPE_SPEC.TY IN CLASS_NON_TASK THEN
            D ( SM_BASE_TYPE, TYPE_SPEC, BASE_TYPE);
         END IF;
         D ( XD_SOURCE_NAME, TYPE_SPEC, ID);
      
                -- RETURN THE CONSTRUCTED TYPE_SPEC
         RETURN TYPE_SPEC;
      END EVAL_TYPE_DEF;
   
   
       FUNCTION COPY_COMP_LIST_IDS(COMP_LIST: TREE; H: H_TYPE) RETURN
                        TREE IS
         DECL_S		: TREE	:= D ( AS_DECL_S, COMP_LIST);
         VARIANT_PART	: TREE	:= D ( AS_VARIANT_PART, COMP_LIST);
         NEW_COMP_LIST	: TREE	:= COPY_NODE(COMP_LIST);
         VARIANT_S		: TREE;
         VARIANT_LIST	: SEQ_TYPE;
         VARIANT		: TREE;
         NEW_VARIANT_LIST	: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
      BEGIN
         D ( LX_SRCPOS, NEW_COMP_LIST, TREE_VOID);
      
         DECL_S := COPY_ITEM_S_IDS ( DECL_S, H );
         D ( AS_DECL_S, NEW_COMP_LIST, DECL_S);
      
         IF VARIANT_PART /= TREE_VOID THEN
            VARIANT_PART := COPY_NODE ( VARIANT_PART );
            D ( LX_SRCPOS, VARIANT_PART, TREE_VOID);
            D ( AS_VARIANT_PART, NEW_COMP_LIST, VARIANT_PART);
            VARIANT_S := COPY_NODE(D ( AS_VARIANT_S,
                                        VARIANT_PART));
            D ( LX_SRCPOS, VARIANT_S, TREE_VOID);
            D ( AS_VARIANT_S, VARIANT_PART, VARIANT_S);
            VARIANT_LIST := LIST(VARIANT_S);
            
            WHILE NOT IS_EMPTY ( VARIANT_LIST) LOOP
               POP ( VARIANT_LIST, VARIANT);
               IF VARIANT.TY = DN_VARIANT THEN
                  VARIANT := COPY_NODE ( VARIANT );
                  D ( LX_SRCPOS, VARIANT, TREE_VOID);
                  D ( AS_COMP_LIST, VARIANT, COPY_COMP_LIST_IDS(D ( AS_COMP_LIST, VARIANT), H) );
                  NEW_VARIANT_LIST := APPEND ( NEW_VARIANT_LIST, VARIANT);
               END IF;
            END LOOP;
            LIST(VARIANT_S, NEW_VARIANT_LIST);
         END IF;
      
         D ( AS_PRAGMA_S, NEW_COMP_LIST, TREE_VOID);
      
         RETURN NEW_COMP_LIST;
      END COPY_COMP_LIST_IDS;
   
   
       FUNCTION COPY_ITEM_S_IDS(ITEM_S: TREE; H: H_TYPE) RETURN TREE IS
         NEW_ITEM_S: TREE;
         ITEM_LIST: SEQ_TYPE;
         ITEM: TREE;
         NEW_ITEM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      
         SOURCE_NAME_S: TREE;
         ID_LIST: SEQ_TYPE;
         ID: TREE;
         ID_DEF: TREE;
         NEW_ID_LIST: SEQ_TYPE;
      BEGIN
         IF ITEM_S = TREE_VOID THEN
            RETURN TREE_VOID;
         END IF;
      
         NEW_ITEM_S := COPY_NODE(ITEM_S);
         ITEM_LIST := LIST(NEW_ITEM_S);
      
         D ( LX_SRCPOS, NEW_ITEM_S, TREE_VOID);
         WHILE NOT IS_EMPTY ( ITEM_LIST) LOOP
            POP ( ITEM_LIST, ITEM);
            IF ITEM.TY IN CLASS_DSCRMT_PARAM_DECL'FIRST
                                        .. CLASS_ID_S_DECL'LAST
                                        THEN
               ITEM := COPY_NODE(ITEM);
               D ( LX_SRCPOS, ITEM, TREE_VOID);
               NEW_ITEM_LIST := APPEND ( NEW_ITEM_LIST,
                                        ITEM);
            
               SOURCE_NAME_S := COPY_NODE(D ( 
                                                AS_SOURCE_NAME_S, ITEM));
               D ( LX_SRCPOS, SOURCE_NAME_S, TREE_VOID);
               D ( AS_SOURCE_NAME_S, ITEM, SOURCE_NAME_S);
            
               ID_LIST := LIST(SOURCE_NAME_S);
               NEW_ID_LIST := (TREE_NIL,TREE_NIL);
               WHILE NOT IS_EMPTY ( ID_LIST) LOOP
                  POP ( ID_LIST, ID);
                  ID := COPY_NODE(ID);
                  D ( LX_SRCPOS, ID, TREE_VOID);
                  IF D ( LX_SYMREP,ID).TY =
                                                        DN_SYMBOL_REP THEN
                     ID_DEF := MAKE_DEF_FOR_ID(
                                                        ID, H);
                     MAKE_DEF_VISIBLE(ID_DEF);
                  ELSE
                     D ( XD_REGION, ID,
                                                        H.REGION_DEF);
                  END IF;
                  NEW_ID_LIST := APPEND ( NEW_ID_LIST,
                                                ID);
               END LOOP;
               LIST(SOURCE_NAME_S, NEW_ID_LIST);
            
            ELSIF ITEM.TY = DN_NULL_COMP_DECL THEN
               NEW_ITEM_LIST := APPEND ( NEW_ITEM_LIST,
                                        ITEM);
            END IF;
         
         END LOOP;
         LIST(NEW_ITEM_S, NEW_ITEM_LIST);
         RETURN NEW_ITEM_S;
      END COPY_ITEM_S_IDS;
   
   
       FUNCTION GET_SUBTYPE_OF_DISCRETE_RANGE(DISCRETE_RANGE: TREE) RETURN
                        TREE IS
         RESULT: TREE;
      BEGIN
         CASE DISCRETE_RANGE.TY IS
            WHEN DN_RANGE =>
               RESULT := COPY_NODE
                                        ( GET_BASE_STRUCT(D ( SM_TYPE_SPEC,
                                                        DISCRETE_RANGE)) );
               IF RESULT.TY IN DN_ENUMERATION ..
                                                DN_INTEGER THEN
                  D ( SM_RANGE, RESULT, DISCRETE_RANGE);
                  D ( SM_DERIVED, RESULT, TREE_VOID);
                  DB(SM_IS_ANONYMOUS, RESULT, TRUE);
               ELSE
                  RESULT := TREE_VOID;
               END IF;
               RETURN RESULT;
            WHEN DN_RANGE_ATTRIBUTE =>
               DECLARE
                  PREFIX: TREE := D ( AS_NAME,
                                                DISCRETE_RANGE);
                  PREFIX_SUBTYPE: TREE;
                  WHICH_SUBSCRIPT: INTEGER := 1;
                  INDEX_LIST: SEQ_TYPE;
                  INDEX: TREE;
               BEGIN
                  IF D ( AS_EXP, DISCRETE_RANGE) /=
                                                        TREE_VOID THEN
                     IF GET_STATIC_VALUE(D ( 
                                                                        AS_EXP,
                                                                        DISCRETE_RANGE)) /=
                                                                TREE_VOID
                                                                THEN
                        WHICH_SUBSCRIPT
                                                                := DI(
                                                                SM_VALUE,
                                                                D ( AS_EXP,
                                                                        DISCRETE_RANGE));
                     ELSE
                        WHICH_SUBSCRIPT := -
                                                                1;
                     END IF;
                  END IF;
                  IF PREFIX.TY = DN_SELECTED THEN
                     PREFIX := D ( AS_DESIGNATOR,
                                                        PREFIX);
                  END IF;
                  IF PREFIX.TY = DN_USED_NAME_ID THEN
                                                -- IT'S A TYPE MARK
                     PREFIX_SUBTYPE := D ( 
                                                        SM_TYPE_SPEC,D ( 
                                                                SM_DEFN,
                                                                PREFIX));
                  ELSE
                     PREFIX_SUBTYPE := D ( 
                                                        SM_EXP_TYPE,
                                                        PREFIX);
                     IF GET_BASE_STRUCT(
                                                                        PREFIX_SUBTYPE).TY =
                                                                DN_ACCESS THEN
                        PREFIX_SUBTYPE :=
                                                                D ( 
                                                                SM_DESIG_TYPE
                                                                ,
                                                                GET_SUBSTRUCT(
                                                                        PREFIX_SUBTYPE) );
                     END IF;
                  END IF;
                  PREFIX_SUBTYPE := GET_SUBSTRUCT(
                                                PREFIX_SUBTYPE);
                  IF PREFIX_SUBTYPE.TY =
                                                        DN_CONSTRAINED_ARRAY THEN
                     INDEX_LIST := LIST(D ( 
                                                                SM_INDEX_SUBTYPE_S,
                                                                PREFIX_SUBTYPE));
                  ELSIF PREFIX_SUBTYPE.TY =
                                                        DN_ARRAY THEN
                     INDEX_LIST := LIST(D ( 
                                                                SM_INDEX_S,
                                                                PREFIX_SUBTYPE));
                  ELSE
                     INDEX_LIST := (TREE_NIL,TREE_NIL);
                  END IF;
                  LOOP
                     IF IS_EMPTY ( INDEX_LIST) THEN
                                                        -- (ERROR ALREADY REPORTED)
                        RETURN TREE_VOID;
                     END IF;
                     POP ( INDEX_LIST, INDEX);
                     WHICH_SUBSCRIPT :=
                                                        WHICH_SUBSCRIPT -
                                                        1;
                     EXIT
                                                        WHEN
                                                        WHICH_SUBSCRIPT =
                                                        0;
                  END LOOP;
                  IF INDEX.TY = DN_INDEX THEN
                     RETURN D ( SM_TYPE_SPEC,
                                                        INDEX);
                  ELSE
                     RETURN INDEX;
                  END IF;
               END;
            WHEN DN_DISCRETE_SUBTYPE =>
               DECLARE
                  SUBTYPE_INDICATION: CONSTANT TREE
                                                := D ( 
                                                AS_SUBTYPE_INDICATION,
                                                DISCRETE_RANGE);
                  CONSTRAINT: CONSTANT TREE
                                                := D ( AS_CONSTRAINT,
                                                SUBTYPE_INDICATION);
                  NAME_DEFN: TREE;
               BEGIN
                  IF CONSTRAINT.TY = DN_RANGE THEN
                     RETURN
                                                        GET_SUBTYPE_OF_DISCRETE_RANGE(
                                                        CONSTRAINT);
                  ELSE
                     NAME_DEFN := GET_NAME_DEFN(
                                                        D ( AS_NAME,
                                                                SUBTYPE_INDICATION));
                     IF NAME_DEFN /= TREE_VOID THEN
                        RETURN D ( 
                                                                SM_TYPE_SPEC,
                                                                NAME_DEFN);
                     ELSE
                        RETURN TREE_VOID;
                     END IF;
                  END IF;
               END;
            WHEN OTHERS =>
               PUT_LINE ( "!!INVALID DISCRETE RANGE" );
               RAISE PROGRAM_ERROR;
         END CASE;
      END GET_SUBTYPE_OF_DISCRETE_RANGE;
   
   
       PROCEDURE WALK_COMP_LIST (COMP_LIST: TREE; H: H_TYPE) IS
                -- WALK THE COMPONENT LIST (FIXED PART + VARIANT PART + PRAGMAS)
                -- ... IN A RECORD DECLARATION OR [RECURSIVELY] IN A VARIANT PART
                -- ... (CALLED FROM EVAL_TYPE_DEF FOR RECORD DECLARATION)
      
         DECL_S:         CONSTANT TREE := D ( AS_DECL_S, COMP_LIST);
         VARIANT_PART:   CONSTANT TREE := D ( AS_VARIANT_PART,
                        COMP_LIST);
         PRAGMA_S:       CONSTANT TREE := D ( AS_PRAGMA_S, COMP_LIST);
      
      BEGIN
      
                -- WALK THE FIXED PART
         WALK_ITEM_S(DECL_S, H);
      
                -- IF THERE IS A VARIANT PART
         IF VARIANT_PART /= TREE_VOID THEN
         
            DECLARE
               NAME:           TREE := D ( AS_NAME,
                                        VARIANT_PART);
               VARIANT_S:      CONSTANT TREE := D ( 
                                        AS_VARIANT_S, VARIANT_PART);
            
               NAME_TYPE:      TREE;
               VARIANT_LIST:   SEQ_TYPE := LIST(
                                        VARIANT_S);
               VARIANT: TREE;
            BEGIN
                                -- $$$$ NEED TO ALLOW DISCRIMINANT NAMES AT APPROPRIATE POINTS
            
                                -- EVALUATE THE DISCRIMINANT NAME
                                -- ... (SYNTAX REQUIRES SIMPLE NAME)
               NAME := WALK_NAME(DN_DISCRIMINANT_ID, NAME);
               NAME_TYPE := GET_BASE_TYPE(NAME);
            
                                -- FOR EACH VARIANT OR PRAGMA
               WHILE NOT IS_EMPTY ( VARIANT_LIST) LOOP
                  POP ( VARIANT_LIST, VARIANT);
               
                                        -- IF IT IS A VARIANT
                  IF VARIANT.TY = DN_VARIANT THEN
                  
                                                -- WALK THE CHOICE LIST
                     WALK_DISCRETE_CHOICE_S
                                                        ( D ( AS_CHOICE_S,
                                                                VARIANT)
                                                        , NAME_TYPE );
                  
                                                -- WALK THE VARIANT COMPONENT LIST
                     WALK_COMP_LIST(D ( 
                                                                AS_COMP_LIST,
                                                                VARIANT),
                                                        H);
                  
                                                -- ELSE -- SINCE IT MUST BE A VARIANT_PRAGMA
                  ELSE
                  
                                                -- WALK THE PRAGMA
                     WALK(D ( AS_PRAGMA,VARIANT),
                                                        H);
                  END IF;
               END LOOP;
            END;
         END IF;
      
                -- WALK THE PRAGMA PART
         WALK_ITEM_S(PRAGMA_S, H);
      END WALK_COMP_LIST;
   
   --|----------------------------------------------------------------------------------------------
   END DEF_WALK;
