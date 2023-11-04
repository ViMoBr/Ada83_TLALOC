    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	SEM_GLOB
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY SEM_GLOB IS
      USE EXPRESO;
    
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE INITIALIZE_GLOBAL_DATA IS
      BEGIN
      
         SU.USED_PACKAGE_LIST	:= (TREE_NIL,TREE_NIL);
         SU.INCOMPLETE_TYPE_LIST 	:= (TREE_NIL,TREE_NIL);
         SU.PRIVATE_TYPE_LIST	:= (TREE_NIL,TREE_NIL);
      
         INITIAL_H := (	REGION_DEF	=> TREE_VOID,
            	LEX_LEVEL	=> 1,
            IS_IN_SPEC	=> TRUE,
            IS_IN_BODY	=> FALSE,
            SUBP_SYMREP	=> TREE_VOID,
            RETURN_TYPE	=> TREE_VOID,
            ENCLOSING_LOOP_ID	=> TREE_VOID
            );
      END INITIALIZE_GLOBAL_DATA;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       PROCEDURE INITIALIZE_PREDEFINED_TYPES IS
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE INIT
          FUNCTION INIT ( X :STRING ) RETURN TREE IS
            DEFLIST		: SEQ_TYPE	:= LIST ( STORE_SYM ( X ) );
            DEF		: TREE;
         BEGIN
            WHILE NOT IS_EMPTY ( DEFLIST ) LOOP
               POP ( DEFLIST, DEF );
               IF D ( XD_REGION_DEF, DEF ) = PREDEFINED_STANDARD_DEF THEN
                  RETURN D ( SM_TYPE_SPEC, D ( XD_SOURCE_NAME, DEF ) );
               END IF;
            END LOOP;
            RETURN TREE_VOID;
         END INIT;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE SET_RANGE_BOUNDS
          PROCEDURE SET_RANGE_BOUNDS ( TYPE_NODE :TREE; LOW, HIGH :OUT TREE ) IS
            RANGE_NODE: TREE;
         BEGIN
            IF TYPE_NODE /= TREE_VOID THEN
               RANGE_NODE := D ( SM_RANGE, TYPE_NODE );
               LOW := EXPRESO.GET_STATIC_VALUE ( D ( AS_EXP1, RANGE_NODE ) );
               HIGH := GET_STATIC_VALUE ( D ( AS_EXP2, RANGE_NODE ) );
            ELSE
               LOW := UARITH.U_VAL ( 0 );
               HIGH := UARITH.U_VAL ( 0 );
            END IF;
         END SET_RANGE_BOUNDS;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE SET_ACCURACY
          PROCEDURE SET_ACCURACY ( TYPE_NODE :TREE; ACCURACY :OUT TREE ) IS
         BEGIN
            IF TYPE_NODE /= TREE_VOID THEN
               ACCURACY := D ( SM_ACCURACY, TYPE_NODE );
            ELSE
               ACCURACY := UARITH.U_VAL ( 0 );
            END IF;
         END SET_ACCURACY;
      
      BEGIN
         PREDEFINED_BOOLEAN	:= INIT ( "BOOLEAN" );
         PREDEFINED_SHORT_INTEGER	:= INIT ( "SHORT_INTEGER" );
         PREDEFINED_INTEGER	:= INIT ( "INTEGER" );
         PREDEFINED_LONG_INTEGER	:= INIT ( "LONG_INTEGER" );
         PREDEFINED_FLOAT	:= INIT ( "FLOAT" );
         PREDEFINED_LONG_FLOAT	:= INIT ( "LONG_FLOAT" );
         PREDEFINED_STRING	:= INIT ( "STRING" );
         PREDEFINED_DURATION	:= INIT ( "DURATION" );
         PREDEFINED_ADDRESS	:= INIT ( "_ADDRESS" );
      
         PREDEFINED_STANDARD_ID := D ( XD_SOURCE_NAME, PREDEFINED_STANDARD_DEF );
      
         SET_RANGE_BOUNDS ( PREDEFINED_SHORT_INTEGER, PREDEFINED_SHORT_INTEGER_FIRST, PREDEFINED_SHORT_INTEGER_LAST );
         SET_RANGE_BOUNDS ( PREDEFINED_INTEGER, PREDEFINED_INTEGER_FIRST, PREDEFINED_INTEGER_LAST );
         SET_RANGE_BOUNDS ( PREDEFINED_LONG_INTEGER, PREDEFINED_LONG_INTEGER_FIRST, PREDEFINED_LONG_INTEGER_LAST );
         IF PREDEFINED_LONG_INTEGER /= TREE_VOID THEN
            PREDEFINED_LARGEST_INTEGER := PREDEFINED_LONG_INTEGER;
         ELSE
            PREDEFINED_LARGEST_INTEGER := PREDEFINED_INTEGER;
         END IF;
      
         SET_RANGE_BOUNDS ( PREDEFINED_FLOAT, PREDEFINED_FLOAT_FIRST, PREDEFINED_FLOAT_LAST );
         SET_ACCURACY ( PREDEFINED_FLOAT, PREDEFINED_FLOAT_ACCURACY);
         SET_RANGE_BOUNDS ( PREDEFINED_LONG_FLOAT, PREDEFINED_LONG_FLOAT_FIRST, PREDEFINED_LONG_FLOAT_LAST );
         SET_ACCURACY ( PREDEFINED_LONG_FLOAT, PREDEFINED_LONG_FLOAT_ACCURACY );
         IF PREDEFINED_LONG_FLOAT /= TREE_VOID THEN
            PREDEFINED_LARGEST_FLOAT := PREDEFINED_LONG_FLOAT;
         ELSE
            PREDEFINED_LARGEST_FLOAT := PREDEFINED_FLOAT;
         END IF;
      
      END INITIALIZE_PREDEFINED_TYPES;
      
   --|----------------------------------------------------------------------------------------------
   END SEM_GLOB;
