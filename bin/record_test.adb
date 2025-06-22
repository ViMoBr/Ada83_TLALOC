			-----------
procedure			RECORD_TEST
is			-----------

  subtype SBT is string( 1 .. 10 );

package DEFINITIONS is

--  type STR is new STRING( 1 ..32 );
--  type ARR is array( 1 ..64 ) of NATURAL;

--  type REC1		is record
--			FINAL	: INTEGER;
--			end record;

  type ENREGISTREMENT	is record
			SH	: INTEGER;
--			R1	: REC1;
			T3	: STRING( 1 .. 64 );
			end record;

--  ENREG	: ENREGISTREMENT;
--  CH	: CHARACTER;

end DEFINITIONS;

  ENREG1 : DEFINITIONS.ENREGISTREMENT;

begin
null;
--  ENREG1.R1.FINAL := 3;
--  DEFINITIONS.ENREG.SH := 2;
--  DEFINITIONS.ENREG.T1( 1 ) := 'A';
--  DEFINITIONS.CH := DEFINITIONS.ENREG.T1( 1 );

end	RECORD_TEST;
	-----------
