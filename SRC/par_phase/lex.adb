WITH TEXT_IO;
USE TEXT_IO;
--|-------------------------------------------------------------------------------------------------
--|	LEX
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY LEX IS
   
  CHAR_CONTEXT		: BOOLEAN	:= TRUE;
  ATTRIBUTE_CONTEXT		: BOOLEAN	:= FALSE;
   
  TYPE TOKEN_TYPE		IS ( NIL, IDENT, PUNCT, QUOTE, INT, DEC, CHAR, ERROR );		--| ULEX TYPE BRUT A LA LECTURE
  TEXT			: STRING(1 .. 255);						--| TAMPON TEXTE DU L'ULEX
  TOKEN_LENGTH		: NATURAL;
   
  HASH_SIZE		: CONSTANT INTEGER	:= 311;
  HASH_TABLE		: ARRAY ( 0 .. HASH_SIZE - 1 ) OF LEX_TYPE := ( OTHERS=> LT_IDENTIFIER );
   
   
--|-------------------------------------------------------------------------------------------------
--|	FUNCTION HASH_POS
--|-------------------------------------------------------------------------------------------------
FUNCTION HASH_POS ( TXT :STRING ) RETURN INTEGER IS					--| FONCTION DE HACHAGE DU NOM DE TERMINAL
  I: INTEGER;
