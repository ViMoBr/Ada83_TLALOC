------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--
--	E N U M C S T _ T E S T   --   temoin de bissection TLALOC
--
--	Bug releve le 19 aout 2026 (tranche TC-10, target_code-lex.adb) :
--	une CONSTANTE de type discret (enumere) initialisee DYNAMIQUEMENT,
--	utilisee comme parametre actuel, plante l'expander :
--	    raised PROGRAM_ERROR : idl.adb:432 explicit raise
--	    !! L ATTRIBUT SM_VALUE DU NOEUD [DN_USED_OBJECT_ID...]
--	       N EST PAS UN ENTIER
--	L'expander suppose statique toute constante discrete et lit
--	SM_VALUE pour l'emettre en litteral. LRM 83 : une constante n'est
--	pas necessairement statique (3.2.1 ; statique = 4.9).
--
--	Trois cas pour la bissection :
--	  K_STATIC  : constante a initialisation LITTERALE  -> attendu OK
--	  V_DYNAMIC : VARIABLE  a initialisation dynamique  -> attendu OK
--	  K_DYNAMIC : CONSTANTE a initialisation dynamique  -> PLANTAGE
--	Verdict a l'execution (une fois compilable) : affiche "OK 1 2 3".
--
------------------------------------------------------------------------------------------------------------------------

with TEXT_IO;
use  TEXT_IO;

procedure		ENUMCST_TEST
is

  type COLOR		is ( RED, GREEN, BLUE );

  BOX			: array ( 1 .. 3 ) of COLOR := ( GREEN, RED, BLUE );

  HIT			: NATURAL	:= 0;

  K_STATIC		: constant COLOR := GREEN;			--| cas 1 : statique, doit passer
  V_DYNAMIC		: COLOR		 := BOX( 1 );			--| cas 2 : variable dynamique, doit passer
  K_DYNAMIC		: constant COLOR := BOX( 1 );			--| cas 3 : CONSTANTE dynamique, plante idl.adb:432

  procedure		TOUCH ( C :COLOR )
  is
  begin
    if C = GREEN
    then
      HIT := HIT + 1;
    end if;
  end TOUCH;

begin
  TOUCH( K_STATIC );
  TOUCH( V_DYNAMIC );
  TOUCH( K_DYNAMIC );
  if HIT = 3
  then
    PUT_LINE( "OK 1 2 3" );
  else
    PUT_LINE( "ECHEC : HIT =" & NATURAL'IMAGE( HIT ) );
  end if;
end	ENUMCST_TEST;
