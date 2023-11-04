SEPARATE ( IDL.SEM_PHASE )
--|----------------------------------------------------------------------------------------------
--|	AGGRESO
--|----------------------------------------------------------------------------------------------
PACKAGE BODY AGGRESO IS
  USE EXP_TYPE, EXPRESO;
  USE VIS_UTIL;
  USE DEF_UTIL;
  USE REQ_UTIL;
   
  TYPE ASSOC_CURSOR_TYPE	IS RECORD
		ASSOC_LIST	: SEQ_TYPE;
		ASSOC	: TREE;
		EXP	: TREE;
		CHOICE_LIST	: SEQ_TYPE;
		CHOICE	: TREE;
		COUNT	: NATURAL;
		FIRST_COUNT	: POSITIVE;
		END RECORD;
   
  PROCEDURE INIT_ASSOC_CURSOR ( ASSOC_CURSOR :OUT ASSOC_CURSOR_TYPE; ASSOC_LIST :SEQ_TYPE );
  PROCEDURE ADVANCE_ASSOC_CURSOR ( ASSOC_CURSOR: IN OUT ASSOC_CURSOR_TYPE );
  FUNCTION  VALUE_IS_IN_CHOICE_S ( VALUE :TREE; CHOICE_S :TREE ) RETURN BOOLEAN;
  PROCEDURE RESOLVE_RECORD_AGGREGATE ( EXP :TREE; TYPE_STRUCT :TREE );
  PROCEDURE RESOLVE_ERRONEOUS_AGGREGATE ( EXP :TREE );
  PROCEDURE RESOLVE_ARRAY_SUBAGGREGATE
                ( EXP:		TREE
                ; COMP_TYPE:	TREE
                ; INDEX_LIST:	SEQ_TYPE
                ; SCALAR_LIST:	IN OUT SEQ_TYPE
                ; NAMED_OTHERS_OK:	BOOLEAN := FALSE );
  PROCEDURE RESOLVE_STRING_SUBAGGREGATE
                ( EXP:		TREE
                ; COMP_TYPE:	TREE
                ; INDEX:		TREE
                ; SCALAR_LIST:	IN OUT SEQ_TYPE );
  PROCEDURE MAKE_NORMALIZED_LIST
                ( AGGREGATE_ARRAY: IN OUT AGGREGATE_ARRAY_TYPE
                ; NORMALIZED_LIST: OUT SEQ_TYPE );
   
        -- $$$$ SHOULDN'T BE HERE
  FUNCTION GET_SUBTYPE_OF_ID (ID: TREE) RETURN TREE IS
                -- GETS SUBTYPE CORRESPONDING TO COMPONENT ID
         RESULT: TREE := D(SM_OBJ_TYPE, ID);
  BEGIN
    IF RESULT.TY IN DN_PRIVATE .. DN_L_PRIVATE THEN
      RESULT := D(SM_TYPE_SPEC, RESULT);
    ELSIF RESULT.TY = DN_INCOMPLETE
       AND THEN D(XD_FULL_TYPE_SPEC, RESULT) /= TREE_VOID THEN
       RESULT := D(XD_FULL_TYPE_SPEC, RESULT);
    END IF;
    RETURN RESULT;
  END;
