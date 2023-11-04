    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	REP_CLAU
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY REP_CLAU IS
      USE DEF_UTIL;
      USE VIS_UTIL;
      USE MAKE_NOD;
      USE EXP_TYPE, EXPRESO;
      USE REQ_UTIL;
      USE SET_UTIL;
      USE ATT_WALK;
      USE NOD_WALK;
   
        -- $$$$ SHOULD NOT BE HERE
      --|-------------------------------------------------------------------------------------------
      --|
       PROCEDURE REQUIRE_CURRENT_REGION
                        ( NAME: TREE
                        ; DEFSET: IN OUT DEFSET_TYPE
                        ; H: H_TYPE )
                        IS
         TEMP_DEFSET: DEFSET_TYPE := DEFSET;
         TEMP_DEFINTERP: DEFINTERP_TYPE;
         TEMP_DEF: TREE;
         SOURCE_NAME: TREE;
         UNIT_DESC: TREE;
      BEGIN
         IF IS_EMPTY ( TEMP_DEFSET) THEN
            RETURN;
         END IF;
      
         DEFSET := EMPTY_DEFSET;
         WHILE NOT IS_EMPTY ( TEMP_DEFSET) LOOP
            POP ( TEMP_DEFSET, TEMP_DEFINTERP);
            TEMP_DEF := GET_DEF(TEMP_DEFINTERP);
         
            IF D ( XD_REGION_DEF, TEMP_DEF) = H.REGION_DEF
                                        AND THEN NOT (H.IS_IN_BODY AND DB(
                                                XD_IS_IN_SPEC, TEMP_DEF)) THEN
                                -- $$$$ DON'T KNOW IF DERIVED IS LEGAL $$$$ ASSUME NOT
               SOURCE_NAME := D ( XD_SOURCE_NAME,TEMP_DEF);
               IF SOURCE_NAME.TY = DN_BLTN_OPERATOR_ID THEN
                  NULL;
               ELSIF SOURCE_NAME.TY IN
                                                CLASS_SUBPROG_NAME THEN
                  UNIT_DESC := D ( SM_UNIT_DESC,
                                                SOURCE_NAME);
                  IF UNIT_DESC.TY /=
                                                        DN_RENAMES_UNIT
                                                        AND THEN UNIT_DESC.TY
                                                        NOT IN
                                                        DN_IMPLICIT_NOT_EQ
                                                        ..
                                                        DN_DERIVED_SUBPROG
                                                        THEN
                     ADD_TO_DEFSET(DEFSET,
                                                        TEMP_DEFINTERP);
                  END IF;
               ELSE
                  ADD_TO_DEFSET(DEFSET,
                                                TEMP_DEFINTERP);
               END IF;
            END IF;
         END LOOP;
      
         IF IS_EMPTY ( DEFSET) THEN
            ERROR ( D ( LX_SRCPOS,NAME),
                                "MUST BE IN CURRENT REGION");
         END IF;
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_LENGTH_REP(ATTRIBUTE: TREE; EXP: IN OUT TREE; H:
                        H_TYPE)
                        IS
         USE PRENAME;
         ATTRIBUTE_ID: TREE;
         PREFIX: TREE := D ( AS_NAME, ATTRIBUTE);
         PREFIX_TYPE: TREE := EVAL_TYPE_MARK ( PREFIX);
         TYPESET: TYPESET_TYPE;
         STATIC_VALUE: TREE := TREE_VOID;
      BEGIN
         ATTRIBUTE_ID := EVAL_ATTRIBUTE_IDENTIFIER(ATTRIBUTE);
         PREFIX := RESOLVE_TYPE_MARK ( PREFIX);
         D ( AS_NAME, ATTRIBUTE, PREFIX);
         D ( SM_EXP_TYPE, ATTRIBUTE, TREE_VOID);
         EVAL_EXP_TYPES(EXP, TYPESET);
         IF ATTRIBUTE_ID /= TREE_VOID THEN
            CASE DEFINED_ATTRIBUTES'VAL(DI(XD_POS,
                                                        ATTRIBUTE_ID)) IS
               WHEN SIZE =>
                  REQUIRE_INTEGER_TYPE(EXP, TYPESET);
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  EXP := RESOLVE_EXP ( EXP, TYPESET);
                  IF NOT IS_EMPTY ( TYPESET) THEN
                     STATIC_VALUE :=
                                                        GET_STATIC_VALUE(
                                                        EXP);
                     IF STATIC_VALUE =
                                                                TREE_VOID THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        EXP),
                                                                "STATIC EXPRESSION REQUIRED");
                     END IF;
                  END IF;
                  IF PREFIX_TYPE.TY IN
                                                        CLASS_SCALAR THEN
                     D ( CD_IMPL_SIZE,
                                                        PREFIX_TYPE,
                                                        STATIC_VALUE);
                  ELSIF PREFIX_TYPE.TY =
                                                        DN_TASK_SPEC
                                                        OR PREFIX_TYPE.TY IN
                                                        CLASS_UNCONSTRAINED THEN
                     D ( SM_SIZE, PREFIX_TYPE,
                                                        STATIC_VALUE);
                  END IF;
               WHEN STORAGE_SIZE =>
                  REQUIRE_INTEGER_TYPE(EXP, TYPESET);
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  EXP := RESOLVE_EXP ( EXP, TYPESET);
                  IF PREFIX_TYPE.TY /=
                                                        DN_TASK_SPEC
                                                        AND PREFIX_TYPE.TY /=
                                                        DN_ACCESS THEN
                     ERROR ( D ( LX_SRCPOS,
                                                                ATTRIBUTE)
                                                        ,
                                                        "MUST BE ACCESS OR TASK TYPE");
                  ELSE
                     D ( SM_STORAGE_SIZE,
                                                        PREFIX_TYPE, EXP);
                  END IF;
               WHEN SMALL =>
                  REQUIRE_REAL_TYPE(EXP, TYPESET);
                  REQUIRE_UNIQUE_TYPE(EXP, TYPESET);
                  EXP := RESOLVE_EXP ( EXP, TYPESET);
                  IF NOT IS_EMPTY ( TYPESET) THEN
                     STATIC_VALUE :=
                                                        GET_STATIC_VALUE(
                                                        EXP);
                     IF STATIC_VALUE =
                                                                TREE_VOID THEN
                        ERROR ( D ( LX_SRCPOS,
                                                                        EXP),
                                                                "STATIC EXPRESSION REQUIRED");
                     END IF;
                  END IF;
                  IF PREFIX_TYPE.TY /= DN_FIXED THEN
                     ERROR ( D ( LX_SRCPOS,
                                                                ATTRIBUTE)
                                                        ,
                                                        "MUST BE FIXED POINT TYPE");
                  ELSE
                     D ( CD_IMPL_SMALL,
                                                        PREFIX_TYPE,
                                                        STATIC_VALUE);
                     DECLARE
                        USE UARITH;
                        PREFIX_SUBTYPE:
                                                                TREE
                                                                := D ( 
                                                                SM_TYPE_SPEC,
                                                                D ( SM_DEFN,
                                                                        PREFIX));
                        POW_32: TREE :=
                                                                U_VALUE(
                                                                "16#100000000#");
                     BEGIN
                        IF PREFIX_SUBTYPE.TY IN
                                                                        DN_PRIVATE ..
                                                                        DN_L_PRIVATE
                                                                        THEN
                           PREFIX_SUBTYPE :=
                                                                        D ( 
                                                                        SM_TYPE_SPEC,
                                                                        PREFIX_SUBTYPE);
                        ELSIF PREFIX_SUBTYPE.TY = DN_INCOMPLETE THEN
                           PREFIX_SUBTYPE
                                                                        :=
                                                                        D ( 
                                                                        XD_FULL_TYPE_SPEC,
                                                                        PREFIX_SUBTYPE);
                        END IF;
                        IF PREFIX_SUBTYPE.TY = DN_FIXED THEN
                           D ( 
                                                                        CD_IMPL_SMALL,
                                                                        PREFIX_SUBTYPE,
                                                                        STATIC_VALUE);
                        END IF;
                        D ( SM_VALUE, D ( 
                                                                        AS_EXP1,
                                                                        D ( 
                                                                                SM_RANGE,
                                                                                PREFIX_TYPE))
                                                                , (-
                                                                        POW_32) *
                                                                STATIC_VALUE );
                        D ( SM_VALUE, D ( 
                                                                        AS_EXP2,
                                                                        D ( 
                                                                                SM_RANGE,
                                                                                PREFIX_TYPE))
                                                                , (POW_32 -
                                                                        U_VAL(
                                                                                1)) *
                                                                STATIC_VALUE );
                     END;
                  END IF;
               WHEN OTHERS =>
                  ERROR ( D ( LX_SRCPOS,D ( 
                                                                AS_USED_NAME_ID,
                                                                ATTRIBUTE))
                                                ,
                                                "THIS ATTRIBUTE NOT ALLOWED IN LENGTH CLAUSE");
                  EXP := RESOLVE_EXP ( EXP, TREE_VOID);
            END CASE;
         END IF;
      END RESOLVE_LENGTH_REP;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_ENUM_REP(SIMPLE_NAME: IN OUT TREE; EXP: TREE; H:
                        H_TYPE)
                        IS
         ENUM_TYPE		: TREE	:= EVAL_TYPE_MARK (  SIMPLE_NAME );
         DUMMY		: TREE;
         ENUM_LIST		: SEQ_TYPE;
         ENUM		: TREE;
         ITEM_LIST		: SEQ_TYPE;
         ITEM		: TREE;
         CHOICE		: TREE;
         CHOICE_VALUE	: TREE;
         CURRENT_VALUE	: TREE;
         PRIOR_VALUE	: TREE	:= TREE_VOID;
         DUMMY_ARRAY_TYPE	: TREE;
      BEGIN
         SIMPLE_NAME := RESOLVE_TYPE_MARK ( SIMPLE_NAME );
         IF ENUM_TYPE.TY /= DN_ENUMERATION THEN
            DUMMY := RESOLVE_EXP ( EXP, TREE_VOID);
            RETURN;
         END IF;
                -- (JUST IN CASE IT DOESN'T RESOLVE)
         D ( SM_NORMALIZED_COMP_S, EXP, MAKE_GENERAL_ASSOC_S( (TREE_NIL,TREE_NIL) ) );
      
         DUMMY_ARRAY_TYPE := MAKE_ARRAY ( SM_COMP_TYPE => MAKE ( DN_UNIVERSAL_INTEGER ), SM_INDEX_S => MAKE_INDEX_S( SINGLETON ( ENUM_TYPE ) ));
         D ( SM_BASE_TYPE, DUMMY_ARRAY_TYPE, DUMMY_ARRAY_TYPE);
         DUMMY := RESOLVE_EXP ( EXP, DUMMY_ARRAY_TYPE);
         D ( SM_EXP_TYPE, EXP, TREE_VOID );
      
                -- CHECK AND INSERT VALUES
         ENUM_LIST := LIST ( D ( SM_LITERAL_S, ENUM_TYPE));
         ITEM_LIST := LIST ( D ( SM_NORMALIZED_COMP_S, EXP));
         IF IS_EMPTY ( ITEM_LIST) THEN
            RETURN;
         END IF;
      
         WHILE NOT IS_EMPTY ( ENUM_LIST) LOOP
            POP ( ENUM_LIST, ENUM);
            IF IS_EMPTY ( ITEM_LIST) THEN
               ERROR ( D ( LX_SRCPOS,EXP), "TOO FEW VALUES");
               RETURN;
            END IF;
            POP ( ITEM_LIST, ITEM);
            IF ITEM.TY = DN_NAMED THEN
               CHOICE := HEAD ( LIST ( D ( AS_CHOICE_S, ITEM)));
               ITEM := D ( AS_EXP, ITEM);
               IF CHOICE.TY = DN_CHOICE_EXP THEN
                  CHOICE_VALUE := GET_STATIC_VALUE( D ( AS_EXP,CHOICE ) );
               ELSIF CHOICE.TY = DN_CHOICE_RANGE AND THEN D ( AS_DISCRETE_RANGE, CHOICE).TY = DN_RANGE THEN
                  CHOICE_VALUE := GET_STATIC_VALUE ( D ( AS_EXP1, D ( AS_DISCRETE_RANGE, CHOICE)) );
                  IF CHOICE_VALUE /= TREE_VOID
                     AND THEN NOT UARITH.U_EQUAL ( CHOICE_VALUE, D ( AS_EXP2, D ( AS_DISCRETE_RANGE, CHOICE)) )
                  THEN
                     ERROR ( D ( LX_SRCPOS,CHOICE),
                                                        "DUPLICATES NOT ALLOWED");
                     RETURN;
                  END IF;
               ELSE
                  CHOICE_VALUE := TREE_VOID;
               END IF;
               IF CHOICE_VALUE = TREE_VOID THEN
                  ERROR ( D ( LX_SRCPOS,CHOICE), "MUST BE STATIC, NOT OTHERS");
                  RETURN;
               ELSIF NOT UARITH.U_EQUAL ( CHOICE_VALUE, D ( SM_POS, ENUM) ) THEN
                  ERROR ( D ( LX_SRCPOS,CHOICE), "MUST EXACTLY MATCH ENUM LITS");
                  RETURN;
               END IF;
            END IF;
            CURRENT_VALUE := GET_STATIC_VALUE( ITEM );
            IF CURRENT_VALUE = TREE_VOID THEN
               ERROR ( D ( LX_SRCPOS,EXP), "STATIC VALUE REQUIRED" );
               RETURN;
            END IF;
            
            IF DI(SM_POS, ENUM) /= 0 AND THEN UARITH."<="( CURRENT_VALUE, PRIOR_VALUE ) THEN
               ERROR ( D ( LX_SRCPOS,EXP), "VALUES MUST BE IN ORDER" );
            END IF;
            PRIOR_VALUE := CURRENT_VALUE;
            D ( SM_REP, ENUM, CURRENT_VALUE);
         END LOOP;
      
         IF NOT IS_EMPTY ( ITEM_LIST) THEN
            ERROR ( D ( LX_SRCPOS,HEAD ( ITEM_LIST)), "TOO MANY VALUES" );
         END IF;
      END;
--|#################################################################################################
--|	PROCEDURE RESOLVE_ADDRESS_REP
PROCEDURE RESOLVE_ADDRESS_REP ( SIMPLE_NAME: IN OUT TREE; EXP: IN OUT TREE; H: H_TYPE ) IS
  NAME_DEFSET	: DEFSET_TYPE;
  NAME_ID	: TREE := TREE_VOID;
  TYPESET	: TYPESET_TYPE;
BEGIN
  FIND_DIRECT_VISIBILITY ( SIMPLE_NAME, NAME_DEFSET );
  REQUIRE_CURRENT_REGION ( SIMPLE_NAME, NAME_DEFSET, H );
  REQUIRE_UNIQUE_DEF ( SIMPLE_NAME, NAME_DEFSET );
  NAME_ID := GET_THE_ID ( NAME_DEFSET );
  CASE NAME_ID.TY IS
  WHEN CLASS_OBJECT_NAME =>
    STASH_DEFSET ( SIMPLE_NAME, NAME_DEFSET );
    SIMPLE_NAME := RESOLVE_EXP ( SIMPLE_NAME, GET_BASE_TYPE ( NAME_ID ) );
  WHEN CLASS_SUBPROG_NAME =>
    SIMPLE_NAME := RESOLVE_NAME ( SIMPLE_NAME, NAME_ID );
  WHEN DN_TYPE_ID =>
    IF D ( SM_TYPE_SPEC, NAME_ID).TY /= DN_TASK_SPEC THEN
      ERROR ( D ( LX_SRCPOS, SIMPLE_NAME ), "ADDRESS CLAUSE NOT ALLOWED" );
      NAME_ID := TREE_VOID;
    END IF;
  WHEN DN_ENTRY_ID =>
    SIMPLE_NAME := RESOLVE_NAME ( SIMPLE_NAME, NAME_ID );
    IF D ( SM_SPEC, NAME_ID ).TY = DN_ENTRY
    AND THEN D ( AS_DISCRETE_RANGE, D ( SM_SPEC, NAME_ID ) ) /= TREE_VOID
    THEN
      ERROR ( D ( LX_SRCPOS, SIMPLE_NAME ), "ADDRESS FOR ENTRY FAMILY" );
      NAME_ID := TREE_VOID;
    END IF;
  WHEN DN_VOID =>
    NULL;
  WHEN OTHERS =>
    ERROR ( D ( LX_SRCPOS, SIMPLE_NAME ), "ADDRESS CLAUSE NOT ALLOWED" );
    NAME_ID := TREE_VOID;
  END CASE;
      
  IF PREDEFINED_ADDRESS = TREE_VOID THEN
    ERROR ( D ( LX_SRCPOS, EXP ), "PREDEFINED SYSTEM NOT WITHED" );
  END IF;
  EVAL_EXP_TYPES ( EXP, TYPESET );
  REQUIRE_TYPE ( GET_BASE_TYPE ( PREDEFINED_ADDRESS ), EXP, TYPESET );
  EXP := RESOLVE_EXP ( EXP, TYPESET );

  CASE NAME_ID.TY IS
  WHEN CLASS_OBJECT_NAME =>
    D ( SM_ADDRESS, NAME_ID, EXP);
    IF D ( SM_OBJ_TYPE, NAME_ID ).TY = DN_TASK_SPEC THEN
      D ( SM_ADDRESS, D ( SM_OBJ_TYPE, NAME_ID ), EXP );
    END IF;
  WHEN CLASS_SUBPROG_NAME | DN_ENTRY_ID =>
    D ( SM_ADDRESS, NAME_ID, EXP );
  WHEN CLASS_TYPE_NAME =>
    D ( SM_ADDRESS, D ( SM_TYPE_SPEC, NAME_ID ), EXP );
  WHEN OTHERS =>
    NULL;
  END CASE;
END RESOLVE_ADDRESS_REP;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE RESOLVE_RECORD_REP
                        ( SIMPLE_NAME:	IN OUT TREE
                        ; ALIGNMENT:	TREE
                        ; COMP_REP_S:	TREE
                        ; H:		H_TYPE )
                        IS
         DEFSET: DEFSET_TYPE;
         NAME_ID: TREE;
         NAME_TYPE: TREE;
         RECORD_DEF: TREE;
         TYPESET: TYPESET_TYPE;
         REP_LIST: SEQ_TYPE :=LIST ( COMP_REP_S);
         COMP_REP: TREE;
         REP_NAME: TREE;
         REP_EXP: TREE;
         REP_RANGE: TREE;
         IS_SUBTYPE: BOOLEAN;
         DEFLIST: SEQ_TYPE;
         DEF: TREE;
      BEGIN
         FIND_DIRECT_VISIBILITY(SIMPLE_NAME, DEFSET);
         REQUIRE_UNIQUE_DEF(SIMPLE_NAME, DEFSET);
         NAME_ID := GET_THE_ID(DEFSET);
         IF NAME_ID.TY NOT IN CLASS_TYPE_NAME
                                OR ELSE GET_BASE_TYPE(NAME_ID).TY /=
                                DN_RECORD THEN
            NAME_ID := TREE_VOID;
            ERROR ( D ( LX_SRCPOS,SIMPLE_NAME),
                                "MUST BE RECORD TYPE");
            RECORD_DEF := TREE_VOID;
         ELSE
            NAME_TYPE := GET_BASE_TYPE(NAME_ID);
            RECORD_DEF := GET_DEF(HEAD ( DEFSET));
         END IF;
         SIMPLE_NAME := MAKE_USED_NAME_ID_FROM_OBJECT (SIMPLE_NAME);
         D ( SM_DEFN, SIMPLE_NAME, NAME_ID);
      
         WALK_ITEM_S(D ( AS_PRAGMA_S,ALIGNMENT), H);
         IF D ( AS_EXP,ALIGNMENT) /= TREE_VOID THEN
            EVAL_EXP_TYPES(D ( AS_EXP,ALIGNMENT), TYPESET);
            REQUIRE_INTEGER_TYPE(D ( AS_EXP,ALIGNMENT),TYPESET);
            REQUIRE_UNIQUE_TYPE(D ( AS_EXP,ALIGNMENT),TYPESET);
            D ( AS_EXP, ALIGNMENT, RESOLVE_EXP ( D ( AS_EXP,
                                                ALIGNMENT),TYPESET));
            IF NOT IS_EMPTY ( TYPESET)
                                        AND THEN GET_STATIC_VALUE(D ( 
                                                AS_EXP,ALIGNMENT)) =
                                        TREE_VOID THEN
               ERROR ( D ( LX_SRCPOS,ALIGNMENT),
                                        "ALIGNMENT NOT STATIC");
            END IF;
         END IF;
      
         WHILE NOT IS_EMPTY ( REP_LIST) LOOP
            POP ( REP_LIST, COMP_REP);
            IF COMP_REP.TY = DN_COMP_REP THEN
               REP_NAME := D ( AS_NAME, COMP_REP);
               REP_EXP := D ( AS_EXP, COMP_REP);
               REP_RANGE := D ( AS_RANGE, COMP_REP);
            
               REP_NAME := MAKE_USED_NAME_ID_FROM_OBJECT(
                                        REP_NAME);
               D ( SM_DEFN, REP_NAME, TREE_VOID);
               IF RECORD_DEF /= TREE_VOID THEN
                  DEFLIST :=LIST ( D ( LX_SYMREP,
                                                        REP_NAME));
                  WHILE NOT IS_EMPTY ( DEFLIST) LOOP
                     POP ( DEFLIST,DEF);
                     IF D ( XD_REGION_DEF,DEF) =
                                                                RECORD_DEF THEN
                        D ( SM_DEFN,
                                                                REP_NAME,
                                                                D ( 
                                                                        XD_SOURCE_NAME,
                                                                        DEF));
                        EXIT;
                     END IF;
                  END LOOP;
                  IF D ( SM_DEFN, REP_NAME) =
                                                        TREE_VOID THEN
                     ERROR ( D ( LX_SRCPOS,
                                                                REP_NAME)
                                                        ,
                                                        "NOT A COMPONENT OF RECORD");
                  END IF;
               END IF;
            
               EVAL_EXP_TYPES(REP_EXP, TYPESET);
               REQUIRE_INTEGER_TYPE(REP_EXP, TYPESET);
               REQUIRE_UNIQUE_TYPE(REP_EXP, TYPESET);
               REP_EXP := RESOLVE_EXP ( REP_EXP, TYPESET);
            
               EVAL_EXP_SUBTYPE_TYPES(REP_RANGE, TYPESET,
                                        IS_SUBTYPE);
               REQUIRE_INTEGER_TYPE(REP_RANGE, TYPESET);
               REQUIRE_UNIQUE_TYPE(REP_RANGE, TYPESET);
               REP_RANGE := RESOLVE_DISCRETE_RANGE
                                        (REP_RANGE, GET_THE_TYPE(TYPESET));
               IF REP_RANGE.TY = DN_RANGE
                                                AND THEN GET_STATIC_VALUE(
                                                D ( AS_EXP1,REP_RANGE)) /=
                                                TREE_VOID
                                                AND THEN GET_STATIC_VALUE(
                                                D ( AS_EXP2,REP_RANGE)) /=
                                                TREE_VOID
                                                THEN
                  NULL;
               ELSE
                  ERROR ( D ( LX_SRCPOS, REP_RANGE),
                                                "STATIC RANGE REQUIRED");
               END IF;
            
               D ( AS_NAME, COMP_REP, REP_NAME);
               D ( AS_EXP, COMP_REP, REP_EXP);
               D ( AS_RANGE, COMP_REP, REP_RANGE);
            ELSE -- MUST BE PRAGMA
               WALK(D ( AS_PRAGMA,COMP_REP), H);
            END IF;
         END LOOP;
      END RESOLVE_RECORD_REP;
   
   --|----------------------------------------------------------------------------------------------
   END REP_CLAU;
