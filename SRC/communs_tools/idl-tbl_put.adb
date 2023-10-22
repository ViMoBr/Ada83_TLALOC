SEPARATE (IDL)
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE TBL_PUT
PROCEDURE TBL_PUT ( NOM_TEXTE :STRING ) IS
   
  RESULT_FILE, NFILE	: TEXT_IO.FILE_TYPE;
  RULE_LIST		: SEQ_TYPE;
  RULE_NBR		: NATURAL	:= 0;
  VOID_WAS_SEEN		: BOOLEAN	:= FALSE;
  USE INT_IO;
   
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PROCESS_RULES
  PROCEDURE PROCESS_RULES ( CLASS_RULE :TREE ) IS
      
    ITEM_LIST		: SEQ_TYPE	:= LIST ( CLASS_RULE );	--| LISTE DES RÈGLES DÉFINISSANT LES MEMBRES DE LA CLASSE
    ITEM		: TREE;
    RULE_NODE		: TREE;
      
    VOID_SYM		: TREE	:= STORE_SYM ( "VOID");
      
    --|---------------------------------------------------------------------------------------------
    --|	PROCEDURE PUT_RULE
    PROCEDURE PUT_RULE ( RULE :TREE ) IS
      SUBTYPE STR3	IS STRING( 1..3 );
      --|-------------------------------------------------------------------------------------
      --|	PROCEDURE PUT_PROPER_ATTRS
      PROCEDURE PUT_PROPER_ATTRS ( TER_LIST_ARG :SEQ_TYPE; PREFIX :STR3 ) IS
        TER_LIST	: SEQ_TYPE	:= TER_LIST_ARG;
        TER		: TREE;
        --|----------------------------------------------------------------------------------
        --|	PROCEDURE PUT_ATTR
        PROCEDURE PUT_ATTR ( TER :TREE ) IS
          TER_PREFIX	: STRING( 1..3 ) := "???";
          TER_NAME	: CONSTANT STRING	:= PRINT_NAME ( D ( XD_SYMREP, TER ) );
        BEGIN
               
          IF TER_NAME'LENGTH >= 3 THEN			--| SI LE NOM EST ASSEZ LONG
            TER_PREFIX( 1..3 ) := TER_NAME( TER_NAME'FIRST..TER_NAME'FIRST+2 );	--| EXTRAIRE LA TRANCHE DU PRÉFIXE
          END IF;
                  
          IF TER_PREFIX = PREFIX			--| SI C'EST LE PRÉFIXE COURANT
             OR ELSE (	PREFIX = "   " AND TER_PREFIX /= "AS_"	--| OU SI ON A MIS "   " MAIS QUE CE N'EST PAS UN CONNU "AS_", "LX_", "SM_"
                  		AND TER_PREFIX /= "LX_" AND TER_PREFIX /= "SM_")
          THEN
            IF DI ( XD_ATTR_ID, TER ) < 0 THEN			--| ATTRIBUT DE TYPE SÉQUENCE
              PUT ( 'A');				--| METTRE A EN DÉBUT DE LIGNE
                     
            ELSIF PRINT_NAME ( D ( XD_ATTR_TYPE, TER ) ) = "INTEGER" THEN	--| TYPAGE "INTEGER"
              PUT ( 'I');				--| METTRE I EN DÉBUT DE LIGNE
                     
            ELSIF PRINT_NAME ( D ( XD_ATTR_TYPE, TER ) ) = "BOOLEAN" THEN	--| TYPAGE "BOOLEAN"
              PUT ( 'B');				--| METTRE B EN DÉBUT DE LIGNE
                     
            ELSE				--| TOUT AUTRE ATTRIBUT
              PUT ( 'A');				--| METTRE A EN DÉBUT DE LIGNE

            END IF;
            PUT ("   ");
            PUT ( DI ( XD_ATTR_ID, TER ), 4 );			--| METTRE LE N° D'ATTRIBUT (POUR LE RETROUVER DANS LA LISTE DES ATTRIBUTS)
            PUT ( "   ");
            PUT_LINE ( PRINT_NAME (D (XD_SYMREP, TER ) ) );		--| METTRE LE NOM DE L'ATTRIBUT
            PUT_LINE ( NFILE, ASCII.HT & "=> " & PRINT_NAME (D (XD_SYMREP, TER ) )	--| ATTRIBUT
                              & ASCII.HT & ":" & PRINT_NAME (D (XD_ATTR_TYPE, TER ) )	--| ET TYPE AU FICHIER NOEUDS COMPLETS
                        );
          END IF;
        END PUT_ATTR;
            
      BEGIN
        WHILE NOT IS_EMPTY ( TER_LIST ) LOOP			--| TANT QU'IL Y A DES ATTRIBUTS PROPRES
          POP ( TER_LIST, TER );			--| PRENDRE UN ATTRIBUT
          IF TER.TY = DN_ATTR THEN			--| EN PRINCIPE L'ATTRIBUT DOIT ÊTRE DE CE TYPE
            PUT_ATTR ( TER );				--| L'IMPRIMER
          END IF;
        END LOOP;
      END PUT_PROPER_ATTRS;
      --|-------------------------------------------------------------------------------------------
      --|	PROCEDURE PUT_INHERITED_ATTRS
      PROCEDURE PUT_INHERITED_ATTRS ( CLASS_NODE :TREE; PREFIX :STR3 ) IS
      BEGIN
        IF CLASS_NODE /= TREE_VOID THEN
          PUT_INHERITED_ATTRS ( D ( XD_PARENT, CLASS_NODE ), PREFIX );		--| RÉCURSION AU NIVEAU SUPÉRIEUR
          PUT_PROPER_ATTRS ( LIST ( CLASS_NODE ), PREFIX );		--| PUIS PLACER LES ATTRIBUTS PROPRES HÉRITÉS À CE NIVEAU
        END IF;
      END;
      --|-------------------------------------------------------------------------------------
         
    BEGIN
      PUT ( "N ");				--| LIGNE NOEUD (PARTIE GAUCHE DE LA RÈGLE)
      INT_IO.PUT ( RULE_NBR, 3 );				--| D'ABORD LE N° DE RÈGLE
      DI ( XD_NODE_ID, RULE, RULE_NBR );			--| LE MÉMORISER DANS LA RÈGLE
      PUT_LINE ( ' ' & PRINT_NAME ( D ( XD_SYMREP, RULE ) ) );		--| PUIS LE NOM DE LA RÈGLE (DU NOEUD)
      PUT_LINE ( NFILE, PRINT_NAME ( D ( XD_SYMREP, RULE ) ) & ASCII.HT & "=>" );	--| NOM DU NOEUD AU FICHIER NOEUDS
      DECLARE
        PARENT	: TREE	:= D ( XD_PARENT, RULE );	--| CLASSE DANS LAQUELLE EST COMPRIS LE NOEUD DE LA RÈGLE
      BEGIN
        PUT_INHERITED_ATTRS ( PARENT, "AS_" );			--| METTRE LES ATTRIBUTS HÉRITÉS DU GENRE "AS_" (SYNTAXIQUES)
        PUT_PROPER_ATTRS ( LIST ( RULE ), "AS_" );			--| IMPRIMER LA LISTE DES ATTRIBUTS PROPRES DE LA RÈGLE (LES CHAMPS DU NOEUD)
            
        PUT_INHERITED_ATTRS ( PARENT,"LX_" );			--| REFAIRE ENSUITE POUR LES "LX_" (LEXICAUX)
        PUT_PROPER_ATTRS ( LIST ( RULE ),"LX_" );
            
        PUT_INHERITED_ATTRS ( PARENT, "SM_" );			--| REFAIRE ENSUITE POUR LES "SM_" (SÉMANTIQUES)
        PUT_PROPER_ATTRS ( LIST ( RULE ), "SM_" );

        PUT_INHERITED_ATTRS (PARENT, "   " );			--| REFAIRE ENSUITE POUR LES "LX"
        PUT_PROPER_ATTRS ( LIST ( RULE ), "   " );
      END;
      RULE_NBR := RULE_NBR + 1;
      PUT_LINE ( NFILE, ASCII.HT & ';' );
    END PUT_RULE;
      
  BEGIN
      
    PUT_LINE ( "C " & PRINT_NAME ( D ( XD_SYMREP, CLASS_RULE ) ) );		--| LIGNE DÉBUT DE CLASSE
      
    WHILE NOT IS_EMPTY ( ITEM_LIST ) LOOP
      POP ( ITEM_LIST, ITEM );				--| PRENDRE UN MEMBRE DE LA CLASSE TRAITÉE
         
      IF ITEM.TY /= DN_ATTR THEN				--| SI CE N'EST PAS UN ATTRIBUT (UN MEMBRE)
        RULE_NODE := D ( XD_CLASS_NODE, ITEM );			--| PRENDRE SA RÈGLE DE DÉFINITION
        IF DB ( XD_IS_CLASS, RULE_NODE ) THEN			--| LA RÈGLE DÉFINIT UN MEMBRE CLASSE
          PROCESS_RULES ( D ( XD_CLASS_NODE, ITEM ) );
        ELSE					--| LA RÈGLE DÉFINIT DES ATTRIBUTS
          IF D ( XD_SYMREP, RULE_NODE) /= VOID_SYM THEN		--| PAS LA RÈGLE DÉFINISSANT "VOID"
            PUT_RULE ( D ( XD_CLASS_NODE, ITEM ) );		--| IMPRIMER LA RÈGLE NAAA
                     
          ELSIF NOT VOID_WAS_SEEN THEN			--| SI C'EST LA RÈGLE POUR "VOID" ET QU'ON NE L'A PAS ENCORE VUE
            VOID_WAS_SEEN := TRUE;			--| INDIQUER QUE L'ON A VU CELLE-CI
            PUT_RULE ( D ( XD_CLASS_NODE, ITEM ) );		--| IMPRIMER LA RÈGLE
          END IF;
        END IF;
            
      ELSE					--| S'IL Y A UN TERMINAL C'EST UNE PROPRIÉTÉ DE CLASSE
        NULL;				--| NE RIEN IMPRIMER : LA PROPRIÉTÉ SERA COLLECTÉE PAR PUT_INHERITED_ATTRS COMME ATTRIBUT HÉRITÉ
      END IF;
            
    END LOOP;
      
    PUT_LINE ( "E " & PRINT_NAME ( D ( XD_SYMREP, CLASS_RULE ) ) );		--| LIGNE FIN DE CLASSE
  END PROCESS_RULES;
   
