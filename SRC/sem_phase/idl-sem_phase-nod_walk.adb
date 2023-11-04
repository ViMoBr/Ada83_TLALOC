    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	NOD_WALK
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY NOD_WALK IS
   
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE MAKE_NOD;
      USE EXP_TYPE, EXPRESO;
      USE REQ_UTIL;
      USE RED_SUBP;
      USE DEF_WALK;
      USE SET_UTIL;
      USE STM_WALK;
      USE PRA_WALK;
      USE ATT_WALK;
      USE HOM_UNIT;
      USE DERIVED; -- REMEMBER_DERIVED_DECL
   
   
      EQUAL_SYM: TREE := TREE_VOID; -- STORESYM("=");
      NOT_EQUAL_SYM: TREE := TREE_VOID; -- STORESYM("/=");
   
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE FORCE_UPPER_CASE
       PROCEDURE FORCE_UPPER_CASE ( OPERATOR_ID :TREE ) IS
          FUNCTION MAKE_UPPER_CASE(A_IN: STRING) RETURN STRING IS
            MAGIC: CONSTANT := CHARACTER'POS('A') - CHARACTER'
                                POS('A');
            A: STRING (A_IN'RANGE) := A_IN;
         BEGIN
            FOR II IN A'RANGE LOOP
               IF A(II) IN 'A' .. 'Z' THEN
                  A(II) := CHARACTER'VAL(CHARACTER'POS ( A( II ) ) - MAGIC );
               END IF;
            END LOOP;
            RETURN A;
         END MAKE_UPPER_CASE;
      
      BEGIN
         D ( LX_SYMREP, OPERATOR_ID, STORE_SYM ( MAKE_UPPER_CASE(PRINT_NAME ( D ( LX_SYMREP,
                                                        OPERATOR_ID))) ) );
      END FORCE_UPPER_CASE;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S
       PROCEDURE INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S :TREE; OBJ_TYPE :TREE; INIT_EXP :TREE := TREE_VOID ) IS
         SOURCE_NAME_LIST	: SEQ_TYPE	:= LIST ( SOURCE_NAME_S);
         SOURCE_NAME	: TREE;
         SOURCE_DEF		: TREE;
         PRIOR_NAME		: TREE;
         PRIOR_DEF		: TREE;
      
         TEMP_OBJ_TYPE	: TREE	:= OBJ_TYPE;
         TEMP_INIT_EXP	: TREE	:= INIT_EXP;
      BEGIN
         WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST) LOOP
         
            POP ( SOURCE_NAME_LIST, SOURCE_NAME);
            SOURCE_DEF := GET_DEF_FOR_ID (  SOURCE_NAME );
            MAKE_DEF_VISIBLE ( SOURCE_DEF );
            PRIOR_DEF := GET_PRIOR_DEF (  SOURCE_DEF );
            D ( SM_OBJ_TYPE, SOURCE_NAME, TEMP_OBJ_TYPE );
            IF TEMP_INIT_EXP /= TREE_VOID THEN
               D ( SM_INIT_EXP, SOURCE_NAME, TEMP_INIT_EXP );
            END IF;
         
            IF OBJ_TYPE = TREE_VOID THEN
               MAKE_DEF_IN_ERROR ( SOURCE_DEF);
            ELSIF PRIOR_DEF /= TREE_VOID THEN
               IF SOURCE_NAME.TY = DN_CONSTANT_ID THEN
                  PRIOR_NAME := D ( XD_SOURCE_NAME, PRIOR_DEF );
                  IF PRIOR_NAME.TY = DN_CONSTANT_ID
                    AND THEN D ( SM_INIT_EXP, PRIOR_NAME ) = TREE_VOID
                    AND THEN GET_BASE_TYPE (  D ( SM_OBJ_TYPE, PRIOR_NAME ) ) = GET_BASE_TYPE ( TEMP_OBJ_TYPE )
                  THEN
                     REMOVE_DEF_FROM_ENVIRONMENT ( SOURCE_DEF);
                     D ( SM_FIRST, SOURCE_NAME, PRIOR_NAME );
                     D ( SM_INIT_EXP, PRIOR_NAME, TEMP_INIT_EXP );
                  ELSE
                     ERROR (  D ( LX_SRCPOS, SOURCE_NAME ),
                        "DUPLICATE DECLARATION OF CONSTANT - " & PRINT_NAME ( D ( LX_SYMREP, SOURCE_NAME ) ) );
                     MAKE_DEF_IN_ERROR ( 
                                                        SOURCE_DEF);
                  END IF;
               ELSE
                  ERROR ( D ( LX_SRCPOS, SOURCE_NAME ),
                     "DUPLICATE DECLARATION - " & PRINT_NAME ( D ( LX_SYMREP, SOURCE_NAME ) ) );
                  MAKE_DEF_IN_ERROR ( SOURCE_DEF);
               END IF;
            ELSE
               MAKE_DEF_VISIBLE ( SOURCE_DEF);
            END IF;
         
         END LOOP;
      END INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE FIXUP_CONSTRAINED_ARRAY_OBJECTS
       PROCEDURE FIXUP_CONSTRAINED_ARRAY_OBJECTS ( SOURCE_NAME_S :TREE; H :H_TYPE ) IS
         SOURCE_NAME_LIST	: SEQ_TYPE	:= LIST ( SOURCE_NAME_S );
         SOURCE_NAME	: TREE;
         OBJ_TYPE		: TREE;
         EXP		: TREE;
         CONSTRAINED_SPEC	: TREE;
         UNCONSTRAINED_SPEC	: TREE;
      BEGIN
         POP ( SOURCE_NAME_LIST, SOURCE_NAME );
         OBJ_TYPE := D ( SM_OBJ_TYPE, SOURCE_NAME );
         EXP := D ( SM_INIT_EXP, SOURCE_NAME );
                -- MAKE PREDEFINED OPERATORS FOR FIRST OBJECT TYPE
         PRE_FCNS.GEN_PREDEFINED_OPERATORS ( GET_BASE_TYPE ( OBJ_TYPE ), H );
                -- FOR EACH SOURCE NAME EXCEPT THE FIRST
         WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST ) LOOP
            POP ( SOURCE_NAME_LIST, SOURCE_NAME );
                        -- MAKE COPIES OF TYPE AND SUBTYPE SPEC
            CONSTRAINED_SPEC := COPY_NODE ( OBJ_TYPE );
            UNCONSTRAINED_SPEC := COPY_NODE ( D ( SM_BASE_TYPE, CONSTRAINED_SPEC ) );
            D ( XD_SOURCE_NAME, CONSTRAINED_SPEC, SOURCE_NAME );
            D ( XD_SOURCE_NAME, UNCONSTRAINED_SPEC, SOURCE_NAME );
            D ( SM_BASE_TYPE, UNCONSTRAINED_SPEC, UNCONSTRAINED_SPEC );
            D ( SM_BASE_TYPE, CONSTRAINED_SPEC, UNCONSTRAINED_SPEC );
                        -- GENERATE PREDEFINED OPERATORS FOR CREATED TYPE
            PRE_FCNS.GEN_PREDEFINED_OPERATORS ( GET_BASE_TYPE ( UNCONSTRAINED_SPEC ), H );
                        -- IF AN INITIALIZATION EXPRESSION WAS GIVEN
            IF EXP /= TREE_VOID THEN
                                -- MAKE A COPY OF IT WITH THE NEW TYPE
               EXP := COPY_NODE ( EXP );
               D ( SM_EXP_TYPE, EXP, CONSTRAINED_SPEC );
               D ( SM_INIT_EXP, SOURCE_NAME, EXP );
            END IF;
         END LOOP;
      END FIXUP_CONSTRAINED_ARRAY_OBJECTS;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE FINISH_PARAM_DECL
       PROCEDURE FINISH_PARAM_DECL ( NODE :TREE; H :H_TYPE ) IS
         SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
         EXP		: TREE	:= D ( AS_EXP, NODE );
         NAME		: TREE	:= D ( AS_NAME, NODE );
      
         TYPE_SPEC		: TREE;
         TYPESET		: TYPESET_TYPE;
      BEGIN
         TYPE_SPEC := EVAL_TYPE_MARK ( NAME );
         NAME := RESOLVE_TYPE_MARK ( NAME );
         D ( AS_NAME, NODE, NAME );
      
         IF EXP /= TREE_VOID THEN
            EVAL_EXP_TYPES ( EXP, TYPESET );
            REQUIRE_TYPE ( GET_BASE_TYPE ( TYPE_SPEC), EXP, TYPESET );
            EXP := RESOLVE_EXP ( EXP, TYPESET );
         END IF;
                -- GET SUBTYPE FOR OBJECT
         IF TYPE_SPEC /= TREE_VOID THEN
            TYPE_SPEC := D ( SM_TYPE_SPEC, GET_NAME_DEFN ( NAME ) );
         END IF;
      
         INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S, OBJ_TYPE => TYPE_SPEC, INIT_EXP => EXP );
      END FINISH_PARAM_DECL;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE FINISH_PARAM_S
       PROCEDURE FINISH_PARAM_S ( DECL_S :TREE; H :H_TYPE ) IS
         DECL_LIST	: SEQ_TYPE	:= LIST ( DECL_S );
         DECL	: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( DECL_LIST ) LOOP
            POP ( DECL_LIST, DECL );
            WALK ( DECL, H );
            FINISH_PARAM_DECL ( DECL, H );
         END LOOP;
      END FINISH_PARAM_S;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE WALK_HEADER
       PROCEDURE WALK_HEADER ( NODE :TREE; H :H_TYPE ) IS
      BEGIN
      
         CASE CLASS_HEADER'( NODE.TY ) IS
         
            WHEN DN_PROCEDURE_SPEC =>
               DECLARE
                  PARAM_S	: TREE	:= D ( AS_PARAM_S, NODE );
               BEGIN
                  FINISH_PARAM_S ( PARAM_S, H );
               END;
         
         
            WHEN DN_FUNCTION_SPEC =>
               DECLARE
                  PARAM_S	: TREE	:= D ( AS_PARAM_S, NODE );
                  NAME	: TREE	:= D ( AS_NAME, NODE );
                  DUMMY	: TREE;
               BEGIN
                  IF NAME /= TREE_VOID THEN
                     DUMMY := EVAL_TYPE_MARK ( NAME );
                     NAME := RESOLVE_TYPE_MARK ( NAME );
                     D ( AS_NAME, NODE, NAME );
                  END IF;
                  FINISH_PARAM_S ( PARAM_S, H );
               END;
         
            WHEN DN_ENTRY =>
               DECLARE
                  PARAM_S	: TREE := D ( AS_PARAM_S, NODE );
                  DISCRETE_RANGE	: TREE := D ( AS_DISCRETE_RANGE, NODE );
                  TYPESET	: TYPESET_TYPE;
                  TYPE_SPEC	: TREE;
               BEGIN
                  IF DISCRETE_RANGE /= TREE_VOID THEN
                     EVAL_NON_UNIVERSAL_DISCRETE_RANGE ( DISCRETE_RANGE, TYPESET );
                     REQUIRE_UNIQUE_TYPE ( DISCRETE_RANGE, TYPESET );
                     TYPE_SPEC := GET_THE_TYPE ( TYPESET );
                     IF TYPE_SPEC.TY = DN_UNIVERSAL_INTEGER THEN
                                                        --$$$$ CHECK FOR VALID BOUND EXPRESSIONS
                                                        --$$$$ ARE WE CHECKING THAT IT IS DISCRETE ?
                        TYPE_SPEC := PREDEFINED_INTEGER;
                     END IF;
                     DISCRETE_RANGE := RESOLVE_DISCRETE_RANGE ( DISCRETE_RANGE, TYPE_SPEC );
                     D ( AS_DISCRETE_RANGE, NODE, DISCRETE_RANGE );
                  ELSE
                     TYPE_SPEC := TREE_VOID;
                  END IF;
                  FINISH_PARAM_S ( PARAM_S, H );
               END;
         
            WHEN DN_PACKAGE_SPEC =>
               DECLARE
                  DECL_S1	: CONSTANT TREE	:= D ( AS_DECL_S1, NODE );
                  DECL_S2	: CONSTANT TREE	:= D ( AS_DECL_S2, NODE );
                  H		: H_TYPE	:= WALK_HEADER.H;
               BEGIN
                  DB ( XD_BODY_IS_REQUIRED, NODE, FALSE );
                  WALK_ITEM_S (  DECL_S1, H );
                  H.IS_IN_SPEC := FALSE;
                  WALK_ITEM_S ( DECL_S2, H );
                  DB ( XD_BODY_IS_REQUIRED, NODE, TRUE );
               END;
         END CASE;
      END WALK_HEADER;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE WALK_UNIT_DESC
       PROCEDURE WALK_UNIT_DESC ( SOURCE_NAME :TREE; NODE :TREE; H :H_TYPE; HEADER :TREE := TREE_VOID ) IS
      BEGIN
         IF NODE = TREE_VOID THEN
            RETURN;
         END IF;
      
         CASE CLASS_UNIT_DESC'( NODE.TY ) IS
         
            WHEN DN_RENAMES_UNIT | DN_NAME_DEFAULT =>
               DECLARE
                  NAME	: TREE	:= D ( AS_NAME, NODE );
               BEGIN
                  IF SOURCE_NAME.TY = DN_PACKAGE_ID THEN
                     NAME := WALK_NAME ( DN_PACKAGE_ID, NAME );
                  ELSE
                     NAME := WALK_HOMOGRAPH_UNIT ( NAME, HEADER );
                  END IF;
                  D ( AS_NAME, NODE, NAME );
               END;
         
            WHEN DN_INSTANTIATION =>
               INSTANT.WALK_INSTANTIATION ( SOURCE_NAME, NODE, H );
         
            WHEN DN_BOX_DEFAULT | DN_NO_DEFAULT =>
               NULL;
         
            WHEN DN_BLOCK_BODY =>
               DECLARE
                  ITEM_S	: TREE	:= D ( AS_ITEM_S, NODE );
                  STM_S	: TREE	:= D ( AS_STM_S, NODE );
                  ALTERNATIVE_S	: TREE	:= D ( AS_ALTERNATIVE_S, NODE );
                  ALTERNATIVE_LIST	: SEQ_TYPE;
                  ALTERNATIVE	: TREE;
               BEGIN
                  WALK_ITEM_S ( ITEM_S, H );
                  IF STM_S /= TREE_VOID THEN
                     DECLARE_LABEL_BLOCK_LOOP_IDS ( STM_S, H );
                  END IF;
                  IF ALTERNATIVE_S /= TREE_VOID THEN
                     ALTERNATIVE_LIST := LIST ( ALTERNATIVE_S );
                     WHILE NOT IS_EMPTY ( ALTERNATIVE_LIST ) LOOP
                        POP ( ALTERNATIVE_LIST, ALTERNATIVE );
                        IF ALTERNATIVE.TY = DN_ALTERNATIVE THEN
                           DECLARE_LABEL_BLOCK_LOOP_IDS ( D ( AS_STM_S, ALTERNATIVE ), H );
                        END IF;
                     END LOOP;
                  END IF;
                  IF STM_S /= TREE_VOID THEN
                     WALK_STM_S ( STM_S, H );
                  END IF;
                  WALK_ALTERNATIVE_S ( ALTERNATIVE_S, H );
               END;
         
            WHEN DN_STUB =>
               DECLARE
               BEGIN
                  NULL;
               END;
         
            WHEN DN_IMPLICIT_NOT_EQ | DN_DERIVED_SUBPROG =>
               PUT_LINE ( "!! WALK_UNIT_DESC: INVALID NODE" );
               RAISE PROGRAM_ERROR;
         
         END CASE;
      END WALK_UNIT_DESC;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE CHECK_EQUALITY_OPERATOR
       PROCEDURE CHECK_EQUALITY_OPERATOR ( OPERATOR_ID :TREE; H :H_TYPE ) IS
         SYMREP: TREE;
         NEW_ID: TREE;
      BEGIN
         IF OPERATOR_ID.TY /= DN_OPERATOR_ID THEN
            RETURN;
         END IF;
      
         IF EQUAL_SYM = TREE_VOID THEN
            EQUAL_SYM := STORE_SYM ( """=""");
            NOT_EQUAL_SYM := STORE_SYM ( """/=""");
         END IF;
      
         SYMREP := D ( LX_SYMREP, OPERATOR_ID);
         IF SYMREP = NOT_EQUAL_SYM THEN
            ERROR ( D ( LX_SRCPOS,OPERATOR_ID),
                                "DEFINITION OF ""/="" OPERATOR");
         END IF;
      
         IF SYMREP = EQUAL_SYM THEN
            NEW_ID := COPY_NODE(OPERATOR_ID);
                        -- SET SM_FIRST TO THE CREATED ID
            D ( SM_FIRST, NEW_ID, NEW_ID);
            D ( LX_SYMREP, NEW_ID, NOT_EQUAL_SYM);
            D ( SM_UNIT_DESC
                                , NEW_ID
                                ,  MAKE_IMPLICIT_NOT_EQ
                                (SM_EQUAL => OPERATOR_ID) );
            MAKE_DEF_VISIBLE
                                ( MAKE_DEF_FOR_ID ( NEW_ID, H)
                                , D ( XD_HEADER, GET_DEF_FOR_ID ( OPERATOR_ID)) );
            D ( XD_NOT_EQUAL
                                , OPERATOR_ID
                                , NEW_ID );
                        -- CONSTRUCT NEW FORMAL PARAMETER ID'S
            DECLARE
               SPEC: TREE := COPY_NODE(D ( SM_SPEC, NEW_ID));
               PARAM_S: TREE := COPY_NODE(D ( AS_PARAM_S,
                                                SPEC));
               PARAM_LIST: SEQ_TYPE := LIST ( PARAM_S);
               PARAM: TREE;
               ID_S: TREE;
               ID_LIST: SEQ_TYPE;
               ID: TREE;
               NEW_ID_LIST: SEQ_TYPE;
               NEW_PARAM_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
            BEGIN
               WHILE NOT IS_EMPTY ( PARAM_LIST) LOOP
                  POP ( PARAM_LIST, PARAM);
                  PARAM := COPY_NODE(PARAM);
                  ID_S := COPY_NODE(D ( 
                                                        AS_SOURCE_NAME_S,
                                                        PARAM));
                  ID_LIST := LIST ( ID_S);
                  NEW_ID_LIST := (TREE_NIL,TREE_NIL);
                  WHILE NOT IS_EMPTY ( ID_LIST) LOOP
                     POP ( ID_LIST, ID);
                     ID := COPY_NODE(ID);
                     D ( SM_FIRST, ID, ID);
                     NEW_ID_LIST := APPEND (
                                                        NEW_ID_LIST, ID);
                  END LOOP;
                  LIST ( ID_S, NEW_ID_LIST);
                  D ( AS_SOURCE_NAME_S, PARAM, ID_S);
                  NEW_PARAM_LIST := APPEND (
                                                NEW_PARAM_LIST, PARAM);
               END LOOP;
               LIST ( PARAM_S, NEW_PARAM_LIST);
               D ( AS_PARAM_S, SPEC, PARAM_S);
               D ( SM_SPEC, NEW_ID, SPEC);
            END;
         END IF;
      END CHECK_EQUALITY_OPERATOR;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION IS_CONSTANT_EXP
       FUNCTION IS_CONSTANT_EXP ( EXP :TREE ) RETURN BOOLEAN IS
      BEGIN
         IF EXP.TY = DN_SELECTED THEN
            RETURN IS_CONSTANT_EXP (  D ( AS_DESIGNATOR, EXP ) );
         ELSIF EXP.TY = DN_USED_OBJECT_ID THEN
            RETURN D ( SM_DEFN, EXP ).TY = DN_CONSTANT_ID;
         ELSE
            RETURN FALSE;
         END IF;
      END IS_CONSTANT_EXP;
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION SWITCH_REGION
       PROCEDURE SWITCH_REGION ( GENERIC_ID, REGION_DEF :TREE ) IS
         ITEM_LIST	: SEQ_TYPE	:= LIST ( D ( SM_GENERIC_PARAM_S, GENERIC_ID ) );
         ITEM	: TREE;
         NAME_LIST	: SEQ_TYPE;
         NAME	: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( ITEM_LIST) LOOP
            POP ( ITEM_LIST, ITEM );
            CASE CLASS_ITEM'( ITEM.TY ) IS
               WHEN CLASS_DSCRMT_PARAM_DECL | CLASS_ID_S_DECL =>
                  NAME_LIST := LIST ( D ( AS_SOURCE_NAME_S, ITEM ) );
                  WHILE NOT IS_EMPTY ( NAME_LIST) LOOP
                     POP ( NAME_LIST, NAME );
                     IF D ( LX_SYMREP,NAME ).TY = DN_SYMBOL_REP THEN
                        D ( XD_REGION_DEF, GET_DEF_FOR_ID ( NAME ), REGION_DEF );
                     END IF;
                  END LOOP;
               WHEN CLASS_ID_DECL =>
                  IF D ( LX_SYMREP,D ( AS_SOURCE_NAME, ITEM ) ).TY = DN_SYMBOL_REP THEN
                     D ( XD_REGION_DEF, GET_DEF_FOR_ID ( D ( AS_SOURCE_NAME, ITEM ) ), REGION_DEF );
                  END IF;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END LOOP;
      END;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE REPROCESS_USE_CLAUSES
       PROCEDURE REPROCESS_USE_CLAUSES ( DECL_S :TREE; H :H_TYPE ) IS		--| POUR LA VISIBILITÉ DANS LE CORPS DES CLAUSES DE LA DECL DE PACKAGE
         DECL_LIST	: SEQ_TYPE;
         DECL	: TREE;
         ITEM_LIST	: SEQ_TYPE;
         ITEM	: TREE;
         ITEM_DEFN	: TREE;
         ITEM_DEF	: TREE;
      BEGIN
         IF DECL_S = TREE_VOID THEN
            RETURN;
         END IF;
      
         DECL_LIST := LIST ( DECL_S );
         WHILE NOT IS_EMPTY ( DECL_LIST ) LOOP
            POP ( DECL_LIST, DECL );
            IF DECL.TY = DN_USE THEN
               ITEM_LIST := LIST ( D ( AS_NAME_S, DECL ) );
               WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP
                  POP ( ITEM_LIST, ITEM );
                  IF ITEM.TY = DN_SELECTED THEN
                     ITEM := D ( AS_DESIGNATOR, ITEM );
                  END IF;
                  IF ITEM.TY = DN_USED_NAME_ID THEN
                     ITEM_DEFN := D ( SM_DEFN, ITEM );
                  ELSE
                     ITEM_DEFN := TREE_VOID;
                  END IF;
                  IF ITEM_DEFN.TY = DN_PACKAGE_ID THEN
                     ITEM_DEF := GET_DEF_FOR_ID ( ITEM_DEFN );
                     IF DI ( XD_LEX_LEVEL, ITEM_DEF) <= 0
                       AND THEN NOT DB ( XD_IS_USED, ITEM_DEF ) THEN
                        DB ( XD_IS_USED, ITEM_DEF, TRUE );
                        SU.USED_PACKAGE_LIST := INSERT ( SU.USED_PACKAGE_LIST, ITEM_DEF );
                     END IF;
                  END IF;
               END LOOP;
            ELSIF DECL.TY = DN_TYPE_DECL
              AND THEN ( D ( AS_TYPE_DEF, DECL).TY = DN_RECORD_DEF
              OR ELSE D ( AS_TYPE_DEF, DECL).TY IN DN_CONSTRAINED_ARRAY_DEF .. DN_UNCONSTRAINED_ARRAY_DEF )
                                        THEN
               PRE_FCNS.GEN_PREDEFINED_OPERATORS ( D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, DECL ) ), H );
            ELSIF DECL.TY IN CLASS_OBJECT_DECL
              AND THEN D ( AS_TYPE_DEF, DECL ).TY = DN_CONSTRAINED_ARRAY_DEF
            THEN
               DECLARE
                  ID_LIST	: SEQ_TYPE	:= LIST ( D ( AS_SOURCE_NAME_S, DECL ) );
                  ID	: TREE;
               BEGIN
                  WHILE NOT IS_EMPTY ( ID_LIST ) LOOP
                     POP ( ID_LIST, ID );
                     PRE_FCNS.GEN_PREDEFINED_OPERATORS ( D ( SM_OBJ_TYPE, ID ), H );
                  END LOOP;
               END;
            END IF;
         END LOOP;
      END REPROCESS_USE_CLAUSES;
     --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE WALK
       PROCEDURE WALK ( NODE :TREE; H :H_TYPE ) IS
      
      BEGIN
         IF NODE = TREE_VOID THEN
            RETURN;
         END IF;
      
         CASE CLASS_ITEM'( NODE.TY ) IS
                        
            WHEN DN_DSCRMT_DECL | DN_IN | DN_IN_OUT | DN_OUT =>		--| DISCRIMINANT OU DIRECTION
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );
               END;
         
         
                       	 --| DECLARATION DE CONSTANTE
            WHEN DN_CONSTANT_DECL =>
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
                  EXP	: TREE	:= D ( AS_EXP, NODE);
                  TYPE_DEF	: TREE	:= D ( AS_TYPE_DEF, NODE );
               
                  TYPE_SPEC	: TREE;
                  TYPESET	: TYPESET_TYPE;
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );			--| INSÉRER LES NOMS DANS L'ENVIRONNEMENT
               
                  IF TYPE_DEF.TY = DN_CONSTRAINED_ARRAY_DEF THEN		--| DÉCLARATION DE TABLEAU CONTRAINT
                     TYPE_SPEC := EVAL_TYPE_DEF ( TYPE_DEF, HEAD ( LIST ( SOURCE_NAME_S ) ), H );	--| EVALUER LA DÉFINITION DE TYPE
                  
                  ELSE	--| LA DÉCLARATION CONTIENT UNE SUBTYPE INDICATION
                     TYPE_SPEC := EVAL_SUBTYPE_INDICATION ( TYPE_DEF );
                     RESOLVE_SUBTYPE_INDICATION ( TYPE_DEF, TYPE_SPEC );
                     D ( AS_TYPE_DEF, NODE, TYPE_DEF );
                  END IF;
               
                  EVAL_EXP_TYPES ( EXP, TYPESET );			--| EVALUER L'EXPRESSION QUI DOIT ÊTRE DONNÉE
                  REQUIRE_TYPE ( GET_BASE_TYPE ( TYPE_SPEC ), EXP, TYPESET );
                  REQUIRE_NONLIMITED_TYPE ( EXP, TYPESET );
                  EXP := RESOLVE_EXP ( EXP, TYPESET );
                  D ( AS_EXP, NODE, EXP );
                                        -- COMPLETE SOURCE_NAME DEFINITIONS AND MAKE VISIBLE
                  INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S, OBJ_TYPE => TYPE_SPEC, INIT_EXP => EXP );
                                        -- IF TYPE DEFINITION IS A CONSTRAINED ARRAY DEFINITION
                  IF TYPE_DEF.TY = DN_CONSTRAINED_ARRAY_DEF THEN
                     FIXUP_CONSTRAINED_ARRAY_OBJECTS ( SOURCE_NAME_S, H );		--| COPIER LES ARRAY TYPE SPECS ET GÉNÉRER LES OPÉRATEURS PRÉDÉFINIS
                  END IF;
               END;
         --| DECLARATION DE VARIABLE
            WHEN DN_VARIABLE_DECL =>
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
                  EXP	: TREE	:= D ( AS_EXP, NODE);
                  TYPE_DEF	: TREE	:= D ( AS_TYPE_DEF, NODE );
               
                  TYPE_SPEC	: TREE;
                  TYPESET	: TYPESET_TYPE;
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );			--| INSÉRER LES NOMS DANS L'ENVIRONNEMENT
               
                  IF TYPE_DEF.TY = DN_CONSTRAINED_ARRAY_DEF THEN		--| CONTIENT UNE DÉFINITION DE TABLEAU CONTRAINT
                     TYPE_SPEC := EVAL_TYPE_DEF ( TYPE_DEF, HEAD ( LIST ( SOURCE_NAME_S ) ), H );	--| EVALUER LA DÉFINITION DE TYPE
                  
                  ELSE				--| INDICATION DE SOUS TYPE
                     TYPE_SPEC := EVAL_SUBTYPE_INDICATION ( TYPE_DEF );		--| EVALUER LA SUBTYPE INDICATION
                     RESOLVE_SUBTYPE_INDICATION ( TYPE_DEF, TYPE_SPEC );		--| LA RÉSOUDRE
                     D ( AS_TYPE_DEF, NODE, TYPE_DEF );
                  END IF;
               
                  IF EXP /= TREE_VOID THEN			--| UNE EXPRESSION EST DONNÉE
                     EVAL_EXP_TYPES ( EXP, TYPESET );
                     REQUIRE_TYPE ( GET_BASE_TYPE ( TYPE_SPEC ), EXP, TYPESET );
                     REQUIRE_NONLIMITED_TYPE ( EXP, TYPESET );
                     EXP := RESOLVE_EXP ( EXP, TYPESET );
                     D ( AS_EXP, NODE, EXP );
                  END IF;
               
                  INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S,	--| TERMINER LES DÉFINITIONS ET RENDRE VISIBLE
                     	OBJ_TYPE => TYPE_SPEC, INIT_EXP => EXP );
               
                  IF TYPE_DEF.TY =  DN_CONSTRAINED_ARRAY_DEF THEN
                     FIXUP_CONSTRAINED_ARRAY_OBJECTS ( SOURCE_NAME_S, H );
                  END IF;
               END;
                      	  --| DECLARATION DE NOMBRE
            WHEN DN_NUMBER_DECL =>
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
                  EXP	: TREE	:= D ( AS_EXP, NODE );
                  TYPE_SPEC	: TREE;
                  TYPESET	: TYPESET_TYPE;
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );
                  EVAL_EXP_TYPES ( EXP, TYPESET );
                  REQUIRE_UNIVERSAL_TYPE ( EXP, TYPESET );
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  TYPE_SPEC := GET_THE_TYPE ( TYPESET );
                  EXP := RESOLVE_EXP ( EXP, TYPE_SPEC );
                  INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S, OBJ_TYPE => TYPE_SPEC, INIT_EXP => EXP );
               END;
                      	  --| DECLARATION D'EXCEPTION
            WHEN DN_EXCEPTION_DECL =>
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );
                  CHECK_UNIQUE_SOURCE_NAME_S ( SOURCE_NAME_S );
               END;
                      	  --| DECLARATION DE CONSTANTE DIFFEREE
            WHEN DN_DEFERRED_CONSTANT_DECL =>
               DECLARE
                  SOURCE_NAME_S	: TREE	:= D ( AS_SOURCE_NAME_S, NODE );
                  NAME	: TREE	:= D ( AS_NAME, NODE );
                  TYPE_SPEC	: TREE;
               BEGIN
                  WALK_SOURCE_NAME_S ( SOURCE_NAME_S, H );
                  TYPE_SPEC := EVAL_TYPE_MARK ( NAME );
                  IF TYPE_SPEC /= TREE_VOID THEN
                     TYPE_SPEC := D (  SM_TYPE_SPEC, GET_NAME_DEFN ( NAME ) );
                  END IF;
                  NAME := RESOLVE_TYPE_MARK ( NAME );
                  D ( AS_NAME, NODE, NAME );
                                        -- CHECK THAT CURRENT DECLARATION IS IN VISIBLE PART
                                        -- ... AND THAT TYPE IS PRIVATE TYPE IS DEFINED IN THIS REGION
                                        -- ... (OUTSIDE THE PACKAGE, SM_TYPE_SPEC IS NOT VOID)
                  IF NOT H.IS_IN_SPEC OR ELSE GET_BASE_TYPE ( TYPE_SPEC).TY NOT IN CLASS_PRIVATE_SPEC THEN
                     ERROR ( D ( LX_SRCPOS,NODE), "DEFERRED CONSTANT NOT ALLOWED" );
                  END IF;
                  
                  INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S ( SOURCE_NAME_S, OBJ_TYPE => TYPE_SPEC, INIT_EXP => TREE_VOID );
               END;
                      	  --| DECLARATION DE TYPE
            WHEN DN_TYPE_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  DSCRMT_DECL_S	: TREE	:= D ( AS_DSCRMT_DECL_S, NODE );
                  TYPE_DEF	: TREE	:= D ( AS_TYPE_DEF, NODE );
               
                  SOURCE_DEF	: TREE	:= MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  TYPE_SPEC	: TREE;
               
                  PRIOR_DEF	: TREE;
                  PRIOR_NAME	: TREE;
                  PRIOR_SPEC	: TREE	:= TREE_VOID;
                  NEW_DSCRMT_DECL_S	: TREE	:= DSCRMT_DECL_S;
                  H		: H_TYPE	:= WALK.H;
                  S		: S_TYPE;
               BEGIN
                  PRIOR_DEF := GET_PRIOR_DEF ( SOURCE_DEF );
                  
                  IF PRIOR_DEF /= TREE_VOID THEN			--| IL Y A UNE DÉFINITION ANTÉRIEURE
                     PRIOR_NAME := D ( XD_SOURCE_NAME, PRIOR_DEF );
                  
                     IF PRIOR_NAME.TY IN DN_PRIVATE_TYPE_ID .. DN_L_PRIVATE_TYPE_ID THEN	--| TYPE PRIVÉ (LIMITÉ)
                        PRIOR_SPEC := D ( SM_TYPE_SPEC, PRIOR_NAME );
                        
                        IF D ( SM_TYPE_SPEC, PRIOR_SPEC ) /= TREE_VOID OR ELSE H.IS_IN_SPEC THEN	--| TYPE COMPLET ANTÉRIEUR ! OU ON EST DANS LA PARTIE VISIBLE
                           PRIOR_SPEC := TREE_VOID;			--| INDIQUER UNE ERREUR
                        END IF;
                     
                     ELSIF PRIOR_NAME.TY = DN_TYPE_ID THEN			--| UN ID DE TYPE
                        PRIOR_SPEC := D ( SM_TYPE_SPEC, PRIOR_NAME );		--| SPÉCIF DE TYPE CORRESPONDANTE
                        IF PRIOR_SPEC.TY /= DN_INCOMPLETE			--| CE N'EST PAS UN INCOMPLET
                          OR ELSE D ( XD_FULL_TYPE_SPEC, PRIOR_SPEC ) /= TREE_VOID THEN	--| LE TYPE COMPLET EST DÉJÀ DÉCLARÉ
                           PRIOR_SPEC := TREE_VOID;			--| INDIQUER UNE ERREUR
                        END IF;
                     END IF;
                  
                     IF TYPE_DEF.TY NOT IN DN_ENUMERATION_DEF .. DN_RECORD_DEF THEN	--| CE N'EST PAS UNE DÉFINITION COMPLÈTE POSSIBLE
                        PRIOR_SPEC := TREE_VOID;			--| INDIQUER UNE ERREUR
                     END IF;
                  
                     IF PRIOR_SPEC = TREE_VOID THEN			--| REDÉCLARATION INTERDITE
                        ERROR ( D ( LX_SRCPOS, NODE ), "REDECLARATION OF TYPE NAME");
                        MAKE_DEF_IN_ERROR ( PRIOR_DEF );			--| DÉFINITION ANTÉRIEURE INDIQUÉE EN ERREUR
                        PRIOR_DEF := TREE_VOID;			--| FAIRE COMME S'IL N'Y AVAIT PAS D'ENTÉRIEURE
                     END IF;
                  END IF;
                                        -- IF DISCRIMINANTS WERE GIVEN
                  IF DSCRMT_DECL_S /= TREE_VOID AND THEN NOT IS_EMPTY ( LIST ( DSCRMT_DECL_S ) ) THEN
                  
                                                -- WALK THE DISCRIMINANTS
                                                -- ... (IN THE RECORD'S DECLARATIVE REGION)
                     ENTER_REGION ( SOURCE_DEF, H, S );
                                                --WALK_ITEM_S(DSCRMT_DECL_S, H);
                     FINISH_PARAM_S ( DSCRMT_DECL_S, H );
                     LEAVE_REGION (SOURCE_DEF, S );
                     H := WALK.H;
                  
                     IF TYPE_DEF.TY NOT IN DN_ACCESS_DEF .. DN_L_PRIVATE_DEF
                        AND THEN TYPE_DEF /= TREE_VOID
                       THEN
                        ERROR ( D ( LX_SRCPOS, DSCRMT_DECL_S ), "DISCRIMINANTS NOT ALLOWED" );
                     ELSIF PRIOR_DEF /= TREE_VOID THEN
                        IF D ( SM_DISCRIMINANT_S, PRIOR_SPEC ) = TREE_VOID
                           OR ELSE IS_EMPTY ( LIST ( D ( SM_DISCRIMINANT_S, PRIOR_SPEC ) ) )
                        THEN
                           ERROR ( D ( LX_SRCPOS, DSCRMT_DECL_S ), "FIRST DECLARATION HAD NO DISCRIMINANTS");
                        ELSE
                           NEW_DSCRMT_DECL_S
                                                                        :=
                                                                        D ( 
                                                                        SM_DISCRIMINANT_S,
                                                                        PRIOR_SPEC);
                           CONFORM_PARAMETER_LISTS
                                                                        (
                                                                        NEW_DSCRMT_DECL_S
                                                                        ,
                                                                        DSCRMT_DECL_S );
                           NEW_DSCRMT_DECL_S
                                                                        :=
                                                                        D ( 
                                                                        SM_DISCRIMINANT_S,
                                                                        PRIOR_SPEC);
                           IF TYPE_DEF.TY /=
                                                                                DN_RECORD_DEF THEN
                              ERROR ( 
                                                                                D ( 
                                                                                        LX_SRCPOS,
                                                                                        DSCRMT_DECL_S)
                                                                                ,
                                                                                "FULL TYPE MUST BE RECORD");
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               
                  IF PRIOR_DEF /= TREE_VOID THEN
                     D ( SM_FIRST, SOURCE_NAME,
                                                        PRIOR_NAME);
                  ELSE
                     PRIOR_DEF := SOURCE_DEF;
                     PRIOR_NAME := SOURCE_NAME;
                  END IF;
               
                  IF TYPE_DEF = TREE_VOID THEN
                     ENTER_REGION ( PRIOR_DEF, H, S );
                     TYPE_SPEC := MAKE_INCOMPLETE ( SM_DISCRIMINANT_S => NEW_DSCRMT_DECL_S, XD_SOURCE_NAME => SOURCE_NAME );
                     LEAVE_REGION ( PRIOR_DEF, S);
                  ELSE
                     TYPE_SPEC := EVAL_TYPE_DEF ( TYPE_DEF, PRIOR_NAME, H, NEW_DSCRMT_DECL_S );
                     IF TYPE_DEF.TY = DN_DERIVED_DEF THEN
                        REMEMBER_DERIVED_DECL ( NODE );
                     END IF;
                  END IF;
               
                  D ( SM_TYPE_SPEC, SOURCE_NAME, TYPE_SPEC );
                  IF TYPE_SPEC /= TREE_VOID THEN
                     IF PRIOR_DEF /= SOURCE_DEF THEN
                        REMOVE_DEF_FROM_ENVIRONMENT ( SOURCE_DEF );
                        IF PRIOR_SPEC /= TREE_VOID THEN
                           IF PRIOR_SPEC.TY = DN_INCOMPLETE THEN
                              D ( XD_FULL_TYPE_SPEC, PRIOR_SPEC, TYPE_SPEC );
                           ELSE
                              D ( SM_TYPE_SPEC, PRIOR_SPEC, TYPE_SPEC );
                           END IF;
                        END IF;
                     ELSE
                        MAKE_DEF_VISIBLE ( SOURCE_DEF );
                     END IF;
                     PRE_FCNS.GEN_PREDEFINED_OPERATORS ( GET_BASE_TYPE ( TYPE_SPEC ), H );
                  ELSE
                     MAKE_DEF_IN_ERROR ( SOURCE_DEF );
                  END IF;
               END;
         
            WHEN DN_SUBTYPE_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  SUBTYPE_INDICATION	: TREE	:= D ( AS_SUBTYPE_INDICATION, NODE );
                  SOURCE_DEF	: TREE	:= MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  TYPE_SPEC	: TREE;
               BEGIN
                  TYPE_SPEC := EVAL_TYPE_DEF ( SUBTYPE_INDICATION, SOURCE_NAME, H );
                  D ( SM_TYPE_SPEC, SOURCE_NAME, TYPE_SPEC );
                  IF TYPE_SPEC /= TREE_VOID THEN
                     MAKE_DEF_VISIBLE ( SOURCE_DEF );
                  ELSE
                     MAKE_DEF_IN_ERROR ( SOURCE_DEF );
                  END IF;
               END;
         
            WHEN DN_TASK_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  DECL_S	: TREE	:= D ( AS_DECL_S, NODE );
               
                  H		: H_TYPE	:= WALK.H;
                  S		: S_TYPE;
                  SOURCE_DEF	: TREE	:=  MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  PRIOR_DEF	: TREE;
               
                  TASK_SPEC	: TREE	:= MAKE_TASK_SPEC ( SM_DECL_S => DECL_S, XD_SOURCE_NAME => SOURCE_NAME );
               BEGIN
                  IF SOURCE_NAME.TY = DN_TYPE_ID THEN
                     D ( SM_FIRST, SOURCE_NAME, SOURCE_NAME );
                     D ( SM_TYPE_SPEC, SOURCE_NAME, TASK_SPEC );
                     PRIOR_DEF := GET_PRIOR_DEF ( SOURCE_DEF );
                     IF PRIOR_DEF /= TREE_VOID THEN
                        IF D (  XD_SOURCE_NAME, PRIOR_DEF).TY = DN_L_PRIVATE_TYPE_ID THEN
                           REMOVE_DEF_FROM_ENVIRONMENT ( SOURCE_DEF );
                           D ( SM_FIRST, SOURCE_NAME, D ( XD_SOURCE_NAME, PRIOR_DEF ) );
                           D ( SM_TYPE_SPEC, D ( SM_TYPE_SPEC, D ( XD_SOURCE_NAME, PRIOR_DEF ) ), TASK_SPEC );
                           SOURCE_DEF := PRIOR_DEF;
                        ELSIF ( D (  XD_SOURCE_NAME, PRIOR_DEF).TY = DN_TYPE_ID
                          AND THEN D ( SM_TYPE_SPEC, D ( XD_SOURCE_NAME, PRIOR_DEF ) ).TY = DN_INCOMPLETE ) THEN
                           REMOVE_DEF_FROM_ENVIRONMENT ( SOURCE_DEF );
                           D ( SM_FIRST, SOURCE_NAME, D ( XD_SOURCE_NAME, PRIOR_DEF ) );
                           D ( XD_FULL_TYPE_SPEC, D ( SM_TYPE_SPEC, D ( XD_SOURCE_NAME, PRIOR_DEF ) ), TASK_SPEC );
                           SOURCE_DEF := PRIOR_DEF;
                        ELSE
                           ERROR ( D ( LX_SRCPOS, SOURCE_NAME ),
                              "DUPLICATE NAME FOR TASK - " & PRINT_NAME ( D ( LX_SYMREP, SOURCE_NAME ) ) );
                           MAKE_DEF_IN_ERROR ( SOURCE_DEF );
                        END IF;
                        D ( XD_SOURCE_NAME, TASK_SPEC, D ( XD_SOURCE_NAME, SOURCE_DEF ) );
                     ELSE
                        MAKE_DEF_VISIBLE ( SOURCE_DEF );
                     END IF;
                  ELSE
                     D ( SM_OBJ_TYPE, SOURCE_NAME, TASK_SPEC );
                     CHECK_UNIQUE_DEF ( SOURCE_DEF );
                  END IF;
               
                  ENTER_REGION ( SOURCE_DEF, H, S);
                  WALK_ITEM_S ( DECL_S, H);
                  LEAVE_REGION ( SOURCE_DEF, S);
               END;
         
            WHEN DN_GENERIC_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  HEADER	: TREE	:= D ( AS_HEADER, NODE );
                  ITEM_S	: TREE	:= D ( AS_ITEM_S, NODE );
                  ITEM_LIST	: SEQ_TYPE	:= LIST ( ITEM_S );
                  ITEM	: TREE;
               
                  H		: H_TYPE := WALK.H;
                  S		: S_TYPE;
                  SOURCE_DEF	: TREE := MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
               BEGIN
                  D ( SM_FIRST, SOURCE_NAME, SOURCE_NAME );
                  D ( SM_SPEC, SOURCE_NAME, HEADER );
                  D ( SM_GENERIC_PARAM_S, SOURCE_NAME, ITEM_S );
               
                  CHECK_UNIQUE_DEF ( SOURCE_DEF );
               
                  ENTER_REGION ( SOURCE_DEF, H, S );
                  WHILE NOT IS_EMPTY ( ITEM_LIST) LOOP
                     POP ( ITEM_LIST, ITEM);
                     WALK ( ITEM, H );
                     IF ITEM.TY IN CLASS_PARAM THEN
                        FINISH_PARAM_DECL ( ITEM, H );
                     END IF;
                  END LOOP;
                  H.SUBP_SYMREP := D ( LX_SYMREP, SOURCE_NAME );
                                        --IF KIND ( HEADER) IN CLASS_SUBP_ENTRY_HEADER THEN
                                        --    WALK_ITEM_S(D ( AS_PARAM_S,HEADER), H);
                                        --END IF;
                  WALK_HEADER ( HEADER, H );
                  LEAVE_REGION ( SOURCE_DEF, S);
                  MAKE_DEF_VISIBLE ( SOURCE_DEF, HEADER);
               END;
         
            WHEN DN_SUBPROG_ENTRY_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  HEADER	: TREE	:= D ( AS_HEADER, NODE );
                  UNIT_KIND	: TREE	:= D ( AS_UNIT_KIND, NODE );
               
                  H		: H_TYPE := WALK.H;
                  S		: S_TYPE;
                  SOURCE_DEF	: TREE;
                  PRIOR_DEF	: TREE;
               BEGIN
                  IF SOURCE_NAME.TY = DN_OPERATOR_ID THEN
                     FORCE_UPPER_CASE ( SOURCE_NAME );
                  END IF;
                  SOURCE_DEF := MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  D ( SM_SPEC, SOURCE_NAME, HEADER );
                  IF SOURCE_NAME.TY /= DN_ENTRY_ID THEN
                     D ( SM_FIRST, SOURCE_NAME, SOURCE_NAME );
                     D ( SM_UNIT_DESC, SOURCE_NAME, UNIT_KIND );
                  END IF;
               
                  IF HEADER /= TREE_VOID THEN
                     ENTER_REGION ( SOURCE_DEF, H, S );
                     H.SUBP_SYMREP := D ( LX_SYMREP, SOURCE_NAME );
                                                --WALK_ITEM_S(D ( AS_PARAM_S,HEADER), H);
                     WALK_HEADER ( HEADER, H );
                     LEAVE_REGION ( SOURCE_DEF, S);
                     H := WALK.H;
                  END IF;
                  WALK_UNIT_DESC ( SOURCE_NAME, UNIT_KIND, H, HEADER );
                  HEADER := D ( SM_SPEC, SOURCE_NAME );
                                        -- IN CASE INSTANTIATION
                  IF HEADER.TY = DN_ENTRY
                    AND THEN D ( AS_DISCRETE_RANGE, HEADER ) /= TREE_VOID THEN
                                                -- IT IS AN ENTRY FAMILY
                     MAKE_DEF_VISIBLE ( SOURCE_DEF );
                     PRIOR_DEF := GET_PRIOR_DEF ( SOURCE_DEF );
                  ELSE
                     MAKE_DEF_VISIBLE ( SOURCE_DEF, HEADER );
                     PRIOR_DEF := GET_PRIOR_HOMOGRAPH_DEF ( SOURCE_DEF );
                  END IF;
                  IF PRIOR_DEF /= TREE_VOID THEN
                     IF D ( XD_HEADER, PRIOR_DEF) /= TREE_FALSE THEN
                        ERROR ( D ( LX_SRCPOS, SOURCE_NAME),
                           "DUPLICATE DEF FOR SUBPROGRAM NAME - " & PRINT_NAME ( D ( LX_SYMREP, SOURCE_NAME ) ) );
                     END IF;
                     MAKE_DEF_IN_ERROR ( SOURCE_DEF);
                  ELSE
                     CHECK_EQUALITY_OPERATOR (  SOURCE_NAME, H );
                  END IF;
               END;
         
            WHEN DN_PACKAGE_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  HEADER	: TREE	:= D ( AS_HEADER, NODE );
                  UNIT_KIND	: TREE	:= D ( AS_UNIT_KIND, NODE );
               
                  H		: H_TYPE	:= WALK.H;
                  S		: S_TYPE;
                  SOURCE_DEF	: TREE	:= MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
               BEGIN
                  D ( SM_FIRST, SOURCE_NAME, SOURCE_NAME );
                  D ( SM_SPEC, SOURCE_NAME, HEADER );
                  D ( SM_UNIT_DESC, SOURCE_NAME, UNIT_KIND );
               
                  CHECK_UNIQUE_DEF ( SOURCE_DEF );
                  WALK_UNIT_DESC ( SOURCE_NAME, UNIT_KIND, H );
                  MAKE_DEF_VISIBLE ( SOURCE_DEF );
                  IF HEADER /= TREE_VOID THEN
                     ENTER_REGION ( SOURCE_DEF, H, S );
                     WALK_HEADER ( HEADER, H );
                     LEAVE_REGION ( SOURCE_DEF, S );
                  END IF;
               END;
                        -- FOR A RENAMING DECLARATION FOR AN OBJECT
            WHEN DN_RENAMES_OBJ_DECL =>
               DECLARE
                  SOURCE_NAME	: TREE	:= D ( AS_SOURCE_NAME, NODE );
                  NAME	: TREE	:= D ( AS_NAME, NODE );
                  TYPE_MARK_NAME	: TREE	:= D ( AS_TYPE_MARK_NAME, NODE );
               
                  SOURCE_DEF	: TREE	:= MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  BASE_TYPE	: TREE;
                  TYPESET	: TYPESET_TYPE;
               BEGIN
                                        -- EVALUATE AND RESOLVE THE TYPE MARK
                  BASE_TYPE := GET_BASE_TYPE ( EVAL_TYPE_MARK ( TYPE_MARK_NAME ) );
                  TYPE_MARK_NAME := RESOLVE_TYPE_MARK ( TYPE_MARK_NAME );
                  D ( AS_TYPE_MARK_NAME, NODE, TYPE_MARK_NAME );
                                        -- EVALUATE THE NAME BEING REDEFINED; REQUIRE SAME BASE TYPE
                  EVAL_EXP_TYPES ( NAME, TYPESET );
                  REQUIRE_TYPE ( BASE_TYPE, NAME, TYPESET );
                  NAME := RESOLVE_EXP ( NAME, TYPESET );
                                        -- IF A CONSTANT (OR IN PARAMETER) IS BEING RENAMED
                  IF IS_CONSTANT_EXP ( NAME) THEN
                                                -- REPLACE VARIABLE_ID WITH CONSTANT_ID
                                                -- SM_FIRST ADDED 8-17-91 WBE
                     SOURCE_NAME := MAKE_CONSTANT_ID (	LX_SRCPOS => D ( LX_SRCPOS, SOURCE_NAME ),
                        	LX_SYMREP => D ( LX_SYMREP, SOURCE_NAME ),
                        	XD_REGION => D ( XD_REGION, SOURCE_NAME )
                        );
                     D ( SM_FIRST, SOURCE_NAME, SOURCE_NAME );
                     D ( AS_SOURCE_NAME, NODE, SOURCE_NAME );
                                                -- FIX UP DEF TO POINT TO NEWLY-CREATED CONSTANT_ID
                     D ( XD_SOURCE_NAME, SOURCE_DEF, SOURCE_NAME );
                  END IF;
                                        -- STORE REMAINING ATTRIBUTES OF SOURCE NAME
                  D ( SM_INIT_EXP, SOURCE_NAME, NAME );
                  DB ( SM_RENAMES_OBJ, SOURCE_NAME, TRUE );
                  D ( SM_OBJ_TYPE, SOURCE_NAME, D ( SM_EXP_TYPE, NAME ) );
                                        -- CHECK THAT SOURCE NAME IS UNIQUE AND MAKE IT VISIBLE
                  CHECK_UNIQUE_DEF(SOURCE_DEF);
               END;
         
            WHEN DN_RENAMES_EXC_DECL =>
               DECLARE
                  SOURCE_NAME: TREE := D ( 
                                                AS_SOURCE_NAME, NODE);
                  NAME: TREE := D ( AS_NAME, NODE);
               
                  SOURCE_DEF: TREE :=
                                                MAKE_DEF_FOR_ID ( 
                                                SOURCE_NAME, H);
               BEGIN
               
                                        -- WALK THE REDEFINED EXCEPTION NAME
                  NAME := WALK_NAME(DN_EXCEPTION_ID,
                                                NAME);
                  D ( AS_NAME, NODE, NAME);
               
                                        -- $$$$ WHAT ABOUT WHEN NAME IS A RENAMED EXCEPTION ?
               
                                        -- INSERT REDEFINED NAME IN SOURCE NAME
                  IF NAME.TY = DN_SELECTED THEN
                     NAME := D ( AS_DESIGNATOR,
                                                        NAME);
                  END IF;
                  D ( SM_RENAMES_EXC, SOURCE_NAME, D ( 
                                                        SM_DEFN,NAME));
               
                                        -- ADDED 6/29/90 (OMITTED.  WHY WASN'T IT FOUND BY ACVC?)
                                        -- CHECK FOR UNIQUE NAMES AND MAKE VISIBLE
                  CHECK_UNIQUE_DEF(SOURCE_DEF);
               END;
         
         
            WHEN DN_NULL_COMP_DECL =>
               DECLARE
               BEGIN
                  NULL;
               END;
         
         
            WHEN DN_LENGTH_ENUM_REP =>
               DECLARE
                  NAME: TREE := D ( AS_NAME, NODE);
                  EXP: TREE := D ( AS_EXP, NODE);
               BEGIN
                                        -- IF IT IS A LENGTH CLAUSE
                  IF NAME.TY = DN_ATTRIBUTE THEN
                     REP_CLAU.RESOLVE_LENGTH_REP( NAME,EXP, H );
                     D ( AS_EXP, NODE, EXP );
                  
                                                -- ELSE -- IT IS AN ENUMERATION REPRESENTATION CLAUSE
                                                -- ... (BY SYNTAX -- NAME IS USED_OBJECT_ID, EXP IS AGGREGATE)
                  ELSE
                     REP_CLAU.RESOLVE_ENUM_REP ( NAME,EXP, H );
                     D ( AS_NAME, NODE, NAME );
                  END IF;
               END;
         
         
            WHEN DN_ADDRESS =>
               DECLARE
                  NAME: TREE := D ( AS_NAME, NODE);
                  EXP: TREE := D ( AS_EXP, NODE);
               BEGIN
                  REP_CLAU.RESOLVE_ADDRESS_REP(NAME,
                                                EXP,H);
                  D ( AS_NAME, NODE, NAME);
                  D ( AS_EXP, NODE, EXP);
               END;
         
         
            WHEN DN_RECORD_REP =>
               DECLARE
                  NAME: TREE := D ( AS_NAME, NODE);
                  ALIGNMENT_CLAUSE: TREE := D ( 
                                                AS_ALIGNMENT_CLAUSE, NODE);
                  COMP_REP_S: TREE := D ( 
                                                AS_COMP_REP_S, NODE);
               BEGIN
                  REP_CLAU.RESOLVE_RECORD_REP(NAME,
                                                ALIGNMENT_CLAUSE,
                                                COMP_REP_S,H);
                  D ( AS_NAME, NODE, NAME);
                  D ( AS_ALIGNMENT_CLAUSE, NODE,
                                                ALIGNMENT_CLAUSE);
                  D ( AS_COMP_REP_S, NODE, COMP_REP_S);
                  IF D ( SM_DEFN,NAME).TY IN
                                                        CLASS_TYPE_NAME
                                                        AND GET_BASE_TYPE ( 
                                                                NAME).TY =
                                                        DN_RECORD THEN
                     D ( SM_REPRESENTATION,
                                                        GET_BASE_TYPE ( 
                                                                NAME),
                                                        NODE);
                  END IF;
               END;
                        -- FOR A USE CLAUSE (NOT PART OF A CONTEXT CLAUSE)
            WHEN DN_USE =>
               DECLARE
                  NAME_S: TREE := D ( AS_NAME_S, NODE);
               
                  NAME_LIST: SEQ_TYPE := LIST ( 
                                                NAME_S);
                  NAME: TREE;
                  NAME_DEFN: TREE;
                  NEW_NAME_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                  PACKAGE_DEF: TREE;
               BEGIN
               
                                        -- FOR EACH USED NAME
                  WHILE NOT IS_EMPTY ( NAME_LIST) LOOP
                     POP ( NAME_LIST, NAME);
                                                -- EVALUATE AND RESOLVE PACKAGE NAME
                     NAME := WALK_NAME ( DN_PACKAGE_ID, NAME );
                     NEW_NAME_LIST := APPEND ( NEW_NAME_LIST, NAME );
                                                -- GET THE PACKAGE ID OF THE ORIGINAL (UNRENAMED) PACKAGE
                     LOOP
                        IF NAME.TY = DN_SELECTED THEN
                           NAME := D ( AS_DESIGNATOR, NAME );
                        END IF;
                        NAME_DEFN := D ( SM_DEFN, NAME );
                        EXIT WHEN NAME_DEFN.TY /= DN_PACKAGE_ID
                           OR ELSE D ( SM_UNIT_DESC, NAME_DEFN).TY /= DN_RENAMES_UNIT;
                        NAME := D ( AS_NAME, D ( SM_UNIT_DESC, NAME_DEFN ) );
                     END LOOP;
                                                -- IF IT IS INDEED A PACKAGE ID
                     IF NAME_DEFN.TY = DN_PACKAGE_ID THEN
                                                        -- GET THE DEF CORRESPONDING TO THE PACKAGE
                        PACKAGE_DEF :=
                                                                GET_DEF_FOR_ID ( 
                                                                NAME_DEFN);
                     
                                                        -- IF IT IS NOT AN ENCLOSING REGION AND NOT USED
                        IF DI ( 
                                                                        XD_LEX_LEVEL,
                                                                        PACKAGE_DEF) <=
                                                                        0
                                                                        AND THEN NOT
                                                                        DB ( 
                                                                        XD_IS_USED,
                                                                        PACKAGE_DEF) THEN
                        
                                                                -- MARK IT USED
                           DB ( 
                                                                        XD_IS_USED,
                                                                        PACKAGE_DEF,
                                                                        TRUE);
                        
                                                                -- ADD IT TO LIST OF USED REGIONS
                           SU.USED_PACKAGE_LIST
                                                                        :=
                                                                        INSERT ( 
                                                                        SU.USED_PACKAGE_LIST,
                                                                        PACKAGE_DEF);
                        END IF;
                     END IF;
                  END LOOP;
               
                                        -- REPLACE NAME LIST WITH LIST OF RESOLVED NAMES
                  LIST ( NAME_S, NEW_NAME_LIST);
               END;
         
         
            WHEN DN_PRAGMA =>
               DECLARE
                  USED_NAME_ID	: TREE	:= D ( AS_USED_NAME_ID, NODE );
                  GENERAL_ASSOC_S	: TREE	:= D ( AS_GENERAL_ASSOC_S, NODE );
               BEGIN
                  WALK_PRAGMA ( USED_NAME_ID, GENERAL_ASSOC_S, H );
               END;
         
            WHEN DN_SUBPROGRAM_BODY =>
               DECLARE
                  SOURCE_NAME: TREE := D ( 
                                                AS_SOURCE_NAME, NODE);
                  FIRST_NAME: TREE := D ( SM_FIRST,
                                                SOURCE_NAME);
                  BODY_NODE: TREE := D ( AS_BODY, NODE);
                  FIRST_HEADER: TREE := TREE_VOID;
                  HEADER: TREE := D ( AS_HEADER, NODE);
               
                  H: H_TYPE := WALK.H;
                  S: S_TYPE;
                  SOURCE_DEF: TREE;
                  PRIOR_DEF: TREE;
               BEGIN
                  IF SOURCE_NAME.TY = DN_OPERATOR_ID THEN
                     FORCE_UPPER_CASE ( SOURCE_NAME );
                  END IF;
                  SOURCE_DEF := MAKE_DEF_FOR_ID ( SOURCE_NAME, H );
                  D ( SM_SPEC, SOURCE_NAME, HEADER );
                  D ( SM_UNIT_DESC, SOURCE_NAME, TREE_VOID );
                                        --D ( XD_BODY, SOURCE_NAME, BODY_NODE);
               
                  IF FIRST_NAME = SOURCE_NAME THEN
                     PRIOR_DEF := GET_PRIOR_DEF ( 
                                                        SOURCE_DEF);
                     IF PRIOR_DEF /= TREE_VOID
                        AND THEN D (  XD_SOURCE_NAME, PRIOR_DEF).TY = DN_GENERIC_ID
                     THEN
                        FIRST_NAME := D ( XD_SOURCE_NAME, PRIOR_DEF );
                        PRIOR_DEF := GET_DEF_FOR_ID ( FIRST_NAME );
                     ELSE
                        PRIOR_DEF := SOURCE_DEF;
                     END IF;
                  ELSE
                     PRIOR_DEF := GET_DEF_FOR_ID ( FIRST_NAME );
                                                -- LIBRARY UNIT WITH EXISTING SUBPROGRAM SPEC
                                                -- $$$$ WORRY ABOUT KILLING PRIOR BODY IN THIS COMPILATION
                     D ( XD_REGION_DEF, PRIOR_DEF, H.REGION_DEF );
                  END IF;
               
                  IF SOURCE_DEF /= PRIOR_DEF
                     AND THEN D ( SM_SPEC, D ( XD_SOURCE_NAME, SOURCE_DEF ) ) = D ( SM_SPEC, D ( XD_SOURCE_NAME, PRIOR_DEF ) )
                  THEN
                                                -- (SPEC WAS GENERATED IN LIBPHASE; DO NOT REDO IT)
                     NULL;
                  ELSE
                     ENTER_REGION ( SOURCE_DEF, H,
                                                        S);
                                                --WALK_ITEM_S(D ( AS_PARAM_S,HEADER), H);
                     H.SUBP_SYMREP := D ( 
                                                        LX_SYMREP,
                                                        SOURCE_NAME);
                     IF SOURCE_DEF /= PRIOR_DEF
                                                                AND THEN FIRST_NAME.TY =
                                                                DN_GENERIC_ID THEN
                                                        -- (SPEC IS GENERIC) - $$$$
                        SWITCH_REGION ( 
                                                                FIRST_NAME,
                                                                SOURCE_DEF);
                        WALK_HEADER ( 
                                                                HEADER, H);
                        SWITCH_REGION ( 
                                                                FIRST_NAME,
                                                                PRIOR_DEF);
                     ELSE
                        WALK_HEADER ( 
                                                                HEADER, H);
                     END IF;
                     LEAVE_REGION ( SOURCE_DEF, S);
                     H := WALK.H;
                  END IF;
               
                  IF FIRST_NAME = SOURCE_NAME THEN
                                                -- (LOOK FOR A SUBPROGRAM DECLARATION)
                     MAKE_DEF_VISIBLE ( 
                                                        SOURCE_DEF, HEADER);
                     PRIOR_DEF :=
                                                        GET_PRIOR_HOMOGRAPH_DEF(
                                                        SOURCE_DEF);
                     IF PRIOR_DEF /= TREE_VOID THEN
                        REMOVE_DEF_FROM_ENVIRONMENT ( 
                                                                SOURCE_DEF);
                        FIRST_NAME := D ( 
                                                                XD_SOURCE_NAME,
                                                                PRIOR_DEF);
                     END IF;
                  END IF;
                  IF PRIOR_DEF = TREE_VOID THEN
                     MAKE_DEF_VISIBLE ( 
                                                        SOURCE_DEF, HEADER);
                     CHECK_EQUALITY_OPERATOR ( 
                                                        SOURCE_NAME, H);
                  ELSE
                     IF FIRST_NAME.TY IN
                                                                CLASS_SUBPROG_NAME
                                                                OR FIRST_NAME.TY =
                                                                DN_GENERIC_ID THEN
                        FIRST_HEADER := D ( 
                                                                SM_SPEC,
                                                                FIRST_NAME);
                     END IF;
                     IF FIRST_HEADER.TY /= HEADER.TY THEN
                        IF D ( XD_HEADER,
                                                                        PRIOR_DEF) /=
                                                                        TREE_FALSE THEN
                           ERROR ( D ( 
                                                                                LX_SRCPOS,
                                                                                SOURCE_NAME)
                                                                        ,
                                                                        "DUPLICATE DEF FOR SUBPROGRAM NAME - "
                                                                        &
                                                                        PRINT_NAME ( 
                                                                                D ( 
                                                                                        LX_SYMREP,
                                                                                        SOURCE_NAME)) );
                        END IF;
                        MAKE_DEF_IN_ERROR ( 
                                                                SOURCE_DEF);
                        FIRST_NAME :=
                                                                SOURCE_NAME;
                     ELSE
                        D ( SM_FIRST,
                                                                SOURCE_NAME,
                                                                FIRST_NAME);
                     END IF;
                  END IF;
               
                  IF FIRST_NAME /= SOURCE_NAME THEN
                                                --D ( XD_BODY, FIRST_NAME, BODY_NODE);
                     D ( SM_SPEC, SOURCE_NAME, D ( 
                                                                SM_SPEC,
                                                                FIRST_NAME));
                     CONFORM_PARAMETER_LISTS
                                                        ( D ( AS_PARAM_S, D ( 
                                                                        SM_SPEC,
                                                                        FIRST_NAME))
                                                        , D ( AS_PARAM_S,
                                                                HEADER) );
                     REMOVE_DEF_FROM_ENVIRONMENT ( 
                                                        SOURCE_DEF);
                     SOURCE_DEF := PRIOR_DEF;
                  END IF;
               
                  ENTER_BODY(SOURCE_DEF, H, S);
                  IF FIRST_NAME.TY =
                                                        DN_GENERIC_ID THEN
                     MAKE_DEF_VISIBLE ( 
                                                        SOURCE_DEF, D ( 
                                                                SM_SPEC,
                                                                FIRST_NAME));
                  END IF;
                  IF D ( XD_HEADER,SOURCE_DEF).TY =
                                                        DN_FUNCTION_SPEC THEN
                     H.RETURN_TYPE :=
                                                        GET_BASE_TYPE
                                                        (D ( AS_NAME,D ( 
                                                                        XD_HEADER,
                                                                        SOURCE_DEF)));
                  END IF;
                  WALK_UNIT_DESC ( SOURCE_NAME,
                                                BODY_NODE, H);
                  IF FIRST_NAME.TY =
                                                        DN_GENERIC_ID THEN
                     MAKE_DEF_VISIBLE ( 
                                                        SOURCE_DEF);
                  END IF;
                  LEAVE_BODY(SOURCE_DEF, S);
               END;
         
         
            WHEN DN_PACKAGE_BODY =>
               DECLARE
                  SOURCE_NAME: TREE := D ( 
                                                AS_SOURCE_NAME, NODE);
                  BODY_NODE: TREE := D ( AS_BODY, NODE);
               
                  FIRST_NAME: TREE;
                  H: H_TYPE := WALK.H;
                  S: S_TYPE;
                  SOURCE_DEF: TREE;
               BEGIN
                                        -- CHECK FOR LIBRARY UNIT WITH EXISTING PACKAGE SPEC
                                        -- $$$$ WORRY ABOUT KILLING PRIOR BODY IN THIS COMPILATION
                  FIRST_NAME := D ( SM_FIRST,
                                                SOURCE_NAME);
                  IF FIRST_NAME /= SOURCE_NAME THEN
                     SOURCE_DEF :=
                                                        GET_DEF_FOR_ID ( D ( 
                                                                SM_FIRST,
                                                                SOURCE_NAME));
                     D ( XD_REGION_DEF,
                                                        SOURCE_DEF,
                                                        H.REGION_DEF);
                  END IF;
               
                  SOURCE_DEF := GET_DEF_IN_REGION(
                                                SOURCE_NAME, H);
                  IF SOURCE_DEF = TREE_VOID THEN
                     ERROR ( D ( LX_SRCPOS,NODE)
                                                        ,
                                                        "NO SPECIFICATION FOUND FOR PACKAGE - "
                                                        & PRINT_NAME ( D ( 
                                                                        LX_SYMREP,
                                                                        SOURCE_NAME)) );
                     SOURCE_DEF :=
                                                        MAKE_DEF_FOR_ID ( 
                                                        SOURCE_NAME, H);
                     D ( SM_SPEC, SOURCE_NAME,
                                                        TREE_VOID);
                                                -- AVOID CRASH
                     MAKE_DEF_IN_ERROR ( 
                                                        SOURCE_DEF);
                  ELSE
                     FIRST_NAME := D ( 
                                                        XD_SOURCE_NAME,
                                                        SOURCE_DEF);
                     IF FIRST_NAME.TY /=
                                                                DN_PACKAGE_ID
                                                                AND THEN (
                                                                FIRST_NAME.TY /=
                                                                DN_GENERIC_ID
                                                                OR ELSE
                                                                D (  SM_SPEC,FIRST_NAME).TY
                                                                /=
                                                                DN_PACKAGE_SPEC)
                                                                THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        NODE)
                                                                ,
                                                                "DUPLICATE NAME FOR PACKAGE - "
                                                                &
                                                                PRINT_NAME ( 
                                                                        D ( 
                                                                                LX_SYMREP,
                                                                                SOURCE_NAME)) );
                        SOURCE_DEF :=
                                                                MAKE_DEF_FOR_ID ( 
                                                                SOURCE_NAME,
                                                                H);
                        MAKE_DEF_IN_ERROR ( 
                                                                SOURCE_DEF);
                        FIRST_NAME :=
                                                                SOURCE_NAME;
                     ELSIF D ( XD_BODY,
                                                                FIRST_NAME) /=
                                                                TREE_VOID THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        NODE)
                                                                ,
                                                                "DUPLICATE BODY FOR PACKAGE - "
                                                                &
                                                                PRINT_NAME ( 
                                                                        D ( 
                                                                                LX_SYMREP,
                                                                                SOURCE_NAME)) );
                     END IF;
                  END IF;
               
                  D ( SM_FIRST, SOURCE_NAME,
                                                FIRST_NAME);
                  D ( SM_SPEC, SOURCE_NAME, D ( SM_SPEC,
                                                        FIRST_NAME));
                  D ( SM_UNIT_DESC, SOURCE_NAME,
                                                TREE_VOID);
                  D ( XD_REGION, SOURCE_NAME, D ( 
                                                        XD_REGION,
                                                        FIRST_NAME));
                  IF BODY_NODE.TY = DN_STUB THEN
                     NULL;
                                                -- D ( XD_STUB, SOURCE_NAME, SOURCE_NAME);
                                                -- D ( XD_STUB, FIRST_NAME, SOURCE_NAME);
                  ELSE
                                                -- D ( XD_BODY, FIRST_NAME, NODE);
                                                -- D ( XD_BODY, SOURCE_NAME, NODE);
                                                -- D ( XD_STUB, SOURCE_NAME, D ( XD_STUB, FIRST_NAME));
                     ENTER_BODY(SOURCE_DEF, H,
                                                        S);
                                                -- SCAN SPEC FOR USE CLAUSES
                     DECLARE
                        SPEC: TREE := D ( 
                                                                SM_SPEC,
                                                                SOURCE_NAME);
                     BEGIN
                        IF SPEC /=
                                                                        TREE_VOID THEN
                           REPROCESS_USE_CLAUSES(
                                                                        D ( 
                                                                                AS_DECL_S1,
                                                                                SPEC),
                                                                        H);
                           REPROCESS_USE_CLAUSES(
                                                                        D ( 
                                                                                AS_DECL_S2,
                                                                                SPEC),
                                                                        H);
                        END IF;
                     END;
                     WALK_UNIT_DESC ( 
                                                        SOURCE_NAME,
                                                        BODY_NODE, H);
                     LEAVE_BODY(SOURCE_DEF, S);
                  END IF;
               END;
         
         
            WHEN DN_TASK_BODY =>
               DECLARE
                  SOURCE_NAME: TREE := D ( 
                                                AS_SOURCE_NAME, NODE);
                  BODY_NODE: TREE := D ( AS_BODY, NODE);
               
                  H: H_TYPE := WALK.H;
                  S: S_TYPE;
               
                  SOURCE_DEF: TREE :=
                                                MAKE_DEF_FOR_ID ( 
                                                SOURCE_NAME,H);
                  PRIOR_DEF: TREE;
                  PRIOR_NAME: TREE;
                  TASK_TYPE: TREE := TREE_VOID;
               BEGIN
               
                  PRIOR_DEF := GET_PRIOR_DEF ( 
                                                SOURCE_DEF);
                  IF PRIOR_DEF /= TREE_VOID THEN
                     TASK_TYPE := GET_BASE_TYPE ( 
                                                        D ( XD_SOURCE_NAME,
                                                                PRIOR_DEF));
                  END IF;
               
                  D ( SM_TYPE_SPEC, SOURCE_NAME,
                                                TASK_TYPE);
                  D ( SM_BODY, SOURCE_NAME, BODY_NODE);
                  IF TASK_TYPE.TY /= DN_TASK_SPEC THEN
                     ERROR ( D ( LX_SRCPOS,NODE),
                                                        "NO TASK [TYPE] DECLARATION");
                     MAKE_DEF_IN_ERROR ( 
                                                        SOURCE_DEF);
                     PRIOR_NAME := SOURCE_NAME;
                     TASK_TYPE := TREE_VOID;
                  ELSE
                     REMOVE_DEF_FROM_ENVIRONMENT ( 
                                                        SOURCE_DEF);
                     PRIOR_NAME := D ( 
                                                        XD_SOURCE_NAME,
                                                        PRIOR_DEF);
                     D ( SM_FIRST, SOURCE_NAME,
                                                        PRIOR_NAME);
                     IF D ( XD_BODY, TASK_TYPE) /=
                                                                TREE_VOID
                                                                OR ELSE (
                                                                D ( XD_STUB,
                                                                        TASK_TYPE) /=
                                                                TREE_VOID
                                                                AND THEN
                                                                BODY_NODE.TY =
                                                                DN_STUB)
                                                                THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        SOURCE_NAME),
                                                                "DUPLICATE BODY OR STUB DECLARATION");
                        TASK_TYPE :=
                                                                TREE_VOID;
                     ELSE
                        SOURCE_DEF :=
                                                                PRIOR_DEF;
                                                        --D ( SM_BODY, TASK_TYPE, BODY_NODE);
                     END IF;
                  END IF;
               
                  IF BODY_NODE.TY /= DN_STUB THEN
                     IF TASK_TYPE /= TREE_VOID THEN
                        NULL;
                                                        -- D ( XD_BODY, TASK_TYPE, BODY_NODE);
                     END IF;
                  ELSE
                     IF TASK_TYPE /= TREE_VOID THEN
                        NULL;
                                                        -- D ( XD_STUB, TASK_TYPE, SOURCE_NAME);
                     END IF;
                  END IF;
               
                  ENTER_BODY(SOURCE_DEF, H, S);
                  WALK_UNIT_DESC ( SOURCE_NAME,
                                                BODY_NODE, H);
                  LEAVE_BODY(SOURCE_DEF, S);
               END;
         
         END CASE;
      
      END WALK;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE WALK_SOURCE_NAME_S
       PROCEDURE WALK_SOURCE_NAME_S ( SOURCE_NAME_S :TREE; H :H_TYPE ) IS
         SOURCE_NAME_LIST: SEQ_TYPE := LIST ( SOURCE_NAME_S);
         SOURCE_NAME: TREE;
         DUMMY_DEF: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST) LOOP
            POP ( SOURCE_NAME_LIST, SOURCE_NAME);
            DUMMY_DEF := MAKE_DEF_FOR_ID ( SOURCE_NAME, H);
         END LOOP;
      END WALK_SOURCE_NAME_S;
   
   
   
   
   
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE ENTER_REGION
       PROCEDURE ENTER_REGION ( DEF :TREE; H :IN OUT H_TYPE; S :OUT S_TYPE ) IS
      BEGIN
         S.SB := SB;
         S.SU := SU;
         H.REGION_DEF := DEF;
         H.LEX_LEVEL := H.LEX_LEVEL + 1;
         DI ( XD_LEX_LEVEL, DEF, H.LEX_LEVEL);
         H.IS_IN_SPEC := TRUE;
         H.IS_IN_BODY := FALSE;
         H.RETURN_TYPE := TREE_VOID;
         SU.USED_PACKAGE_LIST := (TREE_NIL,TREE_NIL);
      END ENTER_REGION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE LEAVE_REGION
       PROCEDURE LEAVE_REGION ( DEF :TREE; S :S_TYPE ) IS
         PACKAGE_DEF	: TREE;
      BEGIN
         DI ( XD_LEX_LEVEL, DEF, 0 );
         WHILE NOT IS_EMPTY ( SU.USED_PACKAGE_LIST ) LOOP
            POP ( SU.USED_PACKAGE_LIST, PACKAGE_DEF );
            DB ( XD_IS_USED, PACKAGE_DEF, FALSE );
         END LOOP;
         SB := S.SB;
         SU := S.SU;
      END LEAVE_REGION;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE ENTER_BODY
       PROCEDURE ENTER_BODY ( DEF :TREE; H :IN OUT H_TYPE; S :OUT S_TYPE ) IS
      BEGIN
         ENTER_REGION ( DEF, H, S);
         H.IS_IN_SPEC := FALSE;
         H.IS_IN_BODY := TRUE;
         IF D ( XD_SOURCE_NAME, DEF).TY = DN_GENERIC_ID
                                AND THEN D ( XD_HEADER, DEF) /= TREE_FALSE THEN
            MAKE_DEF_VISIBLE ( DEF, D ( SM_SPEC,D ( XD_SOURCE_NAME,
                                                DEF)));
         END IF;
      END ENTER_BODY;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE LEAVE_BODY
       PROCEDURE LEAVE_BODY ( DEF :TREE; S :S_TYPE ) IS
      BEGIN
         LEAVE_REGION ( DEF, S);
         IF D ( XD_SOURCE_NAME, DEF).TY = DN_GENERIC_ID
                                AND THEN D ( XD_HEADER, DEF) /= TREE_FALSE THEN
            MAKE_DEF_VISIBLE ( DEF);
         END IF;
      END LEAVE_BODY;
   
   
   
   
   
   
   
   
       PROCEDURE FINISH_VARIABLE_DECL(NODE: TREE; H: H_TYPE) IS
         SOURCE_NAME_S: TREE := D ( AS_SOURCE_NAME_S, NODE);
         EXP: TREE := D ( AS_EXP, NODE);
         TYPE_DEF: TREE := D ( AS_TYPE_DEF, NODE);
      
         TYPE_SPEC: TREE;
         TYPESET: TYPESET_TYPE;
      BEGIN
         TYPE_SPEC := EVAL_SUBTYPE_INDICATION(TYPE_DEF);
         RESOLVE_SUBTYPE_INDICATION(TYPE_DEF, TYPE_SPEC);
         D ( AS_TYPE_DEF, NODE, TYPE_DEF);
      
         IF EXP /= TREE_VOID THEN
            IF NOT IS_NONLIMITED_TYPE(TYPE_SPEC) THEN
               ERROR ( D ( LX_SRCPOS, TYPE_DEF),
                                        "INITIAL VALUE FOR LIMITED TYPE");
               TYPE_SPEC := TREE_VOID;
            END IF;
         
            EVAL_EXP_TYPES(EXP, TYPESET);
            REQUIRE_TYPE(GET_BASE_TYPE ( TYPE_SPEC), EXP,
                                TYPESET);
            EXP := RESOLVE_EXP(EXP, TYPESET);
         END IF;
      
         INSERT_OBJ_TYPE_AND_INIT_EXP_IN_S(SOURCE_NAME_S
                        , OBJ_TYPE => TYPE_SPEC
                        , INIT_EXP => EXP);
      END FINISH_VARIABLE_DECL;
   
   
       FUNCTION WALK_EXP_MUST_BE_NAME(NAME: TREE) RETURN TREE IS
         NAME_KIND: NODE_NAME := NAME.TY;
         DEFSET: DEFSET_TYPE;
      BEGIN
         IF NAME_KIND = DN_USED_OBJECT_ID
                                OR NAME_KIND = DN_SELECTED THEN
            FIND_VISIBILITY(NAME, DEFSET);
            REQUIRE_UNIQUE_DEF(NAME, DEFSET);
            RETURN RESOLVE_NAME(NAME, GET_THE_ID(DEFSET));
         ELSE
            ERROR ( D ( LX_SRCPOS, NAME), "NAME REQUIRED");
            RETURN WALK_ERRONEOUS_EXP(NAME);
         END IF;
      END WALK_EXP_MUST_BE_NAME;
   
   
       FUNCTION WALK_NAME(ID_KIND: NODE_NAME; NAME: TREE) RETURN TREE IS
         NEW_NAME: CONSTANT TREE := WALK_EXP_MUST_BE_NAME(NAME);
         NAME_DEFN: TREE := GET_NAME_DEFN(NEW_NAME);
      BEGIN
      
         IF NAME_DEFN = TREE_VOID OR ELSE NAME_DEFN.TY =
                                ID_KIND THEN
            NULL;
         ELSIF ID_KIND = DN_PACKAGE_ID
                                AND THEN NAME_DEFN.TY = DN_GENERIC_ID
                                AND THEN D ( SM_SPEC,NAME_DEFN).TY =
                                DN_PACKAGE_SPEC
                                AND THEN DI ( XD_LEX_LEVEL,GET_DEF_FOR_ID ( 
                                        NAME_DEFN)) > 0
                                THEN
            NULL;
         ELSE
            ERROR ( D ( LX_SRCPOS, NAME), "NAME MUST BE " &
                                NODE_IMAGE(ID_KIND));
                        -- ADDED WBE 9/21/90
                        -- CLEAR DEFN IF WRONG KIND
            IF NEW_NAME.TY = DN_SELECTED THEN
               D ( SM_DEFN, D ( AS_DESIGNATOR, NEW_NAME),
                                        TREE_VOID);
            ELSE
               D ( SM_DEFN, NEW_NAME, TREE_VOID);
            END IF;
         END IF;
      
         RETURN NEW_NAME;
      END WALK_NAME;
   
   
       FUNCTION WALK_TYPE_MARK(NAME: TREE) RETURN TREE IS
         NEW_NAME: CONSTANT TREE := WALK_EXP_MUST_BE_NAME(NAME);
         NAME_DEFN: TREE := GET_NAME_DEFN(NEW_NAME);
      BEGIN
      
         IF NAME_DEFN.TY NOT IN CLASS_TYPE_NAME
                                AND THEN NAME_DEFN /= TREE_VOID THEN
            ERROR ( D ( LX_SRCPOS, NAME), "TYPE MARK REQUIRED");
         END IF;
      
         RETURN NEW_NAME;
      END WALK_TYPE_MARK;
   
   
       PROCEDURE WALK_DISCRETE_CHOICE_S(CHOICE_S: TREE; TYPE_SPEC: TREE) IS
         CHOICE_LIST:	SEQ_TYPE := LIST ( CHOICE_S);
         CHOICE: 	TREE;
      
         NEW_CHOICE_LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
         EXP:		TREE;
         TYPESET:	TYPESET_TYPE;
         IS_SUBTYPE:	BOOLEAN;
      BEGIN
         WHILE NOT IS_EMPTY ( CHOICE_LIST) LOOP
            POP ( CHOICE_LIST, CHOICE);
         
            CASE CLASS_CHOICE'(CHOICE.TY) IS
               WHEN DN_CHOICE_EXP =>
                  EXP := D ( AS_EXP, CHOICE);
                  EVAL_EXP_SUBTYPE_TYPES(EXP,
                                                TYPESET, IS_SUBTYPE);
                  REQUIRE_TYPE(TYPE_SPEC, EXP,
                                                TYPESET);
                  IF NOT IS_SUBTYPE THEN
                     EXP := RESOLVE_EXP(EXP,
                                                        GET_THE_TYPE(
                                                                TYPESET));
                     D ( AS_EXP, CHOICE, EXP);
                  ELSE
                     EXP :=
                                                        RESOLVE_DISCRETE_RANGE(
                                                        EXP, GET_THE_TYPE(
                                                                TYPESET));
                     CHOICE :=
                                                        MAKE_CHOICE_RANGE
                                                        ( LX_SRCPOS => D ( 
                                                                LX_SRCPOS,
                                                                CHOICE)
                                                        ,
                                                        AS_DISCRETE_RANGE =>
                                                        EXP );
                  
                  END IF;
               WHEN DN_CHOICE_RANGE =>
                  EXP := D ( AS_DISCRETE_RANGE, CHOICE);
                  EVAL_DISCRETE_RANGE(EXP, TYPESET);
                  REQUIRE_TYPE(TYPE_SPEC, EXP,
                                                TYPESET);
                  EXP := RESOLVE_DISCRETE_RANGE(EXP,
                                                GET_THE_TYPE(TYPESET));
                  D ( AS_DISCRETE_RANGE, CHOICE, EXP);
            
               WHEN DN_CHOICE_OTHERS =>
                  NULL;
            END CASE;
         
            NEW_CHOICE_LIST := APPEND (NEW_CHOICE_LIST, CHOICE);
         END LOOP;
         LIST ( CHOICE_S, NEW_CHOICE_LIST);
      END WALK_DISCRETE_CHOICE_S;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE WALK_ITEM_S
       PROCEDURE WALK_ITEM_S (ITEM_S: TREE; H: H_TYPE) IS
         ITEM_LIST: SEQ_TYPE := LIST ( ITEM_S);
         ITEM: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( ITEM_LIST) LOOP
            POP ( ITEM_LIST, ITEM);
            WALK(ITEM,H);
         END LOOP;
      END WALK_ITEM_S;
   
   --|----------------------------------------------------------------------------------------------
   END NOD_WALK;
