SEPARATE (IDL)
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE IDL_READ
--|-------------------------------------------------------------------------------------------------
PROCEDURE IDL_READ ( NOM_TEXTE :STRING ) IS   --| LIT UNE DESCRIPTION IDL EN MEMOIRE VIRTUELLE
   
  IFILE 		: FILE_TYPE;			--| FICHIER IDL
  SLINE		: STRING ( 1..256 );		--| LIGNE TEXTE COURANTE
  COL		: NATURAL	:= 1;		--| PROCHAINE COLONNE À LIRE
  F_COL		: NATURAL;			--| PREMIÈRE COLONNE DU LEXÈME
  TOKEN_LENGTH		: NATURAL;			--| LONGUEUR DU LEXÈME
  LAST		: NATURAL	:= 0;		--| NOMBRE DE CARACTÈRE DE LA LIGNE
  TOKEN_IS_NAME		: BOOLEAN;
  LINE_COUNT		: NATURAL	:= 0;
   
  ATTR_COUNT		: INTEGER	:= -1;
  SOURCE_LIST		: SEQ_TYPE;			--| LISTE  DES LIGNES SOURCES
  SOURCEPOS		: TREE;			--| LA POSITION SOURCE DU LEXÈME COURANT
  SOURCELINE		: TREE;			--| LE NOEUD LIGNE SOURCE
   
  USER_ROOT		: TREE;			--| RACINE DE L'ARBRE
   
  TYPE CONTEXT_TYPE	IS (NIL, IN_NODE, IN_CLASS);
  CONTEXT		: CONTEXT_TYPE	:= NIL;
   
  PROCEDURE PROCESS_IDL;
  PROCEDURE CHECK_IDL;
  PROCEDURE PRINT_IDL;
   
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE GET_TOKEN
  PROCEDURE GET_TOKEN IS
  BEGIN
    WHILE COL <= LAST AND THEN ( SLINE( COL ) = ' ' OR ELSE SLINE( COL ) = ASCII.HT ) LOOP	--| PASSER LES ESPACES
      COL := COL + 1;
    END LOOP;
         
    IF COL < LAST AND THEN SLINE( COL ) = '-' AND THEN SLINE( COL+1 ) = '-' THEN	--| SAUTER EN FIN DE LIGNE SUR COMMENTAIRE
      COL := LAST + 1;
    END IF;
         
    IF COL > LAST THEN				--| SI ON EST POST FIN DE LIGNE
      LOOP
        IF END_OF_FILE ( IFILE ) THEN RETURN; END IF;
            
        IF END_OF_LINE ( IFILE ) THEN
          SKIP_LINE ( IFILE );
          LINE_COUNT := LINE_COUNT + 1;
          LAST := 0;
        ELSE
          SLINE( 1..2 ) := "??";				--| FORCER À AUTRE CHOSE QUE // EN CAS DE LIGNE VIDE
          GET_LINE( IFILE, SLINE, LAST );			--| LIRE UNE LIGNE
          IF SLINE( 1..2 ) = "//" THEN				--| NE S'OCCUPER QUE DES LIGNES COMMENÇANT PAR //
            COL := 3;				--| SE METTRE EN COL 3 POST "//"
          ELSE
            COL := LAST + 1;				--| POST FIN DE LIGNE POUR NEGLIGER LA LIGNE
          END IF;
        END IF;
            
        WHILE COL <= LAST AND THEN ( SLINE(COL) = ' ' OR ELSE SLINE(COL) = ASCII.HT ) LOOP	--| PASSER LES BLANCS
          COL := COL + 1;
        END LOOP;
            
        IF COL <= LAST THEN
          IF SLINE( COL ) = '-' AND THEN COL < LAST AND THEN SLINE( COL+1 ) = '-' THEN
            COL := LAST + 1;
          ELSE					--| LIGNE NON VIDE
            SOURCELINE := MAKE ( DN_SOURCELINE );			--| CREER UN NOEUD LIGNE SOURCE
            DI  ( XD_NUMBER, SOURCELINE, LINE_COUNT );			--| Y METTRE LE NUMERO DE LIGNE
            LIST( SOURCELINE, (TREE_NIL,TREE_NIL) );			--| INITIALISER LA XD_ERROR_LIST
            SOURCE_LIST := APPEND ( SOURCE_LIST, SOURCELINE );		--| METTRE LA LIGNE EN FILE
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
         
    F_COL := COL;
    TOKEN_LENGTH := 1;
    TOKEN_IS_NAME := FALSE;
         
    CASE SLINE(COL) IS
    WHEN 'A'..'Z' | 'a'..'z' =>
      TOKEN_IS_NAME := TRUE;
      COL := COL +1;
      WHILE COL <= LAST
            AND THEN ( SLINE( COL ) IN 'A'..'Z'
                       OR ELSE SLINE( COL ) IN 'a'..'z'
                       OR ELSE SLINE( COL ) = '_'
                       OR ELSE SLINE( COL ) IN '0'..'9'
               	)
      LOOP
        TOKEN_LENGTH := TOKEN_LENGTH + 1;
        COL := COL + 1;
      END LOOP;
               
    WHEN ':' =>					--| PEUT ETRE ::=
      IF COL + 2 <= LAST
                  AND THEN SLINE (COL + 1) = ':' AND THEN SLINE( COL + 2 ) = '=' THEN	--| OUI UN ::=
        TOKEN_LENGTH := 3;				--| LONGUEUR 3
        COL := COL + 3;
      ELSE
        COL := COL + 1;
      END IF;
               
    WHEN '=' =>					--| PEUT ETRE =>
      IF COL + 1 <= LAST AND THEN SLINE( COL + 1 ) = '>' THEN		--| OUI "=>"
        TOKEN_LENGTH := 2;
        COL := COL + 2;
      ELSE
        COL := COL + 1;
      END IF;
               
    WHEN '|' | ';' | ',' =>
      COL := COL + 1;
               
    WHEN OTHERS =>
      COL := COL + 1;
               
    END CASE;
         
    SOURCEPOS := MAKE_SOURCE_POSITION( SOURCELINE, SRCCOL_IDX( F_COL ) );

  END GET_TOKEN;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PROCESS_IDL
  PROCEDURE PROCESS_IDL IS
      
    RULE_NODE		: TREE;
    NODE_LIST		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
    PRIOR_F_COL	: POSITIVE	:= 1;
    PRIOR_TOKEN_LENGTH	: NATURAL	:= 0;
    TYPE ATTR_TYPE	IS (NORMAL, SEQ);
         
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE MAKE_RULE_OR_CLASS_NODE
    PROCEDURE MAKE_RULE_OR_CLASS_NODE ( NODE_NAME :STRING ) IS
      SYMBOL		: TREE	:= STORE_SYM ( NODE_NAME );	--| STOCKER/RETIRER LE NOM DE NOEUD RÈGLE (NOM EN PARTIE GAUCHE AVANT LE => )
      R_LIST		: SEQ_TYPE	:= LIST ( SYMBOL );		--| LISTE CONTENANT LE NOEUD RÈGLE ASSOCIEES AU SYMBOLE (REFERENCE COMME GAUCHE DE RÈGLE OU TYPAGE)
    BEGIN
      IF IS_EMPTY ( R_LIST ) THEN				--| LA LISTE EST VIDE, C'EST LA PREMIÈRE DEFINITION DE RÈGLE/CLASSE
        RULE_NODE := MAKE ( DN_CLASS_NODE );			--| FABRIQUER UN NOEUD POUR LA RÈGLE/CLASSE
        D ( XD_SYMREP, RULE_NODE, SYMBOL );			--| METTRE LE SYMBOLE DU NOM DE RÈGLE (NOM GAUCHE) DANS LE XD_NAME DU NOEUD RÈGLE
        LIST ( RULE_NODE, (TREE_NIL,TREE_NIL) );			--| INITIALISER À VIDE LA LISTE DES ELEMENTS DU CÔTE DROIT
        IF CONTEXT = IN_NODE THEN				--| DANS UN NOEUD RÈGLE SIMPLE
          DB ( XD_IS_CLASS, RULE_NODE, FALSE );			--| MARQUER UNE RÈGLE DE STRUCTURE D'ATTRIBUTS
        ELSE					--| DANS UNE CLASSE
          DB ( XD_IS_CLASS, RULE_NODE, TRUE );			--| MARQUER UNE RÈGLE DE DEFINITION DE CLASSE
        END IF;
        D ( LX_SRCPOS, RULE_NODE, SOURCEPOS );			--| METTRE LA POSITION SOURCE DONNEE PAR GET_TOKEN
        D ( XD_PARENT, RULE_NODE, TREE_VOID );
        LIST ( SYMBOL, APPEND ( (TREE_NIL,TREE_NIL), RULE_NODE ) );		--| METTRE LE NOEUD RÈGLE COMME ELEMENT UNIQUE DE LISTE DU SYMBOLE DE NOM GAUCHE (XD_DEFLIST)
        NODE_LIST := APPEND ( NODE_LIST, RULE_NODE );			--| METTRE EN LISTE LA RÈGLE
            
      ELSE					--| UNE RÈGLE AVEC MEME PARTIE GAUCHE A DEJÀ ETE VUE
        DECLARE
          DEF	: TREE	:= HEAD ( R_LIST );			--| PRENDRE LE NOEUD DE TETE, LE NOEUD RÈGLE
        BEGIN
          IF DEF.TY = DN_CLASS_NODE THEN			--| VERIFIER QUE C'EST UNE RÈGLE
            RULE_NODE := DEF;				--| PRENDRE CE NOEUD COMME COURANT
            IF CONTEXT = IN_CLASS THEN				--| ON A UN NOM CITE EN CLASSE (PEUT AVOIR ETE TROUVE AUPARAVANT CITE COMME TYPAGE EN DROITE DE RÈGLE D'ATTRIBUTION )
              DB ( XD_IS_CLASS, RULE_NODE, TRUE );			--| MARQUER COMME CLASSE
            END IF;
                     
          ELSE					--| ANOMALIE LE NOEUD N'EST PAS UNE RÈGLE
            ERROR ( SOURCEPOS, "HOLA ! " & NODE_NAME & " N EST PAS UN NOM EN PARTIE GAUCHE (REGLE) !" );
          END IF;
        END;
      END IF;
            
    END MAKE_RULE_OR_CLASS_NODE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE MAKE_ATTR
    PROCEDURE MAKE_ATTR ( ATTR_NAME :STRING; ATYPE :ATTR_TYPE; NOM_TYPE :STRING ) IS
      SYMBOL		: TREE	:= STORE_SYM ( ATTR_NAME );	--| STOCKER/RETIRER LE SYMBOLE (SYMREP) DE L'ATTRIBUT
      A_LIST		: SEQ_TYPE	:= LIST ( SYMBOL );		--| LISTE CONTENANT LA DEFINITION DE L'ATTRIBUT
      TYPAGE		: TREE	:= STORE_SYM ( NOM_TYPE );	--| STOCKER/REPRENDRE LE SYMBOLE DU TYPE DE L'ATTRIBUT (UN NOM DE RÈGLE OU DE CLASSE)
      ATTR		: TREE;
    BEGIN
         
      IF IS_EMPTY ( A_LIST ) THEN				--| AUCUNE APPARITION DE CET ATTRIBUT
        ATTR_COUNT := ATTR_COUNT + 1;				--| UN ATTRIBUT DE PLUS
        ATTR := MAKE ( DN_ATTR );				--| CREER UN NOEUD DE TYPE ATTRIBUT/TERMINAL
        D ( XD_SYMREP, ATTR, SYMBOL );				--| POINTER LE SYMBOLE DANS LE CHAMP XD_SYMREP DU TERMINAL
               
        CASE ATYPE IS				--| SUIVANT QUE L'ON A UN ATTRIBUT SIMPLE OU UNE SEQUENCE
        WHEN NORMAL =>				--| UN ATTRIBUT SIMPLE
          DI ( XD_ATTR_ID, ATTR, ATTR_COUNT );			--| PORTER LE N° D'ATTRIBUT EN POSITIF
        WHEN OTHERS =>				--| UN ATTRIBUT SEQUENCE, PORTER LE N° D'ATTRIBUT EN NEGATIF
          DI (XD_ATTR_ID, ATTR, - ATTR_COUNT );
        END CASE;
        D ( XD_ATTR_TYPE, ATTR, TYPAGE );			--| METTRE LE TYPAGE
        LIST ( SYMBOL, APPEND ( (TREE_NIL,TREE_NIL), ATTR ) );		--| PORTER L'ATTRIBUT CREÉ EN LISTE DANS LE XD_DEFLIST DU SYMREP
               
      ELSE					--| IL Y A DEJÀ EU UNE APPARITION
        ATTR := HEAD ( A_LIST );				--| PRENDRE LA DEFINITION EXISTANTE
      END IF;
            
      IF ATTR.TY = DN_ATTR THEN				--| CE DOIT ETRE UN ATTRIBUT/TERMINAL
        CASE ATYPE IS
        WHEN NORMAL =>				--| ATTRIBUT SIMPLE (NON SEQUENCE)
          IF DI ( XD_ATTR_ID, ATTR ) < 0  THEN			--| IL Y A UNE ANOMALIE (LE N° D'ATTRIBUT DOIT ETRE POSITIF DANS CE CAS)
            ERROR ( SOURCEPOS, "ATTR IS SEQ" & ATTR_NAME);
                       
          ELSIF TYPAGE /= D ( XD_ATTR_TYPE, ATTR ) THEN			--| ANOMALIE SI LE TYPAGE NE CORRESPOND PAS À CE QUI EST DANS L'ATTRIBUT (VOIR LA LIGNE (**) UN PEU PLUS HAUT)
            DECLARE
              OLD_TYPAGE	: TREE	:= D ( XD_ATTR_TYPE, ATTR );
            BEGIN
              ERROR ( SOURCEPOS, "VALUE OF " & ATTR_NAME
                              & " IS "   & PRINT_NAME ( TYPAGE )
                              & " [" & PAGE_IDX'IMAGE ( TYPAGE.PG )
                              & "." & LINE_IDX'IMAGE ( TYPAGE.LN )
                              & "." & NODE_NAME'IMAGE ( TYPAGE.TY ) & "] CALLED " & PRINT_NAME ( TYPAGE )
                              
                              & ", NOT " & PRINT_NAME ( OLD_TYPAGE )
                              & " [" & PAGE_IDX'IMAGE ( OLD_TYPAGE.PG )
                              & "." & LINE_IDX'IMAGE ( OLD_TYPAGE.LN )
                              & "." & NODE_NAME'IMAGE ( OLD_TYPAGE.TY ) & "] CALLED " & PRINT_NAME ( OLD_TYPAGE )
                              );
            END;
          END IF;
        WHEN OTHERS =>				--| ATTRIBUT SEQUENCE
          IF DI ( XD_ATTR_ID, ATTR) >= 0 THEN			--| ANOMALIE SI LE N° D'ATTRIBUT EST POSITIF (IL DOIT ETRE NEGATIF POUR UNE SEQUENCE)
            ERROR ( SOURCEPOS, "ATTR IS NOT SEQ" & ATTR_NAME );
                        
          ELSIF TYPAGE /= D ( XD_ATTR_TYPE, ATTR) THEN			--| SI LE TYPAGE DE SEQUENCE DIFFÈRE DE L'ANTERIEUR
            DECLARE
              TEMP	: TREE	:= ATTR;			--| GARER L'ATTRIBUT ANCIENNEMENT TYPE
            BEGIN
              ATTR := MAKE ( DN_ATTR );				--| REFAIRE UN TERMINAL QUI EST PRIS COMME ATTRIBUT
              D  ( XD_SYMREP, ATTR, D ( XD_SYMREP, TEMP ) );		--| DANS LE SYMREP DU NOUVEAU, RECOPIER LE SYMREP DE L'ANCIEN
              DI ( XD_ATTR_ID, ATTR, DI ( XD_ATTR_ID, TEMP ) );		--| REPORTER AUSSI LE N° D'ATTRIBUT
              D  ( XD_ATTR_TYPE, ATTR, TYPAGE );			--| METTRE LE TYPAGE DANS CE NOUVEAU NOEUD ATTRIBUT QUI DIFÈRE PAR LE TYPAGE
            END;
          END IF;
        END CASE;
        DECLARE
          ASEQ	: SEQ_TYPE	 := LIST ( RULE_NODE );		--| REPRENDRE LA XD_LIST DU NOEUD RÈGLE EN COURS
        BEGIN
          LIST ( RULE_NODE, APPEND ( ASEQ, ATTR ) );			--| AJOUTER AU NOEUD RÈGLE EN COURS LA LISTE DES ATTRIBUTS AUGMENTEE
        END;
      ELSE					--| LA DEFINITION (TROUVEE) N'EST PAS UN TERMINAL !
        ERROR ( SOURCEPOS, "NOT DEFINED AS AN ATTRIBUTE -" & ATTR_NAME );
               
      END IF;
            
    END MAKE_ATTR;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE MAKE_MEMBER
    PROCEDURE MAKE_MEMBER ( MEMBER_NAME :STRING ) IS
         
      SYMBOL		: TREE	:= STORE_SYM ( MEMBER_NAME );	--| STOCKER/REPRENDRE LE SYMREP CORRESPONDANT AU NOM D'ELEMENT DE CLASSE
      MEMBER		: TREE	:= MAKE ( DN_MEMBER );	--| FABRIQUER UN NON TERMINAL POUR UN ELEMENT APPARTENANT À UNE CLASSE
      M_LIST		: SEQ_TYPE	:= LIST ( SYMBOL );		--| LA LISTE CONTENANT LA RÈGLE DEFINISSANT LE SYMBOLE
    BEGIN
      D ( XD_SYMREP, MEMBER, SYMBOL );				--| METTRE LE SYMREP DANS LE CHAMP XD_SYMREP DU MEMBRE DE CLASSE
      D ( LX_SRCPOS, MEMBER, SOURCEPOS );			--| METTRE LA POSITION SOURCE DU MEMBRE CREÉ PAR GET_TOKEN
      LIST ( RULE_NODE, APPEND ( LIST ( RULE_NODE ), MEMBER ) );		--| AJOUTER LE MEMBRE À LA LISTE DES MEMBRES DU NOEUD
    END ;
    --|---------------------------------------------------------------------------------------------
      
  BEGIN
    LAST := 0;
    COL := 1;
    GET_TOKEN;
    LOOP
         
      EXIT WHEN END_OF_FILE (IFILE) OR ELSE SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "end";	--| FINIR AVEC LE FICHIER OU LE LEXÈME %%% QUI INDIQUE LA FIN
         
      IF TOKEN_IS_NAME THEN				--| LEXÈME IDENTIFICATEUR
        PRIOR_F_COL := F_COL;				--| GARDER SA POSITION
        PRIOR_TOKEN_LENGTH := TOKEN_LENGTH;			--| ET SA LONGUEUR
        GET_TOKEN;					--| ET PASSER AU SUIVANT (QUI VA PERMETTRE DE SAVOIR CE QUE L'ON VA FAIRE)
                  
      ELSIF SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "=>" THEN		--| INDIQUE UNE RÈGLE DEFINISSANT DES ATTRIBUTS
        CONTEXT := IN_NODE;				--| GARDER UNE TRACE DE CE FAIT : DEFINITION D'UNE ASSOCIATION D'ATTRIBUTS
        MAKE_RULE_OR_CLASS_NODE ( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) );	--| TENTER LA CREATION D'UN NOEUD RÈGLE (OU LE RAMENER S'IL EXISTE DEJÀ)
        GET_TOKEN;					--| ALLER CHERCHER LE PREMIER NOM D'ATTRIBUT OU LE ;
                  
      ELSIF SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "::=" THEN		--| LEXÈME MARQUANT UNE DEFINITION DE CLASSE
        CONTEXT := IN_CLASS;				--| GARDER UNE TRACE DE CE FAIT : DEFINITION D'UNE CLASSE
        MAKE_RULE_OR_CLASS_NODE ( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) );	--| TENTER LA CREATION D'UN NOEUD RÈGLE (OU LE RAMENER S'IL EXISTE DEJÀ)
        GET_TOKEN;					--| ALLER CHERCHER UN COMPOSANT DE CLASSE
        WHILE SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) /= ";" LOOP		--| JUSQU'À LA FIN DE LA DEFINITION DE CLASSE
          IF TOKEN_IS_NAME THEN				--| SI L'ON A UN NOM (PAS UNE ',' SEPARATRICE)
            MAKE_MEMBER ( SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) );		--| CREER UN MEMBRE DE CLASSE
          END IF;
          GET_TOKEN;				--| AVANCER AU LEXÈME SUIVANT
        END LOOP;
                  
      ELSIF SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = ":" THEN		--| SEPARATEUR DU TYPAGE
        GET_TOKEN;					--| AMENER UN SEQ OU LE NOM DU TYPE
        IF SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "Seq" THEN		--| C'EST UN SEQ
          GET_TOKEN;				--| PRENDRE LE OF OU LE NOM DE TYPE
          IF SLINE( F_COL..F_COL + TOKEN_LENGTH - 1) = "Of" THEN		--| ON A LE OF
            GET_TOKEN;				--| PRENDRE LE NOM DE TYPE
          END IF;
          MAKE_ATTR ( SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ), SEQ,	--| AJOUTER UN ATTRIBUT SEQUENCE
                      SLINE( F_COL..F_COL + TOKEN_LENGTH - 1 )		--| AVEC SON TYPAGE
                     );
               
        ELSIF SLINE( PRIOR_F_COL..PRIOR_F_COL +PRIOR_TOKEN_LENGTH -1 ) /= "lx_comments" THEN	--| SI CE N'EST PAS UN ATTRIBUT LX_COMMENTS
          MAKE_ATTR ( SLINE( PRIOR_F_COL..PRIOR_F_COL + PRIOR_TOKEN_LENGTH - 1), NORMAL,	--| AJOUTER UN ATTRIBUT SIMPLE (NON SEQUENCE)
                      SLINE( F_COL..F_COL + TOKEN_LENGTH - 1 )		--| AVEC SON TYPAGE
                     );
        END IF;
               
      ELSE
        GET_TOKEN;					--| LEXÈME NON RECONNU, PASSER AU SUIVANT
      END IF;
    END LOOP;
      
    USER_ROOT := MAKE ( DN_USER_ROOT );				--| FABRIQUER LE NOEUD RACINE ARBRE
    D ( XD_SOURCENAME, USER_ROOT, STORE_TEXT ( NOM_TEXTE ) );		--| Y METTRE LE NOM DE FICHIER ANS XD_SOURCENAME
    LIST ( USER_ROOT, NODE_LIST );				--| PORTER DANS LE NOEUD SEQUENCE LA LISTE DES NOEUDS
    D ( XD_USER_ROOT, TREE_ROOT, USER_ROOT );			--| METTRE LE NOEUD RACINE ARBRE DANS LA RACINE SYSTÈME
  END PROCESS_IDL;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE CHECK_IDL
  PROCEDURE CHECK_IDL IS
    NODE_LIST		: SEQ_TYPE	:= LIST ( USER_ROOT );	--| REPRENDRE LA LISTE DES RÈGLES DU CHAMP XD_LIST
    RULE_NODE		: TREE;
    ITEM_LIST		: SEQ_TYPE;
    ITEM		: TREE;
  BEGIN
    PUT_LINE ( "**** VERIFICATION ...");
    WHILE NOT IS_EMPTY ( NODE_LIST ) LOOP
      POP ( NODE_LIST, RULE_NODE );				--| RETIRER UN NOEUD RÈGLE
      ITEM_LIST := LIST ( RULE_NODE );				--| LISTE DES ATTRIBUTS OU DES MEMBRES
      WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP			--| TANT QUE LISTE NON VIDE
        POP ( ITEM_LIST, ITEM );				--| RETIRER UN ELEMENT DE LA XD_LIST (ATTRIBUT OU MEMBRE DE CLASSE)
            
        IF ITEM.TY = DN_ATTR THEN				--| TERMINAL (OU ATTRIBUT)
          DECLARE
            TYPAGE	: TREE	:= D ( XD_ATTR_TYPE, ITEM );		--| LE TYPE DE L'ATTRIBUT
          BEGIN
            IF TYPAGE.TY /= DN_SYMBOL_REP THEN
              ERROR ( D ( LX_SRCPOS, RULE_NODE ), "TYPAGE INEXISTANT: " );
            END IF;
          END;
                 
        ELSE					--| NON TERMINAL (OU MEMBRE DE CLASSE)
          DECLARE
            DEFINING_RULE_LIST	: SEQ_TYPE	:= LIST ( D ( XD_SYMREP, ITEM ) );
          BEGIN
                  
            IF IS_EMPTY ( DEFINING_RULE_LIST ) THEN
              ERROR ( D ( LX_SRCPOS, RULE_NODE ), "!! CLASSE VIDE : " & PRINT_NAME ( D ( XD_SYMREP, ITEM ) ) );
            ELSIF HEAD ( DEFINING_RULE_LIST ).TY /= DN_CLASS_NODE THEN 
              ERROR ( D ( LX_SRCPOS, RULE_NODE ), "!! PAS UN NOEUD CLASSE : " & PRINT_NAME ( D ( XD_SYMREP, ITEM ) ) );
            ELSE
              DECLARE
                DEFINING_RULE	: CONSTANT TREE	:= HEAD ( DEFINING_RULE_LIST );
                OWNER	: CONSTANT TREE	:= RULE_NODE;
                PARENT	: TREE	:= D ( XD_PARENT, DEFINING_RULE );
              BEGIN
                D ( XD_CLASS_NODE, ITEM, DEFINING_RULE );
                IF PARENT = TREE_VOID THEN
                  D ( XD_PARENT, DEFINING_RULE, OWNER );
                             
                ELSIF DEFINING_RULE = TREE_VOID THEN
                  NULL;
                ELSIF PARENT /= OWNER THEN
                  ERROR ( D ( LX_SRCPOS, OWNER ), "NOEUD/CLASSE "
                                 & PRINT_NAME ( D ( XD_SYMREP, DEFINING_RULE ) )
                                 & " A LA FOIS DANS " & PRINT_NAME ( D ( XD_SYMREP, OWNER ) )
                                 & " ET " & PRINT_NAME ( D ( XD_SYMREP, PARENT ) )
                                 );
                END IF;
              END;
            END IF;
          END;
        END IF;
      END LOOP;
    END LOOP;
  END CHECK_IDL;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PRINT_IDL
  PROCEDURE PRINT_IDL IS
    NODE_LIST		: SEQ_TYPE	:= LIST ( USER_ROOT );
    RULE_NODE		: TREE;
    ITEM_LIST		: SEQ_TYPE;
    ITEM		: TREE;
    DEFLIST		: SEQ_TYPE;
    NFILE, CFILE	: TEXT_IO.FILE_TYPE;			--| FICHIERS NOEUDS ET HIERARCHIE
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE CLASS_PATH
    PROCEDURE CLASS_PATH ( NODE :TREE; IS_CLASS :BOOLEAN ) IS
      PARENT	: CONSTANT TREE	:= D( XD_PARENT, NODE );
    BEGIN
      IF PARENT = NODE THEN
        ERROR( D( LX_SRCPOS, NODE ), "AUTO PARENT ! " & PRINT_NAME( D( XD_SYMREP, NODE ) ) );
        PUT_LINE ( "ERREUR PARTITION" );
      END IF;
         
      IF PARENT = TREE_VOID THEN				--| CLASSE DE BASE
        IF DB( XD_IS_CLASS, NODE ) THEN				--| UN NOEUD CLASSE
          DECLARE
            THE_NAME	: CONSTANT STRING	:= PRINT_NAME( D ( XD_SYMREP, NODE ) );
          BEGIN
            IF THE_NAME /= "NON_DIANA"
              AND THEN THE_NAME /= "ALL_SOURCE"
              AND THEN THE_NAME /= "TYPE_SPEC"
              AND THEN THE_NAME /= "STANDARD_IDL"
            THEN
              PUT_LINE ( "**** PARTITION INATTENDUE = " & THE_NAME );
            END IF;
            PUT( THE_NAME );
            IF NOT IS_CLASS THEN
              PUT( CFILE, THE_NAME );
            END IF;
          END;
               
        ELSE					--| UN NOEUD DE RÈGLE D'ATTRIBUTION
          PUT( "..." );
        END IF;
            
      ELSE					--| PAS CLASSE DE BASE
        CLASS_PATH( PARENT, IS_CLASS );				--| REMONTER VERS LA CLASSE DE BASE
        PUT( " > " & PRINT_NAME( D( XD_SYMREP, NODE ) ) );
        IF NOT IS_CLASS THEN
          PUT ( CFILE, " > " & PRINT_NAME ( D ( XD_SYMREP, NODE ) ) );		--| REPETER
        END IF;
      END IF;
    END CLASS_PATH;
         
         
  BEGIN
    CREATE ( NFILE, OUT_FILE, NOM_TEXTE & "_NODES_.TXT" );			--| FICHIER INFORMATION TEXTE DES NOEUDS
    CREATE ( CFILE, OUT_FILE, NOM_TEXTE & "_CLASS_.TXT" );			--| FICHIER INFORMATION TEXTE HIERARCHIE DES CLASSES
    SET_OUTPUT ( NFILE );
    PUT_LINE ( "----- ARBORESCENCE IDL -----");
    WHILE NOT IS_EMPTY ( NODE_LIST ) LOOP
      POP ( NODE_LIST, RULE_NODE );
            
      DECLARE
        IS_A_CLASS	: CONSTANT BOOLEAN	:= DB ( XD_IS_CLASS, RULE_NODE );
      BEGIN
        DECLARE
          RULE_CLASS_NAME	: CONSTANT STRING	:= PRINT_NAME ( D ( XD_SYMREP, RULE_NODE ) );
        BEGIN
               
          IF IS_A_CLASS THEN				--| DEFINIT UNE CLASSE
            PUT ( "{" & RULE_CLASS_NAME & "}" );
          ELSE
            PUT ( RULE_CLASS_NAME );
          END IF;
        END;
            
        PUT ( ASCII.HT & "PATH " );
        CLASS_PATH ( RULE_NODE, IS_CLASS=> DB ( XD_IS_CLASS, RULE_NODE ) );
        IF NOT IS_A_CLASS THEN				--| PAS UNE CLASSE
          NEW_LINE ( CFILE );
        END IF;
            
        ITEM_LIST := LIST ( RULE_NODE );			--| LISTE DES ATTRIBUTS OU DES MEMBRES
        IF NOT IS_EMPTY ( ITEM_LIST ) THEN
          IF IS_A_CLASS THEN				--| DEFINIT UNE CLASSE
            PUT ( " ::= " );
          END IF;
        END IF;
        NEW_LINE;
      END;
         
      WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP
        POP ( ITEM_LIST, ITEM );
               
        IF ITEM.TY = DN_ATTR THEN				--| ATTRIBUT
          PUT ( ASCII.HT & "=> " & PRINT_NAME ( D ( XD_SYMREP, ITEM ) ) & ASCII.HT & ": ");
          IF DI ( XD_ATTR_ID, ITEM ) < 0 THEN			--| ATTRIBUT SEQUENCE
            PUT ( "SEQ OF ");
          END IF;
          PUT_LINE ( PRINT_NAME ( D ( XD_ATTR_TYPE, ITEM ) ) );		--| TYPAGE
                  
        ELSE					--| MEMBRE DE CLASSE
          PUT ( ASCII.HT & PRINT_NAME ( D ( XD_SYMREP, ITEM ) ) );		--| NOM DU MEMBRE
          DEFLIST := LIST ( D ( XD_SYMREP, ITEM ) );
          IF IS_EMPTY ( DEFLIST ) OR ELSE HEAD ( DEFLIST ).TY /= DN_CLASS_NODE THEN
            PUT ( " ?????" );
          END IF;
          NEW_LINE;
        END IF;
      END LOOP;
      NEW_LINE;
            
    END LOOP;
    SET_OUTPUT ( STANDARD_OUTPUT );
    CLOSE ( NFILE );
    CLOSE ( CFILE );
         
  EXCEPTION
    WHEN OTHERS =>
      CLOSE ( NFILE );
      CLOSE ( CFILE );
      PUT_LINE ( "ERREUR A L IMPRESSION" );
  END PRINT_IDL;
   
BEGIN
   
  OPEN ( IFILE, IN_FILE, NOM_TEXTE & ".IDL" );			--| FICHIER SOURCE IDL
  PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".IDL EST OUVERT " );
  CREATE_IDL_TREE_FILE ( NOM_TEXTE & ".LAR");			--| FICHIER D'ARBRE IDL
  PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".LAR  EST CREE" );
  SOURCE_LIST := (TREE_NIL,TREE_NIL);
      
  PUT_LINE ( "PROCESS IDL ..." ); PROCESS_IDL; PUT_LINE ( " OK" );
  LIST ( TREE_ROOT, SOURCE_LIST );
  CLOSE ( IFILE );
      
  CHECK_IDL;
  PRINT_IDL;
         
  CLOSE_IDL_TREE_FILE;
       
EXCEPTION
  WHEN NAME_ERROR =>
    PUT_LINE ( "LE FICHIER DESCRIPTION : " & NOM_TEXTE & ".IDL  EST INTROUVABLE" );
   
--|-------------------------------------------------------------------------------------------------
END IDL_READ;
