------------------------------------------------------------------------------------------------------------------------
--
--	T A R G E T _ C O D E . E M I T S   --   corps  (remplace le corps vide)
--
--	TRANCHE TC-04, cible x86-64 seule : infrastructure (tampon, ecritures
--	little-endian, en-tete ELF64 + Phdr, amorcage) et premiere tranche de
--	la table d'encodage - transcription OCTET PAR OCTET de
--	codi_x86_64.finc (les db/dd commentes SONT la spec) :
--	  DROP(4) DUP(12) LI(18 = movabs+PUSH_RAX) ADD(12) SUB(12) MUL(24)
--	  BRA(5 = E9 rel32) SYS_EXIT(7 si code=0, 10 sinon).
--	Toute mnemonique hors tranche : refus bruyant (la table se remplit
--	livraison par livraison, chaque ajout sous l'oracle cmp vs fasmg).
--
--	CONTRAT (NOTE v1 par 2.5) : SIZE_OF ne depend JAMAIS d'une adresse non
--	posee. P2B (adressage) : une passe, tailles deterministes, labels
--	poses, ASM_SIZE = $ - ENTRY. P3 : emission ; auto-controle par element
--	(octets emis = SIZE_OF, sinon refus bruyant - le contrat est verifie
--	a chaque tour, pas suppose).
--	Constantes differees (STR/CST, LIFO) : TC-05.
--	MULTICIBLE (C0, 26 aout) : ce corps est le pilote GENERIQUE de l'emission.
--	Chaque cible est une sous-unite (X86_64_TARGET, ARM64_TARGET,
--	RISCV64_TARGET) qui n'expose que TRAITS, SIZE_OF, ENCODE, PROLOGUE.
--	Quatre points de dispatch (case TARGET_CPU) et quatre seulement ; le
--	reste ne connait la cible que par TR (traits courants). Les mnemoniques
--	de DONNEES et de DECLARATION, identiques dans tous les codi, sont
--	traitees ici, avant le case (bourrage TR.PAD_BYTE).
--
--	AMORCAGE (codi tete + queue) : org 0x400000, entree 0x400078
--	(= 64 ELF + 56 Phdr), prologue 82 octets : xor rax ; mmap tas 64 Mo
--	(r12 = haut) ; pile montante (rsp -4 Mo, r15 display 32, rbp, FP0) ;
--	co-pile (r14 = ENTRY + 8*((ASM_SIZE+7)/8), premier frame, r13).
--	p_filesz = ASM_SIZE ; p_memsz = ASM_SIZE + 16 Gio (budget co-pile).
--
--	HYPOTHESE TLALOC (temoin TC-04) : SEQUENTIAL_IO( CHARACTER ) ecrit
--	un octet par element. Si faux, le cmp le dira immediatement.
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE )

					-----
