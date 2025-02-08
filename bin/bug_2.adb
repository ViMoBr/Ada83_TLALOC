procedure BUG_2 is

  procedure DEDANS  is
  begin

BLOC_A:
    declare
      i :integer := 0;
    begin
      i:= 1;
    end;

  end DEDANS;

begin
  null;
end BUG_2;	-- ca passe !
