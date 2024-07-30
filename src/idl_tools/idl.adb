WITH SYSTEM, UNCHECKED_CONVERSION;
WITH TEXT_IO;
USE  TEXT_IO;
--|-------------------------------------------------------------------------------------------------
--|		IDL SPECIALISE POUR LECTURE ET MISE EN ARBRE "IST" (IDL STRUCTURE TREE) DE TOUT FICHIER IDL
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY IDL IS
   
  DEBUG		: BOOLEAN		:= FALSE;						--| POSITIONNE PAR LE "PRAGMA DEBUG;" (VOIR PRA_WALK)
   
  TREE_VIRGIN	: CONSTANT TREE	:= (P, TY => DN_VIRGIN, PG => 0, LN => 0);		--| POINTEUR NON INITIALISE
   
  PACKAGE INT_IO	IS NEW INTEGER_IO ( INTEGER );					--| POUR L'IO D'ENTIERS
   
  --|-----------------------------------------------------------------------------------------------
  --|		PAGE_MANAGER
  --|-----------------------------------------------------------------------------------------------
  PACKAGE PAGE_MAN IS

    MAX_VPG			: CONSTANT PAGE_IDX	:= PAGE_IDX'LAST;			--| PAGES VIRTUELLES (N° DE PAGES PHYSIQUES)
    SUBTYPE VPG_IDX			IS PAGE_IDX RANGE 0 .. MAX_VPG;
    SUBTYPE VPG_NUM			IS VPG_IDX  RANGE 1 .. MAX_VPG;

    MAX_RPG			: CONSTANT	:= 2000;				--| PAGES PHYSIQUES (REELLES)
    TYPE RPG_IDX			IS NEW INTEGER RANGE 0 .. MAX_RPG; 			--|
    SUBTYPE RPG_NUM			IS RPG_IDX     RANGE 1 .. MAX_RPG;

    MAX_AREA			: CONSTANT	:= 10;				--| POINTS D'INSERTION
    TYPE AREA_IDX			IS NEW INTEGER RANGE 0 .. MAX_AREA;
    SUBTYPE AREA_NUM		IS AREA_IDX    RANGE 1 .. MAX_AREA;

    ASSOC_PAGE			: ARRAY( VPG_NUM ) OF RPG_IDX		:= (OTHERS=> 0);	--| TABLE DES N° DE PAGES PHYSIQUES (OU LEUR NEGATIF SI PHYSIQUE FLOTTANTE) ASSOCIEES AUX VIRTUELLES
    CUR_VP			: VPG_NUM;					--| PAGE VIRTUELLE COURANTE
    CUR_RP			: RPG_NUM;					--| PAGE PHYSIQUE COURANTE
    HIGH_VPG			: VPG_IDX;					--| DERNIÈRE PAGE VIRTUELLE

    PROCEDURE CREATE_PAGE_MANAGER	( PAGE_FILE_NAME :STRING );				--| CREATION D'UN FICHIER DE PAGINATION
    PROCEDURE OPEN_PAGE_MANAGER	( PAGE_FILE_NAME :STRING );				--| OUVERTURE D'UN FICHIER DE PAGINATION EXISTANT
    FUNCTION  READ_PAGE		( VP :VPG_NUM )			RETURN RPG_NUM;	--| DONNE LA PAGE PHYSIQUE D'UNE VIRTUELLE
    PROCEDURE NEW_BLOCK;								--| FORCERA L ALLOCATION D UN NOUVEAU BLOC
    PROCEDURE ALLOC_PAGE		( AR :AREA_IDX; REQUESTED_SIZE :LINE_NBR );
    PROCEDURE CLOSE_PAGE_MANAGER;							--| FERMETURE DU FICHIER DE PAGINATION


    TYPE SECTOR		IS ARRAY( LINE_IDX ) OF TREE;					--| TREE DE 0 A 127
    TYPE A_SECTOR		IS ACCESS SECTOR;

    TYPE RPG_DATA		IS RECORD							--| DONNEES GESTION PAGE REELLE
			  VP		: VPG_IDX;				--| PAGE VIRTUELLE ASSOCIEE (0 SI PAS ASSOCIEE)
			  AREA		: AREA_IDX;
			  CHANGED		: BOOLEAN;
			  RECUPERABLE	: BOOLEAN;
			  DATA		: A_SECTOR;
			END RECORD;
    PAG			: ARRAY( RPG_NUM ) OF RPG_DATA				--| TABLE DE PAGES REELLES
         			:= (OTHERS=> (	VP		=> 0,			--| NON LIEE
         					AREA		=> 0,
         					CHANGED		=> FALSE,
					RECUPERABLE	=> TRUE,
         					DATA		=> NEW SECTOR )
         			);

    TYPE AREA_DATA		IS RECORD							--| MARQUE DE POINT D'INSERTION
			  VP		: VPG_IDX;				--| PAGE VIRTUELLE D'INSERTION
			  FREE_LINE	: LINE_NBR;				--| LIGNE D'INSERTION
			END RECORD;
      
    AREA			: ARRAY (AREA_NUM) OF AREA_DATA
         			:= (OTHERS=> (	VP		=> 0,
         					FREE_LINE		=> LINE_NBR'LAST		--| INITIALISE AINSI POUR FORCER UNE ALLOC AU DEPART
         					)
         			);

  --|-----------------------------------------------------------------------------------------------
  END PAGE_MAN;
  USE PAGE_MAN;
   
   
   
   
   
  --|-----------------------------------------------------------------------------------------------
  --|		IDL_MAN
  --|-----------------------------------------------------------------------------------------------
  PACKAGE IDL_MAN IS
      
    TYPE ARITIES		IS (NULLARY, UNARY, BINARY, TERNARY, ARBITRARY);
      
    TREE_FALSE		: CONSTANT TREE	:= (P, TY => DN_FALSE, PG => 0, LN => 0);
    TREE_TRUE		: CONSTANT TREE	:= (P, TY => DN_TRUE,  PG => 0, LN => 0);
    TREE_VOID		: CONSTANT TREE	:= (P, TY => DN_VOID,  PG => 0, LN => 0);
    TREE_ROOT		: CONSTANT TREE	:= (P, TY => DN_ROOT,  PG => 1, LN => 0);
      
    TREE_BINARY_ZERO	: CONSTANT TREE	:= (P, TY => NODE_NAME'VAL(0), PG => 0, LN => 0);
      
    PRAGMA_CONTEXT		: TREE		:= TREE_VOID;
      
    FUNCTION  ARITY		( T :TREE )			RETURN ARITIES;
    FUNCTION  SON_1		( T :TREE )			RETURN TREE;
    PROCEDURE SON_1		( T :TREE; V :TREE );
    FUNCTION  SON_2		( T :TREE )			RETURN TREE;
    PROCEDURE SON_2		( T :TREE; V :TREE );
    FUNCTION  SON_3		( T :TREE )			RETURN TREE;
    PROCEDURE SON_3		( T :TREE; V :TREE );
      
    FUNCTION  HEAD		( S :SEQ_TYPE )			RETURN TREE;
    FUNCTION  TAIL		( S :SEQ_TYPE )			RETURN SEQ_TYPE;
    FUNCTION  INSERT	( S :SEQ_TYPE; T :TREE )		RETURN SEQ_TYPE;
    FUNCTION  APPEND	( S :SEQ_TYPE; T :TREE )		RETURN SEQ_TYPE;
    FUNCTION  SINGLETON	( T :TREE )			RETURN SEQ_TYPE;
      
    PROCEDURE LIST		( T :TREE; S :SEQ_TYPE );

    PROCEDURE DABS		( RANG :ATTR_NBR; T :TREE; VAL :TREE );				--| ACCES ATTRIBUT PAR RANG
    FUNCTION  DABS		( RANG :ATTR_NBR; T :TREE )		RETURN TREE;
      
    FUNCTION  STORE_TEXT	( S :STRING )			RETURN TREE;		--| REND UN TXTREP
    FUNCTION  STORE_SYM	( S :STRING )			RETURN TREE;
    FUNCTION  FIND_SYM	( S :STRING )			RETURN TREE;		--| REND TREE_VOID SI ABSENT
      
    FUNCTION  MAKE_SOURCE_POSITION	( T :TREE; COL :SRCCOL_IDX )	RETURN TREE;
    FUNCTION  GET_SOURCE_LINE		( T :TREE )		RETURN TREE;
    FUNCTION  GET_SOURCE_COL		( T :TREE )		RETURN SRCCOL_IDX;
    PROCEDURE ERROR			( T :TREE; MSG : STRING);
    PROCEDURE WARNING		( T :TREE; MSG : STRING);
      
    FUNCTION  MAKE		( NN :NODE_NAME; NB_ATTR :ATTR_NBR; AR :AREA_IDX ) RETURN TREE;
    FUNCTION  MAKE		( NN :NODE_NAME; NB_ATTR: ATTR_NBR )		 RETURN TREE;	--| POUR LE LIEU D'INSERTION 1
    FUNCTION  LAST_BLOCK					RETURN VPG_IDX;		--| DERNIERE PAGE VIRTUELLE
      
    FUNCTION  PRINT_NAME	( PG :VPG_IDX; LN :LINE_IDX )		RETURN STRING;
    FUNCTION  NODE_REP	( T :TREE )			RETURN STRING;
      
  --|-----------------------------------------------------------------------------------------------
  END IDL_MAN;
  USE IDL_MAN;





  --|-----------------------------------------------------------------------------------------------
  --|		IDL_TBL
  --|-----------------------------------------------------------------------------------------------
  PACKAGE IDL_TBL IS
      
    MAX_NODE_ATTR		: CONSTANT	:= 820;					--| NOMBRE MAX DE MENTIONS D'ATRIBUTS DANS TOUS LES NOEUDS
         
    TYPE NODE_SPECIF	IS RECORD							--| SPECIF DE NOEUD
			  NS_SIZE		: ATTR_NBR;				--| NOMBRE D'ATTRIBUTS
			  NS_FIRST_A	: INTEGER;
			  NS_ARITY	: ARITIES;				--| ARITE DU NOEUD
			END RECORD;
    TYPE NODE_SPECIF_TABLE	IS ARRAY (NODE_NAME) OF NODE_SPECIF;				--| TABLE DES SPECIFS DE NOEUDS
      
    TYPE ATTR_SPECIF	IS RECORD
			  ATTR		: ATTRIBUTE_NAME;
			  IS_LIST		: BOOLEAN;
			END RECORD;
    TYPE ATTR_ID_TABLE	IS ARRAY (1 .. MAX_NODE_ATTR) OF ATTR_SPECIF;			--| TABLE DE TOUS LES N° D'ATTRIBUTS DE TOUS LES NOEUDS
      
    TYPE DIANA_TABLE_TYPE	IS RECORD
			  TB_LAST_NODE		: INTEGER;
			  TB_LAST_ATTR		: INTEGER;
			  TB_LAST_NODE_ATTR		: INTEGER;
			  TB_N_SPEC		: NODE_SPECIF_TABLE;		--| TABLE DES SPECIFS NOEUD
			  TB_A_SPEC		: ATTR_ID_TABLE;			--| TABLE DES N° DE TOUS LES ATTRIBUTS DE TOUS LES NOUEDS
			END RECORD;
      
    DIANA_TABLE_AREA	: DIANA_TABLE_TYPE;
      
    LAST_NODE		: INTEGER		RENAMES DIANA_TABLE_AREA.TB_LAST_NODE;
    LAST_ATTR		: INTEGER		RENAMES DIANA_TABLE_AREA.TB_LAST_ATTR;
    LAST_NODE_ATTR		: INTEGER		RENAMES DIANA_TABLE_AREA.TB_LAST_NODE_ATTR;
    N_SPEC		: NODE_SPECIF_TABLE		RENAMES DIANA_TABLE_AREA.TB_N_SPEC;
    A_SPEC		: ATTR_ID_TABLE		RENAMES DIANA_TABLE_AREA.TB_A_SPEC;
      
    PROCEDURE INIT_SPEC	( SPEC_FILE :STRING );					--| LECTURE DE LA TABLE À PARTIR DU FICHIER SPEC_FILE.TBL
    PROCEDURE WRITE_SPEC	( SPEC_FILE :STRING );					--| ECRITURE DE LA TABLE EN BINAIRE DANS LE FICHIER SPEC_FILE.BIN
    PROCEDURE READ_SPEC	( SPEC_FILE :STRING );					--| LECTRE DE LA TABLE À PARTIR D'UN FICHIER SPEC_FILE.BIN
      
  --|-----------------------------------------------------------------------------------------------
  END IDL_TBL;
  USE IDL_TBL;
      
  PACKAGE BODY PAGE_MAN		IS SEPARATE;
  PACKAGE BODY IDL_TBL		IS SEPARATE;
  PACKAGE BODY IDL_MAN		IS SEPARATE;
   
   
   

   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE CREATE_IDL_TREE_FILE
--|
PROCEDURE CREATE_IDL_TREE_FILE ( PAGE_FILE_NAME :STRING ) IS				--| CREATION FICHIER DE PAGES D ARBRE IDL STRUCTURE TREE (IST)
BEGIN
  BEGIN
    READ_SPEC( "./tbl/idl" );
  EXCEPTION
    WHEN NAME_ERROR =>								--| OUVERTURE DU FICHIER .TBL
      INIT_SPEC ( "./tbl/idl" );
      WRITE_SPEC( "./tbl/idl" );							--| ECRITURE DU .BIN
  END;

  PAGE_MAN.CREATE_PAGE_MANAGER ( PAGE_FILE_NAME );
		--|
		--|		INSTALLATION NOEUD RACINE
		--|         
  DECLARE
    ROOT		: TREE		:= MAKE ( DN_ROOT, NB_ATTR=> 5, AR=> 1 );		--| UN NOEUD A 5 ATTRIBUTS AU POINT INSERTION 1
  BEGIN
    DI( XD_HIGH_PAGE,   ROOT, 1 );							--| xd_high_page : DERNIERE PAGE VIRTUELLE
    D ( XD_SOURCE_LIST, ROOT, TREE_NIL );						--| xd_source_list : LISTE DE SOURCES
    DI( XD_ERR_COUNT,   ROOT, 0 );							--| xd_err_count : NOMBRE D'ERREURS
  END;
		--|
		--|		INSTALLATION LISTE DE HACHAGE
		--|         
  DECLARE
    NB		: LINE_IDX	:= LINE_IDX'LAST;
    T		: TREE		:= MAKE ( DN_HASH, NB_ATTR=> NB, AR=> 2 );		--| LISTE DE HACHAGE
  BEGIN
    FOR I IN 1 .. LINE_IDX'LAST LOOP
      DABS ( I, T, TREE_NIL );							--| INITIALISER AVEC DES NIL
    END LOOP;
  END;
         
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE OPEN_IDL_TREE_FILE
--|
PROCEDURE OPEN_IDL_TREE_FILE ( PAGE_FILE_NAME :STRING ) IS
BEGIN
  PAGE_MAN.OPEN_PAGE_MANAGER ( PAGE_FILE_NAME );
  READ_SPEC ( "./tbl/idl" );								--| OUVERTURE DU FICHIER IDL.BIN
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE CLOSE_IDL_TREE_FILE
--|
PROCEDURE CLOSE_IDL_TREE_FILE IS
BEGIN
  PAGE_MAN.CLOSE_PAGE_MANAGER;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE
--|
FUNCTION MAKE ( NN :NODE_NAME ) RETURN TREE IS
BEGIN
  IF IDL_TBL.N_SPEC( NN ).NS_SIZE = 0 THEN						--| TYPE DE NOEUD SANS ATTRIBUT
    RETURN (P, TY=> NN, PG=> 0, LN=> 0 );						--| TY 0 1 : FORMAT DU NOEUD SANS ATTRIBUT
  ELSE										--| NOEUD AVEC ATTRIBUTS EN NOMBRE NS_SIZE
    RETURN MAKE( NN, N_SPEC( NN ).NS_SIZE, 1 );						--| TYP TAILLE LIGNE
  END IF;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		 PROCEDURE D
--|
PROCEDURE D ( AN :ATTRIBUTE_NAME; T :TREE; V :TREE ) IS
  APOS		: INTEGER := N_SPEC( T.TY ).NS_FIRST_A;					--| INDICE DE PREMIER ATTRIBUT DANS LA TABLE DE TOUS LES ATTRIBUTS DE TOUS LES NOEUDS
BEGIN
  FOR I IN 1 .. N_SPEC( T.TY ).NS_SIZE LOOP						--| BALAYAGE SUR LES ATTRIBUTS DU NOEUD POINTE PAR T
    IF A_SPEC( APOS ).ATTR = AN THEN							--| SI C'EST L'ATTRIBUT CHERCHE
      DABS( I, T, V );								--| REMPLIR LE CHAMP
      RETURN;
    END IF;
    APOS := APOS + 1;								--| MONTER AU CHAMP SUIVANT
  END LOOP;
  PUT_LINE( "!! PROCEDURE D : PAS D ATTRIBUT " & ATTR_IMAGE( AN ) & " DANS " & NODE_REP( T ) );	--| L'ATTRIBUT N'A PA S ETE TROUVE POUR LE NOEUD
  RAISE PROGRAM_ERROR;								--| ERREUR
END D;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION D
--|
FUNCTION D ( AN :ATTRIBUTE_NAME; T :TREE ) RETURN TREE IS
  APOS		: INTEGER := N_SPEC( T.TY ).NS_FIRST_A;					--| INDICE DE PREMIER ATTRIBUT DANS LA TABLE DE TOUS LES ATTRIBUTS DE TOUS LES NOEUDS
BEGIN
  FOR I IN 1 .. N_SPEC( T.TY ).NS_SIZE LOOP						--| BALAYAGE SUR LES ATTRIBUTS DU NOEUD POINTE PAR T
    IF A_SPEC( APOS ).ATTR = AN THEN							--| SI C'EST L'ATTRIBUT CHERCHE
      RETURN DABS( I, T );								--| RENDRE LE CHAMP
    END IF;
    APOS := APOS + 1;								--| MONTER AU CHAMP SUIVANT
  END LOOP;
  PUT_LINE( "!! FUNCTION D : PAS D ATTRIBUT " & ATTR_IMAGE( AN ) & " DANS " & NODE_REP( T ) );	--| L'ATTRIBUT N'A PA S ETE TROUVE POUR LE NOEUD
  RAISE PROGRAM_ERROR;								--| ERREUR
END D;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE DB
--|
PROCEDURE DB ( AN :ATTRIBUTE_NAME; T :TREE; V :BOOLEAN ) IS
  VAL		: TREE		:= TREE_FALSE;					--| VALEUR ARBRE À PLACER (INITIALISEE À FAUX)
BEGIN
  IF V THEN
    VAL := TREE_TRUE;								--| SI VALEUR VRAI À PLACER, CHANGER VAL À VALEUR VRAIE
  END IF;
  D( AN, T, VAL );									--| PLACER VAL DANS L'ATTRIBUT
END DB;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION DB
--|
FUNCTION DB ( AN :ATTRIBUTE_NAME; T :TREE ) RETURN BOOLEAN IS
  A	: TREE	:= D( AN, T );
BEGIN
  IF A = TREE_TRUE THEN RETURN TRUE;
  ELSIF A = TREE_FALSE THEN RETURN FALSE;
  ELSE
    PUT_LINE( "!! L ATTRIBUT " & ATTR_IMAGE( AN ) & " DU NOEUD " & NODE_REP( T ) & " N EST PAS UN BOOLEEN");
    RAISE PROGRAM_ERROR;
  END IF;
END DB;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE DI
--|
PROCEDURE DI ( AN :ATTRIBUTE_NAME; T :TREE; V :INTEGER) IS
  VAL_POS	: POSITIVE_SHORT;
  COMPLEMENT_DEUX	: ATTR_NBR;
BEGIN
  IF V < 0 THEN
    VAL_POS := POSITIVE_SHORT( ABS( V+1 ) ); COMPLEMENT_DEUX := 1;
  ELSE
    VAL_POS := POSITIVE_SHORT( V ); COMPLEMENT_DEUX := 0;
  END IF;
  D( AN, T, (HI, NOTY=> DN_NUM_VAL, ABSS=> VAL_POS, NSIZ=> COMPLEMENT_DEUX) );
END DI;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION DI
--|
FUNCTION DI ( AN :ATTRIBUTE_NAME; T :TREE) RETURN INTEGER IS
  ATTR		: TREE		:= D( AN, T );
BEGIN
  IF ATTR.PT = HI AND THEN ATTR.NOTY = DN_NUM_VAL THEN
    IF ATTR.NSIZ = 0 THEN
      RETURN INTEGER( ATTR.ABSS );
    ELSIF ATTR.NSIZ = 1 THEN
      RETURN INTEGER( -ATTR.ABSS - 1 );
    END IF;
  END IF;
  PUT_LINE( "!! L ATTRIBUT " & ATTR_IMAGE( AN ) & " DU NOEUD " & NODE_REP( T ) & " N EST PAS UN ENTIER");
  RAISE PROGRAM_ERROR;
END DI;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION LIST
--|
FUNCTION LIST ( T :TREE ) RETURN SEQ_TYPE IS
  A_IDX	: INTEGER := N_SPEC( T.TY ).NS_FIRST_A;
BEGIN
  FOR I IN 1 .. N_SPEC( T.TY ).NS_SIZE LOOP
    IF A_SPEC( A_IDX ).IS_LIST THEN
      RETURN (FIRST=> DABS ( I, T ) , NEXT=> TREE_NIL );
    END IF;
    A_IDX := A_IDX + 1;
  END LOOP;
         
  PUT_LINE( "!! IL N Y A PAS DE LISTE ASSOCIEE AU NOEUD " & NODE_REP( T ) );
  RAISE PROGRAM_ERROR;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION IS_EMPTY
--|
FUNCTION IS_EMPTY ( S :SEQ_TYPE ) RETURN BOOLEAN IS
BEGIN
  RETURN S.FIRST = TREE_NIL;
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 --|		PROCEDURE POP
--|
PROCEDURE POP ( S :IN OUT SEQ_TYPE; T :OUT TREE ) IS
BEGIN
  T := HEAD( S );
  S := TAIL( S );
END POP;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION PRINT_NAME
--|
FUNCTION PRINT_NAME ( T :TREE ) RETURN STRING IS						--| POUR TXTREP OR SYMBOL_REP
  TR		: TREE := T;
BEGIN
  IF TR.TY = DN_SYMBOL_REP THEN							--| POUR UN SYMBOL_REP
    TR := DABS( 1, TR );								--| PRENDRE LE TXTREP CORRRESPONDANT
  END IF;
         
  IF TR.TY /= DN_TXTREP THEN								--| SI CE N'EST PAS UN TXTREP
    RETURN "PAS UN TXTREP PAS DE CHAINE ???";						--| CHAINE PAS DE NOM
  END IF;
         
  DECLARE
    TXT_HDR		: TREE		:= DABS( 0, TR );				--| PRENDRE L'ENTETE DU BLOC DE CHAINE
    USE SYSTEM;
    START			: LINE_IDX	:= TR.LN+1;				--| EMPLACEMENT DU PREMIER TREE COMPRENANT LE NOM
    NB_TREES		: LINE_IDX	:= LINE_IDX( TXT_HDR.NSIZ );			--| NOMBRE DE TREES COMPRENANT LE NOM
    NB_CARS		: NATURAL		:= NATURAL( NB_TREES )*(TREE'SIZE+STORAGE_UNIT-1)/STORAGE_UNIT;
    TYPE SUITE_TREES	IS ARRAY( START .. START-1+NB_TREES ) OF TREE;
    SUBTYPE CHN		IS STRING( 1 .. NB_CARS );
    FUNCTION TO_CHN	IS NEW UNCHECKED_CONVERSION( SUITE_TREES, CHN );
    THE_CHN		: CHN;
  BEGIN
    THE_CHN := TO_CHN( SUITE_TREES( PAG( CUR_RP ).DATA.ALL( START..START-1+NB_TREES ) ) );
    RETURN THE_CHN( 2..1+NATURAL( CHARACTER'POS( THE_CHN( 1 ) ) ) );
  END;
         
END PRINT_NAME;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION NODE_IMAGE
--|
FUNCTION NODE_IMAGE ( NN :NODE_NAME ) RETURN STRING IS
BEGIN
  RETURN NODE_NAME'IMAGE( NN );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION ATTR_IMAGE
--|
FUNCTION ATTR_IMAGE ( AN :ATTRIBUTE_NAME ) RETURN STRING IS
BEGIN
  RETURN ATTRIBUTE_NAME'IMAGE( AN );
END;
    
  USE PRINT_NOD;
  PACKAGE BODY PRINT_NOD IS SEPARATE;
   
   
  PROCEDURE IDL_READ ( NOM_TEXTE :STRING )		IS SEPARATE;			--|
  PROCEDURE NAM_PUT  ( NOM_TEXTE :STRING )		IS SEPARATE;			--|
  PROCEDURE TBL_PUT  ( NOM_TEXTE :STRING )		IS SEPARATE;			--|
   
--|-------------------------------------------------------------------------------------------------
END IDL;
