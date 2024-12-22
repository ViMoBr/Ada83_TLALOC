with CG_LIB, CG_PRIVATE, CG1, DIANA;
use  CG_LIB, CG_PRIVATE, CG1, DIANA;

package CG_EXPR is

	STD_BOOLEAN   : constant := 13;
	STD_INTEGER   : constant := 19;
	STD_CHARACTER : constant := 32;

	procedure LOADPARAMS(T_NORMALIZED_PARAM_S : in TREE);
	procedure COMPILEEXPRESSION (T_EXPR : in TREE);
	function  BOOLEANTYPE (T_TYPE_SPEC : in TREE) return BOOLEAN;
	function  CHARACTERTYPE (T_TYPE_SPEC : in TREE) return BOOLEAN;
	function  ACODETYPE (T_TYPE_SPEC : in TREE) return ACODETYPES;
	procedure LOADADDRESS_INDEXED (T_INDEXED : in TREE);
	procedure LOADOBJECTADDRESS (T_OBJECT : in TREE);
	procedure LOADADDRESS (T_OBJECT : in TREE);
	function  TYPESTRUCT (T_TYPE : in TREE) return TREE;
	function  TYPESTRUCTOFEXPR (T_EXP : in TREE) return TREE;
	function  CONSTRAINED (T_TYPE_SPEC : in TREE) return BOOLEAN;
	function  TYPESIZE (T : in TREE) return INTEGER;
	procedure LOADTYPESIZE (T : in TREE);
	function  LEVELOFTYPE (T_TYPE_SPEC : in TREE) return LEVEL_TYPE;
	procedure GETCLO (T : in TREE; COMPUNITNR : out BYTE; LVL: out LEVEL_TYPE; OFFS       : out OFFSET_TYPE);

end CG_EXPR;
