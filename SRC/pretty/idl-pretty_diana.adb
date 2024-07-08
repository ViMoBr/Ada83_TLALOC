separate( IDL )
--|-------------------------------------------------------------------------------------------------

			--	PRETTY_DIANA	--

--|-------------------------------------------------------------------------------------------------
procedure PRETTY_DIANA ( OPTION :CHARACTER := 'U' ) is
  OFILE		: FILE_TYPE;							--| LE FICHIER DE SORTIE IMPRESSION

  DEBUG_PRETTY	: BOOLEAN		:= FALSE;
  --|-----------------------------------------------------------------------------------------------

  --	IMPRIME	--

  --|-----------------------------------------------------------------------------------------------
  procedure IMPRIME is
      
    LAST_PAGE		: VPG_IDX	:= VPG_IDX( DI ( XD_HIGH_PAGE, TREE_ROOT ) );
         
    type STATUS		is ( PRINT, PRINT_AS, NO_PRINT );				--| MARQUAGE DE LIGNE DE PAGE : IMPRIMER, IMPRIMER COMME ALL_SOURCE, LAISSER
    type PRINT_STATUS_VECTOR	is array( LINE_IDX ) of STATUS;				--| VECTEUR MARQUAGE D UNE PAGE
    type PRINT_STATUS_ARRAY	is array( 1 .. LAST_PAGE ) of PRINT_STATUS_VECTOR;		--| MARQUAGE DE TOUS LES TREES DU FICHIER ARBRE (INDICAGE PAR PAGE ET LIGNE)
      
    PRINT_STATUS		: PRINT_STATUS_ARRAY	:= (others => (others => PRINT) );
    USER_ROOT		: TREE			:= D( XD_USER_ROOT, TREE_ROOT );
    COMPLTN_STRUCT		: TREE			:= D( XD_STRUCTURE, USER_ROOT );

    --|-----------------------------------------------------------------------------------------------

    --		INDENT	--

    --|-----------------------------------------------------------------------------------------------
    procedure INDENT ( IND :INTEGER ) is
      I	: INTEGER := IND;
    begin
      NEW_LINE;									--| SE FAIT SUR UNE NOUVELLE LIGNE
      while I >= 8 loop
        PUT ( "      | " );								--| UNE SUITE DE 8 CARACTERES AVEC UN | A 7
        I := I - 8;									--| 8 DE MOINS
      end loop;
      for N in 1 .. I loop PUT ( ' ' ); end loop;						--| RELIQUAT DE BLANCS
    end INDENT; 
    --|---------------------------------------------------------------------------------------------

    --		MARK_STRUCT	--

    --|---------------------------------------------------------------------------------------------
    procedure MARK_STRUCT ( T :TREE ) is						--| MARQUE EN PRINT_AS LES TREES DE LA CATEGORIE "ALL_SOURCE"
    begin
      if T = TREE_VOID or else T = TREE_NIL or else T = TREE_VIRGIN or else T.PT = HI		--| TREE VERS UN NOEUD SANS ATTRIBUT OU REPRESENTANT UN ENTIER 16 BITS NEGATIF OU UNE POSITION SOURCE
         or else ( (T.PT=P or T.PT=L) and then PRINT_STATUS( T.PG )( T.LN ) /= PRINT) then	--| DEJA MARQUE
        return;									--| NE RIEN FAIRE
      end if;

      if T.PT = P or T.PT = L then  
        PRINT_STATUS( T.PG )( T.LN ) := PRINT_AS;						--| INITIALISER EN MARQUER EN A IMPRIMER ELEMENT "AS_"
        if T.TY in CLASS_ALL_SOURCE then						--| TYPE DANS LA CLASSE ELEMENTS DE CODE SOURCE
	  
	if ARITY( T ) = ARBITRARY then						--| ARITE QUELCONQUE : LISTE
	  declare
	    ITEM_LIST	: SEQ_TYPE	:= LIST( T );				--| AMENER LA LISTE POINTEE
	    ITEM		: TREE;
	  begin
	    while not IS_EMPTY( ITEM_LIST ) loop					--| TANT QUE PAS VIDE
	      POP( ITEM_LIST, ITEM );							--| EXTRAIRE UN POINTEUR DE LA LISTE
	      MARK_STRUCT( ITEM );							--| FAIRE LE MARQUAGE EN SUIVANT CE POINTEUR
	    end loop;
	  end;
	        
	else									--| ARITE DEFINIE
	  for I in 1..ATTR_NBR( ARITIES'POS( ARITY( T ) ) ) loop				--| POUR TOUS LES CHAMPS
	    MARK_STRUCT( DABS( I, T ) );						--| FAIRE LE MARQUAGE EN SUIVANT LE POINTEUR DU CHAMP
	  end loop;
	end if;
	  
        end if;
      end if;
    end MARK_STRUCT;
    --|---------------------------------------------------------------------------------------------

    --		PRINT_DIANA	--

    --|---------------------------------------------------------------------------------------------
    procedure PRINT_DIANA ( T : TREE; IND : NATURAL; PARENT :TREE ) is
      A_SUB	: INTEGER;
    begin
if debug_pretty then put_line( "print_diana" ); end if;

--..................................................................................................

--		IMPRESSION AU BESOIN DU POINTEUR DE NOEUD

--..................................................................................................
      PRINT_NOD.PRINT_TREE( T );							--| IMPRIMER LE POINTEUR D'ARBRE
	  
      if T = TREE_VOID or else T = TREE_NIL or else T = TREE_VIRGIN
	or else T.PT = HI or else T.PT = S then						--| UN SOURCELINE OU UN ENTIER 16 BITS NEGATIF OU UN POINTEUR NIL
        return;									--| FINI
      end if;
         
      A_SUB := N_SPEC( T.TY ).NS_FIRST_A;
      if T.TY in CLASS_ALL_SOURCE then							--| NOEUD STRUCTUREL
--..................................................................................................

--		IMPRESSION DE LA POSITION SOURCE DU NOEUD

--..................................................................................................
IMPRIME_POSITION_SOURCE:
        declare
	SPOS	: TREE	:= D( LX_SRCPOS, T );	  				--| POSITION SOURCE : (LIGNE,COL)
        begin
	PUT ( " SLOC(" );
	if SPOS.PT = S and then SPOS.COL in 1 .. 254 then
	  declare
	    IML : constant STRING	:= INTEGER'IMAGE( DI( XD_NUMBER, GET_SOURCE_LINE( SPOS ) ) );
	    IMC : constant STRING	:= SRCCOL_IDX'IMAGE( GET_SOURCE_COL( SPOS ) );
	  begin
	    PUT( IML( 2..IML'LENGTH ) & "," & IMC( 2..IMC'LENGTH ) );
	  end;
	else
	  PRINT_TREE( SPOS );
	end if;
	PUT( ')' );
        end IMPRIME_POSITION_SOURCE;
--..................................................................................................

--		IMPRESSION AU BESOIN DU NOM DE NOEUD

--..................................................................................................
        if T.TY in CLASS_SOURCE_NAME then						--| CHOSES QUI ONT UN SYMBOLE ASSOCIE
	declare
	  SYMREP		: TREE		:= D( LX_SYMREP, T );
	  DEFLIST		: SEQ_TYPE;
	  DEF		: TREE;
	begin
	  if SYMREP.TY = DN_SYMBOL_REP then
	    DEFLIST := LIST( SYMREP );
	    while not IS_EMPTY( DEFLIST ) loop
	      POP( DEFLIST, DEF );
	      if DEF.TY = DN_DEF and then D( XD_SOURCE_NAME, DEF ) = T then
	        PUT( ' ' ); PRINT_TREE( DEF );
	        PUT( ' ' ); PRINT_TREE( D( XD_REGION_DEF, DEF ) );
	        exit;
	      end if;
	    end loop;
	  end if;
	end;
        end if;
	     
      end if;
--..................................................................................................

--		IMPRESSION EVENTUELLE DU CORPS DE NOEUD

--..................................................................................................
      if PRINT_STATUS( T.PG )( T.LN ) = NO_PRINT then					--| PAS D'IMPRESSION DU NOEUD, RETOUR
        return;
      end if;
	     
      PRINT_STATUS ( T.PG )( T.LN ) := NO_PRINT;						--| MENTIONNER NE PLUS IMPRIMER A L AVENIR
--..................................................................................................

--		CAS SPECIAL DU NOEUD UNITE DE COMPILATION OPTIONS POUR PAGES WITHEES

--..................................................................................................
      if T.TY = DN_COMPILATION_UNIT then						--| CAS SPECIAL DE L'UNITE DE COMPILATION
        declare
	TRANS_WITH_LIST	: SEQ_TYPE	:= LIST( T );				--| LISTE DES WITH
	TRANS_WITH	: TREE;
	COMP_UNIT		: TREE;
        begin
	if TRANS_WITH_LIST.FIRST /= TREE_VIRGIN then					--| TETE DE LISTE NON INITIALISEE : LIB_PHASE NON FAITE

if debug_pretty then put_line( "dn_compilation_unit trans_with_list" ); end if;

	  while not IS_EMPTY ( TRANS_WITH_LIST ) loop
	    POP ( TRANS_WITH_LIST, TRANS_WITH );					--| EXTRAIRE UN ELEMENT DE LISTE WITH
	 	
	    COMP_UNIT := D( TW_COMP_UNIT, TRANS_WITH );
	    if D( XD_NBR_PAGES, COMP_UNIT ) /= TREE_VIRGIN then
	      for I in COMP_UNIT.PG .. COMP_UNIT.PG + PAGE_IDX( DI( XD_NBR_PAGES, COMP_UNIT ) ) - 1 loop
	        declare
	          PS : STATUS := NO_PRINT;
	        begin
	          if OPTION = 'P' then PS := PRINT_AS; elsif OPTION = 'A' then PS := PRINT; end if;
	          PRINT_STATUS( I ) := (others => PS);					--| IMPRIMER SUIVANT OPTION
	        end;
	      end loop;
	    end if;
	  end loop;

	end if;
        end;
      end if;
--..................................................................................................

--		IMPRESSION DU CONTENU DE NOEUD (DESCENDANTS)

--..................................................................................................
TRAITER_LES_DESCENDANTS:
      declare
        NB_STRUC_CHILD	: ATTR_NBR	:= 0;
	     
        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_NON_STRUCT_ATTR
        procedure PRINT_NON_STRUCT_ATTR ( A_SUB :INTEGER; T :TREE; IND :INTEGER; PARENT :TREE) is	--| IMPRESSION SANS DETAIL DES SOUS ARBRES (PRINT_TREE)
        begin
if debug_pretty then put_line( "print_non_struct_attr" ); end if;

	if T = TREE_VOID or else T = TREE_VIRGIN then
	  PUT( "^" & NODE_NAME'IMAGE( T.TY ) ); return;
	end if;
	if T.PT = S  then PUT( "c" & SRCCOL_IDX'IMAGE( T.COL ) ); return; end if;
	if T.PT = HI then PUT( "#" & NODE_NAME'IMAGE( T.NOTY ) ); return; end if;

	INDENT( IND );
	PUT( ATTRIBUTE_NAME'IMAGE( A_SPEC( A_SUB ).ATTR ) );
	     
	if not A_SPEC( A_SUB ).IS_LIST and then T.TY /= DN_LIST then			--| PAS UNE LISTE
	  PUT(": ");
	  if T.PG > 0 and then T.TY = DN_REAL_VAL then
	    PRINT_TREE( D( XD_NUMER,T ) ); PUT( '/' ); PRINT_TREE( D( XD_DENOM, T ) );
	  else
	    PRINT_TREE( T );
	  end if;

	  if T.PG > 0 and then T.TY = DN_SYMBOL_REP then
	    PUT( ' ' & PRINT_NAME( T ) );
	  end if;

	else									--| UNE LISTE
IMPRIME_UNE_LISTE:
	  declare
	    SQ	:  SEQ_TYPE	:= ( FIRST=> T, NEXT=> TREE_NIL );
	    E	: TREE;
	  begin
	    PUT( ": { " ); 
	    while not IS_EMPTY( SQ ) loop
	      POP( SQ, E ); INDENT( IND ); PRINT_TREE( E );
	    end loop;
	    PUT( " }" );
	  end IMPRIME_UNE_LISTE;

	end if;
        end PRINT_NON_STRUCT_ATTR;
        --|-----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_STRUCT_ATTR
        procedure PRINT_STRUCT_ATTR ( A_SUB : INTEGER; T : TREE; IND :INTEGER; PARENT : TREE ) is	--| IMPRESSION AVEC DETAIL DES SOUS ARBRES (PRINT_DIANA)
	ATNBR	: ATTRIBUTE_NAME	:= A_SPEC( A_SUB ).ATTR;
        begin

	if T = TREE_VOID or else T = TREE_VIRGIN then
	  PUT( "^" & NODE_NAME'IMAGE( T.TY ) ); return;
	end if;

	if T.PT = S  then PUT( "c" & SRCCOL_IDX'IMAGE( T.COL ) ); return; end if;
	if T.PT = HI then PUT( "#" & NODE_NAME'IMAGE( T.NOTY ) ); return; end if;

if debug_pretty then put_line( "print_struct_attr" ); end if;

	if T.PT = P and then T.TY in CLASS_STANDARD_IDL and then not A_SPEC( A_SUB ).IS_LIST then
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	  return;
	elsif T.PT = P and then T.TY = DN_REAL_VAL then
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	  return;
	end if;
	     
	INDENT( IND );
	PUT( ATTRIBUTE_NAME'IMAGE( ATNBR ) );

	if not A_SPEC( A_SUB ).IS_LIST then						--| PAS UNE LISTE
	  if T.PT = S then
	    PUT( ": " ); PRINT_TREE( T );
	  else
	    PUT( ": ") ; PRINT_DIANA( T, IND+2, PARENT );
	  end if;

	else


IMPRIME_LISTE_DETAILLEE:								--| UNE LISTE
	  declare
	    SQ	: SEQ_TYPE	:= ( FIRST=> T, NEXT=> TREE_NIL );
	  begin
	    if IS_EMPTY( SQ ) then PUT( ": {}" );
	    else
	      declare
	        HD	: TREE	:= HEAD( SQ );
	      begin
	        if IS_EMPTY( TAIL( SQ ) ) then						--| UN SEUL ELEMENT
		PUT( ": { " ); PRINT_DIANA( HD, IND+2, PARENT ); PUT( " }" );
	        else								--| LISTE GENERALE
	 	PUT( ':' );
	 	INDENT( IND );
	 	PUT( "{ " );
	 	PRINT_DIANA( HD, IND+4, PARENT );
	 	SQ := TAIL( SQ );
	 	while not IS_EMPTY( SQ ) loop
	 	  INDENT( IND + 2 );
	 	  PRINT_DIANA( HEAD( SQ ), IND+4, PARENT );
	 	  SQ := TAIL( SQ );
		end loop;
	 	PUT( " }" );
	        end if;
	      end;


	    end if;
	  end IMPRIME_LISTE_DETAILLEE;
	end if;
        end PRINT_STRUCT_ATTR;
        --|----------------------------------------------------------------------------------------
        --|	PROCEDURE MAYBE_NON_STRUCT_ATTR
        procedure MAYBE_NON_STRUCT_ATTR ( A_SUB : INTEGER; T : TREE; IND : INTEGER; PARENT, GRAND_PARENT : TREE ) is
        begin
	if T.PT = S or T.PT = HI then return; end if;

if debug_pretty then put( "maybe_non_struct_attr ("
	& "P" & VPG_IDX'image( T.PG ) & " L" & LINE_IDX'image( T.LN ) & ") " );
  if T.PG /= 0 then put( " status=" & STATUS'image( PRINT_STATUS( T.PG )( T.LN ) ) ); end if;
  new_line;
end if;

	if T.PG = 0 or else PRINT_STATUS( T.PG )( T.LN ) = NO_PRINT then
	  PRINT_NON_STRUCT_ATTR ( A_SUB, T, IND, PARENT );
	else
	  PRINT_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	end if;
        end MAYBE_NON_STRUCT_ATTR;
        --|----------------------------------------------------------------------------------------
        --|	PROCEDURE PRINT_IF_NOT_STRUCTURAL
        procedure PRINT_IF_NOT_STRUCTURAL ( A_SUB : INTEGER; T : TREE; IND : INTEGER; PARENT, GRAND_PARENT : TREE ) is
        begin

	if T.PT = HI then
	  INDENT( IND );
	  PUT( ATTRIBUTE_NAME'IMAGE( A_SPEC( A_SUB ).ATTR ) );
	  PUT( ": HI noty=" & NODE_NAME'IMAGE( T.NOTY ) & " abss=" & POSITIVE_SHORT'IMAGE( T.ABSS ) & " nsiz=" & ATTR_NBR'IMAGE( T.NSIZ ) );
	  return;
	end if;

	if T.PT = S or else T.PG = 0 then						--| S NIL VOID VIRGIN
	  return;
	end if;

if debug_pretty then put_line( "print_if_not_structural" ); end if;

	if PRINT_STATUS( T.PG )( T.LN ) /= PRINT then
	  PRINT_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT );
	else
	  MAYBE_NON_STRUCT_ATTR( A_SUB, T, IND, PARENT, GRAND_PARENT );
	end if;
        end PRINT_IF_NOT_STRUCTURAL;
	          
      begin
 if debug_pretty then put_line( "traiter_les_descendants" ); end if;

        if (T.PT = P or T.PT = L) and then T.TY in CLASS_ALL_SOURCE then
	if ARITY( T ) = ARBITRARY then						--| UN ELEMENT DE LISTE
	  NB_STRUC_CHILD := 1;							--| UN SEUL ELEMENT STRUCTUREL D'ARBRE SYNTAXIQUE
	else
	  NB_STRUC_CHILD := ARITIES'POS( ARITY( T ) );					--| AUTANT D'ELEMENTS STRUCTURELS QUE L'ARITE L'INDIQUE
	end if;
        end if;
	  
        for I in 1 .. NB_STRUC_CHILD loop						--| S'OCCUPER DES DESCENDANTS DE STRUCTURE SYNTAXIQUE (EVENTUELLEMENT)
	if A_SPEC( A_SUB + INTEGER(I) - 1 ).ATTR /= LX_SRCPOS then				--| SI PAS UN SRCPOS
	  MAYBE_NON_STRUCT_ATTR( A_SUB + INTEGER( I ) - 1, DABS ( I, T ), IND, T, PARENT );
	end if;
        end loop;
	 
        for I in NB_STRUC_CHILD + 1 .. N_SPEC( T.TY ).NS_SIZE loop				--| APRES LES CHAMPS COMPRIS DANS L'ARITE SYNTAXIQUE D'AUTRE CHAMPS EVENTUELS
	if A_SPEC( A_SUB + INTEGER( I ) - 1 ).ATTR /= LX_SRCPOS then			--| SI PAS UN SRCPOS
	  PRINT_IF_NOT_STRUCTURAL ( A_SUB + INTEGER( I ) - 1, DABS ( I, T ), IND, T, PARENT );
	end if;
        end loop;
      end TRAITER_LES_DESCENDANTS;
         
 if debug_pretty then put_line( "print_diana ok" ); end if;
    end PRINT_DIANA;
      
  begin

    PUT_LINE( "TREE_ROOT=" );    print_node( TREE_ROOT );
    PUT_LINE( "USER_ROOT=" );    print_node( USER_ROOT );

    MARK_STRUCT( COMPLTN_STRUCT );							--| MARQUER LES NOEUDS DE CLASS_ALL_SOURCE
    PRINT_DIANA( COMPLTN_STRUCT, 0, TREE_VOID );
    NEW_LINE;
  end IMPRIME;
   
begin
  OPEN_IDL_TREE_FILE( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );			--| OUVRIR LE FICHIER ARBRE TEMPORAIRE
  CREATE( OFILE, OUT_FILE,"$$$_TREE.TXT" );						--| CREER LE FICHIER IMPRESSION DE L'ARBRE
  SET_OUTPUT( OFILE );								--| REDIRIGER LA SORTIE STANDARD VERS LE FICHIER IMPRESSION
  IMPRIME;									--| IMPRIMER L'ARBRE
  SET_OUTPUT( STANDARD_OUTPUT );							--| REPOSITIONNER LA SORTIE STANDARD
  CLOSE( OFILE );									--| FERMER LE FICHIER IMPRESSION
  CLOSE_IDL_TREE_FILE;								--| FERMER LE FICHIER ARBRE
      
exception
  when others => 									--| POUR TOUT PROBLEME
    SET_OUTPUT( STANDARD_OUTPUT );							--| REPOSITIONNER LA SORTIE STANDARD
    CLOSE( OFILE );									--| FERMER LE FICHIER IMPRESSION
    CLOSE_IDL_TREE_FILE;								--| FERMER LE FICHIER ARBRE
    raise;
end PRETTY_DIANA;
