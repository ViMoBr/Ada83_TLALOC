-----------------------------------------------------------------------------------------------------------------------
--
--	S E L F U N _ T E S T   --   temoin de bissection (aout 2026)
--
--	Origine : expander plante (idl.adb:332, "PAS D ATTRIBUT SM_DEFN DANS
--	[DN_SELECTED]") sur le temoin P0 de TARGET_CODE, expression :
--	    IR.LAZY_OF( IR.ELT_ID( E ) ).F /= 0
--	Constats prealables : F(args).CHAMP a nom SIMPLE fonctionne (l'expander
--	se compile lui-meme avec D(...).TY partout ; temoin IDL_MAN DABS) ;
--	l'appel QUALIFIE simple fonctionne (IR.ELT_COUNT en borne de boucle,
--	code juste avant le plantage). Le delta est donc dans la combinaison
--	nom etendu / prefixe de composant selectionne / conversion a marque
--	etendue en argument. Les quatre variantes ci-dessous bissectent :
--	la ou les variantes qui plantent localisent la construction fautive.
--	Suspicion : SM_DEFN non pose par le SEMANTISEUR sur le DN_SELECTED du
--	nom d'appel quand l'appel est prefixe d'un .CHAMP ; premiere lecture
--	bruyante cote expander (entree de CODE_DN_BLTN_OPERATOR_ID).
--
--	Verdict attendu apres correction : "PASSE selfun_test", aucun ECHEC.
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		SELFUN_TEST
is

  N			: INTEGER	:= 3;
  OK			: BOOLEAN	:= TRUE;

  package		P
  is
    type ID		is range 0 .. 100;
    type SL		is
      record
	F		: INTEGER	:= 0;
	L		: INTEGER	:= 0;
      end record;
    function MK ( X :ID ) return SL;
  end	P;

  V			: P.SL;

  package body		P
  is
    function		MK ( X :ID ) return SL
    is
      R			: SL;
    begin
      R.F := INTEGER( X );
      R.L := INTEGER( X ) + 1;
      return R;
    end MK;
  end	P;

  use P;								--| pour la variante C (non qualifiee)

begin

  --  A : la forme complete qui a plante TARGET_CODE
  --      (nom etendu + conversion a marque etendue + .CHAMP sur le resultat)
  if P.MK( P.ID( N ) ).F /= 3
  then
    OK := FALSE;
    PUT_LINE( "ECHEC A : P.MK( P.ID( N ) ).F" );
  end if;

  --  B : nom etendu, SANS conversion en argument
  if P.MK( 4 ).F /= 4
  then
    OK := FALSE;
    PUT_LINE( "ECHEC B : P.MK( 4 ).F" );
  end if;

  --  C : nom SIMPLE (use), avec conversion a marque simple
  if MK( ID( N ) ).F /= 3
  then
    OK := FALSE;
    PUT_LINE( "ECHEC C : MK( ID( N ) ).F" );
  end if;

  --  D : contournement par variable intermediaire (doit passer des aujourd'hui)
  V := P.MK( P.ID( N ) );
  if V.F /= 3  or else  V.L /= 4
  then
    OK := FALSE;
    PUT_LINE( "ECHEC D : variable intermediaire" );
  end if;

  if OK
  then
    PUT_LINE( "PASSE selfun_test" );
  end if;

end	SELFUN_TEST;
