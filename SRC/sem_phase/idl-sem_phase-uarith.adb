   WITH TEXT_IO; USE  TEXT_IO;
    SEPARATE ( IDL.SEM_PHASE )
    --|----------------------------------------------------------------------------------------------
    --|	UARITH
    --|----------------------------------------------------------------------------------------------
    PACKAGE BODY UARITH IS
    
      USE UNIV_OPS, EXPRESO;
   
      --|-------------------------------------------------------------------------------------------
      --|	FUNCTION IS_ZERO
       FUNCTION IS_ZERO ( V :VECTOR ) RETURN BOOLEAN IS
      BEGIN
         RETURN V.D( 1..V.L ) = (1..V.L => 0);
      END IS_ZERO;
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION U_VAL
       FUNCTION U_VAL ( A :INTEGER ) RETURN TREE IS
         A_SPREAD	: VECTOR;
      BEGIN
         SPREAD ( A, A_SPREAD);
         RETURN U_INT ( A_SPREAD);
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION U_VALUE
       FUNCTION U_VALUE ( TXT :STRING ) RETURN TREE IS
      BEGIN
         RETURN EVAL_NUM ( TXT);
      END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION U_POS
       FUNCTION U_POS ( A :TREE ) RETURN INTEGER IS
      BEGIN
         IF A.LN /= 0 THEN
            RAISE PROGRAM_ERROR;
         END IF;
         RETURN INTEGER( A.PG );
      END U_POS;
--|#################################################################################################
--|	FUNCTION U_EQUAL
FUNCTION U_EQUAL ( LEFT, RIGHT :TREE ) RETURN TREE IS
BEGIN
  IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
    RETURN TREE_VOID;
  ELSIF LEFT.TY = DN_NUM_VAL THEN
    DECLARE
      L_SPREAD, R_SPREAD	: VECTOR;
    BEGIN
      SPREAD ( LEFT, L_SPREAD );
      SPREAD ( RIGHT, R_SPREAD );
      IF L_SPREAD.S = R_SPREAD.S AND THEN V_EQUAL ( L_SPREAD, R_SPREAD ) THEN
        RETURN U_VAL ( 1 );
      ELSE
        RETURN U_VAL ( 0 );
      END IF;
    END;
  ELSE					--| VALEUR REELLE
    RETURN U_EQUAL ( D( XD_NUMER, LEFT) * D( XD_DENOM, RIGHT ), D( XD_NUMER, RIGHT ) * D( XD_DENOM, LEFT ) );
  END IF;
