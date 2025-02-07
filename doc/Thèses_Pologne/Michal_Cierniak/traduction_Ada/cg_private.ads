package CG_PRIVATE is

  MAXFILENR        : constant Integer := 10;
  MAXFILENAMELEN   : constant Integer := 80;
  SYMBOLSBUFFERLEN : constant Integer := 10_000;

  subtype FILENRTYPE is Integer range 0 .. MAXFILENR;
  subtype FILENAMETYPE is String (1 .. MAXFILENAMELEN);

  type SOURCE_POSITION is record
    FILE_NR : FILENRTYPE;
    COL_NR  : Integer;
    LINE_NR : Integer;
  end record;

  subtype SYMBOL_REP is Integer;
  subtype NUMBER_REP is SYMBOL_REP;

  type VALUE_TYPES is (NO_VALUE, STRING_VALUE, BOOL_VALUE, INT_VALUE, CHAR_VALUE);

  type VALUE (V_TYPE : VALUE_TYPES := NO_VALUE) is record
    case V_TYPE is
      when NO_VALUE =>
        null;
      when STRING_VALUE =>
        STR_VAL : SYMBOL_REP;
      when BOOL_VALUE =>
        BOO_VAL : Boolean;
      when INT_VALUE =>
        INT_VAL : Integer;
      when CHAR_VALUE =>
        CHR_VAL : Character;
    end case;
  end record;

  subtype COMP_UNIT_NBR is INTEGER range 0 .. 255;
  subtype BYTE is INTEGER range 0 .. 255;
  subtype WORD is INTEGER range 0 .. 32_767;
  subtype REEL is Float;

  type BINARY_OP is (AND_THEN, OR_ELSE);

  type OPERATOR is
   (OP_AND, OP_OR, OP_XOR, OP_EQ, OP_NE, OP_LT, OP_LE, OP_GT, OP_GE, OP_PLUS, OP_MINUS, OP_CAT, OP_UNARY_PLUS,
    OP_UNARY_MINUS, OP_ABS, OP_NOT, OP_MULT, OP_DIV, OP_MOD, OP_REM, OP_EXP);

  function FILENAMENUMBER (NAME : FILENAMETYPE) return FILENRTYPE;
  function FILENAME (NR : FILENRTYPE) return FILENAMETYPE;
  function PUTSYMBOL (S : String) return SYMBOL_REP;
  function GETSYMBOL (SYM : SYMBOL_REP) return String;

end CG_PRIVATE;
