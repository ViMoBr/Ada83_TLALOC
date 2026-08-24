------------------------------------------------------------------------------------------------------------------------
-- OPB_TEST -- temoin minimal, chantier "erreur type A" (comparaisons
-- UARITH toutes FAUSSES sous T2 : @IB3 = FFFFFF, reference T1 = TFTTTT).
--
-- HYPOTHESE CIBLEE (a confirmer/infirmer par ce temoin) : les six
-- comparaisons couvrent trois configurations mathematiques disjointes
-- (signe, egalite, longueurs differentes) -- une corruption des DONNEES
-- du VECTOR ne peut pas rendre les six fausses a la fois. Le seul
-- mecanisme qui les uniformise est que le RESULTAT BOOLEAN de
-- l'operateur n'arrive jamais a l'appelant : le "LI 0" pousse comme
-- lieu-resultat au site d'appel est relu tel quel (0 = FALSE, toujours).
-- Famille presumee : protocole d'appel / epilogue des operateurs
-- utilisateur a resultat SCALAIRE et operandes RECORD REPRESENTE 32
-- bits (TREE) -- la case que OPDEF_TEST ne couvre pas : ses checks 1-4
-- portent des operandes records ORDINAIRES (doublets), et le "<" vers
-- BOOLEAN y prend ces memes operandes. Ici : operandes = record
-- REPRESENTE (passe comme scalaire 32 bits, cf. IS_SMALL_REP_RECORD),
-- resultat = BOOLEAN. C'est exactement la signature des ">="/"<=" 
-- BOOLEAN d'UARITH (TREE, TREE) return BOOLEAN.
--
-- Motif NODE calque sur TREE (PT 2 bits, 32 bits au total, rep clause).
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO;  use TEXT_IO;

procedure OPB_TEST is

  NB_OK  : INTEGER := 0;
  NB_ERR : INTEGER := 0;

  package P is

    type NODE is record
      PT : INTEGER range 0 .. 3;
      LN : INTEGER range 0 .. 16383;
      PG : INTEGER range 0 .. 65535;
    end record;

    for NODE use record at mod 4;
      PT at 0 range 0 .. 1;
      LN at 0 range 2 .. 15;
      PG at 0 range 16 .. 31;
    end record;
    for NODE'SIZE use 32;

    function ">=" ( LEFT, RIGHT : NODE ) return BOOLEAN;
    function "<=" ( LEFT, RIGHT : NODE ) return BOOLEAN;
    function ">=" ( LEFT, RIGHT : NODE ) return NODE;
    function "<=" ( LEFT, RIGHT : NODE ) return NODE;
    function MK  ( V : INTEGER )        return NODE;
    function GEB ( LEFT, RIGHT : NODE ) return BOOLEAN;

  end P;
  use P;

  A, B, C : NODE;
  R       : BOOLEAN;

  package body P is

    function ">=" ( LEFT, RIGHT : NODE ) return BOOLEAN is
    begin
      return LEFT.PG >= RIGHT.PG;               -- ">=" INTEGER : predefini, pas de recursion (cf. n 140)
    end ">=";

    function "<=" ( LEFT, RIGHT : NODE ) return BOOLEAN is
    begin
      return LEFT.PG <= RIGHT.PG;
    end "<=";

    function ">=" ( LEFT, RIGHT : NODE ) return NODE is
      R : NODE;
    begin
      R.PT := 0;  R.LN := 0;
      if LEFT.PG >= RIGHT.PG then R.PG := 1; else R.PG := 0; end if;
      return R;
    end ">=";

    function "<=" ( LEFT, RIGHT : NODE ) return NODE is
      R : NODE;
    begin
      R.PT := 0;  R.LN := 0;
      if LEFT.PG <= RIGHT.PG then R.PG := 1; else R.PG := 0; end if;
      return R;
    end "<=";

    function MK ( V : INTEGER ) return NODE is
      R : NODE;
    begin
      R.PT := 0;  R.LN := 0;  R.PG := V;
      return R;
    end MK;

    function GEB ( LEFT, RIGHT : NODE ) return BOOLEAN is
    begin
      return ( LEFT >= RIGHT ) = MK (1);       -- motif UARITH exact :
    end GEB;                                   -- egalite _NODE, gauche parenthesee

  end P;

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
  A.PT := 1;  A.LN := 10;  A.PG := 5;           -- affectations de composantes (pas d'agregat :
  B.PT := 1;  B.LN := 10;  B.PG := 3;           -- on reste dans le corpus prouve, CODE_STORE_REP_COMPONENT)
  C.PT := 1;  C.LN := 10;  C.PG := 5;

  -- 1..4 : forme condition de if -- le motif EXACT de la sonde @IB3
  if A >= B then VERDICT (TRUE, 1);  else VERDICT (FALSE, 1); end if;
  if B <= A then VERDICT (TRUE, 2);  else VERDICT (FALSE, 2); end if;
  if A <= B then VERDICT (FALSE, 3); else VERDICT (TRUE, 3);  end if;   -- attendu FAUX
  if A >= C then VERDICT (TRUE, 4);  else VERDICT (FALSE, 4); end if;   -- cas d'EGALITE

  -- 5..6 : resultat affecte a une variable BOOLEAN
  R := A >= B;   VERDICT (R, 5);
  R := A <= C;   VERDICT (R, 6);                                        -- cas d'EGALITE

  -- 7 : resultat passe directement en parametre effectif
  VERDICT (B <= C, 7);

  -- 8 : appel depuis un sous-programme imbrique (niveau lexical superieur,
  --     comme DEF_WALK appelant UARITH)
  declare
    procedure DEEP is
    begin
      if C >= B then VERDICT (TRUE, 8); else VERDICT (FALSE, 8); end if;
    end DEEP;
  begin
    DEEP;
  end;

  -- 9..10 : version NODE des homonymes (contexte d'affectation NODE)
  declare
    N : NODE;
  begin
    N := A >= B;
    VERDICT (N.PG = 1, 9);
    N := A <= B;
    VERDICT (N.PG = 0, 10);
  end;

  -- 11..12 : le motif UARITH (egalite de records representes, operande
  -- gauche = appel d'operateur PARENTHESE) -- gardien du n 112-5e
  VERDICT (GEB (A, B), 11);
  VERDICT (not GEB (B, A), 12);

  PUT_LINE ( "RESULTAT :" & INTEGER'IMAGE (NB_OK) & " OK," & INTEGER'IMAGE (NB_ERR) & " ECHECS" );
  if NB_ERR = 0 then
    PUT_LINE ( "OPB_TEST PASSE" );
  else
    PUT_LINE ( "OPB_TEST ECHOUE" );
  end if;

end OPB_TEST;
