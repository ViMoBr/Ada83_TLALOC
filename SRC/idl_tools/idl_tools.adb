WITH TEXT_IO, IDL;
USE  TEXT_IO;					--| LA VERSION ADAPTÉE À LA GESTION DES STRUCTURES DE GRAMMAIRE LALR
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE IDL_TOOLS
--|-------------------------------------------------------------------------------------------------
PROCEDURE IDL_TOOLS IS
    
   C	: CHARACTER;
   L	: NATURAL;
   CMD	: STRING(1..64);
BEGIN
   
  LOOP
    NEW_LINE;
    PUT_LINE ( "-----------------------------------------------" );
    PUT_LINE ( "                OUTILS IDL" );
    PUT_LINE ( "-----------------------------------------------" );
    NEW_LINE;
    PUT_LINE ( "LIRE/VERIF IDL (DONNE NODES_ CLASS_ .LAR) ... R" );
    PUT_LINE ( "ECRIRE TBL (DONNE .LAR NODES) ............... T" );
    PUT_LINE ( "ECRIRE NACN (.ADS) .......................... N" );
    NEW_LINE;
    PUT_LINE ( "QUITTER ..................................... Q" );
    NEW_LINE;
    PUT      ( "                 CHOIX : " );
    GET_LINE ( CMD, L );
    C := CMD( 1 );
    NEW_LINE;

    CASE C IS
    WHEN 'R' | 'T' | 'N' =>
      PUT ( "NOM DE FICHIER DESCRIPTION (SANS EXTENSION .IDL) : " );
      GET_LINE ( CMD, L );
      NEW_LINE;

    WHEN 'Q' =>
      EXIT;

    WHEN OTHERS =>
      NEW_LINE;
    END CASE;
         
    IF C = 'R' THEN
      IDL.IDL_READ ( CMD( 1..L ) );

    ELSIF C = 'T' THEN
      IDL.TBL_PUT ( CMD( 1..L ) );

    ELSIF C = 'N' THEN
      IDL.NAM_PUT ( CMD( 1..L ) );
    END IF;
         
    NEW_LINE;
      
  END LOOP;
   
  PUT_LINE ( "AU REVOIR ..." );
      
--|------------------------------------------------------------------------------------------------
END IDL_TOOLS;
