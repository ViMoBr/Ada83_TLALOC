with TEXT_IO;  use TEXT_IO;

procedure GOTO_SELARG_TEST  is

-- Gardien du piege n 148 : double empilement de l'@data pour un prefixe
-- NOM ETENDU (PKG.ARR( I )) dans CODE_INDEXED.  Reproduit la forme exacte
-- des 6 segfaults du bootstrap T2 (12/08/2026) : table de records au
-- niveau paquetage, index RUNTIME, champ scalaire passe en actuel d'une
-- fonction a resultat STRING, appel en operande de concatenation.
-- Les goto arriere et avant exercent CODE_GOTO/CODE_LABELED du
-- compilateur HOTE quand ce temoin sert de source compilee.
-- Rouge de reference : compile par le T1 d'AVANT le commit n 148, le
-- binaire segfaulte au premier PUT_LINE (BLKMOV, rdi = champ [T(1)+8]).

  package PKG  is
    type REC  is record
		    ID  : INTEGER;		-- occupe [elem+0]
		    LBL : INTEGER;		-- lu a [elem+8] par le bug
		  end record;
    T   : array( 1 .. 4 ) of REC;
    TOP : INTEGER := 3;
  end PKG;

  I : INTEGER := 0;

  function  LSTR ( N : INTEGER )  return STRING  is
    S : constant STRING := INTEGER'IMAGE( N );
  begin
    return 'L' & S( S'FIRST + 1 .. S'LAST );
  end LSTR;

begin
  for K in PKG.T'RANGE  loop
    PKG.T( K ) := ( ID => K, LBL => 10 * K + 2 );
  end loop;

<<ARRIERE>>				-- CODE_LABELED du compilateur hote
  I := I + 1;

  -- la forme fautive : PKG.ARR( index runtime ).champ en actuel,
  -- appel en operande de "&"
  PUT_LINE( "tour" & INTEGER'IMAGE( I ) & " -> " & LSTR( PKG.T( PKG.TOP ).LBL ) );

  if  I < 2  then
    goto ARRIERE;			-- CODE_GOTO arriere du compilateur hote
  end if;

  if  I = 2  then
    goto AVANT;				-- CODE_GOTO avant
  end if;

  PUT_LINE( "jamais atteint" );

<<AVANT>>
  PUT_LINE( "fin -> " & LSTR( PKG.T( 1 ).LBL ) );
end GOTO_SELARG_TEST;
