--	Vincent MORIN	Universite de Bretagne Occidentale	janvier 2025	Licence CC BY-SA 4.0
--	1	2	3	4	5	6	7	8	9	10	11	12

with LEX, GRMR_OPS, GRMR_TBL;
use  LEX, GRMR_OPS, GRMR_TBL;
separate( IDL )

				---------
		procedure		PAR_PHASE		( PATH_TEXTE, NOM_TEXTE, LIB_PATH :STRING )
				---------
is

  USER_ROOT		: TREE;									--| POINTEUR VERS LA RACINE SECONDAIRE DE L ARBRE SYNTAXIQUE
  IFILE			: FILE_TYPE;								--| FICHIER TEXTE SOURCE ADA
  LINE_COUNT		: NATURAL		:= 0;							--| NOMBRE DE LIGNES VUES
      
  SOURCE_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);					--| TETE DE LA LISTE DES ENREGISTREMENTS LIGNES DE SOURCE
  SOURCE_LINE		: TREE;									--| POINTEUR A LA LIGNE DE SOURCE COURANTE
  SOURCEPOS		: TREE;									--| POINTEUR VERS UN NOEUD POSITION SOURCE
  TOKENSYM		: LEX_TYPE;								--| BYTE WITH TER/NONTER REP
   
  DEBUG_PARSE		: BOOLEAN		:= FALSE;							--| PRINT PARSE TREE WHILE PARSING
  DEBUG_SEM		: BOOLEAN		:= FALSE;							--| PRINT SEMANTICS WHILE PARSING


		--| PILE POUR ACTIONS SEMANTIQUES CONSTRUCTIVES DE L ANALYSE SYNTAXIQUE


  type SEMSTAK_ELMT_KIND	is ( NODE_ELMT, TOKEN_ELMT, LIST_ELMT );

  type SEMSTAK_UNIT( KIND :SEMSTAK_ELMT_KIND := NODE_ELMT )
			is record
 			  SPOS		: TREE;							--| POSITION SOURCE DE L ELEMENT
			  case KIND is
			  when NODE_ELMT
			     | TOKEN_ELMT =>
			    ELMT		: TREE;							--| ELEMENT DE PILE
			  when LIST_ELMT =>
			    SEQ		: SEQ_TYPE;
			  end case;
			end record;

  SEMSTAK			: array( 1 .. 100 ) of SEMSTAK_UNIT;						--| PILE SYNTAXIQUE
  SSITOP			: INTEGER;								--| INDICE HAUT DE PILE


		--| VARIABLES TEMPORAIRES DE TRAVAIL

  AUXA			: SEMSTAK_UNIT;
  TT			: SEMSTAK_UNIT;
  NODE_CREATED		: BOOLEAN;								--| NOEUD CREE PAR REDUCTION


				--------
  procedure			SET_DFLT		( NODE :TREE )	is separate;			--| POUR INITIALISATIONS
				--------


				-----------------
  procedure			READ_PARSE_TABLES
				-----------------
  is
  begin
    declare
      package GTIO		renames GRMR_TBL.GRMR_TBL_IO;
      BIN_FILE		: GTIO.FILE_TYPE;
      use GTIO;
    begin
      begin
        OPEN( BIN_FILE, IN_FILE, "parse.bin" );								--| OUVRIR LA FICHIER DE LA TABLE DE GRAMMAIRE
      exception
        when GTIO.NAME_ERROR =>	PUT_LINE( "parse.bin FILE MISSING" );
				raise PROGRAM_ERROR;
      end;
      READ ( BIN_FILE, GRMR_TBL.GRMR );									--| AMENER LA TABLE
      CLOSE( BIN_FILE );										--| FERMER LE FICHIER TABLE
    end;

  end	READ_PARSE_TABLES;
	-----------------


				---------
  procedure			GET_TOKEN								--| SEULE PROCEDURE APPELANT LEX_SCAN
				---------
  is
				---------------
    procedure			GET_SOURCE_LINE
				---------------
    is
    begin
      LINE_COUNT := LINE_COUNT + 1;									--| ON VA PRENDRE UNE LIGNE DE PLUS
      GET_LINE( IFILE, SLINE.BDY, SLINE.LEN );
      LAST := SLINE.LEN;
      LEX.COL := 0;											--| POUR LE LEXEUR RETOUR COLONNE 0

    end	GET_SOURCE_LINE;
	---------------

  begin
    if  LTYPE /= LT_END_MARK  then									--| ON EST PAS EN FIN DE TAMPON LIGNE
      LEX_SCAN;											--| RETIRE UNE ULEX
    end if;
					--------------------
					CHERCHE_LIGNE_PLEINE:
    while  LTYPE = LT_END_MARK  loop									--| TANT QU ON A UNE LIGNE VIDE

      if  END_OF_FILE( IFILE )  then									--| SI ON EST EN FIN DE FICHIER SOURCE
        SLINE.BDY( 1 .. 5 ) := "*END*";									--| METTRE *END* COMME CONTENU DE TAMPON
        F_COL := 1;											--| AVEC DEBUT ET FIN DE COLONNE AD HOC
        E_COL := 5;
        exit;											--| SORTIE DE LA BOUCLE
      end if;

      GET_SOURCE_LINE;
      
      LEX_SCAN;											--| IDENTIFIER LE LEXEME OU UNE FIN DE LIGNE
            
      if  LTYPE /= LT_END_MARK  then
        SOURCE_LINE := MAKE( DN_SOURCELINE );								--| FABRIQUER UN NOEUD LIGNE SOURCE
        DI  ( XD_NUMBER, SOURCE_LINE, LINE_COUNT );							--| METTRE LE NUMERO DE LIGNE DANS L ATTRIBUT XD_NUMBER DE CE NOEUD
        LIST( SOURCE_LINE, (TREE_NIL,TREE_NIL) );								--| POST FIXER LE NOEUD PAR UNE SEQUENCE VIDE
        SOURCE_LIST := APPEND( SOURCE_LIST, SOURCE_LINE );							--| AJOUTER LE NOEUD LIGNE SOURCE A LA LISTE DES LIGNES SOURCES

        if  LAST = MAX_STRING  and then  not END_OF_LINE( IFILE )  then					--| ON EST SORTI SUR BUTEE EN FIN DE TAMPON
          ERROR( MAKE_SOURCE_POSITION( SOURCE_LINE, SRCCOL_IDX( MAX_STRING ) ),
		"LIGNE TROP LONGUE" );
        end if;
      end if;

    end loop	CHERCHE_LIGNE_PLEINE;
		--------------------

    if  LTYPE /= LT_END_MARK  then									--| ON EST SORTI AVEC UNE UNITE LEXICALE NON FIN
      SOURCEPOS := MAKE_SOURCE_POSITION( SOURCE_LINE, SRCCOL_IDX( F_COL ) );					--| FABRIQUER UN NOEUD POSITION SOURCE EN COLONNE DEBUT ET AVEC REFERENCE AU NOEUD LIGNE SOURCE
    end if;
    TOKENSYM := LTYPE;										--| TYPE DU LEXEME

  end	GET_TOKEN;
	---------


				--------------
  procedure			MAKE_AUXA_NODE		( ACTION :INTEGER )
				--------------
  is
  begin

    if  DEBUG_SEM  then
      PUT( ' ' & NODE_NAME'IMAGE( NODE_NAME'VAL( ACTION mod 1000 ) ) );
    end if;

    AUXA := ( NODE_ELMT, SOURCEPOS, MAKE( NODE_NAME'VAL( ACTION mod 1000 ) ) );					--| FABRIQUER UN POINTEUR NOEUD TYPE CODE SOUS 1000
    D( LX_SRCPOS, AUXA.ELMT, SOURCEPOS );								--| ET AUSSI DANS L ATTRIBUT LX_SRCPOS DU NOEUD FABRIQUE
    SET_DFLT( AUXA.ELMT );										--| INITIALISER PAR DEFAUT

  end	MAKE_AUXA_NODE;
	--------------


				-----------
  procedure			TABLE_ERROR		( MSG :STRING )
				-----------
  is
  begin
    NEW_LINE;
    PUT_LINE( SLINE.BDY( 1 .. SLINE.LEN ) );
    ERROR( SOURCEPOS, MSG );
    raise PROGRAM_ERROR;

  end	TABLE_ERROR;
	-----------


				--------
  procedure			POP_ITEM			( AA :out SEMSTAK_UNIT )			--| RETIRE UN ELEMENT DE PILE SS EN VERIFIANT L EPUISEMENT
				--------
  is
  begin
    if  SSITOP <= 0  then
      TABLE_ERROR("SEM STACK UNDERFLOW.");
    end if;
    AA := SEMSTAK( SSITOP );
    SSITOP := SSITOP - 1;

  end	POP_ITEM;
	--------


				--------
  procedure			POP_NODE			( AA :out SEMSTAK_UNIT )			--| RETIRE UN ELEMENT DE PILE EN VERIFIANT QUE C EST UN NOEUD
				--------
  is
    XX		: SEMSTAK_UNIT;
  begin
    POP_ITEM( XX );
    if  XX.KIND /= NODE_ELMT  then
      TABLE_ERROR( "POP_NODE : NOEUD ATTENDU SUR SEMSTAK." );
    end if;
    AA := XX;

  end	POP_NODE;
	--------

				---------------------
  procedure			POP_AUXA_SON_ARG_NODE	( SON :INTEGER )
				---------------------
  is
    NN		: SEMSTAK_UNIT;
  begin
    POP_NODE( NN );
    DABS( LINE_IDX( SON ), AUXA.ELMT, NN.ELMT );								--| LES ATTRIBUTS as_ DOIVENT ETRE AVANT TOUT AUTRE TYPE D ATTRIBUT

    if  DEBUG_SEM  then
      NEW_LINE; PUT( "popped AUXA SON " & INTEGER'IMAGE(SON+1) & " = " ); PRINT_NODE( NN.ELMT );
    end if;

    AUXA.SPOS := NN.SPOS;
    D( LX_SRCPOS, AUXA.ELMT, NN.SPOS );

  end	POP_AUXA_SON_ARG_NODE;
	---------------------


				--------------------------
  procedure			SET_AUXA_SON1_NEW_NAME_SEQ
				--------------------------
  is
    ID_S		: TREE	:= MAKE( DN_SOURCE_NAME_S );
  begin
    SET_DFLT( ID_S );
    LIST( ID_S, (TREE_NIL,TREE_NIL) );
    D( LX_SRCPOS, ID_S, TREE_VOID );
    DABS( 1, AUXA.ELMT, ID_S );

  end	SET_AUXA_SON1_NEW_NAME_SEQ;
	--------------------------


				------------------
  procedure			SET_AUXA_SON1_VOID
				------------------
  is
  begin
    DABS( 1, AUXA.ELMT, TREE_VOID );

  end	SET_AUXA_SON1_VOID;
	------------------


				---------
  procedure			POP_TOKEN			( AA :out SEMSTAK_UNIT )			--| DEPILE DE SS EN VERIFIANT QUE C'EST UN JETON
				---------
  is
    XX	: SEMSTAK_UNIT;
  begin
    POP_ITEM( XX );
    if  XX.KIND /= TOKEN_ELMT  then
      TABLE_ERROR( "POP_TOKEN : JETON ATTENDU SUR SEMSTAK." );
    end if;
    AA := XX;

  end	POP_TOKEN;
	---------


				--------
  procedure			POP_LIST			( AA :out SEMSTAK_UNIT )			--| DEPILE DE SS EN VERIFIANT QUE C EST UNE LISTE
				--------
  is
    XX	: SEMSTAK_UNIT;
  begin
    POP_ITEM( XX );
    if  XX.KIND = NODE_ELMT  or else  XX.KIND = TOKEN_ELMT  then
      TABLE_ERROR( "POP_LIST : LISTE ATTENDUE SUR SEMSTAK." );
    end if;
    AA := XX;

  end	POP_LIST;
	--------


				-------------
  procedure			MAKE_FCN_NODE		( ACTION :INTEGER; AP :in out INTEGER; SEQ :SEQ_TYPE )
				-------------
  is
    USED_STRING	: TREE	:= MAKE( DN_USED_OP );
    PARAM_S	: TREE	:= MAKE( DN_GENERAL_ASSOC_S );
  begin
    SET_DFLT( USED_STRING );
    SET_DFLT( PARAM_S );
    LIST( PARAM_S, SEQ );
    D( LX_SRCPOS, PARAM_S, D( LX_SRCPOS, HEAD( SEQ ) ) );
    D( LX_SRCPOS, USED_STRING, D( LX_SRCPOS, PARAM_S ) );
    AP := AP + 1;
    D( LX_SYMREP, USED_STRING,
         ( P,	TY=> DN_SYMBOL_REP,
		PG=> PAGE_IDX( ACTION mod 1000 ),
		LN=> LINE_IDX( GRMR_TBL.GRMR.AC_TBL( AP ) )
	)
     );
    MAKE_AUXA_NODE( NODE_NAME'POS( DN_FUNCTION_CALL ) );
    SET_DFLT( AUXA.ELMT );
    D ( AS_NAME, AUXA.ELMT, USED_STRING );
    DB( LX_PREFIX, AUXA.ELMT, FALSE );
    D ( AS_GENERAL_ASSOC_S, AUXA.ELMT, PARAM_S );

  end	MAKE_FCN_NODE;
	-------------


				--------------
  procedure			PUSH_AUXA_NODE								--| EMPILE AUXA SUR LA PILE SS
				--------------
  is
  begin
    SSITOP	  := SSITOP + 1;
    SEMSTAK( SSITOP ) := AUXA;
    NODE_CREATED	  := TRUE;

    if  DEBUG_SEM  then
      NEW_LINE; PUT( "pushed AUXA = " & SEMSTAK_ELMT_KIND'IMAGE( AUXA.KIND ) & ' ' );
      case AUXA.KIND is
      when NODE_ELMT | TOKEN_ELMT => PRINT_NODE( AUXA.ELMT );
      when LIST_ELMT => PRINT_NODE( AUXA.SEQ.FIRST );
      end case;
    end if;

  end	PUSH_AUXA_NODE;
	--------------


				----------
  procedure			BUILD_TREE	( ACTION :INTEGER; AP: in out INTEGER )
				----------
  is
    ACTION_OP		: GRMR_OP		:= GRMR_OP'VAL( ACTION / 1000 );				--| UNE DES 28 ACTIONS SEMANTIQUES (MISE AUX MILLIERS DE ACTION)
    ID_NODE		: TREE;									--| XXX_ID CONSTRUCTED HERE
    LEFT_NODE		: TREE;									--| TEMP. FOR LEFTMOST NODE ($DEF)
    LEFT_KIND		: NODE_NAME;								--| TEMP FOR KIND OF ABOVE NODE
    T_SEQ			: SEQ_TYPE;
  begin

    if  DEBUG_SEM  then
      PUT_LINE( "action construction : " & GRMR_OP_IMAGE( ACTION_OP ) );
    end if;

    case ACTION_OP is
    when G_ERROR =>
      raise PROGRAM_ERROR;

    when N_0 =>
      MAKE_AUXA_NODE( ACTION ); PUSH_AUXA_NODE;								--| FABRIQUE UN NOEUD POINTE DANS AUXA ET EMPILE AUXA
               
    when N_DEF =>
      POP_NODE( AUXA );
      POP_ITEM( TT );
      if  ( TT.KIND = NODE_ELMT  and then  AUXA.ELMT.TY in CLASS_BLOCK_LOOP )
          or else  TT.KIND = TOKEN_ELMT
      then null;
      else
        TABLE_ERROR( "TOKEN OR VOID EXPECTED ON STACK FOR $DEF" );
      end if;
           
      if  DEBUG_SEM  then
        PUT( ' ' & NODE_NAME'IMAGE( NODE_NAME'VAL( ACTION mod 1000 ) ) );
      end if;

      ID_NODE := MAKE( NODE_NAME'VAL( ACTION mod 1000 ) );
      D( LX_SYMREP, ID_NODE, TT.ELMT );
      D( LX_SRCPOS, ID_NODE, TT.SPOS );
      SET_DFLT( ID_NODE );
            
      LEFT_NODE := DABS( 1, AUXA.ELMT );
      LEFT_KIND := LEFT_NODE.TY;
      if  LEFT_KIND = DN_VOID  then
        DABS( 1, AUXA.ELMT, ID_NODE );
      elsif  LEFT_KIND = DN_SOURCE_NAME_S  then
        LIST( LEFT_NODE, INSERT( LIST( LEFT_NODE ), ID_NODE ) );
        D( LX_SRCPOS, LEFT_NODE, TT.SPOS );
      else
        TABLE_ERROR( "INVALID NODE ON STACK FOR $DEF." );
      end if;
      PUSH_AUXA_NODE;
               
    when N_1 =>											--| FABRIQUE UN NOEUD DANS AUXA DEPILE SON FILS 1 EMPILE AUXA
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 1 );
      PUSH_AUXA_NODE;

    when N_2 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 2 );  POP_AUXA_SON_ARG_NODE( 1 );
      PUSH_AUXA_NODE;
               
    when N_N2 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 2 );  SET_AUXA_SON1_NEW_NAME_SEQ;
      PUSH_AUXA_NODE;
               
    when N_V2 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 2 );  SET_AUXA_SON1_VOID;
      PUSH_AUXA_NODE;
               
    when N_3 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 3 );  POP_AUXA_SON_ARG_NODE( 2 );  POP_AUXA_SON_ARG_NODE( 1 );
      PUSH_AUXA_NODE;
               
    when N_N3 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 3 );  POP_AUXA_SON_ARG_NODE( 2 );  SET_AUXA_SON1_NEW_NAME_SEQ;
      PUSH_AUXA_NODE;
               
    when N_V3 =>
      MAKE_AUXA_NODE( ACTION );
      POP_AUXA_SON_ARG_NODE( 3 );  POP_AUXA_SON_ARG_NODE( 2 );  SET_AUXA_SON1_VOID;
      PUSH_AUXA_NODE;

    when N_L =>
      POP_LIST( TT );  MAKE_AUXA_NODE( ACTION );  LIST( AUXA.ELMT, TT.SEQ );  PUSH_AUXA_NODE;

      if  DEBUG_SEM  then
        PUT( "TT = " ); PRINT_NODE( TT.SEQ.FIRST );
      end if;

    when G_INFIX =>											--| POP DEUX ELEMENTS EN LISTE ARGS PUIS PUSH UN NOEUD FONCTION
      POP_NODE( TT );  T_SEQ := INSERT( (TREE_NIL,TREE_NIL) , TT.ELMT );
      POP_NODE( TT );  T_SEQ := INSERT( T_SEQ, TT.ELMT);
      MAKE_FCN_NODE( ACTION, AP, T_SEQ );
      PUSH_AUXA_NODE;

    when G_UNARY =>
      POP_NODE( TT );  T_SEQ := INSERT( (TREE_NIL,TREE_NIL), TT.ELMT );
      MAKE_FCN_NODE( ACTION, AP, T_SEQ );
      PUSH_AUXA_NODE;

    when G_LX_SYMREP =>
      POP_NODE( AUXA );  POP_TOKEN( TT );
      D( LX_SYMREP, AUXA.ELMT, TT.ELMT );
      D( LX_SRCPOS, AUXA.ELMT, TT.SPOS );
      PUSH_AUXA_NODE;

    when G_LX_NUMREP =>										--| PLACE LE NUMREP TT DANS LA TETE DE PILE
      POP_NODE( AUXA );  POP_TOKEN( TT );
            
      if  TT.ELMT.TY /= DN_TXTREP  then
        TABLE_ERROR( "TXTREP EXPECTED FOR LX_NUMREP." );
      end if;
            
      D( LX_NUMREP, AUXA.ELMT, TT.ELMT);
      D( LX_SRCPOS, AUXA.ELMT, TT.SPOS );
            
      PUSH_AUXA_NODE;

    when G_LX_DEFAULT =>
      POP_NODE( AUXA );  DB( LX_DEFAULT, AUXA.ELMT, TRUE );  PUSH_AUXA_NODE;

    when G_NOT_LX_DEFAULT =>
      POP_NODE( AUXA );  DB( LX_DEFAULT, AUXA.ELMT, FALSE );  PUSH_AUXA_NODE;

    when G_NIL =>											--| PUSH LISTE VIDE AUXA
      AUXA := (KIND=> LIST_ELMT, SPOS=> SOURCEPOS, SEQ=> (TREE_NIL,TREE_NIL) );  PUSH_AUXA_NODE;

    when G_INSERT =>										--| INSERE AU DEBUT DANS LA LISTE EN TETE DE PILE LE NOEUD TT
      POP_LIST( AUXA );  POP_NODE( TT );
      AUXA.SEQ := INSERT( AUXA.SEQ, TT.ELMT );  AUXA.SPOS := TT.SPOS;
      PUSH_AUXA_NODE;

    when G_APPEND =>										--| AJOUTE EN FIN LE NOEUD TT A UNE LISTE REMISE EN TETE DE PILE
      POP_NODE( TT );  POP_LIST( AUXA );
      AUXA.SEQ := APPEND( AUXA.SEQ, TT.ELMT );
      if  AUXA.SPOS = TREE_VOID  then
        AUXA.SPOS := TT.SPOS;
      end if;
      PUSH_AUXA_NODE;

    when G_CAT =>											--| CONCATENER DEUX LISTES TT A AUXA
      POP_LIST( TT );  POP_LIST( AUXA );
      if  AUXA.SEQ.FIRST = TREE_NIL  then
        AUXA := TT;
      elsif  TT.SEQ.FIRST = TREE_NIL  then
        null;
      else
        AUXA.SEQ := APPEND( AUXA.SEQ, TT.SEQ.FIRST );
      end if;
      PUSH_AUXA_NODE;

    when G_VOID =>
      AUXA := ( KIND=> NODE_ELMT, SPOS=> SOURCEPOS, ELMT=> MAKE( DN_VOID ) );
      PUSH_AUXA_NODE;

    when G_LIST =>
      POP_NODE( TT );
      AUXA := ( KIND=> LIST_ELMT, SPOS=> TT.SPOS, SEQ=> INSERT( (TREE_NIL,TREE_NIL) , TT.ELMT ) );
      PUSH_AUXA_NODE;

    when G_EXCH_1 =>
      AUXA := SEMSTAK( SSITOP );  SEMSTAK( SSITOP ) := SEMSTAK( SSITOP - 1 );  SEMSTAK( SSITOP - 1 ) := AUXA;

    when G_EXCH_2 =>
      AUXA := SEMSTAK( SSITOP );  SEMSTAK( SSITOP ) := SEMSTAK( SSITOP - 2 );  SEMSTAK( SSITOP - 2 ) := AUXA;

    when G_CHECK_NAME =>										-- VERIFIER L IDENTITE DU NOM DE FIN DE BLOC AVEC CELUI DU BLOC

      if  DEBUG_SEM  then
        for  I in 0 .. 6  loop
	exit when  SSITOP-I < 1;
	declare
	  SEK	: SEMSTAK_ELMT_KIND	:= SEMSTAK( SSITOP-I ).KIND;
	begin
	  PUT_LINE( " ssitop -" & INTEGER'IMAGE( I ) & ' ' & SEMSTAK_ELMT_KIND'IMAGE( SEK ) );
	  if  SEK /= LIST_ELMT  then PRINT_NODE( SEMSTAK( SSITOP-I ).ELMT ); end if;
	end;
        end loop;
      end if;

      if  SEMSTAK( SSITOP-2).KIND = NODE_ELMT  then
        declare
	SYM_REP_ORIGINE	: TREE		:= SEMSTAK( SSITOP-2 ).ELMT;
        begin
	declare
	  CHECK_ELMT_TY	: NODE_NAME	:= SEMSTAK( SSITOP-2 ).ELMT.TY;
	begin
	if  CHECK_ELMT_TY = DN_PACKAGE_ID  or  CHECK_ELMT_TY = DN_GENERIC_ID  then				--| FIN DE PACK OU DE GENERIQUE
	  SYM_REP_ORIGINE := D( LX_SYMREP, SEMSTAK( SSITOP-2 ).ELMT );
	elsif  CHECK_ELMT_TY = DN_VOID  or  CHECK_ELMT_TY = DN_WHILE
	       or  CHECK_ELMT_TY = DN_FOR  or CHECK_ELMT_TY = DN_REVERSE  then				--| FIN DE BLOC OU DE BOUCLE WHILE OU FOR/REVERSE
	  SYM_REP_ORIGINE := SEMSTAK( SSITOP-3 ).ELMT;
	end if;
          end;

          declare
	  FIRST_STR	:constant STRING	:= PRINT_NAME( SYM_REP_ORIGINE );
	  SECND_STR	:constant STRING	:= PRINT_NAME( AUXA.ELMT );
          begin
	  if  SECND_STR /= FIRST_STR  then
	    ERROR( AUXA.SPOS, "identifier " & FIRST_STR & " expected" );
	  end if;
          end;
        end;
      end if;

      SSITOP := SSITOP - 1;


    when G_CHECK_SUBP_NAME =>										--| VERIFIER L IDENTITE DU NOM DE FIN DE PROC OU PACK AVEC SON CORRESPONDANT

      if  DEBUG_SEM  then
        for  I in 0 .. 6  loop
	exit when  SSITOP-I < 1;
	declare
	  SEK	: SEMSTAK_ELMT_KIND	:= SEMSTAK( SSITOP-I ).KIND;
	begin
	  PUT_LINE( " ssitop -" & INTEGER'IMAGE( I ) & ' ' & SEMSTAK_ELMT_KIND'IMAGE( SEK ) );
	  if  SEK /= LIST_ELMT  then PRINT_NODE( SEMSTAK( SSITOP-I ).ELMT ); end if;
	end;
        end loop;
      end if;

      declare
        INDICE_VERIF	: INTEGER	:= 5;
      begin
        if  SEMSTAK( SSITOP-2).KIND = NODE_ELMT  and then  SEMSTAK( SSITOP-2 ).ELMT.TY = DN_PACKAGE_ID  then
	INDICE_VERIF := 2;
        elsif  SEMSTAK( SSITOP-4).KIND = NODE_ELMT  and then  SEMSTAK( SSITOP-4 ).ELMT.TY = DN_PACKAGE_ID  then
	INDICE_VERIF := 4;
        end if;

        declare
	FIRST_STR	:constant STRING	:= PRINT_NAME( D( LX_SYMREP, SEMSTAK( SSITOP-INDICE_VERIF ).ELMT ) );
	SECND_STR	:constant STRING	:= PRINT_NAME( AUXA.ELMT );
        begin
	if  SECND_STR /= FIRST_STR  then
	  ERROR( AUXA.SPOS, "identifier " & FIRST_STR & " expected" );
	end if;
        end;
      end;
      SSITOP := SSITOP - 1;

    when G_CHECK_ACCEPT_NAME =>

