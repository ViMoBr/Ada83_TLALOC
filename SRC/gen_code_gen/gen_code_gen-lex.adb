SEPARATE ( GEN_CODE_GEN )
						---
			PACKAGE BODY		LEX
						---

IS
      
  FE		: FILE_TYPE;									--| LE FICHIER D'ENTREE CONTENANT LES SECTIONS DE CODEGEN
  S		: STRING( 1.. 256 );								--| TAMPON POUR UNE LIGNE DE CE FICHIER
  L		: NATURAL	:= 0;									--| LONGUEUR DE LA LIGNE
      
  COL		: POSITIVE	:= NATURAL'LAST;							--| COLONNE COURANTE SUR LA LIGNE
  TOK_START	: POSITIVE;									--| DEBUT
  TOK_END		: NATURAL;									--| ET FIN DU LEXEME
      
					------
		PROCEDURE			AVANCE
					------
IS
  BEGIN
    GET_A_TOKEN:
    LOOP												--| BOUCLER TANT QUE L'ON A PAS UN LEXEME VALIDE
    
      IF COL > L THEN										--| ON EST EN FIN DE LIGNE
        LOOP											--| BOUCLE POUR PASSER LES LIGNES NE CONCERNANT PAS CODEGEN (NE COMMENCANT PAS PAR "##")
          IF END_OF_FILE ( FE ) THEN									--| ON EST EN FIN DE FICHIER
            S( 1..3 ) := "END";									--| METTRE "END" COMME LEXEME
            TOK_START := 1;										--| DEBUTE EN 1
            TOK_END := 3;										--| FINIT EN 3
            EXIT GET_A_TOKEN;										--| SORTIR DE LA BOUCLE
          ELSE											--| ON EST PAS EN FIN DE FICHIER
            GET_LINE ( FE, S, L );									--| PRENDRE UNE LIGNE DU FICHIER
            LINE_NBR := LINE_NBR + 1;									--| LA COMPTER
            EXIT WHEN S( 1..2 ) = "##";									--| NE SORTIR QUE SI LA LIGNE COMMENCE PAR "##" INDIQUANT UN LIGNE POUR CODEGEN
          END IF;
        END LOOP;
        COL := 3;					--| COLONNE JUSTE APRÈS ## (POSITIONS 1 ET 2)
      END IF;
	--| ON EST SUR UNE LIGNE POUR CODEGEN (D'ABORD PASSER LES ESPACES)
      WHILE COL <= L AND THEN ( (S( COL ) = ASCII.HT) OR (S( COL ) = ' ' AND NOT SEPA_TAB_ONLY) ) LOOP
        COL := COL + 1;
      END LOOP;
            
      IF COL <= L THEN				--| IL N'Y A PAS QUE DES ESPACES
        TOK_START := COL;				--| DEBUT DU LEXEME A LA COLONNE
        TOK_END := COL;				--| INITIALISER LA FIN DE LEXEME À LA MEME VALEUR
	--| ACCUMULER LES CARACTERES DU LEXEME, ARRET SUR ESPACE
        WHILE COL <= L AND THEN ( (S( COL ) /= ASCII.HT) AND NOT (S( COL ) = ' ' AND NOT SEPA_TAB_ONLY) ) LOOP
          COL := COL + 1;
        END LOOP;
	--| SI LE LEXEME EST UNE INDICATION DE COMMENTAIRE "--"
        IF S( TOK_START..TOK_START+1 ) = "--" THEN
          COL := L+1;				--| ALLER À LA FIN DE LA LIGNE
        ELSE
          TOK_END := COL-1;				--| REMETTRE LA FIN DE LEXEME A SA PLACE
          RETURN;					--| C'EST OK
        END IF;
      END IF;
               
    END LOOP GET_A_TOKEN;
  END;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  FUNCTION LEXEME RETURN STRING IS
  BEGIN
    RETURN S( TOK_START..TOK_END );
  END;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  PROCEDURE RE_INIT IS
  BEGIN
    L := 0;
    COL := NATURAL'LAST;
    RESET ( FE );
    AVANCE;
  END;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|
  PROCEDURE LEX_END IS
  BEGIN
    CLOSE ( FE );
  END;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
BEGIN
  OPEN ( FE, IN_FILE, "../IDL/DIANA.IDL" );
  AVANCE;
--|-------------------------------------------------------------------------------------------------
END LEX;
