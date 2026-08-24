------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate ( EXPANDER )
				-----------------
package body			REPRESENTED_ITEMS
				-----------------
is

  function  FIND_COMP_REP_ELEM_FROM_COMPONENT ( COMP_ID :TREE ) return TREE;

			--------------------
  function		STATIC_INTEGER_VALUE	( EXP :TREE )	return INTEGER
  is			--------------------
  begin
    -- Premier périmètre volontairement restreint :
    -- les positions de représentation doivent être statiques.
    --
    -- Dans les clauses :
    --   C at <exp> range <lo> .. <hi>
    -- <exp>, <lo>, <hi> arrivent normalement comme numeric_literal
    -- ou comme expression déjà évaluée avec SM_VALUE entier.

    if  EXP.TY = DN_NUMERIC_LITERAL  or else  EXP.TY in CLASS_EXP  then
      return DI( SM_VALUE, EXP );

    else
      PUT_LINE( "; REPRESENTED_ITEMS.STATIC_INTEGER_VALUE : EXP.TY inattendu " & NODE_NAME'IMAGE( EXP.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	STATIC_INTEGER_VALUE;
	--------------------


			------------------------
  function		REPRESENTATION_SIZE_BITS	( TYPE_SPEC :TREE ) return INTEGER
  is			------------------------
  begin
      return  DI( SM_SIZE, TYPE_SPEC );

  end	REPRESENTATION_SIZE_BITS;
	------------------------


			-----------------
  procedure		GET_COMP_REP_ELEM	( REP_ELEM :TREE; COMP_ID :out TREE;
					  BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH :out INTEGER )
  is			-----------------
    RNG		: TREE		:= D( AS_RANGE, REP_ELEM );
    EXP_FIRST	: TREE		:= D( AS_EXP1, RNG );
    EXP_LAST	: TREE		:= D( AS_EXP2, RNG );
    BIT_DEPART	: INTEGER		:= STATIC_INTEGER_VALUE( EXP_FIRST );
    BIT_FIN	: INTEGER		:= STATIC_INTEGER_VALUE( EXP_LAST );

  begin
    COMP_ID := D( SM_DEFN, D( AS_NAME, REP_ELEM ) );
    BYTE_OFFSET := STATIC_INTEGER_VALUE( D( AS_EXP, REP_ELEM ) );
    FIRST_BIT := BIT_DEPART;
    LAST_BIT := BIT_FIN;
    WIDTH := BIT_FIN - BIT_DEPART + 1;

  end	GET_COMP_REP_ELEM;
	-----------------


			--------------------
  function		REP_RECORD_USED_BITS	( TYPE_SPEC :TREE )		return INTEGER
  is			--------------------
    REP			: TREE		:= D( SM_REPRESENTATION, TYPE_SPEC );
    REP_S			: SEQ_TYPE	:= LIST( D( AS_COMP_REP_S, REP ) );
    REP_ELEM		: TREE;
    MAX_BIT		: INTEGER		:= 0;

  begin
    while  not IS_EMPTY( REP_S )  loop
      POP( REP_S, REP_ELEM );

      if  REP_ELEM.TY = DN_COMP_REP  then
        declare
	BYTE_OFFSET	: INTEGER		:= STATIC_INTEGER_VALUE( D( AS_EXP, REP_ELEM ) );
	RNG		: TREE		:= D( AS_RANGE, REP_ELEM );
	LAST_BIT		: INTEGER		:= STATIC_INTEGER_VALUE( D( AS_EXP2, RNG ) );
	END_BIT		: INTEGER		:= BYTE_OFFSET * CODI.STORAGE_UNIT + LAST_BIT + 1;
        begin
	if  END_BIT > MAX_BIT  then  MAX_BIT := END_BIT;  end if;
        end;
      end if;
    end loop;

    return MAX_BIT;

  end	REP_RECORD_USED_BITS;
	--------------------


			----------------------------
  function		REPRESENTED_RECORD_SIZE_BITS		( TYPE_SPEC :TREE )		return INTEGER
  is			----------------------------

    TS		: TREE		:= TYPE_SPEC;
    SIZE_BITS	: INTEGER		:= 0;
    USED_BITS	: INTEGER		:= 0;

  begin
    if  TS.TY = DN_PRIVATE  or else  TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    begin
      SIZE_BITS := DI( SM_SIZE, TS );									-- 1. Source prioritaire : clause "for T'SIZE use N".
    exception
      when others =>
        SIZE_BITS := 0;
    end;

    if  SIZE_BITS > 0  then
      return  SIZE_BITS;
    end if;

    USED_BITS := REP_RECORD_USED_BITS( TS );								-- 2. Calcul minimal à partir des comp_rep.
    if  USED_BITS > 0  then
      return  USED_BITS;
    end if;

    -- 3. Dernier recours : CD_IMPL_SIZE si déjà posé.
    begin
      SIZE_BITS := DI( CD_IMPL_SIZE, TS );
    exception
      when others =>  SIZE_BITS := 0;
    end;
    --| DEFAUT DOCUMENTE (vague 2, triage 28/07) : le 0 final est une
    --| sentinelle ATTRAPEE par tous les appelants, verifies le 28/07 :
    --| IS_SMALL_REP_RECORD (0 -> FALSE), CODE_REPRESENTED_RECORD_AGGREGATE
    --| et CODE_STORE_REP_COMPONENT (<= 0 -> raise), STATIC_RECORD_SIZE_BITS
    --| (0 -> sentinelle non-statique de STATIC_TYPE_SIZE_BITS).  Tout
    --| NOUVEL appelant doit tester <= 0 -- sinon lever ici a la place.

    return SIZE_BITS;

  end	REPRESENTED_RECORD_SIZE_BITS;
	----------------------------



			--------------
  function		HAS_RECORD_REP		( TYPE_SPEC :TREE )		return BOOLEAN
  is			--------------

    TS	: TREE	:= TYPE_SPEC;

  begin
    if  TS.TY = DN_PRIVATE  or else  TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    if  TS.TY /= DN_RECORD  then
      return  FALSE;
    end if;

    return  D( SM_REPRESENTATION, TS ) /= TREE_VOID;

  end	HAS_RECORD_REP;
	--------------


			-----------------
  function		HAS_COMPONENT_REP		( COMP_ID :TREE )		return BOOLEAN
  is			-----------------
    REP	: TREE;

  begin
    if not ( COMP_ID.TY = DN_COMPONENT_ID  or else  COMP_ID.TY = DN_DISCRIMINANT_ID )  then
      return FALSE;
    end if;

    REP := D( SM_COMP_REP, COMP_ID );

    if REP /= TREE_VOID  and then  REP.TY = DN_COMP_REP then
      return TRUE;
    end if;

    return  FIND_COMP_REP_ELEM_FROM_COMPONENT( COMP_ID ) /= TREE_VOID;

  end	HAS_COMPONENT_REP;
	-----------------


			-----------------
  procedure		GET_COMPONENT_REP		( COMP_ID :TREE; BYTE_OFFSET :out INTEGER;
						  FIRST_BIT, LAST_BIT, WIDTH :out INTEGER )
  is			-----------------
    REP		: TREE;
    DUMMY_ID	: TREE;
  begin
    if  not HAS_COMPONENT_REP( COMP_ID )  then
      PUT_LINE( "; REPRESENTED_ITEMS.GET_COMPONENT_REP : composant sans SM_COMP_REP "
	      & NODE_NAME'IMAGE( COMP_ID.TY ) );
      raise PROGRAM_ERROR;
    end if;

    REP := D( SM_COMP_REP, COMP_ID );

    if  REP = TREE_VOID  or else  REP = TREE_NIL  or else  REP.TY /= DN_COMP_REP  then
      REP := FIND_COMP_REP_ELEM_FROM_COMPONENT( COMP_ID );  -- copie derivee : via la clause partagee
    end if;

    GET_COMP_REP_ELEM( REP, DUMMY_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );

  end	GET_COMPONENT_REP;
	-----------------


			-------------------
  function		IS_SMALL_REP_RECORD		( TYPE_SPEC :TREE )		return BOOLEAN
  is			-------------------

    TS		: TREE		:= TYPE_SPEC;
    REP		: TREE;
    REP_S		: SEQ_TYPE;
    REP_ELEM	: TREE;
    SIZE_BITS	: NATURAL;

  begin
    if  not HAS_RECORD_REP( TS )  then
      return  FALSE;
    end if;

    if  TS.TY = DN_PRIVATE  or else  TS.TY = DN_L_PRIVATE  then
      TS := D( SM_TYPE_SPEC, TS );
    elsif  TS.TY = DN_INCOMPLETE  then
      TS := D( XD_FULL_TYPE_SPEC, TS );
    end if;

    SIZE_BITS := REPRESENTED_RECORD_SIZE_BITS( TS );

    if  SIZE_BITS <= 0  or else  SIZE_BITS > 64  then
      return  FALSE;
    end if;

    -- Premier périmètre : modèle TREE-like.
    -- Tous les champs doivent être dans le même contenant logique
    -- commençant à byte_offset 0.
    REP	:= D( SM_REPRESENTATION, TS );
    REP_S := LIST( D( AS_COMP_REP_S, REP ) );

    while  not IS_EMPTY( REP_S )  loop
      POP( REP_S, REP_ELEM );

      if  REP_ELEM.TY = DN_COMP_REP  then
        declare
	COMP_ID		: TREE;
	BYTE_OFFSET	: NATURAL;
	FIRST_BIT, LAST_BIT : NATURAL;
	WIDTH		: NATURAL;
	END_BIT		: NATURAL;
        begin
	GET_COMP_REP_ELEM( REP_ELEM, COMP_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );
	END_BIT := BYTE_OFFSET * CODI.STORAGE_UNIT + LAST_BIT + 1;

	if  LAST_BIT < FIRST_BIT  or else  WIDTH <= 0  or else  WIDTH > 64  or else  END_BIT > SIZE_BITS  then
	  return  FALSE;
	end if;
        end;
      end if;
    end loop;

    return  TRUE;

  end	IS_SMALL_REP_RECORD;
	-------------------


			----------------------------
  procedure		CODE_REPRESENTED_RECORD_DECL		( TYPE_ID :TREE; TYPE_SPEC :TREE )
  is			----------------------------

    TYPE_ID_STR	:constant STRING	:= '_' & PRINT_NAME( D( LX_SYMREP, TYPE_ID ) );
    LVL_STR	:constant STRING	:= IMAGE( CODI.CUR_LEVEL );
    SIZE_BITS	: INTEGER;

  begin
    if  not HAS_RECORD_REP( TYPE_SPEC )  then
      PUT_LINE( "; REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_DECL : record sans representation "
	      & TYPE_ID_STR );
      raise  PROGRAM_ERROR;
    end if;

    if  not IS_SMALL_REP_RECORD( TYPE_SPEC )  then
      PUT_LINE( "; REPRESENTED_ITEMS.CODE_REPRESENTED_RECORD_DECL : representation trop generale "
	      & TYPE_ID_STR );
      raise  PROGRAM_ERROR;
    end if;

    SIZE_BITS := REPRESENTATION_SIZE_BITS( TYPE_SPEC );
    DI( CD_LEVEL, TYPE_SPEC, INTEGER( CODI.CUR_LEVEL ) );
    DI( CD_IMPL_SIZE, TYPE_SPEC, SIZE_BITS );
    DB( CD_COMPILED, TYPE_SPEC, TRUE );

    if  CODI.DEBUG  then
      NEW_LINE;
      PUT_LINE( CODI.TAB50 & "; " & TYPE_ID_STR & " REPRESENTED RECORD TYPE INFO" );
    end if;

    PUT_LINE( TYPE_ID_STR & " = '" & TYPE_ID_STR & "'" );
    PUT_LINE( "namespace " & TYPE_ID_STR );

    -- Patron minimal compatible avec les records ordinaires :
    -- SIZ reste exprimé en bits, comme les autres patrons de type.
    PUT_LINE( "VAR use__info, Q" );
    PUT_LINE( "VAR SIZ__, D" );
    PUT_LINE( tab & "LVA" & CODI.tab & LVL_STR & ", SIZ__" );
    PUT_LINE( tab & "SA"  & CODI.tab & LVL_STR & ", use__info" );

    PUT_LINE( tab & "LI" & CODI.tab & IMAGE( SIZE_BITS ) );
    PUT_LINE( tab & "SD" & CODI.tab & LVL_STR & ", SIZ__" );

    declare
      SIZE_BYTES : INTEGER;
    begin
      SIZE_BYTES := ( SIZE_BITS + CODI.STORAGE_UNIT - 1 ) / CODI.STORAGE_UNIT;
      PUT_LINE( "size = " & IMAGE( SIZE_BYTES ) );
    end;

    if  CODI.DEBUG  then
      declare
        REP		: TREE		:= D( SM_REPRESENTATION, TYPE_SPEC );
        REP_S		: SEQ_TYPE	:= LIST( D( AS_COMP_REP_S, REP ) );
        REP_ELEM		: TREE;
      begin
        while  not IS_EMPTY( REP_S )  loop
	POP( REP_S, REP_ELEM );

	if  REP_ELEM.TY = DN_COMP_REP  then
	  declare
	    COMP_ID	: TREE;
	    BYTE_OFFSET	: INTEGER;
	    FIRST_BIT	: INTEGER;
	    LAST_BIT	: INTEGER;
	    WIDTH		: INTEGER;
	  begin
	    GET_COMP_REP_ELEM( REP_ELEM, COMP_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );
	    PUT_LINE( ";   " & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) & " at" & INTEGER'IMAGE( BYTE_OFFSET )
		    & " range" & INTEGER'IMAGE( FIRST_BIT ) & " .." & INTEGER'IMAGE( LAST_BIT )
		    & " width" & INTEGER'IMAGE( WIDTH ) );
	  end;
	end if;
        end loop;
      end;
    end if;

    PUT_LINE( "end namespace" );

  end	CODE_REPRESENTED_RECORD_DECL;
	----------------------------


			---------------------------------
  procedure		CODE_REPRESENTED_RECORD_AGGREGATE	( AGGREGATE :TREE; TYPE_SPEC :TREE )
  is			---------------------------------

    REP		: TREE		:= D( SM_REPRESENTATION, TYPE_SPEC );
    SIZE_BITS	: INTEGER		:= REPRESENTED_RECORD_SIZE_BITS( TYPE_SPEC );

		------------------
    function	FIND_COMP_REP_ELEM		( COMP_ID :TREE )	return TREE
    is		------------------
      REP_S		: SEQ_TYPE	:= LIST( D( AS_COMP_REP_S, REP ) );
      REP_ELEM		: TREE;
      DEFN		: TREE;

    begin
      while  not IS_EMPTY( REP_S )  loop
        POP( REP_S, REP_ELEM );

        if  REP_ELEM.TY = DN_COMP_REP  then
	DEFN := D( SM_DEFN, D( AS_NAME, REP_ELEM ) );

	if  DEFN = COMP_ID  then
	  return  REP_ELEM;
	end if;
        end if;
      end loop;

      return  TREE_VOID;

    end	FIND_COMP_REP_ELEM;
	------------------

		-----------------
    procedure	EMIT_PACKED_FIELD	( COMP_ID :TREE; COMP_EXP :TREE )
    is		-----------------

      REP_ELEM		: TREE;
      DUMMY_ID		: TREE;
      BYTE_OFFSET		: NATURAL;
      FIRST_BIT, LAST_BIT	: NATURAL;
      WIDTH		: NATURAL;

    begin
      REP_ELEM := FIND_COMP_REP_ELEM( COMP_ID );

      if  REP_ELEM = TREE_VOID  or else  REP_ELEM = TREE_NIL  then
        PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : composant sans comp_rep "
	& PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
        raise  PROGRAM_ERROR;
      end if;

      GET_COMP_REP_ELEM( REP_ELEM, DUMMY_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );

      if BYTE_OFFSET /= 0 then
        PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : byte_offset non nul non gere pour "
	& PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
        raise  PROGRAM_ERROR;
      end if;

      -- Premier périmètre : champs <= 30 bits pour éviter les débordements
      -- Ada INTEGER dans le calcul du masque. Pour TREE, les champs font
      -- 2, 7, 15 ou 8 bits.
      if  WIDTH <= 0  or else  WIDTH > 30  then
        PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : largeur non geree " & INTEGER'IMAGE( WIDTH ) );
        raise  PROGRAM_ERROR;
      end if;

      if  CODI.DEBUG  then
        PUT_LINE( tab50 & "; pack " & PRINT_NAME( D( LX_SYMREP, COMP_ID ) )
		& " range" & INTEGER'IMAGE( FIRST_BIT )
		& " .."	& INTEGER'IMAGE( LAST_BIT )
		& " width" & INTEGER'IMAGE( WIDTH ) );
      end if;

      EXPRESSIONS.CODE_EXP( COMP_EXP );

      PUT_LINE( tab & "LI"  & tab & IMAGE( FIRST_BIT ) );
      PUT_LINE( tab & "LI"  & tab & IMAGE( WIDTH ) );
      PUT_LINE( tab & "BFI" );									-- @data_to_modify, @data_inserted, accumulator, value

    end	EMIT_PACKED_FIELD;
	-----------------

		-------------------------
    procedure	EMIT_POSITIONAL_COMPONENT	( POS :in out INTEGER; COMP_EXP :TREE )
    is		-------------------------

      DSCRMT_S		: SEQ_TYPE	:= LIST( D( SM_DISCRIMINANT_S, TYPE_SPEC ) );
      DSCRMT_DECL		: TREE;

    begin
      while  not IS_EMPTY( DSCRMT_S )  loop
        POP( DSCRMT_S, DSCRMT_DECL );
        declare
	DSCRMT_ID_S	: SEQ_TYPE	:= LIST( D( AS_SOURCE_NAME_S, DSCRMT_DECL ) );
	DSCRMT_ID		: TREE;
	COUNT		: INTEGER		:= 0;
        begin
	while  not IS_EMPTY( DSCRMT_ID_S )  loop
	  POP( DSCRMT_ID_S, DSCRMT_ID );
	  COUNT := COUNT + 1;

	  if  COUNT = POS  then
	    EMIT_PACKED_FIELD( DSCRMT_ID, COMP_EXP );
	    POS := POS + 1;
	    return;
	  end if;
	end loop;
        end;
      end loop;

      PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : composant positionnel non gere " & INTEGER'IMAGE( POS ) );
      raise  PROGRAM_ERROR;

    end	EMIT_POSITIONAL_COMPONENT;
	-------------------------

		----------------
    procedure	EMIT_NAMED_ASSOC	( ASSOC : TREE )
    is		----------------
      COMP_EXP	: TREE		:= D( AS_EXP, ASSOC );
      CHOICES	: SEQ_TYPE	:= LIST( D( AS_CHOICE_S, ASSOC ) );
      CH		: TREE;
      COMP_ID	: TREE;
    begin
      while  not IS_EMPTY( CHOICES )  loop
        POP( CHOICES, CH );

        if  CH.TY = DN_CHOICE_EXP  then
	COMP_ID := D( SM_DEFN, D( AS_EXP, CH ) );

	if  COMP_ID = TREE_VOID  or else  COMP_ID = TREE_NIL  then
	  PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : choix sans SM_DEFN" );
	  raise PROGRAM_ERROR;
	end if;

	EMIT_PACKED_FIELD( COMP_ID, COMP_EXP );

        elsif  CH.TY = DN_CHOICE_OTHERS  then
	PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : others non gere" );
	raise PROGRAM_ERROR;

        else
	PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : choix non gere " & NODE_NAME'IMAGE( CH.TY ) );
	raise  PROGRAM_ERROR;
        end if;
      end loop;

    end	EMIT_NAMED_ASSOC;
	----------------


  begin
    if  CODI.DEBUG  then
      PUT_LINE( tab50 & "; Assign_represented_record_aggregate size" & INTEGER'IMAGE( SIZE_BITS ) & " bits" );
    end if;

    if  SIZE_BITS <= 0  or else  SIZE_BITS > 32  then
      PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : taille non geree " & INTEGER'IMAGE( SIZE_BITS ) );
      raise  PROGRAM_ERROR;
    end if;

    -- Entrée :
    --   @data
    --
    -- On garde deux exemplaires de @data :
    --   @data original sera supprimé à la fin,
    --   @data copie servira au store final.
    --
    -- Pile :
    --   @data, @data, accumulator

    PUT_LINE( tab & "DUP" );
    PUT_LINE( tab & "LI" & tab & "0" );

    declare
      SEQ		: SEQ_TYPE	:= LIST( D( AS_GENERAL_ASSOC_S, AGGREGATE ) );
      ASSOC	: TREE;
      POS		: INTEGER		:= 1;

    begin
      while  not IS_EMPTY( SEQ )  loop
        POP( SEQ, ASSOC );

        if  ASSOC.TY = DN_NAMED  then
	EMIT_NAMED_ASSOC( ASSOC );

        elsif  ASSOC.TY in CLASS_EXP  then
	EMIT_POSITIONAL_COMPONENT( POS, ASSOC );

        else
	PUT_LINE( "; CODE_REPRESENTED_RECORD_AGGREGATE : association non geree " & NODE_NAME'IMAGE( ASSOC.TY ) );
	raise  PROGRAM_ERROR;
        end if;
      end loop;
    end;
    -- Pile avant store :
    --   @data, @data, packed_word
    --
    -- Sd -1,0 dépile packed_word puis dépile @data comme adresse cible.
    -- Il reste l'exemplaire initial de @data, supprimé ensuite.

    PUT_LINE( tab & "SD" );
    PUT_LINE( tab & "DROP" );

  end	CODE_REPRESENTED_RECORD_AGGREGATE;
	---------------------------------


			-----------------------
  procedure		CODE_LOAD_REP_COMPONENT	( COMP_ID :TREE )
  is			-----------------------

    COMP_TYPE		: TREE		:= D( SM_OBJ_TYPE, COMP_ID );
    REP_ELEM		: TREE		:= FIND_COMP_REP_ELEM_FROM_COMPONENT( COMP_ID );
    BYTE_OFFSET		: NATURAL;
    FIRST_BIT,LAST_BIT	: NATURAL;
    WIDTH			: NATURAL;
    DUMMY_ID		: TREE;

  begin
    if  REP_ELEM = TREE_VOID  or else  REP_ELEM = TREE_NIL  then
      PUT_LINE( "; CODE_LOAD_REP_COMPONENT : composant sans representation " & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
      raise  PROGRAM_ERROR;
    end if;

    GET_COMP_REP_ELEM( REP_ELEM, DUMMY_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );

    if  BYTE_OFFSET /= 0  then
      PUT_LINE( "; CODE_LOAD_REP_COMPONENT : byte_offset non nul non gere" );
      raise  PROGRAM_ERROR;
    end if;

    -- L'adresse du record est au sommet de pile.
    -- Ld sans argument = Ld -1, 0 : charge le dword pointé.
    PUT_LINE( tab & "LD" );

    PUT_LINE( tab & "LI" & TAB & IMAGE( FIRST_BIT ) );
    PUT_LINE( tab & "LI" & TAB & IMAGE( WIDTH ) );

    if  COMP_TYPE.TY = DN_INTEGER  then
      -- À affiner ensuite : tous les entiers Ada ne sont pas forcément signés
      -- au sens d'un champ représenté. Pour TREE, PAGE_IDX, LINE_IDX,
      -- ATTR_NBR, etc. sont positifs, donc UBFX suffit.
      PUT_LINE( tab & "UBFX" );
    else
      -- Enumérations et booléens : extraction non signée.
      PUT_LINE( tab & "UBFX" );
    end if;

  end	CODE_LOAD_REP_COMPONENT;
	-----------------------


			---------------------------------
  function		FIND_COMP_REP_ELEM_FROM_COMPONENT	( COMP_ID :TREE )	return TREE
  is			---------------------------------

    OWNER			: TREE	:= D( XD_REGION, COMP_ID );
    TYPE_SPEC		: TREE;
    REP			: TREE;
    REP_S			: SEQ_TYPE;
    REP_ELEM		: TREE;
    DEFN			: TREE;

  begin
    if  OWNER = TREE_VOID  then return  TREE_VOID;  end if;

    if  OWNER.TY = DN_TYPE_ID  or else  OWNER.TY = DN_PRIVATE_TYPE_ID  or else  OWNER.TY = DN_L_PRIVATE_TYPE_ID  then
      TYPE_SPEC := CODI.FULL_TYPE_VIEW( D( SM_TYPE_SPEC, OWNER ) );
    else
      return  TREE_VOID;
    end if;

    if  not HAS_RECORD_REP( TYPE_SPEC )  then  return  TREE_VOID;  end if;

    REP := D( SM_REPRESENTATION, TYPE_SPEC );
    REP_S := LIST( D( AS_COMP_REP_S, REP ) );

    while  not IS_EMPTY( REP_S )  loop
      POP( REP_S, REP_ELEM );

      DEFN := D( SM_DEFN, D( AS_NAME, REP_ELEM ) );
      if  DEFN = COMP_ID  or else  PRINT_NAME( D( LX_SYMREP, DEFN ) ) = PRINT_NAME( D( LX_SYMREP, COMP_ID ) )  then	-- n 95b : composant COPIE par derivation (new TREE) -- la clause
        return  REP_ELEM;										-- designe les composants du PARENT.
      end if;											-- Noms uniques dans un record : sur.

    end loop;

    return  TREE_VOID;

  end	FIND_COMP_REP_ELEM_FROM_COMPONENT;
	---------------------------------


			------------------------
  procedure		CODE_STORE_REP_COMPONENT	( COMP_ID :TREE; VALUE_EXP  :TREE )
  is			------------------------

    REP_ELEM		: TREE;
    DUMMY_ID		: TREE;

    BYTE_OFFSET		: INTEGER;
    FIRST_BIT,LAST_BIT	: NATURAL;
    WIDTH			: INTEGER;

    OWNER			: TREE;
    TYPE_SPEC		: TREE		:= TREE_VOID;
    SIZE_BITS		: INTEGER		:= 0;
    SIZE_BYTES		: INTEGER		:= 0;

		------------------
    procedure	EMIT_LOAD_OLD_WORD
    is		------------------
    begin
      if SIZE_BYTES <= 1 then  PUT_LINE( tab & "LB" );
      elsif SIZE_BYTES <= 2 then  PUT_LINE( tab & "LW" );
      elsif SIZE_BYTES <= 4 then  PUT_LINE( tab & "LD" );
      else  PUT_LINE( TAB & "LQ" );
      end if;

    end	EMIT_LOAD_OLD_WORD;
	------------------

		-------------------
    procedure	EMIT_STORE_NEW_WORD
    is		-------------------
    begin
      if SIZE_BYTES <= 1 then  PUT_LINE( tab & "SB" );
      elsif SIZE_BYTES <= 2 then  PUT_LINE( tab & "SW" );
      elsif SIZE_BYTES <= 4 then  PUT_LINE( tab & "SD" );
      else  PUT_LINE( tab & "SQ" );
      end if;

    end	EMIT_STORE_NEW_WORD;
	-------------------

  begin
    if  COMP_ID = TREE_VOID  or else  COMP_ID = TREE_NIL  then
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : COMP_ID absent" );
      raise  PROGRAM_ERROR;
    end if;

    if  not ( COMP_ID.TY = DN_COMPONENT_ID  or else  COMP_ID.TY = DN_DISCRIMINANT_ID )  then
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : COMP_ID inattendu " & NODE_NAME'IMAGE( COMP_ID.TY ) );
      raise  PROGRAM_ERROR;
    end if;

    REP_ELEM := FIND_COMP_REP_ELEM_FROM_COMPONENT( COMP_ID );

    if  REP_ELEM = TREE_VOID  or else  REP_ELEM = TREE_NIL  then
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : composant sans representation "
        & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
      raise  PROGRAM_ERROR;
    end if;

    GET_COMP_REP_ELEM( REP_ELEM, DUMMY_ID, BYTE_OFFSET, FIRST_BIT, LAST_BIT, WIDTH );

    if  BYTE_OFFSET /= 0  then
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : byte_offset non nul non gere pour "
        & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
      raise  PROGRAM_ERROR;
    end if;

    OWNER := D( XD_REGION, COMP_ID );

    if  OWNER /= TREE_VOID  and then  OWNER /= TREE_NIL  and then
	(OWNER.TY = DN_TYPE_ID   or else  OWNER.TY = DN_PRIVATE_TYPE_ID  or else  OWNER.TY = DN_L_PRIVATE_TYPE_ID)
    then
      TYPE_SPEC := CODI.FULL_TYPE_VIEW( D( SM_TYPE_SPEC, OWNER ) );
    else
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : region du composant non DN_TYPE_ID "
        & PRINT_NAME( D( LX_SYMREP, COMP_ID ) ) );
      raise  PROGRAM_ERROR;
    end if;

    SIZE_BITS := REPRESENTED_RECORD_SIZE_BITS( TYPE_SPEC );

    if  SIZE_BITS <= 0  or else SIZE_BITS > 64  then
      PUT_LINE( "; CODE_STORE_REP_COMPONENT : taille record represente non geree "
        & INTEGER'IMAGE( SIZE_BITS ) );
      raise  PROGRAM_ERROR;
    end if;

    SIZE_BYTES := ( SIZE_BITS + CODI.STORAGE_UNIT - 1 )
	      / CODI.STORAGE_UNIT;

    if  CODI.DEBUG  then
      PUT_LINE( TAB50 & "; store represented component "
        & PRINT_NAME( D( LX_SYMREP, COMP_ID ) )
        & " range" & INTEGER'IMAGE( FIRST_BIT )
        & " .."   & INTEGER'IMAGE( LAST_BIT )
        & " width" & INTEGER'IMAGE( WIDTH ) );
    end if;

    PUT_LINE( tab & "DUP" );										-- @data a modifier en entree
    EMIT_LOAD_OLD_WORD;										-- charge valeur a modifier
    EXPRESSIONS.CODE_EXP( VALUE_EXP );									-- Valeur a inserer
    PUT_LINE( tab & "LI" & TAB & IMAGE( FIRST_BIT ) );
    PUT_LINE( tab & "LI" & TAB & IMAGE( WIDTH ) );
    PUT_LINE( tab & "BFI" );										-- Bit Field Insert
    EMIT_STORE_NEW_WORD;

  end	CODE_STORE_REP_COMPONENT;
	------------------------


	-----------------
end	REPRESENTED_ITEMS;
	-----------------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
