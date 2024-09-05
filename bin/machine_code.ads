			------------
	package		MACHINE_CODE
			------------

is

  type ASM_OPCODE		is (ET, OU, NON, OUX, SYSCALL, PUT_STR, DB, LDI, LINK, UNLINK,
			    LDB, LDW, LDD, LDQ, ILDB, ILDW, ILDD, ILDQ,
			    STB, STW, STD, STA);

  subtype ASM_OPCODE_0	is ASM_OPCODE range ET .. PUT_STR;
  subtype ASM_OPCODE_1	is ASM_OPCODE range DB .. UNLINK;
  subtype ASM_OPCODE_2	is ASM_OPCODE range LDB .. STA;

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
