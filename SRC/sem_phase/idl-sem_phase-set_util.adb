    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	SET_UTIL
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY SET_UTIL IS
      USE DEF_UTIL;
      USE PRENAME;
      USE VIS_UTIL;
   
       FUNCTION IS_MEMBER(ITEM_LIST: SEQ_TYPE; ITEM: TREE) RETURN BOOLEAN;
       PROCEDURE REDUCE_UNIQUE
                ( ITEM_LIST: IN OUT SEQ_TYPE
                ; IS_CONFLICT: OUT BOOLEAN );
       FUNCTION COMBINE_EXTRAINFO(EXTRAINFO_1, EXTRAINFO_2:
                EXTRAINFO_TYPE)
                RETURN EXTRAINFO_TYPE;
   
        --======================================================================
   
       FUNCTION GET_DEF(DEFINTERP: DEFINTERP_TYPE) RETURN TREE IS
         DEF:		TREE := TREE(DEFINTERP);
      BEGIN
         IF DEF.TY = DN_IMPLICIT_CONV
                                OR ELSE DEF.TY = DN_NULLARY_CALL THEN
            DEF := D(XD_ITEM, DEF);
         END IF;
         RETURN DEF;
      END GET_DEF;
   
        ------------------------------------------------------------------------
   
       FUNCTION IS_NULLARY(DEFINTERP: DEFINTERP_TYPE) RETURN BOOLEAN IS
      BEGIN
         RETURN TREE(DEFINTERP).TY = DN_NULLARY_CALL;
      
      END IS_NULLARY;
   
        ------------------------------------------------------------------------
   
       FUNCTION GET_EXTRAINFO(DEFINTERP: DEFINTERP_TYPE) RETURN EXTRAINFO_TYPE IS
      BEGIN
         IF TREE(DEFINTERP).TY = DN_IMPLICIT_CONV THEN
            DECLARE
               S1 : SEQ_TYPE:= LIST( TREE( DEFINTERP ) );
            BEGIN
               RETURN EXTRAINFO_TYPE( S1 );
            END;
         ELSE
            RETURN NULL_EXTRAINFO;
         END IF;
      END GET_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       FUNCTION IS_EMPTY(DEFSET: DEFSET_TYPE) RETURN BOOLEAN IS
      BEGIN
         RETURN IS_EMPTY(SEQ_TYPE(DEFSET));
      END IS_EMPTY;
   
        ------------------------------------------------------------------------
   
       FUNCTION HEAD(DEFSET: DEFSET_TYPE) RETURN DEFINTERP_TYPE IS
      BEGIN
         RETURN DEFINTERP_TYPE(HEAD(SEQ_TYPE(DEFSET)));
      END HEAD;
   
        ------------------------------------------------------------------------
   
       PROCEDURE POP(DEFSET: IN OUT DEFSET_TYPE; DEFINTERP: OUT
                        DEFINTERP_TYPE) IS
         TREE_DEFINTERP: TREE;
      BEGIN
                -- (NOTE.  VERDIX DOES NOT ACCEPT CONVERSION ON OUT PARAMETER)
                --POP(SEQ_TYPE(DEFSET), TREE(DEFINTERP));
         POP(SEQ_TYPE(DEFSET), TREE_DEFINTERP);
         DEFINTERP := DEFINTERP_TYPE(TREE_DEFINTERP);
      END POP;
   
        ------------------------------------------------------------------------
   
       FUNCTION GET_TYPE(TYPEINTERP: TYPEINTERP_TYPE) RETURN TREE IS
         TYPE_SPEC:	TREE := TREE(TYPEINTERP);
      BEGIN
         IF TYPE_SPEC.TY = DN_IMPLICIT_CONV THEN
            TYPE_SPEC := D(XD_ITEM, TYPE_SPEC);
         END IF;
         RETURN TYPE_SPEC;
      END GET_TYPE;
   
        ------------------------------------------------------------------------
   
       FUNCTION GET_EXTRAINFO(TYPEINTERP: TYPEINTERP_TYPE) RETURN EXTRAINFO_TYPE IS
      BEGIN
         IF TREE(TYPEINTERP).TY = DN_IMPLICIT_CONV THEN
            DECLARE
               S1 : SEQ_TYPE:= LIST( TREE( TYPEINTERP ) );
            BEGIN
               RETURN EXTRAINFO_TYPE( S1 );
            END;
         ELSE
            RETURN NULL_EXTRAINFO;
         END IF;
      END GET_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       FUNCTION IS_EMPTY(TYPESET: TYPESET_TYPE) RETURN BOOLEAN IS
      BEGIN
         RETURN IS_EMPTY(SEQ_TYPE(TYPESET));
      END IS_EMPTY;
   
        ------------------------------------------------------------------------
   
       FUNCTION HEAD(TYPESET: TYPESET_TYPE) RETURN TYPEINTERP_TYPE IS
      BEGIN
         RETURN TYPEINTERP_TYPE(HEAD(SEQ_TYPE(TYPESET)));
      END HEAD;
   
        ------------------------------------------------------------------------
   
       PROCEDURE POP ( TYPESET: IN OUT TYPESET_TYPE
                        ; TYPEINTERP: OUT TYPEINTERP_TYPE)
                        IS
         TREE_TYPEINTERP: TREE;
      BEGIN
                -- (NOTE.  VERDIX DOES NOT ACCEPT CONVERSION ON OUT PARAMETER)
                --POP(SEQ_TYPE(TYPESET), TREE(TYPEINTERP));
         POP(SEQ_TYPE(TYPESET), TREE_TYPEINTERP);
         TYPEINTERP := TYPEINTERP_TYPE(TREE_TYPEINTERP);
      END POP;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_TO_DEFSET ( DEFSET: IN OUT DEFSET_TYPE
                        ; DEFINTERP: DEFINTERP_TYPE )
                        IS
         DEFLIST: SEQ_TYPE := SEQ_TYPE(DEFSET);
      BEGIN
         DEFLIST := APPEND(DEFLIST, TREE(DEFINTERP));
         DEFSET := DEFSET_TYPE(DEFLIST);
      END ADD_TO_DEFSET;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_TO_DEFSET ( DEFSET: IN OUT DEFSET_TYPE
                        ; DEF: TREE
                        ; EXTRAINFO: EXTRAINFO_TYPE := NULL_EXTRAINFO
                        ; IS_NULLARY: BOOLEAN := FALSE )
                        IS
         DEFLIST: SEQ_TYPE := SEQ_TYPE(DEFSET);
         DEFTREE: TREE;
      BEGIN
         IF NOT IS_EMPTY(SEQ_TYPE(EXTRAINFO)) THEN
            DEFTREE := MAKE(DN_IMPLICIT_CONV);
            D(XD_ITEM, DEFTREE, DEF);
            LIST(DEFTREE, SEQ_TYPE(EXTRAINFO));
         ELSIF IS_NULLARY THEN
            DEFTREE := MAKE(DN_NULLARY_CALL);
            D(XD_ITEM, DEFTREE, DEF);
         ELSE
            DEFTREE := DEF;
         END IF;
         DEFLIST := APPEND(DEFLIST, DEFTREE);
         DEFSET := DEFSET_TYPE(DEFLIST);
      END ADD_TO_DEFSET;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_TO_TYPESET ( TYPESET: IN OUT TYPESET_TYPE
                        ; TYPEINTERP: TYPEINTERP_TYPE )
                        IS
      BEGIN
         ADD_TO_TYPESET
                        ( TYPESET
                        , GET_TYPE(TYPEINTERP)
                        , GET_EXTRAINFO(TYPEINTERP) );
      END ADD_TO_TYPESET;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_TO_TYPESET ( TYPESET: IN OUT TYPESET_TYPE
                        ; TYPE_SPEC: TREE
                        ; EXTRAINFO: EXTRAINFO_TYPE := NULL_EXTRAINFO )
                        IS
      
          FUNCTION MAKE_TYPEINTERP(TYPE_SPEC: TREE; EXTRALIST:
                                SEQ_TYPE)
                                RETURN TREE
                                IS
            RESULT: TREE := TYPE_SPEC;
         BEGIN
            IF NOT IS_EMPTY(EXTRALIST) THEN
               RESULT := MAKE(DN_IMPLICIT_CONV);
               D(XD_ITEM, RESULT, TYPE_SPEC);
               LIST(RESULT, EXTRALIST);
            END IF;
            RETURN RESULT;
         END MAKE_TYPEINTERP;
      
          FUNCTION ADD_INFO(TYPETREE: TREE; EXTRALIST: SEQ_TYPE) RETURN
                                TREE IS
                        -- THERE ARE TWO INTERPRETATIONS WITH SAME RESULT TYPE
                        -- CHECK FOR COMPATIBILITY OF IMPLICIT CONVERSIONS
         
            TYPE_SPEC	: CONSTANT TREE := GET_TYPE( TYPEINTERP_TYPE(TYPETREE));
            OLD_EXTRALIST	: SEQ_TYPE;
            TEMP_LIST	: SEQ_TYPE;
            TEMP_ITEM	: TREE;
            NEW_LIST	: SEQ_TYPE := (TREE_NIL,TREE_NIL);
            IS_AMBIGUOUS	: BOOLEAN := FALSE;
         BEGIN
                        -- IF NO IMPLICIT CONVERSIONS FOR NEW INTERPRETATION
            IF IS_EMPTY(EXTRALIST) THEN
            
                                -- RETURN INTERPRETATION WITH NO CONVERSIONS
               RETURN TYPE_SPEC;
            END IF;
         
                        -- IF NO IMPLICIT CONVERSIONS FOR OLD INTERPRETATION
            OLD_EXTRALIST := SEQ_TYPE(GET_EXTRAINFO(
                                        TYPEINTERP_TYPE(TYPETREE)));
            IF IS_EMPTY(OLD_EXTRALIST) THEN
            
                                -- RETURN INTERPRETATION WITH NO CONVERSIONS
               RETURN TYPE_SPEC;
            END IF;
         
                        -- BOTH HAVE CONVERSIONS
                        -- GET COMMON CONVERSIONS AND TEST FOR CONFLICT IN OLD INTERP
                        -- (NEW_LIST := LIST OF COMMON CONVERSIONS)
                        -- (IS_AMBIGUOUS := TRUE IF OLD INTERP HAS A CONV THAT NEW DOESN'T)
            TEMP_LIST := OLD_EXTRALIST;
            WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
               POP(TEMP_LIST, TEMP_ITEM);
               IF TEMP_ITEM = TREE_VOID THEN
                  IS_AMBIGUOUS := TRUE;
               ELSIF IS_MEMBER(EXTRALIST, TEMP_ITEM) THEN
                  NEW_LIST := APPEND(NEW_LIST,
                                                TEMP_ITEM);
               ELSE
                  IS_AMBIGUOUS := TRUE;
               
                                        -- IF NO CONFLICT IN OLD INTERPRETATION
               END IF;
            END LOOP;
            IF NOT IS_AMBIGUOUS THEN
            
                                -- RETAIN OLD INTERPRETATION
               RETURN TYPETREE;
            END IF;
         
                        -- OLD INTERPRETATION HAD A CONFLICT
                        -- FOR EACH CONVERSION IN NEW INTERPRETATION
            TEMP_LIST := EXTRALIST;
            WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
               POP(TEMP_LIST, TEMP_ITEM);
            
                                -- IF IT IS ALREADY KNOWN THAT THERE IS A CONFLICT
                                -- OR IF CONVERSION IS NOT COMMON TO THE OLD INTERPRETATION
               IF TEMP_ITEM = TREE_VOID
                                                OR ELSE NOT IS_MEMBER(
                                                NEW_LIST, TEMP_ITEM) THEN
               
                                        -- ADD VOID TO NEW LIST TO MARK CONFLICT AND STOP LOOKING
                  NEW_LIST := INSERT(NEW_LIST,
                                                TREE_VOID);
                  EXIT;
               END IF;
            END LOOP;
         
                        -- RETURN INTERPRETATION WITH NEW CONVERSION LIST
            RETURN MAKE_TYPEINTERP(TYPE_SPEC, NEW_LIST);
         END ADD_INFO;
      
          FUNCTION INSERT_TYPE ( TYPELIST: SEQ_TYPE
                                ; TYPE_SPEC: TREE
                                ; EXTRALIST: SEQ_TYPE )
                                RETURN SEQ_TYPE
                                IS
            OLD_HEAD:	TREE;
            OLD_TYPE:	TREE;
            OLD_TAIL:	SEQ_TYPE;
            NEW_HEAD:	TREE;
            NEW_TAIL:	SEQ_TYPE;
         BEGIN
            IF IS_EMPTY(TYPELIST) THEN
               RETURN SINGLETON(MAKE_TYPEINTERP(
                                                TYPE_SPEC, EXTRALIST));
            ELSE
               OLD_HEAD := HEAD(TYPELIST);
               OLD_TYPE := GET_TYPE(TYPEINTERP_TYPE(
                                                OLD_HEAD));
               IF OLD_TYPE = TYPE_SPEC THEN
                  NEW_HEAD := ADD_INFO(OLD_HEAD,
                                                EXTRALIST);
                  IF NEW_HEAD = OLD_HEAD THEN
                     RETURN TYPELIST;
                  ELSE
                     RETURN INSERT(TAIL( TYPELIST), NEW_HEAD);
                  END IF;
               ELSIF OLD_TYPE.PG > TYPE_SPEC.PG
                                                OR (OLD_TYPE.PG =
                                                TYPE_SPEC.PG
                                                AND OLD_TYPE.LN >
                                                TYPE_SPEC.LN)
                                                THEN
                  OLD_TAIL := TAIL(TYPELIST);
                  NEW_TAIL := INSERT_TYPE ( OLD_TAIL
                                                , TYPE_SPEC
                                                , EXTRALIST );
                  IF OLD_TAIL = NEW_TAIL THEN
                     RETURN TYPELIST;
                  ELSE
                     RETURN INSERT(NEW_TAIL,
                                                        OLD_HEAD);
                  END IF;
               ELSE
                  RETURN INSERT ( TYPELIST
                                                , MAKE_TYPEINTERP(
                                                        TYPE_SPEC,
                                                        EXTRALIST) );
               END IF;
            END IF;
         END INSERT_TYPE;
      
      BEGIN -- ADD_TO_TYPESET
         TYPESET := TYPESET_TYPE(INSERT_TYPE
                        ( SEQ_TYPE(TYPESET)
                                , TYPE_SPEC
                                , SEQ_TYPE(EXTRAINFO) ));
      END ADD_TO_TYPESET;
   
        ------------------------------------------------------------------------
   
       PROCEDURE REQUIRE_UNIQUE_DEF(EXP: TREE; DEFSET: IN OUT DEFSET_TYPE) IS
         IS_CONFLICTING_CONVERSION:	BOOLEAN;
         SAVE_DEFSET:			CONSTANT DEFSET_TYPE := DEFSET;
      BEGIN
         IF IS_EMPTY(DEFSET) THEN
            RETURN;
         END IF;
      
         REDUCE_UNIQUE(SEQ_TYPE(DEFSET), IS_CONFLICTING_CONVERSION);
         IF IS_EMPTY(DEFSET) THEN
            IF NOT IS_CONFLICTING_CONVERSION THEN
               ERROR(D(LX_SRCPOS,EXP),
                                        "AMBIGUOUS NAME - "
                                        & PRINT_NAME ( D(LX_SYMREP,
                                                        GET_THE_ID(
                                                                SAVE_DEFSET))) );
            ELSE
               ERROR(D(LX_SRCPOS,EXP),
                                        "IMPLICIT CONVERSION CONFLICT - "
                                        & PRINT_NAME ( D(LX_SYMREP,
                                                        GET_THE_ID(
                                                                SAVE_DEFSET))) );
            END IF;
         END IF;
      END REQUIRE_UNIQUE_DEF;
   
        ------------------------------------------------------------------------
   
       PROCEDURE REQUIRE_UNIQUE_TYPE(EXP: TREE; TYPESET: IN OUT
                        TYPESET_TYPE) IS
         IS_CONFLICTING_CONVERSION:	BOOLEAN;
         TYPE_SPEC:			TREE;
      BEGIN
         IF IS_EMPTY(TYPESET) THEN
            RETURN;
         END IF;
      
         REDUCE_UNIQUE(SEQ_TYPE(TYPESET), IS_CONFLICTING_CONVERSION);
         IF IS_EMPTY(TYPESET) THEN
            IF NOT IS_CONFLICTING_CONVERSION THEN
               ERROR(D(LX_SRCPOS,EXP),
                                        "AMBIGUOUS EXPRESSION TYPE");
            ELSE
               ERROR ( D(LX_SRCPOS,EXP)
                                        , "IMPLICIT CONVERSION CONFLICT" );
            END IF;
         
         ELSE
            TYPE_SPEC := GET_THE_TYPE(TYPESET);
            IF TYPE_SPEC.TY = DN_ANY_INTEGER THEN
               TYPESET := EMPTY_TYPESET;
               DECLARE
                  T1	: TREE	:= MAKE( DN_UNIVERSAL_INTEGER );
               BEGIN
                  ADD_TO_TYPESET( TYPESET, T1 );
               END;
            ELSIF TYPE_SPEC.TY = DN_ANY_REAL THEN
               TYPESET := EMPTY_TYPESET;
               DECLARE
                  T1	: TREE	:=  MAKE( DN_UNIVERSAL_REAL );
               BEGIN
                  ADD_TO_TYPESET( TYPESET, T1 );
               END;
            END IF;
         END IF;
      END REQUIRE_UNIQUE_TYPE;
   
        ------------------------------------------------------------------------
   
       FUNCTION GET_THE_ID(DEFSET: DEFSET_TYPE) RETURN TREE IS
      BEGIN
         IF IS_EMPTY(DEFSET) THEN
            RETURN TREE_VOID;
         ELSE
            RETURN D(XD_SOURCE_NAME, GET_DEF(HEAD(DEFSET)));
         END IF;
      END GET_THE_ID;
   
        ------------------------------------------------------------------------
   
       FUNCTION THE_ID_IS_NULLARY(DEFSET: DEFSET_TYPE) RETURN BOOLEAN IS
      BEGIN
         RETURN HEAD(SEQ_TYPE(DEFSET)).TY = DN_NULLARY_CALL;
      END THE_ID_IS_NULLARY;
   
        ------------------------------------------------------------------------
   
       FUNCTION GET_THE_TYPE(TYPESET: TYPESET_TYPE) RETURN TREE IS
      BEGIN
         IF IS_EMPTY(TYPESET) THEN
            RETURN TREE_VOID;
         ELSE
            RETURN GET_TYPE(HEAD(TYPESET));
         END IF;
      END GET_THE_TYPE;
   
        ------------------------------------------------------------------------
   
       PROCEDURE REDUCE_OPERATOR_DEFS(EXP: TREE; DEFSET: IN OUT
                        DEFSET_TYPE) IS
         TEMP_DEFSET:	DEFSET_TYPE := DEFSET;
         DEFINTERP:	DEFINTERP_TYPE;
         DEF:		TREE;
         DEF_ID:		TREE;
         HEADER: 	TREE;
         IS_CONVERSION_REQUIRED: BOOLEAN;
         NEW_DEFSET: DEFSET_TYPE;
      
          FUNCTION IS_UNIVERSAL_FIRST_PARAM(DEF: TREE) RETURN
                                BOOLEAN IS
            HEADER: TREE := D(XD_HEADER, DEF);
            FIRST_PARAM: TREE := HEAD(LIST(D(AS_PARAM_S,
                                                HEADER)));
            FIRST_PARAM_ID: TREE := HEAD(LIST(D(
                                                AS_SOURCE_NAME_S,
                                                FIRST_PARAM)));
            PARAM_TYPE_KIND: NODE_NAME := D(SM_OBJ_TYPE,
                                        FIRST_PARAM_ID).TY;
         BEGIN
            RETURN PARAM_TYPE_KIND = DN_UNIVERSAL_INTEGER
                                OR PARAM_TYPE_KIND = DN_UNIVERSAL_REAL;
         END IS_UNIVERSAL_FIRST_PARAM;
      
      BEGIN -- REDUCE_OPERATOR_DEFS
                -- FIRST, SEE IF THIS IS A RELATIONAL OPERATOR WITH UNIV PARAMETERS
                -- FOR EACH INTERPRETATION
         WHILE NOT IS_EMPTY(TEMP_DEFSET) LOOP
            POP(TEMP_DEFSET, DEFINTERP);
         
                        -- IF IT IS A BUILTIN OPERATOR
            DEF := GET_DEF(DEFINTERP);
            DEF_ID := D(XD_SOURCE_NAME, DEF);
            IF DEF_ID.TY = DN_BLTN_OPERATOR_ID THEN
            
                                -- IF IT IS NOT A RELATIONAL OPERATOR
               IF OP_CLASS'VAL(DI(SM_OPERATOR,DEF_ID))
                                                NOT IN
                                                CLASS_EQ_RELATIONAL_OP
                                                THEN
               
                                        -- NO REDUCTION TO BE DONE -- RETURN
                  RETURN;
               
                                        -- ELSE IF THIS INTERPRETATION HAS UNIVERSAL PARAMETERS
               ELSIF IS_UNIVERSAL_FIRST_PARAM(DEF) THEN
               
                                        -- REMEMBER IF CONVERSIONS REQUIRED FOR PARAMETERS
                  IS_CONVERSION_REQUIRED
                                                := TREE(DEFINTERP).TY =
                                                DN_IMPLICIT_CONV;
               
                                        -- SET UP TO SCAN ENTIRE DEFSET AGAIN AND STOP SEARCHING
                  TEMP_DEFSET := DEFSET;
                  EXIT;
               END IF;
            
                                -- ELSE IF IT IS NOT AN OPERATOR (BUILTIN OR OTHERWISE)
            ELSIF DEF_ID.TY /= DN_OPERATOR_ID THEN
            
                                -- NO REDUCTION TO BE MADE -- JUST RETURN
               RETURN;
            END IF;
         END LOOP;
      
         IF IS_EMPTY(TEMP_DEFSET) THEN
         
                        -- NOTHING TO REDUCE; NO INTERPRETATIONS WITHOUT CONVERSIONS
                        -- RETURN WITH DEFSET UNCHANGED
            RETURN;
         END IF;
      
                -- THERE IS AN INTERPRETATION AS RELATIONAL WITH UNIVERSAL PARAMETERS
                -- IS_CONVERSION_REQUIRED IS TRUE IF THAT INTERPRETATION HAS CONVERSIONS
                -- FOR EACH INTERPRETATION
         NEW_DEFSET := EMPTY_DEFSET;
         WHILE NOT IS_EMPTY(TEMP_DEFSET) LOOP
            POP(TEMP_DEFSET, DEFINTERP);
         
            DEF := GET_DEF(DEFINTERP);
            HEADER := D(XD_HEADER, DEF);
            IF GET_BASE_TYPE(D(AS_NAME, HEADER)) =
                                        PREDEFINED_BOOLEAN THEN
               IF IS_UNIVERSAL_FIRST_PARAM(DEF) THEN
                  ADD_TO_DEFSET(NEW_DEFSET,
                                                DEFINTERP);
               ELSIF IS_CONVERSION_REQUIRED THEN
                  ADD_TO_DEFSET
                                                ( NEW_DEFSET
                                                , DEF
                                                , EXTRAINFO_TYPE(INSERT
                                                        ( SEQ_TYPE(
                                                                        GET_EXTRAINFO(
                                                                                DEFINTERP))
                                                                , EXP ) ));
               END IF;
            ELSE
               ADD_TO_DEFSET
                                        ( NEW_DEFSET
                                        , DEF
                                        , EXTRAINFO_TYPE(INSERT
                                                ( SEQ_TYPE(GET_EXTRAINFO(
                                                                        DEFINTERP))
                                                        , EXP ) ));
            END IF;
         END LOOP;
         DEFSET := NEW_DEFSET;
      END REDUCE_OPERATOR_DEFS;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_EXTRAINFO
                        ( DEFINTERP:	IN OUT DEFINTERP_TYPE
                        ; EXTRAINFO:	EXTRAINFO_TYPE )
                        IS
         NEW_EXTRAINFO: EXTRAINFO_TYPE
                        := COMBINE_EXTRAINFO(GET_EXTRAINFO(DEFINTERP),
                        EXTRAINFO);
         NEW_DEFINTERP: TREE;
      BEGIN
         IF IS_EMPTY(SEQ_TYPE(NEW_EXTRAINFO)) THEN
            NULL;
         ELSE
            NEW_DEFINTERP := MAKE(DN_IMPLICIT_CONV);
            D(XD_ITEM, NEW_DEFINTERP, GET_DEF(DEFINTERP));
            LIST(NEW_DEFINTERP, SEQ_TYPE(NEW_EXTRAINFO));
            DEFINTERP := DEFINTERP_TYPE(NEW_DEFINTERP);
         END IF;
      END ADD_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_EXTRAINFO
                        ( DEFINTERP:	IN OUT DEFINTERP_TYPE
                        ; EXTRAINFO_OF: TYPEINTERP_TYPE )
                        IS
      BEGIN
         ADD_EXTRAINFO(DEFINTERP, GET_EXTRAINFO(EXTRAINFO_OF));
      END ADD_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_EXTRAINFO
                        ( TYPEINTERP:	IN OUT TYPEINTERP_TYPE
                        ; EXTRAINFO:	EXTRAINFO_TYPE )
                        IS
         NEW_EXTRAINFO: EXTRAINFO_TYPE
                        := COMBINE_EXTRAINFO(GET_EXTRAINFO(TYPEINTERP),
                        EXTRAINFO);
         NEW_TYPEINTERP: TREE;
      BEGIN
         IF IS_EMPTY(SEQ_TYPE(NEW_EXTRAINFO)) THEN
            NULL;
         ELSE
            NEW_TYPEINTERP := MAKE(DN_IMPLICIT_CONV);
            D(XD_ITEM, NEW_TYPEINTERP, GET_TYPE(TYPEINTERP));
            LIST(NEW_TYPEINTERP, SEQ_TYPE(NEW_EXTRAINFO));
            TYPEINTERP := TYPEINTERP_TYPE(NEW_TYPEINTERP);
         END IF;
      END ADD_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_EXTRAINFO
                        ( TYPEINTERP:	IN OUT TYPEINTERP_TYPE
                        ; EXTRAINFO_OF: TYPEINTERP_TYPE )
                        IS
      BEGIN
         ADD_EXTRAINFO(TYPEINTERP, GET_EXTRAINFO(EXTRAINFO_OF));
      END ADD_EXTRAINFO;
   
        ------------------------------------------------------------------------
   
       PROCEDURE ADD_EXTRAINFO
                        ( EXTRAINFO:	IN OUT EXTRAINFO_TYPE
                        ; EXTRAINFO_IN:	EXTRAINFO_TYPE )
                        IS
      BEGIN
         EXTRAINFO := COMBINE_EXTRAINFO(EXTRAINFO, EXTRAINFO_IN);
      END ADD_EXTRAINFO;
   
        --======================================================================
   
       FUNCTION IS_MEMBER(ITEM_LIST: SEQ_TYPE; ITEM: TREE) RETURN BOOLEAN IS
         TEMP_LIST: SEQ_TYPE := ITEM_LIST;
      BEGIN
         WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
            IF HEAD(TEMP_LIST) = ITEM THEN
               RETURN TRUE;
            END IF;
            TEMP_LIST := TAIL(TEMP_LIST);
         END LOOP;
         RETURN FALSE;
      END IS_MEMBER;
   
       FUNCTION INSERT(DEFSET: DEFSET_TYPE; DEFINTERP: DEFINTERP_TYPE)
                        RETURN DEFSET_TYPE
                        IS
      BEGIN
         RETURN DEFSET_TYPE(INSERT(SEQ_TYPE(DEFSET), TREE(
                                        DEFINTERP)));
      END INSERT;
   
       FUNCTION INSERT(TYPESET: TYPESET_TYPE; TYPEINTERP: TYPEINTERP_TYPE)
                        RETURN TYPESET_TYPE IS
      BEGIN
         RETURN TYPESET_TYPE(INSERT(SEQ_TYPE(TYPESET), TREE(
                                        TYPEINTERP)));
      END INSERT;
   
       PROCEDURE STASH_DEFSET(EXP: TREE; DEFSET: DEFSET_TYPE) IS
      BEGIN
         IF EXP.TY = DN_SELECTED THEN
            STASH_DEFSET(D(AS_DESIGNATOR,EXP), DEFSET);
         ELSE
            D(SM_DEFN, EXP, CAST_TREE(SEQ_TYPE(DEFSET)));
         END IF;
      END STASH_DEFSET;
   
       FUNCTION FETCH_DEFSET(EXP: TREE) RETURN DEFSET_TYPE IS
      BEGIN
         IF EXP.TY = DN_SELECTED THEN
            RETURN FETCH_DEFSET(D(AS_DESIGNATOR,EXP));
         ELSE
            RETURN DEFSET_TYPE(CAST_SEQ_TYPE(D(SM_DEFN, EXP)));
         END IF;
      END FETCH_DEFSET;
   
       PROCEDURE STASH_TYPESET(EXP: TREE; TYPESET: TYPESET_TYPE) IS
      BEGIN
         D(SM_EXP_TYPE, EXP, CAST_TREE(SEQ_TYPE(TYPESET)));
      END STASH_TYPESET;
   
       FUNCTION FETCH_TYPESET(EXP: TREE) RETURN TYPESET_TYPE IS
      BEGIN
         RETURN TYPESET_TYPE(CAST_SEQ_TYPE(D(SM_EXP_TYPE, EXP)));
      END FETCH_TYPESET;
   
        ------------------------------------------------------------------------
   
       PROCEDURE REDUCE_UNIQUE
                        ( ITEM_LIST: IN OUT SEQ_TYPE
                        ; IS_CONFLICT: OUT BOOLEAN)
                        IS
         TEMP_LIST: SEQ_TYPE := ITEM_LIST;
         TEMP_ITEM: TREE;
         TEMP_TYPE: TREE; -- MAY BE DEF TOO
         RESULT_SEEN_WITHOUT_CONVERSION: BOOLEAN := FALSE;
         RESULT_SEEN_WITHOUT_CONFLICT: BOOLEAN := FALSE;
         RESULT_SEEN_WITH_CONFLICT: BOOLEAN := FALSE;
      
          FUNCTION IS_CONFLICTING_CONVERSION(ITEM: TREE) RETURN
                                BOOLEAN IS
            CONV_LIST: SEQ_TYPE;
            CONV_ITEM: TREE;
            TEMP_LIST: SEQ_TYPE;
            TEMP_ITEM: TREE;
         BEGIN
            IF ITEM.TY /= DN_IMPLICIT_CONV THEN
               RESULT_SEEN_WITHOUT_CONVERSION := TRUE;
               RETURN FALSE;
            END IF;
         
                        -- FAST RETURN IF ITEM WITHOUT CONVERSION ALREADY SEEN
            IF RESULT_SEEN_WITHOUT_CONVERSION THEN
               RETURN TRUE;
            END IF;
         
            CONV_LIST := LIST(ITEM);
            IF HEAD(CONV_LIST) = TREE_VOID THEN
               RETURN TRUE;
            END IF;
         
            WHILE NOT IS_EMPTY(CONV_LIST) LOOP
               POP(CONV_LIST, CONV_ITEM);
            
               TEMP_LIST := ITEM_LIST;
               WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
                  POP(TEMP_LIST, TEMP_ITEM);
                  IF TEMP_ITEM = ITEM THEN
                     NULL;
                  ELSIF TEMP_ITEM.TY /=
                                                        DN_IMPLICIT_CONV THEN
                     RESULT_SEEN_WITHOUT_CONVERSION :=
                                                        TRUE;
                     RETURN TRUE;
                  ELSIF NOT IS_MEMBER(LIST(
                                                                TEMP_ITEM),
                                                        CONV_ITEM) THEN
                     RETURN TRUE;
                  END IF;
               END LOOP;
            END LOOP;
            RETURN FALSE;
         END IS_CONFLICTING_CONVERSION;
      
      BEGIN -- REDUCE_UNIQUE
         IS_CONFLICT := FALSE;
      
         IF IS_EMPTY(ITEM_LIST) THEN
            RETURN;
         END IF;
      
         TEMP_LIST := ITEM_LIST;
         WHILE NOT IS_EMPTY(TEMP_LIST) LOOP
            POP(TEMP_LIST, TEMP_ITEM);
            IF TEMP_ITEM.TY = DN_IMPLICIT_CONV THEN
               TEMP_TYPE := D(XD_ITEM, TEMP_ITEM);
            ELSE
               TEMP_TYPE:= TEMP_ITEM;
            END IF;
         
                        -- IF THERE IS AN INTERPRETATION AS A UNIVERSAL INTEGER OR REAL
            IF TEMP_TYPE.TY = DN_UNIVERSAL_INTEGER
                                        OR TEMP_TYPE.TY =
                                        DN_UNIVERSAL_REAL THEN
            
                                -- THIS IS ONLY POSSIBLE INTERPRETATION
                                -- IF THIS INTERPRETATION REQUIRES A CONVERSION NOT REQUIRED
                                -- ... BY SOME OTHER INTERPRETATION
               IF IS_CONFLICTING_CONVERSION(TEMP_ITEM) THEN
               
                                        -- ALL INTERPRETATIONS CONFLICT, SINCE OTHERS REQUIRE
                                        -- ... CONVERSION OF THE UNIVERSAL TYPE
                  ITEM_LIST := (TREE_NIL,TREE_NIL);
                  IS_CONFLICT := TRUE;
               
                                        -- ELSE -- SINCE THIS INTERPRETATION HAS NO CONFLICTS
               ELSE
               
                                        -- THIS INTERPRETATION IS THE CORRECT ONE
                  IF TEMP_ITEM.TY =
                                                        DN_IMPLICIT_CONV THEN
                     ITEM_LIST := SINGLETON(D(
                                                                XD_ITEM,
                                                                TEMP_ITEM));
                  ELSE
                     ITEM_LIST := SINGLETON(
                                                        TEMP_ITEM);
                  END IF;
                  IS_CONFLICT := FALSE;
               END IF;
            
                                -- RETURN
               RETURN;
            END IF;
         
         
            IF IS_CONFLICTING_CONVERSION(TEMP_ITEM) THEN
               RESULT_SEEN_WITH_CONFLICT := TRUE;
            ELSE
               IF RESULT_SEEN_WITHOUT_CONFLICT THEN
                  ITEM_LIST := (TREE_NIL,TREE_NIL);
               ELSE
                  ITEM_LIST := SINGLETON(TEMP_TYPE);
                  RESULT_SEEN_WITHOUT_CONFLICT :=
                                                TRUE;
               END IF;
            END IF;
         END LOOP;
      
         IF RESULT_SEEN_WITHOUT_CONFLICT THEN
            RETURN;
         ELSE
            ITEM_LIST := (TREE_NIL,TREE_NIL);
            IS_CONFLICT := RESULT_SEEN_WITH_CONFLICT;
         END IF;
      END REDUCE_UNIQUE;
   
       FUNCTION COMBINE_EXTRAINFO(EXTRAINFO_1, EXTRAINFO_2:
                        EXTRAINFO_TYPE)
                        RETURN EXTRAINFO_TYPE
                        IS
                -- GIVEN TWO EXTRAINFO LISTS, RETURN EXTRAINFO LIST WITH CONVERSIONS
                -- REQUIRED BY BOTH LISTS
      BEGIN
         IF IS_EMPTY(SEQ_TYPE(EXTRAINFO_1)) THEN
            RETURN EXTRAINFO_2;
         END IF;
      
         IF IS_EMPTY(SEQ_TYPE(EXTRAINFO_2)) THEN
            RETURN EXTRAINFO_1;
         END IF;
      
         DECLARE
            LIST_1:	SEQ_TYPE := SEQ_TYPE(EXTRAINFO_1);
            LIST_2:	SEQ_TYPE := SEQ_TYPE(EXTRAINFO_2);
            RESULT:	SEQ_TYPE := (TREE_NIL,TREE_NIL);
         BEGIN
            IF HEAD(LIST_2) = TREE_VOID THEN
               LIST_2 := TAIL(LIST_2);
               IF HEAD(LIST_1) /= TREE_VOID THEN
                  RESULT := SINGLETON(TREE_VOID);
               END IF;
               IF IS_EMPTY(LIST_2) THEN
                  RETURN EXTRAINFO_TYPE(APPEND(
                                                        RESULT,LIST_1.FIRST));
               END IF;
            END IF;
         
            WHILE NOT IS_EMPTY(LIST_1) LOOP
               RESULT := APPEND(RESULT,HEAD(LIST_1));
               LIST_1 := TAIL(LIST_1);
            END LOOP;
            RETURN EXTRAINFO_TYPE(APPEND(RESULT, LIST_2.FIRST));
         END;
      END COMBINE_EXTRAINFO;
   
   --|----------------------------------------------------------------------------------------------
   END SET_UTIL;
