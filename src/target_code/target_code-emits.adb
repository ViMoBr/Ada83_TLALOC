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
--	Constantes differees (STR/CST, LIFO) : TC-05. Retarget (ENCODE_ARM64,
--	ENCODE_RISCV64, TRAITS par cible) : reintroduit quand la table x86
--	sera complete - une seule cible ici, au plus simple.
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
  PROLOGUE_SIZE		: constant			:= 82;
  CURADDR			: SYMBOLS.VALUE_TYPE		:= 0;					--| adresse du POINT D'APPEL de SIZE_OF (posee par
												--| P2B et P3) : alignements INLINE (END_BLOC_DEF)
  HEAP_SIZE		: constant			:= 64 * 1024 * 1024;			--| TAILLE_TAS
  COPILE_RESERVE		: constant SYMBOLS.VALUE_TYPE 	:= 16 * 1024 * 1024 * 1024;

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

			----
  procedure		Q64F		( V :LONG_FLOAT )						--| IEEE 754 double, petit-boutiste :
  is			----
    A			: LONG_FLOAT		:= V;
    SGN			: SYMBOLS.VALUE_TYPE	:= 0;
    EXP			: INTEGER			:= 0;
    M			: SYMBOLS.VALUE_TYPE	:= 0;
    BSE			: SYMBOLS.VALUE_TYPE;
  begin
    if  A = 0.0  then
      for  I in 1 .. 8  loop
        B( 0 );
      end loop;
      return;
    end if;
    if  A < 0.0  then
      SGN := 1;
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
    BSE := SYMBOLS.VALUE_TYPE( EXP + 1023 );
    A := A - 1.0;
    for  I in 1 .. 52  loop
      A := A * 2.0;
      M := M * 2;
      if  A >= 1.0  then
        M := M + 1;
        A := A - 1.0;
      end if;
    end loop;
    for  I in 1 .. 6  loop										--| six octets bas de la mantisse
      B( INTEGER( M mod 256 ) );
      M := M / 256;
    end loop;
    B( INTEGER( M mod 16 ) + INTEGER( BSE mod 16 ) * 16 );							--| 4 bits hauts de mantisse + 4 bas d'exposant
    B( INTEGER( BSE / 16 ) + INTEGER( SGN ) * 128 );							--| 7 bits hauts d'exposant + signe
  end Q64F;



		-- briques ancillaires (codi : PUSH_RAX / POP_RAX)

			----------
  procedure		E_PUSH_RAX								--| 8 octets
  is			----------
  begin
    B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#08# );							--| mov [rbp+8], rax
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#08# );							--| lea rbp, [rbp+8]
  end	E_PUSH_RAX;
	----------
			---------
  procedure		E_POP_RAX									--| 8 octets
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );							--| mov rax, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RAX;
	---------
			---------
  procedure		E_POP_RBX									--| 8 octets (rangements, comparaisons)
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#5D# ); B( 16#00# );							--| mov rbx, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RBX;
	---------
			---------
  procedure		E_POP_RCX									--| 8 octets (decalages, conversions)
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#4D# ); B( 16#00# );							--| mov rcx, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RCX;
	---------
			---------
  procedure		E_POP_RDI									--| 8 octets (BLKMOV)
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#7D# ); B( 16#00# );							--| mov rdi, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RDI;
	---------
			---------
  procedure		E_POP_RSI									--| 8 octets (SYS_PUT_STR)
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#75# ); B( 16#00# );							--| mov rsi, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RSI;
	---------
			---------
  procedure		E_POP_RDX									--| 8 octets (E/S fichiers)
  is			---------
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#55# ); B( 16#00# );							--| mov rdx, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end	E_POP_RDX;
	---------
			-----------------
  procedure		E_COPY_STRING_NUL								--| COPY_STRING_APPEND_NUL du codi (31) :
  is			-----------------								--| copie la chaine Ada (doublet en rsi) sur
  begin												--| la pile montante, NUL final, rdi = debut
    B( 16#48# ); B( 16#8B# ); B( 16#46# ); B( 16#08# );							--| mov rax, [rsi+8]
    B( 16#8B# ); B( 16#48# ); B( 16#0C# );								--| mov ecx, [rax+12]
    B( 16#FF# ); B( 16#C1# );										--| inc ecx
    B( 16#2B# ); B( 16#48# ); B( 16#08# );								--| sub ecx, [rax+8]
    B( 16#48# ); B( 16#8B# ); B( 16#36# );								--| mov rsi, [rsi]
    B( 16#48# ); B( 16#8D# ); B( 16#7D# ); B( 16#08# );							--| lea rdi, [rbp+8]
    B( 16#FC# );											--| cld
    B( 16#AC# ); B( 16#AA# );										--| lodsb ; stosb
    B( 16#E2# ); B( 16#FC# );										--| loop
    B( 16#C6# ); B( 16#07# ); B( 16#00# );								--| mov byte [rdi], 0
    B( 16#48# ); B( 16#8D# ); B( 16#7D# ); B( 16#08# );							--| lea rdi, [rbp+8]
  end	E_COPY_STRING_NUL;
	-----------------

			-----------
  function		ELAB_TARGET	( E :IR.ELT_ID )	return SYMBOLS.VALUE_TYPE
  --| adresse de prefix.subname.elab pour CALL/LSPA - le prefixe des FINC
  --| reels porte un POINT FINAL de concatenation (releve EXP-03) ; le
  --| temoin, lui, ecrit "STANDARD" nu : les deux formes sont acceptees.
  is
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

			------
  function		S_DISP		( D, W0 :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			------
  begin
    if  D = 0  then
      return W0;
    elsif  D >= -128  and then  D < 128  then
      return  W0 + 1;
    end if;
    return  W0 + 4;

  end	S_DISP;
	------

			-----
  function		S_FPA		( LVL :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			-----
  begin
    if  LVL = 0  then
      return  3;
    elsif  LVL <= 15  then
      return  4;
    end if;
    return  7;

  end	S_FPA;
	-----

			------
  function		S_BASE		( LVL :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			------
  begin
    if  LVL = -1  then
      return  8;											--| POP_RAX : adresse empilee
    end if;
    return  S_FPA( LVL );

  end	S_BASE;
	------

  --| motif commun FP_IN_RAX / FP_IN_RBP / RAX_IN_FP : 49 xx (yy|zz [8l])
			--------
  procedure		E_R15_OP		( OP0, OP1, OPD :INTEGER;
					  LVL :SYMBOLS.VALUE_TYPE )
  is			--------
  begin
    B( 16#49# ); B( OP0 );
    if  LVL = 0  then
      B( OP1 );
    elsif  LVL <= 15  then
      B( OPD ); B( INTEGER( 8 * LVL ) );
    else
      B( OPD + 16#40# );										--| ModRM disp32 (ex. 47->87, 6F->AF)
      D32( INTEGER( 8 * LVL ) );
    end if;

  end	E_R15_OP;
	--------

			-----
  procedure		E_FPA		( LVL :SYMBOLS.VALUE_TYPE )					--| mov rax, [r15+8l]
  is			-----
  begin
    E_R15_OP( 16#8B#, 16#07#, 16#47#, LVL );

  end	E_FPA;
	-----

			--------
  procedure		E_FP_RBP		( LVL :SYMBOLS.VALUE_TYPE )					--| mov rbp, [r15+8l]
  is			--------
  begin
    E_R15_OP( 16#8B#, 16#2F#, 16#6F#, LVL );

  end	E_FP_RBP;
	--------

			--------
  procedure		E_RAX_FP		( LVL :SYMBOLS.VALUE_TYPE )					--| mov [r15+8l], rax
  is			--------
  begin
    E_R15_OP( 16#89#, 16#07#, 16#47#, LVL );

  end	E_RAX_FP;
	--------
			------
  procedure		E_BASE ( LVL :SYMBOLS.VALUE_TYPE )
  is			------
  begin
    if  LVL = -1  then
      E_POP_RAX;
    else
      E_FPA( LVL );
    end if;

  end	E_BASE;
	------

  --| queue ModRM(+disp) commune aux FETCH/STORE : [rax] / [rax+d8] / [rax+d32]

			------------
  procedure		E_MODRM_DISP	( M0, M8, M32 :INTEGER; D :SYMBOLS.VALUE_TYPE )
  is			------------
  begin
    if  D = 0  then
      B( M0 );
    elsif  D >= -128  and then  D < 128  then
      B( M8 ); B( INTEGER( D mod 256 ) );
    else
      B( M32 );
      D32( INTEGER( D ) );
    end if;

  end	E_MODRM_DISP;
	------------

			---------
  procedure		E_FETCH_B		( D :SYMBOLS.VALUE_TYPE )					--| movsx rax, byte [rax+d]
  is			---------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#BE# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_B;
	---------

			---------
  procedure		E_FETCH_W		( D :SYMBOLS.VALUE_TYPE )					--| movsx rax, word [rax+d]
  is			---------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#BF# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_W;
	---------

			---------
  procedure		E_FETCH_D		( D :SYMBOLS.VALUE_TYPE )					--| movsx rax, dword [rax+d]
  is			---------
  begin
    B( 16#48# ); B( 16#63# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_D;
	---------

			---------
  procedure		E_FETCH_Q		( D :SYMBOLS.VALUE_TYPE )					--| mov rax, qword [rax+d]
  is			---------
  begin
    B( 16#48# ); B( 16#8B# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_Q;
	---------

			---------
  procedure		E_STORE_B		( D :SYMBOLS.VALUE_TYPE )					--| mov byte [rax+d], bl
  is			---------
  begin
    B( 16#88# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end	E_STORE_B;
	---------

			---------
  procedure		E_STORE_W		( D :SYMBOLS.VALUE_TYPE )					--| mov word [rax+d], bx
  is			---------
  begin
    B( 16#66# ); B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end	E_STORE_W;
	---------

			---------
  procedure		E_STORE_D		( D :SYMBOLS.VALUE_TYPE )					--| mov dword [rax+d], ebx
  is			---------
  begin
    B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end	E_STORE_D;
	---------
			---------
  procedure		E_STORE_Q		( D :SYMBOLS.VALUE_TYPE )					--| mov qword [rax+d], rbx
  is			---------
  begin
    B( 16#48# ); B( 16#89# );
    E_MODRM_DISP( 16#18#, 16#58#, 16#98#, D );
  end	E_STORE_Q;
	---------

			----------
  procedure		E_FETCH_BU	( D :SYMBOLS.VALUE_TYPE )					--| movzx rax, byte [rax+d]
  is			----------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#B6# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_BU;
	----------

			----------
  procedure		E_FETCH_WU	( D :SYMBOLS.VALUE_TYPE )					--| movzx rax, word [rax+d]
  is			----------
  begin
    B( 16#48# ); B( 16#0F# ); B( 16#B7# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_WU;
	----------

			----------
  procedure		E_FETCH_DU	( D :SYMBOLS.VALUE_TYPE )					--| mov eax, dword [rax+d] (zero-etend)
  is
  begin
    B( 16#8B# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
  end	E_FETCH_DU;
	----------

			-------
  procedure		E_IBASE		( LVL, DISP :SYMBOLS.VALUE_TYPE )				--| INDIRECT_BASE_IN_RAX du codi :
  is			-------									--| base (pile ou frame) puis
  begin												--| rax := [rax + disp]
    E_BASE( LVL );
    B( 16#48# ); B( 16#8B# );
    E_MODRM_DISP( 16#00#, 16#40#, 16#80#, DISP );

  end	E_IBASE;
	-------

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

  --| emission des octets du contenu, dans l'ordre des operandes

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

  --|  Differes STR/CST : UNE routine, deux modes (LIFO : dernier
  --|  enregistre place/emis en PREMIER - releve DIS_BONJOUR).
  --|  PLACING : pose les adresses (P2B) ; sinon : emet (P3), bourrage
  --|  16#90#, et VERIFIE que chaque adresse emise egale l'adresse posee.

			-----------
  procedure		DO_DEFERRED	( PLACING :BOOLEAN;
					  FROM, TO :IR.ELT_ID;
					  CUR :in out SYMBOLS.VALUE_TYPE )
  is			-----------

    S0	:constant SYMBOLS.SCOPE_ID	:= SYMBOLS.CURRENT_SCOPE;

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
		B( 16#90# );						--| bourrage align_q (byte-diff !)
	      end loop;
	      if SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( NAME & ".data_ptr" ) )
		 /= ORG + SYMBOLS.VALUE_TYPE( TOP )
	      then
		FAULT( "placement STR incoherent P2B/P3 : " & NAME );
	      end if;
	      Q64( P + 32 );						--| dq data
	      Q64( P + 16 );						--| dq info
	      D32( INTEGER( 8 * LEN ) );				--| SIZ  (bits)
	      D32( 8 );							--| COMP_SIZ
	      D32( 1 );							--| FST_1
	      D32( INTEGER( LEN ) );					--| LST_1
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
		B( 16#90# );
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

			-------
  function		SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			-------

    M	:constant STRING	:= LEX.IMAGE( IR.MNEMO_OF( E ) );

  begin
    if  IR.KIND_OF( E ) /= IR.MACRO_CALL then  return 0;							--| labels, virtual, map : zero octet
    end if;

    if  M = "DROP"  then return  4;
    elsif  M = "DUP"  then return  12;

    elsif  M = "db"  then return  DB_LEN( E );								--| octets inline
    elsif  M = "rd"  then return  0;									--| reservation statique (TC-12)  then return 0;											--| pure declaration : zero octet
    elsif  M = "rq"  then return  0;									--| reservation statique (TC-12)  then return 0;											--| pure declaration : zero octet

			---------------------------------------------------
--			L O A D	C O N S T A N T E S	  I M M E D I A T E S

    elsif  M = "LI"  then return  18;									--| movabs(10) + PUSH_RAX(8) : taille FIXE (canonique)
    elsif  M = "LIF"  then return 18;									--| movabs + IEEE double + push (fixe)


			-------------------------------------------------------------
--			L O A D	C O N S T A N T  /  V A R I A B L E   A D R E S S E

    elsif  M = "LCA"  then return 18;									--| movabs ptr+disp (10) + PUSH_RAX (8)
    elsif  M = "LSPA"  then return  18;									--| movabs .elab (canonique) + PUSH_RAX
    elsif  M = "LVA"  then
      declare
        D	:constant SYMBOLS.VALUE_TYPE := OPV( E, 2, 0 );
        L	: SYMBOLS.VALUE_TYPE := 0;
      begin
	if D /= 0
	then
	  L := S_DISP( D, 3 );									--| lea : 4 ou 7 ; RIEN si disp = 0
	end if;
	return S_BASE( OPV( E, 1, -1 ) ) + L + 8;
      end;
    elsif  M = "LIVA"
    then
      declare
        O	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 3, 0 );
      begin
        if  O = 0  then
	return  S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
        end if;
        return  S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + S_DISP( O, 3 ) + 8;			--| lea rax, [rax+ofs]
      end;

				-----------------
--				L O A D	D A T A		(unsigned/signed)

    elsif  M = "ULB"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
    elsif  M = "ULW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
    elsif  M = "ULD"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 2 ) + 8;
    elsif  M = "LB"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
    elsif  M = "LW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 4 ) + 8;
    elsif  M = "LD"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;
    elsif  M = "LQ"  or else  M = "LA"  then
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 ) + 8;

    elsif  M = "ULIB"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
    elsif  M = "ULIW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
    elsif  M = "ULID"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 2 ) + 8;
    elsif  M = "LIB"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
    elsif  M = "LIW"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 4 ) + 8;
    elsif  M = "LID"  then return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
						+ S_DISP( OPV( E, 3, 0 ), 3 ) + 8;
    elsif  M = "LIQ"  or else  M = "LIA" then								--| LIA = LIQ (alias du codi)
      return S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 ) + 8;


				-------------------
--				S T O R E	  D A T A

    elsif  M = "SB"  then return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 2 );
    elsif  M = "SW"  then return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 );
    elsif  M = "SD"  then return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 2 );
    elsif  M = "SQ"  or else  M = "SA"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 );
    elsif  M = "SIB"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 2 );
    elsif  M = "SIW"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );
    elsif  M = "SID"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 2 );
    elsif  M = "SIQ"  or else  M = "SIA"  then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );


		-------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S

    elsif M = "ET"  or  M = "OU"  or  M = "OUX"  or  M = "SHL" then return  12;
    elsif  M = "NON"  then return  4;									--| not qword [rbp]
    elsif  M = "SHR"  then return  12;									--| POP_RCX + shr qword [rbp], cl


		-----------------------------------------
--		O P E R A T I O N S	  B I T	F I E L D S

    elsif  M = "UBFX"  then return  42;									--| champ non signe (val, LSB, Width empiles)
    elsif  M = "SBFX"  then return  39;									--| champ signe (shl puis sar)
    elsif  M = "BFI"  then return  56;									--| insertion de champ (old, val, LSB, Width)


		-------------------------------------------------------------
--		O P E R A T I O N S	  A R I T H M E T I Q U E   E N T I E R E

    elsif  M = "DEC"  or else  M = "INC"  or else  M = "NEG"  then return  4;
    elsif  M = "ABS"  then return  16;									--| (x xor allsign) - allsign
    elsif  M = "CLAMP0"  then return  15;
    elsif  M = "ADD"  or else  M = "SUB"  then return 12;							--| POP_RAX(8) + op qword [rbp],rax (4)
    elsif  M = "MUL"  then return  24;									--| POP_RAX + imul qword [rbp] + DROP + PUSH_RAX
    elsif  M = "DIV"  then return  29;
    elsif  M = "REMI"  then return  32;
    elsif  M = "MODI"  then return  48;
    elsif  M = "SAR"  then return  12;									--| POP_RCX + sar qword [rbp], cl


	---------------------------------------------------------------------------------------------
--	O P E R A T I O N S	  A R I T H M E T I Q U E   F L O T T A N T E   ( S S E 2	d o u b l e )

    elsif  M = "FADD"  or else  M = "FSUB"  or else  M = "FMUL"  or else  M = "FDIV"
    then return  23;
    elsif  M = "FNEG"  then return  4;
    elsif  M = "FABS"  then return  4;									--| and byte [rbp+7], 7F (signe IEEE)
    elsif  M = "FEXP"  then return  47;									--| A ** N entier (boucle mulsd)


	---------------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F L O T T A N T

    elsif M = "CVTIF"  or else  M = "CVTFI"  or else  M = "CVTFIR"
    then return  14;


	---------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F I X E D

    elsif  M = "CVTIX"  then return  38;
    elsif  M = "CVTXI"  then return  70;								--| X*NUMER/DENOM arrondi au plus pres


				-----------------------
--				C O M P A R A I S O N S

    elsif  M = "CEQ"  then return  16;									--| POP_RBX + cmp + sete
    elsif  M = "CNE"  or else  M = "CGT"  or else  M = "CGE"  or else  M = "CLT"  or else  M = "CLE"
    then return  16;


		-------------------------------------------------------------------------
--		C O M P A R A I S O N S   F L O T T A N T E S   ( S S E 2	d o u b l e )

    elsif  M = "FCEQ"  then return  28;									--| ucomisd + sete, NaN exclu (setnp)
    elsif  M = "FCNE"  then return  28;
    elsif  M = "FCGT"  or else  M = "FCGE"  or else  M = "FCLT"
    then return  22;
    elsif  M = "FCLE"  then return  22;									--| ucomisd inverse + setae


			-----------------------------------------------------
--			O P E R A T I O N S	  C O N T R O L E	D E   F L O T

    elsif  M = "BRA"  then return  5;									--| E9 rel32 SYSTEMATIQUE (piege n 82)
    elsif  M = "BT"  then return 16;									--| POP_RAX + or al,al + jnz rel32 (n 82)
    elsif  M = "BF"  then return 16;									--| comme BT (jz rel32)
    elsif  M = "CALL"  then return 5;									--| E8/E9 rel32, taille FIXE
    elsif  M = "CALLI"  then return 10;									--| POP_RAX + FF D0
    elsif  M = "RTD"  then
      declare
        P	:constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
        if  P = 0  then
	return  1;										--| C3 seul
        elsif  P < 128  then
	return  5;										--| lea rbp,-p8 + C3
        end if;
        return  8;											--| lea rbp,-p32 + C3
      end;

			---------------------------------------------------
--			O P E R A T I O N S	  G E S T I O N   D E   P I L E

    elsif  M = "LINK"  then
      declare
	LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
	A8		: constant SYMBOLS.VALUE_TYPE
			:= 8 * ( ( OPV( E, 2, 0 ) + 7 ) / 8 );
	N		: SYMBOLS.VALUE_TYPE := 10;			--| co-pile : 3 + 3 + 4
      begin
	if LVL > 0
	then
	  N := N + S_FPA( LVL ) + 8;					--| FP(lvl) + PUSH
	  if LVL <= 15
	  then
	    N := N + 4;
	  else
	    N := N + 7;							--| fidele au codi (ModRM 6F + dd :
	  end if;							--| suspect au dela de lvl 15 - a auditer)
	end if;
	if A8 /= 0
	then
	  if A8 < 128
	  then
	    N := N + 4;
	  else
	    N := N + 7;
	  end if;
	end if;
	return N;
      end;

    elsif  M = "UNLINK"  then
      declare
	LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
	return S_FPA( LVL ) + 8 + S_FPA( LVL ) + 4;			--| FP_IN_RBP + POP_RAX + RAX_IN_FP + copile
      end;

    elsif  M = "PRO"  then return 5;							--| E8/E9 rel32, taille FIXE

    elsif  M = "PRMS"  or else  M = "PRM"  or else  M = "endPRMS"									--| reservation statique (TC-12)
      then return 0;											--| pure declaration : zero octet

    elsif  M = "ELB"  then								--| elab: + LINK lvl, loc_siz - meme compte que LINK
      declare
	LVL	:constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
	A8	:constant SYMBOLS.VALUE_TYPE
			:= 8 * ( ( SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "loc_siz" ) ) + 7 ) / 8 );
	N	: SYMBOLS.VALUE_TYPE := 10;
      begin
        if  LVL > 0  then
	N := N + S_FPA( LVL ) + 8;
	if  LVL <= 15  then
	  N := N + 4;
	else
	  N := N + 7;
	end if;
        end if;
        if  A8 /= 0  then
	if  A8 < 128  then
	  N := N + 4;
	else
	  N := N + 7;
	end if;
        end if;
        return N;
      end;

    elsif  M = "BEGIN_BLOC_DEF"  then return 5;								--| BRA IMAGES.skip (les db suivent, inline)

    elsif  M = "END_BLOC_DEF"  then									--| info dd x4 + align_q NOP + dd x4 + dq x2 :
      return 48 + ( 8 - ( ( CURADDR + 16 ) mod 8 ) ) mod 8;							--| l'adresse du point d'appel donne le bourrage

    elsif  M = "STR"  or else  M = "CST"  then return  0;							--| DIFFERE : place/emis apres le code (LIFO)

    elsif  M = "USEINFO"  or else  M = "STATOFS"  or else  M = "VAR"  then return  0;				--| pure declaration : zero octet

    elsif  M = "CO_VAR"  then return  28;

    elsif  M = "HEAP_ALLOC"  then return  34;

    elsif  M = "endPRO"  then return  0;								--| reservation statique (TC-12)  then return 0;											--| pure declaration : zero octet

    elsif  M = "EXC_MACH"  then									--| pilier 11 : photo machine (codi) - chemin froid,
      declare											--| deplacements disp32 UNIFORMES : taille fixe
        LVL	:constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
        if  LVL < 0  or else  LVL > 31  then
	FAULT( "EXC_MACH : lvl hors 0..31 (assert du codi)" );
        end if;
        return  S_FPA( LVL ) + 57;
      end;

    elsif  M = "EXC_RAISE"  then return  53;								--| deroulage : instance unique, taille fixe


		-----------------------------------------------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S	D E   B L O C   (LRM 4.5.1) -- lot D3

    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then
      return  41;											--| BLK_OP_OCTET (and 20 / or 08 / xor 30)

    elsif  M = "BLKNOT"  then return  29;								--| xor byte 1 (NON booleen par octet)
    elsif  M = "BLKMOV"  then return  34;
    elsif  M = "BLKCMP"  then return  45;
    elsif  M = "LEXCMP"  then									--| 96 + paire de charges normalisees
      declare
        SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
        SGN	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
      begin
        if  SIZC = 1  or else  SIZC = 2  then
	if  SGN = 1  then  return  104;  end if;
	return  102;
        elsif  SIZC = 4  then
	if  SGN = 1  then  return  102;  end if;
	return  100;
        elsif  SIZC = 8  then
	return  102;
        end if;
        FAULT( "LEXCMP : taille de composant non supportee" );
        return  0;
      end;


				------------------------------
--				SPECIFIQUE  L I N U X   X86-64

    elsif  M = "SYS_CLOCK_GETTIME"  then return  19;							--| clock_gettime(REALTIME, @timespec)
    elsif  M = "SYS_PUT_CHAR"  then return  18;
    elsif  M = "SYS_PUT_STR"  then return  31;								--| POP_RSI (8) + 23
    elsif  M = "SYS_GET_CHAR"  then return  91;
    elsif  M = "SYS_GET_STR"  then return  41;
    elsif  M = "SYS_FILE_CREATE"  then return  58;
    elsif  M = "SYS_FILE_OPEN"  then return  54;
    elsif  M = "SYS_FILE_SET_POS"  then return  28;
    elsif  M = "SYS_FILE_GET_POS"  then return  23;							--| lseek(SEEK_CUR, 0) - resultat sur [rbp]
    elsif  M = "SYS_FILE_GET_SIZE"  then return  51;							--| lseek END puis SET (position preservee)
    elsif  M = "SYS_FILE_READ"  or else  M = "SYS_FILE_WRITE"  then return  33;
    elsif  M = "SYS_FILE_CLOSE"  then return  17;
    elsif  M = "SYS_FILE_DELETE"  then return  50;
    elsif  M = "SYS_EXIT"  then
      if  IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP  and then  IR.OP_INT( E, 1 ) /= 0  then
        return  10;
      end if;
      return 7;											--| code = 0 : xor edi, edi

    end if;

    FAULT( "mnemonique hors tranche TC-04 : " & M );
    return 0;								--| jamais atteint

  end	SIZE_OF;
	-------


			------
  procedure		ENCODE		( E :IR.ELT_ID )
  is			------

    M			: constant STRING		:= LEX.IMAGE( IR.MNEMO_OF( E ) );
    V			: SYMBOLS.VALUE_TYPE;

  begin
    if  M = "DROP"  then
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );

    elsif  M = "DUP"  then
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#08# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#08# );

    elsif  M = "db"  then  EMIT_DB( E );
    elsif  M = "rd"  then  null;									--| pure declaration : zero octet
    elsif  M = "rq"  then  null;									--| pure declaration : zero octet


			---------------------------------------------------
--			L O A D	C O N S T A N T E S	  I M M E D I A T E S

    elsif  M = "LI"  then
      if  IR.N_OPS( E ) < 1  then
        FAULT( "LI : operande attendu" );
      end if;

      B( 16#48# ); B( 16#B8# );									--| movabs rax, imm64
      Q64( OPV( E, 1, 0 ) );										--| litteral, nom ou EXPR (corpus : LI size*8)
      E_PUSH_RAX;

    elsif  M = "LIF"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.FLT_OP  then
        FAULT( "LIF : litteral flottant attendu" );
      end if;

      B( 16#48# ); B( 16#B8# );									--| movabs rax, imm64 (IEEE double)
      Q64F( IR.OP_FLT( E, 1 ) );
      E_PUSH_RAX;


			-------------------------------------------------------------
--			L O A D	C O N S T A N T  /  V A R I A B L E   A D R E S S E

    elsif  M = "LCA"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( "LCA : nom attendu" );
      end if;
      SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      if  IR.N_OPS( E ) >= 2  and then  IR.OP_TAG( E, 2 ) = IR.INT_OP  then
	V := V + IR.OP_INT( E, 2 );
      elsif  IR.N_OPS( E ) >= 2  and then  IR.OP_TAG( E, 2 ) = IR.EXPR_OP  then
	V := V + LEX.EVAL( IR.OP_TXT( E, 2 ) );
      end if;
      B( 16#48# ); B( 16#B8# );									--| movabs rax, ptr+disp
      Q64( V );
      E_PUSH_RAX;

    elsif  M = "LSPA"  then
      V := ELAB_TARGET( E );
      B( 16#48# ); B( 16#B8# );									--| movabs rax, .elab (forme canonique)
      Q64( V );
      E_PUSH_RAX;

    elsif  M = "LVA"  then
      declare
        D		:constant SYMBOLS.VALUE_TYPE := OPV( E, 2, 0 );
      begin
        E_BASE( OPV( E, 1, -1 ) );
        if  D /= 0  then
	B( 16#48# ); B( 16#8D# );									--| lea rax, [rax+d]
	E_MODRM_DISP( 16#00#, 16#40#, 16#80#, D );
        end if;
        E_PUSH_RAX;
      end;

    elsif M = "LIVA"
    then
      declare
	O		: constant SYMBOLS.VALUE_TYPE := OPV( E, 3, 0 );
      begin
	E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
	if O /= 0
	then
	  B( 16#48# ); B( 16#8D# );									--| lea rax, [rax+ofs]
	  E_MODRM_DISP( 16#00#, 16#40#, 16#80#, O );
	end if;
	E_PUSH_RAX;
      end;


				-----------------
--				L O A D	D A T A		(unsigned/signed)

    elsif  M = "ULB"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_BU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "ULW"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_WU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "ULD"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_DU( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LB"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_B( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LW"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_W( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LD"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_D( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LQ"  or else  M = "LA"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_FETCH_Q( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "ULIB"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_BU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif  M = "ULIW"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_WU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif  M = "ULID"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_DU( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LIB"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_B( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LIW"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_W( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif M = "LID"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_D( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

    elsif M = "LIQ"  or else  M = "LIA"  then												--| LIA = LIQ (alias du codi)
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_FETCH_Q( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

				-------------------
--				S T O R E	  D A T A

    elsif  M = "SB"  then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_B( OPV( E, 2, 0 ) );

    elsif  M = "SW"  then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_W( OPV( E, 2, 0 ) );

    elsif  M = "SD"  then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_D( OPV( E, 2, 0 ) );

    elsif  M = "SQ"  or else  M = "SA"  then
      E_POP_RBX;
      E_BASE( OPV( E, 1, -1 ) );
      E_STORE_Q( OPV( E, 2, 0 ) );

    elsif  M = "SIB"  then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_B( OPV( E, 3, 0 ) );

    elsif  M = "SIW"  then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_W( OPV( E, 3, 0 ) );

    elsif M = "SID"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_D( OPV( E, 3, 0 ) );

    elsif M = "SIQ"  or else  M = "SIA"  then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_Q( OPV( E, 3, 0 ) );


		-------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S

    elsif  M = "ET"  then
      E_POP_RAX;
      B( 16#48# ); B( 16#21# ); B( 16#45# ); B( 16#00# );

    elsif  M = "OU"  then										--| ou logique
      E_POP_RAX;
      B( 16#48# ); B( 16#09# ); B( 16#45# ); B( 16#00# );							--| or qword [rbp], rax

    elsif  M = "NON"  then										--| non bit a bit
      B( 16#48# ); B( 16#F7# ); B( 16#55# ); B( 16#00# );							--| not qword [rbp]

    elsif M  = "OUX"  then										--| xor qword [rbp], rax
      E_POP_RAX;
      B( 16#48# ); B( 16#31# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SHL"  then										--| shl qword [rbp], cl
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#65# ); B( 16#00# );

    elsif  M = "SHR"  then										--| decalage droit logique
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#6D# ); B( 16#00# );							--| shr qword [rbp], cl



		-----------------------------------------
--		O P E R A T I O N S	  B I T	F I E L D S

    elsif  M = "UBFX"  then										--| extraction de champ non signe
      E_POP_RDX;											--| Width
      E_POP_RCX;											--| LSB
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );							--| mov rax, [rbp]
      B( 16#48# ); B( 16#D3# ); B( 16#E8# );								--| shr rax, cl
      B( 16#48# ); B( 16#89# ); B( 16#D1# );								--| mov rcx, rdx
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );								--| rdx := 1
      B( 16#48# ); B( 16#D3# ); B( 16#E2# );								--| shl rdx, cl
      B( 16#48# ); B( 16#FF# ); B( 16#CA# );								--| dec rdx (masque)
      B( 16#48# ); B( 16#21# ); B( 16#D0# );								--| and rax, rdx
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );							--| mov [rbp], rax

    elsif  M = "SBFX"  then										--| extraction de champ signe
      E_POP_RDX;											--| Width
      E_POP_RCX;											--| LSB
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );							--| mov rax, [rbp]
      B( 16#48# ); B( 16#D3# ); B( 16#E8# );								--| shr rax, cl
      B( 16#6A# ); B( 16#40# ); B( 16#59# );								--| rcx := 64
      B( 16#48# ); B( 16#29# ); B( 16#D1# );								--| sub rcx, rdx (64 - Width)
      B( 16#48# ); B( 16#D3# ); B( 16#E0# );								--| shl rax, cl
      B( 16#48# ); B( 16#D3# ); B( 16#F8# );								--| sar rax, cl (extension)
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );							--| mov [rbp], rax

    elsif  M = "BFI"  then										--| insertion de champ dans [rbp]
      E_POP_RCX;											--| Width
      E_POP_RDX;											--| LSB
      E_POP_RAX;											--| valeur a inserer
      B( 16#6A# ); B( 16#01# ); B( 16#5B# );								--| rbx := 1
      B( 16#48# ); B( 16#D3# ); B( 16#E3# );								--| shl rbx, cl
      B( 16#48# ); B( 16#FF# ); B( 16#CB# );								--| dec rbx (masque)
      B( 16#48# ); B( 16#21# ); B( 16#D8# );								--| and rax, rbx
      B( 16#48# ); B( 16#89# ); B( 16#D1# );								--| mov rcx, rdx (LSB)
      B( 16#48# ); B( 16#D3# ); B( 16#E0# );								--| shl rax, cl
      B( 16#48# ); B( 16#D3# ); B( 16#E3# );								--| shl rbx, cl
      B( 16#48# ); B( 16#F7# ); B( 16#D3# );								--| not rbx
      B( 16#48# ); B( 16#21# ); B( 16#5D# ); B( 16#00# );							--| and [rbp], rbx (nettoyer)
      B( 16#48# ); B( 16#09# ); B( 16#45# ); B( 16#00# );							--| or [rbp], rax (inserer)


		-------------------------------------------------------------
--		O P E R A T I O N S	  A R I T H M E T I Q U E   E N T I E R E

    elsif  M = "DEC"  then										--| dec qword [rbp]
      B( 16#48# ); B( 16#FF# ); B( 16#4D# ); B( 16#00# );

    elsif  M = "INC"  then										--| inc qword [rbp]
      B( 16#48# ); B( 16#FF# ); B( 16#45# ); B( 16#00# );

    elsif  M = "NEG"  then										--| neg qword [rbp]
      B( 16#48# ); B( 16#F7# ); B( 16#5D# ); B( 16#00# );

    elsif  M = "ABS"  then										--| valeur absolue entiere
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );							--| mov rax, [rbp]
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#3F# );							--| sar rax, 63 (allsign)
      B( 16#48# ); B( 16#31# ); B( 16#45# ); B( 16#00# );							--| xor [rbp], rax
      B( 16#48# ); B( 16#29# ); B( 16#45# ); B( 16#00# );							--| sub [rbp], rax

    elsif  M = "CLAMP0"  then										--| sommet := max(0, sommet)
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#3F# );
      B( 16#48# ); B( 16#F7# ); B( 16#D0# );
      B( 16#48# ); B( 16#21# ); B( 16#45# ); B( 16#00# );

    elsif  M = "ADD"  then
      E_POP_RAX;
      B( 16#48# ); B( 16#01# ); B( 16#45# ); B( 16#00# );							--| add qword [rbp], rax

    elsif  M = "SUB"  then
      E_POP_RAX;
      B( 16#48# ); B( 16#29# ); B( 16#45# ); B( 16#00# );							--| sub qword [rbp], rax

    elsif  M = "MUL"  then
      E_POP_RAX;
      B( 16#48# ); B( 16#F7# ); B( 16#6D# ); B( 16#00# );							--| imul qword [rbp]
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| DROP
      E_PUSH_RAX;

    elsif  M = "DIV"  then										--| division signee tronquee
      E_POP_RBX;
      E_POP_RAX;
      B( 16#48# ); B( 16#99# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      E_PUSH_RAX;

    elsif  M = "REMI"  then										--| reste (signe du dividende)
      E_POP_RBX;
      E_POP_RAX;
      B( 16#48# ); B( 16#99# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      B( 16#48# ); B( 16#89# ); B( 16#D0# );
      E_PUSH_RAX;

    elsif  M = "MODI"  then										--| modulo Ada (signe du diviseur)
      E_POP_RBX;
      E_POP_RAX;
      B( 16#48# ); B( 16#99# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      B( 16#48# ); B( 16#89# ); B( 16#D0# );
      B( 16#48# ); B( 16#85# ); B( 16#C0# );
      B( 16#74# ); B( 16#0B# );
      B( 16#48# ); B( 16#89# ); B( 16#C1# );
      B( 16#48# ); B( 16#31# ); B( 16#D9# );
      B( 16#79# ); B( 16#03# );
      B( 16#48# ); B( 16#01# ); B( 16#D8# );
      E_PUSH_RAX;

    elsif  M = "SAR"  then										--| decalage droit arithmetique
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#7D# ); B( 16#00# );							--| sar qword [rbp], cl


	---------------------------------------------------------------------------------------------
--	O P E R A T I O N S	  A R I T H M E T I Q U E   F L O T T A N T E   ( S S E 2	d o u b l e )

    elsif  M = "FADD"  then										--| addsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#58# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FSUB"  then										--| subsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#5C# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FMUL"  then										--| mulsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#59# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FDIV"  then										--| divsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#5E# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FNEG"  then										--| bascule du bit de signe IEEE
      B( 16#80# ); B( 16#75# ); B( 16#07# ); B( 16#80# );

    elsif  M = "FABS"  then										--| bit 63 a zero (signe IEEE 754)
      B( 16#80# ); B( 16#65# ); B( 16#07# ); B( 16#7F# );							--| and byte [rbp+7], 7F

    elsif  M = "FEXP"  then										--| A ** N (N entier positif depile)
      E_POP_RCX;
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );					--| movsd xmm0, [rbp] (base)
      B( 16#48# ); B( 16#B8# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# ); B( 16#00# );
			B( 16#F0# ); B( 16#3F# );							--| movabs rax, 1.0
      B( 16#66# ); B( 16#48# ); B( 16#0F# ); B( 16#6E# ); B( 16#C8# );					--| movq xmm1, rax (accumulateur)
      B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| test rcx, rcx
      B( 16#74# ); B( 16#09# );									--| jz +9 (N = 0 : resultat 1.0)
      B( 16#F2# ); B( 16#0F# ); B( 16#59# ); B( 16#C8# );							--| mulsd xmm1, xmm0
      B( 16#48# ); B( 16#FF# ); B( 16#C9# );								--| dec rcx
      B( 16#75# ); B( 16#F7# );									--| jnz -9
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#4D# ); B( 16#00# );					--| movsd [rbp], xmm1


	---------------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F L O T T A N T

    elsif  M = "CVTIF"  then										--| entier -> double (cvtsi2sd)
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2A# ); B( 16#C0# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CVTFI"  then										--| double -> entier, troncature (cvttsd2si)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2C# ); B( 16#C0# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CVTFIR"  then										--| double -> entier, arrondi machine (cvtsd2si)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2D# ); B( 16#C0# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );


	---------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F I X E D

    elsif  M = "CVTIX"  then										--| entier -> fixed : I * DENOM / NUMER
      E_POP_RBX;
      E_POP_RCX;
      E_POP_RAX;
      B( 16#48# ); B( 16#F7# ); B( 16#E9# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      E_PUSH_RAX;

    elsif  M = "CVTXI"  then										--| X * NUMER / DENOM, arrondi au plus pres
      E_POP_RBX;											--| DENOM
      E_POP_RCX;											--| NUMER
      E_POP_RAX;											--| X
      B( 16#48# ); B( 16#F7# ); B( 16#E9# );								--| imul rcx
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );								--| idiv rbx
      B( 16#48# ); B( 16#89# ); B( 16#D1# );								--| mov rcx, rdx
      B( 16#48# ); B( 16#C1# ); B( 16#F9# ); B( 16#3F# );							--| sar rcx, 63
      B( 16#48# ); B( 16#31# ); B( 16#CA# );								--| xor rdx, rcx (|reste|)
      B( 16#48# ); B( 16#29# ); B( 16#CA# );								--| sub rdx, rcx
      B( 16#48# ); B( 16#D1# ); B( 16#EB# );								--| shr rbx, 1
      B( 16#48# ); B( 16#83# ); B( 16#D3# ); B( 16#00# );							--| adc rbx, 0 (demi-DENOM arrondi)
      B( 16#48# ); B( 16#39# ); B( 16#DA# );								--| cmp rdx, rbx
      B( 16#72# ); B( 16#07# );									--| jb +7 (pas d arrondi)
      B( 16#48# ); B( 16#83# ); B( 16#C9# ); B( 16#01# );							--| or rcx, 1 (signe du quotient)
      B( 16#48# ); B( 16#01# ); B( 16#C8# );								--| add rax, rcx
      E_PUSH_RAX;


				-----------------------
--				C O M P A R A I S O N S

    elsif  M = "CEQ"  then
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );							--| cmp [rbp], rbx
      B( 16#0F# ); B( 16#94# ); B( 16#45# ); B( 16#00# );							--| sete [rbp]

    elsif  M = "CNE"  then										--| A /= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#95# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CGT"  then										--| A > B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9F# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CGE"  then										--| A >= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9D# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CLT"  then										--| A < B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9C# ); B( 16#45# ); B( 16#00# );

    elsif  M = "CLE"  then										--| A <= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9E# ); B( 16#45# ); B( 16#00# );


		-------------------------------------------------------------------------
--		C O M P A R A I S O N S   F L O T T A N T E S   ( S S E 2	d o u b l e )

    elsif  M = "FCEQ"  then										--| egalite flottante (NaN exclu)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );					--| movsd xmm1, [rbp] (B)
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| DROP
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );					--| movsd xmm0, [rbp] (A)
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );							--| ucomisd xmm0, xmm1
      B( 16#0F# ); B( 16#94# ); B( 16#45# ); B( 16#00# );							--| sete [rbp]
      B( 16#0F# ); B( 16#9B# ); B( 16#C0# );								--| setnp al (pas NaN)
      B( 16#20# ); B( 16#45# ); B( 16#00# );								--| and [rbp], al

    elsif  M = "FCNE"  then										--| A /= B flottant (NaN -> vrai)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#95# ); B( 16#45# ); B( 16#00# );
      B( 16#0F# ); B( 16#9A# ); B( 16#C0# );
      B( 16#08# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FCGT"  then										--| A > B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FCGE"  then										--| A >= B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#93# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FCLT"  then										--| A < B flottant (ucomisd inverse)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C8# );
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );

    elsif  M = "FCLE"  then										--| A <= B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );					--| movsd xmm1, [rbp] (B)
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| DROP
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );					--| movsd xmm0, [rbp] (A)
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C8# );							--| ucomisd xmm1, xmm0 (inverse)
      B( 16#0F# ); B( 16#93# ); B( 16#45# ); B( 16#00# );							--| setae [rbp]


			-----------------------------------------------------
--			O P E R A T I O N S	  C O N T R O L E	D E   F L O T

    elsif  M = "BRA"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( "BRA : label attendu" );
      end if;
      SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      B( 16#E9# );											--| jmp rel32
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );						--| disp = cible - fin d'instruction

    elsif  M = "BT"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( "BT : label attendu" );
      end if;
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      E_POP_RAX;
      B( 16#08# ); B( 16#C0# );									--| or al, al
      B( 16#0F# ); B( 16#85# );									--| jnz rel32 (n 82)
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );

    elsif  M = "BF"  then										--| branch false : comme BT, jz rel32
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( "BF : label attendu" );
      end if;
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      E_POP_RAX;
      B( 16#08# ); B( 16#C0# );									--| or al, al
      B( 16#0F# ); B( 16#84# );									--| jz rel32
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );

    elsif  M = "CALL"  then
      V := ELAB_TARGET( E );
      B( 16#E8# );											--| call rel32 vers .elab (lazy reel)
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );

    elsif  M = "CALLI"  then
      E_POP_RAX;
      B( 16#FF# ); B( 16#D0# );									--| call rax

    elsif  M = "RTD"  then
      declare
        P		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
        if  P /= 0  then
	B( 16#48# ); B( 16#8D# );
	if  P < 128  then
	  B( 16#6D# ); B( INTEGER( ( -P ) mod 256 ) );							--| lea rbp, [rbp - p8]
	else
	  B( 16#AD# );
	  D32( INTEGER( -P ) );									--| lea rbp, [rbp - p32]
	end if;
        end if;
        B( 16#C3# );										--| ret (micro-pile rsp)
      end;


			---------------------------------------------------
--			O P E R A T I O N S	  G E S T I O N   D E   P I L E

    elsif  M = "LINK"  then
      declare
        LVL	: constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
        A8	: constant SYMBOLS.VALUE_TYPE		:= 8 * ( ( OPV( E, 2, 0 ) + 7 ) / 8 );
      begin
        if  LVL > 0  then
	E_FPA( LVL );
	E_PUSH_RAX;
	B( 16#49# ); B( 16#89# );
	if  LVL <= 15  then
	  B( 16#6F# ); B( INTEGER( 8 * LVL ) );								--| mov [r15+8l], rbp
	else
	  B( 16#6F# );										--| FIDELE AU CODI (ModRM 6F + dd : suspect
	  D32( INTEGER( 8 * LVL ) );									--| au dela de lvl 15, jamais exerce - auditer
	end if;											--| DES DEUX COTES le jour venu)
        end if;
        if  A8 /= 0  then
	B( 16#48# ); B( 16#8D# );
	if  A8 < 128  then
	  B( 16#6D# ); B( INTEGER( A8 ) );								--| lea rbp, [rbp+alloc8]
	else
	  B( 16#AD# );
	  D32( INTEGER( A8 ) );									--| lea rbp, [rbp+alloc32]
	end if;
        end if;
        B( 16#4D# ); B( 16#89# ); B( 16#2E# );								--| mov [r14], r13
        B( 16#4D# ); B( 16#89# ); B( 16#F5# );								--| mov r13, r14
        B( 16#4D# ); B( 16#8D# ); B( 16#76# ); B( 16#08# );							--| lea r14, [r14+8]
      end;

    elsif  M = "UNLINK"  then
      declare
        LVL	: constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
      begin
        E_FP_RBP( LVL );
        E_POP_RAX;
        E_RAX_FP( LVL );
        B( 16#4D# ); B( 16#8B# ); B( 16#6D# ); B( 16#00# );							--| mov r13, [r13]
      end;

    elsif  M = "PRO"  then
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "post" ) );							--| contournement d'elaboration
      B( 16#E9# );
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );

    elsif M = "PRMS"  or else  M = "PRM"  or else  M = "endPRMS"						--| reservation statique (TC-12)
    then  null;											--| pure declaration : zero octet

    elsif  M = "ELB"  then										--| LINK lvl, loc_siz (elab deja adresse en P2B)
      declare
        LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
        A8		: constant SYMBOLS.VALUE_TYPE
			:= 8 * ( ( SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "loc_siz" ) ) + 7 ) / 8 );
      begin
        if  LVL > 0  then
	E_FPA( LVL );
	E_PUSH_RAX;
	B( 16#49# ); B( 16#89# );
	if  LVL <= 15  then
	  B( 16#6F# ); B( INTEGER( 8 * LVL ) );
	else
	  B( 16#6F# );										--| fidele au codi (suspect > 15, cf. TC-06)
	  D32( INTEGER( 8 * LVL ) );
	end if;
        end if;
        if  A8 /= 0  then
	B( 16#48# ); B( 16#8D# );
	if  A8 < 128  then
	  B( 16#6D# ); B( INTEGER( A8 ) );
	else
	  B( 16#AD# );
	  D32( INTEGER( A8 ) );
	end if;
        end if;
        B( 16#4D# ); B( 16#89# ); B( 16#2E# );
        B( 16#4D# ); B( 16#89# ); B( 16#F5# );
        B( 16#4D# ); B( 16#8D# ); B( 16#76# ); B( 16#08# );
      end;

    elsif  M = "BEGIN_BLOC_DEF"  then									--| BRA IMAGES.skip (resolution posee a P2B)
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.skip" ) );
      B( 16#E9# );
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );

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
	B( 16#90# );										--| align_q : bourrage NOP
        end loop;
        D32( INTEGER( OPV( E, 1, 0 ) ) );								--| SIZ (en bits pour un enumere)
        D32( INTEGER( OPV( E, 2, 0 ) ) );								--| FST
        D32( INTEGER( OPV( E, 3, 0 ) ) );								--| LST
        D32( 0 );
        Q64( D0 );											--| data_ptr
        Q64( SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.info" ) ) );						--| info_ptr
      end;

    elsif  M = "STR"  or else  M = "CST"  then
      null;											--| differe : emis apres le code par DO_DEFERRED

    elsif  M = "USEINFO"  or else  M = "STATOFS"  or else  M = "VAR"  then
      null;											--| pure declaration : zero octet

    elsif  M = "CO_VAR"  then										--| alloue N octets (arrondis qword) sur la
      E_POP_RAX;											--| co-pile, empile l'adresse de debut de bloc
      B( 16#4C# ); B( 16#89# ); B( 16#75# ); B( 16#08# );							--| mov [rbp+8], r14
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#08# );							--| lea rbp, [rbp+8]
      B( 16#48# ); B( 16#83# ); B( 16#C0# ); B( 16#07# );							--| add rax, 7
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#03# );							--| sar rax, 3
      B( 16#4D# ); B( 16#8D# ); B( 16#34# ); B( 16#C6# );							--| lea r14, [r14 + 8*rax]

    elsif  M = "HEAP_ALLOC"  then									--| alloue N octets (arrondis qword) sur la
      E_POP_RAX;											--| rax = taille demandee
      B( 16#48# ); B( 16#83# ); B( 16#C0# ); B( 16#07# );							--| add rax, 7
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#03# );							--| sar rax, 3	nombre de qwords
      B( 16#48# ); B( 16#C1# ); B( 16#E0# ); B( 16#03# );							--| shl rax, 3	taille alignee en octets
      B( 16#49# ); B( 16#29# ); B( 16#C4# );								--| sub r12, rax	tas descendant depuis le haut reserve
      B( 16#4C# ); B( 16#89# ); B( 16#E0# );								--| mov rax, r12	adresse du nouveau bloc
      E_PUSH_RAX;

    elsif  M = "endPRO"										--| code expanse au LEX (TC-10)
    then  null;											--| pure declaration : zero octet

    elsif  M = "EXC_MACH"  then									--| pilier 11 : photographie de l'etat machine
      declare											--| dans le contexte a [FP(lvl) + ctx]
        LVL	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 0 );
        CTX	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
      begin
        if  LVL < 0  or else  LVL > 31  then
	FAULT( "EXC_MACH : lvl hors 0..31 (assert du codi)" );
        end if;
        E_FPA( LVL );										--| rax := FP(lvl)
        B( 16#48# ); B( 16#89# ); B( 16#A8# );								--| mov [rax + ctx+16], rbp
        D32( INTEGER( CTX + 16 ) );
        B( 16#48# ); B( 16#89# ); B( 16#A0# );								--| mov [rax + ctx+24], rsp
        D32( INTEGER( CTX + 24 ) );
        B( 16#4C# ); B( 16#89# ); B( 16#A8# );								--| mov [rax + ctx+32], r13
        D32( INTEGER( CTX + 32 ) );
        B( 16#4C# ); B( 16#89# ); B( 16#B0# );								--| mov [rax + ctx+40], r14
        D32( INTEGER( CTX + 40 ) );
        B( 16#48# ); B( 16#C7# ); B( 16#80# );								--| mov qword [rax + ctx+48], lvl+1   (nlvl)
        D32( INTEGER( CTX + 48 ) );
        D32( INTEGER( LVL + 1 ) );
        B( 16#48# ); B( 16#8D# ); B( 16#B8# );								--| lea rdi, [rax + ctx+56]   (dest. du prefixe)
        D32( INTEGER( CTX + 56 ) );
        B( 16#4C# ); B( 16#89# ); B( 16#FE# );								--| mov rsi, r15   (source : le display)
        B( 16#B9# );										--| mov ecx, lvl+1
        D32( INTEGER( LVL + 1 ) );
        B( 16#F3# ); B( 16#48# ); B( 16#A5# );								--| rep movsq   (FP(0..lvl) -> ctx+56..)
      end;

    elsif  M = "EXC_RAISE"  then									--| deroulage (LRM 11.4.1) : POP avant dispatch ;
      declare											--| atteint par BRA, jamais par CALL
        TOPD	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 0 );
      begin
        B( 16#49# ); B( 16#8B# ); B( 16#1F# );								--| mov rbx, [r15]      (rbx := FP(0))
        B( 16#48# ); B( 16#8B# ); B( 16#83# );								--| mov rax, [rbx + top]   (contexte sommet)
        D32( INTEGER( TOPD ) );
        B( 16#48# ); B( 16#8B# ); B( 16#08# );								--| mov rcx, [rax]      (PREV_CTX)
        B( 16#48# ); B( 16#89# ); B( 16#8B# );								--| mov [rbx + top], rcx   (POP avant dispatch)
        D32( INTEGER( TOPD ) );
        B( 16#4C# ); B( 16#8B# ); B( 16#68# ); B( 16#20# );							--| mov r13, [rax+32]   (frame pointer co-pile)
        B( 16#4C# ); B( 16#8B# ); B( 16#70# ); B( 16#28# );							--| mov r14, [rax+40]   (sommet co-pile)
        B( 16#48# ); B( 16#8B# ); B( 16#60# ); B( 16#18# );							--| mov rsp, [rax+24]   (micro-pile purgee)
        B( 16#48# ); B( 16#8B# ); B( 16#48# ); B( 16#30# );							--| mov rcx, [rax+48]   (NXT_LVL)
        B( 16#48# ); B( 16#8D# ); B( 16#70# ); B( 16#38# );							--| lea rsi, [rax+56]
        B( 16#4C# ); B( 16#89# ); B( 16#FF# );								--| mov rdi, r15
        B( 16#F3# ); B( 16#48# ); B( 16#A5# );								--| rep movsq   (FP(0..lvl) restaures)
        B( 16#48# ); B( 16#8B# ); B( 16#68# ); B( 16#10# );							--| mov rbp, [rax+16]   (pile de travail)
        B( 16#FF# ); B( 16#60# ); B( 16#08# );								--| jmp [rax+8]   (DISPATCH du frame porteur)
      end;

		-----------------------------------------------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S	D E   B L O C   (LRM 4.5.1) -- lot D3

    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then					--| [DST] op= [SRC] octet a octet
      declare
        OPC		:INTEGER := 16#20#;								--| and
      begin
        if  M = "BLKOU"  then  OPC := 16#08#;  end if;							--| or
        if  M = "BLKOUX"  then  OPC := 16#30#;  end if;							--| xor
        E_POP_RSI;											--| @SRC
        E_POP_RCX;											--| LEN
        E_POP_RDI;											--| @DST
        B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| test rcx, rcx
        B( 16#74# ); B( 16#0C# );									--| jz fin (LEN = 0)
        B( 16#8A# ); B( 16#06# );									--| mov al, [rsi]
        B( OPC ); B( 16#07# );									--| op [rdi], al
        B( 16#48# ); B( 16#FF# ); B( 16#C6# );								--| inc rsi
        B( 16#48# ); B( 16#FF# ); B( 16#C7# );								--| inc rdi
        B( 16#E2# ); B( 16#F4# );									--| loop
      end;

    elsif  M = "BLKNOT"  then										--| NON booleen par octet (xor 1)
      E_POP_RCX;											--| LEN
      E_POP_RDI;											--| @DST
      B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| test rcx, rcx
      B( 16#74# ); B( 16#08# );									--| jz fin
      B( 16#80# ); B( 16#37# ); B( 16#01# );								--| xor byte [rdi], 1
      B( 16#48# ); B( 16#FF# ); B( 16#C7# );								--| inc rdi
      B( 16#E2# ); B( 16#F8# );									--| loop

    elsif  M = "BLKMOV"  then										--| dest, compte, source empiles (source au sommet)
      E_POP_RSI;
      E_POP_RCX;
      E_POP_RDI;
      B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| test rcx, rcx
      B( 16#74# ); B( 16#05# );									--| jz +5
      B( 16#FC# );											--| cld
      B( 16#AC# );											--| lodsb
      B( 16#AA# );											--| stosb
      B( 16#E2# ); B( 16#FC# );									--| loop

    elsif  M = "BLKCMP"  then										--| dest, compte, source empiles (source au sommet)
      E_POP_RSI;
      E_POP_RCX;
      E_POP_RDI;
      B( 16#31# ); B( 16#C0# );									--| xor eax, eax
      B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| test rcx, rcx
      B( 16#74# ); B( 16#03# );									--| jz +3
      B( 16#FC# );											--| cld
      B( 16#F3# ); B( 16#A6# );									--| repe cmpsb
      B( 16#0F# ); B( 16#94# ); B( 16#C0# );								--| sete al
      E_PUSH_RAX;

    elsif  M = "LEXCMP"  then										--| comparaison lexicographique (LRM 4.5.2)
      declare
        SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
        SGN	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
        F		:INTEGER := 6;									--| taille de la paire de charges
      begin
        if  ( SIZC = 1  or else  SIZC = 2 )  and then  SGN = 1  then
	F := 8;
        elsif  SIZC = 4  then
	F := 4;
	if  SGN = 1  then  F := 6;  end if;
        end if;
        E_POP_RDX;											--| LEN_D
        E_POP_RSI;											--| @D
        E_POP_RCX;											--| LEN_G
        E_POP_RDI;											--| @G
        B( 16#48# ); B( 16#85# ); B( 16#C9# );								--| boucle : test rcx, rcx
        B( 16#74# ); B( 28 + F );									--| jz epuise
        B( 16#48# ); B( 16#85# ); B( 16#D2# );								--| test rdx, rdx
        B( 16#74# ); B( 23 + F );									--| jz epuise
        if  SIZC = 1  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#0F# ); B( 16#BE# ); B( 16#07# ); B( 16#48# ); B( 16#0F# ); B( 16#BE# ); B( 16#1E# );	--| movsx octets
	else
	  B( 16#0F# ); B( 16#B6# ); B( 16#07# ); B( 16#0F# ); B( 16#B6# ); B( 16#1E# );				--| movzx octets
	end if;
        elsif  SIZC = 2  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#0F# ); B( 16#BF# ); B( 16#07# ); B( 16#48# ); B( 16#0F# ); B( 16#BF# ); B( 16#1E# );	--| movsx mots
	else
	  B( 16#0F# ); B( 16#B7# ); B( 16#07# ); B( 16#0F# ); B( 16#B7# ); B( 16#1E# );				--| movzx mots
	end if;
        elsif  SIZC = 4  then
	if  SGN = 1  then
	  B( 16#48# ); B( 16#63# ); B( 16#07# ); B( 16#48# ); B( 16#63# ); B( 16#1E# );				--| movsxd dwords
	else
	  B( 16#8B# ); B( 16#07# ); B( 16#8B# ); B( 16#1E# );						--| mov dwords (zero-etend)
	end if;
        else
	B( 16#48# ); B( 16#8B# ); B( 16#07# ); B( 16#48# ); B( 16#8B# ); B( 16#1E# );				--| mov qwords
        end if;
        B( 16#48# ); B( 16#39# ); B( 16#D8# );								--| cmp rax, rbx (signee, normalisee)
        B( 16#75# ); B( 16#1E# );									--| jne differe
        B( 16#48# ); B( 16#83# ); B( 16#C7# ); B( INTEGER( SIZC ) );						--| add rdi, siz
        B( 16#48# ); B( 16#83# ); B( 16#C6# ); B( INTEGER( SIZC ) );						--| add rsi, siz
        B( 16#48# ); B( 16#83# ); B( 16#E9# ); B( INTEGER( SIZC ) );						--| sub rcx, siz
        B( 16#48# ); B( 16#83# ); B( 16#EA# ); B( INTEGER( SIZC ) );						--| sub rdx, siz
        B( 16#EB# ); B( 256 - 33 - F );									--| jmp boucle
        B( 16#48# ); B( 16#29# ); B( 16#D1# );								--| epuise : sub rcx, rdx (prefixe commun)
        B( 16#74# ); B( 16#0B# );									--| jz egal
        B( 16#78# ); B( 16#0D# );									--| js moins
        B( 16#6A# ); B( 16#01# ); B( 16#58# );								--| plus : rax := +1
        B( 16#EB# ); B( 16#0B# );									--| jmp empile
        B( 16#7C# ); B( 16#06# );									--| differe : jl moins
        B( 16#EB# ); B( 16#F7# );									--| jmp plus
        B( 16#31# ); B( 16#C0# );									--| egal : rax := 0
        B( 16#EB# ); B( 16#03# );									--| jmp empile
        B( 16#6A# ); B( 16#FF# ); B( 16#58# );								--| moins : rax := -1
        E_PUSH_RAX;											--| empile : -1 / 0 / +1
      end;


				------------------------------
--				SPECIFIQUE  L I N U X   X86-64

    elsif  M = "SYS_CLOCK_GETTIME"  then								--| clock_gettime(REALTIME, @timespec)
      E_POP_RSI;
      B( 16#48# ); B( 16#31# ); B( 16#FF# );								--| xor rdi, rdi (CLOCK_REALTIME)
      B( 16#68# ); B( 16#E4# ); B( 16#00# ); B( 16#00# ); B( 16#00# );					--| push 228
      B( 16#58# );											--| pop rax
      B( 16#0F# ); B( 16#05# );									--| syscall

    elsif  M = "SYS_PUT_CHAR"  then									--| caractere au sommet, ecrit sur stdout, DROP
      B( 16#48# ); B( 16#89# ); B( 16#EE# );
      B( 16#6A# ); B( 16#01# );
      B( 16#58# );
      B( 16#48# ); B( 16#89# ); B( 16#C2# );
      B( 16#48# ); B( 16#89# ); B( 16#C7# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );

    elsif  M = "SYS_PUT_STR"  then
      E_POP_RSI;											--| @doublet (name.data_ptr)
      B( 16#48# ); B( 16#8B# ); B( 16#46# ); B( 16#08# );							--| mov rax, [rsi+8]
      B( 16#8B# ); B( 16#50# ); B( 16#0C# );								--| mov edx, [rax+12]  (last)
      B( 16#FF# ); B( 16#C2# );									--| inc edx
      B( 16#2B# ); B( 16#50# ); B( 16#08# );								--| sub edx, [rax+8]   (longueur)
      B( 16#6A# ); B( 16#01# );  B( 16#58# );								--| push 1 ; pop rax   (sys_write)
      B( 16#48# ); B( 16#89# ); B( 16#C7# );								--| mov rdi, rax       (stdout)
      B( 16#48# ); B( 16#8B# ); B( 16#36# );								--| mov rsi, [rsi]     (@caracteres)
      B( 16#0F# ); B( 16#05# );									--| syscall

    elsif  M = "SYS_GET_CHAR"  then									--| lecture stdin non canonique (termios modifie puis restaure)
      B( 16#48# ); B( 16#83# ); B( 16#EC# ); B( 16#40# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#01# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#83# ); B( 16#64# ); B( 16#24# ); B( 16#0C# ); B( 16#F5# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#02# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      E_POP_RSI;
      B( 16#6A# ); B( 16#00# );
      B( 16#58# );
      B( 16#48# ); B( 16#89# ); B( 16#C7# );
      B( 16#6A# ); B( 16#01# );
      B( 16#5A# );
      B( 16#0F# ); B( 16#05# );
      B( 16#83# ); B( 16#4C# ); B( 16#24# ); B( 16#0C# ); B( 16#0A# );
      B( 16#6A# ); B( 16#10# );
      B( 16#58# );
      B( 16#48# ); B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#C7# ); B( 16#C6# ); B( 16#02# ); B( 16#54# ); B( 16#00# ); B( 16#00# );
      B( 16#48# ); B( 16#89# ); B( 16#E2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#83# ); B( 16#C4# ); B( 16#40# );

    elsif  M = "SYS_GET_STR"  then									--| lit une ligne dans la chaine (doublet), reporte la longueur lue
      E_POP_RSI;
      B( 16#48# ); B( 16#8B# ); B( 16#46# ); B( 16#08# );
      B( 16#8B# ); B( 16#50# ); B( 16#0C# );
      B( 16#FF# ); B( 16#C2# );
      B( 16#2B# ); B( 16#50# ); B( 16#08# );
      B( 16#31# ); B( 16#C0# );
      B( 16#31# ); B( 16#FF# );
      B( 16#48# ); B( 16#8B# ); B( 16#36# );
      B( 16#0F# ); B( 16#05# );
      E_POP_RSI;
      B( 16#FF# ); B( 16#C8# );
      B( 16#89# ); B( 16#06# );

    elsif  M = "SYS_FILE_CREATE"  then									--| creat(O_CREAT|O_RDWR|O_TRUNC, u+rwx) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#6A# ); B( 16#02# );
      B( 16#58# );
      B( 16#BE# ); B( 16#42# ); B( 16#02# ); B( 16#00# ); B( 16#00# );
      B( 16#BA# ); B( 16#C0# ); B( 16#01# ); B( 16#00# ); B( 16#00# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_OPEN"  then									--| open(RDWR) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#6A# ); B( 16#02# );
      B( 16#58# );
      B( 16#6A# ); B( 16#02# );
      B( 16#5E# );
      B( 16#48# ); B( 16#31# ); B( 16#D2# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_SET_POS"  then									--| lseek(SEEK_SET) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      B( 16#48# ); B( 16#31# ); B( 16#D2# );
      B( 16#6A# ); B( 16#08# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_GET_POS"  then									--| lseek(fd, 0, SEEK_CUR)
      E_POP_RDI;
      B( 16#48# ); B( 16#31# ); B( 16#F6# );								--| xor rsi, rsi
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );								--| rdx := 1 (SEEK_CUR)
      B( 16#6A# ); B( 16#08# ); B( 16#58# );								--| rax := 8 (lseek)
      B( 16#0F# ); B( 16#05# );									--| syscall
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );							--| mov [rbp], rax (lieu result)

    elsif  M = "SYS_FILE_GET_SIZE"  then								--| taille, position preservee
      E_POP_RDI;
      B( 16#48# ); B( 16#31# ); B( 16#F6# );								--| xor rsi, rsi
      B( 16#6A# ); B( 16#01# ); B( 16#5A# );								--| SEEK_CUR
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );					--| lseek : position courante
      B( 16#49# ); B( 16#89# ); B( 16#C0# );								--| mov r8, rax
      B( 16#48# ); B( 16#31# ); B( 16#F6# );								--| xor rsi, rsi
      B( 16#6A# ); B( 16#02# ); B( 16#5A# );								--| SEEK_END
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );					--| lseek : taille
      B( 16#49# ); B( 16#89# ); B( 16#C1# );								--| mov r9, rax
      B( 16#4C# ); B( 16#89# ); B( 16#C6# );								--| mov rsi, r8
      B( 16#48# ); B( 16#31# ); B( 16#D2# );								--| xor rdx, rdx (SEEK_SET)
      B( 16#6A# ); B( 16#08# ); B( 16#58# ); B( 16#0F# ); B( 16#05# );					--| lseek : restauration
      B( 16#4C# ); B( 16#89# ); B( 16#4D# ); B( 16#00# );							--| mov [rbp], r9 (lieu result)

    elsif  M = "SYS_FILE_READ"  then									--| read(fd, tampon, longueur) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      E_POP_RDX;
      B( 16#6A# ); B( 16#00# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_WRITE"  then									--| write(fd, tampon, longueur) - resultat sur [rbp]
      E_POP_RDI;
      E_POP_RSI;
      E_POP_RDX;
      B( 16#6A# ); B( 16#01# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_CLOSE"  then									--| close(fd) - resultat sur [rbp]
      E_POP_RDI;
      B( 16#6A# ); B( 16#03# );
      B( 16#58# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_FILE_DELETE"  then									--| unlink(nom copie NUL-termine) - resultat sur [rbp]
      E_POP_RSI;
      E_COPY_STRING_NUL;
      B( 16#B8# ); B( 16#57# ); B( 16#00# ); B( 16#00# ); B( 16#00# );
      B( 16#0F# ); B( 16#05# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );

    elsif  M = "SYS_EXIT"  then
      B( 16#6A# ); B( 16#3C# );									--| push 60
      B( 16#58# );											--| pop rax
      if IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP
	 and then  IR.OP_INT( E, 1 ) /= 0
      then
	B( 16#BF# );										--| mov edi, imm32
	D32( INTEGER( IR.OP_INT( E, 1 ) ) );
      else
	B( 16#31# ); B( 16#FF# );									--| xor edi, edi
      end if;
      B( 16#0F# ); B( 16#05# );									--| syscall

    else
      FAULT( "mnemonique hors tranche TC-04 : " & M );
    end if;
  end ENCODE;


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
      B( 0 );								--| padding e_ident
    end loop;
    W16( 2 );								--| ET_EXEC
    W16( 62 );								--| EM_X86_64
    D32( 1 );								--| e_version
    Q64( ENTRY_PT );							--| e_entry
    Q64( 64 );								--| e_phoff
    Q64( 0 );								--| e_shoff
    D32( 0 );								--| e_flags
    W16( 64 );								--| e_ehsize
    W16( 56 );								--| e_phentsize
    W16( 1 );								--| e_phnum
    W16( 0 ); W16( 0 ); W16( 0 );					--| e_shentsize, e_shnum, e_shstrndx
    --  Phdr
    D32( 1 );								--| PT_LOAD
    D32( 7 );								--| RWX
    Q64( 16#78# );							--| p_offset
    Q64( ENTRY_PT );							--| p_vaddr
    Q64( 0 );								--| p_paddr
    Q64( ASM );								--| p_filesz
    Q64( ASM + COPILE_RESERVE );					--| p_memsz : + 16 Gio co-pile (piege n 109)
    Q64( 4096 );							--| p_align
    if TOP /= 16#78#
    then
      FAULT( "en-tete ELF : longueur inattendue" );
    end if;
  end EMIT_ELF_HEADER;

  procedure		EMIT_PROLOGUE
  is
    T0			: constant INTEGER := TOP;
    COPILE_BASE		: constant SYMBOLS.VALUE_TYPE
			:= ENTRY_PT + 8 * ( ( ASM + 7 ) / 8 );
  begin
    B( 16#48# ); B( 16#31# ); B( 16#C0# );				--| xor rax, rax
    --  tas : mmap anonyme 64 Mo
    B( 16#48# ); B( 16#31# ); B( 16#FF# );				--| xor rdi, rdi
    B( 16#BE# );  D32( HEAP_SIZE );					--| mov esi, TAILLE_TAS
    B( 16#6A# ); B( 16#03# );  B( 16#5A# );				--| push 3 ; pop rdx
    B( 16#41# ); B( 16#BA# ); B( 16#22# ); B( 0 ); B( 0 ); B( 0 );	--| mov r10d, 0x22
    B( 16#49# ); B( 16#C7# ); B( 16#C0# );
    B( 16#FF# ); B( 16#FF# ); B( 16#FF# ); B( 16#FF# );			--| mov r8, -1
    B( 16#45# ); B( 16#31# ); B( 16#C9# );				--| xor r9d, r9d
    B( 16#6A# ); B( 16#09# );  B( 16#58# );				--| push 9 ; pop rax
    B( 16#0F# ); B( 16#05# );						--| syscall
    B( 16#4C# ); B( 16#8D# ); B( 16#A0# );  D32( HEAP_SIZE );		--| lea r12, [rax + TAILLE_TAS]
    --  pile montante + display
    B( 16#48# ); B( 16#8D# ); B( 16#A4# ); B( 16#24# );
    B( 16#00# ); B( 16#00# ); B( 16#C0# ); B( 16#FF# );			--| lea rsp, [rsp - 4 Mo]
    B( 16#49# ); B( 16#89# ); B( 16#E7# );				--| mov r15, rsp
    B( 16#48# ); B( 16#8D# ); B( 16#AC# ); B( 16#24# );
    B( 16#00# ); B( 16#01# ); B( 16#00# ); B( 16#00# );			--| lea rbp, [rsp + 8*32]
    B( 16#49# ); B( 16#89# ); B( 16#2F# );				--| mov [r15], rbp
    --  co-pile
    B( 16#4C# ); B( 16#8D# ); B( 16#34# ); B( 16#25# );
    D32( INTEGER( COPILE_BASE ) );					--| lea r14, [ENTRY + 8*((ASM_SIZE+7)/8)]
    B( 16#4D# ); B( 16#89# ); B( 16#36# );				--| mov [r14], r14
    B( 16#4D# ); B( 16#89# ); B( 16#F5# );				--| mov r13, r14
    B( 16#4D# ); B( 16#8D# ); B( 16#76# ); B( 16#08# );			--| lea r14, [r14 + 8]
    if TOP - T0 /= PROLOGUE_SIZE
    then
      FAULT( "amorcage : longueur inattendue" );
    end if;
  end EMIT_PROLOGUE;


  -------------------------------------------------------------------------------------------------------------------
  --			P2B : adressage  /  P3 : emission
  -------------------------------------------------------------------------------------------------------------------

  procedure		P2B_ADDRESSES ( FROM, TO :IR.ELT_ID )
  is
    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    CUR			: SYMBOLS.VALUE_TYPE := ENTRY_PT + PROLOGUE_SIZE;
  begin
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
	  SYMBOLS.SET_VALUE( SYMBOLS.DECLARE_SYM( "data", SYMBOLS.CODE_LABEL ), CUR + 5 );
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
  end ASM_SIZE;

			-------
  procedure		P3_EMIT		( FROM, TO :IR.ELT_ID; BIN_NAME :STRING )
  is			-------

    S0			: constant SYMBOLS.SCOPE_ID := SYMBOLS.CURRENT_SCOPE;
    T0			: INTEGER;
    F			: BIO.FILE_TYPE;

  begin
    TOP := 0;
    EMIT_ELF_HEADER;
    EMIT_PROLOGUE;

    for  E in FROM .. TO  loop
      SYMBOLS.SET_EPOCH( NATURAL( E ) );								--| epoque du texte (TC-24)
      if PASSES.ACTIVE( E )  and then  IR.KIND_OF( E ) = IR.MACRO_CALL
      then
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
