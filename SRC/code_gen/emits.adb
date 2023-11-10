WITH DIANA_NODE_ATTR_CLASS_NAMES;
USE  DIANA_NODE_ATTR_CLASS_NAMES;
--|-------------------------------------------------------------------------------------------------
--|	EMITS
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY EMITS IS
   
  USE OP_CODE_IO;
  USE CODE_TYPE_IO;
   
      
  INT_LABEL	: LABEL_TYPE	:= 1;
  FS		: FILE_TYPE;
  CDX		: CONSTANT ARRAY(OP_CODE) OF OFFSET_TYPE := (				--| TABLE DES TAILLES DE CHAQUE INSTRUCTION (CODE EXTENSION)
			-4,  0, -2, -4,  0, -4,  4, -4,  0,
			 0,  0,  0,  0,  0,  0, -4,  4,  0,
			 0,  0, -4,  0,  0,  0,  0,  0,  0,
			 0, -4,  0, -4, -4,  0, -4,  0,  0,
			-4,  4,  4,  4,  4,  4, -4, -4,  4,
			 0, -4, -8,  0, -4,-12,  0, -4,  0,
			-4,  0,  0,  0,  0,  0,  0, -4,  0,
			 0,  0, -4, -8, -4, -4,  0, -4,  0,
			 0, -4
			);
  PDX		: CONSTANT ARRAY(STD_PROC) OF OFFSET_TYPE := (
			0, -4, 0, -8, -8, -4, -12, 0, -4, -16, 0
			);

--|#################################################################################################
--|	PROCEDURE OPEN_OUTPUT_FILE
PROCEDURE OPEN_OUTPUT_FILE ( FILE_NAME :STRING ) IS
BEGIN
  CREATE ( FS, OUT_FILE, FILE_NAME & ".COD" );
  INT_LABEL := 1;
END;
--|#################################################################################################
--|
PROCEDURE CLOSE_OUTPUT_FILE IS
BEGIN
  CLOSE ( FS );
END;
      
  PACKAGE INT_IO	IS NEW INTEGER_IO ( INTEGER ); USE INT_IO;
  PACKAGE LBL_IO	IS NEW INTEGER_IO ( LABEL_TYPE ); USE LBL_IO;
      
