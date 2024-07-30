SEPARATE( IDL )
--|--------------------------------------------------------------------------------------------------
--|		PRINT_STAT
--|--------------------------------------------------------------------------------------------------
PROCEDURE PRINT_STAT ( NOM_TEXTE :STRING ) IS						--| IMPRESSION DES ÉTATS LALR POUR DÉBOGAGE
  USER_ROOT	: TREE;
  STATE_SEQ	: SEQ_TYPE;
  STATE		: TREE;
  ITEM_SEQ	: SEQ_TYPE;
  ITEM		: TREE;
  ALT		: TREE;
  SYL_SEQ		: SEQ_TYPE;
  SYL		: TREE;
  TEMP_SEQ	: SEQ_TYPE;
  GOTO_STATE	: TREE;
  FOLLOW		: TREE;
  OLD_FOLLOW	: TREE;
  OFILE		: TEXT_IO.FILE_TYPE;
BEGIN
  OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
  CREATE( OFILE, OUT_FILE, NOM_TEXTE & "_PARSE_TBL.txt" );
  SET_OUTPUT( OFILE );
  USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
  STATE_SEQ := LIST( D( XD_STATELIST, USER_ROOT ) );
  WHILE NOT IS_EMPTY( STATE_SEQ ) LOOP
    POP( STATE_SEQ, STATE );
    NEW_LINE;
    PUT( "STATE NO." );
    INT_IO.PUT( DI( XD_STATE_NBR, STATE ) );
    PUT( " ::" );
    NEW_LINE;
    ITEM_SEQ := LIST( STATE );
    OLD_FOLLOW := TREE_VOID;
    WHILE NOT IS_EMPTY( ITEM_SEQ ) LOOP
      POP( ITEM_SEQ, ITEM );
      ALT := D( XD_ALTERNATIVE, ITEM );
      INT_IO.PUT( DI( XD_ALT_NBR, ALT ) );
      PUT( ": " & PRINT_NAME( D( XD_NAME, D( XD_RULE, ALT ) ) ) & " ::=" );
      SYL_SEQ := LIST( ALT );
      FOR I IN 1 .. DI( XD_SYL_NBR, ITEM ) LOOP
        IF IS_EMPTY( SYL_SEQ ) THEN
          PUT( " ***TOO-FEW-SYLLABLES***" );
          EXIT;
        END IF;
        POP( SYL_SEQ, SYL );
        PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
      END LOOP;
      TEMP_SEQ := LIST( ITEM );
      IF SYL_SEQ.FIRST /= TEMP_SEQ.FIRST THEN
        PUT( " ***BAD-TAIL-IN-ITEM***" );
      END IF;
      PUT( " @" );
      WHILE NOT IS_EMPTY( SYL_SEQ ) LOOP
        POP( SYL_SEQ, SYL );
        PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
      END LOOP;
      GOTO_STATE := D( XD_GOTO, ITEM );
      IF GOTO_STATE.TY /= DN_VOID THEN
        PUT ( " ===> ");
        INT_IO.PUT( DI( XD_STATE_NBR, GOTO_STATE ), 1 );
      ELSE
        FOLLOW := D( XD_FOLLOW, ITEM );
        SYL_SEQ := LIST( FOLLOW );
        IF NOT IS_EMPTY( SYL_SEQ ) THEN
          PUT( " --->");
          WHILE NOT IS_EMPTY( SYL_SEQ ) LOOP
            POP( SYL_SEQ, SYL );
            PUT( ' ' & PRINT_NAME( D( XD_SYMREP, SYL ) ) );
          END LOOP;
        END IF;
      END IF;
      NEW_LINE;
    END LOOP;
  END LOOP;
  CLOSE( OFILE );
  SET_OUTPUT( STANDARD_OUTPUT );
  CLOSE_IDL_TREE_FILE;
--|--------------------------------------------------------------------------------------------------
END PRINT_STAT;
