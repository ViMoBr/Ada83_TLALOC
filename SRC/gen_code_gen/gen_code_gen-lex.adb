separate ( GEN_CODE_GEN )
					---
		package body		LEX
					---

is
      
  FE		: FILE_TYPE;									--| LE FICHIER D'ENTREE CONTENANT LES SECTIONS DE CODEGEN
  S		: STRING( 1.. 256 );								--| TAMPON POUR UNE LIGNE DE CE FICHIER
  L		: NATURAL	:= 0;									--| LONGUEUR DE LA LIGNE
      
  COL		: POSITIVE	:= NATURAL'LAST;							--| COLONNE COURANTE SUR LA LIGNE
  TOK_START	: POSITIVE;									--| DEBUT
  TOK_END		: NATURAL;									--| ET FIN DU LEXEME
      
		------
  procedure	AVANCE
  is		------
  begin
    GET_A_TOKEN:
    loop												--| BOUCLER TANT QUE L'ON A PAS UN LEXEME VALIDE
    
      if COL > L then										--| ON EST EN FIN DE LIGNE
        loop											--| BOUCLE POUR PASSER LES LIGNES NE CONCERNANT PAS CODEGEN (NE COMMENCANT PAS PAR "##")
          if END_OF_FILE ( FE ) then									--| ON EST EN FIN DE FICHIER
            S( 1..3 ) := "END";									--| METTRE "END" COMME LEXEME
            TOK_START := 1;										--| DEBUTE EN 1
            TOK_END := 3;										--| FINIT EN 3
            exit GET_A_TOKEN;										--| SORTIR DE LA BOUCLE
          else											--| ON EST PAS EN FIN DE FICHIER
            GET_LINE ( FE, S, L );									--| PRENDRE UNE LIGNE DU FICHIER
            LINE_NBR := LINE_NBR + 1;									--| LA COMPTER
            exit when S( 1..2 ) = "##";									--| NE SORTIR QUE SI LA LIGNE COMMENCE PAR "##" INDIQUANT UN LIGNE POUR CODEGEN
          end if;
        end loop;
        COL := 3;											--| COLONNE JUSTE APRÈS ## (POSITIONS 1 ET 2)
      end if;
	--| ON EST SUR UNE LIGNE POUR CODEGEN (D'ABORD PASSER LES ESPACES)
      while COL <= L and then ( (S( COL ) = ASCII.HT) or (S( COL ) = ' ' and not SEPA_TAB_ONLY) ) loop
        COL := COL + 1;
      end loop;
            
      if COL <= L then										--| IL N'Y A PAS QUE DES ESPACES
        TOK_START := COL;										--| DEBUT DU LEXEME A LA COLONNE
        TOK_END := COL;										--| INITIALISER LA FIN DE LEXEME À LA MEME VALEUR
	--| ACCUMULER LES CARACTERES DU LEXEME, ARRET SUR ESPACE
        while COL <= L and then ( (S( COL ) /= ASCII.HT) and not (S( COL ) = ' ' and not SEPA_TAB_ONLY) ) loop
          COL := COL + 1;
        end loop;
	--| SI LE LEXEME EST UNE INDICATION DE COMMENTAIRE "--"
        if S( TOK_START..TOK_START+1 ) = "--" then
          COL := L+1;										--| ALLER À LA FIN DE LA LIGNE
        else
          TOK_END := COL-1;										--| REMETTRE LA FIN DE LEXEME A SA PLACE
          return;											--| C'EST OK
        end if;
      end if;
               
    end loop GET_A_TOKEN;
  end AVANCE;

		------
  function	LEXEME			return STRING
  is		------
  begin
    return S( TOK_START..TOK_END );
  end LEXEME;

		-------
  procedure	RE_INIT
  is		-------
  begin
    L := 0;
    COL := NATURAL'LAST;
    RESET ( FE );
    AVANCE;
  end RE_INIT;

		-------
  procedure	LEX_END
  is		-------
  begin
    CLOSE ( FE );
  end LEX_END;

      
begin
  OPEN ( FE, IN_FILE, "../IDL/DIANA_CODE_GEN.IDL" );
  AVANCE;
end LEX;