--|#################################################################################################
--|
PROCEDURE WRITE_LABEL ( LBL :LABEL_TYPE; COMMENT :STRING := "" ) IS
BEGIN
  PUT ( FS, "$ " );
  PUT ( FS, LBL,1 );				--| LABEL IMPRIMÉ SUR 6 CARACTÈRES
      
  IF COMMENTS_ON AND COMMENT /= "" THEN
     PUT ( FS, ASCII.HT & ASCII.HT & ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
  END IF;
  NEW_LINE ( FS );
END;
--|#################################################################################################
--|
PROCEDURE GEN_LBL_ASSIGNMENT ( LBL :LABEL_TYPE; N :NATURAL ) IS
BEGIN
  PUT ( FS, "$ " );
  PUT ( FS, LBL, 1 );				--| LABEL IMPRIMÉ SUR 6 CARACTÈRES
  PUT ( FS, " = " );				--| AFFECTATION
  INT_IO.PUT ( FS, N, 1 );				--| IMPRIMER LA VALEUR AFFECTÉE SUR 7 CARACTÈRES
  NEW_LINE ( FS );
END;
--|#################################################################################################
--| 
PROCEDURE MEASURE ( OC :OP_CODE ) IS
BEGIN
  TOP_ACT := TOP_ACT + CDX( OC );
  IF TOP_MAX < TOP_ACT THEN
    TOP_MAX := TOP_ACT;
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT_COMMENT ( COMMENT :STRING ) IS			--| ESSENTIELLEMENT POUR INDIQUER LES PARTIES RESTANT A FAIRE
BEGIN
  PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
END EMIT_COMMENT;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN BAND | EEX | BNOT | BOR | RAI | BXOR =>
      PUT ( FS, ASCII.HT );
      PUT ( FS, OC, 0, LOWER_CASE );
    WHEN QUIT =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; CT :CODE_TYPE; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN ADD | DIV | DPL | EXP | EQ | GE | GT | LE |
      LT | MODU | MUL | NEQ | REMN | STO | SUB | SWP =>
      PUT ( FS, OC, 0, LOWER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, '.' );
    PUT ( FS, CT, 0, LOWER_CASE );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|-------------------------------------------------------------------------------------------------
--| 
PROCEDURE GEN_OC ( OC :OP_CODE; COMMENT :STRING := "" ) IS
BEGIN
  CASE OC IS
  WHEN LDC =>
    MEASURE ( LDC );
    PUT ( FS, ASCII.HT );
    PUT ( FS, OC, 0, LOWER_CASE );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  WHEN OTHERS =>
    RAISE ILLEGAL_OP_CODE;
  END CASE;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; B :BOOLEAN; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    GEN_OC ( OC );
    PUT ( FS, ".B" & ASCII.HT & BOOLEAN'IMAGE ( B ) );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; C :CHARACTER; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    GEN_OC ( OC );
    PUT ( FS, ".C" & ASCII.HT & "'" & CHARACTER'IMAGE ( C ) & "'" );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; LBL :LABEL_TYPE; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN JMPF | LVB | JMPT | JMP =>
      PUT ( FS, ASCII.HT );
      PUT ( FS, OC, 0, LOWER_CASE );
      PUT ( FS, ASCII.HT & "$ " );
    WHEN EXH | RFL =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
      PUT ( FS, ASCII.HT & "$ " );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, LBL, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      IF OC = EXH OR OC = RFL THEN
        PUT ( FS, ASCII.HT );
      END IF;
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; I :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN RAI =>
      PUT ( FS, OC, 0, LOWER_CASE );
      PUT ( FS, ASCII.HT & "# " );
    WHEN ALO | GET | IXA | MST | PUT | RET =>
      PUT ( FS, OC, 0, LOWER_CASE );
      PUT ( FS, ASCII.HT );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, I, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; CT :CODE_TYPE; I :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN DEC | INC | IND | LDC=>
      PUT ( FS, OC, 0, LOWER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, '.' );
    PUT ( FS, CT, 0, LOWER_CASE );
    PUT ( FS, ASCII.HT );
    PUT ( FS, I, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; S :STRING; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN PKG | PKB | PRO =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, ASCII.HT  & S );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; NUM, LBL :LABEL_TYPE; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN EXC =>
      PUT ( FS, OC, 0, LOWER_CASE );
      PUT ( FS, ASCII.HT & "# " );
      PUT ( FS, NUM, 1 ); 
      PUT ( FS, ASCII.HT & "$ " );
      PUT ( FS, LBL, 1 );
                  
      IF COMMENTS_ON AND COMMENT /= "" THEN
        PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
      END IF;
      NEW_LINE ( FS );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; LBL :LABEL_TYPE; S :STRING; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN EXL =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
      PUT ( FS, ASCII.HT & "# " );
      PUT ( FS, LBL, 1 ); 
      PUT ( FS, ASCII.HT & S );
                  
      IF COMMENTS_ON AND COMMENT /= "" THEN
        PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
      END IF;
      NEW_LINE ( FS );
                  
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; I :INTEGER; LBL :LABEL_TYPE; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN CALL =>
      PUT ( FS, ASCII.HT );
      PUT ( FS, OC, 0, LOWER_CASE );
      PUT ( FS, I, 7 );
    WHEN ENT =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
      PUT ( FS, I, 3 );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
            
    PUT ( FS, ASCII.HT & "$ " );
    PUT ( FS, LBL, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; IA, IB :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN LDA | LAO | MST =>
      PUT ( FS, OC, 0, LOWER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, ASCII.HT );
    PUT ( FS, IA, 1 ); 
    PUT ( FS, ASCII.HT );
    PUT ( FS, IB, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; CT :CODE_TYPE; IA, IB :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    PUT ( FS, ASCII.HT );
    CASE OC IS
    WHEN LDO | LOD | SRO | STR =>
      PUT ( FS, OC, 0, LOWER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, '.' );
    PUT ( FS, CT, 0, LOWER_CASE );
    PUT ( FS, ASCII.HT );
    PUT ( FS, IA, 1 ); 
    PUT ( FS, ASCII.HT );
    PUT ( FS, IB, 1 );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( OC :OP_CODE; I :INTEGER; S :STRING; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    MEASURE ( OC );
    CASE OC IS
    WHEN RFP =>
      PUT ( FS, "  " );
      PUT ( FS, OC, 0, UPPER_CASE );
    WHEN OTHERS =>
      RAISE ILLEGAL_OP_CODE;
    END CASE;
    PUT ( FS, I, 9 ); 
    PUT ( FS, ASCII.HT & S ); 
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
PROCEDURE EMIT ( P :STD_PROC; COMMENT :STRING := "" ) IS
BEGIN
  IF GENERATE_CODE THEN
    TOP_ACT := TOP_ACT + PDX( P );
    IF TOP_MAX < TOP_ACT THEN
      TOP_MAX := TOP_ACT;
    END IF;
    PUT ( FS, ASCII.HT );
    PUT ( FS, TRAP, 0, LOWER_CASE );
    PUT ( FS, ASCII.HT & STD_PROC'IMAGE ( P ) );
            
    IF COMMENTS_ON AND COMMENT /= "" THEN
      PUT ( FS, ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    END IF;
    NEW_LINE ( FS );
  END IF;
END;
--|#################################################################################################
--|
--|	PROCEDURE GEN_LOAD_ADDR
--|
PROCEDURE GEN_LOAD_ADDR ( COMP_UNIT_NUMBER :COMP_UNIT_NBR; LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF LVL = 0 THEN					--| NIVEAU 0 (UNITES DE PREMIER NIVEAU)
    EMIT ( LAO, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );		--| LAOD GLOBAL POUR L UNITE AVEC LE DECALAGE REQUIS
  ELSE					--| NIVEAUX DE PROFONDEUR NON NULLE
    EMIT ( LDA, INTEGER(LEVEL - LVL), OFFSET, COMMENT );			--| CHARGEMENT AU NIVEAU REQUIS AVEC SUIVI DES LIENS STATIQUES ET DECALAGE
  END IF;
END;
--|#################################################################################################
--|
--|	PROCEDURE GEN_LOAD
--|
PROCEDURE GEN_LOAD ( CT :CODE_TYPE; COMP_UNIT_NUMBER :COMP_UNIT_NBR; LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF LVL = 0 THEN
    EMIT ( LDO, CT, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );
  ELSE
    EMIT ( LOD, CT, INTEGER(LEVEL - LVL), OFFSET, COMMENT );
  END IF;
END;
--|#################################################################################################
--|
--|	PROCEDURE GEN_STORE
--|
PROCEDURE GEN_STORE ( CT :CODE_TYPE; COMP_UNIT_NUMBER :COMP_UNIT_NBR; LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" ) IS
BEGIN
  IF LVL = 0 THEN					--| POUR LE NIVEAU 0
    EMIT ( SRO, CT, INTEGER ( COMP_UNIT_NUMBER ), OFFSET, COMMENT );		--| STOCKAGE GLOBAL POUR UNE UNITE DE PREMIER NIVEAU AU DECALAGE REQUIS
  ELSE					--| PPOUR LES AUTRES NIVEAUX
    EMIT ( STR, CT, INTEGER ( LEVEL - LVL ), OFFSET, COMMENT );		--| STOCKAGE AU NIVEAU REQUIS AVEC SUIVI DES LIENS STATIQUES ET DECALAGE
  END IF;
END; 
--|#################################################################################################
--|
--|	FUNCTION NEXT_LABEL
--|
FUNCTION NEXT_LABEL RETURN LABEL_TYPE IS
BEGIN
  INT_LABEL := INT_LABEL + 1;
  RETURN INT_LABEL;
END;
--|#################################################################################################
--|
PROCEDURE INC_LEVEL IS
BEGIN
  LEVEL := LEVEL + 1;
EXCEPTION
  WHEN CONSTRAINT_ERROR => RAISE STATIC_LEVEL_OVERFLOW;
END;
--|#################################################################################################
--|
PROCEDURE DEC_LEVEL IS
BEGIN
  LEVEL := LEVEL - 1;
EXCEPTION
  WHEN CONSTRAINT_ERROR => RAISE STATIC_LEVEL_UNDERFLOW;
END;
--|#################################################################################################
--|
PROCEDURE INC_OFFSET ( I :INTEGER ) IS
BEGIN
  OFFSET_ACT := OFFSET_ACT + OFFSET_TYPE ( I );			--| AUGMENTER LE DECALAGE
  IF OFFSET_MAX < OFFSET_ACT THEN				--| SI LE DECALAGE MAX EST AU DESSOUS DU DECALAGE ACTUEL
    OFFSET_MAX := OFFSET_ACT;				--| METTRE A JOUR LE DECALAGE MAX
  END IF;
EXCEPTION
  WHEN CONSTRAINT_ERROR => RAISE STATIC_OFFSET_OVERFLOW;
END;
--|#################################################################################################
--|
--|	PROCEDURE ALIGN
--|
PROCEDURE ALIGN ( AL :INTEGER ) IS
  TMP	: OFFSET_TYPE	:= OFFSET_ACT + AL - 1;
BEGIN
  OFFSET_ACT := TMP - TMP MOD AL;
END;
--|#################################################################################################
--|
--|	PROCEDURE PERFORM_RETURN	
--|
PROCEDURE PERFORM_RETURN ( ENCLOSING_BLOCK_BODY :TREE ) IS
  LVBLBL	: LABEL_TYPE;
  ENCLOSING_LEVEL	: INTEGER	:= DI ( CD_LEVEL, ENCLOSING_BLOCK_BODY );	--| NIVEAU IMBRICATION STATIQUE DU BLOC ENGLOBANT
BEGIN
  IF ENCLOSING_LEVEL /= EMITS.LEVEL THEN			--| SI LE NIVEAU D IMBRICATION 
    LVBLBL := NEXT_LABEL;
    EMIT ( LVB, LVBLBL);				--| EMETTRE UN LEAVE BLOCK AVEC ETIQUETTE VERS LA DIFFERENCE DE NIVEAU
    GEN_LBL_ASSIGNMENT ( LVBLBL, EMITS.LEVEL - ENCLOSING_LEVEL );		--| DONNER LA VALEUR DIFFERENCE DE NIVEAU A CETTE ETIQUETTE
  END IF;
  EMIT ( JMP, LABEL_TYPE( DI ( CD_RETURN_LABEL, ENCLOSING_BLOCK_BODY ) ) );		--| SAUT INCONDITIONNEL À L'ÉTIQUETTE DE SORTIE DU BLOC ENGLOBANT
END PERFORM_RETURN;
--|#################################################################################################
--|
--|	FUNCTION TYPE_SIZE
--|
FUNCTION TYPE_SIZE ( TYPE_SPEC :TREE ) RETURN NATURAL IS
BEGIN
  CASE TYPE_SPEC.TY IS
  WHEN DN_ACCESS =>
    RETURN ADDR_SIZE;
  WHEN DN_CONSTRAINED_ARRAY =>
    RETURN 2* ADDR_SIZE;
  WHEN DN_ENUMERATION | DN_INTEGER =>
    RETURN INTG_SIZE;
  WHEN OTHERS =>
    PUT_LINE ( "!!! TYPE_SIZE : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
    RAISE PROGRAM_ERROR;
  END CASE;
END;
--|#################################################################################################
--|
--|	FUNCTION CODE_TYPE_OF
--|
FUNCTION CODE_TYPE_OF ( EXP_OR_TYPE_SPEC :TREE ) RETURN CODE_TYPE IS
BEGIN
  IF EXP_OR_TYPE_SPEC.TY IN CLASS_EXP THEN
    DECLARE
      EXP	: TREE	RENAMES EXP_OR_TYPE_SPEC;
    BEGIN
      CASE EXP.TY IS
      WHEN DN_FUNCTION_CALL | DN_PARENTHESIZED | DN_USED_OBJECT_ID =>
        RETURN CODE_TYPE_OF ( D ( SM_EXP_TYPE, EXP ) );
                     
      WHEN OTHERS =>
        PUT_LINE ( "!!! CODE_TYPE_OF : EXP.TY ILLICITE " & NODE_NAME'IMAGE ( EXP.TY ) );
        RAISE PROGRAM_ERROR;
      END CASE;
    END;
            
  ELSIF EXP_OR_TYPE_SPEC.TY IN CLASS_TYPE_SPEC THEN
    DECLARE
      TYPE_SPEC	: TREE	RENAMES EXP_OR_TYPE_SPEC;
    BEGIN
      CASE TYPE_SPEC.TY IS
      WHEN DN_ACCESS =>
        RETURN A;
                  
      WHEN DN_ENUMERATION =>
        DECLARE
          TYPE_SOURCE_NAME	: TREE	:= D ( XD_SOURCE_NAME, TYPE_SPEC );
          TYPE_SYMREP	: TREE	:= D ( LX_SYMREP, TYPE_SOURCE_NAME );
          NAME	: CONSTANT STRING	:= PRINT_NAME ( TYPE_SYMREP );
        BEGIN
          IF NAME = "BOOLEAN" THEN
            RETURN B;
          ELSIF NAME = "CHARACTER" THEN
            RETURN C;
          ELSE
            RETURN I;
          END IF;
        END;
                  
      WHEN DN_INTEGER | DN_NUMERIC_LITERAL =>
        RETURN I;
                  
      WHEN OTHERS =>
        PUT_LINE ( "!!! CODE_TYPE_OF : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
        RAISE PROGRAM_ERROR;
      END CASE;
    END;
            
  ELSE
    PUT_LINE ( "!!! CODE_TYPE_OF : EXP_OR_TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( EXP_OR_TYPE_SPEC.TY ) );
    RAISE PROGRAM_ERROR;
  END IF;
END CODE_TYPE_OF;
   
--|#################################################################################################
--|
--|	FUNCTION NUMBER_OF_DIMENSIONS
--|
FUNCTION NUMBER_OF_DIMENSIONS ( EXP :TREE ) RETURN NATURAL IS
BEGIN
  IF EXP.TY IN CLASS_CONSTRAINED THEN
    RETURN NUMBER_OF_DIMENSIONS ( D ( SM_BASE_TYPE, EXP ) );
            
  ELSIF EXP.TY = DN_FUNCTION_CALL OR EXP.TY = DN_USED_OBJECT_ID THEN
    RETURN NUMBER_OF_DIMENSIONS ( D ( SM_EXP_TYPE, EXP ) );
            
  ELSIF EXP.TY = DN_ARRAY THEN
    RETURN DI ( CD_DIMENSIONS, EXP );
            
  ELSE
    PUT_LINE ( "!!! NUMBER_OF_DIMENSIONS : TYPE EXPRESSION ILLICITE" & NODE_NAME'IMAGE ( EXP.TY ) );
    RAISE PROGRAM_ERROR;
  END IF;
END NUMBER_OF_DIMENSIONS;
--|#################################################################################################
--|
--|	PROCEDURE GET_CLO
--|
PROCEDURE GET_CLO ( OBJECT :TREE; COMP_UNIT :OUT COMP_UNIT_NBR; LVL :OUT LEVEL_TYPE; OFS :OUT OFFSET_TYPE ) IS
BEGIN
  CASE OBJECT.TY IS
  WHEN DN_IN =>
    COMP_UNIT := 0;
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  WHEN DN_IN_OUT_ID | DN_OUT_ID =>
    COMP_UNIT := 0;
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_VAL_OFFSET, OBJECT );
         
  WHEN DN_INTEGER =>
    COMP_UNIT := DI ( CD_COMP_UNIT, OBJECT );
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  WHEN DN_VARIABLE_ID =>
    COMP_UNIT := DI ( CD_COMP_UNIT, OBJECT );
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  WHEN OTHERS =>
    PUT_LINE ( "!!! GET_CLO : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( OBJECT.TY ) );
    RAISE PROGRAM_ERROR;
  END CASE;
END GET_CLO;
--|#################################################################################################
--|
--|	FUNCTION CONSTRAINED
--|
FUNCTION CONSTRAINED ( TYPE_SPEC :TREE ) RETURN BOOLEAN IS
BEGIN
  RETURN NOT ( TYPE_SPEC.TY IN CLASS_UNCONSTRAINED );
END;
--|#################################################################################################
--|
--|	PROCEDURE LOAD_TYPE_SIZE
--|
PROCEDURE LOAD_TYPE_SIZE ( TYPE_SPEC :TREE ) IS
BEGIN
  IF CONSTRAINED ( TYPE_SPEC ) THEN
    EMIT ( LDC, I, TYPE_SIZE ( TYPE_SPEC ), "LOAD TYPE SIZE" );
  ELSE
    PUT_LINE ( "!!! LOAD_TYPE_SIZE : TYPE_SPEC NON CONTRAINT" );
    RAISE PROGRAM_ERROR;
  END IF;
END LOAD_TYPE_SIZE;
--|-------------------------------------------------------------------------------------------------
END EMITS;