-- La pile abstraite croit vers le bas
--	---------------------
--	|    BAS DE PILE 	|

--	|		| param_1
--	|		| param_2


--	|		| param_K
--	|        -8	| parent_FP
--	|        -4	| RET_ADDR
--	|         0	| FP_bck
--	|        +4	| VAR_LOC_1
--	|		|
--	---------------------


--	PGA	Push Global Address		Unit_num      Offset
--	PLA	Push Local  Address		Level_delta   Offset
--	PGD	Push Global Data		Unit_num      Offset
--	PLD	Push Local  Data		Level_delta   Offset
--	SGD	Store Global Data
--	SLD	Store Local Data
with TEXT_IO, IDL;
use  TEXT_IO, IDL;

			--------------------
	package		CODAGE_INTERMEDIAIRE
			--------------------

is

  type OPERAND_REF		is private;
  NO_OPERAND		:constant OPERAND_REF;

  type OPERAND_TYPE		is ( UNKNOWN, BYTE_TYP, HALF_TYP, WORD_TYP, LONG_TYP, SINGLE_TYP, DOUBLE_TYP, ADR_TYP );

  MAX_LABEL			: constant		:= 30_000;				--| NB MAX D'ETIQUETTES DE SAUT
  MAX_OFFSET			: constant		:= 10_000;				--|
  MAX_LEVEL			: constant		:= 128;					--| NB MAX DE NIVEAUX D'IMBRICATION
   
  type LABEL_TYPE			is new NATURAL		range 0..MAX_LABEL;				--| TYPE ETIQUETTE
  subtype OFFSET_VAL		is INTEGER		range -MAX_OFFSET .. MAX_OFFSET;
  type LEVEL_NUM			is new INTEGER		range -MAX_LEVEL .. MAX_LEVEL-1;

  subtype SEGMENT_NUM		is INTEGER		range 0 .. 32767;


  ADDR_SIZE			: constant		:= 4;					--| ADRESSES SUR 32 BITS
  ADDR_AL				: constant		:= 4;					--| ALIGNEMENT ADRESSE SUR 4 OCTETS
  BOOL_SIZE			: constant		:= 1;					--| BOOLEEN SUR 1 OCTET
  BOOL_AL				: constant		:= 1;					--| ALIGNEMENT BOOLEEN SUR 1 OCTET
  CHAR_SIZE			: constant		:= 1;					--| CARACTERE SUR 8 BITS
  CHAR_AL				: constant		:= 1;					--| ALIGNEMENT CARACTERE SUR 1 OCTET
  INTG_SIZE			: constant		:= 4;					--| ENTIER SUR 32 BITS
  INTG_AL				: constant		:= 4;					--| ALIGNEMENT ENTIER SUR 4 OCTETS
  STACK_AL			: constant		:= 4;
  ARRAY_AL			: constant		:= 4;
  RECORD_AL			: constant		:= 4;
   
  FIRST_PARAM_OFFSET		: constant OFFSET_VAL	:= 8;
  FIRST_LOCAL_VAR_OFFSET		: constant OFFSET_VAL	:= -4;
  RELATIVE_RESULT_OFFSET		: constant OFFSET_VAL	:= 4;
      
  type OP_CODE			is (								--| CODES OPERATION DU ACODE POLONAIS
		ABO,   ABSV,  ACA,   ACC,   ACT,   ADD,   ALO,   BAND,  CHR,  TRAP,
		CSTA,  CSTI,  CSTS,  CALL,  DEC,   DIV,   DPL,   EAC,   EEX,  ENT,
		EQ,    ETD,   ETE,   ETK,   ETR,   EXC,   EXH,   EXL,   EXP,  JMPF,
		FRE,   GE,    GET,   GT,    INC,   IND,   IXA,   PGA,   LCA,  PLA,
		LDC,   PGD,   LE,    LT,    PLD,   LVB,   MODU,  MOV,   MST,  MUL,
		MVV,   NEG,   NEQ,   BNOT,  BOR,   PKB,   PKG,   PRO,   PUT,  QUIT,
		RAI,   REMN,  RET,   RFL,   RFP,   SGD,   STO,   SLD,   SUB,  SWP,
		JMPT,  JMP,   BXOR,  XJP
		);
      
  package OP_CODE_IO		is new ENUMERATION_IO( OP_CODE );					--| POUR ECRIRE LES CODES SUR LE FICHIER DE SORTIE
   
  type CODE_DATA_TYPE		is ( A, B, C, I );							--| ADDRESS BOOLEAN CHARACTER INTEGER
      
  package CODE_DATA_TYPE_IO		is new ENUMERATION_IO( CODE_DATA_TYPE );
   
  type STD_PROC			is (
		AR1, AR2, CLB, CLN, CNT, CVB, CYA, LBD, LEN, PUA, TRM
      		);
   
  COMMENTS_ON			: BOOLEAN	:= TRUE;							--| COMMUTATEUR POUR L'EMISSION DES COMMENTAIRES AVEC LE CODE
      
  CUR_COMP_UNIT			: SEGMENT_NUM;							--| NO D'UNITE DE COMPILATION COURANTE
  GENERATE_CODE			: BOOLEAN		:= TRUE;						--| COMMUTATEUR POUR LA GENERATION DU CODE
  CUR_LEVEL			: LEVEL_NUM;							--| NIVEAU D'IMBRICATION COURANT
   
  OFFSET_ACT			: OFFSET_VAL;
  OFFSET_MAX			: OFFSET_VAL;
  TOP_ACT				: OFFSET_VAL;							--| TOP OF STACK ACTUEL (LA PILE CROIT POSITIVEMENT)
  TOP_MAX				: OFFSET_VAL;							--| TOP OF STACK MAXIMAL
      
  PARAM_SIZE			: NATURAL;							--| TAILLE DES PARAMETRES DE PROCEDURE EN OCTETS
  RESULT_SIZE			: NATURAL;							--| TAILLE DU RESULTAT DE FONCTION EN OCTETS
  FUN_RESULT_OFFSET			: OFFSET_VAL	:= 0;
  FUNCTION_RESULT			: TREE;
   
   
  SKIP_LBL, HANDLER_BEGIN_LBL		: LABEL_TYPE;							--| UTILISES POUR LES EXCEPTIONS HANDLERS
  ENCLOSING_BODY			: TREE;
  CHOICE_OTHERS_FLAG		: BOOLEAN	:= FALSE;
      
  AFTER_IF_LBL			: LABEL_TYPE;
   
  BEFORE_LOOP_LBL			: LABEL_TYPE;
  AFTER_LOOP_LBL			: LABEL_TYPE;
  LOOP_STM_S			: TREE;
  LOOP_OP_INC_DEC			: OP_CODE;							--| POUR LE TRAITEMENT DES BOUCLES FOR REVERSE
  LOOP_OP_GT_LT			: OP_CODE;							--| DE MEME
  
  TYPE_SYMREP			: TREE;								--| UTILISE POUR LES OBJECT_DECL VAR CONST
      
  procedure OPEN_OUTPUT_FILE		( FILE_NAME :STRING );
  procedure CLOSE_OUTPUT_FILE;
  procedure WRITE_LABEL		( LBL :LABEL_TYPE; COMMENT :STRING := "" );
  procedure GEN_LBL_ASSIGNMENT	( LBL :LABEL_TYPE; N :NATURAL );
  procedure EMIT_COMMENT		( COMMENT :STRING );						--| ESSENTIELLEMENT POUR INDIQUER LES PARTIES RESTANT A FAIRE
  procedure EMIT			( OC :OP_CODE;				COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	CT  :CODE_DATA_TYPE;	COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	B   :BOOLEAN;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	C   :CHARACTER;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	LBL :LABEL_TYPE;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	I   :INTEGER;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	CT  :CODE_DATA_TYPE;
						I   :INTEGER;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	S :STRING;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	NUM, LBL :LABEL_TYPE;	COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	LBL :LABEL_TYPE;
						S :STRING;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	I :INTEGER;
						LBL :LABEL_TYPE;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	IA, IB :INTEGER;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	CT :CODE_DATA_TYPE;
						IA, IB :INTEGER;		COMMENT :STRING := "" );
  procedure EMIT			( OC :OP_CODE;	I :INTEGER;
						S :STRING;		COMMENT :STRING := "" );
  procedure EMIT			( P :STD_PROC;				COMMENT :STRING := "" );

  procedure GEN_PUSH_DATA		( CT :CODE_DATA_TYPE;
				  COMP_UNIT_NUMBER :SEGMENT_NUM;
				  LVL :LEVEL_NUM;
				  OFFSET :INTEGER;				COMMENT :STRING := "" );
   
  function  NEW_LABEL							return LABEL_TYPE;
  procedure INC_LEVEL;
  procedure DEC_LEVEL;
  procedure DEC_OFFSET		( I :NATURAL );
  procedure ALIGN			( AL :INTEGER );
       
       
  procedure PERFORM_RETURN		( ENCLOSING_BLOCK_BODY :TREE );
  function  TYPE_SIZE		( TYPE_SPEC :TREE )				return NATURAL;
  function  CODE_DATA_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )			return CODE_DATA_TYPE;
   
  function  NUMBER_OF_DIMENSIONS	( EXP :TREE )				return NATURAL;
  function  CONSTRAINED		( TYPE_SPEC :TREE ) 			return BOOLEAN;
  procedure LOAD_TYPE_SIZE		( TYPE_SPEC :TREE );







  type OPCI		is (

			RAZ,	LIMM,	LOAD,	STORE,	LEA,			-- 0 oper
										-- 1 oper
			NON,	OPPS,	OPPR,
  			CNVS16,	CNVS32,	CNVS64,	CNVR,
										-- 2 oper
			EBA1,	EBA0,	TEB,
			ET,	OU,
			DLD,	DLG,	DAD,	DAG,	ROD,	ROG,
			ADDS,	ADDR,	SOUS,	SOUR,	MULS,	MULR,	DIVS,	DIVR,

			CMPZ,							-- ctl 0
			CMP,							-- ctl 1
			BORNES,							-- ctl 3
			CALL,	RTD,						-- flot 0
  			BRA,	BGT,	BLT,	BGE,	BLE,	BEQ,	BNE,	-- flot 1
			LINK,	UNLINK						-- frame
			);

  type OPCI_CLASS	 	is (
			ARG0,	ARG1,	ARG2,
			PRM,
			CTL1,	CTL2,	CTL3,
  			FLOT0,	FLOT1,
			FRAME
			);

  subtype OPCI_ARG0		is OPCI range RAZ     .. LEA;
  subtype OPCI_ARG1		is OPCI range NON     .. CNVR;
  subtype OPCI_ARG2		is OPCI range EBA1    .. DIVR;
  subtype OPCI_CTL1		is OPCI range CMPZ    .. CMPZ;
  subtype OPCI_CTL2		is OPCI range CMP     .. CMP;
  subtype OPCI_CTL3		is OPCI range BORNES  .. BORNES;
  subtype OPCI_FLOT0	is OPCI range CALL    .. RTD;
  subtype OPCI_FLOT1	is OPCI range BRA     .. BNE;
  subtype OPCI_FRAME	is OPCI range LINK    .. UNLINK;


  type TARGET_LBL_REF	is private;

  type DIRECTION_DE_PASSAGE	is ( ENTREE, SORTIE, ENTREE_SORTIE );
 