--|-------------------------------------------------------------------------------------------------
      --|
       PROCEDURE INIT_ASSOC_CURSOR
                        ( ASSOC_CURSOR: 	OUT ASSOC_CURSOR_TYPE
                        ; ASSOC_LIST:		SEQ_TYPE )
                        IS
                -- INITIALIZE CUMULATIVE FIELDS OF ASSOC_CURSOR RECORD
      BEGIN
         ASSOC_CURSOR.ASSOC_LIST := ASSOC_LIST;
         ASSOC_CURSOR.CHOICE_LIST := (TREE_NIL,TREE_NIL);
         ASSOC_CURSOR.COUNT := 0;
      END INIT_ASSOC_CURSOR;
   
       PROCEDURE ADVANCE_ASSOC_CURSOR (ASSOC_CURSOR: IN OUT
                        ASSOC_CURSOR_TYPE) IS
                -- ADVANCE ASSOC_CURSOR TO NEXT CHOICE
      BEGIN
      
                -- IF THERE ARE REMAINING CHOICES IN CURRENT CHOICE LIST
         IF NOT IS_EMPTY(ASSOC_CURSOR.CHOICE_LIST) THEN
         
                        -- STEP TO THE NEXT ONE
            POP(ASSOC_CURSOR.CHOICE_LIST, ASSOC_CURSOR.CHOICE);
            ASSOC_CURSOR.COUNT := ASSOC_CURSOR.COUNT + 1;
         
                        -- ELSE IF THERE ARE REMAINING ASSOCIATIONS
         ELSIF NOT IS_EMPTY (ASSOC_CURSOR.ASSOC_LIST) THEN
         
                        -- STEP TO THE NEXT ASSOCIATION
            POP(ASSOC_CURSOR.ASSOC_LIST, ASSOC_CURSOR.ASSOC);
            ASSOC_CURSOR.COUNT := ASSOC_CURSOR.COUNT + 1;
            ASSOC_CURSOR.FIRST_COUNT := ASSOC_CURSOR.COUNT;
         
                        -- IF IT IS A NAMED ASSOCIATION
            IF ASSOC_CURSOR.ASSOC.TY = DN_NAMED THEN
            
                                -- SAVE THE EXPRESSION
               ASSOC_CURSOR.EXP := D(AS_EXP,
                                        ASSOC_CURSOR.ASSOC);
            
                                -- GET THE LIST OF CHOICES
               ASSOC_CURSOR.CHOICE_LIST
                                        := LIST(D(AS_CHOICE_S,
                                                ASSOC_CURSOR.ASSOC));
            
                                -- STEP TO THE FIRST CHOICE
               POP(ASSOC_CURSOR.CHOICE_LIST,
                                        ASSOC_CURSOR.CHOICE);
            
                                -- ELSE -- SINCE IT IS NOT A NAMED ASSOCIATION
            ELSE
            
                                -- SAVE THE EXPRESSION
               ASSOC_CURSOR.EXP := ASSOC_CURSOR.ASSOC;
            
                                -- SET CHOICE TO VOID
               ASSOC_CURSOR.CHOICE := TREE_VOID;
            
                                -- ELSE -- SINCE THERE ARE NO MORE ASSOCIATIONS
            END IF;
         ELSE
         
                        -- SET THE .ASSOC FIELD TO VOID TO INDICATE TERMINATION
            ASSOC_CURSOR.ASSOC := TREE_VOID;
         END IF;
      END ADVANCE_ASSOC_CURSOR;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION COUNT_AGGREGATE_CHOICES(ASSOC_S: TREE) RETURN NATURAL IS
                -- COUNT THE NUMBER OF DISTINCT CHOICES IN A LIST OF ASSOCIATIONS
                -- ... (EITHER IN A DISCRIMINANT CONSTRAINT OR AN AGGREGATE)
      
         ASSOC_CURSOR:	ASSOC_CURSOR_TYPE;
      BEGIN
      
                -- STEP THROUGH CHOICES
         INIT_ASSOC_CURSOR(ASSOC_CURSOR, LIST(ASSOC_S));
         LOOP
            ADVANCE_ASSOC_CURSOR(ASSOC_CURSOR);
            EXIT
                                WHEN ASSOC_CURSOR.ASSOC = TREE_VOID;
         END LOOP;
      
                -- RETURN THE COUNT FROM THE CURSOR
         RETURN ASSOC_CURSOR.COUNT;
      END COUNT_AGGREGATE_CHOICES;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE SPREAD_ASSOC_S
                        ( ASSOC_S:		TREE
                        ; AGGREGATE_ARRAY:	IN OUT AGGREGATE_ARRAY_TYPE )
                        IS
                -- SPREAD ELEMENTS OF AN ASSOC_S FOR AN AGGREGATE INTO
                -- ... AN AGGREGATE ARRAY (WHICH IS KNOWN TO BE OF CORRECT SIZE).
      
         ASSOC_CURSOR: ASSOC_CURSOR_TYPE;
      BEGIN
      
                -- FOR EACH ARRAY ELEMENT AND CORRESPONDING CHOICE
         INIT_ASSOC_CURSOR(ASSOC_CURSOR, LIST(ASSOC_S));
         FOR I IN AGGREGATE_ARRAY'RANGE LOOP
            ADVANCE_ASSOC_CURSOR(ASSOC_CURSOR);
         
                        -- FILL IN FIELDS OF AGGREGATE_ARRAY
            AGGREGATE_ARRAY(I).FIRST :=
                                ASSOC_CURSOR.FIRST_COUNT;
            AGGREGATE_ARRAY(I).CHOICE := ASSOC_CURSOR.CHOICE;
            AGGREGATE_ARRAY(I).SEEN := FALSE;
            AGGREGATE_ARRAY(I).RESOLVED := FALSE;
            AGGREGATE_ARRAY(I).ID := TREE_VOID;
         
                        -- FILL IN EXP AND EVALUATE TYPES FOR FIRST CHOICE OF ASSOC
            IF I = ASSOC_CURSOR.FIRST_COUNT THEN
               AGGREGATE_ARRAY(I).ASSOC :=
                                        ASSOC_CURSOR.ASSOC;
               AGGREGATE_ARRAY(I).EXP := ASSOC_CURSOR.EXP;
               EVAL_EXP_TYPES
                                        ( AGGREGATE_ARRAY(I).EXP
                                        , AGGREGATE_ARRAY(I).TYPESET );
            END IF;
         END LOOP;
      
      END SPREAD_ASSOC_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE WALK_RECORD_DECL_S
                        ( EXP:			TREE
                        ; DECL_S:		TREE
                        ; AGGREGATE_ARRAY:	IN OUT AGGREGATE_ARRAY_TYPE
                        ; NORMALIZED_LIST:	IN OUT SEQ_TYPE
                        ; LAST_POSITIONAL:	IN OUT NATURAL )
                        IS
                -- WALK ONE SEQUENCE OF COMPONENT DECLARATIONS FOR A RECORD
                -- (THERE IS ONE SUCH FOR DISCRIMINANTS AND ONE FOR COMP_LIST)
      
         PARAM_CURSOR:	PARAM_CURSOR_TYPE;
         NAMED_SUB:	NATURAL;
         CHOICE: 	TREE;
      BEGIN
      
                -- FOR EACH COMPONENT DECLARED IN THE DECL_S
         INIT_PARAM_CURSOR(PARAM_CURSOR, LIST(DECL_S));
         LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            EXIT
                                WHEN PARAM_CURSOR.ID = TREE_VOID;
         
                        -- IF IT MATCHES A POSITIONAL PARAMETER
            IF LAST_POSITIONAL < AGGREGATE_ARRAY'LAST
                                        AND THEN AGGREGATE_ARRAY(
                                        LAST_POSITIONAL + 1).CHOICE =
                                        TREE_VOID
                                        THEN
            
                                -- MARK POSITIONAL PARAMETER SEEN
               LAST_POSITIONAL := LAST_POSITIONAL + 1;
               AGGREGATE_ARRAY(LAST_POSITIONAL).SEEN :=
                                        TRUE;
               AGGREGATE_ARRAY(LAST_POSITIONAL).RESOLVED :=
                                        TRUE;
               AGGREGATE_ARRAY(LAST_POSITIONAL).ID :=
                                        PARAM_CURSOR.ID;
            
                                -- CHECK TYPE AND RESOLVE EXPRESSION
               REQUIRE_TYPE
                                        ( GET_BASE_TYPE(PARAM_CURSOR.ID)
                                        , AGGREGATE_ARRAY(LAST_POSITIONAL).
                                        EXP
                                        , AGGREGATE_ARRAY(LAST_POSITIONAL).
                                        TYPESET );
               AGGREGATE_ARRAY(LAST_POSITIONAL).EXP :=
                                        RESOLVE_EXP_OR_AGGREGATE
                                        ( AGGREGATE_ARRAY(LAST_POSITIONAL).
                                        EXP
                                        , GET_SUBTYPE_OF_ID(
                                                PARAM_CURSOR.ID)
                                        , NAMED_OTHERS_OK => TRUE );
            
                                -- ADD EXPRESSION TO NORMALIZED LIST
               NORMALIZED_LIST := APPEND
                                        ( NORMALIZED_LIST
                                        , AGGREGATE_ARRAY(LAST_POSITIONAL).
                                        EXP );
            
                                -- ELSE -- SINCE NO MORE POSITIONAL PARAMETERS
            ELSE
            
                                -- SEARCH FOR MATCHING NAME
               NAMED_SUB := LAST_POSITIONAL;
               LOOP
                  NAMED_SUB := NAMED_SUB + 1;
                  EXIT
                                                WHEN NAMED_SUB >
                                                AGGREGATE_ARRAY'LAST;
                  CHOICE := AGGREGATE_ARRAY(
                                                NAMED_SUB).CHOICE;
                  EXIT
                                                WHEN CHOICE.TY =
                                                DN_CHOICE_OTHERS;
                  EXIT
                                                WHEN NOT AGGREGATE_ARRAY(
                                                NAMED_SUB).SEEN
                                                AND THEN CHOICE.TY =
                                                DN_CHOICE_EXP
                                                AND THEN D(AS_EXP,
                                                        CHOICE).TY IN
                                                CLASS_DESIGNATOR
                                                AND THEN D(LX_SYMREP, D(
                                                        AS_EXP,CHOICE))
                                                = D(LX_SYMREP,
                                                PARAM_CURSOR.ID);
               END LOOP;
            
                                -- IF MATCH WAS FOUND
               IF NAMED_SUB <= AGGREGATE_ARRAY'LAST THEN
               
                                        -- MARK NAMED PARAMETER SEEN
                  AGGREGATE_ARRAY(NAMED_SUB).SEEN :=
                                                TRUE;
                  AGGREGATE_ARRAY(NAMED_SUB).ID :=
                                                PARAM_CURSOR.ID;
               
                                        -- REPLACE CHOICE_EXP EXPRESSION WITH USED_NAME_ID
                  IF AGGREGATE_ARRAY(NAMED_SUB).
                                                        CHOICE.TY =
                                                        DN_CHOICE_EXP
                                                        THEN
                     D(AS_EXP, AGGREGATE_ARRAY(
                                                                NAMED_SUB).
                                                        CHOICE
                                                        ,
                                                        MAKE_USED_NAME_ID_FROM_OBJECT
                                                        ( D(AS_EXP
                                                                        ,
                                                                        AGGREGATE_ARRAY(
                                                                                NAMED_SUB).
                                                                        CHOICE)));
                     D(SM_DEFN, D(AS_EXP,
                                                                AGGREGATE_ARRAY(
                                                                        NAMED_SUB).
                                                                CHOICE)
                                                        , PARAM_CURSOR.ID );
                  END IF;
               
                                        -- CHECK TYPE (FOR FIRST CHOICE OF AN ASSOCIATION)
                                        -- ... (NOTE. GIVES ERROR IF CONFLICTING TYPES IN ASSOC)
                  NAMED_SUB := AGGREGATE_ARRAY(
                                                NAMED_SUB).FIRST;
                  REQUIRE_TYPE
                                                ( GET_BASE_TYPE(
                                                        PARAM_CURSOR.ID)
                                                , AGGREGATE_ARRAY(
                                                        NAMED_SUB).EXP
                                                , AGGREGATE_ARRAY(
                                                        NAMED_SUB).
                                                TYPESET );
               
                                        -- RESOLVE, IF THIS EXP NOT ALREADY RESOLVED
                  IF NOT AGGREGATE_ARRAY(NAMED_SUB).
                                                        RESOLVED THEN
                     AGGREGATE_ARRAY(NAMED_SUB).
                                                        EXP
                                                        :=
                                                        RESOLVE_EXP_OR_AGGREGATE
                                                        ( AGGREGATE_ARRAY(
                                                                NAMED_SUB).
                                                        EXP
                                                        ,
                                                        GET_SUBTYPE_OF_ID(
                                                                PARAM_CURSOR.ID)
                                                        , NAMED_OTHERS_OK =>
                                                        TRUE );
                     AGGREGATE_ARRAY(NAMED_SUB).
                                                        RESOLVED := TRUE;
                  END IF;
               
                                        -- ADD EXPRESSION TO NORMALIZED LIST
                  NORMALIZED_LIST := APPEND
                                                ( NORMALIZED_LIST
                                                , AGGREGATE_ARRAY(
                                                        NAMED_SUB).EXP );
               
                                        -- ELSE -- SINCE NO MATCH WAS FOUND
               ELSE
               
                                        -- INDICATE ERROR
                  ERROR(D(LX_SRCPOS,EXP)
                                                ,
                                                "NO VALUE FOR COMPONENT - "
                                                & PRINT_NAME ( D(LX_SYMREP,
                                                                PARAM_CURSOR.ID)) );
               END IF;
            END IF;
         END LOOP;
      END WALK_RECORD_DECL_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_RECORD_ASSOC_S
                        ( ASSOC_S:		TREE
                        ; AGGREGATE_ARRAY:	IN OUT AGGREGATE_ARRAY_TYPE )
                        IS
                -- RESOLVE ELEMENTS OF AN ASSOC_S FOR AN AGGREGATE
                -- ... (INDIVIDUAL EXPRESSIONS HAVE BEEN RESOLVED)
      
         NEW_ASSOC: TREE;
         NEW_ASSOC_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      BEGIN
      
                -- FOR EACH ARRAY ELEMENT AND CORRESPONDING CHOICE
         FOR I IN AGGREGATE_ARRAY'RANGE LOOP
         
                        -- IF ELEMENT IS FIRST CHOICE OF AN ASSOCIATION
            IF I = AGGREGATE_ARRAY(I).FIRST THEN
            
                                -- MAKE SURE THAT EXPRESSION HAS BEEN RESOLVED
               IF NOT AGGREGATE_ARRAY(I).RESOLVED THEN
                  AGGREGATE_ARRAY(I).EXP :=
                                                RESOLVE_EXP
                                                ( AGGREGATE_ARRAY(I).EXP
                                                , TREE_VOID );
               
                                        -- REPLACE RESOLVED EXPRESSION
               END IF;
               IF AGGREGATE_ARRAY(I).CHOICE = TREE_VOID THEN
                  NEW_ASSOC := AGGREGATE_ARRAY(I).
                                                EXP;
               ELSE
                  NEW_ASSOC := AGGREGATE_ARRAY(I).
                                                ASSOC;
                  D(AS_EXP, NEW_ASSOC,
                                                AGGREGATE_ARRAY(I).EXP);
               END IF;
            
                                -- ADD ASSOCIATION TO NEW LIST;
               NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                        NEW_ASSOC);
            END IF;
         
                        -- CHECK THAT CHOICE EXISTED IN TYPE
            IF NOT AGGREGATE_ARRAY(I).SEEN THEN
               IF AGGREGATE_ARRAY(I).CHOICE = TREE_VOID THEN
                  ERROR(D(LX_SRCPOS,NEW_ASSOC),
                                                "NO MATCHING COMPONENT");
               ELSIF AGGREGATE_ARRAY(I).CHOICE.TY =
                                                DN_CHOICE_EXP THEN
                  IF D(AS_EXP, AGGREGATE_ARRAY(
                                                                        I).
                                                                CHOICE).TY
                                                        =
                                                        DN_USED_OBJECT_ID
                                                        THEN
                     ERROR(D(LX_SRCPOS,
                                                                AGGREGATE_ARRAY(
                                                                        I).
                                                                CHOICE)
                                                        ,
                                                        "NO MATCHING COMPONENT FOR - "
                                                        & PRINT_NAME ( D(
                                                                        LX_SYMREP
                                                                        ,
                                                                        D(
                                                                                AS_EXP,
                                                                                AGGREGATE_ARRAY(
                                                                                        I).
                                                                                CHOICE) )));
                  ELSE
                     ERROR(D(LX_SRCPOS,
                                                                AGGREGATE_ARRAY(
                                                                        I).
                                                                CHOICE)
                                                        ,
                                                        "SIMPLE NAME REQUIRED");
                  END IF;
               ELSIF AGGREGATE_ARRAY(I).CHOICE.TY =
                                                DN_CHOICE_EXP THEN
                  ERROR(D(LX_SRCPOS,AGGREGATE_ARRAY(
                                                                I).CHOICE)
                                                , "RANGE NOT ALLOWED");
               ELSE -- SINCE KIND(...) = DN_CHOICE_OTHERS
                  ERROR(D(LX_SRCPOS,AGGREGATE_ARRAY(
                                                                I).CHOICE)
                                                ,
                                                "NO MATCHING COMPONENT FOR OTHERS");
               END IF;
            END IF;
         END LOOP;
      
                -- INSERT RESOLVED LIST IN ASSOC_S
         LIST(ASSOC_S, NEW_ASSOC_LIST);
      END RESOLVE_RECORD_ASSOC_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION RESOLVE_EXP_OR_AGGREGATE
                        ( EXP:			TREE
                        ; SUBTYPE_SPEC: 	TREE
                        ; NAMED_OTHERS_OK:	BOOLEAN )
                        RETURN TREE
                        IS
         SCALAR_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      BEGIN
         IF SUBTYPE_SPEC.TY = DN_CONSTRAINED_ARRAY THEN
                        -- $$$$ NEED TO PASS SUBTYPES OF INDEXES
            IF EXP.TY = DN_AGGREGATE THEN
               RESOLVE_ARRAY_SUBAGGREGATE
                                        ( EXP
                                        , D(SM_COMP_TYPE, GET_BASE_STRUCT(
                                                        SUBTYPE_SPEC))
                                        , LIST(D(SM_INDEX_S,
                                                        GET_BASE_STRUCT(
                                                                SUBTYPE_SPEC)))
                                        , SCALAR_LIST
                                        , NAMED_OTHERS_OK );
               D(SM_EXP_TYPE, EXP, SUBTYPE_SPEC);
            ELSIF EXP.TY = DN_STRING_LITERAL THEN
               RESOLVE_STRING_SUBAGGREGATE
                                        ( EXP
                                        , D(SM_COMP_TYPE, GET_BASE_STRUCT(
                                                        SUBTYPE_SPEC))
                                        , HEAD(LIST(D(SM_INDEX_S
                                                                ,
                                                                GET_BASE_STRUCT(
                                                                        SUBTYPE_SPEC))))
                                        , SCALAR_LIST );
               D(SM_EXP_TYPE, EXP, SUBTYPE_SPEC);
            ELSE
               RETURN RESOLVE_EXP(EXP, GET_BASE_TYPE(
                                                SUBTYPE_SPEC));
            END IF;
         ELSE
            RETURN RESOLVE_EXP(EXP, GET_BASE_TYPE(
                                        SUBTYPE_SPEC));
         END IF;
         RETURN EXP;
      END RESOLVE_EXP_OR_AGGREGATE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_AGGREGATE
                        ( EXP:			TREE
                        ; TYPE_SPEC:		TREE )
                        IS
         TYPE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
         SCALAR_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      BEGIN
         IF TYPE_STRUCT.TY = DN_RECORD THEN
            RESOLVE_RECORD_AGGREGATE(EXP, TYPE_STRUCT);
            D(SM_EXP_TYPE, EXP, TYPE_SPEC);
         ELSIF TYPE_STRUCT.TY = DN_ARRAY THEN
            RESOLVE_ARRAY_SUBAGGREGATE
                                ( EXP
                                , D(SM_COMP_TYPE, GET_BASE_STRUCT(
                                                TYPE_SPEC))
                                , LIST(D(SM_INDEX_S, GET_BASE_STRUCT(
                                                        TYPE_SPEC)))
                                , SCALAR_LIST );
            D(SM_EXP_TYPE, EXP, TYPE_SPEC);
         ELSE
            RESOLVE_ERRONEOUS_AGGREGATE(EXP);
         END IF;
      END RESOLVE_AGGREGATE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_STRING
                        ( EXP:			TREE
                        ; TYPE_SPEC:		TREE )
                        IS
         SCALAR_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         TYPE_STRUCT: TREE := GET_BASE_TYPE(TYPE_SPEC);
         COMP_TYPE: TREE := TREE_VOID;
         INDEX_TYPE: TREE := TREE_VOID;
      BEGIN
         IF TYPE_STRUCT /= TREE_VOID THEN
            COMP_TYPE := D(SM_COMP_TYPE, TYPE_STRUCT);
            INDEX_TYPE := HEAD(LIST(D(SM_INDEX_S, TYPE_STRUCT)));
         END IF;
         RESOLVE_STRING_SUBAGGREGATE
                        ( EXP
                        , GET_BASE_TYPE(COMP_TYPE)
                        , INDEX_TYPE
                        , SCALAR_LIST );
      END RESOLVE_STRING;
