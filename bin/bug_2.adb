procedure BUG_2 is

  procedure DEDANS  is
  begin

BLOC_A:
    begin
      null;
    end PAS_BLOC_A;

  end PAS_DEDANS;

begin
  null;
end PAS_BUG_2;	-- ca passe !
