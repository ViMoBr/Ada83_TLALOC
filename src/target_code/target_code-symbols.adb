------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--
--	T A R G E T _ C O D E . S Y M B O L S   --   corps
--
--	Table unique de symboles (hachage nom+scope -> chaine), arbre de
--	portees, zones de layout empilables, marques d'atteignabilite.
--	Capacites STATIQUES ; tout depassement est un refus bruyant (R6),
--	jamais un ecrasement silencieux.
--
--	SEMANTIQUE DE REFERENCE : fasmg (NOTE_SUBSET_FASMG v1 par 2.1).
--	  - resolution non pointee : scope courant puis PARENTS SEULEMENT
--	    (piege n 105 — jamais les freres) ;
--	  - "namespace X" cherche X dans le scope COURANT SEULEMENT et le
--	    rouvre s'il existe (reouverture CUMULATIVE : namespace STANDARD
--	    en tete de chaque FINC). POINT DE DIVERGENCE POSSIBLE avec fasmg
--	    si un FINC rouvrait un namespace par remontee depuis un scope
--	    plus profond — aucun cas constate dans le corpus ; a re-examiner
--	    au premier ecart du byte-diff.
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE )
				-------
package body			SYMBOLS
is				-------

		--  reserve de noms

  POOL_MAX		:constant		:= 16_000_000;
  POOL			: STRING( 1 .. POOL_MAX );
  POOL_TOP		: NATURAL			:= 0;
  EPOCH			: NATURAL			:= NATURAL'LAST;				--| element en cours des boucles P2/P2B/P3 ;

		--  table des symboles

  type SYM_CELL		is record
			  NAME_FIRST	: NATURAL		:= 0;					--| tranche du nom dans POOL
			  NAME_LAST	: NATURAL		:= 0;
			  SCOPE		: SCOPE_ID	:= ROOT_SCOPE;				--| scope d'appartenance
			  CLASS		: SYM_CLASS	:= PLAIN_VALUE;
			  VALUE		: VALUE_TYPE	:= 0;
			  VALUE_SET	: BOOLEAN		:= FALSE;					--| adresses posees en P2 seulement
			  UNDER		: SCOPE_ID	:= 0;					--| scope OUVERT par ce symbole (SCOPE_NAME)
			  BIRTH		: NATURAL		:= 0;					--| 0 = de tout temps ; ombres : element declarant
			  NEXT_H		: SYM_ID		:= NO_SYM;				--| chaine de hachage
			end record;

  TABLE			: array ( SYM_ID range 1 .. SYM_ID'LAST ) of SYM_CELL;
  LAST_SYM		: SYM_ID	:= NO_SYM;

  HASH_MOD		:constant NATURAL	:= 65_536;
  BUCKETS			: array ( NATURAL( 0 ) .. HASH_MOD - 1 ) of SYM_ID	:= ( others => NO_SYM );

		--  arbre des portees

  type SCOPE_CELL		is record
			  PARENT		: SCOPE_ID	:= 0;
			  SELF		: SYM_ID		:= NO_SYM;				--| symbole SCOPE_NAME ouvrant (NO_SYM : racine)
			end record;

  SCOPES			: array ( SCOPE_ID range 1 .. SCOPE_ID'LAST ) of SCOPE_CELL;
  LAST_SCOPE		: SCOPE_ID	:= ROOT_SCOPE;						--| la racine existe d'emblee
  CURRENT			: SCOPE_ID	:= ROOT_SCOPE;

		--  zones de layout (empilables : VARzone peut contenir des virtual at 0)

  ZONE_DEPTH_MAX		:constant	:= 16;
  ZONE_POSITIONS		: array ( 1 .. ZONE_DEPTH_MAX ) of VALUE_TYPE;
  ZONE_TOP		: NATURAL		:= 0;

  MARKS			: NATURAL		:= 0;							--| LAZY_MARK creees (point fixe P1)


			-----
  procedure		FAULT		( MSG :STRING )
  is			-----
  begin
    PUT_LINE( "TARGET_CODE.SYMBOLS : " & MSG );
    raise  SYMBOL_FAULT;

  end	FAULT;
	-----

			---------
  function		SAME_NAME		( S :SYM_ID; NAME :STRING )		return BOOLEAN
  is			---------
  begin
    if  TABLE( S ).NAME_LAST - TABLE( S ).NAME_FIRST + 1 /= NAME'LENGTH  then
      return  FALSE;
    end if;

    return  POOL( TABLE( S ).NAME_FIRST .. TABLE( S ).NAME_LAST ) = NAME;

  end	SAME_NAME;
	---------


			-------
  function		HASH_OF		( SCOPE :SCOPE_ID; NAME :STRING ) 	 return NATURAL
  is			-------

    H			: NATURAL	:= NATURAL( SCOPE );

  begin
    for  I in NAME'RANGE  loop
      H := ( H * 31 + CHARACTER'POS( NAME( I ) ) ) mod HASH_MOD;
    end loop;
    return  H;

  end	HASH_OF;
	-------

  --| dans UN scope, sans remontee
			----
  function		FIND ( SCOPE :SCOPE_ID; NAME :STRING ) return SYM_ID
  is			----

    S			: SYM_ID	:= BUCKETS( HASH_OF( SCOPE, NAME ) );

  begin
    while  S /= NO_SYM  loop
      if  TABLE( S ).SCOPE = SCOPE
	and then  TABLE( S ).BIRTH <= EPOCH								--| epoque : la definition la plus recente
	and then  POOL( TABLE( S ).NAME_FIRST .. TABLE( S ).NAME_LAST ) = NAME				--| deja nee au point du texte (TC-24)
      then
        return  S;
      end if;
      S := TABLE( S ).NEXT_H;
    end loop;
    return  NO_SYM;

  end	FIND;
	----


			---------
  procedure		SET_EPOCH		( N :NATURAL )						--| estampille des boucles d'elements (TC-24)
  is			---------
  begin
    EPOCH := N;
  end	SET_EPOCH;
	---------


			--------
  function		NEW_CELL		( SCOPE :SCOPE_ID; NAME :STRING;
					  CLASS :SYM_CLASS; VALUE :VALUE_TYPE )		return SYM_ID
  is			--------
    H	: constant NATURAL	:= HASH_OF( SCOPE, NAME );
  begin
    if  LAST_SYM = SYM_ID'LAST  then
      FAULT( "table pleine (SYM_MAX) sur : " & NAME );
    end if;

    if  POOL_TOP + NAME'LENGTH > POOL_MAX  then
      FAULT( "reserve de noms pleine (POOL_MAX) sur : " & NAME );
    end if;

    LAST_SYM := LAST_SYM + 1;
    POOL( POOL_TOP + 1 .. POOL_TOP + NAME'LENGTH ) := NAME;
    TABLE( LAST_SYM ).NAME_FIRST := POOL_TOP + 1;
    TABLE( LAST_SYM ).NAME_LAST := POOL_TOP + NAME'LENGTH;
    POOL_TOP := POOL_TOP + NAME'LENGTH;
    TABLE( LAST_SYM ).SCOPE := SCOPE;
    TABLE( LAST_SYM ).CLASS := CLASS;
    TABLE( LAST_SYM ).VALUE := VALUE;
    TABLE( LAST_SYM ).UNDER := 0;
    case  CLASS  is
    when CODE_LABEL | CONSTANT_ADDR | SCOPE_NAME =>							--| adresses : posees en P2 par SET_VALUE
	TABLE( LAST_SYM ).VALUE_SET := FALSE;
    when others =>											--| offsets, gardes, marques : valeur immediate
	TABLE( LAST_SYM ).VALUE_SET := TRUE;
    end case;
    TABLE( LAST_SYM ).NEXT_H := BUCKETS( H );
    BUCKETS( H ) := LAST_SYM;
    return  LAST_SYM;

  end	NEW_CELL;
	--------


  --| duplication : seules les classes d'AFFECTATION (GUARD, PLAIN_VALUE) sont
  --| redefinissables (semantique fasmg "X = ..."), LAZY_MARK est idempotente
  --| (sans recompter) ; tout le reste est un refus bruyant.
			----------
  function		DECLARE_IN	( SCOPE :SCOPE_ID; NAME :STRING;
					  CLASS :SYM_CLASS; VALUE :VALUE_TYPE )		return SYM_ID
  is			----------

    F			: constant SYM_ID := FIND( SCOPE, NAME );
    S			: SYM_ID;

  begin
    if  F = NO_SYM  then
      S := NEW_CELL( SCOPE, NAME, CLASS, VALUE );
      if  CLASS = LAZY_MARK  then
        MARKS := MARKS + 1;										--| croissance => le point fixe P1 continue
      end if;
      return  S;
    end if;

    if  ( CLASS = GUARD  or  CLASS = PLAIN_VALUE )  and then  TABLE( F ).CLASS = SCOPE_NAME  then			--| affectation sur un nom de namespace : toleree
      return  F;											--| sans changement (tete canonique STANDARD =
    end if;											--| 'STANDARD' apres que le scope existe — seule

    if  TABLE( F ).CLASS = SCOPE_NAME  and then  not TABLE( F ).VALUE_SET  then					--| namespace X PUIS VAR/label X (meme nom) :
      TABLE( F ).CLASS := CLASS;									--| unification - le symbole prend classe et
      TABLE( F ).VALUE := VALUE;									--| valeur, GARDE ses enfants (UNDER) ; entite
      case  CLASS  is										--| unique fasmg (ADA_COMP, releve TC-23)
      when CODE_LABEL | CONSTANT_ADDR | SCOPE_NAME =>
	TABLE( F ).VALUE_SET := FALSE;								--| adresses : posees en P2 par SET_VALUE
      when others =>
	TABLE( F ).VALUE_SET := TRUE;									--| offsets, gardes, marques : valeur immediate
      end case;
      return  F;
    end if;

    if  ( CLASS = GUARD  or  CLASS = PLAIN_VALUE )  and then
       ( TABLE( F ).CLASS = GUARD  or  TABLE( F ).CLASS = PLAIN_VALUE )
    then
      TABLE( F ).VALUE := VALUE;
      TABLE( F ).VALUE_SET := TRUE;
      return  F;
    end if;

    if  CLASS = LAZY_MARK  and then  TABLE( F ).CLASS = LAZY_MARK  then
      return  F;
    end if;

    if  CLASS = FRAME_OFFSET  and then  TABLE( F ).CLASS = FRAME_OFFSET  then					--| VAR redefini (name = $ fasmg : GFP_disp
      declare											--| d'ADA_COMP) : OMBRE nee a l'epoque de
        S	: constant SYM_ID	:= NEW_CELL( SCOPE, NAME, CLASS, VALUE );					--| l'element declarant - les references
      begin											--| anterieures gardent l'ancienne (TC-24)
        TABLE( S ).BIRTH := EPOCH;
        return  S;
      end;
    end if;

    declare
      P			: constant SYM_ID := SCOPES( CURRENT ).SELF;
    begin
      if  P = NO_SYM  then
        FAULT( "declaration dupliquee (racine) : " & NAME );
      else
        FAULT( "declaration dupliquee : " & NAME & "  dans "
		& POOL( TABLE( P ).NAME_FIRST .. TABLE( P ).NAME_LAST )
		& "  classes " & SYM_CLASS'IMAGE( CLASS )
		& " vs " & SYM_CLASS'IMAGE( TABLE( F ).CLASS ) );
      end if;
    end;
    return  NO_SYM;											--| jamais atteint

  end	DECLARE_IN;
	----------


		-- services publics : portees

			-----------
  procedure		ENTER_SCOPE	( NAME :STRING )
  is			-----------

    F	: SYM_ID	:= FIND( CURRENT, NAME );								--| scope COURANT SEULEMENT (cf. en-tete)

  begin
    if  F = NO_SYM  then
      if  LAST_SCOPE = SCOPE_ID'LAST  then
	FAULT( "trop de namespaces (SCOPE_MAX) sur : " & NAME );
      end if;

      LAST_SCOPE := LAST_SCOPE + 1;
      F := NEW_CELL( CURRENT, NAME, SCOPE_NAME, 0 );
      TABLE( F ).UNDER := LAST_SCOPE;
      SCOPES( LAST_SCOPE ).PARENT := CURRENT;
      SCOPES( LAST_SCOPE ).SELF := F;
      CURRENT := LAST_SCOPE;

    elsif  TABLE( F ).CLASS = SCOPE_NAME  then
      CURRENT := TABLE( F ).UNDER;									--| reouverture CUMULATIVE

    elsif TABLE( F ).CLASS = GUARD  or  TABLE( F ).CLASS = PLAIN_VALUE  then					--| namespace sur une garde : PROMOTION (tete
      if LAST_SCOPE = SCOPE_ID'LAST									--| canonique — STANDARD = 'STANDARD' PUIS
      then											--| namespace STANDARD, ordre du corpus reel)
	FAULT( "trop de namespaces (SCOPE_MAX) sur : " & NAME );
      end if;
      LAST_SCOPE := LAST_SCOPE + 1;
      TABLE( F ).CLASS := SCOPE_NAME;
      TABLE( F ).UNDER := LAST_SCOPE;
      SCOPES( LAST_SCOPE ).PARENT := CURRENT;
      SCOPES( LAST_SCOPE ).SELF := F;
      CURRENT := LAST_SCOPE;

    elsif  TABLE( F ).UNDER /= 0  then								--| symbole value deja pourvu d'enfants :
      CURRENT := TABLE( F ).UNDER;									--| reouverture (entite unique fasmg)

    else											--| symbole value SANS enfants : lui attacher
      if  LAST_SCOPE = SCOPE_ID'LAST  then								--| son scope - classe et valeur CONSERVEES
	FAULT( "trop de namespaces (SCOPE_MAX) sur : " & NAME );						--| (VAR X puis namespace X : ADA_COMP, TC-23)
      end if;
      LAST_SCOPE := LAST_SCOPE + 1;
      TABLE( F ).UNDER := LAST_SCOPE;
      SCOPES( LAST_SCOPE ).PARENT := CURRENT;
      SCOPES( LAST_SCOPE ).SELF := F;
      CURRENT := LAST_SCOPE;
    end if;

  end	ENTER_SCOPE;
	-----------


			-----------
  procedure		LEAVE_SCOPE
  is			-----------
  begin
    if  CURRENT = ROOT_SCOPE  then
      FAULT( "end namespace excedentaire (deja a la racine)" );
    end if;

    CURRENT := SCOPES( CURRENT ).PARENT;

  end	LEAVE_SCOPE;
	-----------


			-------------
  function		CURRENT_SCOPE		return SCOPE_ID
  is			-------------
  begin
    return  CURRENT;

  end	CURRENT_SCOPE;
	-------------


			---------
  procedure		USE_SCOPE		( S :SCOPE_ID )
  is			---------
  begin
    if  S < ROOT_SCOPE  or  S > LAST_SCOPE  then
      FAULT( "USE_SCOPE hors table" );
    end if;

    CURRENT := S;

  end	USE_SCOPE;
	---------


		-- services publics : declarations et resolution

			-----------
  function		DECLARE_SYM	( NAME :STRING; CLASS :SYM_CLASS;
					  VALUE :VALUE_TYPE := 0 )		return SYM_ID
  is			-----------
  begin
    return  DECLARE_IN( CURRENT, NAME, CLASS, VALUE );

  end	DECLARE_SYM;
	-----------


			-----------
  procedure		DECLARE_SYM	( NAME :STRING; CLASS :SYM_CLASS;
					  VALUE :VALUE_TYPE := 0 )
  is			-----------

    IGNORE		: SYM_ID;
  begin
    IGNORE := DECLARE_IN( CURRENT, NAME, CLASS, VALUE );

  end	DECLARE_SYM;
	-----------


			---------
  procedure		SET_VALUE		( S :SYM_ID; VALUE :VALUE_TYPE )
  is			---------
  begin
    if  S = NO_SYM  or  S > LAST_SYM  then
      FAULT( "SET_VALUE hors table" );
    end if;

    TABLE( S ).VALUE := VALUE;
    TABLE( S ).VALUE_SET := TRUE;

  end	SET_VALUE;
	---------


  --| premier composant par REMONTEE DES PARENTS (piege n 105), suivants par
  --| descente stricte de namespaces
			-----------
  function		TRY_RESOLVE	( DOTTED :STRING )		return SYM_ID
  is			-----------

    FIRST		: INTEGER		:= DOTTED'FIRST;
    DOT		: INTEGER;
    S		: SYM_ID		:= NO_SYM;
  begin
    loop
      DOT := FIRST;
      while  DOT <= DOTTED'LAST  and then  DOTTED( DOT ) /= '.'  loop
        DOT := DOT + 1;
      end loop;
      if  FIRST > DOT - 1  then
        return  NO_SYM;										--| composant vide : nom mal forme
      end if;

      if S = NO_SYM  then										--| premier composant : remontee
        declare
	  LEVEL	: SCOPE_ID := CURRENT;
        begin
	loop
	  S := FIND( LEVEL, DOTTED( FIRST .. DOT - 1 ) );
	  exit when  S /= NO_SYM  or  LEVEL = ROOT_SCOPE;
	  LEVEL := SCOPES( LEVEL ).PARENT;
	end loop;
        end;
        if  S = NO_SYM  then
	return NO_SYM;
        end if;

      else											--| composants suivants : descente
        if  TABLE( S ).UNDER = 0  then									--| sans enfants : descente impossible
	return NO_SYM;										--| (les symboles values a enfants passent :
        end if;											--| entite unique fasmg, TC-23)
        S := FIND( TABLE( S ).UNDER, DOTTED( FIRST .. DOT - 1 ) );
        if  S = NO_SYM  then
	return NO_SYM;
        end if;
      end if;

      exit when  DOT > DOTTED'LAST;
      FIRST := DOT + 1;
    end loop;
    return  S;

  end	TRY_RESOLVE;
	-----------


			-------
  function		RESOLVE		( DOTTED :STRING )	return SYM_ID
  is			-------

    S			: constant SYM_ID := TRY_RESOLVE( DOTTED );

  begin
    if  S = NO_SYM  then
      FAULT( "symbole introuvable : " & DOTTED );
    end if;

    return  S;

  end	RESOLVE;
	-------


			----------
  function		IS_DEFINED	( DOTTED :STRING )	return BOOLEAN
  is			----------
  begin
    return  TRY_RESOLVE( DOTTED ) /= NO_SYM;

  end	IS_DEFINED;
	----------


			--------
  function		CLASS_OF		( S :SYM_ID )	return SYM_CLASS
  is			--------
  begin
    if  S = NO_SYM  or  S > LAST_SYM  then
      FAULT( "CLASS_OF hors table" );
    end if;

    return  TABLE( S ).CLASS;

  end	CLASS_OF;
	--------


			--------
  function		VALUE_OF		( S :SYM_ID )	return VALUE_TYPE
  is			--------
  begin
    if  S = NO_SYM  or  S > LAST_SYM  then
      FAULT( "VALUE_OF hors table" );
    end if;

    if  not TABLE( S ).VALUE_SET  then								--| adresse consultee avant P2 : bug de phase
      FAULT( "valeur non encore posee : " & POOL( TABLE( S ).NAME_FIRST .. TABLE( S ).NAME_LAST ) );
    end if;
    return  TABLE( S ).VALUE;

  end	VALUE_OF;
	--------


			-----------
  function		SCOPE_UNDER	( S :SYM_ID )	return SCOPE_ID
  is			-----------
  begin
    if  CLASS_OF( S ) /= SCOPE_NAME  then
      FAULT( "SCOPE_UNDER sur un non-namespace" );
    end if;

    return  TABLE( S ).UNDER;

  end	SCOPE_UNDER;
	-----------


		-- services publics : zones de layout

			---------
  procedure		OPEN_ZONE		( BASE :VALUE_TYPE )
  is			---------
  begin
    if  ZONE_TOP = ZONE_DEPTH_MAX  then
      FAULT( "zones trop imbriquees (ZONE_DEPTH_MAX)" );
    end if;

    ZONE_TOP := ZONE_TOP + 1;
    ZONE_POSITIONS( ZONE_TOP ) := BASE;

  end	OPEN_ZONE;
	---------


  --| padding VIRTUEL : les octets reels (16#90#/0) sont l'affaire d'EMIT.
  --| Miroir de layout (piege n 110) : meme calcul que fasmg align_* et que
  --| ALIGN_STATIC_BITS cote expander — test-miroir obligatoire.

			----------
  procedure		ZONE_ALIGN		( ALGN :VALUE_TYPE )
  is			----------

    D			: VALUE_TYPE;
  begin
    if  ZONE_TOP = 0  then
      FAULT( "ZONE_ALIGN sans zone ouverte" );
    end if;

    if  ALGN > 1  then
      D := ZONE_POSITIONS( ZONE_TOP ) mod ALGN;
      if  D /= 0  then
        ZONE_POSITIONS( ZONE_TOP ) := ZONE_POSITIONS( ZONE_TOP ) + ALGN - D;
      end if;
    end if;

  end	ZONE_ALIGN;
	----------


			------------
  procedure		ZONE_RESERVE	( SIZE :VALUE_TYPE )
  is			------------
  begin
    if  ZONE_TOP = 0  then
      FAULT( "ZONE_RESERVE sans zone ouverte" );
    end if;
    ZONE_POSITIONS( ZONE_TOP ) := ZONE_POSITIONS( ZONE_TOP ) + SIZE;

  end	ZONE_RESERVE;
	------------


			--------
  function		ZONE_POS		return VALUE_TYPE
  is			--------
  begin
    if  ZONE_TOP = 0  then
      FAULT( "ZONE_POS sans zone ouverte" );
    end if;
    return  ZONE_POSITIONS( ZONE_TOP );									--| le "$" fasmg de la zone courante

  end	ZONE_POS;
	--------


			----------
  function		CLOSE_ZONE		return VALUE_TYPE
  is			----------

    P			: VALUE_TYPE;
  begin
    P := ZONE_POS;									--| verifie aussi la pile non vide
    ZONE_TOP := ZONE_TOP - 1;
    return  P;											--| prm_siz = P-8, loc_siz aligne q : chez l'appelant

  end	CLOSE_ZONE;
	----------

  -------------------------------------------------------------------------------------------------------------------
  --			services publics : atteignabilite
  -------------------------------------------------------------------------------------------------------------------

			----
  procedure		MARK		( PREFIX, SUBNAME :STRING )
  is			----

    P			:constant SYM_ID	:= RESOLVE( PREFIX );
    IGNORE		: SYM_ID;

  begin
    if  TABLE( P ).CLASS /= SCOPE_NAME  then
      FAULT( "MARK : prefixe non-namespace : " & PREFIX );
    end if;
    IGNORE := DECLARE_IN( TABLE( P ).UNDER, SUBNAME & "_", LAZY_MARK, 0 );

  end	MARK;
	----


			-----------
  function		REACH_COUNT		return NATURAL
  is			-----------
  begin
    return  MARKS;

  end	REACH_COUNT;
	-----------


		-- carto

			--------
  procedure		PUT_PATH		( S :SCOPE_ID )
  is			--------
  begin
    if  S /= ROOT_SCOPE  then
      PUT_PATH( SCOPES( S ).PARENT );
      PUT( POOL( TABLE( SCOPES( S ).SELF ).NAME_FIRST
		 .. TABLE( SCOPES( S ).SELF ).NAME_LAST ) & "." );
    end if;

  end	PUT_PATH;
	--------

			--------
  procedure		DUMP_MAP
  is			--------
  begin
    for  S in 1 .. LAST_SYM  loop
      if  TABLE( S ).VALUE_SET  and then  TABLE( S ).CLASS /= GUARD  then
        PUT( LONG_INTEGER'IMAGE( TABLE( S ).VALUE ) & "  " & SYM_CLASS'IMAGE( TABLE( S ).CLASS ) & "  " );
        PUT_PATH( TABLE( S ).SCOPE );
        PUT_LINE( POOL( TABLE( S ).NAME_FIRST .. TABLE( S ).NAME_LAST ) );
      end if;
    end loop;

  end	DUMP_MAP;
	--------

			---------
  function		POOL_USED				return NATURAL
  is			---------
  begin
    return POOL_TOP;
  end	POOL_USED;
	---------

			-------------
  function		POOL_CAPACITY			return NATURAL
  is			-------------
  begin
    return POOL_MAX;
  end	POOL_CAPACITY;
	-------------

			---------
  function		SYM_COUNT				return NATURAL
  is			---------
  begin
    return NATURAL( LAST_SYM );
  end	SYM_COUNT;
	---------

			-----------
  function		SCOPE_COUNT			return NATURAL
  is			-----------
  begin
    return NATURAL( LAST_SCOPE );
  end	SCOPE_COUNT;
	-----------


	-------
end	SYMBOLS;
	-------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
