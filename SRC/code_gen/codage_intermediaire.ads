with IDL;
use  IDL;

			--------------------
	package		CODAGE_INTERMEDIAIRE
			--------------------
is


  type OPCI		is (

			RAZ,					-- 0 arg
								-- 1 arg
			NON,	OPPS,	OPPR,
  			CNVS16,	CNVS32,	CNVS64,	CNVR,
			TRSF,
								-- 2 args
			EBA1,	EBA0,	TEB,
			ET,	OU,
			DLD,	DLG,	DAD,	DAG,	ROD,	ROG,
			ADDS,	ADDR,	SOUS,	SOUR,	MULS,	MULR,	DIVS,	DIVR,

			CHRGA,	TRSFA,				-- 1 adr
  			ADDA,					-- 2 adr
			CMPZ,					-- ctl 0
			CMP,					-- ctl 1
			BORNES,					-- ctl 3
			LINK, UNLINK, RTD,				-- flot 0
  			BSC, BSS, BIS, BSE, BIE, BEG, BNE		-- flot 1
			);

  type OPCI_CLASS	 	is (
			ARG0,	ARG1,	ARG2,
			PRM,
		 	ADR1,	ADR2,
			CTL1,	CTL2,	CTL3,
  			FLOT0,	FLOT1,
			CALL
			);

  subtype OPCI_ARG0		is OPCI range RAZ     .. RAZ;
  subtype OPCI_ARG1		is OPCI range NON     .. TRSF;
  subtype OPCI_ARG2		is OPCI range EBA1    .. DIVR;
  subtype OPCI_ADR1		is OPCI range CHRGA   .. TRSFA;
  subtype OPCI_ADR2		is OPCI range ADDA    .. ADDA;
  subtype OPCI_CTL1		is OPCI range CMPZ    .. CMPZ;
  subtype OPCI_CTL2		is OPCI range CMP     .. CMP;
  subtype OPCI_CTL3		is OPCI range BORNES  .. BORNES;
  subtype OPCI_FLOT0	is OPCI range LINK    .. RTD;
  subtype OPCI_FLOT1	is OPCI range BSC     .. BNE;


  type TARGET_LBL		is private;
  type DESIGNATION		is private;

  type DIRECTION_DE_PASSAGE	is ( ENTREE, SORTIE, ENTREE_SORTIE );
 

  function  NEW_DESIGNATION					return DESIGNATION;
  procedure FREE_DESIGNATION		( D :DESIGNATION );

  function  NEW_LBL						return TARGET_LBL;
  procedure STOCK_CP		( FOR_LBL : TARGET_LBL );

  procedure CODE_IMM		( DESIGNE :DESIGNATION; VALEUR_IMM :INTEGER );
  procedure CODE_CST		( DESIGNE :DESIGNATION; CST_DEF :TREE );
