    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	EXPRESO
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY EXPRESO IS
      USE DEF_UTIL;
      USE SEM_GLOB;
      USE VIS_UTIL;
      USE EXP_TYPE;
      USE MAKE_NOD;
      USE RED_SUBP;
      USE REQ_UTIL;
      USE DEF_WALK;
      USE AGGRESO;
      USE ATT_WALK;
   
       FUNCTION WALK_DISCRMT_CONSTRAINT
                ( RECORD_TYPE:		TREE
                ; GENERAL_ASSOC_S:	TREE )
                RETURN TREE;
   
       FUNCTION RESOLVE_RANGE(EXP: TREE; TYPE_SPEC: TREE) RETURN TREE;
   
   
       FUNCTION GET_NAME_DEFN(NAME: TREE) RETURN TREE IS
      BEGIN
         CASE NAME.TY IS
            WHEN DN_VOID =>
               RETURN TREE_VOID;
            WHEN DN_SELECTED =>
               RETURN D(SM_DEFN, D(AS_DESIGNATOR, NAME));
            WHEN CLASS_DESIGNATOR =>
               RETURN D(SM_DEFN, NAME);
            WHEN OTHERS =>
               PUT_LINE ( "!! GET_NAME_DEFN: INVALID PARAMETER");
               RAISE PROGRAM_ERROR;
         END CASE;
      END GET_NAME_DEFN;
   
        -- $$$$ PROBABLY SHOULDN'T BE HERE
       FUNCTION LENGTH(A: SEQ_TYPE) RETURN NATURAL IS
         COUNT: NATURAL := 0;
         ATAIL: SEQ_TYPE := A;
      BEGIN
         WHILE NOT IS_EMPTY(ATAIL) LOOP
            COUNT := COUNT + 1;
            ATAIL := TAIL(ATAIL);
         END LOOP;
         RETURN COUNT;
      END LENGTH;
   
       FUNCTION APPROP_STRUCT(TYPE_SPEC: TREE) RETURN TREE IS
         TYPE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
      BEGIN
         IF TYPE_STRUCT.TY = DN_ACCESS THEN
            TYPE_STRUCT := GET_BASE_STRUCT(D(SM_DESIG_TYPE,
                                        TYPE_STRUCT));
         END IF;
         RETURN TYPE_STRUCT;
      END APPROP_STRUCT;
--|#################################################################################################
--|
FUNCTION GET_STATIC_VALUE ( EXP :TREE ) RETURN TREE IS
BEGIN
  CASE EXP.TY IS
  WHEN CLASS_USED_OBJECT | CLASS_NAME_VAL | CLASS_EXP_VAL =>
    RETURN D( SM_VALUE, EXP );
  WHEN DN_CONSTANT_ID | DN_NUMBER_ID =>
    RETURN GET_STATIC_VALUE ( D( SM_INIT_EXP, EXP ) );
  WHEN CLASS_ENUM_LITERAL =>
    RETURN UARITH.U_VAL ( DI( SM_POS, EXP ) );
  WHEN OTHERS =>
    RETURN TREE_VOID;
  END CASE;
