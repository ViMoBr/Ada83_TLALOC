#COMMANDE AU COMPILATEUR
 <pre>
 ./T2 ./ ../../src/par_phase/lex.adb W
 </pre>
 
#PROGRAMME SOUMIS AU COMPILATEUR
<pre> 
lex.adb
</pre>

#REMARQUES
segfault sur un BLKMOV dans EXPANDER.UTILS.LABEL_STR appelé par EXPANDER. INSTRUCTIONS.CODE_GOTO

#INSTRUCTION SEGFAULT 0x68cb76
 <pre>
(gdb) x/16i $rip-32
   0x68cb56:    or     %cl,-0x75(%rax)
   0x68cb59:    jne    0x68cb5b
   0x68cb5b:    lea    -0x8(%rbp),%rbp
   0x68cb5f:    mov    0x0(%rbp),%rcx
   0x68cb63:    lea    -0x8(%rbp),%rbp
   0x68cb67:    mov    0x0(%rbp),%rdi
   0x68cb6b:    lea    -0x8(%rbp),%rbp
   0x68cb6f:    test   %rcx,%rcx
   0x68cb72:    je     0x68cb79
   0x68cb74:    cld
   0x68cb75:    lods   %ds:(%rsi),%al
=> 0x68cb76:    stos   %al,%es:(%rdi)
   0x68cb77:    loop   0x68cb75
   0x68cb79:    jmp    0x68cb7e
   0x68cb7e:    mov    0x10(%r15),%rbp
   0x68cb82:    mov    0x0(%rbp),%rax

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x7fffffc0a518      140737484203288    rbx            0x7fffffc0a518      140737484203288    │
│rcx            0x10                16                 rdx            0x0                 0                  │
│rsi            0x7fffffc0a519      140737484203289    rdi            0x1                 1                  │
│rbp            0x7fffffc0a570      0x7fffffc0a570     rsp            0x7fffffbfda38      0x7fffffbfda38     │
│r8             0xffffffffffffffff  -1                 r9             0x0                 0                  │
│r10            0x22                34                 r11            0x246               582                │
│r12            0x7ffff7de7000      140737351938048    r13            0x2a519b8           44374456           │
│r14            0x2a519f0           44374512           r15            0x7fffffbfdaf0      140737484151536    │
│rip            0x68cb76            0x68cb76           eflags         0x10202             [ IF RF ]          │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc0a530: 0x00007fffffc0a538      0x0000000800000008
0x7fffffc0a540: 0x0000000100000001      0x0000000002a519d9
0x7fffffc0a550: 0x00007fffffc0a558      0x0000000800000010
0x7fffffc0a560: 0x0000000300000002      0x00007fffffc0a518
0x7fffffc0a570: 0x0000000002a4cb08      0x0000000000000001
0x7fffffc0a580: 0x0000000000000010      0x00007fffffc0a518
0x7fffffc0a590: 0x0000000000000003      0x0000000000000000
0x7fffffc0a5a0: 0x00007fffffc0a4a0      0x00007fffffc0a5b0

</pre>

#BACKTRACE ET MAP
<pre>
#0  0x000000000068cb76 in ?? ()
LABEL_STR_L16 0x000000000068C323
var elab LSTR 0x000000000068C344
 disp 0x0000000000000008
 **zone segfault**
INC_LEVEL_L17 0x000000000068CB9C

#1  0x0000000000cd0dab in ?? ()
CODE_GOTO_L136 0x0000000000CCCF65
var elab TARGET 0x0000000000CCCF86
 disp 0x0000000000000008
var elab E 0x0000000000CCD7A8
 disp 0x0000000000000008
 **zone appel**
CODE_RAISE_L146 0x0000000000CD1104

#2  0x0000000000ccccc7 in ?? ()

#3  0x0000000000c9848c in ?? ()

