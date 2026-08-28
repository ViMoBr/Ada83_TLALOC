------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE.EMITS )

					------------
package body				ARM64_TARGET
is					------------

  use IR;												--| operateurs ELT_KIND / OPERAND_TAG (LRM 8.4)

  --|  TRANCHE C1 (TC-ARM04) : DROP DUP LI ADD SUB MUL BRA BEGIN_BLOC_DEF
  --|  SYS_EXIT + amorcage. TRANCHE C2 (TC-ARM05/06) : LCA LSPA LIF LVA LIVA,
  --|  charges et rangements directs/indirects/non signes (ULB..LA, ULIB..LIA,
  --|  SB..SA, SIB..SIA), LINK UNLINK CEQ BT BF SYS_PUT_STR.
  --|  Transcription MOT PAR MOT de codi_arm64.finc.
  --|  Registres (codi tete) : x29 sommet de micro-pile, x28 display,
  --|  x27 haut de co-pile, x26 frame de co-pile, x25 haut du tas.
  --|  Une instruction = un mot de 32 bits petit-boutiste (DD).
  --|  Ada 83 n'a pas d'operateurs de bits sur les entiers : les champs
  --|  d'un mot sont COMPOSES PAR ADDITION, exact tant qu'ils sont disjoints
  --|  - c'est le cas de tous les 'or' du codi (Rd bits 0-4 = + Rd, imm16
  --|  bits 5-20 = * 32, hw bits 21-22 = * 2097152, imm26 bits 0-25).
  --|  'shr' de fasmg est ARITHMETIQUE (plancher) : CHUNK retire le reste
  --|  avant de diviser (Ada tronque vers zero). 'and 0xFFFF' = mod 65536,
  --|  'xor 0xFFFF' d'un chunk = 16#FFFF# - chunk.

  --|  TRANCHE C3 (TC-ARM07/09, corpus NULL_PROG) : NEG INC DEC SHL CLAMP0 OUX
  --|  FNEG DIV REMI CVTIX CGT CLT CLE CNE CGE BLKMOV CO_VAR PRO ELB CALL CALLI
  --|  RTD EXC_MACH EXC_RAISE.

  --|  TRANCHE C4 (TC-ARM16/21, completion) : ET OU NON SHR SAR UBFX SBFX BFI ABS
  --|  MODI, FADD FSUB FMUL FDIV FABS FEXP CVTIF CVTFI CVTFIR CVTXI, FCEQ FCNE FCGT
  --|  FCGE FCLT FCLE, HEAP_ALLOC, BLKAND BLKOU BLKOUX BLKNOT BLKCMP LEXCMP, SYS_*
  --|  (CLOCK_GETTIME, PUT_CHAR, GET_CHAR, GET_STR, FILE_*). La table du codi est
  --|  COMPLETE. Les sequences fixes sont transcrites mecaniquement depuis le
  --|  codi (transcribe.py, branchements internes resolus, desassemblage).

			--
  procedure		DD		( V :SYMBOLS.VALUE_TYPE )					--| un mot d'instruction
  is			--
    U			: SYMBOLS.VALUE_TYPE	:= V;
  begin
    for  I in 1 .. 4  loop
      B( INTEGER( U mod 256 ) );
      U := ( U - ( U mod 256 ) ) / 256;
    end loop;

  end	DD;
	--

			-----
  function		CHUNK		( V :SYMBOLS.VALUE_TYPE; IDX :NATURAL )	return SYMBOLS.VALUE_TYPE
  is			-----									--| ((V) shr (16*IDX)) and 0xFFFF du codi :
    U			: SYMBOLS.VALUE_TYPE	:= V;						--| tranche IDX (0..3) du motif 64 bits,
  begin												--| complement a deux (division PLANCHER)
    for  I in 1 .. IDX  loop
      U := ( U - ( U mod 65536 ) ) / 65536;
    end loop;
    return  U mod 65536;

  end	CHUNK;
	-----

  --|  QUAD_CONST Rd, val (codi) : 0..0xFFFF -> movz ; -0x10000..-1 -> movn ;
  --|  sinon vue movz (chunks nuls implicites) ou vue movn (chunks 0xFFFF
  --|  implicites), la moins chere, premier chunk explicite movz/movn puis
  --|  movk. Taille = 4 * max( 1, min( nz, nf ) ) : fonction de val SEULE
  --|  (contrat SIZE_OF : val est un immediat ou un offset de P2, jamais une
  --|  adresse - les adresses passent par QUAD_ADDR, taille fixe).

			------
  function		QC_LEN		( V :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			------
    NZ			: SYMBOLS.VALUE_TYPE	:= 0;
    NF			: SYMBOLS.VALUE_TYPE	:= 0;
    C			: SYMBOLS.VALUE_TYPE;
  begin
    if  V >= 0  and then  V <= 16#FFFF#  then
      return  4;
    elsif  V < 0  and then  V >= -16#10000#  then
      return  4;
    end if;
    for  IDX in 0 .. 3  loop
      C := CHUNK( V, IDX );
      if  C /= 0  then
        NZ := NZ + 1;
      end if;
      if  C /= 16#FFFF#  then
        NF := NF + 1;
      end if;
    end loop;
    if  NZ < NF  then
      NF := NZ;											--| min
    end if;
    if  NF < 1  then
      NF := 1;											--| max( 1, . )
    end if;
    return  4 * NF;

  end	QC_LEN;
	------

			------------
  procedure		E_QUAD_CONST	( RD, V :SYMBOLS.VALUE_TYPE )
  is			------------
    NZ			: SYMBOLS.VALUE_TYPE	:= 0;
    NF			: SYMBOLS.VALUE_TYPE	:= 0;
    C			: SYMBOLS.VALUE_TYPE;
    EMITTED		: BOOLEAN		:= FALSE;
  begin
    if  V >= 0  and then  V <= 16#FFFF#  then
      DD( 16#D2800000# + V * 32 + RD );									--| movz Rd, #val
      return;
    elsif  V < 0  and then  V >= -16#10000#  then
      DD( 16#92800000# + ( -V - 1 ) * 32 + RD );								--| movn Rd, #(not val)
      return;
    end if;
    for  IDX in 0 .. 3  loop
      C := CHUNK( V, IDX );
      if  C /= 0  then
        NZ := NZ + 1;
      end if;
      if  C /= 16#FFFF#  then
        NF := NF + 1;
      end if;
    end loop;
    for  IDX in 0 .. 3  loop
      C := CHUNK( V, IDX );
      if  NZ <= NF  then										--| vue movz : les chunks nuls sont implicites
        if  C /= 0  then
          if  not EMITTED  then
            DD( 16#D2800000# + SYMBOLS.VALUE_TYPE( IDX ) * 2097152 + C * 32 + RD );				--| movz Rd, #chunk, lsl #(16*idx)
            EMITTED := TRUE;
          else
            DD( 16#F2800000# + SYMBOLS.VALUE_TYPE( IDX ) * 2097152 + C * 32 + RD );				--| movk Rd, #chunk, lsl #(16*idx)
          end if;
        end if;
      else											--| vue movn : les chunks 0xFFFF sont implicites
        if  C /= 16#FFFF#  then
          if  not EMITTED  then
            DD( 16#92800000# + SYMBOLS.VALUE_TYPE( IDX ) * 2097152 + ( 16#FFFF# - C ) * 32 + RD );			--| movn Rd, #(not chunk), lsl #(16*idx)
            EMITTED := TRUE;
          else
            DD( 16#F2800000# + SYMBOLS.VALUE_TYPE( IDX ) * 2097152 + C * 32 + RD );				--| movk Rd, #chunk, lsl #(16*idx)
          end if;
        end if;
      end if;
    end loop;
    if  not EMITTED  then										--| tous implicites : 0 (movz) ou -1 (movn)
      if  NZ <= NF  then
        DD( 16#D2800000# + RD );
      else
        DD( 16#92800000# + RD );
      end if;
    end if;

  end	E_QUAD_CONST;
	------------

			---
  procedure		E_B		( TARGET :SYMBOLS.VALUE_TYPE )				--| b label : 0x14000000 or ((disp shr 2)
  is			---									--| and 0x3FFFFFF), disp = cible - $ de

    DISP	: constant SYMBOLS.VALUE_TYPE		:= TARGET - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) );			--| l'instruction (codi : lbl - $ + 4)
    W	: constant SYMBOLS.VALUE_TYPE		:= ( DISP - ( DISP mod 4 ) ) / 4;				--| shr 2 plancher
  begin
    DD( 16#14000000# + ( W mod 2 ** 26 ) );								--| and 0x3FFFFFF : complement a deux 26 bits

  end	E_B;
	---

			----------
  procedure		E_PUSH_RAX								--| 8 octets
  is			----------
  begin
    DD( 16#F80083A0# );										--| stur x0, [x29, #8]
    DD( 16#910023BD# );										--| add  x29, x29, #8
  end	E_PUSH_RAX;
	----------

			---------
  procedure		E_POP_RAX									--| 8 octets
  is			---------
  begin
    DD( 16#F94003A0# );										--| ldr x0, [x29]
    DD( 16#D10023BD# );										--| sub x29, x29, #8
  end	E_POP_RAX;
	---------

			---------
  procedure		E_POP_RBX									--| 8 octets (data dans x1)
  is			---------
  begin
    DD( 16#F94003A1# );										--| ldr x1, [x29]
    DD( 16#D10023BD# );										--| sub x29, x29, #8
  end	E_POP_RBX;
	---------

			---------
  procedure		E_POP_RCX									--| x2
  is			---------
  begin
    DD( 16#F94003A2# );										--| ldr x2, [x29]
    DD( 16#D10023BD# );										--| sub x29, x29, #8
  end	E_POP_RCX;
	---------

			---------
  procedure		E_POP_RDX									--| x3
  is			---------
  begin
    DD( 16#F94003A3# );										--| ldr x3, [x29]
    DD( 16#D10023BD# );
  end	E_POP_RDX;
	---------

			---------
  procedure		E_POP_RDI									--| x5
  is			---------
  begin
    DD( 16#F94003A5# );										--| ldr x5, [x29]
    DD( 16#D10023BD# );
  end	E_POP_RDI;
	---------

			---------
  procedure		E_POP_RSI									--| x4
  is			---------
  begin
    DD( 16#F94003A4# );										--| ldr x4, [x29]
    DD( 16#D10023BD# );
  end	E_POP_RSI;
	---------


  --|  Display (codi FP_IN_RAX / RAX_IN_FP / FP_IN_RBP) : [x28 + 8*lvl],
  --|  imm12 scale 8 = lvl, champ bits 10-21 (* 1024). lvl 0..31.

			-----
  procedure		E_FPA		( LVL :SYMBOLS.VALUE_TYPE )					--| ldr x0, [x28, #8*lvl]
  is			-----
  begin
    if  LVL < 0  or else  LVL > 31  then
      FAULT( "niveau de frame hors 0..31" );
    end if;
    DD( 16#F9400380# + LVL * 1024 );
  end	E_FPA;
	-----

			--------
  procedure		E_RAX_FP	( LVL :SYMBOLS.VALUE_TYPE )						--| str x0, [x28, #8*lvl]
  is			--------
  begin
    DD( 16#F9000380# + LVL * 1024 );
  end	E_RAX_FP;
	--------

			--------
  procedure		E_FP_RBP	( LVL :SYMBOLS.VALUE_TYPE )						--| ldr x29, [x28, #8*lvl]
  is			--------
  begin
    DD( 16#F940039D# + LVL * 1024 );
  end	E_FP_RBP;
	--------

			------
  function		S_BASE		( LVL :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			------
  begin
    if  LVL = -1  then
      return  8;											--| POP_RAX : adresse empilee
    end if;
    return  4;											--| FP_IN_RAX
  end	S_BASE;
	------

			------
  procedure		E_BASE		( LVL :SYMBOLS.VALUE_TYPE )					--| BASE_IN_RAX
  is			------
  begin
    if  LVL = -1  then
      E_POP_RAX;
    else
      E_FPA( LVL );
    end if;
  end	E_BASE;
	------

  --|  Acces memoire [x0 + disp] (FETCH_* / STORE_* et LOAD_QUAD / STORE_QUAD
  --|  du codi) : TROIS PLAGES, l'homologue arm de S_DISP.
  --|    disp >= 0, <= 4095*scale, multiple de scale : forme scalee, imm12 =
  --|      disp/scale, champ bits 10-21 (* 1024) ;
  --|    disp -256..255 : forme non scalee (ldur/stur), imm9 signe = disp and
  --|      0x1FF = disp mod 512, champ bits 12-20 (* 4096) ;
  --|    sinon : QUAD_CONST 17, disp puis forme registre [x0, x17].
  --|  OPS / OPU / OPR : les trois opcodes avec leurs champs fixes (Rt, Rn = x0,
  --|  Rm = 17) deja poses ; seul le champ de deplacement est ajoute ici.
  --|  (Le codi teste disp = 0 a part puis disp > 0 pour l'octet : meme mot.)

			-----
  function		M_LEN		( D, SCALE :SYMBOLS.VALUE_TYPE )	return SYMBOLS.VALUE_TYPE
  is			-----
  begin
    if  D >= 0  and then  D <= 4095 * SCALE  and then  D mod SCALE = 0  then
      return  4;
    elsif  D >= -256  and then  D <= 255  then
      return  4;
    end if;
    return  QC_LEN( D ) + 4;
  end	M_LEN;
	-----

			-----
  procedure		E_MEM		( D, SCALE, OPS, OPU, OPR :SYMBOLS.VALUE_TYPE )
  is			-----
  begin
    if  D >= 0  and then  D <= 4095 * SCALE  and then  D mod SCALE = 0  then
      DD( OPS + ( D / SCALE ) * 1024 );									--| [x0, #disp]  imm12 scale
    elsif  D >= -256  and then  D <= 255  then
      DD( OPU + ( D mod 512 ) * 4096 );									--| [x0, #disp]  imm9 signe
    else
      E_QUAD_CONST( 17, D );										--| x17 = disp
      DD( OPR );											--| [x0, x17]
    end if;
  end	E_MEM;
	-----

  --|  Les douze acces du codi : (scale, OPS, OPU, OPR). Formes registre =
  --|  opcode codi or (17 shl 16) [or 1] : 0x38606800 -> 16#38716800#, etc.

  procedure E_FETCH_UB	( D :SYMBOLS.VALUE_TYPE )							--| ldrb w0 (zero-ext.)
  is begin  E_MEM( D, 1, 16#39400000#, 16#38400000#, 16#38716800# );  end E_FETCH_UB;
  procedure E_FETCH_UW	( D :SYMBOLS.VALUE_TYPE )							--| ldrh w0
  is begin  E_MEM( D, 2, 16#79400000#, 16#78400000#, 16#78716800# );  end E_FETCH_UW;
  procedure E_FETCH_UD	( D :SYMBOLS.VALUE_TYPE )							--| ldr w0
  is begin  E_MEM( D, 4, 16#B9400000#, 16#B8400000#, 16#B8716800# );  end E_FETCH_UD;
  procedure E_FETCH_B	( D :SYMBOLS.VALUE_TYPE )							--| ldrsb x0
  is begin  E_MEM( D, 1, 16#39800000#, 16#38800000#, 16#38B16800# );  end E_FETCH_B;
  procedure E_FETCH_W	( D :SYMBOLS.VALUE_TYPE )							--| ldrsh x0
  is begin  E_MEM( D, 2, 16#79800000#, 16#78800000#, 16#78B16800# );  end E_FETCH_W;
  procedure E_FETCH_D	( D :SYMBOLS.VALUE_TYPE )							--| ldrsw x0
  is begin  E_MEM( D, 4, 16#B9800000#, 16#B8800000#, 16#B8B16800# );  end E_FETCH_D;
  procedure E_FETCH_Q	( D :SYMBOLS.VALUE_TYPE )							--| ldr x0 (LOAD_QUAD d, 0, 0)
  is begin  E_MEM( D, 8, 16#F9400000#, 16#F8400000#, 16#F8716800# );  end E_FETCH_Q;
  procedure E_STORE_B	( D :SYMBOLS.VALUE_TYPE )							--| strb w1
  is begin  E_MEM( D, 1, 16#39000001#, 16#38000001#, 16#38316801# );  end E_STORE_B;
  procedure E_STORE_W	( D :SYMBOLS.VALUE_TYPE )							--| strh w1
  is begin  E_MEM( D, 2, 16#79000001#, 16#78000001#, 16#78316801# );  end E_STORE_W;
  procedure E_STORE_D	( D :SYMBOLS.VALUE_TYPE )							--| str w1
  is begin  E_MEM( D, 4, 16#B9000001#, 16#B8000001#, 16#B8316801# );  end E_STORE_D;
  procedure E_STORE_Q	( D :SYMBOLS.VALUE_TYPE )							--| str x1 (STORE_QUAD d, 0, 1)
  is begin  E_MEM( D, 8, 16#F9000001#, 16#F8000001#, 16#F8316801# );  end E_STORE_Q;

			-------
  procedure		E_IBASE		( LVL, D :SYMBOLS.VALUE_TYPE )				--| INDIRECT_BASE_IN_RAX
  is			-------
  begin
    E_BASE( LVL );
    E_FETCH_Q( D );
  end	E_IBASE;
	-------

  --|  Ajout d'un deplacement a x0 (LVA / LIVA) : rien si 0 ; add/sub imm12
  --|  (-4095..4095, champ * 1024) ; sinon QUAD_CONST 17 puis add x0, x0, x17.

			-----
  function		A_LEN		( D :SYMBOLS.VALUE_TYPE )		return SYMBOLS.VALUE_TYPE
  is			-----
  begin
    if  D = 0  then
      return  0;
    elsif  D >= -4095  and then  D <= 4095  then
      return  4;
    end if;
    return  QC_LEN( D ) + 4;
  end	A_LEN;
	-----

			-----
  procedure		E_ADD		( D :SYMBOLS.VALUE_TYPE )
  is			-----
  begin
    if  D = 0  then
      null;
    elsif  D >= 0  and then  D <= 4095  then
      DD( 16#91000000# + D * 1024 );									--| add x0, x0, #disp
    elsif  D >= -4095  and then  D < 0  then
      DD( 16#D1000000# + ( -D ) * 1024 );								--| sub x0, x0, #(-disp)
    else
      E_QUAD_CONST( 17, D );
      DD( 16#8B110000# );										--| add x0, x0, x17
    end if;
  end	E_ADD;
	-----

			-----------
  procedure		E_QUAD_ADDR	( RD, V :SYMBOLS.VALUE_TYPE )					--| adresse : TAILLE FIXE 8 (movz + movk)
  is			-----------
  begin
    if  V < 0  or else  V > 16#FFFFFFFF#  then
      FAULT( "QUAD_ADDR : adresse hors 32 bits" );							--| assert du codi
    end if;
    DD( 16#D2800000# + CHUNK( V, 0 ) * 32 + RD );								--| movz Rd, #lo16
    DD( 16#F2A00000# + CHUNK( V, 1 ) * 32 + RD );								--| movk Rd, #hi16, lsl #16
  end	E_QUAD_ADDR;
	-----------


  --|  LOAD_QUAD ofs, Ra, Rd / STORE_QUAD ofs, Ra, Rs du codi, registres
  --|  quelconques (EXC_MACH, EXC_RAISE) : memes trois plages qu'E_MEM,
  --|  opcodes = base + Ra * 32 + Rt ; forme registre avec Rm = 17 deja pose.

			----
  procedure		E_LQ		( OFS, RA, RD :SYMBOLS.VALUE_TYPE )				--| ldr Rd, [Ra, #ofs]
  is			----
  begin
    E_MEM( OFS, 8, 16#F9400000# + RA * 32 + RD, 16#F8400000# + RA * 32 + RD, 16#F8716800# + RA * 32 + RD );
  end	E_LQ;
	----

			----
  procedure		E_SQ		( OFS, RA, RS :SYMBOLS.VALUE_TYPE )				--| str Rs, [Ra, #ofs]
  is			----
  begin
    E_MEM( OFS, 8, 16#F9000000# + RA * 32 + RS, 16#F8000000# + RA * 32 + RS, 16#F8316800# + RA * 32 + RS );
  end	E_SQ;
	----


  --|  LINK lvl, alloc (codi) : partage par LINK et ELB (alloc = loc_siz).
  --|  12 (co-pile) + 16 si lvl > 0 + selon alloc8 = 8*((alloc+7)/8) :
  --|  0 / 4 (imm12) / 4 (imm12 lsl 12) / QC_LEN + 4 (x17).

			--------
  function		LINK_LEN	( LVL, ALLOC :SYMBOLS.VALUE_TYPE )	return SYMBOLS.VALUE_TYPE
  is			--------

    A8			: constant SYMBOLS.VALUE_TYPE	:= 8 * ( ( ALLOC + 7 ) / 8 );
    N			: SYMBOLS.VALUE_TYPE		:= 12;

  begin
    if  LVL > 0  then
      N := N + 16;
    end if;
    if  A8 /= 0  then
      if  A8 <= 4095  then
        N := N + 4;
      elsif  A8 <= 16777215  and then  A8 mod 4096 = 0  then
        N := N + 4;
      else
        N := N + QC_LEN( A8 ) + 4;
      end if;
    end if;
    return  N;

  end	LINK_LEN;
	--------


			------
  procedure		E_LINK		( LVL, ALLOC :SYMBOLS.VALUE_TYPE )
  is			------
    A8			: constant SYMBOLS.VALUE_TYPE	:= 8 * ( ( ALLOC + 7 ) / 8 );
  begin
    if  ALLOC < 0  then
      FAULT( "LINK : alloc negatif" );									--| assert du codi
    end if;
    if  LVL > 0  then
      E_FPA( LVL );											--| x0 = ancien FP du niveau
      E_PUSH_RAX;
      DD( 16#F900039D# + LVL * 1024 );									--| str x29, [x28, #8*lvl]
    end if;
    if  A8 /= 0  then
      if  A8 <= 4095  then
        DD( 16#910003BD# + A8 * 1024 );									--| add x29, x29, #alloc8
      elsif  A8 <= 16777215  and then  A8 mod 4096 = 0  then
        DD( 16#914003BD# + ( A8 / 4096 ) * 1024 );							--| add x29, x29, #alloc8, lsl #12
      else
        E_QUAD_CONST( 17, A8 );
        DD( 16#8B1103BD# );										--| add x29, x29, x17
      end if;
    end if;
    DD( 16#F900037A# );										--| str x26, [x27]
    DD( 16#AA1B03FA# );										--| mov x26, x27
    DD( 16#9100237B# );										--| add x27, x27, #8

  end	E_LINK;
	------


			---------
  procedure		E_SDIV128									--| SDIV128_64_POS : (x3:x0) / x1, x1 > 0
  is			---------									--| x0 = quotient, x3 = reste ; 29 mots,
  begin												--| branchements internes FIXES (C3)
    DD( 16#937FFC10# );										--| asr x16, x0, #63
    DD( 16#EB10007F# );										--| cmp x3, x16
    DD( 16#540000A1# );										--| b.ne slow (+7)
    DD( 16#9AC10C02# );										--| sdiv x2, x0, x1
    DD( 16#9B018043# );										--| msub x3, x2, x1, x0
    DD( 16#AA0203E0# );										--| mov x0, x2
    DD( 16#14000017# );										--| b fin (+23)
    DD( 16#937FFC70# );										--| slow: asr x16, x3, #63
    DD( 16#CA100000# );										--| eor x0, x0, x16
    DD( 16#CA100063# );										--| eor x3, x3, x16
    DD( 16#EB100000# );										--| subs x0, x0, x16
    DD( 16#DA100063# );										--| sbc x3, x3, x16
    DD( 16#AA0003E2# );										--| mov x2, x0
    DD( 16#D2800000# );										--| mov x0, #0
    DD( 16#D2800811# );										--| mov x17, #64
    DD( 16#AB020042# );										--| boucle: adds x2, x2, x2
    DD( 16#BA030063# );										--| adcs x3, x3, x3
    DD( 16#D37FF800# );										--| lsl x0, x0, #1
    DD( 16#54000062# );										--| b.cs soustraire (+3)
    DD( 16#EB01007F# );										--| cmp x3, x1
    DD( 16#54000063# );										--| b.lo suite (+3)
    DD( 16#CB010063# );										--| soustraire: sub x3, x3, x1
    DD( 16#B2400000# );										--| orr x0, x0, #1
    DD( 16#F1000631# );										--| suite: subs x17, x17, #1
    DD( 16#54FFFEE1# );										--| b.ne boucle (-9)
    DD( 16#CA100000# );										--| eor x0, x0, x16
    DD( 16#CB100000# );										--| sub x0, x0, x16
    DD( 16#CA100063# );										--| eor x3, x3, x16
    DD( 16#CB100063# );										--| sub x3, x3, x16

  end	E_SDIV128;
	---------


			-------
  function		SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			-------

    M	:constant STRING	:= LEX.IMAGE( IR.MNEMO_OF( E ) );

  begin
    if  IR.KIND_OF( E ) /= IR.MACRO_CALL  then  return 0;							--| labels, virtual, map : zero octet
    end if;

    if  M = "DROP"  then return  4;
    elsif  M = "DUP"  then return  12;

			---------------------------------------------------
--			L O A D	C O N S T A N T E S	  I M M E D I A T E S

    elsif  M = "LI"  then return  QC_LEN( OPV( E, 1, 0 ) ) + 8;						--| QUAD_CONST (1..4 mots) + PUSH_RAX
    elsif  M = "LIF"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.FLT_OP  then
        FAULT( "LIF : litteral flottant attendu" );
      end if;
      return  QC_LEN( DOUBLE_BITS( IR.OP_FLT( E, 1 ) ) ) + 8;


			-------------------------------------------------------------
--			L O A D	C O N S T A N T  /  V A R I A B L E   A D R E S S E

    elsif  M = "LCA"  then return  16;									--| QUAD_ADDR (8) + PUSH_RAX (8)
    elsif  M = "LSPA"  then return  16;

    elsif  M = "LVA"  then return  S_BASE( OPV( E, 1, -1 ) ) + A_LEN( OPV( E, 2, 0 ) ) + 8;
    elsif  M = "LIVA"  then return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 )
					+ A_LEN( OPV( E, 3, 0 ) ) + 8;


				-----------------
--				L O A D	D A T A		(unsigned/signed)

    elsif  M = "ULB"  or else  M = "LB"  then  return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 1 ) + 8;
    elsif  M = "ULW"  or else  M = "LW"  then  return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 2 ) + 8;
    elsif  M = "ULD"  or else  M = "LD"  then  return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 4 ) + 8;
    elsif  M = "LQ"  or else  M = "LA"  then  return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + 8;
    elsif  M = "ULIB"  or else  M = "LIB"  then
      return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 1 ) + 8;
    elsif  M = "ULIW"  or else  M = "LIW"  then
      return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 2 ) + 8;
    elsif  M = "ULID"  or else  M = "LID"  then
      return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 4 ) + 8;
    elsif  M = "LIQ"  or else  M = "LIA"  then
      return  S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 8 ) + 8;


				-------------------
--				S T O R E	  D A T A

    elsif  M = "SB"  then return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 1 );
    elsif  M = "SW"  then return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 2 );
    elsif  M = "SD"  then return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 4 );
    elsif  M = "SQ"  or else  M = "SA"  then
      return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 );
    elsif  M = "SIB"  then
      return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 1 );
    elsif  M = "SIW"  then
      return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 2 );
    elsif  M = "SID"  then
      return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 4 );
    elsif  M = "SIQ"  or else  M = "SIA"  then
      return  8 + S_BASE( OPV( E, 1, -1 ) ) + M_LEN( OPV( E, 2, 0 ), 8 ) + M_LEN( OPV( E, 3, 0 ), 8 );


		-------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S

    elsif  M = "ET"  or else  M = "OU"  or else  M = "OUX" or else M = "SHL"  or else  M = "SHR"  then return  20;	--| POP + ldr, op, str
    elsif  M = "NON"  then return  12;


		-----------------------------------------
--		O P E R A T I O N S	  B I T	F I E L D S

    elsif  M = "UBFX"  or else  M = "SBFX"  then return  44;
    elsif  M = "BFI"  then return  68;


		-------------------------------------------------------------
--		O P E R A T I O N S	  A R I T H M E T I Q U E   E N T I E R E

    elsif  M = "DEC"  or else  M = "INC"  or else  M = "NEG"  then return  12;
    elsif  M = "ABS"  then return  16;
    elsif  M = "CLAMP0"  then return  16;
    elsif  M = "ADD"  or else  M = "SUB"  or else  M = "MUL"  then return  20;					--| POP_RAX + ldr, op, str
    elsif  M = "DIV"  then return  28;									--| POP_RBX + POP_RAX + sdiv + PUSH_RAX
    elsif  M = "REMI"  then return  32;									--| ... sdiv + msub ...
    elsif  M = "MODI"  then return  48;		--| REMI + ajustement (cbz, eor, tbz, add)
    elsif  M = "SAR"  then return  20;									--| POP + ldr, op, str


	---------------------------------------------------------------------------------------------
--	O P E R A T I O N S	  A R I T H M E T I Q U E   F L O T T A N T E   ( S S E 2	d o u b l e )

    elsif  M = "FADD"  or else  M = "FSUB"  or else  M = "FMUL"  or else  M = "FDIV"  then return  20;		--| ldr d1, DROP, ldr d0, op, str d0
    elsif  M = "FNEG"  then return  12;
    elsif  M = "FABS"  then return  12;
    elsif  M = "FEXP"  then return  40;									--| POP_RCX + 1.0 par movz lsl 48 + boucle fmul


	---------------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F L O T T A N T

    elsif  M = "CVTIF"  or else  M = "CVTFI"  or else  M = "CVTFIR"  then return  12;


	---------------------------------------------------
--	C O N V E R S I O N S   E N T I E R  <->  F I X E D

    elsif  M = "CVTIX"  then return  156;								--| 3 POP + smulh + mul + SDIV128_64_POS (29 mots) + PUSH
    elsif  M = "CVTXI"  then return  192;								--| 3 POP (24) + smulh, mul (8) + SDIV128_64_POS (116) + arrondi (36) + PUSH (8)


				-----------------------
--				C O M P A R A I S O N S

    elsif  M = "CEQ"  then return  24;									--| POP_RBX + ldr, cmp, cset, str
    elsif  M = "CGT"  or else  M = "CLT"  or else  M = "CLE"  or else  M = "CNE"  or else  M = "CGE"  then
      return  24;											--| comme CEQ


		-------------------------------------------------------------------------
--		C O M P A R A I S O N S   F L O T T A N T E S   ( S S E 2	d o u b l e )

    elsif  M = "FCEQ"  or else  M = "FCNE"  or else  M = "FCGT"  or else  M = "FCGE"  or else  M = "FCLT"
	 or else  M = "FCLE"  then return  24;								--| fcmp + cset


			-----------------------------------------------------
--			O P E R A T I O N S	  C O N T R O L E	D E   F L O T

    elsif  M = "BRA"  then return  4;									--| b imm26, taille FIXE
    elsif  M = "BT"  or else  M = "BF"  then return  16;							--| POP_RAX + cbz/cbnz +8 + b (forme longue)
    elsif  M = "CALL"  then return  16;									--| adr, sub sp, str, b .elab (taille FIXE)
    elsif  M = "CALLI"  then return  24;								--| POP_RAX + adr, sub sp, str, br x0
    elsif  M = "RTD"  then
      declare
	P		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
	if  P = 0  then
	  return  12;										--| ldr x16, [sp] ; add sp ; br x16
	elsif  P <= 4095  then
	  return  16;
	elsif  P <= 16777215  and then  P mod 4096 = 0  then
	  return  16;
	end if;
	return  QC_LEN( P ) + 16;
      end;


			---------------------------------------------------
--			O P E R A T I O N S	  G E S T I O N   D E   P I L E

    elsif  M = "LINK"  then
      declare
	LVL		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
	return  LINK_LEN( LVL, OPV( E, 2, 0 ) );
      end;

    elsif  M = "UNLINK"  then return  20;								--| FP_IN_RBP + POP_RAX + RAX_IN_FP + ldr x26
    elsif  M = "UNLINKR"  then return  24;								--| FP_IN_RBP + POP_RAX + RAX_IN_FP + ldr x26 + mox x27,x26

    elsif  M = "PRO"  then return  4;									--| BRA post

    elsif  M = "ELB"  then										--| LINK lvl, loc_siz (elab deja adresse en P2B)
      return  LINK_LEN( OPV( E, 1, 0 ), SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "loc_siz" ) ) );

    elsif  M = "BEGIN_BLOC_DEF"  then return  4;								--| BRA IMAGES.skip (TRAITS.BRA_SIZE)

    elsif  M = "CO_VAR"  then return  28;								--| POP_RAX + 5 mots

    elsif  M = "HEAP_ALLOC"  then return  36;

    elsif  M = "EXC_MACH"  then
      declare
	LVL	:constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
	CTX	:constant SYMBOLS.VALUE_TYPE		:= OPV( E, 2, 0 );
	N	: SYMBOLS.VALUE_TYPE		:= 8 + QC_LEN( LVL + 1 );				--| FP_IN_RAX + mov x16, sp + QUAD_CONST 16, lvl+1
      begin
	N := N + M_LEN( CTX + 16, 8 ) + M_LEN( CTX + 24, 8 ) + M_LEN( CTX + 32, 8 )
	       + M_LEN( CTX + 40, 8 ) + M_LEN( CTX + 48, 8 );
	for  I in 0 .. INTEGER( LVL )  loop
	  N := N + M_LEN( 8 * SYMBOLS.VALUE_TYPE( I ), 8 ) + M_LEN( CTX + 56 + 8 * SYMBOLS.VALUE_TYPE( I ), 8 );
	end loop;
	return  N;
      end;

    elsif  M = "EXC_RAISE"  then
      return  76 + 2 * M_LEN( OPV( E, 1, 0 ), 8 );							--| 19 acces/mots fixes + boucle (6) ; top lu et ecrit


		-----------------------------------------------------------------------------
--		O P E R A T I O N S	  L O G I Q U E S	D E   B L O C   (LRM 4.5.1) -- lot D3

    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then return  60;				--| 3 POP + cbz + boucle de 8 mots
    elsif  M = "BLKNOT"  then return  44;
    elsif  M = "BLKMOV"  then return  44;								--| 3 POP + 5 mots
    elsif  M = "BLKCMP"  then return  80;
    elsif  M = "LEXCMP"  then
      declare
	SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
      begin
	if  SIZC /= 1  and then  SIZC /= 2  and then  SIZC /= 4  and then  SIZC /= 8  then
	  FAULT( "LEXCMP : taille de composant non supportee" );						--| err du codi
	end if;
	return  124;										--| 4 POP + 21 mots + PUSH, quelle que soit la paire de charges
      end;

				------------------------------
--				SPECIFIQUE  L I N U X   X86-64

    elsif  M = "SYS_CLOCK_GETTIME"  or else  M = "SYS_PUT_CHAR"  then return  24;
    elsif  M = "SYS_PUT_STR"  then return  44;								--| POP_RSI (8) + 9 mots
    elsif  M = "SYS_GET_CHAR"  then return  128;								--| termios : ioctl x3 + read
    elsif  M = "SYS_GET_STR"  then return  60;
    elsif  M = "SYS_FILE_CREATE"  or else  M = "SYS_FILE_OPEN"  then return  92;				--| POP_RSI + COPY_STRING_APPEND_NUL (56) + openat
    elsif  M = "SYS_FILE_SET_POS"  then return  40;
    elsif  M = "SYS_FILE_GET_POS"  then return  32;
    elsif  M = "SYS_FILE_GET_SIZE"  then return  80;
    elsif  M = "SYS_FILE_WRITE"  or else  M = "SYS_FILE_READ"  then return  48;
    elsif  M = "SYS_FILE_CLOSE"  then return  24;
    elsif  M = "SYS_FILE_DELETE"  then return  88;
    elsif  M = "SYS_EXIT"  then
      if  IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP  and then  IR.OP_INT( E, 1 ) /= 0  then
        return  QC_LEN( IR.OP_INT( E, 1 ) ) + 8;
      end if;
      return  12;											--| movz x0, #0 ; movz x8, #93 ; svc

    else
      FAULT( "hors tranche arm64 (C4) : " & M );
      return 0;
    end if;

  end	SIZE_OF;
	-------


			------
  procedure		ENCODE		( E :IR.ELT_ID )
  is			------

    M			: constant STRING		:= LEX.IMAGE( IR.MNEMO_OF( E ) );
    V			: SYMBOLS.VALUE_TYPE;

  begin
    if  M = "DROP"  then
      DD( 16#D10023BD# );										--| sub x29, x29, #8

    elsif  M = "DUP"  then
      DD( 16#F94003A0# );										--| ldr x0, [x29]
      DD( 16#F80083A0# );										--| stur x0, [x29, #8]
      DD( 16#910023BD# );										--| add x29, x29, #8

    elsif  M = "LI"  then
      if  IR.N_OPS( E ) < 1  then
        FAULT( "LI : operande attendu" );
      end if;
      E_QUAD_CONST( 0, OPV( E, 1, 0 ) );								--| litteral, nom ou EXPR (corpus : LI size*8)
      E_PUSH_RAX;

    elsif  M = "ADD"  then
      E_POP_RAX;											--| x0 = B
      DD( 16#F94003A1# );										--| ldr x1, [x29]	x1 = A
      DD( 16#8B000021# );										--| add x1, x1, x0
      DD( 16#F90003A1# );										--| str x1, [x29]

    elsif  M = "SUB"  then
      E_POP_RAX;
      DD( 16#F94003A1# );										--| ldr x1, [x29]
      DD( 16#CB000021# );										--| sub x1, x1, x0
      DD( 16#F90003A1# );										--| str x1, [x29]

    elsif  M = "MUL"  then
      E_POP_RAX;
      DD( 16#F94003A1# );										--| ldr x1, [x29]
      DD( 16#9B007C21# );										--| mul x1, x1, x0
      DD( 16#F90003A1# );										--| str x1, [x29]

    elsif  M = "BRA"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( "BRA : label attendu" );
      end if;
      SYMBOLS.USE_SCOPE( IR.SCOPE_OF( E ) );
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      E_B( V );

    elsif  M = "BEGIN_BLOC_DEF"  then									--| BRA IMAGES.skip (resolution posee a P2B)
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "IMAGES.skip" ) );
      E_B( V );

    elsif  M = "BT"  or else  M = "BF"  then								--| forme longue systematique (pieges 82, 88)
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP  then
        FAULT( M & " : label attendu" );
      end if;
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      E_POP_RAX;
      if  M = "BT"  then
        DD( 16#B4000040# );										--| cbz  x0, +8  (x0 = 0 : enjambe le b)
      else
        DD( 16#B5000040# );										--| cbnz x0, +8  (x0 /= 0 : enjambe le b)
      end if;
      E_B( V );

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
      E_QUAD_ADDR( 0, V );										--| ptr + disp
      E_PUSH_RAX;

    elsif  M = "LSPA"  then
      V := ELAB_TARGET( E );
      E_QUAD_ADDR( 0, V );										--| .elab (forme canonique)
      E_PUSH_RAX;

    elsif  M = "LIF"  then
      if  IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.FLT_OP  then
        FAULT( "LIF : litteral flottant attendu" );
      end if;
      E_QUAD_CONST( 0, DOUBLE_BITS( IR.OP_FLT( E, 1 ) ) );							--| motif IEEE 754 par movz/movk
      E_PUSH_RAX;

    elsif  M = "LVA"  then
      E_BASE( OPV( E, 1, -1 ) );
      E_ADD( OPV( E, 2, 0 ) );
      E_PUSH_RAX;

    elsif  M = "LIVA"  then
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_ADD( OPV( E, 3, 0 ) );
      E_PUSH_RAX;

			-------------------
--			L O A D	D A T A

    elsif  M = "ULB"  then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_UB( OPV( E, 2, 0 ) );  E_PUSH_RAX;
    elsif  M = "ULW"  then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_UW( OPV( E, 2, 0 ) );  E_PUSH_RAX;
    elsif  M = "ULD"  then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_UD( OPV( E, 2, 0 ) );  E_PUSH_RAX;
    elsif  M = "LB"   then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_B( OPV( E, 2, 0 ) );   E_PUSH_RAX;
    elsif  M = "LW"   then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_W( OPV( E, 2, 0 ) );   E_PUSH_RAX;
    elsif  M = "LD"   then  E_BASE( OPV( E, 1, -1 ) );  E_FETCH_D( OPV( E, 2, 0 ) );   E_PUSH_RAX;
    elsif  M = "LQ"  or else  M = "LA"  then								--| LA = LQ (alias du codi)
      E_BASE( OPV( E, 1, -1 ) );  E_FETCH_Q( OPV( E, 2, 0 ) );  E_PUSH_RAX;

    elsif  M = "ULIB"  then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_UB( OPV( E, 3, 0 ) );  E_PUSH_RAX;
    elsif  M = "ULIW"  then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_UW( OPV( E, 3, 0 ) );  E_PUSH_RAX;
    elsif  M = "ULID"  then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_UD( OPV( E, 3, 0 ) );  E_PUSH_RAX;
    elsif  M = "LIB"   then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_B( OPV( E, 3, 0 ) );   E_PUSH_RAX;
    elsif  M = "LIW"   then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_W( OPV( E, 3, 0 ) );   E_PUSH_RAX;
    elsif  M = "LID"   then  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_D( OPV( E, 3, 0 ) );   E_PUSH_RAX;
    elsif  M = "LIQ"  or else  M = "LIA"  then								--| LIA = LIQ (alias du codi)
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_FETCH_Q( OPV( E, 3, 0 ) );  E_PUSH_RAX;

			-------------------
--			S T O R E	D A T A

    elsif  M = "SB"  then  E_POP_RBX;  E_BASE( OPV( E, 1, -1 ) );  E_STORE_B( OPV( E, 2, 0 ) );
    elsif  M = "SW"  then  E_POP_RBX;  E_BASE( OPV( E, 1, -1 ) );  E_STORE_W( OPV( E, 2, 0 ) );
    elsif  M = "SD"  then  E_POP_RBX;  E_BASE( OPV( E, 1, -1 ) );  E_STORE_D( OPV( E, 2, 0 ) );
    elsif  M = "SQ"  or else  M = "SA"  then								--| SA = SQ (alias du codi)
      E_POP_RBX;  E_BASE( OPV( E, 1, -1 ) );  E_STORE_Q( OPV( E, 2, 0 ) );

    elsif  M = "SIB"  then  E_POP_RBX;  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_STORE_B( OPV( E, 3, 0 ) );
    elsif  M = "SIW"  then  E_POP_RBX;  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_STORE_W( OPV( E, 3, 0 ) );
    elsif  M = "SID"  then  E_POP_RBX;  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_STORE_D( OPV( E, 3, 0 ) );
    elsif  M = "SIQ"  or else  M = "SIA"  then								--| SIA = SIQ (alias du codi)
      E_POP_RBX;  E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );  E_STORE_Q( OPV( E, 3, 0 ) );

			-----------
--			F R A M E S

    elsif  M = "LINK"  then
      declare
        LVL	: constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
      begin
        E_LINK( LVL, OPV( E, 2, 0 ) );
      end;

    elsif  M = "ELB"  then										--| LINK lvl, loc_siz
      E_LINK( OPV( E, 1, 0 ), SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "loc_siz" ) ) );

    elsif  M = "UNLINK"  then
      declare
        LVL	: constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
      begin
        E_FP_RBP( LVL );										--| x29 = FP(lvl)
        E_POP_RAX;
        E_RAX_FP( LVL );										--| restaurer le display
        DD( 16#F940035A# );										--| ldr x26, [x26]
      end;

    elsif  M = "UNLINKR"  then
      declare
        LVL	: constant SYMBOLS.VALUE_TYPE		:= OPV( E, 1, 0 );
      begin
        E_FP_RBP( LVL );										--| x29 = FP(lvl)
        E_POP_RAX;
        E_RAX_FP( LVL );										--| restaurer le display
        DD( 16#AA1A03FB# );										--| mox x27, x26
        DD( 16#F940035A# );										--| ldr x26, [x26]
      end;

			-------------------
--			C O M P A R A I S O N

    elsif  M = "CEQ"  then
      E_POP_RBX;											--| x1 = B
      DD( 16#F94003A0# );										--| ldr x0, [x29]	x0 = A
      DD( 16#EB01001F# );										--| cmp x0, x1
      DD( 16#9A9F17E0# );										--| cset x0, eq
      DD( 16#F90003A0# );										--| str x0, [x29]

			-------------------
--			S Y S T E M E

    elsif  M = "SYS_PUT_STR"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F9400480# );										--| ldr x0, [x4, #8]    info
      DD( 16#B9400C02# );										--| ldr w2, [x0, #12]   LST
      DD( 16#91000442# );										--| add x2, x2, #1
      DD( 16#B9400811# );										--| ldr w17, [x0, #8]   FST
      DD( 16#CB110042# );										--| sub x2, x2, x17     longueur
      DD( 16#F9400081# );										--| ldr x1, [x4]        caracteres
      DD( 16#D2800020# );										--| movz x0, #1         stdout
      DD( 16#D2800808# );										--| movz x8, #64        sys_write
      DD( 16#D4000001# );										--| svc #0

			-------------------
--			S T R U C T U R E

    elsif  M = "PRO"  then
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( "post" ) );							--| contournement d'elaboration
      E_B( V );

    elsif  M = "CALL"  then										--| micro-pile de retours par sp (16 par appel)
      V := ELAB_TARGET( E );
      DD( 16#10000090# );										--| adr x16, .+16  (retour = apres le b)
      DD( 16#D10043FF# );										--| sub sp, sp, #16
      DD( 16#F90003F0# );										--| str x16, [sp]
      E_B( V );											--| b .elab (lazy reel)

    elsif  M = "CALLI"  then
      E_POP_RAX;											--| x0 = cible
      DD( 16#10000090# );
      DD( 16#D10043FF# );
      DD( 16#F90003F0# );
      DD( 16#D61F0000# );										--| br x0

    elsif  M = "RTD"  then
      declare
        P		: constant SYMBOLS.VALUE_TYPE := OPV( E, 1, 0 );
      begin
        if  P < 0  then
          FAULT( "RTD : prm_size negatif" );								--| assert du codi
        end if;
        if  P /= 0  then
	if  P <= 4095  then
	  DD( 16#D10003BD# + P * 1024 );								--| sub x29, x29, #prm_size
	elsif  P <= 16777215  and then  P mod 4096 = 0  then
	  DD( 16#D14003BD# + ( P / 4096 ) * 1024 );							--| sub x29, x29, #prm_size, lsl #12
	else
	  E_QUAD_CONST( 17, P );
	  DD( 16#CB1103BD# );									--| sub x29, x29, x17
	end if;
        end if;
        DD( 16#F94003F0# );										--| ldr x16, [sp]
        DD( 16#910043FF# );										--| add sp, sp, #16
        DD( 16#D61F0200# );										--| br x16
      end;

			-------------------
--			C A L C U L

    elsif  M = "NEG"  then
      DD( 16#F94003A0# );  DD( 16#CB0003E0# );  DD( 16#F90003A0# );						--| ldr ; neg x0, x0 ; str
    elsif  M = "INC"  then
      DD( 16#F94003A0# );  DD( 16#91000400# );  DD( 16#F90003A0# );						--| ldr ; add x0, x0, #1 ; str
    elsif  M = "DEC"  then
      DD( 16#F94003A0# );  DD( 16#D1000400# );  DD( 16#F90003A0# );						--| ldr ; sub x0, x0, #1 ; str
    elsif  M = "FNEG"  then
      DD( 16#FD4003A0# );  DD( 16#1E614000# );  DD( 16#FD0003A0# );						--| ldr d0 ; fneg d0, d0 ; str d0
    elsif  M = "CLAMP0"  then
      DD( 16#F94003A0# );  DD( 16#F100001F# );  DD( 16#9A9FA000# );  DD( 16#F90003A0# );				--| ldr ; cmp x0, #0 ; csel x0, x0, xzr, ge ; str
    elsif  M = "SHL"  then
      E_POP_RCX;											--| x2 = positions
      DD( 16#F94003A0# );  DD( 16#9AC22000# );  DD( 16#F90003A0# );						--| ldr ; lslv x0, x0, x2 ; str
    elsif  M = "OUX"  then
      E_POP_RAX;
      DD( 16#F94003A1# );  DD( 16#CA000021# );  DD( 16#F90003A1# );						--| ldr x1 ; eor x1, x1, x0 ; str x1
    elsif  M = "DIV"  then
      E_POP_RBX;											--| x1 = B
      E_POP_RAX;											--| x0 = A
      DD( 16#9AC10C00# );										--| sdiv x0, x0, x1
      E_PUSH_RAX;
    elsif  M = "REMI"  then
      E_POP_RBX;
      E_POP_RAX;
      DD( 16#9AC10C02# );										--| sdiv x2, x0, x1
      DD( 16#9B018040# );										--| msub x0, x2, x1, x0
      E_PUSH_RAX;
    elsif  M = "CVTIX"  then										--| I * DENOM / NUMER sur 128 bits
      E_POP_RBX;											--| x1 = NUMER
      E_POP_RCX;											--| x2 = DENOM
      E_POP_RAX;											--| x0 = I
      DD( 16#9B427C03# );										--| smulh x3, x0, x2
      DD( 16#9B027C00# );										--| mul   x0, x0, x2
      E_SDIV128;											--| x0 = quotient, x3 = reste
      E_PUSH_RAX;

			-----------------------
--			C O M P A R A I S O N S

    elsif  M = "CGT"  or else  M = "CLT"  or else  M = "CLE"  or else  M = "CNE"  or else  M = "CGE"  then
      E_POP_RBX;											--| x1 = B
      DD( 16#F94003A0# );										--| ldr x0, [x29]	x0 = A
      DD( 16#EB01001F# );										--| cmp x0, x1
      if  M = "CGT"  then  DD( 16#9A9FD7E0# );								--| cset x0, gt
      elsif  M = "CLT"  then  DD( 16#9A9FA7E0# );								--| cset x0, lt
      elsif  M = "CLE"  then  DD( 16#9A9FC7E0# );								--| cset x0, le
      elsif  M = "CNE"  then  DD( 16#9A9F07E0# );								--| cset x0, ne
      else  DD( 16#9A9FB7E0# );									--| cset x0, ge
      end if;
      DD( 16#F90003A0# );										--| str x0, [x29]

			---------
--			B L O C S

    elsif  M = "BLKMOV"  then
      E_POP_RSI;											--| x4 = source
      E_POP_RCX;											--| x2 = nombre d'octets
      E_POP_RDI;											--| x5 = destination
      DD( 16#B40000A2# );										--| cbz x2, +20
      DD( 16#38401490# );										--| ldrb w16, [x4], #1
      DD( 16#380014B0# );										--| strb w16, [x5], #1
      DD( 16#D1000442# );										--| sub x2, x2, #1
      DD( 16#B5FFFFA2# );										--| cbnz x2, -12
    elsif  M = "CO_VAR"  then
      E_POP_RAX;											--| x0 = taille
      DD( 16#F80083BB# );										--| stur x27, [x29, #8]
      DD( 16#910023BD# );										--| add x29, x29, #8
      DD( 16#91001C00# );										--| add x0, x0, #7
      DD( 16#9343FC00# );										--| asr x0, x0, #3
      DD( 16#8B000F7B# );										--| add x27, x27, x0, lsl #3

			-------------------
--			E X C E P T I O N S

    elsif  M = "EXC_MACH"  then									--| photographie de l'etat machine a [FP(lvl) + ctx]
      declare
        LVL	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 0 );
        CTX	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
      begin
        if  LVL < 0  or else  LVL > 31  then
	FAULT( "EXC_MACH : lvl hors 0..31 (assert du codi)" );
        end if;
        E_FPA( LVL );										--| x0 := FP(lvl)
        E_SQ( CTX + 16, 0, 29 );									--| pile de travail
        DD( 16#910003F0# );										--| mov x16, sp
        E_SQ( CTX + 24, 0, 16 );									--| micro-pile de retours
        E_SQ( CTX + 32, 0, 26 );									--| frame co-pile
        E_SQ( CTX + 40, 0, 27 );									--| sommet co-pile
        E_QUAD_CONST( 16, LVL + 1 );
        E_SQ( CTX + 48, 0, 16 );									--| nlvl
        for  I in 0 .. INTEGER( LVL )  loop								--| prefixe du display FP(0..lvl)
	E_LQ( 8 * SYMBOLS.VALUE_TYPE( I ), 28, 16 );
	E_SQ( CTX + 56 + 8 * SYMBOLS.VALUE_TYPE( I ), 0, 16 );
        end loop;
      end;

    elsif  M = "EXC_RAISE"  then									--| deroulage : POP avant dispatch
      declare
        TOPD	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 0 );
      begin
        E_LQ( 0, 28, 1 );										--| x1 := FP(0)
        E_LQ( TOPD, 1, 0 );										--| x0 := contexte sommet
        DD( 16#AA0003E3# );										--| mov x3, x0
        E_LQ( 0, 3, 2 );										--| x2 := PREV_CTX
        E_SQ( TOPD, 1, 2 );										--| POP avant dispatch
        E_LQ( 32, 3, 26 );										--| frame co-pile
        E_LQ( 40, 3, 27 );										--| sommet co-pile
        E_LQ( 24, 3, 16 );
        DD( 16#9100021F# );										--| mov sp, x16
        E_LQ( 48, 3, 2 );										--| x2 := NXT_LVL
        DD( 16#9100E064# );										--| add x4, x3, #56
        DD( 16#AA1C03E5# );										--| mov x5, x28
        DD( 16#F9400090# );										--| boucle: ldr x16, [x4]
        DD( 16#F90000B0# );										--| str x16, [x5]
        DD( 16#91002084# );										--| add x4, x4, #8
        DD( 16#910020A5# );										--| add x5, x5, #8
        DD( 16#D1000442# );										--| sub x2, x2, #1
        DD( 16#B5FFFF62# );										--| cbnz x2, boucle (-20)
        E_LQ( 16, 3, 29 );										--| pile de travail
        E_LQ( 8, 3, 16 );										--| DISPATCH
        DD( 16#D61F0200# );										--| br x16
      end;


			-------------------
--			L O G I Q U E ,   C H A M P S   D E   B I T S

    elsif  M = "ET"  then
      DD( 16#F94003A0# );										--| POP_RAX : ldr x0, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A1# );										--| ldr x1, [x29]	x1 = A
      DD( 16#8A000021# );										--| and x1, x1, x0	x1 = A and B
      DD( 16#F90003A1# );										--| str x1, [x29]

    elsif  M = "OU"  then
      DD( 16#F94003A0# );										--| POP_RAX : ldr x0, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A1# );										--| ldr x1, [x29]
      DD( 16#AA000021# );										--| orr x1, x1, x0
      DD( 16#F90003A1# );										--| str x1, [x29]

    elsif  M = "NON"  then
      DD( 16#F94003A0# );										--| ldr x0, [x29]
      DD( 16#AA2003E0# );										--| mvn x0, x0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SHR"  then
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| ldr x0, [x29]
      DD( 16#9AC22400# );										--| lsrv x0, x0, x2
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SAR"  then
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| ldr x0, [x29]
      DD( 16#9AC22800# );										--| asrv x0, x0, x2
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "UBFX"  then
      DD( 16#F94003A3# );										--| POP_RDX : ldr x3, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| ldr x0, [x29]	valeur source
      DD( 16#9AC22400# );										--| lsrv x0, x0, x2	x0 := valeur >> LSB
      DD( 16#D2800021# );										--| movz x1, #1
      DD( 16#9AC32021# );										--| lslv x1, x1, x3	x1 = 1 << Width
      DD( 16#D1000421# );										--| sub x1, x1, #1	x1 = mask
      DD( 16#8A010000# );										--| and x0, x0, x1	x0 = field non signe
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SBFX"  then
      DD( 16#F94003A3# );										--| POP_RDX : ldr x3, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| ldr x0, [x29]	valeur source
      DD( 16#9AC22400# );										--| lsrv x0, x0, x2	x0 := valeur >> LSB
      DD( 16#D2800802# );										--| movz x2, #64
      DD( 16#CB030042# );										--| sub x2, x2, x3	x2 = 64 - Width
      DD( 16#9AC22000# );										--| lslv x0, x0, x2	signe du champ en bit 63
      DD( 16#9AC22800# );										--| asrv x0, x0, x2	extension de signe
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "BFI"  then
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A3# );										--| POP_RDX : ldr x3, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| POP_RAX : ldr x0, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#D2800021# );										--| movz x1, #1
      DD( 16#9AC22021# );										--| lslv x1, x1, x2	1 << Width
      DD( 16#D1000421# );										--| sub x1, x1, #1	mask = (1 << Width) - 1
      DD( 16#8A010000# );										--| and x0, x0, x1	inserted &= mask
      DD( 16#9AC32000# );										--| lslv x0, x0, x3	inserted <<= LSB
      DD( 16#9AC32021# );										--| lslv x1, x1, x3	mask <<= LSB
      DD( 16#AA2103E1# );										--| mvn x1, x1		~shifted_mask
      DD( 16#F94003B0# );										--| ldr x16, [x29]	old_quad
      DD( 16#8A010210# );										--| and x16, x16, x1	clear field in old_quad
      DD( 16#AA000210# );										--| orr x16, x16, x0	insert field
      DD( 16#F90003B0# );										--| str x16, [x29]

    elsif  M = "ABS"  then
      DD( 16#F94003A0# );										--| ldr x0, [x29]
      DD( 16#F100001F# );										--| cmp x0, #0   (alias de subs xzr, x0, #0)
      DD( 16#DA805400# );										--| cneg x0, x0, mi  (mi = N=1 = negatif)
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "MODI"  then
      DD( 16#F94003A1# );										--| POP_RBX : ldr x1, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A0# );										--| POP_RAX : ldr x0, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#9AC10C02# );										--| sdiv x2, x0, x1     (quotient dans x2)
      DD( 16#9B018040# );										--| msub x0, x2, x1, x0 (reste dans x0)
      DD( 16#B4000080# );										--| cbz x0, .end (saut +16 octets = 4 instr)
      DD( 16#CA010002# );										--| eor x2, x0, x1
      DD( 16#B6F80042# );										--| tbz x2, #63, .end (saut +8 octets = 2 instr)
      DD( 16#8B010000# );										--| add x0, x0, x1
      DD( 16#F80083A0# );										--| PUSH_RAX : stur x0, [x29, #8]
      DD( 16#910023BD# );										--|            add x29, x29, #8

			-------------------
--			F L O T T A N T

    elsif  M = "FADD"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]	(B = TOS dans d1)
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]	(A = nouveau TOS dans d0)
      DD( 16#1E612800# );										--| fadd d0, d0, d1	(d0 = A + B)
      DD( 16#FD0003A0# );										--| str d0, [x29]	(ecraser A par le resultat)

    elsif  M = "FSUB"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E613800# );										--| fsub d0, d0, d1	(d0 = A - B)
      DD( 16#FD0003A0# );										--| str d0, [x29]

    elsif  M = "FMUL"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E610800# );										--| fmul d0, d0, d1	(d0 = A * B)
      DD( 16#FD0003A0# );										--| str d0, [x29]

    elsif  M = "FDIV"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]	(B = diviseur)
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]	(A = dividende)
      DD( 16#1E611800# );										--| fdiv d0, d0, d1	(d0 = A / B)
      DD( 16#FD0003A0# );										--| str d0, [x29]

    elsif  M = "FABS"  then
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E60C000# );										--| fabs d0, d0
      DD( 16#FD0003A0# );										--| str d0, [x29]

    elsif  M = "FEXP"  then
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]	(d0 = base)
      DD( 16#D2E7FE00# );										--| movz x0, #0x3FF0, lsl #48  (1.0)
      DD( 16#9E670001# );										--| fmov d1, x0	(d1 = 1.0 accumulateur)
      DD( 16#B4000082# );										--| cbz x2, .end (+16)(si N=0, resultat = 1.0, sauter +16 octets = 3 instr)
      DD( 16#1E600821# );										--| fmul d1, d1, d0	(accum *= base)
      DD( 16#D1000442# );										--| sub x2, x2, #1
      DD( 16#B5FFFFC2# );										--| cbnz x2, .loop	(saut -8 octets = -2 instr)
      DD( 16#FD0003A1# );										--| str d1, [x29]	(ecraser TOS par le resultat)

    elsif  M = "CVTIF"  then
      DD( 16#F94003A0# );										--| ldr x0, [x29]		(entier signe depuis la pile)
      DD( 16#9E620000# );										--| scvtf d0, x0		(convertir entier -> double)
      DD( 16#FD0003A0# );										--| str d0, [x29]		(ecraser l'entier par le double)

    elsif  M = "CVTFI"  then
      DD( 16#FD4003A0# );										--| ldr d0, [x29]		(double depuis la pile dans d0)
      DD( 16#9E780000# );										--| fcvtzs x0, d0		(convertir double -> entier avec troncature ; ftype=01 double, 0x9EF8.... etait h0)
      DD( 16#F90003A0# );										--| str x0, [x29]		(ecraser le double par l'entier)

    elsif  M = "CVTFIR"  then
      DD( 16#FD4003A0# );										--| ldr d0, [x29]		(double depuis la pile dans d0)
      DD( 16#9E600000# );										--| fcvtns x0, d0		nearest, ties-to-even (identique x86-64)
      DD( 16#F90003A0# );										--| str x0, [x29]		(ecraser le double par l'entier)

    elsif  M = "CVTXI"  then										--| X * NUMER / DENOM, arrondi au plus proche
      E_POP_RBX;											--| x1 = DENOM
      E_POP_RCX;											--| x2 = NUMER
      E_POP_RAX;											--| x0 = X
      DD( 16#9B427C03# );										--| smulh x3, x0, x2
      DD( 16#9B027C00# );										--| mul   x0, x0, x2
      E_SDIV128;											--| x0 = quotient, x3 = reste
      DD( 16#937FFC64# );										--| asr x4, x3, #63
      DD( 16#CA040063# );										--| eor x3, x3, x4
      DD( 16#CB040063# );										--| sub x3, x3, x4   abs(reste)
      DD( 16#91000421# );										--| add x1, x1, #1
      DD( 16#D341FC21# );										--| lsr x1, x1, #1   ceil(DENOM/2)
      DD( 16#EB01007F# );										--| cmp x3, x1
      DD( 16#54000063# );										--| b.lo no_round (+3)
      DD( 16#B2400084# );										--| orr x4, x4, #1
      DD( 16#8B040000# );										--| add x0, x0, x4
      E_PUSH_RAX;

    elsif  M = "FCEQ"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]	(B = TOS)
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]	(A)
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9F17E0# );										--| cset x0, eq
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "FCNE"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9F07E0# );										--| cset x0, ne
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "FCGT"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9FD7E0# );										--| cset x0, gt
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "FCGE"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9FB7E0# );										--| cset x0, ge
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "FCLT"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9F57E0# );										--| cset x0, mi  (= less than en flottant)
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "FCLE"  then
      DD( 16#FD4003A1# );										--| ldr d1, [x29]
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8
      DD( 16#FD4003A0# );										--| ldr d0, [x29]
      DD( 16#1E612000# );										--| fcmp d0, d1
      DD( 16#9A9F87E0# );										--| cset x0, ls  (= lower or same en flottant)
      DD( 16#F90003A0# );										--| str x0, [x29]

			-------------------
--			T A S ,   B L O C S

    elsif  M = "HEAP_ALLOC"  then
      DD( 16#F94003A0# );										--| POP_RAX : ldr x0, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#91001C00# );										--| add x0, x0, #7
      DD( 16#D343FC00# );										--| lsr x0, x0, #3
      DD( 16#D37DF000# );										--| lsl x0, x0, #3
      DD( 16#CB000339# );										--| sub x25, x25, x0
      DD( 16#AA1903E0# );										--| mov x0, x25
      DD( 16#F80083A0# );										--| PUSH_RAX : stur x0, [x29, #8]
      DD( 16#910023BD# );										--|            add x29, x29, #8

    elsif  M = "BLKAND"  or else  M = "BLKOU"  or else  M = "BLKOUX"  then					--| [DST] op= [SRC] octet a octet
      E_POP_RSI;											--| x4 = @SRC
      E_POP_RCX;											--| x2 = LEN
      E_POP_RDI;											--| x5 = @DST
      DD( 16#B4000122# );										--| cbz x2, fin (+9)
      DD( 16#39400090# );										--| boucle: ldrb w16, [x4]
      DD( 16#394000B1# );										--| ldrb w17, [x5]
      if  M = "BLKAND"  then  DD( 16#0A100231# );								--| and w17, w17, w16
      elsif  M = "BLKOU"  then  DD( 16#2A100231# );							--| orr w17, w17, w16
      else  DD( 16#4A100231# );									--| eor w17, w17, w16
      end if;
      DD( 16#390000B1# );										--| strb w17, [x5]
      DD( 16#91000484# );										--| add x4, x4, #1
      DD( 16#910004A5# );										--| add x5, x5, #1
      DD( 16#D1000442# );										--| sub x2, x2, #1
      DD( 16#B5FFFF22# );										--| cbnz x2, boucle (-7)

    elsif  M = "BLKNOT"  then
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#B40000E2# );										--|   [+7]
      DD( 16#394000B0# );										--| ldrb w16, [x5]
      DD( 16#52000210# );										--| eor w16, w16, #1
      DD( 16#390000B0# );										--| strb w16, [x5]
      DD( 16#910004A5# );										--| add x5, x5, #1
      DD( 16#D1000442# );										--| sub x2, x2, #1
      DD( 16#B5FFFF62# );										--|   [-5]

    elsif  M = "BLKCMP"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A2# );										--| POP_RCX : ldr x2, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#D2800020# );										--| mov x0, #1 (LEN=0 => egal)
      DD( 16#B4000162# );										--|   [+11]
      DD( 16#39400090# );										--| ldrb w16, [x4]
      DD( 16#394000B1# );										--| ldrb w17, [x5]
      DD( 16#6B11021F# );										--| cmp w16, w17
      DD( 16#540000C1# );										--| b.ne different  [+6]
      DD( 16#91000484# );										--| add x4, x4, #1
      DD( 16#910004A5# );										--| add x5, x5, #1
      DD( 16#D1000442# );										--| sub x2, x2, #1
      DD( 16#B5FFFF22# );										--|   [-7]
      DD( 16#14000002# );										--| b fin  [+2]
      DD( 16#D2800000# );										--| mov x0, #0
      DD( 16#F80083A0# );										--| PUSH_RAX : stur x0, [x29, #8]
      DD( 16#910023BD# );										--|            add x29, x29, #8

    elsif  M = "LEXCMP"  then										--| comparaison lexicographique (LRM 4.5.2) : -1 / 0 / +1
      declare
        SIZC	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 1, 8 );
        SGN	:constant SYMBOLS.VALUE_TYPE	:= OPV( E, 2, 0 );
      begin
        E_POP_RDX;											--| x3 = LEN_D
        E_POP_RSI;											--| x4 = @D
        E_POP_RCX;											--| x2 = LEN_G
        E_POP_RDI;											--| x5 = @G
        DD( 16#B4000162# );										--| boucle: cbz x2, epuise (+11)
        DD( 16#B4000143# );										--| cbz x3, epuise (+10)
        if  SIZC = 1  then
	if  SGN = 1  then  DD( 16#398000A0# );  DD( 16#39800081# );						--| ldrsb x0, [x5] ; ldrsb x1, [x4]
	else  DD( 16#394000A0# );  DD( 16#39400081# );							--| ldrb w0 ; ldrb w1
	end if;
        elsif  SIZC = 2  then
	if  SGN = 1  then  DD( 16#798000A0# );  DD( 16#79800081# );						--| ldrsh x0 ; ldrsh x1
	else  DD( 16#794000A0# );  DD( 16#79400081# );							--| ldrh w0 ; ldrh w1
	end if;
        elsif  SIZC = 4  then
	if  SGN = 1  then  DD( 16#B98000A0# );  DD( 16#B9800081# );						--| ldrsw x0 ; ldrsw x1
	else  DD( 16#B94000A0# );  DD( 16#B9400081# );							--| ldr w0 ; ldr w1
	end if;
        elsif  SIZC = 8  then
	DD( 16#F94000A0# );  DD( 16#F9400081# );							--| ldr x0 ; ldr x1
        else
	FAULT( "LEXCMP : taille de composant non supportee" );
        end if;
        DD( 16#EB01001F# );										--| cmp x0, x1
        DD( 16#54000161# );										--| b.ne differe (+11)
        DD( 16#910000A5# + SIZC * 1024 );								--| add x5, x5, #siz
        DD( 16#91000084# + SIZC * 1024 );								--| add x4, x4, #siz
        DD( 16#D1000042# + SIZC * 1024 );								--| sub x2, x2, #siz
        DD( 16#D1000063# + SIZC * 1024 );								--| sub x3, x3, #siz
        DD( 16#17FFFFF6# );										--| b boucle (-10)
        DD( 16#EB030042# );										--| epuise: subs x2, x2, x3
        DD( 16#540000C0# );										--| b.eq egal (+6)
        DD( 16#540000EB# );										--| b.lt moins (+7)
        DD( 16#D2800020# );										--| plus: mov x0, #1
        DD( 16#14000006# );										--| b empile (+6)
        DD( 16#5400008B# );										--| differe: b.lt moins (+4)
        DD( 16#17FFFFFD# );										--| b plus (-3)
        DD( 16#D2800000# );										--| egal: mov x0, #0
        DD( 16#14000002# );										--| b empile (+2)
        DD( 16#92800000# );										--| moins: mov x0, #-1
        E_PUSH_RAX;											--| empile:
      end;

			-------------------
--			S Y S T E M E

    elsif  M = "SYS_CLOCK_GETTIME"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0403E1# );										--| mov x1, x4		(arg2 = buffer)
      DD( 16#D2800000# );										--| movz x0, #0		(arg1 = CLOCK_REALTIME)
      DD( 16#D2800E28# );										--| movz x8, #113		(sys_clock_gettime)
      DD( 16#D4000001# );										--| svc #0

    elsif  M = "SYS_PUT_CHAR"  then
      DD( 16#AA1D03E1# );										--| mov x1, x29		(adresse du caractere = sommet de pile)
      DD( 16#D2800020# );										--| movz x0, #1		(fd = stdout)
      DD( 16#D2800022# );										--| movz x2, #1		(count = 1)
      DD( 16#D2800808# );										--| movz x8, #64		(sys_write)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#D10023BD# );										--| DROP : sub x29, x29, #8

    elsif  M = "SYS_GET_CHAR"  then
      DD( 16#D10103FF# );										--| sub sp, sp, #64
      DD( 16#D2800000# );										--| movz x0, #0		(fd = stdin)
      DD( 16#D28A8021# );										--| movz x1, #0x5401	(TCGETS)
      DD( 16#910003E2# );										--| add x2, sp, #0	(adresse du termios temporaire = sp)
      DD( 16#D28003A8# );										--| movz x8, #29		(sys_ioctl)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#B9400FE0# );										--| ldr w0, [sp, #12]	(charger c_lflag)
      DD( 16#12800151# );										--| movn w17, #0xA	(w17 = 0xFFFFFFF5)
      DD( 16#0A110000# );										--| and w0, w0, w17	(masquer ICANON et ECHO)
      DD( 16#B9000FE0# );										--| str w0, [sp, #12]	(remettre c_lflag)
      DD( 16#D2800000# );										--| movz x0, #0		(fd = stdin)
      DD( 16#D28A8041# );										--| movz x1, #0x5402	(TCSETS)
      DD( 16#910003E2# );										--| add x2, sp, #0
      DD( 16#D28003A8# );										--| movz x8, #29		(sys_ioctl)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E1# );										--| mov x1, x5		(buf)
      DD( 16#D2800000# );										--| movz x0, #0		(fd = stdin)
      DD( 16#D2800022# );										--| movz x2, #1		(count = 1)
      DD( 16#D28007E8# );										--| movz x8, #63		(sys_read)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#B9400FE0# );										--| ldr w0, [sp, #12]
      DD( 16#52800151# );										--| movz w17, #0xA
      DD( 16#2A110000# );										--| orr w0, w0, w17	(remettre ICANON et ECHO)
      DD( 16#B9000FE0# );										--| str w0, [sp, #12]
      DD( 16#D2800000# );										--| movz x0, #0
      DD( 16#D28A8041# );										--| movz x1, #0x5402
      DD( 16#910003E2# );										--| add x2, sp, #0
      DD( 16#D28003A8# );										--| movz x8, #29
      DD( 16#D4000001# );										--| svc #0
      DD( 16#910103FF# );										--| add sp, sp, #64

    elsif  M = "SYS_GET_STR"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F9400480# );										--| ldr x0, [x4, #8]
      DD( 16#B9400C02# );										--| ldr w2, [x0, #12]   (w2 = LST)
      DD( 16#91000442# );										--| add x2, x2, #1
      DD( 16#B9400811# );										--| ldr w17, [x0, #8]   (w17 = FST)
      DD( 16#CB110042# );										--| sub x2, x2, x17     (x2 = count)
      DD( 16#F9400081# );										--| ldr x1, [x4]
      DD( 16#D2800000# );										--| movz x0, #0         (fd = stdin)
      DD( 16#D28007E8# );										--| movz x8, #63        (sys_read)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#D1000400# );										--| sub x0, x0, #1
      DD( 16#B9000080# );										--| str w0, [x4]

    elsif  M = "SYS_FILE_CREATE"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F9400480# );										--| CSAN: ldr x0, [x4, #8]	(adresse info)
      DD( 16#B9400C02# );										--| CSAN: ldr w2, [x0, #12]	(LST)
      DD( 16#91000442# );										--| CSAN: add x2, x2, #1
      DD( 16#B9400811# );										--| CSAN: ldr w17, [x0, #8]	(FST)
      DD( 16#CB110042# );										--| CSAN: sub x2, x2, x17	(count)
      DD( 16#F9400084# );										--| CSAN: ldr x4, [x4]		(adresse caracteres source)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(destination)
      DD( 16#B40000A2# );										--| CSAN: cbz x2, .end (saut +20 octets = 5 instr) - cas pathologique chaine vide
      DD( 16#38401490# );										--| CSAN: ldrb w16, [x4], #1
      DD( 16#380014B0# );										--| CSAN: strb w16, [x5], #1
      DD( 16#D1000442# );										--| CSAN: sub x2, x2, #1
      DD( 16#B5FFFFA2# );										--| CSAN: cbnz x2, .loop (saut -12 octets)
      DD( 16#390000BF# );										--| CSAN: strb wzr, [x5]	(NUL final)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(remettre x5 au debut de la copie)
      DD( 16#92800C60# );										--| movn x0, #99	(x0 = AT_FDCWD = -100)
      DD( 16#AA0503E1# );										--| mov x1, x5	(path)
      DD( 16#D2804842# );										--| movz x2, #0x242	(O_CREAT | O_RDWR | O_TRUNC)
      DD( 16#D2803803# );										--| movz x3, #0x1C0	(mode = 0700)
      DD( 16#D2800708# );										--| movz x8, #56	(sys_openat)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]	(ATTENTION PAS PUSH ! ID rendu sur le lieu result de la fonction)

    elsif  M = "SYS_FILE_OPEN"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F9400480# );										--| CSAN: ldr x0, [x4, #8]	(adresse info)
      DD( 16#B9400C02# );										--| CSAN: ldr w2, [x0, #12]	(LST)
      DD( 16#91000442# );										--| CSAN: add x2, x2, #1
      DD( 16#B9400811# );										--| CSAN: ldr w17, [x0, #8]	(FST)
      DD( 16#CB110042# );										--| CSAN: sub x2, x2, x17	(count)
      DD( 16#F9400084# );										--| CSAN: ldr x4, [x4]		(adresse caracteres source)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(destination)
      DD( 16#B40000A2# );										--| CSAN: cbz x2, .end (saut +20 octets = 5 instr) - cas pathologique chaine vide
      DD( 16#38401490# );										--| CSAN: ldrb w16, [x4], #1
      DD( 16#380014B0# );										--| CSAN: strb w16, [x5], #1
      DD( 16#D1000442# );										--| CSAN: sub x2, x2, #1
      DD( 16#B5FFFFA2# );										--| CSAN: cbnz x2, .loop (saut -12 octets)
      DD( 16#390000BF# );										--| CSAN: strb wzr, [x5]	(NUL final)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(remettre x5 au debut de la copie)
      DD( 16#92800C60# );										--| movn x0, #99	(AT_FDCWD)
      DD( 16#AA0503E1# );										--| mov x1, x5
      DD( 16#D2800042# );										--| movz x2, #2	(O_RDWR)
      DD( 16#D2800003# );										--| movz x3, #0	(mode = 0)
      DD( 16#D2800708# );										--| movz x8, #56	(sys_openat)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_SET_POS"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5	(fd)
      DD( 16#AA0403E1# );										--| mov x1, x4	(offset)
      DD( 16#D2800002# );										--| movz x2, #0	(SEEK_SET)
      DD( 16#D28007C8# );										--| movz x8, #62	(sys_lseek)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_GET_POS"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#D2800001# );										--| movz x1, #0	(offset = 0)
      DD( 16#D2800022# );										--| movz x2, #1	(SEEK_CUR)
      DD( 16#D28007C8# );										--| movz x8, #62
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_GET_SIZE"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#D2800001# );										--| movz x1, #0
      DD( 16#D2800022# );										--| movz x2, #1	(SEEK_CUR)
      DD( 16#D28007C8# );										--| movz x8, #62
      DD( 16#D4000001# );										--| svc #0
      DD( 16#AA0003E6# );										--| mov x6, x0	(x6 = position courante a restaurer)
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#D2800001# );										--| movz x1, #0
      DD( 16#D2800042# );										--| movz x2, #2	(SEEK_END)
      DD( 16#D28007C8# );										--| movz x8, #62
      DD( 16#D4000001# );										--| svc #0
      DD( 16#AA0003E7# );										--| mov x7, x0	(x7 = taille du fichier)
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#AA0603E1# );										--| mov x1, x6
      DD( 16#D2800002# );										--| movz x2, #0	(SEEK_SET)
      DD( 16#D28007C8# );										--| movz x8, #62
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A7# );										--| str x7, [x29]

    elsif  M = "SYS_FILE_WRITE"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A3# );										--| POP_RDX : ldr x3, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5	(fd)
      DD( 16#AA0403E1# );										--| mov x1, x4	(buf)
      DD( 16#AA0303E2# );										--| mov x2, x3	(count)
      DD( 16#D2800808# );										--| movz x8, #64	(sys_write)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_READ"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F94003A3# );										--| POP_RDX : ldr x3, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#AA0403E1# );										--| mov x1, x4
      DD( 16#AA0303E2# );										--| mov x2, x3
      DD( 16#D28007E8# );										--| movz x8, #63	(sys_read)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_CLOSE"  then
      DD( 16#F94003A5# );										--| POP_RDI : ldr x5, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#AA0503E0# );										--| mov x0, x5
      DD( 16#D2800728# );										--| movz x8, #57	(sys_close)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_FILE_DELETE"  then
      DD( 16#F94003A4# );										--| POP_RSI : ldr x4, [x29]
      DD( 16#D10023BD# );										--|           sub x29, x29, #8
      DD( 16#F9400480# );										--| CSAN: ldr x0, [x4, #8]	(adresse info)
      DD( 16#B9400C02# );										--| CSAN: ldr w2, [x0, #12]	(LST)
      DD( 16#91000442# );										--| CSAN: add x2, x2, #1
      DD( 16#B9400811# );										--| CSAN: ldr w17, [x0, #8]	(FST)
      DD( 16#CB110042# );										--| CSAN: sub x2, x2, x17	(count)
      DD( 16#F9400084# );										--| CSAN: ldr x4, [x4]		(adresse caracteres source)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(destination)
      DD( 16#B40000A2# );										--| CSAN: cbz x2, .end (saut +20 octets = 5 instr) - cas pathologique chaine vide
      DD( 16#38401490# );										--| CSAN: ldrb w16, [x4], #1
      DD( 16#380014B0# );										--| CSAN: strb w16, [x5], #1
      DD( 16#D1000442# );										--| CSAN: sub x2, x2, #1
      DD( 16#B5FFFFA2# );										--| CSAN: cbnz x2, .loop (saut -12 octets)
      DD( 16#390000BF# );										--| CSAN: strb wzr, [x5]	(NUL final)
      DD( 16#910023A5# );										--| CSAN: add x5, x29, #8	(remettre x5 au debut de la copie)
      DD( 16#92800C60# );										--| movn x0, #99	(AT_FDCWD)
      DD( 16#AA0503E1# );										--| mov x1, x5	(path)
      DD( 16#D2800002# );										--| movz x2, #0	(flag)
      DD( 16#D2800468# );										--| movz x8, #35	(sys_unlinkat)
      DD( 16#D4000001# );										--| svc #0
      DD( 16#F90003A0# );										--| str x0, [x29]

    elsif  M = "SYS_EXIT"  then
      if  IR.N_OPS( E ) >= 1  and then  IR.OP_TAG( E, 1 ) = IR.INT_OP  and then  IR.OP_INT( E, 1 ) /= 0  then
        E_QUAD_CONST( 0, IR.OP_INT( E, 1 ) );								--| x0 = code
      else
        DD( 16#D2800000# );										--| movz x0, #0
      end if;
      DD( 16#D2800BA8# );										--| movz x8, #93 (sys_exit)
      DD( 16#D4000001# );										--| svc #0

    else
      FAULT( "hors tranche arm64 (C4) : " & M );
    end if;

  end	ENCODE;
	------


			--------
  procedure		PROLOGUE
  is			--------

    T0			: constant INTEGER := TOP;
    COPILE_BASE		: constant SYMBOLS.VALUE_TYPE
			:= ENTRY_PT + 8 * ( ( ASM + 7 ) / 8 );						--| co_pile_start du codi
  begin
    --  tas : mmap anonyme 64 Mo (x8 = 222)
    DD( 16#D2800000# );										--| mov x0, #0
    DD( 16#D2800801# );										--| mov x1, #64
    DD( 16#D36CAC21# );										--| lsl x1, x1, #20 = 64 MiB
    DD( 16#D2800062# );										--| mov x2, #3   PROT_READ|PROT_WRITE
    DD( 16#D2800443# );										--| mov x3, #0x22 MAP_PRIVATE|MAP_ANONYMOUS
    DD( 16#92800004# );										--| mov x4, #-1
    DD( 16#D2800005# );										--| mov x5, #0
    DD( 16#D2801BC8# );										--| mov x8, #222  sys_mmap
    DD( 16#D4000001# );										--| svc #0
    DD( 16#D2A08010# );										--| movz x16, #0x400, lsl #16 = 64 MiB
    DD( 16#8B100019# );										--| add x25, x0, x16  haut du tas
    --  pile montante + display
    DD( 16#D2A00810# );										--| movz x16, #0x40, lsl #16 = 4 MiB
    DD( 16#CB3063FF# );										--| sub sp, sp, x16
    DD( 16#910003FC# );										--| mov x28, sp
    DD( 16#9104039D# );										--| add x29, x28, #256
    DD( 16#F900039D# );										--| str x29, [x28]  FP(0)
    --  co-pile : x27 = ENTRY + 8*((ASM_SIZE+7)/8), quatre mots (taille FIXE)
    DD( 16#D2800000# + CHUNK( COPILE_BASE, 0 ) * 32 + 27 );							--| movz x27, #imm0
    DD( 16#F2A00000# + CHUNK( COPILE_BASE, 1 ) * 32 + 27 );							--| movk x27, #imm1, lsl #16
    DD( 16#F2C00000# + CHUNK( COPILE_BASE, 2 ) * 32 + 27 );							--| movk x27, #imm2, lsl #32
    DD( 16#F2E00000# + CHUNK( COPILE_BASE, 3 ) * 32 + 27 );							--| movk x27, #imm3, lsl #48
    DD( 16#F900037B# );										--| str x27, [x27]  premier frame
    DD( 16#AA1B03FA# );										--| mov x26, x27
    DD( 16#9100237B# );										--| add x27, x27, #8
    if  TOP - T0 /= TRAITS.PROLOGUE_SIZE  then
      FAULT( "amorcage arm64 : longueur inattendue" );
    end if;

  end	PROLOGUE;
	--------


	------------
end	ARM64_TARGET;
	------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
