with TEXT_IO;
use  TEXT_IO;
			---------
procedure			FILE_TEST
is			---------
  F	: TEXT_IO.FILE_TYPE;
  NOM	:constant STRING	:= "./essai.txt";
begin
  CREATE( F, OUT_FILE, NOM );
end	FILE_TEST;
	---------
