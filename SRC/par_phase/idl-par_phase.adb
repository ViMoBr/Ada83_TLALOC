WITH LEX, GRMR_OPS, GRMR_TBL;
USE  LEX, GRMR_OPS, GRMR_TBL;
SEPARATE ( IDL )
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE PAR_PHASE				EFFECTUE L'ANALYSE SYNTAXIQUE
--|-------------------------------------------------------------------------------------------------
PROCEDURE PAR_PHASE ( NOM_TEXTE, LIB_PATH :STRING ) IS
   
  USER_ROOT	: TREE;								--| POINTEUR VERS LA RACINE SECONDAIRE DE L ARBRE SYNTAXIQUE
  IFILE		: FILE_TYPE;							--| FICHIER TEXTE SOURCE ADA
  LINE_COUNT	: NATURAL	:= 0;							--| NOMBRE DE LIGNES
      
  SOURCE_LIST	: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);				--| TETE DE LA LISTE DES ENREGISTREMENTS LIGNES DE SOURCE
  SOURCE_LINE	: TREE;								--| POINTEUR A LA LIGNE DE SOURCE COURANTE
  SOURCEPOS	: TREE;								--| POINTEUR VERS UN NOEUD POSITION SOURCE
  TOKENSYM	: LEX_TYPE;							-- BYTE WITH TER/NONTER REP
   
  PRINT_PARSE	: BOOLEAN		:= FALSE;						-- PRINT PARSE TREE WHILE PARSING
  PRINT_SEM	: BOOLEAN		:= FALSE;						-- PRINT SEMANTICS WHILE PARSING
   
   -- SEMANTIC STACK
  SS_SUB		: INTEGER;
  TYPE SS_TYPE	IS RECORD
		  I	: SEQ_TYPE;						--| NOEUD, SYMREP OU NUMREP DANS I.FIRST SINON I EST UNE LISTE
 		  SPOS	: TREE;							--| POSITION SOURCE
		END RECORD;
  SS		: ARRAY( 1 .. 100 ) OF SS_TYPE;					--| PILE SYNTAXIQUE

   -- SEMANTIC WORK AREA:
  WW		: SS_TYPE;
  TT		: SS_TYPE;
  NODE_CREATED	: BOOLEAN;							-- NODE WAS CREATED BY THIS REDUCTION

  PROCEDURE SET_DFLT ( NODE :TREE ) IS SEPARATE;
   
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE READ_PARSE_TABLES
  --|-----------------------------------------------------------------------------------------------
  PROCEDURE READ_PARSE_TABLES IS
  BEGIN
    DECLARE
      PACKAGE GTIO RENAMES GRMR_TBL.GRMR_TBL_IO;
      BIN_FILE	: GTIO.FILE_TYPE;
      USE GTIO;
    BEGIN
      OPEN ( BIN_FILE, IN_FILE, "PARSE.BIN" );						--| OUVRIR LA FICHIER DE LA TABLE DE GRAMMAIRE
      READ ( BIN_FILE, GRMR_TBL.GRMR );							--| AMENER LA TABLE
      CLOSE( BIN_FILE );								--| FERMER LE FICHIER TABLE
    END;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE GET_TOKEN
  --|-----------------------------------------------------------------------------------------------
  PROCEDURE GET_TOKEN IS								--| SEULE PROCEDURE APPELANT LEX_SCAN
    CH	: CHARACTER;
  BEGIN
    IF LTYPE /= LT_END_MARK THEN							--| ON EST PAS EN FIN DE TAMPON LIGNE
      LEX_SCAN;									--| RETIRE UNE ULEX
    END IF;

CHERCHE_LIGNE_PLEINE:         
    WHILE LTYPE = LT_END_MARK LOOP							--| TANT QU ON A UNE LIGNE VIDE

      IF END_OF_FILE ( IFILE ) THEN							--| VERIFIER SI ON EST EN FIN DE FICHIER SOURCE
        SLINE.BDY ( 1..5 ) := "*END*";							--| AUQUEL CAS METTRE *END* COMME CONTENU DE TAMPON
        F_COL := 1;									--| AVEC DEBUT ET FIN DE COLONNE AD HOC
        E_COL := 5;
        EXIT;									--| SORTIE DE LA BOUCLE LIGNES VIDES
      END IF;

      LINE_COUNT := LINE_COUNT + 1;							--| ON VA PRENDRE UNE LIGNE DE PLUS
      LAST := 0;									--| AUCUN CARACTERE ENCORE PRIS