--|-------------------------------------------------------------------------------------------------
      --|
       PROCEDURE RESOLVE_ERRONEOUS_AGGREGATE(EXP: TREE) IS
                -- TYPE WRONG FOR AGGREGATE OR UNRESOLVED
                -- CHECK EXPRESSIONS ANYWAY
         GENERAL_ASSOC_S: CONSTANT TREE := D(AS_GENERAL_ASSOC_S,
                        EXP);
         ASSOC_COUNT: NATURAL := COUNT_AGGREGATE_CHOICES(
                        GENERAL_ASSOC_S);
         AGGREGATE_ARRAY: AGGREGATE_ARRAY_TYPE(1..ASSOC_COUNT);
         TEMP_EXP: TREE;
      BEGIN
         D(SM_EXP_TYPE, EXP, TREE_VOID);
         SPREAD_ASSOC_S(GENERAL_ASSOC_S, AGGREGATE_ARRAY);
         FOR I IN AGGREGATE_ARRAY'RANGE LOOP
            IF AGGREGATE_ARRAY(I).FIRST = I THEN
               TEMP_EXP := RESOLVE_EXP(AGGREGATE_ARRAY(I).
                                        EXP, TREE_VOID);
            END IF;
         END LOOP;
      END RESOLVE_ERRONEOUS_AGGREGATE;
