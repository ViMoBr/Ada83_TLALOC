--	LIB_PHASE.ADB	VINCENT MORIN	21/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2	3	4	5	6	7	8	9	0

with SEQUENTIAL_IO;
separate ( IDL )

					---------
procedure					LIB_PHASE
is					---------
   
  INITIAL_TIMESTAMP		: INTEGER;
  CUR_TIMESTAMP		: INTEGER;
  LIB_INFO_SEQ		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);			--| LISTE DES NOEUDS LIB_INFO
   
  GENERIC_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
  LOADED_UNIT_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
   
  NEW_UNIT_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
  TRANS_WITH_SEQ		: SEQ_TYPE;						--| LISTE FERMETURE TRANSITIVE DES "WITH" D UNE UNITE DE LA COMPILATION
   
  CHTABLE			: constant STRING( 1..32 ) := "0123456789ABCDEFGHJKLMNPRSTVWXYZ";

  DEBUG_LIB		: BOOLEAN	:= FALSE;						--| POUR DEVERMINAGE

  procedure READ_LIB_CTL_FILE;
  procedure REGENERATE_LIB_CTL_FILE;
  procedure INSERT_XD_LIB_NAME_IN_COMP_UNIT	( COMP_UNIT :TREE );
  procedure LOAD_RELOC_LIB_BLOCKS		( COMP_UNIT :TREE );
  procedure ENTER_DEFAULT_GENERIC_FORMALS;
  procedure ENTER_USED_DEFINING_IDS;



				---------------
	procedure			START_LIB_PHASE
is

begin
  OPEN_IDL_TREE_FILE ( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
      
  if DI( XD_ERR_COUNT, TREE_ROOT) = 0 then

    declare
      USER_ROOT	: constant TREE	:= D( XD_USER_ROOT, TREE_ROOT );
      COMPILATION	: constant TREE	:= D( XD_STRUCTURE, USER_ROOT );
      COMP_UNIT_SEQ	: SEQ_TYPE	:= LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ) );
      COMP_UNIT	: TREE;
      SRC_NAME	: constant STRING	:= PRINT_NAME( D( XD_SOURCENAME, USER_ROOT ) );
    begin

      if SRC_NAME = "_standrd.ads" then goto FINISH; end if;

      READ_LIB_CTL_FILE;

			LOAD_RELOC_LIB_BLOCKS_ALL_COMP_UNITS:            

      while not IS_EMPTY( COMP_UNIT_SEQ ) loop

        POP( COMP_UNIT_SEQ, COMP_UNIT );
        if D( AS_ALL_DECL, COMP_UNIT ).TY = DN_VOID then
          PUT_LINE ( "IDL.LIB_PHASE : PAS D'UNITE NE CONTENANT QUE DES PRAGMAS" );
        else
	INSERT_XD_LIB_NAME_IN_COMP_UNIT( COMP_UNIT );
	LOAD_RELOC_LIB_BLOCKS( COMP_UNIT );
        end if;
      end loop		LOAD_RELOC_LIB_BLOCKS_ALL_COMP_UNITS;

            
      LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ), NEW_UNIT_LIST );
      if DI( XD_ERR_COUNT, TREE_ROOT ) = 0 then
        REGENERATE_LIB_CTL_FILE;
      end if;
            
      ENTER_DEFAULT_GENERIC_FORMALS;
      ENTER_USED_DEFINING_IDS;

    end;

  end if;

<<FINISH>>     
  CLOSE_IDL_TREE_FILE;

