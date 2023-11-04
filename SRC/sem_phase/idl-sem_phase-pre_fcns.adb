    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	PRE_FCNS
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY PRE_FCNS IS
      USE DEF_UTIL;
      USE PRENAME;
      USE MAKE_NOD;
      USE REQ_UTIL;
        -- THIS PACKAGE CONTAINS THE PROCEDURE GEN_PREDEFINED_OPERATORS
        --	 WHICH CREATES DEF NODES FOR PREDEFINED OPERATORS FOR A GIVEN
        --	 TYPE
        -- NOTE.  GEN_PREDEFINED_OPERATORS CARES WHETHER TYPE IS LIMITED
        --	 OR PRIVATE OR INCOMPLETE; THUS, WHEN PROCESSING TRANSITIVE WITHS,
        --	 POINTERS TO FULL SPECS SHOULD BE CLEARED AND THEN SET AGAIN
        --	 WHEN THE FULL SPEC IS SEEN
   
        -- FIRST-TIME SWITCHES -- GEN_PREDEFINED_OPERATORS IS CALLED
        --	 BEFORE THE STATIC STORAGE IN SEM_GLOB HAS BEEN INITIALIZED;
        --	 PREDEFINED_BOOLEAN AND PREDEFINED_INTEGER ARE SET UP HERE
        --	 WHEN THE APPROPRIATE CALL TO GEN_PREDEFINED_OPERATORS IS MADE
      BOOLEAN_IS_INITIALIZED:	BOOLEAN := FALSE;
      INTEGER_IS_INITIALIZED:	BOOLEAN := FALSE;
   
        -- STATIC STORAGE -- NODES TO BE REUSED FOR DIFFERENT CALLS
        --	 TO GET_PREDEFINED_OPERATORS
      LEFT_SYMREP:		TREE;
      RIGHT_SYMREP:		TREE;
      LEFT_INTEGER_IN:		TREE;
      RIGHT_INTEGER_IN:		TREE;
   
        --======================================================================
   
        -- INTERNAL SUBPROGRAMS
   
        -- UTILITY FUNCTIONS TO GENERATE NODES USED BY GEN_PREDEFINED_OPERATORS
   
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GEN_IN(SYMREP, TYPE_SPEC: TREE) RETURN TREE IS
      BEGIN
         RETURN MAKE_IN
                        ( AS_SOURCE_NAME_S => MAKE_SOURCE_NAME_S
                        ( LIST => SINGLETON(MAKE_IN_ID
                                        ( LX_SYMREP => SYMREP
                                                , SM_OBJ_TYPE => TYPE_SPEC )) ) );
      END GEN_IN;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GEN_DOUBLE_PARAM (LEFT_IN, RIGHT_IN: TREE) RETURN TREE IS
      BEGIN
         RETURN MAKE_GENERAL_ASSOC_S
                        ( LIST => APPEND( SINGLETON(LEFT_IN), RIGHT_IN ) );
      END GEN_DOUBLE_PARAM;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GEN_SINGLE_PARAM (RIGHT_IN: TREE) RETURN TREE IS
      BEGIN
         RETURN MAKE_GENERAL_ASSOC_S
                        ( LIST => SINGLETON(RIGHT_IN) );
      END GEN_SINGLE_PARAM;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GEN_HEADER (RESULT, PARAMS: TREE) RETURN TREE IS
      BEGIN
         RETURN MAKE_FUNCTION_SPEC
                        ( AS_NAME => RESULT
                        , AS_PARAM_S => PARAMS );
      END GEN_HEADER;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE GEN_OP_DEF(OP: OP_CLASS; HEADER: TREE; H: H_TYPE) IS
         DEF: TREE;
      BEGIN
         DEF := MAKE_DEF_FOR_ID (BLTN_ID_ARRAY(OP), H);
         MAKE_DEF_VISIBLE(DEF, HEADER);
      END GEN_OP_DEF;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION OPS_ARE_NOT_YET_DEFINED
                        ( TYPE_SPEC:	TREE
                        ; OP_FIRST:	OP_CLASS
                        ; OP_LAST:	OP_CLASS )
                        RETURN BOOLEAN
                        IS
                -- TESTS IF NAMES FOR OPS IN OP_FIRST .. OP_LAST ARE USED IN
                -- ... THEN COMPILATION BUT OPERATIONS NOT YET DEFINED
                -- ... (USED IN FULL DECLARATION OF [LIMITED] PRIVATE TYPES)
      BEGIN
         FOR OP IN OP_FIRST .. OP_LAST LOOP
            IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
               DECLARE
                  DEFLIST:	SEQ_TYPE
                                                := LIST(D(LX_SYMREP,
                                                        BLTN_ID_ARRAY(OP)));
                  DEF:	TREE;
                  BASE_TYPE:  TREE := GET_BASE_TYPE(
                                                TYPE_SPEC);
                  REGION: TREE
                                                := D(XD_REGION, D(
                                                        XD_SOURCE_NAME,
                                                        BASE_TYPE));
                  REGION_DEF: TREE := GET_DEF_FOR_ID(
                                                REGION);
               BEGIN
                  WHILE NOT IS_EMPTY(DEFLIST) LOOP
                     POP (DEFLIST, DEF);
                     IF D(XD_SOURCE_NAME, DEF).TY =
                                                                DN_BLTN_OPERATOR_ID
                                                                AND THEN D(
                                                                XD_REGION_DEF,
                                                                DEF) =
                                                                REGION_DEF
                                                                AND THEN
                                                                GET_BASE_TYPE(
                                                                D(
                                                                        SM_OBJ_TYPE,
                                                                        HEAD
                                                                        (
                                                                                LIST(
                                                                                        D(
                                                                                                AS_SOURCE_NAME_S,
                                                                                                HEAD
                                                                                                (
                                                                                                        LIST(
                                                                                                                D(
                                                                                                                        AS_PARAM_S
                                                                                                                        ,
                                                                                                                        D(
                                                                                                                                XD_HEADER,
                                                                                                                                DEF) ))) ))) ))
                                                                =
                                                                BASE_TYPE
                                                                THEN
                        RETURN FALSE;
                     END IF;
                  END LOOP;
                  RETURN TRUE;
               END;
            END IF;
         END LOOP;
         RETURN FALSE;
      END OPS_ARE_NOT_YET_DEFINED;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE GEN_PREDEFINED_OPERATORS(TYPE_SPEC: TREE; H_IN: H_TYPE) IS
      
         H:		H_TYPE := H_IN;
      
         BASE_TYPE:	CONSTANT TREE := GET_BASE_TYPE(TYPE_SPEC);
         BASE_STRUCT:	CONSTANT TREE := GET_BASE_STRUCT(BASE_TYPE);
      
                -- NODES REUSED FOR SEVERAL CLASSES OF PREDEFINED OPERATOR
         LEFT_TYPE_IN:	TREE := TREE_VOID;
         RIGHT_TYPE_IN:	TREE := TREE_VOID;
         PARAMS_TWO:	TREE := TREE_VOID;
         PARAMS_ONE:	TREE := TREE_VOID;
         HEADER_BOOLEAN: TREE := TREE_VOID;
         HEADER_TYPE:	TREE := TREE_VOID;
         HEADER_BY_INT:	TREE := TREE_VOID;
      
                --------------------------------------------------------------------
      
                -- FUNCTIONS TO GENERATE AND OBTAIN REUSED NODES
                -- THESE PERMIT NODES TO BE GENERATED ONLY IF ACTUALLY USED
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_LEFT_TYPE_IN RETURN TREE IS
         BEGIN
            IF LEFT_TYPE_IN = TREE_VOID THEN
               LEFT_TYPE_IN := GEN_IN(LEFT_SYMREP,
                                        BASE_TYPE);
            END IF;
            RETURN LEFT_TYPE_IN;
         END USE_LEFT_TYPE_IN;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_RIGHT_TYPE_IN RETURN TREE IS
         BEGIN
            IF RIGHT_TYPE_IN = TREE_VOID THEN
               IF RIGHT_SYMREP = LEFT_SYMREP THEN
                  RIGHT_TYPE_IN := USE_LEFT_TYPE_IN;
               ELSE
                  RIGHT_TYPE_IN := GEN_IN(
                                                RIGHT_SYMREP, BASE_TYPE);
               END IF;
            END IF;
            RETURN RIGHT_TYPE_IN;
         END USE_RIGHT_TYPE_IN;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_PARAMS_TWO RETURN TREE IS
         BEGIN
            IF PARAMS_TWO = TREE_VOID THEN
               PARAMS_TWO := GEN_DOUBLE_PARAM
                                        ( USE_LEFT_TYPE_IN
                                        , USE_RIGHT_TYPE_IN );
            END IF;
            RETURN PARAMS_TWO;
         END USE_PARAMS_TWO;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_PARAMS_ONE RETURN TREE IS
         BEGIN
            IF PARAMS_ONE = TREE_VOID THEN
               PARAMS_ONE := GEN_SINGLE_PARAM(
                                        USE_RIGHT_TYPE_IN);
            END IF;
            RETURN PARAMS_ONE;
         END USE_PARAMS_ONE;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_HEADER_BOOLEAN RETURN TREE IS
         BEGIN
            IF HEADER_BOOLEAN = TREE_VOID THEN
               HEADER_BOOLEAN := GEN_HEADER(
                                        PREDEFINED_BOOLEAN,USE_PARAMS_TWO);
            END IF;
            RETURN HEADER_BOOLEAN;
         END USE_HEADER_BOOLEAN;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_HEADER_TYPE RETURN TREE IS
         BEGIN
            IF HEADER_TYPE = TREE_VOID THEN
               HEADER_TYPE := GEN_HEADER(BASE_TYPE,
                                        USE_PARAMS_TWO);
            END IF;
            RETURN HEADER_TYPE;
         END USE_HEADER_TYPE;
         --|----------------------------------------------------------------------------------------
         --|
          FUNCTION USE_HEADER_BY_INT RETURN TREE IS
         BEGIN
            IF HEADER_BY_INT = TREE_VOID THEN
               HEADER_BY_INT := GEN_HEADER(BASE_TYPE,
                                        GEN_DOUBLE_PARAM
                                        ( USE_LEFT_TYPE_IN,
                                                RIGHT_INTEGER_IN ));
            END IF;
            RETURN HEADER_BY_INT;
         END USE_HEADER_BY_INT;
      
                -- PROCEDURES TO GENERATE PREDEFINED OPERATORS FOR DIFFERENT CLASSES
                --   OF TYPES
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_EQ IS
         BEGIN
            FOR OP IN CLASS_EQUALITY_OP LOOP
               IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
                  GEN_OP_DEF(OP, USE_HEADER_BOOLEAN,
                                                H);
               END IF;
            END LOOP;
         END GEN_PREDEF_EQ;
      
                -- GENERATES PREDEFINED EQUALITY AND INEQUALITY
                --   UNLESS THE TYPE IS FULL DECLARATION OF A PRIVATE TYPE,
                --   IN WHICH CASE EQUALITY AND INEQUALITY HAVE ALREADY BEEN
                --   DECLARED
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE CHECK_PREDEF_EQ IS
         BEGIN
            IF OPS_ARE_NOT_YET_DEFINED(BASE_TYPE
                                        , CLASS_EQUALITY_OP'FIRST,
                                        CLASS_EQUALITY_OP'LAST)
                                        THEN
               GEN_PREDEF_EQ;
            END IF;
         END CHECK_PREDEF_EQ;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_BOOLEAN IS
         BEGIN
            FOR OP IN CLASS_BOOLEAN_OP LOOP
               IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
                  GEN_OP_DEF(OP, USE_HEADER_TYPE, H);
               END IF;
            END LOOP;
            IF BLTN_ID_ARRAY(OP_NOT) /= TREE_VOID THEN
               GEN_OP_DEF
                                        ( OP_NOT
                                        , GEN_HEADER(BASE_TYPE,
                                                USE_PARAMS_ONE)
                                        , H );
            END IF;
         END GEN_PREDEF_BOOLEAN;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_RELATIONAL IS
         BEGIN
            FOR OP IN CLASS_RELATIONAL_OP LOOP
               IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
                  GEN_OP_DEF(OP, USE_HEADER_BOOLEAN,
                                                H);
               END IF;
            END LOOP;
         END GEN_PREDEF_RELATIONAL;
      
                -- GENERATE OPERATORS FOR NUMERIC TYPE
                -- LOWER AND UPPER BOUNDS OF REQUIRED OPERATORS ARE GIVEN,
                --   TO ALLOW THIS PROCEDURE TO BE USED FOR DIFFERENT CLASSES
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_NUMERIC (FIRST_OP, LAST_OP: OP_CLASS) IS
            HEADER_SINGLE: TREE := GEN_HEADER(BASE_TYPE,
                                USE_PARAMS_ONE);
         BEGIN
            FOR OP IN FIRST_OP .. LAST_OP LOOP
               IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
                  GEN_OP_DEF(OP, USE_HEADER_TYPE, H);
               END IF;
            END LOOP;
            FOR OP IN CLASS_UNARY_NUMERIC_OP LOOP
               IF BLTN_ID_ARRAY(OP) /= TREE_VOID THEN
                  GEN_OP_DEF(OP, HEADER_SINGLE, H);
               END IF;
            END LOOP;
         END GEN_PREDEF_NUMERIC;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_FIXED_MULTIPLY IS
         BEGIN
            IF BLTN_ID_ARRAY(OP_MULT) /= TREE_VOID THEN
               GEN_OP_DEF(OP_MULT, USE_HEADER_BY_INT, H);
               GEN_OP_DEF(OP_MULT, GEN_HEADER
                                        ( BASE_TYPE
                                                , GEN_DOUBLE_PARAM
                                                ( LEFT_INTEGER_IN
                                                        , RIGHT_TYPE_IN ) )
                                        , H );
            END IF;
            IF BLTN_ID_ARRAY(OP_DIV) /= TREE_VOID THEN
               GEN_OP_DEF(OP_DIV, USE_HEADER_BY_INT, H);
            END IF;
         END GEN_PREDEF_FIXED_MULTIPLY;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_CAT IS
            COMP_TYPE: TREE := D(SM_COMP_TYPE, BASE_TYPE);
            LEFT_COMP_IN: TREE := GEN_IN(LEFT_SYMREP,
                                COMP_TYPE);
            RIGHT_COMP_IN: TREE := GEN_IN(RIGHT_SYMREP,
                                COMP_TYPE);
         BEGIN
            IF BLTN_ID_ARRAY(OP_CAT) /= TREE_VOID THEN
               GEN_OP_DEF(OP_CAT, USE_HEADER_TYPE, H);
               GEN_OP_DEF(OP_CAT, GEN_HEADER
                                        ( BASE_TYPE
                                                , GEN_DOUBLE_PARAM(
                                                        LEFT_COMP_IN,
                                                        RIGHT_COMP_IN) )
                                        , H );
               GEN_OP_DEF(OP_CAT, GEN_HEADER
                                        ( BASE_TYPE
                                                , GEN_DOUBLE_PARAM(
                                                        USE_LEFT_TYPE_IN,
                                                        RIGHT_COMP_IN) )
                                        , H );
               GEN_OP_DEF(OP_CAT, GEN_HEADER
                                        ( BASE_TYPE
                                                , GEN_DOUBLE_PARAM(
                                                        LEFT_COMP_IN,
                                                        USE_RIGHT_TYPE_IN) )
                                        , H );
            END IF;
         END GEN_PREDEF_CAT;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_EXP IS
         BEGIN
            IF BLTN_ID_ARRAY(OP_EXP) /= TREE_VOID THEN
               GEN_OP_DEF
                                        ( OP_EXP
                                        , USE_HEADER_BY_INT
                                        , H );
            END IF;
         END GEN_PREDEF_EXP;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_ARRAY IS
            COMP_TYPE: TREE
                                := GET_BASE_TYPE(D(SM_COMP_TYPE,
                                        BASE_STRUCT));
         BEGIN
                        -- CHECK THAT COMPONENT TYPE EXISTS (1.E. NOT PRIOR ERROR)
            IF COMP_TYPE = TREE_VOID THEN
               RETURN;
            END IF;
         
                        -- IF IT IS A ONE-DIMENSIONAL ARRAY
            IF IS_EMPTY(TAIL(LIST(D(SM_INDEX_S, BASE_STRUCT)))) THEN
            
                                -- GENERATE CONCATENATION OPERATORS
               IF OPS_ARE_NOT_YET_DEFINED(BASE_TYPE,
                                                OP_CAT, OP_CAT) THEN
                  GEN_PREDEF_CAT;
               END IF;
            END IF;
         
                        -- FOR AN ARRAY WITH PRIVATE COMPONENTS
            IF H.IS_IN_SPEC
                                        AND THEN IS_PRIVATE_TYPE(
                                        COMP_TYPE) THEN
            
                                -- RELATIONAL AND BOOLEAN OPERATORS NOT DEFINED YET
               RETURN;
            END IF;
         
            IF IS_EMPTY(TAIL(LIST(D(SM_INDEX_S, BASE_STRUCT)))) THEN
               IF OPS_ARE_NOT_YET_DEFINED(BASE_TYPE
                                                , CLASS_RELATIONAL_OP'
                                                FIRST, CLASS_RELATIONAL_OP'
                                                LAST)
                                                THEN
                  GEN_PREDEF_RELATIONAL;
               END IF;
            
            END IF;
            IF IS_BOOLEAN_TYPE(COMP_TYPE) THEN
               IF OPS_ARE_NOT_YET_DEFINED(BASE_TYPE
                                                , CLASS_BOOLEAN_OP'FIRST,
                                                CLASS_BOOLEAN_OP'LAST)
                                                THEN
                  GEN_PREDEF_BOOLEAN;
               END IF;
            END IF;
         END GEN_PREDEF_ARRAY;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_UNIV_REAL IS
            UI_TYPE:		TREE := MAKE(DN_UNIVERSAL_INTEGER);
            LEFT_UI_IN: 	TREE;
            RIGHT_UI_IN:	TREE;
            HEADER_UI_UR:	TREE;
            HEADER_UR_UI:	TREE;
         BEGIN
            IF BLTN_ID_ARRAY(OP_MULT) /= TREE_VOID
                                        OR BLTN_ID_ARRAY(OP_DIV) /=
                                        TREE_VOID THEN
               RIGHT_UI_IN := GEN_IN(RIGHT_SYMREP,
                                        UI_TYPE);
               HEADER_UR_UI := GEN_HEADER
                                        ( BASE_TYPE
                                        , GEN_DOUBLE_PARAM(
                                                USE_LEFT_TYPE_IN,
                                                RIGHT_UI_IN));
            END IF;
            IF BLTN_ID_ARRAY(OP_DIV) /= TREE_VOID THEN
               GEN_OP_DEF(OP_DIV, HEADER_UR_UI, H);
            END IF;
            IF BLTN_ID_ARRAY(OP_MULT) /= TREE_VOID THEN
               LEFT_UI_IN := GEN_IN(LEFT_SYMREP, UI_TYPE);
               HEADER_UI_UR := GEN_HEADER
                                        ( BASE_TYPE
                                        , GEN_DOUBLE_PARAM(LEFT_UI_IN,
                                                USE_RIGHT_TYPE_IN));
               GEN_OP_DEF(OP_MULT,HEADER_UI_UR,H);
               GEN_OP_DEF(OP_MULT,HEADER_UR_UI,H);
            END IF;
         END GEN_PREDEF_UNIV_REAL;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE GEN_PREDEF_UNIV_FIXED IS
         BEGIN
            IF BLTN_ID_ARRAY(OP_MULT) /= TREE_VOID THEN
               GEN_OP_DEF(OP_MULT, USE_HEADER_TYPE, H);
            END IF;
            IF BLTN_ID_ARRAY(OP_DIV) /= TREE_VOID THEN
               GEN_OP_DEF(OP_DIV, USE_HEADER_TYPE, H);
            END IF;
         END GEN_PREDEF_UNIV_FIXED;
      
      
      BEGIN -- GEN_PREDEFINED_OPERATORS
         IF BASE_TYPE = TREE_VOID
                                OR ELSE IS_LIMITED_TYPE(BASE_TYPE) THEN
            RETURN;
         END IF;
      
         CASE CLASS_TYPE_SPEC'(BASE_STRUCT.TY) IS
            WHEN DN_L_PRIVATE | DN_TASK_SPEC | DN_INCOMPLETE |
                                        CLASS_CONSTRAINED =>
               PUT_LINE ( "!! GEN_PREDEFINED_OPERATORS: IMPOSSIBLE TYPE");
               RAISE PROGRAM_ERROR;
               
            WHEN DN_PRIVATE =>
               CHECK_PREDEF_EQ;
            WHEN DN_RECORD | DN_ACCESS =>
               CHECK_PREDEF_EQ;
            WHEN DN_ENUMERATION =>
               IF NOT BOOLEAN_IS_INITIALIZED THEN
                  PREDEFINED_BOOLEAN := TYPE_SPEC;
                  LEFT_SYMREP := FIND_SYM ( "LEFT");
                  RIGHT_SYMREP := FIND_SYM ( "RIGHT");
                  BOOLEAN_IS_INITIALIZED := TRUE;
               END IF;
               CHECK_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               IF IS_BOOLEAN_TYPE(BASE_TYPE) THEN
                  GEN_PREDEF_BOOLEAN;
               END IF;
            WHEN DN_INTEGER =>
               IF NOT INTEGER_IS_INITIALIZED THEN
                  PREDEFINED_INTEGER := BASE_TYPE;
                  LEFT_INTEGER_IN := GEN_IN(
                                                LEFT_SYMREP,
                                                PREDEFINED_INTEGER);
                  RIGHT_INTEGER_IN := GEN_IN(
                                                RIGHT_SYMREP,
                                                PREDEFINED_INTEGER);
                  INTEGER_IS_INITIALIZED := TRUE;
               END IF;
               CHECK_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               GEN_PREDEF_NUMERIC(CLASS_INTEGER_OP'FIRST,
                                        CLASS_INTEGER_OP'LAST);
               GEN_PREDEF_EXP;
            WHEN DN_FLOAT =>
               CHECK_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               GEN_PREDEF_NUMERIC
                                        ( CLASS_FLOAT_OP'FIRST,
                                        CLASS_FLOAT_OP'LAST );
               GEN_PREDEF_EXP;
            WHEN DN_FIXED =>
               CHECK_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               GEN_PREDEF_NUMERIC( CLASS_FIXED_OP'FIRST,
                                        CLASS_FIXED_OP'LAST );
               GEN_PREDEF_FIXED_MULTIPLY;
            WHEN DN_UNIVERSAL_INTEGER =>
               GEN_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               GEN_PREDEF_NUMERIC(CLASS_INTEGER_OP'FIRST,
                                        CLASS_INTEGER_OP'LAST);
               GEN_PREDEF_EXP;
            WHEN DN_UNIVERSAL_REAL =>
               GEN_PREDEF_EQ;
               GEN_PREDEF_RELATIONAL;
               GEN_PREDEF_NUMERIC(CLASS_FLOAT_OP'FIRST,
                                        CLASS_FLOAT_OP'LAST);
               GEN_PREDEF_EXP;
               GEN_PREDEF_UNIV_REAL;
            WHEN DN_UNIVERSAL_FIXED =>
               GEN_PREDEF_UNIV_FIXED;
            WHEN DN_ARRAY =>
               CHECK_PREDEF_EQ;
               GEN_PREDEF_ARRAY;
         END CASE;
      END GEN_PREDEFINED_OPERATORS;
   
    --|----------------------------------------------------------------------------------------------
   END PRE_FCNS;
