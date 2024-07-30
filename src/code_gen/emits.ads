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
						-----
			package			EMITS
						-----

is

  MAX_LABEL			: constant		:= 30_000;				--| NB MAX D'ETIQUETTES DE SAUT
  MAX_OFFSET			: constant		:= 10_000;				--|
  MAX_LEVEL			: constant		:= 200;					--| NB MAX DE NIVEAUX D'IMBRICATION
   
  type LABEL_TYPE			is new NATURAL		range 0..MAX_LABEL;				--| TYPE ETIQUETTE
  subtype OFFSET_TYPE		is INTEGER		range -MAX_OFFSET..MAX_OFFSET;		--| TYPE DECALAGE
  subtype LEVEL_TYPE		is NATURAL		range 0..MAX_LEVEL;				--| TYPE NIVEAU D'IMBRICATION
   
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
   
  FIRST_PARAM_OFFSET		: constant OFFSET_TYPE	:= 10;
  FIRST_LOCAL_VAR_OFFSET		: constant OFFSET_TYPE	:= 0;
  RELATIVE_RESULT_OFFSET		: constant OFFSET_TYPE	:= 4;
      
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
   
  subtype COMP_UNIT_NBR		is NATURAL range 0..255;						--| SOUS TYPE NO D'UNITE DE COMPILATION
   
  CUR_COMP_UNIT			: COMP_UNIT_NBR;							--| NO D'UNITE DE COMPILATION COURANTE
  GENERATE_CODE			: BOOLEAN		:= TRUE;						--| COMMUTATEUR POUR LA GENERATION DU CODE
  CUR_LEVEL			: LEVEL_TYPE;							--| NIVEAU D'IMBRICATION COURANT
   
  OFFSET_ACT			: OFFSET_TYPE;
  OFFSET_MAX			: OFFSET_TYPE;
  TOP_ACT				: OFFSET_TYPE;							--| TOP OF STACK ACTUEL (LA PILE CROIT POSITIVEMENT)
  TOP_MAX				: OFFSET_TYPE;							--| TOP OF STACK MAXIMAL
      
  PARAM_SIZE			: NATURAL;							--| TAILLE DES PARAMETRES DE PROCEDURE EN OCTETS
  RESULT_SIZE			: NATURAL;							--| TAILLE DU RESULTAT DE FONCTION EN OCTETS
  FUN_RESULT_OFFSET			: OFFSET_TYPE	:= 0;
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

  procedure GEN_PUSH_ADDR		( COMP_UNIT_NUMBER :COMP_UNIT_NBR;
				  LVL :LEVEL_TYPE;
				  OFFSET :INTEGER;				COMMENT :STRING := "" );
  procedure GEN_PUSH_DATA		( CT :CODE_DATA_TYPE;
				  COMP_UNIT_NUMBER :COMP_UNIT_NBR;
				  LVL :LEVEL_TYPE;
				  OFFSET :INTEGER;				COMMENT :STRING := "" );
  procedure GEN_STORE		( CT :CODE_DATA_TYPE;
				  COMP_UNIT_NUMBER :COMP_UNIT_NBR;
				  LVL :LEVEL_TYPE;
				  OFFSET :INTEGER;				COMMENT :STRING := "" );
   
  function  NEW_LABEL							return LABEL_TYPE;
  procedure INC_LEVEL;
  procedure DEC_LEVEL;
  procedure INC_OFFSET		( I :INTEGER );
  procedure ALIGN			( AL :INTEGER );
       
       
  procedure PERFORM_RETURN		( ENCLOSING_BLOCK_BODY :TREE );
  function  TYPE_SIZE		( TYPE_SPEC :TREE )				return NATURAL;
  function  CODE_DATA_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )			return CODE_DATA_TYPE;
   
  function  NUMBER_OF_DIMENSIONS	( EXP :TREE )				return NATURAL;
  procedure GET_ULO			( OBJECT :TREE; COMP_UNIT :out COMP_UNIT_NBR;					--| DONNE L UNITE LE NIVEAU ET L OFFSET D UN OBJET
				  LVL :out LEVEL_TYPE; OFS :out OFFSET_TYPE );
  function  CONSTRAINED		( TYPE_SPEC :TREE ) 			return BOOLEAN;
  procedure LOAD_TYPE_SIZE		( TYPE_SPEC :TREE );


  ILLEGAL_OP_CODE, STATIC_LEVEL_OVERFLOW, STATIC_LEVEL_UNDERFLOW,
  STATIC_OFFSET_OVERFLOW	: exception;
 
	-----      
end	EMITS;
	-----