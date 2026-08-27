# LIVRAISON TC-16 - CALCUL, COMPARAISONS, BRANCHES (tranche E3)
(20 aout 2026 - s'applique sur l'etat courant : post-TC-14 + DO_VAR de
TC-15 (1.1) + unites majuscules du temoin 14. Regles habituelles.)

TABLE (28 mnemoniques, transcrits du codi, tailles FIXES - operations
de pile pures) : CNE CGT CGE CLT CLE (16 : POP_RBX + cmp + setcc), BF
(16, comme BT en jz), DEC INC NEG FNEG (4), CLAMP0 (15), OUX SHL (12),
DIV (29), REMI (32), MODI (48), CVTIX (38), FADD FSUB FMUL FDIV (23),
FCGT FCGE FCLT (22), FCNE (28, NaN -> vrai), CVTIF CVTFI CVTFIR (14).
Le codi definit aussi ET OU NON SHR SAR ABS FABS FCEQ FCLE FEXP CVTXI
UBFX SBFX BFI : HORS CORPUS des quatre FINC, non transcrits (refus
bruyant s'ils surgissent - la tranche suivante les prendra au besoin).

## COMMIT 1 - EMITS : helper E_POP_RCX + tailles

### MODIFICATION 1.1 - target_code-emits.adb (apres E_POP_RBX) (insertion pure)
ANCRE (texte existant, unique) :
<<<
  end E_POP_RBX;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
  end E_POP_RBX;

  procedure		E_POP_RCX									--| 8 octets (decalages, conversions)
  is
  begin
    B( 16#48# ); B( 16#8B# ); B( 16#4D# ); B( 16#00# );							--| mov rcx, [rbp]
    B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );							--| lea rbp, [rbp-8]
  end E_POP_RCX;
>>>

### MODIFICATION 1.2 - target_code-emits.adb (SIZE_OF, apres la famille des acces) (insertion pure)
Ancre : la derniere branche SIZE_OF de TC-14 (SIQ).
ANCRE (texte existant, unique) :
<<<
    elsif M = "SIQ"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    elsif M = "SIQ"
    then
      return 8 + S_BASE( OPV( E, 1, -1 ) ) + S_DISP( OPV( E, 2, 0 ), 3 )
	     + S_DISP( OPV( E, 3, 0 ), 3 );
    elsif M = "DEC"  or else  M = "INC"  or else  M = "NEG"  or else  M = "FNEG"
    then
      return 4;
    elsif M = "OUX"  or else  M = "SHL"
    then
      return 12;
    elsif M = "CVTIF"  or else  M = "CVTFI"  or else  M = "CVTFIR"
    then
      return 14;
    elsif M = "CLAMP0"
    then
      return 15;
    elsif M = "CNE"  or else  M = "CGT"  or else  M = "CGE"  or else  M = "CLT"  or else  M = "CLE"
    then
      return 16;
    elsif M = "FCGT"  or else  M = "FCGE"  or else  M = "FCLT"
    then
      return 22;
    elsif M = "FADD"  or else  M = "FSUB"  or else  M = "FMUL"  or else  M = "FDIV"
    then
      return 23;
    elsif M = "FCNE"
    then
      return 28;
    elsif M = "DIV"
    then
      return 29;
    elsif M = "REMI"
    then
      return 32;
    elsif M = "CVTIX"
    then
      return 38;
    elsif M = "MODI"
    then
      return 48;
    elsif M = "BF"
    then
      return 16;							--| comme BT (jz rel32)
>>>

## COMMIT 2 - EMITS : encodages

### MODIFICATION 2.1 - target_code-emits.adb (ENCODE, apres la famille des acces) (insertion pure)
Ancre : la fin de la branche ENCODE de SIQ (TC-14).
ANCRE (texte existant, unique) :
<<<
    elsif M = "SIQ"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_Q( OPV( E, 3, 0 ) );
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + insertion) :
<<<
    elsif M = "SIQ"
    then
      E_POP_RBX;
      E_IBASE( OPV( E, 1, -1 ), OPV( E, 2, 0 ) );
      E_STORE_Q( OPV( E, 3, 0 ) );
    elsif M = "CNE"
    then								--| A /= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#95# ); B( 16#45# ); B( 16#00# );
    elsif M = "CGT"
    then								--| A > B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9F# ); B( 16#45# ); B( 16#00# );
    elsif M = "CGE"
    then								--| A >= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9D# ); B( 16#45# ); B( 16#00# );
    elsif M = "CLT"
    then								--| A < B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9C# ); B( 16#45# ); B( 16#00# );
    elsif M = "CLE"
    then								--| A <= B
      E_POP_RBX;
      B( 16#48# ); B( 16#39# ); B( 16#5D# ); B( 16#00# );
      B( 16#0F# ); B( 16#9E# ); B( 16#45# ); B( 16#00# );
    elsif M = "DEC"
    then								--| dec qword [rbp]
      B( 16#48# ); B( 16#FF# ); B( 16#4D# ); B( 16#00# );
    elsif M = "INC"
    then								--| inc qword [rbp]
      B( 16#48# ); B( 16#FF# ); B( 16#45# ); B( 16#00# );
    elsif M = "NEG"
    then								--| neg qword [rbp]
      B( 16#48# ); B( 16#F7# ); B( 16#5D# ); B( 16#00# );
    elsif M = "CLAMP0"
    then								--| sommet := max(0, sommet)
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );
      B( 16#48# ); B( 16#C1# ); B( 16#F8# ); B( 16#3F# );
      B( 16#48# ); B( 16#F7# ); B( 16#D0# );
      B( 16#48# ); B( 16#21# ); B( 16#45# ); B( 16#00# );
    elsif M = "OUX"
    then								--| xor qword [rbp], rax
      E_POP_RAX;
      B( 16#48# ); B( 16#31# ); B( 16#45# ); B( 16#00# );
    elsif M = "SHL"
    then								--| shl qword [rbp], cl
      E_POP_RCX;
      B( 16#48# ); B( 16#D3# ); B( 16#65# ); B( 16#00# );
    elsif M = "DIV"
    then								--| division signee tronquee
      E_POP_RBX;
      E_POP_RAX;
      B( 16#48# ); B( 16#99# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      E_PUSH_RAX;
    elsif M = "REMI"
    then								--| reste (signe du dividende)
      E_POP_RBX;
      E_POP_RAX;
      B( 16#48# ); B( 16#99# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      B( 16#48# ); B( 16#89# ); B( 16#D0# );
      E_PUSH_RAX;
    elsif M = "MODI"
    then								--| modulo Ada (signe du diviseur)
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
    elsif M = "CVTIX"
    then								--| entier -> fixed : I * DENOM / NUMER
      E_POP_RBX;
      E_POP_RCX;
      E_POP_RAX;
      B( 16#48# ); B( 16#F7# ); B( 16#E9# );
      B( 16#48# ); B( 16#F7# ); B( 16#FB# );
      E_PUSH_RAX;
    elsif M = "FADD"
    then								--| addsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#58# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );
    elsif M = "FSUB"
    then								--| subsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#5C# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );
    elsif M = "FMUL"
    then								--| mulsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#59# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );
    elsif M = "FDIV"
    then								--| divsd
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#0F# ); B( 16#5E# ); B( 16#C1# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );
    elsif M = "FNEG"
    then								--| bascule du bit de signe IEEE
      B( 16#80# ); B( 16#75# ); B( 16#07# ); B( 16#80# );
    elsif M = "FCNE"
    then								--| A /= B flottant (NaN -> vrai)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#95# ); B( 16#45# ); B( 16#00# );
      B( 16#0F# ); B( 16#9A# ); B( 16#C0# );
      B( 16#08# ); B( 16#45# ); B( 16#00# );
    elsif M = "FCGT"
    then								--| A > B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );
    elsif M = "FCGE"
    then								--| A >= B flottant
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C1# );
      B( 16#0F# ); B( 16#93# ); B( 16#45# ); B( 16#00# );
    elsif M = "FCLT"
    then								--| A < B flottant (ucomisd inverse)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#4D# ); B( 16#00# );
      B( 16#48# ); B( 16#8D# ); B( 16#6D# ); B( 16#F8# );
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#66# ); B( 16#0F# ); B( 16#2E# ); B( 16#C8# );
      B( 16#0F# ); B( 16#97# ); B( 16#45# ); B( 16#00# );
    elsif M = "CVTIF"
    then								--| entier -> double (cvtsi2sd)
      B( 16#48# ); B( 16#8B# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2A# ); B( 16#C0# );
      B( 16#F2# ); B( 16#0F# ); B( 16#11# ); B( 16#45# ); B( 16#00# );
    elsif M = "CVTFI"
    then								--| double -> entier, troncature (cvttsd2si)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2C# ); B( 16#C0# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "CVTFIR"
    then								--| double -> entier, arrondi machine (cvtsd2si)
      B( 16#F2# ); B( 16#0F# ); B( 16#10# ); B( 16#45# ); B( 16#00# );
      B( 16#F2# ); B( 16#48# ); B( 16#0F# ); B( 16#2D# ); B( 16#C0# );
      B( 16#48# ); B( 16#89# ); B( 16#45# ); B( 16#00# );
    elsif M = "BF"
    then								--| branch false : comme BT, jz rel32
      if IR.N_OPS( E ) < 1  or else  IR.OP_TAG( E, 1 ) /= IR.NAME_OP
      then
	FAULT( "BF : label attendu" );
      end if;
      V := SYMBOLS.VALUE_OF( SYMBOLS.RESOLVE( LEX.IMAGE( IR.OP_TXT( E, 1 ) ) ) );
      E_POP_RAX;
      B( 16#08# ); B( 16#C0# );						--| or al, al
      B( 16#0F# ); B( 16#84# );						--| jz rel32
      D32( INTEGER( V - ( ORG + SYMBOLS.VALUE_TYPE( TOP ) + 4 ) ) );
>>>

## COMMIT 3 - TEMOIN TC-16 (pilote)

(Pas de temoin TC-15 : erratum, prouve par la batterie.)

### MODIFICATION 3.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-14) :
<<<
      PUT_LINE( "  chmod +x TC_TEST14.BIN && ./TC_TEST14.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-16) :
<<<
      PUT_LINE( "  chmod +x TC_TEST14.BIN && ./TC_TEST14.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE CALCUL (TC-16) - les 28 mnemoniques de la
  --|  tranche E3, chacun sous verdict d'execution discriminant :
  --|  division tronquee / reste / modulo Ada (signes croises), NEG,
  --|  INC/DEC, CLAMP0 (deux bords), OUX, SHL, les cinq comparaisons
  --|  entieres (vraies par BT, fausses par BF), l'arithmetique et les
  --|  comparaisons flottantes (FCNE en filtre d'egalite), FNEG, les
  --|  conversions CVTIF / CVTFI (troncature) / CVTFIR (arrondi machine
  --|  pair : 3.5 -> 4) / CVTIX (7 * 2 / 3 = 4). Verdicts : 0 = tout
  --|  bon ; 3..30 = etape fautive. A RETIRER avec les autres.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM16		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC calcul : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST16.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	DIV" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k16_3:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	REMI" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k16_4:" );
    PUT_LINE( F, "	LI	17" );
    PUT_LINE( F, "	LI	-5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_5" );
    PUT_LINE( F, "	SYS_EXIT	5" );
    PUT_LINE( F, "k16_5:" );
    PUT_LINE( F, "	LI	-17" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	MODI" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_6" );
    PUT_LINE( F, "	SYS_EXIT	6" );
    PUT_LINE( F, "k16_6:" );
    PUT_LINE( F, "	LI	42" );
    PUT_LINE( F, "	NEG" );
    PUT_LINE( F, "	LI	-42" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_7" );
    PUT_LINE( F, "	SYS_EXIT	7" );
    PUT_LINE( F, "k16_7:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	INC" );
    PUT_LINE( F, "	DEC" );
    PUT_LINE( F, "	LI	8" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_8" );
    PUT_LINE( F, "	SYS_EXIT	8" );
    PUT_LINE( F, "k16_8:" );
    PUT_LINE( F, "	LI	-7" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	0" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_9" );
    PUT_LINE( F, "	SYS_EXIT	9" );
    PUT_LINE( F, "k16_9:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLAMP0" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_10" );
    PUT_LINE( F, "	SYS_EXIT	10" );
    PUT_LINE( F, "k16_10:" );
    PUT_LINE( F, "	LI	61680" );
    PUT_LINE( F, "	LI	4080" );
    PUT_LINE( F, "	OUX" );
    PUT_LINE( F, "	LI	65280" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_11" );
    PUT_LINE( F, "	SYS_EXIT	11" );
    PUT_LINE( F, "k16_11:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	SHL" );
    PUT_LINE( F, "	LI	48" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_12" );
    PUT_LINE( F, "	SYS_EXIT	12" );
    PUT_LINE( F, "k16_12:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BT	k16_13" );
    PUT_LINE( F, "	SYS_EXIT	13" );
    PUT_LINE( F, "k16_13:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGT" );
    PUT_LINE( F, "	BF	k16_14" );
    PUT_LINE( F, "	SYS_EXIT	14" );
    PUT_LINE( F, "k16_14:" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLT" );
    PUT_LINE( F, "	BT	k16_15" );
    PUT_LINE( F, "	SYS_EXIT	15" );
    PUT_LINE( F, "k16_15:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CLE" );
    PUT_LINE( F, "	BT	k16_16" );
    PUT_LINE( F, "	SYS_EXIT	16" );
    PUT_LINE( F, "k16_16:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CGE" );
    PUT_LINE( F, "	BT	k16_17" );
    PUT_LINE( F, "	SYS_EXIT	17" );
    PUT_LINE( F, "k16_17:" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	LI	5" );
    PUT_LINE( F, "	CNE" );
    PUT_LINE( F, "	BF	k16_18" );
    PUT_LINE( F, "	SYS_EXIT	18" );
    PUT_LINE( F, "k16_18:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FADD" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_19" );
    PUT_LINE( F, "	SYS_EXIT	19" );
    PUT_LINE( F, "k16_19:" );
    PUT_LINE( F, "	LIF	5.5" );
    PUT_LINE( F, "	LIF	2.25" );
    PUT_LINE( F, "	FSUB" );
    PUT_LINE( F, "	LIF	3.25" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_20" );
    PUT_LINE( F, "	SYS_EXIT	20" );
    PUT_LINE( F, "k16_20:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FMUL" );
    PUT_LINE( F, "	LIF	3.75" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_21" );
    PUT_LINE( F, "	SYS_EXIT	21" );
    PUT_LINE( F, "k16_21:" );
    PUT_LINE( F, "	LIF	7.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FDIV" );
    PUT_LINE( F, "	LIF	3.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_22" );
    PUT_LINE( F, "	SYS_EXIT	22" );
    PUT_LINE( F, "k16_22:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FNEG" );
    PUT_LINE( F, "	LIF	-2.5" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_23" );
    PUT_LINE( F, "	SYS_EXIT	23" );
    PUT_LINE( F, "k16_23:" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCLT" );
    PUT_LINE( F, "	BT	k16_24" );
    PUT_LINE( F, "	SYS_EXIT	24" );
    PUT_LINE( F, "k16_24:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	1.5" );
    PUT_LINE( F, "	FCGT" );
    PUT_LINE( F, "	BT	k16_25" );
    PUT_LINE( F, "	SYS_EXIT	25" );
    PUT_LINE( F, "k16_25:" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	LIF	2.5" );
    PUT_LINE( F, "	FCGE" );
    PUT_LINE( F, "	BT	k16_26" );
    PUT_LINE( F, "	SYS_EXIT	26" );
    PUT_LINE( F, "k16_26:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	CVTIF" );
    PUT_LINE( F, "	LIF	7.0" );
    PUT_LINE( F, "	FCNE" );
    PUT_LINE( F, "	BF	k16_27" );
    PUT_LINE( F, "	SYS_EXIT	27" );
    PUT_LINE( F, "k16_27:" );
    PUT_LINE( F, "	LIF	-3.75" );
    PUT_LINE( F, "	CVTFI" );
    PUT_LINE( F, "	LI	-3" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_28" );
    PUT_LINE( F, "	SYS_EXIT	28" );
    PUT_LINE( F, "k16_28:" );
    PUT_LINE( F, "	LIF	3.5" );
    PUT_LINE( F, "	CVTFIR" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_29" );
    PUT_LINE( F, "	SYS_EXIT	29" );
    PUT_LINE( F, "k16_29:" );
    PUT_LINE( F, "	LI	7" );
    PUT_LINE( F, "	LI	2" );
    PUT_LINE( F, "	LI	3" );
    PUT_LINE( F, "	CVTIX" );
    PUT_LINE( F, "	LI	4" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k16_30" );
    PUT_LINE( F, "	SYS_EXIT	30" );
    PUT_LINE( F, "k16_30:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM16 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST16.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM16, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM16, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM16, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST16.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD.loc_siz" ) ) = 8,
	   "frame 0 sans variable (loc_siz 8)" );

    if OK
    then
      PUT_LINE( "PASSE calcul" );
      PUT_LINE( "TC_TEST16.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST16.FAS TC_REF16 && cmp TC_REF16 TC_TEST16.BIN" );
      PUT_LINE( "  chmod +x TC_TEST16.BIN && ./TC_TEST16.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE COMMIT 3 (quadruple) :
(a) fasmg TC_TEST16.FAS TC_REF16 && cmp -> muet. Premiers suspects :
    MODI (sequence a sauts internes, 48 octets) puis FCNE (28).
(b) fasmg accepte TC_TEST16.FAS.
(c) "PASSE calcul" ; ./TC_TEST16.BIN -> 0 (3..30 = etape fautive).
(d) cmp TC-04..14 muets, executions conformes.

## CLOTURE (documentation)
- NOTE_SUBSET par 1.2 : tranche calcul LUE (TC-16) ; ET OU NON SHR SAR
  ABS FABS FCEQ FCLE FEXP CVTXI UBFX SBFX BFI restent hors table
  (hors corpus des quatre FINC).
- RESTE : E4 blocs inline (align_q en flot : SIZE_OF avec adresse
  courante, BEGIN/END_BLOC_DEF, db, BLKMOV, CO_VAR), puis E5.
