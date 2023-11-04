    SEPARATE ( IDL.SEM_PHASE )
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
    FUNCTION EVAL_NUM(TXT: STRING) RETURN TREE IS
      USE UNIV_OPS;
   
      MAXCOL: CONSTANT INTEGER := TXT'LAST;
      COL: INTEGER := TXT'FIRST;
      CHR : CHARACTER := TXT(TXT'FIRST);
      SCALEFACTOR : INTEGER := INTEGER'LAST;
      VNUMER: VECTOR;
      VDENOM: VECTOR;
      RADIX:  INTEGER := 10;
      EXPONENT: INTEGER := 0;
      EXPONENT_POSITIVE: BOOLEAN := TRUE;
   
   
       PROCEDURE V_CLEAR(ARG: OUT VECTOR) IS
      BEGIN
         ARG.S := +1;
         ARG.L := 1;
         ARG.D(1) := 0;
      END V_CLEAR;
   
       PROCEDURE V_INCREMENT(DLTA: INTEGER; V: IN OUT VECTOR) IS
         TEMP: UDIGIT;
         CARRY : UDIGIT := 0;
      BEGIN
         V_SCALE(RADIX,V);
         TEMP := V.D(1) + UDIGIT(DLTA);
         IF TEMP >= 10000 THEN
            CARRY := 1;
            TEMP := TEMP - 10000;
         END IF;
         V.D(1) := TEMP;
         FOR I IN 2 .. V.L LOOP
            IF CARRY = 0 THEN
               RETURN;
            END IF;
            TEMP := V.D(I) + 1;
            IF TEMP >= 10000 THEN
               CARRY := 1;
               TEMP := TEMP - 10000;
            ELSE
               CARRY := 0;
            END IF;
            V.D(I) := TEMP;
         END LOOP;
         IF CARRY > 0 THEN
            V.L := V.L + 1;
            V.D(V.L) := CARRY;
            NORMALIZE(V); -- TO CHECK FOR OVERFLOW
         END IF;
      END V_INCREMENT;
   
       PROCEDURE NEXT_CHR IS
      BEGIN
         COL := COL + 1;
         IF COL <= MAXCOL THEN
            CHR := TXT(COL);
         ELSE
            CHR := ' ';
         END IF;
      END NEXT_CHR;
   
   BEGIN
      V_CLEAR ( VNUMER );
                -- GET INTEGER VAL OR RADIX
      WHILE CHR IN '0' .. '9' OR ELSE CHR = '.' OR ELSE CHR = '_' LOOP
         IF CHR = '.' THEN
            SCALEFACTOR := 0;
         ELSIF CHR /= '_' THEN
            V_INCREMENT ( CHARACTER'POS ( CHR ) - CHARACTER'POS ( '0' ), VNUMER );
            SCALEFACTOR := SCALEFACTOR - 1;
         END IF;
         NEXT_CHR;
      END LOOP;
      IF CHR = '#' THEN
         RADIX := INTEGER(VNUMER.D(1));
         VNUMER.D(1) := 0;
         NEXT_CHR;
         WHILE CHR /= '#' LOOP
            IF CHR = '.' THEN
               SCALEFACTOR := 0;
            ELSIF CHR = '_' THEN
               NULL;
            ELSIF CHR <= '9' THEN
               V_INCREMENT (CHARACTER'POS(CHR) - CHARACTER'POS('0'), VNUMER );
               SCALEFACTOR := SCALEFACTOR - 1;
            ELSE
               V_INCREMENT (CHARACTER'POS(CHR) - CHARACTER'POS('A') + 10, VNUMER );
               SCALEFACTOR := SCALEFACTOR - 1;
            END IF;
            NEXT_CHR;
         END LOOP;
         NEXT_CHR;
         
      END IF;
      IF CHR = 'E' THEN
         NEXT_CHR;
         IF CHR = '+' THEN
            NEXT_CHR;
         ELSIF CHR = '-' THEN
            NEXT_CHR;
            EXPONENT_POSITIVE := FALSE;
         END IF;
         WHILE CHR /= ' ' LOOP
            IF EXPONENT > 3275 THEN
               PUT_LINE ( "!! EXPONENT IN NUMERIC LIT TOO LARGE" );
               RAISE PROGRAM_ERROR;
            END IF;
            EXPONENT := EXPONENT * 10 + CHARACTER'POS ( CHR ) - CHARACTER'POS ( '0' );
            NEXT_CHR;
         END LOOP;
         IF NOT EXPONENT_POSITIVE THEN
            EXPONENT := - EXPONENT;
         END IF;
      END IF;
      IF SCALEFACTOR < 0 THEN
         EXPONENT := EXPONENT + SCALEFACTOR;
         V_CLEAR ( VDENOM );
         VDENOM.D(1) := 1;
      END IF;
      
      IF EXPONENT > 0 THEN
         FOR I IN 1 .. EXPONENT LOOP
            V_SCALE(RADIX, VNUMER);
         END LOOP;
      ELSIF EXPONENT < 0 THEN
         FOR I IN 1 .. - EXPONENT LOOP
            V_SCALE(RADIX, VDENOM);
         END LOOP;
      END IF;
      
      
      
      
      IF SCALEFACTOR >= 0 THEN
         VNUMER.D(VNUMER.L+1) := 0;
         RETURN U_INT(VNUMER);
      ELSE
         V_LOWEST_TERMS(VNUMER,VDENOM);
         VNUMER.D(VNUMER.L+1) := 0;
         VDENOM.D(VDENOM.L+1) := 0;
         RETURN U_REAL(VNUMER, VDENOM);
      END IF;
   END EVAL_NUM;
