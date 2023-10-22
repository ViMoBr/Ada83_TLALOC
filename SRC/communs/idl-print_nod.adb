WITH UNCHECKED_CONVERSION;
SEPARATE( IDL )
--|-------------------------------------------------------------------------------------------------
--|		PRINT_NOD
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY PRINT_NOD IS
   
		--| POUR DETERMINER SI LA MACHINE EST LITTLE-ENDIAN OU BIG-ENDIAN

  DUMMY2			: INTEGER;
  DUMMY			: ARRAY (1..4) OF CHARACTER	:= (CHARACTER'VAL(1),ASCII.NUL,ASCII.NUL,ASCII.NUL);
  FOR DUMMY USE AT DUMMY2'ADDRESS;
  IS_LITTLE_ENDIAN		: CONSTANT BOOLEAN		:= (DUMMY2 = 1);
   
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PNN
--|
FUNCTION  L_PNN ( NN :NODE_NAME ) RETURN NATURAL IS
  STR		: CONSTANT STRING		:= NODE_NAME'IMAGE ( NN );
BEGIN
  PUT ( STR );
  RETURN STR'LENGTH;
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PINT							--| IMPRIME UN ENTIER 16 BITS
--|
FUNCTION L_PINT ( I :INTEGER ) RETURN NATURAL IS
BEGIN
  IF I < 0 THEN									--| ENTIER NEGATIF
    IF I < -32767 THEN								--| PAS DE VALEUR POSITIVE CORRESPONDANTE
      PUT ( "-32768" );								--| ECRIRE LA VALEUR NEGATIVE MINIMALE
      RETURN 6;									--| 6 CARACTERES DE LONG
    ELSE										--| CAS STANDARD DES NEGATIFS POUR LESQUELS UNE VALEUR POSITIVE CORRESPONDANTE EXISTE
      PUT ( '-' );									--| METTRE LE SIGNE
      RETURN L_PINT ( -I ) + 1;							--| IMPRIMER LE POSITIF ET RETOURNER LA LONGUEUR (AVEC SIGNE -)
    END IF;
  ELSIF I > 9 THEN									--| POSITIF ET NOMBRE A PLUS D'1 CHIFFRE
    RETURN L_PINT ( I/10 ) + L_PINT ( I MOD 10 );						--| IMPRIMER LE DIV SUIVI DU MOD EN RETOURNANT LEUR LONGUEUR TOTALE
  ELSE										--| POSITIF A 1 SEUL CHIFFRE
    PUT ( CHARACTER'VAL ( CHARACTER'POS ( '0' ) + I ) );					--| IMPRIMER LE CHIFFRE
    RETURN 1;
  END IF;
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PINT
--|
FUNCTION L_PINT ( S :VPG_IDX ) RETURN NATURAL IS
BEGIN
  RETURN L_PINT( INTEGER( S ) );
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PINT
--|
FUNCTION  L_PINT ( B :LINE_IDX ) RETURN NATURAL IS
BEGIN
  RETURN L_PINT ( INTEGER( B ) );
END;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION PRINT_ABS_TREE
--|
FUNCTION PRINT_ABS_TREE ( T :TREE ) RETURN INTEGER IS					--| IMPRESSION D'UN POINTEUR DENOTANT UNE ANOMALIE
  SIZE		: INTEGER		:= 8;						--| LE "!?>" DE DEBUT PLUS LES DEUX . ET LE "<?!" DE FIN
BEGIN
  PUT ( "!?>" );
  SIZE := SIZE + L_PNN ( T.TY );							--| VALEUR DU CHAMP TYPE
  PUT ( '.' );
  SIZE := SIZE + L_PINT ( T.PG );							--| VALEUR DU CHAMP PAGE
  PUT('.');
  SIZE := SIZE + L_PINT( T.LN );							--| VALEUR DU CHAMP LIGNE (DE PAGE VIRTUELLE OU BLOC FICHIER ARBRE)
  PUT ( "<?!" );
  RETURN SIZE;
END;
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE PUT_LONG_DIGIT
--|
PROCEDURE PUT_LONG_DIGIT ( I :INTEGER ) IS						--| ENTIER A 4 CHIFFRES AVEC ZEROS NON SIGNIFICATIFS
  DUMMY: INTEGER;
