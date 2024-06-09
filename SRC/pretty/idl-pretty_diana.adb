SEPARATE( IDL )
--|-------------------------------------------------------------------------------------------------

			--	PRETTY_DIANA	--

--|-------------------------------------------------------------------------------------------------
PROCEDURE PRETTY_DIANA ( OPTION :CHARACTER := 'U' ) IS
  OFILE		: FILE_TYPE;							--| LE FICHIER DE SORTIE IMPRESSION

  DEBUG_PRETTY	: BOOLEAN		:= FALSE;
  --|-----------------------------------------------------------------------------------------------

  --	IMPRIME	--

  --|-----------------------------------------------------------------------------------------------
  PROCEDURE IMPRIME IS
      
    LAST_PAGE		: VPG_IDX	:= VPG_IDX( DI ( XD_HIGH_PAGE, TREE_ROOT ) );
         
    TYPE STATUS		IS ( PRINT, PRINT_AS, NO_PRINT );				--| MARQUAGE DE LIGNE DE PAGE : IMPRIMER, IMPRIMER COMME ALL_SOURCE, LAISSER
    TYPE PRINT_STATUS_VECTOR	IS ARRAY( LINE_IDX ) OF STATUS;				--| VECTEUR MARQUAGE D UNE PAGE
    TYPE PRINT_STATUS_ARRAY	IS ARRAY( 1 .. LAST_PAGE ) OF PRINT_STATUS_VECTOR;		--| MARQUAGE DE TOUS LES TREES DU FICHIER ARBRE (INDICAGE PAR PAGE ET LIGNE)
      
    PRINT_STATUS		: PRINT_STATUS_ARRAY	:= (OTHERS => (OTHERS => PRINT) );
    USER_ROOT		: TREE			:= D( XD_USER_ROOT, TREE_ROOT );
    COMPLTN_STRUCT		: TREE			:= D( XD_STRUCTURE, USER_ROOT );

    --|-----------------------------------------------------------------------------------------------

    --		INDENT	--

    --|-----------------------------------------------------------------------------------------------
    PROCEDURE INDENT ( IND :INTEGER ) IS
      I	: INTEGER := IND;
    BEGIN
      NEW_LINE;									--| SE FAIT SUR UNE NOUVELLE LIGNE
      WHILE I >= 8 LOOP
        PUT ( "      | " );								--| UNE SUITE DE 8 CARACTERES AVEC UN | A 7
        I := I - 8;									--| 8 DE MOINS
      END LOOP;
      FOR N IN 1 .. I LOOP PUT ( ' ' ); END LOOP;						--| RELIQUAT DE BLANCS
    END INDENT; 
    --|---------------------------------------------------------------------------------------------

    --		MARK_STRUCT	--

    --|---------------------------------------------------------------------------------------------
    PROCEDURE MARK_STRUCT ( T :TREE ) IS						--| MARQUE EN PRINT_AS LES TREES DE LA CATEGORIE "ALL_SOURCE"
    BEGIN
      IF T = TREE_VOID OR ELSE T = TREE_NIL OR ELSE T = TREE_VIRGIN OR ELSE T.PT = HI		--| TREE VERS UN NOEUD SANS ATTRIBUT OU REPRESENTANT UN ENTIER 16 BITS NEGATIF OU UNE POSITION SOURCE
         OR ELSE ( (T.PT=P OR T.PT=L) AND THEN PRINT_STATUS( T.PG )( T.LN ) /= PRINT) THEN	--| DEJA MARQUE
        RETURN;									--| NE RIEN FAIRE
      END IF;

      IF T.PT = P OR T.PT = L THEN  
        PRINT_STATUS( T.PG )( T.LN ) := PRINT_AS;						--| INITIALISER EN MARQUER EN A IMPRIMER ELEMENT "AS_"
        IF T.TY IN CLASS_ALL_SOURCE THEN						--| TYPE DANS LA CLASSE ELEMENTS DE CODE SOURCE
	  
	IF ARITY( T ) = ARBITRARY THEN						--| ARITE QUELCONQUE : LISTE
	  DECLARE
	    ITEM_LIST	: SEQ_TYPE	:= LIST( T );				--| AMENER LA LISTE POINTEE
	    ITEM		: TREE;
	  BEGIN
	    WHILE NOT IS_EMPTY( ITEM_LIST ) LOOP					--| TANT QUE PAS VIDE
	      POP( ITEM_LIST, ITEM );							--| EXTRAIRE UN POINTEUR DE LA LISTE
	      MARK_STRUCT( ITEM );							--| FAIRE LE MARQUAGE EN SUIVANT CE POINTEUR
	    END LOOP;
	  END;
	        
	ELSE									--| ARITE DEFINIE
	  FOR I IN 1..ATTR_NBR( ARITIES'POS( ARITY( T ) ) ) LOOP				--| POUR TOUS LES CHAMPS
	    MARK_STRUCT( DABS( I, T ) );						--| FAIRE LE MARQUAGE EN SUIVANT LE POINTEUR DU CHAMP
	  END LOOP;
	END IF;
	  
        END IF;
      END IF;
    END MARK_STRUCT;
    --|---------------------------------------------------------------------------------------------

    --		PRINT_DIANA	--

    --|---------------------------------------------------------------------------------------------
    PROCEDURE PRINT_DIANA ( T : TREE; IND : NATURAL; PARENT :TREE ) IS
      A_SUB	: INTEGER;
    BEGIN
if debug_pretty then put_line( "print_diana" ); end if;

--..................................................................................................

--		IMPRESSION AU BESOIN DU POINTEUR DE NOEUD

--..................................................................................................
      PRINT_NOD.PRINT_TREE( T );							--| IMPRIMER LE POINTEUR D'ARBRE
	  
      IF T = TREE_VOID OR ELSE T = TREE_NIL OR ELSE T = TREE_VIRGIN
	OR ELSE T.PT = HI OR ELSE T.PT = S THEN						--| UN SOURCELINE OU UN ENTIER 16 BITS NEGATIF OU UN POINTEUR NIL
        RETURN;									--| FINI
      END IF;
         
      A_SUB := N_SPEC( T.TY ).NS_FIRST_A;
      IF T.TY IN CLASS_ALL_SOURCE THEN							--| NOEUD STRUCTUREL
--..................................................................................................

--		IMPRESSION DE LA POSITION SOURCE DU NOEUD

--..................................................................................................
IMPRIME_POSITION_SOURCE:
        DECLARE
	SPOS	: TREE	:= D( LX_SRCPOS, T );	  				--| POSITION SOURCE : (LIGNE,COL)
        BEGIN
	PUT ( " SLOC(" );
	IF SPOS.PT = S AND THEN SPOS.COL IN 1 .. 254 THEN
	  DECLARE
	    IML : CONSTANT STRING	:= INTEGER'IMAGE( DI( XD_NUMBER, GET_SOURCE_LINE( SPOS ) ) );
	    IMC : CONSTANT STRING	:= SRCCOL_IDX'IMAGE( GET_SOURCE_COL( SPOS ) );
	  BEGIN
	    PUT( IML( 2..IML'LENGTH ) & "," & IMC( 2..IMC'LENGTH ) );
	  END;
	ELSE
	  PRINT_TREE( SPOS );
	END IF;
	PUT( ')' );
        END IMPRIME_POSITION_SOURCE;
--..................................................................................................

--		IMPRESSION AU BESOIN DU NOM DE NOEUD

--..................................................................................................
        IF T.TY IN CLASS_SOURCE_NAME THEN						--| CHOSES QUI ONT UN SYMBOLE ASSOCIE
	DECLARE
	  SYMREP		: TREE		:= D( LX_SYMREP, T );
	  DEFLIST		: SEQ_TYPE;
	  DEF		: TREE;
	BEGIN
	  IF SYMREP.TY = DN_SYMBOL_REP THEN
	    DEFLIST := LIST( SYMREP );
	    WHILE NOT IS_EMPTY( DEFLIST ) LOOP
	      POP( DEFLIST, DEF );
	      IF DEF.TY = DN_DEF AND THEN D( XD_SOURCE_NAME, DEF ) = T THEN
	        PUT( ' ' ); PRINT_TREE( DEF );
	        PUT( ' ' ); PRINT_TREE( D( XD_REGION_DEF, DEF ) );
	        EXIT;
	      END IF;
	    END LOOP;
	  END IF;
	END;
        END IF;
	     
      END IF;
--..................................................................................................

--		IMPRESSION EVENTUELLE DU CORPS DE NOEUD

--..................................................................................................
      IF PRINT_STATUS( T.PG )( T.LN ) = NO_PRINT THEN					--| PAS D'IMPRESSION DU NOEUD, RETOUR
        RETURN;
      END IF;
	     
      PRINT_STATUS ( T.PG )( T.LN ) := NO_PRINT;						--| MENTIONNER NE PLUS IMPRIMER A L AVENIR
--..................................................................................................

--		CAS SPECIAL DU NOEUD UNITE DE COMPILATION OPTIONS POUR PAGES WITHEES

--..................................................................................................
      IF T.TY = DN_COMPILATION_UNIT THEN						--| CAS SPECIAL DE L'UNITE DE COMPILATION
        DECLARE
	TRANS_WITH_LIST	: SEQ_TYPE	:= LIST( T );				--| LISTE DES WITH
	TRANS_WITH	: TREE;
	COMP_UNIT		: TREE;
        BEGIN
	IF TRANS_WITH_LIST.FIRST /= TREE_VIRGIN THEN					--| TETE DE LISTE NON INITIALISEE : LIB_PHASE NON FAITE

if debug_pretty then put_line( "dn_compilation_unit trans_with_list" ); end if;

	  WHILE NOT IS_EMPTY ( TRANS_WITH_LIST ) LOOP
	    POP ( TRANS_WITH_LIST, TRANS_WITH );					--| EXTRAIRE UN ELEMENT DE LISTE WITH
	 	
	    COMP_UNIT := D( TW_COMP_UNIT, TRANS_WITH );
	    IF D( XD_NBR_PAGES, COMP_UNIT ) /= TREE_VIRGIN THEN
	      FOR I IN COMP_UNIT.PG .. COMP_UNIT.PG + PAGE_IDX( DI( XD_NBR_PAGES, COMP_UNIT ) ) - 1 LOOP
	        DECLARE
	          PS : STATUS := NO_PRINT;
	        BEGIN
	          IF OPTION = 'P' THEN PS := PRINT_AS; ELSIF OPTION = 'A' THEN PS := PRINT; END IF;
	          PRINT_STATUS( I ) := (OTHERS => PS);					--| IMPRIMER SUIVANT OPTION
	        END;
	      END LOOP;
	    END IF;
	  END LOOP;

	END IF;
        END;
      END IF;
--..................................................................................................

--		IMPRESSION DU CONTENU DE NOEUD (DESCENDANTS)

--..................................................................................................
TRAITER_LES_DESCENDANTS:
      DECLARE
        NB_STRUC_CHILD	: ATTR_NBR	:= 0;
	     
        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_NON_STRUCT_ATTR
        PROCEDURE PRINT_NON_STRUCT_ATTR ( A_SUB :INTEGER; T :TREE; IND :INTEGER; PARENT :TREE) IS	--| IMPRESSION SANS DETAIL DES SOUS ARBRES (PRINT_TREE)
        BEGIN
if debug_pretty then put_line( "print_non_struct_attr" ); end if;

	IF T = TREE_VOID OR ELSE T = TREE_VIRGIN THEN
	  PUT( "^" & NODE_NAME'IMAGE( T.TY ) ); RETURN;
	END IF;
	IF T.PT = S  THEN PUT( "c" & SRCCOL_IDX'IMAGE( T.COL ) ); RETURN; END IF;
	IF T.PT = HI THEN PUT( "#" & NODE_NAME'IMAGE( T.NOTY ) ); RETURN; END IF;

	INDENT( IND );
	PUT( ATTRIBUTE_NAME'IMAGE( A_SPEC( A_SUB ).ATTR ) );
	     
	IF NOT A_SPEC( A_SUB ).IS_LIST AND THEN T.TY /= DN_LIST THEN			--| PAS UNE LISTE
	  PUT(": ");
	  IF T.PG > 0 AND THEN T.TY = DN_REAL_VAL THEN
	    PRINT_TREE( D( XD_NUMER,T ) ); PUT( '/' ); PRINT_TREE( D( XD_DENOM, T ) );
	  ELSE
	    PRINT_TREE( T );
	  END IF;

	  IF T.PG > 0 AND THEN T.TY = DN_SYMBOL_REP THEN
	    PUT( ' ' & PRINT_NAME( T ) );
	  END IF;

	ELSE									--| UNE LISTE
IMPRIME_UNE_LISTE:
	  DECLARE
	    SQ	:  SEQ_TYPE	:= ( FIRST=> T, NEXT=> TREE_NIL );
	    E	: TREE;
	  BEGIN
	    PUT( ": { " ); 
	    while not IS_EMPTY( SQ ) loop
	      POP( SQ, E ); INDENT( IND ); PRINT_TREE( E );
	    end loop;
	    PUT( " }" );
	  END IMPRIME_UNE_LISTE;

	END IF;
        END PRINT_NON_STRUCT_ATTR;
        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_STRUCT_ATTR
        PROCEDURE PRINT_STRUCT_ATTR ( A_SUB : INTEGER; T : TREE; IND :INTEGER; PARENT : TREE ) IS	--| IMPRESSION AVEC DETAIL DES SOUS ARBRES (PRINT_DIANA)
	ATNBR	: ATTRIBUTE_NAME	:= A_SPEC( A_SUB ).ATTR;
        BEGIN

	IF T = TREE_VOID OR ELSE T = TREE_VIRGIN THEN
	  PUT( "^" & NODE_NAME'IMAGE( T.TY ) ); RETURN;
	END IF;
	IF T.PT = S  THEN PUT( "c" & SRCCOL_IDX'IMAGE( T.COL ) ); RETURN; END IF;
	IF T.PT = HI THEN PUT( "#" & NODE_NAME'IMAGE( T.NOTY ) ); RETURN; END IF;

if debug_pretty then put_line( "print_struct_attr" ); end if;

	IF T.PT = P AND THEN T.TY IN CLASS_STANDARD_IDL AND THEN NOT A_SPEC( A_SUB ).IS_LIST THEN
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	  RETURN;
	ELSIF T.PT = P AND THEN T.TY = DN_REAL_VAL THEN
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	  RETURN;
	END IF;
	     
	INDENT( IND );
	PUT( ATTRIBUTE_NAME'IMAGE( ATNBR ) );

	IF NOT A_SPEC( A_SUB ).IS_LIST THEN						--| PAS UNE LISTE
	  IF T.PT = S THEN
	    PUT( ": " ); PRINT_TREE( T );
	  ELSE
	    PUT( ": ") ; PRINT_DIANA( T, IND+2, PARENT );
	  END IF;

	ELSE


IMPRIME_LISTE_DETAILLEE:								--| UNE LISTE
	  DECLARE
	    SQ	: SEQ_TYPE	:= ( FIRST=> T, NEXT=> TREE_NIL );
	  BEGIN
	    IF IS_EMPTY( SQ ) THEN PUT( ": {}" );
	    ELSE
	      DECLARE
	        HD	: TREE	:= HEAD( SQ );
	      BEGIN
	        IF IS_EMPTY( TAIL( SQ ) ) THEN						--| UN SEUL ELEMENT
		PUT( ": { " ); PRINT_DIANA( HD, IND+2, PARENT ); PUT( " }" );
	        ELSE								--| LISTE GENERALE
	 	PUT( ':' );
	 	INDENT( IND );
	 	PUT( "{ " );
	 	PRINT_DIANA( HD, IND+4, PARENT );
	 	SQ := TAIL( SQ );
	 	WHILE NOT IS_EMPTY( SQ ) LOOP
	 	  INDENT( IND + 2 );
	 	  PRINT_DIANA( HEAD( SQ ), IND+4, PARENT );
	 	  SQ := TAIL( SQ );
		END LOOP;
	 	PUT( " }" );
	        END IF;
	      END;


	    END IF;
	  END IMPRIME_LISTE_DETAILLEE;
	END IF;
        END PRINT_STRUCT_ATTR;
        --|----------------------------------------------------------------------------------------
        --|	PROCEDURE MAYBE_NON_STRUCT_ATTR
        PROCEDURE MAYBE_NON_STRUCT_ATTR ( A_SUB : INTEGER; T : TREE; IND : INTEGER; PARENT, GRAND_PARENT : TREE ) IS
        BEGIN
	IF T.PT = S OR T.PT = HI THEN RETURN; END IF;

if debug_pretty then put( "maybe_non_struct_attr ("
	& "P" & VPG_IDX'image( T.PG ) & " L" & LINE_IDX'image( T.LN ) & ") " );
  if T.PG /= 0 then put( " status=" & STATUS'image( PRINT_STATUS( T.PG )( T.LN ) ) ); end if;
  new_line;
end if;

	IF T.PG = 0 OR ELSE PRINT_STATUS( T.PG )( T.LN ) = NO_PRINT THEN
	  PRINT_NON_STRUCT_ATTR ( A_SUB, T, IND, PARENT );
	ELSE
	  PRINT_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	END IF;
        END MAYBE_NON_STRUCT_ATTR;
        --|----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_IF_NOT_STRUCTURAL
        PROCEDURE PRINT_IF_NOT_STRUCTURAL ( A_SUB : INTEGER; T : TREE; IND : INTEGER; PARENT, GRAND_PARENT : TREE ) IS
        BEGIN
	IF (T.PT = S OR T.PT = HI) OR ELSE T.PG = 0 THEN RETURN; END IF;			--| S HI NIL VOID VIRGIN

if debug_pretty then put_line( "print_if_not_structural" ); end if;

	IF PRINT_STATUS( T.PG )( T.LN ) /= PRINT THEN
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	ELSE
	  MAYBE_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT, GRAND_PARENT );
	END IF;
        END PRINT_IF_NOT_STRUCTURAL;
	          
      BEGIN
 if debug_pretty then put_line( "traiter_les_descendants" ); end if;

       IF (T.PT = P OR T.PT = L) AND THEN T.TY IN CLASS_ALL_SOURCE THEN
	IF ARITY( T ) = ARBITRARY THEN						--| UN ELEMENT DE LISTE
	  NB_STRUC_CHILD := 1;							--| UN SEUL ELEMENT STRUCTUREL D'ARBRE SYNTAXIQUE
	ELSE
	  NB_STRUC_CHILD := ARITIES'POS( ARITY( T ) );					--| AUTANT D'ELEMENTS STRUCTURELS QUE L'ARITE L'INDIQUE
	END IF;
        END IF;
	  
        FOR I IN 1 .. NB_STRUC_CHILD LOOP						--| S'OCCUPER DES DESCENDANTS DE STRUCTURE SYNTAXIQUE (EVENTUELLEMENT)
	IF A_SPEC( A_SUB + INTEGER(I) - 1 ).ATTR /= LX_SRCPOS THEN				--| SI PAS UN SRCPOS
	  MAYBE_NON_STRUCT_ATTR( A_SUB + INTEGER( I ) - 1, DABS ( I, T ), IND, T, PARENT );
	END IF;
        END LOOP;
	 
        FOR I IN NB_STRUC_CHILD + 1 .. N_SPEC( T.TY ).NS_SIZE LOOP				--| APRES LES CHAMPS COMPRIS DANS L'ARITE SYNTAXIQUE D'AUTRE CHAMPS EVENTUELS
	IF A_SPEC( A_SUB + INTEGER( I ) - 1 ).ATTR /= LX_SRCPOS THEN			--| SI PAS UN SRCPOS
	  PRINT_IF_NOT_STRUCTURAL ( A_SUB + INTEGER( I ) - 1, DABS ( I, T ), IND, T, PARENT );
	END IF;
        END LOOP;
      END TRAITER_LES_DESCENDANTS;
         
 if debug_pretty then put_line( "print_diana ok" ); end if;
    END PRINT_DIANA;
      
  BEGIN

    PUT_LINE( "TREE_ROOT=" );    print_node( TREE_ROOT );
    PUT_LINE( "USER_ROOT=" );    print_node( USER_ROOT );

    MARK_STRUCT( COMPLTN_STRUCT );							--| MARQUER LES NOEUDS DE CLASS_ALL_SOURCE
    PRINT_DIANA( COMPLTN_STRUCT, 0, TREE_VOID );
    NEW_LINE;
  END IMPRIME;
   
BEGIN
  OPEN_IDL_TREE_FILE( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );			--| OUVRIR LE FICHIER ARBRE TEMPORAIRE
  CREATE( OFILE, OUT_FILE,"$$$_TREE.TXT" );						--| CREER LE FICHIER IMPRESSION DE L'ARBRE
  SET_OUTPUT( OFILE );								--| REDIRIGER LA SORTIE STANDARD VERS LE FICHIER IMPRESSION
  IMPRIME;									--| IMPRIMER L'ARBRE
  SET_OUTPUT( STANDARD_OUTPUT );							--| REPOSITIONNER LA SORTIE STANDARD
  CLOSE( OFILE );									--| FERMER LE FICHIER IMPRESSION
  CLOSE_IDL_TREE_FILE;								--| FERMER LE FICHIER ARBRE
      
EXCEPTION
  WHEN OTHERS => 									--| POUR TOUT PROBLEME
    SET_OUTPUT( STANDARD_OUTPUT );							--| REPOSITIONNER LA SORTIE STANDARD
    CLOSE( OFILE );									--| FERMER LE FICHIER IMPRESSION
    CLOSE_IDL_TREE_FILE;								--| FERMER LE FICHIER ARBRE
    RAISE;
END PRETTY_DIANA;