package body				EMITS
is					-----

  use IR;												--| operateurs ELT_KIND / OPERAND_TAG (LRM 8.4)

  package BIO		is new SEQUENTIAL_IO( CHARACTER );

  ORG			: constant			:= 16#400000#;
  ENTRY_PT		: constant			:= 16#400078#;
  CURADDR			: SYMBOLS.VALUE_TYPE		:= 0;					--| adresse du POINT D'APPEL de SIZE_OF (posee par
												--| P2B et P3) : alignements INLINE (END_BLOC_DEF)
  HEAP_SIZE		: constant			:= 64 * 1024 * 1024;			--| TAILLE_TAS (identique sur toutes les cibles)
  TR			: TARGET_TRAITS;								--| traits de la cible courante, poses en tete de
												--| P2B et de P3 (objet : avant tout corps, Ada 83)

  --  tampon binaire

  BIN_MAX			: constant			:= 32_000_000;
  subtype BYTE		is INTEGER range 0 .. 255;
  BIN			: array ( 0 .. BIN_MAX ) of BYTE;
  TOP			: INTEGER				:= 0;					--| = offset fichier du prochain octet

  ASM			: SYMBOLS.VALUE_TYPE		:= 0;					--| ASM_SIZE ( $ - ENTRY )


			-----
  procedure		FAULT		( MSG :STRING )
  is			-----
  begin
    PUT_LINE( "TARGET_CODE.EMITS : " & MSG );
    raise  EMIT_FAULT;

  end	FAULT;
	-----

		-- ecritures little-endian (negatifs : complement a deux via mod)

			---
  procedure		 B		( V :INTEGER )
  is			---
  begin
    if  TOP > BIN_MAX  then
      FAULT( "tampon binaire plein (BIN_MAX)" );
    end if;

    BIN( TOP ) := V mod 256;
    TOP := TOP + 1;
  end	 B;
	---

			---
  procedure		W16		( V :INTEGER )
  is			---
  begin
    B( V );
    B( V / 256 );

  end	W16;
	---

			---
  procedure		D32		( V :INTEGER )
  is			---
    U			: INTEGER	:= V;
  begin
    for  I in 1 .. 4  loop
      B( U mod 256 );
      U := ( U - ( U mod 256 ) ) / 256;									--| division apres retrait du reste :
    end loop;											--| correcte aussi pour les negatifs (rel32)

  end	D32;
	---

			---
  procedure		Q64		( V :SYMBOLS.VALUE_TYPE )
  is			---
    U			: SYMBOLS.VALUE_TYPE := V;
  begin
    for  I in 1 .. 8  loop
      B( INTEGER( U mod 256 ) );
      U := ( U - ( U mod 256 ) ) / 256;
    end loop;

  end	Q64;
	---


  --| extraction par arithmetique EXACTE (multiplications par 2) - la						--| 52 bits de mantisse, 11 d'exposant,
  --| mantisse de LONG_FLOAT (double hote) tient dans 52 bits, le residu					--| 1 de signe
  --| final est nul. Denormaux, infinis, NaN : hors corpus, refus bruyant.

			-----------
  function		DOUBLE_BITS	( V :LONG_FLOAT )		return SYMBOLS.VALUE_TYPE
  is			-----------								--| motif 64 bits d'un double : M + BSE * 2**52
    A			: LONG_FLOAT		:= V;						--| + SGN * 2**63 ; 2**63 n'est pas representable,
    SGN			: BOOLEAN		:= FALSE;					--| le motif signe est rendu NEGATIF (Q64 ecrit
    EXP			: INTEGER			:= 0;					--| le complement a deux : memes octets qu'avant)
    M			: SYMBOLS.VALUE_TYPE	:= 0;
    R			: SYMBOLS.VALUE_TYPE;
  begin
    if  A = 0.0  then
      return  0;
    end if;
    if  A < 0.0  then
      SGN := TRUE;
      A := -A;
    end if;
    while  A >= 2.0  loop
      A := A / 2.0;
      EXP := EXP + 1;
    end loop;
    while  A < 1.0  loop
      A := A * 2.0;
      EXP := EXP - 1;
    end loop;
    if  EXP + 1023 < 1  or else  EXP + 1023 > 2046  then
      FAULT( "flottant hors du corpus (denormal ou infini)" );
    end if;
    A := A - 1.0;
    for  I in 1 .. 52  loop
      A := A * 2.0;
      M := M * 2;
      if  A >= 1.0  then
        M := M + 1;
        A := A - 1.0;
      end if;
    end loop;
    R := M + SYMBOLS.VALUE_TYPE( EXP + 1023 ) * 2 ** 52;							--| mantisse (52 bits) + exposant biaise
    if  SGN  then
      R := R - 2 ** 62 - 2 ** 62;									--| - 2**63 en deux temps (bit de signe)
    end if;
    return  R;

  end	DOUBLE_BITS;
	-----------

			----
  procedure		Q64F		( V :LONG_FLOAT )						--| IEEE 754 double, petit-boutiste
  is			----
  begin
    Q64( DOUBLE_BITS( V ) );

  end	Q64F;
	----


  --|  Famille des acces de frame (TC-06) - briques partagees.
  --|  Widths des sequences disp (codi FETCH_*/STORE_*) : W0 pour disp=0,
  --|  W0+1 pour -128..127, W0+4 au dela. LEA de LVA : 0 octet si disp=0.

  --| valeur d'operande : vide/absent -> defaut (lvl:-1, disp:0) ; entier ;
  --| NOM resolu (offsets de P2_LAYOUT - pas d'adresses : contrat intact) ;
  --| expression via LEX.EVAL. Le scope courant est celui de l'element
  --| (pose par les boucles P2B/P3).
			---
  function		OPV		( E :IR.ELT_ID; I :NATURAL;
					  DEF :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			---
  begin
    if  I > IR.N_OPS( E )  or else  IR.OP_TAG( E, I ) = IR.EMPTY_OP  then
      return  DEF;
    elsif  IR.OP_TAG( E, I ) = IR.INT_OP  then
      return  IR.OP_INT( E, I );
    elsif  IR.OP_TAG( E, I ) = IR.NAME_OP  then
      return  SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, I ) ) ) );
    elsif  IR.OP_TAG( E, I ) = IR.EXPR_OP  then
      return  LEX.EVAL( IR.OP_TXT( E, I ) );
    end if;
    FAULT( "operande de forme inattendue" );
    return 0;

  end	OPV;
	---


  --| longueur d'une tranche STRB : octets EFFECTIFS (le doublage du
  --| delimiteur est resolu au STORE par CLASSIFY depuis TC-12)

			--------
  function		STRB_LEN		( S :LEX.SLICE )		return SYMBOLS.VALUE_TYPE
  is			--------
  begin
    if  S.F = 0  or  S.L < S.F  then
      return  0;
    end if;
    return  SYMBOLS.VALUE_TYPE( S.L - S.F + 1 );

  end	STRB_LEN;
	--------


  --| contenu d'un db : TOUS les operandes (entiers 0..255 et chaines)

			------
  function		DB_LEN		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			------

    N	: SYMBOLS.VALUE_TYPE	:= 0;

  begin
    if  IR.N_OPS( E ) < 1  then
      FAULT( "db sans contenu" );
    end if;

    for  I in 1 .. IR.N_OPS( E )  loop
      if  IR.OP_TAG( E, I ) = IR.STRB_OP  then
        N := N + STRB_LEN( IR.OP_TXT( E, I ) );
      elsif  IR.OP_TAG( E, I ) = IR.INT_OP  then
        if  IR.OP_INT( E, I ) < 0  or else  IR.OP_INT( E, I ) > 255  then
	FAULT( "octet de db hors 0..255" );
        end if;
        N := N + 1;
      else
	FAULT( "contenu de db inattendu (chaine ou octet)" );
      end if;
    end loop;
    return  N;

  end	DB_LEN;
	------


  --| adresse de prefix.subname.elab pour CALL/LSPA - le prefixe des FINC
  --| reels porte un POINT FINAL de concatenation (releve EXP-03) ; le
  --| temoin, lui, ecrit "STANDARD" nu : les deux formes sont acceptees.

			-----------
  function		ELAB_TARGET	( E :IR.ELT_ID )	return SYMBOLS.VALUE_TYPE
  is			-----------

    P			: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 1 ) );
    S			: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );

  begin
    if  IR.N_OPS( E ) < 2
       or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP
       or else  IR.OP_TAG( E, 2 ) /= IR.NAME_OP
    then
      FAULT( "CALL/LSPA : prefixe, sous-nom attendus" );
    end if;
    return  SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( P & S & ".elab" ) );						--| concatenation FIDELE (le point du prefixe
												--| est le separateur, fourni par l'appelant :
												--| forme nue = nom soude = echec bruyant,
												--| comme fasmg - temoin TC-07c)
  end	ELAB_TARGET;
	-----------


			-------
  procedure		EMIT_DB		( E :IR.ELT_ID )
  is			-------
  begin
    for  K in 1 .. IR.N_OPS( E )  loop
      if  IR.OP_TAG( E, K ) = IR.STRB_OP  then
        declare
	T		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, K ) );
        begin
	for  I in T'RANGE  loop
	  B( CHARACTER'POS( T( I ) ) );
	end loop;
        end;
      else
        B( INTEGER( IR.OP_INT( E, K ) ) );
      end if;
    end loop;

  end	EMIT_DB;
	-------


				-------------
  package				X86_64_TARGET
  is				-------------

    TRAITS	:constant TARGET_TRAITS
		:= ( E_MACHINE		=> 62,
		     ORIG			=> 16#400000#,
		     ENTRY_POINT		=> 16#400078#,
		     PAD_BYTE		=> 16#90#,						--| nop
		     CALL_FRAME		=> 8,
		     MEMSZ_RESERVE		=> 16 * 1024 * 1024 * 1024,					--| TAILLE_COPILE 16 Gio (codi_x86_64)
		     PROLOGUE_SIZE		=> 82,
		     BRA_SIZE		=> 5 );							--| E9 rel32

    function  SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE;
    procedure ENCODE		( E :IR.ELT_ID );
    procedure PROLOGUE;										--| amorcage (codi queue), TRAITS.PROLOGUE_SIZE octets

	-------------
  end	X86_64_TARGET;
	-------------
  package body X86_64_TARGET is separate;


				------------
  package				ARM64_TARGET
  is				------------

    TRAITS	:constant TARGET_TRAITS
		:= ( E_MACHINE		=> 183,							--| EM_AARCH64
		     ORIG			=> 16#400000#,
		     ENTRY_POINT		=> 16#400078#,
		     PAD_BYTE		=> 0,							--| padding zero (data, not code)
		     CALL_FRAME		=> 16,							--| sp aligne 16
		     MEMSZ_RESERVE		=> 1 * 1024 * 1024 * 1024,					--| TAILLE_COPILE 1 Gio (codi_arm64)
		     PROLOGUE_SIZE		=> 92,							--| 23 mots de 32 bits
		     BRA_SIZE		=> 4 );							--| b imm26

    function  SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE;
    procedure ENCODE		( E :IR.ELT_ID );
    procedure PROLOGUE;

	------------
  end	ARM64_TARGET;
	------------
  package body ARM64_TARGET is separate;


				--------------
  package				RISCV64_TARGET
  is				--------------

    TRAITS	:constant TARGET_TRAITS								--| A POSER avec codi_riscv64.finc : seuls
		:= ( E_MACHINE		=> 243,							--| E_MACHINE, PAD et CALL_FRAME sont acquis
		     ORIG			=> 16#400000#,
		     ENTRY_POINT		=> 16#400078#,
		     PAD_BYTE		=> 0,
		     CALL_FRAME		=> 16,
		     MEMSZ_RESERVE		=> 1 * 1024 * 1024 * 1024,					--| provisoire
		     PROLOGUE_SIZE		=> 0,							--| provisoire
		     BRA_SIZE		=> 8 );							--| provisoire (auipc + jalr)

    function  SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE;
    procedure ENCODE		( E :IR.ELT_ID );
    procedure PROLOGUE;

	--------------
  end	RISCV64_TARGET;
	--------------
  package body RISCV64_TARGET is separate;



  --|  Quatre points de dispatch, et quatre seulement : TRAITS, PROLOGUE,
  --|  SIZE_OF, ENCODE. Les mnemoniques de DONNEES (db, END_BLOC_DEF, STR/CST
  --|  differes) et de DECLARATION (rd, rq, USEINFO, STATOFS, VAR, PRMS, PRM,
  --|  endPRMS, endPRO) sont identiques dans tous les codi : traitees ICI,
  --|  avant le case, bourrage TR.PAD_BYTE. BEGIN_BLOC_DEF est un BRA : cible.

			------
  function		TRAITS					return TARGET_TRAITS
  is			------
  begin
    case  TARGET_CPU  is
      when X86_64  => return X86_64_TARGET.TRAITS;
      when ARM64   => return ARM64_TARGET.TRAITS;
      when RISCV64 => return RISCV64_TARGET.TRAITS;
    end case;
  end	TRAITS;
	------

			--------
  procedure		PROLOGUE
  is			--------
  begin
    case  TARGET_CPU  is
      when X86_64  => X86_64_TARGET.PROLOGUE;
      when ARM64   => ARM64_TARGET.PROLOGUE;
      when RISCV64 => RISCV64_TARGET.PROLOGUE;
    end case;
  end	PROLOGUE;
	--------

			-------
  function		SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			-------

    M	:constant STRING	:= LEX.IMAGE( IR.MNEMO_OF( E ) );

  begin
    if  IR.KIND_OF( E ) /= IR.MACRO_CALL  then  return 0;							--| labels, virtual, map : zero octet
    end if;

    if  M = "db"  then  return  DB_LEN( E );								--| octets inline
    elsif  M = "rd"  or else  M = "rq"  then  return  0;							--| reservation statique (TC-12)
    elsif  M = "STR"  or else  M = "CST"  then  return  0;							--| DIFFERE : place/emis apres le code (LIFO)
    elsif  M = "USEINFO"  or else  M = "STATOFS"  or else  M = "VAR"  then  return  0;				--| pure declaration : zero octet
    elsif  M = "PRMS"  or else  M = "PRM"  or else  M = "endPRMS"  or else  M = "endPRO"
      then  return  0;											--| pure declaration : zero octet
    elsif  M = "END_BLOC_DEF"  then									--| info dd x4 + align_q + dd x4 + dq x2 :
      return  48 + ( 8 - ( ( CURADDR + 16 ) mod 8 ) ) mod 8;							--| l'adresse du point d'appel donne le bourrage
    end if;

    case  TARGET_CPU  is
      when X86_64  => return X86_64_TARGET.SIZE_OF( E );
      when ARM64   => return ARM64_TARGET.SIZE_OF( E );
      when RISCV64 => return RISCV64_TARGET.SIZE_OF( E );
    end case;

  end	SIZE_OF;
	-------

			------
  procedure		ENCODE		( E :IR.ELT_ID )
  is			------

    M			: constant STRING		:= LEX.IMAGE( IR.MNEMO_OF( E ) );

  begin
    if  M = "db"  then
      EMIT_DB( E );

    elsif  M = "rd"  or else  M = "rq"
       or else  M = "STR"  or else  M = "CST"								--| differes : emis apres le code par DO_DEFERRED
       or else  M = "USEINFO"  or else  M = "STATOFS"  or else  M = "VAR"
       or else  M = "PRMS"  or else  M = "PRM"  or else  M = "endPRMS"  or else  M = "endPRO"
    then
      null;											--| pure declaration : zero octet

    elsif  M = "END_BLOC_DEF"  then
      declare
        D0	: constant SYMBOLS.VALUE_TYPE
			:= SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.data" ) );
        D1	: constant SYMBOLS.VALUE_TYPE
			:= SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.data_end" ) );
      begin
        D32( INTEGER( 8 * ( D1 - D0 ) ) );								--| info : longueur en BITS
        D32( 8 );
        D32( 1 );
        D32( INTEGER( D1 - D0 ) );
        while  ( ORG + SYMBOLS.VALUE_TYPE( TOP ) ) mod 8 /= 0  loop
	B( TR.PAD_BYTE );										--| align_q : bourrage de la cible
        end loop;
        D32( INTEGER( OPV( E, 1, 0 ) ) );								--| SIZ (en bits pour un enumere)
        D32( INTEGER( OPV( E, 2, 0 ) ) );								--| FST
        D32( INTEGER( OPV( E, 3, 0 ) ) );								--| LST
        D32( 0 );
        Q64( D0 );											--| data_ptr
        Q64( SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.info" ) ) );						--| info_ptr
      end;

    else
      case  TARGET_CPU  is
        when X86_64  => X86_64_TARGET.ENCODE( E );
        when ARM64   => ARM64_TARGET.ENCODE( E );
        when RISCV64 => RISCV64_TARGET.ENCODE( E );
      end case;
    end if;

  end	ENCODE;
	------


  --|  Differes STR/CST : UNE routine, deux modes (LIFO : dernier
  --|  enregistre place/emis en PREMIER - releve DIS_BONJOUR).
  --|  PLACING : pose les adresses (P2B) ; sinon : emet (P3), bourrage
  --|  TR.PAD_BYTE, et VERIFIE que chaque adresse emise egale l'adresse posee.

			-----------
  procedure		DO_DEFERRED	( PLACING :BOOLEAN;
					  FROM, TO :IR.ELT_ID;
					  CUR :in out SYMBOLS.VALUE_TYPE )
  is			-----------

    S0	:constant SYMBOLS.SCOPE_ID	:= SYMBOLS.CURRENT_SCOPE;

  --| contenu d'un STR = operandes 2.. : chaine quotee (STRB) ou OCTET
  --| litteral (db du codi - tete reelle : STR EXC_NL__, 10), melables

			---------------
  function		STR_CONTENT_LEN		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			---------------

    N	: SYMBOLS.VALUE_TYPE	:= 0;

  begin
    if  IR.N_OPS( E ) < 2  then
      FAULT( "STR sans contenu" );
    end if;

    for  I in 2 .. IR.N_OPS( E )  loop
      if  IR.OP_TAG( E, I ) = IR.STRB_OP  then
        N := N + STRB_LEN( IR.OP_TXT( E, I ) );
      elsif  IR.OP_TAG( E, I ) = IR.INT_OP  then
        if  IR.OP_INT( E, I ) < 0  or else  IR.OP_INT( E, I ) > 255  then
	FAULT( "octet de STR hors 0..255" );
        end if;
        N := N + 1;
      else
        FAULT( "contenu de STR inattendu (chaine ou octet)" );
      end if;
    end loop;
    return  N;

  end	STR_CONTENT_LEN;
	---------------

			----------------
  procedure		EMIT_STR_CONTENT		( E :IR.ELT_ID )
  is			----------------
  begin
    for  K in 2 .. IR.N_OPS( E )  loop
      if  IR.OP_TAG( E, K ) = IR.STRB_OP  then
        declare
	T	: constant STRING	:= LEX.IMAGE( IR.OP_TXT( E, K ) );
	I	: NATURAL		:= T'FIRST;
        begin
	while  I <= T'LAST  loop
	  B( CHARACTER'POS( T( I ) ) );								--| octets effectifs (doublage resolu au STORE)
	  I := I + 1;
	end loop;
        end;
      else
        B( INTEGER( IR.OP_INT( E, K ) ) );								--| octet litteral (controle par STR_CONTENT_LEN)
      end if;
    end loop;

  end	EMIT_STR_CONTENT;
	----------------

			--------
  function		ALIGNED8		( P :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			--------
  begin
    if  P mod 8 = 0  then
      return  P;
    end if;
    return  P + 8 - ( P mod 8 );

  end	ALIGNED8;
	--------


  begin
    for  DI in reverse 1 .. IR.DEFER_COUNT  loop
      declare
        E		:constant IR.ELT_ID		:= IR.DEFER_AT( DI );
        M		:constant STRING		:= LEX.IMAGE( IR.MNEMO_OF( E ) );
        NAME	:constant STRING		:= LEX.IMAGE( IR.OP_TXT( E, 1 ) );
      begin
	SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
	if  E < FROM  or else  E > TO  then								--| liste GLOBALE, plage locale : les differes des
	  null;											--| temoins precedents ne fuient plus ici (fuite
												--| 'Bonjour' vue au byte-diff, cmp octet 97 -
												--| emise DERNIERE : meme la fuite etait LIFO)
	elsif not PASSES.ACTIVE( E )
	then											--| differe d'un CORPS MORT (paresse n 110) :
	  null;											--| fasmg le saute avec sa garde, nous aussi
												--| (STR vide de RET_STR_L57, 32 octets, releve
												--| du byte-diff integral du 21 aout)

	elsif M = "STR"
	then
	  declare
	    LEN		: constant SYMBOLS.VALUE_TYPE := STR_CONTENT_LEN( E );
	    P		: constant SYMBOLS.VALUE_TYPE := ALIGNED8( CUR );
	  begin
	    if PLACING
	    then
	      SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( NAME & ".data_ptr" ), P );
	      SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( NAME & ".info_ptr" ), P + 8 );
	      SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( NAME & ".info" ),     P + 16 );
	      SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( NAME & ".data" ),     P + 32 );
	    else
	      while ORG + SYMBOLS.VALUE_TYPE( TOP ) < P
	      loop
	        B( TR.PAD_BYTE );									--| bourrage align_q de la cible (byte-diff !)
	      end loop;
	      if SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( NAME & ".data_ptr" ) )
		 /= ORG + SYMBOLS.VALUE_TYPE( TOP )
	      then
		FAULT( "placement STR incoherent P2B/P3 : " & NAME );
	      end if;
	      Q64( P + 32 );									--| dq data
	      Q64( P + 16 );									--| dq info
	      D32( INTEGER( 8 * LEN ) );								--| SIZ  (bits)
	      D32( 8 );										--| COMP_SIZ
	      D32( 1 );										--| FST_1
	      D32( INTEGER( LEN ) );									--| LST_1
	      EMIT_STR_CONTENT( E );
	    end if;
	    CUR := P + 32 + LEN;
	  end;

	elsif M = "CST"
	then
	  declare
	    C		: constant STRING := LEX.IMAGE( IR.OP_TXT( E, 2 ) );
	    UNIT	: SYMBOLS.VALUE_TYPE;
	    P		: SYMBOLS.VALUE_TYPE;
	    VAL		: SYMBOLS.VALUE_TYPE;
	  begin
	    if C = "b"
	    then
	      UNIT := 1;
	    elsif C = "w"
	    then
	      UNIT := 2;
	    elsif C = "d"
	    then
	      UNIT := 4;
	    elsif C = "q"
	    then
	      UNIT := 8;
	    else
	      FAULT( "CST : unite inconnue : " & C );
	    end if;
	    if IR.OP_TAG( E, 3 ) /= IR.INT_OP
	    then
	      FAULT( "CST : valeur litterale attendue (tranche TC-05)" );
	    end if;
	    VAL := IR.OP_INT( E, 3 );
	    P := CUR;
	    if UNIT > 1  and then  P mod UNIT /= 0
	    then
	      P := P + UNIT - ( P mod UNIT );
	    end if;
	    if PLACING
	    then
	      SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( NAME ), P );
	    else
	      while ORG + SYMBOLS.VALUE_TYPE( TOP ) < P
	      loop
		B( TR.PAD_BYTE );
	      end loop;
	      if UNIT = 1
	      then
		B( INTEGER( VAL mod 256 ) );
	      elsif UNIT = 2
	      then
		W16( INTEGER( VAL mod 65536 ) );
	      elsif UNIT = 4
	      then
		D32( INTEGER( VAL mod 4294967296 ) );
	      else
		Q64( VAL );
	      end if;
	    end if;
	    CUR := P + UNIT;
	  end;

	else
	  FAULT( "differe inattendu : " & M );
	end if;
      end;
    end loop;
    SYMBOLS.USE_SCOPE( S0 );

  end	DO_DEFERRED;
	-----------


		-- table de la tranche : tailles puis encodages




  -------------------------------------------------------------------------------------------------------------------
  --			en-tete ELF64 + Phdr (codi queue) et amorcage (codi tete)
  -------------------------------------------------------------------------------------------------------------------

			---------------
  procedure		EMIT_ELF_HEADER
  is			---------------
  begin
    B( 16#7F# ); B( CHARACTER'POS( 'E' ) ); B( CHARACTER'POS( 'L' ) ); B( CHARACTER'POS( 'F' ) );
    B( 2 ); B( 1 ); B( 1 ); B( 0 );									--| CLASS64, 2LSB, EV_CURRENT, SYSTEM_V
    for I in 1 .. 8
    loop
      B( 0 );											--| padding e_ident
    end loop;
    W16( 2 );											--| ET_EXEC
    W16( TR.E_MACHINE );										--| 62 x86, 183 aarch64, 243 riscv
    D32( 1 );											--| e_version
    Q64( ENTRY_PT );										--| e_entry
    Q64( 64 );											--| e_phoff
    Q64( 0 );											--| e_shoff
    D32( 0 );											--| e_flags
    W16( 64 );											--| e_ehsize
    W16( 56 );											--| e_phentsize
    W16( 1 );											--| e_phnum
    W16( 0 ); W16( 0 ); W16( 0 );									--| e_shentsize, e_shnum, e_shstrndx
    --  Phdr
    D32( 1 );											--| PT_LOAD
    D32( 7 );											--| RWX
    Q64( 16#78# );											--| p_offset
    Q64( ENTRY_PT );										--| p_vaddr
    Q64( 0 );											--| p_paddr
    Q64( ASM );											--| p_filesz
    Q64( ASM + SYMBOLS.VALUE_TYPE( TR.MEMSZ_RESERVE ) );							--| p_memsz : + TAILLE_COPILE de la cible (piege n 109)
    Q64( 4096 );											--| p_align
    if TOP /= 16#78#
    then
      FAULT( "en-tete ELF : longueur inattendue" );
    end if;

  end	EMIT_ELF_HEADER;
	---------------



  -------------------------------------------------------------------------------------------------------------------
  --			P2B : adressage  /  P3 : emission
  -------------------------------------------------------------------------------------------------------------------

  procedure		P2B_ADDRESSES ( FROM, TO :IR.ELT_ID )
  is
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    CUR			: SYMBOLS.VALUE_TYPE;
  begin
    TR := TRAITS;											--| traits de la cible courante (aussi lus par DO_DEFERRED)
    CUR := ENTRY_PT + SYMBOLS.VALUE_TYPE( TR.PROLOGUE_SIZE );
    for  E in FROM .. TO  loop
      if  PASSES.ACTIVE( E )  then
        SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
        SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
        if  IR.KIND_OF( E ) = IR.LABEL_DEF  then
	SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( LEX.IMAGE( IR.MNEMO_OF( E ) ) ), CUR );

        elsif  IR.KIND_OF( E ) = IR.MACRO_CALL  then
	if  LEX.IMAGE( IR.MNEMO_OF( E ) ) = "ELB"  then							--| le label elab vit DANS la macro : adresse
	  SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "elab" ), CUR );						--| AVANT le LINK qu'elle emet (TC-07)

	elsif  LEX.IMAGE( IR.MNEMO_OF( E ) ) = "endPRO"  then						--| idem pour post (cible du BRA de PRO)
	  SYMBOLS.SET_VALUE( SYMBOLS.RESOLVE( "post" ), CUR );

	elsif  LEX.IMAGE( IR.MNEMO_OF( E ) ) = "BEGIN_BLOC_DEF"  then					--| IMAGES.data = adresse APRES le BRA (TC-17)
	  SYMBOLS.ENTER_SCOPE( "IMAGES" );
	  SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data", SYMBOLS.CODE_LABEL ),
			 CUR + SYMBOLS.VALUE_TYPE( TR.BRA_SIZE ) );
	  SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );

	elsif  LEX.IMAGE( IR.MNEMO_OF( E ) ) = "END_BLOC_DEF"  then						--| ENUM_USE_INFO etendu : info a CUR, align_q
	  declare											--| NOP apres info, SIZ/FST/LST/pad (dd) puis
	    PS		: SYMBOLS.VALUE_TYPE;							--| data_ptr/info_ptr (dq) ; skip = fin, cible
	  begin											--| du BRA d'ouverture
	    PS := ( 8 - ( ( CUR + 16 ) mod 8 ) ) mod 8;
	    SYMBOLS.ENTER_SCOPE( "IMAGES" );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data_end", SYMBOLS.CODE_LABEL ), CUR );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "info", SYMBOLS.CODE_LABEL ), CUR );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data_ptr", SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 16 );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "info_ptr", SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 24 );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "skip", SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 32 );
	    SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "SIZ", SYMBOLS.CODE_LABEL ), CUR + 16 + PS );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "FST", SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 4 );
	    SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "LST", SYMBOLS.CODE_LABEL ), CUR + 16 + PS + 8 );
	  end;
	end if;
	CURADDR := CUR;										--| adresse du point d'appel (alignements inline)

	CUR := CUR + SIZE_OF( E );

        end if;
      end if;
    end loop;

    DO_DEFERRED( PLACING => TRUE, FROM => FROM, TO => TO, CUR => CUR );					--| constantes apres le code, LIFO (DIS_BONJOUR)
    ASM := CUR - ENTRY_PT;										--| pas de differes dans la tranche TC-04 (TC-05)
    if ORG + ASM >= 2 ** 32
    then
      FAULT( "image au dela de 2**32 : forme canonique d'adresse invalide" );
    end if;
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );									--| hors boucle : tout redevient visible (TC-24)

  end	P2B_ADDRESSES;
	-------------

			--------
  function		ASM_SIZE		return SYMBOLS.VALUE_TYPE
  is			--------
  begin
    return ASM;

  end	ASM_SIZE;
	--------


			-------
  procedure		P3_EMIT		( FROM, TO :IR.ELT_ID; BIN_NAME :STRING )
  is			-------

    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    T0			: INTEGER;
    F			: BIO.FILE_TYPE;

  begin
    TR := TRAITS;											--| avant EMIT_ELF_HEADER, qui lit TR
    TOP := 0;
    EMIT_ELF_HEADER;
    PROLOGUE;

    for  E in FROM .. TO  loop
      SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
      if PASSES.ACTIVE( E )  and then  IR.KIND_OF( E ) = IR.MACRO_CALL  then
	SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
	T0 := TOP;
	CURADDR := ORG + SYMBOLS.VALUE_TYPE( TOP );							--| pour le SIZE_OF du contrat (TC-17)

	ENCODE( E );
	if SYMBOLS.VALUE_TYPE( TOP - T0 ) /= SIZE_OF( E )
	then											--| auto-controle du contrat SIZE_OF = ENCODE
	  FAULT( "taille emise /= SIZE_OF : " & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
	end if;

      end if;
    end loop;

    declare
      CUR		: SYMBOLS.VALUE_TYPE := ORG + SYMBOLS.VALUE_TYPE( TOP );
    begin
      DO_DEFERRED( PLACING => FALSE, FROM => FROM, TO => TO, CUR => CUR );
    end;

    if SYMBOLS.VALUE_TYPE( TOP ) - 16#78# /= ASM
    then
      FAULT( "ASM_SIZE incoherent entre P2B et P3" );
    end if;

    BIO.CREATE( F, BIO.OUT_FILE, BIN_NAME );
    for I in 0 .. TOP - 1
    loop
      BIO.WRITE( F, CHARACTER'VAL( BIN( I ) ) );
    end loop;
    BIO.CLOSE( F );
    SYMBOLS.USE_SCOPE( S0 );
    SYMBOLS.SET_EPOCH( NATURAL'LAST );									--| hors boucle : tout redevient visible (TC-24)

  end	P3_EMIT;
	-------

			------------
  function		BIN_CAPACITY				return NATURAL
  is			------------
  begin
    return BIN_MAX;
  end	BIN_CAPACITY;
	------------


	-----
end	EMITS;
	-----

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
