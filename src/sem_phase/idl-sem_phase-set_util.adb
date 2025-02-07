separate (IDL.SEM_PHASE)
    --|----------------------------------------------------------------------------------------------
    --| SET_UTIL
    --|----------------------------------------------------------------------------------------------
package body SET_UTIL is
  use DEF_UTIL;
  use PRENAME;
  use VIS_UTIL;

  function IS_MEMBER (ITEM_LIST : SEQ_TYPE; ITEM : TREE) return Boolean;
  procedure REDUCE_UNIQUE (ITEM_LIST : in out SEQ_TYPE; IS_CONFLICT : out Boolean);
  function COMBINE_EXTRAINFO (EXTRAINFO_1, EXTRAINFO_2 : EXTRAINFO_TYPE) return EXTRAINFO_TYPE;

        --======================================================================

  function GET_DEF (DEFINTERP : DEFINTERP_TYPE) return TREE is
    DEF : TREE := TREE (DEFINTERP);
  begin
    if DEF.TY = DN_IMPLICIT_CONV or else DEF.TY = DN_NULLARY_CALL then
      DEF := D (XD_ITEM, DEF);
    end if;
    return DEF;
  end GET_DEF;

        ------------------------------------------------------------------------

  function IS_NULLARY (DEFINTERP : DEFINTERP_TYPE) return Boolean is
  begin
    return TREE (DEFINTERP).TY = DN_NULLARY_CALL;

  end IS_NULLARY;

        ------------------------------------------------------------------------

  function GET_EXTRAINFO (DEFINTERP : DEFINTERP_TYPE) return EXTRAINFO_TYPE is
  begin
    if TREE (DEFINTERP).TY = DN_IMPLICIT_CONV then
      declare
        S1 : SEQ_TYPE := LIST (TREE (DEFINTERP));
      begin
        return EXTRAINFO_TYPE (S1);
      end;
    else
      return NULL_EXTRAINFO;
    end if;
  end GET_EXTRAINFO;

        ------------------------------------------------------------------------

  function IS_EMPTY (DEFSET : DEFSET_TYPE) return Boolean is
  begin
    return IS_EMPTY (SEQ_TYPE (DEFSET));
  end IS_EMPTY;

        ------------------------------------------------------------------------

  function HEAD (DEFSET : DEFSET_TYPE) return DEFINTERP_TYPE is
  begin
    return DEFINTERP_TYPE (HEAD (SEQ_TYPE (DEFSET)));
  end HEAD;

        ------------------------------------------------------------------------

  procedure POP (DEFSET : in out DEFSET_TYPE; DEFINTERP : out DEFINTERP_TYPE) is
    TREE_DEFINTERP : TREE;
  begin
                -- (NOTE.  VERDIX DOES NOT ACCEPT CONVERSION ON OUT PARAMETER)
                --POP(SEQ_TYPE(DEFSET), TREE(DEFINTERP));
    POP (SEQ_TYPE (DEFSET), TREE_DEFINTERP);
    DEFINTERP := DEFINTERP_TYPE (TREE_DEFINTERP);
  end POP;

        ------------------------------------------------------------------------

  function GET_TYPE (TYPEINTERP : TYPEINTERP_TYPE) return TREE is
    TYPE_SPEC : TREE := TREE (TYPEINTERP);
  begin
    if TYPE_SPEC.TY = DN_IMPLICIT_CONV then
      TYPE_SPEC := D (XD_ITEM, TYPE_SPEC);
    end if;
    return TYPE_SPEC;
  end GET_TYPE;

        ------------------------------------------------------------------------

  function GET_EXTRAINFO (TYPEINTERP : TYPEINTERP_TYPE) return EXTRAINFO_TYPE is
  begin
    if TREE (TYPEINTERP).TY = DN_IMPLICIT_CONV then
      declare
        S1 : SEQ_TYPE := LIST (TREE (TYPEINTERP));
      begin
        return EXTRAINFO_TYPE (S1);
      end;
    else
      return NULL_EXTRAINFO;
    end if;
  end GET_EXTRAINFO;

        ------------------------------------------------------------------------

  function IS_EMPTY (TYPESET : TYPESET_TYPE) return Boolean is
  begin
    return IS_EMPTY (SEQ_TYPE (TYPESET));
  end IS_EMPTY;

        ------------------------------------------------------------------------

  function HEAD (TYPESET : TYPESET_TYPE) return TYPEINTERP_TYPE is
  begin
    return TYPEINTERP_TYPE (HEAD (SEQ_TYPE (TYPESET)));
  end HEAD;

        ------------------------------------------------------------------------

  procedure POP (TYPESET : in out TYPESET_TYPE; TYPEINTERP : out TYPEINTERP_TYPE) is
    TREE_TYPEINTERP : TREE;
  begin
                -- (NOTE.  VERDIX DOES NOT ACCEPT CONVERSION ON OUT PARAMETER)
                --POP(SEQ_TYPE(TYPESET), TREE(TYPEINTERP));
    POP (SEQ_TYPE (TYPESET), TREE_TYPEINTERP);
    TYPEINTERP := TYPEINTERP_TYPE (TREE_TYPEINTERP);
  end POP;

        ------------------------------------------------------------------------

  procedure ADD_TO_DEFSET (DEFSET : in out DEFSET_TYPE; DEFINTERP : DEFINTERP_TYPE) is
    DEFLIST : SEQ_TYPE := SEQ_TYPE (DEFSET);
  begin
    DEFLIST := APPEND (DEFLIST, TREE (DEFINTERP));
    DEFSET  := DEFSET_TYPE (DEFLIST);
  end ADD_TO_DEFSET;

        ------------------------------------------------------------------------

  procedure ADD_TO_DEFSET (DEFSET : in out DEFSET_TYPE; DEF : TREE; EXTRAINFO : EXTRAINFO_TYPE := NULL_EXTRAINFO; IS_NULLARY : Boolean := False) is
    DEFLIST : SEQ_TYPE := SEQ_TYPE (DEFSET);
    DEFTREE : TREE;
  begin
    if not IS_EMPTY (SEQ_TYPE (EXTRAINFO)) then
      DEFTREE := MAKE (DN_IMPLICIT_CONV);
      D (XD_ITEM, DEFTREE, DEF);
      LIST (DEFTREE, SEQ_TYPE (EXTRAINFO));
    elsif IS_NULLARY then
      DEFTREE := MAKE (DN_NULLARY_CALL);
      D (XD_ITEM, DEFTREE, DEF);
    else
      DEFTREE := DEF;
    end if;
    DEFLIST := APPEND (DEFLIST, DEFTREE);
    DEFSET  := DEFSET_TYPE (DEFLIST);
  end ADD_TO_DEFSET;

        ------------------------------------------------------------------------

  procedure ADD_TO_TYPESET (TYPESET : in out TYPESET_TYPE; TYPEINTERP : TYPEINTERP_TYPE) is
  begin
    ADD_TO_TYPESET (TYPESET, GET_TYPE (TYPEINTERP), GET_EXTRAINFO (TYPEINTERP));
  end ADD_TO_TYPESET;

        ------------------------------------------------------------------------

  procedure ADD_TO_TYPESET (TYPESET : in out TYPESET_TYPE; TYPE_SPEC : TREE; EXTRAINFO : EXTRAINFO_TYPE := NULL_EXTRAINFO) is

    function MAKE_TYPEINTERP (TYPE_SPEC : TREE; EXTRALIST : SEQ_TYPE) return TREE is
      RESULT : TREE := TYPE_SPEC;
    begin
      if not IS_EMPTY (EXTRALIST) then
        RESULT := MAKE (DN_IMPLICIT_CONV);
        D (XD_ITEM, RESULT, TYPE_SPEC);
        LIST (RESULT, EXTRALIST);
      end if;
      return RESULT;
    end MAKE_TYPEINTERP;

    function ADD_INFO (TYPETREE : TREE; EXTRALIST : SEQ_TYPE) return TREE is
                        -- THERE ARE TWO INTERPRETATIONS WITH SAME RESULT TYPE
                        -- CHECK FOR COMPATIBILITY OF IMPLICIT CONVERSIONS

      TYPE_SPEC     : constant TREE := GET_TYPE (TYPEINTERP_TYPE (TYPETREE));
      OLD_EXTRALIST : SEQ_TYPE;
      TEMP_LIST     : SEQ_TYPE;
      TEMP_ITEM     : TREE;
      NEW_LIST      : SEQ_TYPE      := (TREE_NIL, TREE_NIL);
      IS_AMBIGUOUS  : Boolean       := False;
    begin
                        -- IF NO IMPLICIT CONVERSIONS FOR NEW INTERPRETATION
      if IS_EMPTY (EXTRALIST) then

                                -- RETURN INTERPRETATION WITH NO CONVERSIONS
        return TYPE_SPEC;
      end if;

                        -- IF NO IMPLICIT CONVERSIONS FOR OLD INTERPRETATION
      OLD_EXTRALIST := SEQ_TYPE (GET_EXTRAINFO (TYPEINTERP_TYPE (TYPETREE)));
      if IS_EMPTY (OLD_EXTRALIST) then

                                -- RETURN INTERPRETATION WITH NO CONVERSIONS
        return TYPE_SPEC;
      end if;

                        -- BOTH HAVE CONVERSIONS
                        -- GET COMMON CONVERSIONS AND TEST FOR CONFLICT IN OLD INTERP
                        -- (NEW_LIST := LIST OF COMMON CONVERSIONS)
                        -- (IS_AMBIGUOUS := TRUE IF OLD INTERP HAS A CONV THAT NEW DOESN'T)
      TEMP_LIST := OLD_EXTRALIST;
      while not IS_EMPTY (TEMP_LIST) loop
        POP (TEMP_LIST, TEMP_ITEM);
        if TEMP_ITEM = TREE_VOID then
          IS_AMBIGUOUS := True;
        elsif IS_MEMBER (EXTRALIST, TEMP_ITEM) then
          NEW_LIST := APPEND (NEW_LIST, TEMP_ITEM);
        else
          IS_AMBIGUOUS := True;

                                        -- IF NO CONFLICT IN OLD INTERPRETATION
        end if;
      end loop;
      if not IS_AMBIGUOUS then

                                -- RETAIN OLD INTERPRETATION
        return TYPETREE;
      end if;

                        -- OLD INTERPRETATION HAD A CONFLICT
                        -- FOR EACH CONVERSION IN NEW INTERPRETATION
      TEMP_LIST := EXTRALIST;
      while not IS_EMPTY (TEMP_LIST) loop
        POP (TEMP_LIST, TEMP_ITEM);

                                -- IF IT IS ALREADY KNOWN THAT THERE IS A CONFLICT
                                -- OR IF CONVERSION IS NOT COMMON TO THE OLD INTERPRETATION
        if TEMP_ITEM = TREE_VOID or else not IS_MEMBER (NEW_LIST, TEMP_ITEM) then

                                        -- ADD VOID TO NEW LIST TO MARK CONFLICT AND STOP LOOKING
          NEW_LIST := INSERT (NEW_LIST, TREE_VOID);
          exit;
        end if;
      end loop;

                        -- RETURN INTERPRETATION WITH NEW CONVERSION LIST
      return MAKE_TYPEINTERP (TYPE_SPEC, NEW_LIST);
    end ADD_INFO;

    function INSERT_TYPE (TYPELIST : SEQ_TYPE; TYPE_SPEC : TREE; EXTRALIST : SEQ_TYPE) return SEQ_TYPE is
      OLD_HEAD : TREE;
      OLD_TYPE : TREE;
      OLD_TAIL : SEQ_TYPE;
      NEW_HEAD : TREE;
      NEW_TAIL : SEQ_TYPE;
    begin
      if IS_EMPTY (TYPELIST) then
        return SINGLETON (MAKE_TYPEINTERP (TYPE_SPEC, EXTRALIST));
      else
        OLD_HEAD := HEAD (TYPELIST);
        OLD_TYPE := GET_TYPE (TYPEINTERP_TYPE (OLD_HEAD));
        if OLD_TYPE = TYPE_SPEC then
          NEW_HEAD := ADD_INFO (OLD_HEAD, EXTRALIST);
          if NEW_HEAD = OLD_HEAD then
            return TYPELIST;
          else
            return INSERT (TAIL (TYPELIST), NEW_HEAD);
          end if;
        elsif OLD_TYPE.PG > TYPE_SPEC.PG or (OLD_TYPE.PG = TYPE_SPEC.PG and OLD_TYPE.LN > TYPE_SPEC.LN) then
          OLD_TAIL := TAIL (TYPELIST);
          NEW_TAIL := INSERT_TYPE (OLD_TAIL, TYPE_SPEC, EXTRALIST);
          if OLD_TAIL = NEW_TAIL then
            return TYPELIST;
          else
            return INSERT (NEW_TAIL, OLD_HEAD);
          end if;
        else
          return INSERT (TYPELIST, MAKE_TYPEINTERP (TYPE_SPEC, EXTRALIST));
        end if;
      end if;
    end INSERT_TYPE;

  begin -- ADD_TO_TYPESET
    TYPESET := TYPESET_TYPE (INSERT_TYPE (SEQ_TYPE (TYPESET), TYPE_SPEC, SEQ_TYPE (EXTRAINFO)));
  end ADD_TO_TYPESET;

        ------------------------------------------------------------------------

  procedure REQUIRE_UNIQUE_DEF (EXP : TREE; DEFSET : in out DEFSET_TYPE) is
    IS_CONFLICTING_CONVERSION : Boolean;
    SAVE_DEFSET               : constant DEFSET_TYPE := DEFSET;
  begin
    if IS_EMPTY (DEFSET) then
      return;
    end if;

    REDUCE_UNIQUE (SEQ_TYPE (DEFSET), IS_CONFLICTING_CONVERSION);
    if IS_EMPTY (DEFSET) then
      if not IS_CONFLICTING_CONVERSION then
        ERROR (D (LX_SRCPOS, EXP), "AMBIGUOUS NAME - " & PRINT_NAME (D (LX_SYMREP, GET_THE_ID (SAVE_DEFSET))));
      else
        ERROR (D (LX_SRCPOS, EXP), "IMPLICIT CONVERSION CONFLICT - " & PRINT_NAME (D (LX_SYMREP, GET_THE_ID (SAVE_DEFSET))));
      end if;
    end if;
  end REQUIRE_UNIQUE_DEF;

        ------------------------------------------------------------------------

  procedure REQUIRE_UNIQUE_TYPE (EXP : TREE; TYPESET : in out TYPESET_TYPE) is
    IS_CONFLICTING_CONVERSION : Boolean;
    TYPE_SPEC                 : TREE;
  begin
    if IS_EMPTY (TYPESET) then
      return;
    end if;

    REDUCE_UNIQUE (SEQ_TYPE (TYPESET), IS_CONFLICTING_CONVERSION);
    if IS_EMPTY (TYPESET) then
      if not IS_CONFLICTING_CONVERSION then
        ERROR (D (LX_SRCPOS, EXP), "AMBIGUOUS EXPRESSION TYPE");
      else
        ERROR (D (LX_SRCPOS, EXP), "IMPLICIT CONVERSION CONFLICT");
      end if;

    else
      TYPE_SPEC := GET_THE_TYPE (TYPESET);
      if TYPE_SPEC.TY = DN_ANY_INTEGER then
        TYPESET := EMPTY_TYPESET;
        declare
          T1 : TREE := MAKE (DN_UNIVERSAL_INTEGER);
        begin
          ADD_TO_TYPESET (TYPESET, T1);
        end;
      elsif TYPE_SPEC.TY = DN_ANY_REAL then
        TYPESET := EMPTY_TYPESET;
        declare
          T1 : TREE := MAKE (DN_UNIVERSAL_REAL);
        begin
          ADD_TO_TYPESET (TYPESET, T1);
        end;
      end if;
    end if;
  end REQUIRE_UNIQUE_TYPE;

        ------------------------------------------------------------------------

  function GET_THE_ID (DEFSET : DEFSET_TYPE) return TREE is
  begin
    if IS_EMPTY (DEFSET) then
      return TREE_VOID;
    else
      return D (XD_SOURCE_NAME, GET_DEF (HEAD (DEFSET)));
    end if;
  end GET_THE_ID;

        ------------------------------------------------------------------------

  function THE_ID_IS_NULLARY (DEFSET : DEFSET_TYPE) return Boolean is
  begin
    return HEAD (SEQ_TYPE (DEFSET)).TY = DN_NULLARY_CALL;
  end THE_ID_IS_NULLARY;

        ------------------------------------------------------------------------

  function GET_THE_TYPE (TYPESET : TYPESET_TYPE) return TREE is
  begin
    if IS_EMPTY (TYPESET) then
      return TREE_VOID;
    else
      return GET_TYPE (HEAD (TYPESET));
    end if;
  end GET_THE_TYPE;

        ------------------------------------------------------------------------

  procedure REDUCE_OPERATOR_DEFS (EXP : TREE; DEFSET : in out DEFSET_TYPE) is
    TEMP_DEFSET            : DEFSET_TYPE := DEFSET;
    DEFINTERP              : DEFINTERP_TYPE;
    DEF                    : TREE;
    DEF_ID                 : TREE;
    HEADER                 : TREE;
    IS_CONVERSION_REQUIRED : Boolean;
    NEW_DEFSET             : DEFSET_TYPE;

    function IS_UNIVERSAL_FIRST_PARAM (DEF : TREE) return Boolean is
      HEADER          : TREE      := D (XD_HEADER, DEF);
      FIRST_PARAM     : TREE      := HEAD (LIST (D (AS_PARAM_S, HEADER)));
      FIRST_PARAM_ID  : TREE      := HEAD (LIST (D (AS_SOURCE_NAME_S, FIRST_PARAM)));
      PARAM_TYPE_KIND : NODE_NAME := D (SM_OBJ_TYPE, FIRST_PARAM_ID).TY;
    begin
      return PARAM_TYPE_KIND = DN_UNIVERSAL_INTEGER or PARAM_TYPE_KIND = DN_UNIVERSAL_REAL;
    end IS_UNIVERSAL_FIRST_PARAM;

  begin -- REDUCE_OPERATOR_DEFS
                -- FIRST, SEE IF THIS IS A RELATIONAL OPERATOR WITH UNIV PARAMETERS
                -- FOR EACH INTERPRETATION
    while not IS_EMPTY (TEMP_DEFSET) loop
      POP (TEMP_DEFSET, DEFINTERP);

                        -- IF IT IS A BUILTIN OPERATOR
      DEF    := GET_DEF (DEFINTERP);
      DEF_ID := D (XD_SOURCE_NAME, DEF);
      if DEF_ID.TY = DN_BLTN_OPERATOR_ID then

                                -- IF IT IS NOT A RELATIONAL OPERATOR
        if OP_CLASS'VAL (DI (SM_OPERATOR, DEF_ID)) not in CLASS_EQ_RELATIONAL_OP then

                                        -- NO REDUCTION TO BE DONE -- RETURN
          return;

                                        -- ELSE IF THIS INTERPRETATION HAS UNIVERSAL PARAMETERS
        elsif IS_UNIVERSAL_FIRST_PARAM (DEF) then

                                        -- REMEMBER IF CONVERSIONS REQUIRED FOR PARAMETERS
          IS_CONVERSION_REQUIRED := TREE (DEFINTERP).TY = DN_IMPLICIT_CONV;

                                        -- SET UP TO SCAN ENTIRE DEFSET AGAIN AND STOP SEARCHING
          TEMP_DEFSET := DEFSET;
          exit;
        end if;

                                -- ELSE IF IT IS NOT AN OPERATOR (BUILTIN OR OTHERWISE)
      elsif DEF_ID.TY /= DN_OPERATOR_ID then

                                -- NO REDUCTION TO BE MADE -- JUST RETURN
        return;
      end if;
    end loop;

    if IS_EMPTY (TEMP_DEFSET) then

                        -- NOTHING TO REDUCE; NO INTERPRETATIONS WITHOUT CONVERSIONS
                        -- RETURN WITH DEFSET UNCHANGED
      return;
    end if;

                -- THERE IS AN INTERPRETATION AS RELATIONAL WITH UNIVERSAL PARAMETERS
                -- IS_CONVERSION_REQUIRED IS TRUE IF THAT INTERPRETATION HAS CONVERSIONS
                -- FOR EACH INTERPRETATION
    NEW_DEFSET := EMPTY_DEFSET;
    while not IS_EMPTY (TEMP_DEFSET) loop
      POP (TEMP_DEFSET, DEFINTERP);

      DEF    := GET_DEF (DEFINTERP);
      HEADER := D (XD_HEADER, DEF);
      if GET_BASE_TYPE (D (AS_NAME, HEADER)) = PREDEFINED_BOOLEAN then
        if IS_UNIVERSAL_FIRST_PARAM (DEF) then
          ADD_TO_DEFSET (NEW_DEFSET, DEFINTERP);
        elsif IS_CONVERSION_REQUIRED then
          ADD_TO_DEFSET (NEW_DEFSET, DEF, EXTRAINFO_TYPE (INSERT (SEQ_TYPE (GET_EXTRAINFO (DEFINTERP)), EXP)));
        end if;
      else
        ADD_TO_DEFSET (NEW_DEFSET, DEF, EXTRAINFO_TYPE (INSERT (SEQ_TYPE (GET_EXTRAINFO (DEFINTERP)), EXP)));
      end if;
    end loop;
    DEFSET := NEW_DEFSET;
  end REDUCE_OPERATOR_DEFS;

        ------------------------------------------------------------------------

  procedure ADD_EXTRAINFO (DEFINTERP : in out DEFINTERP_TYPE; EXTRAINFO : EXTRAINFO_TYPE) is
    NEW_EXTRAINFO : EXTRAINFO_TYPE := COMBINE_EXTRAINFO (GET_EXTRAINFO (DEFINTERP), EXTRAINFO);
    NEW_DEFINTERP : TREE;
  begin
    if IS_EMPTY (SEQ_TYPE (NEW_EXTRAINFO)) then
      null;
    else
      NEW_DEFINTERP := MAKE (DN_IMPLICIT_CONV);
      D (XD_ITEM, NEW_DEFINTERP, GET_DEF (DEFINTERP));
      LIST (NEW_DEFINTERP, SEQ_TYPE (NEW_EXTRAINFO));
      DEFINTERP := DEFINTERP_TYPE (NEW_DEFINTERP);
    end if;
  end ADD_EXTRAINFO;

        ------------------------------------------------------------------------

  procedure ADD_EXTRAINFO (DEFINTERP : in out DEFINTERP_TYPE; EXTRAINFO_OF : TYPEINTERP_TYPE) is
  begin
    ADD_EXTRAINFO (DEFINTERP, GET_EXTRAINFO (EXTRAINFO_OF));
  end ADD_EXTRAINFO;

        ------------------------------------------------------------------------

  procedure ADD_EXTRAINFO (TYPEINTERP : in out TYPEINTERP_TYPE; EXTRAINFO : EXTRAINFO_TYPE) is
    NEW_EXTRAINFO  : EXTRAINFO_TYPE := COMBINE_EXTRAINFO (GET_EXTRAINFO (TYPEINTERP), EXTRAINFO);
    NEW_TYPEINTERP : TREE;
  begin
    if IS_EMPTY (SEQ_TYPE (NEW_EXTRAINFO)) then
      null;
    else
      NEW_TYPEINTERP := MAKE (DN_IMPLICIT_CONV);
      D (XD_ITEM, NEW_TYPEINTERP, GET_TYPE (TYPEINTERP));
      LIST (NEW_TYPEINTERP, SEQ_TYPE (NEW_EXTRAINFO));
      TYPEINTERP := TYPEINTERP_TYPE (NEW_TYPEINTERP);
    end if;
  end ADD_EXTRAINFO;

        ------------------------------------------------------------------------

  procedure ADD_EXTRAINFO (TYPEINTERP : in out TYPEINTERP_TYPE; EXTRAINFO_OF : TYPEINTERP_TYPE) is
  begin
    ADD_EXTRAINFO (TYPEINTERP, GET_EXTRAINFO (EXTRAINFO_OF));
  end ADD_EXTRAINFO;

        ------------------------------------------------------------------------

  procedure ADD_EXTRAINFO (EXTRAINFO : in out EXTRAINFO_TYPE; EXTRAINFO_IN : EXTRAINFO_TYPE) is
  begin
    EXTRAINFO := COMBINE_EXTRAINFO (EXTRAINFO, EXTRAINFO_IN);
  end ADD_EXTRAINFO;

        --======================================================================

  function IS_MEMBER (ITEM_LIST : SEQ_TYPE; ITEM : TREE) return Boolean is
    TEMP_LIST : SEQ_TYPE := ITEM_LIST;
  begin
    while not IS_EMPTY (TEMP_LIST) loop
      if HEAD (TEMP_LIST) = ITEM then
        return True;
      end if;
      TEMP_LIST := TAIL (TEMP_LIST);
    end loop;
    return False;
  end IS_MEMBER;

  function INSERT (DEFSET : DEFSET_TYPE; DEFINTERP : DEFINTERP_TYPE) return DEFSET_TYPE is
  begin
    return DEFSET_TYPE (INSERT (SEQ_TYPE (DEFSET), TREE (DEFINTERP)));
  end INSERT;

  function INSERT (TYPESET : TYPESET_TYPE; TYPEINTERP : TYPEINTERP_TYPE) return TYPESET_TYPE is
  begin
    return TYPESET_TYPE (INSERT (SEQ_TYPE (TYPESET), TREE (TYPEINTERP)));
  end INSERT;

  procedure STASH_DEFSET (EXP : TREE; DEFSET : DEFSET_TYPE) is
  begin
    if EXP.TY = DN_SELECTED then
      STASH_DEFSET (D (AS_DESIGNATOR, EXP), DEFSET);
    else
      D (SM_DEFN, EXP, CAST_TREE (SEQ_TYPE (DEFSET)));
    end if;
  end STASH_DEFSET;

  function FETCH_DEFSET (EXP : TREE) return DEFSET_TYPE is
  begin
    if EXP.TY = DN_SELECTED then
      return FETCH_DEFSET (D (AS_DESIGNATOR, EXP));
    else
      return DEFSET_TYPE( CAST_SEQ_TYPE( D( SM_DEFN, EXP ) ) );
    end if;
  end FETCH_DEFSET;

  procedure STASH_TYPESET (EXP : TREE; TYPESET : TYPESET_TYPE) is
  begin
    D (SM_EXP_TYPE, EXP, CAST_TREE (SEQ_TYPE (TYPESET)));
  end STASH_TYPESET;

  function FETCH_TYPESET (EXP : TREE) return TYPESET_TYPE is
  begin
    return TYPESET_TYPE (CAST_SEQ_TYPE (D (SM_EXP_TYPE, EXP)));
  end FETCH_TYPESET;

        ------------------------------------------------------------------------

  procedure REDUCE_UNIQUE (ITEM_LIST : in out SEQ_TYPE; IS_CONFLICT : out Boolean) is
    TEMP_LIST                      : SEQ_TYPE := ITEM_LIST;
    TEMP_ITEM                      : TREE;
    TEMP_TYPE                      : TREE; -- MAY BE DEF TOO
    RESULT_SEEN_WITHOUT_CONVERSION : Boolean  := False;
    RESULT_SEEN_WITHOUT_CONFLICT   : Boolean  := False;
    RESULT_SEEN_WITH_CONFLICT      : Boolean  := False;

    function IS_CONFLICTING_CONVERSION (ITEM : TREE) return Boolean is
      CONV_LIST : SEQ_TYPE;
      CONV_ITEM : TREE;
      TEMP_LIST : SEQ_TYPE;
      TEMP_ITEM : TREE;
    begin
      if ITEM.TY /= DN_IMPLICIT_CONV then
        RESULT_SEEN_WITHOUT_CONVERSION := True;
        return False;
      end if;

                        -- FAST RETURN IF ITEM WITHOUT CONVERSION ALREADY SEEN
      if RESULT_SEEN_WITHOUT_CONVERSION then
        return True;
      end if;

      CONV_LIST := LIST (ITEM);
      if HEAD (CONV_LIST) = TREE_VOID then
        return True;
      end if;

      while not IS_EMPTY (CONV_LIST) loop
        POP (CONV_LIST, CONV_ITEM);

        TEMP_LIST := ITEM_LIST;
        while not IS_EMPTY (TEMP_LIST) loop
          POP (TEMP_LIST, TEMP_ITEM);
          if TEMP_ITEM = ITEM then
            null;
          elsif TEMP_ITEM.TY /= DN_IMPLICIT_CONV then
            RESULT_SEEN_WITHOUT_CONVERSION := True;
            return True;
          elsif not IS_MEMBER (LIST (TEMP_ITEM), CONV_ITEM) then
            return True;
          end if;
        end loop;
      end loop;
      return False;
    end IS_CONFLICTING_CONVERSION;

  begin -- REDUCE_UNIQUE
    IS_CONFLICT := False;

    if IS_EMPTY (ITEM_LIST) then
      return;
    end if;

    TEMP_LIST := ITEM_LIST;
    while not IS_EMPTY (TEMP_LIST) loop
      POP (TEMP_LIST, TEMP_ITEM);
      if TEMP_ITEM.TY = DN_IMPLICIT_CONV then
        TEMP_TYPE := D (XD_ITEM, TEMP_ITEM);
      else
        TEMP_TYPE := TEMP_ITEM;
      end if;

                        -- IF THERE IS AN INTERPRETATION AS A UNIVERSAL INTEGER OR REAL
      if TEMP_TYPE.TY = DN_UNIVERSAL_INTEGER or TEMP_TYPE.TY = DN_UNIVERSAL_REAL then

                                -- THIS IS ONLY POSSIBLE INTERPRETATION
                                -- IF THIS INTERPRETATION REQUIRES A CONVERSION NOT REQUIRED
                                -- ... BY SOME OTHER INTERPRETATION
        if IS_CONFLICTING_CONVERSION (TEMP_ITEM) then

                                        -- ALL INTERPRETATIONS CONFLICT, SINCE OTHERS REQUIRE
                                        -- ... CONVERSION OF THE UNIVERSAL TYPE
          ITEM_LIST   := (TREE_NIL, TREE_NIL);
          IS_CONFLICT := True;

                                        -- ELSE -- SINCE THIS INTERPRETATION HAS NO CONFLICTS
        else

                                        -- THIS INTERPRETATION IS THE CORRECT ONE
          if TEMP_ITEM.TY = DN_IMPLICIT_CONV then
            ITEM_LIST := SINGLETON (D (XD_ITEM, TEMP_ITEM));
          else
            ITEM_LIST := SINGLETON (TEMP_ITEM);
          end if;
          IS_CONFLICT := False;
        end if;

                                -- RETURN
        return;
      end if;

      if IS_CONFLICTING_CONVERSION (TEMP_ITEM) then
        RESULT_SEEN_WITH_CONFLICT := True;
      else
        if RESULT_SEEN_WITHOUT_CONFLICT then
          ITEM_LIST := (TREE_NIL, TREE_NIL);
        else
          ITEM_LIST                    := SINGLETON (TEMP_TYPE);
          RESULT_SEEN_WITHOUT_CONFLICT := True;
        end if;
      end if;
    end loop;

    if RESULT_SEEN_WITHOUT_CONFLICT then
      return;
    else
      ITEM_LIST   := (TREE_NIL, TREE_NIL);
      IS_CONFLICT := RESULT_SEEN_WITH_CONFLICT;
    end if;
  end REDUCE_UNIQUE;

  function COMBINE_EXTRAINFO (EXTRAINFO_1, EXTRAINFO_2 : EXTRAINFO_TYPE) return EXTRAINFO_TYPE is
                -- GIVEN TWO EXTRAINFO LISTS, RETURN EXTRAINFO LIST WITH CONVERSIONS
                -- REQUIRED BY BOTH LISTS
  begin
    if IS_EMPTY (SEQ_TYPE (EXTRAINFO_1)) then
      return EXTRAINFO_2;
    end if;

    if IS_EMPTY (SEQ_TYPE (EXTRAINFO_2)) then
      return EXTRAINFO_1;
    end if;

    declare
      LIST_1 : SEQ_TYPE := SEQ_TYPE (EXTRAINFO_1);
      LIST_2 : SEQ_TYPE := SEQ_TYPE (EXTRAINFO_2);
      RESULT : SEQ_TYPE := (TREE_NIL, TREE_NIL);
    begin
      if HEAD (LIST_2) = TREE_VOID then
        LIST_2 := TAIL (LIST_2);
        if HEAD (LIST_1) /= TREE_VOID then
          RESULT := SINGLETON (TREE_VOID);
        end if;
        if IS_EMPTY (LIST_2) then
          return EXTRAINFO_TYPE (APPEND (RESULT, LIST_1.FIRST));
        end if;
      end if;

      while not IS_EMPTY (LIST_1) loop
        RESULT := APPEND (RESULT, HEAD (LIST_1));
        LIST_1 := TAIL (LIST_1);
      end loop;
      return EXTRAINFO_TYPE (APPEND (RESULT, LIST_2.FIRST));
    end;
  end COMBINE_EXTRAINFO;

   --|----------------------------------------------------------------------------------------------
end SET_UTIL;
