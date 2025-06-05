			------------
	package		MACHINE_CODE
			------------

is

  type ASM_OPCODE		is (ET,	OU,	NON,	OUX,	SYSCALL,	SYS_PUT_CHAR,	SYS_PUT_STR,	SYS_GET_CHAR,	SYS_GET_STR,
			    SYS_FILE_CREATE, SYS_FILE_OPEN, SYS_FILE_CLOSE, SYS_FILE_DELETE,
			    DB,	LI,	LIF,	LCA,	LINK,	UNLINK,
			    LB,	LW,	LD,	LQ,	LA,
			    LIB,	LIW,	LID,	LIQ,	LIA,	LVA,
			    SB,	SW,	SD,	SQ,	SA,
			    SIB,	SIW,	SID,	SIQ,	SIA
			   );

  subtype ASM_OPCODE_0	is ASM_OPCODE range ET .. SYS_FILE_DELETE;
  subtype ASM_OPCODE_1	is ASM_OPCODE range DB .. UNLINK;
  subtype ASM_OPCODE_2	is ASM_OPCODE range LB .. SIA;

  type ASM_OP_0		is record
			  OPCODE	: ASM_OPCODE_0;
			end record;

  type ASM_OP_1		is record
			  OPCODE	: ASM_OPCODE_1;
			  VAL	: INTEGER;
			end record;

  type ASM_OP_2		is record
			  OPCODE	: ASM_OPCODE_2;
			  LVL	: NATURAL;
			  OFS	: INTEGER;
			end record;


end	MACHINE_CODE;
	------------
