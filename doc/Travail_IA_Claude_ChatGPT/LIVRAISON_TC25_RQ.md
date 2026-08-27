# LIVRAISON TC-25 - rq : RESERVATION DE QWORDS (corpus ADA_COMP)
(24 aout 2026 - s'applique sur l'etat POST-TC-24 + vos ajouts.)

RELEVE : 'rq' emis par l'expander dans les records manuels (zone
virtual), jumeau 64 bits du 'rd' de TC-12. Trois entrees calquees :
avance de position 8 x N a P2, zero octet a l'emission. Doctrine
releve : rw attendra d'apparaitre au corpus.

## COMMIT 1 - LES TROIS ENTREES

### MODIFICATION 1.1 - target_code-passes.adb (sur place, auto-localisee)
P2 : l'avance 8 x N, calquee sur rd.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
	    elsif MNEMO_IS( EI, "rd" )  then							--| reservation de N dwords en zone statique
	      if STOP = 0  or else  IR.N_OPS( EI ) < 1			--| (records manuels de _STANDRD - TC-12)
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
		FAULT( "forme rd inattendue (N dwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 4 * IR.OP_INT( EI, 1 );
>>>
REMPLACER PAR :
<<<
	    elsif MNEMO_IS( EI, "rd" )  then							--| reservation de N dwords en zone statique
	      if STOP = 0  or else  IR.N_OPS( EI ) < 1			--| (records manuels de _STANDRD - TC-12)
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
		FAULT( "forme rd inattendue (N dwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 4 * IR.OP_INT( EI, 1 );

	    elsif MNEMO_IS( EI, "rq" )  then							--| reservation de N qwords (ADA_COMP, TC-25)
	      if STOP = 0  or else  IR.N_OPS( EI ) < 1			--| 
		 or else  IR.OP_TAG( EI, 1 ) /= IR.INT_OP
		 or else  IR.OP_INT( EI, 1 ) < 0
	      then
		FAULT( "forme rq inattendue (N qwords, en zone virtual)" );
	      end if;
	      SPOSES( STOP ) := SPOSES( STOP ) + 8 * IR.OP_INT( EI, 1 );
>>>

### MODIFICATION 1.2 - target_code-emits.adb (sur place, auto-localisee)
SIZE_OF : zero octet, comme rd.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif  M = "rd"  then return  0;									--| reservation statique (TC-12)  then return 0;											--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif  M = "rd"  then return  0;									--| reservation statique (TC-12)  then return 0;											--| pure declaration : zero octet
    elsif  M = "rq"  then return  0;									--| reservation statique qwords (TC-25)
>>>

### MODIFICATION 1.3 - target_code-emits.adb (sur place, auto-localisee)
ENCODE : rien, comme rd.
ANCRE = BLOC A SUPPRIMER (texte existant, unique, auto-localisant) :
<<<
    elsif M = "rd"  then  null;											--| pure declaration : zero octet
>>>
REMPLACER PAR :
<<<
    elsif M = "rd"  then  null;											--| pure declaration : zero octet
    elsif M = "rq"  then  null;											--| pure declaration : zero octet (TC-25)
>>>

## COMMIT 2 - TEMOIN TC-25 (pilote)

### MODIFICATION 2.1 - target_code.adb (insertion pure, fin du pilote)
ANCRE (texte existant, unique : fin du temoin TC-24) :
<<<
      PUT_LINE( "  chmod +x TC_TEST24.BIN && ./TC_TEST24.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;
>>>
SUPPRIMER : le texte de l'ancre elle-meme (repris a l'identique en tete du remplacement).
REMPLACER PAR (ancre reprise inchangee + temoin TC-25) :
<<<
      PUT_LINE( "  chmod +x TC_TEST24.BIN && ./TC_TEST24.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

  --|  TEMOIN TEMPORAIRE rq (TC-25) - record manuel en zone virtual :
  --|  rq 2 avance de 16, rd 1 de 4, verifies par differences de
  --|  positions en verdicts executes. Verdicts : 0 ; 3..4. A RETIRER.
  declare
    use LEX;
    use SYMBOLS;
    use IR;
    OK			: BOOLEAN	:= TRUE;
    F			: FILE_TYPE;
    FROM25		: IR.ELT_ID;

    procedure CHECK ( COND :BOOLEAN; MSG :STRING )
    is
    begin
      if not COND
      then
	OK := FALSE;
	PUT_LINE( "ECHEC rq : " & MSG );
      end if;
    end CHECK;

  begin
    CREATE( F, OUT_FILE, "TC_TEST25.FAS" );
    PUT_LINE( F, "	include '../../src/expander/fasmg/codi_x86_64.finc'" );
    PUT_LINE( F, "STANDARD = 'STANDARD'" );
    PUT_LINE( F, "namespace STANDARD" );
    PUT_LINE( F, "  virtual at 8" );
    PUT_LINE( F, "    VARzone::" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "	LINK	0, loc_siz" );
    PUT_LINE( F, "namespace _R25" );
    PUT_LINE( F, "  virtual at 0" );
    PUT_LINE( F, "A25 = $" );
    PUT_LINE( F, "	rq 2" );
    PUT_LINE( F, "B25 = $" );
    PUT_LINE( F, "	rd 1" );
    PUT_LINE( F, "C25 = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    PUT_LINE( F, "	LI	16" );
    PUT_LINE( F, "	LI	STANDARD._R25.B25 - STANDARD._R25.A25" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k25_3" );
    PUT_LINE( F, "	SYS_EXIT	3" );
    PUT_LINE( F, "k25_3:" );
    PUT_LINE( F, "	LI	20" );
    PUT_LINE( F, "	LI	STANDARD._R25.C25 - STANDARD._R25.A25" );
    PUT_LINE( F, "	CEQ" );
    PUT_LINE( F, "	BT	k25_4" );
    PUT_LINE( F, "	SYS_EXIT	4" );
    PUT_LINE( F, "k25_4:" );
    PUT_LINE( F, "	SYS_EXIT	0" );
    PUT_LINE( F, " virtual VARzone" );
    PUT_LINE( F, "   loc_siz = $" );
    PUT_LINE( F, "  end virtual" );
    PUT_LINE( F, "end namespace" );
    CLOSE( F );

    FROM25 := IR.ELT_ID( IR.ELT_COUNT + 1 );
    RUN_P0( "TC_TEST25.FAS" );
    PASSES.P1_REACH;
    PASSES.P2_LAYOUT( FROM25, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P2B_ADDRESSES( FROM25, IR.ELT_ID( IR.ELT_COUNT ) );
    EMITS.P3_EMIT( FROM25, IR.ELT_ID( IR.ELT_COUNT ), "TC_TEST25.BIN" );

    CHECK( VALUE_OF( RESOLVE( "STANDARD._R25.B25" ) ) = 16
	   and then VALUE_OF( RESOLVE( "STANDARD._R25.C25" ) ) = 20,
	   "rq 2 avance de 16, rd 1 de 4" );

    if OK
    then
      PUT_LINE( "PASSE rq" );
      PUT_LINE( "TC_TEST25.BIN ecrit - oracle externe :" );
      PUT_LINE( "  fasmg TC_TEST25.FAS TC_REF25 && cmp TC_REF25 TC_TEST25.BIN" );
      PUT_LINE( "  chmod +x TC_TEST25.BIN && ./TC_TEST25.BIN ; echo $?   (attendu : 0)" );
    end if;
  end;

>>>

ORACLE (quadruple) : (a) cmp TC_REF25/TC_TEST25.BIN muet ; (b) fasmg
accepte ; (c) PASSE rq, ./TC_TEST25.BIN -> 0 ; (d) batterie muette,
unites du corpus muettes, ADA_COMP franchit ce refus.
