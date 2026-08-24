-----------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
-----------------------------------------------------------------------------------------------------------------------
--
--	T A R G E T _ C O D E . P A S S E S   --   corps
--
--	P1 : ATTEIGNABILITE. Remplace le lazy fasmg (postpone + ~definite, qui
--	exigeait le multi-passes). Point fixe sur les marques : les CALL/LSPA
--	des elements ACTIFS posent PREFIX.SUBNAME_ (SYMBOLS.MARK) ; un element
--	est actif si sa garde lazy, evaluee DANS SON SCOPE estampille (lecon
--	TC-02f : jamais depuis la racine), est definie. Ensemble fini
--	croissant : terminaison garantie, cap de securite bruyant.
--
--	P2 : LAYOUT. Miroir n 110, TROISIEME implementation (fasmg,
--	ALIGN_STATIC_BITS, ici) — regles relues dans codi_x86_64.finc :
--	  PRO      : pousse un contexte de frame (PPOS=8, VPOS=8) ;
--	  PRMS/PRM : name_ofs = PPOS ; dq -> PPOS+8 ;
--	  endPRMS  : prm_siz = PPOS-8 ;
--	  ELB      : declare le label elab ; VPOS = 8 ;
--	  VAR n,c,k: align selon c (b/w/d/q) puis n_disp=VPOS, VPOS+=unite*k ;
--	             c LITTERAL (octets) : align_q, VPOS+=c ;
--	  USEINFO n: align_q ; n__u = VPOS ; VPOS+=8 ;
--	  endPRO   : declare le label post ; align_q ; loc_siz = VPOS ;
--	             depile le contexte de frame ;
--	  tete .fas: "VARzone::" (dans un virtual at) OUVRE LE FRAME DE
--	             NIVEAU 0 (VPOS = base de la zone ; jamais depile) ;
--	  queue .fas: "virtual VARzone" rouvre la zone du frame courant ;
--	             "X = $" y fige la position SANS align_q (fidele a
--	             l'expander, CREATE_FAS_MAIN_FILE) ;
--	  virtual at N / STATOFS nom,siz,algn / end virtual : zone statique
--	             empilable ; algn OCTETS 1/2/4/8, repli par taille si 0
--	             (siz>4:q, >2:d, >1:w) ; reservation rb siz (octets).
--	Q7 (sous-programmes imbriques) : modele PILE de VARzones (une par
--	frame) ; oracle de tranchement = fasmg DEBUG_LLIR=1 (show loc_siz)
--	sur une unite reelle imbriquee. Adresses / tailles : TC-04.
--
-----------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE )

					------
