separate( IDL.SEM_PHASE)
--|----------------------------------------------------------------------------------------------
--|     RED_SUBP
--|----------------------------------------------------------------------------------------------
package body RED_SUBP is

  use VIS_UTIL, EXP_TYPE, EXPRESO, DEF_UTIL, MAKE_NOD, SET_UTIL, REQ_UTIL, DEF_WALK, ATT_WALK, AGGRESO;

  type ACTUAL_TYPE	is record
		  SYM	: TREE;
		  EXP	: TREE;
		  TYPESET	: TYPESET_TYPE;
		end record;

  type ACTUAL_ARRAY_TYPE is array( Positive range <>) of ACTUAL_TYPE;

  function  LENGTH			( LIST :SEQ_TYPE )				return NATURAL;
  function  GET_FUNCTION_RESULT_SUBTYPE	( NAME_DEFINTERP :DEFINTERP_TYPE )		return TREE;
  function  GET_APPLY_NAME_RESULT_TYPE	( NAME_DEFINTERP :DEFINTERP_TYPE )		return TREE;
  function  STATIC_OP_VALUE		( OP_ID :TREE; NORM_PARAM_S :TREE )		return TREE;
  function  RESOLVE_SLICE		( NAME :TREE; DISCRETE_RANGE :TREE;
				  TYPE_SPEC :TREE )				return TREE;
  function  RESOLVE_INDEXED		( EXP :TREE )				return TREE;

  function  RESOLVE_CONVERSION	( EXP :TREE; SUBTYPE_ID :TREE )		return TREE;
  procedure REDUCE_APPLY_NAMES	( NAME :TREE; NAME_DEFSET :in out DEFSET_TYPE;
				  GEN_ASSOC_S :TREE; INDEX :TREE := TREE_VOID;
				  IS_SLICE_OUT :out BOOLEAN);
  procedure CHECK_ACTUAL_LIST		( HEADER :TREE; ACTUAL :ACTUAL_ARRAY_TYPE;
				  ACTUALS_OK :out BOOLEAN; EXTRAINFO :out EXTRAINFO_TYPE );
  procedure CHECK_SUBSCRIPT_LIST	( ARRAY_TYPE :TREE; ACTUAL :ACTUAL_ARRAY_TYPE;
				  ACTUALS_OK :out BOOLEAN; EXTRAINFO :out EXTRAINFO_TYPE );
  procedure REDUCE_ARRAY_PREFIX_TYPES	( NAME :TREE; NAME_TYPESET :in out TYPESET_TYPE;
				  GEN_ASSOC_S :TREE; IS_SLICE_OUT :out BOOLEAN );
  function  RESOLVE_EXP_OR_UNIV_FIXED	( EXP : TREE; TYPE_SPEC :TREE) return TREE;
  function  RESOLVE_SUBSCRIPTS	( ARRAY_TYPE :TREE; GENERAL_ASSOC_S :TREE )	return TREE;
  function  GET_ARRAY_COMPONENT_TYPE	( TYPE_SPEC :TREE )				return TREE;

  --|-------------------------------------------------------------------------------------------
  --|
  function LENGTH ( LIST :SEQ_TYPE ) return NATURAL is
          -- GIVES LENGTH OF A SEQ_TYPE
    LIST_TAIL : SEQ_TYPE := LIST;
    COUNT     : NATURAL  := 0;
  begin
    while not IS_EMPTY( LIST_TAIL ) loop
      LIST_TAIL := TAIL( LIST_TAIL );
      COUNT     := COUNT + 1;
    end loop;
    return COUNT;
  end LENGTH;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  procedure EVAL_SUBP_CALL ( EXP :TREE; TYPESET :out TYPESET_TYPE ) is
          -- EVALUATES POSSIBLE RESULT TYPES OF APPLY CONSTRUCT

    NAME			: TREE		:= D( AS_NAME, EXP );
    GEN_ASSOC_S		: constant TREE	:= D( AS_GENERAL_ASSOC_S, EXP );
    DESIGNATOR 		: TREE		:= TREE_VOID;
    NAME_DEFSET		: DEFSET_TYPE;
    NAME_DEFINTERP		: DEFINTERP_TYPE;
    NAME_TYPESET		: TYPESET_TYPE;
    NAME_TYPEINTERP		: TYPEINTERP_TYPE;
    NAME_STRUCT		: TREE;
    NEW_TYPESET		: TYPESET_TYPE	:= EMPTY_TYPESET;
    IS_SLICE		: BOOLEAN;
  begin
    if NAME.TY = DN_STRING_LITERAL then
      NAME := MAKE_USED_OP_FROM_STRING( NAME );
    end if;

          -- IF PREFIX IS SIMPLE OR SELECTED NAME
    if NAME.TY = DN_SELECTED or NAME.TY in CLASS_DESIGNATOR then
      FIND_VISIBILITY( NAME, NAME_DEFSET );
      if not IS_EMPTY( NAME_DEFSET ) then
        if IS_TYPE_DEF( GET_DEF( HEAD( NAME_DEFSET ) ) ) then
                            -- CONVERSION
          ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( GET_THE_ID( NAME_DEFSET ) ) );
          STASH_DEFSET( NAME, NAME_DEFSET);
        else
          REQUIRE_FUNCTION_OR_ARRAY_DEF( NAME, NAME_DEFSET );
          REDUCE_APPLY_NAMES( NAME, NAME_DEFSET, GEN_ASSOC_S, IS_SLICE_OUT => IS_SLICE );
          REDUCE_OPERATOR_DEFS( EXP, NAME_DEFSET );
          STASH_DEFSET( NAME, NAME_DEFSET );
          while not IS_EMPTY( NAME_DEFSET ) loop
            POP( NAME_DEFSET, NAME_DEFINTERP );
            declare
              RESULT_TYPE : TREE;
            begin
              if IS_SLICE then
                RESULT_TYPE := GET_BASE_STRUCT( D( XD_SOURCE_NAME, GET_DEF( NAME_DEFINTERP ) ) );
                if RESULT_TYPE.TY = DN_ACCESS then
                  RESULT_TYPE := GET_BASE_TYPE( D( SM_DESIG_TYPE, RESULT_TYPE ) );
                else
                  RESULT_TYPE := GET_BASE_TYPE( RESULT_TYPE );
                end if;
              else
                RESULT_TYPE := GET_APPLY_NAME_RESULT_TYPE( NAME_DEFINTERP );
              end if;
              ADD_TO_TYPESET( NEW_TYPESET, RESULT_TYPE, GET_EXTRAINFO( NAME_DEFINTERP ) );
            end;
          end loop;
        end if;
      else
                        --( FOLLOWING FORCES PARAM TO BE EVAL'ED, EVEN THO NO FCN)
        REDUCE_APPLY_NAMES( NAME, NAME_DEFSET, GEN_ASSOC_S );
        STASH_DEFSET( NAME, NAME_DEFSET );
      end if;

                   -- ELSE -- SINCE PREFIX IS NOT SIMPLE OR SELECTED NAME
    else

                   -- PREFIX MUST BE EXPRESSION APPROPRIATE FOR ARRAY TYPE
      EVAL_EXP_TYPES( NAME, NAME_TYPESET );
      REDUCE_ARRAY_PREFIX_TYPES( NAME, NAME_TYPESET, GEN_ASSOC_S, IS_SLICE );
      STASH_TYPESET( NAME, NAME_TYPESET );
      while not IS_EMPTY( NAME_TYPESET ) loop
        POP( NAME_TYPESET, NAME_TYPEINTERP);
        NAME_STRUCT := GET_BASE_STRUCT( GET_TYPE( NAME_TYPEINTERP ) );
        if NAME_STRUCT.TY = DN_ACCESS then
          NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, NAME_STRUCT ) );
        end if;
        if IS_SLICE then
          ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( NAME_STRUCT ), GET_EXTRAINFO( NAME_TYPEINTERP ) );
        else
          ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( D( SM_COMP_TYPE, NAME_STRUCT ) ), GET_EXTRAINFO( NAME_TYPEINTERP ) );
        end if;
      end loop;
    end if;

          -- RETURN THE NEW TYPESET
    TYPESET := NEW_TYPESET;
  end EVAL_SUBP_CALL;
  --|-------------------------------------------------------------------------------------------
  --|
  function GET_FUNCTION_RESULT_SUBTYPE ( NAME_DEFINTERP :DEFINTERP_TYPE ) return TREE is
    RESULT_TYPE		: TREE	:= D( AS_NAME, D( XD_HEADER, GET_DEF( NAME_DEFINTERP ) ) );
    TYPE_MARK_DEFN		: TREE;
  begin
    if RESULT_TYPE.TY in CLASS_TYPE_SPEC then
      return RESULT_TYPE;
    else
      if RESULT_TYPE.TY = DN_SELECTED then
        TYPE_MARK_DEFN := D( SM_DEFN, D( AS_DESIGNATOR, RESULT_TYPE ) );
      else
        TYPE_MARK_DEFN := D( SM_DEFN, RESULT_TYPE );
      end if;
      if TYPE_MARK_DEFN = TREE_VOID then
        return TREE_VOID;
      else
        return D( SM_TYPE_SPEC, TYPE_MARK_DEFN );
      end if;
    end if;
  end GET_FUNCTION_RESULT_SUBTYPE;
  --|-------------------------------------------------------------------------------------------
  --|
  function GET_APPLY_NAME_RESULT_TYPE ( NAME_DEFINTERP :DEFINTERP_TYPE ) return TREE is
    NAME_ID	: TREE	:= D( XD_SOURCE_NAME, GET_DEF( NAME_DEFINTERP ) );
  begin
    case NAME_ID.TY is
      when DN_TYPE_ID | DN_SUBTYPE_ID | DN_PRIVATE_TYPE_ID | DN_L_PRIVATE_TYPE_ID =>
        return GET_BASE_TYPE( NAME_ID );
      when DN_FUNCTION_ID | DN_GENERIC_ID =>
        if IS_NULLARY( NAME_DEFINTERP ) then
          return GET_ARRAY_COMPONENT_TYPE( D( AS_NAME, D( SM_SPEC, NAME_ID ) ) );
        else
          return GET_BASE_TYPE( D( AS_NAME, D( SM_SPEC, NAME_ID ) ) );
        end if;
      when DN_OPERATOR_ID | DN_BLTN_OPERATOR_ID =>
        return GET_BASE_TYPE( D( AS_NAME, D( XD_HEADER, GET_DEF( NAME_DEFINTERP ) ) ) );
                   --$$$ WORRY ABOUT EXTRA INFO AND BOOLEAN VALUED OPS
      when others =>
                        -- $$$ MUST BE EXPRESSION
        return GET_ARRAY_COMPONENT_TYPE( D( SM_OBJ_TYPE, NAME_ID ) );
    end case;
  end GET_APPLY_NAME_RESULT_TYPE;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  function RESOLVE_FUNCTION_CALL ( EXP :TREE; TYPE_SPEC :TREE ) return TREE is
    NAME			: TREE		:= D( AS_NAME, EXP );
    GENERAL_ASSOC_S		: TREE		:= D( AS_GENERAL_ASSOC_S, EXP );
    DEFSET		: DEFSET_TYPE;
    DEFINTERP		: DEFINTERP_TYPE;
    NEW_DEFSET		: DEFSET_TYPE	:= EMPTY_DEFSET;
    DEF_ID		: TREE;
    ORIG_DEF_ID		: TREE;							-- DEF_ID PRIOR TO RENAMING
  begin

          -- IF SLICE, RESOLVE AND RETURN SLICE
    if not IS_EMPTY( LIST( GENERAL_ASSOC_S ) ) and then HEAD( LIST( GENERAL_ASSOC_S ) ).TY in CLASS_DISCRETE_RANGE then
      return RESOLVE_SLICE( NAME, HEAD( LIST( GENERAL_ASSOC_S ) ), TYPE_SPEC );
    end if;

          -- IF PREFIX IS SIMPLE OR SELECTED NAME
    if NAME.TY = DN_SELECTED or NAME.TY in CLASS_DESIGNATOR then
      DEFSET := FETCH_DEFSET( NAME );
      if IS_EMPTY( DEFSET ) then
        null;
      elsif IS_TYPE_DEF( GET_DEF( HEAD( DEFSET ) ) ) then
                        -- MUST BE CONVERSION
        NEW_DEFSET := DEFSET;
      elsif TYPE_SPEC /= TREE_VOID then
        while not IS_EMPTY( DEFSET ) loop
          POP( DEFSET, DEFINTERP );
          if GET_APPLY_NAME_RESULT_TYPE( DEFINTERP ) = TYPE_SPEC
	   or else ( TYPE_SPEC.TY = DN_UNIVERSAL_FIXED
		   and then GET_BASE_STRUCT( GET_APPLY_NAME_RESULT_TYPE( DEFINTERP ) ).TY = DN_FIXED
		 )
	then
            ADD_TO_DEFSET( NEW_DEFSET, DEFINTERP );
          end if;
        end loop;
        if IS_EMPTY( NEW_DEFSET) then
          ERROR( D( LX_SRCPOS, NAME ), "**** NO VALID DEFS IN RESOLVE");
        end if;
      end if;

      REQUIRE_UNIQUE_DEF( NAME, NEW_DEFSET );

      DEF_ID := GET_THE_ID( NEW_DEFSET );
      NAME   := RESOLVE_NAME( NAME, DEF_ID );
      D( AS_NAME, EXP, NAME );

      if IS_EMPTY( NEW_DEFSET ) then
        RESOLVE_ERRONEOUS_PARAM_S( GENERAL_ASSOC_S );
        D( SM_EXP_TYPE, EXP, TREE_VOID );
        return EXP;

      else
        case CLASS_DEF_NAME'( DEF_ID.TY ) is
          when CLASS_OBJECT_NAME =>
            return RESOLVE_INDEXED( EXP );

          when CLASS_TYPE_NAME =>
                                 -- MUST BE A CONVERSION
            return RESOLVE_CONVERSION( EXP, DEF_ID );

          when DN_FUNCTION_ID | DN_GENERIC_ID | DN_BLTN_OPERATOR_ID | DN_OPERATOR_ID =>
            if IS_NULLARY( HEAD( NEW_DEFSET ) ) then
              NAME := MAKE_FUNCTION_CALL
		( LX_SRCPOS => D( LX_SRCPOS, NAME ),
		AS_NAME => NAME,
		AS_GENERAL_ASSOC_S => MAKE_GENERAL_ASSOC_S( LX_SRCPOS => D( LX_SRCPOS, NAME ),
		LIST =>(TREE_NIL, TREE_NIL) ), SM_EXP_TYPE => GET_FUNCTION_RESULT_SUBTYPE( HEAD( NEW_DEFSET ) ) );
                                          -- MAKE NORMALIZED_PARAM_S FOR THE DEFAULT PARAMS
              D( SM_NORMALIZED_PARAM_S, NAME, RESOLVE_SUBP_PARAMETERS( GET_DEF( HEAD( NEW_DEFSET ) ), D( AS_GENERAL_ASSOC_S, NAME ) ) );
              D( AS_NAME, EXP, NAME );
              return RESOLVE_INDEXED( EXP );
            else
              D( SM_EXP_TYPE, EXP, GET_FUNCTION_RESULT_SUBTYPE( HEAD( NEW_DEFSET ) ) );
              D( SM_NORMALIZED_PARAM_S, EXP, RESOLVE_SUBP_PARAMETERS( GET_DEF( HEAD( NEW_DEFSET ) ), GENERAL_ASSOC_S ) );
                                          -- WALK BACK THRU RENAMES - LOOK FOR BUILT IN OP
              ORIG_DEF_ID := DEF_ID;
              if ORIG_DEF_ID.TY = DN_OPERATOR_ID then
                while ORIG_DEF_ID.TY in DN_FUNCTION_ID .. DN_OPERATOR_ID and then D( SM_UNIT_DESC, ORIG_DEF_ID).TY = DN_RENAMES_UNIT loop
                  ORIG_DEF_ID := D( AS_NAME, D( SM_UNIT_DESC, ORIG_DEF_ID ) );
                  if ORIG_DEF_ID.TY = DN_SELECTED then
                    ORIG_DEF_ID := D( AS_DESIGNATOR, ORIG_DEF_ID );
                  end if;
                  ORIG_DEF_ID := D( SM_DEFN, ORIG_DEF_ID );
                end loop;
              end if;
              if ORIG_DEF_ID.TY = DN_BLTN_OPERATOR_ID then
                D( SM_VALUE, EXP, STATIC_OP_VALUE( ORIG_DEF_ID, D( SM_NORMALIZED_PARAM_S, EXP ) ) );
              end if;
              return EXP;
            end if;

          when others =>
            PUT_LINE( "!! RESOLVE_FUNCTION_CALL: INVALID NAME" );
            raise PROGRAM_ERROR;
        end case;
      end if;

    elsif NAME.TY = DN_ATTRIBUTE then
      return RESOLVE_ATTRIBUTE( EXP );

    else
      declare
        NAME_TYPESET	: TYPESET_TYPE	:= FETCH_TYPESET( NAME );
        NAME_TYPEINTERP	: TYPEINTERP_TYPE;
        NAME_STRUCT		: TREE;
        NEW_TYPESET		: TYPESET_TYPE	:= EMPTY_TYPESET;
      begin
        while not IS_EMPTY( NAME_TYPESET ) loop
          POP( NAME_TYPESET, NAME_TYPEINTERP );
          NAME_STRUCT := GET_BASE_STRUCT( GET_TYPE( NAME_TYPEINTERP ) );
          if NAME_STRUCT.TY = DN_ACCESS then
            NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, NAME_STRUCT ) );
          end if;
          if GET_BASE_TYPE( D( SM_COMP_TYPE, NAME_STRUCT ) ) = TYPE_SPEC
	   or else ( TYPE_SPEC.TY = DN_UNIVERSAL_FIXED
		   and then GET_BASE_STRUCT( D( SM_COMP_TYPE, NAME_STRUCT ) ).TY = DN_FIXED
		 )
	then
            ADD_TO_TYPESET( NEW_TYPESET, NAME_TYPEINTERP );
          end if;
        end loop;
        NAME := RESOLVE_EXP( NAME, NEW_TYPESET );
        D( AS_NAME, EXP, NAME );
      end;
      return RESOLVE_INDEXED( EXP );
    end if;

  end RESOLVE_FUNCTION_CALL;
  --|-------------------------------------------------------------------------------------------
  --|
  function STATIC_OP_VALUE( OP_ID :TREE; NORM_PARAM_S :TREE ) return TREE is
    use UARITH, PRENAME;

    PARAM_TAIL	: SEQ_TYPE	:= LIST( NORM_PARAM_S );
    FIRST_PARAM	: TREE;
    FIRST_VALUE	: TREE;
    SECOND_VALUE	: TREE;
  begin
          -- GET THE FIRST PARAMETER AND ITS VALUE
    POP( PARAM_TAIL, FIRST_PARAM );
    FIRST_VALUE := GET_STATIC_VALUE( FIRST_PARAM );

          -- IF FIRST PARAMETER IS NOT STATIC
    if FIRST_VALUE = TREE_VOID then

                   -- NO VALUE; RETURN
      return TREE_VOID;
    end if;

          -- IF THERE IS A SECOND PARAMETER
    if not IS_EMPTY( PARAM_TAIL ) then

                   -- GET ITS VALUE
      SECOND_VALUE := GET_STATIC_VALUE( HEAD( PARAM_TAIL ) );

                   -- IF SECOND PARAMETER IS NOT STATIC
      if SECOND_VALUE = TREE_VOID then

                        -- NO VALUE; RETURN
        return TREE_VOID;
      end if;
    end if;

    case OP_CLASS'VAL( DI( SM_OPERATOR, OP_ID ) ) is
      when OP_AND =>
        return FIRST_VALUE and SECOND_VALUE;
      when OP_OR =>
        return FIRST_VALUE or SECOND_VALUE;
      when OP_XOR =>
        return FIRST_VALUE xor SECOND_VALUE;
      when OP_NOT =>
        return not FIRST_VALUE;
      when OP_UNARY_PLUS =>
        return FIRST_VALUE;
      when OP_UNARY_MINUS =>
        return -FIRST_VALUE;
      when OP_ABS =>
        return abs FIRST_VALUE;
      when OP_EQ =>
        return U_EQUAL( FIRST_VALUE, SECOND_VALUE );
      when OP_NE =>
        return U_NOT_EQUAL( FIRST_VALUE, SECOND_VALUE );
      when OP_LT =>
        return FIRST_VALUE < SECOND_VALUE;
      when OP_LE =>
        return FIRST_VALUE <= SECOND_VALUE;
      when OP_GT =>
        return FIRST_VALUE > SECOND_VALUE;
      when OP_GE =>
        return FIRST_VALUE >= SECOND_VALUE;
      when OP_PLUS =>
        return FIRST_VALUE + SECOND_VALUE;
      when OP_MINUS =>
        return FIRST_VALUE - SECOND_VALUE;
      when OP_MULT =>
        return FIRST_VALUE * SECOND_VALUE;
      when OP_DIV =>
        return FIRST_VALUE / SECOND_VALUE;
      when OP_MOD =>
        return FIRST_VALUE mod SECOND_VALUE;
      when OP_REM =>
        return FIRST_VALUE rem SECOND_VALUE;
      when OP_CAT =>
        return TREE_VOID;
      when OP_EXP =>
        return FIRST_VALUE**SECOND_VALUE;
    end case;
  end STATIC_OP_VALUE;
  --|-------------------------------------------------------------------------------------------
  --|
  function RESOLVE_SLICE ( NAME :TREE; DISCRETE_RANGE :TREE; TYPE_SPEC :TREE ) return TREE is
    ARRAY_TYPE		: TREE	:= GET_BASE_STRUCT( TYPE_SPEC);
    INDEX_TYPE		: TREE	:= TREE_VOID;
    RESOLVED_RANGE		: TREE	:= DISCRETE_RANGE;
    RESOLVED_NAME		: TREE;
  begin
					-- CHECK THAT NAME IS ARRAY TYPE
					-- ... AND GET THE INDEX SUBTYPE
    if ARRAY_TYPE.TY = DN_ACCESS then
      ARRAY_TYPE := GET_BASE_STRUCT( D( SM_DESIG_TYPE, ARRAY_TYPE ) );
    end if;
    if ARRAY_TYPE.TY /= DN_ARRAY then
      if ARRAY_TYPE /= TREE_VOID then
        PUT_LINE( "!! RESOLVE_SLICE: ARRAY TYPE EXPECTED" );
        raise PROGRAM_ERROR;
      end if;
    else
      INDEX_TYPE := GET_BASE_TYPE( D( SM_TYPE_SPEC, HEAD( LIST( D( SM_INDEX_S, ARRAY_TYPE ) ) ) ) );
    end if;

          -- RESOLVE THE RANGE IF IT IS AN EXPLICIT RANGE
          -- ...( OTHERWISE IT IS ALREADY RESOLVED)
    if RESOLVED_RANGE.TY = DN_RANGE then
      RESOLVED_RANGE := RESOLVE_DISCRETE_RANGE( RESOLVED_RANGE, INDEX_TYPE );
    end if;

          -- RESOLVE THE NAME
    if NAME.TY in CLASS_DESIGNATOR or else NAME.TY = DN_SELECTED then
      declare
        NAME_DEFSET		: DEFSET_TYPE	:= FETCH_DEFSET( NAME );
        NAME_DEFINTERP	: DEFINTERP_TYPE;
        NAME_STRUCT		: TREE;
        NEW_DEFSET		: DEFSET_TYPE	:= EMPTY_DEFSET;
      begin
        if not IS_EMPTY( NAME_DEFSET ) and ARRAY_TYPE /= TREE_VOID then
          while not IS_EMPTY( NAME_DEFSET ) loop
            POP( NAME_DEFSET, NAME_DEFINTERP );
            NAME_STRUCT := GET_BASE_STRUCT( D( XD_SOURCE_NAME, GET_DEF( NAME_DEFINTERP ) ) );
            if NAME_STRUCT.TY = DN_ACCESS then
              NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, NAME_STRUCT ) );
            end if;
            if NAME_STRUCT = ARRAY_TYPE then
              ADD_TO_DEFSET( NEW_DEFSET, NAME_DEFINTERP );
            end if;
          end loop;
          if IS_EMPTY( NEW_DEFSET ) then
            ERROR( D( LX_SRCPOS, NAME ), "**** NO DEFS FOR SLICE NAME" );
          end if;
          REQUIRE_UNIQUE_DEF( NAME, NEW_DEFSET );
        end if;
        RESOLVED_NAME := RESOLVE_EXP( NAME, GET_BASE_TYPE( GET_THE_ID( NEW_DEFSET ) ) );
      end;
    else
      declare
        NAME_TYPESET	: TYPESET_TYPE	:= FETCH_TYPESET( NAME );
        NAME_TYPEINTERP	: TYPEINTERP_TYPE;
        NAME_STRUCT		: TREE;
        NEW_TYPESET		: TYPESET_TYPE	:= EMPTY_TYPESET;
      begin
        if not IS_EMPTY( NAME_TYPESET ) and ARRAY_TYPE /= TREE_VOID then
          while not IS_EMPTY( NAME_TYPESET ) loop
            POP( NAME_TYPESET, NAME_TYPEINTERP );
            NAME_STRUCT := GET_BASE_STRUCT( GET_TYPE( NAME_TYPEINTERP ) );
            if NAME_STRUCT.TY = DN_ACCESS then
              NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, NAME_STRUCT ) );
            end if;
            if NAME_STRUCT = ARRAY_TYPE then
              ADD_TO_TYPESET( NEW_TYPESET, NAME_TYPEINTERP );
            end if;
          end loop;
          if IS_EMPTY( NEW_TYPESET ) then
            ERROR( D( LX_SRCPOS, NAME ), "**** NO TYPES FOR SLICE NAME" );
          end if;
        end if;
        RESOLVED_NAME := RESOLVE_EXP( NAME, NEW_TYPESET );
      end;

                   -- MAKE SLICE

    end if;
    return MAKE_SLICE( LX_SRCPOS => D( LX_SRCPOS, NAME ),
		AS_NAME => RESOLVED_NAME,
		AS_DISCRETE_RANGE => RESOLVED_RANGE, SM_EXP_TYPE => TYPE_SPEC );

  end RESOLVE_SLICE;
  --|-------------------------------------------------------------------------------------------
  --|
  function RESOLVE_INDEXED( EXP :TREE) return TREE is
          -- EXP IS A FUNCTION_CALL NODE; MAKE IT INDEXED
          -- AS_NAME[EXP] IS ALREADY RESOLVED

    NAME		: constant TREE	:= D( AS_NAME, EXP );
    GEN_ASSOC_S	: constant TREE	:= D( AS_GENERAL_ASSOC_S, EXP );

    ARRAY_SUBTYPE	: constant TREE	:= D( SM_EXP_TYPE, NAME );
    ARRAY_TYPE	: TREE		:= GET_BASE_STRUCT( ARRAY_SUBTYPE );
    COMP_SUBTYPE	: TREE;
  begin

          -- CHECK THAT NAME IS ARRAY TYPE
    if ARRAY_TYPE.TY = DN_ACCESS then
      ARRAY_TYPE := GET_BASE_STRUCT( D( SM_DESIG_TYPE, ARRAY_TYPE ) );
    end if;
    if ARRAY_TYPE.TY /= DN_ARRAY then
      if ARRAY_TYPE = TREE_VOID then
        RESOLVE_ERRONEOUS_PARAM_S( GEN_ASSOC_S );
        D( SM_EXP_TYPE, EXP, TREE_VOID );
        return EXP;
      else
        PUT_LINE( "!! RESOLVE_INDEXED: ARRAY TYPE EXPECTED" );
        raise PROGRAM_ERROR;
      end if;
    end if;

          -- GET THE COMPONENT SUBTYPE
    COMP_SUBTYPE := D( SM_COMP_TYPE, ARRAY_TYPE );

          -- RESOLVE SUBSCRIPTS, MAKE INDEXED NODE AND RETURN
    return MAKE_INDEXED( LX_SRCPOS => D( LX_SRCPOS, EXP ),
		AS_NAME => NAME,
		AS_EXP_S => RESOLVE_SUBSCRIPTS( ARRAY_TYPE, GEN_ASSOC_S),
		SM_EXP_TYPE => COMP_SUBTYPE );

  end RESOLVE_INDEXED;
  --|-------------------------------------------------------------------------------------------
  --|
  function RESOLVE_CONVERSION( EXP :TREE; SUBTYPE_ID :TREE) return TREE is
          -- EXP IS A FUNCTION_CALL NODE; MAKE IT CONVERSION
          -- AS_NAME[EXP] IS ALREADY RESOLVED

    NAME			: constant TREE	:= D( AS_NAME, EXP );
    GEN_ASSOC_S		: constant TREE	:= D( AS_GENERAL_ASSOC_S, EXP );
    TARGET_STRUCT		: TREE		:= GET_BASE_STRUCT( SUBTYPE_ID );

    PARAM_LIST		: SEQ_TYPE	:= LIST( GEN_ASSOC_S );
    PARAM			: TREE;
    PARAM_TYPESET		: TYPESET_TYPE;
    PARAM_TYPEINTERP	: TYPEINTERP_TYPE;
    PARAM_STRUCT		: TREE;
    NEW_TYPESET		: TYPESET_TYPE	:= EMPTY_TYPESET;
  begin
    POP( PARAM_LIST, PARAM );
    if PARAM.TY = DN_ASSOC then
      ERROR( D( LX_SRCPOS, PARAM ), "NAMED CONVERSION PARAM" );
      PARAM := D( AS_EXP, PARAM );
    end if;
    if not IS_EMPTY( PARAM_LIST ) then
      ERROR( D( LX_SRCPOS, HEAD( PARAM_LIST ) ), "CONVERSION HAS MORE THAN 1 PARAM" );
    end if;
    EVAL_EXP_TYPES( PARAM, PARAM_TYPESET );

    if not IS_EMPTY( PARAM_TYPESET ) and then TARGET_STRUCT /= TREE_VOID then
      case TARGET_STRUCT.TY is
        when DN_INTEGER .. DN_FIXED =>
          while not IS_EMPTY( PARAM_TYPESET ) loop
            POP( PARAM_TYPESET, PARAM_TYPEINTERP );
            PARAM_STRUCT := GET_BASE_STRUCT( GET_TYPE( PARAM_TYPEINTERP ) );
            if PARAM_STRUCT.TY in DN_INTEGER .. DN_FIXED
	     or PARAM_STRUCT.TY in DN_UNIVERSAL_INTEGER .. DN_UNIVERSAL_REAL
	     or PARAM_STRUCT.TY in DN_ANY_INTEGER .. DN_ANY_REAL
	  then
              ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( PARAM_STRUCT), GET_EXTRAINFO( PARAM_TYPEINTERP ) );
            end if;
          end loop;
        when DN_ARRAY =>
          while not IS_EMPTY( PARAM_TYPESET ) loop
            POP( PARAM_TYPESET, PARAM_TYPEINTERP );
            PARAM_STRUCT := GET_BASE_STRUCT( GET_TYPE( PARAM_TYPEINTERP ) );
            if PARAM_STRUCT.TY = DN_ARRAY
	     and then GET_BASE_TYPE( D( SM_COMP_TYPE, TARGET_STRUCT ) ) = GET_BASE_TYPE( D( SM_COMP_TYPE, PARAM_STRUCT ) )
	  then
              declare
                TARGET_INDEX_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_S, TARGET_STRUCT ) );
                TARGET_INDEX		: TREE;
                PARAM_INDEX_LIST	: SEQ_TYPE	:= LIST( D( SM_INDEX_S, PARAM_STRUCT ) );
                PARAM_INDEX		: TREE;
              begin
                loop
                  if IS_EMPTY( TARGET_INDEX_LIST ) then
                    if IS_EMPTY( PARAM_INDEX_LIST ) then
                      ADD_TO_TYPESET( NEW_TYPESET, GET_BASE_TYPE( PARAM_STRUCT), GET_EXTRAINFO( PARAM_TYPEINTERP ) );
                    end if;
                    exit;
                  elsif IS_EMPTY( PARAM_INDEX_LIST ) then
                    exit;
                  end if;
                  POP( TARGET_INDEX_LIST, TARGET_INDEX );
                  POP( PARAM_INDEX_LIST, PARAM_INDEX );
                  TARGET_INDEX := GET_BASE_TYPE( D( SM_TYPE_SPEC, TARGET_INDEX ) );
                  PARAM_INDEX  := GET_BASE_TYPE( D( SM_TYPE_SPEC, PARAM_INDEX ) );
                  if TARGET_INDEX.TY = DN_INTEGER and then PARAM_INDEX.TY = DN_INTEGER then
                    null;
                  elsif GET_ANCESTOR_TYPE( TARGET_INDEX ) = GET_ANCESTOR_TYPE( PARAM_INDEX ) then
                    null;
                  else
                    exit;
                  end if;
                end loop;
              end;
            end if;
          end loop;
        when others =>
          TARGET_STRUCT := GET_ANCESTOR_TYPE( TARGET_STRUCT );
          while not IS_EMPTY( PARAM_TYPESET ) loop
            POP( PARAM_TYPESET, PARAM_TYPEINTERP );
            PARAM_STRUCT := GET_ANCESTOR_TYPE( GET_TYPE( PARAM_TYPEINTERP ) );
            if PARAM_STRUCT = TARGET_STRUCT then
              ADD_TO_TYPESET( NEW_TYPESET, PARAM_TYPEINTERP );
            end if;
          end loop;
      end case;

      if IS_EMPTY( NEW_TYPESET ) then
        ERROR( D( LX_SRCPOS, PARAM ), "INVALID TYPE FOR CONVERSION" );
      else
        REQUIRE_UNIQUE_TYPE( PARAM, NEW_TYPESET );
      end if;
    end if;

    PARAM := RESOLVE_EXP( PARAM, NEW_TYPESET );
    return MAKE_CONVERSION( LX_SRCPOS => D( LX_SRCPOS, EXP), AS_NAME => NAME,
		AS_EXP => PARAM, SM_EXP_TYPE => D( SM_TYPE_SPEC, SUBTYPE_ID ) );
  end RESOLVE_CONVERSION;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|
  procedure REDUCE_APPLY_NAMES ( NAME :TREE; NAME_DEFSET :in out DEFSET_TYPE; GEN_ASSOC_S :TREE; INDEX :TREE := TREE_VOID ) is
          -- THIS VERSION CALLED FROM WALK_STM FOR PROCEDURE OR ENTRY CALL
    IS_SLICE : BOOLEAN;
          -- NEVER SET, SINCE NAME IS PROC OR ENTRY
  begin
    REDUCE_APPLY_NAMES( NAME, NAME_DEFSET, GEN_ASSOC_S, INDEX, IS_SLICE);
  end REDUCE_APPLY_NAMES;
