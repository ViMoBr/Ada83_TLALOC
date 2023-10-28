--|-------------------------------------------------------------------------------------------------
--|	GRMR_OPS
--|-------------------------------------------------------------------------------------------------
PACKAGE BODY GRMR_OPS IS
   
  TYPE HASH_BYTE	IS RANGE 0..255;	FOR HASH_BYTE'SIZE USE 8;
   
  HSIZE		: CONSTANT := 37;
  HCODE		: INTEGER;
      
  TYPE HTABLE_TYPE	IS RECORD
		  HN	: STRING(1 .. 17)	:= (OTHERS=>' ');
		  HP	: GRMR_OP	:= G_ERROR;
		END RECORD;
  HTABLE		: ARRAY (0 .. INTEGER(HSIZE-1)) OF HTABLE_TYPE;
  ITABLE		: ARRAY (GRMR_OP) OF HASH_BYTE;					--| POUR LA FONCTION IMAGE
   
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE HASH_SEARCH
PROCEDURE HASH_SEARCH ( S :STRING ) IS
  A_17	: STRING( 1 .. 17 )	:= (OTHERS => ' ');
BEGIN
  IF S'LENGTH <= 17 THEN
    A_17( 1 .. S'LENGTH ) := S;
  END IF;
  HCODE := (S'LENGTH + CHARACTER'POS( S( S'LAST ) ) ) MOD HSIZE;
      
  WHILE A_17 /= HTABLE( HCODE ).HN AND THEN HTABLE( HCODE ).HP /= G_ERROR LOOP
    HCODE := (HCODE + 1) MOD HSIZE;
  END LOOP;
END HASH_SEARCH;
--|#################################################################################################
--|	FUNCTION GRMR_OP_VALUE
FUNCTION GRMR_OP_VALUE ( S :STRING ) RETURN GRMR_OP IS
BEGIN
  HASH_SEARCH( S );
  RETURN HTABLE( HCODE ).HP;
END;
--|#################################################################################################
--|	FUNCTION GRMR_OP_IMAGE
FUNCTION GRMR_OP_IMAGE ( GO :GRMR_OP ) RETURN STRING IS
  LL	: INTEGER	:= 17;
  TXT	: STRING( 1..17 )	:= HTABLE( INTEGER( ITABLE( GO ) ) ).HN;
BEGIN
  WHILE TXT( LL ) = ' ' LOOP
    LL := LL - 1;
  END LOOP;
  RETURN TXT( 1 .. LL + 1 );
END GRMR_OP_IMAGE;
--|#################################################################################################
   
BEGIN
  DECLARE

    PROCEDURE STASH ( P :GRMR_OP; S :STRING ) IS
      A_17	: STRING( 1 .. 17 )	:= (OTHERS => ' ');
    BEGIN
      HASH_SEARCH( S );
      A_17( 1 .. S'LENGTH ) := S;
      HTABLE( HCODE ) := (HN=> A_17, HP=> P);
      ITABLE( P ) := HASH_BYTE( HCODE );
    END STASH;
      
  BEGIN
    STASH ( N_0,			"$0"		);
    STASH ( N_DEF,			"$DEF" 		);
    STASH ( N_1,			"$1"		);
    STASH ( N_2,			"$2"		);
    STASH ( N_3,			"$3"		);
    STASH ( N_N2,			"$N2"		);
    STASH ( N_N3,			"$N3"		);
    STASH ( N_V2,			"$V2"		);
    STASH ( N_V3,			"$V3"		);
    STASH ( N_L,			"$L"		);
    STASH ( G_INFIX,		"infix"		);
    STASH ( G_UNARY,		"unary"		);
    STASH ( G_LX_SYMREP,		"lx_symrep"	);
    STASH ( G_LX_NUMREP,		"lx_numrep"	);
    STASH ( G_LX_DEFAULT,		"lx_default"	);
    STASH ( G_NOT_LX_DEFAULT,		"not_lx_default"	);
    STASH ( G_NIL,			"nil"		);
    STASH ( G_INSERT,		"insert"		);
    STASH ( G_APPEND,		"append"		);
    STASH ( G_CAT,			"cat"		);
    STASH ( G_VOID,			"void" 		);
    STASH ( G_LIST,			"list" 		);
    STASH ( G_EXCH_1,		"exch_1"		);
    STASH ( G_EXCH_2,		"exch_2"		);
    STASH ( G_CHECK_NAME,		"check_name"	);
    STASH ( G_CHECK_SUBP_NAME,	"check_subp_name"	);
    STASH ( G_CHECK_ACCEPT_NAME,	"check_accept_name"	);
  END;
--|-------------------------------------------------------------------------------------------------
END GRMR_OPS;
