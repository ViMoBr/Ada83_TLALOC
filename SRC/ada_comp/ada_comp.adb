--	ADA_COMP.ADB	VINCENT MORIN	21/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2	3	4	5	6	7	8	9	0

with TEXT_IO, CALENDAR;
use  TEXT_IO, CALENDAR;
with IDL, CODE_GEN;
				--------
	procedure			ADA_COMP
is				--------
														
  COMMAND			: STRING( 1..512 );						--| PRESENTEE AU STDIN
  CMD_LENGTH		: NATURAL;

  ACCES_TEXTE		: STRING( 1..256 );
  ACCES_TEXTE_LENGTH	: NATURAL;

  OPTION			: CHARACTER;
  TIME_1, TIME_2		: CALENDAR.TIME;
begin

  GET_LINE( COMMAND, CMD_LENGTH );

  declare
    NC1	: NATURAL	:= 1;								--| INDICE DEBUT DE CHAINE
    NC2	: NATURAL	:= 0;								--| INDICE POST CHAINE
  begin

ISOLE_PROJECT_DIR_PATH:								--| ISOLER DANS IDL.PROJECT_PATH LA CHAINE PARAMETRE CHEMIN DE REPERTOIRE PROJET
    begin
      loop exit when COMMAND( NC1 ) /= ' '; NC1 := NC1 + 1; end loop;
      NC2 := NC1 + 1;
      loop exit when COMMAND( NC2 ) = ' ';  NC2 := NC2 + 1; end loop;

      IDL.PROJECT_PATH_LENGTH := NC2 - NC1;
      IDL.PROJECT_PATH( 1..IDL.PROJECT_PATH_LENGTH ) := COMMAND( NC1 .. NC2-1 );
    end ISOLE_PROJECT_DIR_PATH;

    IDL.LIB_PATH_LENGTH := IDL.PROJECT_PATH_LENGTH + IDL.DEFAULT_LIB_PATH'LENGTH;
    IDL.LIB_PATH( 1..IDL.LIB_PATH_LENGTH )
	:= IDL.PROJECT_PATH( 1 .. IDL.PROJECT_PATH_LENGTH )
	   & IDL.DEFAULT_LIB_PATH;

ISOLE_RELATIVE_SOURCE_PATH:								--| ISOLER DANS ACCES_TEXTE LA CHAINE PARAMETRE CHEMIN DE TEXTE SOURCE
    begin
      NC1 := NC2;
      loop exit when COMMAND( NC1 ) /= ' '; NC1 := NC1 + 1; end loop;
      NC2 := NC1 + 1;
      loop exit when COMMAND( NC2 ) = ' ';  NC2 := NC2 + 1; end loop;

      ACCES_TEXTE_LENGTH := (NC2 - NC1);
      ACCES_TEXTE( 1..ACCES_TEXTE_LENGTH ) := COMMAND( NC1 .. NC2-1 );

    end ISOLE_RELATIVE_SOURCE_PATH;

ISOLE_OPTION:									--| ISOLER DANS OPTION LE CARACTERE OPTION D'ARRET
    begin
      NC1 := NC2;
      loop exit when COMMAND( NC1 ) /= ' '; NC1 := NC1 + 1; end loop;
      OPTION := COMMAND( NC1 );
    end ISOLE_OPTION;
  end;

  if OPTION = 'U' or OPTION = 'P' or OPTION = 'A' then
    IDL.PRETTY_DIANA( OPTION );
    return;
  end if;

  PUT_LINE ( "ADA83 " & ACCES_TEXTE( 1..ACCES_TEXTE_LENGTH ) );				--| INDIQUER CE QUE L'ON COMPILE
  TIME_1 := CLOCK;									--| AMORCER LE CHRONOMETRAGE


  declare
    POSITION_SEPARATEUR	: NATURAL	:= ACCES_TEXTE_LENGTH;
  begin
DEBUT_NOM_TEXTE:
    while ACCES_TEXTE( POSITION_SEPARATEUR ) /= '/' loop
      POSITION_SEPARATEUR := POSITION_SEPARATEUR - 1;
      exit when POSITION_SEPARATEUR = 0;
    end loop DEBUT_NOM_TEXTE;

    IDL.PAR_PHASE (	IDL.PROJECT_PATH( 1 .. IDL.PROJECT_PATH_LENGTH ) & ACCES_TEXTE( 1 .. POSITION_SEPARATEUR ),
		ACCES_TEXTE( POSITION_SEPARATEUR+1 .. ACCES_TEXTE_LENGTH ),
		IDL.LIB_PATH );
		if OPTION = 'S' then goto FIN; end if;
  end;

  IDL.LIB_PHASE;					if OPTION = 'L' then goto FIN; end if;	--| CHARGEMENT DES WITH
  IDL.SEM_PHASE;					if OPTION = 'M' then goto FIN; end if;	--| ANALYSE SEMANTIQUE
  IDL.ERR_PHASE ( ACCES_TEXTE( 1.. ACCES_TEXTE_LENGTH ) );	if OPTION = 'E' then goto FIN; end if;	--| TRAITEMENT D'ERREURS
  IDL.WRITE_LIB;					if OPTION = 'W' then goto FIN; end if;	--| ECRITURE EN LIBRAIRIE
  CODE_GEN;

<<FIN>>
  TIME_2 := CLOCK;									--| TERMINER LE CHRONOMETRAGE
  PUT( "..Ok" & INTEGER'IMAGE( INTEGER( 1000 * (TIME_2 - TIME_1) ) ) & " msec" );		--| ET AFFICHER

	--------
end	ADA_COMP;
	--------

pragma PAGE;

-----------------------------------------------------------------------------------------------------------------------------------

--						ADA_COMP

--	La procedure ADA_COMP est le point d'entree du compilateur Ada 83.
--	La commande est presentee au STANDARD_INPUT sous la forme de trois chaines :
--
--		CHEMIN_REPERTOIRE_PROJET   CHEMIN_RELATIF_SOURCE  LETTRE_OPTION
--
--	Le chemin du repertoire projet est soit un absolu vers le repertoire dans lequel est le dossier librairie ADA_LIB,
-- soit un relatif a ce meme dossier projet par rapport dossier contenant l'executable du compilateur.
-- Ce chemin se termine par le nom du repertoire projet (pas de / final).
--	Le chemin relatif vers le fichier texte source a compiler est relatif au dossier projet.
--	La lettre option indique l'etape a laquelle le compilateur s'arrete, ou une option d'impression de l'arbre DIANA :
--
--		S	arret apres analyse syntaxique
--		L	arret apres la phase de lecture de librairie
--		M	arret apres analyse semantique
--		E	arret apres la phase de traitement d'erreur
--		W	arret apres la phase d'ecriture en librairie
--		U	impression
--		P	impression des noeuds syntaxiques seulement
--		A	impression de tous les noeuds
--
--	Comme il n'y a pas de passage de parametre en Ada 83, la chaine commande est soit entree a la main, soit presentee
-- par le shell a l'aide d'une commande du genre :
--
--		./ada_comp <<< "$1 $2 $3"
--
--	En fonction des parametres, ADA_COMP appelle l'une des 6 procedures :
--		IDL.PAR_PHASE
--		IDL.LIB_PHASE
--		IDL.SEM_PHASE
--		IDL.ERR_PHASE
--		IDL.WRITE_LIB
--		CODE_GEN
--		IDL.PRETTY_DIANA
--
--	VINCENT MORIN	21/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE	(UBO)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