GET_A_LINE:
      WHILE NOT END_OF_LINE( IFILE )  LOOP						--| TANT QUE PAS EN FIN DE LIGNE
        LAST := LAST + 1;								--| ON VA PRENDRE UN CARACTERE DE PLUS
        GET( IFILE, SLINE.BDY ( LAST ) );						--| LE PRENDRE EFFECTIVEMENT
        IF SLINE.BDY( LAST ) = '-' THEN							--| SI C EST UN '-'
          GET( IFILE, CH );								--| PRENDRE UN AUTRE
          IF CH = '-' THEN								--| SI C EST ENCORE UN '-'
            LAST := LAST - 1;								--| RECULER L INDICE DE DERNIER CARACTERE POUR ELIMINER LE '-' PRECEDENT
            EXIT;									--| ET SORTIR DE LA LECTURE DE LIGNE (PASSER LES COMMENTAIRES)
          END IF;
          LAST := LAST + 1;								--| PAS UN '-' INCREMENTER L INDEICE DE DERNIER CARACTERE
          SLINE.BDY( LAST ) := CH;							--| ET STOCKER LE CARACTERE DIFFERANT DE '-'
        END IF;
        EXIT WHEN LAST = SLINE.BDY'LAST;						--| SORTIE FORCEE SI ON ARRIVE EN FIN DE TAMPON LIGNE
      END LOOP GET_A_LINE;

      IF NOT END_OF_FILE( IFILE ) THEN							--| SI PAS EN FIN DE FICHIER
        SKIP_LINE( IFILE );								--| SAUTER LA FIN DE LIGNE
      END IF;
      SLINE.LEN := LAST;								--| LONGUEUR DE LA LIGNE LUE
      LEX.COL := 0;									--| POUR LE LEXEUR COLONNE 0
         
      LEX_SCAN;									--| IDENTIFIER LE LEXEME
            
      IF LTYPE /= LT_END_MARK THEN
        SOURCE_LINE := MAKE( DN_SOURCELINE );						--| FABRIQUER UN NOEUD LIGNE SOURCE
        DI  ( XD_NUMBER, SOURCE_LINE, LINE_COUNT );					--| METTRE LE NUMERO DE LIGNE DANS L ATTRIBUT XD_NUMBER DE CE NOEUD
        LIST( SOURCE_LINE, (TREE_NIL,TREE_NIL) );						--| POST FIXER LE NOEUD PAR UNE SEQUENCE VIDE
        SOURCE_LIST := APPEND( SOURCE_LIST, SOURCE_LINE );					--| AJOUTER LE NOEUD LIGNE SOURCE A LA LISTE DES LIGNES SOURCES

        IF LAST = MAX_STRING AND THEN NOT END_OF_LINE( IFILE ) THEN				--| ON EST SORTI SUR BUTEE EN FIN DE TAMPON
          ERROR( MAKE_SOURCE_POSITION( SOURCE_LINE, MAX_STRING ), "LINE TOO LONG FOR IMPLEMENTATION" );
        END IF;
      END IF;

    END LOOP CHERCHE_LIGNE_PLEINE;
      
    IF LTYPE /= LT_END_MARK THEN							--| ON EST SORTI AVEC UNE LIGNE INTERESSANTE
      SOURCEPOS := MAKE_SOURCE_POSITION( SOURCE_LINE, F_COL );				--| FABRIQUER UN NOEUD POSITION SOURCE EN COLONNE DEBUT ET AVEC REFERENCE AU NOEUD LIGNE SOURCE
    END IF;
    TOKENSYM := LTYPE;								--| TYPE DU LEXEME
  END GET_TOKEN;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE MAKE_NODE
  PROCEDURE MAKE_NODE ( ACTION :INTEGER ) IS
  BEGIN
    WW.I.FIRST := MAKE( NODE_NAME'VAL( ACTION MOD 1000 ) );
    WW.I.NEXT := TREE_TRUE;								-- MARKS A NODE
    WW.SPOS := SOURCEPOS;
    D( LX_SRCPOS, WW.I.FIRST, SOURCEPOS );
    SET_DFLT( WW.I.FIRST );								-- SET DEFAULT ATTRIBUTES
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE TABLE_ERROR
  PROCEDURE TABLE_ERROR ( MSG :STRING ) IS
  BEGIN
    NEW_LINE;
    PUT_LINE( SLINE.BDY( 1 .. SLINE.LEN ) );
    ERROR( SOURCEPOS, MSG );
    RAISE PROGRAM_ERROR;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE POP_ITEM
  PROCEDURE POP_ITEM ( AA :OUT SS_TYPE ) IS
  BEGIN
    IF SS_SUB <= 0 THEN
      TABLE_ERROR("SEM STACK UNDERFLOW.");
    END IF;
    AA := SS( SS_SUB );
    SS_SUB := SS_SUB - 1;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE POP_NODE
  PROCEDURE POP_NODE ( AA :OUT SS_TYPE ) IS
    XX	: SS_TYPE;
  BEGIN
    POP_ITEM( XX );
    IF XX.I.NEXT /= TREE_TRUE THEN
      TABLE_ERROR( "NODE EXPECTED ON SEMANTIC STACK." );
    END IF;
    AA := XX;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE ARG_NODE
  PROCEDURE ARG_NODE ( SON :INTEGER ) IS
    NN: SS_TYPE;
  BEGIN
    POP_NODE( NN );
    DABS( LINE_NBR( SON ), WW.I.FIRST, NN.I.FIRST );
    WW.SPOS := NN.SPOS;
    D( LX_SRCPOS, WW.I.FIRST, NN.SPOS );
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE ARG_ID_S
  PROCEDURE ARG_ID_S IS
    ID_S	: TREE	:= MAKE( DN_SOURCE_NAME_S );
  BEGIN
    SET_DFLT( ID_S );
    LIST( ID_S, (TREE_NIL,TREE_NIL) );
    D( LX_SRCPOS, ID_S, TREE_VOID );
    DABS( 1, WW.I.FIRST, ID_S );
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE ARG_VOID
  PROCEDURE ARG_VOID IS
  BEGIN
    DABS( 1, WW.I.FIRST, TREE_VOID );
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE POP_TOKEN
  PROCEDURE POP_TOKEN ( AA :OUT SS_TYPE ) IS
    XX	: SS_TYPE;
  BEGIN
    POP_ITEM( XX );
    IF XX.I.NEXT /= TREE_FALSE THEN
      TABLE_ERROR( "TOKEN EXPECTED ON SEMANTIC STACK." );
    END IF;
    AA := XX;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE POP_LIST
  PROCEDURE POP_LIST ( AA :OUT SS_TYPE ) IS
    XX	: SS_TYPE;
  BEGIN
    POP_ITEM( XX );
    IF XX.I.NEXT = TREE_TRUE OR ELSE XX.I.NEXT = TREE_FALSE THEN
      TABLE_ERROR( "LIST EXPECTED ON SEMANTIC STACK." );
    END IF;
    AA := XX;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE MAKE_FCN_NODE
  PROCEDURE MAKE_FCN_NODE ( ACTION :INTEGER; AP :IN OUT INTEGER; SEQ :SEQ_TYPE ) IS
    USED_STRING	: TREE	:= MAKE( DN_USED_OP );
    PARAM_S	: TREE	:= MAKE( DN_GENERAL_ASSOC_S );
  BEGIN
    SET_DFLT( USED_STRING );
    SET_DFLT( PARAM_S );
    LIST( PARAM_S, SEQ );
    D( LX_SRCPOS, PARAM_S, D( LX_SRCPOS, HEAD( SEQ ) ) );
    D( LX_SRCPOS, USED_STRING, D( LX_SRCPOS, PARAM_S ) );
    AP := AP + 1;
    D( LX_SYMREP, USED_STRING,
         ( TY=> DN_SYMBOL_REP, PG=> PAGE_SHORT( ACTION MOD 1000 ), LN=> LINE_NBR( GRMR_TBL.GRMR.AC_TBL( AP ) ) )
     );
    MAKE_NODE( NODE_NAME'POS( DN_FUNCTION_CALL ) );
    SET_DFLT ( WW.I.FIRST );
    D ( AS_NAME, WW.I.FIRST, USED_STRING );
    DB( LX_PREFIX, WW.I.FIRST, FALSE );
    D ( AS_GENERAL_ASSOC_S, WW.I.FIRST, PARAM_S );
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PUSH_NODE
  PROCEDURE PUSH_NODE IS
  BEGIN
    SS_SUB := SS_SUB + 1;
    SS( SS_SUB ) := WW;
    NODE_CREATED := TRUE;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE BUILD_TREE
  PROCEDURE BUILD_TREE ( ACTION :INTEGER; AP: IN OUT INTEGER ) IS
     -- DOES SEMANTIC ACTION AND INCREMENTS AP APPROPRIATELY
    ACTION_OP	: GRMR_OP;
    ID_NODE	: TREE;								-- XXX_ID CONSTRUCTED HERE
    LEFT_NODE	: TREE;								-- TEMP. FOR LEFTMOST NODE ($DEF)
    LEFT_KIND	: NODE_NAME;							-- TEMP FOR KIND OF ABOVE NODE
    T_SEQ		: SEQ_TYPE;
  BEGIN
    ACTION_OP := GRMR_OP'VAL( ACTION / 1000 );

    CASE ACTION_OP IS
    WHEN G_ERROR =>
      RAISE PROGRAM_ERROR;
    WHEN N_0 =>
      MAKE_NODE( ACTION );
      PUSH_NODE;
               
    WHEN N_DEF =>
      POP_NODE( WW );
      POP_ITEM( TT );
      IF ( TT.I.NEXT = TREE_TRUE AND THEN WW.I.FIRST.TY IN CLASS_BLOCK_LOOP )
      OR ELSE TT.I.NEXT = TREE_FALSE THEN
        NULL;
      ELSE
        TABLE_ERROR( "TOKEN OR VOID EXPECTED ON STACK FOR $DEF" );
      END IF;
           
      ID_NODE := MAKE( NODE_NAME'VAL( ACTION MOD 1000 ) );
      D( LX_SYMREP, ID_NODE, TT.I.FIRST );
      D( LX_SRCPOS, ID_NODE, TT.SPOS );
      SET_DFLT( ID_NODE );
            
      LEFT_NODE := DABS( 1, WW.I.FIRST );
      LEFT_KIND := LEFT_NODE.TY;
      IF LEFT_KIND = DN_VOID THEN
        DABS( 1, WW.I.FIRST, ID_NODE );
      ELSIF LEFT_KIND = DN_SOURCE_NAME_S THEN
        LIST( LEFT_NODE, INSERT( LIST( LEFT_NODE ), ID_NODE ) );
        D( LX_SRCPOS, LEFT_NODE, TT.SPOS );
      ELSE
        TABLE_ERROR( "INVALID NODE ON STACK FOR $DEF." );
      END IF;
      PUSH_NODE;
               
    WHEN N_1 =>
      MAKE_NODE( ACTION );  ARG_NODE( 1 );  PUSH_NODE;
               
    WHEN N_2 =>
      MAKE_NODE( ACTION );  ARG_NODE( 2 );  ARG_NODE( 1 );  PUSH_NODE;
               
    WHEN N_N2 =>
      MAKE_NODE( ACTION );  ARG_NODE( 2 );  ARG_ID_S;  PUSH_NODE;
               
    WHEN N_V2 =>
      MAKE_NODE( ACTION );  ARG_NODE( 2 );  ARG_VOID;  PUSH_NODE;
               
    WHEN N_3 =>
      MAKE_NODE( ACTION );  ARG_NODE( 3 );  ARG_NODE( 2 );  ARG_NODE( 1 );  PUSH_NODE;
               
    WHEN N_N3 =>
      MAKE_NODE( ACTION );  ARG_NODE( 3 );  ARG_NODE( 2 );  ARG_ID_S;  PUSH_NODE;
               
    WHEN N_V3 =>
      MAKE_NODE( ACTION );  ARG_NODE( 3 );  ARG_NODE( 2 );  ARG_VOID;  PUSH_NODE;

    WHEN N_L =>
      POP_LIST( TT );  MAKE_NODE( ACTION );  LIST( WW.I.FIRST, TT.I );  PUSH_NODE;

    WHEN G_INFIX =>
      POP_NODE( TT );  T_SEQ := INSERT( (TREE_NIL,TREE_NIL) , TT.I.FIRST );
      POP_NODE( TT );  T_SEQ := INSERT( T_SEQ, TT.I.FIRST);
      MAKE_FCN_NODE( ACTION, AP, T_SEQ );
      PUSH_NODE;

    WHEN G_UNARY =>
      POP_NODE( TT );  T_SEQ := INSERT( (TREE_NIL,TREE_NIL), TT.I.FIRST );
      MAKE_FCN_NODE( ACTION, AP, T_SEQ );
      PUSH_NODE;

    WHEN G_LX_SYMREP =>
      POP_NODE( WW );  POP_TOKEN( TT );
      D( LX_SYMREP, WW.I.FIRST, TT.I.FIRST );
      D( LX_SRCPOS, WW.I.FIRST, TT.SPOS );
      PUSH_NODE;

    WHEN G_LX_NUMREP =>
      POP_NODE( WW );  POP_TOKEN( TT );
            
      IF TT.I.FIRST.TY /= DN_TXTREP THEN
        TABLE_ERROR( "TXTREP EXPECTED FOR LX_NUMREP." );
      END IF;
            
      D( LX_NUMREP, WW.I.FIRST, TT.I.FIRST);
      D( LX_SRCPOS, WW.I.FIRST, TT.SPOS );
            
      PUSH_NODE;

    WHEN G_LX_DEFAULT =>
      POP_NODE( WW );  DB( LX_DEFAULT, WW.I.FIRST, TRUE );  PUSH_NODE;

    WHEN G_NOT_LX_DEFAULT =>
      POP_NODE( WW );  DB( LX_DEFAULT, WW.I.FIRST, FALSE );  PUSH_NODE;

    WHEN G_NIL =>
      WW.I := (TREE_NIL,TREE_NIL);  WW.SPOS := SOURCEPOS;  PUSH_NODE;

    WHEN G_INSERT =>
      POP_LIST( WW );  POP_NODE( TT );
      WW.I := INSERT( WW.I, TT.I.FIRST );  WW.SPOS := TT.SPOS;
      PUSH_NODE;

    WHEN G_APPEND =>
      POP_NODE( TT );  POP_LIST( WW );
      WW.I := APPEND( WW.I, TT.I.FIRST );
      IF WW.SPOS = TREE_VOID THEN
        WW.SPOS := TT.SPOS;
      END IF;
      PUSH_NODE;

    WHEN G_CAT =>
      POP_LIST( TT );  POP_LIST( WW );
      IF WW.I.FIRST = TREE_NIL THEN
        WW := TT;
      ELSIF TT.I.FIRST = TREE_NIL THEN
        NULL;
      ELSE
        WW.I := APPEND( WW.I, TT.I.FIRST );
      END IF;
      PUSH_NODE;

    WHEN G_VOID =>
      WW := ( I    => ( FIRST=> MAKE( DN_VOID ), NEXT=> TREE_TRUE ), 
              SPOS => SOURCEPOS );
      PUSH_NODE;

    WHEN G_LIST =>
      POP_NODE( TT );
      WW := ( I=> INSERT( (TREE_NIL,TREE_NIL) , TT.I.FIRST ), SPOS=> TT.SPOS );
      PUSH_NODE;

    WHEN G_EXCH_1 =>
      WW := SS( SS_SUB );  SS( SS_SUB ) := SS( SS_SUB - 1 );  SS( SS_SUB - 1 ) := WW;

    WHEN G_EXCH_2 =>
      WW := SS( SS_SUB );  SS( SS_SUB ) := SS( SS_SUB - 2 );  SS( SS_SUB - 2 ) := WW;

    WHEN G_CHECK_NAME =>
      SS_SUB := SS_SUB - 1;

    WHEN G_CHECK_SUBP_NAME =>
      SS_SUB := SS_SUB - 1;

    WHEN G_CHECK_ACCEPT_NAME =>
      SS_SUB := SS_SUB - 1;

    END CASE;
    AP := AP + 1;
  END BUILD_TREE;
   
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PARSE_COMPILATION
  PROCEDURE PARSE_COMPILATION IS
    STACK_MAX	: CONSTANT		:= 125;
    TYPE STACK_TYPE	IS RECORD
		  STATE	: POSITIVE;
		  SRCPOS	: TREE;
		END RECORD;
    STACK		: ARRAY( 1 .. STACK_MAX ) OF STACK_TYPE;
      
    SP		: INTEGER RANGE 1 .. STACK_MAX:= 1;					--| POINTEUR DE PILE SYNTAXIQUE
    STATE		: POSITIVE		:= 1;					--| ETAT D ANALYSEUR INITIALISE A 1
    AP		: INTEGER;
    ACTION	: INTEGER;
    ASYM		: AC_BYTE;
    NBR_OF_SYLS	: NATURAL;							-- NUMBER OF SYLLABLES TO BE POPPED
    ZERO_BYTE	: CONSTANT AC_BYTE		:= 0;
      
  BEGIN
    LTYPE     := LT_END_MARK;								--| INITIALISER A LIGNE VIDE
    SOURCEPOS := TREE_VOID;								--| INITIALISER LA POSITION SOURCE A VIDE
    GET_TOKEN;									--| ALLER CHERCHER UN LEXEME
      
    STACK( 1 ).STATE  := 1;
    STACK( 1 ).SRCPOS := SOURCEPOS;
    STACK( 2 ).SRCPOS := SOURCEPOS;
      
    SS_SUB := 0;									-- START WITH EMPTY SEMANTIC STACK

    LOOP
      AP := GRMR_TBL.GRMR.ST_TBL( STATE );

      IF AP <= 0 THEN
        ACTION := AP;
      ELSE
       -- POINTS TO SHIFT STUFF
        LOOP
          ASYM := GRMR_TBL.GRMR.AC_SYM( AP );
          EXIT WHEN ASYM = ZERO_BYTE OR ELSE ASYM = LEX_TYPE'POS( TOKENSYM );
          AP := AP + 1;
        END LOOP;
        ACTION := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
      END IF;

      IF ACTION > 0 THEN								-- CAN'T BE SEMANTICS SINCE DIDN'T INDIRECT
            
            -- ADD TO SEMANTIC STACK IF THIS TOKEN HAS SEMANTICS
        IF LTYPE IN LT_WITH_SEMANTICS THEN
          WW.I.NEXT := TREE_FALSE;							-- IT IS A TOKEN
          WW.SPOS   := SOURCEPOS;
          IF LTYPE = LT_NUMERIC_LIT THEN
            WW.I.FIRST := STORE_TEXT( TOKEN_STRING );
          ELSE
            WW.I.FIRST := STORE_SYM( TOKEN_STRING );
          END IF;
          PUSH_NODE;
        END IF;
           
        IF LTYPE = LT_END_MARK THEN							--| ARRIVE EN FIN DE COMPILATION
          IF SP /= 2 THEN
            PUT_LINE( "HOWEVER, SP = " & INTEGER'IMAGE( SP ) );
          END IF;
          IF SS_SUB /= 1 THEN
            PUT( "HOWEVER, SS_SUB = " & INTEGER'IMAGE( SS_SUB ) );
          ELSE
            WW := SS( 1 );
            IF WW.I.NEXT /= TREE_TRUE THEN
              PUT_LINE( "HOWEVER, AST IS NOT A NODE." );
            ELSE									--| SAUVER L'ARBRE SYNTAXIQUE DANS LE XD_STRUCTURE DU USER_ROOT
              D( XD_STRUCTURE, USER_ROOT, WW.I.FIRST );
            END IF;
          END IF;
          EXIT;
        END IF;

        SP := SP + 1;
        STATE := ACTION;
        STACK( SP ).STATE    := ACTION;
        STACK( SP ).SRCPOS   := SOURCEPOS;
        STACK( SP+1 ).SRCPOS := SOURCEPOS;
        GET_TOKEN;
               
      ELSIF ACTION = 0 THEN								--| ERREUR DE SYNTAXE
        PUT_LINE( SLINE.BDY( 1 .. SLINE.LEN ) );						--| AFFICHER LA LIGNE CONCERNEE
        ERROR( SOURCEPOS, "SYNTAX ERROR - " & SLINE.BDY( F_COL..E_COL ) );			--| INSERE UN NOEUD ERREUR ET AFFICHE UN MESSAGE
        EXIT;

      ELSE
       -- SEMANTIC AND REDUCE ACTIONS
        NODE_CREATED := FALSE;
        LOOP

          IF ACTION > -10000 THEN  -- TRANSFER TO SEMANTIC ACTION TABLE
            AP := - ACTION; -- TRANSFER IN TABLE
            LOOP
              ACTION := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
              EXIT WHEN ACTION <= 0;
              BUILD_TREE( ACTION, AP );							--| CONSTRUCTION DE L ARBRE INCREMENTE AP EN INTERNE
            END LOOP;
          END IF;

          IF ACTION > -30000 AND ACTION <= -10000 THEN
                 -- REDUCE
            ACTION      :=  - ACTION - 10000;
            NBR_OF_SYLS := ACTION/1000;
            ACTION      := ACTION MOD 1000; -- I.E., RULE
            SP := SP - NBR_OF_SYLS; -- POP THE STACK
            STATE := STACK( SP ).STATE;
            SS( SS_SUB ).SPOS := STACK( SP+1 ).SRCPOS;
            IF NODE_CREATED AND THEN SS( SS_SUB ).I.NEXT = TREE_TRUE
               AND THEN SS( SS_SUB ).I.FIRST /= TREE_VOID THEN
              D( LX_SRCPOS, SS( SS_SUB ).I.FIRST, SS( SS_SUB ).SPOS);
            END IF;
                  -- FIND GOTO FOR NONTERMINAL IN THIS STATE
            AP := GRMR_TBL.GRMR.ST_TBL( STATE );
            LOOP
              AP := AP - 1;
              ASYM := GRMR_TBL.GRMR.AC_SYM( AP );
              IF ASYM = ZERO_BYTE THEN
                PUT_LINE ( "!! ****** NONTER GOTO NOT FOUND." );
                RAISE PROGRAM_ERROR;
              END IF;
              EXIT WHEN INTEGER( ASYM ) = ACTION;
            END LOOP;
            STATE := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
            SP := SP + 1;
            STACK( SP ).STATE := STATE;
            IF NBR_OF_SYLS = 0 THEN
                    -- NULLABLE REDUCTION; SRCPOS NOT ALREADY THERE
              STACK( SP ).SRCPOS := SOURCEPOS;
            END IF;
            STACK( SP+1 ).SRCPOS := SOURCEPOS;
            EXIT;

          ELSE
            PUT_LINE ( "!! PARSE_TABLE_ERROR" );
            RAISE PROGRAM_ERROR;
          END IF;

        END LOOP;
      END IF;
    END LOOP;
  END PARSE_COMPILATION;
   
BEGIN
  READ_PARSE_TABLES;								--| TABLES DE LA GRAMMAIRE LUES DANS PARSE.BIN
      
  OPEN( IFILE, IN_FILE, NOM_TEXTE );							--| OUVRIR LE FICHIER SOURCE A COMPILER

  CREATE_IDL_TREE_FILE( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );			--| CREER LE FICHIER D'ARBRE (AVEC SON NOEUD RACINE DE TYPE DN_ROOT)
  USER_ROOT := MAKE( DN_USER_ROOT );							--| CREER UN NOEUD RACINE SECONDAIRE DU TYPE DN_USER_ROOT
  D( XD_USER_ROOT, TREE_ROOT, USER_ROOT );						--| NOEUD USER_ROOT DANS LE CHAMP XD_USER_ROOT DU NOEUD TREE_ROOT
  D( XD_SOURCENAME, USER_ROOT, STORE_TEXT( NOM_TEXTE ) );					--| NOM DU SOURCE DANS LE CHAMP XD_XOURCENAME DU NOEUD USER_ROOT
      
  PARSE_COMPILATION;								--| EFFECTUER LA PHASE D'ANALYSE SYNTAXIQUE DU SOURCE
      
  D( XD_SOURCE_LIST, TREE_ROOT, SOURCE_LIST.FIRST );					--| STOCKE LA LISTE SOURCE_LIST DANS L'ATTRIBUT XD_SOURCE_LIST
  
  CLOSE( IFILE );
      
  CLOSE_PAGE_MANAGER;								--| FERMER LE FICHIER ARBRE
      
--|-------------------------------------------------------------------------------------------------
END PAR_PHASE;