    SEPARATE ( IDL )
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE ERR_PHASE
    PROCEDURE ERR_PHASE IS
   
      FULL_LIST		: CONSTANT BOOLEAN	:= FALSE;
      IFILE		: FILE_TYPE;			--| LE FICHIER SOURCE
      LINE_COUNT		: NATURAL	:= 0;
      
   BEGIN
      OPEN_IDL_TREE_FILE ( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
      DECLARE
         USER_ROOT	: TREE	:= D ( XD_USER_ROOT, TREE_ROOT );
      BEGIN
         OPEN ( IFILE, IN_FILE, PRINT_NAME ( DABS ( 1, USER_ROOT ) ) );
      END;
      
      DECLARE
         SOURCE_LIST	: SEQ_TYPE	:= LIST ( TREE_ROOT );
         ERRORLIST		: SEQ_TYPE;
         SOURCENBR		: INTEGER	:= 0;		--| N° DE LIGNE PROVENANT DE LA LISTE
         USE IDL.INT_IO;
      BEGIN
         LOOP
            IF IS_EMPTY ( SOURCE_LIST ) THEN
               SOURCENBR := INTEGER'LAST;
               ERRORLIST := (TREE_NIL,TREE_NIL);
            ELSE
               DECLARE
                  SOURCELINE	: TREE;
               BEGIN
                  POP ( SOURCE_LIST, SOURCELINE );
                  SOURCENBR := DI ( XD_NUMBER, SOURCELINE );
                  ERRORLIST := LIST ( SOURCELINE );
               END;
            END IF;
         
            WHILE LINE_COUNT < SOURCENBR AND THEN NOT END_OF_FILE ( IFILE ) LOOP
               LINE_COUNT := LINE_COUNT + 1;
               IF END_OF_LINE ( IFILE ) THEN
                  SKIP_LINE ( IFILE );
                  IF FULL_LIST THEN
                     NEW_LINE;
                  END IF;
               ELSE
                  DECLARE
                     SLINE		: STRING( 1 ..256 );		--| LA LIGNE COURANTE
                     LAST		: NATURAL;			--| LONGUEUR DE LIGNE COURANTE
                  BEGIN
                     GET_LINE ( IFILE, SLINE, LAST );
                     IF FULL_LIST OR ELSE (NOT IS_EMPTY ( ERRORLIST) AND THEN LINE_COUNT = SOURCENBR) THEN
                        PUT ( LINE_COUNT, 1 );
                        PUT_LINE ( ":  " & SLINE( 1..LAST ) );
                     END IF;
                  END;
               END IF;
            END LOOP;
         
            WHILE NOT IS_EMPTY ( ERRORLIST ) LOOP
               DECLARE
                  ERROR	: TREE;
               BEGIN
                  POP( ERRORLIST, ERROR );
                  PUT( "==> ");
                  PUT( INTEGER( GET_SOURCE_COL( D( XD_SRCPOS, ERROR ) ) ), 1 );
                  PUT_LINE( ": " & PRINT_NAME( D( XD_TEXT, ERROR ) ) );
               END;
            END LOOP;
         
            EXIT WHEN SOURCENBR = INTEGER'LAST;
         END LOOP;
      END;
   
      CLOSE( IFILE );
      CLOSE_IDL_TREE_FILE;
   
   END ERR_PHASE;
