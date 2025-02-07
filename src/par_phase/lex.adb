with TEXT_IO;
use TEXT_IO;
--|-------------------------------------------------------------------------------------------------
--|	LEX
--|-------------------------------------------------------------------------------------------------
package body LEX is
   
  CHAR_CONTEXT		: BOOLEAN	:= TRUE;
  ATTRIBUTE_CONTEXT		: BOOLEAN	:= FALSE;
   
  type TOKEN_TYPE		is ( NIL, IDENT, PUNCT, QUOTE, INT, DEC, CHAR, ERROR );		--| ULEX TYPE BRUT A LA LECTURE
  TEXT			: STRING(1 .. 255);						--| TAMPON TEXTE DE L'ULEX
  TOKEN_LENGTH		: NATURAL;
   
  HASH_SIZE		: constant INTEGER	:= 311;
  HASH_TABLE		: array ( 0 .. HASH_SIZE - 1 ) of LEX_TYPE := ( others=> LT_IDENTIFIER );
   
   
--|-------------------------------------------------------------------------------------------------
--|	FUNCTION HASH_POS
--|-------------------------------------------------------------------------------------------------
function HASH_POS ( TXT :STRING ) return INTEGER is					--| FONCTION DE HACHAGE DU NOM DE TERMINAL
  I: INTEGER;
