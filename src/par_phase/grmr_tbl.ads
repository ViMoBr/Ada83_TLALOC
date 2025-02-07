with SEQUENTIAL_IO;
--|-------------------------------------------------------------------------------------------------
--|		PACKAGE GRMR_TBL
--|-------------------------------------------------------------------------------------------------
package GRMR_TBL is
      
  type AC_BYTE		is range 0..16#FF#;			for AC_BYTE'SIZE use 8;
  type AC_SHORT		is range -16#8000# .. 16#7FFF#;	for AC_SHORT'SIZE use 16;
      
  type ST_TBL_TYPE		is array (1 .. 1000) of INTEGER;				--| TABLE D'ETATS
  type AC_SYM_TYPE		is array (1 .. 4800) of AC_BYTE;				--| TABLE D'ACTIONS
  type AC_TBL_TYPE		is array (1 .. 6000) of AC_SHORT;
      --| VALEURS DANS AC_TBL
      --| VAL DANS 1..999  ETAT DE DECALAGE SUR LA PILE
      --| VAL DANS 1_000..SHORT'LAST FAIRE K:= (VAL-1)/1_000 ET OPERER SUIVANT GRMR_OP'VAL(K) AVEC ARGUMENT GRMR_OP'VAL(1) SAUF POUR INFIX ET UNARY : ARG PAGE PUIS LINE AU MOT SUIVANT
      --| VAL 0 INDIQUE UNE ERREUR
      --| VAL DANS  -9_999..-1  ALLER A L'ACTION INDICE ABS(VAL) DANS AC_TBL
      --| VAL DANS SHORT'FIRST..-9_999  FAIRE K:= (-VAL-10_000-1)/1000 PUIS POP K ELEMENTS ET REDUIRE A 1
      
      -- NONTER TABLE
      -- INFO TO BUILD TXTREP FOR NONTER (FOR DEBUG PURPOSES)
  type NTER_PG_TYPE		is array (1 .. 255) of AC_BYTE;
  type NTER_LN_TYPE		is array (1 .. 255) of AC_BYTE;
      
  type GRMR_TBL_RECORD	is record
			  ST_TBL		: ST_TBL_TYPE;				--| TABLE D ETATS
			  ST_TBL_LAST	: INTEGER;				--| DERNIER ETAT
			  AC_SYM		: AC_SYM_TYPE;				--| TABLE DE CODES SYMBOLES
			  AC_TBL		: AC_TBL_TYPE;				--| TABLE D ACTIONS
			  AC_SYM_LAST	: INTEGER;				--| DERNIER CODE SYMBOLE
			  AC_TBL_LAST	: INTEGER;				--| DERNIER CODE ACTION
			  NTER_PG		: NTER_PG_TYPE;				--| PAGE NON TERM
			  NTER_LN		: NTER_LN_TYPE;				--| LIGNE NON TERM
			  NTER_LAST	: INTEGER;
			end record;
      
  GRMR	: GRMR_TBL_RECORD;
      
  package GRMR_TBL_IO	is new SEQUENTIAL_IO( GRMR_TBL_RECORD );
      
--|-------------------------------------------------------------------------------------------------
end GRMR_TBL;
