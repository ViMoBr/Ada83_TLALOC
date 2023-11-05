WITH UNCHECKED_CONVERSION;
SEPARATE( IDL.SEM_PHASE )
--|-------------------------------------------------------------------------------------------------
--|		UNIV_OPS
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY UNIV_OPS IS
   
  NUM_VAL		: CONSTANT INTEGER	:= NODE_NAME'POS( DN_NUM_VAL );
   
  TYPE UDIGIT_PAIR_TYPE	IS RECORD
			  U1, U2	: UDIGIT;
			END RECORD;
			PRAGMA PACK( UDIGIT_PAIR_TYPE );
            
  TYPE VECTOR_DIGITS_PAIRS	IS ARRAY(1..LINE_IDX(126)) OF UDIGIT_PAIR_TYPE;
			PRAGMA PACK( VECTOR_DIGITS_PAIRS );

  TYPE VECTOR_PAIRS		IS RECORD
			  L	: NATURAL;					--| NOMBRE DE "CHIFFRES" 10_000 AIRES
			  S	: UDIGIT;						--| SIGNE +1 OR -1
			  P	: VECTOR_DIGITS_PAIRS;				--| PAIRES DE CHIFFRES
			END RECORD;			PRAGMA PACK( VECTOR_PAIRS );
         
   
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE DIGIT_MUL
--|
PROCEDURE DIGIT_MUL ( A, B :IN UDIGIT; HIGH, LOW :OUT UDIGIT ) IS
  A1	: UDIGIT	:= A / 100;
  B1	: UDIGIT	:= B / 100;
  A2	: UDIGIT	:= A MOD 100;
  B2	: UDIGIT	:= B MOD 100;
  XX	: UDIGIT	:= A1 * B2 + A2 * B1;
  LL	: UDIGIT	:= A2 * B2 + (XX MOD 100) * 100;
BEGIN
  LOW  := LL MOD 10_000;
  HIGH := A1 * B1 + LL / 10_000 + XX / 100;
END DIGIT_MUL;
--|------------------------------------------------------------------------------------------------
--|		FUNCTION DIGIT_DIV
--|
FUNCTION DIGIT_DIV ( H, L, A :UDIGIT ) RETURN UDIGIT IS
  QUO	: UDIGIT;
  PH, PL	: UDIGIT;			-- TRIAL PRODUCT
BEGIN
				-- MUST HAVE H < A (OTHERWISE OVERFLOW)      
  IF H = 0 THEN
    RETURN L / A;
  ELSIF A < 100 THEN
				-- FORCE A >= 100
    RETURN DIGIT_DIV( H*100+L/100, (L MOD 100)*100, A*100);
  ELSE
				-- ALWAYS REDUCE TO A SIMPLER CASE
    IF H >= 100 THEN
      QUO := (H / ((A+99) / 100)) * 100;
    ELSE
      QUO := ((H*100) + (L/100)) / ((A+99) / 100);
    END IF;
				-- ASSERT: QUO > 0
    DIGIT_MUL(A, QUO, PH, PL);
				-- ASSERT: H*10000 + L = QUO*A + PH*10000 + PL
    IF L >= PL THEN
      RETURN QUO + DIGIT_DIV(H - PH, L - PL, A);
    ELSE
      RETURN QUO + DIGIT_DIV(H - 1 - PH, L + 10000 - PL, A);
    END IF;
  END IF;
END DIGIT_DIV;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION U_INT
--|
FUNCTION U_INT ( V :VECTOR ) RETURN TREE IS
BEGIN