BEGIN
  I := TXT'LENGTH + 157 * CHARACTER'POS( TXT( TXT'LAST ) );
  I := I MOD HASH_SIZE;
  WHILE HASH_TABLE(I) /= LT_IDENTIFIER AND THEN LEX_IMAGE( HASH_TABLE( I ) ) /= TXT LOOP
    I := I + 1;
    IF I = HASH_SIZE THEN
      I := 0;
    END IF;
  END LOOP;
  RETURN I;
END HASH_POS;
--|-------------------------------------------------------------------------------------------------
--|	FUNCTION HASH_SEARCH
FUNCTION HASH_SEARCH ( TXT :STRING ) RETURN LEX_TYPE IS
BEGIN
  RETURN HASH_TABLE( HASH_POS( TXT ) );
END;
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE NEXT_TOKEN
PROCEDURE NEXT_TOKEN ( CHAR_CONTEXT: BOOLEAN; TTYPE_OUT: OUT TOKEN_TYPE; TOK_LEN :OUT NATURAL ) IS
      
  USE ASCII;
      
  CASE_MAGIC		: CONSTANT := CHARACTER'POS ( 'a' ) - CHARACTER'POS ( 'A' );

  W_COL			: NATURAL;
  START_COL		: POSITIVE;
  TOK_TYP			: TOKEN_TYPE;
  CHR			: CHARACTER;
  QUOTE_CHR		: CHARACTER;
  BASE			: INTEGER;
  BASE_DIGIT		: CHARACTER;
  BASE_LETTER		: CHARACTER;
  LINE_LENGTH		: INTEGER;
                -- NUMBER OF SIGNIFICANT CHARS IN TEXT
      
  SL		: LINE_OF_SOURCE RENAMES SLINE;

BEGIN
  LINE_LENGTH := SLINE.LEN;								--| LONGUEUR DE LIGNE
  W_COL := COL + 1;									--| No CARACTERE SUIVANT
      
  WHILE W_COL <= LINE_LENGTH LOOP
    CHR := SL.BDY( W_COL );								--| PRENDRE LE CARACTERE
    EXIT WHEN CHR /= ' ' AND THEN CHR NOT IN ASCII.HT .. ASCII.CR;				--| SORTIR SI PAS BLANC
    W_COL := W_COL + 1;								--| PASSER AU SUIVANT
  END LOOP;
      
  START_COL := W_COL;								--| POSITION PREMIER CARACTERE DU LEXEME
       
  IF W_COL > LINE_LENGTH THEN
    TOKEN_LENGTH := 0;
    TOK_TYP := NIL;
    GOTO ACCEPT_TOKEN;
  END IF;
      
  TEXT( 1 ) := CHR;
  TOKEN_LENGTH := 1;
  TOK_TYP := PUNCT;									--| PAR DEFAUT
  W_COL := W_COL + 1;
  IF W_COL <= LINE_LENGTH THEN
    CHR := SL.BDY( W_COL );
  ELSE
    CHR:=' ';
  END IF;
      
  CASE TEXT (1) IS
  WHEN 'A' .. 'Z' =>
    TOK_TYP := IDENT;
    GOTO SCAN_IDENT;
  WHEN '_' =>									-- AUTORISER LES _ DE TETE POUR LA PROGRAMMATION SYSTEME
    TOK_TYP := IDENT;
    GOTO SCAN_IDENT;
  WHEN 'a' .. 'z' =>
    TEXT (1) := CHARACTER'VAL( CHARACTER'POS( TEXT( 1 ) ) - CASE_MAGIC );
    TOK_TYP := IDENT;
    GOTO SCAN_IDENT;
  WHEN '0' .. '9' =>
    TOK_TYP := INT;
    GOTO SCAN_INT;
  WHEN '"' | '%' =>
    TOK_TYP := QUOTE;
    QUOTE_CHR := TEXT (1);
    TEXT (1) := '"';
    GOTO SCAN_QUOTE;
  WHEN ''' =>
    GOTO SCAN_CHAR;
  WHEN '-' =>
    GOTO SCAN_COMMENT;
  WHEN '=' =>
    GOTO SCAN_EQUAL;
  WHEN '.' =>
    GOTO SCAN_PERIOD;
  WHEN '*' =>
    GOTO SCAN_STAR;
  WHEN ':' | '/' =>
    GOTO SCAN_COLON_SLASH;
  WHEN '>' =>
    GOTO SCAN_GREATER_THAN;
  WHEN '<' =>
    GOTO SCAN_LESS_THAN;
  WHEN '&' | '(' | ')' | '+' | ',' | ';' | '|' =>
    GOTO ACCEPT_TOKEN;
  WHEN '!' =>
    TEXT (1) := '|';
    GOTO ACCEPT_TOKEN;
  WHEN OTHERS =>
    IF TEXT (1) NOT IN ' ' .. CHARACTER'VAL( 127 ) THEN
      TEXT (1) := '?';
    END IF;
    GOTO SCAN_ERROR;
  END CASE;
      
<<SCAN_IDENT>>
  CASE CHR IS
  WHEN '_' =>
    GOTO SCAN_IDENT_UNDERLINE;
  WHEN 'A' .. 'Z' | '0' .. '9' =>
    NULL;
  WHEN 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
  WHEN OTHERS =>
    GOTO ACCEPT_TOKEN;
  END CASE;
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := CHR;
  W_COL := W_COL + 1;
  IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
  ELSE CHR:=' '; END IF;
  GOTO SCAN_IDENT;
      
<<SCAN_IDENT_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := CHR;
  W_COL := W_COL + 1;
  IF W_COL<=LINE_LENGTH THEN CHR := SL.BDY( W_COL );
  ELSE CHR:=' '; END IF;
  IF CHR NOT IN 'A' .. 'Z' AND THEN CHR NOT IN 'a' .. 'z'
  AND THEN CHR NOT IN '0' .. '9' THEN
    TOK_TYP := ERROR;
  END IF;
  GOTO SCAN_IDENT;
      
<<SCAN_INT>>
  CASE CHR IS
  WHEN '0' .. '9' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR := SL.BDY(W_COL);
    ELSE CHR:=' '; END IF;
    GOTO SCAN_INT;
  WHEN '_' =>
    GOTO SCAN_INT_UNDERLINE;
  WHEN '.' =>
    GOTO SCAN_INT_PERIOD;
  WHEN 'E' | 'e' =>
    GOTO SCAN_INT_E;
  WHEN '#' | ':' =>
    QUOTE_CHR := CHR;
    GOTO SCAN_BASED_INT;
  WHEN OTHERS =>
    GOTO ACCEPT_NUMBER;
  END CASE;
      
<<SCAN_INT_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT (TOKEN_LENGTH) := CHR;
  W_COL := W_COL + 1;
  IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
  ELSE CHR:=' '; END IF;
  IF CHR NOT IN '0' .. '9' THEN
    TOK_TYP := ERROR;
  END IF;
  GOTO SCAN_INT;
      
<<SCAN_INT_PERIOD>>
  IF W_COL < LINE_LENGTH AND THEN SL.BDY (W_COL + 1) IN '0' .. '9' THEN
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    CHR := SL.BDY(W_COL);
    IF TOK_TYP = INT THEN
      TOK_TYP := DEC;
    END IF;
                      -- GOTO SCAN_DEC;
  ELSE
    GOTO ACCEPT_NUMBER;
  END IF;
      
<<SCAN_DEC>>
  CASE CHR IS
  WHEN '0' .. '9' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
    ELSE CHR:=' '; END IF;
    GOTO SCAN_DEC;
  WHEN '_' =>
    GOTO SCAN_DEC_UNDERLINE;
  WHEN 'E' | 'e' =>
    GOTO SCAN_DEC_E;
  WHEN OTHERS =>
    GOTO ACCEPT_NUMBER;
  END CASE;
      
<<SCAN_DEC_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT (TOKEN_LENGTH) := CHR;
  W_COL := W_COL + 1;
  IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
  ELSE CHR:=' '; END IF;
  IF CHR NOT IN '0' .. '9' THEN
    TOK_TYP := ERROR;
  END IF;
  GOTO SCAN_DEC;
      
<<SCAN_BASED_INT>>
  BASE := 0;
  FOR I IN 1 .. TOKEN_LENGTH LOOP
    IF TEXT (I) IN '0' .. '9' AND THEN BASE <= 16 THEN
      BASE := BASE * 10 + CHARACTER'POS( TEXT (I) ) - CHARACTER'POS( '0' );
    END IF;
  END LOOP;
  IF BASE NOT IN 2 .. 16 THEN
    TOK_TYP := ERROR;
    BASE := 16;
  END IF;
      
  IF BASE <= 9 THEN
    BASE_DIGIT := CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE - 1 );
  ELSE
    BASE_DIGIT := '9';
  END IF;
  BASE_LETTER := CHARACTER'VAL( CHARACTER'POS( 'A' ) + BASE - 11 );
      
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := '#';
  W_COL := W_COL + 1;
  IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
  ELSE CHR:=' '; END IF;
  IF CHR IN '0' .. '9' OR ELSE CHR IN 'A' .. 'Z' OR ELSE CHR IN 'a'..'z' THEN
    NULL; -- GO TO SCAN_BASED_INT_DIGIT
  ELSE
    GOTO SCAN_ERROR;
  END IF;
      
<<SCAN_BASED_INT_DIGIT>>
  CASE CHR IS
  WHEN '0' .. '9' =>
    IF CHR > BASE_DIGIT THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR := ' '; END IF;
    GOTO SCAN_BASED_INT_DIGIT;
  WHEN 'A' .. 'Z' =>
    IF CHR > BASE_LETTER THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR := ' '; END IF;
    GOTO SCAN_BASED_INT_DIGIT;
  WHEN 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
    GOTO SCAN_BASED_INT_DIGIT;
  WHEN '_' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
    ELSE CHR := ' '; END IF;
    IF CHR NOT IN '0' .. '9' AND THEN CHR NOT IN 'A' .. 'Z'
    AND THEN CHR NOT IN 'a' .. 'z' THEN
      TOK_TYP := ERROR;
    END IF;
    GOTO SCAN_BASED_INT_DIGIT;
  WHEN '#' | ':' =>
    IF CHR /= QUOTE_CHR THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := '#';
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
    ELSE CHR:=' '; END IF;
    IF CHR = 'E' OR ELSE CHR = 'e' THEN
      GOTO SCAN_INT_E;
    ELSE
      GOTO ACCEPT_NUMBER;
    END IF;
  WHEN '.' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR:=' '; END IF;
    IF CHR NOT IN '0' .. '9' AND THEN CHR NOT IN 'A' .. 'Z'
    AND THEN CHR NOT IN 'a' .. 'z' THEN
      TOK_TYP := ERROR;
    END IF;
    IF TOK_TYP = INT THEN
      TOK_TYP := DEC;
    END IF;
    GOTO SCAN_BASED_DEC_DIGIT;
  WHEN OTHERS =>
    GOTO SCAN_ERROR;
  END CASE;
      
<<SCAN_BASED_DEC_DIGIT>>
  CASE CHR IS
  WHEN '0' .. '9' =>
    IF CHR > BASE_DIGIT THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR := ' '; END IF;
    GOTO SCAN_BASED_DEC_DIGIT;
  WHEN 'A' .. 'Z' =>
    IF CHR > BASE_LETTER THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR:=' '; END IF;
      GOTO SCAN_BASED_DEC_DIGIT;
  WHEN 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
    GOTO SCAN_BASED_DEC_DIGIT;
  WHEN '_' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY( W_COL );
    ELSE CHR:=' '; END IF;
    IF CHR NOT IN '0' .. '9' AND THEN CHR NOT IN 'A' .. 'Z'
    AND THEN CHR NOT IN 'a' .. 'z' THEN
      TOK_TYP := ERROR;
    END IF;
    GOTO SCAN_BASED_DEC_DIGIT;
  WHEN '#' | ':' =>
    IF CHR /= QUOTE_CHR THEN
      TOK_TYP := ERROR;
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := '#';
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
    ELSE CHR:=' '; END IF;
    IF CHR = 'E' OR ELSE CHR = 'e' THEN
      GOTO SCAN_DEC_E;
    ELSE
      GOTO ACCEPT_NUMBER;
    END IF;
  WHEN OTHERS =>
    GOTO SCAN_ERROR;
  END CASE;
      
<<SCAN_INT_E>>
  IF W_COL < LINE_LENGTH AND THEN SL.BDY (W_COL + 1) = '-' THEN
    TOK_TYP := ERROR;
  END IF;
                -- GOTO SCAN_DEC_E
      
<<SCAN_DEC_E>>
  IF W_COL >= LINE_LENGTH THEN
    TOK_TYP := ERROR;
    GOTO ACCEPT_TOKEN;
  END IF;
  CHR := SL.BDY (W_COL + 1);
  IF CHR IN '0' .. '9' OR ELSE CHR = '+' OR ELSE CHR = '-' THEN
    W_COL := W_COL + 1;
    TOKEN_LENGTH := TOKEN_LENGTH + 2;
    TEXT( TOKEN_LENGTH - 1 ) := 'E';
    TEXT( TOKEN_LENGTH ) := CHR;
    IF (CHR = '+' OR ELSE CHR = '-')
    AND THEN (W_COL >= LINE_LENGTH
    OR ELSE SL.BDY( W_COL + 1 ) NOT IN '0' .. '9') THEN
      TOK_TYP := ERROR;
    END IF;
    W_COL := W_COL + 1;
    IF W_COL<=LINE_LENGTH THEN CHR:=SL.BDY(W_COL);
    ELSE CHR:=' '; END IF;
                        -- GOTO SCAN_EXPONENT;
  ELSE
    TOK_TYP := ERROR;
    GOTO ACCEPT_TOKEN;
  END IF;
      
<<SCAN_EXPONENT>>
  IF CHR IN '0' .. '9' OR ELSE CHR = '_' THEN
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF CHR = '_' THEN
      IF W_COL > LINE_LENGTH OR ELSE SL.BDY( W_COL ) NOT IN '0' .. '9' THEN
        TOK_TYP := ERROR;
      END IF;
    END IF;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR :=  ' '; END IF;
    GOTO SCAN_DEC;
  END IF;
  GOTO ACCEPT_NUMBER;
      
<<SCAN_QUOTE>>
  IF W_COL <= LINE_LENGTH THEN
    CHR := SL.BDY (W_COL);
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF CHR = QUOTE_CHR THEN
                                -- COPY DOUBLED QUOTE (BUT NOT %)
      IF W_COL <= LINE_LENGTH AND THEN SL.BDY( W_COL ) = QUOTE_CHR THEN
        IF QUOTE_CHR = '"' THEN
          TOKEN_LENGTH := TOKEN_LENGTH + 1;
          TEXT( TOKEN_LENGTH ) := CHR;
        END IF;
        W_COL := W_COL + 1;
      ELSE
        TEXT( TOKEN_LENGTH ) := '"';
        GOTO ACCEPT_TOKEN;
      END IF;
    ELSIF CHR = '"' THEN
      TOK_TYP := ERROR;      -- '"' INSIDE % ... %
    END IF;
    GOTO SCAN_QUOTE;
  ELSE
    TOK_TYP := ERROR;
    GOTO ACCEPT_TOKEN;
  END IF;
      
<<SCAN_CHAR>>
  IF CHAR_CONTEXT
  AND THEN W_COL < LINE_LENGTH
  AND THEN SL.BDY( W_COL + 1 ) = ''' THEN
    TOK_TYP := CHAR;
    TOKEN_LENGTH := 3;
    TEXT (2) := SL.BDY( W_COL );
    TEXT (3) := ''';
    W_COL := W_COL + 2;
    IF TEXT(2) NOT IN ' ' .. CHARACTER'VAL(127) THEN
      TOK_TYP := ERROR;
      TEXT(2) := '?';
    END IF;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_COMMENT>>
  IF CHR = '-' THEN
    TOK_TYP := NIL;
                        -- RECOPIE LIBERTE AVEC LA NORME ADA83 TOUS CARACTERES AUTORISES DANS LES COMMENTAIRES
    WHILE W_COL <= LINE_LENGTH LOOP
      CHR := SL.BDY( W_COL );
      W_COL := W_COL + 1;
               -- IF CHR NOT IN ' ' .. CHARACTER'VAL (127) AND THEN CHR NOT IN ASCII.HT .. ASCII.CR THEN
                  -- TOK_TYP := ERROR;
               -- END IF;
    END LOOP;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_EQUAL>>
  IF CHR = '>' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_PERIOD>>
  IF CHR = '.' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_STAR>>
  IF CHR = '*' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_COLON_SLASH>>
  IF CHR = '=' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_GREATER_THAN>>
  IF CHR = '=' OR CHR = '>' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
    
<<SCAN_LESS_THAN>>
  IF CHR = '=' OR CHR = '<' OR CHR = '>' THEN
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  END IF;
  GOTO ACCEPT_TOKEN;
      
<<SCAN_ERROR>>
  TOK_TYP := ERROR;
  CASE CHR IS
  WHEN ' ' | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9'
                                        | '&' | ''' | '(' | ')' | '*' | '+' | ','
                                        | '-' | '.' | '/' | ':' | '<' | '='
                                        | '>' | '|' | '!' | '%' | HT =>
    GOTO ACCEPT_TOKEN;
  WHEN OTHERS =>
    IF CHR NOT IN ' ' .. CHARACTER'VAL ( 127 ) THEN
      CHR := '?';
    END IF;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    IF W_COL <= LINE_LENGTH THEN CHR := SL.BDY( W_COL );
    ELSE CHR := ' '; END IF;
    GOTO SCAN_ERROR;
  END CASE;
      
<<ACCEPT_NUMBER>>
  IF CHR IN 'A' .. 'Z' OR ELSE CHR IN 'a' .. 'z' OR ELSE CHR IN '0' .. '9' THEN
    TOK_TYP := ERROR;
  END IF;
      
<<ACCEPT_TOKEN>>
  COL := W_COL - 1;
  TTYPE_OUT := TOK_TYP;
  F_COL := START_COL;
  TOK_LEN := TOKEN_LENGTH;
END NEXT_TOKEN;
--|#################################################################################################
--|
--|	PROCEDURE LEX_SCAN
--|
PROCEDURE LEX_SCAN IS
  TOK_TYP		: TOKEN_TYPE;
  TOK_LEN		: NATURAL;
BEGIN
  NEXT_TOKEN( CHAR_CONTEXT, TOK_TYP, TOK_LEN );						--| LIRE L UNITE LEXICALE
  E_COL := F_COL + TOK_LEN - 1;							--| METTRE A JOUR LA COLONNE DE FIN
										--| AFECTER LE TYPE DE L ULEX
  IF TOK_TYP = NIL THEN								--| TYPE BRUT NIL
    LTYPE := LT_END_MARK;								--| ULEX FIN
  ELSE
    CHAR_CONTEXT := TRUE;
    IF TOK_TYP = QUOTE THEN								--| TYPE BRUT AVEC GUILLEMENT
      LTYPE := LT_STRING_LIT;								--| ULEX CHAINE
    ELSIF TOK_TYP = INT OR TOK_TYP = DEC THEN						--| TYPE BRUT ENTIER OU DECIMAL
      LTYPE := LT_NUMERIC_LIT;							--| ULEX NOMBRE
    ELSIF TOK_TYP = CHAR THEN								--| TYPE BRUT CARACTERE
      LTYPE := LT_CHAR_LIT;								--| ULEX CARACTERE
    ELSIF TOK_TYP = ERROR THEN							--| TYPE BRUT ERREUR
      LTYPE := LT_ERROR;								--| ULEX ERREUR
    ELSE										--| CLASSE TTYPE = IDENT OR PUNCT
      IF ATTRIBUTE_CONTEXT AND THEN TOK_TYP = IDENT THEN					--| IDENTIFICATEUR ATTRIBUT
        LTYPE := LT_IDENTIFIER;							--| ULEX IDENTIFICATEUR
      ELSE									--| HORS CONTEXTE D' ATTRIBUT
        LTYPE := HASH_SEARCH( TEXT( 1..TOK_LEN ) );					--| CHERCHER LE LEX_TYPE DE MOT CLE EVENTUEL
      END IF;
      IF LTYPE = LT_IDENTIFIER THEN							--| IDENTIFICATEUR
        IF TOK_TYP = IDENT THEN							--| TYPE BRUT IDENTIFICATEUR
          CHAR_CONTEXT := FALSE;							--| SORTIE DU CONTEXTE CARACTERES IDENTIFICATEUR
        ELSE
          LTYPE := LT_ERROR;								--| ERREUR SI TYPE BRUT NON IDENT
        END IF;
      END IF;
    END IF;
  END IF;
  
  ATTRIBUTE_CONTEXT := ( LTYPE = LT_APOSTROPHE );						--| APOSTROPHE PASSER EN CONTEXTE IDENTIFICATEUR ATTRIBUT
         
END LEX_SCAN;
--|#################################################################################################
--|
--|	FUNCTION TOKEN_STRING							--| RETOURNE LA CHAINE DE L ULEX
--|
FUNCTION TOKEN_STRING RETURN STRING IS
BEGIN
  RETURN TEXT( 1..TOKEN_LENGTH );
END;
--|#################################################################################################
--|
--|	FUNCTION LEX_IMAGE
--|
FUNCTION LEX_IMAGE ( LT :LEX_TYPE ) RETURN STRING IS					--| RETOURNE LA CHAINE IMAGE DU TYPE DE L ULEX

BEGIN
  CASE LT IS
  WHEN LT_AMPERSAND .. LT_BOX =>							--| SYMBOLE
    DECLARE
      OP_TEXT	: CONSTANT STRING( 1..52 )
		  := "& ' ( ) * + , - . / : ; < = > | =>..**:=/=>=<=<<>><>";
      II		: INTEGER								--| POSITION DE LA CHAINE DU SYMBOLE
		  := LEX_TYPE'POS ( LT ) * 2 - LEX_TYPE'POS ( LT_AMPERSAND ) * 2 + 1;
      TEMP_STRING	: STRING ( 1 .. 2 )	:= OP_TEXT( II .. II+1 );
      
    BEGIN
      IF TEMP_STRING( 2 ) = ' ' THEN RETURN TEMP_STRING( 1 .. 1 );				--| SYMBOLE A UN SEUL CARACTERE
      ELSE RETURN TEMP_STRING( 1 .. 2 );						--| SYMBOLE A DEUX CARACTERES
      END IF;
    END;
               
  WHEN LT_ABORT .. LT_XOR => 								--| MOT RESERVE RETIRER LE "LT_" QUI PREFIXE LE MOT DANS L IMAGE
    DECLARE
      IMAGE	: CONSTANT STRING		:= LEX_TYPE'IMAGE( LT );			--| IMAGE PAR EXEMPLE "LT_ABORT"
      TRONQ	: STRING ( 1..IMAGE'LENGTH-3 ):= IMAGE ( 4 .. IMAGE'LENGTH );
    BEGIN
      RETURN TRONQ;									--| RETOURNER SEULEMENT "ABORT"
    END;

  WHEN LT_IDENTIFIER	=> RETURN "identifier";
  WHEN LT_NUMERIC_LIT	=> RETURN "numeric_literal";
  WHEN LT_STRING_LIT	=> RETURN "string_literal";
  WHEN LT_CHAR_LIT		=> RETURN "character_literal";
  WHEN LT_END_MARK		=> RETURN "*end*";
  WHEN LT_ERROR		=> RETURN "*error*";
  END CASE;
END LEX_IMAGE;
--|#################################################################################################

BEGIN
  FOR LT IN LT_ABORT .. LT_BOX LOOP							--| POUR TOUS LES TERMINAUX
    HASH_TABLE( HASH_POS( LEX_IMAGE( LT ) ) ) := LT;
  END LOOP;
--|-------------------------------------------------------------------------------------------------
END LEX;