END;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION U_NOT_EQUAL
       FUNCTION U_NOT_EQUAL ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         RETURN NOT U_EQUAL ( LEFT, RIGHT );
      END U_NOT_EQUAL;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "<"
       FUNCTION "<" ( LEFT, RIGHT : TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
               IF L_SPREAD.S < 0 THEN
                  IF R_SPREAD.S > 0 OR ELSE V_LESS ( R_SPREAD, L_SPREAD ) THEN
                     RETURN U_VAL ( 1 );
                  END IF;
               ELSE
                  IF R_SPREAD.S > 0 AND THEN V_LESS ( L_SPREAD, R_SPREAD ) THEN
                     RETURN U_VAL ( 1 );
                  END IF;
               END IF;
               RETURN U_VAL ( 0 );
            END;
         ELSE					--| VALEUR RÉELLE
            RETURN "<" (	D ( XD_NUMER, LEFT ) * D ( XD_DENOM, RIGHT ),
               D ( XD_NUMER, RIGHT ) * D ( XD_DENOM, LEFT )
               );
         END IF;
      END "<";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "<="
       FUNCTION "<=" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         RETURN NOT (RIGHT < LEFT);
      END "<=";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION ">"
       FUNCTION ">" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         RETURN (RIGHT < LEFT);
      END ">";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION ">="
       FUNCTION ">=" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         RETURN NOT (LEFT < RIGHT);
      END ">=";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION U_MEMBER
       FUNCTION U_MEMBER ( VALUE, DISCRETE_RANGE :TREE ) RETURN TREE IS
      BEGIN
         IF VALUE = TREE_VOID THEN
            RETURN TREE_VOID;
         END IF;
      
         IF DISCRETE_RANGE.TY = DN_RANGE THEN
            RETURN (VALUE >= EXPRESO.GET_STATIC_VALUE ( D ( AS_EXP1, DISCRETE_RANGE ) ) )
               AND (VALUE <= GET_STATIC_VALUE ( D (AS_EXP2, DISCRETE_RANGE ) ) );
         
         ELSIF DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE THEN
            TEXT_IO.PUT_LINE ( "!! $$$$ RANGE ATTR DISCR SUBT" );
            RETURN TREE_VOID;
         
         ELSIF DISCRETE_RANGE.TY = DN_DISCRETE_SUBTYPE THEN
            DECLARE
               SUBTYPE_INDICATION	: CONSTANT TREE	:= D ( AS_SUBTYPE_INDICATION, DISCRETE_RANGE );
               NAME		: CONSTANT TREE	:= D ( AS_NAME, SUBTYPE_INDICATION );
               CONSTRAINT	: CONSTANT TREE	:= D ( AS_CONSTRAINT, SUBTYPE_INDICATION );
            BEGIN
               IF CONSTRAINT.TY IN CLASS_RANGE THEN
                  RETURN U_MEMBER ( VALUE, CONSTRAINT );
               ELSIF CONSTRAINT.TY IN CLASS_REAL_CONSTRAINT AND THEN D ( AS_RANGE, CONSTRAINT ) /= TREE_VOID THEN
                  RETURN U_MEMBER ( VALUE, D ( AS_RANGE, CONSTRAINT ) );
               ELSIF CONSTRAINT /= TREE_VOID THEN
                  PUT_LINE ( "!! $$$$ U_MEMBER: INDEX/DSCRMT CONSTRAINT" );
                  RAISE PROGRAM_ERROR;
               END IF;
            
               IF D ( SM_DEFN, NAME ) = TREE_VOID THEN
                  RETURN TREE_VOID;
               END IF;
                                -- (BETTER BE A DISCRETE SUBTYPE)
               RETURN U_MEMBER ( VALUE, D ( SM_RANGE, D ( SM_TYPE_SPEC, D ( SM_DEFN, NAME ) ) ) );
            END;
         END IF;
         RETURN TREE_VOID;
      END U_MEMBER;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION "<="(LEFT, RIGHT: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN (LEFT <= RIGHT) = U_VAL ( 1);
      END "<=";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION ">="(LEFT, RIGHT: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN (LEFT >= RIGHT) = U_VAL ( 1);
      END ">=";
--|#################################################################################################
--|
FUNCTION U_EQUAL ( LEFT, RIGHT :TREE ) RETURN BOOLEAN IS
BEGIN
  RETURN U_EQUAL ( LEFT, RIGHT ) = U_VAL ( 1 );
END U_EQUAL;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       FUNCTION U_MEMBER(VALUE, DISCRETE_RANGE: TREE) RETURN BOOLEAN IS
      BEGIN
         RETURN U_MEMBER(VALUE, DISCRETE_RANGE) = U_VAL ( 1);
      END U_MEMBER;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "AND"
       FUNCTION "AND" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.PG > 0 AND RIGHT.PG > 0 THEN
            RETURN U_VAL ( 1 );
         ELSE
            RETURN U_VAL ( 0 );
         END IF;
      END "AND";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "OR"
       FUNCTION "OR" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.PG > 0 OR RIGHT.PG > 0 THEN
            RETURN U_VAL ( 1 );
         ELSE
            RETURN U_VAL ( 0 );
         END IF;
      END "OR";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "XOR"
       FUNCTION "XOR" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.PG /= RIGHT.PG THEN
            RETURN U_VAL ( 1 );
         ELSE
            RETURN U_VAL ( 0 );
         END IF;
      END "XOR";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "NOT"
       FUNCTION "NOT" ( RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
         ELSE
            RETURN U_VAL ( 1 - INTEGER( RIGHT.PG ) );
         END IF;
      END "NOT";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "-"
       FUNCTION "-" ( RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF RIGHT.TY = DN_NUM_VAL THEN
            DECLARE
               R_SPREAD	: VECTOR;
            BEGIN
               SPREAD ( RIGHT, R_SPREAD );
               R_SPREAD.S := - R_SPREAD.S;
               RETURN U_INT ( R_SPREAD );
            END;
         ELSE -- MUST BE REAL_VAL
            RETURN U_REAL ( - D ( XD_NUMER, RIGHT ), D ( XD_DENOM, RIGHT ) );
         END IF;
      END "-";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "ABS"
       FUNCTION "ABS" ( RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF RIGHT.TY = DN_NUM_VAL THEN
            DECLARE
               R_SPREAD	: VECTOR;
            BEGIN
               SPREAD ( RIGHT, R_SPREAD );
               IF R_SPREAD.S > 0 THEN
                  RETURN RIGHT;
               ELSE
                  R_SPREAD.S := +1;
                  RETURN U_INT ( R_SPREAD );
               END IF;
            END;
         ELSE					--| DOIT ÊTRE UN RÉEL
            RETURN U_REAL ( ABS D ( XD_NUMER, RIGHT ), D ( XD_DENOM, RIGHT ) );
         END IF;
      END "ABS";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "+"
       FUNCTION "+" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
               
               IF L_SPREAD.S = R_SPREAD.S THEN
                  V_ADD ( L_SPREAD, R_SPREAD );
                  RETURN U_INT ( R_SPREAD );
                  
               ELSIF V_EQUAL ( L_SPREAD, R_SPREAD ) THEN
                  RETURN U_VAL ( 0 );
                  
               ELSIF V_LESS ( L_SPREAD, R_SPREAD ) THEN
                  V_SUB ( L_SPREAD, R_SPREAD );
                  RETURN U_INT ( R_SPREAD );
                  
               ELSE
                  V_SUB ( R_SPREAD, L_SPREAD );
                  RETURN U_INT ( L_SPREAD);
               END IF;
            END;
         ELSE					--| RÉEL
            RETURN U_REAL(
               D ( XD_NUMER, LEFT ) * D ( XD_DENOM, RIGHT ) + D ( XD_NUMER, RIGHT ) * D ( XD_DENOM, LEFT ),
               D ( XD_DENOM, LEFT ) * D ( XD_DENOM, RIGHT )
               );
         END IF;
      END "+";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "-"
       FUNCTION "-" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
               R_SPREAD.S := - R_SPREAD.S;
                                -- REST OF CODE SAME AS +
               IF L_SPREAD.S = R_SPREAD.S THEN
                  V_ADD ( L_SPREAD, R_SPREAD );
                  RETURN U_INT ( R_SPREAD );
                  
               ELSIF V_EQUAL ( L_SPREAD, R_SPREAD ) THEN
                  RETURN U_VAL ( 0 );
                  
               ELSIF V_LESS ( L_SPREAD, R_SPREAD ) THEN
                  V_SUB ( L_SPREAD, R_SPREAD );
                  RETURN U_INT ( R_SPREAD );
               ELSE
                  V_SUB ( R_SPREAD, L_SPREAD );
                  RETURN U_INT ( L_SPREAD );
               END IF;
            END;
         ELSE -- MUST BE REAL_VAL
            RETURN U_REAL(
               D ( XD_NUMER, LEFT ) * D ( XD_DENOM, RIGHT ) - D ( XD_NUMER, RIGHT ) * D ( XD_DENOM, LEFT ),
               D ( XD_DENOM, LEFT ) * D ( XD_DENOM, RIGHT )
               );
         END IF;
      END "-";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "*"
       FUNCTION "*" ( LEFT, RIGHT :TREE ) RETURN TREE IS
                -- I*I, I*R, R*I, R*R
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL AND RIGHT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
               TEMP		: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
               V_MUL ( L_SPREAD, R_SPREAD, TEMP );
               TEMP.S := L_SPREAD.S * R_SPREAD.S;
               RETURN U_INT ( TEMP );
            END;
         ELSIF RIGHT.TY = DN_NUM_VAL THEN
            RETURN U_REAL ( D ( XD_NUMER, LEFT ) * RIGHT, D ( XD_DENOM, LEFT ) );
         ELSIF LEFT.TY = DN_NUM_VAL THEN
            RETURN RIGHT * LEFT;
         ELSE					--| RÉEL
            RETURN U_REAL ( D ( XD_NUMER, LEFT ) * D ( XD_NUMER, RIGHT ), D ( XD_DENOM, LEFT ) * D ( XD_DENOM, RIGHT ) );
         END IF;
      END "*";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "/"
       FUNCTION "/" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL AND RIGHT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
               TEMP		: VECTOR;
            BEGIN
               SPREAD ( RIGHT, R_SPREAD );
               IF IS_ZERO ( R_SPREAD ) THEN
                  RETURN TREE_VOID;
               END IF;
               SPREAD ( LEFT, L_SPREAD );
               V_DIV ( R_SPREAD, L_SPREAD, TEMP );
               TEMP.S := L_SPREAD.S * R_SPREAD.S;
               RETURN U_INT ( TEMP );
            END;
         ELSIF RIGHT.TY = DN_NUM_VAL THEN
            IF RIGHT = U_VAL ( 0) THEN
               RETURN TREE_VOID;
            END IF;
            RETURN U_REAL ( D ( XD_NUMER, LEFT ), D ( XD_DENOM, LEFT ) * RIGHT );
         ELSE					--| RÉEL
            IF D ( XD_NUMER, RIGHT ) = U_VAL ( 0 ) THEN
               RETURN TREE_VOID;
            END IF;
            RETURN U_REAL ( D ( XD_NUMER, LEFT ) * D ( XD_DENOM, RIGHT ), D ( XD_DENOM, LEFT ) * D ( XD_NUMER, RIGHT ) );
         END IF;
      END "/";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "MOD"
       FUNCTION "MOD" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSE
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
               TEMP		: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
            
               IF IS_ZERO ( R_SPREAD ) THEN
                  RETURN TREE_VOID; -- ZERO DIVIDE
               END IF;
            
               V_DIV ( R_SPREAD, L_SPREAD, TEMP );
               IF L_SPREAD.S /= R_SPREAD.S AND THEN NOT IS_ZERO ( L_SPREAD ) THEN
                  V_SUB ( L_SPREAD, R_SPREAD );
                  L_SPREAD.D( 1..R_SPREAD.L ) := R_SPREAD.D( 1..R_SPREAD.L );
               END IF;
               L_SPREAD.S := R_SPREAD.S;
               RETURN U_INT ( L_SPREAD );
            END;
         END IF;
      END "MOD";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "REM"
       FUNCTION "REM" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSE
            DECLARE
               L_SPREAD, R_SPREAD	: VECTOR;
               TEMP		: VECTOR;
            BEGIN
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( RIGHT, R_SPREAD );
            
               IF IS_ZERO ( R_SPREAD ) THEN
                  RETURN TREE_VOID;				--| DIVISION PAR ZÉRO
               END IF;
            
               V_DIV ( R_SPREAD, L_SPREAD, TEMP );			--| LE SIGNE EST CELUI DU L_SPREAD D'ORIGINE
               RETURN U_INT ( L_SPREAD );
            END;
         END IF;
      END "REM";
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	FUNCTION "**"
       FUNCTION "**" ( LEFT, RIGHT :TREE ) RETURN TREE IS
      BEGIN
         IF LEFT = TREE_VOID OR RIGHT = TREE_VOID THEN
            RETURN TREE_VOID;
            
         ELSIF RIGHT.PT = HI THEN							--| CONSTRAINT ERROR SUR LE SECOND ARGUMENT, ENTIER CODÉ SUR 16 BITS !!!!
            RETURN TREE_VOID;
            
         ELSIF LEFT.TY = DN_NUM_VAL THEN
            DECLARE
               L_SPREAD	: VECTOR;
               TEMP		: VECTOR;
               RESULT	: VECTOR;
               COUNT	: INTEGER	:= U_POS(RIGHT);
            BEGIN
               IF COUNT < 0 THEN
                  RETURN TREE_VOID;				--| CONSTRAINT ERROR FOR - EXP
               END IF;
               SPREAD ( LEFT, L_SPREAD );
               SPREAD ( 1, RESULT );
               WHILE COUNT > 0 LOOP
                  V_MUL ( L_SPREAD, RESULT, TEMP );
                  RESULT := TEMP;
                  RESULT.S := RESULT.S * L_SPREAD.S;
                  COUNT := COUNT - 1;
               END LOOP;
               RETURN U_INT ( RESULT );
            END;
            
         ELSE
            IF U_POS( RIGHT ) >= 0 THEN
               RETURN U_REAL( D( XD_NUMER, LEFT ) ** RIGHT, D( XD_DENOM, LEFT ) ** RIGHT );
            ELSE
               RETURN U_REAL( D( XD_DENOM, LEFT) ** (- RIGHT), D( XD_NUMER, LEFT ) ** (- RIGHT) );
            END IF;
         END IF;
      END "**";
   
    --|----------------------------------------------------------------------------------------------
   END UARITH;
