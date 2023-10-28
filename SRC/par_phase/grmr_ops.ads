--|-------------------------------------------------------------------------------------------------
--|	GRMR_OPS
--|-------------------------------------------------------------------------------------------------
PACKAGE GRMR_OPS IS
      
  TYPE GRMR_OP	IS (
	G_ERROR,		N_0,		N_DEF,		N_1,
	N_2,		N_N2,		N_V2,		N_3,
	N_N3,		N_V3,		N_L,		G_INFIX,
	G_UNARY,		G_LX_SYMREP,	G_LX_NUMREP,	G_LX_DEFAULT,
	G_NOT_LX_DEFAULT,	G_NIL,		G_INSERT,		G_APPEND,
	G_CAT,		G_VOID,		G_LIST,		G_EXCH_1,
	G_EXCH_2,		G_CHECK_NAME,	G_CHECK_SUBP_NAME,	G_CHECK_ACCEPT_NAME
	);

  SUBTYPE GRMR_OP_NODE	IS GRMR_OP RANGE N_0 .. N_L;
  SUBTYPE GRMR_OP_NULLARY	IS GRMR_OP RANGE N_0 .. N_DEF;
  SUBTYPE GRMR_OP_UNARY	IS GRMR_OP RANGE N_1 .. N_1;
  SUBTYPE GRMR_OP_BINARY	IS GRMR_OP RANGE N_2 .. N_V2;
  SUBTYPE GRMR_OP_TERNARY	IS GRMR_OP RANGE N_3 .. N_V3;
  SUBTYPE GRMR_OP_ARBITRARY	IS GRMR_OP RANGE N_L .. N_L;
  SUBTYPE GRMR_OP_QUOTE	IS GRMR_OP RANGE G_INFIX .. G_UNARY;
  SUBTYPE GRMR_OP_NOARG	IS GRMR_OP RANGE G_LX_SYMREP .. GRMR_OP'LAST;
      
      
  FUNCTION  GRMR_OP_VALUE	( S :STRING )	RETURN GRMR_OP;
  FUNCTION  GRMR_OP_IMAGE	( GO :GRMR_OP )	RETURN STRING;
      
--|-------------------------------------------------------------------------------------------------
END GRMR_OPS;
