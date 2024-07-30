with TEXT_IO, CG_LIB;
use TEXT_IO, CG_LIB;

package body CG_PRIVATE is

	type CHAR_ARRAY is array (1 .. 65535) of CHARACTER;

	FILENAMES             : array (1 .. MAXFILENR) of FILENAMETYPE;
	NUMBEROFFILENAMES     : INTEGER := 0;
	SYMBOLSBUFFER         : CHAR_ARRAY;
	SYMBOLSBUFFERFILLPTR  : INTEGER := 1;

	procedure CONDITIONALERROR (ERRORNUMBER : INTEGER; ERRORCONDITION : BOOLEAN) is
	begin
		if ERRORCONDITION then
			ERROR (ERRORNUMBER);
		end if;
	end CONDITIONALERROR;

	function SEARCH (BUFFER : in CHAR_ARRAY; BUFLENGTH : INTEGER;
									MATCH  : in STRING; MATLENGTH : INTEGER) return INTEGER is
		NOTFOUNDFLAG : constant INTEGER := -1;
		FIRSTCH      : CHARACTER;
		OK           : BOOLEAN;
	begin
		if (MATLENGTH <= BUFLENGTH) and (MATLENGTH > 0) then
			FIRSTCH := MATCH (MATCH'FIRST);
			for I in 1 .. BUFLENGTH - MATLENGTH + 1 loop
				if BUFFER (I) = FIRSTCH then
					OK := TRUE;
					for J in 2 .. MATLENGTH loop
						OK := OK and then (BUFFER (I + J - 1) = MATCH (J));
						exit when not OK;
					end loop;
					if OK then
						return I - 1;
					end if;
				end if;
			end loop;
		end if;
		return NOTFOUNDFLAG;
	end SEARCH;

	function FILENAMENUMBER (NAME : FILENAMETYPE) return FILENRTYPE is
		N : INTEGER := 1;
	begin
		CONDITIONALERROR (5001, NUMBEROFFILENAMES >= MAXFILENR);
		while N <= NUMBEROFFILENAMES loop
			if NAME = FILENAMES (N) then
				return N;
			end if;
			N := N + 1;
		end loop;
		FILENAMES (N) := NAME;
		NUMBEROFFILENAMES := N;
		return N;
	end FILENAMENUMBER;

	function FILENAME (NR : FILENRTYPE) return FILENAMETYPE is
	begin
		CONDITIONALERROR (2, NR > NUMBEROFFILENAMES);
		return FILENAMES (NR);
	end FILENAME;

	function PUTSYMBOL (S : STRING) return SYMBOL_REP is
		I  : INTEGER;
		SA	 : constant STRING	:= ' ' & TRIM (S) & ' ';
	begin
		CONDITIONALERROR (5002, SYMBOLSBUFFERFILLPTR > SYMBOLSBUFFERLEN - SA'LENGTH);
		I := SEARCH (SYMBOLSBUFFER, SYMBOLSBUFFERFILLPTR, SA, SA'LENGTH);
		if I = -1 then
			for J in 2 .. S'LENGTH - 1 loop
				SYMBOLSBUFFER (SYMBOLSBUFFERFILLPTR + J - 1) := SA (J);
			end loop;
			SYMBOLSBUFFERFILLPTR := SYMBOLSBUFFERFILLPTR + SA'LENGTH - 1;
			return SYMBOLSBUFFERFILLPTR;
		else
			return I + 2;
		end if;
	end PUTSYMBOL;

	function GETSYMBOL (SYM : SYMBOL_REP) return STRING is
		I : INTEGER := SYM;
		J : INTEGER := 0;
		S : STRING (1 .. SYMBOLSBUFFERLEN);
	begin
		CONDITIONALERROR (4, I > SYMBOLSBUFFERFILLPTR);
		while SYMBOLSBUFFER (I) /= ' ' loop
			J := J + 1;
			S (J) := SYMBOLSBUFFER (I);
			I := I + 1;
		end loop;
		return S (1 .. J);
	end GETSYMBOL;

begin
	SYMBOLSBUFFER (1) := ' ';
end CG_PRIVATE;
