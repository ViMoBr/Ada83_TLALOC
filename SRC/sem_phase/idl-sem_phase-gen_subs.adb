separate (IDL.SEM_PHASE)
    --|----------------------------------------------------------------------------------------------
    --| GEN_SUBS
    --|----------------------------------------------------------------------------------------------
package body GEN_SUBS is
  use NEWSNAM;
  use VIS_UTIL;
  use PRE_FCNS;

  procedure SUBSTITUTE_GENERAL_NODE (NODE : in out TREE; NODE_HASH : in out NODE_HASH_TYPE; H : H_TYPE);

  function HASH_NODE_HASH (NODE_HASH : NODE_HASH_TYPE; NODE : TREE) return Natural;

  procedure SEARCH_NODE_HASH (NODE_HASH : in out NODE_HASH_TYPE; NODE : in out TREE);
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
  procedure REPLACE_NODE (NODE : in out TREE; NODE_HASH : in out NODE_HASH_TYPE) is
    OLD_NODE : constant TREE := NODE;
  begin
    NODE := COPY_NODE (NODE);
    INSERT_NODE_HASH (NODE_HASH, NODE, OLD_NODE);
  end REPLACE_NODE;

  procedure SUBSTITUTE_GENERAL_NODE (NODE : in out TREE; NODE_HASH : in out NODE_HASH_TYPE; H : H_TYPE) is
    use IDL_TBL;

    OLD_NODE      : constant TREE := NODE;
    OLD_ATTRIBUTE : TREE;
    ATTRIBUTE     : TREE;
  begin

                -- FOR EACH ATTRIBUTE OF THE GIVEN NODE
    for I in 1 .. N_SPEC (NODE.TY).NS_SIZE loop
      ATTRIBUTE     := DABS (I, NODE);
      OLD_ATTRIBUTE := ATTRIBUTE;

                        -- SUBSTITUTE FOR IT
      SUBSTITUTE (ATTRIBUTE, NODE_HASH, H);

                        -- IF IT WAS CHANGED BY THE SUBSTITUTION
      if ATTRIBUTE /= OLD_ATTRIBUTE then

                                -- IF THIS IS THE FIRST CHANGE
        if NODE = OLD_NODE then

                                        -- CREATE A NEW NODE
          NODE := COPY_NODE (NODE);
        end if;

                                -- REPLACE THE CHANGED ATTRIBUTE
        DABS (I, NODE, ATTRIBUTE);
      end if;
    end loop;
  end SUBSTITUTE_GENERAL_NODE;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
  procedure SUBSTITUTE_ATTRIBUTES (NODE : in out TREE; NODE_HASH : in out NODE_HASH_TYPE; H_IN : H_TYPE) is
    use IDL_TBL;
    H : H_TYPE renames H_IN;

    OLD_ATTRIBUTE : TREE;
    ATTRIBUTE     : TREE;
  begin

                -- FOR EACH ATTRIBUTE OF THE GIVEN NODE
    for I in 1 .. N_SPEC (NODE.TY).NS_SIZE loop
      ATTRIBUTE     := DABS (I, NODE);
      OLD_ATTRIBUTE := ATTRIBUTE;

                        -- SUBSTITUTE FOR IT
      SUBSTITUTE (ATTRIBUTE, NODE_HASH, H);

                        -- IF IT WAS CHANGED BY THE SUBSTITUTION
      if ATTRIBUTE /= OLD_ATTRIBUTE then

                                -- REPLACE THE CHANGED ATTRIBUTE
        DABS (I, NODE, ATTRIBUTE);
      end if;
    end loop;
  end SUBSTITUTE_ATTRIBUTES;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|
  procedure SUBSTITUTE (NODE : in out TREE; NODE_HASH : in out NODE_HASH_TYPE; H_IN : H_TYPE) is
    OLD_NODE : constant TREE := NODE;
    H        : H_TYPE renames H_IN;
  begin
                -- $$$$ FOR TESTING -- AVOID RUNAWAY SUBSTITUTION
    if NODE_HASH.LIMIT > 0 then
      NODE_HASH.LIMIT := NODE_HASH.LIMIT - 1;
    else
      Put_Line ("!! RUNAWAY LOOP IN GENERIC SUBSTITUTION");
      raise Program_Error;
    end if;

                -- CHECK FOR NODE WITH NO ATTRIBUTES
    if NODE.PT = HI or NODE.PT = S then
      return;                                           --| ENTETE/INTEGER OU SRCPOS
    elsif NODE.PG = 0 or else DABS (0, NODE).NSIZ = 0 then
      return;                               --| POINTEUR P NIL OU VOID OU VIRGIN OU SANS ATTRIBUT
    end if;
                -- IF NODE HAS ALREADY BEEN CONSIDERED
    SEARCH_NODE_HASH (NODE_HASH, NODE);

                -- IF IT WAS ACTUALLY CHANGED
    if NODE /= OLD_NODE then

                        -- RETURN RESULT FROM HASH TABLE
      return;
    end if;

    case NODE.TY is

      when DN_ROOT =>
        Put_Line ("!! INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when DN_TXTREP | DN_NUM_VAL =>
        null;

      when CLASS_BOOLEAN | DN_NIL =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when DN_LIST =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when DN_SOURCELINE | DN_ERROR =>
        Put_Line ("!! INVALID NODE IN GENERIC COPY");

      when DN_SYMBOL_REP =>
        null;

      when DN_HASH | DN_VOID =>
        Put_Line ("!! INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when CLASS_DEF_NAME =>
                                -- (ONLY SUBSTITUTED IF FOUND IN HASH TABLE)
        null;

      when DN_BLOCK_MASTER =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_DSCRMT_PARAM_DECL | DN_NUMBER_DECL | DN_EXCEPTION_DECL | DN_DEFERRED_CONSTANT_DECL =>
        declare
          SOURCE_NAME_S    : TREE     := D (AS_SOURCE_NAME_S, NODE);
          SOURCE_NAME_LIST : SEQ_TYPE := LIST (SOURCE_NAME_S);
          SOURCE_NAME      : TREE;
        begin
          while not IS_EMPTY (SOURCE_NAME_LIST) loop
            POP (SOURCE_NAME_LIST, SOURCE_NAME);
            REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H, NODE);
          end loop;
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when CLASS_OBJECT_DECL =>
        declare
          SOURCE_NAME_S    : TREE      := D (AS_SOURCE_NAME_S, NODE);
          SOURCE_NAME_LIST : SEQ_TYPE  := LIST (SOURCE_NAME_S);
          SOURCE_NAME      : TREE;
          TYPE_DEF_KIND    : NODE_NAME := D (AS_TYPE_DEF, NODE).TY;
        begin
          while not IS_EMPTY (SOURCE_NAME_LIST) loop
            POP (SOURCE_NAME_LIST, SOURCE_NAME);

            REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H, NODE);
            if TYPE_DEF_KIND = DN_CONSTRAINED_ARRAY_DEF then
              GEN_PREDEFINED_OPERATORS (D (SM_OBJ_TYPE, SOURCE_NAME), H);
            end if;
          end loop;

          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when DN_TYPE_DECL =>
        declare
          SOURCE_NAME     : TREE := D (AS_SOURCE_NAME, NODE);
          DERIVED_ID_LIST : SEQ_TYPE;
          DERIVED_ID      : TREE;
        begin
          REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H, NODE);
          GEN_PREDEFINED_OPERATORS (D (SM_TYPE_SPEC, SOURCE_NAME), H);
          if D (AS_TYPE_DEF, NODE).TY = DN_DERIVED_DEF then
            DERIVED_ID_LIST := LIST (D (AS_TYPE_DEF, NODE));
            while not IS_EMPTY (DERIVED_ID_LIST) loop
              POP (DERIVED_ID_LIST, DERIVED_ID);
              REPLACE_SOURCE_NAME (DERIVED_ID, NODE_HASH, H);
            end loop;
          end if;
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when DN_SUBTYPE_DECL =>
        declare
          SOURCE_NAME : TREE := D (AS_SOURCE_NAME, NODE);
        begin
          REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H);
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when DN_TASK_DECL | CLASS_SIMPLE_RENAME_DECL =>
        declare
          SOURCE_NAME : TREE := D (AS_SOURCE_NAME, NODE);
        begin
          REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H, NODE);
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when CLASS_UNIT_DECL =>
        declare
          SOURCE_NAME : TREE := D (AS_SOURCE_NAME, NODE);
        begin
          REPLACE_SOURCE_NAME (SOURCE_NAME, NODE_HASH, H, NODE);
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        end;

      when DN_NULL_COMP_DECL =>
        null;

      when CLASS_NAMED_REP | DN_RECORD_REP | DN_USE =>
                                -- $$$$ WORRY ABOUT FORWARD REFS TO ADDRESS CLAUSES
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when DN_PRAGMA =>
        declare
          USED_NAME_ID : TREE := D (AS_USED_NAME_ID, NODE);
        begin
          USED_NAME_ID := COPY_NODE (USED_NAME_ID);
          if D (SM_DEFN, USED_NAME_ID) /= TREE_VOID then
            SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
          end if;
        end;

      when DN_SUBPROGRAM_BODY | DN_PACKAGE_BODY | DN_TASK_BODY | DN_SUBUNIT =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when CLASS_TYPE_DEF =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_SEQUENCES =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_STM_ELEM =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when CLASS_NAMED_ASSOC =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_USED_OBJECT =>
        declare
          OLD_DEFN : constant TREE := D (SM_DEFN, NODE);
          DEFN     : TREE          := OLD_DEFN;
          EXP_TYPE : TREE          := D (SM_EXP_TYPE, NODE);
        begin
          SUBSTITUTE (DEFN, NODE_HASH, H);
          if DEFN /= OLD_DEFN then
            SUBSTITUTE (EXP_TYPE, NODE_HASH, H);
            NODE := COPY_NODE (NODE);
            D (SM_DEFN, NODE, DEFN);
            D (SM_EXP_TYPE, NODE, EXP_TYPE);
          end if;
        end;

      when CLASS_USED_NAME | CLASS_NAME_EXP | CLASS_EXP_EXP | CLASS_CONSTRAINT | CLASS_CHOICE | CLASS_HEADER | CLASS_UNIT_DESC | CLASS_MEMBERSHIP_OP | CLASS_SHORT_CIRCUIT_OP =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_TEST_CLAUSE_ELEM | CLASS_ITERATION | CLASS_ALTERNATIVE_ELEM =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when CLASS_COMP_REP_ELEM =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when CLASS_CONTEXT_ELEM =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when CLASS_VARIANT_ELEM | DN_ALIGNMENT | DN_VARIANT_PART | DN_COMP_LIST =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when DN_COMPILATION | DN_COMPILATION_UNIT =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;

      when DN_INDEX =>
        SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);

      when DN_TASK_SPEC =>
        null;

      when CLASS_NON_TASK =>
        if D (SM_BASE_TYPE, NODE) /= NODE then
          SUBSTITUTE_GENERAL_NODE (NODE, NODE_HASH, H);
        else
          null;
        end if;

      when CLASS_PRIVATE_SPEC | DN_INCOMPLETE =>
        null;

      when DN_REAL_VAL =>
        null;

      when DN_UNIVERSAL_INTEGER | DN_UNIVERSAL_FIXED | DN_UNIVERSAL_REAL | DN_USER_ROOT | DN_TRANS_WITH .. DN_NULLARY_CALL =>
        Put_Line ("INVALID NODE IN GENERIC COPY");
        raise Program_Error;
      when DN_VIRGIN =>
        Put_Line ("!! UN NOEUD NON INITIALISE");
        raise Program_Error;
    end case;

                -- IF A CHANGE WAS MADE
    if NODE /= OLD_NODE then

                        -- ENTER CHANGE IN HASH TABLE
      INSERT_NODE_HASH (NODE_HASH, NODE, OLD_NODE);
    end if;
  end SUBSTITUTE;
      --|-------------------------------------------------------------------------------------------
      --|
  function HASH_NODE_HASH (NODE_HASH : NODE_HASH_TYPE; NODE : TREE) return Natural is
    HASH_CODE : Natural := abs (Integer (NODE.PG) - 79 * Integer (NODE.LN));
  begin
    HASH_CODE := HASH_CODE mod NODE_HASH.A'LENGTH;
    return HASH_CODE;
  end HASH_NODE_HASH;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
  procedure INSERT_NODE_HASH (NODE_HASH : in out NODE_HASH_TYPE; NEW_NODE : TREE; OLD_NODE : TREE) is
    HASH_INDEX     : Natural := HASH_NODE_HASH (NODE_HASH, OLD_NODE);
    HASH_CHAIN     : TREE    := NODE_HASH.A (HASH_INDEX);
    NEW_HASH_CHAIN : TREE    := MAKE (DN_LIB_INFO);
  begin
    D (XD_SHORT, NEW_HASH_CHAIN, HASH_CHAIN);
    D (XD_PRIMARY, NEW_HASH_CHAIN, OLD_NODE);
    D (XD_SECONDARY, NEW_HASH_CHAIN, NEW_NODE);
    NODE_HASH.A (HASH_INDEX) := NEW_HASH_CHAIN;
  end INSERT_NODE_HASH;
      --|-------------------------------------------------------------------------------------------
      --|
  procedure SEARCH_NODE_HASH (NODE_HASH : in out NODE_HASH_TYPE; NODE : in out TREE) is
    HASH_INDEX : Natural := HASH_NODE_HASH (NODE_HASH, NODE);
    HASH_CHAIN : TREE    := NODE_HASH.A (HASH_INDEX);
  begin
    while HASH_CHAIN /= TREE_VOID loop
      if D (XD_PRIMARY, HASH_CHAIN) = NODE then
        NODE := D (XD_SECONDARY, HASH_CHAIN);
        exit;
      end if;
      HASH_CHAIN := D (XD_SHORT, HASH_CHAIN);
    end loop;
  end SEARCH_NODE_HASH;

    --|----------------------------------------------------------------------------------------------
end GEN_SUBS;
