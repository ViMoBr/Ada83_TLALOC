with TEXT_IO;			use TEXT_IO;
with GRMR_TBL;

procedure PROBE_READ
is
  use GRMR_TBL;

  KO_TOTAL	: NATURAL := 0;

  procedure VERDICT( LABEL :STRING; BAD :NATURAL; FIRST :INTEGER )
  is
  begin
    if  BAD = 0  then
      PUT_LINE( LABEL & " : OK" );
    else
      PUT_LINE( LABEL & " : DIVERGE," & NATURAL'IMAGE( BAD )
	      & " cellules, premiere a l'indice" & INTEGER'IMAGE( FIRST ) );
      KO_TOTAL := KO_TOTAL + BAD;
    end if;
  end VERDICT;

  procedure SCALAR( LABEL :STRING; LU :INTEGER; ATTENDU :INTEGER )
  is
  begin
    if  LU = ATTENDU  then
      PUT_LINE( LABEL & " : OK" );
    else
      PUT_LINE( LABEL & " : DIVERGE, lu" & INTEGER'IMAGE( LU )
	      & " attendu" & INTEGER'IMAGE( ATTENDU ) );
      KO_TOTAL := KO_TOTAL + 1;
    end if;
  end SCALAR;

begin
  declare
    use GRMR_TBL_IO;
    F	: GRMR_TBL_IO.FILE_TYPE;
  begin
    OPEN( F, IN_FILE, "parse_probe.bin" );
    READ( F, GRMR );
    CLOSE( F );
  end;

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in ST_TBL_TYPE'RANGE loop
      if  GRMR.ST_TBL( I ) /= I * 1009 - 500_000  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "ST_TBL ", BAD, FIRST );
  end;

  SCALAR( "ST_TBL_LAST ", GRMR.ST_TBL_LAST, 16#5EED1# );

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in AC_SYM_TYPE'RANGE loop
      if  GRMR.AC_SYM( I ) /= AC_BYTE( (I*7) mod 256 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "AC_SYM ", BAD, FIRST );
  end;

  declare
    BAD_NEG	: NATURAL := 0;					-- attendu < 0 : juge la charge SIGNEE (Lw)
    BAD_POS	: NATURAL := 0;					-- attendu >= 0
    FIRST	: INTEGER := 0;
    ATTENDU	: INTEGER;
  begin
    for I in AC_TBL_TYPE'RANGE loop
      ATTENDU := ((I*13) mod 60_001) - 30_000;
      if  GRMR.AC_TBL( I ) /= AC_SHORT( ATTENDU )  then
        if  BAD_NEG + BAD_POS = 0  then FIRST := I; end if;
        if  ATTENDU < 0  then BAD_NEG := BAD_NEG + 1;
	          else  BAD_POS := BAD_POS + 1;
        end if;
      end if;
    end loop;
    VERDICT( "AC_TBL (attendus negatifs)", BAD_NEG, FIRST );
    VERDICT( "AC_TBL (attendus positifs)", BAD_POS, FIRST );
    if  BAD_NEG + BAD_POS > 0  then
      if  FIRST mod 2 = 0  then
        PUT_LINE( "AC_TBL : premier divergent PAIR" );
      else
        PUT_LINE( "AC_TBL : premier divergent IMPAIR" );
      end if;
    end if;
  end;

  SCALAR( "AC_SYM_LAST ", GRMR.AC_SYM_LAST, 16#5EED2# );
  SCALAR( "AC_TBL_LAST ", GRMR.AC_TBL_LAST, 16#5EED3# );

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in NTER_PG_TYPE'RANGE loop
      if  GRMR.NTER_PG( I ) /= AC_BYTE( (I*3) mod 251 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "NTER_PG", BAD, FIRST );
  end;

  declare
    BAD	: NATURAL := 0;
    FIRST	: INTEGER := 0;
  begin
    for I in NTER_LN_TYPE'RANGE loop
      if  GRMR.NTER_LN( I ) /= AC_BYTE( (I*5) mod 253 )  then
        if  BAD = 0  then FIRST := I; end if;
        BAD := BAD + 1;
      end if;
    end loop;
    VERDICT( "NTER_LN", BAD, FIRST );
  end;

  SCALAR( "NTER_LAST ", GRMR.NTER_LAST, 16#5EED4# );

  if  KO_TOTAL = 0  then
    PUT_LINE( "PROBE PASSE" );
  else
    PUT_LINE( "PROBE ECHOUE" );
  end if;

end PROBE_READ;
