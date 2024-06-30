package CG_LIB is

  MAXLABEL  : constant Integer := 30_000;
  MAXOFFSET : constant Integer := 10_000;
  MAXLEVEL  : constant Integer := 200;

  subtype LABEL_TYPE is Integer range 0 .. MAXLABEL;
  subtype OFFSET_TYPE is Integer range -MAXOFFSET .. MAXOFFSET;
  subtype LEVEL_TYPE is Integer range 0 .. MAXLEVEL;

  procedure HALT (N : Integer);

  function TRIM (S : String) return String;

	procedure ERROR (ERRORNUMBER : Integer);

end CG_LIB;