--  function  NEW_OPERAND					return OPERAND_REF;
--  procedure FREE			( OPERAND :OPERAND_REF );

  function  NEW_LBL									return TARGET_LBL_REF;
  procedure STOCK_CP		( FOR_LBL : TARGET_LBL_REF );

  function  LOAD_IMM		( IMM_VAL :INTEGER )				return OPERAND_REF;
  function  LOAD_MEM		( DEFN :TREE )					return OPERAND_REF;
  function  LOAD_ADR		( DEFN :TREE )					return OPERAND_REF;
  procedure STORE			( DEST_DEFN :TREE; OTYPE :OPERAND_TYPE; SRC_OPER :OPERAND_REF );
  function  OPERAND_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )				return OPErAND_TYPE;

  procedure MAKE_OPRND_PRM		( OPERAND  :OPERAND_REF; DIRECTION :DIRECTION_DE_PASSAGE );

  procedure ARG1_OP			( RESULTAT :OPERAND_REF; OP: OPCI_ARG1; X1: OPERAND_REF );

  procedure FLOT0_OP		( OP :OPCI_FLOT0; ALLOC_DESALLOC :INTEGER := 0 );
  procedure FLOT1_OP		( OP :OPCI_FLOT1; TARGET :TARGET_LBL_REF );
  procedure FRAME_OP		( OP :OPCI_FRAME; ALLOC :INTEGER := 0 );



  TROP_DE_REPRISES, TROP_D_OPERANDS, OPERAND_INVALIDE,
  TROP_DE_TEMPORAIRES_A, TROP_DE_TEMPORAIRES_T, TROP_IFLOTS1,
  OPERAND_OVERFLOW	 		: exception;


  ILLEGAL_OP_CODE, STATIC_LEVEL_OVERFLOW, STATIC_LEVEL_UNDERFLOW,
  STATIC_OFFSET_OVERFLOW	: exception;



					-------
					private
					-------
  type INSTR_LOC		is new NATURAL;

  COMPTEUR_PROGRAMME	: INSTR_LOC		:= 1;


			-- REPRISES DE SAUTS

  MAX_BRANCHS		:constant		:= 150;
  type NUM_BRANCH		is range 0 .. MAX_BRANCHS;

  MAX_TARGET_LBLS		:constant		:= 150;
  type TARGET_LBL_REF	is range 0 .. MAX_TARGET_LBLS;

  BRANCH_ILOC		: array( NUM_BRANCH )     of INSTR_LOC;
  TARGET_ILOC		: array( TARGET_LBL_REF ) of INSTR_LOC;



			-- OPERANDS

  type SLO_LOC		is record
			  SEG		: SEGMENT_NUM;
			  LVL		: LEVEL_NUM;
			  OFS		: OFFSET_VAL;
			end record;

  type GENRE_OPERAND	is ( IMM, MEM, TMP, PRM, FREE );
  OPERAND_TYPE_IMAGE	:constant array( OPERAND_TYPE ) of CHARACTER	:= ( 'u', 'b', 'h', 'w', 'l', 's', 'd', 'a' );

  type OPERAND_REC ( GENRE :GENRE_OPERAND := FREE )	is record
			  INACTIF			: BOOLEAN;
			  OPER_TYP		: OPERAND_TYPE;
 		 	  case GENRE is
  			  when IMM		=> VALEUR		: INTEGER;
  			  when MEM		=> LOC		: SLO_LOC;
						   SIZ		: INTEGER;
  			  when TMP 		=> DEFINING_ILOC	: INSTR_LOC;
  			  when PRM		=> DIRECTION	: DIRECTION_DE_PASSAGE;
						   PRM_OFS	: OFFSET_VAL;
						   PRM_SIZ	: INTEGER;
  			  when FREE		=> NEXT_FREE	: OPERAND_REF;
			  end case;
			end record;

  NMAX_OPERANDS		:constant			:= 256;
  type OPERAND_REF		is new INSTR_LOC;
  NO_OPERAND		:constant OPERAND_REF	:= 0;


			-- INSTRUCTIONS

  type INSTRUC ( GENRE :OPCI_CLASS := ARG0 )
			is record