package body				PASSES
is					------

  use IR;												--| operateurs de ELT_KIND / OPERAND_TAG (LRM 8.4)

		--  contextes de frame (Q7 : modele pile)

  FRAME_MAX		:constant	:= 32;
  VPOSES			: array ( 1 .. FRAME_MAX ) of SYMBOLS.VALUE_TYPE;
  PPOSES			: array ( 1 .. FRAME_MAX ) of SYMBOLS.VALUE_TYPE;
  FSCOPES			: array ( 1 .. FRAME_MAX ) of SYMBOLS.SCOPE_ID;
  FTOP			: NATURAL	:= 0;

		--  zones statiques (virtual at N, empilables)

  SZONE_MAX		:constant	:= 16;
  SPOSES			: array ( 1 .. SZONE_MAX ) of SYMBOLS.VALUE_TYPE;
  STOP			: NATURAL	:= 0;


  procedure		FAULT ( MSG :STRING )
  is
  begin
    PUT_LINE( "TARGET_CODE.PASSES : " & MSG );
    raise PASS_FAULT;
  end FAULT;


  function		ALIGNED ( POS, ALGN :SYMBOLS.VALUE_TYPE ) return SYMBOLS.VALUE_TYPE
  is
    D			: SYMBOLS.VALUE_TYPE;
  begin
    if ALGN <= 1
    then
      return POS;
    end if;
    D := POS mod ALGN;
    if D = 0
    then
      return POS;
    end if;
    return POS + ALGN - D;
  end ALIGNED;


  function		MNEMO_IS ( E :IR.ELT_ID; S :STRING ) return BOOLEAN
  is
  begin
    return LEX.IMAGE( IR.MNEMO_OF( E ) ) = S;
  end MNEMO_IS;


		-- activite (garde lazy evaluee dans le scope de l'element)


  function		ACTIVE ( E :IR.ELT_ID ) return BOOLEAN
  is
    L			: constant LEX.SLICE	  := IR.LAZY_OF( E );
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    R			: BOOLEAN;
  begin
    if L.F = 0
    then
      return TRUE;							--| inconditionnel
    end if;
    SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );				--| lecon TC-02f : evaluer DU BON ENDROIT
    R := SYMBOLS.IS_DEFINED( LEX.IMAGE( L ) );
    SYMBOLS.USE_SCOPE( S0 );
    return R;
  end ACTIVE;


		-- P1 : point fixe des marques d'atteignabilite

  procedure		P1_REACH
  is
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    PREV		: NATURAL;
    ROUNDS		: NATURAL	:= 0;
  begin
    loop
      PREV   := SYMBOLS.REACH_COUNT;
      ROUNDS := ROUNDS + 1;
      if ROUNDS > 10_000
      then
	FAULT( "point fixe d'atteignabilite non convergent (impossible : ensemble croissant)" );
      end if;

      for E in 1 .. IR.ELT_COUNT
      loop
	declare
	  EI		: constant IR.ELT_ID := IR.ELT_ID( E );
	begin
	  if IR.KIND_OF( EI ) = IR.MACRO_CALL
	     and then  ( MNEMO_IS( EI, "CALL" )  or else  MNEMO_IS( EI, "LSPA" ) )
	     and then  ACTIVE( EI )
	  then
	    if IR.N_OPS( EI ) < 2
	       or else  IR.OP_TAG( EI, 1 ) /= IR.NAME_OP
	       or else  IR.OP_TAG( EI, 2 ) /= IR.NAME_OP
	    then
	      FAULT( "forme CALL/LSPA inattendue (prefixe, sous-nom attendus)" );
	    end if;
	    SYMBOLS.USE_SCOPE( IR.SCOPE_OF( EI ) );			--| le prefixe se resout DU SITE D'APPEL
	    declare
	      G		: constant STRING
			:= LEX.IMAGE( IR.OP_TXT( EI, 1 ) )
			 & LEX.IMAGE( IR.OP_TXT( EI, 2 ) );		--| concatenation FIDELE au # de fasmg
	      CUT	: NATURAL	:= 0;
	    begin
	      for K in G'RANGE
	      loop
		if G( K ) = '.'
		then
		  CUT := K;						--| dernier point = frontiere scope / feuille
		end if;
	      end loop;
	      if CUT = 0
	      then							--| prefixe SANS point : nom soude — la garde
		SYMBOLS.DECLARE_SYM( G & "_", SYMBOLS.LAZY_MARK );	--| "if defined X_" ne matchera pas, corps mort,
	      else							--| l'appel echouera bruyamment (meme verdict
		SYMBOLS.MARK( G( G'FIRST .. CUT - 1 ),			--| que fasmg — temoin TC-07c)
			      G( CUT + 1 .. G'LAST ) );
	      end if;
	    end;
	  end if;
	end;
      end loop;

      exit when SYMBOLS.REACH_COUNT = PREV;				--| plus de croissance : point fixe atteint
    end loop;
    SYMBOLS.USE_SCOPE( S0 );
  end P1_REACH;


  -------------------------------------------------------------------------------------------------------------------
  --			P2 : layout (zones, offsets, prm_siz / loc_siz, elab / post)
  -------------------------------------------------------------------------------------------------------------------

  procedure		P2_LAYOUT		( FROM, TO :IR.ELT_ID )
  is
    S0			: constant SYMBOLS.SCOPE_ID	:= SYMBOLS.CURRENT_SCOPE;
    FRAME0		: BOOLEAN			:= FALSE;						--| "VARzone::" vu : frame de niveau 0 ouvert
    REOPENED		: BOOLEAN			:= FALSE;						--| "virtual VARzone" en cours (X = $)

		----------
    procedure	PUSH_FRAME	( S :SYMBOLS.SCOPE_ID )
    is		----------
    begin
      if  FTOP = FRAME_MAX  then
        FAULT( "frames trop imbriquees" );
      end if;

      FTOP := FTOP + 1;
      VPOSES( FTOP ) := 8;
      PPOSES( FTOP ) := 8;
      FSCOPES( FTOP ) := S;

    end	PUSH_FRAME;
	----------

		------
    procedure	DO_VAR		( E :IR.ELT_ID )
    is		------

      UNIT		: SYMBOLS.VALUE_TYPE;
      COUNT		: SYMBOLS.VALUE_TYPE	:= 1;

    begin
      if FTOP = 0
      then
	FAULT( "VAR hors de tout sous-programme" );
      end if;
      if IR.N_OPS( E ) < 2  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP
      then
	FAULT( "forme VAR inattendue" );
      end if;
      if IR.N_OPS( E ) >= 3
      then
	if IR.OP_TAG( E, 3 ) /= IR.INT_OP
	then
	  FAULT( "compte VAR non litteral" );
	end if;
	COUNT := IR.OP_INT( E, 3 );
      end if;

      if IR.OP_TAG( E, 2 ) = IR.INT_OP
      then								--| taille litterale en octets : align_q
	VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), 8 );
	SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			     SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
	VPOSES( FTOP ) := VPOSES( FTOP ) + IR.OP_INT( E, 2 );
	return;
      end if;

      if IR.OP_TAG( E, 2 ) /= IR.NAME_OP
      then
	FAULT( "caractere de taille VAR inattendu" );
      end if;
      declare
	C		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );
      begin
	if C = "b"  or else  C = "B"
	then								--| repli de casse, comme la macro VAR du codi
	  UNIT := 1;
	elsif C = "w"  or else  C = "W"
	then
	  UNIT := 2;
	elsif C = "d"  or else  C = "D"
	then
	  UNIT := 4;
	elsif C = "q"  or else  C = "Q"
	then
	  UNIT := 8;
	else								--| taille NOMMEE (corpus : VAR X, NS.TYPE.size) :
	  if IR.N_OPS( E ) >= 3						--| align_q + reservation de la valeur ; le compte
	  then								--| n'existe pas dans cette branche du codi
	    FAULT( "compte avec taille nommee (hors codi) : " & C );
	  end if;
	  VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), 8 );
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			       SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
	  VPOSES( FTOP ) := VPOSES( FTOP ) + LEX.EVAL( IR.OP_TXT( E, 2 ) );
	  return;
	end if;
      end;
      VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), UNIT );
      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
      VPOSES( FTOP ) := VPOSES( FTOP ) + UNIT * COUNT;

    end	DO_VAR;
	------


    procedure		DO_STATOFS ( E :IR.ELT_ID )
    is
      SIZ, ALGN		: SYMBOLS.VALUE_TYPE;
      A			: SYMBOLS.VALUE_TYPE	:= 1;
    begin
      if STOP = 0
      then
	FAULT( "STATOFS hors de toute zone virtual" );
      end if;
      if IR.N_OPS( E ) < 2
	 or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP
	 or else  IR.OP_TAG( E, 2 ) /= IR.INT_OP
      then
	FAULT( "forme STATOFS inattendue" );
      end if;
      SIZ  := IR.OP_INT( E, 2 );
      ALGN := 0;
      if IR.N_OPS( E ) >= 3
      then
	if IR.OP_TAG( E, 3 ) /= IR.INT_OP
	then
	  FAULT( "alignement STATOFS non litteral" );
	end if;
	ALGN := IR.OP_INT( E, 3 );
      end if;

      if ALGN = 8  or  ALGN = 4  or  ALGN = 2  or  ALGN = 1
      then
	A := ALGN;
      elsif ALGN = 0
      then								--| repli : ancienne regle par taille totale
	if SIZ > 4
	then
	  A := 8;
	elsif SIZ > 2
	then
	  A := 4;
	elsif SIZ > 1
	then
	  A := 2;
	end if;
      else
	FAULT( "alignement STATOFS invalide" );
      end if;
      SPOSES( STOP ) := ALIGNED( SPOSES( STOP ), A );
      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( E, 1 ) ),
			   SYMBOLS.STATIC_OFFSET, SPOSES( STOP ) );
      SPOSES( STOP ) := SPOSES( STOP ) + SIZ;				--| rb siz : OCTETS
    end DO_STATOFS;



    procedure		DO_ASSIGN ( E :IR.ELT_ID )
    --| affectation generale "X = expr" (les gardes n 97 sont interceptees
    --| a P0). Forme "X = $" : position courante de la VARzone ROUVERTE -
    --| le loc_siz de niveau 0 de la queue du .fas, SANS align_q (fidele a
    --| l'expander ; endPRO, lui, aligne). Sinon : EVAL, refus bruyant.
    is
      R			: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 1 ) );
      RL		: NATURAL;
    begin
      if IR.N_OPS( E ) < 1
      then
	FAULT( "affectation sans expression" );
      end if;
      RL := R'LAST;
      while RL >= R'FIRST  and then  ( R( RL ) = ' '  or  R( RL ) = ASCII.HT )
      loop
	RL := RL - 1;
      end loop;

      if RL = R'FIRST  and then  R( R'FIRST ) = '$'
      then
	if REOPENED  and then  FTOP > 0
	then								--| $ de la VARzone ROUVERTE (queue du .fas)
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			       SYMBOLS.PLAIN_VALUE, VPOSES( FTOP ) );
	elsif STOP > 0
	then								--| $ d'une zone STATIQUE (records manuels :
	  SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),		--| X = $ / rd 1 ; size = $ apres STATOFS - TC-12)
			       SYMBOLS.PLAIN_VALUE, SPOSES( STOP ) );
	else
	  FAULT( "affectation de $ hors de toute zone : "
		 & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
	end if;

      else
	SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.MNEMO_OF( E ) ),
			     SYMBOLS.PLAIN_VALUE,
			     LEX.EVAL( IR.OP_TXT( E, 1 ) ) );
      end if;
    end DO_ASSIGN;


  begin
    FTOP := 0;
    STOP := 0;

    for  E in FROM .. TO  loop
      declare
        EI	:constant IR.ELT_ID		:= IR.ELT_ID( E );
      begin
	SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
	if ACTIVE( EI )
	then
	  SYMBOLS.USE_SCOPE( IR.SCOPE_OF( EI ) );

	  if IR.KIND_OF( EI ) = IR.AREA_DEF
	  then								--| "VARzone::" (tete canonique, dans un virtual
	    if LEX.IMAGE( IR.MNEMO_OF( EI ) ) /= "VARzone"		--| at) : OUVERTURE DU FRAME DE NIVEAU 0 - les VAR
	    then							--| du niveau 0 y logent ; jamais depile par endPRO
	      FAULT( "zone d'adressage inconnue : "
		     & LEX.IMAGE( IR.MNEMO_OF( EI ) ) );
	    end if;
	    if STOP = 0  or else  FTOP /= 0  or else  FRAME0
	    then
	      FAULT( "VARzone:: attendu une fois, au niveau 0, dans un virtual at" );
	    end if;
	    FTOP := 1;
	    VPOSES( 1 ) := SPOSES( STOP );				--| $ courant de la zone englobante (8)
	    PPOSES( 1 ) := 8;
	    FRAME0 := TRUE;

	  elsif IR.KIND_OF( EI ) = IR.VIRT_REOPEN
	  then								--| "virtual VARzone" (queue du .fas) : le $ des
	    if IR.N_OPS( EI ) < 1					--| affectations devient la position courante du
	       or else  IR.OP_TAG( EI, 1 ) /= IR.NAME_OP		--| frame au sommet de la pile
	       or else  LEX.IMAGE( IR.OP_TXT( EI, 1 ) ) /= "VARzone"
	    then
	      FAULT( "reouverture de zone inconnue" );
	    end if;
	    if FTOP = 0  or else  REOPENED
	    then
	      FAULT( "virtual VARzone hors frame ou deja rouvert" );
	    end if;
	    REOPENED := TRUE;

	  elsif IR.KIND_OF( EI ) = IR.ASSIGNMENT
	  then								--| "X = expr" (spec IR : evaluee en P2) ; la
	    DO_ASSIGN( EI );						--| forme "X = $" exige la zone rouverte

	  elsif IR.KIND_OF( EI ) = IR.VIRT_OPEN
	  then
	    if STOP = SZONE_MAX
	    then
	      FAULT( "zones virtual trop imbriquees" );
	    end if;
	    if IR.N_OPS( EI ) < 1  or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
	    then
	      FAULT( "virtual at sans base litterale" );
	    end if;
	    STOP := STOP + 1;
	    SPOSES( STOP ) := IR.OP_INT( EI, 1 );

	  elsif IR.KIND_OF( EI ) = IR.VIRT_CLOSE
	  then
	    if REOPENED
	    then							--| fermeture de la reouverture : STOP intact
	      REOPENED := FALSE;
	    else
	      if STOP = 0
	      then
		FAULT( "end virtual sans virtual" );
	      end if;
	      STOP := STOP - 1;
	    end if;

	  elsif IR.KIND_OF( EI ) = IR.MACRO_CALL
	  then
	    if  MNEMO_IS( EI, "PRO" )  then
	      PUSH_FRAME( IR.SCOPE_OF( EI ) );