END GET_STATIC_VALUE;
   
        --========================================================================
   
       FUNCTION RESOLVE_EXP(EXP: TREE; TYPE_SPEC: TREE) RETURN TREE IS
         EXP_KIND:		CONSTANT NODE_NAME := EXP.TY;
      
      BEGIN
                -- SHOULD BE SYNTACTICAL EXPRESSION OR VOID
         IF EXP_KIND NOT IN CLASS_EXP THEN
                        -- PRESUMABLY ANY ERROR MESSAGES HAVE BEEN GIVEN
            IF EXP_KIND = DN_RANGE OR EXP_KIND =
                                        DN_DISCRETE_SUBTYPE THEN
               RETURN RESOLVE_DISCRETE_RANGE(EXP,
                                        TYPE_SPEC);
            ELSE
               RETURN EXP;
            END IF;
         END IF;
      
      
         CASE CLASS_EXP'(EXP_KIND) IS
         
            WHEN DN_USED_CHAR | DN_USED_OBJECT_ID =>
               DECLARE
                  DEFSET: DEFSET_TYPE;
                  DEFINTERP: DEFINTERP_TYPE;
                  DEF: TREE;
                  DEF_TYPE: TREE;
                  NEW_DEFSET: DEFSET_TYPE :=
                                                EMPTY_DEFSET;
               
                  DEFN: TREE := TREE_VOID;
               BEGIN
                  IF TYPE_SPEC /= TREE_VOID THEN
                     DEFSET := FETCH_DEFSET(
                                                        EXP);
                     WHILE NOT IS_EMPTY(DEFSET) LOOP
                        POP(DEFSET,
                                                                DEFINTERP);
                        DEF := GET_DEF(
                                                                DEFINTERP);
                        DEF_TYPE :=
                                                                EXPRESSION_TYPE_OF_DEF(
                                                                DEF);
                        IF DEF_TYPE =
                                                                        TYPE_SPEC
                                                                        OR ELSE ( DEF_TYPE.TY =
                                                                        DN_ANY_INTEGER
                                                                        AND THEN ( TYPE_SPEC.TY =
                                                                                DN_INTEGER
                                                                                OR ELSE TYPE_SPEC.TY
                                                                                =
                                                                                DN_UNIVERSAL_INTEGER))
                                                                        OR ELSE ( DEF_TYPE.TY =
                                                                        DN_ANY_REAL
                                                                        AND THEN ( TYPE_SPEC.TY =
                                                                                DN_FLOAT
                                                                                OR ELSE TYPE_SPEC.TY =
                                                                                DN_FIXED
                                                                                OR ELSE TYPE_SPEC.TY
                                                                                =
                                                                                DN_UNIVERSAL_REAL))
                                                                        THEN
                           ADD_TO_DEFSET(
                                                                        NEW_DEFSET,
                                                                        DEFINTERP);
                        END IF;
                     END LOOP;
                     IF IS_EMPTY(NEW_DEFSET) THEN
                        ERROR(D(LX_SRCPOS,
                                                                        EXP),
                                                                "**** NO DEFS IN RESOLVE");
                     END IF;
                     REQUIRE_UNIQUE_DEF(EXP,
                                                        NEW_DEFSET);
                     DEFN := GET_THE_ID(
                                                        NEW_DEFSET);
                  END IF;
               
                  D(SM_DEFN, EXP, DEFN);
                  IF DEFN.TY = DN_FUNCTION_ID
                                                        OR ELSE DEFN.TY =
                                                        DN_GENERIC_ID THEN
                                                -- IT'S FUNCTION CALL WITH ALL DEFAULT ARGS
                     DECLARE
                        NEW_EXP: TREE;
                     BEGIN
                        NEW_EXP :=
                                                                MAKE_FUNCTION_CALL
                                                                (
                                                                LX_SRCPOS =>
                                                                D(
                                                                        LX_SRCPOS,
                                                                        EXP)
                                                                , AS_NAME =>
                                                                MAKE_USED_NAME_ID_FROM_OBJECT
                                                                ( EXP )
                                                                ,
                                                                AS_GENERAL_ASSOC_S =>
                                                                MAKE_GENERAL_ASSOC_S
                                                                ( LIST =>
                                                                        (TREE_NIL,TREE_NIL) )
                                                                ,
                                                                SM_EXP_TYPE =>
                                                                D(
                                                                        SM_TYPE_SPEC,
                                                                        GET_NAME_DEFN
                                                                        (
                                                                                D(
                                                                                        AS_NAME,
                                                                                        D(
                                                                                                SM_SPEC,
                                                                                                DEFN)) )) );
                                                        -- MAKE NORMALIZED_PARAM_S FOR DEFAULT PARAMS
                        D(
                                                                SM_NORMALIZED_PARAM_S
                                                                , NEW_EXP
                                                                ,
                                                                RESOLVE_SUBP_PARAMETERS
                                                                ( GET_DEF(
                                                                                HEAD(
                                                                                        NEW_DEFSET))
                                                                        ,
                                                                        D(
                                                                                AS_GENERAL_ASSOC_S,
                                                                                NEW_EXP) ) );
                        RETURN NEW_EXP;
                     END;
                  ELSIF DEFN.TY IN
                                                        CLASS_TYPE_NAME THEN
                                                -- (FOR NAME OF TASK TYPE INSIDE THE TASK BODY)
                     D(SM_EXP_TYPE, EXP, D(
                                                                SM_TYPE_SPEC,
                                                                DEFN));
                  ELSIF DEFN /= TREE_VOID THEN
                     D(SM_EXP_TYPE, EXP, D(
                                                                SM_OBJ_TYPE,
                                                                DEFN));
                     D(SM_VALUE, EXP,
                                                        GET_STATIC_VALUE(
                                                                DEFN));
                  ELSE
                     D(SM_EXP_TYPE, EXP,
                                                        TREE_VOID);
                  END IF;
               END;
         
         
            WHEN DN_USED_OP =>
               PUT_LINE ( "!! INVALID PARAMETER FOR RESOLVE_EXP" );
               RAISE PROGRAM_ERROR;
         
            WHEN DN_USED_NAME_ID =>
                                -- ALREADY RESOLVED
               NULL;
         
         
            WHEN DN_ATTRIBUTE =>
               DECLARE
                  NEW_EXP: TREE;
               BEGIN
                  NEW_EXP := RESOLVE_ATTRIBUTE(EXP);
                  IF D(SM_EXP_TYPE,NEW_EXP).TY IN
                                                        CLASS_UNSPECIFIED_TYPE THEN
                     D(SM_EXP_TYPE, NEW_EXP,
                                                        TYPE_SPEC);
                  END IF;
                  RETURN NEW_EXP;
               END;
         
            WHEN DN_SELECTED =>
               DECLARE
                  NAME: TREE := D(AS_NAME, EXP);
                  DESIGNATOR: TREE := D(
                                                AS_DESIGNATOR, EXP);
                  DESIGNATOR_REGION: TREE :=
                                                TREE_VOID;
               
                  NAME_TYPESET: TYPESET_TYPE;
                  NAME_TYPEINTERP: TYPEINTERP_TYPE;
                  NEW_NAME_TYPESET: TYPESET_TYPE :=
                                                EMPTY_TYPESET;
               BEGIN
               
                                        -- RESOLVE THE DESIGNATOR
                  DESIGNATOR := RESOLVE_EXP(
                                                DESIGNATOR, TYPE_SPEC);
                  D(AS_DESIGNATOR, EXP, DESIGNATOR);
               
                                        -- IF DESIGNATOR REPRESENTS AN EXPRESSION
                  IF DESIGNATOR.TY IN
                                                        CLASS_USED_OBJECT THEN
                  
                                                -- COPY VALUE AND SUBTYPE
                     D(SM_VALUE, EXP,
                                                        GET_STATIC_VALUE(
                                                                DESIGNATOR));
                     D(SM_EXP_TYPE, EXP, D(
                                                                SM_EXP_TYPE,
                                                                DESIGNATOR));
                  
                                                -- IF PREFIX CAN BE EXPRESSION
                     IF NAME.TY NOT IN
                                                                CLASS_USED_NAME THEN
                     
                                                        -- GET SAVED TYPESET FOR NAME
                        NAME_TYPESET :=
                                                                FETCH_TYPESET(
                                                                NAME);
                     
                                                        -- GET POSSIBLE TYPES OF PREFIX
                        IF D(SM_DEFN,
                                                                        DESIGNATOR) /=
                                                                        TREE_VOID THEN
                           DESIGNATOR_REGION
                                                                        :=
                                                                        D(
                                                                        XD_SOURCE_NAME,
                                                                        D(
                                                                                XD_REGION_DEF
                                                                                ,
                                                                                GET_DEF_FOR_ID(
                                                                                        D(
                                                                                                SM_DEFN,
                                                                                                DESIGNATOR)) ));
                        END IF;
                        WHILE NOT IS_EMPTY(
                                                                        NAME_TYPESET) LOOP
                           POP(
                                                                        NAME_TYPESET,
                                                                        NAME_TYPEINTERP);
                           IF D(
                                                                                XD_SOURCE_NAME
                                                                                ,
                                                                                APPROP_STRUCT(
                                                                                        GET_TYPE(
                                                                                                NAME_TYPEINTERP)))
                                                                                =
                                                                                DESIGNATOR_REGION
                                                                                THEN
                              ADD_TO_TYPESET
                                                                                (
                                                                                NEW_NAME_TYPESET
                                                                                ,
                                                                                NAME_TYPEINTERP);
                           END IF;
                        END LOOP;
                     
                                                        -- REQUIRE A UNIQUE TYPE
                        REQUIRE_UNIQUE_TYPE(
                                                                NAME,
                                                                NEW_NAME_TYPESET);
                     
                                                        -- RESOLVE THE NAME
                        NAME :=
                                                                RESOLVE_EXP(
                                                                NAME,
                                                                NEW_NAME_TYPESET);
                        D(AS_NAME, EXP,
                                                                NAME);
                     END IF;
                  
                                                -- ELSE IF DESIGNATOR IS A FUNCTION CALL
                  ELSIF DESIGNATOR.TY =
                                                        DN_FUNCTION_CALL THEN
                  
                                                -- REPLACE:
                                                --	    SELECTED
                                                --	      AS_NAME: <PREFIX_NAME>
                                                --	      AS_DESIGNATOR: FUNCTION_CALL
                                                --		AS_NAME: <FUNCTION_NAME>
                                                --		...
                                                -- BY:
                                                --	    FUNCTION_CALL
                                                --	      AS_NAME: SELECTED
                                                --		AS_NAME: <PREFIX_NAME>
                                                --		AS_DESIGNATOR: <FUNCTION_NAME>
                                                --	      ...
                     D(AS_DESIGNATOR, EXP, D(
                                                                AS_NAME,
                                                                DESIGNATOR));
                     D(SM_EXP_TYPE, EXP,
                                                        TREE_VOID);
                     D(AS_NAME, DESIGNATOR, EXP);
                     D(LX_SRCPOS, DESIGNATOR, D(
                                                                LX_SRCPOS,
                                                                NAME));
                     RETURN DESIGNATOR;
                  END IF;
               END;
         
         
            WHEN DN_FUNCTION_CALL =>
               RETURN RESOLVE_FUNCTION_CALL(EXP,
                                        TYPE_SPEC);
         
         
            WHEN DN_INDEXED =>
               PUT_LINE ( "!! RESOLVE_EXP: INVALID NODE" );
               RAISE PROGRAM_ERROR;
         
            WHEN DN_SLICE =>
               PUT_LINE ( "!! RESOLVE_EXP: INVALID NODE");
               RAISE PROGRAM_ERROR;
         
            WHEN DN_ALL =>
               DECLARE
                  NAME: TREE := D(AS_NAME, EXP);
                  NAME_TYPESET: TYPESET_TYPE :=
                                                FETCH_TYPESET(NAME);
                  NAME_TYPEINTERP: TYPEINTERP_TYPE;
                  NAME_STRUCT: TREE;
                  NEW_NAME_TYPESET: TYPESET_TYPE :=
                                                EMPTY_TYPESET;
               BEGIN
               
                                        -- GET LIST OF NAME TYPES WITH REQUIRED DESIG TYPE
                                        -- ... (FIND AT LEAST ONE UNLESS TYPE_SPEC IS VOID)
                  WHILE NOT IS_EMPTY(NAME_TYPESET) LOOP
                     POP(NAME_TYPESET,
                                                        NAME_TYPEINTERP);
                     NAME_STRUCT :=
                                                        GET_BASE_STRUCT(
                                                        GET_TYPE(
                                                                NAME_TYPEINTERP));
                     IF GET_BASE_TYPE(D(
                                                                        SM_DESIG_TYPE,
                                                                        NAME_STRUCT)) =
                                                                TYPE_SPEC
                                                                THEN
                        ADD_TO_TYPESET
                                                                (
                                                                NEW_NAME_TYPESET
                                                                ,
                                                                NAME_TYPEINTERP );
                     END IF;
                  END LOOP;
               
                                        -- RESOLVE THE NAME
                  REQUIRE_UNIQUE_TYPE(NAME,
                                                NEW_NAME_TYPESET);
                  NAME := RESOLVE_EXP(NAME,
                                                NEW_NAME_TYPESET);
                  D(AS_NAME, EXP, NAME);
               
                                        -- EXPRESSION TYPE IS DESIGNATED SUBTYPE OF NAME TYPE
                  IF NOT IS_EMPTY(NEW_NAME_TYPESET) THEN
                     D(SM_EXP_TYPE
                                                        , EXP
                                                        , D(SM_DESIG_TYPE
                                                                ,
                                                                GET_BASE_STRUCT
                                                                (
                                                                        GET_THE_TYPE(
                                                                                NEW_NAME_TYPESET))));
                  ELSE
                     D(SM_EXP_TYPE, EXP,
                                                        TYPE_SPEC);
                  END IF;
               END;
         
         
            WHEN DN_SHORT_CIRCUIT =>
               DECLARE
                  EXP1: TREE := D(AS_EXP1, EXP);
                  EXP2: TREE := D(AS_EXP2, EXP);
               BEGIN
               
                                        -- RESOLVE THE TWO EXPRESSIONS
                  EXP1 := RESOLVE_EXP(EXP1,
                                                TYPE_SPEC);
                  D(AS_EXP1, EXP, EXP1);
                  EXP2 := RESOLVE_EXP(EXP2,
                                                TYPE_SPEC);
                  D(AS_EXP2, EXP, EXP2);
               
                                        -- STORE THE RESULT TYPE
                  D(SM_EXP_TYPE, EXP, TYPE_SPEC);
               END;
         
         
            WHEN DN_NUMERIC_LITERAL =>
               DECLARE
               BEGIN
               
                                        -- VALUE ALREADY KNOWN
                                        -- STORE TYPE WHICH IS RESULT OF ANY IMPLICIT CONVERSION
                  D(SM_EXP_TYPE, EXP, TYPE_SPEC);
               END;
         
         
            WHEN DN_NULL_ACCESS =>
               DECLARE
               BEGIN
               
                                        -- STORE THE RESULT TYPE
                  D(SM_EXP_TYPE, EXP, TYPE_SPEC);
               END;
         
         
            WHEN DN_RANGE_MEMBERSHIP =>
               DECLARE
                  EXP_NODE: TREE := D(AS_EXP, EXP);
                  RANGE_NODE: TREE := D(AS_RANGE,
                                                EXP);
                  EXP_TYPESET: TYPESET_TYPE;
                  RANGE_TYPESET: TYPESET_TYPE;
                  TYPESET: TYPESET_TYPE;
                  TYPE_MARK_TYPE: TREE;
               BEGIN
                  EVAL_EXP_TYPES(EXP_NODE,
                                                EXP_TYPESET);
                  IF RANGE_NODE.TY = DN_RANGE
                                                        OR 
                                                        RANGE_NODE.TY =
                                                        DN_ATTRIBUTE
                                                        OR ( 
                                                                RANGE_NODE.TY =
                                                        DN_FUNCTION_CALL
                                                        AND THEN D(
                                                                        AS_NAME,
                                                                        RANGE_NODE).TY =
                                                        DN_ATTRIBUTE )
                                                        THEN
                     EVAL_RANGE(RANGE_NODE,
                                                        RANGE_TYPESET);
                     REQUIRE_SAME_TYPES
                                                        ( EXP_NODE,
                                                        EXP_TYPESET
                                                        , RANGE_NODE,
                                                        RANGE_TYPESET
                                                        , TYPESET );
                     REQUIRE_UNIQUE_TYPE(
                                                        RANGE_NODE,
                                                        TYPESET);
                     EXP_NODE := RESOLVE_EXP(
                                                        EXP_NODE, TYPESET);
                     D(AS_EXP, EXP, EXP_NODE);
                     RANGE_NODE :=
                                                        RESOLVE_RANGE
                                                        (RANGE_NODE,
                                                        GET_THE_TYPE(
                                                                TYPESET));
                     D(AS_RANGE, EXP,
                                                        RANGE_NODE);
                     D(SM_EXP_TYPE, EXP,
                                                        PREDEFINED_BOOLEAN);
                  ELSE
                     TYPE_MARK_TYPE :=
                                                        EVAL_TYPE_MARK(
                                                        RANGE_NODE);
                     RANGE_NODE :=
                                                        RESOLVE_TYPE_MARK(
                                                        RANGE_NODE);
                     REQUIRE_TYPE(
                                                        TYPE_MARK_TYPE,
                                                        EXP_NODE,
                                                        EXP_TYPESET);
                     EXP_NODE := RESOLVE_EXP(
                                                        EXP_NODE,
                                                        EXP_TYPESET);
                     RETURN
                                                        MAKE_TYPE_MEMBERSHIP
                                                        ( LX_SRCPOS => D(
                                                                LX_SRCPOS,
                                                                EXP)
                                                        , AS_EXP =>
                                                        EXP_NODE
                                                        , AS_NAME =>
                                                        RANGE_NODE
                                                        , AS_MEMBERSHIP_OP
                                                        => D(
                                                                AS_MEMBERSHIP_OP,
                                                                EXP)
                                                        , SM_EXP_TYPE =>
                                                        PREDEFINED_BOOLEAN );
                  END IF;
               END;
         
         
            WHEN DN_TYPE_MEMBERSHIP | DN_CONVERSION =>
               PUT_LINE ( "RESOLVE_EXP: INVALID NODE" );
               RAISE PROGRAM_ERROR;
         
            WHEN DN_QUALIFIED =>
               DECLARE
                  EXP_NODE: TREE := D(AS_EXP, EXP);
                  NAME: TREE := D(AS_NAME, EXP);
               
                  EXP_TYPESET: TYPESET_TYPE;
                  NAME_DEFN: TREE;
                  SUBTYPE_SPEC: TREE;
                  VALUE: TREE := D(SM_VALUE, EXP);
               BEGIN
                  NAME := RESOLVE_TYPE_MARK(NAME);
                  D(AS_NAME, EXP, NAME);
                  NAME_DEFN := GET_NAME_DEFN(NAME);
                  IF NAME_DEFN /= TREE_VOID THEN
                     SUBTYPE_SPEC := D(
                                                        SM_TYPE_SPEC,
                                                        NAME_DEFN);
                  ELSE
                     SUBTYPE_SPEC := TREE_VOID;
                  END IF;
               
                  EVAL_EXP_TYPES(EXP_NODE,
                                                EXP_TYPESET);
                  REQUIRE_TYPE(GET_BASE_TYPE(
                                                        SUBTYPE_SPEC)
                                                , EXP_NODE, EXP_TYPESET);
                  IF NOT IS_EMPTY(EXP_TYPESET) THEN
                     EXP_NODE :=
                                                        RESOLVE_EXP_OR_AGGREGATE
                                                        ( EXP_NODE
                                                        , SUBTYPE_SPEC
                                                        , NAMED_OTHERS_OK =>
                                                        TRUE );
                  ELSE
                     EXP_NODE := RESOLVE_EXP
                                                        ( EXP_NODE
                                                        , TREE_VOID );
                  END IF;
                  D(AS_EXP, EXP, EXP_NODE);
               
                  D(SM_EXP_TYPE, EXP, SUBTYPE_SPEC);
                  D(SM_VALUE, EXP, GET_STATIC_VALUE(
                                                        EXP_NODE));
               END;
         
         
            WHEN DN_PARENTHESIZED =>
               DECLARE
                  EXP_NODE: TREE := D(AS_EXP, EXP);
               BEGIN
                  EXP_NODE := RESOLVE_EXP(EXP_NODE,
                                                TYPE_SPEC);
                  D(AS_EXP, EXP, EXP_NODE);
                  D(SM_EXP_TYPE, EXP, D(SM_EXP_TYPE,
                                                        EXP_NODE));
                  D(SM_VALUE, EXP, GET_STATIC_VALUE(
                                                        EXP_NODE));
               END;
         
         
            WHEN DN_AGGREGATE =>
               RESOLVE_AGGREGATE(EXP, TYPE_SPEC);
         
            WHEN DN_STRING_LITERAL =>
               RESOLVE_STRING(EXP, TYPE_SPEC);
         
         
            WHEN DN_QUALIFIED_ALLOCATOR =>
               DECLARE
                  QUALIFIED: TREE := D(AS_QUALIFIED,
                                                EXP);
               BEGIN
                                        -- (NOTE: REQUIRED TYPE IGNORED IN RESOLVE_EXP)
                  QUALIFIED := RESOLVE_EXP(
                                                QUALIFIED, TREE_VOID);
                  D(SM_EXP_TYPE, EXP, TYPE_SPEC);
               END;
         
         
            WHEN DN_SUBTYPE_ALLOCATOR =>
               DECLARE
                  SUBTYPE_INDICATION: TREE := D(
                                                AS_SUBTYPE_INDICATION, EXP);
                  EXP_TYPE: TREE := D(SM_EXP_TYPE,
                                                EXP);
                  DESIG_TYPE: TREE := D(
                                                SM_DESIG_TYPE, EXP);
                  SUBTYPE_SPEC: TREE;
               BEGIN
                  RESOLVE_SUBTYPE_INDICATION(
                                                SUBTYPE_INDICATION,
                                                SUBTYPE_SPEC);
                  D(AS_SUBTYPE_INDICATION, EXP,
                                                SUBTYPE_INDICATION);
                  D(SM_EXP_TYPE, EXP, TYPE_SPEC);
                  D(SM_DESIG_TYPE, EXP, SUBTYPE_SPEC);
               END;
         
         END CASE;
      
                --$$$$$ NEED TO HAVE A TEMPORARY FOR EXP
         RETURN EXP;
      END RESOLVE_EXP;
   
        ------------------------------------------------------------------------
   
       FUNCTION RESOLVE_RANGE(EXP: TREE; TYPE_SPEC: TREE) RETURN TREE IS
      BEGIN
                -- IF IT IS A RANGE
         IF EXP.TY = DN_RANGE THEN
         
                        -- SAVE THE RANGE TYPE AND RESOLVE THE BOUNDS
            D(SM_TYPE_SPEC, EXP, TYPE_SPEC);
            D(AS_EXP1, EXP, RESOLVE_EXP(D(AS_EXP1, EXP),
                                        TYPE_SPEC));
            D(AS_EXP2, EXP, RESOLVE_EXP(D(AS_EXP2, EXP),
                                        TYPE_SPEC));
            RETURN EXP;
         
                        -- ELSE IF IT IS A RANGE ATTRIBUTE
         ELSIF EXP.TY = DN_ATTRIBUTE
                                OR ELSE ( EXP.TY = DN_FUNCTION_CALL
                                AND THEN D(AS_NAME,EXP).TY =
                                DN_ATTRIBUTE )
                                THEN
         
                        -- RESOLVE THE ATTRIBUTE
            RETURN RESOLVE_ATTRIBUTE(EXP);
         
         ELSE
            PUT_LINE ( "!! RESOLVE_RANGE: NOT A RANGE");
            RAISE PROGRAM_ERROR;
         END IF;
      END RESOLVE_RANGE;
   
   
       FUNCTION RESOLVE_DISCRETE_RANGE(EXP: TREE; TYPE_SPEC: TREE) RETURN
                        TREE IS
      BEGIN
                -- IF IT IS A RANGE OR RANGE ATTRIBUTE
         IF EXP.TY = DN_RANGE
                                OR EXP.TY = DN_ATTRIBUTE
                                OR EXP.TY = DN_FUNCTION_CALL THEN
         
                        -- RESOLVE THE RANGE
            RETURN RESOLVE_RANGE(EXP, TYPE_SPEC);
         
                        -- ELSE IF IT IS A DISCRETE_SUBTYPE (INTERMEDIATE NODE)
         ELSIF EXP.TY = DN_DISCRETE_SUBTYPE THEN
         
                        -- RESOLVE THE SUBTYPE INDICATION
            DECLARE
               SUBTYPE_INDICATION: TREE := D(
                                        AS_SUBTYPE_INDICATION, EXP);
               THE_SUBTYPE: TREE;
            BEGIN
               RESOLVE_SUBTYPE_INDICATION
                                        ( SUBTYPE_INDICATION, THE_SUBTYPE );
            END;
            RETURN EXP;
         
                        -- ELSE IF IT IS SUBTYPE INDICATION
         ELSIF EXP.TY = DN_SUBTYPE_INDICATION THEN
         
                        -- MAKE DISCRETE SUBTYPE NODE AND RESOLVE
            RETURN RESOLVE_DISCRETE_RANGE
                                ( MAKE_DISCRETE_SUBTYPE
                                ( LX_SRCPOS => D(LX_SRCPOS, EXP)
                                        , AS_SUBTYPE_INDICATION => EXP )
                                , TYPE_SPEC );
         
                        -- ELSE -- SINCE IT MUST BE A TYPE MARK
         ELSE
         
                        -- MAKE SUBTYPE INDICATION AND RESOLVE
            RETURN RESOLVE_DISCRETE_RANGE
                                ( MAKE_SUBTYPE_INDICATION
                                ( LX_SRCPOS => D(LX_SRCPOS, EXP)
                                        , AS_NAME => EXP
                                        , AS_CONSTRAINT => TREE_VOID )
                                , TYPE_SPEC );
         
         END IF;
      
      END RESOLVE_DISCRETE_RANGE;
   
        ------------------------------------------------------------------------
   
       FUNCTION RESOLVE_TYPE_MARK(EXP: TREE) RETURN TREE IS
      BEGIN
         IF EXP.TY = DN_SUBTYPE_INDICATION THEN
            RETURN RESOLVE_TYPE_MARK(D(AS_NAME, EXP));
                        -- NOTE ERROR ALREADY GIVEN IF NON-VOID CONSTRAINT
         END IF;
      
         IF EXP.TY = DN_SELECTED THEN
            D(AS_DESIGNATOR, EXP, RESOLVE_TYPE_MARK(D(
                                                AS_DESIGNATOR,EXP)));
            D(SM_EXP_TYPE, EXP, TREE_VOID);
            RETURN EXP;
         
         ELSIF EXP.TY = DN_USED_OBJECT_ID THEN
                        -- $$$$ SOMETIMES STILL A DEF? WHY?
            IF D(SM_DEFN,EXP).TY = DN_DEF THEN
               D(SM_DEFN, EXP, D(XD_SOURCE_NAME, D(
                                                        SM_DEFN,EXP)));
            END IF;
            RETURN MAKE_USED_NAME_ID_FROM_OBJECT (EXP);
         
         
         ELSE
            RETURN EXP;
         END IF;
      END RESOLVE_TYPE_MARK;
   
        ------------------------------------------------------------------------
   
       PROCEDURE WALK_RANGE (BASE_TYPE: TREE; RANGE_NODE: TREE) IS
         EXP1: TREE := D(AS_EXP1, RANGE_NODE);
         EXP2: TREE := D(AS_EXP2, RANGE_NODE);
         TYPESET_1, TYPESET_2: TYPESET_TYPE;
      BEGIN
         EVAL_EXP_TYPES(EXP1, TYPESET_1);
         EVAL_EXP_TYPES(EXP2, TYPESET_2);
         REQUIRE_TYPE(BASE_TYPE, EXP1, TYPESET_1);
         REQUIRE_TYPE(BASE_TYPE, EXP2, TYPESET_2);
         EXP1 := RESOLVE_EXP(EXP1, TYPESET_1);
         D(AS_EXP1, RANGE_NODE, EXP1);
         EXP2 := RESOLVE_EXP(EXP2, TYPESET_2);
         D(AS_EXP2, RANGE_NODE, EXP2);
         D(SM_TYPE_SPEC, RANGE_NODE, BASE_TYPE);
      END WALK_RANGE;
   
       PROCEDURE RESOLVE_SUBTYPE_INDICATION
                        ( EXP: IN OUT TREE; SUBTYPE_SPEC: OUT TREE)
                        IS
         NAME:		TREE;
         NAME_DEFN:	TREE;
         CONSTRAINT:	TREE;
         TYPE_STRUCT:	TREE;
         DESIG_STRUCT:	TREE;
         NEW_TYPE_SPEC:	TREE := TREE_VOID;
      BEGIN
         IF EXP.TY /= DN_SUBTYPE_INDICATION THEN
            IF EXP.TY = DN_FUNCTION_CALL THEN
               PUT_LINE ( "!! SUBTYPE_IND IS FUNCTION CALL $$$$$$");
               RAISE PROGRAM_ERROR;
            END IF;
         
                        -- (MUST BE A TYPE MARK)
            EXP := MAKE_SUBTYPE_INDICATION
                                ( AS_NAME => EXP
                                , AS_CONSTRAINT => TREE_VOID
                                , LX_SRCPOS => D(LX_SRCPOS, EXP) );
         END IF;
      
         NAME := D(AS_NAME, EXP);
         NAME := RESOLVE_TYPE_MARK(NAME);
         D(AS_NAME, EXP, NAME);
         NAME_DEFN := GET_NAME_DEFN(NAME);
         IF NAME_DEFN /= TREE_VOID THEN
            NEW_TYPE_SPEC := D(SM_TYPE_SPEC, NAME_DEFN);
         END IF;
         TYPE_STRUCT := GET_BASE_STRUCT(NEW_TYPE_SPEC);
         IF NEW_TYPE_SPEC.TY IN CLASS_PRIVATE_SPEC
                                --AND THEN KIND(TYPE_STRUCT) NOT IN CLASS_PRIVATE_SPEC THEN
                                AND THEN TYPE_STRUCT /= D(SM_TYPE_SPEC,D(
                                        XD_SOURCE_NAME,TYPE_STRUCT))
                                THEN
            NEW_TYPE_SPEC := D(SM_TYPE_SPEC, NEW_TYPE_SPEC);
         END IF;
         DESIG_STRUCT := TYPE_STRUCT;
         IF DESIG_STRUCT.TY = DN_ACCESS THEN
            DESIG_STRUCT := GET_BASE_STRUCT(D(SM_DESIG_TYPE,
                                        DESIG_STRUCT));
         END IF;
      
         CONSTRAINT := D(AS_CONSTRAINT, EXP);
         IF CONSTRAINT.TY = DN_ATTRIBUTE
                                OR ELSE (CONSTRAINT.TY =
                                DN_FUNCTION_CALL
                                AND THEN D(AS_NAME, CONSTRAINT).TY =
                                DN_ATTRIBUTE)
                                THEN
            DECLARE
               TYPESET: TYPESET_TYPE;
               IS_TYPE: BOOLEAN;
            BEGIN
               EVAL_ATTRIBUTE(CONSTRAINT, TYPESET,
                                        IS_TYPE);
               CONSTRAINT := RESOLVE_ATTRIBUTE(
                                        CONSTRAINT);
               IF IS_EMPTY(TYPESET) AND NOT IS_TYPE THEN
                  CONSTRAINT := TREE_VOID;
               END IF;
               D(AS_CONSTRAINT, EXP, CONSTRAINT);
            END;
         END IF;
         CASE CONSTRAINT.TY IS
            WHEN DN_VOID =>
               NULL;
            WHEN CLASS_RANGE =>
               IF TYPE_STRUCT.TY IN CLASS_SCALAR THEN
                  IF CONSTRAINT.TY = DN_RANGE THEN
                     WALK_RANGE
                                                        ( GET_BASE_TYPE(
                                                                TYPE_STRUCT)
                                                        , CONSTRAINT );
                  END IF;
                                        -- $$$$ IS THIS RIGHT FOR A RANGE ATTRIBUTE?
                  IF NEW_TYPE_SPEC.TY IN
                                                        CLASS_PRIVATE_SPEC THEN
                     NEW_TYPE_SPEC := D(
                                                        SM_TYPE_SPEC,
                                                        NEW_TYPE_SPEC);
                  ELSIF NEW_TYPE_SPEC.TY =
                                                        DN_INCOMPLETE THEN
                     NEW_TYPE_SPEC := D(
                                                        XD_FULL_TYPE_SPEC,
                                                        NEW_TYPE_SPEC);
                  END IF;
                  D(SM_TYPE_SPEC, CONSTRAINT,
                                                NEW_TYPE_SPEC);
               
                  NEW_TYPE_SPEC := COPY_NODE(
                                                TYPE_STRUCT);
                  D(SM_RANGE, NEW_TYPE_SPEC,
                                                CONSTRAINT);
                  D(SM_DERIVED, NEW_TYPE_SPEC,
                                                TREE_VOID);
               ELSE
                  ERROR(D(LX_SRCPOS,CONSTRAINT),
                                                "RANGE CONSTRAINT NOT ALLOWED");
               END IF;
            WHEN DN_FIXED_CONSTRAINT =>
               IF TYPE_STRUCT.TY = DN_FIXED THEN
                  DECLARE
                     RANGE_NODE: TREE := D(
                                                        AS_RANGE,
                                                        CONSTRAINT);
                     EXP: TREE := D(AS_EXP,
                                                        CONSTRAINT);
                     TYPESET: TYPESET_TYPE;
                     ACCURACY: TREE;
                  BEGIN
                     D(SM_TYPE_SPEC, CONSTRAINT,
                                                        GET_BASE_TYPE(
                                                                NEW_TYPE_SPEC));
                     NEW_TYPE_SPEC := COPY_NODE(
                                                        NEW_TYPE_SPEC);
                     D(SM_DERIVED,
                                                        NEW_TYPE_SPEC,
                                                        TREE_VOID);
                     EVAL_EXP_TYPES(EXP,
                                                        TYPESET);
                     REQUIRE_REAL_TYPE(EXP,
                                                        TYPESET);
                     REQUIRE_UNIQUE_TYPE(EXP,
                                                        TYPESET);
                     EXP := RESOLVE_EXP(EXP,
                                                        TYPESET);
                     D(AS_EXP, CONSTRAINT, EXP);
                     ACCURACY :=
                                                        GET_STATIC_VALUE(
                                                        EXP);
                     IF ACCURACY = TREE_VOID THEN
                        ERROR(D(LX_SRCPOS,
                                                                        EXP),
                                                                "STATIC DELTA REQUIRED");
                     ELSE
                        D(SM_ACCURACY,
                                                                NEW_TYPE_SPEC,
                                                                ACCURACY);
                     END IF;
                  
                     IF D(AS_RANGE, CONSTRAINT) /=
                                                                TREE_VOID THEN
                        WALK_RANGE
                                                                (
                                                                GET_BASE_TYPE(
                                                                        TYPE_STRUCT)
                                                                ,
                                                                RANGE_NODE );
                        D(SM_RANGE,
                                                                NEW_TYPE_SPEC,
                                                                RANGE_NODE);
                     END IF;
                  END;
               ELSE
                  ERROR(D(LX_SRCPOS,CONSTRAINT),
                                                "FIXED CONSTRAINT NOT ALLOWED");
               END IF;
         
            WHEN DN_FLOAT_CONSTRAINT =>
               IF TYPE_STRUCT.TY = DN_FLOAT THEN
                  DECLARE
                     RANGE_NODE: TREE := D(
                                                        AS_RANGE,
                                                        CONSTRAINT);
                     EXP: TREE := D(AS_EXP,
                                                        CONSTRAINT);
                     TYPESET: TYPESET_TYPE;
                     ACCURACY: TREE;
                  BEGIN
                     D(SM_TYPE_SPEC, CONSTRAINT,
                                                        GET_BASE_TYPE(
                                                                NEW_TYPE_SPEC));
                     NEW_TYPE_SPEC := COPY_NODE(
                                                        NEW_TYPE_SPEC);
                     D(SM_DERIVED,
                                                        NEW_TYPE_SPEC,
                                                        TREE_VOID);
                     EVAL_EXP_TYPES(EXP,
                                                        TYPESET);
                     REQUIRE_INTEGER_TYPE(EXP,
                                                        TYPESET);
                     REQUIRE_UNIQUE_TYPE(EXP,
                                                        TYPESET);
                     EXP := RESOLVE_EXP(EXP,
                                                        TYPESET);
                     D(AS_EXP, CONSTRAINT, EXP);
                     ACCURACY :=
                                                        GET_STATIC_VALUE(
                                                        EXP);
                     IF ACCURACY = TREE_VOID THEN
                        ERROR(D(LX_SRCPOS,
                                                                        EXP),
                                                                "STATIC DIGITS REQUIRED");
                     ELSE
                        D(SM_ACCURACY,
                                                                NEW_TYPE_SPEC,
                                                                ACCURACY);
                     END IF;
                  
                     IF D(AS_RANGE, CONSTRAINT) /=
                                                                TREE_VOID THEN
                        WALK_RANGE
                                                                (
                                                                GET_BASE_TYPE(
                                                                        TYPE_STRUCT)
                                                                ,
                                                                RANGE_NODE );
                        D(SM_RANGE,
                                                                NEW_TYPE_SPEC,
                                                                RANGE_NODE);
                     END IF;
                  END;
               ELSE
                  ERROR(D(LX_SRCPOS,CONSTRAINT),
                                                "FLOAT CONSTRAINT NOT ALLOWED");
                                        --    D(SM_DERIVED, NEW_TYPE_SPEC, CONST_VOID);
               END IF;
         
            WHEN DN_GENERAL_ASSOC_S =>
            
                                -- FOR A RECORD OR PRIVATE TYPE (MUST BE DISCRIMINANT CONSTRAINT)
               IF DESIG_STRUCT.TY = DN_RECORD
                                                OR ELSE DESIG_STRUCT.TY IN
                                                CLASS_PRIVATE_SPEC
                                                OR ELSE DESIG_STRUCT.TY =
                                                DN_INCOMPLETE THEN
               
                  NEW_TYPE_SPEC :=
                                                MAKE_CONSTRAINED_RECORD
                                                ( SM_NORMALIZED_DSCRMT_S =>
                                                WALK_DISCRMT_CONSTRAINT
                                                ( DESIG_STRUCT, CONSTRAINT )
                                                , XD_SOURCE_NAME => D(
                                                        XD_SOURCE_NAME,
                                                        DESIG_STRUCT)
                                                , SM_BASE_TYPE =>
                                                GET_BASE_STRUCT(
                                                        DESIG_STRUCT) );
               
                  CONSTRAINT :=
                                                MAKE_DSCRMT_CONSTRAINT
                                                ( LX_SRCPOS => D(
                                                        LX_SRCPOS,
                                                        CONSTRAINT)
                                                , AS_GENERAL_ASSOC_S =>
                                                CONSTRAINT );
                  D(AS_CONSTRAINT, EXP, CONSTRAINT);
               
                                        -- FOR AN ARRAY TYPE (MUST BE INDEX CONSTRAINT)
               ELSIF DESIG_STRUCT.TY = DN_ARRAY THEN
                  DECLARE
                     DISCRETE_RANGE_LIST:
                                                        SEQ_TYPE := LIST(
                                                        CONSTRAINT);
                     DISCRETE_RANGE: TREE;
                     INDEX_LIST: SEQ_TYPE :=
                                                        LIST(D(SM_INDEX_S,
                                                                DESIG_STRUCT));
                     INDEX: TREE;
                     TYPESET: TYPESET_TYPE;
                     NEW_RANGE_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                     SCALAR_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                  BEGIN
                                                -- FOR EACH MATCHING INDEX
                     WHILE NOT IS_EMPTY(
                                                                INDEX_LIST)
                                                                AND NOT
                                                                IS_EMPTY(
                                                                DISCRETE_RANGE_LIST) LOOP
                        POP(INDEX_LIST,
                                                                INDEX);
                        POP(
                                                                DISCRETE_RANGE_LIST,
                                                                DISCRETE_RANGE);
                     
                                                        -- EVAL AND RESOLVE THE DISCRETE RANGE
                        EVAL_DISCRETE_RANGE(
                                                                DISCRETE_RANGE,
                                                                TYPESET);
                        REQUIRE_TYPE
                                                                (
                                                                GET_BASE_TYPE(
                                                                        D(
                                                                                SM_TYPE_SPEC,
                                                                                INDEX))
                                                                ,
                                                                DISCRETE_RANGE
                                                                , TYPESET );
                        DISCRETE_RANGE :=
                                                                RESOLVE_DISCRETE_RANGE
                                                                (
                                                                DISCRETE_RANGE,
                                                                GET_THE_TYPE(
                                                                        TYPESET) );
                        NEW_RANGE_LIST :=
                                                                APPEND
                                                                (
                                                                NEW_RANGE_LIST,
                                                                DISCRETE_RANGE );
                     
                                                        -- CONSTRUCT SUBTYPE FOR THIS INDEX AND ADD TO SCALAR_S
                        SCALAR_LIST :=
                                                                APPEND
                                                                (
                                                                SCALAR_LIST
                                                                ,
                                                                GET_SUBTYPE_OF_DISCRETE_RANGE
                                                                (
                                                                        DISCRETE_RANGE ) );
                     END LOOP;
                  
                                                -- CHECK FOR DIMENSION MISMATCH
                     IF NOT IS_EMPTY(
                                                                INDEX_LIST) THEN
                        ERROR(D(LX_SRCPOS,
                                                                        CONSTRAINT),
                                                                "TOO FEW ELEMENTS IN INDEX CONSTRAINT");
                     ELSIF NOT IS_EMPTY(
                                                                DISCRETE_RANGE_LIST) THEN
                        ERROR(D(LX_SRCPOS,
                                                                        HEAD(
                                                                                DISCRETE_RANGE_LIST)),
                                                                "TOO MANY ELEMENTS IN INDEX CONSTRAINT");
                     END IF;
                  
                                                -- CONSTRUCT INDEX CONSTRAINT WITH RESOLVED EXPRESSIONS
                     CONSTRAINT :=
                                                        MAKE_INDEX_CONSTRAINT
                                                        (
                                                        AS_DISCRETE_RANGE_S =>
                                                        MAKE_DISCRETE_RANGE_S
                                                        ( LIST =>
                                                                NEW_RANGE_LIST
                                                                ,
                                                                LX_SRCPOS =>
                                                                D(
                                                                        LX_SRCPOS,
                                                                        CONSTRAINT) )
                                                        , LX_SRCPOS => D(
                                                                LX_SRCPOS,
                                                                CONSTRAINT) );
                     D(AS_CONSTRAINT, EXP,
                                                        CONSTRAINT);
                  
                                                -- MAKE NEW CONSTRAINED ARRAY SUBTYPE
                     NEW_TYPE_SPEC :=
                                                        MAKE_CONSTRAINED_ARRAY
                                                        (
                                                        SM_INDEX_SUBTYPE_S =>
                                                        MAKE_SCALAR_S
                                                        ( LIST =>
                                                                SCALAR_LIST )
                                                        , SM_BASE_TYPE =>
                                                        D(SM_BASE_TYPE,
                                                                DESIG_STRUCT)
                                                        , XD_SOURCE_NAME
                                                        => D(
                                                                XD_SOURCE_NAME,
                                                                DESIG_STRUCT) );
                  END;
               
               ELSE
                  ERROR(D(LX_SRCPOS,CONSTRAINT)
                                                ,
                                                "INDEX OR DISCRIMINANT CONSTRAINT NOT ALLOWED");
               END IF;
            
                                -- IF TYPE MARK WAS AN ACCESS TYPE
               IF TYPE_STRUCT.TY = DN_ACCESS THEN
               
                                        -- MAKE CONSTRAINED ACCESS SUBTYPE
                  NEW_TYPE_SPEC :=
                                                MAKE_CONSTRAINED_ACCESS
                                                ( SM_DESIG_TYPE =>
                                                NEW_TYPE_SPEC
                                                , SM_BASE_TYPE =>
                                                GET_BASE_STRUCT(
                                                        TYPE_STRUCT)
                                                , XD_SOURCE_NAME
                                                => D(XD_SOURCE_NAME,
                                                        TYPE_STRUCT) );
               END IF;
         
            WHEN OTHERS =>
               ERROR(D(LX_SRCPOS,CONSTRAINT),
                                        "NOT VALID AS A CONSTRAINT");
         END CASE;
      
         SUBTYPE_SPEC := NEW_TYPE_SPEC;
      END RESOLVE_SUBTYPE_INDICATION;
   
        ------------------------------------------------------------------------
   
       FUNCTION RESOLVE_EXP(EXP: TREE; TYPESET: TYPESET_TYPE) RETURN TREE IS
         TEMP_TYPESET: TYPESET_TYPE := TYPESET;
      BEGIN
         REQUIRE_UNIQUE_TYPE(EXP, TEMP_TYPESET);
         RETURN RESOLVE_EXP(EXP, GET_THE_TYPE(TEMP_TYPESET));
      END RESOLVE_EXP;
   
        ------------------------------------------------------------------------
   
       FUNCTION RESOLVE_NAME(NAME: TREE; DEFN: TREE) RETURN TREE IS
      BEGIN
         IF NAME.TY = DN_SELECTED THEN
            DECLARE
               DESIGNATOR: TREE := D(AS_DESIGNATOR, NAME);
               PREFIX: TREE;
               PREFIX_DEFSET: DEFSET_TYPE;
               PREFIX_DEFINTERP: DEFINTERP_TYPE;
               PREFIX_TYPESET: TYPESET_TYPE;
               PREFIX_TYPEINTERP: TYPEINTERP_TYPE;
               PREFIX_TYPE: TREE;
               NEW_TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
            BEGIN
               DESIGNATOR := RESOLVE_NAME(DESIGNATOR,
                                        DEFN);
               D(AS_DESIGNATOR, NAME, DESIGNATOR);
               IF DESIGNATOR.TY = DN_USED_OBJECT_ID
                                                OR ELSE DESIGNATOR.TY =
                                                DN_USED_CHAR THEN
                  D(SM_EXP_TYPE, NAME, D(
                                                        SM_EXP_TYPE,
                                                        DESIGNATOR));
               ELSE
                  D(SM_EXP_TYPE, NAME, TREE_VOID);
               END IF;
            
               PREFIX := D(AS_NAME, NAME);
            
                                -- IF THE PREFIX CAN BE AN EXPRESSION
                                -- (OTHERWISE IT IS ALREADY RESOLVED AS A USED NAME)
            	            
               IF PREFIX.TY IN CLASS_USED_OBJECT
                 OR ELSE ( PREFIX.TY = DN_SELECTED AND THEN D( AS_DESIGNATOR, PREFIX).TY IN CLASS_USED_OBJECT )
                 OR ELSE ( PREFIX.TY /= DN_SELECTED AND THEN PREFIX.TY IN CLASS_NAME_EXP )
                THEN
               
                                        -- GET THE TYPE OF THE PREFIX EXPRESSION
                  IF PREFIX.TY = DN_SELECTED
                                                        OR ELSE PREFIX.TY IN
                                                        CLASS_DESIGNATOR THEN
                                                -- IT'S AN ID OR SELECTED ID, LOOK AT NAMES
                     IF DEFN /= TREE_VOID THEN
                        PREFIX_DEFSET :=
                                                                FETCH_DEFSET(
                                                                PREFIX);
                     ELSE
                                                        -- 8/9/90 AVOID CRASH FOR UNDEFINED DESIGNATOR
                        PREFIX_DEFSET :=
                                                                EMPTY_DEFSET;
                     END IF;
                     PREFIX_TYPESET :=
                                                        EMPTY_TYPESET;
                     WHILE NOT IS_EMPTY(
                                                                PREFIX_DEFSET) LOOP
                        POP(PREFIX_DEFSET,
                                                                PREFIX_DEFINTERP);
                        PREFIX_TYPE :=
                                                                GET_BASE_TYPE
                                                                ( D(
                                                                        XD_SOURCE_NAME
                                                                        ,
                                                                        GET_DEF(
                                                                                PREFIX_DEFINTERP)) );
                        ADD_TO_TYPESET
                                                                (
                                                                PREFIX_TYPESET
                                                                ,
                                                                PREFIX_TYPE
                                                                ,
                                                                GET_EXTRAINFO(
                                                                        PREFIX_DEFINTERP) );
                     END LOOP;
                  ELSE
                                                -- IT'S A COMPLEX EXPRESSION, GET SAVED TYPESET
                     PREFIX_TYPESET :=
                                                        FETCH_TYPESET(
                                                        PREFIX);
                  END IF;
               
                                        -- SCAN TYPESET TO REPLACE ACCESSES WITH DESIGNATED TYPES
                  WHILE NOT IS_EMPTY(PREFIX_TYPESET) LOOP
                     POP(PREFIX_TYPESET,
                                                        PREFIX_TYPEINTERP);
                     PREFIX_TYPE :=
                                                        GET_BASE_STRUCT
                                                        ( GET_TYPE(
                                                                PREFIX_TYPEINTERP) );
                     IF PREFIX_TYPE.TY =
                                                                DN_ACCESS THEN
                        PREFIX_TYPE :=
                                                                GET_BASE_STRUCT
                                                                ( D(
                                                                        SM_DESIG_TYPE,
                                                                        PREFIX_TYPE) );
                     END IF;
                     IF DEFN /= TREE_VOID
                                                                AND THEN D(
                                                                XD_REGION,
                                                                DEFN)
                                                                = D(
                                                                XD_SOURCE_NAME,
                                                                PREFIX_TYPE)
                                                                THEN
                        ADD_TO_TYPESET(
                                                                NEW_TYPESET,
                                                                PREFIX_TYPEINTERP);
                     END IF;
                  END LOOP;
                  IF IS_EMPTY(NEW_TYPESET)
                                                        AND THEN DEFN /=
                                                        TREE_VOID THEN
                     ERROR(D(LX_SRCPOS,NAME)
                                                        ,
                                                        "***** NO DEFS FOR PREFIX OF SELECTED");
                  END IF;
                  D(AS_NAME, NAME, RESOLVE_EXP
                                                ( D(AS_NAME,NAME)
                                                        , NEW_TYPESET ));
               END IF;
               RETURN NAME;
            END;
         ELSIF NAME.TY IN CLASS_DESIGNATOR THEN
            D(SM_DEFN, NAME, DEFN);
         
            IF NAME.TY = DN_USED_OBJECT_ID THEN
               IF DEFN.TY IN CLASS_OBJECT_NAME THEN
                  D(SM_EXP_TYPE, NAME, D(
                                                        SM_OBJ_TYPE, DEFN));
                  RETURN NAME;
               ELSE
                  RETURN
                                                MAKE_USED_NAME_ID_FROM_OBJECT(
                                                NAME);
               END IF;
            ELSE
               RETURN NAME;
            END IF;
         
         ELSE
            RETURN NAME;
         END IF;
      END RESOLVE_NAME;
   
        ------------------------------------------------------------------------
   
       FUNCTION WALK_ERRONEOUS_EXP(EXP: TREE) RETURN TREE IS
         DUMMY_TYPESET:	TYPESET_TYPE;
         DUMMY_IS_SUBTYPE: BOOLEAN;
      BEGIN
         EVAL_EXP_SUBTYPE_TYPES(EXP, DUMMY_TYPESET,
                        DUMMY_IS_SUBTYPE);
         RETURN RESOLVE_EXP(EXP, TREE_VOID);
      END WALK_ERRONEOUS_EXP;
   
        ------------------------------------------------------------------------
   
       FUNCTION WALK_DISCRMT_CONSTRAINT
                        ( RECORD_TYPE:		TREE
                        ; GENERAL_ASSOC_S:	TREE )
                        RETURN TREE
                        IS
         ACTUAL_COUNT:	NATURAL := COUNT_AGGREGATE_CHOICES(
                        GENERAL_ASSOC_S);
         AGGREGATE_ARRAY: AGGREGATE_ARRAY_TYPE(1 .. ACTUAL_COUNT);
         NORMALIZED_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         LAST_POSITIONAL: NATURAL := 0;
      BEGIN
         SPREAD_ASSOC_S (GENERAL_ASSOC_S, AGGREGATE_ARRAY);
         WALK_RECORD_DECL_S
                        ( GENERAL_ASSOC_S
                        , D(SM_DISCRIMINANT_S, RECORD_TYPE)
                        , AGGREGATE_ARRAY
                        , NORMALIZED_LIST
                        , LAST_POSITIONAL );
         RESOLVE_RECORD_ASSOC_S(GENERAL_ASSOC_S, AGGREGATE_ARRAY);
         RETURN MAKE_EXP_S(LIST => NORMALIZED_LIST);
      END WALK_DISCRMT_CONSTRAINT;
      
    --|----------------------------------------------------------------------------------------------
   END EXPRESO;
