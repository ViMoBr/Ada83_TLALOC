WITH SEQUENTIAL_IO;
WITH TEXT_IO;
SEPARATE (IDL)
--|-------------------------------------------------------------------------------------------------
--|		IDL_TBL
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY IDL_TBL IS
    
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE INIT_SPEC
--|
PROCEDURE INIT_SPEC ( SPEC_FILE : STRING ) IS
       
  PACKAGE INT_IO IS NEW INTEGER_IO ( INTEGER );
  USE INT_IO;
  USE TEXT_IO;
         
  SFILE			: FILE_TYPE;
  T_CHR			: CHARACTER;
  T_INT			: INTEGER;
  T_TXT			: STRING(1..50);
  T_LAST			: NATURAL;
  AS_SEEN			: BOOLEAN;
  AS_LIST_SEEN		: BOOLEAN;
  NON_AS_SEEN		: BOOLEAN;
BEGIN
  OPEN ( SFILE, IN_FILE, SPEC_FILE & ".TBL" );
  LAST_NODE := -1;
  LAST_ATTR := -1;
  LAST_NODE_ATTR := 0;
  WHILE NOT END_OF_FILE ( SFILE ) LOOP
    GET ( SFILE, T_CHR );								--| PRENDRE LE CARACTERE INDIQUANT LE TYPE DE LIGNE
    IF T_CHR /= 'C' AND T_CHR /= 'E' THEN						--| PAS CLASSE (C OU E) DONC 'N' OU 'A'
      GET ( SFILE, T_INT );								--| N° DE NOEUD OU D'ATTRIBUT (NEGATIF)
    END IF;
    GET_LINE ( SFILE, T_TXT, T_LAST );							--| PRENDRE LE RESTANT DE LA LIGNE
        
    SUPPRESS_BLANKS:
    DECLARE
      D		: INTEGER := 0;
    BEGIN
      FOR S IN 1 .. T_LAST LOOP
        IF T_TXT( S ) /= ' ' AND T_TXT( S ) /= ASCII.HT THEN				--| CARACTERE NON ' ' OU TAB
          D := D + 1;								--| AVANCER LE POINTEUR DE DESTINATION
          T_TXT( D ) := T_TXT( S );							--| RECOPIER LE CARACTERE
        END IF;
      END LOOP;
      T_LAST := D;									--| LONGUEUR REDUITE DES ESPACES
    END SUPPRESS_BLANKS;
            
            			--| NOEUDS
    IF T_CHR = 'N' THEN								--| UNE LIGNE DECLARANT UN NOEUD
      LAST_NODE := LAST_NODE + 1;							--| UN NOEUD DE PLUS
      IF LAST_NODE /= T_INT THEN							--| LE NUMERO D'ORDRE DOIT CORRESPONDRE AU NUMERO D'IDENTIFICATION
        PUT_LINE ( "IDL.IDL_TBL.INIT_SPEC: LAST NODE /= T_INT" );
        RAISE PROGRAM_ERROR;
      END IF;
               
      N_SPEC( NODE_NAME'VAL( LAST_NODE ) ) := (		NS_SIZE		=> 0,		--| PAS D'ATTRIBUT, DONC TAILLE NULLE
                     			NS_FIRST_A		=> 0,		--| PAS D'ATTRIBUT ENCORE VU, NUMERO DU PREMIER À 0
                     			NS_ARITY		=> NULLARY
                     		);
      AS_LIST_SEEN := FALSE;								--| PAS VU D' "as_" LIST
      AS_SEEN := FALSE;								--| PAS VU D' "as_"
      NON_AS_SEEN := FALSE;								--| PAS VU DE NON "as_" (UN "xd_" OU "sm_" ...)
               
               			--| ATTRIBUTS

    ELSIF T_CHR = 'A' OR T_CHR = 'B' OR T_CHR = 'I' THEN
      LAST_NODE_ATTR := LAST_NODE_ATTR + 1;						--| UN ATTRIBUT DE PLUS
      DECLARE
        NN	: NODE_NAME	:= NODE_NAME'VAL ( LAST_NODE );
      BEGIN
        IF N_SPEC( NN ).NS_FIRST_A = 0 THEN						--| SI L'ON A PAS VU LE PREMIER ATTRIBUT
          N_SPEC( NN ).NS_FIRST_A := LAST_NODE_ATTR;					--| METTRE L'INDICE DE CET ATTRIBUT COMME PREMIER
        END IF;
        N_SPEC( NN ).NS_SIZE := N_SPEC(  NN ).NS_SIZE + 1;					--| INCREMENTER LA TAILLE DU NOEUD AUQUEL ON AJOUTE L'ATTRIBUT
               
        IF T_LAST >= 3 AND THEN T_TXT(1 .. 3) = "as_" THEN					--| ATTRIBUT COMMENÇANT PAR "as_"
          IF T_INT < 0 THEN								--| IDENTIFICATEUR NEGATIF (REPERE UNE LISTE, UN SEQ_TYPE)
            IF AS_SEEN OR NON_AS_SEEN THEN						--| ON A DEJÀ VU UN AS_ OU UN NON AS_, INTERDIT : UNE "AS_" LIST DOIT ARRIVER EN TÊTE
              PUT_LINE ( "BAD AS_LIST: " &  T_TXT(1 .. T_LAST) );
            END IF;
            AS_SEEN := TRUE;								--| VU UN "AS_"
            AS_LIST_SEEN := TRUE;							--| VU UNE "AS_" LIST
            N_SPEC( NN ).NS_ARITY := ARITIES'VAL ( ARITIES'POS ( N_SPEC( NN ).NS_ARITY)+ 4 );
                     
          ELSE									--| IDENTIFICATEUR POSITIF (UN  AS_" QUI N'EST PAS UN SEQ_TYPE)
            IF AS_LIST_SEEN OR NON_AS_SEEN THEN						--| ON NE DOIT PAS AVOIR DE "AS_" LIST AVANT UN "AS_" NON LISTE ET PAS DE NON "AS_" NON PLUS
              PUT_LINE ( "BAD AS_...: " & T_TXT(1 .. T_LAST) );
            END IF;
            AS_SEEN := TRUE;								--| VU UN "AS_"
            N_SPEC( NN ).NS_ARITY := ARITIES'VAL ( ARITIES'POS ( N_SPEC( NN ).NS_ARITY)+ 1 );
          END IF;
                  
        ELSE									--| PAS UN "AS_"
          NON_AS_SEEN := TRUE;							--| NON "AS_" VU
        END IF;
      END;
               
      A_SPEC( LAST_NODE_ATTR ).IS_LIST :=  T_INT < 0;					--| INDICATEUR DE LISTE (UNE SEULE PAR NOEUD)
      T_INT := ABS T_INT;								--| IDENTIFICATEUR EN POSITIF
      A_SPEC( LAST_NODE_ATTR ).ATTR := ATTRIBUTE_NAME'VAL( T_INT );				--| STOCKER L'IDENTIFICATEUR DE L'ATTRIBUT
      IF T_INT > LAST_ATTR THEN							--| DEPASSE LE NOMBRE D'ATTRIBUTS VUS
        LAST_ATTR := T_INT;								--| METTRE À JOUR CE NOMBRE (NOTRE ATTRIBUT INDIQUE QU'IL Y EN A PLUS)
      END IF;
               
    END IF;
           
  END LOOP;
  CLOSE ( SFILE );
END INIT_SPEC;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
  PACKAGE DTT_IO IS NEW SEQUENTIAL_IO ( DIANA_TABLE_TYPE );
  USE DTT_IO;
   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE WRITE_SPEC
--|
PROCEDURE WRITE_SPEC ( SPEC_FILE :STRING ) IS
  SFILE		: DTT_IO.FILE_TYPE;
BEGIN
  DTT_IO.CREATE ( SFILE, OUT_FILE, SPEC_FILE & ".BIN" );
  DTT_IO.WRITE ( SFILE, DIANA_TABLE_AREA );
  DTT_IO.CLOSE ( SFILE );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE READ_SPEC
--|
PROCEDURE READ_SPEC ( SPEC_FILE :STRING ) IS
  SFILE		: DTT_IO.FILE_TYPE;
BEGIN
  DTT_IO.OPEN ( SFILE, IN_FILE, SPEC_FILE & ".BIN" );
  DTT_IO.READ ( SFILE, DIANA_TABLE_AREA );
  DTT_IO.CLOSE ( SFILE );
END;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      
--|-------------------------------------------------------------------------------------------------
END IDL_TBL;