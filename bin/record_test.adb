			-----------
procedure			RECORD_TEST
is			-----------

package definitions is

  type SHORT	is range -32_768 .. 32_767;

  type REC	is record
		  I1, I2 : SHORT;
		end record;
  for REC use record at mod 8;
		I1 at 0 range 0 .. 15;
		I2 at 3 range 7 .. 22;
		end record;

  type TAB	is array( INTEGER range <> ) of SHORT;

  type ENREGISTREMENT ( LEN :INTEGER )	is record
			SH	: SHORT;
			R1	: REC;
			T1	: TAB( 1 .. LEN );
			end record;

end definitions;
use definitions;

  ENREG	: ENREGISTREMENT( 10 );
--  for ENREG use at 16#45000#;
  KI	: SHORT;

begin
--  KI := ENREG.R1.I1;
  ENREG.R1.I1 := KI;
end	RECORD_TEST;
	-----------