CAS_RETOUR_ELEMENT_HI_SHORT_CODE:							--| QUAND LA VALEUR EST DANS -32768 .. 32767 ON REND UN TREE HI AVEC ABSS ET NSIZ
  BEGIN
    IF V.L = 1 THEN									--| UN SEUL UDIGIT : ENTIER DANS -10_000 .. 10_000
      IF V.D( 1 ) = 0 THEN
        RETURN (HI, NOTY=> DN_NUM_VAL, ABSS=> 0, NSIZ=> 0 );
      ELSIF V.S = +1 THEN
        RETURN (HI, NOTY=> DN_NUM_VAL, ABSS=> POSITIVE_SHORT( V.D( 1 ) ), NSIZ=> 0 );
      ELSIF V.S = -1 THEN
        RETURN (HI, NOTY=> DN_NUM_VAL, ABSS=> POSITIVE_SHORT( V.D( 1 ) - 1 ), NSIZ=> 1 );
      END IF;

    ELSIF V.L = 2 THEN								--| 2 UDIGITS ET CAS DE L INTERVALLE -32768 .. 32767
      IF V.S = -1 AND THEN ( V.D( 2 ) = 3 AND V.D( 1 ) = 2_768 ) THEN				--| VALEUR -32_768
        RETURN (PT=>HI, NOTY=> DN_NUM_VAL, ABSS=> 32_767, NSIZ=>1 );
      END IF;
      IF V.D( 2 ) <= 2								--| VALEURS ABSOLUES DANS 0 .. 29_999
         OR ELSE ( V.D( 2 ) = 3 AND V.D( 1 ) <= 2_767 )					--| OU VALEURS ABSOLUES DANS 30_000 .. 32_767	
      THEN
        IF V.S = +1 THEN								--| VALEURS POSITIVES
          RETURN (HI, NOTY=> DN_NUM_VAL,
		ABSS=> POSITIVE_SHORT( V.D( 2 ) * 10_000 + V.D( 1 ) ), NSIZ=> 0 );
        ELSIF V.S = -1 THEN								--| VALEURS NEGATIVES
          RETURN (HI, NOTY=> DN_NUM_VAL,
		ABSS=> POSITIVE_SHORT( V.D( 2 ) * 10_000 + V.D( 1 ) - 1 ), NSIZ=> 1 );
        END IF;
      END IF;
    END IF;
  END CAS_RETOUR_ELEMENT_HI_SHORT_CODE;

CAS_RETOUR_BLOC_UDIGITS:       
  DECLARE
    W_LEN		: ATTR_NBR	:= ATTR_NBR( (V.L+1) / 2 );				--| NOMBRE DE MOTS (PAIRES DE UDIGITS) DU BLOC
    R		: TREE		:= MAKE( DN_NUM_VAL, W_LEN );				--| CREER LE NOEUD
  BEGIN

PORTER_LE_SIGNE:
    DECLARE
      ENTETE	: TREE	:= DABS( 0, R );						--| PRENDRE L ENTETE DU NOEUD DN_NUM_VAL
    BEGIN
      IF V.S = -1 THEN ENTETE.ABSS := 1;						--| SIGNE NEGATIF INDIQUER DANS LE ABSS
      ELSE ENTETE.ABSS := 0;
      END IF;
      DABS( 0, R, ENTETE );								--| REPORTER DANS L ENTETE
    END PORTER_LE_SIGNE;

COPIE_PAIRES_UDIGITS:
    DECLARE
      ROUND_LEN		: ATTR_NBR	:= ATTR_NBR( V.L / 2 );
      VDP			: VECTOR_PAIRS;	FOR VDP USE AT V'ADDRESS;
      FUNCTION CAST_TREE	IS NEW UNCHECKED_CONVERSION( UDIGIT_PAIR_TYPE, TREE );
    BEGIN
      FOR I IN 1..ROUND_LEN LOOP
        DABS( I, R, CAST_TREE( VDP.P( I ) ) );						--| COPIER UNE PAIRE VDP.P(I)
      END LOOP;

      IF V.L MOD 2 = 1 THEN								--| NOMBRE IMPAIR DE MOTS
        DABS( ROUND_LEN+1, R, CAST_TREE( (V.D( V.L ), 0) ) );				--| COPIER LE DERNIER UDIGIT SUIVI DE 0
      END IF;
    END COPIE_PAIRES_UDIGITS;
    
    RETURN R;
  END CAS_RETOUR_BLOC_UDIGITS;
END U_INT;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION U_REAL
--|
FUNCTION U_REAL ( NUMER, DENOM :VECTOR ) RETURN TREE IS
  R	: TREE	:= MAKE( DN_REAL_VAL );
BEGIN
  D( XD_NUMER, R, U_INT( NUMER ) );
  D( XD_DENOM, R, U_INT( DENOM ) );
  RETURN R;
END U_REAL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION U_REAL
--|
FUNCTION U_REAL ( NUMER, DENOM :TREE ) RETURN TREE IS
  N_SPREAD, D_SPREAD	: VECTOR;
  THE_REAL		: TREE	:= MAKE( DN_REAL_VAL );
