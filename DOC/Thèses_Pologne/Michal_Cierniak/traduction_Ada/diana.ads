with CG_LIB, CG_PRIVATE;
use  CG_LIB, CG_PRIVATE;
package DIANA is

	type NODE_NAME is (
			N_ABORT, N_ACCEPT, N_ACCESS, ADDRESS, AGGREGATE, ALIGNMENT, N_ALL, ALLOCATOR,
			ALTERNATIVE, ALTERNATIVE_S, ARGUMENT_ID, N_ARRAY, ASSIGN, ASSOC, ATTR_ID, 
			ATTRIBUTE, ATTRIBUTE_CALL, BINARY, BLOCK, BOX, N_CASE, CHOICE_S, CODE, 
			COMP_ID, COMP_REP, COMP_REP_S, COMP_UNIT, COMPILATION, COND_CLAUSE, 
			COND_ENTRY, CONST_ID, NCONSTANT, CONSTRAINED, CONTEXT, CONVERSION, 
			DECL_S, DEF_CHAR, DEF_OP, DEFERRED_CONSTANT, N_DELAY, DERIVED, 
			DSCRMT_AGGREGATE, DSCRMT_ID, DSCRMT_VAR, DSCRMT_VAR_S, DSCRT_RANGE_S, 
			NENTRY, ENTRY_CALL, ENTRY_ID, ENUM_ID, ENUM_LITERAL_S, NEXCEPTION, 
			EXCEPTION_ID, N_EXIT, EXP_S, FIXED, FLOAT, N_FOR, FORMAL_DSCRT, FORMAL_FIXED, 
			FORMAL_FLOAT, FORMAL_INTEGER, N_FUNCTION, FUNCTION_CALL, FUNCTION_ID, N_GENERIC, 
			GENERIC_ASSOC_S, GENERIC_ID, GENERIC_PARAM_S, N_GOTO, ID_S, N_IF, N_IN, IN_ID, 
			IN_OP, IN_OUT, IN_OUT_ID, N_INDEX, INDEXED, INNER_RECORD, INSTANTIATION, N_INTEGER, 
			ITEM_S, ITERATION_ID, L_PRIVATE, LABEL_ID, LABELED, N_LOOP, L_PRIVATE_TYPE_ID, 
			MEMBERSHIP, NAME_S, NAMED, NAMED_STM, NAMED_STM_ID, NO_DEFAULT, NOT_IN, 
			NULL_ACCESS, NULL_COMP, NULL_STM, N_NUMBER, NUMBER_ID, NUMERIC_LITERAL, N_OTHERS, 
			N_OUT, OUT_ID, PACKAGE_BODY, PACKAGE_DECL, PACKAGE_ID, PACKAGE_SPEC, PARAM_ASSOC_S, 
			PARAM_S, PARENTHESIZED, N_PRAGMA, PRAGMA_ID, PRAGMA_S, N_PRIVATE, PRIVATE_TYPE_ID, 
			PROC_ID, N_PROCEDURE, PROCEDURE_CALL, QUALIFIED, N_RAISE, N_RANGE, N_RECORD, 
			RECORD_REP, RENAME, N_RETURN, N_REVERSE, N_SELECT, SELECT_CLAUSE, SELECT_CLAUSE_S, 
			SELECTED, SIMPLE_REP, SLICE, STM_S, STRING_LITERAL, N_STUB, SUBPROGRAM_BODY, 
			SUBPROGRAM_DECL, N_SUBTYPE, SUBTYPE_ID, SUBUNIT, TASK_BODY, TASK_BODY_ID, 
			TASK_DECL, TASK_SPEC, N_TERMINATE, TIMED_ENTRY, N_TYPE, TYPE_ID, UNIVERSAL_FIXED, 
			UNIVERSAL_INTEGER, UNIVERSAL_REAL, N_USE, USED_BLTN_ID, USED_BLTN_OP, USED_CHAR, 
			USED_NAME_ID, USED_OBJECT_ID, USED_OP, N_VAR, VAR_ID, N_VARIANT, N_VARIANT_PART, 
			VARIANT_S, N_VOID, N_WHILE, N_WITH
		 );

	type NODE (KIND : NODE_NAME);
	type TREE is access NODE;
	NULL_TREE : constant TREE := null;

	type SEQ_TYPE;
	type SEQ_TYPE_PTR is access SEQ_TYPE;
	type SEQ_TYPE is record
		ELEM : TREE;
		NEXT : SEQ_TYPE_PTR;
	end record;

	type R_ABORT is record
		AS_NAME_S : TREE;
	end record;
	type AR_ABORT is access R_ABORT;

	type R_ACCEPT is record
		AS_NAME    : TREE;
		AS_PARAM_S : TREE;
		AS_STM_S   : TREE;
	end record;

	type R_ACCESS is record
		AS_CONSTRAINED  : TREE;
		SM_SIZE         : TREE;
		SM_STORAGE_SIZE : TREE;
		SM_CONTROLLED   : BOOLEAN;
		CD_LEVEL        : LEVEL_TYPE;
		CD_OFFSET       : OFFSET_TYPE;
		CD_CONSTRAINED  : BOOLEAN;
	end record;

	type R_ADDRESS is record
		AS_NAME : TREE;
		AS_EXP  : TREE;
	end record;

	type R_AGGREGATE is record
		AS_LIST              : SEQ_TYPE_PTR;
		SM_EXP_TYPE          : TREE;
		SM_CONSTRAINT        : TREE;
		SM_NORMALIZED_COMP_S : TREE;
		SM_VALUE             : VALUE;
	end record;

	type R_ALIGNMENT is record
		AS_PRAGMA_S : TREE;
		AS_EXP_VOID : TREE;
	end record;

	type R_ALL is record
		AS_NAME     : TREE;
		SM_EXP_TYPE : TREE;
	end record;

	type R_ALLOCATOR is record
		AS_EXP_CONSTRAINED : TREE;
		SM_EXP_TYPE        : TREE;
		SM_VALUE           : VALUE;
	end record;

	type R_ALTERNATIVE is record
		AS_CHOICE_S : TREE;
		AS_STM_S    : TREE;
	end record;

	type R_ALTERNATIVE_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_AND_THEN is null record;

	type R_ARGUMENT_ID is record
		LX_SYMREP : SYMBOL_REP;
	end record;

	type R_ARRAY is record
		AS_DSCRT_RANGE_S : TREE;
		AS_CONSTRAINED   : TREE;
		SM_SIZE          : TREE;
		SM_PACKING       : BOOLEAN;
		CD_COMP_UNIT     : COMP_UNIT_NBR;
		CD_LEVEL         : LEVEL_TYPE;
		CD_OFFSET        : OFFSET_TYPE;
		CD_DIMENSIONS    : COMP_UNIT_NBR;
		CD_COMPILED      : BOOLEAN;
	end record;

	type R_ASSIGN is record
		AS_NAME : TREE;
		AS_EXP  : TREE;
	end record;

	type R_ASSOC is record
		AS_DESIGNATOR : TREE;
		AS_ACTUAL     : TREE;
	end record;

	type R_ATTR_ID is record
		LX_SYMREP : SYMBOL_REP;
	end record;

	type R_ATTRIBUTE is record
		AS_ID       : TREE;
		AS_NAME     : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_ATTRIBUTE_CALL is record
		AS_EXP      : TREE;
		AS_NAME     : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_BINARY is record
		AS_EXPL      : TREE;
		AS_BINARY_OP : BINARY_OP;
		AS_EXP2      : TREE;
		SM_EXP_TYPE  : TREE;
		SM_VALUE     : VALUE;
	end record;

	type R_BLOCK is record
		AS_ITEM_S        : TREE;
		AS_STM_S         : TREE;
		AS_ALTERNATIVE_S : TREE;
		CD_LEVEL         : LEVEL_TYPE;
		CD_RETURN_LABEL  : LABEL_TYPE;
		CD_RESULT_OFFSET : OFFSET_TYPE;
	end record;

	type R_BOX is null record;

	type R_CASE is record
		AS_ALTERNATIVE_S : TREE;
		AS_EXP           : TREE;
	end record;

	type R_CHOICE_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_CODE is record
		AS_NAME : TREE;
		AS_EXP  : TREE;
	end record;

	type R_COMP_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_INIT_EXP  : TREE;
		SM_OBJ_TYPE  : TREE;
		SM_COMP_SPEC : TREE;
	end record;

	type R_COMP_REP is record
		AS_NAME  : TREE;
		AS_EXP   : TREE;
		AS_RANGE : TREE;
	end record;

	type R_COMP_REP_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_COMP_UNIT is record
		AS_PRAGMA_S  : TREE;
		AS_CONTEXT   : TREE;
		AS_UNIT_BODY : TREE;
	end record;

	type R_COMPILATION is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_COND_CLAUSE is record
		AS_EXP_VOID : TREE;
		AS_STM_S    : TREE;
	end record;

	type R_COND_ENTRY is record
		AS_STM_SL : TREE;
		AS_STM_S2 : TREE;
	end record;

	type R_CONST_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_ADDRESS   : TREE;
		SM_OBJ_TYPE  : TREE;
		SM_OBJ_DEF   : TREE;
		SM_FIRST     : TREE;
		CD_COMP_UNIT : COMP_UNIT_NBR;
		CD_LEVEL     : LEVEL_TYPE;
		CD_OFFSET    : OFFSET_TYPE;
		CD_COMPILED  : BOOLEAN;
	end record;

	type R_CONSTANT is record
		AS_ID_S       : TREE;
		AS_TYPE_SPEC  : TREE;
		AS_OBJECT_DEF : TREE;
	end record;

	type R_CONSTRAINED is record
		AS_NAME        : TREE;
		AS_CONSTRAINT  : TREE;
		CD_IMPL_SIZE   : WORD;
		CD_ALIGNMENT   : BYTE;
		SM_TYPE_STRUCT : TREE;
		SM_BASE_TYPE   : TREE;
		SM_CONSTRAINT  : TREE;
	end record;

	type R_CONTEXT is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_CONVERSION is record
		AS_NAME     : TREE;
		AS_EXP      : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_DECL_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_DEF_CHAR is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OBJ_TYPE : TREE;
		SM_POS      : WORD;
		SM_REP      : BYTE;
	end record;

	type R_DEF_OP is record
		LX_SYMREP   : SYMBOL_REP;
		SM_SPEC     : TREE;
		SM_BODY     : TREE;
		SM_LOCATION : TREE;
		SM_STUB     : TREE;
		SM_FIRST    : TREE;
	end record;

	type R_DEFERRED_CONSTANT is record
		AS_ID_S : TREE;
		AS_NAME : TREE;
	end record;

	type R_DELAY is record
		AS_EXP : TREE;
	end record;

	type R_DERIVED is record
		AS_CONSTRAINED  : TREE;
		CD_IMPL_SIZE    : WORD;
		SM_ACTUAL_DELTA : REEL;
		SM_PACKING      : BOOLEAN;
		SM_CONTROLLED   : BOOLEAN;
		SM_SIZE         : TREE;
		SM_STORAGE_SIZE : TREE;
	end record;

	type R_DSCRMT_AGGREGATE is record
		AS_LIST              : SEQ_TYPE_PTR;
		SM_NORMALIZED_COMP_S : TREE;
	end record;

	type R_DSCRMT_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_OBJ_TYPE  : TREE;
		SM_INIT_EXP  : TREE;
		SM_FIRST     : TREE;
		SM_COMP_SPEC : TREE;
	end record;

	type R_DSCRMT_VAR is record
		AS_ID_S       : TREE;
		AS_NAME       : TREE;
		AS_OBJECT_DEF : TREE;
	end record;

	type R_DSCRMT_VAR_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_DSCRT_RANGE_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_ENTRY is record
		AS_DSCRT_RANGE_VOID : TREE;
		AS_PARAM_S          : TREE;
	end record;

	type R_ENTRY_CALL is record
		AS_NAME               : TREE;
		AS_PARAM_ASSOC_S      : TREE;
		SM_NORMALIZED_PARAM_S : TREE;
	end record;

	type R_ENTRY_ID is record
		LX_SYMREP  : SYMBOL_REP;
		SM_SPEC    : TREE;
		SM_ADDRESS : TREE;
	end record;

	type R_ENUM_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OBJ_TYPE : TREE;
		SM_POS      : WORD;
		SM_REP      : WORD;
	end record;

	type R_ENUM_LITERAL_S is record
		AS_LIST      : SEQ_TYPE_PTR;
		CD_IMPL_SIZE : WORD;
		CD_ALIGNMENT : BYTE;
		SM_SIZE      : TREE;
		CD_LAST      : WORD;
	end record;

	type R_EXCEPTION is record
		AS_ID_S          : TREE;
		AS_EXCEPTION_DEF : TREE;
	end record;

	type R_EXCEPTION_ID is record
		LX_SYMREP        : SYMBOL_REP;
		SM_EXCEPTION_DEF : TREE;
		CD_LABEL         : LABEL_TYPE;
	end record;

	type R_EXIT is record
		AS_NAME_VOID : TREE;
		AS_EXP_VOID  : TREE;
		SM_STM       : TREE;
	end record;

	type R_EXP_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_FIXED is record
		AS_EXP          : TREE;
		AS_RANGE_VOID   : TREE;
		CD_IMPL_SIZE    : WORD;
		SM_SIZE         : TREE;
		SM_ACTUAL_DELTA : REEL;
		SM_BITS         : BYTE;
		SM_BASE_TYPE    : TREE;
	end record;

	type R_FLOAT is record
		AS_EXP         : TREE;
		AS_RANGE_VOID  : TREE;
		CD_ALIGNMENT   : BYTE;
		SM_SIZE        : TREE;
		SM_TYPE_STRUCT : TREE;
		SM_BASE_TYPE   : TREE;
	end record;

	type R_FOR is record
		AS_ID          : TREE;
		AS_DSCRT_RANGE : TREE;
	end record;

	type R_FORMAL_DSCRT is null record;
	type R_FORMAL_FIXED is null record;
	type R_FORMAL_FLOAT is null record;
	type R_FORMAL_INTEGER is null record;

	type R_FUNCTION is record
		AS_NAME_VOID : TREE;
		AS_PARAM_S   : TREE;
	end record;

	type R_FUNCTION_CALL is record
		AS_NAME               : TREE;
		AS_PARAM_ASSOC_S      : TREE;
		SM_EXP_TYPE           : TREE;
		SM_VALUE              : VALUE;
		SM_NORMALIZED_PARAM_S : TREE;
		LX_PREFIX             : BOOLEAN;
	end record;

	type R_FUNCTION_ID is record
		LX_SYMREP      : SYMBOL_REP;
		SM_SPEC        : TREE;
		SM_BODY        : TREE;
		SM_LOCATION    : TREE;
		SM_STUB        : TREE;
		SM_FIRST       : TREE;
		CD_LABEL       : LABEL_TYPE;
		CD_LEVEL       : LEVEL_TYPE;
		CD_PARAM_SIZE  : OFFSET_TYPE;
		CD_RESULT_SIZE : OFFSET_TYPE;
		CD_COMPILED    : BOOLEAN;
	end record;

	type R_GENERIC is record
		AS_ID              : TREE;
		AS_GENERIC_PARAM_S : TREE;
		AS_GENERIC_HEADER  : TREE;
	end record;

	type R_GENERIC_ASSOC_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_GENERIC_ID is record
		LX_SYMREP          : SYMBOL_REP;
		SM_GENERIC_PARAM_S : TREE;
		SM_SPEC            : TREE;
		SM_BODY            : TREE;
		SM_STUB            : TREE;
		SM_FIRST           : TREE;
	end record;

	type R_GENERIC_PARAM_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_GOTO is record
		AS_NAME : TREE;
	end record;

	type R_ID_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_IF is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_IN is record
		AS_EXP_VOID : TREE;
		AS_ID_S     : TREE;
		AS_NAME     : TREE;
		LX_DEFAULT  : BOOLEAN;
	end record;

	type R_IN_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OBJ_TYPE : TREE;
		SM_INIT_EXP : TREE;
		SM_FIRST    : TREE;
		CD_LEVEL    : LEVEL_TYPE;
		CD_OFFSET   : OFFSET_TYPE;
	end record;

	type R_IN_OP is null record;

	type R_IN_OUT is record
		AS_EXP_VOID : TREE;
		AS_ID_S     : TREE;
		AS_NAME     : TREE;
	end record;

	type R_IN_OUT_ID is record
		LX_SYMREP      : SYMBOL_REP;
		SM_OBJ_TYPE    : TREE;
		SM_FIRST       : TREE;
		CD_LEVEL       : LEVEL_TYPE;
		CD_ADDR_OFFSET : OFFSET_TYPE;
		CD_VAL_OFFSET  : OFFSET_TYPE;
	end record;

	type R_INDEX is record
		AS_NAME : TREE;
	end record;

	type R_INDEXED is record
		AS_NAME     : TREE;
		AS_EXP_S    : TREE;
		SM_EXP_TYPE : TREE;
	end record;

	type R_INNER_RECORD is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_INSTANTIATION is record
		AS_NAME            : TREE;
		AS_GENERIC_ASSOC_S : TREE;
		SM_DECL_S          : TREE;
	end record;

	type R_INTEGER is record
		AS_RANGE       : TREE;
		CD_IMPL_SIZE   : WORD;
		SM_SIZE        : TREE;
		SM_TYPE_STRUCT : TREE;
		SM_BASE_TYPE   : TREE;
		CD_COMP_UNIT   : COMP_UNIT_NBR;
		CD_LEVEL       : LEVEL_TYPE;
		CD_OFFSET      : OFFSET_TYPE;
		CD_COMPILED    : BOOLEAN;
	end record;

	type R_ITEM_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_ITERATION_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OBJ_TYPE : TREE;
		CD_LEVEL    : LEVEL_TYPE;
		CD_OFFSET   : OFFSET_TYPE;
	end record;

	type R_L_PRIVATE is record
		SM_DISCRIMINANTS : TREE;
	end record;

	type R_L_PRIVATE_TYPE_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_TYPE_SPEC : TREE;
	end record;

	type R_LABEL_ID is record
		LX_SYMREP : SYMBOL_REP;
		SM_STM    : TREE;
	end record;

	type R_LABELED is record
		AS_ID_S : TREE;
		AS_STM  : TREE;
	end record;

	type R_LOOP is record
		AS_ITERATION        : TREE;
		AS_STM_S            : TREE;
		CD_LEVEL            : LEVEL_TYPE;
		CD_AFTER_LOOP_LABEL : LABEL_TYPE;
	end record;

	type R_MEMBERSHIP is record
		AS_EXP           : TREE;
		AS_MEMBERSHIP_OP : TREE;
		AS_TYPE_RANGE    : TREE;
		SM_EXP_TYPE      : TREE;
		SM_VALUE         : VALUE;
	end record;

	type R_NAME_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_NAMED is record
		AS_CHOICE_S : TREE;
		AS_EXP      : TREE;
	end record;

	type R_NAMED_STM is record
		AS_ID  : TREE;
		AS_STM : TREE;
	end record;

	type R_NAMED_STM_ID is record
		LX_SYMREP : SYMBOL_REP;
		SM_STM    : TREE;
		CD_LABEL  : LABEL_TYPE;
	end record;

	type R_NO_DEFAULT is null record;

	type R_NOT_IN is null record;

	type R_NULL_ACCESS is record
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_NULL_COMP is null record;

	type R_NULL_STM is null record;

	type R_NUMBER is record
		AS_ID_S : TREE;
		AS_EXP  : TREE;
	end record;

	type R_NUMBER_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OBJ_TYPE : TREE;
		SM_INIT_EXP : TREE;
	end record;

	type R_NUMERIC_LITERAL is record
		LX_NUMREP   : NUMBER_REP;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_OTHERS is null record;

	type R_OUT is record
		AS_EXP_YOID : TREE;
		AS_ID_S     : TREE;
		AS_NAME     : TREE;
	end record;

	type R_OUT_ID is record
		LX_SYMREP      : SYMBOL_REP;
		SM_OBJ_TYPE    : TREE;
		SM_FIRST       : TREE;
		CD_LEVEL       : LEVEL_TYPE;
		CD_ADDR_OFFSET : OFFSET_TYPE;
		CD_VAL_OFFSET  : OFFSET_TYPE;
	end record;

	type R_PACKAGE_BODY is record
		AS_ID         : TREE;
		AS_BLOCK_STUB : TREE;
	end record;

	type R_PACKAGE_DECL is record
		AS_ID          : TREE;
		AS_PACKAGE_DEF : TREE;
	end record;


	type R_PACKAGE_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_SPEC     : TREE;
		SM_BODY     : TREE;
		SM_ADDRESS  : TREE;
		SM_STUB     : TREE;
		SM_FIRST    : TREE;
		CD_COMPILED : BOOLEAN;
	end record;

	type R_PACKAGE_SPEC is record
		AS_DECL_S1 : TREE;
		AS_DECL_S2 : TREE;
	end record;

	type R_PARAM_ASSOC_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_PARAM_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_PARENTHESIZED is record
		AS_EXP      : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_PRAGMA is record
		AS_ID            : TREE;
		AS_PARAM_ASSOC_S : TREE;
	end record;

	type R_PRAGMA_ID is record
		AS_LIST   : SEQ_TYPE_PTR;
		LX_SYMREP : SYMBOL_REP;
	end record;

	type R_PRAGMA_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_PRIVATE is record
		SM_DISCRIMINANTS : TREE;
	end record;

	type R_PRIVATE_TYPE_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_TYPE_SPEC : TREE;
	end record;

	type R_PROC_ID is record
		LX_SYMREP     : SYMBOL_REP;
		SM_SPEC       : TREE;
		SM_BODY       : TREE;
		SM_LOCATION   : TREE;
		SM_STUB       : TREE;
		SM_FIRST      : TREE;
		CD_LABEL      : LABEL_TYPE;
		CD_LEVEL      : LEVEL_TYPE;
		CD_PARAM_SIZE : OFFSET_TYPE;
		CD_COMPILED   : BOOLEAN;
	end record;

	type R_PROCEDURE is record
		AS_PARAM_S : TREE;
	end record;

	type R_PROCEDURE_CALL is record
		AS_NAME               : TREE;
		AS_PARAM_ASSOC_S      : TREE;
		SM_NORMALIZED_PARAM_S : TREE;
	end record;

	type R_QUALIFIED is record
		AS_NAME     : TREE;
		AS_EXP      : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_RAISE is record
		AS_NAME_VOID : TREE;
	end record;

	type R_RANGE is record
		AS_EXPL      : TREE;
		AS_EXP2      : TREE;
		SM_BASE_TYPE : TREE;
	end record;

	type R_RECORD is record
		AS_LIST          : SEQ_TYPE_PTR;
		SM_PACKING       : BOOLEAN;
		SM_DISCRIMINANTS : TREE;
		SM_SIZE          : TREE;
		SM_RECORD_SPEC   : TREE;
	end record;

	type R_RECORD_REP is record
		AS_ALIGNMENT  : TREE;
		AS_NAME       : TREE;
		AS_COMP_REP_S : TREE;
	end record;

	type R_RENAME is record
		AS_NAME : TREE;
	end record;

	type R_RETURN is record
		AS_EXP_VOID : TREE;
	end record;

	type R_REVERSE is record
		AS_ID          : TREE;
		AS_DSCRT_RANGE : TREE;
	end record;

	type R_SELECT is record
		AS_STM_S           : TREE;
		AS_SELECT_CLAUSE_S : TREE;
	end record;

	type R_SELECT_CLAUSE is record
		AS_EXP_VOID : TREE;
		AS_STM_S    : TREE;
	end record;

	type R_SELECT_CLAUSE_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_SELECTED is record
		AS_NAME            : TREE;
		AS_DESIGNATOR_CHAR : TREE;
		SM_EXP_TYPE        : TREE;
	end record;

	type R_SIMPLE_REP is record
		AS_NAME : TREE;
		AS_EXP  : TREE;
	end record;

	type R_SLICE is record
		AS_NAME        : TREE;
		AS_DSCRT_RANGE : TREE;
		SM_EXP_TYPE    : TREE;
		SM_CONSTRAINT  : TREE;
	end record;

	type R_STM_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_STRING_LITERAL is record
		LX_SYMREP     : SYMBOL_REP;
		SM_EXP_TYPE   : TREE;
		SM_CONSTRAINT : TREE;
		SM_VALUE      : VALUE;
	end record;

	type R_STUB is null record;

	type R_SUBPROGRAM_BODY is record
		AS_DESIGNATOR : TREE;
		AS_HEADER     : TREE;
		AS_BLOCK_STUB : TREE;
	end record;

	type R_SUBPROGRAM_DECL is record
		AS_DESIGNATOR     : TREE;
		AS_HEADER         : TREE;
		AS_SUBPROGRAM_DEF : TREE;
	end record;

	type R_SUBTYPE is record
		AS_CONSTRAINED : TREE;
		AS_ID          : TREE;
	end record;

	type R_SUBTYPE_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_TYPE_SPEC : TREE;
	end record;

	type R_SUBUNIT is record
		AS_NAME         : TREE;
		AS_SUBUNIT_BODY : TREE;
	end record;

	type R_TASK_BODY is record
		AS_ID         : TREE;
		AS_BLOCK_STUB : TREE;
	end record;

	type R_TASK_BODY_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_TYPE_SPEC : TREE;
		SM_BODY      : TREE;
		SM_STUB      : TREE;
		SM_FIRST     : TREE;
	end record;

	type R_TASK_DECL is record
		AS_ID       : TREE;
		AS_TASK_DEF : TREE;
	end record;

	type R_TASK_SPEC is record
		AS_DECL_S       : TREE;
		SM_BODY         : TREE;
		SM_ADDRESS      : TREE;
		SM_STORAGE_SIZE : TREE;
	end record;

	type R_TERMINATE is null record;

	type R_TIMED_ENTRY is record
		AS_STM_SL : TREE;
		AS_STM_S2 : TREE;
	end record;

	type R_TYPE is record
		AS_ID           : TREE;
		AS_DSCRMT_VAR_S : TREE;
		AS_TYPE_SPEC    : TREE;
	end record;

	type R_TYPE_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_TYPE_SPEC : TREE;
		SM_FIRST     : TREE;
	end record;

	type R_UNIVERSAL_FIXED is null record;

	type R_UNIVERSAL_INTEGER is null record;

	type R_UNIVERSAL_REAL is null record;

	type R_USE is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_USED_BLTN_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OPERATOR : OPERATOR;
	end record;

	type R_USED_BLTN_OP is record
		LX_SYMREP   : SYMBOL_REP;
		SM_OPERATOR : OPERATOR;
	end record;

	type R_USED_CHAR is record
		LX_SYMREP   : SYMBOL_REP;
		SM_DEFN     : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_USED_NAME_ID is record
		LX_SYMREP : SYMBOL_REP;
		SM_DEFN   : TREE;
	end record;

	type R_USED_OBJECT_ID is record
		LX_SYMREP   : SYMBOL_REP;
		SM_DEFN     : TREE;
		SM_EXP_TYPE : TREE;
		SM_VALUE    : VALUE;
	end record;

	type R_USED_OP is record
		LX_SYMREP : SYMBOL_REP;
		SM_DEFN   : TREE;
	end record;

	type R_VAR is record
		AS_ID_S       : TREE;
		AS_TYPE_SPEC  : TREE;
		AS_OBJECT_DEF : TREE;
	end record;

	type R_VAR_ID is record
		LX_SYMREP    : SYMBOL_REP;
		SM_ADDRESS   : TREE;
		SM_OBJ_TYPE  : TREE;
		SM_OBJ_DEF   : TREE;
		CD_COMP_UNIT : COMP_UNIT_NBR;
		CD_LEVEL     : LEVEL_TYPE;
		CD_OFFSET    : OFFSET_TYPE;
		CD_COMPILED  : BOOLEAN;
	end record;

	type R_VARIANT is record
		AS_CHOICE_S : TREE;
		AS_RECORD   : TREE;
	end record;

	type R_VARIANT_PART is record
		AS_NAME      : TREE;
		AS_VARIANT_S : TREE;
	end record;

	type R_VARIANT_S is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type R_VOID is null record;

	type R_WHILE is record
		AS_EXP : TREE;
	end record;

	type R_WITH is record
		AS_LIST : SEQ_TYPE_PTR;
	end record;

	type NODE (KIND : NODE_NAME) is record
		LX_SRCPOS : SOURCE_POSITION;
		case KIND is
			when N_ABORT =>
				C_ABORT             : R_ABORT;
			when N_ACCEPT =>
				C_ACCEPT            : R_ACCEPT;
			when N_ACCESS =>
				C_ACCESS            : R_ACCESS;
			when ADDRESS =>
				C_ADDRESS           : R_ADDRESS;
			when AGGREGATE =>
				C_AGGREGATE         : R_AGGREGATE;
			when ALIGNMENT =>
				C_ALIGNMENT         : R_ALIGNMENT;
			when N_ALL =>
				C_ALL               : R_ALL;
			when ALLOCATOR =>
				C_ALLOCATOR         : R_ALLOCATOR;
			when ALTERNATIVE =>
				C_ALTERNATIVE       : R_ALTERNATIVE;
			when ALTERNATIVE_S =>
				C_ALTERNATIVE_S     : R_ALTERNATIVE_S;
			when ARGUMENT_ID =>
				C_ARGUMENT_ID       : R_ARGUMENT_ID;
			when N_ARRAY =>
				C_ARRAY             : R_ARRAY;
			when ASSIGN =>
				C_ASSIGN            : R_ASSIGN;
			when ASSOC =>
				C_ASSOC             : R_ASSOC;
			when ATTR_ID =>
				C_ATTR_ID           : R_ATTR_ID;
			when ATTRIBUTE =>
				C_ATTRIBUTE         : R_ATTRIBUTE;
			when ATTRIBUTE_CALL =>
				C_ATTRIBUTE_CALL    : R_ATTRIBUTE_CALL;
			when BINARY =>
				C_BINARY            : R_BINARY;
			when BLOCK =>
				C_BLOCK             : R_BLOCK;
			when BOX =>
				C_BOX               : R_BOX;
			when N_CASE =>
				C_CASE              : R_CASE;
			when CHOICE_S =>
				C_CHOICE_S          : R_CHOICE_S;
			when CODE =>
				C_CODE              : R_CODE;
			when COMP_ID =>
				C_COMP_ID           : R_COMP_ID;
			when COMP_REP =>
				C_COMP_REP          : R_COMP_REP;
			when COMP_REP_S =>
				C_COMP_REP_S        : R_COMP_REP_S;
			when COMP_UNIT =>
				C_COMP_UNIT         : R_COMP_UNIT;
			when COMPILATION =>
				C_COMPILATION       : R_COMPILATION;
			when COND_CLAUSE =>
				C_COND_CLAUSE       : R_COND_CLAUSE;
			when COND_ENTRY =>
				C_COND_ENTRY        : R_COND_ENTRY;
			when CONST_ID =>
				C_CONST_ID          : R_CONST_ID;
			when NCONSTANT =>
				C_CONSTANT          : R_CONSTANT;
			when CONSTRAINED =>
				C_CONSTRAINED       : R_CONSTRAINED;
			when CONTEXT =>
				C_CONTEXT           : R_CONTEXT;
			when CONVERSION =>
				C_CONVERSION        : R_CONVERSION;
			when DECL_S =>
				C_DECL_S            : R_DECL_S;
			when DEF_CHAR =>
				C_DEF_CHAR          : R_DEF_CHAR;
			when DEF_OP =>
				C_DEF_OP            : R_DEF_OP;
			when DEFERRED_CONSTANT =>
				C_DEFERED_CONSTANT  : R_DEFERRED_CONSTANT;
			when N_DELAY =>
				C_DELAY             : R_DELAY;
			when DERIVED =>
				C_DERIVED           : R_DERIVED;
			when DSCRMT_AGGREGATE =>
				C_DSCRMT_AGGREGATE  : R_DSCRMT_AGGREGATE;
			when DSCRMT_ID =>
				C_DSCRMT_ID         : R_DSCRMT_ID;
			when DSCRMT_VAR =>
				C_DSCRMT_VAR        : R_DSCRMT_VAR;
			when DSCRMT_VAR_S =>
				C_DSCRMT_VAR_S      : R_DSCRMT_VAR_S;
			when DSCRT_RANGE_S =>
				C_DSCRT_RANGE_S     : R_DSCRT_RANGE_S;
			when NENTRY =>
				C_ENTRY             : R_ENTRY;
			when ENTRY_CALL =>
				C_ENTRY_CALL        : R_ENTRY_CALL;
			when ENTRY_ID =>
				C_ENTRY_ID          : R_ENTRY_ID;
			when ENUM_ID =>
				C_ENUM_ID           : R_ENUM_ID;
			when ENUM_LITERAL_S =>
				C_ENUM_LITERAL_S    : R_ENUM_LITERAL_S;
			when NEXCEPTION =>
				C_EXCEPTION         : R_EXCEPTION;
			when EXCEPTION_ID =>
				C_EXCEPTION_ID      : R_EXCEPTION_ID;
			when N_EXIT =>
				C_EXIT              : R_EXIT;
			when EXP_S =>
				C_EXP_S             : R_EXP_S;
			when FIXED =>
				C_FIXED             : R_FIXED;
			when FLOAT =>
				C_FLOAT             : R_FLOAT;
			when N_FOR =>
				C_FOR               : R_FOR;
			when FORMAL_DSCRT =>
				C_FORMAL_DSCRT      : R_FORMAL_DSCRT;
			when FORMAL_FIXED =>
				C_FORMAL_FIXED      : R_FORMAL_FIXED;
			when FORMAL_FLOAT =>
				C_FORMAL_FLOAT      : R_FORMAL_FLOAT;
			when FORMAL_INTEGER =>
				C_FORMAL_INTEGER    : R_FORMAL_INTEGER;
			when N_FUNCTION =>
				C_FUNCTION          : R_FUNCTION;
			when FUNCTION_CALL =>
				C_FUNCTION_CALL     : R_FUNCTION_CALL;
			when FUNCTION_ID =>
				C_FUNCTION_ID       : R_FUNCTION_ID;
			when N_GENERIC =>
				C_GENERIC           : R_GENERIC;
			when GENERIC_ASSOC_S =>
				C_GENERIC_ASSOC_S   : R_GENERIC_ASSOC_S;
			when GENERIC_ID =>
				C_GENERIC_ID        : R_GENERIC_ID;
			when GENERIC_PARAM_S =>
				C_GENERIC_PARAM_S   : R_GENERIC_PARAM_S;
			when N_GOTO =>
				C_GOTO              : R_GOTO;
			when ID_S =>
				C_ID_S              : R_ID_S;
			when N_IF =>
				C_IF                : R_IF;
			when N_IN =>
				C_IN                : R_IN;
			when IN_ID =>
				C_IN_ID             : R_IN_ID;
			when IN_OP =>
				C_IN_OP             : R_IN_OP;
			when IN_OUT =>
				C_IN_OUT            : R_IN_OUT;
			when IN_OUT_ID =>
				C_IN_OUT_ID         : R_IN_OUT_ID;
			when N_INDEX =>
				C_INDEX             : R_INDEX;
			when INDEXED =>
				C_INDEXED           : R_INDEXED;
			when INNER_RECORD =>
				C_INNER_RECORD      : R_INNER_RECORD;
			when INSTANTIATION =>
				C_INSTATIATION      : R_INSTANTIATION;
			when N_INTEGER =>
				C_INTEGER           : R_INTEGER;
			when ITEM_S =>
				C_ITEM_S            : R_ITEM_S;
			when ITERATION_ID =>
				C_ITERATION_ID      : R_ITERATION_ID;
			when L_PRIVATE =>
				C_L_PRIVATE         : R_L_PRIVATE;
			when LABEL_ID =>
				C_LABEL_ID          : R_LABEL_ID;
			when LABELED =>
				C_LABELED           : R_LABELED;
			when N_LOOP =>
				C_LOOP              : R_LOOP;
			when L_PRIVATE_TYPE_ID =>
				C_L_PRIVATE_TYPE_ID : R_L_PRIVATE_TYPE_ID;
			when MEMBERSHIP =>
				C_MEMBERSHIP        : R_MEMBERSHIP;
			when NAME_S =>
				C_NAME_S            : R_NAME_S;
			when NAMED =>
				C_NAMED             : R_NAMED;
			when NAMED_STM =>
				C_NAMED_STM         : R_NAMED_STM;
			when NAMED_STM_ID =>
				C_NAMED_STM_ID      : R_NAMED_STM_ID;
			when NO_DEFAULT =>
				C_NO_DEFAULT        : R_NO_DEFAULT;
			when NOT_IN =>
				C_NOT_IN            : R_NOT_IN;
			when NULL_ACCESS =>
				C_NULL_ACCESS       : R_NULL_ACCESS;
			when NULL_COMP =>
				C_NULL_COMP         : R_NULL_COMP;
			when NULL_STM =>
				C_NULL_STM          : R_NULL_STM;
			when N_NUMBER =>
				C_NUMBER            : R_NUMBER;
			when NUMBER_ID =>
				C_NUMBER_ID         : R_NUMBER_ID;
			when NUMERIC_LITERAL =>
				C_NUMERIC_LITERAL   : R_NUMERIC_LITERAL;
			when N_others =>
				C_OTHERS            : R_OTHERS;
			when N_OUT =>
				C_OUT               : R_OUT;
			when OUT_ID =>
				C_OUT_ID            : R_OUT_ID;
			when PACKAGE_BODY =>
				C_PACKAGE_BODY      : R_PACKAGE_BODY;
			when PACKAGE_DECL =>
				C_PACKAGE_DECL      : R_PACKAGE_DECL;
			when PACKAGE_ID =>
				C_PACKAGE_ID        : R_PACKAGE_ID;
			when PACKAGE_SPEC =>
				C_PACKAGE_SPEC      : R_PACKAGE_SPEC;
			when PARAM_ASSOC_S =>
				C_PARAM_ASSOC_S     : R_PARAM_ASSOC_S;
			when PARAM_S =>
				C_PARAM_S           : R_PARAM_S;
			when PARENTHESIZED =>
				C_PARENTHESIZED     : R_PARENTHESIZED;
			when N_PRAGMA =>
				C_PRAGMA            : R_PRAGMA;
			when PRAGMA_ID =>
				C_PRAGMA_ID         : R_PRAGMA_ID;
			when PRAGMA_S =>
				C_PRAGMA_S          : R_PRAGMA_S;
			when N_PRIVATE =>
				C_PRIVATE           : R_PRIVATE;
			when PRIVATE_TYPE_ID =>
				C_PRIVATE_TYPE_ID   : R_PRIVATE_TYPE_ID;
			when PROC_ID =>
				C_PROC_ID           : R_PROC_ID;
			when N_PROCEDURE =>
				C_PROCEDURE         : R_PROCEDURE;
			when PROCEDURE_CALL =>
				C_PROCEDURE_CALL    : R_PROCEDURE_CALL;
			when QUALIFIED =>
				C_QUALIFIED         : R_QUALIFIED;
			when N_RAISE =>
				C_RAISE             : R_RAISE;
			when N_RANGE =>
				C_RANGE             : R_RANGE;
			when N_RECORD =>
				C_RECORD            : R_RECORD;
			when RECORD_REP =>
				C_RECORD_REP        : R_RECORD_REP;
			when RENAME =>
				C_RENAME            : R_RENAME;
			when N_RETURN =>
				C_RETURN            : R_RETURN;
			when N_REVERSE =>
				C_REVERSE           : R_REVERSE;
			when N_SELECT =>
				C_SELECT            : R_SELECT;
			when SELECT_CLAUSE =>
				C_SELECT_CLAUSE      : R_SELECT_CLAUSE;
			when SELECT_CLAUSE_S =>
				C_SELECT_CLAUSE_S   : R_SELECT_CLAUSE_S;
			when SELECTED =>
				C_SELECTED          : R_SELECTED;
			when SIMPLE_REP =>
				C_SIMPLE_REP        : R_SIMPLE_REP;
			when SLICE =>
				C_SLICE             : R_SLICE;
			when STM_S =>
				C_STM_S             : R_STM_S;
			when STRING_LITERAL =>
				C_STRING_LITERAL    : R_STRING_LITERAL;
			when N_STUB =>
				C_STUB              : R_STUB;
			when SUBPROGRAM_BODY =>
				C_SUBPROGRAM_BODY   : R_SUBPROGRAM_BODY;
			when SUBPROGRAM_DECL =>
				C_SUBPROGRAM_DECL   : R_SUBPROGRAM_DECL;
			when N_SUBTYPE =>
				C_SUBTYPE           : R_SUBTYPE;
			when SUBTYPE_ID =>
				C_SUBTYPE_ID        : R_SUBTYPE_ID;
			when SUBUNIT =>
				C_SUBUNIT           : R_SUBUNIT;
			when TASK_BODY =>
				C_TASK_BODY         : R_TASK_BODY;
			when TASK_BODY_ID =>
				C_TASK_BODY_ID      : R_TASK_BODY_ID;
			when TASK_DECL =>
				C_TASK_DECL         : R_TASK_DECL;
			when TASK_SPEC =>
				C_TASK_SPEC         : R_TASK_SPEC;
			when N_TERMINATE =>
				C_TERMINATE         : R_TERMINATE;
			when TIMED_ENTRY =>
				C_TIMED_ENTRY       : R_TIMED_ENTRY;
			when N_TYPE =>
				C_TYPE              : R_TYPE;
			when TYPE_ID =>
				C_TYPE_ID           : R_TYPE_ID;
			when UNIVERSAL_FIXED =>
				C_UNIVERSAL_FIXED   : R_UNIVERSAL_FIXED;
			when UNIVERSAL_INTEGER =>
				C_UNIVERSAL_INTEGER : R_UNIVERSAL_INTEGER;
			when UNIVERSAL_REAL =>
				C_UNIVERSAL_REAL    : R_UNIVERSAL_REAL;
			when N_USE =>
				C_USE               : R_USE;
			when USED_BLTN_ID =>
				C_USED_BLTN_ID      : R_USED_BLTN_ID;
			when USED_BLTN_OP =>
				C_USED_BLTN_OP      : R_USED_BLTN_OP;
			when USED_CHAR =>
				C_USED_CHAR         : R_USED_CHAR;
			when USED_NAME_ID =>
				C_USED_NAME_ID      : R_USED_NAME_ID;
			when USED_OBJECT_ID =>
				C_USED_OBJECT_ID    : R_USED_OBJECT_ID;
			when USED_OP =>
				C_USED_OP           : R_USED_OP;
			when N_VAR =>
				C_VAR               : R_VAR;
			when VAR_ID =>
				C_VAR_ID            : R_VAR_ID;
			when N_VARIANT =>
				C_VARIANT           : R_VARIANT;
			when N_VARIANT_PART =>
				C_VARIANT_PART      : R_VARIANT_PART;
			when VARIANT_S =>
				C_VARIANT_S         : R_VARIANT_S;
			when N_VOID =>
				C_VOID              : R_VOID;
			when N_WHILE =>
				C_WHILE             : R_WHILE;
			when N_WITH =>
				C_WITH              : R_WITH;
		end case;
	end record;

	function KIND (T : TREE) return NODE_NAME;
	procedure GET_NODE (T : TREE; ND : NODE);
	function GET_NODE (T :in TREE ) return NODE;
	procedure PUT_NODE (T : TREE; ND : NODE);
	function GET_EMPTY return SEQ_TYPE;
	function HEAD (L : SEQ_TYPE) return TREE;
	function TAIL (L : SEQ_TYPE) return SEQ_TYPE;
	function IS_EMPTY (L : SEQ_TYPE) return BOOLEAN;
	function INSERT (L : SEQ_TYPE; T : TREE) return SEQ_TYPE;
	function APPEND (L : SEQ_TYPE; T : TREE) return SEQ_TYPE;
							
end DIANA;
