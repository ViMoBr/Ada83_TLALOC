-------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	ADA_COMP.ADB	VINCENT MORIN	21/6/2024		UNIVERSITE DE BRETAGNE OCCIDENTALE
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2


--				          |
--				       \\ | //
--				     \\ u ^ u //		/-------_______------\
--				   \ )Y|Y|Y|Y|Y( /	  	|  T  h e            |
--				     / /o o o\ \	     	|  L  o n e s o m e  |
--				    \|H|H|H|H|H|/		|  A  d a            |
--				   G))  Q   Q  ((G	   	|  L  o v i n g      |
--				    / \   "   / \ 	   	|  O  l't i m e r    |
--				   /_/  \V¨V/  \_\	   	|  C  o m p i l e r  |
--				       \vvvvv/	     	\-------______-------/
--				     \ooooooooo/


with TEXT_IO, CALENDAR;
use  TEXT_IO, CALENDAR;
with IDL, CODE_GEN;

					--====--
		procedure			ADA_COMP


is

  CMD_FROM_STDIN		: STRING( 1..512 );
  CMD_LENGTH		: NATURAL;

  ACCES_TEXTE		: STRING( 1..256 );
  ACCES_TEXTE_LENGTH	: NATURAL;

  NO_OPTION_GIVEN		: BOOLEAN		:= FALSE;
  OPTION			: CHARACTER;

  START_TIME, END_TIME	: CALENDAR.TIME;

begin
  GET_LINE( CMD_FROM_STDIN, CMD_LENGTH );

  declare
    CHN_START		: NATURAL	:= CMD_FROM_STDIN'FIRST;
    POST_CHN		: NATURAL	:= 0;

  begin				----------------------
				ISOLE_PROJECT_DIR_PATH:
    begin
FIND_START_1:
      loop
        exit when  CMD_FROM_STDIN( CHN_START ) /= ' ';
        CHN_START := CHN_START + 1;
      end loop  FIND_START_1;
      POST_CHN := CHN_START + 1;
FIND_POST_END_1:
      loop
        exit when  CMD_FROM_STDIN( POST_CHN ) = ' ';
        POST_CHN := POST_CHN + 1;
      end loop  FIND_POST_END_1;

      IDL.PROJECT_PATH_LENGTH	:= POST_CHN - CHN_START;
      IDL.PROJECT_PATH( 1 .. IDL.PROJECT_PATH_LENGTH )
			:= CMD_FROM_STDIN( CHN_START .. POST_CHN-1 );

    end	ISOLE_PROJECT_DIR_PATH;
	----------------------


    IDL.LIB_PATH_LENGTH	:= IDL.PROJECT_PATH_LENGTH + IDL.DEFAULT_LIB_PATH'LENGTH;
    IDL.LIB_PATH( 1..IDL.LIB_PATH_LENGTH )
			:= IDL.PROJECT_PATH( 1 .. IDL.PROJECT_PATH_LENGTH )
			   & IDL.DEFAULT_LIB_PATH;


				--------------------------
				ISOLE_RELATIVE_SOURCE_PATH:
    begin
      CHN_START := POST_CHN;
FIND_START_2:
      loop
        exit when  CMD_FROM_STDIN( CHN_START ) /= ' ';
        CHN_START := CHN_START + 1;
      end loop  FIND_START_2;
      POST_CHN := CHN_START + 1;
FIND_POST_END_2:
      loop
        exit when  CMD_FROM_STDIN( POST_CHN ) = ' ';
        POST_CHN := POST_CHN + 1;
        if  POST_CHN > CMD_FROM_STDIN'LAST  then
	NO_OPTION_GIVEN := TRUE;
        end if;
      end loop  FIND_POST_END_2;

      ACCES_TEXTE_LENGTH	:= (POST_CHN - CHN_START);
      ACCES_TEXTE( 1..ACCES_TEXTE_LENGTH ) := CMD_FROM_STDIN( CHN_START .. POST_CHN-1 );

    end	ISOLE_RELATIVE_SOURCE_PATH;
	--------------------------

    if  NO_OPTION_GIVEN
    then  OPTION := 'S';
    else
				------------
				ISOLE_OPTION:							--| ISOLER DANS OPTION LE CARACTERE OPTION D'ARRET
      begin
        CHN_START := POST_CHN;
FIND_START_3:
        loop
	exit when  CMD_FROM_STDIN( CHN_START ) /= ' ';
	CHN_START := CHN_START + 1;
        end loop  FIND_START_3;
        OPTION := CMD_FROM_STDIN( CHN_START );

      end	ISOLE_OPTION;
	------------
    end if;
  end;

  if  OPTION = 'U'  or  OPTION = 'P'  or  OPTION = 'A'  then
    IDL.PRETTY_DIANA( OPTION );
    return;
  end if;

  START_TIME := CLOCK;
				-----------------------
				SEPARE_PATH_NOM_EXECUTE:

  declare
    POSITION_SEPARATEUR	: NATURAL	:= ACCES_TEXTE_LENGTH;

  begin

DEBUT_NOM_TEXTE:
    while  ACCES_TEXTE( POSITION_SEPARATEUR ) /= '/'  loop
      POSITION_SEPARATEUR := POSITION_SEPARATEUR - 1;
      exit when  POSITION_SEPARATEUR = 0;
    end loop  DEBUT_NOM_TEXTE;


    declare
      CHEMIN_TEXTE	:constant STRING	:= IDL.PROJECT_PATH( 1 .. IDL.PROJECT_PATH_LENGTH )
				      & ACCES_TEXTE( 1 .. POSITION_SEPARATEUR );
      NOM_TEXTE	:constant STRING	:= ACCES_TEXTE( POSITION_SEPARATEUR+1 .. ACCES_TEXTE_LENGTH );

    begin
      IDL.PAR_PHASE( CHEMIN_TEXTE, NOM_TEXTE, IDL.LIB_PATH );
				if  OPTION = 'S'  or  OPTION = 's'  then goto FIN; end if;
      IDL.LIB_PHASE;		if  OPTION = 'L'  or  OPTION = 'l'  then goto FIN; end if;
      IDL.SEM_PHASE;		if  OPTION = 'M'  or  OPTION = 'm'  then goto FIN; end if;

      if  OPTION = 'C'  or  OPTION = 'W'  then
        CODE_GEN;
      end if;

<<FIN>>
      IDL.ERR_PHASE( CHEMIN_TEXTE & NOM_TEXTE );

      if  OPTION = 'W' or OPTION = 'w'  then  IDL.WRITE_LIB;  end if;

      END_TIME := CLOCK;
      PUT_LINE( " ..... Ok" & INTEGER'IMAGE( INTEGER( 1000 * (END_TIME - START_TIME) ) ) & " msec" );

    exception
      when NAME_ERROR => null;
    end;

  end	SEPARE_PATH_NOM_EXECUTE;
	-----------------------

end	ADA_COMP;
	--====--
