    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	NEWSNAM
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY NEWSNAM IS
      USE VIS_UTIL; -- FOR DEBUG (NODE_REP)
      USE DEF_UTIL;
      USE NOD_WALK;
   
       PROCEDURE REPLACE_SOURCE_NAME
                        ( SOURCE_NAME:	IN OUT TREE
                        ; NODE_HASH:	IN OUT NODE_HASH_TYPE
                        ; H_IN: 	H_TYPE
                        ; DECL: 	TREE := TREE_VOID )
                        IS
                -- MAKES A NEW SOURCE NAME FOR A DECLARATION CREATED BY INSTANTIATION
                -- ... MUST BE CAREFUL TO SUBSTITUTE FOR CONSTITUTENTS IN THE
                -- ... PROPER ORDER SO THAT DECLARATIONS ARE PROCESSED BEFORE USED
                -- ... (EVENTUALLY, THIS PROCEDURE COULD BE EXTENDED TO SUBSTITUTE
                -- ... FOR GENERIC BODIES )
      
         OLD_NAME:	CONSTANT TREE := SOURCE_NAME;
         DEF:		TREE := TREE_VOID;
         H:		H_TYPE := H_IN;
         S:		S_TYPE;
      BEGIN
                -- MAKE SURE IDENTIFIER IS IN SYMBOL TABLE, EVEN IF NAME DOES NOT OCCUR
                -- ... IN THE CURRENT COMPILATION
         IF D(LX_SYMREP, SOURCE_NAME).TY = DN_TXTREP THEN
            D(LX_SYMREP
                                , SOURCE_NAME
                                , STORE_SYM ( PRINT_NAME ( D(LX_SYMREP,
                                                        SOURCE_NAME))) );
         END IF;
      
                -- CREATE A NEW NAME
         REPLACE_NODE(SOURCE_NAME, NODE_HASH);
      
         CASE CLASS_SOURCE_NAME'(SOURCE_NAME.TY) IS
         
                        -- FOR A VARIABLE ID
            WHEN DN_VARIABLE_ID =>
               DECLARE
                  TYPE_SPEC:	TREE;
               BEGIN
               
                                        -- MAKE A DEF FOR IT
                  DEF := MAKE_DEF_FOR_ID(
                                                SOURCE_NAME, H);
                  MAKE_DEF_VISIBLE(DEF);
               
                                        -- IF THIS VARIABLE IS DECLARED BY A TASK DECLARATION
                  IF DECL.TY = DN_TASK_DECL THEN
                  
                                                -- IN THE TASK REGION, MAKE NEW TYPE AND SUBSTITUTE
                     ENTER_REGION(DEF, H, S);
                     TYPE_SPEC := D(
                                                        SM_OBJ_TYPE,
                                                        SOURCE_NAME);
                     REPLACE_NODE(TYPE_SPEC,
                                                        NODE_HASH);
                     SUBSTITUTE_ATTRIBUTES(
                                                        TYPE_SPEC,
                                                        NODE_HASH, H);
                     LEAVE_REGION(DEF, S);
                     H := H_IN;
                  
                                                -- ELSE IF DECLARATION INCLUDES A CONSTRAINED ARRAY DEFINITION
                  ELSIF DECL.TY /=
                                                        DN_RENAMES_OBJ_DECL
                                                        AND THEN D( AS_TYPE_DEF, DECL).TY =
                                                        DN_CONSTRAINED_ARRAY_DEF THEN
                  
                                                -- MAKE A NEW BASE TYPE
                     TYPE_SPEC
                                                        := GET_BASE_TYPE(
                                                        D(SM_OBJ_TYPE,
                                                                SOURCE_NAME));
                     REPLACE_NODE(TYPE_SPEC,
                                                        NODE_HASH);
                     SUBSTITUTE_ATTRIBUTES(
                                                        TYPE_SPEC,
                                                        NODE_HASH, H);
                  END IF;
               END;
         
         
                        -- FOR A CONSTANT ID
            WHEN DN_CONSTANT_ID =>
               DECLARE
                  FIRST_NAME:	TREE := SOURCE_NAME;
                  TYPE_SPEC:	TREE;
                  INIT_EXP:	TREE;
               BEGIN
               
                                        -- IF THIS IS THE DEFINING OCCURRENCE
                  FIRST_NAME := D(SM_FIRST, OLD_NAME);
                  IF FIRST_NAME = OLD_NAME THEN
                     FIRST_NAME := SOURCE_NAME;
                  
                                                -- MAKE A DEF FOR IT
                     DEF := MAKE_DEF_FOR_ID(
                                                        SOURCE_NAME, H);
                     MAKE_DEF_VISIBLE(DEF);
                  
                                                -- IF THIS IS A DEFERRED CONSTANT DECLARATION
                     IF DECL.TY =
                                                                DN_DEFERRED_CONSTANT_DECL THEN
                     
                                                        -- CLEAR THE INITIAL EXPRESSION
                        D(SM_INIT_EXP,
                                                                SOURCE_NAME,
                                                                TREE_VOID);
                     
                                                        -- ELSE IF DECLARATION INCLUDES A CONSTRAINED ARRAY DEF
                     ELSIF D(AS_TYPE_DEF,
                                                                        DECL).TY =
                                                                DN_CONSTRAINED_ARRAY_DEF
                                                                THEN
                     
                                                        -- MAKE A NEW BASE TYPE
                        TYPE_SPEC
                                                                :=
                                                                GET_BASE_TYPE(
                                                                D(
                                                                        SM_TYPE_SPEC,
                                                                        SOURCE_NAME));
                        REPLACE_NODE(
                                                                TYPE_SPEC,
                                                                NODE_HASH);
                        SUBSTITUTE_ATTRIBUTES(
                                                                TYPE_SPEC,
                                                                NODE_HASH,
                                                                H);
                     
                     END IF;
                  
                                                -- ELSE -- SINCE THIS IS NOT THE DEFINING OCCURRENCE
                  ELSE
                     SUBSTITUTE(FIRST_NAME,
                                                        NODE_HASH, H);
                  
                                                -- FIX UP FORWARD REFERENCE IN THE DEFERRED CONSTANT
                     INIT_EXP := D(SM_INIT_EXP,
                                                        SOURCE_NAME);
                     SUBSTITUTE(INIT_EXP,
                                                        NODE_HASH, H);
                     D(SM_INIT_EXP, FIRST_NAME,
                                                        INIT_EXP);
                  END IF;
               END;
         
         
                        -- FOR A DISCRIMINANT ID
            WHEN DN_DISCRIMINANT_ID =>
               DECLARE
                  FIRST_NAME:	TREE := D(SM_FIRST,
                                                OLD_NAME);
               BEGIN
               
                                        -- IF THIS IS THE DEFINING OCCURRENCE
                  IF FIRST_NAME = OLD_NAME THEN
                  
                                                -- MAKE A DEF FOR IT
                     DEF := MAKE_DEF_FOR_ID(
                                                        SOURCE_NAME, H);
                     MAKE_DEF_VISIBLE(DEF);
                  END IF;
               END;
         
         
                        -- FOR AN ENUMERATION LITERAL
            WHEN CLASS_ENUM_LITERAL =>
               DECLARE
                  HEADER: TREE := TREE_VOID;
                  DEFLIST: SEQ_TYPE := LIST(D(
                                                        LX_SYMREP,
                                                        SOURCE_NAME));
                  DEF: TREE;
               BEGIN
               
                                        -- IF NAME IS USED
                  WHILE NOT IS_EMPTY(DEFLIST) LOOP
                     POP(DEFLIST, DEF);
                     IF D(XD_SOURCE_NAME, DEF) =
                                                                OLD_NAME THEN
                        HEADER := D(
                                                                XD_HEADER,
                                                                DEF);
                        EXIT;
                     END IF;
                  END LOOP;
                  IF HEADER /= TREE_VOID THEN
                  
                                                -- GET AND SUBSTITUTE IN THE OLD HEADER
                     HEADER := D(XD_HEADER,
                                                        GET_DEF_FOR_ID(
                                                                OLD_NAME));
                     SUBSTITUTE(HEADER,
                                                        NODE_HASH, H);
                  
                                                -- MAKE A DEF FOR THE NEW SOURCE NAME
                     DEF := MAKE_DEF_FOR_ID(
                                                        SOURCE_NAME, H);
                     MAKE_DEF_VISIBLE(DEF,
                                                        HEADER);
                  END IF;
               END;
         
         
                        -- FOR A TYPE ID
            WHEN DN_TYPE_ID =>
               DECLARE
                  FIRST_NAME:	TREE := SOURCE_NAME;
                  TYPE_SPEC:	TREE;
               BEGIN
               
                                        -- GET THE ORIGINAL TYPE_SPEC AND DEFINING OCCURRENCE
                  TYPE_SPEC := D(SM_TYPE_SPEC,
                                                OLD_NAME);
                  FIRST_NAME := D(SM_FIRST, OLD_NAME);
               
                                        -- IF THIS IS THE DEFINING OCCURRENCE
                  IF FIRST_NAME = OLD_NAME THEN
                     FIRST_NAME := SOURCE_NAME;
                  
                                                -- MAKE A DEF FOR IT
                     DEF := MAKE_DEF_FOR_ID(
                                                        SOURCE_NAME, H);
                     MAKE_DEF_VISIBLE(DEF);
                  
                                                -- CLEAR ANY FORWARD REFERENCE TO FULL TYPE SPEC
                     IF TYPE_SPEC.TY IN
                                                                CLASS_CONSTRAINED THEN
                        TYPE_SPEC := D(
                                                                SM_BASE_TYPE,
                                                                TYPE_SPEC);
                     END IF;
                     IF TYPE_SPEC.TY =
                                                                DN_INCOMPLETE THEN
                        D(
                                                                XD_FULL_TYPE_SPEC,
                                                                TYPE_SPEC,
                                                                TREE_VOID);
                     ELSE
                        TYPE_SPEC :=
                                                                GET_BASE_TYPE(
                                                                TYPE_SPEC);
                     END IF;
                  
                                                -- ELSE -- SINCE THIS IS NOT THE DEFINING OCCURRENCE
                  ELSE
                     SUBSTITUTE(FIRST_NAME,
                                                        NODE_HASH, H);
                  
                                                -- GET THE EXISTING DEF
                     DEF := GET_DEF_FOR_ID(
                                                        FIRST_NAME);
                  END IF;
               
                                        -- GET AND REPLACE THE TYPE_SPEC NODE FOR THE BASE TYPE
                  TYPE_SPEC := GET_BASE_TYPE(
                                                TYPE_SPEC);
                  REPLACE_NODE(TYPE_SPEC, NODE_HASH);
               
                                        -- IF THIS TYPE IS (POSSIBLY) A DECLARATIVE REGION
                  IF TYPE_SPEC.TY = DN_RECORD
                                                        OR TYPE_SPEC.TY =
                                                        DN_TASK_SPEC THEN
                                                -- WBE 7/31/90
                  
                                                -- ENTER REGION AND SUBSTITUTE WITHIN THE TYPE SPEC
                     ENTER_REGION(DEF, H, S);
                     SUBSTITUTE_ATTRIBUTES(
                                                        TYPE_SPEC,
                                                        NODE_HASH, H);
                     LEAVE_REGION(DEF, S);
                     H :=
                                                        REPLACE_SOURCE_NAME.H_IN;
                  
                                                -- ELSE -- SINCE THIS TYPE CANNOT BE A DECLARATIVE REGION
                  ELSE
                  
                                                -- IF IT IS AN ENUMERATION TYPE
                     IF TYPE_SPEC.TY =
                                                                DN_ENUMERATION THEN
                     
                                                        -- MAKE NEW ENUMERATION LITERALS
                        DECLARE
                           LITERAL_LIST:
                                                                        SEQ_TYPE
                                                                        :=
                                                                        LIST(
                                                                        D(
                                                                                SM_LITERAL_S,
                                                                                TYPE_SPEC));
                           LITERAL:
                                                                        TREE;
                        BEGIN
                           WHILE NOT
                                                                                IS_EMPTY(
                                                                                LITERAL_LIST) LOOP
                              POP(
                                                                                LITERAL_LIST,
                                                                                LITERAL);
                              REPLACE_SOURCE_NAME
                                                                                (
                                                                                LITERAL
                                                                                ,
                                                                                NODE_HASH
                                                                                ,
                                                                                H );
                           END LOOP;
                        END;
                     END IF;
                  
                                                -- SUBSTITUTE WITHIN THE TYPE SPEC
                     SUBSTITUTE_ATTRIBUTES(
                                                        TYPE_SPEC,
                                                        NODE_HASH, H);
                  END IF;
               
                                        -- IF THIS WAS NOT A DEFINING OCCURRENCE
                  IF FIRST_NAME /= SOURCE_NAME THEN
                  
                                                -- GET AND SUBSTITUTE IN THE FULL SUBTYPE
                     TYPE_SPEC := D(
                                                        SM_TYPE_SPEC,
                                                        SOURCE_NAME);
                     SUBSTITUTE(TYPE_SPEC,
                                                        NODE_HASH, H);
                  
                                                -- FIX UP FORWARD REFERENCES IN DEFINING OCCURRENCE
                     IF FIRST_NAME.TY =
                                                                DN_TYPE_ID THEN
                        D(
                                                                XD_FULL_TYPE_SPEC
                                                                , D(
                                                                        SM_TYPE_SPEC,
                                                                        FIRST_NAME)
                                                                ,
                                                                TYPE_SPEC );
                     ELSE
                        D(SM_TYPE_SPEC
                                                                , D(
                                                                        SM_TYPE_SPEC,
                                                                        FIRST_NAME)
                                                                ,
                                                                TYPE_SPEC );
                     END IF;
                  END IF;
               END;
         
         
                        -- FOR AN [L_]PRIVATE_TYPE ID
            WHEN DN_PRIVATE_TYPE_ID | DN_L_PRIVATE_TYPE_ID =>
               DECLARE
                  TYPE_SPEC:	TREE;
               BEGIN
               
                                        -- MAKE A DEF FOR IT
                  DEF := MAKE_DEF_FOR_ID(
                                                SOURCE_NAME, H);
                  MAKE_DEF_VISIBLE(DEF);
               
                                        -- REPLACE THE TYPE_SPEC NODE FOR THE BASE TYPE
                  TYPE_SPEC := D(SM_TYPE_SPEC,
                                                SOURCE_NAME);
                  REPLACE_NODE(TYPE_SPEC, NODE_HASH);
               
                                        -- CLEAR FORWARD REFERENCE TO FULL TYPE SPEC
                  D(SM_TYPE_SPEC, TYPE_SPEC,
                                                TREE_VOID);
               
                                        -- ENTER REGION AND SUBSTITUTE WITHIN THE TYPE SPEC
                  ENTER_REGION(DEF, H, S);
                  SUBSTITUTE_ATTRIBUTES(TYPE_SPEC,
                                                NODE_HASH, H);
                  LEAVE_REGION(DEF, S);
                  H := REPLACE_SOURCE_NAME.H_IN;
               END;
         
         
                        -- FOR A UNIT OR ENTRY NAME
            WHEN CLASS_NON_TASK_NAME | DN_ENTRY_ID =>
               DECLARE
                  HEADER: TREE := D(SM_SPEC,
                                                SOURCE_NAME);
                  UNIT_DESC: TREE := TREE_VOID;
                  DECL_S: TREE;
                  NOT_EQUAL: TREE;
               BEGIN
               
                                        -- GET THE UNIT_DESC FROM THE DECLARATION
                                        -- ... (DECL VOID FOR "/=" OR DERIVED FUNCTION)
                  IF DECL /= TREE_VOID
                                                        AND THEN SOURCE_NAME.TY IN
                                                        CLASS_SUBPROG_PACK_NAME THEN
                     UNIT_DESC := D(
                                                        SM_UNIT_DESC,
                                                        SOURCE_NAME);
                  END IF;
               
                                        -- MAKE DEF AND ENTER REGION
                  DEF := MAKE_DEF_FOR_ID(
                                                SOURCE_NAME, H);
                  ENTER_REGION(DEF, H, S);
                  H.IS_IN_SPEC := FALSE;
               
                                        -- IF THIS IS AN INSTANTIATION
                  IF UNIT_DESC.TY =
                                                        DN_INSTANTIATION THEN
                  
                                                -- SUBSTITUTE FOR THE DECLARATIONS OF THE GENERIC ACTUALS
                     DECL_S := D(SM_DECL_S,
                                                        UNIT_DESC);
                     SUBSTITUTE(DECL_S,
                                                        NODE_HASH, H);
                  
                                                -- ELSE IF THIS IS A GENERIC DECLARATION
                  ELSIF SOURCE_NAME.TY =
                                                        DN_GENERIC_ID THEN
                  
                                                -- CLEAR THE FORWARD REFERENCE
                     D(SM_BODY, SOURCE_NAME,
                                                        TREE_VOID);
                  
                                                -- SUBSTITUTE FOR THE GENERIC PARAMETER LIST
                     DECL_S := D(
                                                        SM_GENERIC_PARAM_S,
                                                        SOURCE_NAME);
                     SUBSTITUTE(DECL_S,
                                                        NODE_HASH, H);
                  END IF;
               
                                        -- SUBSTITUTE FOR THE HEADER
                  IF HEADER.TY = DN_PACKAGE_SPEC THEN
                     DECL_S := D(AS_DECL_S1,
                                                        HEADER);
                     H.IS_IN_SPEC := TRUE;
                     SUBSTITUTE(DECL_S,
                                                        NODE_HASH, H);
                     H.IS_IN_SPEC := FALSE;
                  ELSIF HEADER.TY = DN_TASK_SPEC THEN
                     H.IS_IN_SPEC := TRUE;
                  END IF;
                  SUBSTITUTE(HEADER, NODE_HASH, H);
               
                                        -- MAKE THE DEF VISIBLE
                  IF SOURCE_NAME.TY IN
                                                        CLASS_SUBPROG_NAME THEN
                     MAKE_DEF_VISIBLE(DEF,
                                                        HEADER);
                  ELSE
                     MAKE_DEF_VISIBLE(DEF);
                  END IF;
               
                                        -- LEAVE REGION
                  LEAVE_REGION(DEF, S);
                  H := REPLACE_SOURCE_NAME.H_IN;
               
                                        -- IF THIS IS AN OPERATOR_ID FOR "="
                  IF SOURCE_NAME.TY =
                                                        DN_OPERATOR_ID
                                                        AND THEN D(
                                                        XD_NOT_EQUAL,
                                                        SOURCE_NAME) /=
                                                        TREE_VOID THEN
                  
                                                -- REPLACE THE INEQUALITY OPERATOR TOO
                     NOT_EQUAL := D(
                                                        XD_NOT_EQUAL,
                                                        SOURCE_NAME);
                     REPLACE_SOURCE_NAME(
                                                        NOT_EQUAL,
                                                        NODE_HASH, H,
                                                        TREE_VOID);
                     D(XD_NOT_EQUAL,
                                                        SOURCE_NAME,
                                                        NOT_EQUAL);
                  END IF;
               END;
         
         
                        -- FOR ID'S WITH NO SPECIAL STRUCTURE
            WHEN DN_NUMBER_ID | DN_COMPONENT_ID |
                                        CLASS_PARAM_NAME
                                        | DN_SUBTYPE_ID | DN_EXCEPTION_ID =>
            
                                -- MAKE A DEF IF NAME IS USED
               IF D(LX_SYMREP, SOURCE_NAME).TY =
                                                DN_SYMBOL_REP THEN
                  DEF := MAKE_DEF_FOR_ID(
                                                SOURCE_NAME, H);
                  MAKE_DEF_VISIBLE(DEF);
               END IF;
         
         
                        -- FOR ID'S WHICH SHOULD NOT OCCUR
            WHEN DN_ITERATION_ID | DN_TASK_BODY_ID |
                                        CLASS_LABEL_NAME =>
            
                                -- ABORT THE COMPILATION
               PUT_LINE ( "!! INVALID ID FOR GENERIC SUBSTITUTION");
               RAISE PROGRAM_ERROR;
         
         END CASE;
      
      
                -- SUBSTITUTE FOR THE ATTRIBUTES OF THE ID
         SUBSTITUTE_ATTRIBUTES(SOURCE_NAME, NODE_HASH, H);
      
      END REPLACE_SOURCE_NAME;
   
   --|----------------------------------------------------------------------------------------------
   END NEWSNAM;
