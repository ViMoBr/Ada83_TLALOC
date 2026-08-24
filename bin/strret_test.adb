------------------------------------------------------------------------------------------------------------------------
-- STRRET_TEST -- gardien du CONTRAT D'EVASION de la co-pile (n 147).
--
-- Les fonctions a resultat dynamique (STRING) laissent leurs donnees
-- sur la co-pile du CALLE ; l'appelant les consomme APRES le retour,
-- y compris en les passant a un appel suivant (dont le LINK alloue
-- au-dessus).  Tout remaniement de la co-pile (retour glissant,
-- marques de relache, restauration de r14...) DOIT laisser ce temoin
-- vert.  C'est le motif qui a revoque R1 : sous R1, les tetes des
-- chaines retournees etaient ecrasees par le frame du consommateur
-- (constate sur _standrd : noms manges, puis PROGRAM_ERROR).
--
-- Couverture : resultat STRING consomme par un appel (le cas
-- _standrd), catenation de DEUX resultats de fonction (deux evades
-- vivants en meme temps), imbrication F(G(..)), resultat dynamique
-- dont la taille depend du parametre, et comparaison apres un appel
-- interpose (la fenetre la plus large).
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO;  use TEXT_IO;

procedure STRRET_TEST is

  NB_OK  : INTEGER := 0;
  NB_ERR : INTEGER := 0;

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

  function STARS ( N : INTEGER ) return STRING is
    S : STRING ( 1 .. N );                       -- taille dynamique -> co-pile du calle
  begin
    for I in 1 .. N loop
      S (I) := '*';
    end loop;
    return S;                                    -- le resultat S'EVADE
  end STARS;

  function BRACKET ( S : STRING ) return STRING is
  begin
    return '[' & S & ']';                        -- consomme un evade, en produit un autre
  end BRACKET;

  function NOOP ( X : INTEGER ) return INTEGER is
  begin
    return X;                                    -- appel interpose : LINK/UNLINK purs
  end NOOP;

  V : INTEGER;

begin
  -- 1 : resultat passe DIRECTEMENT a l'appel suivant (le cas _standrd :
  --     PUT_LINE(nom) -- le LINK de PUT_LINE alloue au-dessus de l'evade)
  PUT_LINE ( STARS ( 5 ) );
  VERDICT ( TRUE, 1 );                           -- la sortie visuelle "*****" fait foi

  -- 2 : longueur et contenu d'un evade simple
  VERDICT ( STARS ( 7 )'LENGTH = 7,       2 );
  VERDICT ( STARS ( 3 )  = "***",         3 );

  -- 3 : catenation de DEUX resultats de fonction (deux evades vivants)
  VERDICT ( STARS ( 2 ) & STARS ( 3 ) = "*****",  4 );

  -- 4 : imbrication F(G(..)) -- l'evade interne traverse le LINK de F
  VERDICT ( BRACKET ( STARS ( 4 ) ) = "[****]",   5 );
  VERDICT ( BRACKET ( BRACKET ( STARS ( 1 ) ) ) = "[[*]]",  6 );

  -- 5 : appel INTERPOSE entre production et consommation de l'evade
  declare
    S : STRING ( 1 .. 6 ) := STARS ( 6 );        -- copie immediate dans du stockage local
  begin
    V := NOOP ( 42 );                            -- LINK/UNLINK par-dessus la zone rendue
    VERDICT ( S = "******" and V = 42,  7 );     -- la COPIE doit survivre, elle
  end;

  PUT_LINE ( "RESULTAT :" & INTEGER'IMAGE (NB_OK) & " OK," & INTEGER'IMAGE (NB_ERR) & " ECHECS" );
  if NB_ERR = 0 then
    PUT_LINE ( "STRRET_TEST PASSE" );
  else
    PUT_LINE ( "STRRET_TEST ECHOUE" );
  end if;

end STRRET_TEST;
