with IDL;
use  IDL;

			--------------------
	package		CODAGE_INTERMEDIAIRE
			--------------------
is

  subtype SEGMENT_NUM	is INTEGER range 0 .. 32767;
  subtype LEVEL_NUM		is INTEGER range 0 .. 16;
  subtype OFFSET_VAL	is INTEGER range -2**31 .. 2**31-1;


  type OPCI		is (

			RAZ,							-- 0 arg
										-- 1 arg
			NON,	OPPS,	OPPR,
  			CNVS16,	CNVS32,	CNVS64,	CNVR,
			TRSF,
										-- 2 args
			EBA1,	EBA0,	TEB,
			ET,	OU,
			DLD,	DLG,	DAD,	DAG,	ROD,	ROG,
			ADDS,	ADDR,	SOUS,	SOUR,	MULS,	MULR,	DIVS,	DIVR,

			CHRGA,	TRSFA,						-- 1 adr
  			ADDA,							-- 2 adr
			CMPZ,							-- ctl 0
			CMP,							-- ctl 1
			BORNES,							-- ctl 3
			CALL,	RTD,						-- flot 0
  			BRA,	BGT,	BLT,	BGE,	BLE,	BEQ,	BNE,	-- flot 1
			LINK, UNLINK						-- frame
			);

  type OPCI_CLASS	 	is (
			ARG0,	ARG1,	ARG2,
			PRM,
		 	ADR1,	ADR2,
			CTL1,	CTL2,	CTL3,
  			FLOT0,	FLOT1,
			FRAME
			);

  subtype OPCI_ARG0		is OPCI range RAZ     .. RAZ;
  subtype OPCI_ARG1		is OPCI range NON     .. TRSF;
  subtype OPCI_ARG2		is OPCI range EBA1    .. DIVR;
  subtype OPCI_ADR1		is OPCI range CHRGA   .. TRSFA;
  subtype OPCI_ADR2		is OPCI range ADDA    .. ADDA;
  subtype OPCI_CTL1		is OPCI range CMPZ    .. CMPZ;
  subtype OPCI_CTL2		is OPCI range CMP     .. CMP;
  subtype OPCI_CTL3		is OPCI range BORNES  .. BORNES;
  subtype OPCI_FLOT0	is OPCI range CALL    .. RTD;
  subtype OPCI_FLOT1	is OPCI range BRA     .. BNE;
  subtype OPCI_FRAME	is OPCI range LINK    .. UNLINK;


  type TARGET_LBL_REF	is private;
  type OPERAND_REF		is private;
  NO_OPERAND		:constant OPERAND_REF;

  type DIRECTION_DE_PASSAGE	is ( ENTREE, SORTIE, ENTREE_SORTIE );
 

  function  NEW_OPERAND					return OPERAND_REF;
  procedure FREE			( OPERAND :OPERAND_REF );

  function  NEW_LBL						return TARGET_LBL_REF;
  procedure STOCK_CP		( FOR_LBL : TARGET_LBL_REF );

  procedure MAKE_OPRND_IMM		( OPERAND :OPERAND_REF; IMM_VAL :INTEGER );
  procedure MAKE_OPRND_DAT		( OPERAND :OPERAND_REF;
				  SEG :SEGMENT_NUM; LVL :LEVEL_NUM; OFS :OFFSET_VAL;
				  SIZ :POSITIVE );
  function  ADR_OPRND		( OPERAND :OPERAND_REF;
				  SEG :SEGMENT_NUM; LVL :LEVEL_NUM; OFS :OFFSET_VAL )	return OPERAND_REF;
  procedure MAKE_OPRND_PRM		( OPERAND  :OPERAND_REF; DIRECTION :DIRECTION_DE_PASSAGE );

  procedure ARG1_OP			( RESULTAT :OPERAND_REF; OP: OPCI_ARG1; X1: OPERAND_REF );

  procedure ADR1_OP			( RESULTAT :OPERAND_REF; OP: OPCI_ADR1; X1: OPERAND_REF );
  procedure ADR2_OP			( RESULTAT :OPERAND_REF; OP: OPCI_ADR2; X1, X2: OPERAND_REF );

  procedure FLOT0_OP		( OP :OPCI_FLOT0; ALLOC_DESALLOC :INTEGER := 0 );
  procedure FLOT1_OP		( OP :OPCI_FLOT1; TARGET :TARGET_LBL_REF );
  procedure FRAME_OP		( OP :OPCI_FRAME; ALLOC :INTEGER := 0 );



  TROP_DE_REPRISES, TROP_D_OPERANDS, OPERAND_INVALIDE,
  TROP_DE_TEMPORAIRES_A, TROP_DE_TEMPORAIRES_T, TROP_IFLOTS1,
  OPERAND_OVERFLOW	 		: exception;



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

  type REC_TEMPORAIRE_A	is record
			  LOCALISATIONS, INDICE_UTILISEE	: INTEGER;
			  PARAMETRES			: PARAMETRES_ACCES;
			end record;

  NMAX_TEMPORAIRES_A	:constant		:= 128;
  type TEMPORAIRE_A		is range 0 .. NMAX_TEMPORAIRES_A;

  TABLE_TEMPORAIRES_A		: array( TEMPORAIRE_A ) of REC_TEMPORAIRE_A;

			-- REPRISES DE SAUTS

  MAX_BRANCHS		:constant		:= 150;
  type NUM_BRANCH		is range 0 .. MAX_BRANCHS;

  MAX_TARGET_LBLS		:constant		:= 150;
  type TARGET_LBL_REF	is range 0 .. MAX_TARGET_LBLS;

  BRANCH_ILOC		: array( NUM_BRANCH )     of INSTR_LOC;
  TARGET_ILOC		: array( TARGET_LBL_REF ) of INSTR_LOC;



			-- OPERANDS


  type GENRE_OPERAND	is ( IMM, DAT, ADR_TMP, DAT_TMP, PRM, FREE );
  type TYPE_OPERAND		is ( UNKNOWN, BYTE_TYP, HALF_TYP, WORD_TYP, LONG_TYP, SINGLE_TYP, DOUBLE_TYP, ADR_TYP );

  type REC_OPERAND ( GENRE :GENRE_OPERAND := FREE )	is record
			  INACTIF			: BOOLEAN;
			  OPER_TYP		: TYPE_OPERAND;
 		 	  case GENRE is
  			  when IMM		=> VALEUR		: INTEGER;
  			  when DAT		=> SEG		: SEGMENT_NUM;
						   OFS		: OFFSET_VAL;
						   SIZ		: INTEGER;
  			  when ADR_TMP 		=> TMP_A		: TEMPORAIRE_A;
  			  when DAT_TMP 		=> TMP_T		: TEMPORAIRE_T;
  			  when PRM		=> DIRECTION	: DIRECTION_DE_PASSAGE;
						   PRM_OFS	: OFFSET_VAL;
						   PRM_SIZ	: INTEGER;
  			  when FREE		=> NEXT_FREE	: OPERAND_REF;
			  end case;
			end record;

  NMAX_OPERANDS		:constant			:= 256;
  type OPERAND_REF		is range 0 .. NMAX_OPERANDS;
  NO_OPERAND		:constant OPERAND_REF	:= 0;


			-- INSTRUCTIONS

  type INSTRUC ( GENRE :OPCI_CLASS := ARG0 )
			is record
			  FIN_BLOC				: BOOLEAN	:= FALSE;
			  BLOC_ENTREE_LATERALE, BLOC_SORTIE_LATERALE	: INTEGER	:= 0;
			  case GENRE is

			  when ARG0 =>	ARG0_OP			: OPCI_ARG0;
					ARG0_RESULT		: REC_OPERAND;

			  when ARG1 =>	ARG1_OP			: OPCI_ARG1;
					ARG1_RESULT, ARG1_X1	: REC_OPERAND;

			  when ARG2 =>	ARG2_OP			: OPCI_ARG2;
					ARG2_RESULT, ARG2_X1, ARG2_X2	: REC_OPERAND;

			  when ADR1 =>	ADR1_OP			: OPCI_ADR1;
					ADR1_RESULT, ADR1_X1	: REC_OPERAND;

			  when ADR2 =>	ADR2_OP			: OPCI_ADR2;
					ADR2_RESULT, ADR2_X1, ADR2_X2	: REC_OPERAND;

			  when CTL1 =>	CTL1_OP			: OPCI_CTL1;
					CTL1_X1			: REC_OPERAND;

			  when CTL2 =>	CTL2_OP			: OPCI_CTL2;
					Ctl2_X1, I_CTL2_X2		: REC_OPERAND;

			  when CTL3 =>	CTL3_OP			: OPCI_CTL3;
					CTL3_X1, I_CTL3_X2, I_CTL3_X3	: REC_OPERAND;

			  when FLOT0 =>	FLOT0_OP			: OPCI_FLOT0;
					DESALLOC			: INTEGER;
					UNIT, PROC		: INTEGER;

			  when FLOT1 =>	FLOT1_OP			: OPCI_FLOT1;
					FLOT1_SAUT		: TARGET_LBL_REF;

			  when PRM =>	PARAMETRE			: REC_OPERAND;

			  when FRAME =>	FRAME_OP			: OPCI_FRAME;
					ALLOC			: INTEGER;
			end case;
			end record;

  MAX_INSTRUCTIONS		:constant	INSTR_LOC	:= 1500;

  TABLE_INSTRUCTIONS	: array( 1..MAX_INSTRUCTIONS ) of INSTRUC;



end	CODAGE_INTERMEDIAIRE;
	--------------------