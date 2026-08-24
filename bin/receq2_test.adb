--| RECEQ2_TEST — verrou de l'egalite des records et tableaux,
--| Y COMPRIS types DERIVES et prives completes par derivation (F1).
--|
--| Reprend integralement RECEQ_TEST v1 (R1-R7, prouvees saines) et
--| ajoute les sections R8-R11 qui reproduisent le fossile F1 :
--| « = » / « /= » d'un type derive de record compile en comparaison
--| d'ADRESSES de doublets (dossier SONDES-VISEL, DEFINTERP_TYPE is
--| new TREE, sequence LVA/LVA/CNE).
--|
--| ORACLE AVANT correctif F1 (T1 actuel)   : R1-R7 passent,
--|   echecs attendus parmi R8-R11 — datation du fossile.
--| ORACLE APRES correctif F1 (T1 refabrique) :
--|   RESULTAT :  22 OK,   0 ECHECS  /  RECEQ2_TEST PASSE
--| gnat (oracle de legalite) : compilation muette, 22 OK.

with TEXT_IO;	use TEXT_IO;

procedure RECEQ2_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  --| clone fidele de la forme de TREE (idl.ads)
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

  --| F1 : types DERIVES
  type DTR	is new TR;				--| derive du clone TREE (cas DEFINTERP_TYPE)
  type DDI	is new DI;				--| derive d'un record 8 octets
  type ARR3	is array ( 1 .. 3 ) of INTEGER;
  type DARR	is new ARR3;				--| derive de tableau (branche tableau)

  --| F1 : prive complete par derivation (fidele a SET_UTIL)
  package PK is
    type PRIV	is private;
    function MK2( T : TR ) return PRIV;
  private
    type PRIV	is new TR;
  end PK;

  T1A	: TR := ( PT => P, TY => K2, PG => 1234, LN => 56 );
  T1B	: TR := ( PT => P, TY => K2, PG => 1234, LN => 56 );
  T1C	: TR := ( PT => P, TY => K3, PG => 1234, LN => 56 );

  D1	: DI;
  D2	: DI;
  D3	: DI;

  W1	: TRI;
  W2	: TRI;

  P1	: PAIRE := ( X => 42, Y => 4242 );
  P2	: PAIRE := ( X => 42, Y => 4242 );
  P3	: PAIRE := ( X => 42, Y => 4243 );

  E1	: DTR := ( PT => P, TY => K1, PG => 777, LN => 7 );
  E2	: DTR := ( PT => P, TY => K1, PG => 777, LN => 7 );
  E3	: DTR := ( PT => P, TY => K1, PG => 778, LN => 7 );

  G1	: DDI;
  G2	: DDI;

  A1	: DARR := ( 10, 20, 30 );
  A2	: DARR := ( 10, 20, 30 );
  A3	: DARR := ( 10, 20, 31 );

  Q1	: PK.PRIV;
  Q2	: PK.PRIV;

  package body PK is
    function MK2( T : TR ) return PRIV is
    begin
      return PRIV( T );
    end MK2;
  end PK;

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

  --| R1 : clone TREE, deux variables, meme contenu
  ASSERT( T1A  = T1B, "R1a TR egalite vraie" );
  ASSERT( not (T1A /= T1B), "R1b TR inegalite fausse" );
  ASSERT( T1A /= T1C, "R1c TR inegalite vraie" );

  --| R2 : paire de TR
  D1 := ( DEF => T1A, TYP => T1C );
  D2 := ( DEF => T1B, TYP => T1C );
  ASSERT( D1  = D2, "R2a DI egalite vraie" );
  ASSERT( not (D1 /= D2), "R2b DI inegalite fausse" );
  D3 := ( DEF => T1C, TYP => T1A );
  ASSERT( D1 /= D3, "R2c DI inegalite vraie" );

  --| R3 : variable := F(...) puis compare
  D3 := MK( T1A, T1C );
  ASSERT( not (D3 /= D1), "R3 F() en variable puis /=" );

  --| R4 : resultat de fonction compare directement
  ASSERT( not (MK( T1B, T1C ) /= D1), "R4 F() compare directement" );

  --| R5 : 12 octets
  W1 := ( A => T1A, B => T1C, C => T1B );
  W2 := ( A => T1B, B => T1C, C => T1A );
  ASSERT( W1 = W2, "R5a TRI egalite vraie" );
  ASSERT( not (W1 /= W2), "R5b TRI inegalite fausse" );

  --| R6 : record plat sans rep clause
  ASSERT( P1  = P2, "R6a PAIRE egalite vraie" );
  ASSERT( not (P1 /= P2), "R6b PAIRE inegalite fausse" );
  ASSERT( P1 /= P3, "R6c PAIRE inegalite vraie" );

  --| R7 : auto-comparaison
  ASSERT( not (D1 /= D1), "R7 X /= X doit etre faux" );

  --| R8 : DERIVE d'un record represente 32 bits  <== fossile F1
  ASSERT( E1  = E2, "R8a DTR egalite vraie      <== F1" );
  ASSERT( not (E1 /= E2), "R8b DTR inegalite fausse   <== F1 (cas SONDEB2)" );
  ASSERT( E1 /= E3, "R8c DTR inegalite vraie" );

  --| R9 : DERIVE d'un record 8 octets
  G1 := ( DEF => T1A, TYP => T1C );
  G2 := ( DEF => T1B, TYP => T1C );
  ASSERT( G1  = G2, "R9a DDI egalite vraie      <== F1" );
  ASSERT( not (G1 /= G2), "R9b DDI inegalite fausse   <== F1" );

  --| R10 : PRIVE complete par derivation (fidele a SET_UTIL)
  Q1 := PK.MK2( T1A );
  Q2 := PK.MK2( T1B );
  ASSERT( PK."="( Q1, Q2 ), "R10a PRIV egalite vraie    <== F1" );
  ASSERT( not PK."/="( Q1, Q2 ), "R10b PRIV inegalite fausse <== F1" );

  --| R11 : DERIVE de tableau (branche tableau de l'aiguillage)
  ASSERT( A1  = A2, "R11a DARR egalite vraie    <== F1 tableau" );
  ASSERT( not (A1 /= A2), "R11b DARR inegalite fausse <== F1 tableau" );
  ASSERT( A1 /= A3, "R11c DARR inegalite vraie" );

  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "RECEQ2_TEST PASSE" );
  else
    PUT_LINE( "RECEQ2_TEST ECHOUE" );
  end if;

end RECEQ2_TEST;
