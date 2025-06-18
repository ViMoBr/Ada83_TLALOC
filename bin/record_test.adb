			-----------
procedure			RECORD_TEST
is			-----------

  vartest : STRING( 1 .. 32 );

  type ENREGISTREMENT	is record
			SH	: INTEGER;
			T1,T2	: STRING( 1 .. 32 );
			T3	: STRING( 1 .. 64 );
			end record;

  ENREG	: ENREGISTREMENT;

begin
null;
  ENREG.T1( 1 ) := 'A';
end	RECORD_TEST;
	-----------
