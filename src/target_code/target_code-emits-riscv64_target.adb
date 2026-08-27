------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE.EMITS )

					--------------
package body				RISCV64_TARGET
is					--------------

			-------
  function		SIZE_OF		( E :IR.ELT_ID )		return SYMBOLS.VALUE_TYPE
  is			-------
  begin
    FAULT( "hors tranche riscv64 : " & LEX.IMAGE( IR.MNEMO_OF( E ) ) );
    return 0;

  end	SIZE_OF;
	-------


			------
  procedure		ENCODE		( E :IR.ELT_ID )
  is			------
  begin
    FAULT( "hors tranche riscv64 : " & LEX.IMAGE( IR.MNEMO_OF( E ) ) );

  end	ENCODE;
	------


			--------
  procedure		PROLOGUE
  is			--------
  begin
    FAULT( "hors tranche riscv64 : amorcage" );

  end	PROLOGUE;
	--------


	--------------
end	RISCV64_TARGET;
	--------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