#4  0x0000000000c978fd in ?? ()
#5  0x0000000000c97729 in ?? ()
#6  0x0000000000ca0a8b in ?? ()
#7  0x0000000000c9f81e in ?? ()
#8  0x0000000000c9e9b8 in ?? ()
#9  0x0000000000c9e2a9 in ?? ()
#10 0x0000000000c98000 in ?? ()
#11 0x0000000000c978fd in ?? ()
#12 0x0000000000c97729 in ?? ()
#13 0x0000000000c8b6cd in ?? ()
#14 0x0000000000c6de57 in ?? ()
#15 0x0000000000c8f93b in ?? ()
#16 0x0000000000c7f858 in ?? ()
#17 0x0000000000c8037c in ?? ()
#18 0x0000000000c7e9c0 in ?? ()
#19 0x0000000000c56456 in ?? ()
#20 0x0000000000d7a7e9 in ?? ()
#21 0x0000000000d82155 in ?? ()
#22 0x0000000000d9e0d0 in ?? ()
#23 0x0000000000d9ef69 in ?? ()

</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT
<pre>
function		  LABEL_STR			( LBL : LABEL_TYPE )	return STRING
  is			-------------
    LSTR  :constant STRING	:= LABEL_TYPE'IMAGE( LBL );
  begin
    return 'L' & LSTR( LSTR'FIRST+1 .. LSTR'LAST );
  end	LABEL_STR;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS EXPANDER-UTILS.FINC
<pre>
if defined LABEL_STR_L16_
PRO	LABEL_STR_L16				;---------- PRO LABEL_STR
 hexa_show 'LABEL_STR_L16 ', $
PRMS					;    debut parametrage
	PRM LBL_ofs				; in
	PRM result__ofs				; resultat de fonction
endPRMS					;    fin parametrage
ELB 2					;    BODY ELAB
 hexa_show 'var elab LSTR ', $
VAR LSTR_disp, q				; variable array : pointeur aux data
VAR LSTR__u, q				; variable array : useinfo pointeur au rec info
	La 0, STANDARD._STRING.use__info
	Sa	2, LSTR__u				; array info ptr at __u
VAR	ANON_141_31_disp, q
VAR	ANON_141_31__u,   q
namespace ANON_141_31_info
  VAR SIZ, d
  VAR _COMP_SIZ, d
  VAR _FST_1, d
  VAR _LST_1, d
end namespace
	LVA 2, ANON_141_31_info.SIZ
	Sa  2, ANON_141_31__u
	LVA 2, ANON_141_31_disp
	ULd  2,	-LBL_ofs
	CALL	STANDARD. ,INTEGER_IMAGE_L11
	DUP
	La
	Sa	2, LSTR_disp				; array data ptr from function result
	La , 8
	Sa	2, LSTR__u				; array info ptr from function result

 hexa_show ' disp ', LSTR_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
; CODE_RETURN : EXPR TYPE = DN_ARRAY  VUE COMPLETE = DN_ARRAY
; CODE & concat _STRING
VAR	ANON_144_12_L49_G_data, q
VAR	ANON_144_12_L49_G_info, q
VAR	ANON_144_18_L49_D_data, q
VAR	ANON_144_18_L49_D_info, q
VAR	ANON_144_12_L49_G_len,  q
VAR	ANON_144_18_L49_D_len,  q
VAR	ANON_144_12_L49_R_disp, q
VAR	ANON_144_12_L49_R__u,   q
namespace ANON_144_12_L49_R_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
VAR	ANON_144_12_L49_G_disp, q
VAR	ANON_144_12_L49_G__u,   q
namespace ANON_144_12_L49_G_info
  VAR SIZ,      d
  VAR _COMP_SIZ, d
  VAR _FST_1,    d
  VAR _LST_1,    d
