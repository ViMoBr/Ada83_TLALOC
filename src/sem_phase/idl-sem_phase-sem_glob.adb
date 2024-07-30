    separate ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	SEM_GLOB
    --|----------------------------------------------------------------------------------------------
    package body SEM_GLOB is
      use EXPRESO;
    
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure INITIALIZE_GLOBAL_DATA is
      begin
      
         SU.USED_PACKAGE_LIST		:= (TREE_NIL,TREE_NIL);
         SU.INCOMPLETE_TYPE_LIST 	:= (TREE_NIL,TREE_NIL);
         SU.PRIVATE_TYPE_LIST		:= (TREE_NIL,TREE_NIL);
      
         INITIAL_H := (	REGION_DEF	=> TREE_VOID,
			LEX_LEVEL		=> 1,
			IS_IN_SPEC	=> TRUE,
			IS_IN_BODY	=> FALSE,
			SUBP_SYMREP	=> TREE_VOID,
			RETURN_TYPE	=> TREE_VOID,
			ENCLOSING_LOOP_ID	=> TREE_VOID
		);
      end INITIALIZE_GLOBAL_DATA;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure INITIALIZE_PREDEFINED_TYPES is
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE INIT
          function INIT ( X :STRING ) return TREE is
            DEFLIST		: SEQ_TYPE	:= LIST ( STORE_SYM ( X ) );
            DEF		: TREE;
         begin
            while not IS_EMPTY ( DEFLIST ) loop
               POP ( DEFLIST, DEF );
               if D ( XD_REGION_DEF, DEF ) = PREDEFINED_STANDARD_DEF then
                  return D ( SM_TYPE_SPEC, D ( XD_SOURCE_NAME, DEF ) );
               end if;
            end loop;
            return TREE_VOID;
         end INIT;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE SET_RANGE_BOUNDS
          procedure SET_RANGE_BOUNDS ( TYPE_NODE :TREE; LOW, HIGH :out TREE ) is
            RANGE_NODE: TREE;
         begin
            if TYPE_NODE /= TREE_VOID then
               RANGE_NODE := D ( SM_RANGE, TYPE_NODE );
               LOW  := EXPRESO.GET_STATIC_VALUE ( D ( AS_EXP1, RANGE_NODE ) );
               HIGH := EXPRESO.GET_STATIC_VALUE ( D ( AS_EXP2, RANGE_NODE ) );
            else
               LOW  := UARITH.U_VAL ( 0 );
               HIGH := UARITH.U_VAL ( 0 );
            end if;
         end SET_RANGE_BOUNDS;
         --|----------------------------------------------------------------------------------------
         --|	PROCEDURE SET_ACCURACY
          procedure SET_ACCURACY ( TYPE_NODE :TREE; ACCURACY :out TREE ) is
         begin
            if TYPE_NODE /= TREE_VOID then
               ACCURACY := D ( SM_ACCURACY, TYPE_NODE );
            else
               ACCURACY := UARITH.U_VAL ( 0 );
            end if;
         end SET_ACCURACY;
      
      begin
         PREDEFINED_BOOLEAN		:= INIT ( "BOOLEAN" );
         PREDEFINED_SHORT_INTEGER	:= INIT ( "SHORT_INTEGER" );
         PREDEFINED_INTEGER		:= INIT ( "INTEGER" );
         PREDEFINED_LONG_INTEGER	:= INIT ( "LONG_INTEGER" );
         PREDEFINED_FLOAT		:= INIT ( "FLOAT" );
         PREDEFINED_LONG_FLOAT	:= INIT ( "LONG_FLOAT" );
         PREDEFINED_STRING		:= INIT ( "STRING" );
         PREDEFINED_DURATION		:= INIT ( "DURATION" );
         PREDEFINED_ADDRESS		:= INIT ( "_ADDRESS" );
      
         PREDEFINED_STANDARD_ID := D ( XD_SOURCE_NAME, PREDEFINED_STANDARD_DEF );
      



         SET_RANGE_BOUNDS ( PREDEFINED_SHORT_INTEGER, PREDEFINED_SHORT_INTEGER_FIRST, PREDEFINED_SHORT_INTEGER_LAST );
         SET_RANGE_BOUNDS ( PREDEFINED_INTEGER, PREDEFINED_INTEGER_FIRST, PREDEFINED_INTEGER_LAST );
         SET_RANGE_BOUNDS ( PREDEFINED_LONG_INTEGER, PREDEFINED_LONG_INTEGER_FIRST, PREDEFINED_LONG_INTEGER_LAST );
         if PREDEFINED_LONG_INTEGER /= TREE_VOID then
            PREDEFINED_LARGEST_INTEGER := PREDEFINED_LONG_INTEGER;
         else
            PREDEFINED_LARGEST_INTEGER := PREDEFINED_INTEGER;
         end if;
      
         SET_RANGE_BOUNDS ( PREDEFINED_FLOAT, PREDEFINED_FLOAT_FIRST, PREDEFINED_FLOAT_LAST );
         SET_ACCURACY ( PREDEFINED_FLOAT, PREDEFINED_FLOAT_ACCURACY);
         SET_RANGE_BOUNDS ( PREDEFINED_LONG_FLOAT, PREDEFINED_LONG_FLOAT_FIRST, PREDEFINED_LONG_FLOAT_LAST );
         SET_ACCURACY ( PREDEFINED_LONG_FLOAT, PREDEFINED_LONG_FLOAT_ACCURACY );
         if PREDEFINED_LONG_FLOAT /= TREE_VOID then
            PREDEFINED_LARGEST_FLOAT := PREDEFINED_LONG_FLOAT;
         else
            PREDEFINED_LARGEST_FLOAT := PREDEFINED_FLOAT;
         end if;
      
      end INITIALIZE_PREDEFINED_TYPES;
      
   --|----------------------------------------------------------------------------------------------
   end SEM_GLOB;
