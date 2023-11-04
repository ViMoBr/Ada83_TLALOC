    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	DEF_UTIL
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY DEF_UTIL IS
    
      USE VIS_UTIL; -- FOR DEBUG (NODE_REP)
      USE EXPRESO; -- FOR GET_NAME_DEFN
   
      --|-------------------------------------------------------------------------------------------
      --|
       FUNCTION HEADER_IS_HOMOGRAPH ( HEADER_1 :TREE; PARAM_S_2 :TREE; RESULT_TYPE_2 :TREE := TREE_VOID ) RETURN BOOLEAN IS
         KIND_1	: CONSTANT NODE_NAME	:= HEADER_1.TY;
      BEGIN
                
         IF KIND_1 NOT IN CLASS_SUBP_ENTRY_HEADER OR ELSE PARAM_S_2 = TREE_VOID THEN	--| IF HEADER_1 IS NON_OVERLOADABLE OR PARAM_S_2 IS VOID
            RETURN TRUE;				--| ILS SONT HOMOGRAPHES
         END IF;
         
         IF (KIND_1 = DN_FUNCTION_SPEC) XOR (RESULT_TYPE_2 /= TREE_VOID) THEN		--| L'UN FONCTION L'AUTRE NON
            RETURN FALSE;				--| ILS NE SONT PAS HOMOGRAPHES
         END IF;
      
         IF KIND_1 = DN_FUNCTION_SPEC THEN			--| DEUX FONCTIONS
            IF GET_BASE_TYPE ( D ( AS_NAME, HEADER_1 ) ) /= GET_BASE_TYPE ( RESULT_TYPE_2 ) THEN	--| TYPES RETOURNÉS DIFFÉRENTS
               RETURN FALSE;				--| ILS NE SONT PAS HOMOGRAPHES
            END IF;
         END IF;
      
         RETURN IS_SAME_PARAMETER_PROFILE ( D ( AS_PARAM_S, HEADER_1 ), PARAM_S_2 );	--| COMPARER LES PROFILS DE PARAMÈTRES
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION MAKE_DEF_FOR_ID ( ID :TREE; H :H_TYPE ) RETURN TREE IS
         SYMREP	: CONSTANT TREE	:= D ( LX_SYMREP, ID );
         DEF	: TREE	:= MAKE ( DN_DEF );
      BEGIN
         IF H.REGION_DEF /= TREE_VOID AND THEN ID.TY IN CLASS_SOURCE_NAME THEN
            D ( XD_REGION, ID, D ( XD_SOURCE_NAME, H.REGION_DEF));
         END IF;
      
         D ( XD_HEADER, DEF, TREE_TRUE );
         D ( XD_SOURCE_NAME, DEF, ID );
         D ( XD_REGION_DEF, DEF, H.REGION_DEF );
         DB ( XD_IS_IN_SPEC, DEF, H.IS_IN_SPEC );
         DB ( XD_IS_USED, DEF, FALSE );
         DI ( XD_LEX_LEVEL, DEF, 0 );
      
         LIST ( SYMREP, INSERT ( LIST ( SYMREP ), DEF ) );
         RETURN DEF;
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_UNIQUE_SOURCE_NAME_S(SOURCE_NAME_S: TREE) IS
                -- CHECK A SEQUENCE OF NEWLY DECLARED SOURCE NAMES FOR UNIQUENESS
      
         SOURCE_NAME_LIST: SEQ_TYPE := LIST ( SOURCE_NAME_S);
         SOURCE_NAME:	  TREE;
      BEGIN
                -- FOR EACH SOURCE_NAME IN THE SEQUENCE
         WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST) LOOP
            POP ( SOURCE_NAME_LIST, SOURCE_NAME);
         
                        -- GET THE CORRESPONDING DEF NODE AND CHECK FOR UNIQUENESS
            CHECK_UNIQUE_DEF(GET_DEF_FOR_ID(SOURCE_NAME));
         END LOOP;
      END CHECK_UNIQUE_SOURCE_NAME_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_CONSTANT_ID_S(SOURCE_NAME_S: TREE; H: H_TYPE) IS
                -- CHECK A SEQUENCE OF NEWLY DECLARED CONSTANT ID'S FOR PRIOR DECL
      
         SOURCE_NAME_LIST: SEQ_TYPE := LIST ( SOURCE_NAME_S);
         SOURCE_NAME:	  TREE;
      BEGIN
                -- FOR EACH SOURCE_NAME IN THE SEQUENCE
         WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST) LOOP
            POP ( SOURCE_NAME_LIST, SOURCE_NAME);
         
                        -- GET THE CORRESPONDING DEF NODE AND CHECK FOR PRIOR DECL
            CHECK_CONSTANT_DEF(GET_DEF_FOR_ID(SOURCE_NAME), H);
         END LOOP;
      END CHECK_CONSTANT_ID_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_DEF_FOR_ID(ID: TREE) RETURN TREE IS
         DEFLIST:	SEQ_TYPE := LIST ( D ( LX_SYMREP,ID));
         DEF:		TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( DEFLIST) LOOP
            POP ( DEFLIST, DEF);
         
            IF D ( XD_SOURCE_NAME, DEF) = ID THEN
               RETURN DEF;
            END IF;
         END LOOP;
      
         PUT_LINE ( "!! NO DEF FOR ID - " & PRINT_NAME( D ( LX_SYMREP, ID ) ) );
         RAISE PROGRAM_ERROR;
      END GET_DEF_FOR_ID;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_PRIOR_DEF(DEF: TREE) RETURN TREE IS
         REGION_DEF:	CONSTANT TREE := D ( XD_REGION_DEF, DEF);
         HEADER: 	CONSTANT TREE := D ( XD_HEADER, DEF);
         DEFLIST:	SEQ_TYPE := LIST ( D ( LX_SYMREP, D ( XD_SOURCE_NAME,
                                        DEF)));
         PRIOR_DEF:	TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( DEFLIST) LOOP
            POP ( DEFLIST, PRIOR_DEF);
            IF PRIOR_DEF /= DEF
                                        AND THEN D ( XD_REGION_DEF,
                                        PRIOR_DEF) = REGION_DEF THEN
               RETURN PRIOR_DEF;
            END IF;
         END LOOP;
      
         RETURN TREE_VOID;
      END GET_PRIOR_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_PRIOR_HOMOGRAPH_DEF (DEF: TREE)
                        RETURN TREE
                        IS
         HEADER: TREE := D ( XD_HEADER, DEF);
      BEGIN
         IF HEADER.TY = DN_FUNCTION_SPEC THEN
            RETURN GET_PRIOR_HOMOGRAPH_DEF
                                ( DEF
                                , D ( AS_PARAM_S,HEADER)
                                , D ( AS_NAME, HEADER) );
         ELSE -- SINCE IT IS A PROCEDURE_SPEC OR AN ENTRY
            RETURN GET_PRIOR_HOMOGRAPH_DEF
                                ( DEF
                                , D ( AS_PARAM_S,HEADER) );
         END IF;
      END GET_PRIOR_HOMOGRAPH_DEF;
   
       FUNCTION GET_PRIOR_HOMOGRAPH_DEF
                        ( DEF, PARAM_S: TREE
                        ; RESULT_TYPE: TREE := TREE_VOID )
                        RETURN TREE
                        IS
                -- NOTE: DOES NOT FIND DERIVED AND BUILTIN SUBPROGRAMS
         REGION_DEF:	CONSTANT TREE := D ( XD_REGION_DEF, DEF);
         DEFLIST:	SEQ_TYPE := LIST ( D ( LX_SYMREP, D ( XD_SOURCE_NAME,
                                        DEF)));
         PRIOR_DEF:	TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( DEFLIST) LOOP
            POP ( DEFLIST, PRIOR_DEF);
            IF PRIOR_DEF /= DEF
                                        AND THEN D ( XD_SOURCE_NAME, PRIOR_DEF).TY /= DN_BLTN_OPERATOR_ID
                                        AND THEN D ( XD_SOURCE_NAME, PRIOR_DEF).TY NOT IN CLASS_ENUM_LITERAL
                                        AND THEN D ( XD_REGION_DEF, PRIOR_DEF) = REGION_DEF
                                        AND THEN HEADER_IS_HOMOGRAPH ( D ( XD_HEADER, PRIOR_DEF), PARAM_S, RESULT_TYPE )
                                        AND THEN ( D ( XD_SOURCE_NAME, PRIOR_DEF).TY NOT IN CLASS_SUBPROG_NAME
                                        OR ELSE D ( SM_UNIT_DESC ,D ( XD_SOURCE_NAME, PRIOR_DEF ) ).TY /= DN_DERIVED_SUBPROG )
                                        THEN
               RETURN PRIOR_DEF;
            END IF;
         END LOOP;
      
         RETURN TREE_VOID;
      END GET_PRIOR_HOMOGRAPH_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_DEF_IN_REGION(ID: TREE; H: H_TYPE) RETURN TREE
                        IS
         REGION_DEF:	CONSTANT TREE := H.REGION_DEF;
         DEFLIST:	SEQ_TYPE := LIST ( D ( LX_SYMREP, ID));
         PRIOR_DEF:	TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( DEFLIST) LOOP
            POP ( DEFLIST, PRIOR_DEF);
            IF D ( XD_REGION_DEF, PRIOR_DEF) = REGION_DEF THEN
               RETURN PRIOR_DEF;
            END IF;
         END LOOP;
      
         RETURN TREE_VOID;
      END GET_DEF_IN_REGION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_UNIQUE_DEF (SOURCE_DEF: TREE) IS
         PRIOR_DEF:	CONSTANT TREE := GET_PRIOR_DEF(SOURCE_DEF);
         SOURCE_NAME:	TREE;
      BEGIN
         IF PRIOR_DEF /= TREE_VOID THEN
            SOURCE_NAME := D ( XD_SOURCE_NAME, SOURCE_DEF);
            ERROR(D ( LX_SRCPOS, SOURCE_NAME)
                                , "DEFINITION IS NOT UNIQUE - "
                                & PRINT_NAME(D ( LX_SYMREP, SOURCE_NAME)));
            D ( XD_HEADER, SOURCE_DEF, TREE_FALSE);
         ELSE
            D ( XD_HEADER, SOURCE_DEF, TREE_VOID);
         END IF;
      END CHECK_UNIQUE_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_CONSTANT_DEF (SOURCE_DEF: TREE; H: H_TYPE) IS
         SOURCE_ID:	CONSTANT TREE := D ( XD_SOURCE_NAME, SOURCE_DEF);
         PRIOR_DEF:	TREE;
         PRIOR_ID:	TREE;
      BEGIN
                -- IF WE ARE NOT IN PRIVATE PART OF A PACKAGE
         IF (H.IS_IN_SPEC) OR (H.IS_IN_BODY) THEN
         
                        -- CHECK FOR UNIQUENESS AND RETURN
            CHECK_UNIQUE_DEF(SOURCE_DEF);
            RETURN;
         END IF;
      
                -- GET PRIOR DEF, IF ANY
         PRIOR_DEF := GET_PRIOR_DEF(SOURCE_DEF);
         IF PRIOR_DEF = TREE_VOID THEN
            MAKE_DEF_VISIBLE(SOURCE_DEF);
            RETURN;
         ELSE
            PRIOR_ID := D ( XD_SOURCE_NAME, PRIOR_DEF);
         END IF;
      
                -- IF PRIOR DEF IS NOT FOR A DEFERRED CONSTANT
                -- WHICH DOES NOT YET HAVE A FULL DECLARATION
         IF PRIOR_ID.TY /= DN_CONSTANT_ID
                                OR ELSE D ( SM_INIT_EXP, PRIOR_ID) /=
                                TREE_VOID
                                THEN
         
                        -- REPEAT UNIQUENESS CHECK TO PUT OUT ERROR MESSAGE AND RETURN
            CHECK_UNIQUE_DEF(SOURCE_DEF);
            RETURN;
         END IF;
      
                -- YES, IT IS A FULL DECLARATION OF A DEFERRED CONSTANT
      
                -- CHECK CONFORMANCE OF DISCRIMINANT LISTS
                -- AND REMOVE DEF'S FOR DUPLICATED NAMES
                -- $$$$$$ STUB -- MUST DO THIS CHECK --- $$$$$$$
                --	IF KIND ( D ( SM_TYPE_SPEC, SOURCE_ID)) = DN_RECORD THEN
                --	    CONFORM_PARAMETER_LISTS
                --		    ( D ( SM_DISCRIMINANT_S, PRIOR_ID)
                --		    , D ( SM_DISCRIMINANT_S, SOURCE_ID) );
                --	ELSE
                --	    CONFORM_PARAMETER_LISTS
                --		    ( D ( SM_DISCRIMINANT_S, PRIOR_ID)
                --		    , CONST_VOID );
                --	END IF;
      
                -- MAKE SOURCE DEF VISIBLE AND RETURN
         REMOVE_DEF_FROM_ENVIRONMENT(SOURCE_DEF);
         D ( SM_FIRST, SOURCE_ID, PRIOR_ID);
         RETURN;
      END CHECK_CONSTANT_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CHECK_TYPE_DEF (SOURCE_DEF: TREE; H: H_TYPE) IS
         PRIOR_DEF:	CONSTANT TREE := GET_PRIOR_DEF(SOURCE_DEF);
      
         SOURCE_ID:	TREE;
         PRIOR_ID:	TREE;
      
      BEGIN
                -- IF THERE IS NO PRIOR DEF THEN
         IF PRIOR_DEF = TREE_VOID THEN
         
                        -- MAKE SOURCE DEF VISIBLE AND RETURN
            MAKE_DEF_VISIBLE(SOURCE_DEF);
            RETURN;
         END IF;
      
                -- GET ID'S CORRESPONDING TO DEF'S
         SOURCE_ID := D ( XD_SOURCE_NAME, SOURCE_DEF);
         PRIOR_ID := D ( XD_SOURCE_NAME, PRIOR_DEF);
      
                -- IF VALID FULL DECLARATION FOR PRIVATE TYPE
         IF PRIOR_ID.TY IN DN_PRIVATE_TYPE_ID ..
                                DN_L_PRIVATE_TYPE_ID
                                AND THEN NOT H.IS_IN_SPEC
                                AND THEN NOT H.IS_IN_BODY THEN
         
            DECLARE
               PRIVATE_NODE: CONSTANT TREE := D ( 
                                        SM_TYPE_SPEC, PRIOR_ID);
            BEGIN
                                -- IF NOT ALREADY DECLARED
               IF D ( SM_TYPE_SPEC, PRIVATE_NODE) =
                                                TREE_VOID THEN
               
                                        -- MAKE THIS THE FULL TYPE DECLARATION
                  D ( SM_TYPE_SPEC, PRIVATE_NODE, D ( 
                                                        SM_TYPE_SPEC,
                                                        SOURCE_ID));
                  D ( SM_FIRST, SOURCE_ID, PRIOR_ID);
               
                                        -- CHECK CONFORMANCE OF DISCRIMINANT LISTS
                                        -- AND REMOVE DEF'S FOR DUPLICATED NAMES
                  IF D ( SM_TYPE_SPEC, SOURCE_ID).TY =
                                                        DN_RECORD THEN
                     CONFORM_PARAMETER_LISTS
                                                        ( D ( 
                                                                SM_DISCRIMINANT_S,
                                                                PRIOR_ID)
                                                        , D ( 
                                                                SM_DISCRIMINANT_S,
                                                                SOURCE_ID) );
                  ELSE
                     CONFORM_PARAMETER_LISTS
                                                        ( D ( 
                                                                SM_DISCRIMINANT_S,
                                                                PRIOR_ID)
                                                        , TREE_VOID );
                  END IF;
               
                                        -- MAKE SOURCE DEF VISIBLE AND RETURN
                  MAKE_DEF_VISIBLE(SOURCE_DEF);
                  RETURN;
               END IF;
            END;
         END IF;
      
                -- IF POSSIBLE VALID FULL DECLARATION FOR INCOMPLETE TYPE DECLARATION
         IF PRIOR_ID.TY = DN_TYPE_ID
                                AND THEN NOT H.IS_IN_SPEC
                                AND THEN NOT H.IS_IN_BODY THEN
         
            DECLARE
               INCOMPLETE_NODE: CONSTANT TREE := D ( 
                                        SM_TYPE_SPEC, PRIOR_ID);
            BEGIN
                                -- IF PRIOR ID IS INCOMPLETE AND NOT ALREADY DECLARED
               IF INCOMPLETE_NODE.TY = DN_INCOMPLETE
                                                AND THEN D ( 
                                                XD_FULL_TYPE_SPEC,
                                                INCOMPLETE_NODE) =
                                                TREE_VOID THEN
               
                                        -- MAKE THIS THE FULL TYPE DECLARATION
                  D ( XD_FULL_TYPE_SPEC,
                                                INCOMPLETE_NODE
                                                , D ( SM_TYPE_SPEC,
                                                        SOURCE_ID));
                  D ( SM_FIRST, SOURCE_ID, PRIOR_ID);
               
                                        -- REMOVE SOURCE DEF FROM ENVIRONMENT AND RETURN
                  REMOVE_DEF_FROM_ENVIRONMENT(
                                                SOURCE_DEF);
                  RETURN;
               END IF;
            END;
         END IF;
      
                -- TYPE NAME IS NOT UNIQUE
                -- USE CHECK UNIQUE SUBPROGRAM TO GIVE ERROR MESSAGE
         CHECK_UNIQUE_DEF(SOURCE_DEF);
      END CHECK_TYPE_DEF;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION ARE_HOMOGRAPH_HEADERS(HEADER_1, HEADER_2: TREE) RETURN
                        BOOLEAN IS
                -- DETERMINES IF TWO HEADERS ARE HOMOGRAPHS
                -- ONLY CALLED WITH HEADER FROM XD_HEADER ATTRIBUTE OF DEF
                --   (HENCE DO NOT NEED TO CHECK, E.G., DISCRETE_RANGE IN ENTRY)
      
         KIND_1: CONSTANT NODE_NAME := HEADER_1.TY;
         KIND_2: CONSTANT NODE_NAME := HEADER_2.TY;
      BEGIN
                -- IF EITHER HEADER IS NON_OVERLOADABLE
         IF KIND_1 NOT IN CLASS_SUBP_ENTRY_HEADER
                                OR KIND_2 NOT IN CLASS_SUBP_ENTRY_HEADER THEN
         
                        -- THEY ARE HOMOGRAPHS
            RETURN TRUE;
         
                        -- ELSE -- SINCE BOTH ARE OVERLOADABLE
         ELSE
         
                        -- SPLIT UP HEADER_2 AND CALL HEADER_IS_HOMOGRAPH
            IF KIND_2 = DN_FUNCTION_SPEC THEN
               RETURN HEADER_IS_HOMOGRAPH
                                        ( HEADER_1
                                        , D ( AS_PARAM_S, HEADER_2)
                                        , D ( AS_NAME, HEADER_2) );
            ELSE
               RETURN HEADER_IS_HOMOGRAPH
                                        ( HEADER_1
                                        , D ( AS_PARAM_S, HEADER_2) );
            END IF;
         END IF;
      END ARE_HOMOGRAPH_HEADERS;
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_SAME_PARAMETER_PROFILE (PARAM_S_1, PARAM_S_2: TREE)
                        RETURN BOOLEAN
                        IS
         PARAM_LIST_1:	SEQ_TYPE := LIST ( PARAM_S_1);
         PARAM_LIST_2:	SEQ_TYPE := LIST ( PARAM_S_2);
         PARAM_1, PARAM_2: TREE;
         ID_LIST_1, ID_LIST_2: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         ID_1, ID_2: TREE;
      BEGIN
                -- LOOP THROUGH BOTH PARAMETER LISTS
         LOOP
         
                        -- GET NEXT ELEMENT FROM PARAM_LIST_1, IF ANY
            IF IS_EMPTY ( ID_LIST_1) THEN
               IF IS_EMPTY ( PARAM_LIST_1) THEN
               
                                        -- THERE IS NONE
                                        -- COMPATIBLE IF NO NEXT ELEMENT IN PARAM_LIST_2
                  RETURN IS_EMPTY ( ID_LIST_2) AND THEN
                                                IS_EMPTY ( PARAM_LIST_2);
               ELSE
                  POP ( PARAM_LIST_1, PARAM_1);
                  ID_LIST_1 := LIST ( D ( 
                                                        AS_SOURCE_NAME_S,
                                                        PARAM_1));
               END IF;
            END IF;
            POP ( ID_LIST_1, ID_1);
         
                        -- GET NEXT ELEMENT FROM PARAM_LIST_2, IF ANY
            IF IS_EMPTY ( ID_LIST_2) THEN
               IF IS_EMPTY ( PARAM_LIST_2) THEN
               
                                        -- THERE IS NONE
                                        -- NOT COMPATIBLE SINCE THERE WAS AN ELEMENT ON PARAM_LIST_1
                  RETURN FALSE;
               ELSE
                  POP ( PARAM_LIST_2, PARAM_2);
                  ID_LIST_2 := LIST ( D ( 
                                                        AS_SOURCE_NAME_S,
                                                        PARAM_2));
               END IF;
            END IF;
            POP ( ID_LIST_2, ID_2);
         
                        -- IF THEY ARE NOT OF THE SAME TYPE,
            IF GET_BASE_TYPE(D ( SM_OBJ_TYPE, ID_1))
                                        /= GET_BASE_TYPE(D ( SM_OBJ_TYPE,
                                                ID_2))
                                        THEN
                                -- THEN THEY ARE NOT COMPATIBLE
               RETURN FALSE;
            END IF;
         END LOOP;
      END IS_SAME_PARAMETER_PROFILE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE CONFORM_PARAMETER_LISTS(PARAM_S_1, PARAM_S_2: TREE) IS
         PARAM_LIST_1:	SEQ_TYPE := LIST ( PARAM_S_1);
         PARAM_LIST_2:	SEQ_TYPE := LIST ( PARAM_S_2);
         PARAM_1, PARAM_2: TREE;
         ID_LIST_1, ID_LIST_2: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         ID_1, ID_2: TREE;
      
      BEGIN
                -- IF PARAMETER LISTS ARE THE SAME
         IF PARAM_S_1 = PARAM_S_2 THEN
         
                        -- MUST BE FROM A GENERATED LIBRARY UNIT
                        -- ... SO, DO NOT CONFORM (I.E. DO NOT REMOVE DEFS)
            RETURN;
         END IF;
      
                -- LOOP THROUGH BOTH PARAMETER LISTS
         LOOP
         
                        -- CHECK THAT STRUCTURE OF LISTS IS COMPATIBLE
            IF (IS_EMPTY ( ID_LIST_1) XOR IS_EMPTY ( ID_LIST_2))
                                        OR (IS_EMPTY ( PARAM_LIST_1) XOR
                                        IS_EMPTY ( PARAM_LIST_2)) THEN
               EXIT;
            
                                -- GET NEXT ELEMENT FROM PARAM_LISTS, IF ANY
                                -- RETURN IF NO MORE ELEMENTS
            END IF;
            IF IS_EMPTY ( ID_LIST_1) THEN
               IF IS_EMPTY ( PARAM_LIST_1) THEN
                  RETURN;
               ELSE
                  POP ( PARAM_LIST_1, PARAM_1);
                  POP ( PARAM_LIST_2, PARAM_2);
                  ID_LIST_1 := LIST ( D (AS_SOURCE_NAME_S, PARAM_1));
                  ID_LIST_2 := LIST ( D ( 
                                                        AS_SOURCE_NAME_S,
                                                        PARAM_2));
               
                  IF PARAM_1.TY /= PARAM_2.TY THEN
                     EXIT;
                  END IF;
               
                  IF NOT IS_COMPATIBLE_EXPRESSION
                                                        ( D ( AS_NAME,
                                                                PARAM_1)
                                                        , D ( AS_NAME,
                                                                PARAM_2) )
                                                        OR ELSE NOT
                                                        IS_COMPATIBLE_EXPRESSION
                                                        ( D ( AS_EXP,
                                                                PARAM_1)
                                                        , D ( AS_EXP,
                                                                PARAM_2) )
                                                        THEN
                     EXIT;
                  END IF;
               END IF;
            END IF;
         
            POP ( ID_LIST_1, ID_1);
         
            IF D ( LX_SYMREP, ID_1) /= D ( LX_SYMREP, HEAD(
                                                ID_LIST_2)) THEN
               EXIT;
            END IF;
         
            POP ( ID_LIST_2, ID_2);
         
                        -- ID'S ARE COMPATIBLE, REPLACE DEFS
            D ( SM_FIRST, ID_2, D ( SM_FIRST, ID_1));
            D ( XD_REGION, ID_2, D ( XD_REGION, ID_1));
            D ( SM_INIT_EXP, ID_2, D ( SM_INIT_EXP, ID_1));
            D ( SM_OBJ_TYPE, ID_2, D ( SM_OBJ_TYPE, ID_1));
            REMOVE_DEF_FROM_ENVIRONMENT(GET_DEF_FOR_ID(ID_2));
         
         END LOOP;
      
                -- INCOMPATIBLE, SINCE WE EXITED FROM LOOP
         ERROR(D ( LX_SRCPOS,PARAM_S_2), "PARAM LISTS NOT COMPATIBLE");
      
                -- DISCARD DEFS FROM SECOND LIST ANYWAY
         LOOP
            WHILE NOT IS_EMPTY ( ID_LIST_2) LOOP
               POP ( ID_LIST_2, ID_2);
               REMOVE_DEF_FROM_ENVIRONMENT(
                                        GET_DEF_FOR_ID(ID_2));
            END LOOP;
            EXIT
                                WHEN IS_EMPTY ( PARAM_LIST_2);
            POP ( PARAM_LIST_2, PARAM_2);
            ID_LIST_2 := LIST ( D ( AS_SOURCE_NAME_S,PARAM_2));
         END LOOP;
      
      END CONFORM_PARAMETER_LISTS;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION IS_COMPATIBLE_EXPRESSION (EXP_1, EXP_2: TREE) RETURN
                        BOOLEAN IS
                -- ARGUMENTS ARE EXPRESSIONS OR RANGES OR VOID
                -- RETURN TRUE IF COMPATIBLE (WITHIN PARAM OR DSCRMT LIST)
      BEGIN
                -- $$$$$$$$ STUB $$$$$$$
         RETURN TRUE;
      END IS_COMPATIBLE_EXPRESSION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE MAKE_DEF_VISIBLE(DEF: TREE; HEADER: TREE := TREE_VOID) IS
      BEGIN
         D ( XD_HEADER, DEF, HEADER);
      END MAKE_DEF_VISIBLE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE MAKE_DEF_IN_ERROR(DEF: TREE) IS
      BEGIN
         D ( XD_HEADER, DEF, TREE_FALSE);
      END MAKE_DEF_IN_ERROR;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE REMOVE_DEF_FROM_ENVIRONMENT(DEF: TREE) IS
      BEGIN
         D ( XD_HEADER, DEF, TREE_VOID);
         D ( XD_REGION_DEF, DEF, TREE_VOID);
         DI ( XD_LEX_LEVEL, DEF, 0);
         DB ( XD_IS_USED, DEF, FALSE);
      END REMOVE_DEF_FROM_ENVIRONMENT;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_DEF_EXP_TYPE(DEF: TREE) RETURN TREE IS
         HEADER: CONSTANT TREE := D ( XD_HEADER,DEF);
         SOURCE_NAME: TREE := D ( XD_SOURCE_NAME, DEF);
      BEGIN
         IF HEADER.TY = DN_FUNCTION_SPEC THEN
            RETURN GET_BASE_TYPE(D ( AS_NAME,HEADER));
         ELSIF SOURCE_NAME.TY IN CLASS_OBJECT_NAME THEN
            RETURN GET_BASE_TYPE(D ( SM_OBJ_TYPE, D ( 
                                                XD_SOURCE_NAME, DEF)));
         ELSIF SOURCE_NAME.TY IN CLASS_TYPE_SPEC THEN
            IF GET_BASE_TYPE(SOURCE_NAME).TY /=
                                        DN_TASK_SPEC THEN
               PUT_LINE ( "!! NON TASK TYPE NAME IN CALL TO GET_DEF_EXP_TYPE" );
               RAISE PROGRAM_ERROR;
            END IF;
            RETURN GET_BASE_TYPE(SOURCE_NAME);
         ELSE
            RETURN TREE_VOID;
         END IF;
      END GET_DEF_EXP_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_BASE_TYPE(TYPE_SPEC_OR_EXP_OR_ID: TREE) RETURN TREE IS
         TYPE_SPEC: TREE := TYPE_SPEC_OR_EXP_OR_ID;
      BEGIN
      
                -- GET A TYPE SPEC FOR THE EXPRESSION OR ID
         CASE TYPE_SPEC_OR_EXP_OR_ID.TY IS
            WHEN DN_VOID =>
               NULL;
            WHEN DN_USED_NAME_ID =>
               TYPE_SPEC := D ( SM_DEFN, TYPE_SPEC);
               IF TYPE_SPEC /= TREE_VOID THEN
                  TYPE_SPEC := D ( SM_TYPE_SPEC,
                                                TYPE_SPEC);
               END IF;
            WHEN CLASS_OBJECT_NAME =>
               TYPE_SPEC := D ( SM_OBJ_TYPE, TYPE_SPEC);
            WHEN DN_FUNCTION_ID =>
                                -- (FOR SLICE WHOSE PREFIX IS FUNCTION WITH ALL DEFAULT ARGS)
               TYPE_SPEC := GET_BASE_TYPE(D ( AS_NAME, D ( 
                                                        SM_SPEC,TYPE_SPEC)));
            WHEN DN_PROCEDURE_ID =>
                                -- (FOR IDENTIFIER AS EXPRESSION BEFORE OVERLOAD RESOLUTION)
               TYPE_SPEC := TREE_VOID;
            WHEN DN_GENERIC_ID =>
                                -- (FOR EITHER OF THE ABOVE CASES)
               IF D ( XD_HEADER,GET_DEF_FOR_ID ( TYPE_SPEC ) ).TY = DN_FUNCTION_SPEC THEN
                  TYPE_SPEC := GET_BASE_TYPE(D (  AS_NAME, D (  SM_SPEC, TYPE_SPEC ) ) );
               ELSE
                  TYPE_SPEC := TREE_VOID;
               END IF;
            WHEN CLASS_TYPE_NAME | CLASS_RANGE =>
               TYPE_SPEC := D ( SM_TYPE_SPEC, TYPE_SPEC);
            WHEN CLASS_USED_OBJECT | CLASS_EXP_EXP
                                        | DN_ATTRIBUTE | DN_FUNCTION_CALL |
                                        DN_INDEXED
                                        | DN_SLICE | DN_ALL =>
               TYPE_SPEC := D ( SM_EXP_TYPE, TYPE_SPEC);
            WHEN DN_SELECTED =>
               TYPE_SPEC := GET_BASE_TYPE(D ( 
                                                AS_DESIGNATOR, TYPE_SPEC));
            WHEN CLASS_TYPE_SPEC =>
               NULL;
            WHEN DN_DISCRETE_SUBTYPE =>
               TYPE_SPEC := GET_BASE_TYPE
                                        ( D ( AS_NAME, D ( 
                                                        AS_SUBTYPE_INDICATION,
                                                        TYPE_SPEC)) );
            WHEN DN_SUBTYPE_INDICATION =>
               TYPE_SPEC := D ( SM_TYPE_SPEC, D ( AS_NAME,
                                                TYPE_SPEC));
            WHEN CLASS_UNSPECIFIED_TYPE =>
               NULL;
            WHEN OTHERS =>
               PUT_LINE ( "!! BAD PARAMETER FOR GET_BASE_TYPE" );
               RAISE PROGRAM_ERROR;
         END CASE;
      
                -- GET UNCONSTRAINED FOR CONSTRAINED TYPE
                -- (IN CASE CONSTRAINED PRIVATE WITH FULL TYPE VISIBLE)
         IF TYPE_SPEC.TY IN CLASS_CONSTRAINED THEN
            TYPE_SPEC := D ( SM_BASE_TYPE, TYPE_SPEC);
         END IF;
      
                -- GET FULL TYPE SPEC FOR PRIVATE OR INCOMPLETE
         IF TYPE_SPEC.TY IN CLASS_PRIVATE_SPEC THEN
            IF D ( SM_TYPE_SPEC, TYPE_SPEC) /= TREE_VOID THEN
               TYPE_SPEC := D ( SM_TYPE_SPEC, TYPE_SPEC);
            END IF;
         ELSIF TYPE_SPEC.TY = DN_INCOMPLETE THEN
            IF D ( XD_FULL_TYPE_SPEC, TYPE_SPEC) /= TREE_VOID THEN
               TYPE_SPEC := D ( XD_FULL_TYPE_SPEC,
                                        TYPE_SPEC);
            END IF;
         END IF;
      
                -- LOOP TO GET BASE TYPE
                -- $$$$ OK? NON-TASK --> PRIVATE ?
         WHILE TYPE_SPEC.TY IN CLASS_NON_TASK
                                AND THEN D ( SM_BASE_TYPE, TYPE_SPEC) /=
                                TYPE_SPEC LOOP
            TYPE_SPEC := D ( SM_BASE_TYPE, TYPE_SPEC);
         END LOOP;
      
         RETURN TYPE_SPEC;
      END GET_BASE_TYPE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION GET_BASE_PACKAGE(PACKAGE_ID: TREE) RETURN TREE IS
         UNIT_DESC: TREE := D ( SM_UNIT_DESC, PACKAGE_ID);
         BASE_ID: TREE;
      BEGIN
         IF UNIT_DESC.TY = DN_RENAMES_UNIT THEN
            BASE_ID := GET_NAME_DEFN(D ( AS_NAME, UNIT_DESC));
            IF BASE_ID /= TREE_VOID THEN
               RETURN GET_BASE_PACKAGE(BASE_ID);
            END IF;
         END IF;
         RETURN PACKAGE_ID;
      END GET_BASE_PACKAGE;
      
   --|----------------------------------------------------------------------------------------------
   END DEF_UTIL;
