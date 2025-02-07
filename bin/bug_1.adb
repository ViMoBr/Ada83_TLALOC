procedure BUG_1 is

  type DIALOG_RECORD;
  type ACC is access DIALOG_RECORD;
  type ACC2 is access ACC;

  type DIALOG_RECORD		is record
				  TEXT_H		: ACC2;
				  EDIT_FIELD	: NATURAL;
				end record;

  D	: DIALOG_RECORD;
begin
  if (D.TEXT_H /= null) then --and then (D.EDIT_FIELD /= 0) then
    null;
  end if;
end	BUG_1;
