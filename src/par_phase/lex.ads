--|-------------------------------------------------------------------------------------------------
--|	LEX
--|-------------------------------------------------------------------------------------------------
package LEX is
       
  type LEX_TYPE is (								--| TYPE D UNITE LEXICALE
         LT_ERROR,									--| ULEX ERREUR

         LT_ABORT,		LT_ABS,		LT_ACCEPT,	LT_ACCESS,		--| UNITES LEXICALES TERMINALES MOTS RESERVES
         LT_ALL,		LT_AND,		LT_ARRAY,		LT_AT,		LT_BEGIN,
         LT_BODY,		LT_CASE,		LT_CONSTANT,	LT_DECLARE,	LT_DELAY,
         LT_DELTA,		LT_DIGITS,	LT_DO,		LT_ELSE,		LT_ELSIF,
         LT_END,		LT_ENTRY,		LT_EXCEPTION,	LT_EXIT,		LT_FOR,
         LT_FUNCTION,	LT_GENERIC,	LT_GOTO,		LT_IF,
         LT_IN,		LT_IS,		LT_LIMITED,	LT_LOOP,		LT_MOD,
         LT_NEW,		LT_NOT,		LT_NULL,		LT_OF,		LT_OR,
         LT_OTHERS,		LT_OUT,		LT_PACKAGE,	LT_PRAGMA,	LT_PRIVATE,
         LT_PROCEDURE,	LT_RAISE,		LT_RANGE,		LT_RECORD,
         LT_REM,		LT_RENAMES,	LT_RETURN,	LT_REVERSE,	LT_SELECT,
         LT_SEPARATE,	LT_SUBTYPE,	LT_TASK,		LT_TERMINATE,
         LT_THEN,		LT_TYPE,		LT_USE,		LT_WHEN,		LT_WHILE,
         LT_WITH,		LT_XOR,
				
         LT_AMPERSAND,	LT_APOSTROPHE,	LT_LEFT_PAREN,	LT_RIGHT_PAREN,		--| UNITES LEXICALES TERMINALES SYMBOLES
         LT_STAR,		LT_PLUS,		LT_COMMA,		LT_HYPHEN,	LT_PERIOD,
         LT_SLASH,		LT_COLON,		LT_SEMICOLON,	LT_LESS_THAN,	LT_EQUAL,
         LT_GREATER_THAN,	LT_VERTICAL_BAR,	LT_ARROW,		LT_DOUBLE_DOT,
         LT_DOUBLE_STAR,	LT_BECOMES,	LT_NOT_EQUAL,	LT_GREATER_EQUAL,
         LT_LESS_EQUAL,	LT_LEFT_LABEL,	LT_RIGHT_LABEL,	LT_BOX,

         LT_IDENTIFIER,	LT_NUMERIC_LIT,	LT_STRING_LIT,	LT_CHAR_LIT,		--| UNITES LEXICALES AVEC SEMANTIQUE

         LT_END_MARK								--| ULEX FIN DE SOURCE
         );
      
  subtype LT_RESERVED	is LEX_TYPE range LT_ABORT      .. LT_XOR;
  subtype LT_SYMBOL		is LEX_TYPE range LT_AMPERSAND  .. LT_BOX;
  subtype LT_TERMINAL	is LEX_TYPE range LT_ABORT      .. LT_BOX;
  subtype LT_WITH_SEMANTICS	is LEX_TYPE range LT_IDENTIFIER .. LT_CHAR_LIT;


  MAX_STRING	: constant POSITIVE	:= 255;						--| CHAINE DE 256 CARACTERES MAXIMUM
      
  type LINE_OF_SOURCE	is record
			  LEN	: NATURAL;
			  BDY	: STRING( 1 .. MAX_STRING );
			end record;
      
  SLINE		: LINE_OF_SOURCE;							--| LIGNE COURANTE LUE
  LAST		: NATURAL;							--| NOMBRE DE CARACTERES LUS
  COL		: NATURAL;							--| DERNIERE COLONNE BALAYEE
  F_COL		: NATURAL;							--| POSITION DU PREMIER CARACTERE DU LEXEME
  E_COL		: NATURAL;							--| POSITION DU DERNIER CARACTERE DU LEXEME
  LTYPE		: LEX_TYPE;							--| TYPE DU LEXEME
   
    
  procedure LEX_SCAN;
  function  TOKEN_STRING				return STRING;

  function  LEX_IMAGE	( LT :LEX_TYPE )		return STRING;
      
--|-------------------------------------------------------------------------------------------------
end LEX;
