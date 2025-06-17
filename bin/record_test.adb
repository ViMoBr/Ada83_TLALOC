			-----------
procedure			RECORD_TEST
is			-----------

--package definitions is
  type ENUM	is ( ENU1, ENU2, ENU3 );

  type SHORT	is range -32_768 .. 32_767;
  subtype BUFFER	is STRING( 1 .. 16 );

  type UARR	is array ( INTEGER range <> ) of INTEGER;
  type MAT	is array ( 1..16, 1..32 ) of INTEGER;

  type REC	is record
		  I1	: INTEGER;
		  LONG	: SHORT;
		  NOM	: BUFFER;
		end record;

--  for REC use record at mod 8;
--		I1 at 0 range 0 .. 15;
--		I2 at 3 range 7 .. 22;
--		end record;

--  type TAB	is array( INTEGER range <> ) of SHORT;

--  type ENREGISTREMENT ( LEN :INTEGER )	is record
--			SH	: SHORT;
--			R1	: REC;
--			T1	: TAB( 1 .. LEN );
--			end record;

--end definitions;
--use definitions;

--  ENREG	: ENREGISTREMENT( 10 );
--  for ENREG use at 16#45000#;

  ENREG	: REC;
  M	: MAT;
  KI	: SHORT;
  C	: CHARACTER;

begin
null;
--  KI := ENREG.LONG;
--  C := ENREG.NOM( 1 );
--  ENREG.R1.I1 := KI;
end	RECORD_TEST;
	-----------
