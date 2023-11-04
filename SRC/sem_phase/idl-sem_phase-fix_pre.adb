SEPARATE( IDL.SEM_PHASE )
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE FIX_PRE
--|-------------------------------------------------------------------------------------------------
PROCEDURE FIX_PRE IS
   
  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION COPY_NODE
  FUNCTION COPY_NODE ( NODE : TREE ) RETURN TREE IS
  BEGIN
    IF NODE.PT = HI OR NODE.PT = S THEN RETURN NODE;					--| PAS DE COPIE DE BLOC ATTRIBUTS DANS CES CAS
    ELSE
      DECLARE
        LEN	: ATTR_NBR	:= DABS( 0, NODE ).NSIZ;
        RESULT	: TREE		:= MAKE( NODE.TY, LEN );
      BEGIN
        FOR I IN 1 .. LEN LOOP
          DABS( I, RESULT, DABS( I, NODE ) );
        END LOOP;
        RETURN RESULT;
      END;
    END IF;
  END COPY_NODE;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE ABORT_RUN
  PROCEDURE ABORT_RUN ( MSG :STRING ) IS
  BEGIN
    SET_OUTPUT( STANDARD_OUTPUT );
    PUT( "**** " );
    PUT_LINE( MSG );
  END ABORT_RUN;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE DEFINE_ID
   PROCEDURE DEFINE_ID ( ID :TREE ) IS
   BEGIN
     IF ID.TY NOT IN CLASS_ENUM_LITERAL AND THEN ID.TY /= DN_CONSTANT_ID THEN
       PUT_LINE( PRINT_NAME( D( LX_SYMREP, ID ) ) );
     END IF;
     LIST( D( LX_SYMREP, ID ), SINGLETON( ID ) );						--| METTRE LE SINGLETON ID DANS LA XD_DEFLIST DU SYMBOLE (DOUBLE CHAÎNAGE ENTRE LES DEUX)
   END DEFINE_ID;
   --|----------------------------------------------------------------------------------------------
   --|	PROCEDURE HEAD_DEFN
   FUNCTION HEAD_DEFN ( USED_ID_OR_SYMREP :TREE ) RETURN TREE IS
     SYMREP	: TREE	:= USED_ID_OR_SYMREP;
     DEFLIST	: SEQ_TYPE;
   BEGIN
     IF USED_ID_OR_SYMREP.TY /= DN_SYMBOL_REP THEN					--| UN USED_NAME_ID OU USED_OBJECT_ID
       SYMREP := D( LX_SYMREP, USED_ID_OR_SYMREP );
     END IF;
     DEFLIST := LIST( SYMREP );
      
     IF IS_EMPTY( DEFLIST ) THEN
       PUT( "SYMBOL NOT DEFINED -- " );
       PUT_LINE( PRINT_NAME( SYMREP ) );
       RETURN TREE_VOID;
     ELSE
       RETURN HEAD( DEFLIST );
     END IF;
  END HEAD_DEFN;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE GET_BASE_TYPE
    FUNCTION GET_BASE_TYPE ( TYPE_SPEC :TREE ) RETURN TREE IS
    BEGIN
      IF TYPE_SPEC.TY IN CLASS_NON_TASK THEN
        RETURN D( SM_BASE_TYPE, TYPE_SPEC );
      ELSE
        RETURN TYPE_SPEC;
      END IF;
    END GET_BASE_TYPE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE TYPE_SPEC_FOR_SUBTYPE
    FUNCTION TYPE_SPEC_FOR_SUBTYPE ( SUBTYPE_INDICATION :TREE ) RETURN TREE IS
      CONSTRAINT		: TREE;
      NAME		: TREE;
      BASE_TYPE		: TREE;
      USE MAKE_NOD;
    BEGIN
      IF SUBTYPE_INDICATION.TY = DN_SUBTYPE_INDICATION THEN
        CONSTRAINT := D( AS_CONSTRAINT, SUBTYPE_INDICATION );
        NAME := D( AS_NAME, SUBTYPE_INDICATION );
      ELSE
        CONSTRAINT := TREE_VOID;
        NAME := SUBTYPE_INDICATION;
      END IF;
      
      BASE_TYPE := D( SM_TYPE_SPEC, D( SM_DEFN, NAME ) );
      IF CONSTRAINT = TREE_VOID THEN
        RETURN BASE_TYPE;
      ELSIF BASE_TYPE.TY = DN_INTEGER THEN
        D( SM_TYPE_SPEC, CONSTRAINT, BASE_TYPE);
        D( SM_EXP_TYPE, D ( AS_EXP1, CONSTRAINT), BASE_TYPE );
        D( SM_EXP_TYPE, D ( AS_EXP2, CONSTRAINT), BASE_TYPE );
        RETURN MAKE_INTEGER (
		SM_RANGE => CONSTRAINT,
               	SM_BASE_TYPE => BASE_TYPE,
               	XD_SOURCE_NAME => D( XD_SOURCE_NAME, BASE_TYPE ) );
      END IF;
      ABORT_RUN ( "BAD TYPE FOR SUBTYPE_INDICATION" );
      RAISE PROGRAM_ERROR;
    END TYPE_SPEC_FOR_SUBTYPE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE WALK
    PROCEDURE WALK ( NODE, PARENT, REGION :TREE ) IS
      USE MAKE_NOD;
    BEGIN
      CASE NODE.TY IS
         
      WHEN DN_VOID =>
        NULL;
         
      WHEN DN_CONSTANT_ID =>
        DEFINE_ID( NODE );
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_ENUMERATION_ID | DN_CHARACTER_ID =>
        DEFINE_ID( NODE );
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_TYPE_ID =>
        DEFINE_ID( NODE );
        D( SM_FIRST, NODE, NODE);
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_SUBTYPE_ID =>
        DEFINE_ID( NODE );
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_PACKAGE_ID =>
        DEFINE_ID( NODE );
        D( SM_FIRST, NODE, NODE);
        D( SM_SPEC, NODE, D ( AS_HEADER, PARENT ) );
        D( SM_UNIT_DESC, NODE, TREE_VOID );
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_EXCEPTION_ID =>
        DEFINE_ID( NODE );
        D( SM_RENAMES_EXC, NODE, TREE_VOID );
        D( XD_REGION, NODE, REGION );
         
      WHEN DN_CONSTANT_DECL =>
        DECLARE
          SOURCE_NAME_S	: CONSTANT TREE := D( AS_SOURCE_NAME_S, NODE );
          EXP		: CONSTANT TREE := D( AS_EXP, NODE );
          TYPE_DEF		: CONSTANT TREE := D( AS_TYPE_DEF, NODE );
        BEGIN
          WALK ( SOURCE_NAME_S, NODE, REGION );
          WALK ( EXP, NODE, REGION );
          WALK ( TYPE_DEF, NODE, REGION );
          DECLARE
            HEAD_SOURCE_NAME	: TREE	:= HEAD( LIST( D( AS_SOURCE_NAME_S, NODE ) ) );
          BEGIN
            D( SM_OBJ_TYPE, HEAD_SOURCE_NAME, TYPE_SPEC_FOR_SUBTYPE( D( AS_TYPE_DEF, NODE ) ) );
            D( SM_INIT_EXP, HEAD_SOURCE_NAME, D( AS_EXP, NODE ) );
          END;
        END;
         
      WHEN DN_EXCEPTION_DECL =>
        DECLARE
          SOURCE_NAME_S	: CONSTANT TREE	:= D( AS_SOURCE_NAME_S, NODE );
        BEGIN
          WALK( SOURCE_NAME_S, NODE, REGION );
        END;
         
      WHEN DN_TYPE_DECL =>
        DECLARE
          SOURCE_NAME	: CONSTANT TREE	:= D( AS_SOURCE_NAME, NODE );
          DSCRMT_DECL_S	: CONSTANT TREE	:= D( AS_DSCRMT_DECL_S, NODE );
          TYPE_DEF		: CONSTANT TREE	:= D( AS_TYPE_DEF, NODE );
        BEGIN
          WALK( SOURCE_NAME, NODE, REGION );
          WALK( DSCRMT_DECL_S, NODE, REGION );
          WALK( TYPE_DEF, NODE, REGION );
               
                                        -- SAVE ANCESTOR TYPE NAME FOR DERIVED TYPE (_ADDRESS)
          IF TYPE_DEF.TY = DN_DERIVED_DEF THEN
            D( SM_TYPE_SPEC, SOURCE_NAME, D( SM_DEFN, D( AS_NAME, D ( AS_SUBTYPE_INDICATION, TYPE_DEF) ) ) );
          END IF;
        END;
         
      WHEN DN_SUBTYPE_DECL =>
        DECLARE
          SOURCE_NAME	: CONSTANT TREE := D( AS_SOURCE_NAME, NODE );
          SUBTYPE_INDICATION	: CONSTANT TREE := D( AS_SUBTYPE_INDICATION, NODE );
          SUBTYPE_NODE	: TREE;
        BEGIN
          WALK( SOURCE_NAME, NODE, REGION );
          WALK( SUBTYPE_INDICATION, NODE, REGION );
               
          SUBTYPE_NODE := TYPE_SPEC_FOR_SUBTYPE( SUBTYPE_INDICATION );
          D( SM_TYPE_SPEC, D( AS_SOURCE_NAME, NODE ), SUBTYPE_NODE );
               
          IF D( AS_CONSTRAINT, SUBTYPE_INDICATION ) /= TREE_VOID THEN
            D( XD_SOURCE_NAME, SUBTYPE_NODE, D(  AS_SOURCE_NAME, NODE ) );
          END IF;
        END;
         
            WHEN DN_PACKAGE_DECL =>
               DECLARE
                  SOURCE_NAME	: CONSTANT TREE := D ( AS_SOURCE_NAME, NODE );
                  HEADER	: CONSTANT TREE := D ( AS_HEADER, NODE );
                  UNIT_KIND	: CONSTANT TREE := D ( AS_UNIT_KIND, NODE );
               BEGIN
                  WALK ( SOURCE_NAME, NODE, REGION );
                  WALK ( HEADER, NODE, REGION => SOURCE_NAME );
                  WALK ( UNIT_KIND, NODE, REGION => SOURCE_NAME );
               END;
         
            WHEN DN_LENGTH_ENUM_REP =>
               DECLARE
                  NAME	: CONSTANT TREE	:= D ( AS_NAME, NODE );
                  EXP	: CONSTANT TREE	:= D ( AS_EXP, NODE );
               BEGIN
                                        --ONLY WALK PREFIX OF ATTRIBUTE, NOT ATTRIBUTE NAME
                  WALK ( D ( AS_NAME, NAME), NODE, REGION );
                  WALK ( EXP, NODE, REGION );
                                        -- IN SOURCE TO INDICATE CD_IMPL_SIZE FOR A TYPE
                                        -- FORM IS: FOR NNN'SIZE USE 999;
                  D ( CD_IMPL_SIZE, D ( SM_TYPE_SPEC, D ( SM_DEFN, D ( AS_NAME, NAME))), D ( SM_VALUE, EXP ) );
               END;
         
            WHEN DN_PRAGMA =>
               DECLARE
                  USED_NAME_ID	: CONSTANT TREE := D ( AS_USED_NAME_ID, NODE );
                  GENERAL_ASSOC_S	: CONSTANT TREE := D ( AS_GENERAL_ASSOC_S, NODE );
               BEGIN
                  WALK ( USED_NAME_ID, NODE, REGION);
                  WALK ( GENERAL_ASSOC_S, NODE, REGION);
                                        -- IN SOURCE TO INDICATE PRAGMA PACKED (STRING)
                  DB ( SM_IS_PACKED, D ( SM_TYPE_SPEC, D ( SM_DEFN, HEAD ( LIST ( GENERAL_ASSOC_S ) ) ) ), TRUE );
               END;
         
            WHEN DN_ENUMERATION_DEF =>
               DECLARE
                  ENUM_LITERAL_S	: CONSTANT TREE	:= D ( AS_ENUM_LITERAL_S, NODE);
                  RANGE_NODE	: TREE	:= MAKE ( DN_RANGE );
                  ENUMERATION	: TREE	:= MAKE_ENUMERATION (
                  			SM_LITERAL_S	=> ENUM_LITERAL_S,
                  			SM_RANGE	=> RANGE_NODE,
                  			CD_IMPL_SIZE	=> 8,
                  			XD_SOURCE_NAME	=> D ( AS_SOURCE_NAME, PARENT )
                  			);
                  ENUM_LITERAL_LIST	: SEQ_TYPE	:= LIST ( ENUM_LITERAL_S );
                  ENUM_LITERAL_FIRST	: TREE	:= HEAD ( ENUM_LITERAL_LIST );
                  ENUM_LITERAL	: TREE;
                  ENUM_POS	: INTEGER	:= -1;
               BEGIN
                  D ( LX_SRCPOS, RANGE_NODE, TREE_VOID );
               
                  D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, PARENT), ENUMERATION );
                  D ( SM_BASE_TYPE, ENUMERATION, ENUMERATION );
               
                  WHILE NOT IS_EMPTY ( ENUM_LITERAL_LIST) LOOP
                     POP ( ENUM_LITERAL_LIST, ENUM_LITERAL );
                     WALK ( ENUM_LITERAL, ENUM_LITERAL_S, REGION );
                     D ( SM_OBJ_TYPE, ENUM_LITERAL, ENUMERATION );
                     ENUM_POS := ENUM_POS + 1;
                     DI ( SM_POS, ENUM_LITERAL, ENUM_POS );
                     DI ( SM_REP, ENUM_LITERAL, ENUM_POS );
                  END LOOP;
               
                  D ( AS_EXP1, RANGE_NODE, MAKE_USED_OBJECT_ID (
                     	LX_SYMREP	=> D ( LX_SYMREP, ENUM_LITERAL_FIRST ),
                     SM_EXP_TYPE	=> ENUMERATION,
                     SM_VALUE	=> UARITH.U_VAL ( 0 ),
                     SM_DEFN	=> ENUM_LITERAL_FIRST
                     )
                     );
                  D ( AS_EXP2, RANGE_NODE, MAKE_USED_OBJECT_ID (
                     	LX_SYMREP	=> D ( LX_SYMREP, ENUM_LITERAL ),
                     SM_EXP_TYPE	=> ENUMERATION,
                     SM_VALUE	=> UARITH.U_VAL ( ENUM_POS ),
                     SM_DEFN	=> ENUM_LITERAL
                     )
                     );
                  D ( SM_TYPE_SPEC, RANGE_NODE, ENUMERATION );
               END;
         
            WHEN DN_SUBTYPE_INDICATION =>
               DECLARE
                  CONSTRAINT	: CONSTANT TREE	:= D ( AS_CONSTRAINT, NODE );
                  NAME	: CONSTANT TREE	:= D ( AS_NAME, NODE );
               BEGIN
                  WALK ( CONSTRAINT, NODE, REGION );
                  WALK ( NAME, NODE, REGION );
                  D ( AS_NAME, NODE, MAKE_USED_NAME_ID (
                     	SM_DEFN	=> D ( SM_DEFN, NAME ),
                     LX_SYMREP	=> D ( LX_SYMREP, NAME ),
                     LX_SRCPOS	=> D ( LX_SRCPOS, NAME )
                     )
                     );
               END;
         
            WHEN DN_INTEGER_DEF =>
               DECLARE
                  USE UARITH;
                  CONSTRAINT	: CONSTANT TREE	:= D ( AS_CONSTRAINT, NODE );
                  INTEGER_NODE	: TREE	:= MAKE_INTEGER (
                  			SM_RANGE	=> CONSTRAINT,
                  		XD_SOURCE_NAME	=> D ( AS_SOURCE_NAME, PARENT )
                  		);
               BEGIN
                  WALK ( CONSTRAINT, NODE, REGION );
                  D ( SM_TYPE_SPEC, CONSTRAINT, INTEGER_NODE );
                  D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, PARENT ), INTEGER_NODE);
                  D ( SM_BASE_TYPE, INTEGER_NODE, INTEGER_NODE);
               END;
         
            WHEN DN_FLOAT_DEF =>
               DECLARE
                  USE UARITH;
               
                  CONSTRAINT	: CONSTANT TREE	:= D ( AS_CONSTRAINT, NODE );
                  RANGE_NODE	: TREE	:= D ( AS_RANGE, CONSTRAINT );
                  FLOAT_NODE	: TREE	:= MAKE_FLOAT (
                  			SM_RANGE	=> RANGE_NODE,
                  		XD_SOURCE_NAME	=> D ( AS_SOURCE_NAME, PARENT )
                  		);
               BEGIN
                  WALK ( CONSTRAINT, NODE, REGION );
                  D ( SM_TYPE_SPEC, CONSTRAINT, FLOAT_NODE );
                  D ( SM_TYPE_SPEC, RANGE_NODE, FLOAT_NODE );
                  D ( SM_ACCURACY, FLOAT_NODE, D ( SM_VALUE, D ( AS_EXP, CONSTRAINT ) ) );
                  D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, PARENT ), FLOAT_NODE );
                  D ( SM_BASE_TYPE, FLOAT_NODE, FLOAT_NODE );
               END;
         
            WHEN DN_FIXED_DEF =>
               DECLARE
                  USE UARITH;
                  CONSTRAINT	: CONSTANT TREE	:= D ( AS_CONSTRAINT, NODE );
                  RANGE_NODE	: TREE	:= D ( AS_RANGE, CONSTRAINT );
                  FIXED_NODE	: TREE	:= MAKE_FIXED ( SM_RANGE => RANGE_NODE, XD_SOURCE_NAME => D ( AS_SOURCE_NAME, PARENT) );
               BEGIN
                  WALK ( CONSTRAINT, NODE, REGION);
                  D ( SM_TYPE_SPEC, CONSTRAINT, FIXED_NODE );
                  D ( SM_TYPE_SPEC, RANGE_NODE, FIXED_NODE );
                  D ( SM_ACCURACY, FIXED_NODE, D ( SM_VALUE, D ( AS_EXP, CONSTRAINT ) ) );
                  D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, PARENT ), FIXED_NODE );
                  D ( SM_BASE_TYPE, FIXED_NODE, FIXED_NODE );
                  D ( CD_IMPL_SMALL, FIXED_NODE, D ( SM_ACCURACY, FIXED_NODE ) );
               END;
         
            WHEN DN_UNCONSTRAINED_ARRAY_DEF =>
               DECLARE
                  SUBTYPE_INDICATION	: CONSTANT TREE	:= D ( AS_SUBTYPE_INDICATION, NODE );
                  INDEX_S	: CONSTANT TREE	:= D ( AS_INDEX_S, NODE );
               
                  ARRAY_NODE: TREE := MAKE_ARRAY (	SM_INDEX_S	=> INDEX_S,
                  			SM_SIZE	=> TREE_VOID,
                  		XD_SOURCE_NAME	=> D ( AS_SOURCE_NAME, PARENT )
                  	);
               BEGIN
                  WALK ( SUBTYPE_INDICATION, NODE, REGION );
                  WALK ( INDEX_S, NODE, REGION );
                  D ( SM_COMP_TYPE, ARRAY_NODE, TYPE_SPEC_FOR_SUBTYPE ( SUBTYPE_INDICATION ) );
                  D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, PARENT ), ARRAY_NODE );
                  D ( SM_BASE_TYPE, ARRAY_NODE, ARRAY_NODE );
               END;
         
            WHEN DN_USED_CHAR =>
               DECLARE
                  DEFN: TREE := HEAD_DEFN ( NODE);
               BEGIN
                  D ( SM_DEFN, NODE, DEFN);
                  D ( SM_EXP_TYPE, NODE, D ( 
                                                        SM_OBJ_TYPE,DEFN));
                  D ( SM_VALUE, NODE, UARITH.U_VAL(DI ( 
                                                                SM_POS,
                                                                DEFN)));
               END;
         
            WHEN DN_USED_OBJECT_ID =>
               DECLARE
                  DEFN	: TREE	:= HEAD_DEFN ( NODE );
               BEGIN
                  D ( SM_DEFN, NODE, DEFN );
                  IF DEFN.TY = DN_ENUMERATION_ID THEN
                     D ( SM_EXP_TYPE, NODE, D ( SM_OBJ_TYPE, DEFN ) );
                     D ( SM_VALUE, NODE, UARITH.U_VAL ( DI ( SM_POS, DEFN ) ) );
                  END IF;
               END;
         
            WHEN DN_FUNCTION_CALL =>
               DECLARE
                  USE UARITH;
                  USE PRENAME;
               
                  NAME	: CONSTANT TREE	:= D ( AS_NAME, NODE );
                  GENERAL_ASSOC_S	: CONSTANT TREE	:= D ( AS_GENERAL_ASSOC_S, NODE );
                  PARAM	: TREE	:= HEAD ( LIST ( GENERAL_ASSOC_S ) );
                  PARAM2	: TREE	:= TREE_VOID;
                  BLTN_OPERATOR_ID	: TREE	:= HEAD ( LIST ( D ( LX_SYMREP, NAME ) ) );
               BEGIN
                                        -- ONLY FOR UNARY "-", "*", "**" IN RANGES
                  WALK ( GENERAL_ASSOC_S, NODE, REGION );
               
                  IF NOT IS_EMPTY ( TAIL ( LIST ( GENERAL_ASSOC_S))) THEN
                     PARAM2 := HEAD ( TAIL ( LIST ( GENERAL_ASSOC_S ) ) );
                  END IF;
               
                  IF (PARAM2 = TREE_VOID) XOR ( OP_CLASS'VAL ( DI ( SM_OPERATOR, BLTN_OPERATOR_ID ) ) IN CLASS_UNARY_OP ) THEN
                     BLTN_OPERATOR_ID := HEAD ( TAIL ( LIST ( D ( LX_SYMREP, NAME ) ) ) );
                  END IF;
               
                  D ( AS_NAME, NODE, MAKE_USED_OP (
                     	SM_DEFN	=> BLTN_OPERATOR_ID,
                     	LX_SYMREP	=> D ( LX_SYMREP, NAME), LX_SRCPOS => D ( LX_SRCPOS, NAME )
                     	)
                     );
               
                  IF PRINT_NAME ( D ( LX_SYMREP,NAME)) = """-""" THEN
                     IF PARAM2 = TREE_VOID THEN
                        D ( SM_VALUE, NODE, - D ( SM_VALUE, PARAM ) );
                     ELSE
                        D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) - D ( SM_VALUE, PARAM2 ) );
                     END IF;
                  ELSIF PRINT_NAME ( D ( LX_SYMREP, NAME ) ) = """*""" THEN
                     D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) * D ( SM_VALUE, PARAM2 ) );
                  ELSIF PRINT_NAME ( D ( LX_SYMREP, NAME ) ) = """**""" THEN
                     D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) ** D ( SM_VALUE, PARAM2 ) );
                  ELSE
                     ABORT_RUN ( "FUNCTION NOT ALLOWED - " & PRINT_NAME ( D ( LX_SYMREP, NAME ) ) );
                     RAISE PROGRAM_ERROR;
                  END IF;
               
                  D ( SM_EXP_TYPE, NODE, GET_BASE_TYPE ( D ( SM_EXP_TYPE, PARAM ) ) );
                  D ( SM_NORMALIZED_PARAM_S, NODE, MAKE_EXP_S (
                     	LIST	=> LIST ( GENERAL_ASSOC_S ),
                     	LX_SRCPOS	=> D ( LX_SRCPOS, GENERAL_ASSOC_S)
                     	)
                     );
               END;
         
            WHEN DN_NUMERIC_LITERAL =>
               DECLARE
                  VALUE	: TREE	:= UARITH.U_VALUE( PRINT_NAME( D( LX_NUMREP, NODE ) ) );
               BEGIN
                  IF (VALUE.PT = HI AND THEN VALUE.NOTY = DN_NUM_VAL)
                     OR (VALUE.PT = P AND THEN VALUE.TY = DN_NUM_VAL)
                  THEN
                     D( SM_EXP_TYPE, NODE, MAKE(  DN_UNIVERSAL_INTEGER ) );
                  ELSE
                     D( SM_EXP_TYPE, NODE, MAKE(  DN_UNIVERSAL_REAL ) );
                  END IF;
                  D( SM_VALUE, NODE, VALUE );
               END;
         
            WHEN DN_RANGE =>
               DECLARE
                  EXP1	: CONSTANT TREE := D( AS_EXP1, NODE );
                  EXP2	: CONSTANT TREE := D( AS_EXP2, NODE );
               BEGIN
                  WALK( EXP1, NODE, REGION );
                  WALK( EXP2, NODE, REGION );
                  D( SM_TYPE_SPEC, NODE, GET_BASE_TYPE( D( SM_EXP_TYPE, EXP1 ) ) );
               END;
         
            WHEN DN_DISCRETE_SUBTYPE =>
               DECLARE
                  SUBTYPE_INDICATION	: CONSTANT TREE := D( AS_SUBTYPE_INDICATION, NODE );
               BEGIN
                  WALK( SUBTYPE_INDICATION, NODE, REGION );
               END;
         
            WHEN DN_FLOAT_CONSTRAINT =>
               DECLARE
                  EXP	: CONSTANT TREE := D( AS_EXP, NODE );
                  RANGE_NODE	: CONSTANT TREE := D( AS_RANGE, NODE );
               BEGIN
                  WALK( EXP, NODE, REGION );
                  WALK( RANGE_NODE, NODE, REGION );
               END;
         
            WHEN DN_FIXED_CONSTRAINT =>
               DECLARE
                  EXP	: CONSTANT TREE := D( AS_EXP, NODE );
                  RANGE_NODE	: CONSTANT TREE := D( AS_RANGE, NODE );
               BEGIN
                  WALK( EXP, NODE, REGION );
                  WALK( RANGE_NODE, NODE, REGION );
               END;
         
            WHEN DN_PACKAGE_SPEC =>
               DECLARE
                  DECL_S1 : CONSTANT TREE := D ( AS_DECL_S1, NODE );
                  DECL_S2 : CONSTANT TREE := D ( AS_DECL_S2, NODE );
               BEGIN
                  WALK ( DECL_S1, NODE, REGION );
                  WALK ( DECL_S2, NODE, REGION );
                  LIST ( D ( AS_DECL_S2, NODE), (TREE_NIL,TREE_NIL) );		--| PAS DE PARTIE PRIVEE (REP SPECS SEULEMENT)
               END;
         
            WHEN DN_COMPILATION =>
               DECLARE
                  COMPLTN_UNIT_S : CONSTANT TREE := D ( AS_COMPLTN_UNIT_S, NODE );
               BEGIN
                  WALK ( COMPLTN_UNIT_S, NODE, REGION );
               END;
         
            WHEN DN_COMPILATION_UNIT =>
               DECLARE
                  CONTEXT_ELEM_S	: CONSTANT TREE := D ( AS_CONTEXT_ELEM_S, NODE );
                  ALL_DECL	: CONSTANT TREE := D ( AS_ALL_DECL, NODE );
                  PRAGMA_S	: CONSTANT TREE := D ( AS_PRAGMA_S, NODE );
               BEGIN
                  WALK ( CONTEXT_ELEM_S, NODE, REGION );
                  WALK ( ALL_DECL, NODE, REGION );
                  WALK ( PRAGMA_S, NODE, REGION );
                  DI ( XD_TIMESTAMP, NODE, 1 );
                  LIST ( NODE, (TREE_NIL,TREE_NIL) );
                  D ( XD_LIB_NAME, NODE, STORE_SYM ( "_STANDRD.DCL" ) );
               END;
         
            WHEN DN_INDEX =>
               DECLARE
                  NAME	: CONSTANT TREE := D ( AS_NAME, NODE );
               BEGIN
                  WALK ( NAME, NODE, REGION );
                  D ( SM_TYPE_SPEC, NODE, D ( SM_TYPE_SPEC, D (SM_DEFN, NAME ) ) );
                  D ( AS_NAME, NODE, MAKE_USED_NAME_ID (
                     	LX_SRCPOS	=> D ( LX_SRCPOS, NAME ),
                     	LX_SYMREP	=> D ( LX_SYMREP, NAME ),
                     	SM_DEFN	=> D ( SM_DEFN, NAME )
                     	)
                     );
               END;
         
            WHEN OTHERS =>
               DECLARE
                  ITEM_LIST	: SEQ_TYPE;
                  ITEM_NODE	: TREE;
               BEGIN
                  CASE ARITY ( NODE ) IS
                     WHEN NULLARY =>
                        NULL;
                     WHEN UNARY =>
                        WALK ( SON_1 ( NODE), NODE, REGION );
                     WHEN BINARY =>
                        WALK ( SON_1 ( NODE), NODE, REGION );
                        WALK ( SON_2 ( NODE), NODE, REGION );
                     WHEN TERNARY =>
                        WALK ( SON_1 ( NODE), NODE, REGION );
                        WALK ( SON_2 ( NODE), NODE, REGION );
                        WALK ( SON_3 ( NODE), NODE, REGION );
                     WHEN ARBITRARY =>
                        ITEM_LIST := LIST ( NODE);
                        WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP
                           POP ( ITEM_LIST, ITEM_NODE );
                           WALK (  ITEM_NODE, NODE, REGION );
                        END LOOP;
                  END CASE;
               END;
         
         END CASE;
      END WALK;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE MAKE_PREDEF_IDS
       PROCEDURE MAKE_PREDEF_IDS ( ID_LIST :OUT SEQ_TYPE ) IS
         USE PRENAME;
      
         NEW_ID_LIST	: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
         NEW_ID		: TREE;
         NEW_ARG_LIST	: SEQ_TYPE;
         NEW_ARG		: TREE;
         ITEM_LENGTH	: NATURAL;
         USE MAKE_NOD;
      BEGIN
         FOR PRAGMA_NAME IN DEFINED_PRAGMAS LOOP
            NEW_ARG_LIST := (TREE_NIL, TREE_NIL);
            IF PRAGMA_NAME = LIST OR PRAGMA_NAME = PRENAME.DEBUG THEN
               FOR ARG_NAME IN LIST_ARGUMENTS LOOP
                  NEW_ARG := MAKE_ARGUMENT_ID (
                     	LX_SYMREP	=> STORE_SYM ( LIST_ARGUMENTS'IMAGE ( ARG_NAME ) ),
                     	XD_POS	=> LIST_ARGUMENTS'POS ( ARG_NAME )
                     	);
                  NEW_ARG_LIST := APPEND ( NEW_ARG_LIST, NEW_ARG );
               END LOOP;
            ELSIF PRAGMA_NAME = OPTIMIZE THEN
               FOR ARG_NAME IN OPTIMIZE_ARGUMENTS LOOP
                  NEW_ARG := MAKE_ARGUMENT_ID (
                     	LX_SYMREP	=> STORE_SYM ( OPTIMIZE_ARGUMENTS'IMAGE ( ARG_NAME ) ),
                     	XD_POS	=> OPTIMIZE_ARGUMENTS'POS ( ARG_NAME )
                     	);
                  NEW_ARG_LIST := APPEND ( NEW_ARG_LIST, NEW_ARG );
               END LOOP;
            ELSIF PRAGMA_NAME = SUPPRESS THEN
               FOR ARG_NAME IN SUPPRESS_ARGUMENTS LOOP
                  NEW_ARG := MAKE_ARGUMENT_ID (
                     	LX_SYMREP	=> STORE_SYM ( SUPPRESS_ARGUMENTS'IMAGE ( ARG_NAME ) ),
                     	XD_POS	=> SUPPRESS_ARGUMENTS'POS ( ARG_NAME )
                     	);
                  NEW_ARG_LIST := APPEND ( NEW_ARG_LIST, NEW_ARG );
               END LOOP;
            ELSIF PRAGMA_NAME = INTERFACE THEN
               FOR ARG_NAME IN INTERFACE_ARGUMENTS LOOP
                  NEW_ARG := MAKE_ARGUMENT_ID (
                     	LX_SYMREP	=> STORE_SYM ( INTERFACE_ARGUMENTS'IMAGE ( ARG_NAME ) ),
                     	XD_POS	=> INTERFACE_ARGUMENTS'POS ( ARG_NAME )
                     	);
                  NEW_ARG_LIST := APPEND ( NEW_ARG_LIST, NEW_ARG );
               END LOOP;
            END IF;
            DECLARE
               SYM	: TREE	:= STORE_SYM ( DEFINED_PRAGMAS'IMAGE ( PRAGMA_NAME ) );
            BEGIN
               NEW_ID := MAKE_PRAGMA_ID (
                  	LX_SYMREP	=> SYM,
                  	XD_POS	=> DEFINED_PRAGMAS'POS ( PRAGMA_NAME ),
                  	SM_ARGUMENT_ID_S	=> MAKE_ARGUMENT_ID_S ( LIST => NEW_ARG_LIST )
                  	);
               NEW_ID_LIST := APPEND ( NEW_ID_LIST, NEW_ID );
               LIST ( SYM, INSERT ( LIST ( SYM ), NEW_ID ) );
            END;
         END LOOP;
      
         FOR ATTRIBUTE_NAME IN DEFINED_ATTRIBUTES LOOP
            DECLARE
               ITEM_NAME	: CONSTANT STRING	:= DEFINED_ATTRIBUTES'IMAGE ( ATTRIBUTE_NAME );
               SYM		: TREE;
            BEGIN
               ITEM_LENGTH := ITEM_NAME'LENGTH;
               IF ITEM_NAME( ITEM_LENGTH - 1 ..ITEM_LENGTH ) = "_X" THEN
                  ITEM_LENGTH := ITEM_LENGTH - 2;
               END IF;
               SYM := STORE_SYM (ITEM_NAME( 1..ITEM_LENGTH ) );
               NEW_ID := MAKE_ATTRIBUTE_ID (
                  		LX_SYMREP	=> SYM,
                  		XD_POS	=> DEFINED_ATTRIBUTES'POS ( ATTRIBUTE_NAME )
                  		);
               NEW_ID_LIST := APPEND ( NEW_ID_LIST, NEW_ID );				--| PREFIXER À LA LISTE DES IDS
               LIST ( SYM, INSERT ( LIST ( SYM ), NEW_ID ) );				--| CHANGER LA XD_DEFLIST PAR UNE AUGMENTEE EN FIN DE L'ID CREÉ
            END;
         END LOOP;
      
         FOR OP_NAME IN OP_CLASS LOOP
            DECLARE
               ITEM_NAME	: CONSTANT STRING	:= BLTN_TEXT_ARRAY ( OP_NAME );
               SYM		: TREE;
            BEGIN
               ITEM_LENGTH := 3;
               WHILE ITEM_NAME( ITEM_LENGTH ) = '!' LOOP
                  ITEM_LENGTH := ITEM_LENGTH - 1;
               END LOOP;
               SYM := STORE_SYM ( '"' & ITEM_NAME( 1..ITEM_LENGTH ) & '"' );
               NEW_ID := MAKE_BLTN_OPERATOR_ID (
                     	LX_SYMREP	=> SYM,
                     	SM_OPERATOR	=> OP_CLASS'POS ( OP_NAME )
                     	);
               NEW_ID_LIST := APPEND ( NEW_ID_LIST, NEW_ID );				--| PREFIXER À LA LISTE DES IDS
               LIST ( SYM, INSERT ( LIST ( SYM ), NEW_ID ) );				--| CHANGER LA XD_DEFLIST PAR UNE AUGMENTEE EN FIN DE L'ID CREÉ
            END;
         END LOOP;
      
         ID_LIST := NEW_ID_LIST;							--| RENDRE LA LISTE DES IDS
         
      END MAKE_PREDEF_IDS;
   
   
BEGIN
  DECLARE
    USER_ROOT		: TREE;
    PREDEF_ID_LIST		: SEQ_TYPE;
  BEGIN
    USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
    MAKE_PREDEF_IDS( PREDEF_ID_LIST );							--| NOEUDS STANDARD POUR LES NOMS PREDEFINIS
      
    WALK( D( XD_STRUCTURE, USER_ROOT ), PARENT => TREE_VOID, REGION => TREE_VOID );		--| PARCOURIR L'ARBRE SYNTAXIQUE DU _STANDRD
      
    DECLARE
      INTEGER_ID		: TREE	:= HEAD_DEFN( STORE_SYM( "INTEGER" ) );
      NATURAL_ID		: TREE	:= HEAD_DEFN( STORE_SYM( "NATURAL" ) );
      POSITIVE_ID		: TREE	:= HEAD_DEFN( STORE_SYM( "POSITIVE" ) );
      INTGR_SIZE		: INTEGER	:= DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC, INTEGER_ID ) );
      DURATION_ID		: TREE	:= HEAD_DEFN( STORE_SYM( "DURATION" ) );
      DURATION_BASE_ID	: TREE	:= HEAD_DEFN( STORE_SYM( "_DURATION" ) );
      DURATION_SPEC		: TREE	:= D( SM_TYPE_SPEC, DURATION_ID );
      DURATION_BASE_SPEC	: TREE	:= D( SM_TYPE_SPEC, DURATION_BASE_ID );
    BEGIN
      DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC,NATURAL_ID ), INTGR_SIZE );
      DI( CD_IMPL_SIZE, D( SM_TYPE_SPEC,POSITIVE_ID ), INTGR_SIZE);
      DI( CD_IMPL_SIZE, DURATION_BASE_SPEC, DI( CD_IMPL_SIZE, DURATION_SPEC ) );
      D ( SM_BASE_TYPE, DURATION_SPEC, DURATION_BASE_SPEC );
      DB( SM_IS_ANONYMOUS, DURATION_BASE_SPEC, TRUE );
      D ( XD_SOURCE_NAME, DURATION_BASE_SPEC, DURATION_ID );
      D ( SM_TYPE_SPEC, D( SM_RANGE, DURATION_SPEC ), DURATION_BASE_SPEC );			--| SOUS TYPE CONTRAINTE D'ETENDUE POUR DURATION
    END;
      
    DECLARE
      ADDRESS_ID	: TREE	:= HEAD_DEFN( STORE_SYM( "_ADDRESS" ) );
      BASE_SPEC	: TREE	:= D( SM_TYPE_SPEC, D( SM_TYPE_SPEC, ADDRESS_ID ) );		--| ID DE TYPE ANCÊTRE DANS SM_TYPE_SPEC
      NEW_SPEC	: TREE	:= COPY_NODE( BASE_SPEC );
    BEGIN
      D( XD_SOURCE_NAME, NEW_SPEC, ADDRESS_ID );
      D( SM_DERIVED, NEW_SPEC, BASE_SPEC );
      D( SM_BASE_TYPE, NEW_SPEC, NEW_SPEC );
      D( SM_TYPE_SPEC, ADDRESS_ID, NEW_SPEC );
    END;
      
    DECLARE
      PACK_SYM	: TREE	:= HEAD_DEFN( STORE_SYM( "_STANDRD" ) );			--| CHERCHER LE SYMBOLE NOM DU PACKAGE _STANDRD EN VERIFIANT QU'IL A UNE DEFLIST
      HEADER		: TREE := D( SM_SPEC, PACK_SYM );
    BEGIN
      LIST( D( AS_DECL_S2, HEADER ), PREDEF_ID_LIST );					--| IDENTIFICATEURS EN PARTIE PRIVEE
    END;
         
  END;
--|-------------------------------------------------------------------------------------------------
END FIX_PRE;
