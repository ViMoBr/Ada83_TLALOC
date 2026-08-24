-- GENBLK_TEST : gardien du piege n 144 (reserve levee).
-- Acces au GFP d'un corps generique depuis :
--   1. un bloc declare d'un PRO du corps (variable locale de type formel) ;
--   2. un PRO imbrique dans un PRO du corps, et un bloc dans ce PRO imbrique ;
--   3. un appel de sous-programme du corps generique emis depuis un bloc
--      (propagation du GFP).
-- Temoin auto-jugeant (CONVENTIONS_ARCHITECTURE section 8).

with TEXT_IO;	use TEXT_IO;

procedure	GENBLK_TEST
is

  NB_OK		: INTEGER	:= 0;
  NB_ECHECS	: INTEGER	:= 0;

  package INT_IO is new INTEGER_IO( INTEGER );

  generic
    type NUM is digits <>;
  package	GEN_PKG
  is
    function	HALF_SUM	( A, B : NUM )			return NUM;	-- 1. bloc declare
    function	NESTED		( A : NUM )			return NUM;	-- 2. PRO imbrique + bloc
    procedure	SCALE		( X : in out NUM; K : in NUM );			-- 3. cible d'appel
    function	CALL_IN_BLOCK	( A : NUM )			return NUM;	-- 3. appel depuis un bloc
  end	GEN_PKG;

  package body	GEN_PKG
  is

    function	HALF_SUM	( A, B : NUM )	return NUM
    is
      R		: NUM	:= A;
    begin
      declare
	H	: NUM	:= 0.5;
      begin
	H := H * B;
	R := R * 0.5 + H;
      end;
      return R;
    end	HALF_SUM;

    function	NESTED		( A : NUM )	return NUM
    is

      function	TWICE	( V : NUM )	return NUM
      is
	W	: NUM	:= V;
      begin
	declare
	  Z	: NUM	:= 2.0;
	begin
	  W := W * Z;
	end;
	return W;
      end	TWICE;

    begin
      return TWICE( A );
    end	NESTED;

    procedure	SCALE		( X : in out NUM; K : in NUM )
    is
    begin
      X := X * K;
    end	SCALE;

    function	CALL_IN_BLOCK	( A : NUM )	return NUM
    is
      R		: NUM	:= A;
    begin
      declare
	K	: NUM	:= 3.0;
      begin
	SCALE( R, K );
      end;
      return R;
    end	CALL_IN_BLOCK;

  end	GEN_PKG;

  package LF_PKG is new GEN_PKG( LONG_FLOAT );
  package F_PKG  is new GEN_PKG( FLOAT );

  procedure	CHECK	( OK : BOOLEAN; SECTION, NUMERO : INTEGER )
  is
  begin
    if  OK  then
      NB_OK := NB_OK + 1;
    else
      NB_ECHECS := NB_ECHECS + 1;
      PUT( "* ECHEC section " );	INT_IO.PUT( SECTION, WIDTH => 1 );
      PUT( " test " );			INT_IO.PUT( NUMERO,  WIDTH => 1 );
      NEW_LINE;
    end if;
  end	CHECK;

begin
  PUT_LINE( "=== GENBLK_TEST : GFP depuis bloc declare / PRO imbrique (piege 144) ===" );

  CHECK( LF_PKG.HALF_SUM( 4.0, 6.0 )   = 5.0, 1, 1 );
  CHECK( LF_PKG.NESTED( 1.25 )         = 2.5, 1, 2 );
  CHECK( LF_PKG.CALL_IN_BLOCK( 2.0 )   = 6.0, 1, 3 );

  CHECK( F_PKG.HALF_SUM( 4.0, 6.0 )    = 5.0, 2, 1 );
  CHECK( F_PKG.NESTED( 1.25 )          = 2.5, 2, 2 );
  CHECK( F_PKG.CALL_IN_BLOCK( 2.0 )    = 6.0, 2, 3 );

  PUT( "RESULTAT : " );	INT_IO.PUT( NB_OK, WIDTH => 1 );
  PUT( " OK, " );		INT_IO.PUT( NB_ECHECS, WIDTH => 1 );
  PUT_LINE( " ECHECS" );

  if  NB_ECHECS = 0  then
    PUT_LINE( "GENBLK_TEST PASSE" );
  else
    PUT_LINE( "GENBLK_TEST ECHOUE" );
  end if;

end	GENBLK_TEST;
