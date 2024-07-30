SEPARATE( IDL )
--|-------------------------------------------------------------------------------------------------
--|		PACKAGE TERM_LIST
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY TERM_LIST IS
   
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION SAME
  FUNCTION SAME ( L1, L2 :SEQ_TYPE ) RETURN BOOLEAN IS
  BEGIN
    RETURN L1.FIRST = L2.FIRST;
  END;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION UNION
  FUNCTION UNION ( L1 :SEQ_TYPE; V :TREE ) RETURN SEQ_TYPE IS
  BEGIN
    IF IS_EMPTY( L1 ) THEN								--| LA LISTE EST VIDE
      RETURN INSERT( L1, V );								--| RETOURNER UNE LISTE AVEC L'ÉLÉMENT INSÉRÉ
    ELSE
      DECLARE
        H1	: TREE	:= HEAD( L1 );						--| TÊTE DE LA LISTE
        N1	: INTEGER	:= DI( XD_TER_NBR, H1 );					--| N° DE TERMINAL DE LA TÊTE
        NV	: INTEGER	:= DI( XD_TER_NBR, V );					--| N° DE TERMINAL DE L'ÉLÉMENT
      BEGIN
        IF N1 = NV THEN								--| SI MÊME N°
          RETURN L1;								--| RETOURNER LA LISTE INCHANGÉE
        ELSIF N1 < NV THEN								--| N° DIFFÉRENTS, CELUI DE LA LISTE STRICTEMENT INFÉRIEUR
          DECLARE
            T1	: SEQ_TYPE	:= TAIL( L1 );					--| PRENDRE LA SUITE DE LISTE
            L	: SEQ_TYPE	:= UNION( T1, V );					--| RETENTER L'UNION AVEC LE RESTE DE LISTE
          BEGIN
            IF SAME( T1, L ) THEN							--| LA LISTE EST INCHANGÉE PAR UNION SUR LE RESTE (ÉLÉMENT REPÉRÉ DANS LE RESTE)
              RETURN L1;								--| RETOURNER LA LISTE INITIALE INCHANGÉE
            ELSE									--| LE RESTE A ÉTÉ CHANGÉ
              RETURN INSERT( L, H1 );							--| METTRE LA TÊTE DEVANT LA NOUVELLE LISTE RESTE
            END IF;
          END;
        ELSE									--| N° DIFFÉRENTS CELUI DE LA LISTE STRICTEMENT SUPÉRIEUR
          RETURN INSERT( L1, V );							--| INSÉRER L'ÉLÉMENT EN TÊTE (PLUS PETITS N° EN TÊTE)
        END IF;
      END;
    END IF;
  END UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION UNION
  FUNCTION UNION ( L1 :SEQ_TYPE; L2 :SEQ_TYPE ) RETURN SEQ_TYPE IS
  BEGIN
    IF IS_EMPTY( L1 ) THEN
      RETURN L2;
    ELSIF IS_EMPTY( L2 ) OR ELSE SAME( L1, L2 ) THEN
      RETURN L1;
    ELSE
      DECLARE
        H1	: TREE		:= HEAD( L1 );
        H2	: TREE		:= HEAD( L2 );
        N1	: INTEGER		:= DI( XD_TER_NBR, H1 );				--| N° DE TERMINAL DE LA TÊTE 1
        N2	: INTEGER		:= DI( XD_TER_NBR, H2 );				--| N° DE TERMINAL DE LA TÊTE 2
        T1, T2, L	: SEQ_TYPE;
      BEGIN
        IF N1 = N2 THEN								--| MÊMES N° DE TÊTES
          T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
          T2 := TAIL( L2 );								--| LE RESTE 2
          L := UNION( T1, T2 );							--| RETENTER L'OPÉRATION SUR LES RESTES
          IF SAME( L, T1 ) THEN							--| L'UNION DES RESTES EST LE RESTE 1 (LE RESTE 1 CONTIENT LE RESTE 2)
            RETURN L1;								--| RENDRE LA LISTE 1
          ELSIF SAME( L, T2 ) THEN							--| L'UNION DES RESTES EST LE RESTE 2 (LE RESTE 2 CONTIENT LE RESTE 1)
            RETURN L2;								--| RENDRE LA LISTE 2
          ELSE									--| L'UNION DES RESTES DIFFÈRE DES DEUX RESTES (CHAQUE RESTE A DES ÉLÉMENTS NON CONTENUS DANS L'AUTRE)
            RETURN INSERT( L, H1 );							--| PRÉFIXER LA TÊTE COMMUNE À LA LISTE UNION DES RESTES
          END IF;
                  
        ELSIF N1 > N2 THEN								--| LA TÊTE 1 EST APRÈS LA TÊTE 2
          RETURN UNION( L2, L1 );							--| RETENTER L'UNION EN PERMUTANT LES LISTES (POUR VENIR AU CAS SUIVANT)
        ELSE									--| LA TÊTE 2 EST APRÈS LA TÊTE 1
          T1 := TAIL( L1 );								--| PRENDRE LE RESTE DE LA LISTE À TÊTE ANTÉRIEURE
          L := UNION( T1, L2 );							--| RETENTER L'UNION SUR LE RESTE ET LA LISTE 2 INITIALE
          IF SAME( L, T1 ) THEN							--| SI L'UNION EST LE RESTE INCHANGÉ (LE RESTE DE 1 CONTENAIT LA LISTE 2)
            RETURN L1;								--| RENDRE LA LISTE 1
          ELSE									--| L'UNION DU RESTE 1 ET DE LA LISTE 2 EST ORIGINAL
            RETURN INSERT( L, H1 );							--| PRÉFIXER LA TÊTE 1 À LA NOUVELLE LISTE UNION
          END IF;
        END IF;
      END;
    END IF;
  END UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION MEMBER
  FUNCTION MEMBER ( L1 :SEQ_TYPE; V :TREE ) RETURN BOOLEAN IS
  BEGIN
    IF IS_EMPTY( L1 ) THEN								--| SI LA LISTE EST VIDE
      RETURN FALSE;									--| L'ÉLÉMENT N'Y EST PAS (!)
    ELSE
      DECLARE
        H1	: TREE		:= HEAD( L1 );					--| TÊTE DE LISTE
        N1	: INTEGER		:= DI( XD_TER_NBR, H1 );				--| N° DE LA TÊTE
        NV	: INTEGER		:= DI( XD_TER_NBR, V );				--| N° DE L'ÉLÉMENT
      BEGIN
        IF N1 = NV THEN								--| N° IDENTIQUES
          RETURN TRUE;								--| L'ÉLÉMENT EST DANS LA LISTE
        ELSIF NV < N1 THEN								--| N° D'ÉLÉMENT INFÉRIEUR
          RETURN FALSE;								--| L'ÉLÉMENT N'EST PAS DANS LA LISTE (ORDONNÉE CROISSANTE)
        ELSE									--| LE N° D'ÉLÉMENT EST POSTÉRIEUR
          RETURN MEMBER( TAIL( L1 ), V );						--| REFAIRE L'OPÉRATION SUR LE RESTE DE LA LISTE
        END IF;
      END;
    END IF;
  END MEMBER;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION R_UNION
  FUNCTION R_UNION ( L1 :SEQ_TYPE; V :TREE ) RETURN SEQ_TYPE IS
  BEGIN
    IF IS_EMPTY( L1 ) THEN								--| LISTE VIDE
      RETURN INSERT( L1, V );								--| RETOURNER LA LISTE AVEC L'ÉLÉMENT EN TÊTE
    ELSE										--| LISTE NON VIDE
      DECLARE
        H1	: TREE	:= HEAD( L1 );						--| LIRE LA TÊTE DE LISTE
      BEGIN
        IF H1 = V THEN								--| SI C'EST L'ÉLÉMENT
          RETURN L1;								--| RETOURNER LA LISTE
        END IF;
        DECLARE
          N1 : INTEGER	:= DI( XD_RULE_NBR, D( XD_RULEINFO, H1 ) );			--| PRENDRE LE N° DE RÈGLE TÊTE DE LISTE
          NV : INTEGER	:= DI( XD_RULE_NBR, D( XD_RULEINFO, V ) );			--| PRENDRE LE N° DE RÈGLE ÉLÉMENT
        BEGIN
          IF N1 < NV THEN								--| LA TÊTE EST ANTÉRIEURE
            DECLARE
              T1 : SEQ_TYPE	:= TAIL( L1 );						--| PRENDRE LE RESTE DE LISTE
              L  : SEQ_TYPE	:= R_UNION( T1, V );					--| RETENTER L'OPÉRATION
            BEGIN
              IF SAME( T1, L ) THEN							--| LE RESTE DE LISTE EST INCHANGÉ (CONTENAIT L'ÉLÉMENT)
                RETURN L1;								--| RETOURNER LA LISTE
              ELSE									--| L'UNION EST ORIGINALE
                RETURN INSERT( L, H1 );							--| RETOURNER UNE LISTE AVEC LA TÊTE 1 PRÉFIXÉE
              END IF;
            END;
          ELSE									--| L'ÉLÉMENT EST ANTÉRIEUR
            RETURN INSERT( L1, V );							--| RETOURNER UNE LISTE AVEC L'ÉLÉMENT PRÉFIXÉ
          END IF;
        END;
      END;
    END IF;
  END R_UNION;
  --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  --|		FUNCTION R_UNION
  FUNCTION R_UNION ( L1 :SEQ_TYPE; L2 :SEQ_TYPE ) RETURN SEQ_TYPE IS
  BEGIN
    IF IS_EMPTY( L1 ) THEN								--| LISTE 1 VIDE
      RETURN L2;									--| RETOURNER LA LISTE 2 COMME UNION
    ELSIF IS_EMPTY( L2 ) OR ELSE SAME( L1, L2 ) THEN					--| LISTE 2 VIDE OU IDENTIQUE À LA LISTE 1
      RETURN L1;									--| RETOURNER LA LISTE 1 COMME UNION
    ELSE
      DECLARE									--| CAS GÉNÉRAL
        H1	: TREE	:= HEAD( L1 );						--| PRENDRE LA TÊTE DE LISTE 1
        H2	: TREE	:= HEAD( L2 );						--| ET LA TÊTE DE LISTE 1
        T1, T2: SEQ_TYPE;
      BEGIN
        IF H1 = H2 THEN								--| SI TÊTES IDENTIQUES
          T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
          T2 := TAIL( L2 );								--| ET LE RESTE 2
          DECLARE
            L : SEQ_TYPE	:= R_UNION( T1, T2 );					--| FAIRE L'UNION DES RESTES
          BEGIN
            IF SAME( L, T1 ) THEN							--| UNION CORRESPONDANT AU RESTE 1 (QUI CONTIENT LE RESTE 2)
              RETURN L1;								--| RETOURNER LA LISTE 1
            ELSIF SAME( L, T2 ) THEN							--| UNION CORRESPONDANT AU RESTE 2 (QUI CONTIENT LE RESTE 1)
              RETURN L2;								--| RETOURNER LA LISTE 2
            ELSE
              RETURN INSERT( L, H1 );							--| PRÉFIXER LA TÊTE COMMUNE À L'UNION ORIGINALE DES RESTES
            END IF;
          END;
        ELSE									--| LES TÊTES DIFFÈRENT
          IF DI( XD_RULE_NBR, D( XD_RULEINFO, H1 ) )					--| LE N° DE TÊTE 1
           		> DI( XD_RULE_NBR, D( XD_RULEINFO,H2 ) ) THEN			--| EST POSTÉRIEUR AU N° DE TÊTE 2
            RETURN R_UNION( L2, L1 );							--| RETENTER L'UNION EN PERMUTANT LES LISTES (POUR TOMBER AU CAS SUIVANT)
          ELSE									--| LE N° DE TÊTE 1 EST ANTÉRIEUR AU N° DE TÊTE 2
            T1 := TAIL( L1 );								--| PRENDRE LE RESTE 1
            DECLARE
              L	: SEQ_TYPE	:= R_UNION( T1, L2 );				--| UNIR LE RESTE 1 À LA LISTE 2
            BEGIN
              IF SAME( L, T1 ) THEN							--| SI UNION CORRESPONDANT AU RESTE 1 (QUI CONTIENT LA LISTE 2)
                RETURN L1;								--| RETOURNER LA LISTE 1
              ELSE									--| UNION ORIGINALE
                RETURN INSERT( L, H1 );							--| RETOURNER UNE LISTE AVEC LA TÊTE 1 PRÉFIXÉE À L'UNION ORIGINALE
              END IF;
            END;
          END IF;
        END IF;
      END;
    END IF;
  END R_UNION;
   
--|--------------------------------------------------------------------------------------------------
END TERM_LIST;