end namespace
	LI	76
	LI	1
	CO_VAR
	Sa  2, ANON_144_12_L49_G_disp
	SIb  2, ANON_144_12_L49_G_disp, 0
	LI	1
	Sd  2, ANON_144_12_L49_G_info._FST_1
	LI	1
	Sd  2, ANON_144_12_L49_G_info._LST_1
	LI	8
	Sd  2, ANON_144_12_L49_G_info._COMP_SIZ
	LI	8
	Sd  2, ANON_144_12_L49_G_info.SIZ
	LVA 2, ANON_144_12_L49_G_info.SIZ
	Sa  2, ANON_144_12_L49_G__u
	LVA 2, ANON_144_12_L49_G_disp
	DUP
	La  ,  0
	Sa  2, ANON_144_12_L49_G_data
	La  ,  8
	Sa  2, ANON_144_12_L49_G_info
	LId 2, ANON_144_12_L49_G_info, _STRING.LST_1
	LId 2, ANON_144_12_L49_G_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  2, ANON_144_12_L49_G_len
	La 2, STANDARD.EXPANDER_L1.UTILS.LABEL_STR_L16.LSTR_disp
	LId	2, STANDARD.EXPANDER_L1.UTILS.LABEL_STR_L16.LSTR__u, STANDARD._STRING.FST_1
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	ADD
	LId 2, STANDARD.EXPANDER_L1.UTILS.LABEL_STR_L16.LSTR__u, STANDARD._STRING.FST_1
	SUB
	LI	1
	MUL
	ADD
namespace ANON_144_18			; ensemble doublet @data/@info pour slice anonyme source
VAR ANON_144_18_disp, q
VAR ANON_144_18__u, q
VAR SIZ, d
VAR COMP_SIZ, d
VAR _FST_1, d
VAR _LST_1, d
	Sa	2, ANON_144_18_disp
	LVA	2, SIZ
	Sa	2, ANON_144_18__u
	LI	8
	Sd	2, COMP_SIZ
	LId	2, STANDARD.EXPANDER_L1.UTILS.LABEL_STR_L16.LSTR__u, STANDARD._STRING.FST_1
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	ADD
	Sd	2, _FST_1
	LId	2, STANDARD.EXPANDER_L1.UTILS.LABEL_STR_L16.LSTR__u, STANDARD._STRING.LST_1
	Sd	2, _LST_1
	Ld	2, _LST_1
	Ld	2, _FST_1
	SUB
	INC
	CLAMP0
	LI	8
	MUL
	Sd	2, SIZ
	LVA	2, ANON_144_18_disp
end namespace
	DUP
	La  ,  0
	Sa  2, ANON_144_18_L49_D_data
	La  ,  8
	Sa  2, ANON_144_18_L49_D_info
	LId 2, ANON_144_18_L49_D_info, _STRING.LST_1
	LId 2, ANON_144_18_L49_D_info, _STRING.FST_1
	SUB
	INC
	CLAMP0
	Sa  2, ANON_144_18_L49_D_len
	La  2, ANON_144_12_L49_G_len
	La  2, ANON_144_18_L49_D_len
	ADD
	CO_VAR
	Sa  2, ANON_144_12_L49_R_disp
	LI	1
	Sd  2, ANON_144_12_L49_R_info._FST_1
	La  2, ANON_144_12_L49_G_len
	La  2, ANON_144_18_L49_D_len
	ADD
	Sd  2, ANON_144_12_L49_R_info._LST_1
	LI	8
	Sd  2, ANON_144_12_L49_R_info._COMP_SIZ
	La  2, ANON_144_12_L49_G_len
	La  2, ANON_144_18_L49_D_len
	ADD
	LI	8
	MUL
	Sd  2, ANON_144_12_L49_R_info.SIZ
	LVA 2, ANON_144_12_L49_R_info.SIZ
	Sa  2, ANON_144_12_L49_R__u
	La  2, ANON_144_12_L49_R_disp
	La  2, ANON_144_12_L49_G_len
	La  2, ANON_144_12_L49_G_data
	BLKMOV
	La  2, ANON_144_12_L49_R_disp
	La  2, ANON_144_12_L49_G_len
	ADD
	La  2, ANON_144_18_L49_D_len
	La  2, ANON_144_18_L49_D_data
	BLKMOV
	LVA 2, ANON_144_12_L49_R_disp
