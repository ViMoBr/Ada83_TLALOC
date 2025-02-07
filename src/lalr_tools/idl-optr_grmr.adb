SEPARATE( IDL )
--|--------------------------------------------------------------------------------------------------
--|		OPTR_GRMR
--|--------------------------------------------------------------------------------------------------
PROCEDURE OPTR_GRMR ( NOM_TEXTE :STRING ) IS
  GRAMMAR		: TREE;
  GR_RULE_S	: SEQ_TYPE;
   
  TYPE RTBL_TYPE	IS RECORD
		  RULE		: TREE;						--| ACCÈS À UNE RÈGLE
		  REPLACEMENT	: TREE;						--| RÈGLE REMPLAÇANTE
		  USE_COUNT	: INTEGER;					--| NOMBRE D'USAGES DE LA RÈGLE
		  IS_ONE_ALT	: BOOLEAN;					--| RÈGLE À UNE SEULE ALTERNATIVE
		END RECORD;
  RTBL		: ARRAY( 1 .. 350) OF RTBL_TYPE;					--| TABLE D'ACCÈS AUX RÈGLES ET INFORMATIONS
  LAST_RULE_NBR	: INTEGER	:= 0;							--| NOMBRE DE RÈGLES
  
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE FIRST_PASS
  PROCEDURE FIRST_PASS IS								--| REMPLACE LES RÈGLES MONO-ALTERNATIVE ET MONO-SYLLABES PAR LA RÈGLE ÉVENTUELLE DE LA SYLLABE
    RULE_S	: SEQ_TYPE	:= GR_RULE_S;
    RULE		: TREE;
      
    --|----------------------------------------------------------------------------------------
    --|	PROCEDURE PROPAGATE_REPLACEMENT
    PROCEDURE PROPAGATE_REPLACEMENT ( I, LIM :INTEGER ) IS
    BEGIN
      IF LIM <= 0 THEN								--| SI L'ON A CELA C'EST QUE L'ON A PLUS DE REMPLAÇANTES DE REMPLAÇANTE QUE DE RÈGLES !
        ERROR( D( LX_SRCPOS, RTBL( I ).RULE ), "CIRCULAR REPLACEMENT" );			--| DONC ON TOURNE EN ROND
      ELSE
        IF RTBL( I ).REPLACEMENT.TY = DN_RULE THEN
          DECLARE
            J : INTEGER	 := DI( XD_RULEINFO, RTBL( I ).REPLACEMENT );			--| NUMÉRO DE LA RÈGLE REMPLAÇANTE
          BEGIN
            IF RTBL( J ).REPLACEMENT.TY = DN_RULE THEN					--| SI LA REMPLAÇANTE A AUSSI UNE REMPLAÇANTE
              PROPAGATE_REPLACEMENT( J, LIM - 1 );					--| ALLER CHERCHER PLUS LOIN (EN INDIQUANT LE NOMBRE DE FOIS MAX OÙ L'ON PEUT FAIRE CELA)
              RTBL( I ).REPLACEMENT := RTBL( J ).REPLACEMENT;				--| METTRE LA REMPLAÇANTE DE LA REMPLAÇANTE COMME REMPLAÇANTE (!)
            END IF;
          END;
        END IF;
      END IF;
    END;
      
  BEGIN
    WHILE NOT IS_EMPTY( RULE_S ) LOOP							--| TANT QU'IL Y A DES RÈGLES
      POP( RULE_S, RULE );								--| EN EXTRAIRE UNE
      LAST_RULE_NBR := LAST_RULE_NBR + 1;						--| UNE RÈGLE DE PLUS
      DI( XD_RULEINFO, RULE, LAST_RULE_NBR );						--| STOCKER LE NUMÉRO DE RÈGLE
            
      DECLARE
        ALTERNATIVE_S	: SEQ_TYPE	:=  LIST( RULE );
        IS_ONE_ALT		: BOOLEAN	:= IS_EMPTY( TAIL( ALTERNATIVE_S ) );			--| INDIQUE SI NE CONTIENT QU'UNE ALTERNATIVE (QUEUE DE LA LISTE D'ALTERNATIVES VIDE)
      BEGIN
        RTBL( LAST_RULE_NBR ) := (
			RULE		=> RULE,					--| STOCKER L'ACCÈS À CETTE RÈGLE DANS LA TABLE DES RÈGLES
			REPLACEMENT	=> TREE_VOID,				--| PAS DE REMPLAÇANTE
			USE_COUNT		=> 0,					--| PAS D'USAGE
			IS_ONE_ALT	=> IS_ONE_ALT				--| INDIQUE SI NE CONTIENT QU'UNE ALTERNATIVE
			);
            
        IF IS_ONE_ALT THEN								--| ON NE CONSIDÈRE QUE LA CAS MONO ALTERNATIVE
          DECLARE
            SYLLABE_S	: SEQ_TYPE	:= LIST( HEAD( ALTERNATIVE_S ) );		--| LISTE DES SYLLABES DE L'UNIQUE ALTERNATIVE
          BEGIN
            IF NOT IS_EMPTY( SYLLABE_S )						--| S'IL Y A DES SYLLABES
               AND THEN IS_EMPTY( TAIL( SYLLABE_S ) )					--| ET S'IL N'Y EN A QU'UNE
               AND THEN IS_EMPTY( LIST( D( XD_SEMANTICS, HEAD( ALTERNATIVE_S ) ) ) )		--| ET ELLE N'A PAS D'ACTION SÉMANTIQUE
            THEN
              DECLARE
                SYLLABE	: TREE	:= HEAD( SYLLABE_S );
              BEGIN
                IF SYLLABE.TY /= DN_TERMINAL THEN						--| LA SYLLABE EST TERMINALE
                  DECLARE
                    DEF_LIST : SEQ_TYPE	:= LIST( D( XD_SYMREP, SYLLABE ) );			--| LISTE DES UTILISATIONS DU SYMBOLE DE SYLLABE
                  BEGIN
                    WHILE NOT IS_EMPTY( DEF_LIST )					--| TANT QU'IL Y A DES UTIISATIONS
                          AND THEN HEAD( DEF_LIST ).TY /= DN_RULE LOOP			--| ET QUE CE N'EST PAS LA RÈGLE DE DÉFINITION
                      DEF_LIST := TAIL( DEF_LIST );					--| AVANCER SUR LA LISTE DES UTILISATIONS
                    END LOOP;
                    IF NOT IS_EMPTY( DEF_LIST ) THEN					--| SI L'ON A TROUVÉ UNE RÈGLE DE DÉFINITION
                      RTBL( LAST_RULE_NBR ).REPLACEMENT := HEAD( DEF_LIST );			--| METTRE CETTE RÈGLE COMME REMPLAÇANTE DE LA RÈGLE MONO-ALTERNATIVE MONO-SYLLABE
                      D( XD_RULE, SYLLABE, HEAD( DEF_LIST ) );				--| MENTIONNER AUSSI DANS LA SYLLABE
                    ELSE
                      D( XD_RULE, SYLLABE, TREE_VOID );					--| S'IL N'Y A PAS DE RÈGLE DE DÉFINITION, METTRE UN ACCÈS VIDE
                    END IF;
                  END;
                END IF;
              END;
            END IF;
          END;
        END IF;
      END;
    END LOOP;
         
    FOR I IN 1 .. LAST_RULE_NBR LOOP							--| BALAYER TOUTES LES RÈGLES
      PROPAGATE_REPLACEMENT( I, LAST_RULE_NBR );						--| POUR PRENDRE LES REMPLAÇANTES DE REMPLAÇANTES
    END LOOP;
  END FIRST_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE SECOND_PASS
  PROCEDURE SECOND_PASS IS								--| CHANGE LA DÉFINITION D'UNE SYLLABE SI CELLE-CI EST REMPLACÉE
  BEGIN
    FOR I IN 1 .. LAST_RULE_NBR LOOP							--| PASSER EN REVUE TOUTES LES RÈGLES
      DECLARE
        RTBL_I	: RTBL_TYPE RENAMES RTBL( I );
      BEGIN
        IF RTBL_I.REPLACEMENT.TY /= DN_RULE THEN						--| LA RÈGLE N'A PAS DE REMPLAÇANTE (PAS TRAITÉE À LA PASSE 1)
          DECLARE
            ALTERNATIVE_S	: SEQ_TYPE	:= LIST( RTBL_I.RULE );			--| PRENDRE SA LISTE D'ALTERNATIVES
            ALTERNATIVE	: TREE;
            SYLLABE_S	: SEQ_TYPE;
            SYLLABE	: TREE;
          BEGIN
            WHILE NOT IS_EMPTY( ALTERNATIVE_S ) LOOP					--| S'IL Y A DES ALTERNATIVES
              POP( ALTERNATIVE_S, ALTERNATIVE );						--| EXTRAIRE LA LISTE DE SES SYLLABES
              SYLLABE_S := LIST( ALTERNATIVE );
                     
              WHILE NOT IS_EMPTY( SYLLABE_S ) LOOP					--| TANT QU'IL Y A DES SYLLABES
                POP( SYLLABE_S, SYLLABE );						--| EN EXTRAIRE UNE
                IF SYLLABE.TY = DN_NONTERMINAL THEN					--| SI C'EST UNE NON TERMINALE
                  DECLARE
                    RULE	: TREE	:= TREE_VOID;
                  BEGIN
                    DECLARE
                      DEFLIST : SEQ_TYPE  := LIST( D( XD_SYMREP, SYLLABE ) );			--| PRENDRE LA LISTE DES UTILISATIONS DE SON SYMBOLE
                    BEGIN
                      WHILE NOT IS_EMPTY( DEFLIST )					--| TANT QU'IL Y A DES UTILISATIONS
                        AND THEN HEAD( DEFLIST).TY /= DN_RULE LOOP				--| ET QUE CE N'EST PAS UNE RÈGLE DE DÉFINITION
                        DEFLIST := TAIL( DEFLIST );					--| AVANCER SUR LA LISTE DES UTILISATIONS
                      END LOOP;
                                 
                      IF NOT IS_EMPTY( DEFLIST ) THEN					--| SI L'ON A TROUVÉ UNE RÈGLE DE DÉFINITION
                        RULE := HEAD( DEFLIST );						--| PRENDRE CETTE RÈGLE DE DÉFINITION
                      END IF;
                    END;
                    D( XD_RULE, SYLLABE, RULE );						--| MENTIONNER LA RÈGLE (OU LE VIDE) DE DÉFINITION DE LA SYLLABE
                    IF RULE.TY /= DN_VOID THEN						--| S'IL Y A EFFECTIVEMENT UNE RÈGLE DE DÉFINITION
                      DECLARE
                        J      : INTEGER	:= DI( XD_RULEINFO, RULE );			--| PRENDRE SON NUMÉRO
                        RTBL_J : RTBL_TYPE	RENAMES RTBL( J );
                      BEGIN
                        IF RTBL_J.REPLACEMENT.TY /= DN_VOID THEN				--| SI LA RÈGLE DE DÉFINITION A UNE REMPLAÇANTE
                          D( XD_SYMREP, SYLLABE, D( XD_NAME, RTBL_J.REPLACEMENT ) );		--| METTRE LE SYMBOLE DE CETTE REMPLAÇANTE COMME SYMBOLE DE LA SYLLABE
                          D( XD_RULE, SYLLABE, RTBL_J.REPLACEMENT );				--| METTRE LA RÈGLE REMPLAÇANTE COMME DÉFINITION DE LA SYLLABE
                          DECLARE
                            K : INTEGER := DI( XD_RULEINFO, RTBL_J.REPLACEMENT );
                          BEGIN
                            RTBL( K ).USE_COUNT := RTBL( K ).USE_COUNT + 1;			--| INDIQUER QUE LA REMPLAÇANTE EST UTILISÉE UNE FOIS DE PLUS
                          END;
                        ELSE
                          RTBL_J.USE_COUNT := RTBL_J.USE_COUNT + 1;
                        END IF;
                      END;
                    END IF;
                  END;
                END IF;
              END LOOP;
                     
            END LOOP;
          END;
        END IF;
      END;
    END LOOP;
  END SECOND_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE THIRD_PASS
  PROCEDURE THIRD_PASS IS
         
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE REPLACE_ALTS
    PROCEDURE REPLACE_ALTS ( ALTERNATIVE_S :IN OUT SEQ_TYPE ) IS
      ALTERNATIVE		: TREE;
      SYLLABE_S		: SEQ_TYPE;
      SYLLABE		: TREE;
      RULE		: TREE;
         
      --|-------------------------------------------------------------------------------------------
      --|		FUNCTION CATENATE
      FUNCTION CATENATE ( A,B: SEQ_TYPE) RETURN SEQ_TYPE IS
      BEGIN
        IF IS_EMPTY( B ) THEN
          RETURN A;
        ELSIF IS_EMPTY( A ) THEN
          RETURN B;
        ELSE
          RETURN INSERT( CATENATE( TAIL( A ), B ), HEAD( A ) );
        END IF;
    END CATENATE;
         
  BEGIN
    IF IS_EMPTY ( ALTERNATIVE_S ) THEN
      RETURN;
    END IF;
    ALTERNATIVE := HEAD ( ALTERNATIVE_S );					--| EXTRAIRE UNE ALTERNATIVE
    SYLLABE_S := LIST ( ALTERNATIVE);						--| EXTRAIRE LA ISTE DE SES SYLLABES
    IF NOT IS_EMPTY ( SYLLABE_S )						--| S'IL Y A DES SYLLABES
       AND THEN IS_EMPTY( TAIL( SYLLABE_S ) )					--| ET UNE SEULE
       AND THEN IS_EMPTY( LIST( D( XD_SEMANTICS, ALTERNATIVE ) ) )			--| ET SANS ACTION SÉMANTIQUE
    THEN
      SYLLABE := HEAD( SYLLABE_S);
      IF SYLLABE.TY = DN_NONTERMINAL THEN
        RULE := D( XD_RULE, SYLLABE);
        IF RULE /= TREE_VOID THEN
                                        -- IT IS DEFINED (ELSE ERR IN INITGRMR)
                                        --@       PUT("CHECKING: "); PUT_LINE(PRINTNAME(D ( XD_NAME,RULE)));
          DECLARE
            RTBL_I	: RTBL_TYPE RENAMES RTBL( DI( XD_RULEINFO, RULE ) );
          BEGIN
            IF RTBL_I.USE_COUNT = 1 THEN
                                                        -- IT IS USED ONCE
              RTBL_I.REPLACEMENT := TREE_FALSE;
                                                        -- MARK REPLACED
              ALTERNATIVE_S := CATENATE( LIST( RTBL_I.RULE ), TAIL( ALTERNATIVE_S ) );
              REPLACE_ALTS( ALTERNATIVE_S);
              RETURN;
            END IF;
          END;
        END IF;
      END IF;
    END IF;
                -- DID NOT REPLACE; CHECK TAIL
    DECLARE
      ALTERNATIVE_S_TAIL	: SEQ_TYPE 	:= TAIL( ALTERNATIVE_S );
      NEW_ALTERNATIVE_S_TAIL	: SEQ_TYPE	:= ALTERNATIVE_S_TAIL;
    BEGIN
      REPLACE_ALTS( NEW_ALTERNATIVE_S_TAIL );
      IF ALTERNATIVE_S_TAIL = NEW_ALTERNATIVE_S_TAIL THEN
        RETURN;
      END IF;
      ALTERNATIVE_S := INSERT( NEW_ALTERNATIVE_S_TAIL, HEAD( ALTERNATIVE_S ) );
    END;
  END REPLACE_ALTS;
      
      
  BEGIN
    FOR I IN 1 .. LAST_RULE_NBR LOOP							--| POUR TOUTES LES RÈGLES
      DECLARE
        RTBL_I		: RTBL_TYPE RENAMES RTBL( I );
        ALTERNATIVE_S	: SEQ_TYPE;
      BEGIN
        IF RTBL_I.REPLACEMENT.TY /= DN_RULE THEN						--| SI LA RÈGLE N'A PAS DE REMPLAÇANTE
          ALTERNATIVE_S := LIST( RTBL_I.RULE );						--| PRENDRE SA LISTE D'ALTERNATIVES
          REPLACE_ALTS( ALTERNATIVE_S );						--| MODIFIER CETTE LISTE D'ALTERNATIVES
          LIST( RTBL_I.RULE, ALTERNATIVE_S );						--| REPLACER LA LISTE MODIFIÉE
        END IF;
      END;
    END LOOP;
  END THIRD_PASS;
  --|-----------------------------------------------------------------------------------------------
  --|		PROCEDURE REWRITE
  PROCEDURE REWRITE IS
    NEW_RULE_COUNT		: INTEGER	:= 0;
    ONE_USE_COUNT		: INTEGER	:= 0;
    RULE_S		: SEQ_TYPE	:= (TREE_NIL,TREE_NIL);
  BEGIN
    FOR I IN 1 .. LAST_RULE_NBR LOOP
      DECLARE
        RTBL_I : RTBL_TYPE RENAMES RTBL( I );
      BEGIN
        IF RTBL_I.REPLACEMENT = TREE_VOID THEN
          NEW_RULE_COUNT := NEW_RULE_COUNT + 1;
          RULE_S := APPEND( RULE_S, RTBL_I.RULE );
          IF RTBL_I.USE_COUNT = 1 THEN
            ONE_USE_COUNT := ONE_USE_COUNT + 1;
          END IF;
        END IF;
      END;
    END LOOP;
    LIST( GRAMMAR, RULE_S );							--| REMPLACE LA LISTE DE REGLES
    PUT ( "RULES:" );
    INT_IO.PUT( LAST_RULE_NBR );
    INT_IO.PUT( NEW_RULE_COUNT );
    NEW_LINE;
    INT_IO.PUT( ONE_USE_COUNT, 1 );
    PUT_LINE  ( " RULES WITH ONE USE." );
  END REWRITE;
   
   
BEGIN
  PUT_LINE ( "OPTR_GRMR" );
  DECLARE
    USER_ROOT	: TREE;
  BEGIN
    OPEN_IDL_TREE_FILE( NOM_TEXTE & ".lar" );
    USER_ROOT := D( XD_USER_ROOT, TREE_ROOT );
    GRAMMAR   := D( XD_GRAMMAR, USER_ROOT );
  END;
  GR_RULE_S := LIST( GRAMMAR );							--| LA LISTE DES RÈGLES DE GRAMMAIRE
  PUT_LINE ( "FIRST PASS." );
  FIRST_PASS;
  PUT_LINE ( "SECOND PASS." );
  SECOND_PASS;
  PUT_LINE ( "THIRD PASS." );
  THIRD_PASS;
  PUT_LINE ( "REWRITE." );
  REWRITE;

  CLOSE_IDL_TREE_FILE;
--|--------------------------------------------------------------------------------------------------
END OPTR_GRMR;
