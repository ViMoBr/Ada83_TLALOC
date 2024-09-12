			------------
	package		MACHINE_CODE
			------------

is

  type ASM_OPCODE		is (ET,	OU,	NON,	OUX,	SYSCALL,	PUT_STR,
			    DB,	LI,	LCA,	LINK,	UNLINK,
			    LB,	LW,	LD,	LQ,	ILB,	ILW,	ILD,	ILQ,
			    SB,	SW,	SD,	SQ
			   );

  subtype ASM_OPCODE_0	is ASM_OPCODE range ET .. PUT_STR;
  subtype ASM_OPCODE_1	is ASM_OPCODE range DB .. UNLINK;
  subtype ASM_OPCODE_2	is ASM_OPCODE range LB .. SQ;

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