BEGIN
  OPEN_IDL_TREE_FILE ( NOM_TEXTE & ".LAR" );			--| FICHIER D'ARBRE IDL
  CREATE	 ( RESULT_FILE, OUT_FILE, NOM_TEXTE & ".TBL" );			--| FICHIER DE SORTIE TBL
  CREATE	 ( NFILE, OUT_FILE, NOM_TEXTE & "_NODES.TXT" );			--| FICHIER DES NOEUDS COMPLETS
   
  TEXT_IO.SET_OUTPUT ( RESULT_FILE );
   
  RULE_LIST := LIST ( STORE_SYM ( "STANDARD_IDL" ) );			--| LISTE DES RÈGLES DONT LA PARTIE GAUCHE EST DANS LA CATÉGORIE STANDARD_IDL
  IF NOT IS_EMPTY ( RULE_LIST) THEN				--| SI NON VIDE
    PROCESS_RULES ( HEAD ( RULE_LIST ) );			--| TRAITER
  END IF;
   
  RULE_LIST := LIST ( STORE_SYM ( "ALL_SOURCE" ) );			--| PAREIL POUR LA CATÉGORIE ALL_SOURCE
  IF NOT IS_EMPTY ( RULE_LIST) THEN
    PROCESS_RULES ( HEAD ( RULE_LIST ) );
  END IF;
   
  RULE_LIST := LIST ( STORE_SYM ( "TYPE_SPEC" ) );			--| PAREIL POUR LA CATÉGORIE TYPE_SPEC
  IF NOT IS_EMPTY ( RULE_LIST) THEN
    PROCESS_RULES ( HEAD ( RULE_LIST ) );
  END IF;
   
  RULE_LIST := LIST ( STORE_SYM ( "NON_DIANA") );			--| PAREIL POUR LA CATÉGORIE NON_DIANA
  IF NOT IS_EMPTY ( RULE_LIST) THEN
    PROCESS_RULES ( HEAD ( RULE_LIST ) );
  END IF;
      
  TEXT_IO.SET_OUTPUT ( TEXT_IO.STANDARD_OUTPUT );
  CLOSE ( NFILE );
  CLOSE ( RESULT_FILE );
  CLOSE_IDL_TREE_FILE;

  PUT_LINE ( "OK" );
  NEW_LINE;
      
      
EXCEPTION
       
  WHEN NAME_ERROR =>
    PUT_LINE ( "LE FICHIER : " & NOM_TEXTE & ".LAR  EST INTROUVABLE" );
            
  WHEN OTHERS =>
            CLOSE ( RESULT_FILE );
            CLOSE_IDL_TREE_FILE;
            PUT_LINE ( "ERREUR TBL_PUT" );
      
   END TBL_PUT;
