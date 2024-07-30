with UNCHECKED_CONVERSION;
separate (IDL)
--|-------------------------------------------------------------------------------------------------
--|			IDL_MAN
--|-------------------------------------------------------------------------------------------------
package body IDL_MAN is
   
  TREE_HASH	: TREE		:= (P, TY=> DN_HASH, PG=> 2, LN=> 0 );
   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION ARITY
--|
function ARITY ( T :TREE ) return ARITIES is
begin 
  return N_SPEC( T.TY ).NS_ARITY;							--| RETOURNER L'ARITE SUIVANT LES SPECIFS DU TYPE DE NOEUD ARBRE
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_1
--|
function SON_1 ( T :TREE ) return TREE is
begin
  if N_SPEC( T.TY ).NS_ARITY in UNARY .. TERNARY then					--| SI L'ARITE LE PERMET
    return DABS ( 1, T );								--| RETOURNER LE PREMIER SOUS ARBRE DE T
  end if;
         
  PUT_LINE ( "IDL.IDL_MAN.SON_1 : PAS DE FILS 1 LISIBLE POUR " & NODE_REP ( T ) );
  raise PROGRAM_ERROR;
end SON_1;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_1
--|
procedure SON_1 ( T :TREE; V :TREE ) is
begin
  if N_SPEC( T.TY ).NS_ARITY in UNARY .. TERNARY then					--| SI L'ARITE LE PERMET
    DABS ( 1, T, V );								--| STOCKER V COMME PREMIER SOUS ARBRE DE T
  else
    PUT_LINE ( "IDL.IDL_MAN.SON_1 : PAS DE FILS 1 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;            
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_2
--|
function SON_2 ( T :TREE ) return TREE is
begin
  if N_SPEC( T.TY ).NS_ARITY in BINARY .. TERNARY then
    return DABS ( 2, T );
  end if;

  PUT_LINE ( "IDL.IDL_MAN.SON_2 : PAS DE FILS 2 LISIBLE POUR " & NODE_REP ( T ) );
  raise PROGRAM_ERROR;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_2
--|
procedure SON_2 ( T :TREE; V :TREE ) is
begin
  if N_SPEC( T.TY ).NS_ARITY in BINARY .. TERNARY then
    DABS ( 2, T, V );
  else
    PUT_LINE ( "IDL.IDL_MAN.SON_2 : PAS DE FILS 2 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;            
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SON_3
--|
function SON_3 ( T :TREE ) return TREE is
begin
  if N_SPEC( T.TY ).NS_ARITY = TERNARY then
    return DABS(3, T);
  end if;

  PUT_LINE ( "IDL.IDL_MAN.SON_3 : PAS DE FILS 3 LISIBLE POUR " & NODE_REP ( T ) );
  raise PROGRAM_ERROR;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SON_3
--|
procedure SON_3 ( T :TREE; V :TREE ) is
begin
  if N_SPEC( T.TY ).NS_ARITY = TERNARY then
    DABS ( 3, T, V );
  else
    PUT_LINE ( "IDL.IDL_MAN.SON_3 : PAS DE FILS 3 INSCRIPTIBLE POUR " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION HEAD
--|
function HEAD ( S :SEQ_TYPE ) return TREE is
begin
  if S.FIRST.TY = DN_LIST then							--| LA SEQ CONTIENT UNE LISTE
    return DABS ( 1, S.FIRST );							--| RENDRE LE PREMIER CHAMP DU NOEUD LISTE
  elsif S.FIRST /= TREE_NIL then							--| LA SEQ CONTIENT UN ELEMENT
    return S.FIRST;									--| RENDRE CELUI-CI
  end if;
            
  PUT_LINE ( "IDL.IDL-MAN.HEAD : TETE DE SEQUENCE SEQ.FIRST = TREE_NIL !" );
  raise PROGRAM_ERROR;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION TAIL
--|
function TAIL ( S :SEQ_TYPE ) return SEQ_TYPE is						--| RETOURNE UN SEQ SUITE DE LISTE
begin
  if S.FIRST.TY = DN_LIST then							--| LISTE A PLUSIEURS ELEMENTS
    declare
      QUEUE :  SEQ_TYPE	:= ( FIRST=> DABS ( 2, S.FIRST ) , NEXT=> TREE_NIL );		--| TETE DE QUEUE ET RIEN
    begin
      if QUEUE.FIRST.TY = DN_LIST then							--| SI TETE INDIQUANT UNE LISTE AVEC UNE SUITE
        QUEUE.NEXT := S.NEXT;								--| LA SUITE DE LA QUEUE EST RENDUE
      end if;
      return QUEUE;
    end;
  elsif S.FIRST /= TREE_NIL then							--| LISTE A UN SEUL ELEMENT
    return ( TREE_NIL, TREE_NIL );							--| RETOURNER UN SEQ VIDE
  end if;
            
  PUT_LINE ( "IDL.IDL-MAN.TAIL : LISTE VIDE S.FIRST = TREE_NIL !" );
  raise PROGRAM_ERROR;
end TAIL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION INSERT
--|
function INSERT ( S :SEQ_TYPE; T :TREE ) return SEQ_TYPE is					--| INSERTION D'UN SEQ EN TETE DE SEQUENCE
begin
  if S.FIRST = TREE_NIL then								--| SEQUENCE VIDE
    return (FIRST=> T , NEXT=> TREE_NIL );						--| RETOURNER UN SEQ A UN ELEMENT
  end if;
      
  declare										--| LE SEQ INITIAL ETAIT NON VIDE
    T_SEQ		: SEQ_TYPE	:= ( FIRST=> MAKE ( DN_LIST ) , NEXT=> S.NEXT );		--| NOUVELLE SEQUENCE
  begin
    DABS ( 1, T_SEQ.FIRST, T );							--| TETE DE SEQUENCE SUR T
    DABS ( 2, T_SEQ.FIRST, S.FIRST );							--| SUITE CONSTITUEE PAR LE DEBUT DE S
            
    if S.NEXT = TREE_NIL then								--| SI S NE CONTIENT QU'UN ELEMENT
      T_SEQ.NEXT := T_SEQ.FIRST;							--| LA SUITE EST CONFONDUE AVEC LE PREMIER ELEMENT
    end if;
            
    return T_SEQ;
  end;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION APPEND
--|
function APPEND ( S :SEQ_TYPE; T :TREE ) return SEQ_TYPE is
  T_SEQ		: SEQ_TYPE;
begin
  if S.FIRST = TREE_NIL then								--| LISTE VIDE
    return ( FIRST=> T , NEXT=> TREE_NIL );						--| SEQUENCE T EN TETE RIEN DERRIERE
               
  elsif S.FIRST.TY /= DN_LIST then							--| SEQUENCE A 1 ELEMENT (PAS DE LISTE EN S.FIRST)
    T_SEQ.FIRST  := MAKE ( DN_LIST );							--| FABRIQUER UNE LISTE
    DABS ( 1, T_SEQ.FIRST, S.FIRST );							--| L'ELEMENT DE S EST EN TETE
    DABS ( 2, T_SEQ.FIRST, T );							--| T SUIT EN FIN
    T_SEQ.NEXT := T_SEQ.FIRST;							--| SEQUENCE TETE ET SUITE CONFONDUES
               
  else										--| S EST UNE LISTE A PLUS D'UN ELEMENT
    declare
      T_TAIL	: TREE		:= S.NEXT;
      T_END	: TREE;
    begin
      if S.NEXT = TREE_NIL then							--| LA SEQUENCE S N'A QU'UNE TETE
        T_TAIL := S.FIRST;								--| LA QUEUE EST LE DEBUT
      end if;
      loop
        T_END := DABS ( 2, T_TAIL );							--| TREE DE FIN DE S
        exit when T_END.TY /= DN_LIST;							--| SORTIE EN FIN DE LISTE (SIMPLE POINTEUR A UN ELEMENT)
        T_TAIL := T_END;								--| SUIVRE LA LISTE
      end loop;
      T_SEQ.FIRST := S.FIRST;
      T_SEQ.NEXT := MAKE ( DN_LIST );							--| FABRIQUER UN ELEMENT DE LISTE
      DABS ( 1, T_SEQ.NEXT, T_END );							--| TETE DE LISTE
      DABS ( 2, T_SEQ.NEXT, T );							--| QUEUE DE LISTE
      DABS ( 2, T_TAIL, T_SEQ.NEXT );							--| CHAINAGE
    end;
  end if;
            
  return T_SEQ;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION SINGLETON
--|
function SINGLETON ( T :TREE ) return SEQ_TYPE is
begin
  return ( FIRST=> T , NEXT=> TREE_NIL );
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE LIST
--|
procedure LIST ( T :TREE; S :SEQ_TYPE ) is
  A_IDX		: INTEGER := N_SPEC( T.TY ).NS_FIRST_A;
begin
  for I in 1 .. N_SPEC( T.TY ).NS_SIZE loop						--| PARCOURIR LES ATTRIBUTS
    if A_SPEC( A_IDX ).IS_LIST then							--| SI ATTRIBUT LISTE RENCONTRE
      DABS ( I, T, S.FIRST );								--| STOCKE LA TETE DE V DANS L'ATTRIBUT I DU NOEUD POINTE PAR T
      return;									--| C'EST BON, SORTIR
    end if;
    A_IDX := A_IDX + 1;								--| ATTIBUT SUIVANT
  end loop;
      
  PUT_LINE ( "IDL.IDL_MAN.LIST : PAS DE LISTE INSCRIPTIBLE DANS " & NODE_REP ( T ) );
  raise PROGRAM_ERROR;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE DABS
--|
procedure DABS ( RANG :ATTR_NBR; T :TREE; VAL :TREE ) is
  RN		: RPG_IDX;
begin
  if T.PG /= CUR_VP then								--| LA PAGE QUI NOUS INTERESSE N'EST PAS COURANTE
    CUR_VP := T.PG;									--| LA MENTIONNER COMME COURANTE
    RN := ASSOC_PAGE( CUR_VP );							--| SON ASSOCIEE PHYSIQUE EST LA RN
--    IF RN = 0 OR ELSE PAG ( RN ).RECUPERABLE THEN					--| SI ELLE EST FLOTTANTE
    if RN = 0 then									--| SI HORS MEMOIRE
      CUR_RP := READ_PAGE ( CUR_VP );							--| ASSURER LA PAGE PHYSIQUE
    else										--| NON FLOTTANTE
      CUR_RP := RN;									--| PAGE REELLE COURANTE
    end if;
  end if;
         
  PAG( CUR_RP ).DATA.all( T.LN + RANG ) := VAL;						--| ECRIRE
  PAG( CUR_RP ).CHANGED := TRUE;							--| MENTIONNEE CHANGEE (ON Y A ECRIT ! )
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION DABS
--|
function DABS ( RANG :ATTR_NBR; T :TREE ) return TREE is
  RN		: RPG_IDX;
begin
  if T.PG /= CUR_VP then								--| LA PAGE DE T N'EST PAS LA COURANTE
    CUR_VP := T.PG;									--| LA MENTIONNER COMME COURANTE
    RN := ASSOC_PAGE( CUR_VP );							--| PAGE REELLE ASSOCIEE : RN
--    IF RN = 0 OR ELSE PAG( RN ).RECUPERABLE THEN					--| SI ELLE EST FLOTTANTE
    if RN = 0 then									--| SI HORS MEMOIRE
      CUR_RP := READ_PAGE( CUR_VP );							--| ASSURER LA PAGE PHYSIQUE
    else										--| NON FLOTTANTE
      CUR_RP := RN;									--| PAGE REELLE COURANTE
    end if;
  end if;
  return PAG( CUR_RP ).DATA.all( T.LN + RANG );						--| LIRE
end;   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION STORE_TEXT
--|
function STORE_TEXT ( S :STRING ) return TREE is						--| STOCKE UNE REPRESENTATION TEXTE
  NB_TREES	: LINE_IDX
		:= LINE_IDX( ( (S'LENGTH+1) * CHARACTER'SIZE + TREE'SIZE-1) / TREE'SIZE );	--| NOMBRE DE TREES POUR CONTENIR LES CARACTERES DE S ET UN OCTET DE LONGUEUR
  NB_CARS		: NATURAL
		:= NATURAL( NB_TREES ) * TREE'SIZE / CHARACTER'SIZE;
begin
  declare
    TT			: TREE		:= MAKE ( DN_TXTREP, NB_ATTR=> NB_TREES, AR=> 9 );--| FABRIQUER LE NOEUD CONTENANT LE TEXTE
    type TTREES		is array (1..NB_TREES) of TREE;
    subtype LSTR		is STRING (1..NB_CARS);
    function TO_TREES	is new UNCHECKED_CONVERSION ( LSTR, TTREES );
    A_COPIER		: LSTR		:= (others=> ASCII.NUL);
    START			: LINE_IDX		:= TT.LN;
    TTR			: TTREES;
  begin
    A_COPIER( 1..S'LENGTH+1 ) := CHARACTER'VAL ( S'LENGTH ) & S;
    TTR := TO_TREES ( A_COPIER );
    for I in 1..NB_TREES loop
      PAG( CUR_RP).DATA.all( START+I ) :=  TTR( I );
    end loop;
    PAG( CUR_RP ).CHANGED := TRUE;							--| MENTIONNEE CHANGEE (ON Y A ECRIT ! )
    return TT;
  end;
end;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION HASH_SEARCH
--|
function HASH_SEARCH ( S :STRING ) return TREE is
  NB_TREES		: ATTR_NBR
		:= ATTR_NBR( ( (S'LENGTH+1) * CHARACTER'SIZE + TREE'SIZE-1) / TREE'SIZE );	--| NOMBRE DE TREES POUR CONTENIR LES CARACTERES DE S ET UN OCTET DE LONGUEUR
  NB_CARS		: NATURAL
		:= NATURAL( NB_TREES ) * TREE'SIZE / CHARACTER'SIZE;
  type TTREES		is array ( 1 .. NB_TREES ) of TREE;
  subtype LSTR		is STRING ( 1 .. NB_CARS );					--| CHAINE DE S AVEC UN OCTET DE LONGUEUR
  function TO_TREES		is new UNCHECKED_CONVERSION ( LSTR, TTREES );			--| CONVERSION DE LA CHAINE EN TABLEAU DE TREES
  TTR			: TTREES;							--| VARIABLE CONVERTIE
  A_COPIER		: LSTR		:= (others=> ASCII.NUL);
         
  HASH_SUM		: INTEGER := 0;						--| VALEUR DE HACHAGE
  function TO_INT		is new UNCHECKED_CONVERSION( TREE, INTEGER );
         
begin
  A_COPIER( 1 .. S'LENGTH+1 ) := CHARACTER'VAL( S'LENGTH ) & S;
  TTR := TO_TREES( A_COPIER );							--| VARIABLE CONVERTIE
      
  for I in 1 .. NB_TREES loop								--| BOUCLE DE CALCUL DE LA VALEUR DE HACHAGE
    HASH_SUM := abs( HASH_SUM - TO_INT( TTR( I ) ) );
  end loop;
        
  declare
    BUCKET	: LINE_IDX	:= LINE_IDX( (HASH_SUM mod INTEGER( LINE_IDX'LAST )) + 1 );	--| SEAU DE HACHAGE (INDICE DANS LE BLOC DES TETES DE LISTE)
    HASH_LIST	: SEQ_TYPE	:= ( FIRST=> DABS ( BUCKET, TREE_HASH ) , NEXT=> TREE_NIL );--| TETE DE LISTE HACHEE
  begin
    while HASH_LIST.FIRST /= TREE_NIL loop						--| SUIVRE LA LISTE DU SEAU
      declare
        SYM_T	: TREE		:= HEAD( HASH_LIST );				--| POINTEUR SYMBOL_REP
        TXT_T	: TREE		:= DABS( 1, SYM_T );				--| LE POINTEUR TXTREP AU NOEUD CONTENANT LE TEXTE
      begin
        if DABS( 0, TXT_T ).NSIZ = NB_TREES then						--| SI LA LONGUEUR DU BLOC CORRESPOND A CELLE DU CONVERTI
          declare
            IS_MATCH	: BOOLEAN		:= TRUE;					--| SUPPOSER QUE CELA VA MARCHER
            START		: LINE_IDX	:= TXT_T.LN;				--| INDICE DE L'ENTETE DU BLOC CONTENANT LE TEXTE A TESTER
            RPG_RP		: RPG_DATA renames PAG( CUR_RP );				--| LA PAGE CONCERNEE
          begin
            for I in 1 .. NB_TREES loop							--| POUR TOUS LES TREES COUVRANT LE TEXTE
              if TTR( I ) /=  RPG_RP.DATA.all( START+I ) then				--| DEUX MORCEAUX DE TEXTE DIFFERENTS
                IS_MATCH := FALSE;							--| DESACCORD
                exit;
              end if;
            end loop;
                     
            if IS_MATCH then								--| ACCORD
              return SYM_T;								--| RETOURNER LE SYMBOLE TROUVE
            end if;
          end;
        end if;
        HASH_LIST := TAIL( HASH_LIST );							--| CONTINUER SUR LE RESTE DE LA LISTE
      end;
    end loop;
    return (HI, NOTY=> DN_NUM_VAL, ABSS=> 0, NSIZ=> BUCKET  );				--| RETOURNER LE SEAU
  end;
end HASH_SEARCH;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION STORE_SYM
--|
function STORE_SYM ( S :STRING ) return TREE is						--| INSERE UN SYMBOLE ACCESSIBLE A LA RECHERCHE
  TR		: TREE		:= HASH_SEARCH( S );
begin
  if TR.PT /= HI then								--| TROUVE LE SYMBOLE DEJA ENTRE
    return TR;
  else
    declare
      SYMREP : TREE := MAKE ( DN_SYMBOL_REP,
			NB_ATTR=> N_SPEC( DN_SYMBOL_REP ).NS_SIZE, AR=> 8 );
    begin
      DABS ( 1, SYMREP, STORE_TEXT ( S ) );						--| LE TEXTE REPRESENTATIF EN PREMIER CHAMP
      DABS ( 2, SYMREP, TREE_NIL );							--| RIEN EN SECOND CHAMP
      declare
        T_SEQ : SEQ_TYPE := ( FIRST=> DABS( TR.NSIZ, TREE_HASH ) , NEXT=> TREE_NIL );
      begin
        T_SEQ := INSERT( T_SEQ, SYMREP );
        DABS( TR.NSIZ, TREE_HASH, T_SEQ.FIRST );
      end;
      return SYMREP;
    end;
  end if;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION FIND_SYM
--|
function FIND_SYM ( S :STRING ) return TREE is
  T		: TREE		:= HASH_SEARCH ( S );
begin
  if T.PT = HI then									--| TROUVE LE BUCKET MAIS PAS LE SYMBOLE
    T := TREE_VOID;									--| RETOURNE RIEN
  elsif T.TY /= DN_SYMBOL_REP then							--| HASH_SEARCH DOIT RETOURNER UN SYMREP
    PUT_LINE ( "IDL.IDL_MAN.FIND_SYM : HASHSEARCH A TROUVE UN NON SYMBOLE " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;
  return T;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE_SOURCE_POSITION
--|
function MAKE_SOURCE_POSITION ( T: TREE; COL :SRCCOL_IDX ) return TREE is			--| FABRIQUE UN ELEMENT S CONTENANT LA COLONNE AVEC UN POINTEUR DE LIGNE
begin
  if T.TY = DN_SOURCELINE then							--| POINTEUR DE SOURCE_LINE
    return (S, COL=> COL, SPG=> T.PG, SLN=> T.LN );
  else										--| SINON ERREUR
    PUT_LINE ( "IDL.IDL_MAN.MAKE_SOURCE_POSITION : T N'EST PAS UN SOURCE_LINE, C'EST " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION GET_SOURCE_LINE
--|
function GET_SOURCE_LINE ( T :TREE ) return TREE is					--| RAMENE LE POINTEUR DE LIGNE ASSOCIE A UN ELEMENT S
begin
  if T.PT = S then
    return (P, TY=> DN_SOURCELINE, PG=> T.SPG, LN=> T.SLN );
  else
    PUT_LINE ( "IDL.IDL_MAN.GET_SOURCE_LINE : POSITION ERRONEE, NOEUD " & NODE_REP ( T ) );
    raise PROGRAM_ERROR;
  end if;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION GET_SOURCE_COL
--|
function GET_SOURCE_COL ( T :TREE ) return SRCCOL_IDX is
begin
  return T.COL;
end;



				----------
  procedure			EMIT_ERROR		( SP_ARG :TREE; MSG :STRING )
  is
    SP			: TREE		:= SP_ARG;
    SRC_LIN		: TREE;
    ERR_NOD		: TREE		:= MAKE( DN_ERROR );
  begin
    if SP.PT /= S then
      SP := D( LX_SRCPOS, SP );
    end if;
         
    D( XD_SRCPOS, ERR_NOD, SP );
    D( XD_TEXT,   ERR_NOD, STORE_TEXT( MSG ) );
    SRC_LIN := GET_SOURCE_LINE( SP );
    LIST( SRC_LIN, (APPEND( LIST( SRC_LIN ), ERR_NOD ) ) );

--    PUT_LINE( POSITIVE_SHORT'IMAGE( D( XD_NUMBER, SRC_LIN ).ABSS ) & ": " & MSG );

  end	EMIT_ERROR;
	----------


				--===--
  procedure			 ERROR			( T :TREE; MSG :STRING )
  is
  begin
    if PRAGMA_CONTEXT /= TREE_VOID then
      DABS( 3, PRAGMA_CONTEXT, TREE_VOID );
--      D( SM_DEFN, PRAGMA_CONTEXT, TREE_VOID );
      WARNING( T, MSG );
            
    else
      EMIT_ERROR( T, MSG );
      declare
        ERR_CNT_FIELD      : TREE	:= D( XD_ERR_COUNT, TREE_ROOT );
      begin
        ERR_CNT_FIELD.ABSS := ERR_CNT_FIELD.ABSS + 1;
        D( XD_ERR_COUNT, TREE_ROOT, ERR_CNT_FIELD );
      end;
    end if;

  end	 ERROR;
	--===--



				--===--
  procedure			WARNING			( T :TREE; MSG :STRING )
  is
  begin
    EMIT_ERROR( T, "(Warning) " & MSG );

  end	WARNING;
	--===--



--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE
--|
function MAKE ( NN :NODE_NAME; NB_ATTR :ATTR_NBR; AR :AREA_IDX ) return TREE is
  FREE_IDX	: LINE_NBR		:= AREA( AR ).FREE_LINE;			--| EMPLACEMENT UTILISABLE
  NB_FREE		: LINE_NBR		:= LINE_NBR( LINE_IDX'LAST ) - FREE_IDX + 1;	--| NB EMPLACEMENTS LIBRES
  NB_REQUIS	: LINE_NBR		:= LINE_NBR( NB_ATTR ) + 1;			--| NB EMPLACEMENTS DEMANDES (ENTETE+ATTRIBUTS)
begin
--  IF NB_REQUIS > NB_FREE THEN								--| IL N'Y A PAS ASSEZ DE PLACE
    ALLOC_PAGE ( AR, NB_REQUIS );							--| DEMANDER UNE PLACE
    FREE_IDX := AREA( AR ).FREE_LINE;							--| NOMBRE DE LIGNES UTILISEES DANS CETTE PAGE
--  END IF;
  CUR_VP := AREA( AR ).VP;								--| No DE PAGE VIRTUELLE DU LIEU D'INSERTION
  CUR_RP := ASSOC_PAGE( CUR_VP );							--| No DE PAGE PHYSIQUE ASSOCIEE
  AREA( AR ).FREE_LINE := FREE_IDX + NB_REQUIS;						--| NOMBRE DE LIGNES OCCUPEES : AJOUTER NB_ATTR + 1 POUR L'ENTETE
  PAG( CUR_RP ).DATA.all( LINE_IDX( FREE_IDX ) ) := (HI, NOTY=> NN, ABSS=> 0, NSIZ=> NB_ATTR );	--| ENTETE DU NOEUD (TYPE ET NB D'ATTRIBUTS)
  PAG( CUR_RP ).CHANGED := TRUE;
  return (P, TY=> NN, PG=> AREA( AR ).VP, LN=> LINE_IDX( FREE_IDX ) );			--| RETOUR DU POINTEUR

exception
  when CONSTRAINT_ERROR =>
    PUT_LINE( "CONSTRAINT_ERROR idl_man.make"
	& " vp=" & VPG_IDX'IMAGE( CUR_VP )
	& " rp=" & RPG_IDX'IMAGE( ASSOC_PAGE( CUR_VP ) ) & " area=" & AREA_IDX'IMAGE( AR ) );
    raise;
    return TREE_NIL;
end MAKE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION MAKE
--|
function MAKE ( NN :NODE_NAME; NB_ATTR: ATTR_NBR ) return TREE is
begin
  return MAKE ( NN, NB_ATTR, AR=> 1 );
end MAKE;      
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION LAST_BLOCK
--|
function LAST_BLOCK return VPG_IDX is
begin
  return HIGH_VPG;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION PRINT_NAME
--|
function PRINT_NAME ( PG :VPG_IDX; LN :LINE_IDX ) return STRING is
begin
  return PRINT_NAME ( (P, TY=> DN_TXTREP, PG=> PG, LN=> LN ) );
end;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION INT_IMAGE_NOBLANK
--|
function INT_IMAGE_NOBLANK ( V :INTEGER ) return STRING is
  IM		: constant STRING		:= INTEGER'IMAGE( V );			--| FABRIQUER L'IMAGE DU NOMBRE
begin
  if V >= 0 then									--| VALEUR POSITIVE (IL Y A UN BLANC A LA PLACE DU SIGNE)
    return IM( 2..IM'LENGTH );							--| RENVOYER L'IMAGE SANS BLANC
  else										--| VALEUR NEGATIVE
    return IM;									--| RENVOYER L'IMAGE (QUI A LE SIGNE - INCLUS)
  end if;
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION NODE_REP
--|
function NODE_REP ( T :TREE ) return STRING is
         
  function NODE_NAME_IMAGE return STRING is
  begin
    return '{' & NODE_NAME'IMAGE ( T.TY ) & '}';
  end;
         
begin
  case T.PT is
  when HI =>
    return '['	& NODE_NAME'IMAGE ( T.NOTY )
		& " NSIZ=" & ATTR_NBR'IMAGE( T.NSIZ )
		& " ABSS=" & POSITIVE_SHORT'IMAGE( T.ABSS )	& ']' ;

  when S =>
    return "[COL="	& SRCCOL_IDX'IMAGE( T.COL )
		& " <" & PAGE_IDX'IMAGE( T.SPG ) & '.' & LINE_IDX'IMAGE( T.SLN ) & '>';
  when P | L =>

    if T = TREE_VIRGIN then return "[___]"; end if;

    return '['	& NODE_NAME'IMAGE(T.TY)
		& '<' & INT_IMAGE_NOBLANK ( INTEGER( T.PG ) )
		& '.' & INT_IMAGE_NOBLANK ( INTEGER( T.LN ) ) & "]>";
  end case;
end NODE_REP;
   

	-------
end	IDL_MAN;
	-------