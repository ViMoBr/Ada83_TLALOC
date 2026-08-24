-----------------------------------------------------------------------------------------------------------------------
--
--	S E L F U N _ T E S T 2   --   temoin de bissection, second etage (aout 2026)
--
--	selfun_test (4 variantes : nom etendu, conversion a marque etendue,
--	.CHAMP sur resultat) est passe ENTIEREMENT : la construction nue est
--	saine. Ce temoin ajoute les deux ingredients restants de l'expression
--	reelle qui plante TARGET_CODE :
--	    IR.LAZY_OF( IR.ELT_ID( E ) ).F
--	  (1) le TYPE DU RESULTAT vient d'un TROISIEME package (fonction dans
--	      IRR, type record dans LEXX) : le designateur .F se resout hors
--	      du package de la fonction ;
--	  (2) l'argument converti est un PARAMETRE DE BOUCLE dont la borne est
--	      elle-meme un appel qualifie (for K in 1 .. IRR.COUNT).
--	Les use sont poses comme dans le temoin reel (use + noms qualifies).
--	Si tout passe encore, le dernier delta est le facteur SOUS-UNITES
--	(corps separate) : temoin multi-fichiers a construire.
--
--	Verdict attendu apres correction : "PASSE selfun_test2", aucun ECHEC.
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;
use TEXT_IO;

procedure		SELFUN_TEST2
is

  N			: INTEGER	:= 2;
  SEEN			: NATURAL	:= 0;
  OK			: BOOLEAN	:= TRUE;

  package		LEXX
  is
    type SL		is
      record
	F		: NATURAL	:= 0;
	L		: NATURAL	:= 0;
      end record;
  end	LEXX;

  package		IRR
  is
    type EID		is range 0 .. 100;
    function IRRCOUNT return NATURAL;
    function LAZY ( X :EID ) return LEXX.SL;				--| resultat d'un TIERS package
  end	IRR;

  package body		IRR
  is
    function		IRRCOUNT return NATURAL
    is
    begin
      return 3;
    end IRRCOUNT;

    function		LAZY ( X :EID ) return LEXX.SL
    is
      R			: LEXX.SL;
    begin
      if X = 2
      then null;
	R.F := 7;							--| seul l'element 2 est "garde"
	R.L := 11;
      end if;
      return R;
    end LAZY;
  end	IRR;

  use LEXX, IRR;

begin

  --  E1 : resultat de type tiers, argument VARIABLE, hors boucle
  if  IRR.LAZY( IRR.EID( N ) ).F /= 7
  then
    OK := FALSE;
    PUT_LINE( "ECHEC E1 : type tiers, variable, hors boucle" );
  end if;

  --  E2 : LA REPLIQUE — parametre de boucle converti, borne = appel
  --       qualifie, .F sur resultat de type tiers, dans le corps de boucle
  for K in 1 .. IRR.IRRCOUNT
  loop
    if IRR.LAZY( IRR.EID( K ) ).F /= 0
    then
      SEEN := SEEN + 1;
    end if;
  end loop;

  if SEEN /= 1
  then
    OK := FALSE;
    PUT_LINE( "ECHEC E2 : parametre de boucle converti" );
  end if;

  --  E3 : meme forme non qualifiee (use)

  SEEN := 0;
  for K in 1 .. IRRCOUNT
  loop
    if  LAZY( EID( K ) ).F /= 0
    then
      SEEN := SEEN + 1;
    end if;
  end loop;

  if SEEN /= 1
  then
    OK := FALSE;
    PUT_LINE( "ECHEC E3 : forme non qualifiee en boucle" );
  end if;

  if OK
  then
    PUT_LINE( "PASSE selfun_test2" );
  end if;
end	SELFUN_TEST2;
