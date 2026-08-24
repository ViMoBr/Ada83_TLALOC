--| RECEQ_TEST — temoin runtime de l'egalite/inegalite de records
--|
--| Cible : le mensonge de « TEMP_DEFINTERP /= OLD_DEFINTERP » observe
--| dans T2s (SONDEB2 NE=TRUE sur singleton) : l'inegalite composite
--| rend « different » sur des valeurs egales. Hypothese : le code emis
--| compare les adresses (doublets) au lieu des valeurs pointees, pour
--| les records au-dela d'un mot.
--|
--| A compiler par T1 et executer : si l'egalite multi-mots est cassee
--| dans le code genere par T1, ce temoin le montre SANS le compilateur.
--| (gnat sert d'oracle de legalite : compile muet, tout passe.)
--|
--| ORACLE : RESULTAT :  14 OK,   0 ECHECS  /  RECEQ_TEST PASSE
--|
--| Sections :
--|   R1  record 32 bits a variantes + rep clause (clone de TREE) :
--|       deux variables, meme contenu           (temoin : A3 marche)
--|   R2  record de 2 clones (8 octets, forme DEFINTERP presumee) :
--|       deux variables, meme contenu — LE cas SONDEB2
--|   R3  variable := F(...) puis compare a une autre variable
--|       (forme exacte du site : HEAD puis /=)
--|   R4  resultat de fonction compare DIRECTEMENT
--|   R5  record de 3 clones (12 octets) : sonde de largeur
--|   R6  record plat de 2 INTEGER (8 octets, SANS rep clause) :
--|       discrimine « rep clause » vs « largeur »
--|   R7  auto-comparaison (X /= X) : doit etre FAUX partout
--| Pas de BOOLEAN'IMAGE nulle part (fossile separe, voir dossier A5).

with TEXT_IO;	use TEXT_IO;

procedure RECEQ_TEST is

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

  --| forme DEFINTERP presumee : paire de TR (8 octets)
  type DI	is record
		    DEF	: TR;
		    TYP	: TR;
		  end record;

  --| sonde de largeur : 12 octets
  type TRI	is record
		    A	: TR;
		    B	: TR;
		    C	: TR;
		  end record;

  --| discriminateur : record plat sans rep clause (8 octets)
  type PAIRE	is record
		    X	: INTEGER;
		    Y	: INTEGER;
		  end record;

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

  --| R2 : paire de TR — LE cas SONDEB2
  D1 := ( DEF => T1A, TYP => T1C );
  D2 := ( DEF => T1B, TYP => T1C );
  ASSERT( D1  = D2, "R2a DI egalite vraie" );
  ASSERT( not (D1 /= D2), "R2b DI inegalite fausse   <== cas SONDEB2" );
  D3 := ( DEF => T1C, TYP => T1A );
  ASSERT( D1 /= D3, "R2c DI inegalite vraie" );

  --| R3 : variable := F(...) puis compare (forme HEAD puis /=)
  D3 := MK( T1A, T1C );
  ASSERT( not (D3 /= D1), "R3 F() en variable puis /=  <== forme du site" );

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

  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "RECEQ_TEST PASSE" );
  else
    PUT_LINE( "RECEQ_TEST ECHOUE" );
  end if;

end RECEQ_TEST;
