--| RECEQ4_TEST — VERROU F1 : egalite des records, y compris types
--| DERIVES (R1..R9). Valeurs derivees par CONVERSION.
--| Exclusions motivees : R10 (prive via fonction MK2) attend le
--| dossier F6 (fonction a resultat prive/derive de record — cause
--| presumee de l'instabilite RECEQ2B/RECEQ3) ; R11 (tableaux derives)
--| est verrouille a part par DARREQ ; agregat de derive : dossier F4,
--| reproducteur receq2_test v1.
--| ORACLE : RESULTAT :  19 OK,   0 ECHECS  /  RECEQ4_TEST PASSE.

with TEXT_IO;	use TEXT_IO;

procedure RECEQ4_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type NN	is ( K0, K1, K2, K3 );			for NN'SIZE use 8;
  type PAGE15	is range 0 .. 16#7FFF#;			for PAGE15'SIZE use 15;
  type LINE7	is range 0 .. 127;			for LINE7'SIZE use 7;
  type SHORT15	is range 0 .. 32767;			for SHORT15'SIZE use 15;
  type COL8	is range 0 .. 255;			for COL8'SIZE use 8;
  type V2	is ( P, S, L, HI );

  type TR (PT : V2 := P)	is record
				  case PT is
				  when P | L =>
				    TY		: NN;
				    PG		: PAGE15;
				    LN		: LINE7;
				  when S =>
				    COL		: COL8;
				    SPG		: PAGE15;
				    SLN		: LINE7;
				  when HI =>
				    NOTY	: NN;
				    ABSS	: SHORT15;
				    NSIZ	: LINE7;
				  end case;
				end record;
			for TR'SIZE use 32;
			for TR use record at mod 4;
				PT	at 0 range 0..1;
				LN	at 0 range 2..8;
				SLN	at 0 range 2..8;
				NSIZ	at 0 range 2..8;
				PG	at 0 range 9..23;
				SPG	at 0 range 9..23;
				ABSS	at 0 range 9..23;
				TY	at 0 range 24..31;
				COL	at 0 range 24..31;
				NOTY	at 0 range 24..31;
			end record;

  type DI	is record
		    DEF	: TR;
		    TYP	: TR;
		  end record;

  type TRI	is record
		    A	: TR;
		    B	: TR;
		    C	: TR;
		  end record;

  type PAIRE	is record
		    X	: INTEGER;
		    Y	: INTEGER;
		  end record;

  type DTR	is new TR;
  type DDI	is new DI;

  T1A	: TR := ( PT => P, TY => K2, PG => 1234, LN => 56 );
  T1B	: TR := ( PT => P, TY => K2, PG => 1234, LN => 56 );
  T1C	: TR := ( PT => P, TY => K3, PG => 1234, LN => 56 );
  T1D	: TR := ( PT => P, TY => K1, PG =>  777, LN =>  7 );
  T1E	: TR := ( PT => P, TY => K1, PG =>  778, LN =>  7 );

  D1	: DI;
  D2	: DI;
  D3	: DI;
  W1	: TRI;
  W2	: TRI;

  P1	: PAIRE := ( X => 42, Y => 4242 );
  P2	: PAIRE := ( X => 42, Y => 4242 );
  P3	: PAIRE := ( X => 42, Y => 4243 );

  E1	: DTR;
  E2	: DTR;
  E3	: DTR;
  G1	: DDI;
  G2	: DDI;

  procedure ASSERT( OK : BOOLEAN; MSG : STRING ) is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT_LINE( "ECHEC : " & MSG );
    end if;
  end ASSERT;

  function MK( D, T : TR ) return DI is
  begin
    return ( DEF => D, TYP => T );
  end MK;

begin

  ASSERT( T1A  = T1B, "R1a TR egalite vraie" );
  ASSERT( not (T1A /= T1B), "R1b TR inegalite fausse" );
  ASSERT( T1A /= T1C, "R1c TR inegalite vraie" );

  D1 := ( DEF => T1A, TYP => T1C );
  D2 := ( DEF => T1B, TYP => T1C );
  ASSERT( D1  = D2, "R2a DI egalite vraie" );
  ASSERT( not (D1 /= D2), "R2b DI inegalite fausse" );
  D3 := ( DEF => T1C, TYP => T1A );
  ASSERT( D1 /= D3, "R2c DI inegalite vraie" );

  D3 := MK( T1A, T1C );
  ASSERT( not (D3 /= D1), "R3 F() en variable puis /=" );
  ASSERT( not (MK( T1B, T1C ) /= D1), "R4 F() compare directement" );

  W1 := ( A => T1A, B => T1C, C => T1B );
  W2 := ( A => T1B, B => T1C, C => T1A );
  ASSERT( W1 = W2, "R5a TRI egalite vraie" );
  ASSERT( not (W1 /= W2), "R5b TRI inegalite fausse" );

  ASSERT( P1  = P2, "R6a PAIRE egalite vraie" );
  ASSERT( not (P1 /= P2), "R6b PAIRE inegalite fausse" );
  ASSERT( P1 /= P3, "R6c PAIRE inegalite vraie" );

  ASSERT( not (D1 /= D1), "R7 X /= X doit etre faux" );

  E1 := DTR( T1D );
  E2 := DTR( T1D );
  E3 := DTR( T1E );
  ASSERT( E1  = E2, "R8a DTR egalite vraie" );
  ASSERT( not (E1 /= E2), "R8b DTR inegalite fausse (cas SONDEB2)" );
  ASSERT( E1 /= E3, "R8c DTR inegalite vraie" );

  G1 := DDI( D1 );
  G2 := DDI( D2 );
  ASSERT( G1  = G2, "R9a DDI egalite vraie" );
  ASSERT( not (G1 /= G2), "R9b DDI inegalite fausse" );


  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "RECEQ4_TEST PASSE" );
  else
    PUT_LINE( "RECEQ4_TEST ECHOUE" );
  end if;

end RECEQ4_TEST;
