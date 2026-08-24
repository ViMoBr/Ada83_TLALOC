------------------------------------------------------------------------------------------------------------------------
-- COPILE_TEST -- temoin du n 147 (segfault text_io.adb, epuisement de
-- co-pile) : la macro UNLINK ne rendait jamais r14.
--
-- Phase 1 : 30 000 000 d'appels d'une fonction triviale.  Avant
-- correctif : >= 8 octets de co-pile fuient par appel (la cellule
-- LINK), soit >= 240 Mo sur une arene d'environ 140 Mo -> SEGFAULT
-- garanti bien avant la fin.  Apres correctif : consommation
-- constante, boucle en quelques secondes.
--
-- Phase 2 : 200 000 appels d'une procedure a tableau local de TAILLE
-- DYNAMIQUE (parametre) -> alloue par CO_VAR ; ecrit puis relu pour
-- valider la recuperation ET l'absence de use-after-free sur le motif
-- standard (resultat/donnees consommes avant tout LINK interpose).
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO;  use TEXT_IO;

procedure COPILE_TEST is

  NB_OK  : INTEGER := 0;
  NB_ERR : INTEGER := 0;
  V : INTEGER;

  procedure VERDICT ( OK : BOOLEAN; NUM : INTEGER ) is
  begin
    if OK then
      NB_OK := NB_OK + 1;
      PUT_LINE ( "check" & INTEGER'IMAGE (NUM) & " OK" );
    else
      NB_ERR := NB_ERR + 1;
      PUT_LINE ( "check" & INTEGER'IMAGE (NUM) & " ECHEC" );
    end if;
  end VERDICT;

  function INCR ( X : INTEGER ) return INTEGER is
  begin
    return X + 1;                                -- LINK/UNLINK a chaque appel : 8 octets
  end INCR;                                      -- de co-pile fuyaient ici, a vie

  function SUM_DYN ( N : INTEGER ) return INTEGER is
    A : array ( 1 .. N ) of INTEGER;             -- taille dynamique -> CO_VAR
    S : INTEGER := 0;
  begin
    for I in 1 .. N loop
      A (I) := I;
    end loop;
    for I in 1 .. N loop
      S := S + A (I);
    end loop;
    return S;                                    -- CO_VAR rendus a l'UNLINK apres correctif
  end SUM_DYN;

begin
  ----------------------------------------------------------------  phase 1
  V := 0;
  for I in 1 .. 30_000_000 loop
    V := INCR ( V );
  end loop;
  PUT_LINE ( "phase 1 terminee" );               -- n'apparait PAS avant correctif (segfault)
  VERDICT ( V = 30_000_000, 1 );

  ----------------------------------------------------------------  phase 2
  V := 0;
  for I in 1 .. 200_000 loop
    V := SUM_DYN ( 20 );                         -- 20*4 octets de CO_VAR par appel
  end loop;
  PUT_LINE ( "phase 2 terminee" );
  VERDICT ( V = 210, 2 );                        -- 1+..+20

  VERDICT ( SUM_DYN ( 100 ) = 5050,  3 );        -- tailles variables
  VERDICT ( SUM_DYN ( 1 )   = 1,     4 );

  PUT_LINE ( "RESULTAT :" & INTEGER'IMAGE (NB_OK) & " OK," & INTEGER'IMAGE (NB_ERR) & " ECHECS" );
  if NB_ERR = 0 then
    PUT_LINE ( "COPILE_TEST PASSE" );
  else
    PUT_LINE ( "COPILE_TEST ECHOUE" );
  end if;

end COPILE_TEST;
