--| DARREQ_TEST — dossier F5 : egalite de TABLEAUX DERIVES.
--| Isole le R11 de RECEQ2b (suspect du segfault terminal).
--| ORACLE AVANT correctif F5 : comportement fautif attendu (datation).
--| ORACLE APRES : RESULTAT :  3 OK,  0 ECHECS / DARREQ_TEST PASSE.
--| gnat : compilation muette, 3 OK.

with TEXT_IO;	use TEXT_IO;

procedure DARREQ_TEST is

  NB_OK	: INTEGER := 0;
  NB_KO	: INTEGER := 0;

  type ARR3	is array ( 1 .. 3 ) of INTEGER;
  type DARR	is new ARR3;

  B3A	: ARR3 := ( 10, 20, 30 );
  B3B	: ARR3 := ( 10, 20, 31 );

  A1	: DARR;
  A2	: DARR;
  A3	: DARR;

  procedure ASSERT( OK : BOOLEAN; MSG : STRING ) is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_KO := NB_KO + 1;
      PUT_LINE( "ECHEC : " & MSG );
    end if;
  end ASSERT;

begin

  PUT_LINE( "JALON 0" );
  A1 := DARR( B3A );
  A2 := DARR( B3A );
  A3 := DARR( B3B );
  PUT_LINE( "JALON 1" );

  ASSERT( A1  = A2, "F5a DARR egalite vraie" );
  ASSERT( not (A1 /= A2), "F5b DARR inegalite fausse" );
  ASSERT( A1 /= A3, "F5c DARR inegalite vraie" );

  PUT_LINE( "RESULTAT : " & INTEGER'IMAGE( NB_OK ) & " OK, "
	& INTEGER'IMAGE( NB_KO ) & " ECHECS" );
  if  NB_KO = 0  then
    PUT_LINE( "DARREQ_TEST PASSE" );
  else
    PUT_LINE( "DARREQ_TEST ECHOUE" );
  end if;

end DARREQ_TEST;
