--|     Quelques explications sont nécessaires sur cette procédure qui n'est pas très longue mais
--| dont le fonctionnement par changement de signe des références de page dans la version d'origine
--| de Peregrine Systems n'est pas très clair.
--|     Lors de l'analyse syntaxique (PAR_PHASE) des pages virtuelles d'arbre sont allouées pour
--| l'arbre DIANA.
--|     Dans la phase librairie où l'on charge les arbres d'unités "withées", des pages
--| supplémentaires ultérieures sont allouées, pages "withées" qui ne seront pas à sauver lors de
--| l'écriture de l'unité après analyse sémantique.
--|     La phase de vérification sémantique (SEM_PHASE) ajoute des pages qui devront, elles, être
--| sauvegardées à la phase WRITE_PHASE derrières les pages "withées" qui ainsi coupent en deux 
--| la plage des pages à sauvegarder :
--|     Pages AST | Pages withées | Pages SEM
--|     Une translation de recompaction avant sauvegarde est ainsi nécessaire et procède en deux temps :
--|     - On marque d'abord toutes les pages à ne pas toucher dans la compaction (les pages au delà
--|       de la dernière utilisée en SEM_PHASE) et toutes les pages d'unités withées
--|     - On fait une recopie des pages de l'unité à sauvegarder afin de former une seule plage de
--| pages à sauvegarder dans le fichier de compilation de l'unité



with SEQUENTIAL_IO;
separate( IDL )
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE WRITE_LIB
procedure WRITE_LIB is
   
  DONT_MOVE		: array( VPG_IDX ) of BOOLEAN;				--| INDIQUE SI UNE PAGE N EST PAS L OBJET DE DEPLACEMENTS DE TRANSLATION
  NEW_UNIT_SEQ		: SEQ_TYPE;						--| LA NOUVELLE LISTE D UNITES APRES COMPACTION
      
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE MARK_DONT_MOVE_PAGES
  procedure MARK_DONT_MOVE_PAGES ( COMP_UNIT :TREE ) is
    TRANS_WITH_SEQ		: SEQ_TYPE	:= LIST( COMP_UNIT);			--| LISTE FERMETURE TRANSITIVE DES WITH
    HIGH_BLOCK		: PAGE_IDX	:= LAST_BLOCK;
  begin
--|
--|		TOUTES LES PAGES JUSQU A HIGH_BLOCK PEUVENT A PRIORI ETRE OBJET DE TRANSLATION DE COMPACTION
--|		LES AUTRES AU DESSUS N ONT PAS A ETRE AFFECTEES
--|
    DONT_MOVE( 1 .. HIGH_BLOCK )	   := (others=>FALSE);
    DONT_MOVE( HIGH_BLOCK + 1 .. MAX_VPG ) := (others=>TRUE);
--|
--|		PARMI LES PAGES SOUS HIGH_BLOCK, LES PAGES WITHEES N ONT PAS A ETRE AFFECTEES PAR DE LA RECOPIE DE COMPACTION
--|
MARK_TRANS_WITH:
    declare
      TRANS_WITH		: TREE;
    begin
      while not IS_EMPTY( TRANS_WITH_SEQ ) loop						--| POUR TOUTE LA LISTE TRANSITIVE DES UNITES WITHEES
        POP( TRANS_WITH_SEQ, TRANS_WITH );						--| SORTIR UN POINTEUR DE BLOC INFO D UNITE WITHEE (AVEC ENTETE SPECIALE NON HI)