put_line( " check accept name " & SEMSTAK_ELMT_KIND'IMAGE( SEMSTAK( SSITOP ).KIND ) );

      SSITOP := SSITOP - 1;

    end case;

    if DEBUG_SEM then NEW_LINE; end if;

    AP := AP + 1;

  end	BUILD_TREE;
	----------


				-----------------
  procedure			PARSE_COMPILATION
				-----------------
  is
    type STACK_TYPE		is record
			  STATE	: POSITIVE;
			  SRCPOS	: TREE;
			end record;

    STACK_MAX		:constant				:= 125;
    STACK			: array( 1 .. STACK_MAX ) of STACK_TYPE;
    SP			: INTEGER range 1 .. STACK_MAX	:= 1;					--| POINTEUR DE PILE SYNTAXIQUE
    STATE			: POSITIVE			:= 1;					--| ETAT D ANALYSEUR INITIALISE A 1
    AP			: INTEGER;
    ACTION		: INTEGER;
    ASYM			: AC_BYTE;
    NBR_OF_SYLS		: NATURAL;								--| NUMBER OF SYLLABLES TO BE POPPED
    ZERO_BYTE		:constant AC_BYTE			:= 0;


				-----------
  procedure			DEBUG_PRINT		( TXT : STRING )
				-----------
  is
  begin
    for  I in 2 .. SP  loop
      PUT("  ");
    end loop;
    PUT( 's' & POSITIVE'IMAGE( STATE ) & '~' );
    if  2 * SP + TXT'LENGTH > 77  then
      PUT_LINE( TXT( TXT'FIRST .. 77 - 2 * SP ) );
    else
      PUT_LINE( TXT );
    end if;

  end	DEBUG_PRINT;
	-----------


				-----------
  procedure			DEBUG_PRINT		( V : TREE )
				-----------
  is
  begin
    DEBUG_PRINT( PRINT_NAME( V ) );
  end DEBUG_PRINT;
      
  begin
    LTYPE     := LT_END_MARK;										--| INITIALISER A LIGNE VIDE
    SOURCEPOS := TREE_VOID;										--| INITIALISER LA POSITION SOURCE A VIDE
    GET_TOKEN;											--| ALLER CHERCHER UN LEXEME
      
    STACK( 1 ).STATE  := 1;
    STACK( 1 ).SRCPOS := SOURCEPOS;
    STACK( 2 ).SRCPOS := SOURCEPOS;
      
    SSITOP := 0;											-- START WITH EMPTY SEMANTIC STACK

    loop
      AP := GRMR_TBL.GRMR.ST_TBL( STATE );

      if  AP <= 0  then
        ACTION := AP;
      else
       -- POINTS TO SHIFT STUFF
        loop
          ASYM := GRMR_TBL.GRMR.AC_SYM( AP );
          exit when  ASYM = ZERO_BYTE  or else  ASYM = LEX_TYPE'POS( TOKENSYM );
          AP := AP + 1;
        end loop;
        ACTION := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
      end if;

      if  ACTION > 0  then										-- CAN'T BE SEMANTICS SINCE DIDN'T INDIRECT

        if  DEBUG_PARSE  then
 	if  LTYPE in LT_WITH_SEMANTICS  or else  LTYPE = LT_ERROR  then
	  DEBUG_PRINT( LEX_IMAGE( LTYPE ) & "\" & TOKEN_STRING);
	else
	  DEBUG_PRINT( TOKEN_STRING );
	end if;
        end if;
            
					-- ADD TO SEMANTIC STACK IF THIS TOKEN HAS SEMANTICS
        if  LTYPE in LT_WITH_SEMANTICS  then
          if  LTYPE = LT_NUMERIC_LIT  then
            AUXA := ( TOKEN_ELMT, SOURCEPOS, STORE_TEXT( TOKEN_STRING ) );
          else
            AUXA := ( TOKEN_ELMT, SOURCEPOS, STORE_SYM( TOKEN_STRING ) );
          end if;
          PUSH_AUXA_NODE;
        end if;
           
        if  LTYPE = LT_END_MARK  then									--| ARRIVE EN FIN DE COMPILATION
          if  SP /= 2  then
            PUT_LINE( "FIN COMPILE MAIS SP = " & INTEGER'IMAGE( SP ) );
          end if;
          if  SSITOP /= 1  then
            PUT( "FIN COMPILE MAIS SSITOP = " & INTEGER'IMAGE( SSITOP ) );
          else
            AUXA := SEMSTAK( 1 );
            if  AUXA.KIND /= NODE_ELMT  then
              PUT_LINE( "FIN COMPILE MAIS SEMSTAK(1) PAS UN NOEUD." );
            else											--| SAUVER L'ARBRE SYNTAXIQUE DANS LE XD_STRUCTURE DU USER_ROOT
              D( XD_STRUCTURE, USER_ROOT, AUXA.ELMT );
              if  DEBUG_PARSE  then PRINT_NODE( D( XD_STRUCTURE, USER_ROOT ) ); end if;
            end if;
          end if;
          exit;
        end if;

        SP := SP + 1;
        STATE := ACTION;
        STACK( SP ).STATE    := ACTION;
        STACK( SP ).SRCPOS   := SOURCEPOS;
        STACK( SP+1 ).SRCPOS := SOURCEPOS;
        GET_TOKEN;
               
      elsif  ACTION = 0  then										--| ERREUR DE SYNTAXE
        ERROR( SOURCEPOS, "ERREUR DE SYNTAXE - " & SLINE.BDY( F_COL..E_COL ) );					--| INSERE UN NOEUD ERREUR ET AFFICHE UN MESSAGE
        exit;

      else
					-- SEMANTIC AND REDUCE ACTIONS
        NODE_CREATED := FALSE;
        loop

          if  ACTION > -10000  then  -- TRANSFER TO SEMANTIC ACTION TABLE
            AP := - ACTION; -- TRANSFER IN TABLE
            loop
              ACTION := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
              exit when  ACTION <= 0;
              BUILD_TREE( ACTION, AP );									--| CONSTRUCTION DE L ARBRE INCREMENTE AP EN INTERNE
            end loop;
          end if;

          if  ACTION > -30000 and ACTION <= -10000  then
                 -- REDUCE
            ACTION      :=  - ACTION - 10000;
            NBR_OF_SYLS := ACTION/1000;
            ACTION      := ACTION mod 1000; -- I.E., RULE
            SP := SP - NBR_OF_SYLS; -- POP THE STACK
            STATE := STACK( SP ).STATE;
            SEMSTAK( SSITOP ).SPOS := STACK( SP+1 ).SRCPOS;
            if  NODE_CREATED  and then  SEMSTAK( SSITOP ).KIND = NODE_ELMT
                and then  SEMSTAK( SSITOP ).ELMT /= TREE_VOID
	  then
              D( LX_SRCPOS, SEMSTAK( SSITOP ).ELMT, SEMSTAK( SSITOP ).SPOS);
            end if;
                  -- FIND GOTO FOR NONTERMINAL IN THIS STATE
            AP := GRMR_TBL.GRMR.ST_TBL( STATE );
            loop
              AP := AP - 1;
              ASYM := GRMR_TBL.GRMR.AC_SYM( AP );
              if  ASYM = ZERO_BYTE  then
                PUT_LINE ( "!! ****** NONTER GOTO NOT FOUND." );
                raise PROGRAM_ERROR;
              end if;
              exit when  INTEGER( ASYM ) = ACTION;
            end loop;
            STATE := INTEGER( GRMR_TBL.GRMR.AC_TBL( AP ) );
            SP := SP + 1;
            STACK( SP ).STATE := STATE;
            if  NBR_OF_SYLS = 0  then
                    -- NULLABLE REDUCTION; SRCPOS NOT ALREADY THERE
              STACK( SP ).SRCPOS := SOURCEPOS;
            end if;
            STACK( SP+1 ).SRCPOS := SOURCEPOS;
            exit;

          else
            PUT_LINE( "!! PARSE_TABLE_ERROR" );
            raise PROGRAM_ERROR;
          end if;

        end loop;
      end if;
    end loop;

  end	PARSE_COMPILATION;
	-----------------

begin
  READ_PARSE_TABLES;										--| TABLES DE LA GRAMMAIRE LUES DANS PARSE.BIN
  OPEN( IFILE, IN_FILE, PATH_TEXTE & NOM_TEXTE );								--| OUVRIR LE FICHIER SOURCE A COMPILER
  PUT( "ada83 compiling " & PATH_TEXTE & NOM_TEXTE );
  CREATE_IDL_TREE_FILE( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );					--| CREER LE FICHIER D'ARBRE (AVEC SON NOEUD RACINE DE TYPE DN_ROOT)
  USER_ROOT := MAKE( DN_USER_ROOT );									--| CREER UN NOEUD RACINE SECONDAIRE DU TYPE DN_USER_ROOT
  D( XD_USER_ROOT,  TREE_ROOT, USER_ROOT );								--| NOEUD USER_ROOT DANS LE CHAMP XD_USER_ROOT DU NOEUD TREE_ROOT
  D( XD_SOURCENAME, USER_ROOT, STORE_TEXT( NOM_TEXTE ) );							--| NOM DU SOURCE DANS LE CHAMP XD_XOURCENAME DU NOEUD USER_ROOT
      
  PARSE_COMPILATION;										--| EFFECTUER LA PHASE D'ANALYSE SYNTAXIQUE DU SOURCE
      
  D( XD_SOURCE_LIST, TREE_ROOT, SOURCE_LIST.FIRST );							--| STOCKE LA LISTE SOURCE_LIST DANS L'ATTRIBUT XD_SOURCE_LIST
  CLOSE( IFILE );
  CLOSE_PAGE_MANAGER;										--| FERMER LE FICHIER ARBRE

exception
  when NAME_ERROR =>
    PUT_LINE( "FILE NOT FOUND : " & PATH_TEXTE & NOM_TEXTE );
    raise;

end	PAR_PHASE;
	---------

--	1	2	3	4	5	6	7	8	9	10	11	12
