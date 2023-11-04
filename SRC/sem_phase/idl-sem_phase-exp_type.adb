    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	EXP_TYPE
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY EXP_TYPE IS
      USE DEF_UTIL, VIS_UTIL;
      USE RED_SUBP;
      USE REQ_UTIL;
      USE ATT_WALK;
   
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE REDUCE_EXP_TYPES
                        ( DEFSET:		DEFSET_TYPE
                        ; TYPESET:		OUT TYPESET_TYPE )
                        IS
                -- FIND EXPRESSION TYPES OF NAMES IN DEFSET
      
         TEMP_DEFSET:		DEFSET_TYPE := DEFSET;
         DEFINTERP:		DEFINTERP_TYPE;
      
         NEW_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
         TYPE_SPEC:		TREE;
      BEGIN
                -- FOR EACH GIVEN DEF
         WHILE NOT IS_EMPTY(TEMP_DEFSET) LOOP
            POP(TEMP_DEFSET, DEFINTERP);
         
                        -- GET ITS TYPE (WHEN CONSIDERED AS AN EXPRESSION)
                        -- (I.E., IF FUNCTION NAME, THEN WITH ALL DEFAULT PARAMETERS)
            TYPE_SPEC := GET_DEF_EXP_TYPE(GET_DEF(DEFINTERP));
         
                        -- SAVE TYPE AND IMPLICIT CONVERSION INFORMATION IN TYPESET
            IF TYPE_SPEC /= TREE_VOID THEN
               ADD_TO_TYPESET(NEW_TYPESET, TYPE_SPEC,
                                        GET_EXTRAINFO(DEFINTERP));
            END IF;
         END LOOP;
      
                -- RETURN THE NEW TYPESET
         TYPESET := NEW_TYPESET;
      END REDUCE_EXP_TYPES;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE REDUCE_DESIGNATED_TYPES
                        ( PREFIX_TYPESET:	IN OUT TYPESET_TYPE
                        ; TYPESET:		OUT TYPESET_TYPE )
                        IS
         TEMP_PREFIXSET: TYPESET_TYPE := PREFIX_TYPESET;
         PREFIX_INTERP:	TYPEINTERP_TYPE;
         PREFIX_TYPE:	TREE;
         PREFIX_STRUCT:	TREE;
         DESIG_TYPE:	TREE;
      
         NEW_PREFIXSET:	TYPESET_TYPE := EMPTY_TYPESET;
         NEW_TYPESET:	TYPESET_TYPE := EMPTY_TYPESET;
      BEGIN
         WHILE NOT IS_EMPTY(TEMP_PREFIXSET) LOOP
            POP(TEMP_PREFIXSET, PREFIX_INTERP);
            PREFIX_TYPE := GET_TYPE(PREFIX_INTERP);
            PREFIX_STRUCT := GET_BASE_STRUCT(PREFIX_TYPE);
         
            IF PREFIX_STRUCT.TY = DN_ACCESS THEN
               DESIG_TYPE := GET_BASE_TYPE(D(
                                                SM_DESIG_TYPE,
                                                PREFIX_STRUCT));
               ADD_TO_TYPESET(NEW_PREFIXSET,
                                        PREFIX_INTERP);
               ADD_TO_TYPESET ( NEW_TYPESET, DESIG_TYPE
                                        , GET_EXTRAINFO(PREFIX_INTERP) );
            END IF;
         END LOOP;
      
         PREFIX_TYPESET := NEW_PREFIXSET;
         TYPESET := NEW_TYPESET;
      END REDUCE_DESIGNATED_TYPES;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_EXP_TYPES
                        ( EXP:			    TREE
                        ; TYPESET:		    OUT TYPESET_TYPE )
                        IS
         IS_SUBTYPE:			BOOLEAN;
      BEGIN
         EVAL_EXP_SUBTYPE_TYPES
                        ( EXP
                        , TYPESET
                        , IS_SUBTYPE );
         IF IS_SUBTYPE THEN
            ERROR(D(LX_SRCPOS,EXP),
                                "EXPRESSION (NOT SUBTYPE) REQUIRED");
            TYPESET := EMPTY_TYPESET;
         END IF;
      END EVAL_EXP_TYPES;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_EXP_SUBTYPE_TYPES
                        ( EXP:			    TREE
                        ; TYPESET:		    OUT TYPESET_TYPE
                        ; IS_SUBTYPE_OUT:	    OUT BOOLEAN)
                        IS
                -- CHECKS THAT EXP REPRESENTS AN EXPRESSION, SUBTYPE OR VOID
                -- ON RETURN, TYPESET IS SET OF POSSIBLE BASE TYPES,
                -- ... WITH IMPLICIT CONVERSION INFORMATION
                -- IF EXP REPRESENTS A SUBTYPE OR SUBTYPES, IS_SUBTYPE_OUT IS
                -- ... SET TO TRUE; THEN TYPESET IS THE SET OF POSSIBLE BASE
                -- ... (THERE MAY BE MORE THAN ONE, SINCE THE SUBTYPE MAY BE
                -- ... OF THE FORM SIMPLE_EXPRESSION .. SIMPLE_EXPRESSION.)
      
         NEW_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
      BEGIN
                -- ASSUME IT IS NOT A RANGE
         IS_SUBTYPE_OUT := FALSE;
      
                -- IF VOID, RETURN WITH EMPTY TYPESET
         IF EXP = TREE_VOID THEN
            TYPESET := EMPTY_TYPESET;
            RETURN;
         END IF;
      
      
         IF EXP.TY = DN_RANGE THEN
            DECLARE
               EXP1: CONSTANT TREE := D(AS_EXP1, EXP);
               EXP2: CONSTANT TREE := D(AS_EXP2, EXP);
               TYPESET_1: TYPESET_TYPE;
               TYPESET_2: TYPESET_TYPE;
            BEGIN
               EVAL_EXP_TYPES(EXP1, TYPESET_1);
               EVAL_EXP_TYPES(EXP2, TYPESET_2);
               REQUIRE_SAME_TYPES
                                        ( EXP1, TYPESET_1
                                        , EXP2, TYPESET_2
                                        , NEW_TYPESET );
            END;
         
            IS_SUBTYPE_OUT := TRUE;
            TYPESET := NEW_TYPESET;
            RETURN;
         END IF;
      
         IF EXP.TY = DN_SUBTYPE_INDICATION THEN
            DECLARE
               TYPE_SPEC: TREE := EVAL_SUBTYPE_INDICATION(
                                        EXP);
            BEGIN
               IF TYPE_SPEC /= TREE_VOID THEN
                  ADD_TO_TYPESET(NEW_TYPESET,
                                                TYPE_SPEC);
               END IF;
               TYPESET := NEW_TYPESET;
            END;
         
            IS_SUBTYPE_OUT := TRUE;
            RETURN;
         END IF;
      
                -- CHECK FOR NAMED, ASSOC (E.G. IN INDEX CONSTRAINT)
         IF EXP.TY NOT IN CLASS_EXP THEN
            ERROR(D(LX_SRCPOS, EXP), "EXPRESSION REQUIRED");
            TYPESET := EMPTY_TYPESET;
            RETURN;
         END IF;
      
      
                -- EXP IS SYNTACTICALLY AN EXPRESSION
         CASE CLASS_EXP'(EXP.TY) IS
         
                        -- WHEN CLASS_USED_OBJECT => -- SEE SELECTED
         
            WHEN DN_USED_OP | DN_USED_NAME_ID =>
               PUT_LINE ( "!! IMPOSSIBLE ARGUMENT FOR EVAL_EXP_TYPES" );
               RAISE PROGRAM_ERROR;
         
         
            WHEN DN_ATTRIBUTE =>
               EVAL_ATTRIBUTE(EXP, TYPESET,
                                                IS_SUBTYPE_OUT);
               RETURN;
         
            WHEN CLASS_USED_OBJECT | DN_SELECTED =>
               DECLARE
                  DEFSET: 		DEFSET_TYPE;
                  SOURCE_NAME:		TREE;
               BEGIN
                  FIND_VISIBILITY(EXP, DEFSET);
                  IF NOT IS_EMPTY(DEFSET) THEN
                     SOURCE_NAME := GET_THE_ID(
                                                        DEFSET);
                     IF SOURCE_NAME.TY IN CLASS_TYPE_NAME
                     AND THEN NOT ( GET_BASE_STRUCT( SOURCE_NAME).TY = DN_TASK_SPEC
                     AND THEN DI( XD_LEX_LEVEL, GET_DEF_FOR_ID ( D( XD_SOURCE_NAME, GET_BASE_STRUCT( SOURCE_NAME)))) > 0 )
                                                                THEN
                        ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( SOURCE_NAME));
                        IS_SUBTYPE_OUT := TRUE;
                     ELSE
                        REDUCE_EXP_TYPES( DEFSET, NEW_TYPESET);
                        IF NOT IS_EMPTY( NEW_TYPESET) THEN
                           IF GET_THE_TYPE( NEW_TYPESET).TY = DN_UNIVERSAL_INTEGER THEN
                              NEW_TYPESET := EMPTY_TYPESET;
                              ADD_TO_TYPESET ( NEW_TYPESET, MAKE(DN_ANY_INTEGER));
                           ELSIF GET_THE_TYPE( NEW_TYPESET).TY = DN_UNIVERSAL_REAL THEN
                              NEW_TYPESET := EMPTY_TYPESET;
                              ADD_TO_TYPESET (
                                                                                NEW_TYPESET
                                                                                ,
                                                                                MAKE(
                                                                                        DN_ANY_REAL));
                           END IF;
                        END IF;
                     END IF;
                     STASH_DEFSET(EXP, DEFSET);
                  END IF;
               END;
         
         
            WHEN DN_FUNCTION_CALL =>
               DECLARE
                  NAME: TREE := D(AS_NAME, EXP);
                  GENERAL_ASSOC_S: TREE := D ( AS_GENERAL_ASSOC_S, EXP );
               
               BEGIN
                  CASE CLASS_EXP'(NAME.TY) IS
                     WHEN DN_ATTRIBUTE =>
                        EVAL_ATTRIBUTE(
                                                                EXP,
                                                                TYPESET,
                                                                IS_SUBTYPE_OUT);
                        RETURN;
                  
                     WHEN DN_USED_OBJECT_ID |
                                                                DN_SELECTED |
                                                                DN_USED_OP =>
                        EVAL_SUBP_CALL
                                                                ( EXP
                                                                ,
                                                                NEW_TYPESET );
                  
                     WHEN DN_STRING_LITERAL =>
                        NAME :=
                                                                MAKE_USED_OP_FROM_STRING(
                                                                NAME);
                        D(AS_NAME, EXP,
                                                                NAME);
                        EVAL_SUBP_CALL
                                                                ( EXP
                                                                ,
                                                                NEW_TYPESET );
                  
                     WHEN OTHERS =>
                        EVAL_SUBP_CALL
                                                                ( EXP
                                                                ,
                                                                NEW_TYPESET );
                  END CASE;
               END;
         
         
            WHEN DN_INDEXED | DN_SLICE =>
               PUT_LINE ( "IMPOSSIBLE ARGUMENT FOR EVAL_EXP_TYPES" );
               RAISE PROGRAM_ERROR;
         
         
            WHEN DN_ALL =>
               DECLARE
                  NAME: CONSTANT TREE := D(AS_NAME,
                                                EXP);
                  PREFIX_TYPESET: TYPESET_TYPE;
               BEGIN
                                        -- GET POSSIBLE TYPES OF PREFIX
                  EVAL_EXP_TYPES(NAME,
                                                PREFIX_TYPESET);
               
                                        -- IF THERE WERE ANY
                  IF NOT IS_EMPTY(PREFIX_TYPESET) THEN
                  
                                                -- FIND THE RESULT TYPES AND REVISE PREFIX TYPE LISTS
                     REDUCE_DESIGNATED_TYPES(
                                                        PREFIX_TYPESET,
                                                        NEW_TYPESET);
                  
                                                -- CHECK THAT THERE WERE SOME
                     IF IS_EMPTY(NEW_TYPESET) THEN
                        ERROR(D(LX_SRCPOS,
                                                                        EXP),
                                                                "PREFIX OF .ALL NOT ACCESS");
                     END IF;
                  END IF;
               
                                        -- SAVE LIST OF POSSIBLE PREFIX TYPES
                  STASH_TYPESET( NAME,
                                                PREFIX_TYPESET);
               END;
         
         
            WHEN DN_SHORT_CIRCUIT =>
               DECLARE
                  EXP1: CONSTANT TREE := D(AS_EXP1,
                                                EXP);
                  EXP2: CONSTANT TREE := D(AS_EXP2,
                                                EXP);
                  TYPESET_1: TYPESET_TYPE;
                  TYPESET_2: TYPESET_TYPE;
               BEGIN
               
                                        -- EVALUATE THE TWO EXPRESSIONS
                  EVAL_EXP_TYPES(EXP1, TYPESET_1);
                  EVAL_EXP_TYPES(EXP2, TYPESET_2);
               
                                        -- THEY MUST BE OF THE SAME BOOLEAN TYPE
                  REQUIRE_BOOLEAN_TYPE(EXP1,
                                                TYPESET_1);
                  REQUIRE_BOOLEAN_TYPE(EXP2,
                                                TYPESET_2);
                  REQUIRE_SAME_TYPES
                                                (EXP1, TYPESET_1, EXP2,
                                                TYPESET_2, NEW_TYPESET);
               END;
         
         
            WHEN DN_NUMERIC_LITERAL =>
               DECLARE
                  VALUE: TREE := UARITH.U_VALUE(
                                                PRINT_NAME ( D(LX_NUMREP, EXP)));
               BEGIN
                                        -- ALWAYS A STATIC VALUE
                                        -- SAVE THE VALUE IN SM_VALUE ATTRIBUTE
                  D(SM_VALUE, EXP, VALUE);
               
                                        -- AND CONSTRUCT TYPE ACCORDING AS THERE WAS A DECIMAL POINT
                  IF VALUE.TY = DN_REAL_VAL THEN
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET, MAKE(
                                                                DN_ANY_REAL));
                  ELSE
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET, MAKE(
                                                                DN_ANY_INTEGER));
                  END IF;
               END;
         
         
            WHEN DN_NULL_ACCESS =>
               ADD_TO_TYPESET(NEW_TYPESET, MAKE(
                                                DN_ANY_ACCESS));
         
         
            WHEN CLASS_MEMBERSHIP =>
                                -- RESULT TYPE IS ALWAYS BOOLEAN
                                -- OPERANDS WILL BE LOOKED AT DURING RESOLVE PASS
               ADD_TO_TYPESET(NEW_TYPESET,
                                        PREDEFINED_BOOLEAN);
               D(SM_EXP_TYPE, EXP, PREDEFINED_BOOLEAN);
         
         
            WHEN DN_CONVERSION =>
               PUT_LINE ( "!! IMPOSSIBLE ARGUMENT FOR EVAL_EXP_TYPES" );
               RAISE PROGRAM_ERROR;
         
            WHEN DN_QUALIFIED =>
               DECLARE
                  NAME: CONSTANT TREE := D(AS_NAME,
                                                EXP);
                  TYPE_SPEC: TREE := EVAL_TYPE_MARK(
                                                NAME);
               BEGIN
                                        -- TYPE IS GIVEN BY THE TYPE MARK
                                        -- OPERAND WILL BE LOOKED AT DURING RESOLVE PASS
                  IF TYPE_SPEC /= TREE_VOID THEN
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET,
                                                        TYPE_SPEC);
                  END IF;
               END;
         
         
            WHEN DN_PARENTHESIZED =>
               DECLARE
                  SUBEXP: CONSTANT TREE := D(AS_EXP,
                                                EXP);
               BEGIN
                                        -- EVALUARE THE EXPRESSION AND PASS IT ON
                  EVAL_EXP_TYPES
                                                ( SUBEXP
                                                , NEW_TYPESET);
               END;
         
         
            WHEN DN_AGGREGATE =>
               ADD_TO_TYPESET(NEW_TYPESET, MAKE(
                                                DN_ANY_COMPOSITE));
         
         
            WHEN DN_STRING_LITERAL =>
               ADD_TO_TYPESET(NEW_TYPESET, MAKE(
                                                DN_ANY_STRING));
         
         
            WHEN DN_QUALIFIED_ALLOCATOR =>
               DECLARE
                  QUALIFIED: CONSTANT TREE := D(
                                                AS_QUALIFIED, EXP);
                  TEMP_TYPESET: TYPESET_TYPE;
                  ANY_ACCESS_OF: TREE := MAKE(
                                                DN_ANY_ACCESS_OF);
               BEGIN
                  EVAL_EXP_TYPES(QUALIFIED,
                                                TEMP_TYPESET);
                  IF NOT IS_EMPTY(TEMP_TYPESET) THEN
                     D(XD_ITEM, ANY_ACCESS_OF,
                                                        GET_THE_TYPE(
                                                                TEMP_TYPESET));
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET,
                                                        ANY_ACCESS_OF);
                  END IF;
               END;
         
            WHEN  DN_SUBTYPE_ALLOCATOR =>
               DECLARE
                  SUBTYPE_INDICATION: CONSTANT TREE
                                                := D(
                                                AS_SUBTYPE_INDICATION, EXP);
                  TYPE_SPEC: TREE :=
                                                EVAL_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION);
                  ANY_ACCESS_OF: TREE := MAKE(
                                                DN_ANY_ACCESS_OF);
               BEGIN
                                        -- TYPE IS GIVEN BY THE SUBTYPE INDICATION
                  IF TYPE_SPEC /= TREE_VOID THEN
                     D(XD_ITEM, ANY_ACCESS_OF,
                                                        TYPE_SPEC);
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET,
                                                        ANY_ACCESS_OF);
                  END IF;
               END;
         
         END CASE;
      
         TYPESET := NEW_TYPESET;
      END EVAL_EXP_SUBTYPE_TYPES;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION EVAL_TYPE_MARK(EXP: TREE) RETURN TREE IS
                -- EXP MUST BE A TYPE MARK (BY THE SYNTAX)
                -- WE DETERMINE VISIBILITY AND CHECK THAT IT IS ONE
      
         DEFSET: 		DEFSET_TYPE := EMPTY_DEFSET;
         TYPE_ID:		TREE := TREE_VOID;
      BEGIN
         IF EXP.TY = DN_SUBTYPE_INDICATION THEN
            IF D(AS_CONSTRAINT, EXP) /= TREE_VOID THEN
               ERROR(D(LX_SRCPOS,EXP),
                                        "TYPE MARK REQUIRED");
            END IF;
            RETURN EVAL_TYPE_MARK(D(AS_NAME, EXP));
         END IF;
      
         IF EXP.TY = DN_USED_OBJECT_ID THEN
            FIND_DIRECT_VISIBILITY(EXP, DEFSET);
         ELSIF EXP.TY = DN_SELECTED
                                AND THEN D(AS_DESIGNATOR,EXP).TY =
                                DN_USED_OBJECT_ID THEN
            FIND_SELECTED_VISIBILITY(EXP, DEFSET);
         ELSE
            ERROR(D(LX_SRCPOS,EXP), "TYPE MARK REQUIRED");
            RETURN TREE_VOID;
         END IF;
      
         TYPE_ID := GET_THE_ID(DEFSET);
         IF TYPE_ID.TY IN CLASS_TYPE_NAME THEN
            NULL;
         ELSIF TYPE_ID /= TREE_VOID THEN
            ERROR(D(LX_SRCPOS,EXP), "NOT A TYPE NAME - "
                                & PRINT_NAME ( D(LX_SYMREP,TYPE_ID)) );
            TYPE_ID := TREE_VOID;
         END IF;
      
         IF EXP.TY = DN_USED_OBJECT_ID THEN
            D(SM_DEFN, EXP, TYPE_ID);
         ELSE -- SINCE EXP) = DN_SELECTED
            D(SM_DEFN, D(AS_DESIGNATOR,EXP), TYPE_ID);
         END IF;
      
         RETURN GET_BASE_TYPE(TYPE_ID);
      END EVAL_TYPE_MARK;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION EVAL_SUBTYPE_INDICATION(EXP: TREE) RETURN TREE IS
         BASE_TYPE: TREE;
      BEGIN
         IF EXP.TY = DN_SUBTYPE_INDICATION THEN
            BASE_TYPE := EVAL_TYPE_MARK(D(AS_NAME, EXP));
                        -- NOTE CONSTRAINT EVALUATED IN RESOLVE PASS
            RETURN BASE_TYPE;
         
         ELSIF EXP.TY = DN_USED_OBJECT_ID
                                OR ELSE EXP.TY = DN_SELECTED THEN
            RETURN EVAL_TYPE_MARK(EXP);
         
         ELSE
            PUT_LINE ( "!! $$$$ NODE SHOULD BE SUBTYPE INDICATION");
            RAISE PROGRAM_ERROR;
         END IF;
      END EVAL_SUBTYPE_INDICATION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_RANGE
                        ( EXP:			    TREE
                        ; TYPESET:		    OUT TYPESET_TYPE)
                        IS
      BEGIN -- EVAL_RANGE
         IF EXP.TY = DN_RANGE THEN
            DECLARE
               EXP_1:		CONSTANT TREE := D(AS_EXP1, EXP);
               EXP_2:		CONSTANT TREE := D(AS_EXP2, EXP);
               TYPESET_1:	TYPESET_TYPE;
               TYPESET_2:	TYPESET_TYPE;
            BEGIN
               EVAL_EXP_TYPES(EXP_1, TYPESET_1);
               EVAL_EXP_TYPES(EXP_2, TYPESET_2);
               REQUIRE_SCALAR_TYPE(EXP_1, TYPESET_1);
               REQUIRE_SCALAR_TYPE(EXP_2, TYPESET_2);
               REQUIRE_SAME_TYPES
                                        ( EXP_1, TYPESET_1
                                        , EXP_2, TYPESET_2
                                        , TYPESET );
            END;
         
         ELSIF EXP.TY = DN_ATTRIBUTE
           OR ELSE ( EXP.TY = DN_FUNCTION_CALL AND THEN D(AS_NAME,EXP).TY = DN_ATTRIBUTE )
         THEN
            DECLARE
               IS_SUBTYPE: BOOLEAN;
            BEGIN
               EVAL_ATTRIBUTE(EXP, TYPESET, IS_SUBTYPE);
               IF NOT IS_SUBTYPE THEN
                  TYPESET := EMPTY_TYPESET;
                  ERROR(D(LX_SRCPOS,EXP),
                                                "RANGE ATTRIBUTE REQUIRED");
               
               END IF;
            END;
         ELSE
            TYPESET := EMPTY_TYPESET;
            ERROR(D(LX_SRCPOS,EXP), "RANGE REQUIRED");
         END IF;
      END EVAL_RANGE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_DISCRETE_RANGE
                        ( EXP:			    TREE
                        ; TYPESET:		    OUT TYPESET_TYPE)
                        IS
         NEW_TYPESET:	TYPESET_TYPE;
      BEGIN -- EVAL_DISCRETE_RANGE
      
                -- IF IT'S A RANGE OR RANGE ATTRIBUTE
         IF EXP.TY = DN_RANGE
                                OR ELSE EXP.TY = DN_ATTRIBUTE
                                OR ELSE EXP.TY = DN_FUNCTION_CALL
                                THEN
         
                        -- EVALUATE THE RANGE
            EVAL_RANGE(EXP, NEW_TYPESET);
         
                        -- ELSE -- MUST BE DISCRETE SUBTYPE OR SUBTYPE INDICATION
         ELSE -- MUST BE A (DISCRETE) SUBTYPE INDICATION
            DECLARE
               SUBTYPE_INDICATION: TREE;
               TYPE_SPEC: TREE;
            BEGIN
               IF EXP.TY = DN_DISCRETE_SUBTYPE THEN
                  SUBTYPE_INDICATION := D(
                                                AS_SUBTYPE_INDICATION, EXP);
               ELSE
                  SUBTYPE_INDICATION := EXP;
               END IF;
            
               NEW_TYPESET := EMPTY_TYPESET;
               TYPE_SPEC := EVAL_SUBTYPE_INDICATION(
                                        SUBTYPE_INDICATION);
               IF TYPE_SPEC /= TREE_VOID THEN
                  ADD_TO_TYPESET(NEW_TYPESET,
                                                TYPE_SPEC);
               END IF;
            END;
         END IF;
      
         REQUIRE_DISCRETE_TYPE(EXP, NEW_TYPESET);
         TYPESET := NEW_TYPESET;
      END EVAL_DISCRETE_RANGE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_NON_UNIVERSAL_DISCRETE_RANGE
                        ( EXP:			    TREE
                        ; TYPESET:		    OUT TYPESET_TYPE)
                        IS
                -- EVALUATE TYPES OF DISCRETE RANGE IN A CONTEXT WHERE
                -- ... CONVERTIBLE UNIVERSAL_INTEGER IS TAKEN AS INTEGER
      
         NEW_TYPESET:	TYPESET_TYPE;
         TYPE_NODE:	TREE;
      BEGIN
      
                -- EVALUATE THE DISCRETE RANGE
         EVAL_DISCRETE_RANGE(EXP, NEW_TYPESET);
      
                -- IF THERE ARE INTERPRETATIONS
         IF NOT IS_EMPTY(NEW_TYPESET) THEN
         
                        -- IF INTERPRETATION IS UNIVERSAL_INTEGER
                        -- ... AND CONTEXT IS CONVERTIBLE
            TYPE_NODE := GET_THE_TYPE(NEW_TYPESET);
            IF TYPE_NODE.TY = DN_ANY_INTEGER
                                        AND THEN EXP.TY = DN_RANGE
                                        AND THEN D(AS_EXP1,EXP).TY /= DN_PARENTHESIZED
                                        AND THEN D(AS_EXP2,EXP).TY /= DN_PARENTHESIZED THEN
            
                                -- REPLACE WITH PREDEFINED INTEGER
               NEW_TYPESET := EMPTY_TYPESET;
               ADD_TO_TYPESET(NEW_TYPESET,
                                        PREDEFINED_INTEGER);
            
                                -- ELSE -- SINCE INTERPRETATION IS NOT CONVERTIBLE UNIVERSAL
            ELSE
            
                                -- DISCARD INTERPRETATIONS AS UNIVERSAL_INTEGER
               REQUIRE_NON_UNIVERSAL_TYPE(EXP,
                                        NEW_TYPESET);
            END IF;
         END IF;
      
                -- RETURN THE REDUCED TYPESET
         TYPESET := NEW_TYPESET;
      END EVAL_NON_UNIVERSAL_DISCRETE_RANGE;
   
    --|----------------------------------------------------------------------------------------------
   END EXP_TYPE;
