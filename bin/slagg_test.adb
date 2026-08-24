------------------------------------------------------------------------------------------------------------------------
-- SLAGG_TEST -- temoin du n 146 (segfault WRITE_LIB) : agregat
-- (others => X) affecte a une TRANCHE.  Avant correctif, le
-- remplissage se fait aux bornes du TYPE depuis le debut de la
-- tranche : la queue du tableau est ecrasee A L'INTERIEUR (plus un
-- debordement au-dela, ici 1..4 octets, silencieux).  La detection est
-- FONCTIONNELLE : simples relectures du tableau, aucun pari sur la
-- disposition memoire.
--
-- Motif calque sur WRITE_LIB.MARK_DONT_MOVE_PAGES :
--     DONT_MOVE( 1 .. HIGH_BLOCK )           := (others=>FALSE);
--     DONT_MOVE( HIGH_BLOCK + 1 .. MAX_VPG ) := (others=>TRUE);
-- bornes de tranche DYNAMIQUES (variable K), composant BOOLEAN.
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO;  use TEXT_IO;

procedure SLAGG_TEST is

  NB_OK  : INTEGER := 0;
  NB_ERR : INTEGER := 0;

  type FLAGS is array ( 1 .. 10 ) of BOOLEAN;

  V : FLAGS;
  K : INTEGER := 4;

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

begin
  V := ( others => FALSE );                    -- tableau ENTIER : voie non-tranche, saine

  V ( 2 .. K ) := ( others => TRUE );          -- LA tranche fautive (bug : remplit 2..11)

  VERDICT (       not V (1),  1 );             -- avant la tranche : intact
  VERDICT (           V (2),  2 );             -- dans la tranche
  VERDICT (           V (4),  3 );             -- dans la tranche (borne haute)
  VERDICT (       not V (5),  4 );             -- APRES la tranche : ECHEC avant correctif
  VERDICT (       not V (10), 5 );             -- fin du tableau   : ECHEC avant correctif

  V ( K + 1 .. 10 ) := ( others => FALSE );    -- 2e vague, motif WRITE_LIB exact

  VERDICT (           V (2),  6 );             -- la 1re tranche doit rester TRUE
  VERDICT (           V (4),  7 );
  VERDICT (       not V (10), 8 );             -- ECHEC avant correctif si vague 2
                                               -- elle-meme decalee/debordante
  PUT_LINE ( "RESULTAT :" & INTEGER'IMAGE (NB_OK) & " OK," & INTEGER'IMAGE (NB_ERR) & " ECHECS" );
  if NB_ERR = 0 then
    PUT_LINE ( "SLAGG_TEST PASSE" );
  else
    PUT_LINE ( "SLAGG_TEST ECHOUE" );
  end if;

end SLAGG_TEST;