--|-------------------------------------------------------------------------------------------------
--|
  procedure REDUCE_APPLY_NAMES ( NAME :TREE; NAME_DEFSET :in out DEFSET_TYPE; GEN_ASSOC_S :TREE; INDEX :TREE := TREE_VOID; IS_SLICE_OUT :out BOOLEAN ) is

    ASSOC_LIST		: SEQ_TYPE		:= LIST( GEN_ASSOC_S );
    ACTUAL_COUNT		: NATURAL 		:= LENGTH( ASSOC_LIST );

    INDEX_TYPESET		: TYPESET_TYPE		:= EMPTY_TYPESET;

    ACTUAL		: ACTUAL_ARRAY_TYPE( 1 .. ACTUAL_COUNT );
    POSITIONAL_LAST		: NATURAL			:= 0;

    NAMED_SEEN		: BOOLEAN			:= FALSE;
    ERROR_SEEN		: BOOLEAN			:= FALSE;
    IS_SLICE		: BOOLEAN			:= FALSE;

    DEFINTERP		: DEFINTERP_TYPE;
    NEW_DEFSET		: DEFSET_TYPE		:= EMPTY_DEFSET;
    HEADER		: TREE;
    NAME_DEF		: TREE;
    NAME_ID		: TREE;

    ACTUALS_OK		: BOOLEAN;
    RESULT_STRUCT		: TREE;

    EXTRAINFO		: EXTRAINFO_TYPE;
  begin
    if INDEX /= TREE_VOID then
      EVAL_EXP_TYPES( INDEX, INDEX_TYPESET );
    end if;

    for I in ACTUAL'RANGE loop
      POP( ASSOC_LIST, ACTUAL( I ).EXP );
      if ACTUAL( I ).EXP.TY = DN_ASSOC then
        NAMED_SEEN     := TRUE;
        ACTUAL( I ).SYM := D( LX_SYMREP, D( AS_USED_NAME, ACTUAL( I ).EXP ) );
        ACTUAL( I ).EXP := D( AS_EXP, ACTUAL( I ).EXP );
      else
        if NAMED_SEEN then
          ERROR( D( LX_SRCPOS, ACTUAL( I ).EXP ), "POSITIONAL PARAMETER FOLLOWS NAMED" );
          ERROR_SEEN := TRUE;
        end if;
        ACTUAL( I).SYM  := TREE_VOID;
        POSITIONAL_LAST := I;
      end if;
    end loop;

    if ACTUAL'LAST = 1 and then INDEX = TREE_VOID and then not NAMED_SEEN then
      EVAL_EXP_SUBTYPE_TYPES( ACTUAL( 1 ).EXP, ACTUAL( 1 ).TYPESET, IS_SLICE );
      if IS_SLICE and then ACTUAL( 1 ).EXP.TY /= DN_RANGE then
                        --( RESOLVE NOW -- USED TO INDICATE SLICE LATER)
        REQUIRE_UNIQUE_TYPE( ACTUAL( 1 ).EXP, ACTUAL( 1 ).TYPESET);
        ACTUAL( 1 ).EXP := RESOLVE_DISCRETE_RANGE( ACTUAL( 1 ).EXP, GET_THE_TYPE( ACTUAL( 1 ).TYPESET ) );
        LIST( GEN_ASSOC_S, SINGLETON( ACTUAL( 1).EXP ) );
      end if;
    else
      for I in ACTUAL'RANGE loop
        EVAL_EXP_TYPES( ACTUAL( I ).EXP, ACTUAL( I ).TYPESET );
                        -- NOTE. FOLLOWING USED TO RESOLVE CONV TO UNIV FIXED
        STASH_TYPESET( ACTUAL( I ).EXP, ACTUAL( I ).TYPESET );
      end loop;
    end if;
    IS_SLICE_OUT := IS_SLICE;

    if IS_EMPTY( NAME_DEFSET ) then
      ERROR_SEEN := TRUE;
    end if;

    if not ERROR_SEEN then
      while not IS_EMPTY( NAME_DEFSET ) loop
        POP( NAME_DEFSET, DEFINTERP );

        ACTUALS_OK := FALSE;
        NAME_DEF   := GET_DEF( DEFINTERP );
        NAME_ID    := D( XD_SOURCE_NAME, NAME_DEF );
                        -- $$$$ WHAT ABOUT GENERIC
        case NAME_ID.TY is
          when DN_ENTRY_ID =>
            HEADER := D( SM_SPEC, NAME_ID );
            if IS_SLICE then
              null;
            elsif HEADER = TREE_VOID then
                                          --( ERROR IN THE DECLARATION)
              null;
            elsif INDEX /= TREE_VOID then
              if D( AS_DISCRETE_RANGE, HEADER ) /= TREE_VOID then
                CHECK_ACTUAL_TYPE( GET_TYPE_OF_DISCRETE_RANGE( D( AS_DISCRETE_RANGE, HEADER)), INDEX_TYPESET, ACTUALS_OK, EXTRAINFO );
                if ACTUALS_OK then
                  ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                  CHECK_ACTUAL_LIST( HEADER, ACTUAL, ACTUALS_OK, EXTRAINFO );
                  if ACTUALS_OK then
                    ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                  end if;
                end if;
              end if;
            elsif D( AS_DISCRETE_RANGE, HEADER ) /= TREE_VOID then
              if ACTUAL'LAST = 1 and then ACTUAL( 1 ).SYM = TREE_VOID then
                CHECK_ACTUAL_TYPE( GET_TYPE_OF_DISCRETE_RANGE( D( AS_DISCRETE_RANGE, HEADER ) ), ACTUAL( 1 ).TYPESET, ACTUALS_OK, EXTRAINFO );
                if ACTUALS_OK then
                  ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                  CHECK_ACTUAL_LIST( HEADER, ACTUAL( 1 .. 0 )
                                                        --( NULL RANGE)
                  , ACTUALS_OK, EXTRAINFO );
                  if ACTUALS_OK then
                    ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                  end if;
                end if;
              else
                ACTUALS_OK := FALSE;
              end if;
            else
              CHECK_ACTUAL_LIST( HEADER, ACTUAL, ACTUALS_OK, EXTRAINFO) ;
              if ACTUALS_OK then
                ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
              end if;
            end if;
            if ACTUALS_OK then
              ADD_TO_DEFSET( NEW_DEFSET, DEFINTERP );
            end if;

          when DN_PROCEDURE_ID | DN_OPERATOR_ID | DN_BLTN_OPERATOR_ID =>
                                 --$$$$ WORRY ABOUT CONVERSIONS WITH BOOLEAN-VALUED OPS
            HEADER := D( XD_HEADER, GET_DEF( DEFINTERP ) );

