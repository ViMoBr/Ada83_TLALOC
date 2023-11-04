    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	HOM_UNIT
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY HOM_UNIT IS
      USE VIS_UTIL;
      USE DEF_UTIL;
      USE RED_SUBP;
      USE SET_UTIL;
      USE EXP_TYPE, EXPRESO;
      USE ATT_WALK;
      USE MAKE_NOD;
    
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION WALK_HOMOGRAPH_UNIT (UNIT_NAME: TREE; HEADER: TREE)
                        RETURN TREE
                        IS
         NEW_NAME: TREE := UNIT_NAME;
         INDEX: TREE := TREE_VOID;
         TYPESET: TYPESET_TYPE := EMPTY_TYPESET;
         DEFSET: DEFSET_TYPE;
         DEFINTERP: DEFINTERP_TYPE;
         DEF: TREE;
         DEF_HEADER: TREE;
         NEW_DEFSET: DEFSET_TYPE := EMPTY_DEFSET;
         INDEX_OK: BOOLEAN := TRUE;
         EXTRAINFO: EXTRAINFO_TYPE := NULL_EXTRAINFO;
         DUMMY_FLAG: BOOLEAN;
      BEGIN
         IF NEW_NAME.TY = DN_STRING_LITERAL THEN
            NEW_NAME := MAKE_USED_OP_FROM_STRING(NEW_NAME);
         END IF;
      
         IF NEW_NAME.TY = DN_FUNCTION_CALL
                                AND THEN (D(AS_NAME, NEW_NAME).TY =
                                DN_USED_OBJECT_ID
                                OR ELSE D(AS_NAME, NEW_NAME).TY =
                                DN_SELECTED )
                                AND THEN IS_EMPTY(TAIL(LIST(D(
                                                        AS_GENERAL_ASSOC_S,
                                                        NEW_NAME))))
                                AND THEN HEAD(LIST(D(
                                                        AS_GENERAL_ASSOC_S,
                                                        NEW_NAME))).TY /=
                                DN_ASSOC
                                THEN
            INDEX := HEAD(LIST(D(AS_GENERAL_ASSOC_S, NEW_NAME)));
            NEW_NAME := D(AS_NAME, NEW_NAME);
            EVAL_EXP_TYPES(INDEX, TYPESET);
         END IF;
      
         IF NEW_NAME.TY = DN_ATTRIBUTE THEN
            EVAL_ATTRIBUTE(NEW_NAME, TYPESET, DUMMY_FLAG,
                                IS_FUNCTION => TRUE);
                        -- $$$$ SHOULD CHECK FOR VALID ATTRIBUTE
            NEW_NAME := RESOLVE_ATTRIBUTE(NEW_NAME);
         ELSIF NEW_NAME.TY = DN_USED_OBJECT_ID
                                OR ELSE NEW_NAME.TY = DN_USED_OP
                                OR ELSE NEW_NAME.TY = DN_USED_CHAR
                                OR ELSE NEW_NAME.TY = DN_SELECTED THEN
            FIND_VISIBILITY(NEW_NAME, DEFSET);
            IF NOT IS_EMPTY(DEFSET) THEN
               WHILE NOT IS_EMPTY(DEFSET) LOOP
                  POP(DEFSET, DEFINTERP);
                  DEF := GET_DEF(DEFINTERP);
                  DEF_HEADER := D(XD_HEADER, DEF);
                  IF INDEX = TREE_VOID THEN
                     IF DEF_HEADER.TY
                                                                IN
                                                                DN_PROCEDURE_SPEC ..
                                                                DN_FUNCTION_SPEC
                                                                OR ELSE ( DEF_HEADER.TY = DN_ENTRY
                                                                AND THEN D(
                                                                        AS_DISCRETE_RANGE,
                                                                        DEF_HEADER)
                                                                =
                                                                TREE_VOID )
                                                                THEN
                        IF
                                                                        ARE_HOMOGRAPH_HEADERS (
                                                                        HEADER,
                                                                        DEF_HEADER)
                                                                        THEN
                           ADD_TO_DEFSET(
                                                                        NEW_DEFSET,
                                                                        DEFINTERP);
                        END IF;
                     END IF;
                  ELSE
                                                -- RETRIEVE THE HEADER FOR ENTRY FAMILY MEMBER
                     IF D(XD_SOURCE_NAME,
                                                                        DEF).TY =
                                                                DN_ENTRY_ID THEN
                        DEF_HEADER := D(
                                                                SM_SPEC, D(
                                                                        XD_SOURCE_NAME,
                                                                        DEF));
                     END IF;
                  
                     IF DEF_HEADER.TY =
                                                                DN_ENTRY
                                                                AND THEN D(
                                                                AS_DISCRETE_RANGE,
                                                                DEF_HEADER) /=
                                                                TREE_VOID
                                                                THEN
                        CHECK_ACTUAL_TYPE
                                                                (
                                                                GET_TYPE_OF_DISCRETE_RANGE
                                                                ( D(
                                                                                AS_DISCRETE_RANGE,
                                                                                DEF_HEADER) )
                                                                , TYPESET
                                                                , INDEX_OK
                                                                ,
                                                                EXTRAINFO );
                        IF INDEX_OK
                                                                        AND THEN
                                                                        IS_SAME_PARAMETER_PROFILE
                                                                        (
                                                                        D(
                                                                                AS_PARAM_S,
                                                                                HEADER)
                                                                        ,
                                                                        D(
                                                                                AS_PARAM_S,
                                                                                DEF_HEADER) )
                                                                        THEN
                           ADD_EXTRAINFO(
                                                                        DEFINTERP,
                                                                        EXTRAINFO);
                           ADD_TO_DEFSET(
                                                                        NEW_DEFSET,
                                                                        DEFINTERP);
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
               DEFSET := NEW_DEFSET;
               IF IS_EMPTY(DEFSET) THEN
                  IF NEW_NAME.TY = DN_SELECTED THEN
                     ERROR(D(LX_SRCPOS,
                                                                UNIT_NAME)
                                                        ,
                                                        "NO MATCHING SUBPROGRAMS - "
                                                        & PRINT_NAME ( D(
                                                                        LX_SYMREP
                                                                        ,
                                                                        D(
                                                                                AS_DESIGNATOR,
                                                                                NEW_NAME) )) );
                  ELSE
                     ERROR(D(LX_SRCPOS,
                                                                UNIT_NAME)
                                                        ,
                                                        "NO MATCHING SUBPROGRAMS - "
                                                        & PRINT_NAME ( D(
                                                                        LX_SYMREP,
                                                                        NEW_NAME)) );
                  END IF;
               END IF;
               REQUIRE_UNIQUE_DEF(NEW_NAME, DEFSET);
               NEW_NAME := RESOLVE_NAME(NEW_NAME,
                                        GET_THE_ID(DEFSET));
               IF INDEX /= TREE_VOID THEN
                  IF IS_EMPTY(DEFSET) THEN
                     INDEX := RESOLVE_EXP(
                                                        INDEX, TREE_VOID);
                  ELSE
                     INDEX := RESOLVE_EXP(
                                                        INDEX,
                                                        GET_TYPE_OF_DISCRETE_RANGE
                                                        ( D(
                                                                        AS_DISCRETE_RANGE,
                                                                        DEF_HEADER) ));
                  END IF;
                  NEW_NAME := MAKE_INDEXED
                                                ( AS_NAME => NEW_NAME
                                                , AS_EXP_S => MAKE_EXP_S
                                                ( LIST => SINGLETON(INDEX)
                                                        , LX_SRCPOS => D(
                                                                LX_SRCPOS
                                                                , D(
                                                                        AS_GENERAL_ASSOC_S,
                                                                        UNIT_NAME) ))
                                                , LX_SRCPOS => D(
                                                        LX_SRCPOS,
                                                        UNIT_NAME) );
               END IF;
            END IF;
         ELSE
            ERROR( D( LX_SRCPOS, NEW_NAME), "CANNOT BE SUBPROGRAM NAME" );
            NEW_NAME := RESOLVE_EXP(NEW_NAME, TREE_VOID);
         END IF;
      
         RETURN NEW_NAME;
      END WALK_HOMOGRAPH_UNIT;
      
   --|----------------------------------------------------------------------------------------------
   END HOM_UNIT;