--  procedure CODE_VAR		( DESIGNE :DESIGNATION; NOM :TREE );
  procedure CODE_PRM		( PARAMETRE :DESIGNATION; DIRECTION :DIRECTION_DE_PASSAGE );
  procedure CODE_ADR1		( RESULTAT :DESIGNATION; OP: OPCI_ADR1; X1: DESIGNATION );

  procedure CODE_FLOT0		( OP :OPCI_FLOT0; ALLOC_DESALLOC :INTEGER := 0 );
  procedure CODE_FLOT1		( OP :OPCI_FLOT1; TARGET :TARGET_LBL );



  TROP_DE_REPRISES, TROP_DE_DESIGNATIONS, DESIGNATION_INVALIDE,
  TROP_DE_TEMPORAIRES_A, TROP_DE_TEMPORAIRES_T, TROP_IFLOTS1 		: exception;



					-------
					private
					-------
  type INSTR_LOC		is new NATURAL;

  COMPTEUR_PROGRAMME	: INSTR_LOC		:= 1;

			-- TEMPORAIRES DATA


  type REC_TEMPORAIRE_T	is record
			  LOCALISATIONS, INDICE_UTILISEE : INTEGER;
			end record;

  NMAX_TEMPORAIRES_T	:constant		:= 128;
  type TEMPORAIRE_T		is range 0 .. NMAX_TEMPORAIRES_T;

  TABLE_TEMPORAIRES_T	: array( TEMPORAIRE_T ) of REC_TEMPORAIRE_T;

			-- TEMPORAIRES ADRESSES

  type GENRE_ACCES	is 	( DIRECT_REG_D,			DIRECT_REG_A,
			  ABSOLU,				IMMEDIAT,

			  INDIRECT,			INDIRECT_POSTINC,			INDIRECT_PREDEC,
			  INDIRECT_DEPLACE,			INDIRECT_INDEXE_DEPLACE,		INDIRECT_INDEXE_BASE,
			  INDIRECT_BASE_POST_INDEXE_DEPLACE,	INDIRECT_BASE_INDEXE_POST_DEPLACE,

			  CP_BASE_POST_INDEXE_DEPLACE,	CP_BASE_INDEXE_POST_DEPLACE,
			  CP_DEPLACE,			CP_INDEXE_DEPLACE,			CP_INDEXE_BASE

			);
  type PARAMETRES_ACCES	is record
			  GENRE				: GENRE_ACCES;
			  REGISTRE, INDEX, ECHELLE		: INTEGER;
			  BASE, DEPLACEMENT, VALEUR_IMMEDIATE	: INTEGER;
			end record;

  type DESCR_TEMPORAIRE_ACCES	is record
			  LOCALISATIONS, INDICE_UTILISEE	: INTEGER;
			  PARAMETRES			: PARAMETRES_ACCES;
			end record;

  NMAX_TEMPORAIRES_A	:constant		:= 128;
  type TEMPORAIRE_A		is range 0 .. NMAX_TEMPORAIRES_A;

  TABLE_TEMPORAIRES_A		: array( TEMPORAIRE_A ) of DESCR_TEMPORAIRE_ACCES;

			-- REPRISES DE SAUTS

  MAX_BRANCHS		:constant		:= 150;
  type NUM_BRANCH		is range 0 .. MAX_BRANCHS;

  MAX_TARGET_LBLS		:constant		:= 150;
  type TARGET_LBL		is range 0 .. MAX_TARGET_LBLS;

  BRANCH_ILOC		: array( NUM_BRANCH ) of INSTR_LOC;
  TARGET_ILOC		: array( TARGET_LBL ) of INSTR_LOC;



			-- DESIGNATIONS


  type GENRE_DATA_ITEM	is ( CST, GLO, STK, IMM, PRM, ADR, TMP );

  type DATA_ITEM ( GENRE :GENRE_DATA_ITEM := IMM )
			is record
 		 	  case GENRE is
  			  when PRM		=> DIRECTION	: DIRECTION_DE_PASSAGE;
  			  when CST | GLO | STK	=> REFERENCE	: TREE;
  			  when IMM		=> VALEUR		: INTEGER;
  			  when TMP 		=> TMP_T		: TEMPORAIRE_T;
  			  when ADR 		=> TMP_A		: TEMPORAIRE_A;
			  end case;
		  	end record;

  type REC_DESIGNATION	is record
			  VAR_OR_CST		: DATA_ITEM;
			  INACTIF			: BOOLEAN;
			  SEGMENT, DECALAGE, TAILLE	: INTEGER;
			end record;

  NMAX_DESIGNATIONS		:constant		:= 256;
  type DESIGNATION		is range 0 .. NMAX_DESIGNATIONS;



			-- INSTRUCTIONS

  type INSTRUC ( GENRE :OPCI_CLASS := ARG0 )
			is record
			  FIN_BLOC				: BOOLEAN	:= FALSE;
			  BLOC_ENTREE_LATERALE, BLOC_SORTIE_LATERALE	: INTEGER	:= 0;
			  case GENRE is

			  when ARG0 =>	ARG0_OP			: OPCI_ARG0;
					ARG0_TYPE			: TREE;
					ARG0_RESULT		: REC_DESIGNATION;

			  when ARG1 =>	ARG1_OP			: OPCI_ARG1;
					ARG1_TYPE			: TREE;
					ARG1_RESULT, ARG1_X1	: REC_DESIGNATION;

			  when ARG2 =>	ARG2_OP			: OPCI_ARG2;
					ARG2_TYPE			: TREE;
					ARG2_RESULT, ARG2_X1, ARG2_X2	: REC_DESIGNATION;

			  when ADR1 =>	ADR1_OP			: OPCI_ADR1;
					ADR1_RESULT, ADR1_X1	: REC_DESIGNATION;

			  when ADR2 =>	ADR2_OP			: OPCI_ADR2;
					ADR2_RESULT, ADR2_X1, ADR2_X2	: REC_DESIGNATION;

			  when CTL1 =>	CTL1_OP			: OPCI_CTL1;
					CTL1_aType		: TREE;
					CTL1_X1			: REC_DESIGNATION;

			  when CTL2 =>	CTL2_OP			: OPCI_CTL2;
					Ctl2_TYPE			: TREE;
					Ctl2_X1, I_CTL2_X2		: REC_DESIGNATION;

			  when CTL3 =>	CTL3_OP			: OPCI_CTL3;
					CTL3_TYPE			: TREE;
					CTL3_X1, I_CTL3_X2, I_CTL3_X3	: REC_DESIGNATION;

			  when FLOT0 =>	FLOT0_OP			: OPCI_FLOT0;
					ALLOC_DESALLOC		: INTEGER;

			  when FLOT1 =>	FLOT1_OP			: OPCI_FLOT1;
					FLOT1_SAUT		: TARGET_LBL;

			  when PRM =>	PARAMETRE			: REC_DESIGNATION;
			  when CALL =>	UNIT, PROC		: INTEGER;
			end case;
			end record;

  MAX_INSTRUCTIONS		:constant	INSTR_LOC	:= 1500;

  TABLE_INSTRUCTIONS	: array( 1..MAX_INSTRUCTIONS ) of INSTRUC;



end	CODAGE_INTERMEDIAIRE;
	--------------------