MARK_DONT_MOVE_PAGES_WITHEES:
        declare
          WITHED_UNIT	: TREE		:= D( TW_COMP_UNIT, TRANS_WITH );		--| POINTEUR VERS NOEUD UNITE WITHEE
          FIRST_PAGE	: PAGE_IDX	:= WITHED_UNIT.PG;
          NBR_PAGES_WITHED	: PAGE_IDX	:= PAGE_IDX( DI( XD_NBR_PAGES, WITHED_UNIT ) );
        begin
          for I in FIRST_PAGE .. FIRST_PAGE + NBR_PAGES_WITHED - 1 loop
            DONT_MOVE( I ) := TRUE;							--| LES PAGES DES UNITES WITHEES SONT DECLAREES HORS TRANSLATION
          end loop;
        end MARK_DONT_MOVE_PAGES_WITHEES;

      end loop;
    end MARK_TRANS_WITH;

  end MARK_DONT_MOVE_PAGES;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE WRITE_UNIT
  procedure WRITE_UNIT ( COMP_UNIT_ARG : TREE) is
    package SEQ_IO is new SEQUENTIAL_IO( SECTOR ); 
    COMP_UNIT		: TREE;
    LIB_FILE		: SEQ_IO.FILE_TYPE;

    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE RECOPIE_POUR_COMPACTION
    function RECOPIE_POUR_COMPACTION ( T : TREE ) return TREE is
    begin
--|
--|		UN SOURCE_POSITION N EST PAS A RECOPIER EN LUI MEME MAIS EXIGE DE RECOPIER LE SOURCE LINE ASSOCIE
--|              
      if T.PT = S then								--| SOURCE_POSITION
        return MAKE_SOURCE_POSITION(							--| RECONSTRUIRE UNE POSITION SOURCE
		RECOPIE_POUR_COMPACTION( GET_SOURCE_LINE( T ) ), GET_SOURCE_COL( T ) );	--| AVEC UN DN_SOURCELINE TRANSLATE
--|
--|		TOUS LES ELEMENTS TERMINAUX (PAS D ATTRIBUT PAS DE REF DE PAGE) SONT RENDUS TELS QUELS
--|              
      elsif T.PT = HI or else T.PG = 0 then						--| NUM_VAL COURTE OU NIL OU NON INITIALISE OU TERMINAL STYLE DN_UNIVERSAL_INTEGER
        return T;									--| JUSTE RETOURNER L ARGUMENT