end	START_LIB_PHASE;
	---------------



			-----------------
	procedure		READ_LIB_CTL_FILE

  is
    FCTL			: TEXT_IO.FILE_TYPE;					--| FICHIER DE CONTOLE DE LA LIBRAIRIE
    LIB_CHAR		: CHARACTER;
    DUMMY_CHAR		: CHARACTER;
    LIB_NUM		: INTEGER;
    LIB_SHORT		: STRING( 1 .. 256 );					--| NOM COURT INTERNE DE LIBRAIRIE POUR L'UNITE
    LIB_TEXT_1		: STRING( 1 .. 256 );					--| POUR LE NOM D'UNITE (NON SEPAREE) OU D'UNITE PARENTE (POUR UNITE SEPAREE)
    LIB_TEXT_2		: STRING( 1 .. 256 );					--| $ POUR UNITE NON SEPAREE, NOM D'UNITE SEPAREE SINON
    LIB_SHORT_LENGTH	: INTEGER;
    LIB_TEXT_1_LENGTH	: INTEGER;
    LIB_TEXT_2_LENGTH	: INTEGER;
    LIB_INFO		: TREE;
    use IDL.INT_IO;
  begin

    declare
      ACCES_LIB_CTL	:constant STRING	:= IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "ADA__LIB.CTL";
    begin
      OPEN( FCTL, IN_FILE, ACCES_LIB_CTL );
    exception
      when NAME_ERROR =>
        CREATE    ( FCTL, OUT_FILE, ACCES_LIB_CTL );
        PUT       ( FCTL, "T " );
        INT_IO.PUT( FCTL, 1, 0 );
        NEW_LINE  ( FCTL );
        PUT_LINE  ( "File " & ACCES_LIB_CTL & " created" );
        CLOSE     ( FCTL );
        OPEN      ( FCTL, IN_FILE, ACCES_LIB_CTL );
    end;
   
    loop
      GET( FCTL, LIB_CHAR );
      if LIB_CHAR = 'T' then
        GET( FCTL, LIB_NUM );
        INITIAL_TIMESTAMP := LIB_NUM;
        CUR_TIMESTAMP     := LIB_NUM;
        exit;									--| SORTIR DE LA BOUCLE, C'EST LA DERNIERE LIGNE DU FICHIER CONTROLE

      elsif LIB_CHAR = 'P' then							--| LIGNE CHEMIN DE LA LIBRAIRIE (PATH)
        SKIP_LINE( FCTL );								--| SAUTER (INUTILE ICI)

      elsif LIB_CHAR = 'S' or LIB_CHAR = 'U' then						--| LIGNE U OU S (UNITE OU UNITE SEPAREE
        GET      ( FCTL, DUMMY_CHAR );							--| PASSER LE BLANC
        GET_LINE ( FCTL, LIB_SHORT, LIB_SHORT_LENGTH );					--| LIRE LE NOM COURT
        GET_LINE ( FCTL, LIB_TEXT_1, LIB_TEXT_1_LENGTH );					--| LIRE LE NOM D'UNITE (SI PAS SEPAREE) OU LE NOM DE PARENTE (SI UNITE SEPAREE)
        if LIB_CHAR = 'U' then							--| LIGNE U (UNSEPARATED UNIT, LES UNITES NON "SEPARATE")
          LIB_TEXT_2( 1..1 ) := "$";							--| NOM SECONDAIRE EN $
          LIB_TEXT_2_LENGTH := 1;							--| LONGUEUR EGALE A UN
        elsif LIB_CHAR = 'S' then							--| LIGNE S (SEPARATED UNIT, LES UNITES "SEPARATE")
          GET_LINE( FCTL, LIB_TEXT_2, LIB_TEXT_2_LENGTH );					--| LIRE LE NOM D'UNITE SEPAREE (PAS CONFONDRE AVEC LE NOM DE SA PARENTE ! )
        else									--| AUTRE PREMIER CARACTERE
          PUT_LINE( "FICHIER DE CONTROLE LIBRAIRIE MAL FORME : LETTRE TYPE LIGNE INCONNUE" );	--| ERREUR SUR LE PREMIER CARACTERE
          raise PROGRAM_ERROR;
        end if;
               
        LIB_INFO := MAKE( DN_LIB_INFO );						--| FABRIQUER UN NOEUD LIB_INFO
        D( XD_SHORT, LIB_INFO, STORE_SYM( LIB_SHORT( 1 .. LIB_SHORT_LENGTH ) ) );		--| NOM COURT (INTERNE A LA LIBRAIRIE)
        D( XD_PRIMARY, LIB_INFO, STORE_SYM( LIB_TEXT_1( 1 .. LIB_TEXT_1_LENGTH ) ) );		--| NOM LONG (D'UNITE SI NON SEPAREE, D'UNITE PARENTE DE SEPAREE SINON)
        D( XD_SECONDARY, LIB_INFO, STORE_SYM( LIB_TEXT_2( 1.. LIB_TEXT_2_LENGTH ) ) );		--| $ SI UNITE NON SEPAREE, NOM D'UNITE SEPAREE SINON
        LIB_INFO_SEQ := APPEND( LIB_INFO_SEQ, LIB_INFO );					--| AJOUTER A LA LISTE DES NOEUDS LIB_INFO
      end if;
    end loop;

    CLOSE( FCTL );									--| FERMER LE FICHIER CONTROLE LIBRAIRIE

  end	READ_LIB_CTL_FILE;
	-----------------



			-----------------------
	procedure		REGENERATE_LIB_CTL_FILE
is

    FCTL			: TEXT_IO.FILE_TYPE;					--| FICHIER CONTROLE
    LIB_PREFIX		: constant STRING	:= GET_LIB_PREFIX;
  begin
    CREATE( FCTL, OUT_FILE, IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "ADA__LIB.CTL" );		--| RECREER LE FICHIER CONTROLE
    if LIB_PREFIX'LENGTH /= 0 then							--| S'IL Y A UNE LIGNE DE PREFIXE LIBRAIRIE (CHEMIN DE CELLE-CI)
      PUT_LINE( FCTL, "P " & LIB_PREFIX );						--| METTRE LA LIGNE P (PREFIXE CHEMIN DU REPERTOIRE LIBRAIRIE)
    end if;
         
    declare
      LINFO_SEQ	: SEQ_TYPE	:= LIB_INFO_SEQ;					--| LISTE DES NOEUDS LIB_INFO
      LIB_INFO	: TREE;
    begin
      while not IS_EMPTY( LINFO_SEQ ) loop						--| TANT QUE LA LISTE DES LIB_INFO EST NON VIDE
        POP( LINFO_SEQ, LIB_INFO );							--| EXTRAIRE UN LIB_INFO
        declare
          EXTEN	: TREE	:= D( XD_SECONDARY, LIB_INFO );				--| LIRE LE NOM SECONDAIRE (NOM D'UNITE SEPAREE OU SIMPLE $ POUR LES AUTRES NON SEPAREES)
          DOLLAR	: TREE	:= STORE_SYM( "$" );					--| STOCKER/RETROUVER LE SYMBOLE $
        begin
          if EXTEN = DOLLAR then							--| SI SECONDAIRE $ (UNITE NON SEPAREE)
            PUT( FCTL, "U ");								--| LIGNE U (UNSEPARATED UNIT)
            PUT_LINE( FCTL, PRINT_NAME ( D( XD_SHORT,   LIB_INFO ) ) );				--| NOM COURT INTERNE	
            PUT_LINE( FCTL, PRINT_NAME ( D( XD_PRIMARY, LIB_INFO ) ) );			--| ET NOM PRIMAIRE (NOM COMPLET DE L'UNITE)
          else
            PUT( FCTL, "S ");								--| LIGNE S (SEPARATED UNIT)
            PUT_LINE( FCTL, PRINT_NAME ( D( XD_SHORT,     LIB_INFO ) ) );			--| NOM COURT
            PUT_LINE( FCTL, PRINT_NAME ( D( XD_PRIMARY,   LIB_INFO ) ) );			--| NOM PRIMAIRE D'UNITE PARENTE DE SEPAREE
            PUT_LINE( FCTL, PRINT_NAME ( D( XD_SECONDARY, LIB_INFO ) ) );			--| NOM D'UNITE SEPAREE DANS CE CAS
          end if;
        end;
      end loop;
    end;
         
    PUT( FCTL, "T " );								--| LIGNE T (ESTAMPILLE "TEMPS" OU No DE MODIFICATION)
    INT_IO.PUT( FCTL, CUR_TIMESTAMP, 0 );						--| INDICE TEMPOREL
    NEW_LINE( FCTL );								--| PASSER A LA LIGNE
    CLOSE( FCTL );									--| FERMER LE FICHIER DE CONTROLE LIBRAIRIE


  end	REGENERATE_LIB_CTL_FILE;
	-----------------------



			-------------
	function		MAKE_FILE_SYM		( PRI, SEC :STRING ) return TREE

is
    BASE_UNIT_SYM		: TREE;
    SECSYM		: TREE;
    TEMP_INFO_SEQ		: SEQ_TYPE;
    LIB_INFO		: TREE;
    EXTEN			: STRING( 1 .. 4 );
    FILESYM		: TREE;
  begin

if debug_lib then put_line( "make_file_sym avec pri=" & PRI
& " sec=" & SEC
); end if;

    if SEC = ".DCL" or else SEC = ".BDY" or else SEC = ".SUB" then				--| UNITES DE COMPILATION SPEC / CORPS
      return STORE_SYM( PRI & SEC );							--| STOCKER LE NOM.EXT ET RETOURNER LE SYMBOLE
    else										--| SOUS UNITE SEPAREE D'UNE UNITE DE LIBRAIRIE
      SECSYM := STORE_SYM( SEC );							--| STOCKER LE NOM DE CORPS SEPARE
      EXTEN := ".SUB";
    end if;
    BASE_UNIT_SYM := STORE_SYM( PRI );							--| STOCKER LE NOM PRIMAIRE
      
    TEMP_INFO_SEQ := LIB_INFO_SEQ;							--| LISTE DES LIB_INFO
    while not IS_EMPTY( TEMP_INFO_SEQ ) loop						--| TANT QU'IL Y EN A
      POP( TEMP_INFO_SEQ, LIB_INFO );							--| EXTRAIRE UN LIB_INFO
      if D( XD_PRIMARY, LIB_INFO ) = BASE_UNIT_SYM					--| CONTIENT UN MEME NOM LONG
      and then D( XD_SECONDARY, LIB_INFO ) = SECSYM					--| AVEC LA MEME EXTENSION
      then
        return STORE_SYM( PRINT_NAME( D( XD_SHORT, LIB_INFO ) ) & EXTEN );			--| RETOURNER LE NOM COURT AVEC EXTENSION CORRESPONDANT
      end if;
    end loop;

    declare
      FILETEXT	: STRING( 1 .. 8 )	:= "$$$$$$$$";					--| CHAINE DE 8 CARACTERES
      NUM_WORK	: INTEGER;
    begin
      NUM_WORK := PRI'LENGTH;								--| LONGUEUR DU NOM
      if NUM_WORK > 4 then								--| DEPASSE 4 CARACTERES
        NUM_WORK := 4;								--| LIMITER A 4
      end if;
      FILETEXT( 1..NUM_WORK ) := PRI( PRI'FIRST..PRI'FIRST+NUM_WORK-1 );			--| REPORTER LE NOM
      NUM_WORK := CUR_TIMESTAMP + 1;							--| ESTAMPILLE DE TEMPS INCREMENTEE
      for I in reverse 6..8 loop							--| DE 8 A 6 A REBOURS
        FILETEXT( I ) := CHTABLE( NUM_WORK mod 32 + 1 );					--| COMPLETER LES 4 (AU PLUS) CARACTERES DE NOM PAR DES CARACTERES CHOISIS DANS LA TABLE 
        NUM_WORK := NUM_WORK / 32;
      end loop;

      FILESYM := STORE_SYM( FILETEXT & EXTEN );						--| STOCKER CE SYMBOLE ARTIFICIEL
      LIB_INFO := MAKE( DN_LIB_INFO );							--| FABRIQUER UN LIB_INFO
      D( XD_SHORT, LIB_INFO, STORE_SYM( FILETEXT ) );					--| Y PORTER LE SYMBOLE
    end;
    D( XD_PRIMARY, LIB_INFO, BASE_UNIT_SYM );						--| Y PORTER AUSSI LE SYMBOLE NOM PRIMAIRE (NOM D'UNITE OU D'UNITE PARENTE DE SEPAREE)
    D( XD_SECONDARY, LIB_INFO, SECSYM );						--| PORTER LE $ (UNITES NON SEPAREES) OU LE NOM D'UNITE SEPAREE
    LIB_INFO_SEQ := APPEND( LIB_INFO_SEQ, LIB_INFO );					--| CHAINER LE LIB_INFO
    return FILESYM;

  end	MAKE_FILE_SYM;
	-------------



			-------------------------------
	procedure		INSERT_XD_LIB_NAME_IN_COMP_UNIT	( COMP_UNIT :TREE )

  is
    UNIT_BODY		: constant TREE	:= D( AS_ALL_DECL, COMP_UNIT );
    FILE_SYM		: TREE;
  begin
    if UNIT_BODY.TY /= DN_SUBUNIT then							--| SI PAS UNE SOUS UNITE (PAS UNE UNITE "SEPARATE")

      declare
        BODY_SOURCE_NAME	: constant TREE	:= D( AS_SOURCE_NAME, UNIT_BODY );
        BODY_SYMREP		: constant TREE	:= D( LX_SYMREP, BODY_SOURCE_NAME );
      begin
--
--		CAS UNITE CORPS : PACKAGE BODY / PROCEDURE ... IS
--
        if UNIT_BODY.TY = DN_PACKAGE_BODY or else UNIT_BODY.TY = DN_SUBPROGRAM_BODY then
	FILE_SYM := MAKE_FILE_SYM( PRINT_NAME( BODY_SYMREP ), ".BDY");
--
--		CAS UNITE SPEC : PACKAGE / PROCEDURE
--
        else
	FILE_SYM := MAKE_FILE_SYM( PRINT_NAME ( BODY_SYMREP ), ".DCL"	);
        end if;

      end;
--|
--|		CAS SEPARATE( X.Y.Z.A ) PACKAGE BODY / PROCEDURE ... IS
--|_________________________________________________________________________________________________
    else										--| SOUS UNITE (SEPAREE)

      declare
        SUBUNIT_BODY	: constant TREE	:= D( AS_SUBUNIT_BODY, UNIT_BODY );
        SUBUNIT_NAME	: constant TREE	:= D( AS_SOURCE_NAME,  SUBUNIT_BODY );
        SUBUNIT_SYMREP	: constant TREE	:= D( LX_SYMREP,       SUBUNIT_NAME );
        SEPARATE_PATH	: constant TREE	:= D( AS_NAME,         UNIT_BODY );

        function SECTION_NOM_SEGMENTE ( SELECTOR : TREE ) return STRING is
        begin
	if SELECTOR.TY = DN_SELECTED then
	  declare
	    HAUT_SELECTEUR	: constant TREE	:= D( AS_NAME,       SELECTOR );
	    ELT_DESIGNANT	: constant TREE	:= D( AS_DESIGNATOR, SELECTOR );
	    CHN_DESIGNANT	: constant TREE	:= D( LX_SYMREP,     ELT_DESIGNANT );
	  begin
	    return SECTION_NOM_SEGMENTE( HAUT_SELECTEUR ) & PRINT_NAME( CHN_DESIGNANT ) & "-";
	  end;
	else
	  return PRINT_NAME( D( LX_SYMREP, SELECTOR ) ) & "-";
	end if;
        end;

      begin
        FILE_SYM := MAKE_FILE_SYM( SECTION_NOM_SEGMENTE( SEPARATE_PATH ) & PRINT_NAME( SUBUNIT_SYMREP ) , ".SUB" );
      end;

    end if;
         
    D( XD_LIB_NAME, COMP_UNIT, FILE_SYM );


  end	INSERT_XD_LIB_NAME_IN_COMP_UNIT;
	-------------------------------


			---------
	function		LOAD_UNIT		( FILESYM_ARG :TREE ) return TREE
			---------
  is    
    FILESYM		: TREE		:= FILESYM_ARG;
    UNIT			: TREE		:= TREE_VOID;
    DELTA_PG_OLD_TO_NEW	: INTEGER;
    UNIT_TIMESTAMP		: INTEGER;

		------
    function	OFFSET		( T :TREE ) return TREE
    is
      TEMP	: TREE	:= T;
    begin
      TEMP.PG := PAGE_IDX( INTEGER( TEMP.PG ) + DELTA_PG_OLD_TO_NEW );
      return TEMP;
    end	OFFSET;
	------

		-------------
    procedure	RELOCATE_UNIT ( UNIT :TREE; WUNIT_SEQ :SEQ_TYPE ) is
      RELOC_TABLE	: array( VPG_NUM ) of PAGE_IDX	:= (others=> 0);
      PNTR	: TREE				:= UNIT;
      LAST_PAGE	: PAGE_IDX			:= PNTR.PG
						+ PAGE_IDX( DI( XD_NBR_PAGES, UNIT ) ) - 1;
      NODE_KIND	: NODE_NAME;
    begin

			FILL_RELOC_TABLE_FOR_WITHED:
      declare
        WUNIT_LIST		: TREE		:= WUNIT_SEQ.FIRST;
        WUNIT		: TREE;
		--------------------
        procedure	FILL_RELOC_FOR_WUNIT ( WUNIT :TREE ) is
          WUNIT_RELOCATED	: TREE		:= OFFSET( WUNIT );
          WUNIT_SYM		: TREE		:= D( TW_FILENAME, WUNIT_RELOCATED );
          WUNIT_SYM_RELOCATED	: TREE		:= OFFSET( WUNIT_SYM );
          WUNIT_RECALL_SYMREP	: TREE		:= STORE_SYM( PRINT_NAME( WUNIT_SYM_RELOCATED ) );
          WUNIT_BLOCK_RECALL	: TREE		:= LOAD_UNIT( WUNIT_RECALL_SYMREP );
          FIRST_PAGE	: PAGE_IDX	:= WUNIT_BLOCK_RECALL.PG;
          UNIT_PNTR		: TREE		:= D( TW_COMP_UNIT, WUNIT_RELOCATED );
          DELTA_PG_OLD_TO_NEW	: INTEGER		:= INTEGER( FIRST_PAGE ) - INTEGER( UNIT_PNTR.PG );
          NBR_PAGES		: PAGE_IDX	:= PAGE_IDX( DI( XD_NBR_PAGES,
				(P, TY=> DN_COMPILATION_UNIT, PG=> FIRST_PAGE, LN=> 0) ) );
      begin
        for I in UNIT_PNTR.PG .. UNIT_PNTR.PG + NBR_PAGES - 1 loop
          RELOC_TABLE( I ) := PAGE_IDX( INTEGER( I ) + DELTA_PG_OLD_TO_NEW );
        end loop;
      end	FILL_RELOC_FOR_WUNIT;
	--------------------
      begin
        if WUNIT_LIST /= TREE_NIL then
          while WUNIT_LIST.TY = DN_LIST loop
            WUNIT      := D( XD_HEAD, OFFSET( WUNIT_LIST ) );
            WUNIT_LIST := D( XD_TAIL, OFFSET( WUNIT_LIST ) );
            FILL_RELOC_FOR_WUNIT( WUNIT );
          end loop;
          FILL_RELOC_FOR_WUNIT( WUNIT_LIST );
        end if;
      end			FILL_RELOC_TABLE_FOR_WITHED;


			FILL_RELOC_TABLE_FOR_UNIT:

      for NEW_PAGE in UNIT.PG .. UNIT.PG + PAGE_IDX( DI ( XD_NBR_PAGES, UNIT ) ) - 1 loop
        declare
	OLD_PAGE	: PAGE_IDX	:= PAGE_IDX( INTEGER( NEW_PAGE ) - DELTA_PG_OLD_TO_NEW );
        begin
          RELOC_TABLE( OLD_PAGE ) := NEW_PAGE;
        end;
      end loop		FILL_RELOC_TABLE_FOR_UNIT;


			RELOCATE_TREE_POINTERS:
      while PNTR.PG <= LAST_PAGE loop
        declare    
          WORD_ZERO	: TREE	:= DABS( 0, PNTR);						--| ENTETE DE NOEUD
        begin
          if WORD_ZERO = TREE_VIRGIN then						--| NON INITIALISE
            PNTR.PG := PNTR.PG + 1;							--| PAGE SUIVANTE
            PNTR.LN := 0;								--| LIGNE 0
          else
            NODE_KIND := WORD_ZERO.NOTY;
            PNTR.TY := NODE_KIND;
                  
            if NODE_KIND /= DN_TXTREP and NODE_KIND /= DN_NUM_VAL then

				RELOCATE_NODE_FIELDS:

              for I in 1 .. WORD_ZERO.NSIZ loop						--| POUR TOUS LES TREES DU NOEUD
                declare
                  FIELD	: TREE	:= DABS( I, PNTR );
                begin
	        if FIELD.PT = S then
                    FIELD.SPG := RELOC_TABLE( FIELD.SPG );   DABS( I, PNTR, FIELD );
                  elsif FIELD.PT /= HI then
		if FIELD.PG /= 0 then
                      FIELD.PG := RELOC_TABLE( FIELD.PG );   DABS( I, PNTR, FIELD );
                      if FIELD.TY = DN_GENERIC_DECL then
                        GENERIC_LIST := INSERT( GENERIC_LIST, FIELD );
		  end if;
                    end if;
                  end if;
                end;
              end loop		RELOCATE_NODE_FIELDS;
            end if;
                  
            if PNTR.LN < LINE_IDX'LAST - WORD_ZERO.NSIZ then				--| SI RESTE DE LA PLACE
	    PNTR.LN := PNTR.LN + WORD_ZERO.NSIZ + 1;					--| MONTER AU NOEUD SUIVANT
	  else
	    PNTR.PG := PNTR.PG + 1;							--| PAGE SUIVANTE
	    PNTR.LN := 0;								--| LIGNE 1
            end if;
          end if;
        end;
      end loop		RELOCATE_TREE_POINTERS;

    end	RELOCATE_UNIT;
	-------------

  begin
    if not IS_EMPTY( LIST( FILESYM ) ) then
      UNIT := HEAD( LIST( FILESYM ) );
      return UNIT;
    end if;  
				READ_UNIT_PAGES:

    declare
      package SEQ_IO	is new SEQUENTIAL_IO( SECTOR );
      LIB_FILE		: SEQ_IO.FILE_TYPE;
    begin

      begin
        SEQ_IO.OPEN( LIB_FILE, SEQ_IO.IN_FILE, GET_LIB_PREFIX & PRINT_NAME( FILESYM ) );
      exception
        when NAME_ERROR => return TREE_VOID;
      end;

					LECTURES:
      declare
        PAGET	: TREE	:= MAKE( NODE_NAME'VAL( 0 ), ATTR_NBR( LINE_IDX'LAST ) );		--| ALLOUER UN ESPACE D'UNE PAGE (SOUS FORME DE NOEUD) DANS L'ARBRE DE LA COMPILATION
        ENTETE	: TREE;
      begin
        SEQ_IO.READ( LIB_FILE, PAG( ASSOC_PAGE( PAGET.PG ) ).DATA.all );			--| LIRE LA PREMIERE PAGE
        ENTETE := DABS( 0, PAGET );							--| PREMIER ENTETE DE PREMIER NOEUD D'UNITE (UN DN_COMPILATION_UNIT)
 
        UNIT := (P, TY=> ENTETE.NOTY, PG=> PAGET.PG, LN=> 0);				--| POINTEUR VERS CE NOEUD COMPTE TENU DE SON TYPE ET DE SON LIEU DE CHARGEMENT
         
        for I in 2 .. DI( XD_NBR_PAGES, UNIT ) loop					--| POUR LE NOMBRE DES AUTRES PAGES
          PAGET := MAKE( NODE_NAME'VAL( 0 ), ATTR_NBR( LINE_IDX'LAST ) );			--| ALLOUER UNE NOUVELLE PAGE (SOUS FORME DE NOEUD) DANS L'ARBRE DE LA COMPILATION
          SEQ_IO.READ( LIB_FILE, PAG( ASSOC_PAGE( PAGET.PG ) ).DATA.all );			--| LIRE LA PAGE
        end loop;
      end					LECTURES;
         
      SEQ_IO.CLOSE( LIB_FILE );

    end				READ_UNIT_PAGES;


    declare      
      OLD_EXAMPLE_PTR	: TREE	:= D( XD_LIB_NAME, UNIT );
    begin
      DELTA_PG_OLD_TO_NEW := INTEGER( UNIT.PG ) - INTEGER( OLD_EXAMPLE_PTR.PG );
    end;
    UNIT_TIMESTAMP := DI( XD_TIMESTAMP, UNIT );


				LOAD_WITHED_UNITS:
    declare
      WUNIT_XD_WITH_LIST	: constant SEQ_TYPE	:= LIST( UNIT );
      WUNIT_LIST		: TREE		:= WUNIT_XD_WITH_LIST.FIRST;
      WUNIT		: TREE;
		----------------
      procedure	LOAD_WITHED_UNIT	( WUNIT_OLD_PLACE :TREE )

      is
        RELOCATED_WUNIT	: constant TREE	:= OFFSET   ( WUNIT_OLD_PLACE );
        OLD_TW_FILENAME	: constant TREE	:= D( TW_FILENAME, RELOCATED_WUNIT );
        NEW_TW_FILENAME	: constant TREE	:= OFFSET   ( OLD_TW_FILENAME );
        TW_FILENAME_SYM	: constant TREE	:= STORE_SYM( PRINT_NAME( NEW_TW_FILENAME ) );
        TW_UNIT		: constant TREE	:= LOAD_UNIT( TW_FILENAME_SYM );
      begin
        if TW_UNIT = TREE_VOID then raise NAME_ERROR; end if;

        if DI( XD_TIMESTAMP, TW_UNIT ) >= UNIT_TIMESTAMP then
          PUT_LINE( "ANOMALIE : " & PRINT_NAME( D( XD_LIB_NAME, TW_UNIT ) )
		& " PAS ANTERIEURE A " & PRINT_NAME( FILESYM ) );
          raise NAME_ERROR;
        end if;
      end	LOAD_WITHED_UNIT;
	----------------
    begin
      if WUNIT_LIST /= TREE_NIL then
        while WUNIT_LIST.TY = DN_LIST loop
          WUNIT      := D( XD_HEAD, OFFSET( WUNIT_LIST ) );
          WUNIT_LIST := D( XD_TAIL, OFFSET( WUNIT_LIST ) );
          LOAD_WITHED_UNIT( WUNIT );
        end loop;
        LOAD_WITHED_UNIT( WUNIT_LIST );
      end if;
    end				LOAD_WITHED_UNITS;


    RELOCATE_UNIT( UNIT, LIST( UNIT ) );
    LOADED_UNIT_LIST := INSERT( LOADED_UNIT_LIST, UNIT );
    LIST( FILESYM, INSERT( (TREE_NIL,TREE_NIL), UNIT ) );
    return UNIT;
         
  end	LOAD_UNIT;
	---------


			---------
	function		LOAD_UNIT			( PRI, SEC :STRING ) return TREE
  is
  begin
    return LOAD_UNIT( MAKE_FILE_SYM( PRI, SEC ) );
  end	LOAD_UNIT;
	---------


  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE INTEGRER_EN_FERMETURE_DES_WITH
  --|
  procedure INTEGRER_EN_FERMETURE_DES_WITH ( UNIT :TREE ) is
  begin

VERIFIER_SI_DEJA_EN_FERMETURE:
    declare
      FERMETURE		: SEQ_TYPE	:= TRANS_WITH_SEQ;				--| FERMETURE TRANSITIVE EN COURS
      ELEMENT		: TREE;
    begin
      while not IS_EMPTY( FERMETURE ) loop
        POP( FERMETURE, ELEMENT );
        if D( TW_COMP_UNIT, ELEMENT ) = UNIT then						--| L UNITE A INTEGRER EN FERMETURE L A ETE ET EST DEJA EN FERMETURE
          return;									--| RIEN A FAIRE SORTIR
        end if;
      end loop;
    end VERIFIER_SI_DEJA_EN_FERMETURE;

INTEGRER_LES_SUBWITHES:
    declare
      SUB_WITH_SEQ		: SEQ_TYPE	:= LIST( UNIT );				--| LISTE DE UNITES WITHEES PAR L UNITE A INTEGRER
      SUB_ELEMENT		: TREE;
    begin
      while not IS_EMPTY( SUB_WITH_SEQ ) loop
        POP( SUB_WITH_SEQ, SUB_ELEMENT );
        INTEGRER_EN_FERMETURE_DES_WITH( D( TW_COMP_UNIT, SUB_ELEMENT ) );					--| RECURSION POUR INTEGRER CES "SOUS" UNITES
      end loop;
    end INTEGRER_LES_SUBWITHES;

INTEGRER_EN_FERMETURE: 
    declare
      INTEGRAND		: TREE		:= MAKE( DN_TRANS_WITH );			--| CREER UN ELEMENT DE LIAISON DE LISTE WITH FERMETURE
    begin     
      D( TW_FILENAME,  INTEGRAND, STORE_TEXT( PRINT_NAME( D( XD_LIB_NAME, UNIT ) ) ) );		--| NOM
      D( TW_COMP_UNIT, INTEGRAND, UNIT );						--| UNITE WITHEE
      TRANS_WITH_SEQ := APPEND( TRANS_WITH_SEQ, INTEGRAND );				--| ENFIN AJOUTER L ELEMENT DE LIAISON EN LISTE FERMETURE
    end INTEGRER_EN_FERMETURE;

  end INTEGRER_EN_FERMETURE_DES_WITH;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE MAKE_USED_NAME_ID
  function MAKE_USED_NAME_ID ( USED_ID :TREE) return TREE is
    USED_NAME_ID	: TREE	:= MAKE( DN_USED_NAME_ID );
  begin
    D( LX_SYMREP, USED_NAME_ID, D( LX_SYMREP, USED_ID ) );
    D( LX_SRCPOS, USED_NAME_ID, D( LX_SRCPOS, USED_ID ) );
    return USED_NAME_ID;
  end MAKE_USED_NAME_ID;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE UNSELECTED
  function UNSELECTED ( NAME :TREE ) return TREE is
  begin
    if NAME.TY = DN_SELECTED then
      return D( AS_DESIGNATOR, NAME );
    else
      return NAME;
    end if;
  end UNSELECTED;


			---------------------
	procedure		TREAT_SUBUNIT_PARENTS	( SUBUNIT :TREE )
			---------------------
  is
    PARENT_NAME_OUT_USED	: TREE	:= D( AS_NAME, SUBUNIT );				--| NAME PARENT DE LA SOUS-UNITE
    ANCESTOR_SYM		: TREE;							--| SYM DE L ANCETRE DE LA SOUS-UNITE (DETERMINE EN FOND DE RECURSION)

    FILE_CHN	: STRING(1..255);							--| CONTIENT LA CHAINE AA-BB-U
    FILE_CHN_L	: NATURAL	:= 0;							--| LONGUEUR D ICELLE
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE INCLUDE_PARENT
  procedure INCLUDE_PARENT ( PARENT_NAME_OUT_USED :in out TREE ) is
  begin
--|
--|	CAS DU SIMPLE NOM DANS LE SEPARATE( X ) (PARENT=ANCETRE)
--|_________________________________________________________________________________________________
    if PARENT_NAME_OUT_USED.TY /= DN_SELECTED then					--| SIMPLE NOM DANS LE SEPARATE OU ARRIVE EN BOUT DE RECURSION

      ANCESTOR_SYM := D( LX_SYMREP, PARENT_NAME_OUT_USED );					--| ON A TROUVE L ANCETRE DU SEPARATE

      declare
        ANCESTOR_NAME	: constant STRING	:= PRINT_NAME( ANCESTOR_SYM );
        ANC_UNIT		: TREE		:= LOAD_UNIT ( ANCESTOR_NAME, ".DCL" );		--| CHARGER LA SPEC DE L UNITE DU SEPARATE
      begin
        FILE_CHN( 1 .. ANCESTOR_NAME'LENGTH ) := ANCESTOR_NAME;
        FILE_CHN_L := ANCESTOR_NAME'LENGTH;

if debug_lib then put_line( "INCLUDE_PARENT simple nom terme charge " & ANCESTOR_NAME ); end if;

        if ANC_UNIT /= TREE_VOID then							--| DCL TROUVEE/CHARGEE OK
          if D( AS_ALL_DECL, ANC_UNIT ).TY = DN_SUBPROGRAM_BODY then				--| SI SEPARE D UN CORPS DE SOUS-PROGRAMME
            LIST( MAKE_FILE_SYM( ANCESTOR_NAME, ".BDY" ), SINGLETON( ANC_UNIT ) );		--| CHAINER DANS LE LIB_INFO
          else
            ANC_UNIT := LOAD_UNIT( ANCESTOR_NAME, ".BDY" );					--| SEPARE D UN PAQUET, CHARGER AUSSI LE CORPS
          end if;
        end if;

        if ANC_UNIT = TREE_VOID then
          ERROR( PARENT_NAME_OUT_USED, "ANCETRE INTROUVABLE - "& ANCESTOR_NAME);		--| LE DCL OU LE BDY N A PAS ETE TROUVE/CHARGE
          ANCESTOR_SYM := TREE_VOID;
        else
          INTEGRER_EN_FERMETURE_DES_WITH( ANC_UNIT );
          PARENT_NAME_OUT_USED := MAKE_USED_NAME_ID( PARENT_NAME_OUT_USED );			--| LE PARENT_NAME EST MODIFIE EN USED_NAME
          D( SM_DEFN, PARENT_NAME_OUT_USED , D( SM_FIRST, SON_1( D( AS_ALL_DECL, ANC_UNIT ) ) ) );
        end if;

      end;
--|
--|	CHAINE DE NOMS POUR SEPARATE( X.Y.Z )
--|_________________________________________________________________________________________________
    else

      D( SM_EXP_TYPE, PARENT_NAME_OUT_USED, TREE_VOID );

      declare
        GRAND_PARENT_NAME_OUT_USED	: TREE	:= D( AS_NAME,       PARENT_NAME_OUT_USED );	--| TIRER LE Y DU X.Y.Z
        PARENT_SYM			: TREE	:= D( AS_DESIGNATOR, PARENT_NAME_OUT_USED );
        CUR_PARENT			: constant STRING	:= PRINT_NAME( D( LX_SYMREP, PARENT_SYM ) );
      begin
        INCLUDE_PARENT( GRAND_PARENT_NAME_OUT_USED );					--| RECURSION

MAJ_FILE_CHN:
        declare
	I_CAR_LIBRE	: NATURAL	:= FILE_CHN_L + 1;
        begin
	FILE_CHN_L := FILE_CHN_L + CUR_PARENT'LENGTH + 1;				--| NOUVELLE LONGUEUR AVEC LE NOM PARENT ET UN TIRET
	FILE_CHN( I_CAR_LIBRE .. FILE_CHN_L ) := '-' & CUR_PARENT;			--| COMPLETER LA CHAINE POUR LE NOM DE FICHIER
        end MAJ_FILE_CHN;

        D( AS_NAME, PARENT_NAME_OUT_USED, GRAND_PARENT_NAME_OUT_USED );			--| REPORTER LE USED_NAME_ID

        if ANCESTOR_SYM /= TREE_VOID then						--| ON A VU L ANCETRE ET PAS DE PROBLEME DEPUIS

 if debug_lib then put_line( "file_select_str " & FILE_CHN( 1.. FILE_CHN_L ) ); end if;

	declare
            TEST_UNIT	: TREE	:= LOAD_UNIT( FILE_CHN( 1.. FILE_CHN_L ), ".SUB" );
	begin


            if TEST_UNIT = TREE_VOID then
              ERROR( PARENT_NAME_OUT_USED, "SOUS-UNITE ANCETRE INTROUVABLE - "
		& PRINT_NAME( D( LX_SYMREP, PARENT_SYM ) ) );
              ANCESTOR_SYM := TREE_VOID;

            elsif PRINT_NAME(
		D( LX_SYMREP, UNSELECTED( GRAND_PARENT_NAME_OUT_USED ) ) )
		/= PRINT_NAME( D( LX_SYMREP, UNSELECTED( D( AS_NAME, D( AS_ALL_DECL, TEST_UNIT ) ) ) ) )
            then
              ERROR( PARENT_NAME_OUT_USED, "NOMS ANCETRES EN CONFLIT - "
		& PRINT_NAME( D( LX_SYMREP, UNSELECTED( PARENT_SYM ) ) )
                     );
              ANCESTOR_SYM := TREE_VOID;
            else
              INTEGRER_EN_FERMETURE_DES_WITH( TEST_UNIT );
	    declare
                USED_NAME	: TREE	:= MAKE_USED_NAME_ID( PARENT_SYM );
	    begin 
	      D( SM_DEFN, USED_NAME, D( SM_FIRST, SON_1( D( AS_SUBUNIT_BODY, D( AS_ALL_DECL, TEST_UNIT ) ) ) ) );
	      D( AS_DESIGNATOR, PARENT_NAME_OUT_USED, USED_NAME );
	    end;
            end if;
          end;
        end if;

      end;

    end if;
  end INCLUDE_PARENT;






  begin
    INCLUDE_PARENT( PARENT_NAME_OUT_USED );						--| PARCOURS RECURSIF VERS L ANCETRE ET CHARGEMENTS EN RETOUR

    D( AS_NAME, SUBUNIT, PARENT_NAME_OUT_USED );						--| USED_NAME_ID PROVENANT DU PARENT_NAME_OUT_USED
--|
--|		VERIFIER QUE S IL Y A UN FICHIER LIBRAIRIE CODE POUR LA SOUS-UNITE IL CONTIENT LE BON NOM
--|	!!! CELA GENERE UN MESSAGE INDESIRABLE LA PREMIERE FOIS QU UNE SOUS UNITE EST COMPILEE. A REVOIR
--|
--    IF ANCESTOR_SYM /= TREE_VOID AND THEN PARENT_NAME_OUT_USED.TY = DN_SELECTED THEN

--      DECLARE
--        UNIT	: TREE	:= LOAD_UNIT( PRINT_NAME( ANCESTOR_SYM ),
--		PRINT_NAME( D( LX_SYMREP, SON_1( D( AS_SUBUNIT_BODY, SUBUNIT ) ) ) )
--		);
--      BEGIN

--if debug_lib then put_line( "tester la presence d un fichier code pour pri=" & PRINT_NAME( ANCESTOR_SYM )
--& "sec=" & PRINT_NAME( D( LX_SYMREP, SON_1( D( AS_SUBUNIT_BODY, SUBUNIT ) ) ) )
--); end if;

--        IF UNIT /= TREE_VOID THEN
--          IF PRINT_NAME( D( LX_SYMREP, D( AS_DESIGNATOR, PARENT_NAME_OUT_USED ) ) )
-- 	  /= PRINT_NAME( D( LX_SYMREP, D( AS_DESIGNATOR,  D( AS_NAME, D( AS_ALL_DECL, UNIT ) ) ) ) )
--          THEN
--            ERROR( SUBUNIT, "CONFLICTING SUBUNIT NAMES" );
--          END IF;
--        END IF;
--      END;

--    END IF;
  end TREAT_SUBUNIT_PARENTS;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE CHECK_USE_CLAUSES
  procedure CHECK_USE_CLAUSES ( CONTEXT_LIST_IN :SEQ_TYPE; CONTEXT_ITEM :TREE ) is
    USE_CLAUSE_LIST		: SEQ_TYPE	:= LIST( D( AS_USE_PRAGMA_S, CONTEXT_ITEM ) );
    USE_CLAUSE		: TREE;
    USE_ID_LIST		: SEQ_TYPE;
    USE_ID		: TREE;
         
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE CHECK_ONE_USE_ID
    procedure CHECK_ONE_USE_ID ( CONTEXT_LIST_IN :SEQ_TYPE; CONTEXT_ITEM, USE_ID : TREE ) is
      SYMREP		: TREE;
      TEMP_CONTEXT_LIST	: SEQ_TYPE 	:= CONTEXT_LIST_IN;
      TEMP_CONTEXT_ITEM	: TREE;
      WITH_ID_LIST		: SEQ_TYPE;
      WITH_ID		: TREE;
    begin
      if USE_ID.TY = DN_PRAGMA then
        return;
      end if;
        
      if USE_ID.TY /= DN_USED_OBJECT_ID then
        ERROR( D( LX_SRCPOS, USE_ID ), "ONLY SIMPLE NAMES ALLOWED IN CONTEXT USE");
      end if;
         
      SYMREP := D( LX_SYMREP, USE_ID );
         
      loop
        POP( TEMP_CONTEXT_LIST, TEMP_CONTEXT_ITEM );
        if TEMP_CONTEXT_ITEM.TY = DN_WITH then
          WITH_ID_LIST := LIST( D( AS_NAME_S, TEMP_CONTEXT_ITEM ) );
          while not IS_EMPTY( WITH_ID_LIST) loop
            POP( WITH_ID_LIST, WITH_ID );
            if D( LX_SYMREP, WITH_ID ) = SYMREP then
              D( SM_DEFN, USE_ID, D( SM_DEFN, WITH_ID ) );
              return;
            end if;
          end loop;
        end if;
        exit when TEMP_CONTEXT_ITEM = CONTEXT_ITEM;
      end loop;
         
      ERROR( D( LX_SRCPOS, USE_ID ),
             "USE'D NAME NOT WITHED IN CURRENT CONTEXT CLAUSE - " & PRINT_NAME( SYMREP ) );
      D( SM_DEFN, USE_ID, TREE_VOID );
    end CHECK_ONE_USE_ID;
         
  begin					--CHECK_USE_CLAUSES
    while not IS_EMPTY( USE_CLAUSE_LIST ) loop
      POP( USE_CLAUSE_LIST, USE_CLAUSE );
      if USE_CLAUSE.TY = DN_USE then
        USE_ID_LIST := LIST( D( AS_NAME_S, USE_CLAUSE ) );
        while not IS_EMPTY( USE_ID_LIST) loop
          POP( USE_ID_LIST, USE_ID );
          if USE_ID.TY = DN_USED_OBJECT_ID then
            CHECK_ONE_USE_ID( CONTEXT_LIST_IN, CONTEXT_ITEM, USE_ID );
          end if;
        end loop;
      end if;
    end loop;
  end CHECK_USE_CLAUSES;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PROCESS_WITH_CLAUSES
  procedure PROCESS_WITH_CLAUSES ( COMP_UNIT : TREE ) is
    UNIT_CONTEXT_LIST	: SEQ_TYPE	:= LIST( D( AS_CONTEXT_ELEM_S, COMP_UNIT ) );
    CONTEXT_ITEM_LIST	: SEQ_TYPE	:= UNIT_CONTEXT_LIST;
    CONTEXT_ITEM		: TREE;
    WITH_NAME_LIST		: SEQ_TYPE;
    WITH_NAME		: TREE;
    UNIT			: TREE;
  begin

TRAITE_ELEMENT_DE_CONTEXTE:
    while not IS_EMPTY( CONTEXT_ITEM_LIST) loop
      POP( CONTEXT_ITEM_LIST, CONTEXT_ITEM );						--| UN ELEMENT DE CONTEXTE
            
      if CONTEXT_ITEM.TY = DN_WITH then							--| QUI EST UN WITH
        WITH_NAME_LIST := LIST( D( AS_NAME_S, CONTEXT_ITEM ) );				--| TIRER LA LISTE DES NOMS WITHES

TRAITE_UN_NOM_WITHE:
        while not IS_EMPTY( WITH_NAME_LIST ) loop
          POP( WITH_NAME_LIST, WITH_NAME );						--| TIRER UN NOM WITHE
          UNIT := LOAD_UNIT( PRINT_NAME( D( LX_SYMREP, WITH_NAME ) ), ".DCL" );			--| CHARGER L UNITE WITHEE
          if UNIT = TREE_VOID then							--| ECHEC
            ERROR( D( LX_SRCPOS, WITH_NAME ),
 		"WITHED UNIT NOT FOUND - " & PRINT_NAME( D( LX_SYMREP, WITH_NAME ) )
		);
            D( SM_DEFN, WITH_NAME, TREE_VOID );						--| RIEN DANS LE WITH_NAME.SM_DEFN

          elsif DI( XD_TIMESTAMP, UNIT) = CUR_TIMESTAMP then
            ERROR( D( LX_SRCPOS, WITH_NAME ),
                        "WITH CLAUSE REFERS TO CURRENT UNIT - " & PRINT_NAME( D( LX_SYMREP, WITH_NAME ) )
                        );
                                                -- AVOID ERROR WHEN CHECKING USE CLAUSE LATER
            D( SM_DEFN, WITH_NAME, TREE_VOID );

          else
            INTEGRER_EN_FERMETURE_DES_WITH( UNIT );					--| UNITE WITHEE EN FERMETURE DES WITH
	  declare
	    WITH_BODY	: TREE	:= D( AS_ALL_DECL, UNIT );
	  begin
	    D( SM_DEFN, WITH_NAME, SON_1( WITH_BODY ) );
	  end;
          end if;
        end loop TRAITE_UN_NOM_WITHE;

      end if;
      CHECK_USE_CLAUSES( UNIT_CONTEXT_LIST, CONTEXT_ITEM );
    end loop TRAITE_ELEMENT_DE_CONTEXTE;

  end PROCESS_WITH_CLAUSES;


			---------------------
	procedure		LOAD_RELOC_LIB_BLOCKS		( COMP_UNIT :TREE )
			---------------------
							
  is
    FILE_SYM		: TREE		:= D( XD_LIB_NAME, COMP_UNIT );
    UNIT_BODY		: TREE		:= D( AS_ALL_DECL, COMP_UNIT );
    UNIT_KIND		: NODE_NAME	:= UNIT_BODY.TY;
    WITH_LIST		: SEQ_TYPE	:= (TREE_NIL, TREE_NIL);
    SPC_UNIT		: TREE;
  begin
    TRANS_WITH_SEQ := (TREE_NIL, TREE_NIL);						--| FERMETURE TRANSITIVE DES WITH INITIALEMENT VIDE

				TREAT_STANDARD_SPEC:
    declare
      SPC_STANDRD	: TREE	:= LOAD_UNIT( "_STANDRD", ".DCL" );
    begin
      if SPC_STANDRD = TREE_VOID then
        PUT_LINE( "ERREUR : ENVIRONNEMENT PREDEFINI _STANDRD.DCL INTROUVABLE.");
        raise PROGRAM_ERROR;
      end if;
      INTEGRER_EN_FERMETURE_DES_WITH( SPC_STANDRD );

    end				TREAT_STANDARD_SPEC;
      
					-- CLEAR LIST OF TRANS-WITH UNITS TO AVOID ABORT IF SELF-REFERENCE
    LIST( COMP_UNIT, (TREE_NIL,TREE_NIL) );
      

    if UNIT_KIND = DN_SUBPROG_ENTRY_DECL then
      null;       
    elsif UNIT_KIND = DN_PACKAGE_DECL or UNIT_KIND = DN_GENERIC_DECL then
      null;

    elsif UNIT_KIND = DN_PACKAGE_BODY or UNIT_KIND = DN_SUBPROGRAM_BODY then


				TREAT_BODY_SPEC:

      declare
        UNIT_PRI	: constant STRING	:= PRINT_NAME( D( LX_SYMREP, SON_1( UNIT_BODY ) ) );	--| LE AS_NAME POUR CHERCHER LA SPEC
      begin
        SPC_UNIT := LOAD_UNIT( UNIT_PRI, ".DCL" );

if debug_lib then put_line( "with_for_one_comp_unit load_unit : unit_pri = " & unit_pri ); end if;

        if SPC_UNIT /= TREE_VOID and then UNIT_KIND = DN_SUBPROGRAM_BODY then			--| CHARGE UNE SPC POUR UN CORPS DE SOUS-PROGRAMME
	declare
	  SPC_UNIT_ALL_DECL	: constant TREE	:= D( AS_ALL_DECL, SPC_UNIT );

	  SPC_UNIT_IS_DECL_NOT_INSTANTIATION	: BOOLEAN	:= 
		SPC_UNIT_ALL_DECL.TY = DN_SUBPROG_ENTRY_DECL
		and then D( AS_UNIT_KIND, SPC_UNIT_ALL_DECL ).TY /= DN_INSTANTIATION;

	  SPC_UNIT_IS_GENERIC_SUBP_SPEC	: BOOLEAN	:= 
		SPC_UNIT_ALL_DECL.TY = DN_GENERIC_DECL
		and then D( AS_HEADER, SPC_UNIT_ALL_DECL ).TY in CLASS_SUBP_ENTRY_HEADER;

	begin
            if not ( SPC_UNIT_IS_DECL_NOT_INSTANTIATION or SPC_UNIT_IS_GENERIC_SUBP_SPEC )							--|   QUI N A PAS
            then
              SPC_UNIT := TREE_VOID;							--| NE PAS TRAITER UNE TELLE UNITE
            end if;
	end;
        end if;
            
        if SPC_UNIT /= TREE_VOID then
          INTEGRER_EN_FERMETURE_DES_WITH( SPC_UNIT );
          D( SM_FIRST, SON_1( UNIT_BODY ), SON_1( D( AS_ALL_DECL, SPC_UNIT ) ) );
          D( XD_PARENT, COMP_UNIT, SPC_UNIT );						--| LA SPEC EST PARENT DU BDY

        else

          if UNIT_KIND = DN_PACKAGE_BODY then						--| POUR UN CORPS DE PAQUET
            ERROR( D( LX_SRCPOS, COMP_UNIT ),
		"CANNOT WITH SPEC FOR " & PRINT_NAME( D( LX_SYMREP, SON_1( UNIT_BODY ) ) ) );

          else
            declare
              FILESYM	: TREE := MAKE_FILE_SYM( UNIT_PRI, ".DCL" );
            begin
              LIST( FILESYM, SINGLETON( COMP_UNIT ) );
              D( XD_LIB_NAME, COMP_UNIT, FILESYM );
            end;
          end if;
        end if;
      end				TREAT_BODY_SPEC;
--|
--|		TRAITEMENT WITH SCOPE POUR SOUS UNITE DE COMPILATION UNIT_KIND = SUBUNIT
--|_________________________________________________________________________________________________        
    else

if debug_lib then put_line( "with_for_one_comp_unit INCLUDES_PARENTS : unit_body = " ); PRINT_NOD.PRINT_NODE(UNIT_BODY); end if;

       TREAT_SUBUNIT_PARENTS( UNIT_BODY );						--| CHARGER TOUT CE QUI EST ENTRE LA SOUS UNITE ET SON ANCETRE Y COMPRIS
    end if;
      
    CUR_TIMESTAMP := CUR_TIMESTAMP + 1;							--| MARQUEUR TEMPOREL
    DI( XD_TIMESTAMP, COMP_UNIT, CUR_TIMESTAMP );						--| REPORTE
    LIST( FILE_SYM, SINGLETON( COMP_UNIT ) );
      
    PROCESS_WITH_CLAUSES( COMP_UNIT );							--| TRAITER LES WITH EXPLICITES EN CLAUSE POUR L UNITE
      
    LIST( COMP_UNIT, TRANS_WITH_SEQ );
    NEW_UNIT_LIST := APPEND( NEW_UNIT_LIST, COMP_UNIT );


  end	LOAD_RELOC_LIB_BLOCKS;
	-----------------------------------



  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE COPY_NODE
  function COPY_NODE ( NODE :TREE ) return TREE is
    WORD_ZERO	: TREE	:= DABS( 0, NODE );
    NEW_NODE	: TREE	:= MAKE( WORD_ZERO.NOTY, WORD_ZERO.NSIZ );
  begin
--    for I in 1 .. WORD_ZERO.NSIZ loop
    for I in 0 .. WORD_ZERO.NSIZ loop
      DABS( I, NEW_NODE, DABS( I, NODE ) );
    end loop;
    return NEW_NODE;
  end COPY_NODE;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE GENERATE_DUMMY_SPEC
--   procedure GENERATE_DUMMY_SPEC ( COMP_UNIT :TREE ) is
-- 					-- GENERATE LIBRARY UNIT FOR DEFAULT SUBPROGRAM SPEC
--     SUBP_BODY		: TREE	:= D( AS_ALL_DECL, COMP_UNIT );
--     SUBP_HEADER		: TREE	:= D( AS_HEADER, SUBP_BODY );
--     NEW_UNIT		: TREE	:= COPY_NODE( COMP_UNIT );
--     NEW_ID		: TREE	:= COPY_NODE( SON_1( SUBP_BODY ) );
--     NEW_DECL		: TREE	:= MAKE( DN_SUBPROG_ENTRY_DECL );
--   begin
--     D( SM_SPEC, NEW_ID, NEW_DECL );
--     D( SM_FIRST, NEW_ID, NEW_ID );
--       
--     D( AS_SOURCE_NAME, NEW_DECL, NEW_ID );
--     D( AS_HEADER, NEW_DECL, D( AS_HEADER, SUBP_BODY ) );
--     D( AS_UNIT_KIND, NEW_DECL, TREE_VOID );
--     D( LX_SRCPOS, NEW_DECL, D( LX_SRCPOS, SUBP_BODY ) );
--       
-- 					-- WORRY ABOUT DUPLICATED CONTEXT AND PRAGMAS $$$$$$$$
--     D( AS_ALL_DECL, NEW_UNIT, NEW_DECL );
--       
--     INSERT_XD_LIB_NAME_IN_COMP_UNIT( NEW_UNIT );
--     LOAD_RELOC_LIB_BLOCKS( NEW_UNIT );
--   end GENERATE_DUMMY_SPEC;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE ENTER_DEFAULT_GENERIC_FORMALS
  procedure ENTER_DEFAULT_GENERIC_FORMALS is
    GENERIC_DECL		: TREE;
    FORMAL_LIST		: SEQ_TYPE;
    FORMAL		: TREE;
    SUBPROGRAM_DEF		: TREE;
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE INSERT_SYMBOL
    procedure INSERT_SYMBOL ( NAME :TREE ) is
      DUMMY	: TREE;
    begin
      if NAME.TY = DN_SELECTED then
        INSERT_SYMBOL( D( AS_NAME, NAME ) );
        INSERT_SYMBOL( D( AS_DESIGNATOR, NAME ) );
      else									--| DOIT ETRE UN DEF_ID, DEF_OP, USED_ID, USED_OP
        DUMMY := STORE_SYM( PRINT_NAME( D( LX_SYMREP, NAME ) ) );
      end if;
    end INSERT_SYMBOL;
      
  begin
    while not IS_EMPTY( GENERIC_LIST) loop
      POP( GENERIC_LIST, GENERIC_DECL );
      FORMAL_LIST := LIST( D( AS_ITEM_S, GENERIC_DECL ) );
      while not IS_EMPTY( FORMAL_LIST) loop
        POP( FORMAL_LIST, FORMAL );
        if FORMAL.TY = DN_SUBPROG_ENTRY_DECL then
          SUBPROGRAM_DEF := D( AS_UNIT_KIND, FORMAL );
          if SUBPROGRAM_DEF.TY = DN_BOX_DEFAULT then
            INSERT_SYMBOL( D( AS_SOURCE_NAME, FORMAL ) );
          end if;
        end if;
      end loop;
    end loop;
  end ENTER_DEFAULT_GENERIC_FORMALS;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE ENTER_USED_DEFINING_IDS
  procedure ENTER_USED_DEFINING_IDS is
    UNIT		: TREE;
    PNTR		: TREE;
    WORD_ZERO	: TREE;
    NODE_TYPE	: NODE_NAME;
    SYMREP	: TREE;
  begin
    while not IS_EMPTY( LOADED_UNIT_LIST ) loop
      POP( LOADED_UNIT_LIST, UNIT );							--| RETIRER UNE UNITE CHARGEE DE LA LISTE DES CHARGEES
      PNTR := UNIT;									--| POINTER LE DEBUT D UNITE
      for I in 1 .. DI( XD_NBR_PAGES, UNIT ) loop
        PNTR.LN := LINE_IDX'FIRST;							--| A CHAQUE PAGE REVENIR A LA PREMIERE LIGNE

PARCOURS_BLOCS_NOEUDS:
        loop
          WORD_ZERO := DABS( 0, PNTR );							--| POSSIBLE ENTETE DE NOEUD
          exit PARCOURS_BLOCS_NOEUDS when WORD_ZERO = TREE_VIRGIN;				--| SORTIR SI EN FAIT NON INITIALISE (FIN DE PARTIE DE PAGE REMPLIE)
          PNTR.TY   := WORD_ZERO.NOTY;
          NODE_TYPE := WORD_ZERO.NOTY;
                  
          case NODE_TYPE is
          when CLASS_DEF_NAME =>							--| TOUS LES ID (DE VARIABLE_ID A BLTN_OPERATOR_ID)
            SYMREP := D( LX_SYMREP, PNTR );						--| PRENDRE LE SYMREP (EN PRINCIPE UN SYMBOLE POUR L ID)
            if SYMREP.TY = DN_TXTREP then						--| SI C'EST UN TXTREP (REMPLACEMENT FAIT PAR WRITE_LIB)
              if NODE_TYPE in CLASS_UNIT_NAME						--| PROCEDURE_ID, FUNCTION_ID, OPERATOR_ID
              or else (	NODE_TYPE = DN_VARIABLE_ID					--| OU VARIABLE
                           	and then D( SM_OBJ_TYPE, PNTR).TY = DN_TASK_SPEC			--| DE TYPE TACHE
                           	)
              or else NODE_TYPE = DN_TYPE_ID						--| OU TYPE_ID
              then
                if NODE_TYPE = DN_VARIABLE_ID or else D( SM_FIRST, PNTR ) = PNTR		--| VARIABLE_ID (TACHE) OU 
                then
                  SYMREP := STORE_SYM( PRINT_NAME( SYMREP ) );				--| STOCKER LE SYMBOLE
                elsif NODE_TYPE = DN_TYPE_ID then						--| TYPE_ID
                  if D( SM_TYPE_SPEC, D( SM_FIRST, PNTR ) ).TY = DN_INCOMPLETE then		--| INCOMPLET
                    D( XD_FULL_TYPE_SPEC, D( SM_TYPE_SPEC, D( SM_FIRST, PNTR ) ), D( SM_TYPE_SPEC, PNTR ) );
                  end if;
                end if;
              else									--| AUTRES DE LA CLASSE DEF_NAME
                SYMREP := FIND_SYM( PRINT_NAME( SYMREP ) );					--| CHERCHER SI LA COMPILATION PRESENTE MENTIONNE CE SYMBOLE
              end if;
              if SYMREP /= TREE_VOID then						--| S'IL EST PRESENT
                D( LX_SYMREP, PNTR, SYMREP );						--| LE METTRE DANS LE LX_SYMREP DU POINTEUR DE L'UNITE CHARGEE
              end if;
            end if;

          when CLASS_DESIGNATOR =>							--| LES USED_OP, USED_NAME_ID, USED_CHAR, USED_OBJECT_ID 
            SYMREP := D( SM_DEFN, PNTR );						--| PRENDRE LE DEF_NAME
            if SYMREP.PG > 0 and then SYMREP.TY in CLASS_DEF_NAME then			--| POINTEUR DE BONNE FACTURE
              SYMREP :=  D( LX_SYMREP, SYMREP );						--| PRENDRE LE SYMBOLE
              if SYMREP.TY = DN_SYMBOL_REP then						--| SI C'EST UN SYMBOLE
                D( LX_SYMREP, PNTR, SYMREP );						--| LE RECOLLER DANS LE POINTEUR
              end if;
            end if;
 
          when others =>
            null;
          end case;

	exit PARCOURS_BLOCS_NOEUDS when PNTR.LN >= LINE_IDX'LAST - WORD_ZERO.NSIZ;
          PNTR.LN := PNTR.LN + WORD_ZERO.NSIZ + 1;
        end loop PARCOURS_BLOCS_NOEUDS;

        PNTR.PG := PNTR.PG + 1;
      end loop;

    end loop;
  end ENTER_USED_DEFINING_IDS;


begin   
  START_LIB_PHASE;

	---------
end	LIB_PHASE;
	---------
