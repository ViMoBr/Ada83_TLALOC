    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	FIX_WITH
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY FIX_WITH IS
   
      USE DEF_UTIL;
      USE SEM_GLOB;
      USE PRE_FCNS;
      USE REQ_UTIL;
      USE DERIVED; -- REMEMBER_DERIVED_DECL
   
        -- FIX UP TRANSITIVELY WITHED UNITS FOR THE GIVEN COMP UNIT
        -- I.E., CREATE DEF RECORDS FOR ID'S, ETC
   
        --$$$$TEMPORARY
       FUNCTION STORE_SYM ( TXTREP: TREE ) RETURN TREE IS
      BEGIN
         RETURN STORE_SYM ( PRINT_NAME ( TXTREP ) );
      END STORE_SYM;
   
        -- $$$ TEMPORARY
        
       FUNCTION MAKE_DEF_FOR_ID ( ID :TREE; REGION_DEF :TREE; IN_SPEC :BOOLEAN ) RETURN TREE IS
       
         H	: H_TYPE := (	REGION_DEF	=> REGION_DEF,
                        	RETURN_TYPE	=> TREE_VOID,
                        	ENCLOSING_LOOP_ID	=> TREE_VOID,
                        	IS_IN_SPEC	=> IN_SPEC,
                        	IS_IN_BODY	=> FALSE,
                        	LEX_LEVEL	=> 0,
                        	SUBP_SYMREP	=> TREE_VOID
         		);
      BEGIN
         IF REGION_DEF /= TREE_VOID THEN
            H.LEX_LEVEL := DI ( XD_LEX_LEVEL, REGION_DEF );
         END IF;
                -- $$$$ THE FOLLOWING IN CASE IT'S A TEXTREP
         IF D ( LX_SYMREP,ID).TY = DN_TXTREP THEN
            D ( LX_SYMREP, ID, STORE_SYM ( D ( LX_SYMREP, ID ) ) );
         END IF;
         
         RETURN DEF_UTIL.MAKE_DEF_FOR_ID ( ID, H );
      END MAKE_DEF_FOR_ID;
   
   
   
   
   
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	PROCEDURE FIX_WITH_CLAUSES
       PROCEDURE FIX_WITH_CLAUSES ( COMPLTN_UNIT :TREE ) IS
         TRANS_WITH_LIST	: SEQ_TYPE := LIST ( COMPLTN_UNIT);
         TRANS_WITH		: TREE;
         WITH_UNIT		: TREE;
         ALL_DECL		: TREE;
         SUBUNIT		: TREE	:= TREE_VOID;
         STANDARD_DEF	: TREE;
         REGION_DEF		: TREE;
      
          PROCEDURE ADD_BLTN_IDS_TO_TABLE(DECL_S2: TREE) IS
            SUBTYPE OP_CLASS IS PRENAME.OP_CLASS;
         
            ID_LIST:	SEQ_TYPE := LIST ( DECL_S2);
            ID:		TREE;
            SYMREP: 	TREE;
         BEGIN
                -- FOR EACH ITEM IN THE PRIVATE PART OF _STANDRD
            WHILE NOT IS_EMPTY ( ID_LIST) LOOP
               POP ( ID_LIST, ID);
                        -- IF IT IS A BLTN_OPERATOR_ID
               IF ID.TY = DN_BLTN_OPERATOR_ID THEN
                                -- FORCE A SYMREP IF SYMBOL IS USED
                  SYMREP := D ( LX_SYMREP, ID);
                  IF SYMREP.TY = DN_TXTREP THEN
                     SYMREP := STORE_SYM ( PRINT_NAME ( SYMREP ) );
                     IF SYMREP /= TREE_VOID THEN
                        D ( LX_SYMREP, ID, SYMREP);
                     END IF;
                  END IF;
                                -- IF SYMBOL IS USED
                  IF SYMREP /= TREE_VOID THEN
                                        -- ADD IT TO THE BUILTIN OPERATOR TABLE
                     PRENAME.BLTN_ID_ARRAY(OP_CLASS'VAL ( DI ( SM_OPERATOR, ID ) ) ) := ID;
                  END IF;
               END IF;
            END LOOP;
         END ADD_BLTN_IDS_TO_TABLE;
         --|----------------------------------------------------------------------------------------
         --|
          PROCEDURE FIX_WITH_ONE_DECL ( DECL, REGION_DEF_IN :TREE; IN_SPEC_IN : BOOLEAN; SUBUNIT_IN :TREE := TREE_VOID ) IS
            H	: H_TYPE := (
                        	REGION_DEF	=> REGION_DEF_IN,
                        	RETURN_TYPE	=> TREE_VOID,
                        	ENCLOSING_LOOP_ID	=> TREE_VOID,
                        	LEX_LEVEL	=> 0,
                        	IS_IN_SPEC	=> IN_SPEC_IN,
            		IS_IN_BODY	=> FALSE,
                        	SUBP_SYMREP	=> TREE_VOID
            		);
            SOURCE_NAME_LIST	: SEQ_TYPE;
            SOURCE_NAME	: TREE;
            DEF		: TREE;
            TYPE_DEF	: TREE;
            BASE_TYPE	: TREE;
            BASE_STRUCT	: TREE;
            HEADER		: TREE;
            --|-------------------------------------------------------------------------------------
            --|	PROCEDURE FIX_WITH_DECL_LIST
             PROCEDURE FIX_WITH_DECL_LIST ( DECL_LIST_IN :SEQ_TYPE; REGION_DEF :TREE; IN_SPEC :BOOLEAN; SUBUNIT_IN :TREE := TREE_VOID ) IS
               DECL_LIST	: SEQ_TYPE	:= DECL_LIST_IN;
               DECL		: TREE;
            BEGIN
               WHILE NOT IS_EMPTY ( DECL_LIST) LOOP
                  POP ( DECL_LIST, DECL );
               
                  IF DECL.TY IN CLASS_ALL_DECL THEN
                     IF DECL.TY = DN_USE AND SUBUNIT_IN = TREE_VOID THEN
                        NULL;
                     ELSE
                        FIX_WITH_ONE_DECL ( DECL, REGION_DEF, IN_SPEC );
                     END IF;
                  END IF;
               
                  EXIT WHEN				--| THIS IS STUB FOR CURRENT COMP UNIT BODY
                     DECL.TY IN CLASS_SUBUNIT_BODY
                     AND THEN D ( AS_BODY, DECL ).TY = DN_STUB
                     AND THEN SUBUNIT_IN.TY = DN_SUBUNIT
                     AND THEN IS_ANCESTOR ( D ( SM_FIRST,D ( AS_SOURCE_NAME, DECL ) ), SUBUNIT_IN );
               
               END LOOP;
            END FIX_WITH_DECL_LIST;
            --|-------------------------------------------------------------------------------------
            --|
             FUNCTION MAKE_DEF_IF_NEEDED ( SOURCE_NAME, REGION_DEF_IN :TREE; IN_SPEC_IN :BOOLEAN ) RETURN TREE IS
               REGION_DEF	: TREE	:= REGION_DEF_IN;
               IN_SPEC	: BOOLEAN	:= IN_SPEC_IN;
               FIRST_NAME	: TREE	:= SOURCE_NAME;
               DEF		: TREE	:= TREE_VOID;
            BEGIN
               CASE CLASS_DEF_NAME'(SOURCE_NAME.TY) IS
                  WHEN DN_VARIABLE_ID | DN_NUMBER_ID | CLASS_ENUM_LITERAL | DN_SUBTYPE_ID |
                       DN_PRIVATE_TYPE_ID | DN_L_PRIVATE_TYPE_ID | DN_GENERIC_ID | DN_COMPONENT_ID |
                  	   DN_EXCEPTION_ID =>
                     IF D ( LX_SYMREP, SOURCE_NAME ).TY = DN_SYMBOL_REP THEN
                        DEF := MAKE_DEF_FOR_ID ( SOURCE_NAME, REGION_DEF, IN_SPEC );
                        MAKE_DEF_VISIBLE ( DEF );
                     END IF;
                  WHEN DN_ENTRY_ID =>
                     IF D ( LX_SYMREP,SOURCE_NAME ).TY = DN_SYMBOL_REP THEN
                        DEF := MAKE_DEF_FOR_ID ( 
                                                SOURCE_NAME, REGION_DEF,
                                                IN_SPEC);
                        IF D ( AS_DISCRETE_RANGE, D ( SM_SPEC,
                                                                SOURCE_NAME)) =
                                                        TREE_VOID
                                                        THEN
                           MAKE_DEF_VISIBLE(DEF, D ( 
                                                                SM_SPEC,
                                                                SOURCE_NAME));
                        ELSE
                           MAKE_DEF_VISIBLE(DEF);
                        END IF;
                     END IF;
                  WHEN DN_CONSTANT_ID | DN_DISCRIMINANT_ID |
                                        CLASS_PARAM_NAME
                                        | DN_TASK_BODY_ID =>
                     FIRST_NAME := D ( SM_FIRST, SOURCE_NAME);
                     IF FIRST_NAME /= SOURCE_NAME THEN
                        IF D ( LX_SYMREP,FIRST_NAME).TY =
                                                        DN_TXTREP THEN
                           DEF := MAKE_DEF_FOR_ID ( FIRST_NAME, REGION_DEF, IN_SPEC );
                        ELSE
                           DEF := GET_DEF_FOR_ID ( FIRST_NAME );
                        END IF;
                     ELSIF D ( LX_SYMREP,FIRST_NAME).TY = DN_SYMBOL_REP THEN
                        DEF := MAKE_DEF_FOR_ID ( FIRST_NAME, REGION_DEF, IN_SPEC );
                        MAKE_DEF_VISIBLE ( DEF );
                     END IF;
                  WHEN CLASS_SUBPROG_NAME =>
                     FIRST_NAME := D ( SM_FIRST, SOURCE_NAME);
                     IF FIRST_NAME /= SOURCE_NAME THEN
                        IF D ( LX_SYMREP,FIRST_NAME).TY = DN_TXTREP THEN
                           DEF := MAKE_DEF_FOR_ID ( FIRST_NAME, REGION_DEF, IN_SPEC );
                        ELSE
                           DEF := GET_DEF_FOR_ID ( FIRST_NAME );
                        END IF;
                     ELSIF D ( LX_SYMREP,FIRST_NAME).TY = DN_SYMBOL_REP THEN
                        DEF := MAKE_DEF_FOR_ID ( FIRST_NAME,
                                                REGION_DEF, IN_SPEC);
                        MAKE_DEF_VISIBLE ( DEF, D ( SM_SPEC, SOURCE_NAME ) );
                     END IF;
                  WHEN DN_TYPE_ID | DN_PACKAGE_ID =>
                     FIRST_NAME := D ( SM_FIRST, SOURCE_NAME);
                     IF FIRST_NAME /= SOURCE_NAME THEN
                        IF D ( LX_SYMREP,FIRST_NAME).TY = DN_TXTREP THEN
                           DEF := MAKE_DEF_FOR_ID ( FIRST_NAME, REGION_DEF, IN_SPEC );
                        ELSE
                           DEF := GET_DEF_FOR_ID ( FIRST_NAME );
                        END IF;
                     ELSE
                        IF D ( LX_SYMREP,SOURCE_NAME).TY /= DN_SYMBOL_REP THEN
                           D ( LX_SYMREP, SOURCE_NAME, STORE_SYM ( D ( LX_SYMREP, SOURCE_NAME ) ) );
                        END IF;
                        DEF := MAKE_DEF_FOR_ID ( SOURCE_NAME, REGION_DEF, IN_SPEC );
                        MAKE_DEF_VISIBLE ( DEF );
                     END IF;
               
                  WHEN CLASS_PREDEF_NAME | DN_ITERATION_ID | CLASS_LABEL_NAME =>
                     PUT_LINE ( "!! BAD ID IN MAKE_DEF_IF_NEEDED" );
                     RAISE PROGRAM_ERROR;
               END CASE;
            
               RETURN DEF;
            END MAKE_DEF_IF_NEEDED;
            --|-------------------------------------------------------------------------------------
            --|
             PROCEDURE REPROCESS_ANCESTOR_USE_CLAUSE ( USE_NODE :TREE ) IS
               NAME_S	: TREE	:= D ( AS_NAME_S, USE_NODE );
               NAME_LIST	: SEQ_TYPE	:= LIST ( NAME_S);
               NAME		: TREE;
               NAME_DEFN	: TREE;
               PACKAGE_DEF	: TREE;
            BEGIN
               WHILE NOT IS_EMPTY ( NAME_LIST) LOOP
                  POP ( NAME_LIST, NAME);
                  LOOP
                     IF NAME.TY = DN_SELECTED THEN
                        NAME := D ( AS_DESIGNATOR, NAME );
                     END IF;
                     NAME_DEFN := D ( SM_DEFN, NAME );
                     EXIT WHEN NAME_DEFN.TY /= DN_PACKAGE_ID OR ELSE D ( SM_UNIT_DESC, NAME_DEFN).TY /= DN_RENAMES_UNIT;
                     NAME := D ( AS_NAME, D ( SM_UNIT_DESC, NAME_DEFN ) );
                  END LOOP;
                  IF NAME_DEFN.TY = DN_PACKAGE_ID THEN
                     PACKAGE_DEF := (GET_DEF_FOR_ID(NAME_DEFN));
                     DB(XD_IS_USED, PACKAGE_DEF, TRUE);
                     USED_PACKAGE_LIST := INSERT ( USED_PACKAGE_LIST, PACKAGE_DEF );
                  END IF;
               END LOOP;
            END REPROCESS_ANCESTOR_USE_CLAUSE;
            --|-------------------------------------------------------------------------------------
            --|
             PROCEDURE SET_REGION_LEVEL ( DEF :TREE; LEVEL :INTEGER ) IS
            BEGIN
               IF DEF /= TREE_VOID THEN
                  DI ( XD_LEX_LEVEL, DEF, LEVEL );
               END IF;
            END;
            --|-------------------------------------------------------------------------------------
            --|
             PROCEDURE FIX_WITH_COMP_LIST ( COMP_LIST: TREE; REGION_DEF: TREE) IS
               VARIANT_PART	: CONSTANT TREE	:= D ( AS_VARIANT_PART, COMP_LIST );
               VARIANT_LIST	: SEQ_TYPE;
               VARIANT	: TREE;
            BEGIN
               FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S,COMP_LIST ) ), REGION_DEF, FALSE );
               IF VARIANT_PART /= TREE_VOID THEN
                  VARIANT_LIST := LIST ( D ( AS_VARIANT_S,VARIANT_PART ) );
                  WHILE NOT IS_EMPTY ( VARIANT_LIST ) LOOP
                     POP ( VARIANT_LIST, VARIANT );
                     IF VARIANT.TY = DN_VARIANT THEN
                        FIX_WITH_COMP_LIST ( D ( AS_COMP_LIST, VARIANT ), REGION_DEF );
                     END IF;
                  END LOOP;
               END IF;
            END FIX_WITH_COMP_LIST;
         
         BEGIN
            IF REGION_DEF_IN /= TREE_VOID THEN
               H.LEX_LEVEL := DI ( XD_LEX_LEVEL, REGION_DEF_IN );
            END IF;
            
            CASE CLASS_ALL_DECL'( DECL.TY ) IS
            
               WHEN DN_BLOCK_MASTER | DN_SUBUNIT =>
                  PUT_LINE ( "!! BAD NODE IN FIX_WITH_ONE_DECL");
                  RAISE PROGRAM_ERROR;
                  
               WHEN CLASS_OBJECT_DECL =>
                  SOURCE_NAME_LIST := LIST ( D ( AS_SOURCE_NAME_S, DECL ) );
                  WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST ) LOOP
                     POP ( SOURCE_NAME_LIST, SOURCE_NAME );
                     DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                     IF D ( AS_TYPE_DEF,DECL).TY = DN_CONSTRAINED_ARRAY_DEF THEN
                        SET_REGION_LEVEL ( DEF, H.LEX_LEVEL + 1 );
                        GEN_PREDEFINED_OPERATORS ( D ( SM_OBJ_TYPE, SOURCE_NAME ), H );
                        SET_REGION_LEVEL ( DEF, 0 );
                     END IF;
                  END LOOP;
                  
               WHEN CLASS_DSCRMT_PARAM_DECL | DN_NUMBER_DECL | DN_EXCEPTION_DECL | DN_DEFERRED_CONSTANT_DECL =>
                  SOURCE_NAME_LIST := LIST ( D ( AS_SOURCE_NAME_S, DECL ) );
                  WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST) LOOP
                     POP ( SOURCE_NAME_LIST, SOURCE_NAME );
                     DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                  END LOOP;
                  
               WHEN DN_TYPE_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL );
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                  SET_REGION_LEVEL(DEF, H.LEX_LEVEL + 1 );
                  FIX_WITH_DECL_LIST ( LIST ( D ( AS_DSCRMT_DECL_S, DECL ) ), DEF, FALSE );
                  TYPE_DEF := D ( AS_TYPE_DEF, DECL );
                  BASE_TYPE := GET_BASE_TYPE ( D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, DECL ) ) );
                  BASE_STRUCT := GET_BASE_STRUCT ( BASE_TYPE );
                  
                  IF TYPE_DEF = TREE_VOID OR ELSE TYPE_DEF.TY IN DN_PRIVATE_DEF .. DN_FORMAL_FLOAT_DEF THEN
                     NULL;
                     
                  ELSIF BASE_STRUCT.TY = DN_ENUMERATION THEN
                     DECLARE				--| PRÉPARER UN HEADER POUR LES LITTÉRAUX ÉNUMÉRÉS
                        PARAM_S	: TREE	:= MAKE ( DN_PARAM_S );
                        FUNCTION_SPEC	: TREE	:= MAKE ( DN_FUNCTION_SPEC );
                        USED_NAME_ID	: TREE	:= MAKE ( DN_USED_NAME_ID );
                     BEGIN
                        LIST ( PARAM_S, (TREE_NIL,TREE_NIL) );
                        D( LX_SRCPOS, PARAM_S, TREE_VOID );
                     
                        D( LX_SRCPOS, USED_NAME_ID, TREE_VOID );
                        D( LX_SYMREP, USED_NAME_ID, TREE_VOID );
                        D( SM_DEFN, USED_NAME_ID, SOURCE_NAME );
                     
                        D( AS_PARAM_S,	FUNCTION_SPEC, PARAM_S );
                        D( AS_NAME,	FUNCTION_SPEC, USED_NAME_ID );
                        D( LX_SRCPOS,	FUNCTION_SPEC, TREE_VOID );
                        
                        HEADER := FUNCTION_SPEC;
                     END;	
                  		
                     SOURCE_NAME_LIST := LIST ( D ( SM_LITERAL_S, BASE_STRUCT ) );
                     WHILE NOT IS_EMPTY ( SOURCE_NAME_LIST ) LOOP
                        POP ( SOURCE_NAME_LIST, SOURCE_NAME );
                        DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                        IF DEF /= TREE_VOID THEN
                           D ( XD_HEADER, DEF, HEADER );
                        END IF;
                     END LOOP;
                     
                  ELSIF BASE_STRUCT.TY = DN_RECORD THEN
                     FIX_WITH_COMP_LIST ( D ( SM_COMP_LIST, BASE_STRUCT ), DEF );
                  END IF;
                                -- (OPS FOR [L-]PRIVATE CREATED AT FULL DECLARATION)
                  IF TYPE_DEF.TY = DN_PRIVATE_DEF THEN
                     DECLARE
                        HOLD_TYPE_SPEC	: TREE;
                     BEGIN
                        BASE_TYPE := D ( SM_TYPE_SPEC, D ( AS_SOURCE_NAME, DECL ) );
                        IF BASE_TYPE.TY IN CLASS_CONSTRAINED THEN
                           BASE_TYPE := D ( SM_BASE_TYPE, BASE_TYPE );
                        END IF;
                        IF BASE_TYPE.TY /= DN_PRIVATE THEN
                           PUT_LINE ( "!! TYPE PRIVATE EXPECTED" );
                           RAISE PROGRAM_ERROR;
                        END IF;
                        HOLD_TYPE_SPEC := D ( SM_TYPE_SPEC, BASE_TYPE );
                        D ( SM_TYPE_SPEC, BASE_TYPE, TREE_VOID );
                        GEN_PREDEFINED_OPERATORS ( BASE_TYPE, H );
                        D ( SM_TYPE_SPEC, BASE_TYPE, HOLD_TYPE_SPEC );
                     END;
                  ELSIF TYPE_DEF.TY /= DN_L_PRIVATE_DEF THEN
                     GEN_PREDEFINED_OPERATORS ( BASE_TYPE, H );
                  END IF;
                  
                  IF TYPE_DEF.TY = DN_DERIVED_DEF THEN
                     REMEMBER_DERIVED_DECL ( DECL );
                     DECLARE
                        DERIVED_SUBP_LIST	: SEQ_TYPE	:= LIST ( TYPE_DEF );
                        DERIVED_SUBP_ID		: TREE;
                        DUMMY		: TREE;
                     BEGIN
                        WHILE NOT IS_EMPTY ( DERIVED_SUBP_LIST ) LOOP
                           POP ( DERIVED_SUBP_LIST, DERIVED_SUBP_ID );
                           DUMMY := MAKE_DEF_IF_NEEDED ( DERIVED_SUBP_ID, H.REGION_DEF, H.IS_IN_SPEC );
                        END LOOP;
                     END;
                  END IF;
                  SET_REGION_LEVEL ( DEF, 0 );
                  
               WHEN DN_TASK_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL );
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                  SET_REGION_LEVEL(DEF, H.LEX_LEVEL + 1);
                  FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S, DECL)),
                                        DEF, TRUE);
                  SET_REGION_LEVEL(DEF, 0);
                  
               WHEN DN_SUBPROG_ENTRY_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL);
                  DEF := MAKE_DEF_IF_NEEDED (  SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC);
                  SET_REGION_LEVEL(DEF, H.LEX_LEVEL + 1);
                  FIX_WITH_DECL_LIST (  LIST ( D ( AS_PARAM_S, D ( AS_HEADER, DECL ) ) ), DEF, TRUE);
                  SET_REGION_LEVEL ( DEF, 0 );
                  
               WHEN DN_GENERIC_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL);
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME,
                                        H.REGION_DEF, H.IS_IN_SPEC);
                  SET_REGION_LEVEL ( DEF, H.LEX_LEVEL + 1 );
                  FIX_WITH_DECL_LIST (  LIST ( D ( AS_ITEM_S, DECL ) ), DEF, FALSE );
                  IF D ( AS_HEADER,DECL).TY IN CLASS_SUBP_ENTRY_HEADER THEN
                     FIX_WITH_DECL_LIST (  LIST ( D ( AS_PARAM_S, D ( AS_HEADER, DECL ) ) ), DEF, FALSE );
                  ELSE -- SINCE IT IS A GENERIC PACKAGE
                     HEADER := D ( AS_HEADER, DECL);
                     FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S1, HEADER ) ), DEF, TRUE );
                     FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S2, HEADER ) ), DEF, FALSE );
                  END IF;
                  SET_REGION_LEVEL(DEF, 0);
                  
               WHEN DN_PACKAGE_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL);
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                  SET_REGION_LEVEL ( DEF, H.LEX_LEVEL + 1 );
                                -- (NOTE: GET SPEC FROM SOURCE NAME IN CASE IT IS AN INSTANTIATION)
                  HEADER := D ( SM_SPEC, SOURCE_NAME );
                  IF HEADER /= TREE_VOID THEN
                     FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S1, HEADER ) ), DEF, TRUE, SUBUNIT_IN );
                     IF NOT H.IS_IN_BODY OR ELSE SUBUNIT_IN /= TREE_VOID THEN
                        FIX_WITH_DECL_LIST ( LIST ( D ( AS_DECL_S2, HEADER)), DEF, FALSE, SUBUNIT_IN );
                     END IF;
                  END IF;
                  SET_REGION_LEVEL(DEF, 0);
                  
               WHEN DN_SUBTYPE_DECL | CLASS_SIMPLE_RENAME_DECL =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL);
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME, H.REGION_DEF, H.IS_IN_SPEC );
                  
               WHEN DN_NULL_COMP_DECL | CLASS_REP | DN_PRAGMA =>
                  NULL;
                  
               WHEN DN_USE =>				-- NOTE. ONLY GET HERE FOR ANCESTORS
                  REPROCESS_ANCESTOR_USE_CLAUSE ( DECL );
                  
               WHEN CLASS_SUBUNIT_BODY =>
                  SOURCE_NAME := D ( AS_SOURCE_NAME, DECL);
                  DEF := MAKE_DEF_IF_NEEDED ( SOURCE_NAME,
                                        H.REGION_DEF, FALSE);
                  SET_REGION_LEVEL(DEF, H.LEX_LEVEL + 1);
                  IF D ( AS_BODY, DECL).TY = DN_BLOCK_BODY
                    AND THEN SUBUNIT_IN /= TREE_VOID THEN
                     FIX_WITH_DECL_LIST ( LIST ( D ( AS_ITEM_S, D ( AS_BODY, DECL ) ) ), DEF, FALSE, SUBUNIT_IN );
                  ELSIF D ( AS_BODY, DECL).TY = DN_STUB
                    AND THEN D ( SM_FIRST, SOURCE_NAME ) = SOURCE_NAME
                  	AND THEN D ( AS_HEADER, DECL).TY IN CLASS_SUBP_ENTRY_HEADER THEN
                     FIX_WITH_DECL_LIST ( LIST ( D ( AS_PARAM_S,D ( AS_HEADER, DECL ) ) ), DEF, FALSE );
                  END IF;
                  SET_REGION_LEVEL ( DEF, 0 );
            END CASE;
         END FIX_WITH_ONE_DECL;
      
      BEGIN
         REMEMBER_DERIVED_DECL ( TREE_VOID );
      
                -- FIRST, DO PREDEFINED STANDARD
         POP ( TRANS_WITH_LIST, TRANS_WITH );
         WITH_UNIT := D ( TW_COMP_UNIT, TRANS_WITH );
         ALL_DECL := D ( AS_ALL_DECL, WITH_UNIT );
                -- ADD BLTN_OPERATOR_ID'S TO TABLE
         ADD_BLTN_IDS_TO_TABLE ( D ( AS_DECL_S2, D ( AS_HEADER, ALL_DECL ) ) );
                -- WALK PACKAGE_DECL FOR _STANDRD
         SUBUNIT := D ( AS_ALL_DECL, COMPLTN_UNIT );
         FIX_WITH_ONE_DECL ( ALL_DECL, TREE_VOID, IN_SPEC_IN => TRUE
                        , SUBUNIT_IN => SUBUNIT );
                -- FIND DEF FOR PREDEFINED STANDARD
         STANDARD_DEF := GET_DEF_FOR_ID
                        ( D ( AS_SOURCE_NAME
                                , HEAD(LIST (D ( AS_DECL_S1, D ( AS_HEADER,
                                                                ALL_DECL))) )));
                -- SET ITS LEVEL TO 2 AND SET LEVEL OF _STANDRD TO 1
         DI(XD_LEX_LEVEL, STANDARD_DEF, 2);
         DI(XD_LEX_LEVEL, D ( XD_REGION_DEF,STANDARD_DEF), 1);
                -- SAVE IT IN GLOBAL DATA AREA
         PREDEFINED_STANDARD_DEF := STANDARD_DEF;
      
                -- MAKE DEFS FOR PREDEFINED FUNCTIONS ON UNVERSAL TYPES
         DECLARE
            H: H_TYPE := ( REGION_DEF => STANDARD_DEF
                                , RETURN_TYPE => TREE_VOID
                                , ENCLOSING_LOOP_ID => TREE_VOID
                                , LEX_LEVEL => 2
                                , IS_IN_SPEC => TRUE
                                , IS_IN_BODY => FALSE
                                , SUBP_SYMREP => TREE_VOID );
         BEGIN
            GEN_PREDEFINED_OPERATORS(MAKE(
                                        DN_UNIVERSAL_INTEGER), H);
            GEN_PREDEFINED_OPERATORS(MAKE(DN_UNIVERSAL_FIXED),
                                H);
            GEN_PREDEFINED_OPERATORS(MAKE(DN_UNIVERSAL_REAL),
                                H);
         END;
      
                -- LOOP THROUGH REMAINING TRANSITIVELY WITHED UNITS
                -- NOTE THAT FOR BODIES, ENCLOSING UNIT DETERMINED FROM SM_FIRST
                -- NOTE ALSO THAT FOR BODIES, IN_SPEC IS FORCED TO FALSE
         WHILE NOT IS_EMPTY ( TRANS_WITH_LIST) LOOP
            POP ( TRANS_WITH_LIST, TRANS_WITH);
            SUBUNIT := D ( AS_ALL_DECL, COMPLTN_UNIT );
            WITH_UNIT := D ( TW_COMP_UNIT, TRANS_WITH );
            ALL_DECL := D ( AS_ALL_DECL, WITH_UNIT );
            REGION_DEF := STANDARD_DEF;
            IF ALL_DECL.TY = DN_SUBUNIT THEN
               ALL_DECL := D ( AS_SUBUNIT_BODY, ALL_DECL );
               REGION_DEF := GET_DEF_FOR_ID ( D ( XD_REGION,D ( AS_SOURCE_NAME, ALL_DECL ) ) );
            ELSIF ALL_DECL.TY = DN_PACKAGE_DECL OR ALL_DECL.TY = DN_SUBPROGRAM_BODY THEN
                                -- SUPPRESS USE CLAUSES IN WITHED PACKAGES
               IF SUBUNIT.TY = DN_PACKAGE_BODY THEN
                  IF D ( AS_SOURCE_NAME, ALL_DECL) /= D ( SM_FIRST, D ( AS_SOURCE_NAME, SUBUNIT ) ) THEN
                     SUBUNIT := TREE_VOID;
                  END IF;
               ELSIF SUBUNIT.TY = DN_SUBUNIT THEN
                  IF ALL_DECL.TY = DN_SUBPROGRAM_BODY THEN
                     IF NOT IS_ANCESTOR ( D ( SM_FIRST, D ( AS_SOURCE_NAME, ALL_DECL ) ), SUBUNIT ) THEN
                        SUBUNIT := TREE_VOID;
                     END IF;
                  ELSE
                     IF NOT IS_ANCESTOR ( D ( AS_SOURCE_NAME, ALL_DECL ), SUBUNIT ) THEN
                        SUBUNIT := TREE_VOID;
                     END IF;
                  END IF;
               ELSE
                  SUBUNIT := TREE_VOID;
               END IF;
            END IF;
            FIX_WITH_ONE_DECL ( ALL_DECL, REGION_DEF, IN_SPEC_IN => TRUE, SUBUNIT_IN => SUBUNIT );
                        -- CLEAR PARENT, SO THAT UNIT IS NOT WITH'ED
            D ( XD_REGION_DEF, GET_DEF_FOR_ID ( D ( SM_FIRST, D ( AS_SOURCE_NAME, ALL_DECL ) ) ), TREE_VOID );
         END LOOP;
      END FIX_WITH_CLAUSES;
   
   
   
   
   
   
   
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION IS_ANCESTOR
       FUNCTION IS_ANCESTOR ( UNIT_ID, SUBUNIT :TREE ) RETURN BOOLEAN IS
         PRIOR_UNIT		: TREE	:= UNIT_ID;
         ANCESTOR_NAME	: TREE	:= D ( AS_NAME, SUBUNIT );
      BEGIN
         IF D ( LX_SYMREP, D ( AS_SOURCE_NAME, D ( AS_SUBUNIT_BODY, SUBUNIT ) ) ) 
            = D ( LX_SYMREP, UNIT_ID ) THEN			--| NAME OF STUB UNIT IS NAME OF CURRENT SUBUNIT
            NULL;
         ELSE
            WHILE ANCESTOR_NAME.TY = DN_SELECTED LOOP
               IF D ( LX_SYMREP, D ( AS_DESIGNATOR, ANCESTOR_NAME ) ) = D ( LX_SYMREP, UNIT_ID ) THEN	-- NAME OF STUB UNIT IS NAME OF ANCESTOR OF CURRENT UNIT
                  EXIT;
               END IF;
               ANCESTOR_NAME := D ( AS_NAME, ANCESTOR_NAME );
            END LOOP;
            IF ANCESTOR_NAME.TY /= DN_SELECTED THEN
                                -- NAME OF STUB IS NOT CURRENT UNIT
                                -- NAME OF STUB IS NOT ANCESTOR OTHER THAN LIBRARY UNIT
                                -- MAYBE IT'S LIBRARY UNIT
               IF D ( LX_SYMREP, ANCESTOR_NAME) = D ( LX_SYMREP, UNIT_ID ) THEN
                  RETURN TRUE;
               ELSE
                  RETURN FALSE;
               END IF;
            END IF;
         END IF;
                -- GET NAME OF LIBRARY UNIT
         WHILE ANCESTOR_NAME.TY = DN_SELECTED LOOP
            ANCESTOR_NAME := D ( AS_NAME, ANCESTOR_NAME );
         END LOOP;
                -- GET LIBRARY UNIT OF STUB
         WHILE D ( XD_REGION, PRIOR_UNIT ) /= TREE_VOID
            AND D ( XD_REGION, PRIOR_UNIT ) /= D ( XD_SOURCE_NAME, PREDEFINED_STANDARD_DEF) LOOP
            PRIOR_UNIT := D ( XD_REGION, PRIOR_UNIT );
         END LOOP;
                -- THIS IS STUB IF LIBRARY UNIT NAMES MATCH
         RETURN D ( LX_SYMREP, PRIOR_UNIT) = D ( LX_SYMREP, ANCESTOR_NAME );
      END IS_ANCESTOR;
      
   --|----------------------------------------------------------------------------------------------
   END FIX_WITH;
