-----------------------------------------------------------------------------------------------------------------------
--
--	F O L D R E J _ T E S T   --   temoin NEGATIF : statique hors gamme (aout 2026)
--
--	CE TEMOIN DOIT ETRE REFUSE A LA COMPILATION (LRM 4.9 : une expression
--	statique dont la valeur sort de la gamme du type est ILLEGALE).
--	Constat du byte-diff TC-04 : TLALOC ENROULE silencieusement
--	16*1024*1024*1024 a 0 dans INTEGER (32 bits) au lieu de refuser —
--	p_memsz ampute de 16 Gio, invisible a l'execution (pages arrondies
--	par le noyau), vu uniquement par le cmp binaire.
--	VERDICT ATTENDU : erreur de compilation sur la ligne ci-dessous.
--	Toute compilation REUSSIE de ce fichier est un ECHEC du temoin.
--	(Ce temoin est donc a executer via le script du filet en mode
--	"compilation doit echouer", pas en mode PASSE/ECHEC d'execution.)
--
-----------------------------------------------------------------------------------------------------------------------

with TEXT_IO;						use TEXT_IO;

procedure		FOLDREJ_TEST
is

  X			: constant INTEGER	:= 16 * 1024 * 1024 * 1024;	--| 2**34 : HORS GAMME INTEGER 32 bits
										--| -> refus statique OBLIGATOIRE ici
begin

  PUT_LINE( "ECHEC foldrej : ce fichier n'aurait pas du compiler,"
	    & " X =" & INTEGER'IMAGE( X ) );

end	FOLDREJ_TEST;
