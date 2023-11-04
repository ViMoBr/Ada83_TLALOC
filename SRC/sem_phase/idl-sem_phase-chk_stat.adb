    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	CHK_STAT
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY CHK_STAT IS
      USE EXPRESO;
      USE REQ_UTIL; -- GET_BASE_STRUCT
      
        -- FUNCTIONS TO CHECK FOR STATIC RANGES AND SUBTYPES
        -- THE IMPLEMENTATION OF THESE FUNCTIONS FOLLOWS RM 4.9/11
   
       FUNCTION IS_STATIC_RANGE(A: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN A.TY = DN_RANGE
                        AND THEN GET_STATIC_VALUE(D(AS_EXP1, A)) /=
                        TREE_VOID
                        AND THEN GET_STATIC_VALUE(D(AS_EXP2, A)) /=
                        TREE_VOID;
      END IS_STATIC_RANGE;
   
   
       FUNCTION IS_STATIC_SUBTYPE(A: TREE) RETURN BOOLEAN IS
      BEGIN
         IF A.TY IN CLASS_PRIVATE_SPEC THEN
            RETURN GET_BASE_STRUCT(A).TY IN CLASS_SCALAR
                                AND THEN IS_STATIC_SUBTYPE(D(SM_TYPE_SPEC,
                                        A));
         ELSIF A.TY = DN_INCOMPLETE THEN
            RETURN GET_BASE_STRUCT(A).TY IN CLASS_SCALAR
                                AND THEN IS_STATIC_SUBTYPE(D(
                                        XD_FULL_TYPE_SPEC,A));
         END IF;
      
         IF A.TY NOT IN CLASS_SCALAR THEN
            RETURN FALSE;
         END IF;
      
         IF D(SM_BASE_TYPE, A) = A THEN
                        -- THIS IS A SCALAR BASE TYPE; TEST FOR GENERIC FORMAL TYPE
            RETURN D(SM_RANGE, A) /= TREE_VOID;
         ELSE
                        -- THIS A SUBTYPE, NOT A BASE TYPE
            RETURN IS_STATIC_RANGE(D(SM_RANGE, A))
                                AND THEN IS_STATIC_SUBTYPE(D(SM_TYPE_SPEC,
                                        D(SM_RANGE,A)));
         END IF;
      END IS_STATIC_SUBTYPE;
   
   
       FUNCTION IS_STATIC_DISCRETE_RANGE(A: TREE) RETURN BOOLEAN IS
      BEGIN
         CASE A.TY IS
            WHEN DN_DISCRETE_SUBTYPE =>
               RETURN IS_STATIC_DISCRETE_RANGE(D(
                                                AS_SUBTYPE_INDICATION,A));
            WHEN DN_SUBTYPE_INDICATION =>
               IF D(AS_CONSTRAINT, A) = TREE_VOID THEN
                  RETURN IS_STATIC_DISCRETE_RANGE(D(
                                                        AS_NAME, A));
               ELSE
                  RETURN IS_STATIC_DISCRETE_RANGE(D(
                                                        AS_NAME, A))
                                                AND THEN IS_STATIC_RANGE(
                                                D(AS_CONSTRAINT, A));
               END IF;
            WHEN DN_RANGE =>
               RETURN IS_STATIC_RANGE(A);
            WHEN DN_USED_NAME_ID =>
               RETURN D(SM_DEFN,A) /= TREE_VOID
                                        AND THEN IS_STATIC_DISCRETE_RANGE
                                        ( D(SM_EXP_TYPE,D(SM_DEFN,A)) );
            WHEN DN_SELECTED =>
               RETURN IS_STATIC_DISCRETE_RANGE(D(
                                                AS_DESIGNATOR,A));
            WHEN OTHERS =>
               RETURN FALSE;
         END CASE;
      END IS_STATIC_DISCRETE_RANGE;
   
       FUNCTION IS_STATIC_INDEX_CONSTRAINT(ARRAY_TYPE, INDEX_CONSTRAINT:
                        TREE)
                        RETURN BOOLEAN
                        IS
         INDEX_LIST: SEQ_TYPE := LIST(D(AS_DISCRETE_RANGE_S,
                                INDEX_CONSTRAINT));
         INDEX: TREE;
         ARRAY_TYPE_SPEC: TREE := ARRAY_TYPE;
      BEGIN
         WHILE NOT IS_EMPTY(INDEX_LIST) LOOP
            POP(INDEX_LIST, INDEX);
         
            IF NOT IS_STATIC_DISCRETE_RANGE(INDEX) THEN
               RETURN FALSE;
            END IF;
         END LOOP;
      
         IF ARRAY_TYPE_SPEC.TY IN CLASS_PRIVATE_SPEC THEN
            ARRAY_TYPE_SPEC := D(SM_TYPE_SPEC,ARRAY_TYPE_SPEC);
         ELSIF ARRAY_TYPE_SPEC.TY = DN_INCOMPLETE THEN
            ARRAY_TYPE_SPEC := D(XD_FULL_TYPE_SPEC,
                                ARRAY_TYPE_SPEC);
         END IF;
      
         IF ARRAY_TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY THEN
                        -- $$$$ SHOULD NOT HAPPEN [RM 3.6.1/3]
            RETURN FALSE;
         END IF;
      
         INDEX_LIST := LIST(D(SM_INDEX_S,ARRAY_TYPE_SPEC));
         WHILE NOT IS_EMPTY(INDEX_LIST) LOOP
            POP(INDEX_LIST, INDEX);
            IF NOT IS_STATIC_SUBTYPE(D(SM_TYPE_SPEC, INDEX)) THEN
               RETURN FALSE;
            END IF;
         END LOOP;
      
         RETURN TRUE;
      END IS_STATIC_INDEX_CONSTRAINT;
   
   --|----------------------------------------------------------------------------------------------
   END CHK_STAT;
