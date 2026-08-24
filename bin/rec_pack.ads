------------------------------------------------------------------------------------------------------------------------
-- REC_PACK (spec) -- temoin des composants tableau de record (correctifs USEINFO / CODE_INDEXED, aout 2026)
-- Miroir de LEX.LINE_OF_SOURCE : constante de borne + composant STRING(1..MAX) anonyme, DANS UN PACKAGE
-- compile spec puis corps (rechargement DCL = surface du bug d'origine).
------------------------------------------------------------------------------------------------------------------------
package REC_PACK is

  MAX	: constant POSITIVE := 8;

  type LIGNE	is record
		    LEN	: NATURAL;
		    BDY	: STRING( 1 .. MAX );			-- sous-type ANONYME (le cas LINE_OF_SOURCE)
		  end record;

  type PAIRE	is record
		    A	: STRING( 1 .. 4 );			-- DEUX sous-types anonymes du MEME type de base :
		    B	: STRING( 1 .. 6 );			-- juge de la collision de l'ancien " namespace _STRING"
		  end record;

  subtype S4	is STRING( 1 .. 4 );

  type RSUB	is record
		    C	: S4;					-- composant de sous-type NOMME (chemin nomme, non-regression)
		  end record;

  type TVEC	is array ( 1 .. 3 ) of INTEGER;

  type RVEC	is record
		    V	: TVEC;					-- composant de type NOMME non-STRING (non-regression)
		  end record;

  GLOB	: LIGNE;						-- objet de niveau package, indexe depuis le corps ET depuis le main
  PATHV	: STRING( 1 .. 4 );					-- variables package : operandes de "&" inter-unites (S8)
  NOMV	: STRING( 1 .. 16 );

  procedure	SET	( L : in out LIGNE;  S : STRING );
  procedure	POSE	( L : in out LIGNE;  I : POSITIVE;  C : CHARACTER );
  function	GET	( L : LIGNE;  I : POSITIVE )	return CHARACTER;

end REC_PACK;
