WITH UNCHECKED_CONVERSION;
SEPARATE (IDL)
--|-------------------------------------------------------------------------------------------------
--|			IDL_MAN
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY IDL_MAN IS
   
  TREE_HASH	: TREE		:= (P, TY=> DN_HASH, PG=> 2, LN=> 0 );
   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION ARITY
--|
FUNCTION ARITY ( T :TREE ) RETURN ARITIES IS
BEGIN 
  RETURN N_SPEC( T.TY ).NS_ARITY;							--| RETOURNER L'ARITE SUIVANT LES SPECIFS DU TYPE DE NOEUD ARBRE
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_1
--|
FUNCTION SON_1 ( T :TREE ) RETURN TREE IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY IN UNARY .. TERNARY THEN					--| SI L'ARITE LE PERMET
    RETURN DABS ( 1, T );								--| RETOURNER LE PREMIER SOUS ARBRE DE T
  END IF;
         
  PUT_LINE ( "IDL.IDL_MAN.SON_1 : PAS DE FILS 1 LISIBLE POUR " & NODE_REP ( T ) );
  RAISE PROGRAM_ERROR;
END SON_1;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_1
--|
PROCEDURE SON_1 ( T :TREE; V :TREE ) IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY IN UNARY .. TERNARY THEN					--| SI L'ARITE LE PERMET
    DABS ( 1, T, V );								--| STOCKER V COMME PREMIER SOUS ARBRE DE T
  ELSE
    PUT_LINE ( "IDL.IDL_MAN.SON_1 : PAS DE FILS 1 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;            
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_2
--|
FUNCTION SON_2 ( T :TREE ) RETURN TREE IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY IN BINARY .. TERNARY THEN
    RETURN DABS ( 2, T );
  END IF;

  PUT_LINE ( "IDL.IDL_MAN.SON_2 : PAS DE FILS 2 LISIBLE POUR " & NODE_REP ( T ) );
  RAISE PROGRAM_ERROR;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_2
--|
PROCEDURE SON_2 ( T :TREE; V :TREE ) IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY IN BINARY .. TERNARY THEN
    DABS ( 2, T, V );
  ELSE
    PUT_LINE ( "IDL.IDL_MAN.SON_2 : PAS DE FILS 2 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;            
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_3
--|
FUNCTION SON_3 ( T :TREE ) RETURN TREE IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY = TERNARY THEN
    RETURN DABS(3, T);
  END IF;

  PUT_LINE ( "IDL.IDL_MAN.SON_3 : PAS DE FILS 3 LISIBLE POUR " & NODE_REP ( T ) );
  RAISE PROGRAM_ERROR;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_3
--|
PROCEDURE SON_3 ( T :TREE; V :TREE ) IS
BEGIN
  IF N_SPEC( T.TY ).NS_ARITY = TERNARY THEN
    DABS ( 3, T, V );
  ELSE
    PUT_LINE ( "IDL.IDL_MAN.SON_3 : PAS DE FILS 3 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION HEAD
--|
FUNCTION HEAD ( S :SEQ_TYPE ) RETURN TREE IS
BEGIN
  IF S.FIRST.TY = DN_LIST THEN							--| LA SEQ CONTIENT UNE LISTE
    RETURN DABS ( 1, S.FIRST );							--| RENDRE LE PREMIER CHAMP DU NOEUD LISTE
  ELSIF S.FIRST /= TREE_NIL THEN							--| LA SEQ CONTIENT UN ELEMENT
    RETURN S.FIRST;									--| RENDRE CELUI-CI
  END IF;
            
  PUT_LINE ( "IDL.IDL-MAN.HEAD : TETE DE SEQUENCE SEQ.FIRST = TREE_NIL !" );
  RAISE PROGRAM_ERROR;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION TAIL
--|
FUNCTION TAIL ( S :SEQ_TYPE ) RETURN SEQ_TYPE IS						--| RETOURNE UN SEQ SUITE DE LISTE
BEGIN
  IF S.FIRST.TY = DN_LIST THEN							--| LISTE A PLUSIEURS ELEMENTS
    DECLARE
      QUEUE :  SEQ_TYPE	:= ( FIRST=> DABS ( 2, S.FIRST ) , NEXT=> TREE_NIL );		--| TETE DE QUEUE ET RIEN
    BEGIN
      IF QUEUE.FIRST.TY = DN_LIST THEN							--| SI TETE INDIQUANT UNE LISTE AVEC UNE SUITE
        QUEUE.NEXT := S.NEXT;								--| LA SUITE DE LA QUEUE EST RENDUE
      END IF;
      RETURN QUEUE;
    END;
  ELSIF S.FIRST /= TREE_NIL THEN							--| LISTE A UN SEUL ELEMENT
    RETURN ( TREE_NIL, TREE_NIL );							--| RETOURNER UN SEQ VIDE
  END IF;
            
  PUT_LINE ( "IDL.IDL-MAN.TAIL : LISTE VIDE S.FIRST = TREE_NIL !" );
  RAISE PROGRAM_ERROR;
END TAIL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION INSERT
--|
FUNCTION INSERT ( S :SEQ_TYPE; T :TREE ) RETURN SEQ_TYPE IS					--| INSERTION D'UN SEQ EN TETE DE SEQUENCE
BEGIN
  IF S.FIRST = TREE_NIL THEN								--| SEQUENCE VIDE
    RETURN (FIRST=> T , NEXT=> TREE_NIL );						--| RETOURNER UN SEQ A UN ELEMENT
  END IF;
      
  DECLARE										--| LE SEQ INITIAL ETAIT NON VIDE
    T_SEQ		: SEQ_TYPE	:= ( FIRST=> MAKE ( DN_LIST ) , NEXT=> S.NEXT );		--| NOUVELLE SEQUENCE
  BEGIN
    DABS ( 1, T_SEQ.FIRST, T );							--| TETE DE SEQUENCE SUR T
    DABS ( 2, T_SEQ.FIRST, S.FIRST );							--| SUITE CONSTITUEE PAR LE DEBUT DE S
            
    IF S.NEXT = TREE_NIL THEN								--| SI S NE CONTIENT QU'UN ELEMENT
      T_SEQ.NEXT := T_SEQ.FIRST;							--| LA SUITE EST CONFONDUE AVEC LE PREMIER ELEMENT
    END IF;
            
    RETURN T_SEQ;
  END;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION APPEND
--|
FUNCTION APPEND ( S :SEQ_TYPE; T :TREE ) RETURN SEQ_TYPE IS
  T_SEQ		: SEQ_TYPE;
BEGIN
  IF S.FIRST = TREE_NIL THEN								--| LISTE VIDE
    RETURN ( FIRST=> T , NEXT=> TREE_NIL );						--| SEQUENCE T EN TETE RIEN DERRIERE
               
  ELSIF S.FIRST.TY /= DN_LIST THEN							--| SEQUENCE A 1 ELEMENT (PAS DE LISTE EN S.FIRST)
    T_SEQ.FIRST  := MAKE ( DN_LIST );							--| FABRIQUER UNE LISTE
    DABS ( 1, T_SEQ.FIRST, S.FIRST );							--| L'ELEMENT DE S EST EN TETE
    DABS ( 2, T_SEQ.FIRST, T );							--| T SUIT EN FIN
    T_SEQ.NEXT := T_SEQ.FIRST;							--| SEQUENCE TETE ET SUITE CONFONDUES
               
  ELSE										--| S EST UNE LISTE A PLUS D'UN ELEMENT
    DECLARE
      T_TAIL	: TREE		:= S.NEXT;
      T_END	: TREE;
    BEGIN
      IF S.NEXT = TREE_NIL THEN							--| LA SEQUENCE S N'A QU'UNE TETE
        T_TAIL := S.FIRST;								--| LA QUEUE EST LE DEBUT
      END IF;
      LOOP
        T_END := DABS ( 2, T_TAIL );							--| TREE DE FIN DE S
        EXIT WHEN T_END.TY /= DN_LIST;							--| SORTIE EN FIN DE LISTE (SIMPLE POINTEUR A UN ELEMENT)
        T_TAIL := T_END;								--| SUIVRE LA LISTE
      END LOOP;
      T_SEQ.FIRST := S.FIRST;
      T_SEQ.NEXT := MAKE ( DN_LIST );							--| FABRIQUER UN ELEMENT DE LISTE
      DABS ( 1, T_SEQ.NEXT, T_END );							--| TETE DE LISTE
      DABS ( 2, T_SEQ.NEXT, T );							--| QUEUE DE LISTE
      DABS ( 2, T_TAIL, T_SEQ.NEXT );							--| CHAINAGE
    END;
  END IF;
            
  RETURN T_SEQ;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SINGLETON
--|
FUNCTION SINGLETON ( T :TREE ) RETURN SEQ_TYPE IS
BEGIN
  RETURN ( FIRST=> T , NEXT=> TREE_NIL );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE LIST
--|
PROCEDURE LIST ( T :TREE; S :SEQ_TYPE ) IS
  A_IDX		: INTEGER := N_SPEC( T.TY ).NS_FIRST_A;
BEGIN
  FOR I IN 1 .. N_SPEC( T.TY ).NS_SIZE LOOP						--| PARCOURIR LES ATTRIBUTS
    IF A_SPEC( A_IDX ).IS_LIST THEN							--| SI ATTRIBUT LISTE RENCONTRE
      DABS ( I, T, S.FIRST );								--| STOCKE LA TETE DE V DANS L'ATTRIBUT I DU NOEUD POINTE PAR T
      RETURN;									--| C'EST BON, SORTIR
    END IF;
    A_IDX := A_IDX + 1;								--| ATTIBUT SUIVANT
  END LOOP;
      
  PUT_LINE ( "IDL.IDL_MAN.LIST : PAS DE LISTE INSCRIPTIBLE DANS " & NODE_REP ( T ) );
  RAISE PROGRAM_ERROR;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE DABS
--|
PROCEDURE DABS ( RANG :ATTR_NBR; T :TREE; VAL :TREE ) IS
  RN		: RPG_IDX;
BEGIN
  IF T.PG /= CUR_VP THEN								--| LA PAGE QUI NOUS INTERESSE N'EST PAS COURANTE
    CUR_VP := T.PG;									--| LA MENTIONNER COMME COURANTE
    RN := ASSOC_PAGE( CUR_VP );							--| SON ASSOCIEE PHYSIQUE EST LA RN
--    IF RN = 0 OR ELSE PAG ( RN ).RECUPERABLE THEN					--| SI ELLE EST FLOTTANTE
    IF RN = 0 THEN									--| SI HORS MEMOIRE
      CUR_RP := READ_PAGE ( CUR_VP );							--| ASSURER LA PAGE PHYSIQUE
    ELSE										--| NON FLOTTANTE
      CUR_RP := RN;									--| PAGE REELLE COURANTE
    END IF;
  END IF;
         
  PAG( CUR_RP ).DATA.ALL( T.LN + RANG ) := VAL;						--| ECRIRE
  PAG( CUR_RP ).CHANGED := TRUE;							--| MENTIONNEE CHANGEE (ON Y A ECRIT ! )
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION DABS
--|
FUNCTION DABS ( RANG :ATTR_NBR; T :TREE ) RETURN TREE IS
  RN		: RPG_IDX;
BEGIN
  IF T.PG /= CUR_VP THEN								--| LA PAGE DE T N'EST PAS LA COURANTE
    CUR_VP := T.PG;									--| LA MENTIONNER COMME COURANTE
    RN := ASSOC_PAGE( CUR_VP );							--| PAGE REELLE ASSOCIEE : RN
--    IF RN = 0 OR ELSE PAG( RN ).RECUPERABLE THEN					--| SI ELLE EST FLOTTANTE
    IF RN = 0 THEN									--| SI HORS MEMOIRE
      CUR_RP := READ_PAGE( CUR_VP );							--| ASSURER LA PAGE PHYSIQUE
    ELSE										--| NON FLOTTANTE
      CUR_RP := RN;									--| PAGE REELLE COURANTE
    END IF;
  END IF;
  RETURN PAG( CUR_RP ).DATA.ALL( T.LN + RANG );						--| LIRE
END;   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION STORE_TEXT
--|
FUNCTION STORE_TEXT ( S :STRING ) RETURN TREE IS						--| STOCKE UNE REPRESENTATION TEXTE
  NB_TREES	: LINE_IDX
		:= LINE_IDX( ( (S'LENGTH+1) * CHARACTER'SIZE + TREE'SIZE-1) / TREE'SIZE );	--| NOMBRE DE TREES POUR CONTENIR LES CARACTERES DE S ET UN OCTET DE LONGUEUR
  NB_CARS		: NATURAL
		:= NATURAL( NB_TREES ) * TREE'SIZE / CHARACTER'SIZE;
BEGIN
  DECLARE
    TT			: TREE		:= MAKE ( DN_TXTREP, NB_ATTR=> NB_TREES, AR=> 9 );--| FABRIQUER LE NOEUD CONTENANT LE TEXTE
    TYPE TTREES		IS ARRAY (1..NB_TREES) OF TREE;
    SUBTYPE LSTR		IS STRING (1..NB_CARS);
    FUNCTION TO_TREES	IS NEW UNCHECKED_CONVERSION ( LSTR, TTREES );
    A_COPIER		: LSTR		:= (OTHERS=> ASCII.NUL);
    START			: LINE_IDX		:= TT.LN;
    TTR			: TTREES;
  BEGIN
    A_COPIER( 1..S'LENGTH+1 ) := CHARACTER'VAL ( S'LENGTH ) & S;
    TTR := TO_TREES ( A_COPIER );
    FOR I IN 1..NB_TREES LOOP
      PAG( CUR_RP).DATA.ALL( START+I ) :=  TTR( I );
    END LOOP;
    PAG( CUR_RP ).CHANGED := TRUE;							--| MENTIONNEE CHANGEE (ON Y A ECRIT ! )
    RETURN TT;
  END;
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION HASH_SEARCH
--|
FUNCTION HASH_SEARCH ( S :STRING ) RETURN TREE IS
  NB_TREES		: ATTR_NBR
		:= ATTR_NBR( ( (S'LENGTH+1) * CHARACTER'SIZE + TREE'SIZE-1) / TREE'SIZE );	--| NOMBRE DE TREES POUR CONTENIR LES CARACTERES DE S ET UN OCTET DE LONGUEUR
  NB_CARS		: NATURAL
		:= NATURAL( NB_TREES ) * TREE'SIZE / CHARACTER'SIZE;
  TYPE TTREES		IS ARRAY ( 1 .. NB_TREES ) OF TREE;
  SUBTYPE LSTR		IS STRING ( 1 .. NB_CARS );					--| CHAINE DE S AVEC UN OCTET DE LONGUEUR
  FUNCTION TO_TREES		IS NEW UNCHECKED_CONVERSION ( LSTR, TTREES );			--| CONVERSION DE LA CHAINE EN TABLEAU DE TREES
  TTR			: TTREES;							--| VARIABLE CONVERTIE
  A_COPIER		: LSTR		:= (OTHERS=> ASCII.NUL);
         
  HASH_SUM		: INTEGER := 0;						--| VALEUR DE HACHAGE
  FUNCTION TO_INT		IS NEW UNCHECKED_CONVERSION( TREE, INTEGER );
         
BEGIN
  A_COPIER( 1 .. S'LENGTH+1 ) := CHARACTER'VAL( S'LENGTH ) & S;
  TTR := TO_TREES( A_COPIER );							--| VARIABLE CONVERTIE
      
  FOR I IN 1 .. NB_TREES LOOP								--| BOUCLE DE CALCUL DE LA VALEUR DE HACHAGE
    HASH_SUM := ABS( HASH_SUM - TO_INT( TTR( I ) ) );
  END LOOP;
        
  DECLARE
    BUCKET	: LINE_IDX	:= LINE_IDX( (HASH_SUM MOD INTEGER( LINE_IDX'LAST )) + 1 );	--| SEAU DE HACHAGE (INDICE DANS LE BLOC DES TETES DE LISTE)
    HASH_LIST	: SEQ_TYPE	:= ( FIRST=> DABS ( BUCKET, TREE_HASH ) , NEXT=> TREE_NIL );--| TETE DE LISTE HACHEE
  BEGIN
    WHILE HASH_LIST.FIRST /= TREE_NIL LOOP						--| SUIVRE LA LISTE DU SEAU
      DECLARE
        SYM_T	: TREE		:= HEAD( HASH_LIST );				--| POINTEUR SYMBOL_REP
        TXT_T	: TREE		:= DABS( 1, SYM_T );				--| LE POINTEUR TXTREP AU NOEUD CONTENANT LE TEXTE
      BEGIN
        IF DABS( 0, TXT_T ).NSIZ = NB_TREES THEN						--| SI LA LONGUEUR DU BLOC CORRESPOND A CELLE DU CONVERTI
          DECLARE
            IS_MATCH	: BOOLEAN		:= TRUE;					--| SUPPOSER QUE CELA VA MARCHER
            START		: LINE_IDX	:= TXT_T.LN;				--| INDICE DE L'ENTETE DU BLOC CONTENANT LE TEXTE A TESTER
            RPG_RP		: RPG_DATA RENAMES PAG( CUR_RP );				--| LA PAGE CONCERNEE
          BEGIN
            FOR I IN 1 .. NB_TREES LOOP							--| POUR TOUS LES TREES COUVRANT LE TEXTE
              IF TTR( I ) /=  RPG_RP.DATA.ALL( START+I ) THEN				--| DEUX MORCEAUX DE TEXTE DIFFERENTS
                IS_MATCH := FALSE;							--| DESACCORD
                EXIT;
              END IF;
            END LOOP;
                     
            IF IS_MATCH THEN								--| ACCORD
              RETURN SYM_T;								--| RETOURNER LE SYMBOLE TROUVE
            END IF;
          END;
        END IF;
        HASH_LIST := TAIL( HASH_LIST );							--| CONTINUER SUR LE RESTE DE LA LISTE
      END;
    END LOOP;
    RETURN (HI, NOTY=> DN_NUM_VAL, ABSS=> 0, NSIZ=> BUCKET  );				--| RETOURNER LE SEAU
  END;
END HASH_SEARCH;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION STORE_SYM
--|
FUNCTION STORE_SYM ( S :STRING ) RETURN TREE IS						--| INSERE UN SYMBOLE ACCESSIBLE A LA RECHERCHE
  TR		: TREE		:= HASH_SEARCH( S );
BEGIN
  IF TR.PT /= HI THEN								--| TROUVE LE SYMBOLE DEJA ENTRE
    RETURN TR;
  ELSE
    DECLARE
      SYMREP : TREE := MAKE ( DN_SYMBOL_REP,
			NB_ATTR=> N_SPEC( DN_SYMBOL_REP ).NS_SIZE, AR=> 8 );
    BEGIN
      DABS ( 1, SYMREP, STORE_TEXT ( S ) );						--| LE TEXTE REPRESENTATIF EN PREMIER CHAMP
      DABS ( 2, SYMREP, TREE_NIL );							--| RIEN EN SECOND CHAMP
      DECLARE
        T_SEQ : SEQ_TYPE := ( FIRST=> DABS( TR.NSIZ, TREE_HASH ) , NEXT=> TREE_NIL );
      BEGIN
        T_SEQ := INSERT( T_SEQ, SYMREP );
        DABS( TR.NSIZ, TREE_HASH, T_SEQ.FIRST );
      END;
      RETURN SYMREP;
    END;
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION FIND_SYM
--|
FUNCTION FIND_SYM ( S :STRING ) RETURN TREE IS
  T		: TREE		:= HASH_SEARCH ( S );
BEGIN
  IF T.PT = HI THEN									--| TROUVE LE BUCKET MAIS PAS LE SYMBOLE
    T := TREE_VOID;									--| RETOURNE RIEN
  ELSIF T.TY /= DN_SYMBOL_REP THEN							--| HASH_SEARCH DOIT RETOURNER UN SYMREP
    PUT_LINE ( "IDL.IDL_MAN.FIND_SYM : HASHSEARCH A TROUVE UN NON SYMBOLE " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;
  RETURN T;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE_SOURCE_POSITION
--|
FUNCTION MAKE_SOURCE_POSITION ( T: TREE; COL :SRCCOL_IDX ) RETURN TREE IS			--| FABRIQUE UN ELEMENT S CONTENANT LA COLONNE AVEC UN POINTEUR DE LIGNE
BEGIN
  IF T.TY = DN_SOURCELINE THEN							--| POINTEUR DE SOURCE_LINE
    RETURN (S, COL=> COL, SPG=> T.PG, SLN=> T.LN );
  ELSE										--| SINON ERREUR
    PUT_LINE ( "IDL.IDL_MAN.MAKE_SOURCE_POSITION : T N'EST PAS UN SOURCE_LINE, C'EST " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION GET_SOURCE_LINE
--|
FUNCTION GET_SOURCE_LINE ( T :TREE ) RETURN TREE IS					--| RAMENE LE POINTEUR DE LIGNE ASSOCIE A UN ELEMENT S
BEGIN
  IF T.PT = S THEN
    RETURN (P, TY=> DN_SOURCELINE, PG=> T.SPG, LN=> T.SLN );
  ELSE
    PUT_LINE ( "IDL.IDL_MAN.GET_SOURCE_LINE : POSITION ERRONEE, NOEUD " & NODE_REP ( T ) );
    RAISE PROGRAM_ERROR;
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION GET_SOURCE_COL
--|
FUNCTION GET_SOURCE_COL ( T :TREE ) RETURN SRCCOL_IDX IS
BEGIN
  RETURN T.COL;
END;
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE EMIT_ERROR
--|
PROCEDURE EMIT_ERROR ( SP_ARG :TREE; MSG :STRING ) IS
  SP		: TREE		:= SP_ARG;
  SRC_LIN		: TREE;
  ERR_NOD		: TREE		:= MAKE( DN_ERROR );
BEGIN
  IF SP.PT /= S THEN								--| NOEUD STRUCTUREL
    SP := D( LX_SRCPOS, SP );								--| REMPLACER SP PAR L'ATTRIBUT LX_SRCPOS
  END IF;
         
  D( XD_SRCPOS, ERR_NOD, SP );							--| POSITION DANS CHAMP 1
  D( XD_TEXT,   ERR_NOD, STORE_TEXT( MSG ) );						--| MESSAGE DANS CHAMP 2
  SRC_LIN := GET_SOURCE_LINE( SP );							--| 
  LIST( SRC_LIN, (APPEND( LIST( SRC_LIN ), ERR_NOD)) );					--| AJOUTER EN FIN LE NOEUD ERREUR

  PUT_LINE( POSITIVE_SHORT'IMAGE ( D( XD_NUMBER, SRC_LIN ).ABSS ) & ": " & MSG );		--| AFFICHAGE DU No DE LIGNE ET DE L'ERREUR
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE ERROR
--|
PROCEDURE ERROR ( T :TREE; MSG :STRING ) IS
  ERR_CNT		: TREE;
BEGIN
  IF PRAGMA_CONTEXT /= TREE_VOID THEN
    DABS( 3, PRAGMA_CONTEXT, TREE_VOID );
    WARNING( T, MSG );
            
  ELSE
    EMIT_ERROR ( T, MSG );
    ERR_CNT := D( XD_ERR_COUNT, TREE_ROOT );
    ERR_CNT.ABSS := ERR_CNT.ABSS + 1;
    D( XD_ERR_COUNT, TREE_ROOT, ERR_CNT );
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE WARNING
--|
PROCEDURE WARNING ( T :TREE; MSG :STRING ) IS
BEGIN
  EMIT_ERROR ( T, "(W) " & MSG );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE
--|
FUNCTION MAKE ( NN :NODE_NAME; NB_ATTR :ATTR_NBR; AR :AREA_IDX ) RETURN TREE IS
  FREE_IDX	: LINE_NBR		:= AREA( AR ).FREE_LINE;			--| EMPLACEMENT UTILISABLE
  NB_FREE		: LINE_NBR		:= LINE_NBR( LINE_IDX'LAST ) - FREE_IDX + 1;	--| NB EMPLACEMENTS LIBRES
  NB_REQUIS	: LINE_NBR		:= LINE_NBR( NB_ATTR ) + 1;			--| NB EMPLACEMENTS DEMANDES (ENTETE+ATTRIBUTS)
BEGIN
--  IF NB_REQUIS > NB_FREE THEN								--| IL N'Y A PAS ASSEZ DE PLACE
    ALLOC_PAGE ( AR, NB_REQUIS );							--| DEMANDER UNE PLACE
    FREE_IDX := AREA( AR ).FREE_LINE;							--| NOMBRE DE LIGNES UTILISEES DANS CETTE PAGE
--  END IF;
  CUR_VP := AREA( AR ).VP;								--| No DE PAGE VIRTUELLE DU LIEU D'INSERTION
  CUR_RP := ASSOC_PAGE( CUR_VP );							--| No DE PAGE PHYSIQUE ASSOCIEE
  AREA( AR ).FREE_LINE := FREE_IDX + NB_REQUIS;						--| NOMBRE DE LIGNES OCCUPEES : AJOUTER NB_ATTR + 1 POUR L'ENTETE
  PAG( CUR_RP ).DATA.ALL( LINE_IDX( FREE_IDX ) ) := (HI, NOTY=> NN, ABSS=> 0, NSIZ=> NB_ATTR );	--| ENTETE DU NOEUD (TYPE ET NB D'ATTRIBUTS)
  PAG( CUR_RP ).CHANGED := TRUE;
  RETURN (P, TY=> NN, PG=> AREA( AR ).VP, LN=> LINE_IDX( FREE_IDX ) );			--| RETOUR DU POINTEUR

exception
  when CONSTRAINT_ERROR =>
    PUT_LINE( "CONSTRAINT_ERROR idl_man.make"
	& " vp=" & VPG_IDX'IMAGE( CUR_VP )
	& " rp=" & RPG_IDX'IMAGE( ASSOC_PAGE( CUR_VP ) ) & " area=" & AREA_IDX'IMAGE( AR ) );
    raise;
    return TREE_NIL;
END MAKE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE
--|
FUNCTION MAKE ( NN :NODE_NAME; NB_ATTR: ATTR_NBR ) RETURN TREE IS
BEGIN
  RETURN MAKE ( NN, NB_ATTR, AR=> 1 );
END MAKE;      
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION LAST_BLOCK
--|
FUNCTION LAST_BLOCK RETURN VPG_IDX IS
BEGIN
  RETURN HIGH_VPG;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION PRINT_NAME
--|
FUNCTION PRINT_NAME ( PG :VPG_IDX; LN :LINE_IDX ) RETURN STRING IS
BEGIN
  RETURN PRINT_NAME ( (P, TY=> DN_TXTREP, PG=> PG, LN=> LN ) );
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION INT_IMAGE_NOBLANK
--|
FUNCTION INT_IMAGE_NOBLANK ( V :INTEGER ) RETURN STRING IS
  IM		: CONSTANT STRING		:= INTEGER'IMAGE( V );			--| FABRIQUER L'IMAGE DU NOMBRE
BEGIN
  IF V >= 0 THEN									--| VALEUR POSITIVE (IL Y A UN BLANC A LA PLACE DU SIGNE)
    RETURN IM( 2..IM'LENGTH );							--| RENVOYER L'IMAGE SANS BLANC
  ELSE										--| VALEUR NEGATIVE
    RETURN IM;									--| RENVOYER L'IMAGE (QUI A LE SIGNE - INCLUS)
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION NODE_REP
--|
FUNCTION NODE_REP ( T :TREE ) RETURN STRING IS
         
  FUNCTION NODE_NAME_IMAGE RETURN STRING IS
  BEGIN
    RETURN '{' & NODE_NAME'IMAGE ( T.TY ) & '}';
  END;
         
BEGIN
  CASE T.PT IS
  WHEN HI =>
    RETURN '['	& NODE_NAME'IMAGE ( T.NOTY )
		& " NSIZ=" & ATTR_NBR'IMAGE( T.NSIZ )
		& " ABSS=" & POSITIVE_SHORT'IMAGE( T.ABSS )	& ']' ;

  WHEN S =>
    RETURN "[COL="	& SRCCOL_IDX'IMAGE( T.COL )
		& " <" & PAGE_IDX'IMAGE( T.SPG ) & '.' & LINE_IDX'IMAGE( T.SLN ) & '>';
  WHEN P | L =>

    IF T = TREE_VIRGIN THEN RETURN "[___]"; END IF;

    RETURN '['	& NODE_NAME'IMAGE(T.TY)
		& '<' & INT_IMAGE_NOBLANK ( INTEGER( T.PG ) )
		& '.' & INT_IMAGE_NOBLANK ( INTEGER( T.LN ) ) & "]>";
  END CASE;
END NODE_REP;
   
--|-------------------------------------------------------------------------------------------------
END IDL_MAN;