stop;

            CHECK_ACTUAL_LIST( HEADER, ACTUAL, ACTUALS_OK, EXTRAINFO );
            if ACTUALS_OK and not IS_SLICE then
              ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
              ADD_TO_DEFSET( NEW_DEFSET, DEFINTERP );
            end if;

          when DN_FUNCTION_ID | DN_GENERIC_ID =>
            HEADER := D( XD_HEADER, GET_DEF( DEFINTERP ) );
            CHECK_ACTUAL_LIST( HEADER, ACTUAL, ACTUALS_OK, EXTRAINFO );
            if ACTUALS_OK and not IS_SLICE then
              ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
              ADD_TO_DEFSET( NEW_DEFSET, DEFINTERP );
            end if;
            if not NAMED_SEEN and then HEADER.TY = DN_FUNCTION_SPEC
                                          -- IE, NOT GEN PROC
              then
              RESULT_STRUCT := GET_BASE_STRUCT( D( AS_NAME, HEADER ) );
              if RESULT_STRUCT.TY = DN_ACCESS then
                RESULT_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, RESULT_STRUCT ) );
              end if;
              if RESULT_STRUCT.TY = DN_ARRAY and then LENGTH( LIST( D( SM_INDEX_S, RESULT_STRUCT ) ) ) = ACTUAL'LENGTH then
                CHECK_ACTUAL_LIST( HEADER, ACTUAL( 1 .. 0 )
                                                   --( NULL RANGE)
                , ACTUALS_OK, EXTRAINFO );
                if ACTUALS_OK then
                  CHECK_SUBSCRIPT_LIST( RESULT_STRUCT, ACTUAL, ACTUALS_OK, EXTRAINFO );
                end if;
                if ACTUALS_OK then
                  ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                  ADD_TO_DEFSET( NEW_DEFSET, GET_DEF( DEFINTERP ), GET_EXTRAINFO( DEFINTERP ), IS_NULLARY => TRUE );
                end if;
              end if;
            end if;

          when CLASS_OBJECT_NAME =>
            RESULT_STRUCT := GET_BASE_STRUCT( D( SM_OBJ_TYPE, NAME_ID ) );
            if RESULT_STRUCT.TY = DN_ACCESS then
              RESULT_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, RESULT_STRUCT ) );
            end if;
            if not NAMED_SEEN and then RESULT_STRUCT.TY = DN_ARRAY and then LENGTH( LIST( D( SM_INDEX_S, RESULT_STRUCT ) ) ) = ACTUAL'LENGTH then
              CHECK_SUBSCRIPT_LIST( RESULT_STRUCT, ACTUAL, ACTUALS_OK, EXTRAINFO );
              if ACTUALS_OK then
                ADD_EXTRAINFO( DEFINTERP, EXTRAINFO );
                ADD_TO_DEFSET( NEW_DEFSET, DEFINTERP );
              end if;
            end if;

          when others =>
            ERROR( D( LX_SRCPOS, NAME ), "NAME NOT VALID IN APPLY" );
        end case;

      end loop;

      if IS_EMPTY( NEW_DEFSET ) then
        ERROR( D( LX_SRCPOS, NAME), "PARAMETER TYPE MISMATCH" );
      end if;
    end if;

    NAME_DEFSET := NEW_DEFSET;
  end REDUCE_APPLY_NAMES;
  --|-------------------------------------------------------------------------------------------
  --|
  procedure CHECK_ACTUAL_LIST( HEADER :TREE; ACTUAL :ACTUAL_ARRAY_TYPE;
			 ACTUALS_OK :out BOOLEAN; EXTRAINFO :out EXTRAINFO_TYPE ) is
    ACTUALS_ACCEPTED	: NATURAL			:= 0;
    NAMED_FIRST		: NATURAL;

    PARAM_CURSOR		: PARAM_CURSOR_TYPE;
    PARAM_SYM		: TREE;
    NEW_ACTUALS_OK		: BOOLEAN;
    NEW_EXTRAINFO		: EXTRAINFO_TYPE		:= NULL_EXTRAINFO;
    SUB_EXTRAINFO		: EXTRAINFO_TYPE;
    ACTUAL_SEEN		: BOOLEAN;
  begin
    INIT_PARAM_CURSOR( PARAM_CURSOR, LIST( D( AS_PARAM_S, HEADER ) ) );

          -- PROCESS POSITIONAL PARAMETERS
    for I in ACTUAL'RANGE loop
      exit when ACTUAL( I ).SYM /= TREE_VOID;

      ADVANCE_PARAM_CURSOR( PARAM_CURSOR );
      if PARAM_CURSOR.ID = TREE_VOID then
        ACTUALS_OK := FALSE;
        EXTRAINFO  := NULL_EXTRAINFO;
        return;
      end if;

      CHECK_ACTUAL_TYPE( GET_BASE_TYPE( D( SM_OBJ_TYPE, PARAM_CURSOR.ID ) ), ACTUAL( I ).TYPESET, NEW_ACTUALS_OK, SUB_EXTRAINFO );
      if not NEW_ACTUALS_OK then
        ACTUALS_OK := FALSE;
        EXTRAINFO  := NULL_EXTRAINFO;
        return;
      end if;

      ADD_EXTRAINFO( NEW_EXTRAINFO, SUB_EXTRAINFO );
      ACTUALS_ACCEPTED := I;
    end loop;

          --PROCESS DEFAULT AND NAMED PARAMETERS
    NAMED_FIRST := ACTUALS_ACCEPTED + 1;
    loop
      ADVANCE_PARAM_CURSOR( PARAM_CURSOR );
      exit when PARAM_CURSOR.ID = TREE_VOID;

      PARAM_SYM   := D( LX_SYMREP, PARAM_CURSOR.ID );
      ACTUAL_SEEN := FALSE;
      for I in NAMED_FIRST .. ACTUAL'LAST loop
        if PARAM_SYM = ACTUAL( I ).SYM then
          CHECK_ACTUAL_TYPE( GET_BASE_TYPE( D( SM_OBJ_TYPE, PARAM_CURSOR.ID ) ), ACTUAL( I ).TYPESET, NEW_ACTUALS_OK, SUB_EXTRAINFO );
          if NEW_ACTUALS_OK then
            ACTUAL_SEEN := TRUE;
            ADD_EXTRAINFO( NEW_EXTRAINFO, SUB_EXTRAINFO );
            ACTUALS_ACCEPTED := ACTUALS_ACCEPTED + 1;
            exit;
          else
            ACTUALS_OK := FALSE;
            EXTRAINFO  := NULL_EXTRAINFO;
            return;
          end if;
        end if;
      end loop;
      if not ACTUAL_SEEN and then D( SM_INIT_EXP, PARAM_CURSOR.ID ) = TREE_VOID then
        ACTUALS_OK := FALSE;
        EXTRAINFO  := NULL_EXTRAINFO;
        return;

      end if;
    end loop;
    if ACTUALS_ACCEPTED = ACTUAL'LENGTH then
      ACTUALS_OK := TRUE;
      EXTRAINFO  := NEW_EXTRAINFO;
    else
      ACTUALS_OK := FALSE;
      EXTRAINFO  := NULL_EXTRAINFO;
    end if;
  end CHECK_ACTUAL_LIST;
  --|-------------------------------------------------------------------------------------------
  --|
  procedure REDUCE_ARRAY_PREFIX_TYPES( NAME :TREE; NAME_TYPESET :in out TYPESET_TYPE; GEN_ASSOC_S :TREE; IS_SLICE_OUT :out BOOLEAN ) is
    ASSOC_LIST		: SEQ_TYPE		:= LIST( GEN_ASSOC_S );
    ACTUAL_COUNT		: NATURAL			:= LENGTH( ASSOC_LIST );

    ACTUAL		: ACTUAL_ARRAY_TYPE( 1 .. ACTUAL_COUNT );
    ACTUALS_OK		: BOOLEAN;

    TYPEINTERP		: TYPEINTERP_TYPE;
    NAME_STRUCT		: TREE;
    NEW_TYPESET		: TYPESET_TYPE		:= EMPTY_TYPESET;

    EXTRAINFO		: EXTRAINFO_TYPE;
    IS_SLICE 		: BOOLEAN			:= FALSE;
  begin
    for I in ACTUAL'RANGE loop
      POP( ASSOC_LIST, ACTUAL( I ).EXP );
      if ACTUAL( I ).EXP.TY = DN_ASSOC then
        ERROR( D( LX_SRCPOS, ACTUAL( I ).EXP ), "NAMED FOR SUBSCRIPT" );
        ACTUAL( I ).EXP := D( AS_EXP, ACTUAL( I ).EXP );
      end if;
      ACTUAL( I ).SYM := TREE_VOID;
    end loop;

    if ACTUAL'LAST = 1 then
      EVAL_EXP_SUBTYPE_TYPES( ACTUAL( 1 ).EXP, ACTUAL( 1 ).TYPESET, IS_SLICE );
      if IS_SLICE and then ACTUAL( 1 ).EXP.TY /= DN_RANGE then
                        --( RESOLVE NOW -- USED TO INDICATE SLICE LATER)
        REQUIRE_UNIQUE_TYPE( ACTUAL( 1 ).EXP, ACTUAL( 1 ).TYPESET );
        ACTUAL( 1 ).EXP := RESOLVE_DISCRETE_RANGE( ACTUAL( 1 ).EXP, GET_THE_TYPE( ACTUAL( 1 ).TYPESET ) );
      end if;
      LIST( GEN_ASSOC_S, SINGLETON( ACTUAL( 1 ).EXP ) );
    else
      for I in ACTUAL'RANGE loop
        EVAL_EXP_TYPES( ACTUAL( I ).EXP, ACTUAL( I ).TYPESET );
      end loop;
    end if;
    IS_SLICE_OUT := IS_SLICE;

    if IS_EMPTY( NAME_TYPESET ) then
      return;
    end if;

    while not IS_EMPTY( NAME_TYPESET ) loop
      POP( NAME_TYPESET, TYPEINTERP );

      ACTUALS_OK  := FALSE;
      NAME_STRUCT := GET_BASE_STRUCT( GET_TYPE( TYPEINTERP ) );
      if NAME_STRUCT.TY = DN_ACCESS then
        NAME_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, NAME_STRUCT ) );
      end if;
      if NAME_STRUCT.TY = DN_ARRAY and then LENGTH( LIST( D( SM_INDEX_S, NAME_STRUCT ) ) ) = ACTUAL'LENGTH then
        CHECK_SUBSCRIPT_LIST( NAME_STRUCT, ACTUAL, ACTUALS_OK, EXTRAINFO );
        if ACTUALS_OK then
          ADD_EXTRAINFO( TYPEINTERP, EXTRAINFO );
          ADD_TO_TYPESET( NEW_TYPESET, TYPEINTERP );
        end if;
      end if;
    end loop;

    if IS_EMPTY( NEW_TYPESET ) then
      ERROR( D( LX_SRCPOS, NAME ), "SUBSCRIPT TYPE MISMATCH" );
    end if;

    NAME_TYPESET := NEW_TYPESET;
  end REDUCE_ARRAY_PREFIX_TYPES;
  --|-------------------------------------------------------------------------------------------
  --|
  procedure CHECK_SUBSCRIPT_LIST( ARRAY_TYPE :TREE; ACTUAL :ACTUAL_ARRAY_TYPE; ACTUALS_OK :out BOOLEAN; EXTRAINFO :out EXTRAINFO_TYPE ) is
    INDEX_LIST		: SEQ_TYPE		:= LIST( D( SM_INDEX_S, ARRAY_TYPE ) );
    INDEX			: TREE;
    NEW_EXTRAINFO		: EXTRAINFO_TYPE		:= NULL_EXTRAINFO;
    NEW_ACTUALS_OK		: BOOLEAN			:= TRUE;
    SUB_EXTRAINFO 		: EXTRAINFO_TYPE;
  begin
    for I in ACTUAL'RANGE loop
      if IS_EMPTY( INDEX_LIST ) then
        ACTUALS_OK := FALSE;
        EXTRAINFO  := NULL_EXTRAINFO;
        return;
      end if;

      POP( INDEX_LIST, INDEX );
      CHECK_ACTUAL_TYPE( GET_BASE_TYPE( D( SM_TYPE_SPEC, INDEX ) ), ACTUAL( I ).TYPESET, NEW_ACTUALS_OK, SUB_EXTRAINFO );
      if NEW_ACTUALS_OK then
        ADD_EXTRAINFO( NEW_EXTRAINFO, SUB_EXTRAINFO );
      else
        ACTUALS_OK := FALSE;
        EXTRAINFO  := NULL_EXTRAINFO;
        return;
      end if;
    end loop;

    if not IS_EMPTY( INDEX_LIST ) then
      ACTUALS_OK := FALSE;
      EXTRAINFO  := NULL_EXTRAINFO;
      return;
    end if;

    ACTUALS_OK := TRUE;
    EXTRAINFO  := NEW_EXTRAINFO;
  end CHECK_SUBSCRIPT_LIST;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  procedure CHECK_ACTUAL_TYPE( FORMAL_TYPE :TREE; ACTUAL_TYPESET :TYPESET_TYPE; ACTUALS_OK :out BOOLEAN; EXTRAINFO :out EXTRAINFO_TYPE ) is
    TYPESET	: TYPESET_TYPE	:= ACTUAL_TYPESET;
    TYPEINTERP	: TYPEINTERP_TYPE;
    TYPE_SPEC	: TREE;

    FORMAL_STRUCT	: TREE;
  begin
    ACTUALS_OK := TRUE;
    EXTRAINFO  := NULL_EXTRAINFO;

    while not IS_EMPTY( TYPESET ) loop
      POP( TYPESET, TYPEINTERP );

      TYPE_SPEC := GET_TYPE( TYPEINTERP );

      if TYPE_SPEC = FORMAL_TYPE then
        EXTRAINFO := GET_EXTRAINFO( TYPEINTERP );
        return;

      elsif TYPE_SPEC.TY in CLASS_UNSPECIFIED_TYPE then
        FORMAL_STRUCT := GET_BASE_STRUCT( FORMAL_TYPE );
        case CLASS_UNSPECIFIED_TYPE'(TYPE_SPEC.TY ) is
          when DN_ANY_ACCESS =>
            if FORMAL_STRUCT.TY = DN_ACCESS then
              return;
            end if;
          when DN_ANY_COMPOSITE =>
            if IS_NONLIMITED_COMPOSITE_TYPE( FORMAL_TYPE ) then
              return;
            end if;
          when DN_ANY_STRING =>
            if IS_STRING_TYPE( FORMAL_TYPE ) then
              return;
            end if;
          when DN_ANY_ACCESS_OF =>
            if FORMAL_STRUCT.TY = DN_ACCESS then
              if GET_BASE_TYPE( D( SM_DESIG_TYPE, FORMAL_STRUCT ) ) = D( XD_ITEM, TYPE_SPEC ) then
                return;
              end if;
            end if;
          when DN_ANY_INTEGER =>
            if IS_INTEGER_TYPE( FORMAL_TYPE ) then
              return;
            end if;
          when DN_ANY_REAL =>
            if IS_REAL_TYPE( FORMAL_TYPE ) then
              return;
            end if;
        end case;

      elsif FORMAL_TYPE.TY = DN_UNIVERSAL_FIXED then
        if GET_BASE_STRUCT( TYPE_SPEC ).TY = DN_FIXED then
          EXTRAINFO := GET_EXTRAINFO( TYPEINTERP );
          return;
        end if;
      end if;
    end loop;

    ACTUALS_OK := FALSE;
  end CHECK_ACTUAL_TYPE;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  function RESOLVE_SUBP_PARAMETERS( DEF :TREE; GEN_ASSOC_S :TREE ) return TREE is
          -- RESOLVES ALL PARAMETER EXPRESSIONS
          -- AND RETURNS THE NORMALIZED PARAMETER LIST

    type ACTUAL_TYPE	is record
			  SYM	: TREE;
			  ASSOC	: TREE;
			end record;

    ACTUAL_LIST		: SEQ_TYPE	:= LIST( GEN_ASSOC_S );
    ACTUAL_TAIL		: SEQ_TYPE	:= ACTUAL_LIST;

    ACTUAL		: array( 1 .. LENGTH( ACTUAL_LIST ) ) of ACTUAL_TYPE;
    POSITIONAL_LAST		: NATURAL		:= 0;

    DEF_HEADER		: TREE		:= D( XD_HEADER, DEF );
    PARAM_S		: TREE;

    PARAM_CURSOR		: PARAM_CURSOR_TYPE;

    EXP			: TREE;
    ACTUAL_SUB		: NATURAL;
    NEW_ASSOC_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
    NEW_NORM_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);

  begin

          -- GET THE SEQUENCE OF PARAMETERS
    if DEF_HEADER.TY in CLASS_SUBP_ENTRY_HEADER then
      PARAM_S := D( AS_PARAM_S, D( XD_HEADER, DEF ) );
    else
      PARAM_S := D( AS_PARAM_S, D( SM_SPEC, D( XD_SOURCE_NAME, DEF ) ) );
    end if;

          -- UNPACK THE ACTUALS
    for I in ACTUAL'RANGE loop
      POP( ACTUAL_LIST, ACTUAL( I ).ASSOC );
      if ACTUAL( I ).ASSOC.TY = DN_ASSOC then
        ACTUAL( I ).SYM := D( LX_SYMREP, D( AS_USED_NAME, ACTUAL( I ).ASSOC ) );
      else
        ACTUAL( I).SYM  := TREE_VOID;
        POSITIONAL_LAST := I;
        ACTUAL_TAIL     := ACTUAL_LIST;
      end if;
    end loop;

          -- FOR EACH POSITIONAL FORMAL
    INIT_PARAM_CURSOR( PARAM_CURSOR, LIST( PARAM_S ) );
    for I in 1 .. POSITIONAL_LAST loop
      ADVANCE_PARAM_CURSOR( PARAM_CURSOR );

                   -- RESOLVE THE ASSOCIATED ACTUAL
      EXP := RESOLVE_EXP_OR_UNIV_FIXED( ACTUAL( I ).ASSOC, D( SM_OBJ_TYPE, PARAM_CURSOR.ID ) );

                   -- ADD TO NEW PARAMETER LIST AND NORMALIZED LIST
      NEW_ASSOC_LIST := APPEND( NEW_ASSOC_LIST, EXP );
      NEW_NORM_LIST  := APPEND( NEW_NORM_LIST, EXP );
    end loop;

          -- ADD NAMED PARAMETERS TO END OF PARAMETER LIST
    if not IS_EMPTY( ACTUAL_TAIL ) then
      NEW_ASSOC_LIST := APPEND( NEW_ASSOC_LIST, ACTUAL_TAIL.FIRST );
    end if;

          -- FOR EACH NAMED FORMAL
    loop
      ADVANCE_PARAM_CURSOR( PARAM_CURSOR );
      exit when PARAM_CURSOR.ID = TREE_VOID;

                   -- SEARCH FOR MATCHING PARAMETER
      ACTUAL_SUB := POSITIONAL_LAST + 1;
      while ACTUAL_SUB <= ACTUAL'LAST loop
        if D( LX_SYMREP, PARAM_CURSOR.ID) = ACTUAL( ACTUAL_SUB ).SYM then
          exit;
        end if;
        ACTUAL_SUB := ACTUAL_SUB + 1;
      end loop;

                   -- IF THERE WAS ONE
      if ACTUAL_SUB <= ACTUAL'LAST then

                        -- RESOLVE THE ACTUAL EXPRESSION
        EXP := RESOLVE_EXP_OR_UNIV_FIXED( D( AS_EXP, ACTUAL( ACTUAL_SUB).ASSOC), D( SM_OBJ_TYPE, PARAM_CURSOR.ID ) );

                        -- PUT RESOLVED EXPRESSION IN THE ASSOCIATION
        D( AS_EXP, ACTUAL( ACTUAL_SUB).ASSOC, EXP );

                        -- NAME IN ASSOC IS USED NAME ID; CLEAR SM_DEFN
        D( SM_DEFN, D( AS_USED_NAME, ACTUAL( ACTUAL_SUB ).ASSOC), TREE_VOID );

                        -- ELSE -- SINCE NO ACTUAL GIVEN
      else

                        -- USE THE DEFAULT EXPRESSION
        EXP := D( SM_INIT_EXP, PARAM_CURSOR.ID );
      end if;

                   -- ADD RESOLVED EXPRESSION TO NORMALIZED LIST
      NEW_NORM_LIST := APPEND( NEW_NORM_LIST, EXP );
    end loop;

          -- SAVE THE MODIFIED GENERAL_ASSOC_S
    LIST( GEN_ASSOC_S, NEW_ASSOC_LIST );

          -- RETURN THE NORMALIZED LIST
    return MAKE_EXP_S( LIST => NEW_NORM_LIST );
  end RESOLVE_SUBP_PARAMETERS;
  --|-------------------------------------------------------------------------------------------
  --|
  function RESOLVE_EXP_OR_UNIV_FIXED ( EXP :TREE; TYPE_SPEC :TREE ) return TREE is
    TYPESET	: TYPESET_TYPE;
    TYPEINTERP	: TYPEINTERP_TYPE;
    NEW_TYPESET	: TYPESET_TYPE;
  begin
    if TYPE_SPEC.TY /= DN_UNIVERSAL_FIXED then
      if EXP.TY = DN_AGGREGATE then
        return RESOLVE_EXP_OR_AGGREGATE( EXP, TYPE_SPEC, NAMED_OTHERS_OK =>( TYPE_SPEC.TY = DN_CONSTRAINED_ARRAY ) );
      else
        return RESOLVE_EXP( EXP, GET_BASE_TYPE( TYPE_SPEC ) );
      end if;
    end if;

    TYPESET     := FETCH_TYPESET( EXP );
    NEW_TYPESET := EMPTY_TYPESET;
    while not IS_EMPTY( TYPESET ) loop
      POP( TYPESET, TYPEINTERP );
      if GET_TYPE( TYPEINTERP ).TY = DN_FIXED then
        ADD_TO_TYPESET( NEW_TYPESET, TYPEINTERP );
      end if;
    end loop;
    if IS_EMPTY( NEW_TYPESET ) then
      ERROR( D( LX_SRCPOS, EXP ), "**** NO TYPES IN RESOLVE UNIV FIX" );
    end if;
    REQUIRE_UNIQUE_TYPE( EXP, NEW_TYPESET );
    return RESOLVE_EXP( EXP, NEW_TYPESET );
  end RESOLVE_EXP_OR_UNIV_FIXED;
  --|-------------------------------------------------------------------------------------------
  --|
  function RESOLVE_SUBSCRIPTS( ARRAY_TYPE :TREE; GENERAL_ASSOC_S :TREE ) return TREE is
    ASSOC_LIST		: SEQ_TYPE	:= LIST( GENERAL_ASSOC_S );
    NEW_ASSOC_LIST		: SEQ_TYPE	:=( TREE_NIL, TREE_NIL );
    EXP			: TREE;
    INDEX_LIST		: SEQ_TYPE;
    INDEX			: TREE;

  begin
    if ARRAY_TYPE.TY = DN_ACCESS then
      INDEX_LIST := LIST( D( SM_INDEX_S, D( SM_DESIG_TYPE, ARRAY_TYPE ) ) );
    else
      INDEX_LIST := LIST( D( SM_INDEX_S, ARRAY_TYPE ) );
    end if;

    while not IS_EMPTY( ASSOC_LIST ) loop
      POP( ASSOC_LIST, EXP );
      POP( INDEX_LIST, INDEX );
      EXP            := RESOLVE_EXP( EXP, GET_BASE_TYPE( D( SM_TYPE_SPEC, INDEX ) ) );
      NEW_ASSOC_LIST := APPEND( NEW_ASSOC_LIST, EXP );
    end loop;

    return MAKE_EXP_S( LX_SRCPOS => D( LX_SRCPOS, GENERAL_ASSOC_S), LIST => NEW_ASSOC_LIST );
  end RESOLVE_SUBSCRIPTS;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  procedure RESOLVE_ERRONEOUS_PARAM_S( GENERAL_ASSOC_S :TREE) is
          -- PARAMETER LIST CAUSED NO FUNCTIONS TO BE SELECTED
          -- RESOLVE ALL PARAMETERS WITH INVALID TYPE

    PARAM_LIST	: SEQ_TYPE	:= LIST( GENERAL_ASSOC_S );
    PARAM		: TREE;
  begin

          -- FOR EACH PARAMETER IN THE PARAM_S
    while not IS_EMPTY( PARAM_LIST ) loop
      POP( PARAM_LIST, PARAM );

                   -- IF IT IS A NAMED ASSOCIATION
      if PARAM.TY = DN_ASSOC then

                        -- DISCARD THE NAME
        PARAM := D( AS_EXP, PARAM );
      end if;

                   -- RESOLVE PARAMETER AND IGNORE THE RESULT
      PARAM := RESOLVE_EXP( PARAM, TREE_VOID );
    end loop;
  end RESOLVE_ERRONEOUS_PARAM_S;
  --|-------------------------------------------------------------------------------------------
  --|
  function GET_ARRAY_COMPONENT_TYPE( TYPE_SPEC :TREE) return TREE is
    BASE_STRUCT	: TREE	:= GET_BASE_STRUCT( TYPE_SPEC );
  begin
    if BASE_STRUCT.TY = DN_ACCESS then
      BASE_STRUCT := GET_BASE_STRUCT( D( SM_DESIG_TYPE, BASE_STRUCT ) );
    end if;
    return GET_BASE_TYPE( D( SM_COMP_TYPE, BASE_STRUCT ) );
  end GET_ARRAY_COMPONENT_TYPE;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  function GET_TYPE_OF_DISCRETE_RANGE( DISCRETE_RANGE :TREE) return TREE is
  begin
    case DISCRETE_RANGE.TY is
      when DN_DISCRETE_SUBTYPE =>
        return GET_TYPE_OF_DISCRETE_RANGE( D( AS_SUBTYPE_INDICATION, DISCRETE_RANGE ) );
      when DN_SUBTYPE_INDICATION =>
        return GET_TYPE_OF_DISCRETE_RANGE( D( AS_NAME, DISCRETE_RANGE ) );
      when DN_RANGE | DN_RANGE_ATTRIBUTE =>
        return GET_BASE_TYPE( D( SM_TYPE_SPEC, DISCRETE_RANGE ) );
      when CLASS_DESIGNATOR | DN_SELECTED =>
        return GET_BASE_TYPE( DISCRETE_RANGE );
      when others =>
        PUT_LINE( "!! GET_TYPE_OF_DISCRETE_RANGE: INVALID PARAMETER" );
        raise PROGRAM_ERROR;
    end case;
  end GET_TYPE_OF_DISCRETE_RANGE;

--|----------------------------------------------------------------------------------------------
end RED_SUBP;
