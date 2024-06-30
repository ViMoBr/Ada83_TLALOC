with TEXT_IO; use TEXT_IO;

package body CG_LIB is

	procedure HALT (N : INTEGER) is
	begin
		PUT ("halt ");
		PUT (INTEGER'IMAGE (N));
		NEW_LINE;
	end HALT;

	function TRIM (S : STRING) return STRING is
		RESULT : STRING := S;
		I      : INTEGER;
	begin
		while (RESULT'LENGTH > 0) and then (RESULT (RESULT'LAST) <= ' ') loop
			RESULT := RESULT (RESULT'FIRST .. RESULT'LAST - 1);
		end loop;

		I := RESULT'FIRST;
		while (I <= RESULT'LAST) and then (RESULT (I) <= ' ') loop
			I := I + 1;
		end loop;

		return RESULT (I .. RESULT'LAST);
	end TRIM;

	procedure ERROR (ERRORNUMBER : INTEGER) is
	begin
		PUT ("Error ");
		PUT (INTEGER'IMAGE (ERRORNUMBER));
		PUT (" - ");

		if ERRORNUMBER < 1000 then
			case ERRORNUMBER is
				when 2   => PUT_LINE ("Filename not defined");
				when 3   => PUT_LINE ("Node does not exist");
				when 4   => PUT_LINE ("Symbol not defined");
				when 5   => PUT_LINE ("Main node is not compilation");
				when 7   => PUT_LINE ("File does not exist");
				when 8   => PUT_LINE ("Illegal A-code instruction");
				when 9   => PUT_LINE ("Negative level");
				when 10  => PUT_LINE ("Error while opening output file");
				when others => PUT_LINE ("Internal error");
			end case;
			HALT (1);
		elsif ERRORNUMBER > 4000 and ERRORNUMBER < 5000 then
			case ERRORNUMBER is
				when 4001 => PUT_LINE ("Missing compilation node");
				when 4002 => PUT_LINE ("Not a node definition");
				when 4003 => PUT_LINE ("Not a valid node number");
				when 4004 => PUT_LINE ("Invalid kind of node");
				when 4005 => PUT_LINE ("Invalid attribute value");
				when 4006 => PUT_LINE ("Invalid attribute name");
				when 4007 => PUT_LINE ("Not a comp_unit node");
				when 4008 => PUT_LINE ("Bad compilation unit");
				when others => PUT_LINE ("Illegal DIANA format");
			end case;
			HALT (2);
		elsif ERRORNUMBER < 6000 then
			case ERRORNUMBER is
				when 5001 => PUT_LINE ("Too many source files");
				when 5002 => PUT_LINE ("Out of symbol space");
				when 5003 => PUT_LINE ("Too big node number");
				when 5004 => PUT_LINE ("Too big A-code label");
				when 5005 => PUT_LINE ("Too big static level");
				when others => PUT_LINE ("Implementation restrictions");
			end case;
			HALT (3);
		else
			HALT (4);
		end if;
	end ERROR;

end CG_LIB;
