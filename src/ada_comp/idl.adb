--	IDL.ADB	VINCENT MORIN	22/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2	3	4	5	6	7	8	9	0

with SYSTEM, UNCHECKED_CONVERSION;
with TEXT_IO;
use  TEXT_IO;
					---
	package body			IDL
is					---
   
  DEBUG		: BOOLEAN		:= FALSE;								--| POSITIONNE PAR LE "PRAGMA DEBUG;" (VOIR PRA_WALK)
   
  TREE_VIRGIN	: constant TREE	:= (P, TY => DN_VIRGIN, PG => 0, LN => 0);				--| POINTEUR NON INITIALISE
   
  package INT_IO	is new INTEGER_IO ( INTEGER ); 							--| POUR L'IO D'ENTIERS



		--------
  package		PAGE_MAN
  is		--------

    MAX_VPG			: constant PAGE_IDX	:= PAGE_IDX'LAST;					--| PAGES VIRTUELLES (N° DE PAGES PHYSIQUES)
    subtype VPG_IDX			is PAGE_IDX range 0 .. MAX_VPG;
    subtype VPG_NUM			is VPG_IDX  range 1 .. MAX_VPG;

    MAX_RPG			: constant	:= 50;						--| PAGES PHYSIQUES (REELLES)
    type RPG_IDX			is new INTEGER range 0 .. MAX_RPG; 					--|
    subtype RPG_NUM			is RPG_IDX     range 1 .. MAX_RPG;

    MAX_AREA			: constant	:= 10;						--| POINTS D'INSERTION
    type AREA_IDX			is new INTEGER range 0 .. MAX_AREA;
    subtype AREA_NUM		is AREA_IDX    range 1 .. MAX_AREA;

    ASSOC_PAGE			: array( VPG_NUM ) of RPG_IDX		:= (others=> 0);			--| TABLE DES N° DE PAGES PHYSIQUES (OU LEUR NEGATIF SI PHYSIQUE FLOTTANTE) ASSOCIEES AUX VIRTUELLES
    CUR_VP			: VPG_NUM;							--| PAGE VIRTUELLE COURANTE
    CUR_RP			: RPG_NUM;							--| PAGE PHYSIQUE COURANTE
    HIGH_VPG			: VPG_IDX;							--| DERNIERE PAGE VIRTUELLE

    procedure CREATE_PAGE_MANAGER	( PAGE_FILE_NAME :STRING );						--| CREATION D'UN FICHIER DE PAGINATION
    procedure OPEN_PAGE_MANAGER	( PAGE_FILE_NAME :STRING );						--| OUVERTURE D'UN FICHIER DE PAGINATION EXISTANT
    function  READ_PAGE		( VP :VPG_NUM )			return RPG_NUM;			--| DONNE LA PAGE PHYSIQUE D'UNE VIRTUELLE
    procedure NEW_BLOCK;										--| FORCERA L ALLOCATION D UN NOUVEAU BLOC
    procedure ALLOC_PAGE		( AR :AREA_IDX; REQUESTED_SIZE :LINE_NBR );
    procedure CLOSE_PAGE_MANAGER;									--| FERMETURE DU FICHIER DE PAGINATION
    procedure DELETE_PAGE_MANAGER;


    type SECTOR		is array( LINE_IDX ) of TREE;							--| TREE DE 0 A 127
    type A_SECTOR		is access SECTOR;

    type RPG_DATA		is record									--| DONNEES GESTION PAGE REELLE
			  VP		: VPG_IDX;						--| PAGE VIRTUELLE ASSOCIEE (0 SI PAS ASSOCIEE)
			  AREA		: AREA_IDX;
			  CHANGED		: BOOLEAN;
			  RECUPERABLE	: BOOLEAN;
			  DATA		: A_SECTOR;
			end record;
    PAG			: array( RPG_NUM ) of RPG_DATA;						--| TABLE DE PAGES REELLES

    type AREA_DATA		is record									--| MARQUE DE POINT D'INSERTION
			  VP		: VPG_IDX;						--| PAGE VIRTUELLE D'INSERTION
			  FREE_LINE	: LINE_NBR;						--| LIGNE D'INSERTION
			end record;
      
    AREA			: array (AREA_NUM) of AREA_DATA
         			:= (others=> (	VP		=> 0,
         					FREE_LINE		=> LINE_NBR'LAST				--| INITIALISE AINSI POUR FORCER UNE ALLOC AU DEPART
         				   )
         			   );

	--------
  end	PAGE_MAN;
	--------
  use PAGE_MAN;



		-------
  package		IDL_MAN
  is		-------
      
    type ARITIES		is (NULLARY, UNARY, BINARY, TERNARY, ARBITRARY);
      
    TREE_FALSE		: constant TREE	:= (HI, NOTY => DN_FALSE, ABSS => 0, NSIZ=> 0);
    TREE_TRUE		: constant TREE	:= (HI, NOTY => DN_TRUE,  ABSS => 1, NSIZ=> 0);
      
    TREE_BINARY_ZERO	: constant TREE	:= (P, TY => NODE_NAME'VAL(0), PG => 0, LN => 0);
      
    PRAGMA_CONTEXT		: TREE		:= TREE_VOID;
      
    function  ARITY			( T :TREE )			return ARITIES;
    function  SON_1			( T :TREE )			return TREE;
    procedure SON_1			( T :TREE; V :TREE );
    function  SON_2			( T :TREE )			return TREE;
    procedure SON_2			( T :TREE; V :TREE );
    function  SON_3			( T :TREE )			return TREE;
    procedure SON_3			( T :TREE; V :TREE );
      
    function  HEAD			( S :SEQ_TYPE )			return TREE;
    function  TAIL			( S :SEQ_TYPE )			return SEQ_TYPE;
    function  INSERT		( S :SEQ_TYPE; T :TREE )		return SEQ_TYPE;
    function  APPEND		( S :SEQ_TYPE; T :TREE )		return SEQ_TYPE;
    function  SINGLETON		( T :TREE )			return SEQ_TYPE;
      
    procedure LIST			( T :TREE; S :SEQ_TYPE );

    procedure DABS			( RANG :ATTR_NBR; T :TREE; VAL :TREE );					--| ACCES ATTRIBUT PAR RANG
    function  DABS			( RANG :ATTR_NBR; T :TREE )		return TREE;
      
    function  STORE_TEXT		( S :STRING )			return TREE;			--| REND UN TXTREP
    function  STORE_SYM		( S :STRING )			return TREE;
    function  FIND_SYM		( S :STRING )			return TREE;			--| REND TREE_VOID SI ABSENT
      
    function  MAKE_SOURCE_POSITION	( T :TREE; COL :SRCCOL_IDX )		return TREE;
    function  GET_SOURCE_LINE		( T :TREE )			return TREE;
    function  GET_SOURCE_COL		( T :TREE )			return SRCCOL_IDX;
    procedure ERROR			( T :TREE; MSG : STRING );
    procedure WARNING		( T :TREE; MSG : STRING );
      
    function  MAKE			( NN :NODE_NAME; NB_ATTR :ATTR_NBR;
				  AR :AREA_IDX )			return TREE;
    function  MAKE			( NN :NODE_NAME; NB_ATTR: ATTR_NBR )	return TREE;			--| POUR LE LIEU D'INSERTION 1
    function  LAST_BLOCK						return VPG_IDX;			--| DERNIERE PAGE VIRTUELLE
      
    function  PRINT_NAME		( PG :VPG_IDX; LN :LINE_IDX )		return STRING;
    function  NODE_REP		( T :TREE )			return STRING;
      
	-------
  end	IDL_MAN;
	-------
  use IDL_MAN;

      
      
		-------
  package		IDL_TBL
  is		-------
      
    MAX_NODE_ATTR		: constant	:= 1024;							--| NOMBRE MAX DE MENTIONS D'ATRIBUTS DANS TOUS LES NOEUDS
         
    type NODE_SPECIF	is record									--| SPECIF DE NOEUD
			  NS_SIZE		: ATTR_NBR;						--| NOMBRE D'ATTRIBUTS
			  NS_FIRST_A	: INTEGER;
			  NS_ARITY	: ARITIES;						--| ARITE DU NOEUD
			end record;
    type NODE_SPECIF_TABLE	is array (NODE_NAME) of NODE_SPECIF;						--| TABLE DES SPECIFS DE NOEUDS
      
    type ATTR_SPECIF	is record
			  ATTR		: ATTRIBUTE_NAME;
			  IS_LIST		: BOOLEAN;
			end record;
    type ATTR_ID_TABLE	is array (1 .. MAX_NODE_ATTR) of ATTR_SPECIF;					--| TABLE DE TOUS LES N° D'ATTRIBUTS DE TOUS LES NOEUDS
      
    type DIANA_TABLE_TYPE	is record
			  TB_LAST_NODE		: INTEGER;
			  TB_LAST_ATTR		: INTEGER;
			  TB_LAST_NODE_ATTR		: INTEGER;
			  TB_N_SPEC		: NODE_SPECIF_TABLE;				--| TABLE DES SPECIFS NOEUD
			  TB_A_SPEC		: ATTR_ID_TABLE;					--| TABLE DES N° DE TOUS LES ATTRIBUTS DE TOUS LES NOUEDS
			end record;
      
    DIANA_TABLE_AREA	: DIANA_TABLE_TYPE;
      
    LAST_NODE		: INTEGER			renames DIANA_TABLE_AREA.TB_LAST_NODE;
    LAST_ATTR		: INTEGER			renames DIANA_TABLE_AREA.TB_LAST_ATTR;
    LAST_NODE_ATTR		: INTEGER			renames DIANA_TABLE_AREA.TB_LAST_NODE_ATTR;
    N_SPEC		: NODE_SPECIF_TABLE		renames DIANA_TABLE_AREA.TB_N_SPEC;
    A_SPEC		: ATTR_ID_TABLE		renames DIANA_TABLE_AREA.TB_A_SPEC;
      
    procedure INIT_SPEC	( SPEC_FILE :STRING );							--| LECTURE DE LA TABLE À PARTIR DU FICHIER SPEC_FILE.TBL
    procedure WRITE_SPEC	( SPEC_FILE :STRING );							--| ECRITURE DE LA TABLE EN BINAIRE DANS LE FICHIER SPEC_FILE.BIN
    procedure READ_SPEC	( SPEC_FILE :STRING );							--| LECTRE DE LA TABLE À PARTIR D'UN FICHIER SPEC_FILE.BIN
      
	-------
  end	IDL_TBL;
	-------
  use IDL_TBL;


  package body PAGE_MAN		is separate;
  package body IDL_TBL		is separate;
  package body IDL_MAN		is separate;


			--------------------
  procedure		CREATE_IDL_TREE_FILE		( PAGE_FILE_NAME :STRING )
  is			--------------------
  begin

    begin
      READ_SPEC( "diana" );
    exception
      when NAME_ERROR =>										--| OUVERTURE DU FICHIER .TBL
        INIT_SPEC ( "diana" );
        WRITE_SPEC( "diana" );									--| ECRITURE DU .BIN
    end;

    PAGE_MAN.CREATE_PAGE_MANAGER( PAGE_FILE_NAME );
 		--|
		--|		INSTALLATION NOEUD RACINE
		--|         
    declare
      ROOT	: TREE	:= MAKE( DN_ROOT, NB_ATTR=>5, AR=> 1 );
    begin
      DI( XD_HIGH_PAGE,   ROOT, 1 );									--| xd_high_page : DERNIERE PAGE VIRTUELLE
      D ( XD_SOURCE_LIST, ROOT, TREE_NIL );								--| xd_source_list : LISTE DE SOURCES
      DI( XD_ERR_COUNT,   ROOT, 0 );									--| xd_err_count : NOMBRE D'ERREURS
    end;
		--|
		--|		INSTALLATION LISTE DE HACHAGE
		--|         
    declare
      NB		: LINE_IDX	:= LINE_IDX'LAST;
      T		: TREE		:= MAKE( DN_HASH, NB_ATTR=> NB, AR=> 2 );				--| LISTE DE HACHAGE
    begin
      for I in 1 .. LINE_IDX'LAST loop
        DABS( I, T, TREE_NIL );									--| INITIALISER AVEC DES NIL
      end loop;
    end;

  --| IL FAUT QUE CECI SOIT AU DEBUT AU MEME LIEU ET EN MEME PLACE QUE DANS LE GENERATEUR DE TABLE PARSE

    declare
      DUMMY	: TREE;
    begin
      DUMMY := STORE_SYM( """AND""" );
      DUMMY := STORE_SYM( """OR"""  );
      DUMMY := STORE_SYM( """XOR""" );
      DUMMY := STORE_SYM( """="""   );
      DUMMY := STORE_SYM( """/="""  );
      DUMMY := STORE_SYM( """<"""   );
      DUMMY := STORE_SYM( """<="""  );
      DUMMY := STORE_SYM( """>"""   );
      DUMMY := STORE_SYM( """>="""  );
      DUMMY := STORE_SYM( """+"""   );
      DUMMY := STORE_SYM( """-"""   );
      DUMMY := STORE_SYM( """&"""   );
      DUMMY := STORE_SYM( """/"""   );
      DUMMY := STORE_SYM( """*"""   );
      DUMMY := STORE_SYM( """MOD""" );
      DUMMY := STORE_SYM( """REM""" );
      DUMMY := STORE_SYM( """**"""  );
      DUMMY := STORE_SYM( """ABS""" );
      DUMMY := STORE_SYM( """NOT""" );
    end;
         
  end	CREATE_IDL_TREE_FILE;
	--------------------


			------------------
  procedure		OPEN_IDL_TREE_FILE		( PAGE_FILE_NAME :STRING )
  is			------------------
  begin
    PAGE_MAN.OPEN_PAGE_MANAGER( PAGE_FILE_NAME );
    begin
      READ_SPEC( "diana" );										--| OUVERTURE DU FICHIER .BIN
    exception
      when NAME_ERROR =>	PUT_LINE( "diana.bin FILE MISSING" );
			raise PROGRAM_ERROR;
    end;
  end	OPEN_IDL_TREE_FILE;
	------------------


			-------------------
  procedure		CLOSE_IDL_TREE_FILE
  is			-------------------
  begin
    PAGE_MAN.CLOSE_PAGE_MANAGER;
  end	CLOSE_IDL_TREE_FILE;
	-------------------


			--------------------
  procedure		DELETE_IDL_TREE_FILE
  is
  begin
    PAGE_MAN.DELETE_PAGE_MANAGER;

  end	DELETE_IDL_TREE_FILE;
	--------------------


			----
  function		MAKE		( NN :NODE_NAME )	return TREE
  is			----
  begin
    if IDL_TBL.N_SPEC( NN ).NS_SIZE = 0 then								--| TYPE DE NOEUD SANS ATTRIBUT
      return (P, TY=> NN, PG=> 0, LN=> 0 );								--| TY 0 1 : FORMAT DU NOEUD SANS ATTRIBUT
    else												--| NOEUD AVEC ATTRIBUTS EN NOMBRE NS_SIZE
      return MAKE( NN, N_SPEC( NN ).NS_SIZE, 1 );								--| TYP TAILLE LIGNE
    end if;
  end	MAKE;
	----


			---
  procedure		 D		( AN :ATTRIBUTE_NAME; T :TREE; V :TREE )
  is			---

    APOS		: INTEGER		:= N_SPEC( T.TY ).NS_FIRST_A;						--| INDICE DE PREMIER ATTRIBUT DANS LA TABLE DE TOUS LES ATTRIBUTS DE TOUS LES NOEUDS
  begin
    for I in 1 .. N_SPEC( T.TY ).NS_SIZE loop								--| BALAYAGE SUR LES ATTRIBUTS DU NOEUD POINTE PAR T
      if A_SPEC( APOS ).ATTR = AN then									--| SI C'EST L'ATTRIBUT CHERCHE
        DABS( I, T, V );										--| REMPLIR LE CHAMP
        return;
      end if;
      APOS := APOS + 1;										--| MONTER AU CHAMP SUIVANT
    end loop;
    PUT_LINE( "!! PROCEDURE D : PAS D ATTRIBUT " & ATTR_IMAGE( AN ) & " DANS " & NODE_REP( T ) );			--| L'ATTRIBUT N'A PAS ETE TROUVE POUR LE NOEUD
    raise PROGRAM_ERROR;										--| ERREUR
  end	D;
	---


			---
  function		 D		( AN :ATTRIBUTE_NAME; T :TREE ) return TREE
  is			---

    APOS		: INTEGER		:= N_SPEC( T.TY ).NS_FIRST_A;						--| INDICE DE PREMIER ATTRIBUT DANS LA TABLE DE TOUS LES ATTRIBUTS DE TOUS LES NOEUDS
  begin
    for I in 1 .. N_SPEC( T.TY ).NS_SIZE loop								--| BALAYAGE SUR LES ATTRIBUTS DU NOEUD POINTE PAR T
      if A_SPEC( APOS ).ATTR = AN then									--| SI C'EST L'ATTRIBUT CHERCHE
        return DABS( I, T );										--| RENDRE LE CHAMP
      end if;
      APOS := APOS + 1;										--| MONTER AU CHAMP SUIVANT
    end loop;
    PUT_LINE( "!! FUNCTION D : PAS D ATTRIBUT " & ATTR_IMAGE( AN ) & " DANS " & NODE_REP( T ) );			--| L'ATTRIBUT N'A PAS ETE TROUVE POUR LE NOEUD
    raise PROGRAM_ERROR;										--| ERREUR
  end	 D;
	---

			--
  procedure		DB		( AN :ATTRIBUTE_NAME; T :TREE; V :BOOLEAN )
  is			--

    VAL		: TREE		:= TREE_FALSE;							--| VALEUR ARBRE À PLACER (INITIALISEE À FAUX)
  begin
    if V then
      VAL := TREE_TRUE;										--| SI VALEUR VRAI À PLACER, CHANGER VAL À VALEUR VRAIE
    end if;
    D( AN, T, VAL );										--| PLACER VAL DANS L'ATTRIBUT
  end	DB;
	--

			--
  function		DB		( AN :ATTRIBUTE_NAME; T :TREE ) return BOOLEAN
  is			--
    A	: TREE	:= D( AN, T );
  begin
    if A = TREE_TRUE then return TRUE;
    elsif A = TREE_FALSE then return FALSE;
    else
      PUT_LINE( "!! L ATTRIBUT " & ATTR_IMAGE( AN ) & " DU NOEUD " & NODE_REP( T ) & " N EST PAS UN BOOLEEN");
      raise PROGRAM_ERROR;
    end if;
  end	DB;
	--


			--
  procedure		DI		( AN :ATTRIBUTE_NAME; T :TREE; V :INTEGER )
  is			--
    VAL_POS		: POSITIVE_SHORT;
    COMPLEMENT_DEUX		: ATTR_NBR;
  begin
    if V < 0 then
      VAL_POS := POSITIVE_SHORT( abs( V+1 ) ); COMPLEMENT_DEUX := 1;
    else
      VAL_POS := POSITIVE_SHORT( V ); COMPLEMENT_DEUX := 0;
    end if;
    D( AN, T, (HI, NOTY=> DN_NUM_VAL, ABSS=> VAL_POS, NSIZ=> COMPLEMENT_DEUX) );
  end	DI;
	--


			--
  function		DI		( AN :ATTRIBUTE_NAME; T :TREE) return INTEGER
  is			--

    ATTR		: TREE		:= D( AN, T );
  begin
    if ATTR.PT = HI and then ATTR.NOTY = DN_NUM_VAL then
      if ATTR.NSIZ = 0 then
        return INTEGER( ATTR.ABSS );
      elsif ATTR.NSIZ = 1 then
        return INTEGER( -ATTR.ABSS - 1 );
      end if;
    end if;
    PUT_LINE( "!! L ATTRIBUT " & ATTR_IMAGE( AN ) & " DU NOEUD " & NODE_REP( T ) & " N EST PAS UN ENTIER");
    raise PROGRAM_ERROR;
  end	DI;
	--


			----
  function		LIST		( T :TREE )	return SEQ_TYPE
  is			----

    A_IDX		: INTEGER		:= N_SPEC( T.TY ).NS_FIRST_A;
  begin
    for I in 1 .. N_SPEC( T.TY ).NS_SIZE loop
      if A_SPEC( A_IDX ).IS_LIST then
        return (FIRST=> DABS ( I, T ) , NEXT=> TREE_NIL );
      end if;
      A_IDX := A_IDX + 1;
    end loop;
         
    PUT_LINE( "!! IL N Y A PAS DE LISTE ASSOCIEE AU NOEUD " & NODE_REP( T ) );
    raise PROGRAM_ERROR;

  end	LIST;
	----


			--------
  function		IS_EMPTY		( S :SEQ_TYPE )	return BOOLEAN
  is			--------
  begin
    return S.FIRST = TREE_NIL  or  S.FIRST = TREE_VOID  or  S.FIRST = TREE_VIRGIN;

  end	IS_EMPTY;
	--------


			---
  procedure		POP		( S :in out SEQ_TYPE; T :out TREE )
  is			---
  begin
    T := HEAD( S );
    S := TAIL( S );

  end	POP;
	---

			----------
  function		PRINT_NAME	( T :TREE ) return STRING					--| POUR TXTREP OR SYMBOL_REP
  is			----------

    TR		: TREE	:= T;
  begin
    if TR.TY = DN_SYMBOL_REP then									--| POUR UN SYMBOL_REP
      TR := DABS( 1, TR );										--| PRENDRE LE TXTREP CORRRESPONDANT
    end if;

   if TR.TY = DN_TXTREP then										--| SI CE N'EST PAS UN TXTREP
    declare
      TXT_HDR		: TREE		:= DABS( 0, TR );						--| PRENDRE L'ENTETE DU BLOC DE CHAINE
      use SYSTEM;
      START		: LINE_IDX	:= TR.LN+1;						--| EMPLACEMENT DU PREMIER TREE COMPRENANT LE NOM
      NB_TREES		: LINE_IDX	:= LINE_IDX( TXT_HDR.NSIZ );					--| NOMBRE DE TREES COMPRENANT LE NOM
      NB_CARS		: NATURAL		:= NATURAL( NB_TREES )
					   *(TREE'SIZE+STORAGE_UNIT-1)/STORAGE_UNIT;
      type SUITE_TREES	is array( START .. START-1+NB_TREES ) of TREE;
      subtype CHN		is STRING( 1 .. NB_CARS );
      function TO_CHN	is new UNCHECKED_CONVERSION( SUITE_TREES, CHN );
      THE_CHN		: CHN;
    begin
      THE_CHN := TO_CHN( SUITE_TREES( PAG( CUR_RP ).DATA.all( START..START-1+NB_TREES ) ) );
      return THE_CHN( 2..1+NATURAL( CHARACTER'POS( THE_CHN( 1 ) ) ) );
    end;
    end if;

    return "PAS UN TXTREP/NUM_VAL PAS DE CHAINE ???";							--| CHAINE PAS DE NOM

  end	PRINT_NAME;
	----------


			---------
  function		PRINT_NUM		( T :TREE ) return STRING					--| POUR DN_NUMVAL
  is			---------
  begin
    if T.TY /= DN_NUM_VAL then									--| SI CE N'EST PAS UN NUMVAL
      return "PAS UN DN_NUM_VAL PAS DE CHAINE ???";							--| CHAINE PAS DE NOM
    end if;

    if T.PT = HI then										--| VALEUR COURTE 16 BITS
      if T.NSIZ = 1 then										--| VALEUR NEGATIVE
        return POSITIVE_SHORT'IMAGE( -T.ABSS - 1 );
      else											--| VALEUR POSITIVE
        return POSITIVE_SHORT'IMAGE( T.ABSS + 1 );
      end if;

    elsif T.PT = P then
      declare											--| UN VRAI DN_NUM_VAL
        ENTETE		: TREE		:= DABS( 0, T );						--| ENTETE CONTENANT LE NOMBRE DE DIGITS
        type DOUBLET	is array( 1..2 ) of SHORT;
        function TO_DOUBLET	is new UNCHECKED_CONVERSION( TREE, DOUBLET );
        ID		: ATTR_NBR 	:= 1;
		----------------
        function	RECURSE_DOUBLETS		return STRING
        is
	DD	: DOUBLET		:= TO_DOUBLET( DABS( ID, T ) );
	DD2	: SHORT		:= DD(2) mod 10_000;
	DD1	: SHORT		:= DD(1) mod 10_000;
	STR2	:constant STRING	:= SHORT'IMAGE( DD2 );
	STR1	:constant STRING	:= SHORT'IMAGE( DD1 );
        begin
	if  ID = ENTETE.NSIZ  then
	  if DD2 = 0  then
	    return STR1( 2 .. STR1'LAST );
	  else
	    return STR2( 2 .. STR2'LAST ) & STR1( 2 .. STR1'LAST );
	  end if;
	else
	  ID := ID + 1;
	  return RECURSE_DOUBLETS & STR2( 2 .. STR2'LAST ) & STR1( 2 .. STR1'LAST );
	end if;
        end	RECURSE_DOUBLETS;
		----------------

      begin
        if ENTETE.ABSS = 1 then									--| ABSS 1 POUR NB NEGATIF
	return '-' & RECURSE_DOUBLETS; 								--| CHIFFRE NEGATIF
        else
	return RECURSE_DOUBLETS;
        end if;
      end;
    end if;

    return "PRINT_NUM T.PT INCORRECT ???";

  end	PRINT_NUM;
	---------


			----------
  function		NODE_IMAGE	( NN :NODE_NAME ) return STRING
  is			----------
  begin
    return NODE_NAME'IMAGE( NN );

  end	NODE_IMAGE;
	----------


		----------
  function	ATTR_IMAGE	( AN :ATTRIBUTE_NAME ) return STRING
  is		----------
  begin
    return ATTRIBUTE_NAME'IMAGE( AN );

  end	ATTR_IMAGE;
	----------
  

  use PRINT_NOD;
  package body PRINT_NOD is separate;


		--------------
  function	GET_LIB_PREFIX		return STRING						--| UTILISEE PAR LIB_PHASE ET WRITE_LIB
  is		--------------

--    CTL		: TEXT_IO.FILE_TYPE;
--    C		: CHARACTER;
--    LINE		: STRING( 1..256 );
--    LEN		: NATURAL	:= 0;
  begin
--    OPEN( CTL, IN_FILE, LIB_PATH(1..LIB_PATH_LENGTH) & "ADA__LIB.CTL" );
--    GET ( CTL, C );
--   if C = 'P' then
--      GET	    ( CTL, C );									--| LE BLANC QUI SUIT
--      GET_LINE( CTL, LINE, LEN );									--| LE PREFIXE (CHEMIN) DE LIBRAIRIE
--    end if;
--    CLOSE( CTL );
--    return LINE( 1..LEN );
    return LIB_PATH( 1 .. LIB_PATH_LENGTH );

  end	GET_LIB_PREFIX;
	--------------


		---------
  procedure	PAR_PHASE		( PATH_TEXTE, NOM_TEXTE, LIB_PATH :STRING ) is separate;

		---------
  procedure	LIB_PHASE		is separate;

		---------
  procedure	SEM_PHASE		is separate;

		---------
  procedure	ERR_PHASE		( ACCES_TEXTE :STRING ) is separate;

		---------
  procedure	WRITE_LIB		is separate;

		------------
  procedure	PRETTY_DIANA	( OPTION :CHARACTER := 'U' ) is separate;


	---
end	IDL;
	---