--|-------------------------------------------------------------------------------------------------
--|
PROCEDURE RESOLVE_RECORD_AGGREGATE(EXP: TREE; TYPE_STRUCT: TREE) IS
  GENERAL_ASSOC_S	: CONSTANT TREE	:= D ( AS_GENERAL_ASSOC_S, EXP );
  ASSOC_COUNT	: NATURAL	:= COUNT_AGGREGATE_CHOICES ( GENERAL_ASSOC_S );
  AGGREGATE_ARRAY	: AGGREGATE_ARRAY_TYPE ( 1..ASSOC_COUNT );
  LAST_POSITIONAL	: NATURAL	:= 0;
  COMP_LIST	: TREE	:= D ( SM_COMP_LIST, TYPE_STRUCT );
  VARIANT_PART	: TREE;
  NORMALIZED_LIST	: SEQ_TYPE	:= ( TREE_NIL, TREE_NIL );
BEGIN
  D( SM_DISCRETE_RANGE, EXP, TREE_VOID );
      
  SPREAD_ASSOC_S ( GENERAL_ASSOC_S, AGGREGATE_ARRAY );
  WALK_RECORD_DECL_S ( EXP, D( SM_DISCRIMINANT_S, TYPE_STRUCT ), AGGREGATE_ARRAY, NORMALIZED_LIST, LAST_POSITIONAL );
  WHILE COMP_LIST /= TREE_VOID LOOP
    WALK_RECORD_DECL_S ( EXP, D(AS_DECL_S, COMP_LIST), AGGREGATE_ARRAY, NORMALIZED_LIST, LAST_POSITIONAL );
    VARIANT_PART := D( AS_VARIANT_PART, COMP_LIST );
    COMP_LIST := TREE_VOID;
    IF VARIANT_PART /= TREE_VOID THEN
      DECLARE
        DSCRMT_ID	: CONSTANT TREE	:= D( SM_DEFN, D(AS_NAME, VARIANT_PART ) );
        DSCRMT_EXP	: TREE	:= TREE_VOID;
        DSCRMT_VALUE: TREE;
        VARIANT_LIST: SEQ_TYPE	:= LIST ( D( AS_VARIANT_S, VARIANT_PART ) );
        VARIANT	: TREE;
      BEGIN
        FOR I IN AGGREGATE_ARRAY'RANGE LOOP
          IF ( DSCRMT_ID = AGGREGATE_ARRAY(I).ID  AND THEN  DSCRMT_ID /= TREE_VOID )
          OR ELSE AGGREGATE_ARRAY(I).CHOICE.TY = DN_CHOICE_OTHERS
          THEN
            DSCRMT_EXP := AGGREGATE_ARRAY ( AGGREGATE_ARRAY(I).FIRST ).EXP;
            EXIT;
          END IF;
        END LOOP;
        IF DSCRMT_EXP = TREE_VOID THEN
          ERROR ( D ( LX_SRCPOS, EXP ), "$$$$ DSCRMT VALUE NOT FOUND" );
          EXIT;
        END IF;
        DSCRMT_VALUE := GET_STATIC_VALUE ( DSCRMT_EXP );
        IF DSCRMT_VALUE = TREE_VOID THEN
          ERROR ( D( LX_SRCPOS, EXP ), "DSCRMT VALUE MUST BE STATIC (LRM 4.3.1 #2)");
          EXIT;
        END IF;
        WHILE NOT IS_EMPTY ( VARIANT_LIST ) LOOP
          POP ( VARIANT_LIST, VARIANT );
          IF VARIANT.TY = DN_VARIANT THEN
            IF VALUE_IS_IN_CHOICE_S ( DSCRMT_VALUE, D( AS_CHOICE_S, VARIANT ) ) THEN
              COMP_LIST := D( AS_COMP_LIST, VARIANT );
              EXIT;
            END IF;
          END IF;
        END LOOP;
        IF COMP_LIST = TREE_VOID THEN
          ERROR ( D( LX_SRCPOS, EXP ), "NO VARIANT FOR DSCRMT VALUE " & PRINT_NAME ( D( LX_SYMREP, DSCRMT_EXP ) ) );
          EXIT;
        END IF;
      END;
    END IF;
  END LOOP;
  RESOLVE_RECORD_ASSOC_S(GENERAL_ASSOC_S, AGGREGATE_ARRAY);
         
  DECLARE
    GAS	: TREE	:= MAKE ( DN_GENERAL_ASSOC_S );
  BEGIN
    LIST ( GAS, NORMALIZED_LIST );
    D( LX_SRCPOS, GAS, TREE_VOID );
    D( SM_NORMALIZED_COMP_S, EXP, GAS );
  END;
         
