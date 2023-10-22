SEPARATE (IDL)
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE NAM_PUT
PROCEDURE NAM_PUT ( NOM_TEXTE :STRING ) IS			--| ECRIT DES PARTIES ADA POUR UN NOUVEL ENVIRONNEMENT IDL
   
  RESULT_FILE: TEXT_IO.FILE_TYPE;
   
  ASSERTION_ERROR: EXCEPTION;
   
  --|-----------------------------------------------------------------------------------------------
  --|	PACKAGE TBL
  --|-----------------------------------------------------------------------------------------------
  PACKAGE TBL IS
      
    TYPE AC_STRING	IS ACCESS STRING;
      
    TYPE NODE_IDX	IS RANGE 0 .. 255;			--| INDICE DES NOEUDS
    TYPE ATTR_IDX	IS RANGE 0 .. 255;			--| INDICE DES ATTRIBUTS
    TYPE CLASS_IDX	IS RANGE 0 .. 150;			--| INDICE DES CLASSES
    TYPE FIELD_IDX	IS RANGE 0 .. 1500;			--| INDICE DES CHAMPS (CITATION D'UN ATTRIBUT DANS UN NOEUD)
      
    LAST_NODE		: NODE_IDX	:= 0;
    LAST_ATTR		: ATTR_IDX	:= 0;
    LAST_CLASS		: CLASS_IDX	:= 0;
      
    NODE_IMAGE		: ARRAY (NODE_IDX) OF AC_STRING;
    START_FIELD	: ARRAY (NODE_IDX) OF FIELD_IDX;
    END_FIELD		: ARRAY (NODE_IDX) OF FIELD_IDX;
      
    ATTR_IMAGE		: ARRAY (ATTR_IDX) OF AC_STRING;		--| NOMS DES ATTRIBUTS
    ATTR_KIND		: ARRAY (ATTR_IDX) OF CHARACTER;		--| 'A' 'B' 'I' ATTRIBUT TREE, BOOLEAN, INTEGER OR SEQUENCE
      
    CLASS_IMAGE	: ARRAY (CLASS_IDX) OF AC_STRING;		--| NOM DES CLASSES
    START_NODE		: ARRAY (CLASS_IDX) OF NODE_IDX;		--| PREMIER NOEUD DE CLASSE
    END_NODE		: ARRAY (CLASS_IDX) OF NODE_IDX;		--| DERNIER NOEUD DE CLASSE
      
    ATTR_IDX_OF_NODE	: ARRAY (FIELD_IDX) OF ATTR_IDX;
      
      
    FUNCTION  UPPER_CASE	( A :STRING )	RETURN STRING;
    PROCEDURE READ_TABLES	( NOM_TABLE :STRING );
      
    --|---------------------------------------------------------------------------------------------
  END TBL;

  USE TBL;
  PACKAGE BODY TBL IS SEPARATE;
      
      
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PUT_NODES_NAMES
  PROCEDURE PUT_NODES_NAMES IS
    I	: NATURAL	:= 0;
  BEGIN
    PUT_LINE ("  TYPE NODE_NAME" & ASCII.HT & "IS (");
    FOR N IN 0 .. TBL.LAST_NODE LOOP
      IF I > 4 THEN
        NEW_LINE;
        I := 0;
      END IF;
      DECLARE
        STR	: STRING RENAMES TBL.NODE_IMAGE( N ).ALL;
      BEGIN
        PUT ( ASCII.HT & "DN_" & UPPER_CASE ( STR ) & "," );
        IF STR'LENGTH+3 > 18 THEN
          I := I + 1;
        END IF;
      END;
      I := I + 1;
    END LOOP;
         
    NEW_LINE;
    PUT_LINE ( ASCII.HT & "DN_VIRGIN" );
    PUT_LINE ( ASCII.HT & ");" );
    NEW_LINE;
  END;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PUT_ATTRIBUTES_NAMES
  PROCEDURE PUT_ATTRIBUTES_NAMES IS
    I	: NATURAL	:= 0;
  BEGIN
    PUT_LINE ( "  TYPE ATTRIBUTE_NAME" & ASCII.HT & "IS (" );
    FOR A IN 0 .. TBL.LAST_ATTR-1 LOOP
      IF I > 4 THEN
        NEW_LINE;
        I := 0;
      END IF;
      DECLARE
        STR	: STRING RENAMES TBL.ATTR_IMAGE( A ).ALL;
      BEGIN
        PUT ( ASCII.HT & STR(STR'FIRST..STR'FIRST+1) & UPPER_CASE ( STR(STR'FIRST+2..STR'LAST) ) & "," );
        IF STR'LENGTH > 18 THEN
          I := I + 1;
        END IF;
      END;
      I := I + 1;
    END LOOP;

    IF TBL.LAST_ATTR MOD 5 = 0 THEN
      NEW_LINE;
    END IF;
    DECLARE
      STR	: STRING RENAMES TBL.ATTR_IMAGE(  TBL.LAST_ATTR ).ALL;
    BEGIN
      PUT ( ASCII.HT & STR(STR'FIRST..STR'FIRST+1) & UPPER_CASE ( STR(STR'FIRST+2..STR'LAST) ) );
    END;
    NEW_LINE;
    PUT_LINE ( ASCII.HT & ");" );
    NEW_LINE;
  END PUT_ATTRIBUTES_NAMES;
  --|-----------------------------------------------------------------------------------------------
  --|	PROCEDURE PUT_CLASSES
  PROCEDURE PUT_CLASSES IS
  BEGIN
    FOR C IN 0 .. TBL.LAST_CLASS LOOP
      PUT_LINE ( "  SUBTYPE CLASS_" & UPPER_CASE ( CLASS_IMAGE( C ).ALL )
                 & ASCII.HT & "IS NODE_NAME RANGE DN_" & UPPER_CASE ( TBL.NODE_IMAGE( START_NODE( C ) ).ALL )
                 & ASCII.HT & ".. DN_" & UPPER_CASE ( TBL.NODE_IMAGE( END_NODE( C ) ).ALL )
                 & ';'
               );
    END LOOP;
    NEW_LINE;
  END;
   
   
BEGIN
  TBL.READ_TABLES ( NOM_TEXTE );
   
  CREATE ( RESULT_FILE, OUT_FILE, NOM_TEXTE & "__node_attr_class_names.ads" );
  SET_OUTPUT ( RESULT_FILE );
   
  PUT_LINE ( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE ( RESULT_FILE, "--|" & ASCII.HT & "NODE_ATTR_CLASS_NAMES");
  PUT_LINE ( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE ( "PACKAGE NODE_ATTR_CLASS_NAMES IS");
  NEW_LINE ( RESULT_FILE );
  PUT_NODES_NAMES;
  PUT_ATTRIBUTES_NAMES;
  PUT_CLASSES;
  NEW_LINE ( RESULT_FILE );
  PUT_LINE ( RESULT_FILE, "--|-------------------------------------------------------------------------------------------------");
  PUT_LINE ( RESULT_FILE, "END NODE_ATTR_CLASS_NAMES;");
   
  SET_OUTPUT ( STANDARD_OUTPUT );
  CLOSE ( RESULT_FILE );
      
END NAM_PUT;