BEGIN
  IF I < 1000 THEN
    PUT ( '0' );
    IF I < 100 THEN
      PUT ( '0' );
      IF I < 10 THEN
        PUT ( '0' );
       END IF;
    END IF;
  END IF;
  DUMMY := L_PINT ( I );
END;
   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE PRINT_TREE
--|
PROCEDURE PRINT_TREE ( T :TREE ) IS
  DUMMY		: INTEGER;
BEGIN
  DUMMY := L_PRINT_TREE ( T );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION L_PRINT_TREE
--|
FUNCTION L_PRINT_TREE ( T :TREE ) RETURN NATURAL IS

  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION TRAITE_SOURCELINE
  --|
  FUNCTION TRAITE_SOURCELINE RETURN NATURAL IS						--| CAS DU NOEUD S (SOURCE_LINE)
  BEGIN
    IF T.PG > PAGE_MAN.HIGH_VPG THEN							--| LE CHAMP PG EST HORS DU FICHIER ARBRE (ANORMAL)
      RETURN PRINT_ABS_TREE ( T );							--| IMPRIMER COMME $$TY.PG.LN$$
    END IF;
               
    DECLARE
      NB_CARS	: NATURAL;
      SLPTR	: TREE		:= (N, TY=> DN_SOURCELINE, PG=> T.SPG, LN=> T.SLN);	--| FABRIQUER UN POINTEUR DE SOURCELINE NORMAL AVEC LE POINTEUR SOURCE_POSITION
      SLNOD	: TREE		:= D( XD_NUMBER, SLPTR );				--| XD_NUMBER UN ENTIER
    BEGIN
      NB_CARS := L_PRINT_TREE( SLPTR );							--| FAIRE IMPRIMER LE NOEUD LIGNE SOURCE (PG=LIGNE ET LN=COL)
      PUT( '(' );									--| ON SUIT AVEC LE CONTENU
      IF SLNOD.TY = DN_NUM_VAL THEN							--| UNE VALEUR NUMERIQUE ENTIERE (16 BITS)
        NB_CARS := NB_CARS + L_PINT( SLNOD.PG );						--| FAIRE IMPRIMER LA VALEUR 16 BITS (NUM LIGNE)
      ELSE									--| ANOMALIE
        NB_CARS := NB_CARS + PRINT_ABS_TREE( SLNOD );					--| AU FORMAT $$TY.PG.LN$$ POUR INFORMATION
      END IF;
      PUT ( ',' );
      NB_CARS := NB_CARS + L_PINT( INTEGER( T.COL ) );
      PUT( ')' );
      RETURN NB_CARS + 3;								--| LES NOMBRES PLUS (,)
    END;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION TRAITE_NUM_VAL
  --|
  FUNCTION TRAITE_NUM_VAL RETURN NATURAL IS
  BEGIN
    IF T.PT = F THEN								--| VALEUR COURTE 16 BITS
      IF T.VAL < 0 THEN								--| VALEUR NEGATIVE
        RETURN L_PINT ( INTEGER( T.VAL ) );						--| IMPRIMER
      ELSE									--| VALEUR POSITIVE
        PUT ( '+' );								--| PREFIXER PAR LE SIGNE
        RETURN L_PINT ( INTEGER( T.VAL ) ) + 1;						--| IMPRIMER ET DONNER LA TAILLE AVEC LE SIGNE EN PLUS
      END IF;
               
    ELSIF T.PT = N THEN								--| POINTEUR VERS BLOC GRAND ENTIER
      IF NOT (T.PG IN 1.. PAGE_MAN.HIGH_VPG) THEN						--| ANOMALIE SUR L ADRESSE DE PAGE
        RETURN PRINT_ABS_TREE ( T );
      END IF;
              
      DECLARE									--| UN VRAI DN_NUM_VAL
        ENTETE		: TREE		:= DABS ( 0, T );				--| ENTETE CONTENANT LE NOMBRE DE DIGITS
        TYPE DOUBLET	IS ARRAY( 1..2 ) OF SHORT;
        FUNCTION TO_DOUBLET	IS NEW UNCHECKED_CONVERSION( TREE, DOUBLET );
        DD		: DOUBLET		:= TO_DOUBLET( DABS ( 1, T ) );		--| PREMIERE PAIRE DE DIGITS BASE 10000
        NB_CARS		: INTEGER		:= 0;
      BEGIN
        IF DD(1) >= 10000 THEN							--| 10000 EST AJOUTE AU PREMIER POUR NB NEGATIF
          PUT ( '-' ); 								--| CHIFFRE NEGATIF
        ELSE
          PUT ( '+' );								--| DE 0 A 9_999 : CHIFFRE POSITIF
        END IF;
        FOR I IN 1 .. ENTETE.LN LOOP
          DD := TO_DOUBLET( DABS ( I, T ) );						--| PAIRE DE DIGITS
          PUT_LONG_DIGIT( INTEGER( DD(1) MOD 10_000 ) );					--| SECOND DIGIT 10_000 AIRE
          PUT ('_');
          PUT_LONG_DIGIT( INTEGER( DD(2) MOD 10_000 ) );					--| PREMIER DIGIT 10_000 AIRE (MOD POUR LE PREMIER
          IF I /= ENTETE.LN THEN
            IF (I MOD 8) = 1 THEN
              NEW_LINE;
            END IF;
            PUT( '_' );
          END IF;
          NB_CARS := NB_CARS + 10;
        END LOOP;
        RETURN NB_CARS;
      END;
    END IF;
    RETURN 0;
  END;
       
BEGIN
       			--| DN_SOURCELINE
  CASE T.PT IS
  WHEN S =>									--| POSITION SOURCE
    RETURN TRAITE_SOURCELINE;
  WHEN F =>									--| TREE REPRESENTANT UN ENTIER 16 BITS STRICTEMENT NEGATIF OU UNE POSITION SOURCE
    IF T.TTY = DN_NUM_VAL THEN							--| VALEUR ENTIERE COURTE
      RETURN TRAITE_NUM_VAL;
    ELSE
      DECLARE
        NAM	: CONSTANT STRING		:= NODE_NAME'IMAGE ( T.TY );			--| CHAINE DU TYPE DE NOEUD
      BEGIN
        PUT ( '(' & NAM & ')' );							--| IMPRIMER LE NOM DU TYPE DE NOEUD
        RETURN NAM'LENGTH + 2;							--| AJOUTER SA LONGUEUR
      END;
    END IF;  
  WHEN N =>									--| 
    IF T.TY = DN_NUM_VAL THEN								--| VALEUR ENTIERE LONGUE
      RETURN TRAITE_NUM_VAL;
    END IF;  
      
    DECLARE
      NB_CARS	: INTEGER;
    BEGIN										--| PAS UNE VALEUR ENTIERE
      DECLARE
        NAM	: CONSTANT STRING		:= NODE_NAME'IMAGE( T.TY );			--| CHAINE DU TYPE DE NOEUD
      BEGIN
        PUT( '[' & NAM );								--| IMPRIMER LE NOM DU TYPE DE NOEUD
        NB_CARS := NAM'LENGTH + 1;							--| AJOUTER SA LONGUEUR
      END;
               
      PUT( ",P" );
      NB_CARS := NB_CARS + L_PINT( T.PG );						--| PAGE OU BLOC DU POINTEUR
      PUT( ",L" );
      NB_CARS := NB_CARS + L_PINT( T.LN ) + 5;						--| LIGNE DU POINTEUR ET AJOUTER LES TAILLES
      PUT( "]" );
               
      IF T.PG = 0 THEN								--| CAS INHABITUEL AU RELOC ?
        RETURN NB_CARS;								--| ARRETER ICI
      END IF;
               
      IF T.TY = DN_TXTREP THEN							--| CAS PARTICULIER D'UN TXTREP
        PUT ( ' ' );
        IF T.PG > PAGE_MAN.HIGH_VPG THEN						--| HORS BORNES (!)
          PUT ( "!?TXT?!" );
          NB_CARS := NB_CARS + 7;							--| TAILLE NOM PLUS UN' ' ET SIX $
          RETURN NB_CARS;
        ELSE
          DECLARE
            WORD_ZERO	: TREE		:= DABS( 0, T );
            WORD_ONE	: TREE		:= DABS( 1, T );
          BEGIN
            IF T.LN + WORD_ZERO.LN > LINE_IDX'LAST
              OR ELSE WORD_ZERO.LN > 32
              OR ELSE (IS_LITTLE_ENDIAN
              AND THEN WORD_ONE.PG MOD 256 >= PAGE_IDX( WORD_ZERO.LN ) * 4)
              OR ELSE (NOT IS_LITTLE_ENDIAN
              AND THEN WORD_ONE.PG / 256 >= PAGE_IDX( WORD_ZERO.LN ) * 4)
            THEN
              NB_CARS := NB_CARS + PRINT_ABS_TREE( WORD_ZERO );
              NB_CARS := NB_CARS + PRINT_ABS_TREE( WORD_ONE );
              RETURN NB_CARS + 1;
            END IF;
          END;
        END IF;
                  
        DECLARE
          NAM	: CONSTANT STRING		:= PRINT_NAME( T );
        BEGIN
          PUT( NAM );
          NB_CARS := NB_CARS + 1 + NAM'LENGTH;
        END;
      END IF;
      RETURN NB_CARS;
    END;
  WHEN L => NULL;
  END CASE;
  RETURN 0;
END L_PRINT_TREE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE PRINT_NODE
--|
PROCEDURE PRINT_NODE ( T :TREE; INDENT :NATURAL := 0 ) IS
       
  --|-----------------------------------------------------------------------------------------------
  --|		 PROCEDURE PRINT_SUB
  --|
  PROCEDURE PRINT_SUB ( T :TREE; IND :NATURAL ) IS
    A_SIZ		: ATTR_NBR	:= N_SPEC( T.TY ).NS_SIZE;
    N_SIZ		: ATTR_NBR	:= A_SIZ;
    A_SUB		: INTEGER		:= N_SPEC( T.TY ).NS_FIRST_A;
    TR		: TREE;
    SQ		: SEQ_TYPE;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE PRINT_SUB_TREE
    --|
    PROCEDURE PRINT_SUB_TREE ( T :TREE ) IS
    BEGIN
      PRINT_TREE( T );
      IF T.TY = DN_SYMBOL_REP AND THEN T.PG > 0 THEN
        PUT( ' ' );
        PUT( PRINT_NAME( T ) );
      END IF;
    END PRINT_SUB_TREE;
            
  BEGIN
    IF T.TY = DN_HASH THEN
      TR := DABS( 0, T );
      N_SIZ := TR.LN;
    END IF;
         
    FOR I IN 1 .. N_SIZ LOOP
            
      FOR J IN 1 .. IND LOOP
        PUT( ' ' );
      END LOOP;
      PUT( "  " );
            
      IF T.TY = DN_HASH THEN
        PUT( '-' );
      ELSE
        PUT( ATTR_IMAGE ( A_SPEC( A_SUB ).ATTR ) );
      END IF;
            
      IF (A_SPEC( A_SUB ).IS_LIST = FALSE) OR ELSE T.TY = DN_HASH THEN
        PUT( ": " );
        PRINT_SUB_TREE( DABS( I, T ) );
      ELSE
        SQ.FIRST := DABS ( I, T );
        SQ.NEXT := TREE_NIL;
               
        IF SQ.FIRST = TREE_NIL THEN
          PUT( ": < >" );
        ELSIF SQ.FIRST.TY /= DN_LIST THEN
          PUT( ": < " );
          PRINT_SUB_TREE( SQ.FIRST );
          PUT( " >" );
        ELSE
          PUT_LINE( ":" );
          FOR I IN 1 .. IND LOOP
            PUT( ' ' );
          END LOOP;
          PUT( "   < " );
          LOOP
            PRINT_SUB_TREE ( HEAD ( SQ ) );
            SQ := TAIL(SQ);
            EXIT WHEN SQ.FIRST = TREE_NIL;
            PUT_LINE( "," );
            FOR I IN 1 .. IND LOOP
              PUT( ' ' );
            END LOOP;
            PUT( "     " );
          END LOOP;
          PUT( " >" );
        END IF;
               
      END IF;
      NEW_LINE;
      A_SUB := A_SUB + 1;
    END LOOP;
         
  END PRINT_SUB;
         
BEGIN
  PRINT_TREE( T );
  NEW_LINE;
  IF T.LN /= 0 THEN
    IF T.PT = S THEN
      PRINT_SUB(  (N, PG=> T.PG, TY=> DN_SOURCELINE, LN=> T.LN ),  INDENT );
    ELSE
      PRINT_SUB( T, INDENT );
    END IF;
  END IF;
  NEW_LINE;
END PRINT_NODE;
--|-------------------------------------------------------------------------------------------------
END PRINT_NOD;