BEGIN
  SPREAD( NUMER, N_SPREAD );
  SPREAD( DENOM, D_SPREAD );
      
  IF D_SPREAD.L = 2 AND THEN D_SPREAD.D( 1 ) = 0 AND THEN D_SPREAD.D( 2 ) = 0 THEN	--| DENOMINATEUR NUL
    RETURN TREE_VOID;
  END IF;

  N_SPREAD.S := N_SPREAD.S * D_SPREAD.S;
  D_SPREAD.S := +1;
  V_LOWEST_TERMS( N_SPREAD, D_SPREAD );
  D( XD_NUMER, THE_REAL, U_INT( N_SPREAD ) );
  D( XD_DENOM, THE_REAL, U_INT( D_SPREAD ) );
  RETURN THE_REAL;
END U_REAL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SPREAD
--|
PROCEDURE SPREAD ( T :TREE; V :IN OUT VECTOR ) IS
  BAD_NSIZ, CANNOT_SPREAD, BAD_SIGN	: EXCEPTION;
BEGIN
  IF T.PT = HI THEN									--| CAS DE L ENTIER COURT -32768 .. 32767
    IF T.NOTY = DN_NUM_VAL THEN							--| ASSURER LE BON TYPE DE NOEUD
      DECLARE
        IVAL	: INTEGER;
      BEGIN
        IF    T.NSIZ = +1 THEN IVAL :=  INTEGER( T.ABSS );
        ELSIF T.NSIZ = -1 THEN IVAL := -INTEGER( T.ABSS ) - 1;
        ELSE RAISE BAD_NSIZ;
        END IF;
        SPREAD( IVAL, V );
      END;
      ELSE RAISE CANNOT_SPREAD;
    END IF;
         
  ELSE										--| CAS DU POINTEUR VERS BLOC DE UDIGITS
    IF T.PT /= P OR ELSE T.TY /= DN_NUM_VAL THEN						--| ASSURER LE TYPE POINTEUR ET NOEUD
      RAISE CANNOT_SPREAD;
    END IF;

