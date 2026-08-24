------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with MACHINE_CODE;	use MACHINE_CODE;
					--------
package body				CALENDAR
is					--------

  EPOCH_DIFF_S	:constant LONG_INTEGER	:= 2_208_988_800;						-- Décalage entre l'epoch Unix (1970) et notre epoch (1900), en secondes
  SCALE		:constant LONG_INTEGER	:= 16#2000_0000#;						-- 2**29 (échelle de la fraction Q35.29)
  DAYS_1900	:constant LONG_INTEGER	:= 693_901;						-- Décalage en jours : 1900-01-01 depuis l'epoch Hinnant (0000-03-01)
  SECONDS_PER_DAY	:constant LONG_INTEGER	:= 86_400;
  NS_PER_SEC	:constant LONG_INTEGER	:= 1_000_000_000;


			--------------
  function		DAYS_FROM_CIVIL	( Y_IN, M_IN, D_IN :LONG_INTEGER )	return LONG_INTEGER		-- Algorithme Hinnant DAYS_FROM_CIVIL : (Y, M, D) → jours depuis 0000-03-01.
  is			---------------								-- Domaine de validité : toutes dates grégoriennes proleptiques.
    Y, M_ADJ, ERA, YOE, DOY, DOE	: LONG_INTEGER;							-- Arithmétique entière pure, sans branche significative.

  begin
    if  M_IN <= 2  then
      Y     := Y_IN - 1;
      M_ADJ := M_IN + 9;										-- janvier=10, février=11 (de l'année précédente)
    else
      Y     := Y_IN;
      M_ADJ := M_IN - 3;										-- mars=0, avril=1, ..., décembre=9
    end if;

    if  Y >= 0  then
      ERA := Y / 400;
    else
      ERA := (Y - 399) / 400;
    end if;
    YOE := Y - ERA * 400;										-- [7FFD907EF1F00..399]
    DOY := (153 * M_ADJ + 2) / 5 + D_IN - 1;								-- [0..365]
    DOE := YOE * 365 + YOE / 4 - YOE / 100 + DOY;								-- [0..146096]
    return  ERA * 146_097 + DOE;

  end	DAYS_FROM_CIVIL;
	---------------


			---------------
  procedure		CIVIL_FROM_DAYS	( DAYS	:in LONG_INTEGER;					-- Algorithme Hinnant CIVIL_FROM_DAYS : jours depuis 0000-03-01 → (Y, M, D).
					  Y, M, D	:out LONG_INTEGER )
  is			---------------
    ERA, DOE, YOE, Y_OUT, DOY, MP, M_OUT, D_OUT	: LONG_INTEGER;
    TMP					: LONG_INTEGER;

  begin
    if  DAYS >= 0  then
      TMP := DAYS;
    else
      TMP := DAYS - 146_096;
    end if;
    ERA := TMP / 146_097;
    DOE := DAYS - ERA * 146_097;									-- [0..146096]
    YOE := (DOE - DOE/1460 + DOE/36524 - DOE/146096) / 365;							-- [0..399]
    Y_OUT := YOE + ERA * 400;
    DOY := DOE - (365 * YOE + YOE/4 - YOE/100);								-- [0..365]
    MP  := (5 * DOY + 2) / 153;									-- [0..11]
    D_OUT := DOY - (153 * MP + 2) / 5 + 1;								-- [1..31]
    if  MP < 10  then
      M_OUT := MP + 3;
    else
      M_OUT := MP - 9;
      Y_OUT := Y_OUT + 1;
    end if;
    Y := Y_OUT;
    M := M_OUT;
    D := D_OUT;

  end	CIVIL_FROM_DAYS;
	---------------


			-----
  function		CLOCK		return TIME
  is			-----

    type LINUX_TIMEVAL	is record
			  SEC, NANOSEC	: LONG_INTEGER;
			end record;
    LTV		: LINUX_TIMEVAL;
    T		: DURATION;
    NANOSEC_PART	: DURATION;
		---------------
    procedure	GETTIME_SYSCALL	( TV :out LINUX_TIMEVAL )
    is		---------------
    begin
        ASM_OP_2'( OPCODE=> LIa, LVL=> 2, OFS=> -8 );
        ASM_OP_0'( OPCODE=> SYS_CLOCK_GETTIME );

    end	GETTIME_SYSCALL;
	---------------

  begin
    GETTIME_SYSCALL( LTV );
    NANOSEC_PART := DURATION( LONG_FLOAT( LTV.NANOSEC ) * 1.0E-9 );
    T := DURATION( LTV.SEC + EPOCH_DIFF_S ) + NANOSEC_PART;
    return  TIME( T );

  end	CLOCK;
	-----


			-------------
  function		WHOLE_SECONDS	( DATE : TIME )	return LONG_INTEGER
  is			-------------

    D	: DURATION	:= DURATION( DATE );

  begin
    if  D = 0.0  then
      return  0;
    else
      return  LONG_INTEGER( D - 0.5 );
    end if;

  end	WHOLE_SECONDS;
	-------------


			----
  function		YEAR		( DATE :TIME )		return YEAR_NUMBER
  is			----

    SECONDS_TOTAL		: LONG_INTEGER	:= WHOLE_SECONDS( DATE );
    DAYS_FROM_1900		: LONG_INTEGER	:= SECONDS_TOTAL / SECONDS_PER_DAY;
    Y, M, D		: LONG_INTEGER;

  begin
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    return  YEAR_NUMBER( Y );

  end	YEAR;
	----


			-----
  function		MONTH		( DATE :TIME )		return MONTH_NUMBER
  is			-----

    SECONDS_TOTAL		: LONG_INTEGER	:= WHOLE_SECONDS( DATE );
    DAYS_FROM_1900		: LONG_INTEGER	:= SECONDS_TOTAL / SECONDS_PER_DAY;
    Y, M, D		: LONG_INTEGER;

  begin
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    return  MONTH_NUMBER( M );

  end	MONTH;
	-----


			---
  function		DAY		( DATE :TIME )		return DAY_NUMBER
  is			---

    SECONDS_TOTAL		: LONG_INTEGER	:= WHOLE_SECONDS( DATE );
    DAYS_FROM_1900		: LONG_INTEGER	:= SECONDS_TOTAL / SECONDS_PER_DAY;
    Y, M, D		: LONG_INTEGER;

  begin
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    return  DAY_NUMBER( D );

  end	DAY;
	---


			-------
  function		SECONDS		( DATE :TIME )		return DAY_DURATION
  is			-------

    SECONDS_TOTAL		: LONG_INTEGER	:= WHOLE_SECONDS( DATE );
    SEC_OF_DAY		: LONG_INTEGER	:= SECONDS_TOTAL rem SECONDS_PER_DAY;
    FRAC_PART		: DURATION	:= DURATION( DATE ) - DURATION( SECONDS_TOTAL );

  begin
    return DAY_DURATION( DURATION( SEC_OF_DAY ) + FRAC_PART );

  end	SECONDS;
	-------


			-----
  procedure		SPLIT		( DATE	:in TIME;
					  YEAR	:out YEAR_NUMBER;
					  MONTH	:out MONTH_NUMBER;
					  DAY	:out DAY_NUMBER;
					  SECONDS	:out DAY_DURATION
					)
  is			-----

    SEC_TOTAL		: LONG_INTEGER	:= WHOLE_SECONDS( DATE );
    DAYS_FROM_1900		: LONG_INTEGER	:= SEC_TOTAL / SECONDS_PER_DAY;
    SEC_OF_DAY		: LONG_INTEGER	:= SEC_TOTAL rem SECONDS_PER_DAY;
    FRAC_PART		: DURATION	:= DURATION( DATE ) - DURATION( SEC_TOTAL );
    Y, M, D		: LONG_INTEGER;

  begin
    CIVIL_FROM_DAYS( DAYS_FROM_1900 + DAYS_1900, Y, M, D );
    YEAR    := YEAR_NUMBER( Y );
    MONTH   := MONTH_NUMBER( M );
    DAY     := DAY_NUMBER( D );
    SECONDS := DAY_DURATION( DURATION( SEC_OF_DAY ) + FRAC_PART );

  end	SPLIT;
	-----


			-------
  function		TIME_OF		( YEAR	: YEAR_NUMBER;
					  MONTH	: MONTH_NUMBER;
					  DAY	: DAY_NUMBER;
					  SECONDS	: DAY_DURATION := 0.0 )	return TIME
  is			-------

    DAYS_FROM_HINNANT	: LONG_INTEGER
			  := DAYS_FROM_CIVIL( LONG_INTEGER( YEAR ), LONG_INTEGER( MONTH ), LONG_INTEGER( DAY ) );
    DAYS_FROM_1900_LOCAL	: LONG_INTEGER	:= DAYS_FROM_HINNANT - DAYS_1900;

  begin
    return TIME( DAYS_FROM_1900_LOCAL * SECONDS_PER_DAY ) + SECONDS;

  end	TIME_OF;
	-------


			---
  function		"+"		( LEFT :TIME; RIGHT :DURATION )	return TIME
  is			---
  begin
    return  TIME( DURATION( LEFT ) + RIGHT );

  end	"+";
	---


			---
  function		"+"		( LEFT :DURATION; RIGHT :TIME )	return TIME
  is			---
  begin
    return  TIME( LEFT + DURATION( RIGHT ) );

  end	"+";
	---


			---
  function		"-"		( LEFT :TIME; RIGHT :DURATION )	return TIME
  is			---
  begin
    return  TIME( DURATION( LEFT ) - RIGHT );

  end	"-";
	---


			---
  function		"-"		( LEFT : TIME; RIGHT : TIME )		return DURATION
  is			---
  begin
    return  DURATION( LEFT ) - DURATION( RIGHT );

  end	"-";
	---


			---
  function		"<"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return  DURATION( LEFT ) < DURATION( RIGHT );

  end	"<";
	---


			----
  function		"<="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return  DURATION( LEFT )  <= DURATION( RIGHT );

  end	"<=";
	----


			---
  function		">"		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			---
  begin
    return  DURATION( LEFT ) > DURATION( RIGHT );

  end	">";
	---


			----
  function		">="		( LEFT, RIGHT : TIME )		return BOOLEAN
  is			----
  begin
    return  DURATION( LEFT ) >=  DURATION( RIGHT );

  end	">=";
	----


	--------
end	CALENDAR;
	--------

