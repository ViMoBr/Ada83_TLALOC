    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	RED_SUBP
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY RED_SUBP IS
      USE VIS_UTIL;
      USE EXP_TYPE, EXPRESO;
      USE DEF_UTIL;
      USE MAKE_NOD;
      USE SET_UTIL;
      USE REQ_UTIL;
      USE DEF_WALK;
      USE ATT_WALK;
      USE AGGRESO;
   
      TYPE ACTUAL_TYPE IS
         RECORD
            SYM:	  TREE;
            EXP:	    TREE;
            TYPESET:	    TYPESET_TYPE;
         END RECORD;
   
      TYPE ACTUAL_ARRAY_TYPE IS ARRAY (POSITIVE RANGE <>) OF ACTUAL_TYPE;
   
   
       FUNCTION LENGTH(LIST: SEQ_TYPE) RETURN NATURAL;
   
       FUNCTION GET_FUNCTION_RESULT_SUBTYPE(NAME_DEFINTERP:
                DEFINTERP_TYPE)
                RETURN TREE;
   
       FUNCTION GET_APPLY_NAME_RESULT_TYPE(NAME_DEFINTERP: DEFINTERP_TYPE)
                RETURN TREE;
   
       FUNCTION STATIC_OP_VALUE(OP_ID: TREE; NORM_PARAM_S: TREE) RETURN
                TREE;
   
       FUNCTION RESOLVE_SLICE
                (NAME: TREE; DISCRETE_RANGE: TREE; TYPE_SPEC: TREE) RETURN
                TREE;
   
       FUNCTION RESOLVE_INDEXED(EXP: TREE) RETURN TREE;
   
       FUNCTION RESOLVE_CONVERSION(EXP: TREE; SUBTYPE_ID: TREE) RETURN
                TREE;
   
       PROCEDURE REDUCE_APPLY_NAMES
                ( NAME: 	TREE
                ; NAME_DEFSET:	IN OUT DEFSET_TYPE
                ; GEN_ASSOC_S:	TREE
                ; INDEX:	TREE := TREE_VOID
                ; IS_SLICE_OUT: OUT BOOLEAN );
   
       PROCEDURE CHECK_ACTUAL_LIST
                ( HEADER:	TREE
                ; ACTUAL:	ACTUAL_ARRAY_TYPE
                ; ACTUALS_OK:	OUT BOOLEAN
                ; EXTRAINFO:	OUT EXTRAINFO_TYPE );
   
       PROCEDURE CHECK_SUBSCRIPT_LIST
                ( ARRAY_TYPE:	TREE
                ; ACTUAL:	ACTUAL_ARRAY_TYPE
                ; ACTUALS_OK:	OUT BOOLEAN
                ; EXTRAINFO:	OUT EXTRAINFO_TYPE );
   
       PROCEDURE REDUCE_ARRAY_PREFIX_TYPES
                ( NAME: 	TREE
                ; NAME_TYPESET: IN OUT TYPESET_TYPE
                ; GEN_ASSOC_S:	TREE
                ; IS_SLICE_OUT: OUT BOOLEAN );
   
       FUNCTION RESOLVE_EXP_OR_UNIV_FIXED(EXP: TREE; TYPE_SPEC: TREE) RETURN
                TREE;
   
       FUNCTION RESOLVE_SUBSCRIPTS
                ( ARRAY_TYPE:		TREE
                ; GENERAL_ASSOC_S:	TREE)
                RETURN TREE;
   
       FUNCTION GET_ARRAY_COMPONENT_TYPE(TYPE_SPEC: TREE) RETURN TREE;
   
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION LENGTH(LIST: SEQ_TYPE) RETURN NATURAL IS
                -- GIVES LENGTH OF A SEQ_TYPE
         LIST_TAIL: SEQ_TYPE := LIST;
         COUNT: NATURAL := 0;
      BEGIN
         WHILE NOT IS_EMPTY(LIST_TAIL) LOOP
            LIST_TAIL := TAIL(LIST_TAIL);
            COUNT := COUNT + 1;
         END LOOP;
         RETURN COUNT;
      END LENGTH;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE EVAL_SUBP_CALL
                        ( EXP:		TREE
                        ; TYPESET:	OUT TYPESET_TYPE )
                        IS
                -- EVALUATES POSSIBLE RESULT TYPES OF APPLY CONSTRUCT
      
         NAME:		TREE := D(AS_NAME, EXP);
         GEN_ASSOC_S:	CONSTANT TREE := D(AS_GENERAL_ASSOC_S, EXP);
         DESIGNATOR:	TREE := TREE_VOID;
      
         NAME_DEFSET:	DEFSET_TYPE;
         NAME_DEFINTERP: DEFINTERP_TYPE;
         NAME_TYPESET:	TYPESET_TYPE;
         NAME_TYPEINTERP:TYPEINTERP_TYPE;
         NAME_STRUCT:	TREE;
         NEW_TYPESET:	TYPESET_TYPE := EMPTY_TYPESET;
         IS_SLICE:	BOOLEAN;
      BEGIN
         IF NAME.TY = DN_STRING_LITERAL THEN
            NAME := MAKE_USED_OP_FROM_STRING(NAME);
         END IF;
      
                -- IF PREFIX IS SIMPLE OR SELECTED NAME
         IF NAME.TY = DN_SELECTED
                                OR NAME.TY IN CLASS_DESIGNATOR THEN
            FIND_VISIBILITY(NAME, NAME_DEFSET);
            IF NOT IS_EMPTY(NAME_DEFSET) THEN
               IF IS_TYPE_DEF(GET_DEF(HEAD(NAME_DEFSET))) THEN
                                        -- CONVERSION
                  ADD_TO_TYPESET
                                                ( NEW_TYPESET
                                                , GET_BASE_TYPE(
                                                        GET_THE_ID(
                                                                NAME_DEFSET)) );
                  STASH_DEFSET(NAME, NAME_DEFSET);
               ELSE
                  REQUIRE_FUNCTION_OR_ARRAY_DEF(
                                                NAME, NAME_DEFSET);
                  REDUCE_APPLY_NAMES(NAME,
                                                NAME_DEFSET, GEN_ASSOC_S
                                                , IS_SLICE_OUT => IS_SLICE );
                  REDUCE_OPERATOR_DEFS(EXP,
                                                NAME_DEFSET);
                  STASH_DEFSET(NAME, NAME_DEFSET);
                  WHILE NOT IS_EMPTY(NAME_DEFSET) LOOP
                     POP(NAME_DEFSET,
                                                        NAME_DEFINTERP);
                     DECLARE
                        RESULT_TYPE: TREE;
                     BEGIN
                        IF IS_SLICE THEN
                           RESULT_TYPE :=
                                                                        GET_BASE_STRUCT
                                                                        (
                                                                        D(
                                                                                XD_SOURCE_NAME
                                                                                ,
                                                                                GET_DEF(
                                                                                        NAME_DEFINTERP) ));
                           IF RESULT_TYPE.TY =
                                                                                DN_ACCESS THEN
                              RESULT_TYPE :=
                                                                                GET_BASE_TYPE
                                                                                (
                                                                                D(
                                                                                        SM_DESIG_TYPE,
                                                                                        RESULT_TYPE) );
                           ELSE
                              RESULT_TYPE :=
                                                                                GET_BASE_TYPE(
                                                                                RESULT_TYPE);
                           END IF;
                        ELSE
                           RESULT_TYPE :=
                                                                        GET_APPLY_NAME_RESULT_TYPE
                                                                        (
                                                                        NAME_DEFINTERP );
                        END IF;
                        ADD_TO_TYPESET
                                                                (
                                                                NEW_TYPESET
                                                                ,
                                                                RESULT_TYPE
                                                                ,
                                                                GET_EXTRAINFO(
                                                                        NAME_DEFINTERP) );
                     END;
                  END LOOP;
               END IF;
            ELSE
                                -- (FOLLOWING FORCES PARAM TO BE EVAL'ED, EVEN THO NO FCN)
               REDUCE_APPLY_NAMES(NAME, NAME_DEFSET,
                                        GEN_ASSOC_S);
               STASH_DEFSET(NAME, NAME_DEFSET);
            END IF;
         
                        -- ELSE -- SINCE PREFIX IS NOT SIMPLE OR SELECTED NAME
         ELSE
         
                        -- PREFIX MUST BE EXPRESSION APPROPRIATE FOR ARRAY TYPE
            EVAL_EXP_TYPES(NAME, NAME_TYPESET);
            REDUCE_ARRAY_PREFIX_TYPES
                                (NAME, NAME_TYPESET, GEN_ASSOC_S, IS_SLICE);
            STASH_TYPESET(NAME, NAME_TYPESET);
            WHILE NOT IS_EMPTY(NAME_TYPESET) LOOP
               POP(NAME_TYPESET, NAME_TYPEINTERP);
               NAME_STRUCT := GET_BASE_STRUCT(GET_TYPE(
                                                NAME_TYPEINTERP));
               IF NAME_STRUCT.TY = DN_ACCESS THEN
                  NAME_STRUCT
                                                := GET_BASE_STRUCT(D(
                                                        SM_DESIG_TYPE,
                                                        NAME_STRUCT));
               END IF;
               IF IS_SLICE THEN
                  ADD_TO_TYPESET
                                                ( NEW_TYPESET
                                                , GET_BASE_TYPE(
                                                        NAME_STRUCT)
                                                , GET_EXTRAINFO(
                                                        NAME_TYPEINTERP) );
               ELSE
                  ADD_TO_TYPESET
                                                ( NEW_TYPESET
                                                , GET_BASE_TYPE(D(
                                                                SM_COMP_TYPE,
                                                                NAME_STRUCT))
                                                , GET_EXTRAINFO(
                                                        NAME_TYPEINTERP) );
               END IF;
            END LOOP;
         END IF;
      
                -- RETURN THE NEW TYPESET
         TYPESET := NEW_TYPESET;
      END EVAL_SUBP_CALL;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GET_FUNCTION_RESULT_SUBTYPE(NAME_DEFINTERP:
                        DEFINTERP_TYPE)
                        RETURN TREE
                        IS
         RESULT_TYPE: TREE := D(AS_NAME, D(XD_HEADER, GET_DEF(
                                        NAME_DEFINTERP)));
         TYPE_MARK_DEFN: TREE;
      BEGIN
         IF RESULT_TYPE.TY IN CLASS_TYPE_SPEC THEN
            RETURN RESULT_TYPE;
         ELSE
            IF RESULT_TYPE.TY = DN_SELECTED THEN
               TYPE_MARK_DEFN := D(SM_DEFN, D(
                                                AS_DESIGNATOR,RESULT_TYPE));
            ELSE
               TYPE_MARK_DEFN := D(SM_DEFN, RESULT_TYPE);
            END IF;
            IF TYPE_MARK_DEFN = TREE_VOID THEN
               RETURN TREE_VOID;
            ELSE
               RETURN D(SM_TYPE_SPEC, TYPE_MARK_DEFN);
            END IF;
         END IF;
      END GET_FUNCTION_RESULT_SUBTYPE;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GET_APPLY_NAME_RESULT_TYPE(NAME_DEFINTERP: DEFINTERP_TYPE)
                        RETURN TREE
                        IS
         NAME_ID: TREE := D(XD_SOURCE_NAME, GET_DEF(NAME_DEFINTERP));
      BEGIN
         CASE NAME_ID.TY IS
            WHEN DN_TYPE_ID | DN_SUBTYPE_ID
                                        | DN_PRIVATE_TYPE_ID |
                                        DN_L_PRIVATE_TYPE_ID =>
               RETURN GET_BASE_TYPE(NAME_ID);
            WHEN DN_FUNCTION_ID | DN_GENERIC_ID =>
               IF IS_NULLARY(NAME_DEFINTERP) THEN
                  RETURN GET_ARRAY_COMPONENT_TYPE(D(
                                                        AS_NAME, D(
                                                                SM_SPEC,
                                                                NAME_ID)));
               ELSE
                  RETURN GET_BASE_TYPE(D(AS_NAME, D(
                                                                SM_SPEC,
                                                                NAME_ID)));
               END IF;
            WHEN DN_OPERATOR_ID | DN_BLTN_OPERATOR_ID =>
               RETURN GET_BASE_TYPE
                                        ( D(AS_NAME, D(XD_HEADER, GET_DEF(
                                                                NAME_DEFINTERP))) );
                        --$$$ WORRY ABOUT EXTRA INFO AND BOOLEAN VALUED OPS
            WHEN OTHERS =>
                                -- $$$ MUST BE EXPRESSION
               RETURN GET_ARRAY_COMPONENT_TYPE(D(
                                                SM_OBJ_TYPE, NAME_ID));
         END CASE;
      END GET_APPLY_NAME_RESULT_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION RESOLVE_FUNCTION_CALL(EXP: TREE; TYPE_SPEC: TREE) RETURN
                        TREE IS
         NAME: TREE := D(AS_NAME, EXP);
         GENERAL_ASSOC_S: TREE := D(AS_GENERAL_ASSOC_S, EXP);
      
         DEFSET: DEFSET_TYPE;
         DEFINTERP: DEFINTERP_TYPE;
         NEW_DEFSET: DEFSET_TYPE := EMPTY_DEFSET;
         DEF_ID: TREE;
         ORIG_DEF_ID: TREE; -- DEF_ID PRIOR TO RENAMING
      BEGIN
      
                -- IF SLICE, RESOLVE AND RETURN SLICE
         IF NOT IS_EMPTY(LIST(GENERAL_ASSOC_S))
                                AND THEN HEAD(LIST(GENERAL_ASSOC_S)).TY IN
                                CLASS_DISCRETE_RANGE THEN
            RETURN RESOLVE_SLICE(NAME, HEAD(LIST(
                                                GENERAL_ASSOC_S)),
                                TYPE_SPEC);
         END IF;
      
                -- IF PREFIX IS SIMPLE OR SELECTED NAME
         IF NAME.TY = DN_SELECTED
                                OR NAME.TY IN CLASS_DESIGNATOR THEN
            DEFSET := FETCH_DEFSET(NAME);
            IF IS_EMPTY(DEFSET) THEN
               NULL;
            ELSIF IS_TYPE_DEF(GET_DEF(HEAD(DEFSET))) THEN
                                -- MUST BE CONVERSION
               NEW_DEFSET := DEFSET;
            ELSIF TYPE_SPEC /= TREE_VOID THEN
               WHILE NOT IS_EMPTY(DEFSET) LOOP
                  POP(DEFSET, DEFINTERP);
                  IF GET_APPLY_NAME_RESULT_TYPE(
                                                        DEFINTERP) =
                                                        TYPE_SPEC
                                                        OR ELSE (TYPE_SPEC.TY = DN_UNIVERSAL_FIXED
                                                        AND THEN GET_BASE_STRUCT
                                                                (
                                                                        GET_APPLY_NAME_RESULT_TYPE(
                                                                                DEFINTERP)).TY
                                                        = DN_FIXED)
                                                        THEN
                     ADD_TO_DEFSET(NEW_DEFSET,
                                                        DEFINTERP);
                  END IF;
               END LOOP;
               IF IS_EMPTY(NEW_DEFSET) THEN
                  ERROR(D(LX_SRCPOS,NAME),
                                                "**** NO VALID DEFS IN RESOLVE");
               END IF;
            END IF;
         
            REQUIRE_UNIQUE_DEF(NAME, NEW_DEFSET);
         
            DEF_ID := GET_THE_ID(NEW_DEFSET);
            NAME := RESOLVE_NAME(NAME, DEF_ID);
            D(AS_NAME, EXP, NAME);
         
            IF IS_EMPTY(NEW_DEFSET) THEN
               RESOLVE_ERRONEOUS_PARAM_S(GENERAL_ASSOC_S);
               D(SM_EXP_TYPE, EXP, TREE_VOID);
               RETURN EXP;
            
            ELSE
               CASE CLASS_DEF_NAME'(DEF_ID.TY) IS
                  WHEN CLASS_OBJECT_NAME =>
                     RETURN RESOLVE_INDEXED(
                                                        EXP);
               
                  WHEN CLASS_TYPE_NAME =>
                                                -- MUST BE A CONVERSION
                     RETURN RESOLVE_CONVERSION(
                                                        EXP, DEF_ID);
               
                  WHEN DN_FUNCTION_ID |
                                                        DN_GENERIC_ID
                                                        |
                                                        DN_BLTN_OPERATOR_ID |
                                                        DN_OPERATOR_ID =>
                     IF IS_NULLARY(HEAD(
                                                                        NEW_DEFSET)) THEN
                        NAME :=
                                                                MAKE_FUNCTION_CALL
                                                                (
                                                                LX_SRCPOS =>
                                                                D(
                                                                        LX_SRCPOS,
                                                                        NAME)
                                                                , AS_NAME =>
                                                                NAME
                                                                ,
                                                                AS_GENERAL_ASSOC_S =>
                                                                MAKE_GENERAL_ASSOC_S
                                                                (
                                                                        LX_SRCPOS =>
                                                                        D(
                                                                                LX_SRCPOS,
                                                                                NAME)
                                                                        ,
                                                                        LIST =>
                                                                        (TREE_NIL,TREE_NIL) )
                                                                ,
                                                                SM_EXP_TYPE =>
                                                                GET_FUNCTION_RESULT_SUBTYPE
                                                                ( HEAD(
                                                                                NEW_DEFSET) ) );
                                                        -- MAKE NORMALIZED_PARAM_S FOR THE DEFAULT PARAMS
                        D(
                                                                SM_NORMALIZED_PARAM_S
                                                                , NAME
                                                                ,
                                                                RESOLVE_SUBP_PARAMETERS
                                                                ( GET_DEF(
                                                                                HEAD(
                                                                                        NEW_DEFSET))
                                                                        ,
                                                                        D(
                                                                                AS_GENERAL_ASSOC_S,
                                                                                NAME) ) );
                        D(AS_NAME, EXP,
                                                                NAME);
                        RETURN
                                                                RESOLVE_INDEXED(
                                                                EXP);
                     ELSE
                        D(SM_EXP_TYPE
                                                                , EXP
                                                                ,
                                                                GET_FUNCTION_RESULT_SUBTYPE
                                                                ( HEAD(
                                                                                NEW_DEFSET) ) );
                        D(
                                                                SM_NORMALIZED_PARAM_S
                                                                , EXP
                                                                ,
                                                                RESOLVE_SUBP_PARAMETERS
                                                                ( GET_DEF(
                                                                                HEAD(
                                                                                        NEW_DEFSET))
                                                                        ,
                                                                        GENERAL_ASSOC_S ) );
                                                        -- WALK BACK THRU RENAMES - LOOK FOR BUILT IN OP
                        ORIG_DEF_ID :=
                                                                DEF_ID;
                        IF ORIG_DEF_ID.TY = DN_OPERATOR_ID THEN
                           WHILE ORIG_DEF_ID.TY IN
                                                                                DN_FUNCTION_ID ..
                                                                                DN_OPERATOR_ID
                                                                                AND THEN D( SM_UNIT_DESC, ORIG_DEF_ID).TY
                                                                                =
                                                                                DN_RENAMES_UNIT
                                                                                LOOP
                              ORIG_DEF_ID :=
                                                                                D(
                                                                                AS_NAME
                                                                                ,
                                                                                D(
                                                                                        SM_UNIT_DESC,
                                                                                        ORIG_DEF_ID) );
                              IF ORIG_DEF_ID.TY =
                                                                                        DN_SELECTED THEN
                                 ORIG_DEF_ID :=
                                                                                        D(
                                                                                        AS_DESIGNATOR,
                                                                                        ORIG_DEF_ID);
                              END IF;
                              ORIG_DEF_ID :=
                                                                                D(
                                                                                SM_DEFN,
                                                                                ORIG_DEF_ID);
                           END LOOP;
                        END IF;
                        IF ORIG_DEF_ID.TY = DN_BLTN_OPERATOR_ID THEN
                           D(
                                                                        SM_VALUE
                                                                        ,
                                                                        EXP
                                                                        ,
                                                                        STATIC_OP_VALUE
                                                                        (
                                                                                ORIG_DEF_ID
                                                                                ,
                                                                                D(
                                                                                        SM_NORMALIZED_PARAM_S,
                                                                                        EXP)));
                        END IF;
                        RETURN EXP;
                     END IF;
               
                  WHEN OTHERS =>
                     PUT_LINE ( "!! RESOLVE_FUNCTION_CALL: INVALID NAME");
                     RAISE PROGRAM_ERROR;
               END CASE;
            END IF;
         
         ELSIF NAME.TY = DN_ATTRIBUTE THEN
            RETURN RESOLVE_ATTRIBUTE(EXP);
         
                        --(CHANGED 6/13/90.  DON'T KNOW WHY THIS WAS HERE; CAUSED
                        --FAILURE ON E.G. INTEGER'IMAGE(12)(2) .)
                        --ELSIF KIND(NAME) = DN_FUNCTION_CALL
                        --AND THEN KIND(D(AS_NAME,NAME)) = DN_ATTRIBUTE THEN
                        --    RETURN RESOLVE_ATTRIBUTE(EXP);
         
         ELSE
            DECLARE
               NAME_TYPESET: TYPESET_TYPE :=
                                        FETCH_TYPESET(NAME);
               NAME_TYPEINTERP: TYPEINTERP_TYPE;
               NAME_STRUCT: TREE;
               NEW_TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
            BEGIN
               WHILE NOT IS_EMPTY(NAME_TYPESET) LOOP
                  POP(NAME_TYPESET, NAME_TYPEINTERP);
                  NAME_STRUCT
                                                := GET_BASE_STRUCT(
                                                GET_TYPE(NAME_TYPEINTERP));
                  IF NAME_STRUCT.TY = DN_ACCESS THEN
                     NAME_STRUCT :=
                                                        GET_BASE_STRUCT
                                                        ( D(SM_DESIG_TYPE,
                                                                NAME_STRUCT) );
                  END IF;
                  IF GET_BASE_TYPE(D(SM_COMP_TYPE,
                                                                NAME_STRUCT))
                                                        = TYPE_SPEC
                                                        OR ELSE ( TYPE_SPEC.TY =
                                                        DN_UNIVERSAL_FIXED
                                                        AND THEN GET_BASE_STRUCT
                                                                (D(
                                                                                SM_COMP_TYPE,
                                                                                NAME_STRUCT)).TY
                                                        = DN_FIXED )
                                                        THEN
                     ADD_TO_TYPESET(
                                                        NEW_TYPESET,
                                                        NAME_TYPEINTERP);
                  END IF;
               END LOOP;
               NAME := RESOLVE_EXP(NAME, NEW_TYPESET);
               D(AS_NAME, EXP, NAME);
            END;
            RETURN RESOLVE_INDEXED(EXP);
         END IF;
      
      END RESOLVE_FUNCTION_CALL;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION STATIC_OP_VALUE(OP_ID: TREE; NORM_PARAM_S: TREE) RETURN
                        TREE IS
         USE UARITH;
         USE PRENAME;
      
         PARAM_TAIL:	SEQ_TYPE := LIST(NORM_PARAM_S);
         FIRST_PARAM:	TREE;
         FIRST_VALUE:	TREE;
         SECOND_VALUE:	TREE;
      BEGIN
                -- GET THE FIRST PARAMETER AND ITS VALUE
         POP(PARAM_TAIL, FIRST_PARAM);
         FIRST_VALUE := GET_STATIC_VALUE(FIRST_PARAM);
      
                -- IF FIRST PARAMETER IS NOT STATIC
         IF FIRST_VALUE = TREE_VOID THEN
         
                        -- NO VALUE; RETURN
            RETURN TREE_VOID;
         END IF;
      
                -- IF THERE IS A SECOND PARAMETER
         IF NOT IS_EMPTY(PARAM_TAIL) THEN
         
                        -- GET ITS VALUE
            SECOND_VALUE := GET_STATIC_VALUE(HEAD(PARAM_TAIL));
         
                        -- IF SECOND PARAMETER IS NOT STATIC
            IF SECOND_VALUE = TREE_VOID THEN
            
                                -- NO VALUE; RETURN
               RETURN TREE_VOID;
            END IF;
         END IF;
      
         CASE OP_CLASS'VAL(DI(SM_OPERATOR, OP_ID)) IS
            WHEN OP_AND =>
               RETURN FIRST_VALUE AND SECOND_VALUE;
            WHEN OP_OR =>
               RETURN FIRST_VALUE OR SECOND_VALUE;
            WHEN OP_XOR =>
               RETURN FIRST_VALUE XOR SECOND_VALUE;
            WHEN OP_NOT =>
               RETURN NOT FIRST_VALUE;
            WHEN OP_UNARY_PLUS =>
               RETURN FIRST_VALUE;
            WHEN OP_UNARY_MINUS =>
               RETURN - FIRST_VALUE;
            WHEN OP_ABS =>
               RETURN ABS FIRST_VALUE;
            WHEN OP_EQ =>
               RETURN U_EQUAL(FIRST_VALUE, SECOND_VALUE);
            WHEN OP_NE =>
               RETURN U_NOT_EQUAL(FIRST_VALUE,
                                        SECOND_VALUE);
            WHEN OP_LT =>
               RETURN FIRST_VALUE < SECOND_VALUE;
            WHEN OP_LE =>
               RETURN FIRST_VALUE <= SECOND_VALUE;
            WHEN OP_GT =>
               RETURN FIRST_VALUE > SECOND_VALUE;
            WHEN OP_GE =>
               RETURN FIRST_VALUE >= SECOND_VALUE;
            WHEN OP_PLUS =>
               RETURN FIRST_VALUE + SECOND_VALUE;
            WHEN OP_MINUS =>
               RETURN FIRST_VALUE - SECOND_VALUE;
            WHEN OP_MULT =>
               RETURN FIRST_VALUE * SECOND_VALUE;
            WHEN OP_DIV =>
               RETURN FIRST_VALUE / SECOND_VALUE;
            WHEN OP_MOD =>
               RETURN FIRST_VALUE MOD SECOND_VALUE;
            WHEN OP_REM =>
               RETURN FIRST_VALUE REM SECOND_VALUE;
            WHEN OP_CAT =>
               RETURN TREE_VOID;
            WHEN OP_EXP =>
               RETURN FIRST_VALUE ** SECOND_VALUE;
         END CASE;
      END STATIC_OP_VALUE;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION RESOLVE_SLICE
                        (NAME: TREE; DISCRETE_RANGE: TREE; TYPE_SPEC: TREE) RETURN
                        TREE
                        IS
         ARRAY_TYPE:	TREE := GET_BASE_STRUCT(TYPE_SPEC);
         INDEX_TYPE:	TREE := TREE_VOID;
         RESOLVED_RANGE: TREE := DISCRETE_RANGE;
         RESOLVED_NAME:	TREE;
      BEGIN
      
                -- CHECK THAT NAME IS ARRAY TYPE
                -- ... AND GET THE INDEX SUBTYPE
         IF ARRAY_TYPE.TY = DN_ACCESS THEN
            ARRAY_TYPE := GET_BASE_STRUCT(D(SM_DESIG_TYPE,
                                        ARRAY_TYPE));
         END IF;
         IF ARRAY_TYPE.TY /= DN_ARRAY THEN
            IF ARRAY_TYPE /= TREE_VOID THEN
               PUT_LINE ( "!! RESOLVE_SLICE: ARRAY TYPE EXPECTED" );
               RAISE PROGRAM_ERROR;
            END IF;
         ELSE
            INDEX_TYPE := GET_BASE_TYPE( D(SM_TYPE_SPEC, HEAD(
                                                LIST
                                                ( D(SM_INDEX_S, ARRAY_TYPE) ) )));
         END IF;
      
                -- RESOLVE THE RANGE IF IT IS AN EXPLICIT RANGE
                -- ... (OTHERWISE IT IS ALREADY RESOLVED)
         IF RESOLVED_RANGE.TY = DN_RANGE THEN
            RESOLVED_RANGE := RESOLVE_DISCRETE_RANGE(
                                RESOLVED_RANGE,INDEX_TYPE);
         END IF;
      
                -- RESOLVE THE NAME
         IF NAME.TY IN CLASS_DESIGNATOR
                                OR ELSE NAME.TY = DN_SELECTED THEN
            DECLARE
               NAME_DEFSET: DEFSET_TYPE := FETCH_DEFSET(
                                        NAME);
               NAME_DEFINTERP: DEFINTERP_TYPE;
               NAME_STRUCT: TREE;
               NEW_DEFSET: DEFSET_TYPE := EMPTY_DEFSET;
            BEGIN
               IF NOT IS_EMPTY(NAME_DEFSET)
                                                AND ARRAY_TYPE /=
                                                TREE_VOID THEN
                  WHILE NOT IS_EMPTY(NAME_DEFSET) LOOP
                     POP(NAME_DEFSET,
                                                        NAME_DEFINTERP);
                     NAME_STRUCT :=
                                                        GET_BASE_STRUCT
                                                        ( D(
                                                                XD_SOURCE_NAME,
                                                                GET_DEF(
                                                                        NAME_DEFINTERP)) );
                     IF NAME_STRUCT.TY =
                                                                DN_ACCESS THEN
                        NAME_STRUCT :=
                                                                GET_BASE_STRUCT
                                                                ( D(
                                                                        SM_DESIG_TYPE,
                                                                        NAME_STRUCT) );
                     END IF;
                     IF NAME_STRUCT =
                                                                ARRAY_TYPE THEN
                        ADD_TO_DEFSET(
                                                                NEW_DEFSET,
                                                                NAME_DEFINTERP);
                     END IF;
                  END LOOP;
                  IF IS_EMPTY(NEW_DEFSET) THEN
                     ERROR(D(LX_SRCPOS,NAME),
                                                        "**** NO DEFS FOR SLICE NAME");
                  END IF;
                  REQUIRE_UNIQUE_DEF(NAME,
                                                NEW_DEFSET);
               END IF;
               RESOLVED_NAME := RESOLVE_EXP
                                        ( NAME
                                        , GET_BASE_TYPE(GET_THE_ID(
                                                        NEW_DEFSET)));
            END;
         ELSE
            DECLARE
               NAME_TYPESET: TYPESET_TYPE :=
                                        FETCH_TYPESET(NAME);
               NAME_TYPEINTERP: TYPEINTERP_TYPE;
               NAME_STRUCT: TREE;
               NEW_TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
            BEGIN
               IF NOT IS_EMPTY(NAME_TYPESET)
                                                AND ARRAY_TYPE /=
                                                TREE_VOID THEN
                  WHILE NOT IS_EMPTY(NAME_TYPESET) LOOP
                     POP(NAME_TYPESET,
                                                        NAME_TYPEINTERP);
                     NAME_STRUCT
                                                        := GET_BASE_STRUCT(
                                                        GET_TYPE(
                                                                NAME_TYPEINTERP));
                     IF NAME_STRUCT.TY =
                                                                DN_ACCESS THEN
                        NAME_STRUCT :=
                                                                GET_BASE_STRUCT
                                                                ( D(
                                                                        SM_DESIG_TYPE,
                                                                        NAME_STRUCT) );
                     END IF;
                     IF NAME_STRUCT =
                                                                ARRAY_TYPE
                                                                THEN
                        ADD_TO_TYPESET(
                                                                NEW_TYPESET,
                                                                NAME_TYPEINTERP);
                     END IF;
                  END LOOP;
                  IF IS_EMPTY(NEW_TYPESET) THEN
                     ERROR(D(LX_SRCPOS,NAME),
                                                        "**** NO TYPES FOR SLICE NAME");
                  END IF;
               END IF;
               RESOLVED_NAME := RESOLVE_EXP(NAME,
                                        NEW_TYPESET);
            END;
         
                        -- MAKE SLICE
         
         END IF;
         RETURN MAKE_SLICE
                        ( LX_SRCPOS => D(LX_SRCPOS, NAME)
                        , AS_NAME => RESOLVED_NAME
                        , AS_DISCRETE_RANGE => RESOLVED_RANGE
                        , SM_EXP_TYPE => TYPE_SPEC );
      
      END RESOLVE_SLICE;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION RESOLVE_INDEXED(EXP: TREE) RETURN TREE IS
                -- EXP IS A FUNCTION_CALL NODE; MAKE IT INDEXED
                -- AS_NAME[EXP] IS ALREADY RESOLVED
      
         NAME:		CONSTANT TREE := D(AS_NAME, EXP);
         GEN_ASSOC_S:	CONSTANT TREE := D(AS_GENERAL_ASSOC_S, EXP);
      
         ARRAY_SUBTYPE:	CONSTANT TREE := D(SM_EXP_TYPE, NAME);
         ARRAY_TYPE:	TREE := GET_BASE_STRUCT(ARRAY_SUBTYPE);
         COMP_SUBTYPE:	TREE;
      BEGIN
      
                -- CHECK THAT NAME IS ARRAY TYPE
         IF ARRAY_TYPE.TY = DN_ACCESS THEN
            ARRAY_TYPE := GET_BASE_STRUCT(D(SM_DESIG_TYPE,
                                        ARRAY_TYPE));
         END IF;
         IF ARRAY_TYPE.TY /= DN_ARRAY THEN
            IF ARRAY_TYPE = TREE_VOID THEN
               RESOLVE_ERRONEOUS_PARAM_S(GEN_ASSOC_S);
               D(SM_EXP_TYPE, EXP, TREE_VOID);
               RETURN EXP;
            ELSE
               PUT_LINE ( "!! RESOLVE_INDEXED: ARRAY TYPE EXPECTED" );
               RAISE PROGRAM_ERROR;
            END IF;
         END IF;
      
                -- GET THE COMPONENT SUBTYPE
         COMP_SUBTYPE := D(SM_COMP_TYPE, ARRAY_TYPE);
      
                -- RESOLVE SUBSCRIPTS, MAKE INDEXED NODE AND RETURN
         RETURN MAKE_INDEXED
                        ( LX_SRCPOS => D(LX_SRCPOS, EXP)
                        , AS_NAME => NAME
                        , AS_EXP_S
                        => RESOLVE_SUBSCRIPTS(ARRAY_TYPE,GEN_ASSOC_S)
                        , SM_EXP_TYPE => COMP_SUBTYPE );
      
      END RESOLVE_INDEXED;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION RESOLVE_CONVERSION(EXP: TREE; SUBTYPE_ID: TREE) RETURN
                        TREE IS
                -- EXP IS A FUNCTION_CALL NODE; MAKE IT CONVERSION
                -- AS_NAME[EXP] IS ALREADY RESOLVED
      
         NAME:		CONSTANT TREE := D(AS_NAME, EXP);
         GEN_ASSOC_S:	CONSTANT TREE := D(AS_GENERAL_ASSOC_S, EXP);
         TARGET_STRUCT:	TREE := GET_BASE_STRUCT(SUBTYPE_ID);
      
         PARAM_LIST:	SEQ_TYPE := LIST(GEN_ASSOC_S);
         PARAM:		TREE;
         PARAM_TYPESET:	TYPESET_TYPE;
         PARAM_TYPEINTERP: TYPEINTERP_TYPE;
         PARAM_STRUCT:	TREE;
         NEW_TYPESET:	TYPESET_TYPE := EMPTY_TYPESET;
      BEGIN
         POP(PARAM_LIST, PARAM);
         IF PARAM.TY = DN_ASSOC THEN
            ERROR(D(LX_SRCPOS,PARAM), "NAMED CONVERSION PARAM");
            PARAM := D(AS_EXP, PARAM);
         END IF;
         IF NOT IS_EMPTY(PARAM_LIST) THEN
            ERROR(D(LX_SRCPOS,HEAD(PARAM_LIST))
                                , "CONVERSION HAS MORE THAN 1 PARAM");
         END IF;
         EVAL_EXP_TYPES(PARAM, PARAM_TYPESET);
      
         IF NOT IS_EMPTY(PARAM_TYPESET)
                                AND THEN TARGET_STRUCT /= TREE_VOID THEN
            CASE TARGET_STRUCT.TY IS
               WHEN DN_INTEGER .. DN_FIXED =>
                  WHILE NOT IS_EMPTY(PARAM_TYPESET) LOOP
                     POP(PARAM_TYPESET,
                                                        PARAM_TYPEINTERP);
                     PARAM_STRUCT :=
                                                        GET_BASE_STRUCT(
                                                        GET_TYPE(
                                                                PARAM_TYPEINTERP));
                     IF PARAM_STRUCT.TY IN
                                                                DN_INTEGER ..
                                                                DN_FIXED
                                                                OR PARAM_STRUCT.TY
                                                                IN
                                                                DN_UNIVERSAL_INTEGER ..
                                                                DN_UNIVERSAL_REAL
                                                                OR PARAM_STRUCT.TY IN
                                                                DN_ANY_INTEGER ..
                                                                DN_ANY_REAL
                                                                THEN
                        ADD_TO_TYPESET
                                                                (
                                                                NEW_TYPESET
                                                                ,
                                                                GET_BASE_TYPE(
                                                                        PARAM_STRUCT)
                                                                ,
                                                                GET_EXTRAINFO(
                                                                        PARAM_TYPEINTERP) );
                     END IF;
                  END LOOP;
               WHEN DN_ARRAY =>
                  WHILE NOT IS_EMPTY(PARAM_TYPESET) LOOP
                     POP(PARAM_TYPESET,
                                                        PARAM_TYPEINTERP);
                     PARAM_STRUCT :=
                                                        GET_BASE_STRUCT(
                                                        GET_TYPE(
                                                                PARAM_TYPEINTERP));
                     IF PARAM_STRUCT.TY =
                                                                DN_ARRAY
                                                                AND THEN
                                                                GET_BASE_TYPE(
                                                                D(
                                                                        SM_COMP_TYPE,
                                                                        TARGET_STRUCT))
                                                                =
                                                                GET_BASE_TYPE(
                                                                D(
                                                                        SM_COMP_TYPE,
                                                                        PARAM_STRUCT))
                                                                THEN
                        DECLARE
                           TARGET_INDEX_LIST:
                                                                        SEQ_TYPE
                                                                        :=
                                                                        LIST(
                                                                        D(
                                                                                SM_INDEX_S,
                                                                                TARGET_STRUCT));
                           TARGET_INDEX:
                                                                        TREE;
                           PARAM_INDEX_LIST:
                                                                        SEQ_TYPE
                                                                        :=
                                                                        LIST(
                                                                        D(
                                                                                SM_INDEX_S,
                                                                                PARAM_STRUCT));
                           PARAM_INDEX:
                                                                        TREE;
                        BEGIN
                           LOOP
                              IF
                                                                                        IS_EMPTY(
                                                                                        TARGET_INDEX_LIST) THEN
                                 IF
                                                                                                IS_EMPTY(
                                                                                                PARAM_INDEX_LIST) THEN
                                    ADD_TO_TYPESET
                                                                                                (
                                                                                                NEW_TYPESET
                                                                                                ,
                                                                                                GET_BASE_TYPE(
                                                                                                        PARAM_STRUCT)
                                                                                                ,
                                                                                                GET_EXTRAINFO(
                                                                                                        PARAM_TYPEINTERP) );
                                 END IF;
                                 EXIT;
                              ELSIF
                                                                                        IS_EMPTY(
                                                                                        PARAM_INDEX_LIST) THEN
                                 EXIT;
                              END IF;
                              POP(
                                                                                TARGET_INDEX_LIST,
                                                                                TARGET_INDEX);
                              POP(
                                                                                PARAM_INDEX_LIST,
                                                                                PARAM_INDEX);
                              TARGET_INDEX :=
                                                                                GET_BASE_TYPE
                                                                                (
                                                                                D(
                                                                                        SM_TYPE_SPEC,
                                                                                        TARGET_INDEX) );
                              PARAM_INDEX :=
                                                                                GET_BASE_TYPE
                                                                                (
                                                                                D(
                                                                                        SM_TYPE_SPEC,
                                                                                        PARAM_INDEX) );
                              IF TARGET_INDEX.TY = DN_INTEGER
                                                                                        AND THEN PARAM_INDEX.TY =
                                                                                        DN_INTEGER THEN
                                 NULL;
                              ELSIF
                                                                                        GET_ANCESTOR_TYPE(
                                                                                        TARGET_INDEX)
                                                                                        =
                                                                                        GET_ANCESTOR_TYPE(
                                                                                        PARAM_INDEX)
                                                                                        THEN
                                 NULL;
                              ELSE
                                 EXIT;
                              END IF;
                           END LOOP;
                        END;
                     END IF;
                  END LOOP;
               WHEN OTHERS =>
                  TARGET_STRUCT := GET_ANCESTOR_TYPE(
                                                TARGET_STRUCT);
                  WHILE NOT IS_EMPTY(PARAM_TYPESET) LOOP
                     POP(PARAM_TYPESET,
                                                        PARAM_TYPEINTERP);
                     PARAM_STRUCT
                                                        :=
                                                        GET_ANCESTOR_TYPE(
                                                        GET_TYPE(
                                                                PARAM_TYPEINTERP));
                     IF PARAM_STRUCT =
                                                                TARGET_STRUCT THEN
                        ADD_TO_TYPESET
                                                                (
                                                                NEW_TYPESET
                                                                ,
                                                                PARAM_TYPEINTERP );
                     END IF;
                  END LOOP;
            END CASE;
         
            IF IS_EMPTY(NEW_TYPESET) THEN
               ERROR(D(LX_SRCPOS, PARAM),
                                        "INVALID TYPE FOR CONVERSION");
            ELSE
               REQUIRE_UNIQUE_TYPE(PARAM, NEW_TYPESET);
            END IF;
         END IF;
      
         PARAM := RESOLVE_EXP(PARAM, NEW_TYPESET);
         RETURN MAKE_CONVERSION
                        ( LX_SRCPOS => D(LX_SRCPOS, EXP)
                        , AS_NAME => NAME
                        , AS_EXP => PARAM
                        , SM_EXP_TYPE => D(SM_TYPE_SPEC, SUBTYPE_ID) );
      END RESOLVE_CONVERSION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REDUCE_APPLY_NAMES
                        ( NAME: 	TREE
                        ; NAME_DEFSET:	IN OUT DEFSET_TYPE
                        ; GEN_ASSOC_S:	TREE
                        ; INDEX:	TREE := TREE_VOID )
                        IS
                -- THIS VERSION CALLED FROM WALK_STM FOR PROCEDURE OR ENTRY CALL
         IS_SLICE: BOOLEAN;
                -- NEVER SET, SINCE NAME IS PROC OR ENTRY
      BEGIN
         REDUCE_APPLY_NAMES
                        ( NAME
                        , NAME_DEFSET
                        , GEN_ASSOC_S
                        , INDEX
                        , IS_SLICE );
      END REDUCE_APPLY_NAMES;
   
   
       PROCEDURE REDUCE_APPLY_NAMES
                        ( NAME: 	TREE
                        ; NAME_DEFSET:	IN OUT DEFSET_TYPE
                        ; GEN_ASSOC_S:	TREE
                        ; INDEX:	TREE := TREE_VOID
                        ; IS_SLICE_OUT: OUT BOOLEAN )
                        IS
         ASSOC_LIST:	SEQ_TYPE := LIST(GEN_ASSOC_S);
         ACTUAL_COUNT:	NATURAL := LENGTH(ASSOC_LIST);
      
         INDEX_TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
      
         ACTUAL: ACTUAL_ARRAY_TYPE (1 .. ACTUAL_COUNT);
         POSITIONAL_LAST: NATURAL := 0;
      
         NAMED_SEEN:		BOOLEAN := FALSE;
         ERROR_SEEN:		BOOLEAN := FALSE;
         IS_SLICE:		BOOLEAN := FALSE;
      
         DEFINTERP:		DEFINTERP_TYPE;
         NEW_DEFSET:		DEFSET_TYPE := EMPTY_DEFSET;
         HEADER: 		TREE;
         NAME_DEF:		TREE;
         NAME_ID:		TREE;
      
         ACTUALS_OK:		BOOLEAN;
         RESULT_STRUCT:		TREE;
      
         EXTRAINFO:		EXTRAINFO_TYPE;
      BEGIN
         IF INDEX /= TREE_VOID THEN
            EVAL_EXP_TYPES(INDEX, INDEX_TYPESET);
         END IF;
      
         FOR I IN ACTUAL'RANGE LOOP
            POP(ASSOC_LIST, ACTUAL(I).EXP);
            IF ACTUAL(I).EXP.TY = DN_ASSOC THEN
               NAMED_SEEN := TRUE;
               ACTUAL(I).SYM := D(LX_SYMREP, D(
                                                AS_USED_NAME, ACTUAL(I).
                                                EXP));
               ACTUAL(I).EXP := D(AS_EXP, ACTUAL(I).EXP);
            ELSE
               IF NAMED_SEEN THEN
                  ERROR(D(LX_SRCPOS, ACTUAL(I).EXP),
                                                "POSITIONAL PARAMETER FOLLOWS NAMED");
                  ERROR_SEEN := TRUE;
               END IF;
               ACTUAL(I).SYM := TREE_VOID;
               POSITIONAL_LAST := I;
            END IF;
         END LOOP;
      
         IF ACTUAL'LAST = 1
                                AND THEN INDEX = TREE_VOID
                                AND THEN NOT NAMED_SEEN THEN
            EVAL_EXP_SUBTYPE_TYPES
                                ( ACTUAL(1).EXP
                                , ACTUAL(1).TYPESET
                                , IS_SLICE );
            IF IS_SLICE
                                        AND THEN ACTUAL(1).EXP.TY /=
                                        DN_RANGE THEN
                                -- (RESOLVE NOW -- USED TO INDICATE SLICE LATER)
               REQUIRE_UNIQUE_TYPE(ACTUAL(1).EXP, ACTUAL(
                                                1).TYPESET);
               ACTUAL(1).EXP := RESOLVE_DISCRETE_RANGE
                                        ( ACTUAL(1).EXP
                                        , GET_THE_TYPE(ACTUAL(1).TYPESET) );
               LIST(GEN_ASSOC_S, SINGLETON(ACTUAL(1).EXP));
            END IF;
         ELSE
            FOR I IN ACTUAL'RANGE LOOP
               EVAL_EXP_TYPES( ACTUAL(I).EXP, ACTUAL(I).
                                        TYPESET );
                                -- NOTE. FOLLOWING USED TO RESOLVE CONV TO UNIV FIXED
               STASH_TYPESET(ACTUAL(I).EXP, ACTUAL(I).
                                        TYPESET);
            END LOOP;
         END IF;
         IS_SLICE_OUT := IS_SLICE;
      
         IF IS_EMPTY(NAME_DEFSET) THEN
            ERROR_SEEN := TRUE;
         END IF;
      
         IF NOT ERROR_SEEN THEN
            WHILE NOT IS_EMPTY (NAME_DEFSET) LOOP
               POP(NAME_DEFSET, DEFINTERP);
            
               ACTUALS_OK := FALSE;
               NAME_DEF := GET_DEF(DEFINTERP);
               NAME_ID := D(XD_SOURCE_NAME, NAME_DEF);
                                -- $$$$ WHAT ABOUT GENERIC
               CASE NAME_ID.TY IS
                  WHEN DN_ENTRY_ID =>
                     HEADER := D(SM_SPEC,
                                                        NAME_ID);
                     IF IS_SLICE THEN
                        NULL;
                     ELSIF HEADER = TREE_VOID THEN
                                                        -- (ERROR IN THE DECLARATION)
                        NULL;
                     ELSIF INDEX /= TREE_VOID THEN
                        IF D(
                                                                        AS_DISCRETE_RANGE,
                                                                        HEADER) /=
                                                                        TREE_VOID THEN
                           CHECK_ACTUAL_TYPE
                                                                        (
                                                                        GET_TYPE_OF_DISCRETE_RANGE
                                                                        (
                                                                                D(
                                                                                        AS_DISCRETE_RANGE,
                                                                                        HEADER) )
                                                                        ,
                                                                        INDEX_TYPESET
                                                                        ,
                                                                        ACTUALS_OK
                                                                        ,
                                                                        EXTRAINFO );
                           IF
                                                                                ACTUALS_OK THEN
                              ADD_EXTRAINFO(
                                                                                DEFINTERP,
                                                                                EXTRAINFO);
                              CHECK_ACTUAL_LIST
                                                                                (
                                                                                HEADER
                                                                                ,
                                                                                ACTUAL
                                                                                ,
                                                                                ACTUALS_OK
                                                                                ,
                                                                                EXTRAINFO );
                              IF
                                                                                        ACTUALS_OK THEN
                                 ADD_EXTRAINFO(
                                                                                        DEFINTERP,
                                                                                        EXTRAINFO);
                              END IF;
                           END IF;
                        END IF;
                     ELSIF D(AS_DISCRETE_RANGE,
                                                                HEADER) /=
                                                                TREE_VOID THEN
                        IF ACTUAL'LAST = 1
                                                                        AND THEN
                                                                        ACTUAL(
                                                                        1).
                                                                        SYM =
                                                                        TREE_VOID THEN
                           CHECK_ACTUAL_TYPE
                                                                        (
                                                                        GET_TYPE_OF_DISCRETE_RANGE
                                                                        (
                                                                                D(
                                                                                        AS_DISCRETE_RANGE,
                                                                                        HEADER) )
                                                                        ,
                                                                        ACTUAL(
                                                                                1).
                                                                        TYPESET
                                                                        ,
                                                                        ACTUALS_OK
                                                                        ,
                                                                        EXTRAINFO );
                           IF
                                                                                ACTUALS_OK THEN
                              ADD_EXTRAINFO(
                                                                                DEFINTERP,
                                                                                EXTRAINFO);
                              CHECK_ACTUAL_LIST
                                                                                (
                                                                                HEADER
                                                                                ,
                                                                                ACTUAL(
                                                                                        1..
                                                                                        0)
                                                                                -- (NULL RANGE)
                                                                                ,
                                                                                ACTUALS_OK
                                                                                ,
                                                                                EXTRAINFO );
                              IF
                                                                                        ACTUALS_OK THEN
                                 ADD_EXTRAINFO(
                                                                                        DEFINTERP,
                                                                                        EXTRAINFO);
                              END IF;
                           END IF;
                        ELSE
                           ACTUALS_OK :=
                                                                        FALSE;
                        END IF;
                     ELSE
                        CHECK_ACTUAL_LIST
                                                                ( HEADER
                                                                , ACTUAL
                                                                ,
                                                                ACTUALS_OK
                                                                ,
                                                                EXTRAINFO );
                        IF ACTUALS_OK THEN
                           ADD_EXTRAINFO(
                                                                        DEFINTERP,
                                                                        EXTRAINFO);
                        END IF;
                     END IF;
                     IF ACTUALS_OK THEN
                        ADD_TO_DEFSET(
                                                                NEW_DEFSET,
                                                                DEFINTERP);
                     END IF;
                  WHEN DN_PROCEDURE_ID |
                                                        DN_OPERATOR_ID
                                                        |
                                                        DN_BLTN_OPERATOR_ID =>
                                                --$$$$ WORRY ABOUT CONVERSIONS WITH BOOLEAN-VALUED OPS
                     HEADER := D(XD_HEADER,
                                                        GET_DEF(DEFINTERP));
                     CHECK_ACTUAL_LIST
                                                        ( HEADER
                                                        , ACTUAL
                                                        , ACTUALS_OK
                                                        , EXTRAINFO );
                     IF ACTUALS_OK AND NOT
                                                                IS_SLICE THEN
                        ADD_EXTRAINFO(
                                                                DEFINTERP,
                                                                EXTRAINFO);
                        ADD_TO_DEFSET(
                                                                NEW_DEFSET,
                                                                DEFINTERP);
                     END IF;
                  WHEN DN_FUNCTION_ID |
                                                        DN_GENERIC_ID =>
                     HEADER := D(XD_HEADER,
                                                        GET_DEF(DEFINTERP));
                     CHECK_ACTUAL_LIST
                                                        ( HEADER
                                                        , ACTUAL
                                                        , ACTUALS_OK
                                                        , EXTRAINFO );
                     IF ACTUALS_OK AND NOT
                                                                IS_SLICE THEN
                        ADD_EXTRAINFO(
                                                                DEFINTERP,
                                                                EXTRAINFO);
                        ADD_TO_DEFSET(
                                                                NEW_DEFSET,
                                                                DEFINTERP);
                     END IF;
                     IF NOT NAMED_SEEN
                                                                AND THEN HEADER.TY = DN_FUNCTION_SPEC
                                                                -- IE, NOT GEN PROC
                                                                THEN
                        RESULT_STRUCT :=
                                                                GET_BASE_STRUCT(
                                                                D(AS_NAME,
                                                                        HEADER));
                        IF RESULT_STRUCT.TY = DN_ACCESS THEN
                           RESULT_STRUCT
                                                                        :=
                                                                        GET_BASE_STRUCT
                                                                        (
                                                                        D(
                                                                                SM_DESIG_TYPE,
                                                                                RESULT_STRUCT) );
                        END IF;
                        IF RESULT_STRUCT.TY = DN_ARRAY
                                                                        AND THEN
                                                                        LENGTH(
                                                                        LIST(
                                                                                D(
                                                                                        SM_INDEX_S,
                                                                                        RESULT_STRUCT)))
                                                                        =
                                                                        ACTUAL'
                                                                        LENGTH
                                                                        THEN
                           CHECK_ACTUAL_LIST
                                                                        (
                                                                        HEADER
                                                                        ,
                                                                        ACTUAL(
                                                                                1..
                                                                                0)
                                                                        -- (NULL RANGE)
                                                                        ,
                                                                        ACTUALS_OK
                                                                        ,
                                                                        EXTRAINFO );
                           IF
                                                                                ACTUALS_OK THEN
                              CHECK_SUBSCRIPT_LIST
                                                                                (
                                                                                RESULT_STRUCT
                                                                                ,
                                                                                ACTUAL
                                                                                ,
                                                                                ACTUALS_OK
                                                                                ,
                                                                                EXTRAINFO );
                           END IF;
                           IF
                                                                                ACTUALS_OK THEN
                              ADD_EXTRAINFO(
                                                                                DEFINTERP,
                                                                                EXTRAINFO);
                              ADD_TO_DEFSET
                                                                                (
                                                                                NEW_DEFSET
                                                                                ,
                                                                                GET_DEF(
                                                                                        DEFINTERP)
                                                                                ,
                                                                                GET_EXTRAINFO(
                                                                                        DEFINTERP)
                                                                                ,
                                                                                IS_NULLARY =>
                                                                                TRUE );
                           END IF;
                        END IF;
                     END IF;
                  WHEN CLASS_OBJECT_NAME =>
                     RESULT_STRUCT :=
                                                        GET_BASE_STRUCT(D(
                                                                SM_OBJ_TYPE,
                                                                NAME_ID));
                     IF RESULT_STRUCT.TY =
                                                                DN_ACCESS THEN
                        RESULT_STRUCT
                                                                :=
                                                                GET_BASE_STRUCT
                                                                ( D(
                                                                        SM_DESIG_TYPE,
                                                                        RESULT_STRUCT) );
                     END IF;
                     IF NOT NAMED_SEEN
                                                                AND THEN RESULT_STRUCT.TY = DN_ARRAY
                                                                AND THEN
                                                                LENGTH(
                                                                LIST(D(
                                                                                SM_INDEX_S,
                                                                                RESULT_STRUCT)))
                                                                = ACTUAL'
                                                                LENGTH
                                                                THEN
                        CHECK_SUBSCRIPT_LIST
                                                                (
                                                                RESULT_STRUCT
                                                                , ACTUAL
                                                                ,
                                                                ACTUALS_OK
                                                                ,
                                                                EXTRAINFO );
                        IF ACTUALS_OK THEN
                           ADD_EXTRAINFO(
                                                                        DEFINTERP,
                                                                        EXTRAINFO);
                           ADD_TO_DEFSET(
                                                                        NEW_DEFSET,
                                                                        DEFINTERP);
                        END IF;
                     END IF;
                  WHEN OTHERS =>
                     ERROR(D(LX_SRCPOS, NAME),
                                                        "NAME NOT VALID IN APPLY");
               END CASE;
            END LOOP;
         
            IF IS_EMPTY(NEW_DEFSET) THEN
               ERROR(D(LX_SRCPOS, NAME),
                                        "PARAMETER TYPE MISMATCH");
            END IF;
         END IF;
      
         NAME_DEFSET := NEW_DEFSET;
      END REDUCE_APPLY_NAMES;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE CHECK_ACTUAL_LIST
                        ( HEADER:	TREE
                        ; ACTUAL:	ACTUAL_ARRAY_TYPE
                        ; ACTUALS_OK:	OUT BOOLEAN
                        ; EXTRAINFO:	OUT EXTRAINFO_TYPE )
                        IS
         ACTUALS_ACCEPTED: NATURAL := 0;
         NAMED_FIRST:	NATURAL;
      
         PARAM_CURSOR:	PARAM_CURSOR_TYPE;
         PARAM_SYM:	TREE;
         NEW_ACTUALS_OK: BOOLEAN;
         NEW_EXTRAINFO:	EXTRAINFO_TYPE := NULL_EXTRAINFO;
         SUB_EXTRAINFO:	EXTRAINFO_TYPE;
         ACTUAL_SEEN:	BOOLEAN;
      BEGIN
         INIT_PARAM_CURSOR(PARAM_CURSOR, LIST(D(AS_PARAM_S, HEADER)));
      
                -- PROCESS POSITIONAL PARAMETERS
         FOR I IN ACTUAL'RANGE LOOP
            EXIT
                                WHEN ACTUAL(I).SYM /= TREE_VOID;
         
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            IF PARAM_CURSOR.ID = TREE_VOID THEN
               ACTUALS_OK := FALSE;
               EXTRAINFO := NULL_EXTRAINFO;
               RETURN;
            END IF;
         
            CHECK_ACTUAL_TYPE
                                ( GET_BASE_TYPE(D(SM_OBJ_TYPE,
                                                PARAM_CURSOR.ID))
                                , ACTUAL(I).TYPESET
                                , NEW_ACTUALS_OK
                                , SUB_EXTRAINFO );
            IF NOT NEW_ACTUALS_OK THEN
               ACTUALS_OK := FALSE;
               EXTRAINFO := NULL_EXTRAINFO;
               RETURN;
            END IF;
         
            ADD_EXTRAINFO(NEW_EXTRAINFO, SUB_EXTRAINFO);
            ACTUALS_ACCEPTED := I;
         END LOOP;
      
                --PROCESS DEFAULT AND NAMED PARAMETERS
         NAMED_FIRST := ACTUALS_ACCEPTED + 1;
         LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            EXIT
                                WHEN PARAM_CURSOR.ID = TREE_VOID;
         
            PARAM_SYM := D(LX_SYMREP, PARAM_CURSOR.ID);
            ACTUAL_SEEN := FALSE;
            FOR I IN NAMED_FIRST .. ACTUAL'LAST LOOP
               IF PARAM_SYM = ACTUAL(I).SYM THEN
                  CHECK_ACTUAL_TYPE
                                                ( GET_BASE_TYPE
                                                ( D(SM_OBJ_TYPE,
                                                                PARAM_CURSOR.ID) )
                                                , ACTUAL(I).TYPESET
                                                , NEW_ACTUALS_OK
                                                , SUB_EXTRAINFO );
                  IF NEW_ACTUALS_OK THEN
                     ACTUAL_SEEN := TRUE;
                     ADD_EXTRAINFO(
                                                        NEW_EXTRAINFO,
                                                        SUB_EXTRAINFO);
                     ACTUALS_ACCEPTED :=
                                                        ACTUALS_ACCEPTED +
                                                        1;
                     EXIT;
                  ELSE
                     ACTUALS_OK := FALSE;
                     EXTRAINFO :=
                                                        NULL_EXTRAINFO;
                     RETURN;
                  END IF;
               END IF;
            END LOOP;
            IF NOT ACTUAL_SEEN
                                        AND THEN D(SM_INIT_EXP,
                                        PARAM_CURSOR.ID) = TREE_VOID THEN
               ACTUALS_OK := FALSE;
               EXTRAINFO := NULL_EXTRAINFO;
               RETURN;
            
            END IF;
         END LOOP;
         IF ACTUALS_ACCEPTED = ACTUAL'LENGTH THEN
            ACTUALS_OK := TRUE;
            EXTRAINFO := NEW_EXTRAINFO;
         ELSE
            ACTUALS_OK := FALSE;
            EXTRAINFO := NULL_EXTRAINFO;
         END IF;
      END CHECK_ACTUAL_LIST;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE REDUCE_ARRAY_PREFIX_TYPES
                        ( NAME: 	TREE
                        ; NAME_TYPESET: IN OUT TYPESET_TYPE
                        ; GEN_ASSOC_S:	TREE
                        ; IS_SLICE_OUT: OUT BOOLEAN )
                        IS
         ASSOC_LIST:	SEQ_TYPE := LIST(GEN_ASSOC_S);
         ACTUAL_COUNT:	NATURAL := LENGTH(ASSOC_LIST);
      
         ACTUAL: ACTUAL_ARRAY_TYPE (1 .. ACTUAL_COUNT);
         ACTUALS_OK: BOOLEAN;
      
         TYPEINTERP:		TYPEINTERP_TYPE;
         NAME_STRUCT:		TREE;
         NEW_TYPESET:		TYPESET_TYPE := EMPTY_TYPESET;
      
         EXTRAINFO:		EXTRAINFO_TYPE;
         IS_SLICE:		BOOLEAN := FALSE;
      BEGIN
         FOR I IN ACTUAL'RANGE LOOP
            POP(ASSOC_LIST, ACTUAL(I).EXP);
            IF ACTUAL(I).EXP.TY = DN_ASSOC THEN
               ERROR(D(LX_SRCPOS,ACTUAL(I).EXP),
                                        "NAMED FOR SUBSCRIPT");
               ACTUAL(I).EXP := D(AS_EXP, ACTUAL(I).EXP);
            END IF;
            ACTUAL(I).SYM := TREE_VOID;
         END LOOP;
      
         IF ACTUAL'LAST = 1 THEN
            EVAL_EXP_SUBTYPE_TYPES
                                ( ACTUAL(1).EXP
                                , ACTUAL(1).TYPESET
                                , IS_SLICE );
            IF IS_SLICE
                                        AND THEN ACTUAL(1).EXP.TY /=
                                        DN_RANGE THEN
                                -- (RESOLVE NOW -- USED TO INDICATE SLICE LATER)
               REQUIRE_UNIQUE_TYPE(ACTUAL(1).EXP, ACTUAL(
                                                1).TYPESET);
               ACTUAL(1).EXP := RESOLVE_DISCRETE_RANGE
                                        ( ACTUAL(1).EXP
                                        , GET_THE_TYPE(ACTUAL(1).TYPESET) );
            END IF;
            LIST(GEN_ASSOC_S, SINGLETON(ACTUAL(1).EXP));
         ELSE
            FOR I IN ACTUAL'RANGE LOOP
               EVAL_EXP_TYPES( ACTUAL(I).EXP, ACTUAL(I).
                                        TYPESET );
            END LOOP;
         END IF;
         IS_SLICE_OUT := IS_SLICE;
      
         IF IS_EMPTY(NAME_TYPESET) THEN
            RETURN;
         END IF;
      
         WHILE NOT IS_EMPTY (NAME_TYPESET) LOOP
            POP(NAME_TYPESET, TYPEINTERP);
         
            ACTUALS_OK := FALSE;
            NAME_STRUCT := GET_BASE_STRUCT(GET_TYPE(
                                        TYPEINTERP));
            IF NAME_STRUCT.TY = DN_ACCESS THEN
               NAME_STRUCT
                                        := GET_BASE_STRUCT
                                        ( D(SM_DESIG_TYPE, NAME_STRUCT) );
            END IF;
            IF NAME_STRUCT.TY = DN_ARRAY
                                        AND THEN LENGTH(LIST(D(SM_INDEX_S,
                                                        NAME_STRUCT)))
                                        = ACTUAL'LENGTH
                                        THEN
               CHECK_SUBSCRIPT_LIST
                                        ( NAME_STRUCT
                                        , ACTUAL
                                        , ACTUALS_OK
                                        , EXTRAINFO );
               IF ACTUALS_OK THEN
                  ADD_EXTRAINFO(TYPEINTERP,
                                                EXTRAINFO);
                  ADD_TO_TYPESET(NEW_TYPESET,
                                                TYPEINTERP);
               END IF;
            END IF;
         END LOOP;
      
         IF IS_EMPTY(NEW_TYPESET) THEN
            ERROR(D(LX_SRCPOS, NAME),
                                "SUBSCRIPT TYPE MISMATCH");
         END IF;
      
         NAME_TYPESET := NEW_TYPESET;
      END REDUCE_ARRAY_PREFIX_TYPES;
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE CHECK_SUBSCRIPT_LIST
                        ( ARRAY_TYPE:	TREE
                        ; ACTUAL:	ACTUAL_ARRAY_TYPE
                        ; ACTUALS_OK:	OUT BOOLEAN
                        ; EXTRAINFO:	OUT EXTRAINFO_TYPE )
                        IS
         INDEX_LIST:	SEQ_TYPE := LIST(D(SM_INDEX_S, ARRAY_TYPE));
         INDEX:		TREE;
         NEW_EXTRAINFO:	EXTRAINFO_TYPE := NULL_EXTRAINFO;
         NEW_ACTUALS_OK: BOOLEAN := TRUE;
         SUB_EXTRAINFO:	EXTRAINFO_TYPE;
      BEGIN
         FOR I IN ACTUAL'RANGE LOOP
            IF IS_EMPTY(INDEX_LIST) THEN
               ACTUALS_OK := FALSE;
               EXTRAINFO := NULL_EXTRAINFO;
               RETURN;
            END IF;
         
            POP(INDEX_LIST, INDEX);
            CHECK_ACTUAL_TYPE
                                ( GET_BASE_TYPE (D(SM_TYPE_SPEC,INDEX))
                                , ACTUAL(I).TYPESET
                                , NEW_ACTUALS_OK
                                , SUB_EXTRAINFO );
            IF NEW_ACTUALS_OK THEN
               ADD_EXTRAINFO(NEW_EXTRAINFO, SUB_EXTRAINFO);
            ELSE
               ACTUALS_OK := FALSE;
               EXTRAINFO := NULL_EXTRAINFO;
               RETURN;
            END IF;
         END LOOP;
      
      
         IF NOT IS_EMPTY(INDEX_LIST) THEN
            ACTUALS_OK := FALSE;
            EXTRAINFO := NULL_EXTRAINFO;
            RETURN;
         END IF;
      
         ACTUALS_OK := TRUE;
         EXTRAINFO := NEW_EXTRAINFO;
      END CHECK_SUBSCRIPT_LIST;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_ACTUAL_TYPE
                        ( FORMAL_TYPE:	 TREE
                        ; ACTUAL_TYPESET: TYPESET_TYPE
                        ; ACTUALS_OK:	OUT BOOLEAN
                        ; EXTRAINFO:	OUT EXTRAINFO_TYPE )
                        IS
         TYPESET:	TYPESET_TYPE := ACTUAL_TYPESET;
         TYPEINTERP:	TYPEINTERP_TYPE;
         TYPE_SPEC:	TREE;
      
         FORMAL_STRUCT:	TREE;
      BEGIN
         ACTUALS_OK := TRUE;
         EXTRAINFO := NULL_EXTRAINFO;
      
         WHILE NOT IS_EMPTY(TYPESET) LOOP
            POP(TYPESET, TYPEINTERP);
         
            TYPE_SPEC:= GET_TYPE(TYPEINTERP);
         
            IF TYPE_SPEC = FORMAL_TYPE THEN
               EXTRAINFO := GET_EXTRAINFO(TYPEINTERP);
               RETURN;
            
            ELSIF TYPE_SPEC.TY IN CLASS_UNSPECIFIED_TYPE THEN
               FORMAL_STRUCT := GET_BASE_STRUCT(
                                        FORMAL_TYPE);
               CASE CLASS_UNSPECIFIED_TYPE'(TYPE_SPEC.TY) IS
                  WHEN DN_ANY_ACCESS =>
                     IF FORMAL_STRUCT.TY =
                                                                DN_ACCESS THEN
                        RETURN;
                     END IF;
                  WHEN DN_ANY_COMPOSITE =>
                     IF
                                                                IS_NONLIMITED_COMPOSITE_TYPE(
                                                                FORMAL_TYPE) THEN
                        RETURN;
                     END IF;
                  WHEN DN_ANY_STRING =>
                     IF IS_STRING_TYPE(
                                                                FORMAL_TYPE) THEN
                        RETURN;
                     END IF;
                  WHEN DN_ANY_ACCESS_OF =>
                     IF FORMAL_STRUCT.TY =
                                                                DN_ACCESS THEN
                        IF GET_BASE_TYPE(
                                                                        D(
                                                                                SM_DESIG_TYPE,
                                                                                FORMAL_STRUCT))
                                                                        =
                                                                        D(
                                                                        XD_ITEM,
                                                                        TYPE_SPEC)
                                                                        THEN
                           RETURN;
                        END IF;
                     END IF;
                  WHEN DN_ANY_INTEGER =>
                     IF IS_INTEGER_TYPE(
                                                                FORMAL_TYPE) THEN
                        RETURN;
                     END IF;
                  WHEN DN_ANY_REAL =>
                     IF IS_REAL_TYPE(
                                                                FORMAL_TYPE) THEN
                        RETURN;
                     END IF;
               END CASE;
            
            ELSIF FORMAL_TYPE.TY = DN_UNIVERSAL_FIXED THEN
               IF GET_BASE_STRUCT(TYPE_SPEC).TY =
                                                DN_FIXED THEN
                  EXTRAINFO := GET_EXTRAINFO(
                                                TYPEINTERP);
                  RETURN;
               END IF;
            END IF;
         END LOOP;
      
         ACTUALS_OK := FALSE;
      END CHECK_ACTUAL_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION RESOLVE_SUBP_PARAMETERS
                        ( DEF:		TREE
                        ; GEN_ASSOC_S:	TREE )
                        RETURN TREE
                        IS
                -- RESOLVES ALL PARAMETER EXPRESSIONS
                -- AND RETURNS THE NORMALIZED PARAMETER LIST
      
         TYPE ACTUAL_TYPE IS
            RECORD
               SYM:	  TREE;
               ASSOC:	    TREE;
            END RECORD;
      
         ACTUAL_LIST: SEQ_TYPE := LIST(GEN_ASSOC_S);
         ACTUAL_TAIL: SEQ_TYPE := ACTUAL_LIST;
      
         ACTUAL: ARRAY ( 1 .. LENGTH(ACTUAL_LIST) ) OF ACTUAL_TYPE;
         POSITIONAL_LAST: NATURAL := 0;
      
         DEF_HEADER: TREE := D(XD_HEADER, DEF);
         PARAM_S: TREE;
      
         PARAM_CURSOR: PARAM_CURSOR_TYPE;
      
         EXP: TREE;
         ACTUAL_SUB: NATURAL;
         NEW_ASSOC_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         NEW_NORM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
      
      BEGIN
      
                -- GET THE SEQUENCE OF PARAMETERS
         IF DEF_HEADER.TY IN CLASS_SUBP_ENTRY_HEADER THEN
            PARAM_S := D(AS_PARAM_S, D(XD_HEADER, DEF));
         ELSE
            PARAM_S := D(AS_PARAM_S, D(SM_SPEC, D(
                                                XD_SOURCE_NAME,DEF)));
         END IF;
      
                -- UNPACK THE ACTUALS
         FOR I IN ACTUAL'RANGE LOOP
            POP(ACTUAL_LIST, ACTUAL(I).ASSOC);
            IF ACTUAL(I).ASSOC.TY = DN_ASSOC THEN
               ACTUAL(I).SYM := D(LX_SYMREP, D(
                                                AS_USED_NAME, ACTUAL(I).
                                                ASSOC));
            ELSE
               ACTUAL(I).SYM := TREE_VOID;
               POSITIONAL_LAST := I;
               ACTUAL_TAIL := ACTUAL_LIST;
            END IF;
         END LOOP;
      
                -- FOR EACH POSITIONAL FORMAL
         INIT_PARAM_CURSOR
                        ( PARAM_CURSOR
                        , LIST(PARAM_S) );
         FOR I IN 1 .. POSITIONAL_LAST LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
         
                        -- RESOLVE THE ASSOCIATED ACTUAL
            EXP := RESOLVE_EXP_OR_UNIV_FIXED
                                (ACTUAL(I).ASSOC, D(SM_OBJ_TYPE,
                                        PARAM_CURSOR.ID));
         
                        -- ADD TO NEW PARAMETER LIST AND NORMALIZED LIST
            NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST, EXP);
            NEW_NORM_LIST := APPEND(NEW_NORM_LIST, EXP);
         END LOOP;
      
                -- ADD NAMED PARAMETERS TO END OF PARAMETER LIST
         IF NOT IS_EMPTY(ACTUAL_TAIL) THEN
            NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST,
                                ACTUAL_TAIL.FIRST);
         END IF;
      
                -- FOR EACH NAMED FORMAL
         LOOP
            ADVANCE_PARAM_CURSOR(PARAM_CURSOR);
            EXIT
                                WHEN PARAM_CURSOR.ID = TREE_VOID;
         
                        -- SEARCH FOR MATCHING PARAMETER
            ACTUAL_SUB := POSITIONAL_LAST + 1;
            WHILE ACTUAL_SUB <= ACTUAL'LAST LOOP
               IF D(LX_SYMREP, PARAM_CURSOR.ID) = ACTUAL(
                                                ACTUAL_SUB).SYM THEN
                  EXIT;
               END IF;
               ACTUAL_SUB := ACTUAL_SUB + 1;
            END LOOP;
         
                        -- IF THERE WAS ONE
            IF ACTUAL_SUB <= ACTUAL'LAST THEN
            
                                -- RESOLVE THE ACTUAL EXPRESSION
               EXP := RESOLVE_EXP_OR_UNIV_FIXED
                                        ( D(AS_EXP, ACTUAL(ACTUAL_SUB).
                                                ASSOC )
                                        , D(SM_OBJ_TYPE,PARAM_CURSOR.ID) );
            
                                -- PUT RESOLVED EXPRESSION IN THE ASSOCIATION
               D(AS_EXP, ACTUAL(ACTUAL_SUB).ASSOC, EXP);
            
                                -- NAME IN ASSOC IS USED NAME ID; CLEAR SM_DEFN
               D(SM_DEFN
                                        , D(AS_USED_NAME, ACTUAL(
                                                        ACTUAL_SUB).ASSOC)
                                        , TREE_VOID );
            
                                -- ELSE -- SINCE NO ACTUAL GIVEN
            ELSE
            
                                -- USE THE DEFAULT EXPRESSION
               EXP := D(SM_INIT_EXP, PARAM_CURSOR.ID);
            END IF;
         
                        -- ADD RESOLVED EXPRESSION TO NORMALIZED LIST
            NEW_NORM_LIST := APPEND(NEW_NORM_LIST, EXP);
         END LOOP;
      
                -- SAVE THE MODIFIED GENERAL_ASSOC_S
         LIST(GEN_ASSOC_S, NEW_ASSOC_LIST);
      
                -- RETURN THE NORMALIZED LIST
         RETURN MAKE_EXP_S(LIST => NEW_NORM_LIST);
      END RESOLVE_SUBP_PARAMETERS;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION RESOLVE_EXP_OR_UNIV_FIXED(EXP: TREE; TYPE_SPEC: TREE) RETURN
                        TREE
                        IS
         TYPESET: TYPESET_TYPE;
         TYPEINTERP: TYPEINTERP_TYPE;
         NEW_TYPESET: TYPESET_TYPE;
      BEGIN
         IF TYPE_SPEC.TY /= DN_UNIVERSAL_FIXED THEN
            IF EXP.TY = DN_AGGREGATE THEN
               RETURN RESOLVE_EXP_OR_AGGREGATE
                                        ( EXP
                                        , TYPE_SPEC
                                        , NAMED_OTHERS_OK
                                        => (TYPE_SPEC.TY =
                                                DN_CONSTRAINED_ARRAY) );
            ELSE
               RETURN RESOLVE_EXP(EXP, GET_BASE_TYPE(
                                                TYPE_SPEC));
            END IF;
         END IF;
      
         TYPESET := FETCH_TYPESET(EXP);
         NEW_TYPESET := EMPTY_TYPESET;
         WHILE NOT IS_EMPTY(TYPESET) LOOP
            POP(TYPESET,TYPEINTERP);
            IF GET_TYPE(TYPEINTERP).TY = DN_FIXED THEN
               ADD_TO_TYPESET(NEW_TYPESET, TYPEINTERP);
            END IF;
         END LOOP;
         IF IS_EMPTY(NEW_TYPESET) THEN
            ERROR(D(LX_SRCPOS,EXP),
                                "**** NO TYPES IN RESOLVE UNIV FIX");
         END IF;
         REQUIRE_UNIQUE_TYPE(EXP, NEW_TYPESET);
         RETURN RESOLVE_EXP(EXP, NEW_TYPESET);
      END RESOLVE_EXP_OR_UNIV_FIXED;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION RESOLVE_SUBSCRIPTS
                        ( ARRAY_TYPE:		TREE
                        ; GENERAL_ASSOC_S:	TREE)
                        RETURN TREE
                        IS
         ASSOC_LIST: SEQ_TYPE := LIST(GENERAL_ASSOC_S);
         NEW_ASSOC_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         EXP: TREE;
      
         INDEX_LIST: SEQ_TYPE;
         INDEX: TREE;
      
      BEGIN
         IF ARRAY_TYPE.TY = DN_ACCESS THEN
            INDEX_LIST := LIST(D(SM_INDEX_S, D(SM_DESIG_TYPE,
                                                ARRAY_TYPE)));
         ELSE
            INDEX_LIST := LIST(D(SM_INDEX_S, ARRAY_TYPE));
         END IF;
      
         WHILE NOT IS_EMPTY(ASSOC_LIST) LOOP
            POP(ASSOC_LIST, EXP);
            POP(INDEX_LIST, INDEX);
            EXP := RESOLVE_EXP(EXP, GET_BASE_TYPE(D(
                                                SM_TYPE_SPEC,INDEX)));
            NEW_ASSOC_LIST := APPEND(NEW_ASSOC_LIST, EXP);
         END LOOP;
      
         RETURN MAKE_EXP_S
                        ( LX_SRCPOS => D(LX_SRCPOS, GENERAL_ASSOC_S)
                        , LIST => NEW_ASSOC_LIST );
      END RESOLVE_SUBSCRIPTS;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_ERRONEOUS_PARAM_S (GENERAL_ASSOC_S: TREE) IS
                -- PARAMETER LIST CAUSED NO FUNCTIONS TO BE SELECTED
                -- RESOLVE ALL PARAMETERS WITH INVALID TYPE
      
         PARAM_LIST: SEQ_TYPE := LIST(GENERAL_ASSOC_S);
         PARAM: TREE;
      BEGIN
      
                -- FOR EACH PARAMETER IN THE PARAM_S
         WHILE NOT IS_EMPTY(PARAM_LIST) LOOP
            POP(PARAM_LIST, PARAM);
         
                        -- IF IT IS A NAMED ASSOCIATION
            IF PARAM.TY = DN_ASSOC THEN
            
                                -- DISCARD THE NAME
               PARAM := D(AS_EXP, PARAM);
            END IF;
         
                        -- RESOLVE PARAMETER AND IGNORE THE RESULT
            PARAM := RESOLVE_EXP(PARAM, TREE_VOID);
         END LOOP;
      END RESOLVE_ERRONEOUS_PARAM_S;
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION GET_ARRAY_COMPONENT_TYPE(TYPE_SPEC: TREE) RETURN TREE IS
         BASE_STRUCT: TREE := GET_BASE_STRUCT(TYPE_SPEC);
      BEGIN
         IF BASE_STRUCT.TY = DN_ACCESS THEN
            BASE_STRUCT := GET_BASE_STRUCT(D(SM_DESIG_TYPE,
                                        BASE_STRUCT));
         END IF;
         RETURN GET_BASE_TYPE(D(SM_COMP_TYPE, BASE_STRUCT));
      END GET_ARRAY_COMPONENT_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_TYPE_OF_DISCRETE_RANGE(DISCRETE_RANGE: TREE) RETURN
                        TREE IS
      BEGIN
         CASE DISCRETE_RANGE.TY IS
            WHEN DN_DISCRETE_SUBTYPE =>
               RETURN GET_TYPE_OF_DISCRETE_RANGE
                                        (D(AS_SUBTYPE_INDICATION,
                                                DISCRETE_RANGE));
            WHEN DN_SUBTYPE_INDICATION =>
               RETURN GET_TYPE_OF_DISCRETE_RANGE(D(
                                                AS_NAME,DISCRETE_RANGE));
            WHEN DN_RANGE | DN_RANGE_ATTRIBUTE =>
               RETURN GET_BASE_TYPE(D(SM_TYPE_SPEC,
                                                DISCRETE_RANGE));
            WHEN CLASS_DESIGNATOR | DN_SELECTED =>
               RETURN GET_BASE_TYPE(DISCRETE_RANGE);
            WHEN OTHERS =>
               PUT_LINE ( "!! GET_TYPE_OF_DISCRETE_RANGE: INVALID PARAMETER" );
               RAISE PROGRAM_ERROR;
         END CASE;
      END GET_TYPE_OF_DISCRETE_RANGE;
   
    --|----------------------------------------------------------------------------------------------
   END RED_SUBP;
