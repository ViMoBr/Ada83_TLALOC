#COMMANDE
 <pre>
 ./DIS_BONJOUR.riscv64exe
 </pre>
 
#REMARQUES
Exécution sur SBC Starfive Visionfive2 du programme assemblé sur laptop x86 avec fasmg et codi_riscv64.finc .
Segfault dans une élaboration de TEXT_IO.

#INSTRUCTION SEGFAULT 0x402d40
 <pre>
(gdb) x/16i $pc-32
   0x402d20:    sd      a0,8(s0)
   0x402d24:    add     s0,s0,8
   0x402d28:    ld      a1,0(s0)
   0x402d2c:    add     s0,s0,-8
   0x402d30:    ld      a0,0(s1)
   0x402d34:    lui     t0,0x1
   0x402d38:    add     t0,t0,-1960
   0x402d3c:    add     t1,a5,zero
=> 0x402d40:    sd      a1,0(t0)
   0x402d44:    ld      a0,0(s1)
   0x402d48:    add     a0,a0,1368
   0x402d4c:    sd      a0,8(s0)
   0x402d50:    add     s0,s0,8
   0x402d54:    ld      a1,0(s0)
   0x402d58:    add     s0,s0,-8
   0x402d5c:    ld      a0,0(s1)

</pre>

#REGISTRES AU SEGFAULT
<pre>
│zero           0x0      0                                                                                   │
│ra             0x2aaaaeeb1e     0x2aaaaeeb1e                                                                │
│sp             0x3fffbff2c0     0x3fffbff2c0                                                                │
│gp             0x2aaab95408     0x2aaab95408                                                                │
│tp             0x3ff7e6b780     0x3ff7e6b780                                                                │
│t0             0x858    2136                                                                                │
│t1             0x0      0                                                                                   │
│t2             0x4      4                                                                                   │
│fp             0x3fffbffe88     0x3fffbffe88                                                                │
│s1             0x3fffbff2c0     274873709248                                                                │
│a0             0x3fffbff3c0     274873709504                                                                │
│a1             0x3fffbffc28     274873711656                                                                │
│a2             0x3e     62                                                                                  │
│a3             0x22     34                                                                                  │
│a4             0xffffffffffffffff       -1                                                                  │
│a5             0x0      0         
a6             0x10     16
a7             0xde     222
s2             0x405790 4216720
s3             0x405788 4216712
s4             0x3ff7ffd000     274743676928
s5             0x3ff7ffdd40     274743680320
s6             0x2aaabaead0     183253002960
s7             0x2aaab94e60     183252897376
s8             0x0      0
s9             0x0      0
s10            0x63     99
s11            0x2aaab9d010     183252930576
t3             0x3ff7f02c80     274742652032
t4             0xa153461a74b74d1b       -6822031931094905573
t5             0x2aaabaf        44739503
t6             0xa153461a74b74d1b       -6822031931094905573
pc             0x402d40 0x402d40
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $s0
0x3fffbffe88:   0x0000000000000000      0x0000003fffbffc28
0x3fffbffe98:   0x0000000000000000      0x000000007fffffff
0x3fffbffea8:   0x0000000000000000      0x0000000000000000
0x3fffbffeb8:   0x0000000000000000      0x0000000000000000
0x3fffbffec8:   0x0000000000000000      0x0000000000000000
0x3fffbffed8:   0x0000000000000000      0x0000000000000000
0x3fffbffee8:   0x0000000000000000      0x0000000000000000
0x3fffbffef8:   0x0000000000000000      0x0000000000000000

</pre>

#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x0000000000402d40 in ?? ()
var elab STD_INPUT 0x0000000000402D10
 disp 0x0000000000000858
var elab STD_OUTPUT 0x0000000000403040
 disp 0x0000000000000990

</pre>

#SOURCE ADA 83 SECTION DE text_io.adb EN SEGFAULT
<pre>
  with MACHINE_CODE;
use  MACHINE_CODE;
					-------
	package body			TEXT_IO
is					-------

  STDOUT_PAGE_LENGTH	: COUNT		:= 0;
  STDOUT_LINE_LENGTH	: COUNT		:= 0;						-- LRM 14.3.3 : non borne par defaut
  STDOUT_PAGE		: POSITIVE_COUNT	:= 1;
  STDOUT_LINE		: POSITIVE_COUNT	:= 1;
  STDOUT_COL		: POSITIVE_COUNT	:= 1;

  DEFAULT_INPUT		: FILE_TYPE;
  DEFAULT_OUTPUT		: FILE_TYPE;
  STD_INPUT		: FILE_TYPE;  -- PROBLEME EN ELABORATION
  STD_OUTPUT		: FILE_TYPE;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS TEXT_IO.FINC
<pre>
 hexa_show 'var elab STD_INPUT ', $
VAR STD_INPUT_disp, q			; variable record : pointeur aux data record
VAR STD_INPUT__u, q				; variable record : pointeur aux useinfo
VAR STD_INPUT__dat, STANDARD.TEXT_IO._FILE_TYPE.size
	LVA	0, STD_INPUT__dat
	Sa	0, STD_INPUT_disp			; record fin
	LVA	0, STANDARD.TEXT_IO._FILE_TYPE.SIZ
	Sa	0, STD_INPUT__u
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.ID
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	NEG
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.IS_OPENED
	LI	0
	Sb
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.PAGE_LENGTH
	ULd 0,	STANDARD.TEXT_IO.UNBOUNDED_disp
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.LINE_LENGTH
	ULd 0,	STANDARD.TEXT_IO.UNBOUNDED_disp
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.PAGE
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.LINE
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.COL
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	Sd
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.IS_DEFAULT_IO
	LI	0
	Sb
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.LOOK_AHEAD
	LI	 0
	Sb
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.HAS_LOOK_AHEAD
	LI	0
	Sb
	LIVa 0, STANDARD.TEXT_IO.STD_INPUT_disp, STANDARD.TEXT_IO._FILE_TYPE.AT_END_OF_FILE
	LI	0
	Sb

 hexa_show ' disp ', STD_INPUT_disp
 hexa_show 'var elab STD_OUTPUT ', $

 </pre>
