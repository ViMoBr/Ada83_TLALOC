    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	ATT_WALK
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY ATT_WALK IS
      USE REQ_UTIL;
      USE VIS_UTIL;
      USE DEF_UTIL;
      USE SET_UTIL;
      USE UARITH;
      USE PRENAME;
      USE EXP_TYPE, EXPRESO;
      USE MAKE_NOD;
      USE SEM_GLOB;
      USE RED_SUBP;
      USE CHK_STAT;
   
       PROCEDURE WALK_ATTRIBUTE_PREFIX
                ( PREFIX:       IN OUT TREE
                ; PREFIX_ID:    OUT TREE
                ; PREFIX_TYPE:  OUT TREE
                ; ATTRIBUTE_ID: TREE );
   
   
       
       PROCEDURE CHECK_PREFIX_AND_ATTRIBUTE (
       ATTRIBUTE_NODE, PREFIX_ID, PREFIX_TYPE :TREE; ATTRIBUTE_SUBTYPE, ATTRIBUTE_VALUE :OUT TREE;
       	PARAMETER :IN OUT TREE; PARAM_TYPESET :IN OUT TYPESET_TYPE;
       	IS_FUNCTION :BOOLEAN );
   
   
        -- $$$$ FOR DEBUG
       PROCEDURE PRINT_TREE(T: TREE) IS
      BEGIN
         IF T.TY = DN_REAL_VAL THEN
            PRINT_NOD.PRINT_TREE(D ( XD_NUMER,T));
            PUT('/');
            PRINT_NOD.PRINT_TREE(D ( XD_DENOM,T));
         ELSE
            PRINT_NOD.PRINT_TREE(T);
         END IF;
      END PRINT_TREE;
   
   
        -- $$$$ EXTENSIONS TO UARITH
       FUNCTION U_REAL(NUMER: INTEGER; DENOM: INTEGER := 1) RETURN TREE IS
         REAL: TREE := MAKE(DN_REAL_VAL);
      BEGIN
         D ( XD_NUMER, REAL, U_VAL(NUMER));
         D ( XD_DENOM, REAL, U_VAL(1));
         REAL := REAL / U_VAL(DENOM);
         RETURN REAL;
      END U_REAL;
   
        -- $$$$ EXTENSIONS TO UARITH
       FUNCTION "<" (L,R: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN NOT (L >= R);
      END "<";
   
       FUNCTION ">" (L,R: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN NOT (L <= R);
      END ">";
   
        -- $$$$ SHOULD NOT BE HERE
       FUNCTION GET_SUBSTRUCT(TYPE_SPEC: TREE) RETURN TREE IS
      BEGIN
         IF TYPE_SPEC.TY IN CLASS_PRIVATE_SPEC
                                AND THEN GET_BASE_STRUCT(TYPE_SPEC).TY IN
                                CLASS_FULL_TYPE_SPEC THEN
            RETURN D ( SM_TYPE_SPEC, TYPE_SPEC);
         ELSIF TYPE_SPEC.TY = DN_INCOMPLETE
                                AND THEN GET_BASE_STRUCT(TYPE_SPEC).TY IN
                                CLASS_FULL_TYPE_SPEC THEN
            RETURN D ( XD_FULL_TYPE_SPEC, TYPE_SPEC);
         ELSE
            RETURN TYPE_SPEC;
         END IF;
      END GET_SUBSTRUCT;
   
   
        -- $$$$ SHOULD NOT BE HERE
       FUNCTION GET_APPROPRIATE_BASE(TYPE_SPEC: TREE) RETURN TREE IS
         BASE_TYPE: TREE := GET_BASE_TYPE(TYPE_SPEC);
      BEGIN
         IF BASE_TYPE.TY = DN_ACCESS THEN
            RETURN GET_BASE_TYPE(D ( SM_DESIG_TYPE,BASE_TYPE));
         ELSE
            RETURN BASE_TYPE;
         END IF;
      END GET_APPROPRIATE_BASE;
   
   
       FUNCTION BITS_IN_INTEGER_PART(REAL: TREE) RETURN NATURAL IS
         TEMP: TREE := REAL;
         RESULT: INTEGER := 0;
      BEGIN
         WHILE TEMP > U_REAL(2**14) LOOP
            TEMP := TEMP / U_VAL(2**14);
            RESULT := RESULT + 14;
         END LOOP;
         WHILE TEMP > U_REAL(1) LOOP
            TEMP := TEMP / U_VAL(2);
            RESULT := RESULT + 1;
         END LOOP;
         RETURN RESULT;
      END BITS_IN_INTEGER_PART;
   
   
       FUNCTION DIGITS_IN_INTEGER_PART(REAL: TREE) RETURN NATURAL IS
         TEMP: TREE := REAL;
         RESULT: INTEGER := 0;
      BEGIN
         WHILE TEMP > U_REAL(10**4) LOOP
            TEMP := TEMP / U_VAL(10**4);
            RESULT := RESULT + 4;
         END LOOP;
         WHILE TEMP > U_REAL(1) LOOP
            TEMP := TEMP / U_VAL(10);
            RESULT := RESULT + 1;
         END LOOP;
         RETURN RESULT;
      END DIGITS_IN_INTEGER_PART;
   
   
       FUNCTION GET_FLOAT_MANTISSA(CONSTRAINT: TREE) RETURN TREE IS
         RESULT: TREE;
      BEGIN
         RESULT := U_VAL(BITS_IN_INTEGER_PART
                        ( U_REAL(10) ** D ( SM_ACCURACY,CONSTRAINT) ) + 1 );
         RETURN RESULT;
      END GET_FLOAT_MANTISSA;
   
   
       FUNCTION GET_FIXED_SMALL(CONSTRAINT: TREE) RETURN TREE IS
         SMALL: TREE := D ( CD_IMPL_SMALL, CONSTRAINT);
      BEGIN
         IF SMALL = TREE_VOID THEN
            SMALL := D ( SM_ACCURACY, CONSTRAINT);
         END IF;
         RETURN SMALL;
      END GET_FIXED_SMALL;
   
   
       FUNCTION GET_FIXED_BOUND(CONSTRAINT: TREE) RETURN TREE IS
         SMALL: CONSTANT TREE := GET_FIXED_SMALL(CONSTRAINT);
         BOUND: TREE := GET_STATIC_VALUE(D ( AS_EXP2,D ( SM_RANGE,
                                        CONSTRAINT)));
         LOW_BOUND: TREE := GET_STATIC_VALUE(D ( AS_EXP1,D ( SM_RANGE,
                                        CONSTRAINT)));
         REAL_ZERO: CONSTANT TREE := U_REAL(0);
      BEGIN
         IF BOUND < U_REAL(0) THEN
            BOUND := - BOUND;
         END IF;
         IF LOW_BOUND < U_REAL(0) THEN
            LOW_BOUND := - LOW_BOUND;
         END IF;
         IF LOW_BOUND > BOUND THEN
            BOUND := LOW_BOUND;
         END IF;
         IF BOUND > SMALL THEN
            BOUND := BOUND - SMALL;
         END IF;
         RETURN BOUND;
      END GET_FIXED_BOUND;
   
   
       FUNCTION GET_FIXED_MANTISSA(CONSTRAINT: TREE) RETURN TREE IS
         RESULT: TREE;
      BEGIN
         RESULT := U_VAL(BITS_IN_INTEGER_PART
                        ( GET_FIXED_BOUND(CONSTRAINT)
                                / GET_FIXED_SMALL(CONSTRAINT) ));
         RETURN RESULT;
      END GET_FIXED_MANTISSA;
   
   
       FUNCTION GET_WIDTH(TYPE_SPEC: TREE) RETURN INTEGER IS
         RANGE_NODE: TREE := D ( SM_RANGE, TYPE_SPEC);
         L_BOUND: TREE := D ( AS_EXP1, RANGE_NODE);
         U_BOUND: TREE := D ( AS_EXP2, RANGE_NODE);
         L_VALUE: TREE;
         U_VALUE: TREE;
         COUNT: INTEGER := 0;
         ESIZE: INTEGER;
         ENUM_LIST: SEQ_TYPE;
         ENUM: TREE;
          FUNCTION SLENGTH ( A :STRING ) RETURN INTEGER IS
                        -- A IS TEXT OF ENUMERATION LITERAL; RETURNS WIDTH
         BEGIN
            IF A ( A'FIRST ) = '_' THEN
               RETURN A'LENGTH - 1;
            ELSE
               RETURN A'LENGTH;
            END IF;
         END SLENGTH;
      BEGIN
         L_VALUE := GET_STATIC_VALUE(L_BOUND);
         U_VALUE := GET_STATIC_VALUE(U_BOUND);
         IF TYPE_SPEC.TY = DN_ENUMERATION THEN
            ENUM_LIST := LIST ( D ( SM_LITERAL_S, TYPE_SPEC));
            WHILE NOT IS_EMPTY ( ENUM_LIST) LOOP
               EXIT
                                        WHEN D ( SM_POS,HEAD ( ENUM_LIST)) =
                                        L_VALUE;
               ENUM_LIST := TAIL(ENUM_LIST);
            END LOOP;
            WHILE NOT IS_EMPTY ( ENUM_LIST) LOOP
               POP ( ENUM_LIST, ENUM);
               ESIZE := SLENGTH(PRINT_NAME ( D ( LX_SYMREP,
                                                        ENUM)));
               IF ESIZE > COUNT THEN
                  COUNT := ESIZE;
               END IF;
               EXIT
                                        WHEN D ( SM_POS,ENUM) = U_VALUE;
            END LOOP;
            RETURN COUNT;
         ELSE -- INTEGER
            IF L_VALUE < U_VAL(0) THEN
               L_VALUE := - L_VALUE;
            END IF;
            IF U_VALUE < U_VAL(0) THEN
               U_VALUE := - U_VALUE;
            END IF;
            IF L_VALUE > U_VALUE THEN
               U_VALUE := L_VALUE;
            END IF;
            WHILE U_VALUE >= U_VAL(10) LOOP
               COUNT := COUNT + 1;
               U_VALUE := U_VALUE / U_VAL(10);
            END LOOP;
            RETURN COUNT+2;
         END IF;
      END GET_WIDTH;
   --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   --|	PROCEDURE EVAL_ATTRIBUTE
       PROCEDURE EVAL_ATTRIBUTE ( EXP :TREE; TYPESET :OUT TYPESET_TYPE; IS_SUBTYPE :OUT BOOLEAN; IS_FUNCTION :BOOLEAN := FALSE ) IS
         ATTRIBUTE_NODE	: TREE	:= EXP;
         PARAMETER		: TREE	:= TREE_VOID;
         PARAM_TYPESET	: TYPESET_TYPE;
         ATTRIBUTE_ID	: TREE;
      
         PREFIX		: TREE;
         PREFIX_ID		: TREE;
         PREFIX_TYPE	: TREE;
      
         NEW_TYPESET	: TYPESET_TYPE	:= EMPTY_TYPESET;
         ATTRIBUTE_SUBTYPE	: TREE	:= TREE_VOID;
         ATTRIBUTE_VALUE	: TREE	:= TREE_VOID;
      BEGIN
         IS_SUBTYPE := FALSE;				--| HYPOTHÈSE : CE N'EST PAS UN 'RANGE
      
                -- SPLIT OFF PARAMETER, IF ONE IS GIVEN
         IF EXP.TY = DN_FUNCTION_CALL THEN
            DECLARE
               PARAM_LIST: SEQ_TYPE := LIST ( D ( AS_GENERAL_ASSOC_S, EXP ) );
            BEGIN
               ATTRIBUTE_NODE := D ( AS_NAME, EXP );			--| UN NAME QUI EST UN ATTRIBUTE
               POP ( PARAM_LIST, PARAMETER );
               IF NOT IS_EMPTY ( PARAM_LIST ) THEN
                  ERROR ( D ( LX_SRCPOS, HEAD ( PARAM_LIST ) ), "ONLY SINGLE PARAMETER ALLOWED FOR ATTRIBUTE" );
               END IF;
               IF PARAMETER.TY = DN_ASSOC THEN
                  ERROR ( D ( LX_SRCPOS, PARAMETER ), "NAMED NOTATION NOT ALLOWED FOR ATTRIBUTE" );
                  PARAMETER := D ( AS_EXP, PARAMETER);
               END IF;
               EVAL_EXP_TYPES ( PARAMETER, PARAM_TYPESET );
            END;
         END IF;
      
                -- LOOKUP ATTRIBUTE ID
         ATTRIBUTE_ID := EVAL_ATTRIBUTE_IDENTIFIER ( ATTRIBUTE_NODE );
         IF ATTRIBUTE_ID = TREE_VOID THEN
            ERROR ( D ( LX_SRCPOS, D ( AS_USED_NAME_ID, ATTRIBUTE_NODE ) ), "ATTRIBUTE NOT KNOWN TO IMPLEMENTATION - "
                                & PRINT_NAME ( D ( LX_SYMREP, D ( AS_USED_NAME_ID, ATTRIBUTE_NODE ) ))
               	            );
         ELSIF DEFINED_ATTRIBUTES'VAL(DI ( XD_POS,ATTRIBUTE_ID)) =
                                RANGE_X THEN
            IS_SUBTYPE := TRUE;
         END IF;
      
                -- WALK PREFIX
         PREFIX := D ( AS_NAME, ATTRIBUTE_NODE);
         WALK_ATTRIBUTE_PREFIX ( PREFIX, PREFIX_ID, PREFIX_TYPE, ATTRIBUTE_ID );
         D ( AS_NAME, ATTRIBUTE_NODE, PREFIX );
      
         IF FALSE THEN
            CHECK_PREFIX_AND_ATTRIBUTE
                                ( ATTRIBUTE_NODE
                                , PREFIX_ID
                                , PREFIX_TYPE
                                , ATTRIBUTE_SUBTYPE
                                , ATTRIBUTE_VALUE
                                , PARAMETER
                                , PARAM_TYPESET
                                , IS_FUNCTION => TRUE );
         ELSE
            CHECK_PREFIX_AND_ATTRIBUTE
                                ( ATTRIBUTE_NODE
                                , PREFIX_ID
                                , PREFIX_TYPE
                                , ATTRIBUTE_SUBTYPE
                                , ATTRIBUTE_VALUE
                                , PARAMETER
                                , PARAM_TYPESET
                                , IS_FUNCTION );
         END IF;
      
         D ( SM_EXP_TYPE, ATTRIBUTE_NODE, ATTRIBUTE_SUBTYPE);
         D ( SM_VALUE, ATTRIBUTE_NODE, ATTRIBUTE_VALUE);
         IF ATTRIBUTE_SUBTYPE /= TREE_VOID THEN
            ADD_TO_TYPESET(NEW_TYPESET, GET_BASE_TYPE(
                                        ATTRIBUTE_SUBTYPE));
         END IF;
         TYPESET := NEW_TYPESET;
      
         IF PARAMETER /= TREE_VOID THEN
            LIST ( D ( AS_GENERAL_ASSOC_S, EXP), SINGLETON(
                                        PARAMETER));
         END IF;
      END EVAL_ATTRIBUTE;
   
   
       FUNCTION RESOLVE_ATTRIBUTE ( EXP: TREE ) RETURN TREE IS
         ATTRIBUTE_NODE: TREE := EXP;
         ATTRIBUTE_ID:   TREE;
      BEGIN
      
                -- SPLIT OFF PARAMETER, IF ONE IS GIVEN
         IF EXP.TY = DN_FUNCTION_CALL THEN
            ATTRIBUTE_NODE := D ( AS_NAME, EXP);
            D ( AS_EXP, ATTRIBUTE_NODE, HEAD ( LIST ( D ( 
                                                        AS_GENERAL_ASSOC_S,
                                                        EXP))));
         END IF;
      
                -- GET THE ATTRIBUTE ID
         ATTRIBUTE_ID := D ( SM_DEFN, D ( AS_USED_NAME_ID,
                                ATTRIBUTE_NODE));
      
                -- IF THE ATTRIBUTE NAME WAS UNDEFINED
         IF ATTRIBUTE_ID = TREE_VOID THEN
         
                        -- JUST RETURN THE ATTRIBUTE NODE
            RETURN ATTRIBUTE_NODE;
         
                        -- ELSE
         ELSE
         
            CASE DEFINED_ATTRIBUTES'VAL(DI ( XD_POS,
                                                        ATTRIBUTE_ID)) IS
            
                                -- FOR A RANGE ATTRIBUTE
               WHEN RANGE_X =>
               
                                        -- CONSTRUCT AND RETURN RANGE_ATTRIBUTE NODE
                  RETURN MAKE_RANGE_ATTRIBUTE (
                     LX_SRCPOS	=> D ( LX_SRCPOS, ATTRIBUTE_NODE ),
                     AS_NAME	=> D ( AS_NAME, ATTRIBUTE_NODE ),
                     AS_USED_NAME_ID	=> D ( AS_USED_NAME_ID, ATTRIBUTE_NODE ),
                     AS_EXP	=> D ( AS_EXP, ATTRIBUTE_NODE ),
                     SM_TYPE_SPEC	=> D ( SM_EXP_TYPE, ATTRIBUTE_NODE )
                     );
            
                                -- FOR AN ATTRIBUTE WHICH IS A FUNCTION
               WHEN PRED | SUCC | POS | VAL | VALUE |
                                                IMAGE =>
               
                                        -- IF A PARAMETER WAS GIVEN
                  IF EXP.TY = DN_FUNCTION_CALL THEN
                  
                                                -- RETURN A FUNCTION CALL
                     D ( SM_NORMALIZED_PARAM_S
                                                        , EXP
                                                        , MAKE_EXP_S
                                                        ( LIST =>
                                                                SINGLETON
                                                                ( D ( 
                                                                                AS_EXP,
                                                                                ATTRIBUTE_NODE) ) ));
                     D ( AS_EXP, ATTRIBUTE_NODE,
                                                        TREE_VOID);
                     D ( SM_EXP_TYPE, EXP, D ( 
                                                                SM_EXP_TYPE,
                                                                ATTRIBUTE_NODE));
                     D ( SM_EXP_TYPE,
                                                        ATTRIBUTE_NODE,
                                                        TREE_VOID);
                     D ( SM_VALUE, EXP, D ( 
                                                                SM_VALUE,
                                                                ATTRIBUTE_NODE));
                     D ( SM_VALUE, ATTRIBUTE_NODE,
                                                        TREE_VOID);
                     RETURN EXP;
                  
                                                -- ELSE
                  ELSE
                  
                                                -- RETURN THE ATTRIBUTE NODE
                     RETURN ATTRIBUTE_NODE;
                  END IF;
            
                                -- FOR ALL OTHER ATTRIBUTES
               WHEN OTHERS =>
               
                                        -- RETURN THE ATTRIBUTE NODE
                  RETURN ATTRIBUTE_NODE;
            END CASE;
         END IF;
      
      END RESOLVE_ATTRIBUTE;
   --|----------------------------------------------------------------------------------------------
   --|	FUNCTION EVAL_ATTRIBUTE_IDENTIFIER
       FUNCTION EVAL_ATTRIBUTE_IDENTIFIER ( ATTRIBUTE_NODE :TREE ) RETURN TREE IS
         USED_OBJECT_ID	: CONSTANT TREE := D ( AS_USED_NAME_ID, ATTRIBUTE_NODE );
         USED_NAME_ID_COPY	: CONSTANT TREE := MAKE_USED_NAME_ID_FROM_OBJECT ( USED_OBJECT_ID );
         SYMREP		: CONSTANT TREE := D ( LX_SYMREP, USED_NAME_ID_COPY );
         DEFLIST		: SEQ_TYPE	:= LIST ( SYMREP );
         DEF		: TREE;
         ID		: TREE;
      BEGIN
      
         D ( AS_USED_NAME_ID, ATTRIBUTE_NODE, USED_NAME_ID_COPY );
         WHILE NOT IS_EMPTY ( DEFLIST ) LOOP
            POP ( DEFLIST, DEF );
            ID := D ( XD_SOURCE_NAME, DEF );
            IF ID.TY = DN_ATTRIBUTE_ID THEN
               D ( SM_DEFN, USED_NAME_ID_COPY, ID );
               RETURN ID;
            END IF;
         END LOOP;
      
         D ( SM_DEFN, USED_NAME_ID_COPY, TREE_VOID );
         ERROR ( D ( LX_SRCPOS, USED_NAME_ID_COPY ), "ATTRIBUTE NOT KNOWN - '" & PRINT_NAME ( D ( LX_SYMREP, USED_NAME_ID_COPY ) ) );
         RETURN TREE_VOID;
      END EVAL_ATTRIBUTE_IDENTIFIER;
   
   
       PROCEDURE WALK_ATTRIBUTE_PREFIX
                        ( PREFIX:       IN OUT TREE
                        ; PREFIX_ID:    OUT TREE
                        ; PREFIX_TYPE:  OUT TREE
                        ; ATTRIBUTE_ID: TREE )
                        IS
                -- NOTE. PREFIX_ID NULL FOR OBJECT OR EXPRESSION
                -- ... AND THE ID FOR ANY OTHER NAMED ENTITY (E.G. TYPE_ID)
                -- PREFIX_TYPE SET FOR OBJECT OR EXPRESSION OR [SUB]TYPE NAME
         DEFSET: DEFSET_TYPE := EMPTY_DEFSET;
         ID: TREE := TREE_VOID;
         TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
         PREFIX_TYPE_OUT: TREE := TREE_VOID;
      BEGIN
      
                -- ASSUME DEFAULT VALUES FOR OUT PARAMETERS
         PREFIX_ID := TREE_VOID;
         PREFIX_TYPE := TREE_VOID;
      
                -- IF PREFIX IS A STRING LITERAL
         IF PREFIX.TY = DN_STRING_LITERAL THEN
         
                        -- MAKE IT A USED_OP
            PREFIX := MAKE_USED_OP_FROM_STRING(PREFIX);
         END IF;
      
                -- IF PREFIX IS A [SELECTED] NAME
         IF PREFIX.TY = DN_SELECTED
                                OR ELSE PREFIX.TY IN CLASS_USED_OBJECT THEN
         
                        -- EVALUATE THE NAME
            FIND_VISIBILITY(PREFIX, DEFSET);
            ID := GET_THE_ID(DEFSET);
         
            CASE ID.TY IS
               WHEN DN_VOID =>
                  PREFIX := RESOLVE_EXP(PREFIX,
                                                TREE_VOID);
               WHEN CLASS_OBJECT_NAME =>
                  REQUIRE_UNIQUE_DEF(PREFIX,DEFSET);
                  STASH_DEFSET(PREFIX, DEFSET);
                  ID := GET_THE_ID(DEFSET);
                  PREFIX_TYPE_OUT := GET_BASE_TYPE(
                                                ID);
                  PREFIX_TYPE := PREFIX_TYPE_OUT;
                  PREFIX := RESOLVE_EXP(PREFIX,
                                                PREFIX_TYPE_OUT);
               WHEN CLASS_TYPE_NAME =>
                  REQUIRE_UNIQUE_DEF(PREFIX,DEFSET);
                  ID := GET_THE_ID(DEFSET);
                  PREFIX_TYPE_OUT := GET_BASE_TYPE(
                                                ID);
                  IF PREFIX_TYPE_OUT.TY =
                                                        DN_TASK_SPEC
                                                        AND THEN DI ( 
                                                        XD_LEX_LEVEL
                                                        , GET_DEF_FOR_ID(
                                                                D ( 
                                                                        XD_SOURCE_NAME,
                                                                        PREFIX_TYPE_OUT)))
                                                        > 0
                                                        THEN
                     PREFIX_TYPE :=
                                                        PREFIX_TYPE_OUT;
                     STASH_DEFSET(PREFIX,
                                                        DEFSET);
                     PREFIX := RESOLVE_EXP(
                                                        PREFIX,
                                                        PREFIX_TYPE_OUT);
                  ELSE
                     PREFIX_ID := ID;
                     PREFIX := RESOLVE_NAME(
                                                        PREFIX, GET_THE_ID(
                                                                DEFSET));
                     PREFIX_TYPE := D ( 
                                                        SM_TYPE_SPEC, ID);
                  END IF;
                  RETURN;
               WHEN DN_OPERATOR_ID | DN_LABEL_ID |
                                                DN_PACKAGE_ID
                                                | DN_TASK_BODY_ID =>
                  REQUIRE_UNIQUE_DEF(PREFIX,DEFSET);
                  PREFIX_ID := GET_THE_ID(DEFSET);
                  PREFIX := RESOLVE_NAME(PREFIX,
                                                GET_THE_ID(DEFSET));
                  RETURN;
               WHEN DN_PROCEDURE_ID | DN_FUNCTION_ID |
                                                DN_ENTRY_ID
                                                | DN_GENERIC_ID =>
                                        -- (PREFIX MAY BE OVERLOADABLE OR MAY BE EXPRESSION)
                  IF ATTRIBUTE_ID = TREE_VOID THEN
                     RETURN;
                  END IF;
               
                  CASE DEFINED_ATTRIBUTES'VAL(DI ( 
                                                                        XD_POS,
                                                                        ATTRIBUTE_ID)) IS
                     WHEN CALLABLE | FIRST |
                                                                LAST |
                                                                LENGTH |
                                                                RANGE_X
                                                                |
                                                                TERMINATED =>
                                                        -- EXPRESSION ALLOWED
                        DECLARE
                           GENERAL_ASSOC_S:
                                                                        TREE :=
                                                                        MAKE_GENERAL_ASSOC_S
                                                                        (
                                                                        LIST =>
                                                                        (TREE_NIL,TREE_NIL)
                                                                        ,
                                                                        LX_SRCPOS =>
                                                                        D ( 
                                                                                LX_SRCPOS,
                                                                                PREFIX) );
                        BEGIN
                           REQUIRE_FUNCTION_OR_ARRAY_DEF(
                                                                        PREFIX,
                                                                        DEFSET);
                           REDUCE_APPLY_NAMES (
                                                                        PREFIX,
                                                                        DEFSET,
                                                                        GENERAL_ASSOC_S);
                           REQUIRE_UNIQUE_DEF(
                                                                        PREFIX,
                                                                        DEFSET);
                           STASH_DEFSET(
                                                                        PREFIX,
                                                                        DEFSET);
                           PREFIX :=
                                                                        MAKE_FUNCTION_CALL
                                                                        (
                                                                        AS_NAME =>
                                                                        PREFIX
                                                                        ,
                                                                        AS_GENERAL_ASSOC_S =>
                                                                        GENERAL_ASSOC_S
                                                                        ,
                                                                        LX_SRCPOS =>
                                                                        D ( 
                                                                                LX_SRCPOS,
                                                                                PREFIX) );
                           PREFIX_TYPE_OUT :=
                                                                        GET_BASE_TYPE(
                                                                        ID);
                           PREFIX_TYPE :=
                                                                        PREFIX_TYPE_OUT;
                           PREFIX :=
                                                                        RESOLVE_EXP
                                                                        (
                                                                        PREFIX,
                                                                        PREFIX_TYPE_OUT );
                        END;
                     WHEN OTHERS =>
                        REQUIRE_UNIQUE_DEF(
                                                                PREFIX,
                                                                DEFSET);
                        PREFIX_ID :=
                                                                GET_THE_ID(
                                                                DEFSET);
                        PREFIX :=
                                                                RESOLVE_NAME(
                                                                PREFIX,
                                                                GET_THE_ID(
                                                                        DEFSET));
                        RETURN;
                  END CASE;
               WHEN DN_BLOCK_LOOP_ID =>
                  ERROR ( D ( LX_SRCPOS,PREFIX),
                                                "CANNOT BE ATTRIBUTE PREFIX");
                  RETURN;
               WHEN OTHERS =>
                  PUT_LINE ( "!! INVALID ID NODE FOR ATTRIBUTE PREFIX" );
                  RAISE PROGRAM_ERROR;
            END CASE;
         
         ELSE
         
            IF PREFIX.TY = DN_FUNCTION_CALL THEN
               DECLARE
                  NAME: TREE := D ( AS_NAME, PREFIX);
                  HOLD_PREFIX: TREE;
                                        -- SAVE PREFIX TO RESTORE IT
                  HOLD_DESIGNATOR: TREE;
                                        -- SAVE DESIG TO RESTORE IT
                  SAVE_NAME: TREE := NAME;
                  GENERAL_ASSOC_S: TREE
                                                := D ( AS_GENERAL_ASSOC_S,
                                                PREFIX);
                  GENERAL_ASSOC_LIST: SEQ_TYPE :=
                                                LIST ( GENERAL_ASSOC_S);
                  INDEX: TREE;
               BEGIN
                  IF  ( NAME.TY = DN_SELECTED
                                                        OR ELSE NAME.TY =
                                                        DN_USED_OBJECT_ID )
                                                        AND THEN NOT
                                                        IS_EMPTY ( 
                                                        GENERAL_ASSOC_LIST)
                                                        AND THEN IS_EMPTY ( 
                                                        TAIL(
                                                                GENERAL_ASSOC_LIST))
                                                        AND THEN 
                                                        HEAD ( 
                                                                GENERAL_ASSOC_LIST).TY /=
                                                        DN_ASSOC
                                                        THEN
                     IF NAME.TY =
                                                                DN_SELECTED THEN
                        HOLD_DESIGNATOR :=
                                                                D ( 
                                                                AS_DESIGNATOR,
                                                                NAME);
                        HOLD_PREFIX := D ( 
                                                                AS_NAME,
                                                                NAME);
                     END IF;
                     FIND_VISIBILITY(NAME,
                                                        DEFSET);
                     ID := GET_THE_ID(DEFSET);
                     IF ID.TY = DN_VOID THEN
                                                        -- FINISH HERE BECAUSE ERROR ALREADY REPORTED
                        NAME :=
                                                                RESOLVE_EXP(
                                                                NAME,
                                                                TREE_VOID);
                        D ( AS_NAME,PREFIX,
                                                                NAME);
                        INDEX := HEAD ( 
                                                                GENERAL_ASSOC_LIST);
                        EVAL_EXP_TYPES(
                                                                INDEX,
                                                                TYPESET);
                        INDEX :=
                                                                RESOLVE_EXP(
                                                                INDEX,
                                                                TREE_VOID);
                        LIST ( 
                                                                GENERAL_ASSOC_S,
                                                                SINGLETON(
                                                                        INDEX));
                        RETURN;
                     ELSIF ID.TY =
                                                                DN_ENTRY_ID
                                                                AND THEN
                                                                D ( 
                                                                        SM_SPEC,
                                                                        ID).TY
                                                                = DN_ENTRY
                                                                AND THEN D ( 
                                                                AS_DISCRETE_RANGE,
                                                                D ( SM_SPEC,
                                                                        ID))
                                                                /=
                                                                TREE_VOID
                                                                THEN
                        NAME :=
                                                                RESOLVE_NAME(
                                                                NAME, ID);
                        D ( AS_NAME,PREFIX,
                                                                NAME);
                        PREFIX_ID := ID;
                        INDEX := HEAD ( 
                                                                GENERAL_ASSOC_LIST);
                        EVAL_EXP_TYPES(
                                                                INDEX,
                                                                TYPESET);
                        REQUIRE_TYPE
                                                                (
                                                                GET_TYPE_OF_DISCRETE_RANGE
                                                                ( D ( 
                                                                                AS_DISCRETE_RANGE
                                                                                ,
                                                                                D ( 
                                                                                        SM_SPEC,
                                                                                        ID)))
                                                                , INDEX
                                                                , TYPESET);
                        INDEX :=
                                                                RESOLVE_EXP(
                                                                INDEX,
                                                                GET_THE_TYPE(
                                                                        TYPESET));
                        LIST ( 
                                                                GENERAL_ASSOC_S,
                                                                SINGLETON(
                                                                        INDEX));
                        RETURN;
                     ELSIF NAME.TY =
                                                                DN_SELECTED THEN
                                                        -- PUT IT BACK TO USED OBJECT ID
                                                        -- SINCE VISIBILITY WILL BE CHECKED AGAIN
                        D ( AS_DESIGNATOR,
                                                                NAME,
                                                                HOLD_DESIGNATOR);
                        D ( AS_NAME, NAME,
                                                                HOLD_PREFIX);
                     END IF;
                  END IF;
               END;
            
                                -- ELSE IF PREFIX IS AN ATTRIBUTE
            ELSIF PREFIX.TY = DN_ATTRIBUTE
                                        AND THEN EVAL_ATTRIBUTE_IDENTIFIER(
                                        PREFIX) /= TREE_VOID THEN
            
               CASE DEFINED_ATTRIBUTES'VAL
                                                        (DI ( XD_POS,
                                                                EVAL_ATTRIBUTE_IDENTIFIER(
                                                                        PREFIX)))
                                                        IS
                  WHEN BASE =>
                                                -- EVALUATE THE 'BASE PREFIX
                     DECLARE
                        BASE_PREFIX:    TREE :=
                                                                D ( AS_NAME,
                                                                PREFIX);
                        BASE_PREFIX_ID:
                                                                TREE;
                        BASE_PREFIX_TYPE:
                                                                TREE;
                     BEGIN
                        WALK_ATTRIBUTE_PREFIX
                                                                (
                                                                BASE_PREFIX
                                                                ,
                                                                BASE_PREFIX_ID
                                                                ,
                                                                BASE_PREFIX_TYPE
                                                                ,
                                                                EVAL_ATTRIBUTE_IDENTIFIER(
                                                                        PREFIX) );
                        IF 
                                                                        BASE_PREFIX_ID.TY IN
                                                                        CLASS_TYPE_NAME THEN
                           PREFIX_ID :=
                                                                        BASE_PREFIX_ID;
                           PREFIX_TYPE_OUT :=
                                                                        GET_BASE_TYPE(
                                                                        BASE_PREFIX_TYPE);
                           PREFIX_TYPE :=
                                                                        PREFIX_TYPE_OUT;
                           PREFIX :=
                                                                        RESOLVE_ATTRIBUTE (
                                                                        PREFIX);
                           D ( AS_NAME,
                                                                        PREFIX,
                                                                        BASE_PREFIX);
                           D ( 
                                                                        SM_EXP_TYPE,
                                                                        PREFIX,
                                                                        TREE_VOID);
                        ELSE
                           ERROR ( D ( 
                                                                                LX_SRCPOS,
                                                                                BASE_PREFIX),
                                                                        "PREFIX OF 'BASE MUST BE A [SUB]TYPE");
                        END IF;
                     END;
                  
                                                -- AND RETURN
                     RETURN;
               
                  WHEN PRED | SUCC | VAL | IMAGE |
                                                        POS | VALUE =>
                                                -- NOTE. THESE CAN BE PREFIX OF 'ADDRESS
                                                -- (ACVC TEST AD7201E.ADA)
                                                -- SEEMS STRANGE FOR 'VAL AND 'POS (NOT REDEFINABLE)
                     DECLARE
                        BASE_PREFIX:    TREE :=
                                                                D ( AS_NAME,
                                                                PREFIX);
                        BASE_PREFIX_ID:
                                                                TREE;
                        BASE_PREFIX_TYPE:
                                                                TREE;
                     BEGIN
                        WALK_ATTRIBUTE_PREFIX
                                                                (
                                                                BASE_PREFIX
                                                                ,
                                                                BASE_PREFIX_ID
                                                                ,
                                                                BASE_PREFIX_TYPE
                                                                ,
                                                                EVAL_ATTRIBUTE_IDENTIFIER(
                                                                        PREFIX) );
                        IF 
                                                                        BASE_PREFIX_ID.TY IN
                                                                        CLASS_TYPE_NAME THEN
                           PREFIX_ID :=
                                                                        TREE_VOID;
                           PREFIX_TYPE_OUT :=
                                                                        TREE_VOID;
                           PREFIX_TYPE :=
                                                                        PREFIX_TYPE_OUT;
                           PREFIX :=
                                                                        RESOLVE_ATTRIBUTE (
                                                                        PREFIX);
                           D ( AS_NAME,
                                                                        PREFIX,
                                                                        BASE_PREFIX);
                           D ( 
                                                                        SM_EXP_TYPE,
                                                                        PREFIX,
                                                                        TREE_VOID);
                        ELSE
                           ERROR ( D ( 
                                                                                LX_SRCPOS,
                                                                                BASE_PREFIX),
                                                                        "PREFIX OF ATTRIBUTE MUST BE A [SUB]TYPE");
                        END IF;
                     
                        RETURN;
                     END;
               
                  WHEN OTHERS =>
                     NULL;
               END CASE;
            END IF;
         
         
                        -- WHEN WE GET HERE, PREFIX MUST BE AN EXPRESSION
                        -- $$$$ NO, IT COULD ALSO BE MEMBER OF ENTRY FAMILY
            EVAL_EXP_TYPES(PREFIX, TYPESET);
         
                        -- $$$$ LIMIT TO NAME OR PREFIX
         
            REQUIRE_UNIQUE_TYPE(PREFIX, TYPESET);
            PREFIX_TYPE_OUT := GET_THE_TYPE(TYPESET);
            PREFIX_TYPE := PREFIX_TYPE_OUT;
            PREFIX := RESOLVE_EXP(PREFIX, PREFIX_TYPE_OUT);
         END IF;
      
      END WALK_ATTRIBUTE_PREFIX;
   
   
       PROCEDURE CHECK_PREFIX_AND_ATTRIBUTE ( ATTRIBUTE_NODE, PREFIX_ID, PREFIX_TYPE :TREE; ATTRIBUTE_SUBTYPE, ATTRIBUTE_VALUE :OUT TREE;
       	PARAMETER :IN OUT TREE; PARAM_TYPESET :IN OUT TYPESET_TYPE;
       	IS_FUNCTION :BOOLEAN ) IS
         USED_NAME_ID	: TREE	:= D ( AS_USED_NAME_ID, ATTRIBUTE_NODE);
         ATTRIBUTE_ID	: TREE	:= D ( SM_DEFN, USED_NAME_ID );
         PREFIX_ERROR	: BOOLEAN	:= FALSE;
         WHICH_ATTRIBUTE	: DEFINED_ATTRIBUTES;
         WHICH_SUBSCRIPT	: INTEGER	:= 1;
         PREFIX_BASE	: CONSTANT TREE	:= GET_BASE_TYPE ( PREFIX_TYPE );
         PREFIX_SUBSTRUCT	: TREE;
      BEGIN
      
                -- RETURN IF ATTRIBUTE_ID IS VOID
         IF ATTRIBUTE_ID = TREE_VOID THEN
            IF PARAMETER /= TREE_VOID THEN
               PARAMETER := RESOLVE_EXP ( PARAMETER, TREE_VOID );
            END IF;
            RETURN;
         END IF;
      
                -- SET DEFAULT RESULTS
         ATTRIBUTE_SUBTYPE := MAKE ( DN_ANY_INTEGER );
         ATTRIBUTE_VALUE := TREE_VOID;
      
                -- CHECK POSSIBLE PREFIXES
         WHICH_ATTRIBUTE := DEFINED_ATTRIBUTES'VAL ( DI ( XD_POS, ATTRIBUTE_ID ) );
         CASE WHICH_ATTRIBUTE IS
            WHEN ADDRESS =>
               ATTRIBUTE_SUBTYPE := PREDEFINED_ADDRESS;
               IF PREDEFINED_ADDRESS = TREE_VOID THEN
                  ERROR ( D ( LX_SRCPOS,ATTRIBUTE_NODE),
                                                "PREDEFINED SYSTEM NOT WITHED");
               END IF;
               IF PREFIX_ID.TY NOT IN CLASS_UNIT_NAME'
                                                FIRST .. DN_ENTRY_ID
                                                AND THEN ( PREFIX_ID.TY /=
                                                DN_TYPE_ID
                                                OR ELSE D ( 
                                                                SM_TYPE_SPEC,
                                                                PREFIX_ID).TY /=
                                                DN_TASK_SPEC
                                                OR ELSE DI ( XD_LEX_LEVEL
                                                        , D ( XD_REGION_DEF,
                                                                GET_DEF_FOR_ID(
                                                                        PREFIX_ID)))
                                                = 0)
                                                AND THEN PREFIX_ID /=
                                                TREE_VOID THEN
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN AFT | FORE =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY =
                                                DN_FIXED THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     IF WHICH_ATTRIBUTE = AFT THEN
                        IF GET_FIXED_SMALL(
                                                                        PREFIX_SUBSTRUCT)
                                                                        >=
                                                                        U_REAL(
                                                                        1,
                                                                        10)
                                                                        THEN
                           ATTRIBUTE_VALUE :=
                                                                        U_VAL(
                                                                        2);
                        ELSE
                           ATTRIBUTE_VALUE :=
                                                                        U_VAL
                                                                        (
                                                                        1 +
                                                                        DIGITS_IN_INTEGER_PART
                                                                        (
                                                                                U_REAL(
                                                                                        1) /
                                                                                GET_FIXED_SMALL
                                                                                (
                                                                                        PREFIX_SUBSTRUCT)));
                        END IF;
                     ELSE -- FORE
                        ATTRIBUTE_VALUE :=
                                                                U_VAL
                                                                ( 1 +
                                                                DIGITS_IN_INTEGER_PART(
                                                                        GET_FIXED_BOUND
                                                                        (
                                                                                PREFIX_SUBSTRUCT )) );
                     END IF;
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN BASE =>
               ERROR ( D ( LX_SRCPOS, D ( AS_USED_NAME_ID,
                                                        ATTRIBUTE_NODE))
                                        , "ATTRIBUTE 'BASE NOT ALLOWED");
            WHEN CALLABLE | TERMINATED =>
               ATTRIBUTE_SUBTYPE := PREDEFINED_BOOLEAN;
               IF PREFIX_ID = TREE_VOID
                                                AND THEN 
                                                GET_APPROPRIATE_BASE(
                                                        PREFIX_TYPE).TY =
                                                DN_TASK_SPEC THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN CONSTRAINED =>
               ATTRIBUTE_SUBTYPE := PREDEFINED_BOOLEAN;
               IF ( PREFIX_ID = TREE_VOID
                                                AND THEN ( 
                                                                GET_APPROPRIATE_BASE(
                                                                        PREFIX_TYPE).TY
                                                        = DN_RECORD
                                                        OR ELSE 
                                                                GET_APPROPRIATE_BASE(
                                                                        PREFIX_TYPE).TY
                                                        IN
                                                        CLASS_PRIVATE_SPEC )
                                                AND THEN NOT IS_EMPTY ( 
                                                        LIST ( D ( 
                                                                        SM_DISCRIMINANT_S
                                                                        ,
                                                                        GET_APPROPRIATE_BASE(
                                                                                PREFIX_TYPE) ))) )
                                                OR ELSE ( PREFIX_ID.TY IN
                                                CLASS_TYPE_NAME
                                                --AND THEN IS_NONLIMITED_TYPE(D ( SM_TYPE_SPEC,PREFIX_ID))
                                                AND THEN IS_PRIVATE_TYPE(
                                                        D ( SM_TYPE_SPEC,
                                                                PREFIX_ID)) )
                                                THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN PRENAME.COUNT =>
               IF PREFIX_ID.TY /= DN_ENTRY_ID THEN
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN DELTA_X =>
               ATTRIBUTE_SUBTYPE := MAKE(DN_ANY_REAL);
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY =
                                                DN_FIXED THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE := D ( 
                                                        SM_ACCURACY,
                                                        PREFIX_SUBSTRUCT);
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN DIGITS_X | EMAX | MACHINE_EMAX | MACHINE_EMIN |
                                        MACHINE_MANTISSA
                                        | MACHINE_RADIX | SAFE_EMAX =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY =
                                                DN_FLOAT THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     CASE WHICH_ATTRIBUTE IS
                        WHEN DIGITS_X =>
                           ATTRIBUTE_VALUE :=
                                                                        D ( 
                                                                        SM_ACCURACY,
                                                                        PREFIX_SUBSTRUCT);
                        WHEN EMAX =>
                           ATTRIBUTE_VALUE :=
                                                                        U_VAL(
                                                                        4)
                                                                        *
                                                                        D ( 
                                                                        SM_ACCURACY,
                                                                        PREFIX_SUBSTRUCT);
                        WHEN MACHINE_EMAX |
                                                                        SAFE_EMAX =>
                                                                -- ($$$ HARD WIRED VALUES FOR MACHINE ATTRIBUTES)
                           IF
                                                                                PREFIX_TYPE =
                                                                                PREDEFINED_FLOAT THEN
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(
                                                                                126);
                           ELSE
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(
                                                                                1022);
                           END IF;
                        WHEN MACHINE_EMIN =>
                           IF
                                                                                PREFIX_TYPE =
                                                                                PREDEFINED_FLOAT THEN
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(-
                                                                                126);
                           ELSE
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(-
                                                                                1022);
                           END IF;
                        WHEN
                                                                        MACHINE_MANTISSA =>
                           IF
                                                                                PREFIX_TYPE =
                                                                                PREDEFINED_FLOAT THEN
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(
                                                                                23);
                           ELSE
                              ATTRIBUTE_VALUE :=
                                                                                U_VAL(
                                                                                51);
                           END IF;
                        WHEN MACHINE_RADIX =>
                           ATTRIBUTE_VALUE :=
                                                                        U_VAL(
                                                                        2);
                        WHEN OTHERS =>
                           PUT_LINE ( "IMPOSSIBLE CASE" );
                           RAISE PROGRAM_ERROR;
                     END CASE;
                  END IF;
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN MANTISSA =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY IN
                                                CLASS_REAL THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     IF PREFIX_SUBSTRUCT.TY =
                                                                DN_FLOAT THEN
                        ATTRIBUTE_VALUE :=
                                                                GET_FLOAT_MANTISSA
                                                                (
                                                                PREFIX_SUBSTRUCT );
                     ELSE
                        ATTRIBUTE_VALUE :=
                                                                GET_FIXED_MANTISSA(
                                                                PREFIX_SUBSTRUCT);
                     END IF;
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN EPSILON =>
               ATTRIBUTE_SUBTYPE := MAKE(DN_ANY_REAL);
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY =
                                                DN_FLOAT THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE := U_REAL(
                                                        1) / (U_VAL(2)
                                                        **
                                                        GET_FLOAT_MANTISSA(
                                                                PREFIX_SUBSTRUCT) );
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN LARGE | SAFE_LARGE | SAFE_SMALL | SMALL =>
               ATTRIBUTE_SUBTYPE := MAKE(DN_ANY_REAL);
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY IN
                                                CLASS_REAL THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF NOT IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     NULL;
                  ELSIF PREFIX_SUBSTRUCT.TY =
                                                        DN_FLOAT THEN
                     CASE WHICH_ATTRIBUTE IS
                        WHEN LARGE =>
                           ATTRIBUTE_VALUE :=
                                                                        (
                                                                        U_REAL(
                                                                                1)
                                                                        -
                                                                        U_REAL(
                                                                                1) /
                                                                        U_VAL(
                                                                                2)
                                                                        **
                                                                        GET_FLOAT_MANTISSA
                                                                        (
                                                                                PREFIX_SUBSTRUCT))
                                                                        *
                                                                        U_VAL(
                                                                        16) **
                                                                        GET_FLOAT_MANTISSA
                                                                        (
                                                                        PREFIX_SUBSTRUCT);
                        WHEN SAFE_LARGE =>
                           IF
                                                                                GET_BASE_TYPE(
                                                                                PREFIX_TYPE) =
                                                                                PREDEFINED_INTEGER THEN
                              ATTRIBUTE_VALUE :=
                                                                                (
                                                                                U_REAL(
                                                                                        1)
                                                                                -
                                                                                U_REAL(
                                                                                        1)/
                                                                                U_VAL(
                                                                                        2)**
                                                                                U_VAL(
                                                                                        23) )
                                                                                *
                                                                                U_VAL(
                                                                                2) **
                                                                                U_VAL(
                                                                                126);
                           ELSE
                              ATTRIBUTE_VALUE :=
                                                                                (
                                                                                U_REAL(
                                                                                        1)
                                                                                -
                                                                                U_REAL(
                                                                                        1)/
                                                                                U_VAL(
                                                                                        2)**
                                                                                U_VAL(
                                                                                        51) )
                                                                                *
                                                                                U_VAL(
                                                                                2) **
                                                                                U_VAL(
                                                                                1022);
                           END IF;
                        WHEN SAFE_SMALL =>
                           IF
                                                                                GET_BASE_TYPE(
                                                                                PREFIX_TYPE) =
                                                                                PREDEFINED_INTEGER THEN
                              ATTRIBUTE_VALUE :=
                                                                                (
                                                                                U_REAL(
                                                                                        1,
                                                                                        2) )
                                                                                /
                                                                                U_VAL(
                                                                                2) **
                                                                                U_VAL(
                                                                                126);
                           ELSE
                              ATTRIBUTE_VALUE :=
                                                                                (
                                                                                U_REAL(
                                                                                        1,
                                                                                        2) )
                                                                                /
                                                                                U_VAL(
                                                                                2) **
                                                                                U_VAL(
                                                                                1022);
                           END IF;
                        WHEN SMALL =>
                           ATTRIBUTE_VALUE :=
                                                                        (
                                                                        U_REAL(
                                                                                1,
                                                                                2) )
                                                                        /
                                                                        U_VAL(
                                                                        16) **
                                                                        GET_FLOAT_MANTISSA
                                                                        (
                                                                        PREFIX_SUBSTRUCT);
                        WHEN OTHERS =>
                           PUT_LINE ( "!! IMPOSSIBLE CASE" );
                           RAISE PROGRAM_ERROR;
                     END CASE;
                  ELSE -- FIXED
                     CASE WHICH_ATTRIBUTE IS
                        WHEN LARGE =>
                           ATTRIBUTE_VALUE :=
                                                                        (
                                                                        U_VAL(
                                                                                2) **
                                                                        GET_FIXED_MANTISSA
                                                                        (
                                                                                PREFIX_SUBSTRUCT)
                                                                        -
                                                                        U_VAL(
                                                                                1) )
                                                                        *
                                                                        GET_FIXED_SMALL
                                                                        (
                                                                        PREFIX_SUBSTRUCT);
                        WHEN SAFE_LARGE =>
                           ATTRIBUTE_VALUE :=
                                                                        GET_STATIC_VALUE(
                                                                        D ( 
                                                                                AS_EXP2,
                                                                                D ( 
                                                                                        SM_RANGE
                                                                                        ,
                                                                                        GET_BASE_TYPE(
                                                                                                PREFIX_TYPE))));
                        WHEN SAFE_SMALL =>
                           ATTRIBUTE_VALUE :=
                                                                        GET_FIXED_SMALL
                                                                        (
                                                                        GET_BASE_TYPE(
                                                                                PREFIX_TYPE));
                        WHEN SMALL =>
                           ATTRIBUTE_VALUE :=
                                                                        GET_FIXED_SMALL
                                                                        (
                                                                        PREFIX_SUBSTRUCT);
                        WHEN OTHERS =>
                           PUT_LINE ( "!! IMPOSSIBLE CASE" );
                           RAISE PROGRAM_ERROR;
                     END CASE;
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN FIRST | LAST | LENGTH =>
                                -- (STATIC VALUE CHECKED LATER WHEN ARGUMENT FOUND)
               NULL;
            WHEN FIRST_BIT | LAST_BIT | POSITION =>
               IF D ( AS_NAME,ATTRIBUTE_NODE).TY =
                                                DN_SELECTED
                                                AND THEN D ( SM_DEFN,D ( 
                                                                AS_DESIGNATOR,
                                                                D ( AS_NAME,
                                                                        ATTRIBUTE_NODE))).TY
                                                IN CLASS_COMP_NAME
                                                THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN IMAGE =>
               IF NOT IS_DISCRETE_TYPE(GET_BASE_TYPE(
                                                        PREFIX_TYPE)) THEN
                  PREFIX_ERROR := TRUE;
               END IF;
               ATTRIBUTE_SUBTYPE := PREDEFINED_STRING;
            WHEN MACHINE_OVERFLOWS | MACHINE_ROUNDS =>
               ATTRIBUTE_SUBTYPE := PREDEFINED_BOOLEAN;
               ATTRIBUTE_VALUE := U_VAL(1);
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY IN
                                                CLASS_REAL THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN POS =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY
                                                IN DN_ENUMERATION ..
                                                DN_INTEGER
                                                THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN PRED | SUCC =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME
                                                AND THEN 
                                                GET_BASE_STRUCT(
                                                        PREFIX_TYPE).TY
                                                IN DN_ENUMERATION ..
                                                DN_INTEGER
                                                THEN
                  ATTRIBUTE_SUBTYPE := D ( 
                                                SM_TYPE_SPEC, PREFIX_ID);
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN RANGE_X =>
            
               IF (	PREFIX_ID.TY IN CLASS_TYPE_NAME
                 	AND THEN GET_SUBSTRUCT( D ( SM_TYPE_SPEC, PREFIX_ID ) ).TY IN CLASS_CONSTRAINED
                 	AND THEN GET_APPROPRIATE_BASE( PREFIX_ID ).TY = DN_ARRAY
               	)
                 OR ELSE (
                 	PREFIX_ID = TREE_VOID
               	AND THEN GET_APPROPRIATE_BASE( PREFIX_TYPE ).TY = DN_ARRAY
               	)
                THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN SIZE =>
               IF PREFIX_ID.TY IN CLASS_TYPE_NAME THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE := D ( 
                                                        CD_IMPL_SIZE,
                                                        PREFIX_SUBSTRUCT);
                  END IF;
               ELSIF PREFIX_ID = TREE_VOID THEN
                                        -- $$$$ CHECK THAT IT IS AN OBJECT
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN STORAGE_SIZE =>
               IF GET_BASE_STRUCT(PREFIX_TYPE).TY =
                                                DN_TASK_SPEC
                                                OR ELSE (
                                                        GET_BASE_STRUCT(
                                                                PREFIX_TYPE).TY =
                                                DN_ACCESS
                                                AND THEN PREFIX_ID.TY IN
                                                CLASS_TYPE_NAME)
                                                THEN
                  NULL;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN VAL | VALUE =>
               IF IS_DISCRETE_TYPE(GET_BASE_TYPE(
                                                        PREFIX_ID)) THEN
                  ATTRIBUTE_SUBTYPE := D ( 
                                                SM_TYPE_SPEC, PREFIX_ID);
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
            WHEN WIDTH =>
               IF IS_DISCRETE_TYPE(GET_BASE_TYPE(
                                                        PREFIX_ID)) THEN
                  PREFIX_SUBSTRUCT := GET_SUBSTRUCT(
                                                D ( SM_TYPE_SPEC,PREFIX_ID));
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE := U_VAL(
                                                        GET_WIDTH(
                                                                PREFIX_SUBSTRUCT));
                  END IF;
               ELSE
                  PREFIX_ERROR := TRUE;
               END IF;
         END CASE;
      
                -- PUT OUT PREFIX ERROR, IF ANY
         IF PREFIX_ERROR THEN
            ERROR ( D ( LX_SRCPOS,ATTRIBUTE_NODE),
                                "INVALID PREFIX FOR ATTRIBUTE");
         END IF;
      
                -- IF THERE WAS A PARAMETER
         IF PARAMETER /= TREE_VOID THEN
         
            IF PREFIX_ID.TY IN CLASS_TYPE_NAME THEN
               PREFIX_SUBSTRUCT := GET_SUBSTRUCT(D ( 
                                                SM_TYPE_SPEC,PREFIX_ID));
            ELSE
               PREFIX_SUBSTRUCT := TREE_VOID;
            END IF;
         
            CASE WHICH_ATTRIBUTE IS
               WHEN IMAGE =>
                  REQUIRE_TYPE(PREFIX_BASE,
                                                PARAMETER, PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
               WHEN POS =>
                  REQUIRE_TYPE(PREFIX_BASE,
                                                PARAMETER, PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE :=
                                                        GET_STATIC_VALUE(
                                                        PARAMETER);
                  END IF;
               WHEN PRED =>
                  REQUIRE_TYPE(PREFIX_BASE,
                                                PARAMETER, PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
                                        -- $$$$ ONLY FOR STATIC SUBTYPE; CHECK CONSTRAINT
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE
                                                        :=
                                                        GET_STATIC_VALUE(
                                                        PARAMETER) - U_VAL(
                                                        1);
                  END IF;
               WHEN SUCC =>
                  REQUIRE_TYPE(PREFIX_BASE,
                                                PARAMETER, PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE
                                                        :=
                                                        GET_STATIC_VALUE(
                                                        PARAMETER) + U_VAL(
                                                        1);
                  END IF;
               WHEN VAL =>
                  REQUIRE_INTEGER_TYPE(PARAMETER,
                                                PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
                  IF IS_STATIC_SUBTYPE(
                                                        PREFIX_SUBSTRUCT) THEN
                     ATTRIBUTE_VALUE :=
                                                        GET_STATIC_VALUE(
                                                        PARAMETER);
                  END IF;
               WHEN VALUE =>
                  REQUIRE_TYPE(PREDEFINED_STRING,
                                                PARAMETER, PARAM_TYPESET);
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER, PARAM_TYPESET);
               WHEN FIRST | LAST | RANGE_X | LENGTH =>
                  IF GET_BASE_STRUCT(
                                                                PREFIX_BASE).TY
                                                        IN CLASS_SCALAR
                                                        THEN
                     ERROR ( D ( LX_SRCPOS,
                                                                PARAMETER),
                                                        "PARAMETER NOT ALLOWED");
                     PARAMETER := RESOLVE_EXP(
                                                        PARAMETER,
                                                        TREE_VOID);
                  ELSE
                     REQUIRE_TYPE(MAKE(
                                                                DN_UNIVERSAL_INTEGER)
                                                        , PARAMETER,
                                                        PARAM_TYPESET);
                     PARAMETER := RESOLVE_EXP(
                                                        PARAMETER,
                                                        PARAM_TYPESET);
                     IF GET_STATIC_VALUE(
                                                                PARAMETER) =
                                                                TREE_VOID THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        PARAMETER)
                                                                ,
                                                                "PARAMETER MUST BE STATIC");
                     ELSE
                        WHICH_SUBSCRIPT :=
                                                                U_POS(
                                                                GET_STATIC_VALUE(
                                                                        PARAMETER));
                     END IF;
                  END IF;
               WHEN OTHERS =>
                  ERROR ( D ( LX_SRCPOS, PARAMETER)
                                                ,
                                                "PARAMETER NOT ALLOWED FOR ATTRIBUTE" );
                  PARAMETER := RESOLVE_EXP(
                                                PARAMETER,TREE_VOID);
            END CASE;
         
         
                        -- ELSE -- SINCE THERE WAS NO PARAMETER
         ELSE
         
            CASE WHICH_ATTRIBUTE IS
               WHEN IMAGE | PRED | SUCC | VALUE =>
                  IF NOT IS_FUNCTION THEN
                     ERROR ( D ( LX_SRCPOS, D ( 
                                                                        AS_USED_NAME_ID,
                                                                        ATTRIBUTE_NODE))
                                                        ,
                                                        "PARAMETER REQUIRED FOR ATTRIBUTE" );
                  END IF;
               WHEN POS | VAL =>
                  IF IS_FUNCTION THEN
                     ERROR ( D ( LX_SRCPOS, D ( 
                                                                        AS_USED_NAME_ID,
                                                                        ATTRIBUTE_NODE))
                                                        ,
                                                        "ATTRIBUTE IS NOT A FUNCTION" );
                  ELSE
                     ERROR ( D ( LX_SRCPOS, D ( 
                                                                        AS_USED_NAME_ID,
                                                                        ATTRIBUTE_NODE))
                                                        ,
                                                        "PARAMETER REQUIRED FOR ATTRIBUTE" );
                  END IF;
               WHEN OTHERS =>
                  IF IS_FUNCTION THEN
                     ERROR ( D ( LX_SRCPOS, D ( 
                                                                        AS_USED_NAME_ID,
                                                                        ATTRIBUTE_NODE))
                                                        ,
                                                        "ATTRIBUTE IS NOT A FUNCTION" );
                  END IF;
            END CASE;
         END IF;
      
         CASE WHICH_ATTRIBUTE IS
            WHEN FIRST | LAST | RANGE_X | LENGTH =>
               DECLARE
                  INDEX: TREE := TREE_VOID;
                  INDEX_LIST: SEQ_TYPE;
                  PREFIX_SUBSTRUCT: TREE :=
                                                PREFIX_TYPE;
               BEGIN
                  IF PREFIX_SUBSTRUCT.TY IN
                                                        DN_PRIVATE ..
                                                        DN_L_PRIVATE THEN
                     PREFIX_SUBSTRUCT := D ( 
                                                        SM_TYPE_SPEC,
                                                        PREFIX_SUBSTRUCT);
                  ELSIF PREFIX_SUBSTRUCT.TY =
                                                        DN_INCOMPLETE THEN
                     PREFIX_SUBSTRUCT := D ( 
                                                        XD_FULL_TYPE_SPEC,
                                                        PREFIX_SUBSTRUCT);
                  END IF;
                  IF PREFIX_SUBSTRUCT.TY =
                                                        DN_ACCESS
                                                        OR ELSE 
                                                        PREFIX_SUBSTRUCT.TY =
                                                        DN_CONSTRAINED_ACCESS THEN
                     PREFIX_SUBSTRUCT := D ( 
                                                        SM_DESIG_TYPE,
                                                        PREFIX_SUBSTRUCT);
                  END IF;
                  IF PREFIX_SUBSTRUCT.TY IN
                                                        DN_PRIVATE ..
                                                        DN_L_PRIVATE THEN
                     PREFIX_SUBSTRUCT := D ( 
                                                        SM_TYPE_SPEC,
                                                        PREFIX_SUBSTRUCT);
                  ELSIF PREFIX_SUBSTRUCT.TY =
                                                        DN_INCOMPLETE THEN
                     PREFIX_SUBSTRUCT := D ( 
                                                        XD_FULL_TYPE_SPEC,
                                                        PREFIX_SUBSTRUCT);
                  END IF;
               
                  IF PREFIX_SUBSTRUCT.TY
                                                        IN CLASS_SCALAR
                                                        THEN
                                                -- $$$$ MAKE SURE WE GET SUBTYPE
                     INDEX := PREFIX_SUBSTRUCT;
                     ATTRIBUTE_SUBTYPE :=
                                                        GET_BASE_TYPE(
                                                        INDEX);
                                                -- $$$$ VALUE ONLY FOR STATIC SUBTYPE
                     IF WHICH_ATTRIBUTE = FIRST THEN
                        IF D ( 
                                                                                SM_RANGE,
                                                                                INDEX).TY =
                                                                        DN_RANGE THEN
                           ATTRIBUTE_VALUE :=
                                                                        GET_STATIC_VALUE
                                                                        (
                                                                        D ( 
                                                                                AS_EXP1,
                                                                                D ( 
                                                                                        SM_RANGE,
                                                                                        INDEX)) );
                        END IF;
                     ELSIF WHICH_ATTRIBUTE =
                                                                LAST THEN
                        IF D ( 
                                                                                SM_RANGE,
                                                                                INDEX).TY =
                                                                        DN_RANGE THEN
                           ATTRIBUTE_VALUE :=
                                                                        GET_STATIC_VALUE
                                                                        (
                                                                        D ( 
                                                                                AS_EXP2,
                                                                                D ( 
                                                                                        SM_RANGE,
                                                                                        INDEX)) );
                        END IF;
                     ELSE
                        ERROR ( D ( LX_SRCPOS,
                                                                        ATTRIBUTE_NODE),
                                                                "ARRAY TYPE REQUIRED");
                     END IF;
                  ELSE
                     PREFIX_SUBSTRUCT :=
                                                        GET_BASE_STRUCT(
                                                        PREFIX_SUBSTRUCT);
                     IF PREFIX_SUBSTRUCT.TY =
                                                                DN_ARRAY THEN
                        INDEX_LIST := LIST ( 
                                                                D ( 
                                                                        SM_INDEX_S,
                                                                        PREFIX_SUBSTRUCT));
                        LOOP
                           IF
                                                                                IS_EMPTY ( 
                                                                                INDEX_LIST) THEN
                              ERROR ( 
                                                                                D ( 
                                                                                        LX_SRCPOS,
                                                                                        PARAMETER),
                                                                                "PARAMETER NOT WITHIN ARRAY DIMENSION");
                              ATTRIBUTE_SUBTYPE :=
                                                                                TREE_VOID;
                              EXIT;
                           ELSE
                              POP ( 
                                                                                INDEX_LIST,
                                                                                INDEX);
                              WHICH_SUBSCRIPT :=
                                                                                WHICH_SUBSCRIPT -
                                                                                1;
                              IF
                                                                                        WHICH_SUBSCRIPT =
                                                                                        0 THEN
                                 IF
                                                                                                WHICH_ATTRIBUTE /=
                                                                                                LENGTH THEN
                                    ATTRIBUTE_SUBTYPE :=
                                                                                                GET_BASE_TYPE
                                                                                                (
                                                                                                D ( 
                                                                                                        SM_TYPE_SPEC,
                                                                                                        INDEX) );
                                 END IF;
                                 EXIT;
                              END IF;
                           END IF;
                        END LOOP;
                     ELSIF PREFIX_SUBSTRUCT /=
                                                                TREE_VOID THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        ATTRIBUTE_NODE),
                                                                "ARRAY TYPE REQUIRED");
                     END IF;
                  END IF;
               END;
         
            WHEN OTHERS =>
               NULL;
         END CASE;
      
      END CHECK_PREFIX_AND_ATTRIBUTE;
   
   
        --PROCEDURE WALK_ATTRIBUTE_FUNCTION(EXP: TREE) IS
        --  PREFIX:         TREE := D ( AS_NAME, EXP);
        --  ATTRIBUTE_ID:   TREE := EVAL_ATTRIBUTE_IDENTIFIER(EXP);
        --  ATTRIBUTE_KIND: DEFINED_ATTRIBUTES;
        --
        --  PREFIX_ID:      TREE;
        --  PREFIX_TYPE:    TREE;
        --BEGIN
        --
        --  -- CHECK ATTRIBUTE IDENTIFIER
        --  IF ATTRIBUTE_ID /= CONST_VOID THEN
        --        ATTRIBUTE_KIND := DEFINED_ATTRIBUTES'VAL(DI(XD_POS,ATTRIBUTE_ID));
        --      CASE ATTRIBUTE_KIND IS
        --      WHEN PRED | SUCC | IMAGE | VALUE =>
        --          NULL;
        --      WHEN OTHERS =>
        --          ERROR(D ( LX_SRCPOS,D ( AS_USED_NAME_ID,EXP))
        --                    , "ATTRIBUTE NOT VALID AS FUNCTION" );
        --          ATTRIBUTE_ID := CONST_VOID;
        --      END CASE;
        --  END IF;
        --
        --  -- RESOLVE THE PREFIX
        --  WALK_ATTRIBUTE_PREFIX
        --          ( PREFIX
        --          , PREFIX_ID
        --          , PREFIX_TYPE
        --          , ATTRIBUTE_ID );
        --
        --  -- STORE THE RESOLVED PREFIX
        --  D ( AS_NAME, EXP, PREFIX);
        --END WALK_ATTRIBUTE_FUNCTION;
   
   
   END ATT_WALK;