--|
--|		UN SYMBOL_REP N EST PAS A RECOPIER EN LUI MEME MAIS EXIGE DE RECOPIER LE TXT_REP ASSOCIE
--|              
      elsif T.TY = DN_SYMBOL_REP then							--| POINTEUR A DN_SYMBOL_REP
        return RECOPIE_POUR_COMPACTION( D( XD_TEXT , T ) );					--| TRANSLATER LE TEXTE (UN TXTREP REMPLACE UN SYMREP (!!)
--|
--|		UN POINTEUR SUR PAGE A NE PAS TOUCHER EST A RETOURNER TEL QUEL
--|              
      elsif DONT_MOVE( T.PG ) then							--| PAGE A NE PAS TRANSLATER
        return T;									--| NE RIEN FAIRE
--|
--|		UN POINTEUR P/L FAISANT L OBJET DE RECOPIE POUR COMPACTION
--|              
      else

               
        declare
          WORD_ZERO		:TREE	:= DABS( 0, T );					--| ENTETE DU NOEUD POINTE PAR T
        begin
--|
--|		CAS OU L ENTETE DU NOEUD DONNE POUR RECOPIE EST DENATUREE EN POINTEUR L CE QUI INDIQUE UNE RECOPIE DEJA FAITE DE CE NOEUD
--|
          if WORD_ZERO.PT = L then							--| ENTETE DE NOEUD DEJA RECOPIE CONTENANT UN POINTEUR L PG|LN AU REMPLACANT
              return (P, TY=> WORD_ZERO.TY, PG=> WORD_ZERO.PG, LN=> WORD_ZERO.LN );		--| RETOURNER LE POINTEUR P RECONSTITUE AU REMPLAÇANT
--|
--|		CAS OU L ENTETE DU NOEUD POINTE DONNE POUR RECOPIE EST NORMALE (HI VALU NSIZ)
--|
          else									--| CAS NORMAL D'UNE ENTETE DE NOEUD

            case T.TY is								--| QUELQUES AJUSTEMENTS SUIVANT TYPE DE NOEUD
            when CLASS_NON_TASK_NAME | DN_TASK_SPEC =>
              D( XD_STUB, T, TREE_VOID );
              D( XD_BODY, T, TREE_VOID );
            when DN_INCOMPLETE =>
              D( XD_FULL_TYPE_SPEC, T, TREE_VOID );
            when others =>
              null;
            end case;

RECOPIE_ET_MARQUAGE:
            declare
              LENGTH		: ATTR_NBR	:= WORD_ZERO.NSIZ;
              COPIED_T		: TREE		:= MAKE( T.TY, LENGTH );
              LPTR_TO_COPIED_T	: TREE		:= (L, TY=> COPIED_T.TY, PG=> COPIED_T.PG, LN=> COPIED_T.LN );
              INUTILE		: TREE;
            begin

              if T.TY = DN_NUM_VAL then							--| POUR UNE VALEUR NUMERIQUE
                DABS( 0, COPIED_T, DABS( 0, T ) );					--| NE PAS OUBLIER L ENTETE QUI CONTIENT LE SIGNE DANS ABSS !!
	    end if;

              DABS( 0, T, LPTR_TO_COPIED_T );						--| ENSUITE REMPLACE L'ENTETE DU RECOPIE PAR UN POINTEUR L AU TRANSLATE INDIQUE QUE LA TRANSLATION A EU LIEU
               
              if T.TY = DN_TXTREP or T.TY = DN_NUM_VAL then					--| TEXTE OU VALEUR NUMERIQUE
                for I in 1 .. LENGTH loop						--| RECOPIER LE CONTENU
                  DABS( I, COPIED_T, DABS( I, T ) );
                end loop;
              else									--| TOUS AUTRES NOEUDS
                if T.TY = DN_COMPILATION_UNIT then					--| POUR UNE UNITE DE COMPILATION
                  INUTILE := RECOPIE_POUR_COMPACTION( D( XD_LIB_NAME, T ) );			--| TRANSLATER LE NOM EN LE CONVERTISSANT EN TXTREP (CONDUIT A DEUX RECOPIES AVEC CI-DESSOUS ! )
                end if;
PROPAGER_RECOPIE:
                for I in 1 .. LENGTH loop						--| POUR LES ATTRIBUTS
                  DABS( I, COPIED_T, RECOPIE_POUR_COMPACTION( DABS( I, T ) ) );			--| METTRE LES ATTRIBUTS TRANSLATES
                end loop PROPAGER_RECOPIE;
              end if;
              return COPIED_T;

            end RECOPIE_ET_MARQUAGE;
          end if;
        end;       
      end if;
    end RECOPIE_POUR_COMPACTION;
      
  begin
    COMP_UNIT := RECOPIE_POUR_COMPACTION ( COMP_UNIT_ARG );					--| FAIRE UNE RECOPIE COMPACTEE

CREER_LE_FICHIER_UNITE:      
    declare
      SYM		: constant TREE	:= D( XD_LIB_NAME, COMP_UNIT );			--| PRENDRE LE SYMBOLE DU NOM DE L'UNITE DANS LA LIBRAIRIE
      FILE_NAM	: constant STRING	:= GET_LIB_PREFIX & PRINT_NAME( SYM );			--| CHAINE DU NOM PREFIXEE
    begin
      SEQ_IO.CREATE( LIB_FILE, SEQ_IO.OUT_FILE, FILE_NAM );					--| CREER LE FICHIER LIBRAIRIE
    end CREER_LE_FICHIER_UNITE;

PREPARER_ECRITURE_PAGES_UNITE:
    declare
      FIRST_PAGE 	: VPG_IDX		:= COMP_UNIT.PG;					--| PREMIÈRE PAGE DE LA RECOPIE COMPACTEE
      NBR_PAGES	: NATURAL		:= NATURAL( LAST_BLOCK - FIRST_PAGE + 1 );		--| NOMBRE DE PAGES DE LA RECOPIE COMPACTEE
      POINTER	: TREE		:= (P, TY=> DN_VOID, PG=> FIRST_PAGE, LN=> 0);		--| FABRIQUER UN POINTEUR NON TYPE POUR TOUCHER LES PAGES
      INUTILE	: TREE;
    begin
      DI ( XD_NBR_PAGES, COMP_UNIT, NBR_PAGES );						--| PORTER LE NOMBRE DE PAGES DANS LE NOEUD RACINE (DN_COMPILATION_UNIT) DE LA RECOPIE

ECRIRE_LES_PAGES_D_UNITE:      							--| DES OPERATIONS D'ECRITURE A CONFINER DANS LE PAGE_MANAGER
      for I in 1 .. NBR_PAGES loop							--| STOCKER LES PAGES
        INUTILE := DABS( 0, POINTER );							--| TOUCHER LA PAGE POUR LA FORCER DANS UNE PAGE PHYSIQUE
        SEQ_IO.WRITE( LIB_FILE, PAG( ASSOC_PAGE( POINTER.PG ) ).DATA.all );			--| ECRIRE LA PAGE
        POINTER.PG := POINTER.PG + 1;							--| PAGE SUIVANTE
      end loop ECRIRE_LES_PAGES_D_UNITE;

    end PREPARER_ECRITURE_PAGES_UNITE;

    SEQ_IO.CLOSE( LIB_FILE );      
    NEW_UNIT_SEQ := APPEND( NEW_UNIT_SEQ, COMP_UNIT );					--| AJOUTER A LA LISTE DES UNITES
  end WRITE_UNIT;
   
begin
  OPEN_IDL_TREE_FILE( IDL.LIB_PATH( 1.. LIB_PATH_LENGTH ) & "$$$.TMP" );
      
  if DI( XD_ERR_COUNT, TREE_ROOT ) > 0 then
    PUT_LINE( "ERREURS ANTERIEURES WRITELIB PAS EXECUTE" );
  else
    NEW_UNIT_SEQ := (TREE_NIL,TREE_NIL);
    declare
      USER_ROOT	: TREE		:= D( XD_USER_ROOT, TREE_ROOT );			--| RETIRER LA RACINE UTILISATEUR
      COMPILATION	: TREE		:= D( XD_STRUCTURE, USER_ROOT );			--| EN EXTRAIRE LA COMPILATION
      COMP_UNIT_SEQ	: SEQ_TYPE	:= LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ) );		--| PUIS LA LISTE D UNITES DE COMPILATION
      COMP_UNIT	: TREE;
    begin