END RESOLVE_RECORD_AGGREGATE;
--|-------------------------------------------------------------------------------------------------
--|
FUNCTION VALUE_IS_IN_CHOICE_S ( VALUE :TREE; CHOICE_S :TREE ) RETURN BOOLEAN IS
      
  USE UARITH;
      
  CHOICE_LIST	: SEQ_TYPE	:= LIST(CHOICE_S);
  CHOICE	: TREE;
BEGIN
  WHILE NOT IS_EMPTY( CHOICE_LIST ) LOOP
    POP ( CHOICE_LIST, CHOICE );
    CASE CHOICE.TY IS
    WHEN DN_CHOICE_EXP =>
      IF U_EQUAL ( GET_STATIC_VALUE ( D( AS_EXP, CHOICE ) ), VALUE ) THEN
        RETURN TRUE;
      END IF;
    WHEN DN_CHOICE_RANGE =>
      IF U_MEMBER ( VALUE, D( AS_DISCRETE_RANGE, CHOICE ) ) THEN
        RETURN TRUE;
      END IF;
    WHEN DN_CHOICE_OTHERS =>
      RETURN TRUE;
    WHEN OTHERS =>
      NULL;
    END CASE;
  END LOOP;
  RETURN FALSE;
END VALUE_IS_IN_CHOICE_S;
--|-------------------------------------------------------------------------------------------------
      --|
       PROCEDURE RESOLVE_ARRAY_SUBAGGREGATE
                        ( EXP:		TREE
                        ; COMP_TYPE:	TREE
                        ; INDEX_LIST:	SEQ_TYPE
                        ; SCALAR_LIST:	IN OUT SEQ_TYPE
                        ; NAMED_OTHERS_OK:	BOOLEAN := FALSE )
                        IS
         GENERAL_ASSOC_S: TREE := D(AS_GENERAL_ASSOC_S, EXP);
         INDEX:		TREE := HEAD(INDEX_LIST);
         INDEX_TAIL:	SEQ_TYPE := TAIL(INDEX_LIST);
         ASSOC_COUNT:	NATURAL := COUNT_AGGREGATE_CHOICES(
                        GENERAL_ASSOC_S);
         AGGREGATE_ARRAY:AGGREGATE_ARRAY_TYPE(1..ASSOC_COUNT);
         TYPESET:	TYPESET_TYPE;
         NEW_ASSOC_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         CHOICE: 	TREE;
         INDEX_TYPE:	TREE;
         POSITIONAL_SEEN:BOOLEAN := FALSE;
         NAMED_SEEN:	BOOLEAN := FALSE;
         OTHERS_SEEN:	BOOLEAN := FALSE;
         IS_RANGE:	BOOLEAN;
      BEGIN
      
         D(SM_EXP_TYPE, EXP, TREE_VOID);
         D(SM_DISCRETE_RANGE, EXP, TREE_VOID);
      
                -- SPREAD AGGREGATE INTO ARRAY
         SPREAD_ASSOC_S(GENERAL_ASSOC_S, AGGREGATE_ARRAY);
      
                -- RESOLVE SUBEXPRESSIONS
         IF IS_EMPTY(INDEX_TAIL) THEN
            FOR I IN AGGREGATE_ARRAY'RANGE LOOP
               IF AGGREGATE_ARRAY(I).FIRST = I THEN
                  TYPESET := AGGREGATE_ARRAY(I).
                                                TYPESET;
                  REQUIRE_TYPE( GET_BASE_TYPE(
                                                        COMP_TYPE)
                                                , AGGREGATE_ARRAY(I).EXP
                                                , TYPESET);
                  AGGREGATE_ARRAY(I).EXP :=
                                                RESOLVE_EXP_OR_AGGREGATE
                                                ( AGGREGATE_ARRAY(I).EXP
                                                , COMP_TYPE
                                                , NAMED_OTHERS_OK => TRUE );
               END IF;
            END LOOP;
         ELSE
            FOR I IN AGGREGATE_ARRAY'RANGE LOOP
               IF AGGREGATE_ARRAY(I).FIRST = I THEN
                  IF AGGREGATE_ARRAY(I).EXP.TY =
                                                        DN_AGGREGATE THEN
                     RESOLVE_ARRAY_SUBAGGREGATE
                                                        ( AGGREGATE_ARRAY(
                                                                I).EXP
                                                        , COMP_TYPE
                                                        , INDEX_TAIL
                                                        , SCALAR_LIST
                                                        , NAMED_OTHERS_OK );
                  ELSIF AGGREGATE_ARRAY(I).EXP.TY =
                                                        DN_STRING_LITERAL
                                                        AND THEN IS_EMPTY(
                                                        TAIL(INDEX_TAIL))
                                                        AND THEN (
                                                        IS_CHARACTER_TYPE(
                                                                GET_BASE_TYPE(
                                                                        COMP_TYPE))
                                                        OR ELSE COMP_TYPE =
                                                        TREE_VOID )
                                                        THEN
                     RESOLVE_STRING_SUBAGGREGATE
                                                        ( AGGREGATE_ARRAY(
                                                                I).EXP
                                                        , COMP_TYPE
                                                        , HEAD(INDEX_TAIL)
                                                        , SCALAR_LIST );
                  ELSE
                     ERROR(D(LX_SRCPOS,
                                                                AGGREGATE_ARRAY(
                                                                        I).
                                                                EXP)
                                                        ,
                                                        "INVALID FORM FOR SUBAGGREGATE" );
                     EVAL_EXP_TYPES(
                                                        AGGREGATE_ARRAY(I).
                                                        EXP, TYPESET);
                     AGGREGATE_ARRAY(I).EXP :=
                                                        RESOLVE_EXP
                                                        ( AGGREGATE_ARRAY(
                                                                I).EXP,
                                                        TREE_VOID );
                  END IF;
               END IF;
            END LOOP;
         END IF;
      
                -- CONSTRUCT NEW ASSOC LIST
         FOR I IN AGGREGATE_ARRAY'RANGE LOOP
            IF AGGREGATE_ARRAY(I).FIRST = I THEN
               IF AGGREGATE_ARRAY(I).CHOICE = TREE_VOID THEN
                  AGGREGATE_ARRAY(I).ASSOC :=
                                                AGGREGATE_ARRAY(I).EXP;
                  POSITIONAL_SEEN := TRUE;
               ELSE
                  D(AS_EXP, AGGREGATE_ARRAY(I).
                                                ASSOC
                                                , AGGREGATE_ARRAY(I).EXP );
                  IF AGGREGATE_ARRAY(I).CHOICE.TY =
                                                        DN_CHOICE_OTHERS THEN
                     OTHERS_SEEN := TRUE;
                  ELSE
                     NAMED_SEEN := TRUE;
                  END IF;
               END IF;
               NEW_ASSOC_LIST := APPEND
                                        ( NEW_ASSOC_LIST, AGGREGATE_ARRAY(
                                                I).ASSOC );
            END IF;
         END LOOP;
      
                -- REPLACE LIST IN GENERAL_ASSOC_S WITH RESOLVED LIST
         IF POSITIONAL_SEEN THEN
            LIST(GENERAL_ASSOC_S, NEW_ASSOC_LIST);
         END IF;
      
                -- IF A NAMED ASSOCIATION WAS SEEN
         IF NAMED_SEEN THEN
         
            IF POSITIONAL_SEEN THEN
               ERROR(D(LX_SRCPOS,EXP),
                                        "POSITIONAL AND NAMED ASSOCIATIONS NOT ALLOWED");
            ELSIF NOT NAMED_OTHERS_OK
                                        AND OTHERS_SEEN THEN
               ERROR(D(LX_SRCPOS,EXP),
                                        "NAMED ASSOCIATIONS NOT ALLOWED WITH OTHERS");
            END IF;
         
                        -- EVALUATE CHOICES
            IF INDEX.TY = DN_INDEX THEN
                                -- (NOTE.  ANON INDEX BASE TYPE MAY HAVE VOID EXPRESSION)
               INDEX_TYPE := D(SM_TYPE_SPEC, INDEX);
            ELSE
               INDEX_TYPE := INDEX;
            END IF;
            INDEX_TYPE := GET_BASE_TYPE(INDEX_TYPE);
            FOR I IN AGGREGATE_ARRAY'RANGE LOOP
               CHOICE := AGGREGATE_ARRAY(I).CHOICE;
               CASE CHOICE.TY IS
                  WHEN DN_CHOICE_EXP =>
                     EVAL_EXP_SUBTYPE_TYPES
                                                        ( D(AS_EXP, CHOICE),
                                                        TYPESET, IS_RANGE );
                     REQUIRE_TYPE(INDEX_TYPE, D(
                                                                AS_EXP,
                                                                CHOICE),
                                                        TYPESET);
                     IF IS_RANGE THEN
                     
                        DECLARE
                           NEW_CHOICE	: TREE	:= MAKE ( DN_CHOICE_RANGE );
                        BEGIN
                           D( AS_DISCRETE_RANGE, NEW_CHOICE, RESOLVE_DISCRETE_RANGE ( D( AS_EXP, CHOICE ), GET_THE_TYPE ( TYPESET ) ) );
                           D( LX_SRCPOS, NEW_CHOICE, D( LX_SRCPOS, CHOICE ) );
                           CHOICE := NEW_CHOICE;
                        END;	
                     	
                        AGGREGATE_ARRAY(I).
                                                                CHOICE :=
                                                                CHOICE;
                        IF AGGREGATE_ARRAY(
                                                                        I).
                                                                        FIRST =
                                                                        I
                                                                        AND THEN
                                                                        IS_EMPTY(
                                                                        TAIL(
                                                                                LIST(
                                                                                        D(
                                                                                                AS_CHOICE_S
                                                                                                ,
                                                                                                AGGREGATE_ARRAY(
                                                                                                        I).
                                                                                                ASSOC))))
                                                                        THEN
                                                                -- REPLACE SINGLETON LIST
                           LIST(D(
                                                                                AS_CHOICE_S,
                                                                                AGGREGATE_ARRAY(
                                                                                        I).
                                                                                ASSOC)
                                                                        ,
                                                                        SINGLETON(
                                                                                CHOICE) );
                        END IF;
                     ELSE
                        D(AS_EXP
                                                                , CHOICE
                                                                ,
                                                                RESOLVE_EXP(
                                                                        D(
                                                                                AS_EXP,
                                                                                CHOICE) ,
                                                                        TYPESET) );
                     END IF;
                  WHEN DN_CHOICE_RANGE =>
                     EVAL_DISCRETE_RANGE
                                                        ( D(
                                                                AS_DISCRETE_RANGE,
                                                                CHOICE),
                                                        TYPESET );
                     REQUIRE_TYPE( INDEX_TYPE
                                                        , D(
                                                                AS_DISCRETE_RANGE,
                                                                CHOICE)
                                                        , TYPESET);
                     D(AS_DISCRETE_RANGE
                                                        , CHOICE
                                                        ,
                                                        RESOLVE_DISCRETE_RANGE
                                                        ( D(
                                                                        AS_DISCRETE_RANGE,
                                                                        CHOICE)
                                                                ,
                                                                GET_THE_TYPE(
                                                                        TYPESET)));
                  WHEN DN_CHOICE_OTHERS =>
                     NULL;
                  WHEN OTHERS => NULL;
               END CASE;
            END LOOP;
            MAKE_NORMALIZED_LIST(AGGREGATE_ARRAY,
                                NEW_ASSOC_LIST);
            GENERAL_ASSOC_S := COPY_NODE(GENERAL_ASSOC_S);
            LIST(GENERAL_ASSOC_S, NEW_ASSOC_LIST);
         END IF;
      
         D(SM_NORMALIZED_COMP_S
                        , EXP
                        , GENERAL_ASSOC_S );
      
      END RESOLVE_ARRAY_SUBAGGREGATE;
