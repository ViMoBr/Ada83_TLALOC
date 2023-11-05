SEPARATE( IDL )
--|-------------------------------------------------------------------------------------------------
    --|	PROCEDURE SEM_PHASE
    PROCEDURE SEM_PHASE IS
   
     --|--------------------------------------------------------------------------------------------
     --|	SEM_GLOB
     --|--------------------------------------------------------------------------------------------
       PACKAGE SEM_GLOB IS
      
         TYPE SB_TYPE	IS RECORD			--| SAUVÉ ET RESTAURÉ AUTOUR DES CORPS
                NULL;
            END RECORD;
      
         TYPE SU_TYPE	IS RECORD			--| SAUVÉ ET RESTAURÉ AUTOUR DES RÉGIONS
               USED_PACKAGE_LIST	: SEQ_TYPE;
               INCOMPLETE_TYPE_LIST	: SEQ_TYPE;
               PRIVATE_TYPE_LIST	: SEQ_TYPE;
            END RECORD;
      
         TYPE H_TYPE	IS RECORD			--| INFORMATION HÉRÉDITAIRE
               REGION_DEF	: TREE;
               LEX_LEVEL	: NATURAL;
               IS_IN_SPEC	: BOOLEAN;
               IS_IN_BODY	: BOOLEAN;
               SUBP_SYMREP	: TREE;
               RETURN_TYPE	: TREE;
               ENCLOSING_LOOP_ID	: TREE;
            END RECORD;
      
        -- GLOBAL DATA
         SB		: SB_TYPE;
         SU		: SU_TYPE;
         INITIAL_H		: H_TYPE;
      
         PREDEFINED_BOOLEAN	: TREE;
         PREDEFINED_SHORT_INTEGER	: TREE;
         PREDEFINED_INTEGER	: TREE;
         PREDEFINED_LONG_INTEGER	: TREE;
         PREDEFINED_LARGEST_INTEGER	: TREE;
         PREDEFINED_FLOAT	: TREE;
         PREDEFINED_LONG_FLOAT	: TREE;
         PREDEFINED_LARGEST_FLOAT	: TREE;
         PREDEFINED_STRING	: TREE;
         PREDEFINED_DURATION	: TREE;
         PREDEFINED_ADDRESS	: TREE;
      
         PREDEFINED_STANDARD_DEF	: TREE;
         PREDEFINED_STANDARD_ID	: TREE;
      
         PREDEFINED_SHORT_INTEGER_FIRST	: TREE;
         PREDEFINED_SHORT_INTEGER_LAST	: TREE;
         PREDEFINED_INTEGER_FIRST	: TREE;
         PREDEFINED_INTEGER_LAST	: TREE;
         PREDEFINED_LONG_INTEGER_FIRST	: TREE;
         PREDEFINED_LONG_INTEGER_LAST	: TREE;
         PREDEFINED_FLOAT_FIRST	: TREE;
         PREDEFINED_FLOAT_LAST	: TREE;
         PREDEFINED_FLOAT_ACCURACY	: TREE;
         PREDEFINED_LONG_FLOAT_FIRST	: TREE;
         PREDEFINED_LONG_FLOAT_LAST	: TREE;
         PREDEFINED_LONG_FLOAT_ACCURACY	: TREE;
      
      
          PROCEDURE INITIALIZE_GLOBAL_DATA;
          PROCEDURE INITIALIZE_PREDEFINED_TYPES;
       
      --|-------------------------------------------------------------------------------------------
      END SEM_GLOB;
      USE SEM_GLOB;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	UNIV_OPS
      --|-------------------------------------------------------------------------------------------
       PACKAGE UNIV_OPS IS
      
         URADIX	: CONSTANT := 10_000;
      
         TYPE UDIGIT	IS RANGE -32_768 .. 32_767;		FOR UDIGIT'SIZE USE 16;
         
         TYPE VECTOR_DIGITS	IS ARRAY( 1..252 ) OF UDIGIT;		PRAGMA PACK( VECTOR_DIGITS );
      
         TYPE VECTOR	IS RECORD
			  L	: NATURAL;					--| NOMBRE DE "CHIFFRES" 10_000 AIRES
			  S	: UDIGIT;						--| SIGNE +1 OR -1
			  D	: VECTOR_DIGITS;					--| CHIFFRES EN BASE 10_000
			END RECORD;			PRAGMA PACK( VECTOR );
      
          FUNCTION  U_INT	( V :VECTOR )		RETURN TREE;			--| FABRIQUE UN ENTIER UNIVERSEL À PARTIR D'UN VECTEUR
          FUNCTION  U_REAL	( NUMER, DENOM :VECTOR )	RETURN TREE;			--| UNIVERSAL REAL À PARTIR DE VECTEURS DÉJÀ RÉDUITS AUX TERMES LES PLUS BAS
          FUNCTION  U_REAL	( NUMER, DENOM :TREE )	RETURN TREE;			--| UNIVERSAL REAL AVEC DEUX ENTIERS UNIVERSELS (NON NÉCESSAIREMENT RÉDUITS)
          PROCEDURE SPREAD	( T :TREE; V :IN OUT VECTOR );
          PROCEDURE SPREAD	( I :INTEGER; V :IN OUT VECTOR );
          PROCEDURE NORMALIZE	( V :IN OUT VECTOR );
      
      --| LES SIGNES SONT IGNORÉS : OPÉRATIONS SUR VALEURS ABSOLUES
        
          PROCEDURE V_ADD	( A :VECTOR; R :IN OUT VECTOR );				-- |R| + |A| --> |R|
          PROCEDURE V_SUB	( A :VECTOR; R :IN OUT VECTOR );				-- |R| - |A| --> |R| ; ASSUME |A| < |R|
          PROCEDURE V_MUL	( A,B :VECTOR; R :IN OUT VECTOR );				-- |A| * |B| --> R
          PROCEDURE V_SCALE	( A :INTEGER; R :IN OUT VECTOR );				-- A * R --> R ; ASSUME A > 0
          PROCEDURE V_DIV	( A :VECTOR; R, Q :IN OUT VECTOR );				-- |R| / |A| --> Q REMAINDER |R| ASSUME A /= 0
          PROCEDURE V_REM	( A :VECTOR; R :IN OUT VECTOR );				-- |R| / |A| --> ... REMAINDER |R| ; ASSUME A /= 0
          PROCEDURE V_GCD	( A,B :VECTOR; R :IN OUT VECTOR );				-- GCD(|A|,|B|) --> R
          PROCEDURE V_LOWEST_TERMS	( A,B : IN OUT VECTOR );				-- REDUCE |A|/|B| TO LOWEST TERMS, ASSUME B /= 0
          FUNCTION  V_EQUAL	( A,B : VECTOR )		RETURN BOOLEAN;			-- TEST |A| = |B|, |A| < |B|
          FUNCTION  V_LESS	( A,B : VECTOR )		RETURN BOOLEAN;
      
      --|-------------------------------------------------------------------------------------------
      END UNIV_OPS;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	UARITH
      --|-------------------------------------------------------------------------------------------
       PACKAGE UARITH IS
      
          FUNCTION  U_VAL	( A :INTEGER )		RETURN TREE;
          FUNCTION  U_VALUE	( TXT :STRING )		RETURN TREE;
          FUNCTION  U_POS	( A : TREE )		RETURN INTEGER;
      
          FUNCTION  U_EQUAL	( LEFT, RIGHT: TREE )	RETURN TREE;
          FUNCTION  U_NOT_EQUAL	( LEFT, RIGHT: TREE )	RETURN TREE;
          FUNCTION  "<"	( LEFT, RIGHT: TREE )	RETURN TREE;
          FUNCTION  "<="	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION  ">"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION  ">="	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION  U_MEMBER	( VALUE, DISCRETE_RANGE :TREE )	RETURN TREE;
      
        -- FOLLOWING RETURN BOOLEAN (FOR COMPILER RANGE TESTS)
          FUNCTION  "<="	( LEFT, RIGHT :TREE )	RETURN BOOLEAN;
          FUNCTION  ">="	( LEFT, RIGHT :TREE )	RETURN BOOLEAN;
          FUNCTION  U_EQUAL	( LEFT, RIGHT :TREE )	RETURN BOOLEAN;
          FUNCTION  U_MEMBER	( VALUE, DISCRETE_RANGE :TREE )	RETURN BOOLEAN;
      
        -- FOLLOWING EXPECT 0 OR 1 AS ARGUMENT -- BOOLEAN OPERATORS
          FUNCTION "AND"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "OR"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "XOR"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "NOT"	( RIGHT :TREE )		RETURN TREE;
      
        -- UNARY FUNCTIONS
          FUNCTION "-"	( RIGHT :TREE )		RETURN TREE;
          FUNCTION "ABS"	( RIGHT :TREE )		RETURN TREE;
      
        -- BINARY FUNCTIONS
          FUNCTION "+"	( LEFT, RIGHT :TREE ) 	RETURN TREE;
          FUNCTION "-"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "*"	( LEFT, RIGHT :TREE )	RETURN TREE; -- I*I, I*R, R*I, R*R
          FUNCTION "/"	( LEFT, RIGHT :TREE )	RETURN TREE; -- I/I, R/I, R/R
          FUNCTION "MOD"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "REM"	( LEFT, RIGHT :TREE )	RETURN TREE;
          FUNCTION "**"	( LEFT, RIGHT :TREE )	RETURN TREE; -- I**I, R**I
      
      --|-------------------------------------------------------------------------------------------
      END UARITH;
      
      
      
      
      
      --|-------------------------------------------------------------------------------------------
      --|	FIX_WITH
      --|-------------------------------------------------------------------------------------------
       PACKAGE FIX_WITH IS
      
         USED_PACKAGE_LIST	: SEQ_TYPE;
      
          PROCEDURE FIX_WITH_CLAUSES	( COMPLTN_UNIT :TREE );
          FUNCTION  IS_ANCESTOR	( UNIT_ID, SUBUNIT :TREE )	RETURN BOOLEAN;
      
      --|-------------------------------------------------------------------------------------------
      END FIX_WITH;
      
      
      
      
      
   --|----------------------------------------------------------------------------------------------
   --|	DEF_UTIL
   --|----------------------------------------------------------------------------------------------
       PACKAGE DEF_UTIL IS
      
          FUNCTION  MAKE_DEF_FOR_ID		( ID :TREE; H :H_TYPE )		RETURN TREE;
          PROCEDURE CHECK_UNIQUE_SOURCE_NAME_S	( SOURCE_NAME_S :TREE );
          PROCEDURE CHECK_CONSTANT_ID_S		( SOURCE_NAME_S :TREE; H :H_TYPE );
          FUNCTION  GET_DEF_FOR_ID		( ID :TREE)			RETURN TREE;
          FUNCTION  GET_PRIOR_DEF		( DEF :TREE)			RETURN TREE;
          FUNCTION  GET_PRIOR_HOMOGRAPH_DEF	( DEF :TREE)			RETURN TREE;
          FUNCTION  GET_PRIOR_HOMOGRAPH_DEF	( DEF, PARAM_S :TREE; RESULT_TYPE :TREE := TREE_VOID )	RETURN TREE;
          FUNCTION  GET_DEF_IN_REGION		( ID :TREE; H :H_TYPE )		RETURN TREE;
          PROCEDURE CHECK_UNIQUE_DEF		( SOURCE_DEF : TREE);
          PROCEDURE CHECK_CONSTANT_DEF		( SOURCE_DEF :TREE; H :H_TYPE );
          PROCEDURE CHECK_TYPE_DEF		( SOURCE_DEF :TREE; H :H_TYPE );
          FUNCTION  ARE_HOMOGRAPH_HEADERS	( HEADER_1, HEADER_2 :TREE )		RETURN BOOLEAN;
          FUNCTION  IS_SAME_PARAMETER_PROFILE	( PARAM_S_1, PARAM_S_2 :TREE )		RETURN BOOLEAN;
          PROCEDURE CONFORM_PARAMETER_LISTS	( PARAM_S_1, PARAM_S_2 :TREE );
          FUNCTION  IS_COMPATIBLE_EXPRESSION	( EXP_1, EXP_2 :TREE )		RETURN BOOLEAN;
          PROCEDURE MAKE_DEF_VISIBLE		( DEF :TREE; HEADER :TREE := TREE_VOID );
          PROCEDURE MAKE_DEF_IN_ERROR		( DEF :TREE );
          PROCEDURE REMOVE_DEF_FROM_ENVIRONMENT	( DEF :TREE );
      
          FUNCTION  GET_DEF_EXP_TYPE		( DEF :TREE )			RETURN TREE;
          FUNCTION  GET_BASE_TYPE		( TYPE_SPEC_OR_EXP_OR_ID :TREE )		RETURN TREE;
          FUNCTION  GET_BASE_PACKAGE		( PACKAGE_ID :TREE )		RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END DEF_UTIL;
      
      
      
      
      
      --|-------------------------------------------------------------------------------------------
      --|	SET_UTIL
      --|-------------------------------------------------------------------------------------------
       PACKAGE SET_UTIL IS
      
         TYPE DEFSET_TYPE	IS PRIVATE;
         TYPE TYPESET_TYPE	IS PRIVATE;
         TYPE DEFINTERP_TYPE	IS PRIVATE;
         TYPE TYPEINTERP_TYPE	IS PRIVATE;
         TYPE EXTRAINFO_TYPE	IS PRIVATE;
      
         EMPTY_DEFSET	: CONSTANT DEFSET_TYPE;
         EMPTY_TYPESET	: CONSTANT TYPESET_TYPE;
         NULL_EXTRAINFO	: CONSTANT EXTRAINFO_TYPE;
      
          FUNCTION  GET_DEF	( DEFINTERP :DEFINTERP_TYPE )		RETURN TREE;
          FUNCTION  IS_NULLARY	( DEFINTERP :DEFINTERP_TYPE )		RETURN BOOLEAN;
          FUNCTION  GET_EXTRAINFO	( DEFINTERP :DEFINTERP_TYPE )		RETURN EXTRAINFO_TYPE;
          FUNCTION  IS_EMPTY	( DEFSET :DEFSET_TYPE )		RETURN BOOLEAN;
          FUNCTION  HEAD	( DEFSET :DEFSET_TYPE )		RETURN DEFINTERP_TYPE;
          PROCEDURE POP	( DEFSET :IN OUT DEFSET_TYPE; DEFINTERP :OUT DEFINTERP_TYPE );
      
          FUNCTION  GET_TYPE	( TYPEINTERP :TYPEINTERP_TYPE ) 		RETURN TREE;
          FUNCTION  GET_EXTRAINFO	( TYPEINTERP :TYPEINTERP_TYPE )		RETURN EXTRAINFO_TYPE;
          FUNCTION  IS_EMPTY	( TYPESET :TYPESET_TYPE )		RETURN BOOLEAN;
          FUNCTION  HEAD	( TYPESET :TYPESET_TYPE )		RETURN TYPEINTERP_TYPE;
          PROCEDURE POP	( TYPESET :IN OUT TYPESET_TYPE; TYPEINTERP :OUT TYPEINTERP_TYPE);
      
          PROCEDURE ADD_TO_DEFSET	( DEFSET :IN OUT DEFSET_TYPE; DEFINTERP :DEFINTERP_TYPE );
          PROCEDURE ADD_TO_DEFSET	( DEFSET :IN OUT DEFSET_TYPE; DEF :TREE; EXTRAINFO :EXTRAINFO_TYPE := NULL_EXTRAINFO; IS_NULLARY :BOOLEAN := FALSE );
          PROCEDURE ADD_TO_TYPESET	( TYPESET :IN OUT TYPESET_TYPE; TYPEINTERP :TYPEINTERP_TYPE );
          PROCEDURE ADD_TO_TYPESET	( TYPESET :IN OUT TYPESET_TYPE; TYPE_SPEC :TREE; EXTRAINFO :EXTRAINFO_TYPE := NULL_EXTRAINFO );
      
          PROCEDURE REQUIRE_UNIQUE_DEF	( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          PROCEDURE REQUIRE_UNIQUE_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
      
          FUNCTION  GET_THE_ID	( DEFSET :DEFSET_TYPE )		RETURN TREE;
          FUNCTION  THE_ID_IS_NULLARY	( DEFSET :DEFSET_TYPE )		RETURN BOOLEAN;
          FUNCTION  GET_THE_TYPE	( TYPESET :TYPESET_TYPE )		RETURN TREE;
      
          PROCEDURE REDUCE_OPERATOR_DEFS( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
      
          PROCEDURE ADD_EXTRAINFO	( DEFINTERP :IN OUT DEFINTERP_TYPE; EXTRAINFO :EXTRAINFO_TYPE );
          PROCEDURE ADD_EXTRAINFO	( DEFINTERP :IN OUT DEFINTERP_TYPE; EXTRAINFO_OF :TYPEINTERP_TYPE );
          PROCEDURE ADD_EXTRAINFO	( TYPEINTERP :IN OUT TYPEINTERP_TYPE; EXTRAINFO :EXTRAINFO_TYPE );
          PROCEDURE ADD_EXTRAINFO	( TYPEINTERP :IN OUT TYPEINTERP_TYPE; EXTRAINFO_OF :TYPEINTERP_TYPE );
          PROCEDURE ADD_EXTRAINFO	( EXTRAINFO :IN OUT EXTRAINFO_TYPE; EXTRAINFO_IN :EXTRAINFO_TYPE );
      
          FUNCTION  INSERT	( DEFSET :DEFSET_TYPE; DEFINTERP :DEFINTERP_TYPE )	RETURN DEFSET_TYPE;
          FUNCTION  INSERT	( TYPESET :TYPESET_TYPE; TYPEINTERP :TYPEINTERP_TYPE )	RETURN TYPESET_TYPE;
      
          PROCEDURE STASH_DEFSET	( EXP :TREE; DEFSET :DEFSET_TYPE );
          FUNCTION  FETCH_DEFSET	( EXP :TREE )			RETURN DEFSET_TYPE;
          PROCEDURE STASH_TYPESET	( EXP :TREE; TYPESET :TYPESET_TYPE );
          FUNCTION  FETCH_TYPESET	( EXP :TREE )			RETURN TYPESET_TYPE;
       
       
       
       
       
      PRIVATE
      
         TYPE DEFSET_TYPE	IS NEW SEQ_TYPE;
         TYPE TYPESET_TYPE	IS NEW SEQ_TYPE;
         TYPE DEFINTERP_TYPE	IS NEW TREE;
         TYPE TYPEINTERP_TYPE	IS NEW TREE;
         TYPE EXTRAINFO_TYPE	IS NEW SEQ_TYPE;
      
         EMPTY_DEFSET	: CONSTANT DEFSET_TYPE	:= (TREE_NIL,TREE_NIL);
         EMPTY_TYPESET	: CONSTANT TYPESET_TYPE	:= (TREE_NIL,TREE_NIL);
         NULL_EXTRAINFO	: CONSTANT EXTRAINFO_TYPE	:= (TREE_NIL,TREE_NIL);
      
      --|----------------------------------------------------------------------------------------------
      END SET_UTIL;
      
      
      
      
      
      --|-------------------------------------------------------------------------------------------
      --|	REQ_UTIL
      --|-------------------------------------------------------------------------------------------
       PACKAGE REQ_UTIL IS
       
         --|----------------------------------------------------------------------------------------
         --|	REQ_GENE
         --|----------------------------------------------------------------------------------------
          PACKAGE REQ_GENE IS
            USE SET_UTIL;
         
             GENERIC
                WITH FUNCTION IS_XXX (ITEM: TREE) RETURN BOOLEAN;
                MESSAGE :IN STRING;
             PROCEDURE REQ_DEF_XXX	( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
         
             GENERIC
                WITH FUNCTION IS_XXX (ITEM: TREE) RETURN BOOLEAN;
                MESSAGE: IN STRING;
             PROCEDURE REQ_TYPE_XXX	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
         
         --|----------------------------------------------------------------------------------------
         END REQ_GENE;
         
         USE SET_UTIL, REQ_GENE;
      
          FUNCTION  GET_BASE_STRUCT		( TYPE_SPEC :TREE )			RETURN TREE;
          FUNCTION  GET_ANCESTOR_TYPE		( TYPE_SPEC :TREE )			RETURN TREE;
          PROCEDURE REQUIRE_SAME_TYPES		( EXP_1 :TREE; TYPESET_1 :TYPESET_TYPE; EXP_2 :TREE; TYPESET_2 :TYPESET_TYPE; TYPESET_OUT :OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_TYPE		( TYPE_SPEC :TREE; EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          FUNCTION  IS_NONLIMITED_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_LIMITED_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_PRIVATE_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_INTEGER_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_BOOLEAN_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_REAL_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_SCALAR_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_MEMBER_OF_UNSPECIFIED	( SPEC_TYPE :TREE; UNSPEC_TYPE :TREE )		RETURN BOOLEAN;
          FUNCTION  IS_NONLIMITED_COMPOSITE_TYPE	( TYPE_SPEC :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_STRING_TYPE		( TYPE_SPEC :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_CHARACTER_TYPE		( TYPE_SPEC :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_UNIVERSAL_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_NON_UNIVERSAL_TYPE	( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_DISCRETE_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_TASK_TYPE		( ITEM :TREE )			RETURN BOOLEAN;
          PROCEDURE REQUIRE_ID		( ID_KIND :NODE_NAME; EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          FUNCTION  IS_TYPE_DEF		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_ENTRY_DEF		( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_PROC_OR_ENTRY_DEF	( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_FUNCTION_OR_ARRAY_DEF	( ITEM :TREE )			RETURN BOOLEAN;
          FUNCTION  IS_FUNCTION_OR_ENUMERATION_DEF	( ITEM :TREE )			RETURN BOOLEAN;
      
          PROCEDURE REQUIRE_NONLIMITED_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_INTEGER_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_BOOLEAN_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_REAL_TYPE		( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_SCALAR_TYPE		( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_UNIVERSAL_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_NON_UNIVERSAL_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_DISCRETE_TYPE	( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_TASK_TYPE		( EXP :TREE; TYPESET :IN OUT TYPESET_TYPE );
          PROCEDURE REQUIRE_TYPE_DEF		( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          PROCEDURE REQUIRE_ENTRY_DEF		( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          PROCEDURE REQUIRE_PROC_OR_ENTRY_DEF	( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          PROCEDURE REQUIRE_FUNCTION_OR_ARRAY_DEF	( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
          PROCEDURE REQUIRE_FUNCTION_OR_ENUMERATION_DEF	( EXP :TREE; DEFSET :IN OUT DEFSET_TYPE );
      
      --|-------------------------------------------------------------------------------------------
      END REQ_UTIL;
      USE REQ_UTIL, REQ_UTIL.REQ_GENE;
      
      
      
      
      
  --|-----------------------------------------------------------------------------------------------
  --|	AGGRESO
  --|-----------------------------------------------------------------------------------------------
  PACKAGE AGGRESO IS
    USE SET_UTIL, DEF_UTIL, REQ_UTIL;
      
    TYPE AGGREGATE_ITEM_TYPE	IS PRIVATE;
      
    TYPE AGGREGATE_ARRAY_TYPE	IS ARRAY (POSITIVE RANGE <>) OF AGGREGATE_ITEM_TYPE;
      
    FUNCTION  COUNT_AGGREGATE_CHOICES	( ASSOC_S :TREE )				RETURN NATURAL;
    PROCEDURE SPREAD_ASSOC_S	( ASSOC_S : TREE; AGGREGATE_ARRAY :IN OUT AGGREGATE_ARRAY_TYPE );
    PROCEDURE WALK_RECORD_DECL_S	( EXP :TREE; DECL_S :TREE; AGGREGATE_ARRAY :IN OUT AGGREGATE_ARRAY_TYPE;
          		  NORMALIZED_LIST :IN OUT SEQ_TYPE; LAST_POSITIONAL :IN OUT NATURAL );
    PROCEDURE RESOLVE_RECORD_ASSOC_S	( ASSOC_S :TREE; AGGREGATE_ARRAY :IN OUT AGGREGATE_ARRAY_TYPE );
    FUNCTION  RESOLVE_EXP_OR_AGGREGATE	( EXP :TREE; SUBTYPE_SPEC :TREE; NAMED_OTHERS_OK :BOOLEAN )		RETURN TREE;
    PROCEDURE RESOLVE_AGGREGATE	( EXP :TREE; TYPE_SPEC :TREE );
    PROCEDURE RESOLVE_STRING	( EXP :TREE; TYPE_SPEC :TREE );
      
  --|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  PRIVATE
      
         TYPE AGGREGATE_ITEM_TYPE	IS RECORD
               FIRST	: POSITIVE;			--| POSITION OF FIRST CHOICE IN CHOICE_S
               CHOICE	: TREE;			--| FROM CHOICE_EXP
               ID		: TREE;			--| DSCRMT OR COMPONENT ID
               ASSOC	: TREE;			--| ONLY FOR FIRST CHOICE
               EXP		: TREE;			--| ONLY FOR FIRST CHOICE
               TYPESET	: TYPESET_TYPE;			--| ONLY FOR FIRST CHOICE
               SEEN		: BOOLEAN;			--| USED TO MARK WHEN FORMAL SEEN FOR CHOICE
               RESOLVED	: BOOLEAN;			--| USED TO MARK WHEN EXP RESOLVED FOR ASSOC
            END RECORD;
      
  --|-----------------------------------------------------------------------------------------------
  END AGGRESO;
      
      
      
      
      
      --|-------------------------------------------------------------------------------------------
      --|	EXPRESO
      --|-------------------------------------------------------------------------------------------
       PACKAGE EXPRESO IS
         USE SET_UTIL;
      
          FUNCTION  GET_NAME_DEFN		( NAME :TREE )		RETURN TREE;
          FUNCTION  GET_STATIC_VALUE		( EXP :TREE )		RETURN TREE;
          FUNCTION  RESOLVE_EXP		( EXP :TREE; TYPE_SPEC :TREE )	RETURN TREE;
          FUNCTION  RESOLVE_DISCRETE_RANGE	( EXP :TREE; TYPE_SPEC :TREE )	RETURN TREE;
          FUNCTION  RESOLVE_TYPE_MARK		( EXP :TREE)		RETURN TREE;
          PROCEDURE RESOLVE_SUBTYPE_INDICATION	( EXP :IN OUT TREE; SUBTYPE_SPEC :OUT TREE );
          FUNCTION  RESOLVE_EXP		( EXP :TREE; TYPESET :TYPESET_TYPE )	RETURN TREE;
          FUNCTION  RESOLVE_NAME		( NAME :TREE; DEFN :TREE )	RETURN TREE;
          FUNCTION  WALK_ERRONEOUS_EXP		( EXP :TREE )		RETURN TREE;
       
      --|-------------------------------------------------------------------------------------------
      END EXPRESO;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	VIS_UTIL
      --|-------------------------------------------------------------------------------------------
       PACKAGE VIS_UTIL IS
         USE SET_UTIL;
      
         TYPE PARAM_CURSOR_TYPE	IS RECORD
               PARAM_LIST	: SEQ_TYPE;
               PARAM	: TREE;
               ID_LIST	: SEQ_TYPE;
               ID		: TREE;
            END RECORD;
      
        --- $$$$ TEMPORARY $$$$$$$$$$$$$$
          FUNCTION IS_OVERLOADABLE_HEADER	( HEADER :TREE )		RETURN BOOLEAN;
        -- $$$$$
      
          PROCEDURE FIND_VISIBILITY		( EXP :TREE; DEFSET :OUT DEFSET_TYPE );
          PROCEDURE FIND_DIRECT_VISIBILITY	( ID :TREE; DEFSET :OUT DEFSET_TYPE );
          PROCEDURE FIND_SELECTED_VISIBILITY	( SELECTED :TREE; DEFSET :OUT DEFSET_TYPE );
      
          FUNCTION  GET_ENCLOSING_DEF		( USED_NAME :TREE; DEFSET :DEFSET_TYPE )RETURN TREE;
          FUNCTION  MAKE_USED_NAME_ID_FROM_OBJECT	( USED_OBJECT_ID :TREE )	RETURN TREE;
          FUNCTION  MAKE_USED_OP_FROM_STRING	( STRING_NODE :TREE )	RETURN TREE;
          FUNCTION  EXPRESSION_TYPE_OF_DEF	( DEF :TREE )		RETURN TREE;
          FUNCTION  ALL_PARAMETERS_HAVE_DEFAULTS	( HEADER :TREE )		RETURN BOOLEAN;
          FUNCTION  CAST_TREE			( ARG :SEQ_TYPE )		RETURN TREE;
          FUNCTION  CAST_SEQ_TYPE		( ARG :TREE )		RETURN SEQ_TYPE;
          FUNCTION  COPY_NODE			( NODE : TREE )		RETURN TREE;
          PROCEDURE INIT_PARAM_CURSOR		( CURSOR :OUT PARAM_CURSOR_TYPE; PARAM_LIST :SEQ_TYPE );
          PROCEDURE ADVANCE_PARAM_CURSOR	( CURSOR :IN OUT PARAM_CURSOR_TYPE );
      
      --|----------------------------------------------------------------------------------------------
      END VIS_UTIL;
      
      
      
      
      
      --|-------------------------------------------------------------------------------------------
      --|	DEF_WALK
      --|-------------------------------------------------------------------------------------------
       PACKAGE DEF_WALK IS
      
          FUNCTION  EVAL_TYPE_DEF		( TYPE_DEF :TREE; ID :TREE; H :H_TYPE; DSCRMT_DECL_S :TREE := TREE_VOID )	RETURN TREE;
          FUNCTION  GET_SUBTYPE_OF_DISCRETE_RANGE	( DISCRETE_RANGE :TREE )			RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END DEF_WALK;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	NOD_WALK
      --|-------------------------------------------------------------------------------------------
       PACKAGE NOD_WALK IS
      
         TYPE S_TYPE	IS RECORD
               SB		: SB_TYPE;
               SU		: SU_TYPE;
            END RECORD;
      
          PROCEDURE WALK		( NODE :TREE; H :H_TYPE );
          PROCEDURE FINISH_PARAM_S		( DECL_S :TREE; H :H_TYPE );
          FUNCTION  WALK_NAME		( ID_KIND :NODE_NAME; NAME :TREE )		RETURN TREE;
          FUNCTION  WALK_TYPE_MARK		( NAME :TREE )			RETURN TREE;
          PROCEDURE WALK_DISCRETE_CHOICE_S	( CHOICE_S :TREE; TYPE_SPEC :TREE );
          PROCEDURE ENTER_REGION		( DEF :TREE; H :IN OUT H_TYPE; S :OUT S_TYPE );
          PROCEDURE LEAVE_REGION		( DEF :TREE; S :S_TYPE );
          PROCEDURE ENTER_BODY		( DEF :TREE; H :IN OUT H_TYPE; S :OUT S_TYPE );
          PROCEDURE LEAVE_BODY		( DEF :TREE; S :S_TYPE );
          PROCEDURE WALK_ITEM_S		( ITEM_S :TREE; H :H_TYPE );
          PROCEDURE WALK_SOURCE_NAME_S		( SOURCE_NAME_S :TREE; H :H_TYPE );
      
      --|----------------------------------------------------------------------------------------------
      END NOD_WALK;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	ATT_WALK
      --|-------------------------------------------------------------------------------------------
       PACKAGE ATT_WALK IS
         USE SET_UTIL;
      
          PROCEDURE EVAL_ATTRIBUTE		( EXP :TREE; TYPESET :OUT TYPESET_TYPE; IS_SUBTYPE :OUT BOOLEAN; IS_FUNCTION : BOOLEAN := FALSE );
          FUNCTION  RESOLVE_ATTRIBUTE		( EXP :TREE )		RETURN TREE;
          FUNCTION  EVAL_ATTRIBUTE_IDENTIFIER	( ATTRIBUTE_NODE :TREE )	RETURN TREE;
      
        --PROCEDURE WALK_ATTRIBUTE_FUNCTION(EXP: TREE);
      
      --|----------------------------------------------------------------------------------------------
      END ATT_WALK;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	STM_WALK
      --|-------------------------------------------------------------------------------------------
       PACKAGE STM_WALK IS
      
          PROCEDURE DECLARE_LABEL_BLOCK_LOOP_IDS	( STM_S :TREE; H :H_TYPE );
          PROCEDURE WALK_STM_S		( STM_S :TREE; H :H_TYPE );
          PROCEDURE WALK_ALTERNATIVE_S		( ALTERNATIVE_S :TREE; H :H_TYPE );
          FUNCTION  WALK_STM		( STM_IN :TREE; H :H_TYPE )	RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END STM_WALK;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	PRA_WALK
      --|-------------------------------------------------------------------------------------------
       PACKAGE PRA_WALK IS
       
          PROCEDURE WALK_PRAGMA	( USED_NAME_ID :TREE; GEN_ASSOC_S :TREE; H :H_TYPE );
          
      --|-------------------------------------------------------------------------------------------
      END PRA_WALK;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	CHK_STAT
      --|-------------------------------------------------------------------------------------------
       PACKAGE CHK_STAT IS
      
          FUNCTION  IS_STATIC_RANGE		( A :TREE )		RETURN BOOLEAN;
          FUNCTION  IS_STATIC_SUBTYPE		( A :TREE )		RETURN BOOLEAN;
          FUNCTION  IS_STATIC_DISCRETE_RANGE	( A :TREE )		RETURN BOOLEAN;
          FUNCTION  IS_STATIC_INDEX_CONSTRAINT	( ARRAY_TYPE, INDEX_CONSTRAINT :TREE )	RETURN BOOLEAN;
        -- FUNCTION IS_STATIC_DISCRIMINANT_CONSTRAINT ... (NOT USED)
        
      --|-------------------------------------------------------------------------------------------
      END CHK_STAT;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	DERIVED
      --|-------------------------------------------------------------------------------------------
       PACKAGE DERIVED IS
       
          FUNCTION  MAKE_DERIVED_SUBPROGRAM_LIST	( DERIVED_SUBTYPE :TREE; PARENT_SUBTYPE :TREE; H :H_TYPE )	RETURN SEQ_TYPE;
          PROCEDURE REMEMBER_DERIVED_DECL	( DECL :TREE );
        -- (CALLED FROM FIXWITH -- REMEMBERS DERIVED DECL WITH DERIVED SUBP)
      
      --|-------------------------------------------------------------------------------------------
      END DERIVED;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	EXP_TYPE
      --|-------------------------------------------------------------------------------------------
       PACKAGE EXP_TYPE IS
         USE SET_UTIL;
      
          PROCEDURE EVAL_EXP_TYPES		( EXP :TREE; TYPESET :OUT TYPESET_TYPE );
          PROCEDURE EVAL_EXP_SUBTYPE_TYPES	( EXP :TREE; TYPESET :OUT TYPESET_TYPE; IS_SUBTYPE_OUT :OUT BOOLEAN );
          FUNCTION  EVAL_TYPE_MARK		( EXP :TREE )		RETURN TREE;
          FUNCTION  EVAL_SUBTYPE_INDICATION	( EXP :TREE )		RETURN TREE;
          PROCEDURE EVAL_RANGE		( EXP :TREE; TYPESET :OUT TYPESET_TYPE );
          PROCEDURE EVAL_DISCRETE_RANGE		( EXP :TREE; TYPESET :OUT TYPESET_TYPE );
          PROCEDURE EVAL_NON_UNIVERSAL_DISCRETE_RANGE	( EXP :TREE; TYPESET :OUT TYPESET_TYPE );
      
      --|-------------------------------------------------------------------------------------------
      END EXP_TYPE;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	HOM_UNIT
      --|-------------------------------------------------------------------------------------------
       PACKAGE HOM_UNIT IS
      
          FUNCTION WALK_HOMOGRAPH_UNIT	( UNIT_NAME :TREE; HEADER :TREE )	RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END HOM_UNIT;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	INSTANT
      --|-------------------------------------------------------------------------------------------
       PACKAGE INSTANT IS
      
          PROCEDURE WALK_INSTANTIATION	( UNIT_ID :TREE; INSTANTIATION :TREE; H :H_TYPE );
          
      --|-------------------------------------------------------------------------------------------
      END INSTANT;
   
      --|-------------------------------------------------------------------------------------------
      --|	MAKE_NOD
      --|-------------------------------------------------------------------------------------------
       PACKAGE MAKE_NOD IS
      
          FUNCTION MAKE_VARIABLE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_RENAMES_OBJ: BOOLEAN := FALSE;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_IS_SHARED: BOOLEAN := FALSE;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTANT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_RENAMES_OBJ: BOOLEAN := FALSE;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NUMBER_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMPONENT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_COMP_REP: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DISCRIMINANT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_COMP_REP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IN_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IN_OUT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_OUT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENUMERATION_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_POS: INTEGER := 0;
                SM_REP: INTEGER := 0;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CHARACTER_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_POS: INTEGER := 0;
                SM_REP: INTEGER := 0;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ITERATION_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBTYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PRIVATE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_L_PRIVATE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PROCEDURE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_UNIT_DESC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_IS_INLINE: BOOLEAN := FALSE;
                SM_INTERFACE: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FUNCTION_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_UNIT_DESC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_IS_INLINE: BOOLEAN := FALSE;
                SM_INTERFACE: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_OPERATOR_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_UNIT_DESC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_IS_INLINE: BOOLEAN := FALSE;
                SM_INTERFACE: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID;
                XD_NOT_EQUAL: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PACKAGE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_UNIT_DESC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_GENERIC_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_GENERIC_PARAM_S: TREE := TREE_VOID;
                SM_BODY: TREE := TREE_VOID;
                SM_IS_INLINE: BOOLEAN := FALSE;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TASK_BODY_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                SM_BODY: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_LABEL_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_BLOCK_LOOP_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENTRY_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_EXCEPTION_ID	( LX_SRCPOS, LX_SYMREP, SM_RENAMES_EXC, XD_REGION: TREE := TREE_VOID )	RETURN TREE;
          FUNCTION MAKE_ATTRIBUTE_ID	( LX_SRCPOS, LX_SYMREP: TREE := TREE_VOID; XD_POS: INTEGER )	RETURN TREE;
          FUNCTION MAKE_PRAGMA_ID	( LX_SRCPOS, LX_SYMREP, SM_ARGUMENT_ID_S :TREE := TREE_VOID; XD_POS :INTEGER )	RETURN TREE;
          FUNCTION MAKE_ARGUMENT_ID	( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER )	RETURN TREE;
          FUNCTION MAKE_BLTN_OPERATOR_ID( LX_SRCPOS, LX_SYMREP: TREE := TREE_VOID; SM_OPERATOR: INTEGER )	RETURN TREE;
      
          FUNCTION MAKE_BLOCK_MASTER
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DSCRMT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IN
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LX_DEFAULT: BOOLEAN := FALSE)
                RETURN TREE;
      
          FUNCTION MAKE_OUT
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IN_OUT
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTANT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_VARIABLE_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NUMBER_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_EXCEPTION_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DEFERRED_CONSTANT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TYPE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DSCRMT_DECL_S: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBTYPE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TASK_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DECL_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_GENERIC_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_ITEM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBPROG_ENTRY_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_UNIT_KIND: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PACKAGE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_UNIT_KIND: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID )
                RETURN TREE;
      
          FUNCTION MAKE_RENAMES_OBJ_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_TYPE_MARK_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RENAMES_EXC_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NULL_COMP_DECL
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_LENGTH_ENUM_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ADDRESS
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RECORD_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_ALIGNMENT_CLAUSE: TREE := TREE_VOID;
                AS_COMP_REP_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USE
                ( AS_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PRAGMA
                ( AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBPROGRAM_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PACKAGE_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TASK_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBUNIT
                ( AS_NAME: TREE := TREE_VOID;
                AS_SUBUNIT_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENUMERATION_DEF
                ( AS_ENUM_LITERAL_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBTYPE_INDICATION
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INTEGER_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FLOAT_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FIXED_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTRAINED_ARRAY_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_UNCONSTRAINED_ARRAY_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                AS_INDEX_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ACCESS_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DERIVED_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL) )
                RETURN TREE;
      
          FUNCTION MAKE_RECORD_DEF
                ( AS_COMP_LIST: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PRIVATE_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_L_PRIVATE_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FORMAL_DSCRT_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FORMAL_INTEGER_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FORMAL_FIXED_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FORMAL_FLOAT_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ALTERNATIVE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ARGUMENT_ID_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CHOICE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMP_REP_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMPLTN_UNIT_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONTEXT_ELEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DECL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DSCRMT_DECL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_GENERAL_ASSOC_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DISCRETE_RANGE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENUM_LITERAL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_EXP_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ITEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INDEX_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NAME_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PARAM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PRAGMA_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SCALAR_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SOURCE_NAME_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_STM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TEST_CLAUSE_ELEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USE_PRAGMA_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_VARIANT_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_LABELED
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                AS_STM: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NULL_STM
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ABORT
                ( AS_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RETURN
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DELAY
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ASSIGN
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_EXIT
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CODE
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CASE
                ( AS_EXP: TREE := TREE_VOID;
                AS_ALTERNATIVE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_GOTO
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RAISE
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENTRY_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PROCEDURE_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ACCEPT
                ( AS_NAME: TREE := TREE_VOID;
                AS_PARAM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_LOOP
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_ITERATION: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_BLOCK
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BLOCK_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COND_ENTRY
                ( AS_STM_S1: TREE := TREE_VOID;
                AS_STM_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TIMED_ENTRY
                ( AS_STM_S1: TREE := TREE_VOID;
                AS_STM_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IF
                ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SELECTIVE_WAIT
                ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TERMINATE
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_STM_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NAMED
                ( AS_EXP: TREE := TREE_VOID;
                AS_CHOICE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ASSOC
                ( AS_EXP: TREE := TREE_VOID;
                AS_USED_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USED_CHAR
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USED_OBJECT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USED_OP
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_USED_NAME_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ATTRIBUTE
                ( AS_NAME: TREE := TREE_VOID;
                AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SELECTED
                ( AS_NAME: TREE := TREE_VOID;
                AS_DESIGNATOR: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FUNCTION_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LX_PREFIX: BOOLEAN := FALSE;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INDEXED
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SLICE
                ( AS_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ALL
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SHORT_CIRCUIT
                ( AS_EXP1: TREE := TREE_VOID;
                AS_SHORT_CIRCUIT_OP: TREE := TREE_VOID;
                AS_EXP2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NUMERIC_LITERAL
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_NUMREP: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NULL_ACCESS
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RANGE_MEMBERSHIP
                ( AS_EXP: TREE := TREE_VOID;
                AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TYPE_MEMBERSHIP
                ( AS_EXP: TREE := TREE_VOID;
                AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONVERSION
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_QUALIFIED
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PARENTHESIZED
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_AGGREGATE
                ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DISCRETE_RANGE: TREE := TREE_VOID;
                SM_NORMALIZED_COMP_S: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_STRING_LITERAL
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DISCRETE_RANGE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_QUALIFIED_ALLOCATOR
                ( AS_QUALIFIED: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SUBTYPE_ALLOCATOR
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DESIG_TYPE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RANGE
                ( AS_EXP1: TREE := TREE_VOID;
                AS_EXP2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RANGE_ATTRIBUTE
                ( AS_NAME: TREE := TREE_VOID;
                AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DISCRETE_SUBTYPE
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FLOAT_CONSTRAINT
                ( AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FIXED_CONSTRAINT
                ( AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INDEX_CONSTRAINT
                ( AS_DISCRETE_RANGE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DSCRMT_CONSTRAINT
                ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CHOICE_EXP
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CHOICE_RANGE
                ( AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CHOICE_OTHERS
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PROCEDURE_SPEC
                ( AS_PARAM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FUNCTION_SPEC
                ( AS_PARAM_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENTRY
                ( AS_PARAM_S: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PACKAGE_SPEC
                ( AS_DECL_S1: TREE := TREE_VOID;
                AS_DECL_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                XD_BODY_IS_REQUIRED: BOOLEAN := FALSE)
                RETURN TREE;
      
          FUNCTION MAKE_RENAMES_UNIT
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INSTANTIATION
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_DECL_S: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NAME_DEFAULT
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_BOX_DEFAULT
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NO_DEFAULT
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_BLOCK_BODY
                ( AS_ITEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                AS_ALTERNATIVE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_STUB
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IMPLICIT_NOT_EQ
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_EQUAL: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_DERIVED_SUBPROG
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_DERIVABLE: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COND_CLAUSE
                ( AS_EXP: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SELECT_ALTERNATIVE
                ( AS_EXP: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_SELECT_ALT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_IN_OP
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_NOT_IN
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_AND_THEN
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_OR_ELSE
                ( LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_FOR
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_REVERSE
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_WHILE
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ALTERNATIVE
                ( AS_CHOICE_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ALTERNATIVE_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMP_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMP_REP_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONTEXT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_WITH
                ( AS_NAME_S: TREE := TREE_VOID;
                AS_USE_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_VARIANT
                ( AS_CHOICE_S: TREE := TREE_VOID;
                AS_COMP_LIST: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_VARIANT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ALIGNMENT
                ( AS_PRAGMA_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_VARIANT_PART
                ( AS_NAME: TREE := TREE_VOID;
                AS_VARIANT_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMP_LIST
                ( AS_DECL_S: TREE := TREE_VOID;
                AS_VARIANT_PART: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMPILATION
                ( AS_COMPLTN_UNIT_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_COMPILATION_UNIT
                ( AS_CONTEXT_ELEM_S: TREE := TREE_VOID;
                AS_ALL_DECL: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                XD_TIMESTAMP: INTEGER := 0;
                LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                XD_NBR_PAGES: INTEGER := 0;
                XD_LIB_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INDEX
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_TASK_SPEC
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_DECL_S: TREE := TREE_VOID;
                SM_BODY: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_STORAGE_SIZE: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ENUMERATION
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_LITERAL_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0)
                RETURN TREE;
      
          FUNCTION MAKE_INTEGER (	SM_DERIVED, SM_BASE_TYPE, SM_RANGE, XD_SOURCE_NAME :TREE := TREE_VOID;
          		CD_IMPL_SIZE: INTEGER := 0; SM_IS_ANONYMOUS :BOOLEAN := FALSE
                	) RETURN TREE;
      
          FUNCTION MAKE_FLOAT
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_ACCURACY: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0)
                RETURN TREE;
      
          FUNCTION MAKE_FIXED
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_ACCURACY: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0;
                CD_IMPL_SMALL: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ARRAY
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_IS_LIMITED: BOOLEAN := FALSE;
                SM_IS_PACKED: BOOLEAN := FALSE;
                SM_INDEX_S: TREE := TREE_VOID;
                SM_COMP_TYPE: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_RECORD
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_IS_LIMITED: BOOLEAN := FALSE;
                SM_IS_PACKED: BOOLEAN := FALSE;
                SM_DISCRIMINANT_S: TREE := TREE_VOID;
                SM_COMP_LIST: TREE := TREE_VOID;
                SM_REPRESENTATION: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_ACCESS
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_STORAGE_SIZE: TREE := TREE_VOID;
                SM_IS_CONTROLLED: BOOLEAN := FALSE;
                SM_DESIG_TYPE: TREE := TREE_VOID;
                SM_MASTER: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTRAINED_ARRAY
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_INDEX_SUBTYPE_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTRAINED_RECORD
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_NORMALIZED_DSCRMT_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_CONSTRAINED_ACCESS
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_DESIG_TYPE: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_PRIVATE
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_DISCRIMINANT_S: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_L_PRIVATE
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_DISCRIMINANT_S: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_INCOMPLETE
                ( SM_DISCRIMINANT_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                XD_FULL_TYPE_SPEC: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_UNIVERSAL_INTEGER
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_UNIVERSAL_FIXED
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
          FUNCTION MAKE_UNIVERSAL_REAL
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END MAKE_NOD;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	GEN_SUBS
      --|-------------------------------------------------------------------------------------------
       PACKAGE GEN_SUBS IS
      
         NODE_HASH_SIZE	: CONSTANT := 131;
         TYPE NODE_ARRAY_TYPE	IS ARRAY (0 .. INTEGER(NODE_HASH_SIZE - 1)) OF TREE;
         TYPE NODE_HASH_TYPE	IS RECORD
               LIMIT	: NATURAL	:= 32000;
               A		: NODE_ARRAY_TYPE	:= (OTHERS => TREE_VOID);
            END RECORD;
      
          PROCEDURE SUBSTITUTE		( NODE :IN OUT TREE; NODE_HASH :IN OUT NODE_HASH_TYPE; H_IN :H_TYPE );
          PROCEDURE REPLACE_NODE		( NODE :IN OUT TREE; NODE_HASH :IN OUT NODE_HASH_TYPE );
          PROCEDURE SUBSTITUTE_ATTRIBUTES	( NODE :IN OUT TREE; NODE_HASH :IN OUT NODE_HASH_TYPE; H_IN :H_TYPE );
          PROCEDURE INSERT_NODE_HASH		( NODE_HASH :IN OUT NODE_HASH_TYPE; NEW_NODE :TREE; OLD_NODE :TREE );
      
      --|-------------------------------------------------------------------------------------------
      END GEN_SUBS;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	NEWSNAM
      --|-------------------------------------------------------------------------------------------
       PACKAGE NEWSNAM IS
         USE GEN_SUBS;
      
          PROCEDURE REPLACE_SOURCE_NAME	( SOURCE_NAME :IN OUT TREE; NODE_HASH :IN OUT NODE_HASH_TYPE; H_IN :H_TYPE; DECL :TREE := TREE_VOID );
          
      --|-------------------------------------------------------------------------------------------
      END NEWSNAM;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	PRE_FCNS
      --|-------------------------------------------------------------------------------------------
       PACKAGE PRE_FCNS IS
      
          PROCEDURE GEN_PREDEFINED_OPERATORS	( TYPE_SPEC :TREE; H_IN :H_TYPE );
       
      --|-------------------------------------------------------------------------------------------
      END PRE_FCNS;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	PRENAME
      --|-------------------------------------------------------------------------------------------
       PACKAGE PRENAME IS
      
         TYPE DEFINED_PRAGMAS	IS (
         	CONTROLLED,	ELABORATE,	INLINE,	INTERFACE,
         	LIST,	MEMORY_SIZE,	OPTIMIZE,	PACK,
         	PAGE,	PRIORITY,	SHARED,	STORAGE_UNIT,
         	SUPPRESS,	SYSTEM_NAME,
         
         	DEBUG				--| PRAGMA DEBUG ( ON|OFF ) -- ENABLES/DISABLES TRACE IN COMPILER
         	);
      
         TYPE LIST_ARGUMENTS	IS ( OFF, ON );
      
         TYPE OPTIMIZE_ARGUMENTS	IS ( TIME, SPACE );
      
         TYPE SUPPRESS_ARGUMENTS	IS (
         	ON,
                	ACCESS_CHECK,	INDEX_CHECK,	DISCRIMINANT_CHECK,
                	LENGTH_CHECK,	RANGE_CHECK,	ELABORATION_CHECK,
                	DIVISION_CHECK,	OVERFLOW_CHECK,	STORAGE_CHECK
                	);
      
         TYPE INTERFACE_ARGUMENTS	IS ( ADA, ASM );
      
         TYPE DEFINED_ATTRIBUTES	IS (
                	ADDRESS,	AFT,	BASE,
                	CALLABLE,	CONSTRAINED,	COUNT,
                	DELTA_X,	DIGITS_X,	EMAX,
                	EPSILON,	FIRST,	FIRST_BIT,
                	FORE,	IMAGE,	LARGE,
                	LAST,	LAST_BIT,	LENGTH,
                	MACHINE_EMAX,	MACHINE_EMIN,
                	MACHINE_MANTISSA,	MACHINE_OVERFLOWS,
                	MACHINE_RADIX, 	MACHINE_ROUNDS,
                	MANTISSA,	POS,	POSITION,
                	PRED,	RANGE_X,	SAFE_EMAX,
                	SAFE_LARGE,	SAFE_SMALL,	SIZE,
                	SMALL, 	STORAGE_SIZE,	SUCC,
                	TERMINATED,	VAL,	VALUE,
                	WIDTH
         	);
      
         TYPE OP_CLASS	IS (
                	OP_AND,	OP_OR,	OP_XOR,	OP_NOT,
         	OP_UNARY_PLUS,	OP_UNARY_MINUS,	OP_ABS,	OP_EQ,
         OP_NE,	OP_LT,	OP_LE,	OP_GT,
         OP_GE,	OP_PLUS,	OP_MINUS,	OP_MULT,
         OP_DIV,	OP_MOD,	OP_REM,	OP_CAT,
         OP_EXP
         );
      
         SUBTYPE CLASS_BOOLEAN_OP	IS OP_CLASS RANGE OP_AND .. OP_XOR;
         SUBTYPE CLASS_EQUALITY_OP	IS OP_CLASS RANGE OP_EQ .. OP_NE;
         SUBTYPE CLASS_RELATIONAL_OP	IS OP_CLASS RANGE OP_LT .. OP_GE;
         SUBTYPE CLASS_EQ_RELATIONAL_OP	IS OP_CLASS RANGE OP_EQ .. OP_GE;
      
         SUBTYPE CLASS_UNARY_OP	IS OP_CLASS RANGE OP_NOT .. OP_ABS;
         SUBTYPE CLASS_UNARY_NUMERIC_OP	IS OP_CLASS RANGE OP_UNARY_PLUS .. OP_ABS;
         SUBTYPE CLASS_FIXED_OP	IS OP_CLASS RANGE OP_PLUS .. OP_MINUS;
         SUBTYPE CLASS_FLOAT_OP	IS OP_CLASS RANGE OP_PLUS .. OP_DIV;
         SUBTYPE CLASS_INTEGER_OP	IS OP_CLASS RANGE OP_PLUS .. OP_REM;
      
         SUBTYPE STRING_3	IS STRING(1..3);
      
         BLTN_TEXT_ARRAY	: CONSTANT ARRAY (OP_CLASS) OF STRING_3 := (
         OP_AND => "AND",	OP_OR => "OR!",	OP_XOR => "XOR",	OP_EQ => "=!!",
         	OP_NE => "/=!",	OP_LT => "<!!",	OP_LE => "<=!",	OP_GT => ">!!",
         	OP_GE => ">=!",	OP_PLUS => "+!!",	OP_MINUS => "-!!",	OP_CAT => "&!!",
         	OP_UNARY_PLUS => "+!!",	OP_UNARY_MINUS => "-!!",
         	OP_ABS => "ABS",	OP_NOT => "NOT",	OP_MULT => "*!!",	OP_DIV => "/!!",
         	OP_MOD => "MOD",	OP_REM => "REM",	OP_EXP => "**!"
         );
      
         BLTN_ID_ARRAY	: ARRAY (OP_CLASS) OF TREE	:= (OTHERS => TREE_VOID);
      
      --|-------------------------------------------------------------------------------------------
      END PRENAME;
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	RED_SUBP
      --|-------------------------------------------------------------------------------------------
       PACKAGE RED_SUBP IS
         USE SET_UTIL;
         USE SET_UTIL;
      
          PROCEDURE EVAL_SUBP_CALL		( EXP :TREE; TYPESET :OUT TYPESET_TYPE );
          FUNCTION  RESOLVE_FUNCTION_CALL	( EXP :TREE; TYPE_SPEC :TREE )	RETURN TREE;
          PROCEDURE REDUCE_APPLY_NAMES		( NAME :TREE; NAME_DEFSET :IN OUT DEFSET_TYPE; GEN_ASSOC_S :TREE; INDEX :TREE := TREE_VOID );
          FUNCTION  RESOLVE_SUBP_PARAMETERS	( DEF :TREE; GEN_ASSOC_S :TREE )	RETURN TREE;
          PROCEDURE RESOLVE_ERRONEOUS_PARAM_S (GENERAL_ASSOC_S: TREE);
          PROCEDURE CHECK_ACTUAL_TYPE		( FORMAL_TYPE :TREE; ACTUAL_TYPESET :TYPESET_TYPE; ACTUALS_OK :OUT BOOLEAN; EXTRAINFO :OUT EXTRAINFO_TYPE );
          FUNCTION  GET_TYPE_OF_DISCRETE_RANGE	( DISCRETE_RANGE :TREE )	RETURN TREE;
      
      --|-------------------------------------------------------------------------------------------
      END RED_SUBP;
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	REP_CLAU
      --|-------------------------------------------------------------------------------------------
       PACKAGE REP_CLAU IS
      
          PROCEDURE RESOLVE_LENGTH_REP	( ATTRIBUTE :TREE; EXP :IN OUT TREE; H :H_TYPE );
          PROCEDURE RESOLVE_ENUM_REP	( SIMPLE_NAME :IN OUT TREE; EXP :TREE; H :H_TYPE );
          PROCEDURE RESOLVE_ADDRESS_REP	( SIMPLE_NAME :IN OUT TREE; EXP :IN OUT TREE; H :H_TYPE );
          PROCEDURE RESOLVE_RECORD_REP	( SIMPLE_NAME :IN OUT TREE; ALIGNMENT :TREE; COMP_REP_S :TREE; H :H_TYPE );
      
      --|-------------------------------------------------------------------------------------------
      END REP_CLAU;
   
   
   
   
   
      USED_PACKAGE_LIST : SEQ_TYPE	RENAMES FIX_WITH.USED_PACKAGE_LIST;
         
         
       PACKAGE BODY SEM_GLOB	IS SEPARATE;
       PACKAGE BODY UNIV_OPS	IS SEPARATE;
       FUNCTION  EVAL_NUM	( TXT :STRING )	RETURN TREE	IS SEPARATE;
       PACKAGE BODY UARITH	IS SEPARATE;
       PACKAGE BODY FIX_WITH	IS SEPARATE;
       PACKAGE BODY DEF_UTIL	IS SEPARATE;
       PACKAGE BODY SET_UTIL	IS SEPARATE;
       PACKAGE BODY REQ_UTIL	IS SEPARATE;
       PACKAGE BODY AGGRESO	IS SEPARATE;
       PACKAGE BODY EXPRESO	IS SEPARATE;
       PACKAGE BODY VIS_UTIL	IS SEPARATE;
       PACKAGE BODY DEF_WALK	IS SEPARATE;
       PACKAGE BODY NOD_WALK	IS SEPARATE;
       PACKAGE BODY ATT_WALK	IS SEPARATE;
       PACKAGE BODY STM_WALK	IS SEPARATE;
       PACKAGE BODY PRA_WALK	IS SEPARATE;
       PACKAGE BODY CHK_STAT	IS SEPARATE;
       PACKAGE BODY DERIVED	IS SEPARATE;
       PACKAGE BODY EXP_TYPE	IS SEPARATE;
       PACKAGE BODY HOM_UNIT	IS SEPARATE;
       PACKAGE BODY INSTANT	IS SEPARATE;
       PACKAGE BODY MAKE_NOD	IS SEPARATE;
       PACKAGE BODY GEN_SUBS	IS SEPARATE;
       PACKAGE BODY NEWSNAM	IS SEPARATE;
       PACKAGE BODY PRE_FCNS	IS SEPARATE;
       PACKAGE BODY RED_SUBP	IS SEPARATE;
       PACKAGE BODY REP_CLAU	IS SEPARATE;
   
       
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE INITIALIZE_PRAGMA_ATTRIBUTE_DEFS
       PROCEDURE INITIALIZE_PRAGMA_ATTRIBUTE_DEFS IS
         STD_PACK_SYM	: TREE	:= STORE_SYM ( "_STANDRD.DCL" );
         STD_PACK_ID	: TREE	:= HEAD ( LIST ( STD_PACK_SYM ) );
         ALL_DECL		: TREE	:= D ( AS_ALL_DECL, STD_PACK_ID );
         STD_PACK_HEADER	: TREE	:= D ( AS_HEADER, ALL_DECL );
         DECL_PRIV		: TREE	:= D ( AS_DECL_S2, STD_PACK_HEADER );
         ID_LIST		: SEQ_TYPE	:= LIST ( DECL_PRIV );	--| LA LISTE DES DÉCLARATIONS PRIVÉES DE _STANDRD
         ID		: TREE;
         DEF		: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( ID_LIST ) LOOP			--| TANT QU'IL Y A DES ÉLÉMENTS PRIVÉS
            POP ( ID_LIST, ID );				--| EN EXTRAIRE UN
            IF ID.TY IN DN_ATTRIBUTE_ID .. DN_PRAGMA_ID			--| SI C'EST UN ID D'ATTRIBUT OU DE PRAGMA
               AND THEN D ( LX_SYMREP, ID ).TY = DN_SYMBOL_REP		--| ET QU'IL Y A BIEN UN SYMBOLE ASSOCIÉ (PAR LIB_PHASE SI L'ID EST UTILISÉ DANS LA COMPILATION)
            THEN
               DEF := DEF_UTIL.MAKE_DEF_FOR_ID ( ID, INITIAL_H );
               D ( XD_REGION_DEF, DEF, TREE_VOID );
               DB ( XD_IS_IN_SPEC, DEF, FALSE );
            END IF;
         END LOOP;
      END INITIALIZE_PRAGMA_ATTRIBUTE_DEFS;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE COMPILE_COMPILATION_UNIT
       PROCEDURE COMPILE_COMPILATION_UNIT ( COMPILATION_UNIT :TREE; H :H_TYPE ) IS
         CONTEXT_ELEM_S	: CONSTANT TREE	:= D ( AS_CONTEXT_ELEM_S, COMPILATION_UNIT );
         ALL_DECL		: CONSTANT TREE	:= D ( AS_ALL_DECL, COMPILATION_UNIT );
         PRAGMA_S		: CONSTANT TREE	:= D ( AS_PRAGMA_S, COMPILATION_UNIT );
         WITH_LIST		: CONSTANT SEQ_TYPE	:= LIST ( COMPILATION_UNIT );
      
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE PROCESS_WITH_NAME_S
          PROCEDURE PROCESS_WITH_NAME_S ( NAME_S :TREE ) IS			--| TRAITE LES CLAUSES WITH DANS LES CLAUSES DE CONTEXTE, SM_DEFN MISES DANS LIB_PHASE
            NAME_LIST	: SEQ_TYPE	:= LIST ( NAME_S );
            NAME		: TREE;
            NEW_NAME_LIST	: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
            NEW_NAME	: TREE;
            NAME_DEFN	: TREE;
            NAME_DEF	: TREE;
         BEGIN
         
            WHILE NOT IS_EMPTY ( NAME_LIST ) LOOP
               POP ( NAME_LIST, NAME );
               NAME_DEFN := D ( SM_DEFN, NAME );			--| CHERCHER LA DÉFINITION CORRESPONDANTE
               NAME_DEF := DEF_UTIL.GET_DEF_FOR_ID ( NAME_DEFN );
               D ( XD_REGION_DEF, NAME_DEF, DEF_UTIL.GET_DEF_FOR_ID ( D ( XD_REGION, NAME_DEFN)) );	--| L'INDIQUER "WITH"ÉE
               NEW_NAME := VIS_UTIL.MAKE_USED_NAME_ID_FROM_OBJECT ( NAME );		--| REMPLACER LES USED_OBJECT_ID AVEC DES USED_NAME_ID
               NEW_NAME_LIST := APPEND ( NEW_NAME_LIST, NEW_NAME );
            END LOOP;
         
            LIST ( NAME_S, NEW_NAME_LIST);			--| SAUVER LA NOUVELLE LISTE DE USED_NAME_ID'S
         END PROCESS_WITH_NAME_S;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE PROCESS_WITH_USE_PRAGMA_S
          PROCEDURE PROCESS_WITH_USE_PRAGMA_S ( USE_PRAGMA_S :TREE ) IS		--| MODIFIE LES DEFS POUR LES CLAUSES USE DANS LES CLAUSES DE CONTEXTE
            USE_PRAGMA_LIST	: SEQ_TYPE	:= LIST ( USE_PRAGMA_S );
            USE_PRAGMA	: TREE;
            NAME_LIST	: SEQ_TYPE;
            NAME		: TREE;
            NEW_NAME_LIST	: SEQ_TYPE;
            NEW_NAME	: TREE;
            NAME_DEFN	: TREE;
            NAME_DEF	: TREE;
         BEGIN
            WHILE NOT IS_EMPTY ( USE_PRAGMA_LIST ) LOOP			--| POUR CHAQUE CLAUSE USE OU PRAGMA
               POP ( USE_PRAGMA_LIST, USE_PRAGMA );
            
               IF USE_PRAGMA.TY = DN_PRAGMA THEN
                  NOD_WALK.WALK ( USE_PRAGMA, INITIAL_H );
               
               ELSE					--| POUR CHAQUE NOM DANS LA CLAUSE USE
                  NAME_LIST := LIST ( D ( AS_NAME_S, USE_PRAGMA ) );
                  NEW_NAME_LIST := (TREE_NIL,TREE_NIL);
                  WHILE NOT IS_EMPTY ( NAME_LIST) LOOP
                     POP ( NAME_LIST, NAME );
                     NAME_DEFN := D ( SM_DEFN, NAME );
                     NAME_DEF := DEF_UTIL.GET_DEF_FOR_ID ( NAME_DEFN );
                     DB ( XD_IS_USED, NAME_DEF, TRUE );			--| L'INDIQUER UTILISÉE
                     NEW_NAME := VIS_UTIL.MAKE_USED_NAME_ID_FROM_OBJECT ( NAME );	--| REMPLACER USED_OBJECT_ID PAR USED_NAME_ID
                     NEW_NAME_LIST := APPEND ( NEW_NAME_LIST, NEW_NAME );
                  END LOOP;
               
                  LIST ( D ( AS_NAME_S, USE_PRAGMA), NEW_NAME_LIST );		--| SAUVER LA NOUVELLE LISTE DE USED_NAME_ID'S 
               END IF;
               
            END LOOP;
         END PROCESS_WITH_USE_PRAGMA_S;
         --|----------------------------------------------------------------------------------------
         --|	   PROCEDURE PROCESS_CONTEXT_CLAUSES
          PROCEDURE PROCESS_CONTEXT_CLAUSES ( COMPILATION_UNIT :TREE ) IS
            CONTEXT_ELEM_S	: CONSTANT TREE	:= D ( AS_CONTEXT_ELEM_S, COMPILATION_UNIT );
            CONTEXT_ELEM_LIST	: SEQ_TYPE	:= LIST ( CONTEXT_ELEM_S );
            CONTEXT_ELEM	: TREE;
            TRANS_WITH_LIST	: SEQ_TYPE	:= LIST ( COMPILATION_UNIT );
            TRANS_WITH	: TREE;
            --|-------------------------------------------------------------------------------------
            --|	      PROCEDURE PROCESS_ANCESTOR_CONTEXT
             PROCEDURE PROCESS_ANCESTOR_CONTEXT ( ANCESTOR_UNIT, COMPILATION_UNIT :TREE ) IS
               --|----------------------------------------------------------------------------------
               --|	         PROCEDURE IS_ANCESTOR
                FUNCTION IS_ANCESTOR ( ANC_ALL_DECL, COMP_ALL_DECL :TREE ) RETURN BOOLEAN IS
               BEGIN
                  IF COMP_ALL_DECL.TY IN CLASS_SUBUNIT_BODY THEN
                     RETURN (
                        ANC_ALL_DECL.TY IN CLASS_UNIT_DECL
                        AND THEN D ( SM_FIRST, D ( AS_SOURCE_NAME, COMP_ALL_DECL ) ) = D ( AS_SOURCE_NAME, ANC_ALL_DECL)
                        );
                  ELSIF COMP_ALL_DECL.TY = DN_SUBUNIT THEN
                     DECLARE
                        COMP_NAME	: TREE	:= D ( AS_NAME, COMP_ALL_DECL );
                        ANC_ID	: TREE	:= TREE_VOID;
                     BEGIN
                        IF ANC_ALL_DECL.TY = DN_SUBUNIT THEN
                           ANC_ID := D ( SM_FIRST, D (  AS_SOURCE_NAME, D ( AS_SUBUNIT_BODY, ANC_ALL_DECL ) ) );
                           RETURN FIX_WITH.IS_ANCESTOR ( ANC_ID, COMP_ALL_DECL );
                        ELSIF ANC_ALL_DECL /= TREE_VOID THEN
                           ANC_ID := D ( SM_FIRST, D (  AS_SOURCE_NAME, ANC_ALL_DECL ) );
                           WHILE COMP_NAME.TY = DN_SELECTED LOOP
                              COMP_NAME := D ( AS_NAME, COMP_NAME );
                           END LOOP;
                           RETURN D ( LX_SYMREP, ANC_ID ) = D ( LX_SYMREP, COMP_NAME );
                        END IF;
                     END;
                  END IF;
                  RETURN FALSE;
               END IS_ANCESTOR;
               --|----------------------------------------------------------------------------------
               --|	          PROCEDURE REPROCESS_CONTEXT
                PROCEDURE REPROCESS_CONTEXT ( CONTEXT_ELEM_S :TREE ) IS
                -- GIVEN CONTEXT_ELEM_S FOR AN ANCESTOR UNIT,
                -- ... REPROCESS WITH'S AND USE'S IN FOR USE IN CURRENT UNIT
                  CONTEXT_ELEM_LIST	: SEQ_TYPE	:= LIST ( CONTEXT_ELEM_S );
                  CONTEXT_ELEM	: TREE;
                  USE_PRAGMA_LIST	: SEQ_TYPE;
                  USE_PRAGMA	: TREE;
                  ITEM_LIST	: SEQ_TYPE;
                  ITEM	: TREE;
               BEGIN
                  WHILE NOT IS_EMPTY ( CONTEXT_ELEM_LIST) LOOP
                     POP ( CONTEXT_ELEM_LIST, CONTEXT_ELEM);
                     IF CONTEXT_ELEM.TY = DN_WITH THEN
                        ITEM_LIST := LIST ( D ( AS_NAME_S, CONTEXT_ELEM ) );
                        WHILE NOT IS_EMPTY ( ITEM_LIST) LOOP
                           POP ( ITEM_LIST, ITEM);
                           IF D ( SM_DEFN, ITEM ) /= TREE_VOID THEN
                              D ( XD_REGION_DEF, DEF_UTIL.GET_DEF_FOR_ID ( D ( SM_DEFN,ITEM ) ), PREDEFINED_STANDARD_DEF );
                           END IF;
                        END LOOP;
                        USE_PRAGMA_LIST := LIST ( D ( AS_USE_PRAGMA_S, CONTEXT_ELEM ) );
                        WHILE NOT IS_EMPTY ( USE_PRAGMA_LIST) LOOP
                           POP ( USE_PRAGMA_LIST, USE_PRAGMA);
                           IF USE_PRAGMA.TY = DN_USE THEN
                              ITEM_LIST := LIST ( D ( AS_NAME_S, USE_PRAGMA ) );
                              WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP
                                 POP ( ITEM_LIST, ITEM );
                                 IF D ( SM_DEFN, ITEM ) /= TREE_VOID THEN
                                    DB ( XD_IS_USED, DEF_UTIL.GET_DEF_FOR_ID ( D ( SM_DEFN, ITEM ) ), TRUE );
                                 END IF;
                              END LOOP;
                           END IF;
                        END LOOP;
                     END IF;
                  END LOOP;
               END REPROCESS_CONTEXT;
            
            BEGIN
               IF IS_ANCESTOR ( D ( AS_ALL_DECL, ANCESTOR_UNIT ), D ( AS_ALL_DECL, COMPILATION_UNIT ) ) THEN
                  REPROCESS_CONTEXT ( D ( AS_CONTEXT_ELEM_S, ANCESTOR_UNIT ) );
               END IF;
            END PROCESS_ANCESTOR_CONTEXT;
         
         BEGIN
                -- FOR EACH CONTEXT_ELEM
            WHILE NOT IS_EMPTY ( CONTEXT_ELEM_LIST) LOOP
               POP ( CONTEXT_ELEM_LIST, CONTEXT_ELEM);
            
               IF CONTEXT_ELEM.TY = DN_WITH THEN
                  PROCESS_WITH_NAME_S ( D ( AS_NAME_S, CONTEXT_ELEM ) );
                  PROCESS_WITH_USE_PRAGMA_S ( D ( AS_USE_PRAGMA_S, CONTEXT_ELEM ) );
               
               ELSE
                  PUT_LINE ( "!! $$$$ CONTEXT PRAGMA." );
                  RAISE PROGRAM_ERROR;
               END IF;
            END LOOP;
         
            WHILE NOT IS_EMPTY ( TRANS_WITH_LIST) LOOP			--| CLAUSES ANCÊTRES
               POP ( TRANS_WITH_LIST, TRANS_WITH);
               PROCESS_ANCESTOR_CONTEXT ( D ( TW_COMP_UNIT, TRANS_WITH ), COMPILATION_UNIT );
            END LOOP;
         
         END PROCESS_CONTEXT_CLAUSES;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE ENTER_ANCESTOR_REGION
          PROCEDURE ENTER_ANCESTOR_REGION ( NAME :TREE; H :IN OUT H_TYPE ) IS
            S		: NOD_WALK.S_TYPE;
            DESIGNATOR	: TREE;
            DEFN		: TREE;
            DES_DEF		: TREE;
            DEFLIST		: SEQ_TYPE;
            DEF		: TREE;
         BEGIN
            IF NAME.TY = DN_SELECTED THEN
               ENTER_ANCESTOR_REGION ( D ( AS_NAME, NAME ), H );
               DESIGNATOR := D ( AS_DESIGNATOR, NAME );
            ELSE
               DESIGNATOR := NAME;
            END IF;
            D ( SM_DEFN, DESIGNATOR, TREE_VOID );
            DEFLIST := LIST ( D ( LX_SYMREP, DESIGNATOR ) );
            WHILE NOT IS_EMPTY ( DEFLIST) LOOP
               POP ( DEFLIST, DEF);
               IF D ( XD_REGION, D ( XD_SOURCE_NAME, DEF ) ) = D ( XD_SOURCE_NAME, H.REGION_DEF ) THEN
                  DEFN := D ( XD_SOURCE_NAME, DEF);
                  IF DEFN.TY = DN_TYPE_ID OR ELSE DEFN.TY IN CLASS_UNIT_NAME THEN
                     DEFN := D ( SM_FIRST, DEFN );
                  END IF;
                  D ( SM_DEFN, DESIGNATOR, DEFN );
                  EXIT;
               END IF;
            END LOOP;
            DEFN := D ( SM_DEFN, DESIGNATOR );
            IF DEFN = TREE_VOID THEN
               PUT_LINE ( "!! DEFN NOT FOUND FOR ANCESTOR");
               RAISE PROGRAM_ERROR;
            END IF;
            DES_DEF := DEF_UTIL.GET_DEF_FOR_ID ( DEFN );
            D ( XD_REGION_DEF, DES_DEF, H.REGION_DEF );
            NOD_WALK.ENTER_BODY ( DES_DEF, H, S );
         END ENTER_ANCESTOR_REGION;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE WALK_ITEM
          PROCEDURE WALK_ITEM ( ITEM :TREE; H_IN :H_TYPE ) IS
            H	: H_TYPE	:= H_IN;
         BEGIN
            NOD_WALK.WALK ( ITEM, H );
         END WALK_ITEM;
         --|----------------------------------------------------------------------------------------
      
      BEGIN
         IF ALL_DECL.TY = DN_VOID THEN
            ERROR ( D ( LX_SRCPOS, COMPILATION_UNIT ), "$$$ EMPTY UNIT NOT IMPLEMENTED YET");
            RETURN;
         END IF;
      
         USED_PACKAGE_LIST := (TREE_NIL, TREE_NIL);
         FIX_WITH.FIX_WITH_CLAUSES ( COMPILATION_UNIT );
         INITIALIZE_PREDEFINED_TYPES;
      
         PROCESS_CONTEXT_CLAUSES ( COMPILATION_UNIT );
      
         DECLARE
            H	: H_TYPE	:= INITIAL_H;
         BEGIN
            H.REGION_DEF := PREDEFINED_STANDARD_DEF;
            H.LEX_LEVEL := 2;
            H.IS_IN_SPEC := TRUE;
            H.IS_IN_BODY := FALSE;
            IF ALL_DECL.TY = DN_SUBUNIT THEN
               ENTER_ANCESTOR_REGION ( D ( AS_NAME, ALL_DECL ), H );
               WALK_ITEM ( D ( AS_SUBUNIT_BODY, ALL_DECL ), H );
            ELSE
               WALK_ITEM ( ALL_DECL, H);
            END IF;
         
            NOD_WALK.WALK_ITEM_S ( PRAGMA_S, H );
         
            WHILE NOT IS_EMPTY ( USED_PACKAGE_LIST) LOOP
               DB ( XD_IS_USED, HEAD ( USED_PACKAGE_LIST ), FALSE );
               USED_PACKAGE_LIST := TAIL ( USED_PACKAGE_LIST );
            END LOOP;
         END;
      
      END COMPILE_COMPILATION_UNIT;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE CANCEL_TRANS_WITHS
       PROCEDURE CANCEL_TRANS_WITHS ( COMPILATION_UNIT :TREE ) IS		--| REND INVISIBLE LES TRANS_WITH DEFS AVANT L'UNITÉ DE COMPILATION SUIVANTE
         USE DEF_UTIL;
         TRANS_WITH_LIST	: SEQ_TYPE := LIST ( COMPILATION_UNIT );
         TRANS_WITH		: TREE;
         ALL_DECL		: TREE;
         UNIT_ID		: TREE;
      BEGIN
         WHILE NOT IS_EMPTY ( TRANS_WITH_LIST ) LOOP
            POP ( TRANS_WITH_LIST, TRANS_WITH );
            ALL_DECL := D ( AS_ALL_DECL, D ( TW_COMP_UNIT, TRANS_WITH ) );
            IF ALL_DECL.TY /= DN_SUBUNIT THEN
               UNIT_ID := D ( AS_SOURCE_NAME, ALL_DECL );
               IF UNIT_ID.TY IN CLASS_UNIT_NAME AND THEN D ( SM_FIRST, UNIT_ID ) = UNIT_ID THEN
                  REMOVE_DEF_FROM_ENVIRONMENT ( GET_DEF_FOR_ID ( UNIT_ID ) );
               END IF;
            ELSE
               UNIT_ID := D ( SM_FIRST, D ( AS_SOURCE_NAME, D ( AS_SUBUNIT_BODY, ALL_DECL ) ) );
               REMOVE_DEF_FROM_ENVIRONMENT ( GET_DEF_FOR_ID ( UNIT_ID ) );
            END IF;
         END LOOP;
         REMOVE_DEF_FROM_ENVIRONMENT ( PREDEFINED_STANDARD_DEF );
      END CANCEL_TRANS_WITHS;
      --|-------------------------------------------------------------------------------------------
     
     --| POUR LE CAS OU L'ON DEMANDE À TRAITER _STANDRD
       PROCEDURE FIX_PRE IS SEPARATE;
      
   
   BEGIN
      OPEN_IDL_TREE_FILE ( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
      
      IF DI ( XD_ERR_COUNT, TREE_ROOT) > 0 THEN
         PUT_LINE ( "SEMPHASE: NOT EXECUTED");
      ELSE
         DECLARE
            USER_ROOT	: TREE	:= D ( XD_USER_ROOT, TREE_ROOT );
            COMPILATION	: TREE	:= D ( XD_STRUCTURE, USER_ROOT );
            COMPLTN_UNIT_LIST	: SEQ_TYPE	:= LIST ( D ( AS_COMPLTN_UNIT_S, COMPILATION ) );
            COMPILATION_UNIT	: TREE;
            SRC_NAME	: CONSTANT STRING	:= PRINT_NAME ( D ( XD_SOURCENAME, USER_ROOT ) );
         BEGIN
         
            IF SRC_NAME = "_STANDRD.ADA" THEN
               FIX_PRE;
               
            ELSE
               INITIALIZE_GLOBAL_DATA;
               INITIALIZE_PRAGMA_ATTRIBUTE_DEFS;
            
               WHILE NOT IS_EMPTY ( COMPLTN_UNIT_LIST ) LOOP
                  POP ( COMPLTN_UNIT_LIST, COMPILATION_UNIT );
                  COMPILE_COMPILATION_UNIT ( COMPILATION_UNIT, INITIAL_H );
                  IF NOT IS_EMPTY ( COMPLTN_UNIT_LIST ) THEN
                     CANCEL_TRANS_WITHS ( COMPILATION_UNIT );
                  END IF;
               END LOOP;
            END IF;
         END;
      END IF;
      
      CLOSE_PAGE_MANAGER;
   END SEM_PHASE;