begin
  I := TXT'LENGTH + 157 * CHARACTER'POS( TXT( TXT'LAST ) );
  I := I mod HASH_SIZE;
  while HASH_TABLE(I) /= LT_IDENTIFIER and then LEX_IMAGE( HASH_TABLE( I ) ) /= TXT loop
    I := I + 1;
    if I = HASH_SIZE then
      I := 0;
    end if;
  end loop;
  return I;
end HASH_POS;
--|-------------------------------------------------------------------------------------------------
--|	FUNCTION HASH_SEARCH
function HASH_SEARCH ( TXT :STRING ) return LEX_TYPE is
begin
  return HASH_TABLE( HASH_POS( TXT ) );
end;
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE NEXT_TOKEN
procedure NEXT_TOKEN ( CHAR_CONTEXT: BOOLEAN; TTYPE_OUT: out TOKEN_TYPE; TOK_LEN :out NATURAL ) is
      
  use ASCII;
      
  CASE_MAGIC		: constant := CHARACTER'POS ( 'a' ) - CHARACTER'POS ( 'A' );

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
      
  SL		: LINE_OF_SOURCE renames SLINE;

begin
  LINE_LENGTH := SLINE.LEN;								--| LONGUEUR DE LIGNE
  W_COL := COL + 1;									--| No CARACTERE SUIVANT
      
  while W_COL <= LINE_LENGTH loop
    CHR := SL.BDY( W_COL );								--| PRENDRE LE CARACTERE
    exit when CHR /= ' ' and then CHR not in ASCII.HT .. ASCII.CR;				--| SORTIR SI PAS BLANC
    W_COL := W_COL + 1;								--| PASSER AU SUIVANT
  end loop;
      
  START_COL := W_COL;								--| POSITION PREMIER CARACTERE DU LEXEME
       
  if W_COL > LINE_LENGTH then
    TOKEN_LENGTH := 0;
    TOK_TYP := NIL;
    goto ACCEPT_TOKEN;
  end if;
      
  TEXT( 1 ) := CHR;
  TOKEN_LENGTH := 1;
  TOK_TYP := PUNCT;									--| PAR DEFAUT
  W_COL := W_COL + 1;
  if W_COL <= LINE_LENGTH then
    CHR := SL.BDY( W_COL );
  else
    CHR:=' ';
  end if;
      
  case TEXT (1) is
  when 'A' .. 'Z' =>
    TOK_TYP := IDENT;
    goto SCAN_IDENT;
  when '_' =>									-- AUTORISER LES _ DE TETE POUR LA PROGRAMMATION SYSTEME
    TOK_TYP := IDENT;
    goto SCAN_IDENT;
  when 'a' .. 'z' =>
    TEXT (1) := CHARACTER'VAL( CHARACTER'POS( TEXT( 1 ) ) - CASE_MAGIC );
    TOK_TYP := IDENT;
    goto SCAN_IDENT;
  when '0' .. '9' =>
    TOK_TYP := INT;
    goto SCAN_INT;
  when '"' | '%' =>
    TOK_TYP := QUOTE;
    QUOTE_CHR := TEXT (1);
    TEXT (1) := '"';
    goto SCAN_QUOTE;
  when ''' =>
    goto SCAN_CHAR;
  when '-' =>
    goto SCAN_COMMENT;
  when '=' =>
    goto SCAN_EQUAL;
  when '.' =>
    goto SCAN_PERIOD;
  when '*' =>
    goto SCAN_STAR;
  when ':' | '/' =>
    goto SCAN_COLON_SLASH;
  when '>' =>
    goto SCAN_GREATER_THAN;
  when '<' =>
    goto SCAN_LESS_THAN;
  when '&' | '(' | ')' | '+' | ',' | ';' | '|' =>
    goto ACCEPT_TOKEN;
  when '!' =>
    TEXT (1) := '|';
    goto ACCEPT_TOKEN;
  when others =>
    if TEXT (1) not in ' ' .. CHARACTER'VAL( 127 ) then
      TEXT (1) := '?';
    end if;
    goto SCAN_ERROR;
  end case;
      
<<SCAN_IDENT>>
  case CHR is
  when '_' =>
    goto SCAN_IDENT_UNDERLINE;
  when 'A' .. 'Z' | '0' .. '9' =>
    null;
  when 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
  when others =>
    goto ACCEPT_TOKEN;
  end case;
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := CHR;
  W_COL := W_COL + 1;
  if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
  else CHR:=' '; end if;
  goto SCAN_IDENT;
      
<<SCAN_IDENT_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := CHR;
  W_COL := W_COL + 1;
  if W_COL<=LINE_LENGTH then CHR := SL.BDY( W_COL );
  else CHR:=' '; end if;
  if CHR not in 'A' .. 'Z' and then CHR not in 'a' .. 'z'
  and then CHR not in '0' .. '9' then
    TOK_TYP := ERROR;
  end if;
  goto SCAN_IDENT;
      
<<SCAN_INT>>
  case CHR is
  when '0' .. '9' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR := SL.BDY(W_COL);
    else CHR:=' '; end if;
    goto SCAN_INT;
  when '_' =>
    goto SCAN_INT_UNDERLINE;
  when '.' =>
    goto SCAN_INT_PERIOD;
  when 'E' | 'e' =>
    goto SCAN_INT_E;
  when '#' | ':' =>
    QUOTE_CHR := CHR;
    goto SCAN_BASED_INT;
  when others =>
    goto ACCEPT_NUMBER;
  end case;
      
<<SCAN_INT_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT (TOKEN_LENGTH) := CHR;
  W_COL := W_COL + 1;
  if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
  else CHR:=' '; end if;
  if CHR not in '0' .. '9' then
    TOK_TYP := ERROR;
  end if;
  goto SCAN_INT;
      
<<SCAN_INT_PERIOD>>
  if W_COL < LINE_LENGTH and then SL.BDY (W_COL + 1) in '0' .. '9' then
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    CHR := SL.BDY(W_COL);
    if TOK_TYP = INT then
      TOK_TYP := DEC;
    end if;
                      -- GOTO SCAN_DEC;
  else
    goto ACCEPT_NUMBER;
  end if;
      
<<SCAN_DEC>>
  case CHR is
  when '0' .. '9' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT (TOKEN_LENGTH) := CHR;
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
    else CHR:=' '; end if;
    goto SCAN_DEC;
  when '_' =>
    goto SCAN_DEC_UNDERLINE;
  when 'E' | 'e' =>
    goto SCAN_DEC_E;
  when others =>
    goto ACCEPT_NUMBER;
  end case;
      
<<SCAN_DEC_UNDERLINE>>
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT (TOKEN_LENGTH) := CHR;
  W_COL := W_COL + 1;
  if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
  else CHR:=' '; end if;
  if CHR not in '0' .. '9' then
    TOK_TYP := ERROR;
  end if;
  goto SCAN_DEC;
      
<<SCAN_BASED_INT>>
  BASE := 0;
  for I in 1 .. TOKEN_LENGTH loop
    if TEXT (I) in '0' .. '9' and then BASE <= 16 then
      BASE := BASE * 10 + CHARACTER'POS( TEXT (I) ) - CHARACTER'POS( '0' );
    end if;
  end loop;
  if BASE not in 2 .. 16 then
    TOK_TYP := ERROR;
    BASE := 16;
  end if;
      
  if BASE <= 9 then
    BASE_DIGIT := CHARACTER'VAL( CHARACTER'POS( '0' ) + BASE - 1 );
  else
    BASE_DIGIT := '9';
  end if;
  BASE_LETTER := CHARACTER'VAL( CHARACTER'POS( 'A' ) + BASE - 11 );
      
  TOKEN_LENGTH := TOKEN_LENGTH + 1;
  TEXT( TOKEN_LENGTH ) := '#';
  W_COL := W_COL + 1;
  if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
  else CHR:=' '; end if;
  if CHR in '0' .. '9' or else CHR in 'A' .. 'Z' or else CHR in 'a'..'z' then
    null; -- GO TO SCAN_BASED_INT_DIGIT
  else
    goto SCAN_ERROR;
  end if;
      
<<SCAN_BASED_INT_DIGIT>>
  case CHR is
  when '0' .. '9' =>
    if CHR > BASE_DIGIT then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR := ' '; end if;
    goto SCAN_BASED_INT_DIGIT;
  when 'A' .. 'Z' =>
    if CHR > BASE_LETTER then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR := ' '; end if;
    goto SCAN_BASED_INT_DIGIT;
  when 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
    goto SCAN_BASED_INT_DIGIT;
  when '_' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR:=SL.BDY(W_COL);
    else CHR := ' '; end if;
    if CHR not in '0' .. '9' and then CHR not in 'A' .. 'Z'
    and then CHR not in 'a' .. 'z' then
      TOK_TYP := ERROR;
    end if;
    goto SCAN_BASED_INT_DIGIT;
  when '#' | ':' =>
    if CHR /= QUOTE_CHR then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := '#';
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
    else CHR:=' '; end if;
    if CHR = 'E' or else CHR = 'e' then
      goto SCAN_INT_E;
    else
      goto ACCEPT_NUMBER;
    end if;
  when '.' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR:=' '; end if;
    if CHR not in '0' .. '9' and then CHR not in 'A' .. 'Z'
    and then CHR not in 'a' .. 'z' then
      TOK_TYP := ERROR;
    end if;
    if TOK_TYP = INT then
      TOK_TYP := DEC;
    end if;
    goto SCAN_BASED_DEC_DIGIT;
  when others =>
    goto SCAN_ERROR;
  end case;
      
<<SCAN_BASED_DEC_DIGIT>>
  case CHR is
  when '0' .. '9' =>
    if CHR > BASE_DIGIT then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR := ' '; end if;
    goto SCAN_BASED_DEC_DIGIT;
  when 'A' .. 'Z' =>
    if CHR > BASE_LETTER then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR:=' '; end if;
      goto SCAN_BASED_DEC_DIGIT;
  when 'a' .. 'z' =>
    CHR := CHARACTER'VAL( CHARACTER'POS( CHR ) - CASE_MAGIC );
    goto SCAN_BASED_DEC_DIGIT;
  when '_' =>
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR:=SL.BDY( W_COL );
    else CHR:=' '; end if;
    if CHR not in '0' .. '9' and then CHR not in 'A' .. 'Z'
    and then CHR not in 'a' .. 'z' then
      TOK_TYP := ERROR;
    end if;
    goto SCAN_BASED_DEC_DIGIT;
  when '#' | ':' =>
    if CHR /= QUOTE_CHR then
      TOK_TYP := ERROR;
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := '#';
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
    else CHR:=' '; end if;
    if CHR = 'E' or else CHR = 'e' then
      goto SCAN_DEC_E;
    else
      goto ACCEPT_NUMBER;
    end if;
  when others =>
    goto SCAN_ERROR;
  end case;
      
<<SCAN_INT_E>>
  if W_COL < LINE_LENGTH and then SL.BDY (W_COL + 1) = '-' then
    TOK_TYP := ERROR;
  end if;
                -- GOTO SCAN_DEC_E
      
<<SCAN_DEC_E>>
  if W_COL >= LINE_LENGTH then
    TOK_TYP := ERROR;
    goto ACCEPT_TOKEN;
  end if;
  CHR := SL.BDY (W_COL + 1);
  if CHR in '0' .. '9' or else CHR = '+' or else CHR = '-' then
    W_COL := W_COL + 1;
    TOKEN_LENGTH := TOKEN_LENGTH + 2;
    TEXT( TOKEN_LENGTH - 1 ) := 'E';
    TEXT( TOKEN_LENGTH ) := CHR;
    if (CHR = '+' or else CHR = '-')
    and then (W_COL >= LINE_LENGTH
    or else SL.BDY( W_COL + 1 ) not in '0' .. '9') then
      TOK_TYP := ERROR;
    end if;
    W_COL := W_COL + 1;
    if W_COL<=LINE_LENGTH then CHR:=SL.BDY(W_COL);
    else CHR:=' '; end if;
                        -- GOTO SCAN_EXPONENT;
  else
    TOK_TYP := ERROR;
    goto ACCEPT_TOKEN;
  end if;
      
<<SCAN_EXPONENT>>
  if CHR in '0' .. '9' or else CHR = '_' then
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if CHR = '_' then
      if W_COL > LINE_LENGTH or else SL.BDY( W_COL ) not in '0' .. '9' then
        TOK_TYP := ERROR;
      end if;
    end if;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR :=  ' '; end if;
    goto SCAN_DEC;
  end if;
  goto ACCEPT_NUMBER;
      
<<SCAN_QUOTE>>
  if W_COL <= LINE_LENGTH then
    CHR := SL.BDY (W_COL);
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if CHR = QUOTE_CHR then
                                -- COPY DOUBLED QUOTE (BUT NOT %)
      if W_COL <= LINE_LENGTH and then SL.BDY( W_COL ) = QUOTE_CHR then
        if QUOTE_CHR = '"' then
          TOKEN_LENGTH := TOKEN_LENGTH + 1;
          TEXT( TOKEN_LENGTH ) := CHR;
        end if;
        W_COL := W_COL + 1;
      else
        TEXT( TOKEN_LENGTH ) := '"';
        goto ACCEPT_TOKEN;
      end if;
    elsif CHR = '"' then
      TOK_TYP := ERROR;      -- '"' INSIDE % ... %
    end if;
    goto SCAN_QUOTE;
  else
    TOK_TYP := ERROR;
    goto ACCEPT_TOKEN;
  end if;
      
<<SCAN_CHAR>>
  if CHAR_CONTEXT
  and then W_COL < LINE_LENGTH
  and then SL.BDY( W_COL + 1 ) = ''' then
    TOK_TYP := CHAR;
    TOKEN_LENGTH := 3;
    TEXT (2) := SL.BDY( W_COL );
    TEXT (3) := ''';
    W_COL := W_COL + 2;
    if TEXT(2) not in ' ' .. CHARACTER'VAL(127) then
      TOK_TYP := ERROR;
      TEXT(2) := '?';
    end if;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_COMMENT>>
  if CHR = '-' then
    TOK_TYP := NIL;
                        -- RECOPIE LIBERTE AVEC LA NORME ADA83 TOUS CARACTERES AUTORISES DANS LES COMMENTAIRES
    while W_COL <= LINE_LENGTH loop
      CHR := SL.BDY( W_COL );
      W_COL := W_COL + 1;
               -- IF CHR NOT IN ' ' .. CHARACTER'VAL (127) AND THEN CHR NOT IN ASCII.HT .. ASCII.CR THEN
                  -- TOK_TYP := ERROR;
               -- END IF;
    end loop;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_EQUAL>>
  if CHR = '>' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_PERIOD>>
  if CHR = '.' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_STAR>>
  if CHR = '*' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_COLON_SLASH>>
  if CHR = '=' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_GREATER_THAN>>
  if CHR = '=' or CHR = '>' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
    
<<SCAN_LESS_THAN>>
  if CHR = '=' or CHR = '<' or CHR = '>' then
    TOKEN_LENGTH := 2;
    TEXT (2) := CHR;
    W_COL := W_COL + 1;
  end if;
  goto ACCEPT_TOKEN;
      
<<SCAN_ERROR>>
  TOK_TYP := ERROR;
  case CHR is
  when ' ' | 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9'
                                        | '&' | ''' | '(' | ')' | '*' | '+' | ','
                                        | '-' | '.' | '/' | ':' | '<' | '='
                                        | '>' | '|' | '!' | '%' | HT =>
    goto ACCEPT_TOKEN;
  when others =>
    if CHR not in ' ' .. CHARACTER'VAL ( 127 ) then
      CHR := '?';
    end if;
    TOKEN_LENGTH := TOKEN_LENGTH + 1;
    TEXT( TOKEN_LENGTH ) := CHR;
    W_COL := W_COL + 1;
    if W_COL <= LINE_LENGTH then CHR := SL.BDY( W_COL );
    else CHR := ' '; end if;
    goto SCAN_ERROR;
  end case;
      
<<ACCEPT_NUMBER>>
  if CHR in 'A' .. 'Z' or else CHR in 'a' .. 'z' or else CHR in '0' .. '9' then
    TOK_TYP := ERROR;
  end if;
      
<<ACCEPT_TOKEN>>
  COL := W_COL - 1;
  TTYPE_OUT := TOK_TYP;
  F_COL := START_COL;
  TOK_LEN := TOKEN_LENGTH;
end NEXT_TOKEN;
--|#################################################################################################
--|
--|	PROCEDURE LEX_SCAN
--|
procedure LEX_SCAN is
  TOK_TYP		: TOKEN_TYPE;
  TOK_LEN		: NATURAL;
begin
  NEXT_TOKEN( CHAR_CONTEXT, TOK_TYP, TOK_LEN );						--| LIRE L UNITE LEXICALE
  E_COL := F_COL + TOK_LEN - 1;							--| METTRE A JOUR LA COLONNE DE FIN
										--| AFECTER LE TYPE DE L ULEX
  if TOK_TYP = NIL then								--| TYPE BRUT NIL
    LTYPE := LT_END_MARK;								--| ULEX FIN
  else
    CHAR_CONTEXT := TRUE;
    if TOK_TYP = QUOTE then								--| TYPE BRUT AVEC GUILLEMENT
      LTYPE := LT_STRING_LIT;								--| ULEX CHAINE
    elsif TOK_TYP = INT or TOK_TYP = DEC then						--| TYPE BRUT ENTIER OU DECIMAL
      LTYPE := LT_NUMERIC_LIT;							--| ULEX NOMBRE
    elsif TOK_TYP = CHAR then								--| TYPE BRUT CARACTERE
      LTYPE := LT_CHAR_LIT;								--| ULEX CARACTERE
    elsif TOK_TYP = ERROR then							--| TYPE BRUT ERREUR
      LTYPE := LT_ERROR;								--| ULEX ERREUR
    else										--| CLASSE TTYPE = IDENT OR PUNCT
      if ATTRIBUTE_CONTEXT and then TOK_TYP = IDENT then					--| IDENTIFICATEUR ATTRIBUT
        LTYPE := LT_IDENTIFIER;							--| ULEX IDENTIFICATEUR
      else									--| HORS CONTEXTE D' ATTRIBUT
        LTYPE := HASH_SEARCH( TEXT( 1..TOK_LEN ) );					--| CHERCHER LE LEX_TYPE DE MOT CLE EVENTUEL
      end if;
      if LTYPE = LT_IDENTIFIER then							--| IDENTIFICATEUR
        if TOK_TYP = IDENT then							--| TYPE BRUT IDENTIFICATEUR
          CHAR_CONTEXT := FALSE;							--| SORTIE DU CONTEXTE CARACTERES IDENTIFICATEUR
        else
          LTYPE := LT_ERROR;								--| ERREUR SI TYPE BRUT NON IDENT
        end if;
      end if;
    end if;
  end if;
  
  ATTRIBUTE_CONTEXT := ( LTYPE = LT_APOSTROPHE );						--| APOSTROPHE PASSER EN CONTEXTE IDENTIFICATEUR ATTRIBUT
         
end LEX_SCAN;
--|#################################################################################################
--|
--|	FUNCTION TOKEN_STRING							--| RETOURNE LA CHAINE DE L ULEX
--|
function TOKEN_STRING return STRING is
begin
  return TEXT( 1..TOKEN_LENGTH );
end;
--|#################################################################################################
--|
--|	FUNCTION LEX_IMAGE
--|
function LEX_IMAGE ( LT :LEX_TYPE ) return STRING is					--| RETOURNE LA CHAINE IMAGE DU TYPE DE L ULEX

begin
  case LT is
  when LT_AMPERSAND .. LT_BOX =>							--| SYMBOLE
    declare
      OP_TEXT	: constant STRING( 1..52 )
		  := "& ' ( ) * + , - . / : ; < = > | =>..**:=/=>=<=<<>><>";
      II		: INTEGER								--| POSITION DE LA CHAINE DU SYMBOLE
		  := LEX_TYPE'POS ( LT ) * 2 - LEX_TYPE'POS ( LT_AMPERSAND ) * 2 + 1;
      TEMP_STRING	: STRING ( 1 .. 2 )	:= OP_TEXT( II .. II+1 );
      
    begin
      if TEMP_STRING( 2 ) = ' ' then return TEMP_STRING( 1 .. 1 );				--| SYMBOLE A UN SEUL CARACTERE
      else return TEMP_STRING( 1 .. 2 );						--| SYMBOLE A DEUX CARACTERES
      end if;
    end;
               
  when LT_ABORT .. LT_XOR => 								--| MOT RESERVE RETIRER LE "LT_" QUI PREFIXE LE MOT DANS L IMAGE
    declare
      IMAGE	: constant STRING		:= LEX_TYPE'IMAGE( LT );			--| IMAGE PAR EXEMPLE "LT_ABORT"
      TRONQ	: STRING ( 1..IMAGE'LENGTH-3 ):= IMAGE ( 4 .. IMAGE'LENGTH );
    begin
      return TRONQ;									--| RETOURNER SEULEMENT "ABORT"
    end;

  when LT_IDENTIFIER	=> return "identifier";
  when LT_NUMERIC_LIT	=> return "numeric_literal";
  when LT_STRING_LIT	=> return "string_literal";
  when LT_CHAR_LIT		=> return "character_literal";
  when LT_END_MARK		=> return "*end*";
  when LT_ERROR		=> return "*error*";
  end case;
end LEX_IMAGE;
--|#################################################################################################

begin
  for LT in LT_ABORT .. LT_BOX loop							--| POUR TOUS LES TERMINAUX
    HASH_TABLE( HASH_POS( LEX_IMAGE( LT ) ) ) := LT;
  end loop;
--|-------------------------------------------------------------------------------------------------
end LEX;