TRAITE_LES_UNITES_DE_COMPILATION:
      while not IS_EMPTY( COMP_UNIT_SEQ ) loop
        POP( COMP_UNIT_SEQ, COMP_UNIT );
        if D( AS_ALL_DECL, COMP_UNIT ).TY = DN_VOID then					--| UNITE A PRAGMAS SEULEMENT
          NEW_UNIT_SEQ := APPEND( NEW_UNIT_SEQ, COMP_UNIT );				--| JUSTE LA RECHAINER DANS LA LISTE MISE A JOUR
        else									--| UNITE USUELLE
          MARK_DONT_MOVE_PAGES( COMP_UNIT );
          NEW_BLOCK;								--| FORCE A SE METTRE AU DEBUT D'UN NOUVEAU BLOC POUR ALIGNER LA RECOPIE COMPACTEE
          WRITE_UNIT( COMP_UNIT );							--| COMPACTER ET ECRIRE L UNITE DE COMPILATION
        end if;
      end loop TRAITE_LES_UNITES_DE_COMPILATION;
           
      LIST( D( AS_COMPLTN_UNIT_S, COMPILATION ), NEW_UNIT_SEQ );				--| REMPLACER LA LISTE DES UNITES PAR CELLE DES COMPACTEES, SERA ECRIT A LA FERMETURE DU FICHIER ARBRE
    end;
  end if;
      
  CLOSE_IDL_TREE_FILE;
--|-------------------------------------------------------------------------------------------------
end WRITE_LIB;