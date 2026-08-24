------------------------------------------------------------------------------------------------------------------------
--
--	T A R G E T _ C O D E . I R
--
--	Liste sequentielle des elements entre P0 et P3. Chaque element est
--	estampille a sa creation : scope courant (SYMBOLS.CURRENT_SCOPE) et
--	garde lazy courante (condition d'atteignabilite, tranche vide = aucun).
--	Les operandes vivent dans un tableau global partage (economie memoire),
--	adresses par bornes FIRST_OP..LAST_OP de l'element.
--	Liste des DIFFERES (STR/CST) en ordre d'enregistrement ; l'emission en
--	ordre INVERSE (LIFO fasmg, releve DIS_BONJOUR) sera l'affaire de P2/P3.
--	TAILLE et ADRESSE de chaque element : champs poses en P2 (TC-03).
--
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( TARGET_CODE )

					--
package body				IR
is					--

  type ELT_CELL		is record
			  KIND		: ELT_KIND	:= MACRO_CALL;
			  MNEMO		: LEX.SLICE;
			  SCOPE		: SYMBOLS.SCOPE_ID	:= SYMBOLS.ROOT_SCOPE;
			  LAZY		: LEX.SLICE;						--| F=0 : inconditionnel
			  FIRST_OP	: NATURAL		:= 0;
			  LAST_OP		: NATURAL		:= 0;					--| < FIRST_OP : aucun operande
			end record;

  ELTS			: array ( ELT_ID range 1 .. ELT_ID'LAST ) of ELT_CELL;
  LAST_ELT		: ELT_ID	:= 0;

  type OP_CELL		is record
			  TAG		: OPERAND_TAG	:= EMPTY_OP;
			  TXT		: LEX.SLICE;
			  IVAL		: LONG_INTEGER	:= 0;
			  FVAL		: LONG_FLOAT	:= 0.0;
			end record;

  OPS			: array ( 1 .. OPS_MAX ) of OP_CELL;
  LAST_OP_G		: NATURAL	:= 0;

  DEFERS			: array ( 1 .. DEFER_MAX ) of ELT_ID;
  LAST_DEFER		: NATURAL	:= 0;

  CUR_LAZY		: LEX.SLICE;								--| garde lazy courante (posee par LEX)


			-----
  procedure		FAULT		( MSG :STRING )
  is			-----
  begin
    PUT_LINE( "TARGET_CODE.IR : " & MSG );
    raise  IR_FAULT;

  end	FAULT;
	-----

  -------------------------------------------------------------------------------------------------------------------
  --			construction (appels de LEX, dans l'ordre du texte)
  -------------------------------------------------------------------------------------------------------------------

			-------
  procedure		NEW_ELT		( KIND :ELT_KIND; MNEMO :LEX.SLICE )
  is			-------
  begin
    if  LAST_ELT = ELT_ID'LAST  then
      FAULT( "table des elements pleine (ELT_MAX)" );
    end if;

    LAST_ELT := LAST_ELT + 1;
    ELTS( LAST_ELT ).KIND	:= KIND;
    ELTS( LAST_ELT ).MNEMO	:= MNEMO;
    ELTS( LAST_ELT ).SCOPE	:= SYMBOLS.CURRENT_SCOPE;
    ELTS( LAST_ELT ).LAZY	:= CUR_LAZY;
    ELTS( LAST_ELT ).FIRST_OP	:= LAST_OP_G + 1;
    ELTS( LAST_ELT ).LAST_OP	:= LAST_OP_G;								--| aucun operande pour l'instant

  end	NEW_ELT;
	-------


			------
  procedure		ADD_OP		( TAG :OPERAND_TAG; TXT :LEX.SLICE;
					  IVAL :LONG_INTEGER := 0; FVAL :LONG_FLOAT := 0.0 )
  is			------
  begin
    if  LAST_ELT = 0  then
      FAULT( "ADD_OP sans element" );
    end if;
    if  LAST_OP_G = OPS_MAX  then
      FAULT( "table des operandes pleine (OPS_MAX)" );
    end if;

    LAST_OP_G := LAST_OP_G + 1;
    OPS( LAST_OP_G ).TAG	:= TAG;
    OPS( LAST_OP_G ).TXT	:= TXT;
    OPS( LAST_OP_G ).IVAL	:= IVAL;
    OPS( LAST_OP_G ).FVAL	:= FVAL;
    ELTS( LAST_ELT ).LAST_OP	:= LAST_OP_G;

  end	ADD_OP;
	------


			--------
  procedure		SET_LAZY		( GUARD :LEX.SLICE )
  is			--------
  begin
    CUR_LAZY := GUARD;

  end	SET_LAZY;
	--------


			----------
  procedure		CLEAR_LAZY
  is			----------
  begin
    CUR_LAZY.F := 0;
    CUR_LAZY.L := 0;

  end	CLEAR_LAZY;
	----------


			----------
  procedure		DEFER_LAST
  is			----------
  begin
    if  LAST_ELT = 0  then
      FAULT( "DEFER_LAST sans element" );
    end if;

    if  LAST_DEFER = DEFER_MAX  then
      FAULT( "table des differes pleine (DEFER_MAX)" );
    end if;

    LAST_DEFER := LAST_DEFER + 1;
    DEFERS( LAST_DEFER ) := LAST_ELT;

  end	DEFER_LAST;
	----------

  -------------------------------------------------------------------------------------------------------------------
  --			acces (P1, P2, P3, temoins)
  -------------------------------------------------------------------------------------------------------------------

			---------
  function		ELT_COUNT			return NATURAL
  is			---------
  begin
    return  NATURAL( LAST_ELT );

  end	ELT_COUNT;
	---------

			-----------
  function		DEFER_COUNT		return NATURAL
  is			-----------
  begin
    return LAST_DEFER;

  end	DEFER_COUNT;
	-----------


			--------
  function		DEFER_AT		( I :NATURAL )	return ELT_ID
  is
  begin
    if  I = 0  or  I > LAST_DEFER  then
      FAULT( "DEFER_AT hors table" );
    end if;

    return  DEFERS( I );

  end	DEFER_AT;
	--------


			---------
  procedure		CHECK_ELT		( E :ELT_ID )
  is			---------
  begin
    if  E = 0  or  E > LAST_ELT  then
      FAULT( "element hors table" );
    end if;

  end	CHECK_ELT;
	---------


			-------
  function		KIND_OF		( E :ELT_ID )	return ELT_KIND
  is			-------
  begin
    CHECK_ELT( E );
    return  ELTS( E ).KIND;

  end	KIND_OF;
	-------


			--------
  function		MNEMO_OF		( E :ELT_ID )	return LEX.SLICE
  is			--------
  begin
    CHECK_ELT( E );
    return  ELTS( E ).MNEMO;

  end	MNEMO_OF;
	--------


			--------
  function		SCOPE_OF		( E :ELT_ID )	return SYMBOLS.SCOPE_ID
  is			--------
  begin
    CHECK_ELT( E );
    return  ELTS( E ).SCOPE;

  end	SCOPE_OF;
	--------


			-------
  function		LAZY_OF		( E :ELT_ID )	return LEX.SLICE
  is			-------
  begin
    CHECK_ELT( E );
    return  ELTS( E ).LAZY;

  end	LAZY_OF;
	-------


			-----
  function		N_OPS		( E :ELT_ID )	return NATURAL
  is			-----
  begin
    CHECK_ELT( E );
    if  ELTS( E ).LAST_OP < ELTS( E ).FIRST_OP  then
      return 0;
    end if;
    return  ELTS( E ).LAST_OP - ELTS( E ).FIRST_OP + 1;

  end	N_OPS;
	-----


			--------
  function		OP_INDEX		( E :ELT_ID; I :NATURAL )	return NATURAL
  is			--------
  begin
    if  I = 0  or  I > N_OPS( E )  then
      FAULT( "operande hors bornes" );
    end if;
    return  ELTS( E ).FIRST_OP + I - 1;

  end	OP_INDEX;
	--------


			------
  function		OP_TAG ( E :ELT_ID; I :NATURAL ) return OPERAND_TAG
  is			------
  begin
    return  OPS( OP_INDEX( E, I ) ).TAG;

  end	OP_TAG;
	------


			------
  function		OP_TXT	( E :ELT_ID; I :NATURAL )	return LEX.SLICE
  is			------
  begin
    return  OPS( OP_INDEX( E, I ) ).TXT;

  end	OP_TXT;
	------


			------
  function		OP_INT	( E :ELT_ID; I :NATURAL )	return LONG_INTEGER
  is			------
  begin
    return  OPS( OP_INDEX( E, I ) ).IVAL;

  end	OP_INT;
	------


			------
  function		OP_FLT	( E :ELT_ID; I :NATURAL )	return LONG_FLOAT
  is			------
  begin
    return  OPS( OP_INDEX( E, I ) ).FVAL;

  end	OP_FLT;
	------


	--
end	IR;
	--

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
