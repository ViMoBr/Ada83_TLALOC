			-----------
procedure			RECORD_TEST
is			-----------

package definitions is
  type BYTE	is range -128 .. 127;
  type SHORT	is range -32_768 .. 32_767;

  type REC_1	is record
		  I1, I2 : SHORT;
		end record;

  type ENREGISTREMENT ( DISCR :INTEGER )	is record
			SH	: SHORT;
			R1	: REC_1;
			INT	: INTEGER;
			B	: BYTE;
			end record;

end definitions;
use definitions;

  ENREG	: ENREGISTREMENT;
--  for ENREG use at 16#45000#;
  KI	: SHORT;

begin
  KI := ENREG.R1.I1;
end	RECORD_TEST;
	-----------