VAR	RET_INFO_L50, q
	DUP
	La  ,  0
	SIq   2, -result__ofs,  0
	DUP
	La  ,  8
	Sa   2, RET_INFO_L50
	DROP
	La   2, -result__ofs
	La  ,  8
	LI	16
	La   2, RET_INFO_L50
	BLKMOV
	BRA ret_lbl
ret_lbl:
	UNLINK 2
	RTD	prm_siz-8
excep:
endPRO					;---------- end PRO LABEL_STR
end if

if defined INC_LEVEL_L17_

 </pre>

#SECTION LLIR APPELANTE DANS INSTRUCTIONS.FINC
<pre>

</pre>

#ADA APPELANT
<pre>
  procedure		CODE_GOTO			( ADA_GOTO :TREE )
  is			---------

    TARGET	: TREE	:= D( AS_NAME, ADA_GOTO );

  begin
    if  TARGET.TY /= DN_LABEL_ID  then
      TARGET := D( SM_DEFN, TARGET );							-- forme du dump GOTO_DUMP :
    end if;										-- DN_USED_NAME_ID -> SM_DEFN -> DN_LABEL_ID
    if  TARGET.TY /= DN_LABEL_ID  then
      PUT_LINE( "; !!! CODE_GOTO : cible non resolue " & NODE_NAME'IMAGE( TARGET.TY ) );		-- refus bruyant (piege n 53)
      raise PROGRAM_ERROR;
    end if;

    declare
      E	: CODI.GOTO_LBL_IDX := CODI.GOTO_LABEL_ENTRY( TARGET );
    begin
      if  CODI.GOTO_LABELS( E ).DEFINED  then						-- GOTO ARRIERE : deniveler ICI, forme de
        for  L in reverse CODI.GOTO_LABELS( E ).LEVEL + 1 .. CODI.CUR_LEVEL  loop			-- CODE_EXIT (pieges n 69 et 34)
	if  CODI.HANDLER_CTX_AT( L )  then  CODI.EXC_POP;  end if;				-- pop des blocs proteges traverses
	PUT_LINE( tab & "UNLINK" & LEVEL_NUM'IMAGE( L ) );
        end loop;
        --  APPEL LABEL STR
        PUT_LINE( tab & "BRA" & tab & LABEL_STR( CODI.GOTO_LABELS( E ).LBL ) );

      else										-- GOTO AVANT : BRA vers le RACCORD propre a
        if  CODI.GOTO_PEND_TOP = MAX_GOTO_LABELS  then					-- ce goto ; le denivele sera emis par
	PUT_LINE( "; !!! CODE_GOTO : table des raccords pleine" );				-- CODE_LABELED qui connaitra les 2 niveaux
	raise PROGRAM_ERROR;
        end if;
        CODI.GOTO_PEND_TOP := CODI.GOTO_PEND_TOP + 1;
        CODI.GOTO_PENDING( CODI.GOTO_PEND_TOP ).TARGET := TARGET;
        CODI.GOTO_PENDING( CODI.GOTO_PEND_TOP ).LBL_G  := NEW_LABEL;
        CODI.GOTO_PENDING( CODI.GOTO_PEND_TOP ).LEVEL  := CODI.CUR_LEVEL;
        for  L in LEVEL_NUM  loop								-- PHOTO des contextes au site du goto
	CODI.GOTO_PENDING( CODI.GOTO_PEND_TOP ).CTX( L ) := CODI.HANDLER_CTX_AT( L );		-- (miroir du principe d'EXC_MACH : les
        end loop;										-- blocs seront refermes a l'etiquette)
        PUT_LINE( tab & "BRA" & tab & LABEL_STR( CODI.GOTO_PENDING( CODI.GOTO_PEND_TOP ).LBL_G ) );
      end if;

    end;

  end	CODE_GOTO;
</pre>