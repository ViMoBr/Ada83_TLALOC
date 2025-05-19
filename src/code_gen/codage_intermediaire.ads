-------------------------------------------------------------------------------------------------------------------------
-- CC BY SA	CODAGE_INTERMEDIAIRE.ADS	VINCENT MORIN	21/6/2024	UNIVERSITE DE BRETAGNE OCCIDENTALE
-------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO, IDL;
use  TEXT_IO, IDL;

			--------------------
	package		CODAGE_INTERMEDIAIRE
			--------------------

is

  DEBUG				: BOOLEAN	:= TRUE;

  tab				: CHARACTER	renames ASCII.HT;

  MAX_INSTR			: constant		:= 10_000;				--| NB MAX D'INSTRUCTIONS
  MAX_LABEL			: constant		:= 10_000;				--| NB MAX D'ETIQUETTES DE SAUT
  MAX_UNIT			: constant		:= 2**11-1;				--| NB MAX D'UNITES PROGRAMME
  MAX_LEVEL			: constant		:= 2**5-1;				--| NB MAX DE NIVEAUX D'IMBRICATION
  MAX_OFFSET			: constant		:= 2**15-1;				--| 32K

  type LABEL_TYPE			is new NATURAL		range 0 .. MAX_LABEL;			--| TYPE ETIQUETTE
  subtype UNIT_NUM			is INTEGER		range 0 .. MAX_UNIT;
  subtype LEVEL_NUM			is NATURAL		range 0 .. MAX_LEVEL;
  subtype OFFSET_VAL		is INTEGER		range -MAX_OFFSET .. MAX_OFFSET;

  ADDR_SIZE			: constant		:= 8;					--| ADRESSES SUR 64 BITS
  BOOL_SIZE			: constant		:= 1;					--| BOOLEEN SUR 1 OCTET
  CHAR_SIZE			: constant		:= 1;					--| CARACTERE SUR 8 BITS
  INTG_SIZE			: constant		:= 4;					--| ENTIER SUR 32 BITS

  type LOOP_CODE			is (
 		DEC,   GT,    INC,   LT 		);

  OUTPUT_CODE			: BOOLEAN			:= TRUE;					-- Dans le traitement de spécif on désactive le codage
  IN_GENERIC_DECL			: BOOLEAN			:= FALSE;					-- Traitement special pour les spec d instantiation

  CUR_LEVEL			: LEVEL_NUM;							--| NIVEAU D'IMBRICATION COURANT
  CUR_OFFSET			: OFFSET_VAL		:= 0;
--  SKIP_LBL, HANDLER_BEGIN_LBL	: LABEL_TYPE;
  NO_SUBP_PARAMS			: BOOLEAN			:= TRUE;					--| pour prms et prm_siz
  ENCLOSING_BODY			: TREE;
  CHOICE_OTHERS_FLAG		: BOOLEAN			:= FALSE;
-- AFTER_IF_LBL			: LABEL_TYPE;
--    
-- BEFORE_LOOP_LBL			: LABEL_TYPE;
-- AFTER_LOOP_LBL			: LABEL_TYPE;
  LOOP_STM_S			: TREE;
  LOOP_OP_INC_DEC			: LOOP_CODE;							--| POUR LE TRAITEMENT DES BOUCLES FOR REVERSE
  LOOP_OP_GT_LT			: LOOP_CODE;							--| DE MEME
--   
  TYPE_SYMREP			: TREE;								--| UTILISE POUR LES OBJECT_DECL VAR CONST


      
  procedure OPEN_OUTPUT_FILE		( FILE_NAME :STRING );
  procedure CLOSE_OUTPUT_FILE;


  function  OPER_SIZ_CHAR		( DEFN :TREE )			return CHARACTER;
  function  EXP_TYPE_CHAR		( EXP :TREE )			return CHARACTER;
   
  function  NEW_LABEL						return LABEL_TYPE;
  function  NEW_LABEL						return STRING;
  function  LABEL_STR		( LBL : LABEL_TYPE )		return STRING;

  procedure INC_LEVEL;
  procedure DEC_LEVEL;
  function  CODE_DATA_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )		return CHARACTER;
  procedure LOAD_MEM		( DEFN :TREE );
  procedure STORE			( DEST_DEFN :TREE );
  function  TAB50							return STRING;

  function  IMAGE			( I : NATURAL )			return STRING;

  OPERAND_OVERFLOW	 		: exception;


end	CODAGE_INTERMEDIAIRE;
	--------------------