PREPARE_VECTOR_FROM_BLOCK:
    DECLARE
      ENTETE	: TREE		:= DABS( 0, T );					--| ENTETE CONTIENT LE SIGNE DANS ABSS ET LE NOMBRE DE PAIRES DANS NSIZ
      VDP		: VECTOR_PAIRS;	FOR VDP USE AT V'ADDRESS;
      FUNCTION CAST_UDIGIT_PAIR	IS NEW UNCHECKED_CONVERSION( TREE, UDIGIT_PAIR_TYPE );
    BEGIN
      V.L := 2 * NATURAL( ENTETE.NSIZ );
      IF ENTETE.ABSS = 1 THEN V.S := -1;						--| NOMBRE INDIQUE NEGATIF
      ELSIF ENTETE.ABSS = 0 THEN V.S := +1;						--| SINON SIGNE POSITIF
      ELSE RAISE BAD_SIGN;
      END IF;
      FOR I IN 1 .. ENTETE.NSIZ LOOP
        VDP.P( I ) := CAST_UDIGIT_PAIR( DABS( I, T ) );
      END LOOP;

    EXCEPTION
      WHEN BAD_SIGN	=>
        PUT_LINE( "!! SPREAD ABSS NOT +1/0 =" & POSITIVE_SHORT'IMAGE( ENTETE.ABSS ) );
        RAISE PROGRAM_ERROR;
    END PREPARE_VECTOR_FROM_BLOCK;
 
    NORMALIZE( V );
  END IF;

EXCEPTION
  WHEN BAD_NSIZ=>         
    PUT_LINE( "!! SPREAD NSIZ NOT +-1 =" & ATTR_NBR'IMAGE( T.NSIZ ) );
    RAISE PROGRAM_ERROR;
  WHEN CANNOT_SPREAD=>
    DECLARE
      NN	: NODE_NAME;
    BEGIN
      CASE T.PT IS
      WHEN HI	=> NN := T.NOTY;
      WHEN P | L	=> NN := T.TY;
      WHEN S	=> NN := DN_SOURCELINE;
      END CASE;
      PUT_LINE( "!! CANNOT SPREAD " & NODE_NAME'IMAGE( NN ) );
      RAISE PROGRAM_ERROR;
    END;
END SPREAD;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE SPREAD
--|
PROCEDURE SPREAD ( I :INTEGER; V :IN OUT VECTOR ) IS
  VAL_POS		: INTEGER		:= ABS( I );
BEGIN
  IF I < 0 THEN V.S := -1;								--| ENTIER NEGATIF SIGNE NEGATIF
  ELSE V.S := +1;									--| SIGNE POSITIF
  END IF;

  V.D(1) := UDIGIT( VAL_POS MOD 10_000 );						--| 0 .. 1E4 -1
  V.L := 1;

  IF VAL_POS < 100_000_000 THEN							--| 0 .. 1E8 -1
    V.D(2) := UDIGIT( (VAL_POS / 10_000) MOD 10_000 );
    V.L := 2;
  ELSE
    V.D(2) := UDIGIT( (VAL_POS / 100_000_000) MOD 10_000 );
    V.L := 3;									--| TROIS UDIGITS
  END IF;
     
  NORMALIZE( V );
END SPREAD;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE NORMALIZE
--|
PROCEDURE NORMALIZE ( V :IN OUT VECTOR ) IS
BEGIN
  IF V.L > 252 THEN
    PUT_LINE ( "!! UNIV INTEGER > 1E756 - COMPILER LIMITATION" );
    RAISE PROGRAM_ERROR;
  END IF;

ENLEVE_ZEROS_NON_SIGNIF:      
  WHILE V.L > 1 AND V.D( V.L ) = 0 LOOP
    V.L := V.L - 1;
  END LOOP ENLEVE_ZEROS_NON_SIGNIF;
END NORMALIZE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_ADD
--|
PROCEDURE V_ADD ( A :VECTOR; R :IN OUT VECTOR ) IS
  ALEN	: INTEGER	:= A.L;
  TEMP	: UDIGIT;
  CARRY	: UDIGIT	:= 0;
BEGIN
  IF R.L < A.L THEN
    FOR I IN R.L + 1 .. A.L LOOP
      R.D( I ) := A.D( I );
    END LOOP;
    ALEN := R.L;
    R.L := A.L;
  END IF;
         
  R.L := R.L + 1;
  R.D( R.L ) := 0;
  FOR I IN 1 .. ALEN LOOP
    TEMP := A.D( I ) + R.D( I ) + CARRY;
    IF TEMP >= 10_000 THEN
      CARRY := 1;
      TEMP := TEMP - 10_000;
    ELSE
      CARRY := 0;
    END IF;
    R.D( I ) := TEMP;
  END LOOP;
         
  FOR I IN ALEN + 1 .. R.L LOOP
    EXIT WHEN CARRY = 0;
    TEMP := R.D( I ) + CARRY;
    IF TEMP >= 10_000 THEN
      TEMP := TEMP - 10_000;
      CARRY := 1;
    ELSE
      CARRY := 0;
    END IF;
    R.D( I ) := TEMP;
  END LOOP;
         
  NORMALIZE( R );
END V_ADD;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_SUB
--|
PROCEDURE V_SUB ( A :VECTOR; R :IN OUT VECTOR ) IS     		--| ON SUPPOSE |A| <= |R| !!!
  TEMP	: UDIGIT;
  BORROW	: UDIGIT := 0;
BEGIN
  IF A.L = R.L AND THEN A = R THEN
    R.L := 1;
    R.D( 1 ) := 0;
  END IF;
         
  FOR I IN 1 .. A.L LOOP
    TEMP := R.D( I ) - A.D( I ) - BORROW;
    IF TEMP < 0 THEN
      BORROW := 1;
      TEMP := TEMP + 10_000;
    ELSE
      BORROW := 0;
    END IF;
    R.D( I ) := TEMP;
  END LOOP;
         
  FOR I IN A.L + 1 .. R.L LOOP
    EXIT WHEN BORROW = 0;
    TEMP := R.D( I ) - BORROW;
    IF TEMP < 0 THEN
      TEMP := TEMP + 10_000;
      BORROW := 1;
    ELSE
      BORROW := 0;
    END IF;
    R.D( I ) := TEMP;
  END LOOP;
         
  NORMALIZE(R);
END V_SUB;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_MUL
--|
PROCEDURE V_MUL ( A, B :VECTOR; R :IN OUT VECTOR ) IS
  H, L, TEMP, CARRY	: UDIGIT;
  K		: INTEGER;
BEGIN
  R.S := +1;
  R.L := A.L + B.L;
  IF R.L > 252 THEN
    PUT_LINE ( "!! UNIV PRODUCT TOO LARGE");
    RAISE PROGRAM_ERROR;
  END IF;
         
  FOR I IN 1 .. R.L LOOP
    R.D( I ) := 0;
  END LOOP;
         
  FOR I IN 1 .. A.L LOOP
    FOR J IN 1 .. B.L LOOP
      K := I + J - 1;
      DIGIT_MUL ( A.D( I ), B.D( J ), H, L );
      TEMP := R.D( K ) + L;
      IF TEMP >= 10_000 THEN
        CARRY := 1;
        TEMP := TEMP - 10_000;
      ELSE
        CARRY := 0;
      END IF;

      R.D( K ) := TEMP;
      K := K + 1;
      TEMP := R.D( K ) + H + CARRY;

      IF TEMP >= 10_000 THEN
        CARRY := 1;
        TEMP := TEMP - 10_000;
      ELSE
        CARRY := 0;
      END IF;
      R.D( K ) := TEMP;
               
      WHILE CARRY > 0 LOOP
        K := K + 1;
        TEMP := R.D( K ) + CARRY;
        IF TEMP >= 10_000 THEN
          CARRY := 1;
          TEMP := TEMP - 10_000;
        ELSE
          CARRY := 0;
        END IF;
        R.D( K ) := TEMP;
      END LOOP;
    END LOOP;
  END LOOP;
         
  NORMALIZE ( R );
END V_MUL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_SCALE
--|
PROCEDURE V_SCALE ( A :INTEGER; R :IN OUT VECTOR ) IS
  H, L	: UDIGIT;
  CARRY	: UDIGIT	:= 0;
BEGIN
  FOR I IN 1..R.L LOOP
    DIGIT_MUL ( UDIGIT( A ), R.D( I ), H, L );
    L := L + CARRY;
    R.D( I ) := L MOD 10_000;
    CARRY := H + L/10_000;
  END LOOP;
         
  IF CARRY > 0 THEN
    R.L := R.L + 1;
    R.D( R.L ) := CARRY;
  END IF;
END V_SCALE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_DIV
--|
PROCEDURE V_DIV ( A :VECTOR; R, Q :IN OUT VECTOR ) IS		--| A EST LE DIVISEUR, R LE DIVIDENDE DEVIENT RESTE, Q EST LE QUOTIENT
                -- A POOR LONG-DIVISION ALGORITHM (EXTRA ITERATIONS)
                -- GOOD ENOUGH FOR GOVERNMENT WORK, FOR NOW
  A_TRIAL		: CONSTANT UDIGIT := A.D(A.L) + 1;		--| CHIFFRE LE PLUS SIGNIFICATIF DU DIVISEUR +1
  QDIG, CARRY, TEMP	: UDIGIT;
  R_PREC		: VECTOR;
  PPROD		: VECTOR;
BEGIN
      
  IF A.D( 1 ) = 0 AND THEN A.L = 1 THEN			--| SI LE PREMIER CHIFFRE EST NUL ET LE NOMBRE DE CHIFFRES EST 1 
    PUT_LINE ( "V_DIV: DIVIDE BY ZERO" );			--| DIVISEUR NUL
    RAISE PROGRAM_ERROR;
  END IF;
      
  R_PREC := R;
  Q.S := +1;
  DECLARE
    DIFF	: INTEGER	:= R.L - A.L + 1;
  BEGIN
    IF DIFF <= 0 THEN
      Q.L := 1;
    ELSE
      Q.L := R.L - A.L + 1;
    END IF;
  END;
         
  FOR I IN 1 .. Q.L LOOP
    Q.D(I) := 0;
  END LOOP;
         
  WHILE NOT V_LESS ( R, A ) LOOP			--| TANT QUE LE RESTE EST SUPERIEUR OU EGAL AU DIVISEUR
    IF R.L = A.L				--| RESTE ET DIVISEUR ONT MÊME NOMBRE DE CHIFFRES
       AND THEN R.D( R.L ) = A.D( A.L )			--| ET MÊME CHIFFRE LE PLUS SIGNIFICATIF
    THEN					--| ON SAIT QUE LE RESTE EST >= AU DIVISEUR
      QDIG := 1;				--| LA DIVISION DES CHIFFRES LES PLUS SIGNIFICATIFS DONNERA 1
      R.L := R.L + 1;				--| ALLONGER LE RESTE
      R.D( R.L ) := 0;				--| POUR UN ZERO NON SIGNIFICATIF
    ELSE		--| ILS N'ONT PAS MÊME NOMBRE DE CHIFFRES OU PAS MÊME CHIFFRE LE PLUS SIGNIFICATIF
      IF R.D( R.L ) >= A_TRIAL THEN	
        R.L := R.L + 1;
        R.D( R.L ) := 0;
      END IF;
      QDIG := DIGIT_DIV ( R.D( R.L ), R.D( R.L-1 ), A_TRIAL );
    END IF;
            
    CARRY := QDIG;
            
    FOR I IN R.L - A.L .. Q.L LOOP
      TEMP := Q.D( I ) + CARRY;
      IF TEMP < 10_000 THEN
        Q.D(I) := TEMP;
        EXIT;
      END IF;
      Q.D( I ) := TEMP - 10_000;
      CARRY := 1;
    END LOOP;
            
    R := R_PREC;
    V_MUL ( Q, A, PPROD );	--| QUOTIENT * A
    IF V_LESS ( R, PPROD ) THEN
      RAISE PROGRAM_ERROR;
    END IF;

    V_SUB ( PPROD, R );	--| RETIRE DU RESTE PRECEDENT
  END LOOP;
  NORMALIZE( Q );
END V_DIV;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_REM
--|
PROCEDURE V_REM ( A :VECTOR; R :IN OUT VECTOR ) IS
   INUTILE	: VECTOR;
BEGIN
  V_DIV ( A, R, INUTILE );
END V_REM;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	PROCEDURE V_GCD
--|
PROCEDURE V_GCD ( A, B :VECTOR; R :IN OUT VECTOR ) IS
  S	: VECTOR	:= B;
BEGIN
  R := A;
  LOOP
    V_REM ( R, S );
    IF S.L = 1 AND THEN S.D( 1 ) = 0 THEN
      RETURN;
    END IF;
    V_REM ( S, R );
    IF R.L = 1 AND THEN R.D( 1 ) = 0 THEN
      R := S;
      RETURN;
    END IF;
  END LOOP;
END V_GCD;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE V_LOWEST_TERMS
--|
PROCEDURE V_LOWEST_TERMS ( A, B :IN OUT VECTOR ) IS
  GCD	: VECTOR;
  TREM	: VECTOR;
  SIGN	: UDIGIT;
BEGIN
  IF B.L = 1 AND THEN B.D( 1 ) = 1 THEN
    RETURN;
  END IF;
  IF A.L = 1 AND THEN A.D( 1 ) = 0 THEN
    B.L := 1;
    B.D( 1 ) := 1;
    RETURN;
  END IF;
  SIGN := A.S * B.S;
  V_GCD ( A, B, GCD );
  IF GCD.L > 1 OR ELSE GCD.D(1) > 1 THEN
    TREM := A;
    V_DIV ( GCD, TREM, A );
    TREM := B;
    V_DIV ( GCD, TREM, B );
  END IF;
  A.S := SIGN;
  B.S := +1;
END V_LOWEST_TERMS;
--|#################################################################################################
--|		FUNCTION V_EQUAL
--|
FUNCTION V_EQUAL ( A, B :VECTOR ) RETURN BOOLEAN IS					--| COMPARAISON EN VALEUR ABSOLUE
BEGIN
  IF A.L /= B.L THEN
    RETURN FALSE;
  ELSE
    RETURN A.D(1..A.L) = B.D(1..B.L);
  END IF;
END V_EQUAL;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION V_LESS
--|
FUNCTION V_LESS ( A, B :VECTOR ) RETURN BOOLEAN IS					--| NE PREND PAS EN COMPTE LE SIGNE
BEGIN
  IF A.L /= B.L THEN
    RETURN A.L < B.L;
  END IF;
  FOR I IN REVERSE 1 .. A.L LOOP
    IF A.D(I) /= B.D(I) THEN
      RETURN A.D(I) < B.D(I);
    END IF;
  END LOOP;
  RETURN FALSE;
END V_LESS;
   
--|-------------------------------------------------------------------------------------------------
END UNIV_OPS;