--	      if FTOP = FRAME_MAX
--	      then
--		FAULT( "sous-programmes trop imbriques" );
--	      end if;
--	      FTOP := FTOP + 1;
--	      VPOSES( FTOP ) := 8;
--	      PPOSES( FTOP ) := 8;

	    elsif  MNEMO_IS( EI, "PRMS" )  then
	      if  FTOP = 0  then
	        FAULT( "PRMS hors frame" );
	      end if;
  -- chaque liste de parametres est un nouveau
  -- virtual at 8 dans le codi
	      PPOSES( FTOP ) := 8;

	    elsif  MNEMO_IS( EI, "PRM" )  then
	      if  FTOP = 0
		or else IR.N_OPS( EI ) < 1
		or else IR.OP_TAG( EI, 1 ) /= IR.NAME_OP
	      then
	        FAULT( "forme PRM inattendue" );
	      end if;

	      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( EI, 1 ) ),
				   SYMBOLS.PARAM_OFFSET, PPOSES( FTOP ) );
	      PPOSES( FTOP ) := PPOSES( FTOP ) + 8;			--| dq ?

	    elsif  MNEMO_IS( EI, "endPRMS" )  then
	      if  FTOP = 0  then
		FAULT( "endPRMS hors sous-programme" );
	      end if;
	      SYMBOLS.DECLARE_SYM( "prm_siz", SYMBOLS.PLAIN_VALUE,
				   PPOSES( FTOP ) - 8 );		--| $-8

	    elsif  MNEMO_IS( EI, "ELB" )  then
 		-- Un PRO a deja ouvert la frame d'un sous-programme.
 		-- Un bloc namespace ... ELB n'en a pas : ELB l'ouvre implicitement.
	      declare
	        use SYMBOLS;
	        BLOC_ELB	: BOOLEAN	:= FSCOPES( FTOP ) /= IR.SCOPE_OF( EI );
	      begin
	        if  FTOP = 0  or else BLOC_ELB  then
		PUSH_FRAME( IR.SCOPE_OF( EI ) );
	        end if;
	      end;
	      SYMBOLS.DECLARE_SYM( "elab", SYMBOLS.CODE_LABEL );
	      VPOSES( FTOP ) := 8;

