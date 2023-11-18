separate( IDL )
--|=================================================================================================|
--|										|
--|				SEM_PHASE						|
--|										|
--|=================================================================================================|
procedure SEM_PHASE is

  --|------------------------------------------------------------------------------------------------

  --		SEM_GLOB

  --|------------------------------------------------------------------------------------------------
  package SEM_GLOB is
      
    type SB_TYPE	is record								--| SAUVE ET RESTAURE AUTOUR DES CORPS
		  null;
		end record;
      
    type SU_TYPE	is record								--| SAUVE ET RESTAURE AUTOUR DES REGIONS
		  USED_PACKAGE_LIST		: SEQ_TYPE;
		  INCOMPLETE_TYPE_LIST	: SEQ_TYPE;
		  PRIVATE_TYPE_LIST		: SEQ_TYPE;
		end record;
      
    type H_TYPE	is record								--| INFORMATION HEREDITAIRE
		REGION_DEF	: TREE;
		LEX_LEVEL		: NATURAL;
		IS_IN_SPEC	: BOOLEAN;
		IS_IN_BODY	: BOOLEAN;
		SUBP_SYMREP	: TREE;
		RETURN_TYPE	: TREE;
		ENCLOSING_LOOP_ID	: TREE;
            end record;

    SB			: SB_TYPE;
    SU			: SU_TYPE;
    INITIAL_H		: H_TYPE;
      
    PREDEFINED_BOOLEAN		: TREE;
    PREDEFINED_SHORT_INTEGER		: TREE;
    PREDEFINED_INTEGER		: TREE;
    PREDEFINED_LONG_INTEGER		: TREE;
    PREDEFINED_LARGEST_INTEGER	: TREE;
    PREDEFINED_FLOAT		: TREE;
    PREDEFINED_LONG_FLOAT		: TREE;
    PREDEFINED_LARGEST_FLOAT		: TREE;
    PREDEFINED_STRING		: TREE;
    PREDEFINED_DURATION		: TREE;
    PREDEFINED_ADDRESS		: TREE;
      
    PREDEFINED_STANDARD_DEF		: TREE;
    PREDEFINED_STANDARD_ID		: TREE;
      
    PREDEFINED_SHORT_INTEGER_FIRST	: TREE;
    PREDEFINED_SHORT_INTEGER_LAST	: TREE;
    PREDEFINED_INTEGER_FIRST		: TREE;
    PREDEFINED_INTEGER_LAST		: TREE;
    PREDEFINED_LONG_INTEGER_FIRST	: TREE;
    PREDEFINED_LONG_INTEGER_LAST	: TREE;
    PREDEFINED_FLOAT_FIRST		: TREE;
    PREDEFINED_FLOAT_LAST		: TREE;
    PREDEFINED_FLOAT_ACCURACY		: TREE;
    PREDEFINED_LONG_FLOAT_FIRST	: TREE;
    PREDEFINED_LONG_FLOAT_LAST	: TREE;
    PREDEFINED_LONG_FLOAT_ACCURACY	: TREE;
      
      
    procedure INITIALIZE_GLOBAL_DATA;
    procedure INITIALIZE_PREDEFINED_TYPES;
       
  --|------------------------------------------------------------------------------------------------
  end SEM_GLOB;
  use SEM_GLOB;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		UNIV_OPS

  --|------------------------------------------------------------------------------------------------
  package UNIV_OPS is
      
    URADIX		: constant := 10_000;

    type UDIGIT		is range -32_768 .. 32_767;		for UDIGIT'SIZE use 16;

    type VECTOR_DIGITS	is array( 1..252 ) of UDIGIT;		pragma PACK( VECTOR_DIGITS );

    type VECTOR		is record
			  L	: NATURAL;					--| NOMBRE DE "CHIFFRES" 10_000 AIRES
			  S	: UDIGIT;						--| SIGNE +1 OR -1
			  D	: VECTOR_DIGITS;					--| CHIFFRES EN BASE 10_000
			end record;			pragma PACK( VECTOR );
      
    function  U_INT		( V :VECTOR )			return TREE;		--| FABRIQUE UN ENTIER UNIVERSEL À PARTIR D'UN VECTEUR
    function  U_REAL	( NUMER, DENOM :VECTOR )		return TREE;		--| UNIVERSAL REAL À PARTIR DE VECTEURS DEJÀ REDUITS AUX TERMES LES PLUS BAS
    function  U_REAL	( NUMER, DENOM :TREE )		return TREE;		--| UNIVERSAL REAL AVEC DEUX ENTIERS UNIVERSELS (NON NECESSAIREMENT REDUITS)
    procedure SPREAD	( T :TREE; V :in out VECTOR );
    procedure SPREAD	( I :INTEGER; V :in out VECTOR );
    procedure NORMALIZE	( V :in out VECTOR );
      
      --| LES SIGNES SONT IGNORES : OPERATIONS SUR VALEURS ABSOLUES
        
    procedure V_ADD		( A :VECTOR; R :in out VECTOR );				-- |R| + |A| --> |R|
    procedure V_SUB		( A :VECTOR; R :in out VECTOR );				-- |R| - |A| --> |R| ; ASSUME |A| < |R|
    procedure V_MUL		( A,B :VECTOR; R :in out VECTOR );				-- |A| * |B| --> R
    procedure V_SCALE	( A :INTEGER; R :in out VECTOR );				-- A * R --> R ; ASSUME A > 0
    procedure V_DIV		( A :VECTOR; R, Q :in out VECTOR );				-- |R| / |A| --> Q REMAINDER |R| ASSUME A /= 0
    procedure V_REM		( A :VECTOR; R :in out VECTOR );				-- |R| / |A| --> ... REMAINDER |R| ; ASSUME A /= 0
    procedure V_GCD		( A,B :VECTOR; R :in out VECTOR );				-- GCD(|A|,|B|) --> R
    procedure V_LOWEST_TERMS	( A,B : in out VECTOR );					-- REDUCE |A|/|B| TO LOWEST TERMS, ASSUME B /= 0
    function  V_EQUAL	( A,B : VECTOR )			return BOOLEAN;		-- TEST |A| = |B|, |A| < |B|
    function  V_LESS	( A,B : VECTOR )			return BOOLEAN;
      
  --|-----------------------------------------------------------------------------------------------
  end UNIV_OPS;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		UARITH

  --|------------------------------------------------------------------------------------------------
  package UARITH is
      
    function  U_VAL		( A :INTEGER )			return TREE;
    function  U_VALUE	( TXT :STRING )			return TREE;
    function  U_POS		( A : TREE )			return INTEGER;
      
    function  U_EQUAL	( LEFT, RIGHT: TREE )		return TREE;
    function  U_NOT_EQUAL	( LEFT, RIGHT: TREE )		return TREE;
    function  "<"		( LEFT, RIGHT: TREE )		return TREE;
    function  "<="		( LEFT, RIGHT :TREE )		return TREE;
    function  ">"		( LEFT, RIGHT :TREE )		return TREE;
    function  ">="		( LEFT, RIGHT :TREE )		return TREE;
    function  U_MEMBER	( VALUE, DISCRETE_RANGE :TREE )	return TREE;
      
        -- FOLLOWING RETURN BOOLEAN (FOR COMPILER RANGE TESTS)
    function  "<="		( LEFT, RIGHT :TREE )		return BOOLEAN;
    function  ">="		( LEFT, RIGHT :TREE )		return BOOLEAN;
    function  U_EQUAL	( LEFT, RIGHT :TREE )		return BOOLEAN;
    function  U_MEMBER	( VALUE, DISCRETE_RANGE :TREE )	return BOOLEAN;
      
        -- FOLLOWING EXPECT 0 OR 1 AS ARGUMENT -- BOOLEAN OPERATORS
    function "AND"		( LEFT, RIGHT :TREE )		return TREE;
    function "OR"		( LEFT, RIGHT :TREE )		return TREE;
    function "XOR"		( LEFT, RIGHT :TREE )		return TREE;
    function "NOT"		( RIGHT :TREE )			return TREE;
      
        -- UNARY FUNCTIONS
    function "-"		( RIGHT :TREE )			return TREE;
    function "ABS"		( RIGHT :TREE )			return TREE;
      
        -- BINARY FUNCTIONS
    function "+"		( LEFT, RIGHT :TREE )	 	return TREE;
    function "-"		( LEFT, RIGHT :TREE )		return TREE;
    function "*"		( LEFT, RIGHT :TREE )		return TREE;		-- I*I, I*R, R*I, R*R
    function "/"		( LEFT, RIGHT :TREE )		return TREE;		-- I/I, R/I, R/R
    function "MOD"		( LEFT, RIGHT :TREE )		return TREE;
    function "REM"		( LEFT, RIGHT :TREE )		return TREE;
    function "**"		( LEFT, RIGHT :TREE )		return TREE;		-- I**I, R**I
      
  --|-----------------------------------------------------------------------------------------------
  end UARITH;
      
      
      
      
      
  --|------------------------------------------------------------------------------------------------

  --		FIX_WITH

  --|------------------------------------------------------------------------------------------------
  package FIX_WITH is
      
    USED_PACKAGE_LIST	: SEQ_TYPE;
      
    procedure FIX_WITH_CLAUSES	( COMPLTN_UNIT :TREE );
    function  IS_ANCESTOR		( UNIT_ID, SUBUNIT :TREE )	return BOOLEAN;
      
  --|------------------------------------------------------------------------------------------------
  end FIX_WITH;
      
      
      
      
      
  --|------------------------------------------------------------------------------------------------

  --		DEF_UTIL

  --|------------------------------------------------------------------------------------------------
  package DEF_UTIL is
      
    function  MAKE_DEF_FOR_ID			( ID :TREE; H :H_TYPE )		return TREE;
    procedure CHECK_UNIQUE_SOURCE_NAME_S	( SOURCE_NAME_S :TREE );
    procedure CHECK_CONSTANT_ID_S		( SOURCE_NAME_S :TREE; H :H_TYPE );
    function  GET_DEF_FOR_ID			( ID :TREE)			return TREE;
    function  GET_PRIOR_DEF			( DEF :TREE)			return TREE;
    function  GET_PRIOR_HOMOGRAPH_DEF		( DEF :TREE)			return TREE;
    function  GET_PRIOR_HOMOGRAPH_DEF		( DEF, PARAM_S :TREE;
					  RESULT_TYPE :TREE := TREE_VOID )	return TREE;
    function  GET_DEF_IN_REGION		( ID :TREE; H :H_TYPE )		return TREE;
    procedure CHECK_UNIQUE_DEF		( SOURCE_DEF : TREE);
    procedure CHECK_CONSTANT_DEF		( SOURCE_DEF :TREE; H :H_TYPE );
    procedure CHECK_TYPE_DEF			( SOURCE_DEF :TREE; H :H_TYPE );
    function  ARE_HOMOGRAPH_HEADERS		( HEADER_1, HEADER_2 :TREE )		return BOOLEAN;
    function  IS_SAME_PARAMETER_PROFILE		( PARAM_S_1, PARAM_S_2 :TREE )	return BOOLEAN;
    procedure CONFORM_PARAMETER_LISTS		( PARAM_S_1, PARAM_S_2 :TREE );
    function  IS_COMPATIBLE_EXPRESSION		( EXP_1, EXP_2 :TREE )		return BOOLEAN;
    procedure MAKE_DEF_VISIBLE		( DEF :TREE; HEADER :TREE := TREE_VOID );
    procedure MAKE_DEF_IN_ERROR		( DEF :TREE );
    procedure REMOVE_DEF_FROM_ENVIRONMENT	( DEF :TREE );
      
    function  GET_DEF_EXP_TYPE		( DEF :TREE )			return TREE;
    function  GET_BASE_TYPE			( TYPE_SPEC_OR_EXP_OR_ID :TREE )	return TREE;
    function  GET_BASE_PACKAGE		( PACKAGE_ID :TREE )		return TREE;
      
  --|------------------------------------------------------------------------------------------------
  end DEF_UTIL;
      
      
      
      
      
  --|------------------------------------------------------------------------------------------------

  --		SET_UTIL

  --|------------------------------------------------------------------------------------------------
  package SET_UTIL is
      
    type DEFSET_TYPE	is private;
    type TYPESET_TYPE	is private;
    type DEFINTERP_TYPE	is private;
    type TYPEINTERP_TYPE	is private;
    type EXTRAINFO_TYPE	is private;
      
    EMPTY_DEFSET		: constant DEFSET_TYPE;
    EMPTY_TYPESET		: constant TYPESET_TYPE;
    NULL_EXTRAINFO		: constant EXTRAINFO_TYPE;
      
    function  GET_DEF	( DEFINTERP :DEFINTERP_TYPE )		return TREE;
    function  IS_NULLARY	( DEFINTERP :DEFINTERP_TYPE )		return BOOLEAN;
    function  GET_EXTRAINFO	( DEFINTERP :DEFINTERP_TYPE )		return EXTRAINFO_TYPE;
    function  IS_EMPTY	( DEFSET :DEFSET_TYPE )		return BOOLEAN;
    function  HEAD		( DEFSET :DEFSET_TYPE )		return DEFINTERP_TYPE;
    procedure POP		( DEFSET :in out DEFSET_TYPE;
			  DEFINTERP :out DEFINTERP_TYPE );
    function  GET_TYPE	( TYPEINTERP :TYPEINTERP_TYPE ) 	return TREE;
    function  GET_EXTRAINFO	( TYPEINTERP :TYPEINTERP_TYPE )	return EXTRAINFO_TYPE;
    function  IS_EMPTY	( TYPESET :TYPESET_TYPE )		return BOOLEAN;
    function  HEAD		( TYPESET :TYPESET_TYPE )		return TYPEINTERP_TYPE;
    procedure POP		( TYPESET :in out TYPESET_TYPE;
			  TYPEINTERP :out TYPEINTERP_TYPE);
      
    procedure ADD_TO_DEFSET	( DEFSET :in out DEFSET_TYPE; DEFINTERP :DEFINTERP_TYPE );
    procedure ADD_TO_DEFSET	( DEFSET     :in out DEFSET_TYPE; DEF :TREE;
			  EXTRAINFO  :EXTRAINFO_TYPE := NULL_EXTRAINFO;
			  IS_NULLARY :BOOLEAN        := FALSE );
    procedure ADD_TO_TYPESET	( TYPESET :in out TYPESET_TYPE; TYPEINTERP :TYPEINTERP_TYPE );
    procedure ADD_TO_TYPESET	( TYPESET :in out TYPESET_TYPE; TYPE_SPEC :TREE; EXTRAINFO :EXTRAINFO_TYPE := NULL_EXTRAINFO );
      
    procedure REQUIRE_UNIQUE_DEF	( EXP :TREE; DEFSET :in out DEFSET_TYPE );
    procedure REQUIRE_UNIQUE_TYPE	( EXP :TREE; TYPESET :in out TYPESET_TYPE );
      
    function  GET_THE_ID		( DEFSET :DEFSET_TYPE )		return TREE;
    function  THE_ID_IS_NULLARY	( DEFSET :DEFSET_TYPE )		return BOOLEAN;
    function  GET_THE_TYPE		( TYPESET :TYPESET_TYPE )		return TREE;
      
    procedure REDUCE_OPERATOR_DEFS( EXP :TREE; DEFSET :in out DEFSET_TYPE );
      
    procedure ADD_EXTRAINFO	( DEFINTERP :in out DEFINTERP_TYPE; EXTRAINFO :EXTRAINFO_TYPE );
    procedure ADD_EXTRAINFO	( DEFINTERP :in out DEFINTERP_TYPE; EXTRAINFO_OF :TYPEINTERP_TYPE );
    procedure ADD_EXTRAINFO	( TYPEINTERP :in out TYPEINTERP_TYPE; EXTRAINFO :EXTRAINFO_TYPE );
    procedure ADD_EXTRAINFO	( TYPEINTERP :in out TYPEINTERP_TYPE; EXTRAINFO_OF :TYPEINTERP_TYPE );
    procedure ADD_EXTRAINFO	( EXTRAINFO :in out EXTRAINFO_TYPE; EXTRAINFO_IN :EXTRAINFO_TYPE );
      
    function  INSERT	( DEFSET :DEFSET_TYPE; DEFINTERP :DEFINTERP_TYPE )	return DEFSET_TYPE;
    function  INSERT	( TYPESET :TYPESET_TYPE; TYPEINTERP :TYPEINTERP_TYPE )	return TYPESET_TYPE;
     
    procedure STASH_DEFSET	( EXP :TREE; DEFSET :DEFSET_TYPE );
    function  FETCH_DEFSET	( EXP :TREE )			return DEFSET_TYPE;
    procedure STASH_TYPESET	( EXP :TREE; TYPESET :TYPESET_TYPE );
    function  FETCH_TYPESET	( EXP :TREE )			return TYPESET_TYPE;





  private
      
    type DEFSET_TYPE	is new SEQ_TYPE;
    type TYPESET_TYPE	is new SEQ_TYPE;
    type DEFINTERP_TYPE	is new TREE;
    type TYPEINTERP_TYPE	is new TREE;
    type EXTRAINFO_TYPE	is new SEQ_TYPE;
      
    EMPTY_DEFSET	: constant DEFSET_TYPE	:= (TREE_NIL,TREE_NIL);
    EMPTY_TYPESET	: constant TYPESET_TYPE	:= (TREE_NIL,TREE_NIL);
    NULL_EXTRAINFO	: constant EXTRAINFO_TYPE	:= (TREE_NIL,TREE_NIL);
      
  --|--------------------------------------------------------------------------------------------------
  end SET_UTIL;
      
      
      
      
      
  --|------------------------------------------------------------------------------------------------

  --		REQ_UTIL

  --|------------------------------------------------------------------------------------------------
  package REQ_UTIL is
       
    --|----------------------------------------------------------------------------------------------
    --|	REQ_GENE
    --|----------------------------------------------------------------------------------------------
    package REQ_GENE is
      use SET_UTIL;
         
      generic
        with function IS_XXX ( ITEM :TREE ) return BOOLEAN;
          MESSAGE :in STRING;
        procedure REQ_DEF_XXX		( EXP :TREE; DEFSET :in out DEFSET_TYPE );
         
        generic
          with function IS_XXX ( ITEM :TREE ) return BOOLEAN;
          MESSAGE: in STRING;
        procedure REQ_TYPE_XXX	( EXP :TREE; TYPESET :in out TYPESET_TYPE );
         
    --|----------------------------------------------------------------------------------------
    end REQ_GENE;
    use SET_UTIL, REQ_GENE;
      
    function  GET_BASE_STRUCT			( TYPE_SPEC :TREE )			return TREE;
    function  GET_ANCESTOR_TYPE		( TYPE_SPEC :TREE )			return TREE;
    procedure REQUIRE_SAME_TYPES		( EXP_1 :TREE; TYPESET_1 :TYPESET_TYPE;
					  EXP_2 :TREE; TYPESET_2 :TYPESET_TYPE;
					  TYPESET_OUT :out TYPESET_TYPE );
    procedure REQUIRE_TYPE			( TYPE_SPEC :TREE; EXP :TREE;
					  TYPESET :in out TYPESET_TYPE );
    function  IS_NONLIMITED_TYPE		( ITEM :TREE )			return BOOLEAN;
    function  IS_LIMITED_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_PRIVATE_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_INTEGER_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_BOOLEAN_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_REAL_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_SCALAR_TYPE			( ITEM :TREE )			return BOOLEAN;
    function  IS_MEMBER_OF_UNSPECIFIED		( SPEC_TYPE :TREE; UNSPEC_TYPE :TREE )	return BOOLEAN;
    function  IS_NONLIMITED_COMPOSITE_TYPE	( TYPE_SPEC :TREE )			return BOOLEAN;
    function  IS_STRING_TYPE			( TYPE_SPEC :TREE )			return BOOLEAN;
    function  IS_CHARACTER_TYPE		( TYPE_SPEC :TREE )			return BOOLEAN;
    function  IS_UNIVERSAL_TYPE		( ITEM :TREE )			return BOOLEAN;
    function  IS_NON_UNIVERSAL_TYPE		( ITEM :TREE )			return BOOLEAN;
    function  IS_DISCRETE_TYPE		( ITEM :TREE )			return BOOLEAN;
    function  IS_TASK_TYPE			( ITEM :TREE )			return BOOLEAN;
    procedure REQUIRE_ID			( ID_KIND :NODE_NAME; EXP :TREE;
					  DEFSET :in out DEFSET_TYPE );
    function  IS_TYPE_DEF			( ITEM :TREE )			return BOOLEAN;
    function  IS_ENTRY_DEF			( ITEM :TREE )			return BOOLEAN;
    function  IS_PROC_OR_ENTRY_DEF		( ITEM :TREE )			return BOOLEAN;
    function  IS_FUNCTION_OR_ARRAY_DEF		( ITEM :TREE )			return BOOLEAN;
    function  IS_FUNCTION_OR_ENUMERATION_DEF	( ITEM :TREE )			return BOOLEAN;
      
    procedure REQUIRE_NONLIMITED_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_INTEGER_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_BOOLEAN_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_REAL_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_SCALAR_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_UNIVERSAL_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_NON_UNIVERSAL_TYPE	( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_DISCRETE_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_TASK_TYPE		( EXP :TREE; TYPESET :in out TYPESET_TYPE );
    procedure REQUIRE_TYPE_DEF		( EXP :TREE; DEFSET :in out DEFSET_TYPE );
    procedure REQUIRE_ENTRY_DEF		( EXP :TREE; DEFSET :in out DEFSET_TYPE );
    procedure REQUIRE_PROC_OR_ENTRY_DEF		( EXP :TREE; DEFSET :in out DEFSET_TYPE );
    procedure REQUIRE_FUNCTION_OR_ARRAY_DEF	( EXP :TREE; DEFSET :in out DEFSET_TYPE );
    procedure REQUIRE_FUNCTION_OR_ENUMERATION_DEF	( EXP :TREE; DEFSET :in out DEFSET_TYPE );
      
  --|-------------------------------------------------------------------------------------------
  end REQ_UTIL;
  use REQ_UTIL, REQ_UTIL.REQ_GENE;
      
      
      
      

  --|------------------------------------------------------------------------------------------------

  --		AGGRESO

  --|------------------------------------------------------------------------------------------------
  package AGGRESO is
    use SET_UTIL, DEF_UTIL, REQ_UTIL;
      
    type AGGREGATE_ITEM_TYPE		is private;
      
    type AGGREGATE_ARRAY_TYPE		is array (POSITIVE range <>) of AGGREGATE_ITEM_TYPE;
      
    function  COUNT_AGGREGATE_CHOICES	( ASSOC_S :TREE )				return NATURAL;
    procedure SPREAD_ASSOC_S		( ASSOC_S :TREE; AGGREGATE_ARRAY :in out AGGREGATE_ARRAY_TYPE );
    procedure WALK_RECORD_DECL_S	( EXP :TREE; DECL_S :TREE; AGGREGATE_ARRAY :in out AGGREGATE_ARRAY_TYPE;
          			  NORMALIZED_LIST :in out SEQ_TYPE; LAST_POSITIONAL :in out NATURAL );
    procedure RESOLVE_RECORD_ASSOC_S	( ASSOC_S :TREE; AGGREGATE_ARRAY :in out AGGREGATE_ARRAY_TYPE );
    function  RESOLVE_EXP_OR_AGGREGATE	( EXP :TREE; SUBTYPE_SPEC :TREE; NAMED_OTHERS_OK :BOOLEAN )		return TREE;
    procedure RESOLVE_AGGREGATE	( EXP :TREE; TYPE_SPEC :TREE );
    procedure RESOLVE_STRING		( EXP :TREE; TYPE_SPEC :TREE );
      
  --|- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -





  private
      
    type AGGREGATE_ITEM_TYPE		is record
				  FIRST		: POSITIVE;			--| POSITION OF FIRST CHOICE IN CHOICE_S
				  CHOICE		: TREE;				--| FROM CHOICE_EXP
				  ID		: TREE;				--| DSCRMT OR COMPONENT ID
				  ASSOC		: TREE;				--| ONLY FOR FIRST CHOICE
				  EXP		: TREE;				--| ONLY FOR FIRST CHOICE
				  TYPESET		: TYPESET_TYPE;			--| ONLY FOR FIRST CHOICE
				  SEEN		: BOOLEAN;			--| USED TO MARK WHEN FORMAL SEEN FOR CHOICE
				  RESOLVED	: BOOLEAN;			--| USED TO MARK WHEN EXP RESOLVED FOR ASSOC
				end record;
      
  --|-----------------------------------------------------------------------------------------------
  end AGGRESO;
      
      
      
      
      
  --|------------------------------------------------------------------------------------------------

  --		EXPRESO

  --|------------------------------------------------------------------------------------------------
  package EXPRESO is
    use SET_UTIL;
      
    function  GET_NAME_DEFN			( NAME :TREE )			return TREE;
    function  GET_STATIC_VALUE		( EXP  :TREE )			return TREE;
    function  RESOLVE_EXP			( EXP  :TREE; TYPE_SPEC :TREE )	return TREE;
    function  RESOLVE_DISCRETE_RANGE		( EXP  :TREE; TYPE_SPEC :TREE )	return TREE;
    function  RESOLVE_TYPE_MARK		( EXP  :TREE)			return TREE;
    procedure RESOLVE_SUBTYPE_INDICATION	( EXP  :in out TREE;
					  SUBTYPE_SPEC :out TREE );
    function  RESOLVE_EXP			( EXP  :TREE; TYPESET :TYPESET_TYPE )	return TREE;
    function  RESOLVE_NAME			( NAME :TREE; DEFN :TREE )		return TREE;
    function  WALK_ERRONEOUS_EXP		( EXP  :TREE )			return TREE;
       
  --|------------------------------------------------------------------------------------------------
  end EXPRESO;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		VIS_UTIL

  --|------------------------------------------------------------------------------------------------
  package VIS_UTIL is
    use SET_UTIL;
      
    type PARAM_CURSOR_TYPE	is record
			  PARAM_LIST	: SEQ_TYPE;
			  PARAM		: TREE;
			  ID_LIST		: SEQ_TYPE;
			  ID		: TREE;
			end record;
      
        --- $$$$ TEMPORARY $$$$$$$$$$$$$$
    function IS_OVERLOADABLE_HEADER		( HEADER :TREE )			return BOOLEAN;
        -- $$$$$
      
    procedure FIND_VISIBILITY			( EXP :TREE; DEFSET :out DEFSET_TYPE );
    procedure FIND_DIRECT_VISIBILITY		( ID :TREE; DEFSET :out DEFSET_TYPE );
    procedure FIND_SELECTED_VISIBILITY		( SELECTED :TREE;
					  DEFSET :out DEFSET_TYPE );
      
    function  GET_ENCLOSING_DEF		( USED_NAME :TREE; DEFSET :DEFSET_TYPE )return TREE;
    function  MAKE_USED_NAME_ID_FROM_OBJECT	( USED_OBJECT_ID :TREE )		return TREE;
    function  MAKE_USED_OP_FROM_STRING		( STRING_NODE :TREE )		return TREE;
    function  EXPRESSION_TYPE_OF_DEF		( DEF :TREE )			return TREE;
    function  ALL_PARAMETERS_HAVE_DEFAULTS	( HEADER :TREE )			return BOOLEAN;
    function  CAST_TREE			( ARG :SEQ_TYPE )			return TREE;
    function  CAST_SEQ_TYPE			( ARG :TREE )			return SEQ_TYPE;
    function  COPY_NODE			( NODE : TREE )			return TREE;
    procedure INIT_PARAM_CURSOR		( CURSOR :out PARAM_CURSOR_TYPE;
					  PARAM_LIST :SEQ_TYPE );
    procedure ADVANCE_PARAM_CURSOR		( CURSOR :in out PARAM_CURSOR_TYPE );
      
  --|--------------------------------------------------------------------------------------------------
  end VIS_UTIL;





  --|------------------------------------------------------------------------------------------------

  --		DEF_WALK

  --|------------------------------------------------------------------------------------------------
  package DEF_WALK is
      
    function  EVAL_TYPE_DEF			( TYPE_DEF :TREE; ID :TREE; H :H_TYPE;
					  DSCRMT_DECL_S :TREE := TREE_VOID )	return TREE;
    function  GET_SUBTYPE_OF_DISCRETE_RANGE	( DISCRETE_RANGE :TREE )		return TREE;
      
  --|------------------------------------------------------------------------------------------------
  end DEF_WALK;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		NOD_WALK

  --|------------------------------------------------------------------------------------------------
  package NOD_WALK is
      
    type S_TYPE	is record
		  SB		: SB_TYPE;
		  SU		: SU_TYPE;
		end record;
      
    procedure WALK			( NODE :TREE; H :H_TYPE );
    procedure FINISH_PARAM_S		( DECL_S :TREE; H :H_TYPE );
    function  WALK_NAME		( ID_KIND :NODE_NAME; NAME :TREE )		return TREE;
    function  WALK_TYPE_MARK		( NAME :TREE )				return TREE;
    procedure WALK_DISCRETE_CHOICE_S	( CHOICE_S :TREE; TYPE_SPEC :TREE );
    procedure ENTER_REGION		( DEF :TREE; H :in out H_TYPE; S :out S_TYPE );
    procedure LEAVE_REGION		( DEF :TREE; S :S_TYPE );
    procedure ENTER_BODY		( DEF :TREE; H :in out H_TYPE; S :out S_TYPE );
    procedure LEAVE_BODY		( DEF :TREE; S :S_TYPE );
    procedure WALK_ITEM_S		( ITEM_S :TREE; H :H_TYPE );
    procedure WALK_SOURCE_NAME_S	( SOURCE_NAME_S :TREE; H :H_TYPE );
      
  --|------------------------------------------------------------------------------------------------
  end NOD_WALK;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		ATT_WALK

  --|------------------------------------------------------------------------------------------------
  package ATT_WALK is
    use SET_UTIL;
      
    procedure EVAL_ATTRIBUTE		( EXP :TREE; TYPESET :out TYPESET_TYPE;
				  IS_SUBTYPE :out BOOLEAN; IS_FUNCTION : BOOLEAN := FALSE );
    function  RESOLVE_ATTRIBUTE	( EXP :TREE )		return TREE;
    function  EVAL_ATTRIBUTE_IDENTIFIER	( ATTRIBUTE_NODE :TREE )	return TREE;
      
        --PROCEDURE WALK_ATTRIBUTE_FUNCTION(EXP: TREE);
      
  --|------------------------------------------------------------------------------------------------
  end ATT_WALK;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		STM_WALK

  --|------------------------------------------------------------------------------------------------
  package STM_WALK is
      
    procedure DECLARE_LABEL_BLOCK_LOOP_IDS	( STM_S :TREE; H :H_TYPE );
    procedure WALK_STM_S			( STM_S :TREE; H :H_TYPE );
    procedure WALK_ALTERNATIVE_S		( ALTERNATIVE_S :TREE; H :H_TYPE );
    function  WALK_STM			( STM_IN :TREE; H :H_TYPE )	return TREE;
      
  --|------------------------------------------------------------------------------------------------
  end STM_WALK;




   
  --|------------------------------------------------------------------------------------------------

  --		PRA_WALK

  --|------------------------------------------------------------------------------------------------
  package PRA_WALK is
       
    procedure WALK_PRAGMA	( USED_NAME_ID :TREE; GEN_ASSOC_S :TREE; H :H_TYPE );
          
  --|------------------------------------------------------------------------------------------------
  end PRA_WALK;





  --|------------------------------------------------------------------------------------------------

  --		CHK_STAT

  --|------------------------------------------------------------------------------------------------
  package CHK_STAT is
      
    function  IS_STATIC_RANGE			( A :TREE )		return BOOLEAN;
    function  IS_STATIC_SUBTYPE		( A :TREE )		return BOOLEAN;
    function  IS_STATIC_DISCRETE_RANGE		( A :TREE )		return BOOLEAN;
    function  IS_STATIC_INDEX_CONSTRAINT	( ARRAY_TYPE, INDEX_CONSTRAINT :TREE )	return BOOLEAN;
        -- FUNCTION IS_STATIC_DISCRIMINANT_CONSTRAINT ... (NOT USED)
        
  --|------------------------------------------------------------------------------------------------
  end CHK_STAT;





  --|------------------------------------------------------------------------------------------------

  --		DERIVED

  --|------------------------------------------------------------------------------------------------
  package DERIVED is
       
    function  MAKE_DERIVED_SUBPROGRAM_LIST	( DERIVED_SUBTYPE :TREE; PARENT_SUBTYPE :TREE;
					  H :H_TYPE )		return SEQ_TYPE;
    procedure REMEMBER_DERIVED_DECL		( DECL :TREE );
        -- (CALLED FROM FIXWITH -- REMEMBERS DERIVED DECL WITH DERIVED SUBP)
      
  --|------------------------------------------------------------------------------------------------
  end DERIVED;
   
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		EXP_TYPE

  --|------------------------------------------------------------------------------------------------
  package EXP_TYPE is
    use SET_UTIL;
      
    procedure EVAL_EXP_TYPES			( EXP :TREE; TYPESET :out TYPESET_TYPE );
    procedure EVAL_EXP_SUBTYPE_TYPES		( EXP :TREE; TYPESET :out TYPESET_TYPE;
					  IS_SUBTYPE_OUT :out BOOLEAN );
    function  EVAL_TYPE_MARK			( EXP :TREE )		return TREE;
    function  EVAL_SUBTYPE_INDICATION		( EXP :TREE )		return TREE;
    procedure EVAL_RANGE			( EXP :TREE; TYPESET :out TYPESET_TYPE );
    procedure EVAL_DISCRETE_RANGE		( EXP :TREE; TYPESET :out TYPESET_TYPE );
    procedure EVAL_NON_UNIVERSAL_DISCRETE_RANGE	( EXP :TREE; TYPESET :out TYPESET_TYPE );
      
  --|------------------------------------------------------------------------------------------------
  end EXP_TYPE;





  --|------------------------------------------------------------------------------------------------

  --		HOM_UNIT

  --|------------------------------------------------------------------------------------------------
  package HOM_UNIT is
      
    function WALK_HOMOGRAPH_UNIT	( UNIT_NAME :TREE; HEADER :TREE )	return TREE;
      
  --|-------------------------------------------------------------------------------------------
  end HOM_UNIT;





  --|------------------------------------------------------------------------------------------------

  --		INSTANT

  --|------------------------------------------------------------------------------------------------
  package INSTANT is
      
    procedure WALK_INSTANTIATION	( UNIT_ID :TREE; INSTANTIATION :TREE; H :H_TYPE );
          
  --|------------------------------------------------------------------------------------------------
  end INSTANT;





  --|------------------------------------------------------------------------------------------------

  --		MAKE_NOD

  --|------------------------------------------------------------------------------------------------
  package MAKE_NOD is
      
          function MAKE_VARIABLE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_RENAMES_OBJ: BOOLEAN := FALSE;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_IS_SHARED: BOOLEAN := FALSE;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTANT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_RENAMES_OBJ: BOOLEAN := FALSE;
                SM_ADDRESS: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NUMBER_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMPONENT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_COMP_REP: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DISCRIMINANT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_COMP_REP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IN_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IN_OUT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_OUT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_INIT_EXP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENUMERATION_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_POS: INTEGER := 0;
                SM_REP: INTEGER := 0;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CHARACTER_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                SM_POS: INTEGER := 0;
                SM_REP: INTEGER := 0;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ITERATION_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_OBJ_TYPE: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBTYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PRIVATE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_L_PRIVATE_TYPE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PROCEDURE_ID
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
                return TREE;
      
          function MAKE_FUNCTION_ID
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
                return TREE;
      
          function MAKE_OPERATOR_ID
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
                return TREE;
      
          function MAKE_PACKAGE_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_UNIT_DESC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID;
                XD_STUB: TREE := TREE_VOID;
                XD_BODY: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_GENERIC_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_GENERIC_PARAM_S: TREE := TREE_VOID;
                SM_BODY: TREE := TREE_VOID;
                SM_IS_INLINE: BOOLEAN := FALSE;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TASK_BODY_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_FIRST: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                SM_BODY: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_LABEL_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_BLOCK_LOOP_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENTRY_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_SPEC: TREE := TREE_VOID;
                SM_ADDRESS: TREE := TREE_VOID;
                XD_REGION: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_EXCEPTION_ID	( LX_SRCPOS, LX_SYMREP, SM_RENAMES_EXC, XD_REGION: TREE := TREE_VOID )	return TREE;
          function MAKE_ATTRIBUTE_ID	( LX_SRCPOS, LX_SYMREP: TREE := TREE_VOID; XD_POS: INTEGER )	return TREE;
          function MAKE_PRAGMA_ID	( LX_SRCPOS, LX_SYMREP, SM_ARGUMENT_ID_S :TREE := TREE_VOID; XD_POS :INTEGER )	return TREE;
          function MAKE_ARGUMENT_ID	( LX_SRCPOS, LX_SYMREP :TREE := TREE_VOID; XD_POS :INTEGER )	return TREE;
          function MAKE_BLTN_OPERATOR_ID( LX_SRCPOS, LX_SYMREP: TREE := TREE_VOID; SM_OPERATOR: INTEGER )	return TREE;
      
          function MAKE_BLOCK_MASTER
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DSCRMT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IN
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LX_DEFAULT: BOOLEAN := FALSE)
                return TREE;
      
          function MAKE_OUT
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IN_OUT
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTANT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_VARIABLE_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NUMBER_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_EXCEPTION_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DEFERRED_CONSTANT_DECL
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TYPE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DSCRMT_DECL_S: TREE := TREE_VOID;
                AS_TYPE_DEF: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBTYPE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TASK_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DECL_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_GENERIC_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_ITEM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBPROG_ENTRY_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_UNIT_KIND: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PACKAGE_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                AS_UNIT_KIND: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID )
                return TREE;
      
          function MAKE_RENAMES_OBJ_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                AS_TYPE_MARK_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RENAMES_EXC_DECL
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NULL_COMP_DECL
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_LENGTH_ENUM_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ADDRESS
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RECORD_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_ALIGNMENT_CLAUSE: TREE := TREE_VOID;
                AS_COMP_REP_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USE
                ( AS_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PRAGMA
                ( AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBPROGRAM_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                AS_HEADER: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PACKAGE_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TASK_BODY
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBUNIT
                ( AS_NAME: TREE := TREE_VOID;
                AS_SUBUNIT_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENUMERATION_DEF
                ( AS_ENUM_LITERAL_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBTYPE_INDICATION
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INTEGER_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FLOAT_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FIXED_DEF
                ( AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTRAINED_ARRAY_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                AS_CONSTRAINT: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_UNCONSTRAINED_ARRAY_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                AS_INDEX_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ACCESS_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DERIVED_DEF
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL) )
                return TREE;
      
          function MAKE_RECORD_DEF
                ( AS_COMP_LIST: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PRIVATE_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_L_PRIVATE_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FORMAL_DSCRT_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FORMAL_INTEGER_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FORMAL_FIXED_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FORMAL_FLOAT_DEF
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ALTERNATIVE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ARGUMENT_ID_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CHOICE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMP_REP_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMPLTN_UNIT_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONTEXT_ELEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DECL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DSCRMT_DECL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_GENERAL_ASSOC_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DISCRETE_RANGE_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENUM_LITERAL_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_EXP_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ITEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INDEX_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NAME_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PARAM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PRAGMA_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SCALAR_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SOURCE_NAME_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_STM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TEST_CLAUSE_ELEM_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USE_PRAGMA_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_VARIANT_S
                ( LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_LABELED
                ( AS_SOURCE_NAME_S: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                AS_STM: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NULL_STM
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ABORT
                ( AS_NAME_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RETURN
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DELAY
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ASSIGN
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_EXIT
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_STM: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CODE
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CASE
                ( AS_EXP: TREE := TREE_VOID;
                AS_ALTERNATIVE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_GOTO
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RAISE
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENTRY_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PROCEDURE_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ACCEPT
                ( AS_NAME: TREE := TREE_VOID;
                AS_PARAM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_LOOP
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_ITERATION: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_BLOCK
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_BLOCK_BODY: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COND_ENTRY
                ( AS_STM_S1: TREE := TREE_VOID;
                AS_STM_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TIMED_ENTRY
                ( AS_STM_S1: TREE := TREE_VOID;
                AS_STM_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IF
                ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SELECTIVE_WAIT
                ( AS_TEST_CLAUSE_ELEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TERMINATE
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_STM_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NAMED
                ( AS_EXP: TREE := TREE_VOID;
                AS_CHOICE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ASSOC
                ( AS_EXP: TREE := TREE_VOID;
                AS_USED_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USED_CHAR
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USED_OBJECT_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USED_OP
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_USED_NAME_ID
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_DEFN: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ATTRIBUTE
                ( AS_NAME: TREE := TREE_VOID;
                AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SELECTED
                ( AS_NAME: TREE := TREE_VOID;
                AS_DESIGNATOR: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FUNCTION_CALL
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                LX_PREFIX: BOOLEAN := FALSE;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID;
                SM_NORMALIZED_PARAM_S: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INDEXED
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SLICE
                ( AS_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ALL
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SHORT_CIRCUIT
                ( AS_EXP1: TREE := TREE_VOID;
                AS_SHORT_CIRCUIT_OP: TREE := TREE_VOID;
                AS_EXP2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NUMERIC_LITERAL
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_NUMREP: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NULL_ACCESS
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RANGE_MEMBERSHIP
                ( AS_EXP: TREE := TREE_VOID;
                AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TYPE_MEMBERSHIP
                ( AS_EXP: TREE := TREE_VOID;
                AS_MEMBERSHIP_OP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONVERSION
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_QUALIFIED
                ( AS_EXP: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PARENTHESIZED
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_VALUE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_AGGREGATE
                ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DISCRETE_RANGE: TREE := TREE_VOID;
                SM_NORMALIZED_COMP_S: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_STRING_LITERAL
                ( LX_SRCPOS: TREE := TREE_VOID;
                LX_SYMREP: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DISCRETE_RANGE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_QUALIFIED_ALLOCATOR
                ( AS_QUALIFIED: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SUBTYPE_ALLOCATOR
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_EXP_TYPE: TREE := TREE_VOID;
                SM_DESIG_TYPE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RANGE
                ( AS_EXP1: TREE := TREE_VOID;
                AS_EXP2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RANGE_ATTRIBUTE
                ( AS_NAME: TREE := TREE_VOID;
                AS_USED_NAME_ID: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DISCRETE_SUBTYPE
                ( AS_SUBTYPE_INDICATION: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FLOAT_CONSTRAINT
                ( AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FIXED_CONSTRAINT
                ( AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INDEX_CONSTRAINT
                ( AS_DISCRETE_RANGE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DSCRMT_CONSTRAINT
                ( AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CHOICE_EXP
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CHOICE_RANGE
                ( AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CHOICE_OTHERS
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PROCEDURE_SPEC
                ( AS_PARAM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FUNCTION_SPEC
                ( AS_PARAM_S: TREE := TREE_VOID;
                AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ENTRY
                ( AS_PARAM_S: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PACKAGE_SPEC
                ( AS_DECL_S1: TREE := TREE_VOID;
                AS_DECL_S2: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                XD_BODY_IS_REQUIRED: BOOLEAN := FALSE)
                return TREE;
      
          function MAKE_RENAMES_UNIT
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INSTANTIATION
                ( AS_NAME: TREE := TREE_VOID;
                AS_GENERAL_ASSOC_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_DECL_S: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NAME_DEFAULT
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_BOX_DEFAULT
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NO_DEFAULT
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_BLOCK_BODY
                ( AS_ITEM_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                AS_ALTERNATIVE_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_STUB
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IMPLICIT_NOT_EQ
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_EQUAL: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_DERIVED_SUBPROG
                ( LX_SRCPOS: TREE := TREE_VOID;
                SM_DERIVABLE: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COND_CLAUSE
                ( AS_EXP: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SELECT_ALTERNATIVE
                ( AS_EXP: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_SELECT_ALT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_IN_OP
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_NOT_IN
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_AND_THEN
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_OR_ELSE
                ( LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_FOR
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_REVERSE
                ( AS_SOURCE_NAME: TREE := TREE_VOID;
                AS_DISCRETE_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_WHILE
                ( AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ALTERNATIVE
                ( AS_CHOICE_S: TREE := TREE_VOID;
                AS_STM_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ALTERNATIVE_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMP_REP
                ( AS_NAME: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                AS_RANGE: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMP_REP_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONTEXT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_WITH
                ( AS_NAME_S: TREE := TREE_VOID;
                AS_USE_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_VARIANT
                ( AS_CHOICE_S: TREE := TREE_VOID;
                AS_COMP_LIST: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_VARIANT_PRAGMA
                ( AS_PRAGMA: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ALIGNMENT
                ( AS_PRAGMA_S: TREE := TREE_VOID;
                AS_EXP: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_VARIANT_PART
                ( AS_NAME: TREE := TREE_VOID;
                AS_VARIANT_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMP_LIST
                ( AS_DECL_S: TREE := TREE_VOID;
                AS_VARIANT_PART: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMPILATION
                ( AS_COMPLTN_UNIT_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_COMPILATION_UNIT
                ( AS_CONTEXT_ELEM_S: TREE := TREE_VOID;
                AS_ALL_DECL: TREE := TREE_VOID;
                AS_PRAGMA_S: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                XD_TIMESTAMP: INTEGER := 0;
                LIST: SEQ_TYPE := (TREE_NIL,TREE_NIL);
                XD_NBR_PAGES: INTEGER := 0;
                XD_LIB_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INDEX
                ( AS_NAME: TREE := TREE_VOID;
                LX_SRCPOS: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_TASK_SPEC
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
                return TREE;
      
          function MAKE_ENUMERATION
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_LITERAL_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0)
                return TREE;
      
          function MAKE_INTEGER (	SM_DERIVED, SM_BASE_TYPE, SM_RANGE, XD_SOURCE_NAME :TREE := TREE_VOID;
          		CD_IMPL_SIZE: INTEGER := 0; SM_IS_ANONYMOUS :BOOLEAN := FALSE
                	) return TREE;
      
          function MAKE_FLOAT
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_ACCURACY: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0)
                return TREE;
      
          function MAKE_FIXED
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_RANGE: TREE := TREE_VOID;
                SM_ACCURACY: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                CD_IMPL_SIZE: INTEGER := 0;
                CD_IMPL_SMALL: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_ARRAY
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_IS_LIMITED: BOOLEAN := FALSE;
                SM_IS_PACKED: BOOLEAN := FALSE;
                SM_INDEX_S: TREE := TREE_VOID;
                SM_COMP_TYPE: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_RECORD
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
                return TREE;
      
          function MAKE_ACCESS
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_SIZE: TREE := TREE_VOID;
                SM_STORAGE_SIZE: TREE := TREE_VOID;
                SM_IS_CONTROLLED: BOOLEAN := FALSE;
                SM_DESIG_TYPE: TREE := TREE_VOID;
                SM_MASTER: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTRAINED_ARRAY
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_INDEX_SUBTYPE_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTRAINED_RECORD
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_NORMALIZED_DSCRMT_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_CONSTRAINED_ACCESS
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_BASE_TYPE: TREE := TREE_VOID;
                SM_DEPENDS_ON_DSCRMT: BOOLEAN := FALSE;
                SM_DESIG_TYPE: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_PRIVATE
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_DISCRIMINANT_S: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_L_PRIVATE
                ( SM_DERIVED: TREE := TREE_VOID;
                SM_IS_ANONYMOUS: BOOLEAN := FALSE;
                SM_DISCRIMINANT_S: TREE := TREE_VOID;
                SM_TYPE_SPEC: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_INCOMPLETE
                ( SM_DISCRIMINANT_S: TREE := TREE_VOID;
                XD_SOURCE_NAME: TREE := TREE_VOID;
                XD_FULL_TYPE_SPEC: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_UNIVERSAL_INTEGER
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_UNIVERSAL_FIXED
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
          function MAKE_UNIVERSAL_REAL
                ( XD_SOURCE_NAME: TREE := TREE_VOID)
                return TREE;
      
  --|------------------------------------------------------------------------------------------------
  end MAKE_NOD;





  --|------------------------------------------------------------------------------------------------

  --		GEN_SUBS

  --|------------------------------------------------------------------------------------------------
  package GEN_SUBS is
      
    NODE_HASH_SIZE		: constant	:= 131;
    type NODE_ARRAY_TYPE	is array( 0 .. INTEGER( NODE_HASH_SIZE - 1 ) ) of TREE;
    type NODE_HASH_TYPE	is record
			  LIMIT	: NATURAL		:= 32000;
			  A	: NODE_ARRAY_TYPE	:= (others => TREE_VOID);
			end record;
      
    procedure SUBSTITUTE		( NODE :in out TREE; NODE_HASH :in out NODE_HASH_TYPE;
				  H_IN :H_TYPE );
    procedure REPLACE_NODE		( NODE :in out TREE; NODE_HASH :in out NODE_HASH_TYPE );
    procedure SUBSTITUTE_ATTRIBUTES	( NODE :in out TREE; NODE_HASH :in out NODE_HASH_TYPE;
				  H_IN :H_TYPE );
    procedure INSERT_NODE_HASH	( NODE_HASH :in out NODE_HASH_TYPE; NEW_NODE :TREE;
				  OLD_NODE :TREE );
      
  --|------------------------------------------------------------------------------------------------
  end GEN_SUBS;





  --|------------------------------------------------------------------------------------------------

  --		NEWSNAM

  --|------------------------------------------------------------------------------------------------
  package NEWSNAM is
    use GEN_SUBS;
      
    procedure REPLACE_SOURCE_NAME	( SOURCE_NAME :in out TREE; NODE_HASH :in out NODE_HASH_TYPE;
				  H_IN :H_TYPE; DECL :TREE := TREE_VOID );
          
  --|------------------------------------------------------------------------------------------------
  end NEWSNAM;





  --|------------------------------------------------------------------------------------------------

  --		PRE_FCNS

  --|------------------------------------------------------------------------------------------------
  package PRE_FCNS is
      
    procedure GEN_PREDEFINED_OPERATORS	( TYPE_SPEC :TREE; H_IN :H_TYPE );
       
  --|------------------------------------------------------------------------------------------------
  end PRE_FCNS;





  --|------------------------------------------------------------------------------------------------

  --		PRENAME

  --|------------------------------------------------------------------------------------------------
  package PRENAME is
      
    type DEFINED_PRAGMAS	is (
			CONTROLLED,	ELABORATE,	INLINE,	INTERFACE,
			LIST,		MEMORY_SIZE,	OPTIMIZE,	PACK,
			PAGE,		PRIORITY,	SHARED,	STORAGE_UNIT,
			SUPPRESS,		SYSTEM_NAME,
			DEBUG							--| PRAGMA DEBUG ( ON|OFF ) -- ENABLES/DISABLES TRACE IN COMPILER
			);
      
    type LIST_ARGUMENTS	is ( OFF, ON );
      
    type OPTIMIZE_ARGUMENTS	is ( TIME, SPACE );
      
    type SUPPRESS_ARGUMENTS	is (
			ON,
			ACCESS_CHECK,	INDEX_CHECK,	DISCRIMINANT_CHECK,
			LENGTH_CHECK,	RANGE_CHECK,	ELABORATION_CHECK,
			DIVISION_CHECK,	OVERFLOW_CHECK,	STORAGE_CHECK
			);
      
    type INTERFACE_ARGUMENTS	is ( ADA, ASM );
      
    type DEFINED_ATTRIBUTES	is (
			ADDRESS,		AFT,		BASE,
			CALLABLE,		CONSTRAINED,	COUNT,
			DELTA_X,		DIGITS_X,		EMAX,
			EPSILON,		FIRST,		FIRST_BIT,
			FORE,		IMAGE,		LARGE,
			LAST,		LAST_BIT,		LENGTH,
			MACHINE_EMAX,	MACHINE_EMIN,
			MACHINE_MANTISSA,	MACHINE_OVERFLOWS,
			MACHINE_RADIX, 	MACHINE_ROUNDS,
			MANTISSA,		POS,		POSITION,
			PRED,		RANGE_X,		SAFE_EMAX,
			SAFE_LARGE,	SAFE_SMALL,	SIZE,
			SMALL, 		STORAGE_SIZE,	SUCC,
			TERMINATED,	VAL,		VALUE,
			WIDTH
			);
      
    type OP_CLASS		is (
			OP_AND,		OP_OR,		OP_XOR,	OP_NOT,
			OP_UNARY_PLUS,	OP_UNARY_MINUS,	OP_ABS,	OP_EQ,
			OP_NE,		OP_LT,		OP_LE,	OP_GT,
			OP_GE,		OP_PLUS,		OP_MINUS,	OP_MULT,
			OP_DIV,		OP_MOD,		OP_REM,	OP_CAT,
			OP_EXP
			);
      
    subtype CLASS_BOOLEAN_OP		is OP_CLASS range OP_AND .. OP_XOR;
    subtype CLASS_EQUALITY_OP		is OP_CLASS range OP_EQ  .. OP_NE;
    subtype CLASS_RELATIONAL_OP	is OP_CLASS range OP_LT  .. OP_GE;
    subtype CLASS_EQ_RELATIONAL_OP	is OP_CLASS range OP_EQ  .. OP_GE;
      
    subtype CLASS_UNARY_OP		is OP_CLASS range OP_NOT        .. OP_ABS;
    subtype CLASS_UNARY_NUMERIC_OP	is OP_CLASS range OP_UNARY_PLUS .. OP_ABS;
    subtype CLASS_FIXED_OP		is OP_CLASS range OP_PLUS       .. OP_MINUS;
    subtype CLASS_FLOAT_OP		is OP_CLASS range OP_PLUS       .. OP_DIV;
    subtype CLASS_INTEGER_OP		is OP_CLASS range OP_PLUS       .. OP_REM;
      
    subtype STRING_3	is STRING(1..3);
      
    BLTN_TEXT_ARRAY	: constant array (OP_CLASS) of STRING_3 := (
	OP_AND => "AND",	OP_OR => "OR!",	OP_XOR => "XOR",	OP_EQ => "=!!",
	OP_NE => "/=!",	OP_LT => "<!!",	OP_LE => "<=!",	OP_GT => ">!!",
	OP_GE => ">=!",	OP_PLUS => "+!!",	OP_MINUS => "-!!",	OP_CAT => "&!!",
	OP_UNARY_PLUS => "+!!",	OP_UNARY_MINUS => "-!!",
	OP_ABS => "ABS",	OP_NOT => "NOT",	OP_MULT => "*!!",	OP_DIV => "/!!",
	OP_MOD => "MOD",	OP_REM => "REM",	OP_EXP => "**!"
	);
      
    BLTN_ID_ARRAY	: array (OP_CLASS) of TREE	:= (others => TREE_VOID);

  --|-----------------------------------------------------------------------------------------------
  end PRENAME;
   
   
   
   
  --|------------------------------------------------------------------------------------------------

  --		RED_SUBP

  --|------------------------------------------------------------------------------------------------
  package RED_SUBP is
    use SET_UTIL;

    procedure EVAL_SUBP_CALL			( EXP :TREE; TYPESET :out TYPESET_TYPE );
    function  RESOLVE_FUNCTION_CALL		( EXP :TREE; TYPE_SPEC :TREE )	return TREE;
    procedure REDUCE_APPLY_NAMES		( NAME :TREE; NAME_DEFSET :in out DEFSET_TYPE;
					  GEN_ASSOC_S :TREE; INDEX :TREE := TREE_VOID );
    function  RESOLVE_SUBP_PARAMETERS		( DEF :TREE; GEN_ASSOC_S :TREE )	return TREE;
    procedure RESOLVE_ERRONEOUS_PARAM_S		( GENERAL_ASSOC_S :TREE);
    procedure CHECK_ACTUAL_TYPE		( FORMAL_TYPE :TREE; ACTUAL_TYPESET :TYPESET_TYPE;
					  ACTUALS_OK :out BOOLEAN;
					  EXTRAINFO :out EXTRAINFO_TYPE );
    function  GET_TYPE_OF_DISCRETE_RANGE	( DISCRETE_RANGE :TREE )		return TREE;
      
  --|------------------------------------------------------------------------------------------------
  end RED_SUBP;





  --|------------------------------------------------------------------------------------------------

  --		REP_CLAU

  --|------------------------------------------------------------------------------------------------
  package REP_CLAU is
      
    procedure RESOLVE_LENGTH_REP	( ATTRIBUTE :TREE; EXP :in out TREE; H :H_TYPE );
    procedure RESOLVE_ENUM_REP	( SIMPLE_NAME :in out TREE; EXP :TREE; H :H_TYPE );
    procedure RESOLVE_ADDRESS_REP	( SIMPLE_NAME :in out TREE; EXP :in out TREE; H :H_TYPE );
    procedure RESOLVE_RECORD_REP	( SIMPLE_NAME :in out TREE; ALIGNMENT :TREE;
				  COMP_REP_S :TREE; H :H_TYPE );
      
  --|------------------------------------------------------------------------------------------------
  end REP_CLAU;





  USED_PACKAGE_LIST	: SEQ_TYPE	renames FIX_WITH.USED_PACKAGE_LIST;
         
         
  package body SEM_GLOB	is separate;
  package body UNIV_OPS	is separate;
  function  EVAL_NUM	( TXT :STRING )	return TREE	is separate;
  package body UARITH	is separate;
  package body FIX_WITH	is separate;
  package body DEF_UTIL	is separate;
  package body SET_UTIL	is separate;
  package body REQ_UTIL	is separate;
  package body AGGRESO	is separate;
  package body EXPRESO	is separate;
  package body VIS_UTIL	is separate;
  package body DEF_WALK	is separate;
  package body NOD_WALK	is separate;
  package body ATT_WALK	is separate;
  package body STM_WALK	is separate;
  package body PRA_WALK	is separate;
  package body CHK_STAT	is separate;
  package body DERIVED	is separate;
  package body EXP_TYPE	is separate;
  package body HOM_UNIT	is separate;
  package body INSTANT	is separate;
  package body MAKE_NOD	is separate;
  package body GEN_SUBS	is separate;
  package body NEWSNAM	is separate;
  package body PRE_FCNS	is separate;
  package body RED_SUBP	is separate;
  package body REP_CLAU	is separate;
   
       
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE INITIALIZE_PRAGMA_ATTRIBUTE_DEFS
  procedure INITIALIZE_PRAGMA_ATTRIBUTE_DEFS is
    STD_PACK_SYM		: TREE		:= STORE_SYM( "_STANDRD.DCL" );
    STD_PACK_ID		: TREE		:= HEAD( LIST( STD_PACK_SYM ) );
    ALL_DECL		: TREE		:= D( AS_ALL_DECL, STD_PACK_ID );
    STD_PACK_HEADER		: TREE		:= D( AS_HEADER, ALL_DECL );
    DECL_PRIV		: TREE		:= D( AS_DECL_S2, STD_PACK_HEADER );
    ID_LIST		: SEQ_TYPE	:= LIST( DECL_PRIV );			--| LA LISTE DES DECLARATIONS PRIVEES DE _STANDRD
    ID			: TREE;
    DEF			: TREE;
  begin
    while not IS_EMPTY( ID_LIST ) loop							--| TANT QU'IL Y A DES ELEMENTS PRIVES
      POP( ID_LIST, ID );								--| EN EXTRAIRE UN
      if ID.TY in DN_ATTRIBUTE_ID .. DN_PRAGMA_ID						--| SI C'EST UN ID D'ATTRIBUT OU DE PRAGMA
         and then D( LX_SYMREP, ID ).TY = DN_SYMBOL_REP					--| ET QU'IL Y A BIEN UN SYMBOLE ASSOCIE (PAR LIB_PHASE SI L'ID EST UTILISE DANS LA COMPILATION)
      then
        DEF := DEF_UTIL.MAKE_DEF_FOR_ID( ID, INITIAL_H );
        D ( XD_REGION_DEF, DEF, TREE_VOID );
        DB( XD_IS_IN_SPEC, DEF, FALSE );
      end if;
    end loop;
  end INITIALIZE_PRAGMA_ATTRIBUTE_DEFS;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE COMPILE_COMPILATION_UNIT
  procedure COMPILE_COMPILATION_UNIT ( COMPILATION_UNIT :TREE; H :H_TYPE ) is
    CONTEXT_ELEM_S		: constant TREE	:= D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT );
    ALL_DECL		: constant TREE	:= D( AS_ALL_DECL, COMPILATION_UNIT );
    PRAGMA_S		: constant TREE	:= D( AS_PRAGMA_S, COMPILATION_UNIT );
    WITH_LIST		: constant SEQ_TYPE	:= LIST( COMPILATION_UNIT );
      
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE PROCESS_WITH_NAME_S
    procedure PROCESS_WITH_NAME_S ( NAME_S :TREE ) is					--| TRAITE LES CLAUSES WITH DANS LES CLAUSES DE CONTEXTE, SM_DEFN MISES DANS LIB_PHASE
      NAME_LIST		: SEQ_TYPE	:= LIST( NAME_S );
      NAME		: TREE;
      NEW_NAME_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
      NEW_NAME		: TREE;
      NAME_DEFN		: TREE;
      NAME_DEF		: TREE;
    begin
         
      while not IS_EMPTY( NAME_LIST ) loop
        POP( NAME_LIST, NAME );
        NAME_DEFN := D( SM_DEFN, NAME );						--| CHERCHER LA DEFINITION CORRESPONDANTE
        NAME_DEF := DEF_UTIL.GET_DEF_FOR_ID( NAME_DEFN );
        D( XD_REGION_DEF, NAME_DEF, DEF_UTIL.GET_DEF_FOR_ID( D( XD_REGION, NAME_DEFN) ) );	--| L'INDIQUER "WITH"EE
        NEW_NAME := VIS_UTIL.MAKE_USED_NAME_ID_FROM_OBJECT( NAME );				--| REMPLACER LES USED_OBJECT_ID AVEC DES USED_NAME_ID
        NEW_NAME_LIST := APPEND( NEW_NAME_LIST, NEW_NAME );
      end loop;
         
      LIST( NAME_S, NEW_NAME_LIST );							--| SAUVER LA NOUVELLE LISTE DE USED_NAME_ID'S
    end PROCESS_WITH_NAME_S;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE PROCESS_WITH_USE_PRAGMA_S
    procedure PROCESS_WITH_USE_PRAGMA_S ( USE_PRAGMA_S :TREE ) is				--| MODIFIE LES DEFS POUR LES CLAUSES USE DANS LES CLAUSES DE CONTEXTE
      USE_PRAGMA_LIST	: SEQ_TYPE	:= LIST( USE_PRAGMA_S );
      USE_PRAGMA		: TREE;
      NAME_LIST		: SEQ_TYPE;
      NAME		: TREE;
      NEW_NAME_LIST		: SEQ_TYPE;
      NEW_NAME		: TREE;
      NAME_DEFN		: TREE;
      NAME_DEF		: TREE;
    begin
      while not IS_EMPTY( USE_PRAGMA_LIST ) loop						--| POUR CHAQUE CLAUSE USE OU PRAGMA
        POP( USE_PRAGMA_LIST, USE_PRAGMA );
            
        if USE_PRAGMA.TY = DN_PRAGMA then
          NOD_WALK.WALK( USE_PRAGMA, INITIAL_H );
               
        else									--| POUR CHAQUE NOM DANS LA CLAUSE USE
          NAME_LIST := LIST( D( AS_NAME_S, USE_PRAGMA ) );
          NEW_NAME_LIST := (TREE_NIL,TREE_NIL);
          while not IS_EMPTY( NAME_LIST) loop
            POP( NAME_LIST, NAME );
            NAME_DEFN := D( SM_DEFN, NAME );
            NAME_DEF := DEF_UTIL.GET_DEF_FOR_ID( NAME_DEFN );
            DB( XD_IS_USED, NAME_DEF, TRUE );						--| L'INDIQUER UTILISEE
            NEW_NAME := VIS_UTIL.MAKE_USED_NAME_ID_FROM_OBJECT( NAME );			--| REMPLACER USED_OBJECT_ID PAR USED_NAME_ID
            NEW_NAME_LIST := APPEND( NEW_NAME_LIST, NEW_NAME );
          end loop;
               
          LIST( D( AS_NAME_S, USE_PRAGMA), NEW_NAME_LIST );					--| SAUVER LA NOUVELLE LISTE DE USED_NAME_ID'S 
        end if;
              
      end loop;
    end PROCESS_WITH_USE_PRAGMA_S;
    --|---------------------------------------------------------------------------------------------
    --|	   PROCEDURE PROCESS_CONTEXT_CLAUSES
    procedure PROCESS_CONTEXT_CLAUSES ( COMPILATION_UNIT :TREE ) is
      CONTEXT_ELEM_S	: constant TREE	:= D( AS_CONTEXT_ELEM_S, COMPILATION_UNIT );
      CONTEXT_ELEM_LIST	: SEQ_TYPE	:= LIST( CONTEXT_ELEM_S );
      CONTEXT_ELEM		: TREE;
      TRANS_WITH_LIST	: SEQ_TYPE	:= LIST( COMPILATION_UNIT );
      TRANS_WITH		: TREE;
      --|-------------------------------------------------------------------------------------------
      --|	      PROCEDURE PROCESS_ANCESTOR_CONTEXT
      procedure PROCESS_ANCESTOR_CONTEXT ( ANCESTOR_UNIT, COMPILATION_UNIT :TREE ) is
      --|-------------------------------------------------------------------------------------------
      --|	         PROCEDURE IS_ANCESTOR
        function IS_ANCESTOR ( ANC_ALL_DECL, COMP_ALL_DECL :TREE ) return BOOLEAN is
        begin
          if COMP_ALL_DECL.TY in CLASS_SUBUNIT_BODY then
            return (    ANC_ALL_DECL.TY in CLASS_UNIT_DECL
                        and then D( SM_FIRST, D( AS_SOURCE_NAME, COMP_ALL_DECL ) ) = D ( AS_SOURCE_NAME, ANC_ALL_DECL)
                        );
          elsif COMP_ALL_DECL.TY = DN_SUBUNIT then
            declare
              COMP_NAME	: TREE	:= D( AS_NAME, COMP_ALL_DECL );
              ANC_ID	: TREE	:= TREE_VOID;
            begin
              if ANC_ALL_DECL.TY = DN_SUBUNIT then
                ANC_ID := D( SM_FIRST, D(  AS_SOURCE_NAME, D( AS_SUBUNIT_BODY, ANC_ALL_DECL ) ) );
                return FIX_WITH.IS_ANCESTOR( ANC_ID, COMP_ALL_DECL );
              elsif ANC_ALL_DECL /= TREE_VOID then
                ANC_ID := D( SM_FIRST, D(  AS_SOURCE_NAME, ANC_ALL_DECL ) );
                while COMP_NAME.TY = DN_SELECTED loop
                  COMP_NAME := D( AS_NAME, COMP_NAME );
                end loop;
                return D( LX_SYMREP, ANC_ID ) = D( LX_SYMREP, COMP_NAME );
              end if;
            end;
          end if;
          return FALSE;
        end IS_ANCESTOR;
        --|----------------------------------------------------------------------------------------
        --|	          PROCEDURE REPROCESS_CONTEXT
        procedure REPROCESS_CONTEXT ( CONTEXT_ELEM_S :TREE ) is
              -- GIVEN CONTEXT_ELEM_S FOR AN ANCESTOR UNIT,
                -- ... REPROCESS WITH'S AND USE'S IN FOR USE IN CURRENT UNIT
          CONTEXT_ELEM_LIST	: SEQ_TYPE	:= LIST( CONTEXT_ELEM_S );
          CONTEXT_ELEM	: TREE;
          USE_PRAGMA_LIST	: SEQ_TYPE;
          USE_PRAGMA	: TREE;
          ITEM_LIST		: SEQ_TYPE;
          ITEM		: TREE;
        begin
          while not IS_EMPTY( CONTEXT_ELEM_LIST ) loop
            POP( CONTEXT_ELEM_LIST, CONTEXT_ELEM);
            if CONTEXT_ELEM.TY = DN_WITH then
              ITEM_LIST := LIST( D( AS_NAME_S, CONTEXT_ELEM ) );
              while not IS_EMPTY( ITEM_LIST) loop
                POP( ITEM_LIST, ITEM);
                if D( SM_DEFN, ITEM ) /= TREE_VOID then
                  D( XD_REGION_DEF, DEF_UTIL.GET_DEF_FOR_ID( D( SM_DEFN,ITEM ) ), PREDEFINED_STANDARD_DEF );
                end if;
              end loop;
              USE_PRAGMA_LIST := LIST( D( AS_USE_PRAGMA_S, CONTEXT_ELEM ) );
              while not IS_EMPTY( USE_PRAGMA_LIST) loop
                POP( USE_PRAGMA_LIST, USE_PRAGMA);
                if USE_PRAGMA.TY = DN_USE then
                  ITEM_LIST := LIST( D( AS_NAME_S, USE_PRAGMA ) );
                  while not IS_EMPTY( ITEM_LIST ) loop
                    POP( ITEM_LIST, ITEM );
                    if D( SM_DEFN, ITEM ) /= TREE_VOID then
                      DB( XD_IS_USED, DEF_UTIL.GET_DEF_FOR_ID( D( SM_DEFN, ITEM ) ), TRUE );
                    end if;
                  end loop;
                end if;
              end loop;
            end if;
          end loop;
        end REPROCESS_CONTEXT;
            
      begin
        if IS_ANCESTOR( D( AS_ALL_DECL, ANCESTOR_UNIT ), D( AS_ALL_DECL, COMPILATION_UNIT ) ) then
          REPROCESS_CONTEXT( D( AS_CONTEXT_ELEM_S, ANCESTOR_UNIT ) );
        end if;
      end PROCESS_ANCESTOR_CONTEXT;

    begin
                -- FOR EACH CONTEXT_ELEM
      while not IS_EMPTY( CONTEXT_ELEM_LIST ) loop
        POP( CONTEXT_ELEM_LIST, CONTEXT_ELEM );
            
        if CONTEXT_ELEM.TY = DN_WITH then
          PROCESS_WITH_NAME_S( D( AS_NAME_S, CONTEXT_ELEM ) );
          PROCESS_WITH_USE_PRAGMA_S( D( AS_USE_PRAGMA_S, CONTEXT_ELEM ) );
               
        else
          PUT_LINE( "!! $$$$ CONTEXT PRAGMA." );
          raise PROGRAM_ERROR;
        end if;
      end loop;
         
      while not IS_EMPTY( TRANS_WITH_LIST ) loop						--| CLAUSES ANCÊTRES
        POP( TRANS_WITH_LIST, TRANS_WITH);
        PROCESS_ANCESTOR_CONTEXT( D( TW_COMP_UNIT, TRANS_WITH ), COMPILATION_UNIT );
      end loop;
         
    end PROCESS_CONTEXT_CLAUSES;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE ENTER_ANCESTOR_REGION
    procedure ENTER_ANCESTOR_REGION ( NAME :TREE; H :in out H_TYPE ) is
      S			: NOD_WALK.S_TYPE;
      DESIGNATOR		: TREE;
      DEFN		: TREE;
      DES_DEF		: TREE;
      DEFLIST		: SEQ_TYPE;
      DEF			: TREE;
    begin
      if NAME.TY = DN_SELECTED then
        ENTER_ANCESTOR_REGION( D( AS_NAME, NAME ), H );
        DESIGNATOR := D( AS_DESIGNATOR, NAME );
      else
        DESIGNATOR := NAME;
      end if;
      D( SM_DEFN, DESIGNATOR, TREE_VOID );
      DEFLIST := LIST( D( LX_SYMREP, DESIGNATOR ) );
      while not IS_EMPTY( DEFLIST) loop
        POP( DEFLIST, DEF);
        if D( XD_REGION, D( XD_SOURCE_NAME, DEF ) ) = D( XD_SOURCE_NAME, H.REGION_DEF ) then
          DEFN := D( XD_SOURCE_NAME, DEF);
          if DEFN.TY = DN_TYPE_ID or else DEFN.TY in CLASS_UNIT_NAME then
            DEFN := D( SM_FIRST, DEFN );
          end if;
          D( SM_DEFN, DESIGNATOR, DEFN );
          exit;
        end if;
      end loop;
      DEFN := D( SM_DEFN, DESIGNATOR );
      if DEFN = TREE_VOID then
        PUT_LINE( "!! DEFN NOT FOUND FOR ANCESTOR" );
        raise PROGRAM_ERROR;
      end if;
      DES_DEF := DEF_UTIL.GET_DEF_FOR_ID( DEFN );
      D( XD_REGION_DEF, DES_DEF, H.REGION_DEF );
      NOD_WALK.ENTER_BODY( DES_DEF, H, S );
    end ENTER_ANCESTOR_REGION;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE WALK_ITEM
    procedure WALK_ITEM ( ITEM :TREE; H_IN :H_TYPE ) is
      H	: H_TYPE	:= H_IN;
    begin
      NOD_WALK.WALK( ITEM, H );
    end WALK_ITEM;
    --|---------------------------------------------------------------------------------------------
      
  begin
    if ALL_DECL.TY = DN_VOID then
      ERROR( D( LX_SRCPOS, COMPILATION_UNIT ), "$$$ EMPTY UNIT NOT IMPLEMENTED YET" );
      return;
    end if;
      
    USED_PACKAGE_LIST := (TREE_NIL, TREE_NIL);
    FIX_WITH.FIX_WITH_CLAUSES( COMPILATION_UNIT );
    INITIALIZE_PREDEFINED_TYPES;
      
    PROCESS_CONTEXT_CLAUSES( COMPILATION_UNIT );
      
    declare
      H	: H_TYPE	:= INITIAL_H;
    begin
      H.REGION_DEF := PREDEFINED_STANDARD_DEF;
      H.LEX_LEVEL  := 2;
      H.IS_IN_SPEC := TRUE;
      H.IS_IN_BODY := FALSE;
      if ALL_DECL.TY = DN_SUBUNIT then
        ENTER_ANCESTOR_REGION( D( AS_NAME, ALL_DECL ), H );
        WALK_ITEM( D( AS_SUBUNIT_BODY, ALL_DECL ), H );
      else
        WALK_ITEM( ALL_DECL, H);
      end if;
         
      NOD_WALK.WALK_ITEM_S( PRAGMA_S, H );
       
      while not IS_EMPTY( USED_PACKAGE_LIST) loop
        DB( XD_IS_USED, HEAD( USED_PACKAGE_LIST ), FALSE );
        USED_PACKAGE_LIST := TAIL( USED_PACKAGE_LIST );
      end loop;
    end;
      
  end COMPILE_COMPILATION_UNIT;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE CANCEL_TRANS_WITHS
  procedure CANCEL_TRANS_WITHS ( COMPILATION_UNIT :TREE ) is				--| REND INVISIBLE LES TRANS_WITH DEFS AVANT L'UNITE DE COMPILATION SUIVANTE
    use DEF_UTIL;
    TRANS_WITH_LIST		: SEQ_TYPE 	:= LIST( COMPILATION_UNIT );
    TRANS_WITH		: TREE;
    ALL_DECL		: TREE;
    UNIT_ID		: TREE;
  begin
    while not IS_EMPTY( TRANS_WITH_LIST ) loop
      POP( TRANS_WITH_LIST, TRANS_WITH );
      ALL_DECL := D( AS_ALL_DECL, D( TW_COMP_UNIT, TRANS_WITH ) );
      if ALL_DECL.TY /= DN_SUBUNIT then
        UNIT_ID := D( AS_SOURCE_NAME, ALL_DECL );
        if UNIT_ID.TY in CLASS_UNIT_NAME and then D( SM_FIRST, UNIT_ID ) = UNIT_ID then
          REMOVE_DEF_FROM_ENVIRONMENT( GET_DEF_FOR_ID( UNIT_ID ) );
        end if;
      else
        UNIT_ID := D( SM_FIRST, D( AS_SOURCE_NAME, D( AS_SUBUNIT_BODY, ALL_DECL ) ) );
        REMOVE_DEF_FROM_ENVIRONMENT( GET_DEF_FOR_ID( UNIT_ID ) );
      end if;
    end loop;
    REMOVE_DEF_FROM_ENVIRONMENT( PREDEFINED_STANDARD_DEF );
  end CANCEL_TRANS_WITHS;
  --|-----------------------------------------------------------------------------------------------
     
  --| POUR LE CAS OU L'ON DEMANDE À TRAITER _STANDRD
  procedure FIX_PRE is separate;

begin
  OPEN_IDL_TREE_FILE( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
      
  if DI( XD_ERR_COUNT, TREE_ROOT) > 0 then
    PUT_LINE( "SEMPHASE: NOT EXECUTED" );
  else
    declare
      USER_ROOT		: TREE		:= D( XD_USER_ROOT, TREE_ROOT );
      COMPILATION		: TREE		:= D( XD_STRUCTURE, USER_ROOT );
      COMPLTN_UNIT_LIST	: SEQ_TYPE	:= LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ) );
      COMPILATION_UNIT	: TREE;
      SRC_NAME		: constant STRING	:= PRINT_NAME( D( XD_SOURCENAME, USER_ROOT ) );
    begin
        
      if SRC_NAME = "_STANDRD.ADA" then
        FIX_PRE;
               
      else
        INITIALIZE_GLOBAL_DATA;
        INITIALIZE_PRAGMA_ATTRIBUTE_DEFS;
            
        while not IS_EMPTY( COMPLTN_UNIT_LIST ) loop
          POP( COMPLTN_UNIT_LIST, COMPILATION_UNIT );
          COMPILE_COMPILATION_UNIT( COMPILATION_UNIT, INITIAL_H );
          if not IS_EMPTY( COMPLTN_UNIT_LIST ) then
            CANCEL_TRANS_WITHS( COMPILATION_UNIT );
          end if;
        end loop;
      end if;
    end;
  end if;
      
  CLOSE_PAGE_MANAGER;
--|=================================================================================================
end SEM_PHASE;