--|-------------------------------------------------------------------------------------------------
      --|
       PROCEDURE RESOLVE_STRING_SUBAGGREGATE
                        ( EXP:		TREE
                        ; COMP_TYPE:	TREE
                        ; INDEX:		TREE
                        ; SCALAR_LIST:	IN OUT SEQ_TYPE )
                        IS
      BEGIN
         D(SM_EXP_TYPE, EXP, TREE_VOID);
         D(SM_DISCRETE_RANGE, EXP, TREE_VOID);
         NULL;
      END RESOLVE_STRING_SUBAGGREGATE;
--|-------------------------------------------------------------------------------------------------
      --|
       PROCEDURE MAKE_NORMALIZED_LIST
                        ( AGGREGATE_ARRAY: IN OUT AGGREGATE_ARRAY_TYPE
                        ; NORMALIZED_LIST: OUT SEQ_TYPE )
                        IS
                -- MAKES NORMALIZED LIST FOR ARRAY AGGREGATE
         AGGREGATE_ITEM: AGGREGATE_ITEM_TYPE;
         NEW_NORMALIZED_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         NON_STATIC_SEEN: BOOLEAN := FALSE;
         CHOICE: TREE;
         RANGE_NODE: TREE;
      BEGIN
         NORMALIZED_LIST := (TREE_NIL,TREE_NIL);
      
                -- FOR EACH CHOICE
         FOR II IN AGGREGATE_ARRAY'RANGE LOOP
         
                        -- MAKE SURE IT HAS ITS OWN 'NAMED' NODE WHICH CAN BE
                        -- MODIFIED IF NECESSARY
            IF AGGREGATE_ARRAY(II).FIRST = II THEN			--| PREMIER CHOICE
            
               IF II < AGGREGATE_ARRAY'LAST AND THEN AGGREGATE_ARRAY( II+1 ).FIRST = II THEN	--| PREMIER MAIS PAS SEUL
                  DECLARE
                     CHOICE_S	: TREE	:= MAKE ( DN_CHOICE_S );
                     NAMED	: TREE	:= MAKE ( DN_NAMED );
                  BEGIN		
                     LIST ( CHOICE_S, SINGLETON ( AGGREGATE_ARRAY( II ).CHOICE ) );
                     D( LX_SRCPOS,	CHOICE_S, D( LX_SRCPOS, AGGREGATE_ARRAY( II ).CHOICE ));
                     D( AS_EXP,	NAMED, D( AS_EXP, AGGREGATE_ARRAY( II ).ASSOC ) );
                     D( AS_CHOICE_S,	NAMED, CHOICE_S);
                     D( LX_SRCPOS,	NAMED, D( LX_SRCPOS, AGGREGATE_ARRAY( II ).ASSOC ) );
                     AGGREGATE_ARRAY(II).ASSOC := NAMED;
                  END;	
               		
               ELSIF				--| PAS PREMIER
                  AGGREGATE_ARRAY(II).CHOICE.TY = DN_CHOICE_RANGE
                  AND THEN D( AS_DISCRETE_RANGE, AGGREGATE_ARRAY( II ).CHOICE).TY = DN_DISCRETE_SUBTYPE
                THEN
                  AGGREGATE_ARRAY(II).ASSOC := COPY_NODE ( AGGREGATE_ARRAY( II ).ASSOC );	--| POURRAIT CHANGER DE TYPE DISCRET À RANGE
               END IF;
            
            ELSE					--| PAS LE PREMIER CHOICE
               DECLARE
                  CHOICE_S	: TREE	:= MAKE ( DN_CHOICE_S );
                  NAMED	: TREE	:= MAKE ( DN_NAMED );
               BEGIN		
                  LIST ( CHOICE_S, SINGLETON ( AGGREGATE_ARRAY( II ).CHOICE ) );
                  D( LX_SRCPOS,	CHOICE_S, D( LX_SRCPOS, AGGREGATE_ARRAY( II ).CHOICE ));
                  D( AS_EXP,	NAMED, D(AS_EXP, AGGREGATE_ARRAY( AGGREGATE_ARRAY( II ).FIRST ).ASSOC ) );
                  D( AS_CHOICE_S,	NAMED, CHOICE_S);
                  D( LX_SRCPOS,	NAMED, D( LX_SRCPOS, AGGREGATE_ARRAY(II).CHOICE ) );
                  AGGREGATE_ARRAY(II).ASSOC := NAMED;
               END;	
            END IF;
         
                        -- REUSE EXP AS VALUE OF STATIC CHOICE
                        -- COMPUTE FIRST STATIC VALUE FOR CHOICE
            CHOICE := AGGREGATE_ARRAY(II).CHOICE;
            IF CHOICE.TY = DN_CHOICE_EXP THEN
                                -- (IT'S A CHOICE_EXP)
               AGGREGATE_ARRAY(II).EXP :=
                                        GET_STATIC_VALUE
                                        ( D(AS_EXP, CHOICE) );
            ELSIF CHOICE.TY = DN_CHOICE_RANGE THEN
                                -- (IT'S A CHOICE_RANGE)
               AGGREGATE_ARRAY(II).EXP := TREE_VOID;
               RANGE_NODE := D(AS_DISCRETE_RANGE, CHOICE);
               IF RANGE_NODE.TY = DN_DISCRETE_SUBTYPE THEN
                                        -- (RANGE GIVEN AS DISCRETE SUBTYPE -- FIND RANGE)
                  RANGE_NODE := D(
                                                AS_SUBTYPE_INDICATION,
                                                RANGE_NODE);
                  IF D(AS_CONSTRAINT, RANGE_NODE) /=
                                                        TREE_VOID THEN
                     RANGE_NODE := D(
                                                        AS_CONSTRAINT,
                                                        RANGE_NODE);
                  ELSE
                     RANGE_NODE := D(AS_NAME,
                                                        RANGE_NODE);
                     IF RANGE_NODE.TY =
                                                                DN_SELECTED THEN
                        RANGE_NODE := D(
                                                                AS_DESIGNATOR,
                                                                RANGE_NODE);
                     END IF;
                     RANGE_NODE := D(SM_DEFN,
                                                        RANGE_NODE);
                     IF RANGE_NODE.TY IN
                                                                CLASS_TYPE_NAME THEN
                        RANGE_NODE := D(
                                                                SM_TYPE_SPEC,
                                                                RANGE_NODE);
                     END IF;
                     IF RANGE_NODE.TY IN
                                                                CLASS_SCALAR THEN
                        RANGE_NODE := D(
                                                                SM_RANGE,
                                                                RANGE_NODE);
                     END IF;
                  END IF;
                  
                  IF RANGE_NODE.TY = DN_RANGE
                     AND THEN GET_STATIC_VALUE( D(AS_EXP1, RANGE_NODE)) /= TREE_VOID
                  	 AND THEN GET_STATIC_VALUE( D(AS_EXP2, RANGE_NODE)) /= TREE_VOID
                  THEN
                     CHOICE := COPY_NODE ( CHOICE );			--| LE SOUS TYPE DISCRET EST STATIQUE, REMPLACER PAR UNE RANGE
                     DECLARE
                        CHOICE_S	: TREE	:= MAKE ( DN_CHOICE_S );
                     BEGIN
                        LIST ( CHOICE_S, SINGLETON ( CHOICE) );
                        D( LX_SRCPOS, CHOICE_S, TREE_VOID );
                        D( AS_CHOICE_S, AGGREGATE_ARRAY(II).ASSOC, CHOICE_S );
                     END;
                     D( AS_DISCRETE_RANGE, CHOICE, RANGE_NODE );
                  END IF;
               END IF;
                                -- GET STATIC VALUE FOR FIRST ELEMENT OF RANGE
               IF RANGE_NODE.TY = DN_RANGE THEN
                  AGGREGATE_ARRAY(II).EXP
                                                := GET_STATIC_VALUE(D(
                                                        AS_EXP1,
                                                        RANGE_NODE));
               ELSE
                  AGGREGATE_ARRAY(II).EXP :=
                                                TREE_VOID;
               END IF;
            ELSIF CHOICE.TY = DN_CHOICE_OTHERS THEN
               AGGREGATE_ARRAY(II).EXP := TREE_VOID;
            ELSE
                                -- (NOT CHOICE_ANYTHING; ERROR MUST HAVE BEEN REPORTED)
               RETURN;
            END IF;
         
                        -- CHECK FOR ILLEGAL NON-STATIC
            IF AGGREGATE_ARRAY(II).EXP = TREE_VOID AND CHOICE.TY /=
                                        DN_CHOICE_OTHERS
                                        AND AGGREGATE_ARRAY'LENGTH > 1 THEN
               NON_STATIC_SEEN := TRUE;
               ERROR( D(LX_SRCPOS,CHOICE),
                                        "CHOICE MUST BE STATIC" );
            END IF;
         
         END LOOP;
      
         IF NON_STATIC_SEEN THEN
            RETURN;
         END IF;
      
                -- SORT THE ENTRIES
         FOR II IN AGGREGATE_ARRAY'FIRST + 1 .. AGGREGATE_ARRAY'
                                LAST LOOP
            EXIT
                                WHEN AGGREGATE_ARRAY(II).EXP = TREE_VOID;
                        -- OTHERS
            FOR JJ IN REVERSE AGGREGATE_ARRAY'FIRST .. II - 1 LOOP
               EXIT
                                        WHEN UARITH."<="
                                        ( AGGREGATE_ARRAY(JJ).EXP
                                        , AGGREGATE_ARRAY(JJ + 1).EXP );
               AGGREGATE_ITEM := AGGREGATE_ARRAY (JJ);
               AGGREGATE_ARRAY (JJ) := AGGREGATE_ARRAY (
                                        JJ + 1);
               AGGREGATE_ARRAY (JJ + 1) := AGGREGATE_ITEM;
            END LOOP;
         END LOOP;
      
                -- CONSTRUCT THE NEW LIST
         FOR II IN AGGREGATE_ARRAY'RANGE LOOP
            NEW_NORMALIZED_LIST := APPEND
                                ( NEW_NORMALIZED_LIST
                                , AGGREGATE_ARRAY(II).ASSOC );
         END LOOP;
      
         NORMALIZED_LIST := NEW_NORMALIZED_LIST;
      END MAKE_NORMALIZED_LIST;
   
--|-------------------------------------------------------------------------------------------------
END AGGRESO;