--	      if FTOP = 0
--	      then
--		FAULT( "ELB hors sous-programme" );
--	      end if;

	    elsif MNEMO_IS( EI, "VAR" )
	    then
	      DO_VAR( EI );

	    elsif MNEMO_IS( EI, "USEINFO" )  then
	      if  FTOP = 0  or else  IR.N_OPS( EI ) < 2							--| le NOM est l'operande 2 (signature relue
		 or else  IR.OP_TAG( EI, 2 ) /= IR.NAME_OP						--| TC-05 ; op1 = lvl, op3 = instruction de
	      then										--| charge, dimensionnee par EMITS)
	        FAULT( "forme USEINFO inattendue" );
	      end if;
	      VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), 8 );
	      SYMBOLS.DECLARE_SYM( LEX.IMAGE( IR.OP_TXT( EI, 2 ) ) & "__u",
				   SYMBOLS.FRAME_OFFSET, VPOSES( FTOP ) );
	      VPOSES( FTOP ) := VPOSES( FTOP ) + 8;

	    elsif  MNEMO_IS( EI, "endPRO" )  then
	      if  FTOP = 0  then
	        FAULT( "endPRO hors frame" );
	      end if;

	      declare
	        use SYMBOLS;
	        SCOPE_MISMATCH	: BOOLEAN	:= FSCOPES( FTOP ) /= IR.SCOPE_OF( EI );
	      begin
	        if  SCOPE_MISMATCH  then
		FAULT( "endPRO : scope different de la frame courante" );
	        end if;
	      end;
	      SYMBOLS.DECLARE_SYM( "post", SYMBOLS.CODE_LABEL );
	      VPOSES( FTOP ) := ALIGNED( VPOSES( FTOP ), 8 );
	      SYMBOLS.DECLARE_SYM( "loc_siz", SYMBOLS.PLAIN_VALUE, VPOSES( FTOP ) );
	      FTOP := FTOP - 1;

	    elsif  MNEMO_IS( EI, "STATOFS" )  then
	      DO_STATOFS( EI );

	    elsif  MNEMO_IS( EI, "rd" )  then								--| reservation de N dwords en zone statique
	      if  STOP = 0  or else  IR.N_OPS( EI ) < 1							--| (records manuels de _STANDRD - TC-12)
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
	        FAULT( "forme rd inattendue (N dwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 4 * IR.OP_INT( EI, 1 );

	    elsif  MNEMO_IS( EI, "rq" )  then								--| reservation de N qwords (ADA_COMP, TC-25)
	      if  STOP = 0  or else  IR.N_OPS( EI ) < 1
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
	        FAULT( "forme rq inattendue (N qwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 8 * IR.OP_INT( EI, 1 );

	    end if;
	  end if;
	end if;
      end;
    end loop;

    if FTOP /= 0  and then  not ( FRAME0  and  FTOP = 1 )
    then
      FAULT( "PRO sans endPRO en fin d'IR" );
    end if;

    if REOPENED
    then
      FAULT( "virtual VARzone sans end virtual en fin d'IR" );
    end if;

    if STOP /= 0
    then
      FAULT( "virtual sans end virtual en fin d'IR" );
    end if;
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );								--| hors boucle : tout redevient visible (TC-24)

  end	P2_LAYOUT;
	---------


	------
end	PASSES;
	------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