--			  FIN_BLOC				: BOOLEAN	:= FALSE;
--			  BLOC_ENTREE_LATERALE, BLOC_SORTIE_LATERALE	: INTEGER	:= 0;
			  case GENRE is

			  when ARG0 =>	ARG0_OP			: OPCI_ARG0;
					ARG0_X1			: OPERAND_REC;

			  when ARG1 =>	ARG1_OP			: OPCI_ARG1;
					ARG1_RESULT, ARG1_X1	: OPERAND_REC;

			  when ARG2 =>	ARG2_OP			: OPCI_ARG2;
					ARG2_RESULT, ARG2_X1, ARG2_X2	: OPERAND_REC;

			  when CTL1 =>	CTL1_OP			: OPCI_CTL1;
					CTL1_X1			: OPERAND_REC;

			  when CTL2 =>	CTL2_OP			: OPCI_CTL2;
					Ctl2_X1, I_CTL2_X2		: OPERAND_REC;

			  when CTL3 =>	CTL3_OP			: OPCI_CTL3;
					CTL3_X1, I_CTL3_X2, I_CTL3_X3	: OPERAND_REC;

			  when FLOT0 =>	FLOT0_OP			: OPCI_FLOT0;
					DESALLOC			: INTEGER;
					UNIT, PROC		: INTEGER;

			  when FLOT1 =>	FLOT1_OP			: OPCI_FLOT1;
					FLOT1_SAUT		: TARGET_LBL_REF;

			  when PRM =>	PARAMETRE			: OPERAND_REC;

			  when FRAME =>	FRAME_OP			: OPCI_FRAME;
					ALLOC			: INTEGER;
			end case;
			end record;

  MAX_INSTRUCTIONS		:constant	INSTR_LOC	:= 1500;

  TABLE_INSTRUCTIONS	: array( 1..MAX_INSTRUCTIONS ) of INSTRUC;

  function  GET_SLO		( OBJECT :TREE )	return SLO_LOC;


end	CODAGE_INTERMEDIAIRE;
	--------------------