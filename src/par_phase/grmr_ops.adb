--|-------------------------------------------------------------------------------------------------
--|	GRMR_OPS
--|-------------------------------------------------------------------------------------------------
package body GRMR_OPS is
   
  type HASH_BYTE	is range 0..255;	for HASH_BYTE'SIZE use 8;
   
  HSIZE		: constant := 37;
  HCODE		: INTEGER;
      
  type HTABLE_TYPE	is record
		  HN	: STRING(1 .. 17)	:= (others=>' ');
		  HP	: GRMR_OP	:= G_ERROR;
		end record;
  HTABLE		: array (0 .. INTEGER(HSIZE-1)) of HTABLE_TYPE;
  ITABLE		: array (GRMR_OP) of HASH_BYTE;					--| POUR LA FONCTION IMAGE
   
--|-------------------------------------------------------------------------------------------------
--|	PROCEDURE HASH_SEARCH
procedure HASH_SEARCH ( S :STRING ) is
  A_17	: STRING( 1 .. 17 )	:= (others => ' ');
begin
  if S'LENGTH <= 17 then
    A_17( 1 .. S'LENGTH ) := S;
  end if;
  HCODE := (S'LENGTH + CHARACTER'POS( S( S'LAST ) ) ) mod HSIZE;
      
  while A_17 /= HTABLE( HCODE ).HN and then HTABLE( HCODE ).HP /= G_ERROR loop
    HCODE := (HCODE + 1) mod HSIZE;
  end loop;
end HASH_SEARCH;
--|#################################################################################################
--|	FUNCTION GRMR_OP_VALUE
function GRMR_OP_VALUE ( S :STRING ) return GRMR_OP is
begin
  HASH_SEARCH( S );
  return HTABLE( HCODE ).HP;
end;
--|#################################################################################################
--|	FUNCTION GRMR_OP_IMAGE
function GRMR_OP_IMAGE ( GO :GRMR_OP ) return STRING is
  LL	: INTEGER	:= 17;
  TXT	: STRING( 1..17 )	:= HTABLE( INTEGER( ITABLE( GO ) ) ).HN;
begin
  while TXT( LL ) = ' ' loop
    LL := LL - 1;
  end loop;
  return TXT( 1 .. LL + 1 );
end GRMR_OP_IMAGE;
--|#################################################################################################
   
begin
  declare

    procedure STASH ( P :GRMR_OP; S :STRING ) is
      A_17	: STRING( 1 .. 17 )	:= (others => ' ');
    begin
      HASH_SEARCH( S );
      A_17( 1 .. S'LENGTH ) := S;
      HTABLE( HCODE ) := (HN=> A_17, HP=> P);
      ITABLE( P ) := HASH_BYTE( HCODE );
    end STASH;
      
  begin
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
  end;
--|-------------------------------------------------------------------------------------------------
end GRMR_OPS;
