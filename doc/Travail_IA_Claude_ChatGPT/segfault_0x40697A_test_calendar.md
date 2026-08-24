#NOTE
exécution de TEST_CALENDAR :

$ ./TEST_CALENDAR
----- TIME_OF / SPLIT -----
 Y M D S =  2000  2 29 Erreur de segmentation (core dumped)


#INSTRUCTION SEGFAULT 0x40697a
 <pre>
  0x406962:    mov    0x10(%r15),%rax
   0x406966:    mov    -0x30(%rax),%rax
   0x40696a:    mov    %rax,0x8(%rbp)
   0x40696e:    lea    0x8(%rbp),%rbp
   0x406972:    mov    0x0(%rbp),%rax
   0x406976:    lea    -0x8(%rbp),%rbp
=> 0x40697a:    mov    -0x20(%rax),%rax
   0x40697e:    mov    %rax,0x8(%rbp)
   0x406982:    lea    0x8(%rbp),%rbp
   0x406986:    mov    0x0(%rbp),%rax
   0x40698a:    lea    -0x8(%rbp),%rbp
   0x40698e:    call   *%rax
   0x406990:    mov    0x10(%r15),%rax

</pre>

#REGISTRES AU SEGFAULT
<pre>
│rax            0x402147aacd9e83e5  4621053491578569701                rbx            0x6                 6                                   │
│rcx            0x403858            4208728                            rdx            0x1                 1                                   │
│rsi            0x7fffffbfe8c0      140737484155072                    rdi            0x1                 1                                   │
│rbp            0x7fffffbfe950      0x7fffffbfe950                     rsp            0x7fffffbfdab8      0x7fffffbfdab8                      │
│r8             0xffffffffffffffff  -1                                 r9             0x0                 0                                   │
│r10            0x22                34                                 r11            0x202               514                                 │
│r12            0x7ffff7e00000      140737352040448                    r13            0x410190            4260240                             │
│r14            0x410198            4260248                            r15            0x7fffffbfdae0      140737484151520                     │
│rip            0x40697a            0x40697a                           eflags         0x10246             [ PF ZF IF RF ]                     │
</pre>

#STACK AU SEGFAULT
<pre>
(gdb) x/16gx $rbp-64
0x7fffffbfe910: 0x00000000004100f8      0x00007fffffbfe900
0x7fffffbfe920: 0x0000000000000043      0x0000000200000002
0x7fffffbfe930: 0x00007fffffbfe880      0x3fe0000000000000
0x7fffffbfe940: 0x0000000600000001      0x00007fffffbfe950
0x7fffffbfe950: 0x00007fffffbfe938      0x402147aacd9e83e5
0x7fffffbfe960: 0x0000000000000000      0x0000000000000000
0x7fffffbfe970: 0x000000000000000a      0x00007fffffbfe8e0
0x7fffffbfe980: 0x0000000000000000      0x00007fffffbfe42c
</pre>

#BACKTRACE ET MAP
<pre>
(gdb) bt
#0  0x000000000040697a in ?? ()
var elab ROUNDING 0x00000000004068B0
 disp 0x0000000000000008
 **zone segfault**
var elab EXP_STR 0x0000000000407754
 disp 0x0000000000000020
 
#1  0x0000000000407fac in ?? ()
PUT_L70 0x0000000000407D85
**zone appel**
FIXED_IO body 0x0000000000407FC5
 
#2  0x000000000040baed in ?? ()
#3  0x000000000040c0f4 in ?? ()
#4  0x000000000040c44a in ?? ()
#5  0x000000000040f519 in ?? ()
</pre>

#SOURCE ADA 83 SECTION EN SEGFAULT

<pre>
      declare
        ROUNDING	: NUM	:= 0.5;
      begin
        for  I in  1 .. AFT  loop
	ROUNDING := ROUNDING / 10.0;
        end loop;

        VAL := VAL + ROUNDING;
      end;

      -- Propager une retenue issue de l'arrondi :
      -- 9.9999996E+n devient 1.000000E+(n+1).
      if  VAL >= 10.0  then
        VAL := VAL / 10.0;
        E := E + 1;
      end if;

      -- Padding FORE : le champ FORE inclut le signe et le chiffre avant le point
      -- Format : [-]d.dddE[+|-]dd
      -- Nombre de caracteres avant le point : 1 chiffre (+ signe eventuel)
      FORE_LEN := 1;
      if  IS_NEGATIVE  then
        FORE_LEN := 2;
      end if;
      if  FORE > FORE_LEN  then
        for  I in 1 .. FORE - FORE_LEN  loop
	PUT( FILE, ' ' );
        end loop;
      end if;

      -- Signe
      if  IS_NEGATIVE  then
        PUT( FILE, '-' );
      end if;

      -- Chiffre avant le point decimal
      DIGIT := INTEGER( VAL );
      if  DIGIT > 9  then DIGIT := 9; end if;				-- securite arrondi
      if  DIGIT < 0  then DIGIT := 0; end if;
      PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
      VAL := ( VAL - NUM( DIGIT ) ) * 10.0;

      -- Point decimal
      PUT( FILE, '.' );

      -- Chiffres apres le point
      for  I in 1 .. AFT  loop
        DIGIT := INTEGER( VAL );
        if  DIGIT > 9  then DIGIT := 9; end if;
        if  DIGIT < 0  then DIGIT := 0; end if;
        PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
        VAL := ( VAL - NUM( DIGIT ) ) * 10.0;
      end loop;

      -- Partie exposant
      if  EXP > 0  then
        PUT( FILE, 'E' );
        if  E < 0  then
	PUT( FILE, '-' );
	E := -E;
        else
	PUT( FILE, '+' );
        end if;
        -- Ecrire l'exposant avec EXP chiffres (padding zero a gauche)
        declare
	EXP_STR	: STRING( 1 .. EXP );

</pre>

#SOURCE ADA 83 PROCEDURE CONTENANT LA FAUTE DANS TEXT_IO.FLOAT_IO

<pre>
    procedure		PUT		( FILE :in FILE_TYPE;
					  ITEM :in NUM;
					  FORE :in FIELD		:= DEFAULT_FORE;
					  AFT  :in FIELD		:= DEFAULT_AFT;
					  EXP  :in FIELD		:= DEFAULT_EXP
					)
    is			---

      VAL		: NUM		:= ITEM;
      IS_NEGATIVE	: BOOLEAN		:= ITEM < 0.0;
      E		: INTEGER		:= 0;
      DIGIT	: INTEGER;
      FORE_LEN	: NATURAL;

    begin
      -- Traiter le signe
      if  IS_NEGATIVE  then
        VAL := -ITEM;
      end if;

      -- Calculer l'exposant : normaliser 1.0 <= VAL < 10.0
      if  VAL /= 0.0  then
        while  VAL >= 10.0  loop
	VAL := VAL / 10.0;
	E := E + 1;
        end loop;

        while  VAL < 1.0  loop
	VAL := VAL * 10.0;
	E := E - 1;
        end loop;
      end if;

      -- Arrondir la mantisse au nombre de chiffres demandes.
      -- L'extraction ulterieure des chiffres est volontairement tronquee.
      declare
        ROUNDING	: NUM	:= 0.5;
      begin
        for  I in  1 .. AFT  loop
	ROUNDING := ROUNDING / 10.0;
        end loop;

        VAL := VAL + ROUNDING;
      end;

      -- Propager une retenue issue de l'arrondi :
      -- 9.9999996E+n devient 1.000000E+(n+1).
      if  VAL >= 10.0  then
        VAL := VAL / 10.0;
        E := E + 1;
      end if;

      -- Padding FORE : le champ FORE inclut le signe et le chiffre avant le point
      -- Format : [-]d.dddE[+|-]dd
      -- Nombre de caracteres avant le point : 1 chiffre (+ signe eventuel)
      FORE_LEN := 1;
      if  IS_NEGATIVE  then
        FORE_LEN := 2;
      end if;
      if  FORE > FORE_LEN  then
        for  I in 1 .. FORE - FORE_LEN  loop
	PUT( FILE, ' ' );
        end loop;
      end if;

      -- Signe
      if  IS_NEGATIVE  then
        PUT( FILE, '-' );
      end if;

      -- Chiffre avant le point decimal
      DIGIT := INTEGER( VAL );
      if  DIGIT > 9  then DIGIT := 9; end if;				-- securite arrondi
      if  DIGIT < 0  then DIGIT := 0; end if;
      PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
      VAL := ( VAL - NUM( DIGIT ) ) * 10.0;

      -- Point decimal
      PUT( FILE, '.' );

      -- Chiffres apres le point
      for  I in 1 .. AFT  loop
        DIGIT := INTEGER( VAL );
        if  DIGIT > 9  then DIGIT := 9; end if;
        if  DIGIT < 0  then DIGIT := 0; end if;
        PUT( FILE, CHARACTER'VAL( CHARACTER'POS( '0' ) + DIGIT ) );
        VAL := ( VAL - NUM( DIGIT ) ) * 10.0;
      end loop;

      -- Partie exposant
      if  EXP > 0  then
        PUT( FILE, 'E' );
        if  E < 0  then
	PUT( FILE, '-' );
	E := -E;
        else
	PUT( FILE, '+' );
        end if;
        -- Ecrire l'exposant avec EXP chiffres (padding zero a gauche)
        declare
	EXP_STR	: STRING( 1 .. EXP );
	POS	: NATURAL := EXP;
	EVAL	: INTEGER := E;
        begin
	for  I in reverse 1 .. EXP  loop
	  EXP_STR( I ) := CHARACTER'VAL( CHARACTER'POS( '0' ) + EVAL mod 10 );
	  EVAL := EVAL / 10;
	end loop;
	PUT( FILE, EXP_STR );
        end;
      end if;

    end	PUT;

</pre>


Appelée par :
#SOURCE ADA 83 PROCEDURE APPELANTE DANS TEST_CALENDAR

<pre>
  package INT_IO is new INTEGER_IO( INTEGER );
  package DUR_IO is new FLOAT_IO( LONG_FLOAT );

  T	: TIME;
  T2	: TIME;
  Y	: YEAR_NUMBER;
  M	: MONTH_NUMBER;
  D	: DAY_NUMBER;
  S	: DAY_DURATION;
  DELTA_T	: DURATION;

		------------
  procedure	AFFICHE_DATE
  is		------------
  begin
    PUT( " Y M D S = " );
    INT_IO.PUT( INTEGER( Y ), WIDTH=> 5 );
    INT_IO.PUT( INTEGER( M ), WIDTH=> 3 );
    INT_IO.PUT( INTEGER( D ), WIDTH=> 3 );
    PUT( ' ' ); DUR_IO.PUT( LONG_FLOAT( S ), FORE => 1, AFT => 6, EXP => 2 );
    NEW_LINE;

  end	AFFICHE_DATE;
	------------

begin
  PUT_LINE( "----- TIME_OF / SPLIT -----" );

  T := TIME_OF( 2000, 2, 29, 86399.75 );

  SPLIT( T, Y, M, D, S );
  AFFICHE_DATE;

</pre>

#SECTION LLIR CONTENANT LE SEGFAULT DANS TEXT_IO.FINC
<pre>
VAR ROUNDING_disp, Q			; variable flottante
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	0.5
	SQ  2,	ROUNDING_disp

 hexa_show ' disp ', ROUNDING_disp
					;    end elab
begin:					;---------- BDY INSTRUCTIONS
VAR	IL667_disp, D				; compteur boucle LOOP__30
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SD  2,	IL667_disp
VAR	LMT_IL667_disp, D			; limite boucle LOOP__30
	LD  1,	-AFT_ofs
	SD  2,	LMT_IL667_disp
	LD  2,	IL667_disp				; test null range LOOP__30
	LD  2,	LMT_IL667_disp
	CGT
	BT	L666
LOOP__30:					; corps boucle LOOP__30
	LVA 2,	ROUNDING_disp
	LA 2,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 2,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	10.0
	FDIV
	SQ  2,	ROUNDING_disp
	LD  2,	IL667_disp				; test de sortie LOOP__30
	LD  2,	LMT_IL667_disp
	CEQ
	BT	L666
	LD  2,	IL667_disp				; mise a jour compteur LOOP__30
	INC
	SD  2,	IL667_disp
	BRA	LOOP__30				; iteration suivante LOOP__30
L666:					; post loop LOOP__30
	LVA 1,	STANDARD.TEXT_IO.FLOAT_IO.PUT_L69.VAL_disp
	LA 2,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 2,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
	LVA 2,	ROUNDING_disp
	LA 2,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 2,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
	FADD
	SQ  1,	STANDARD.TEXT_IO.FLOAT_IO.PUT_L69.VAL_disp
	UNLINK 2
endPRO
					; debut if
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	10.0
	FCGE
	BF	L669
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	10.0
	FDIV
	SQ  1,	VAL_disp
	LD 1,	E_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	ADD
	SD  1,	E_disp
	BRA	L668
L669:
L668:					; post if
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	DUP
	LD	0, STANDARD._NATURAL.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LD	0, STANDARD._NATURAL.LST
	CGT
	BT	STANDARD.ce_raise_
	SD  1,	FORE_LEN_disp
					; debut if
	ULB 1,	IS_NEGATIVE_disp
	BF	L671
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	2
	DUP
	LD	0, STANDARD._NATURAL.FST
	CLT
	BT	STANDARD.ce_raise_
	DUP
	LD	0, STANDARD._NATURAL.LST
	CGT
	BT	STANDARD.ce_raise_
	SD  1,	FORE_LEN_disp
	BRA	L670
L671:
L670:					; post if
					; debut if
	LD  1,	-FORE_ofs
	LD 1,	FORE_LEN_disp
	CGT
	BF	L673
VAR	IL675_disp, D				; compteur boucle LOOP__27
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SD  1,	IL675_disp
VAR	LMT_IL675_disp, D			; limite boucle LOOP__27
	LD  1,	-FORE_ofs
	LD 1,	FORE_LEN_disp
	SUB
	SD  1,	LMT_IL675_disp
	LD  1,	IL675_disp				; test null range LOOP__27
	LD  1,	LMT_IL675_disp
	CGT
	BT	L674
LOOP__27:					; corps boucle LOOP__27
	LI	32
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
	LD  1,	IL675_disp				; test de sortie LOOP__27
	LD  1,	LMT_IL675_disp
	CEQ
	BT	L674
	LD  1,	IL675_disp				; mise a jour compteur LOOP__27
	INC
	SD  1,	IL675_disp
	BRA	LOOP__27				; iteration suivante LOOP__27
L674:					; post loop LOOP__27
	BRA	L672
L673:
L672:					; post if
					; debut if
	ULB 1,	IS_NEGATIVE_disp
	BF	L677
	LI	45
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
	BRA	L676
L677:
L676:					; post if
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
; CODE CONVERSION SOURCE DN_FLOAT TARGET DN_INTEGER
	CVTFI
	SD  1,	DIGIT_disp
					; debut if
	LD 1,	DIGIT_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	9
	CGT
	BF	L679
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	9
	SD  1,	DIGIT_disp
	BRA	L678
L679:
L678:					; post if
					; debut if
	LD 1,	DIGIT_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	CLT
	BF	L681
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	SD  1,	DIGIT_disp
	BRA	L680
L681:
L680:					; post if
	LI	48
	LD 1,	DIGIT_disp
	ADD
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
	LD 1,	DIGIT_disp
; CODE CONVERSION SOURCE DN_INTEGER TARGET DN_FLOAT
	CVTIF					; CODE_CONVERSION FLOAT TARGET FROM DN_INTEGER
	FSUB
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	10.0
	FMUL
	SQ  1,	VAL_disp
	LI	46
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
VAR	IL683_disp, D				; compteur boucle LOOP__28
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	1
	SD  1,	IL683_disp
VAR	LMT_IL683_disp, D			; limite boucle LOOP__28
	LD  1,	-AFT_ofs
	SD  1,	LMT_IL683_disp
	LD  1,	IL683_disp				; test null range LOOP__28
	LD  1,	LMT_IL683_disp
	CGT
	BT	L682
LOOP__28:					; corps boucle LOOP__28
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
; CODE CONVERSION SOURCE DN_FLOAT TARGET DN_INTEGER
	CVTFI
	SD  1,	DIGIT_disp
					; debut if
	LD 1,	DIGIT_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	9
	CGT
	BF	L685
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	9
	SD  1,	DIGIT_disp
	BRA	L684
L685:
L684:					; post if
					; debut if
	LD 1,	DIGIT_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	CLT
	BF	L687
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	SD  1,	DIGIT_disp
	BRA	L686
L687:
L686:					; post if
	LI	48
	LD 1,	DIGIT_disp
	ADD
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
	LVA 1,	VAL_disp
	LA 1,	-GFP_ofs
	LA ,	-NUM__inadr_ofs
	CALLI
	LA 1,	-GFP_ofs
	LA ,	-NUM__ld_ofs
	CALLI
	LD 1,	DIGIT_disp
; CODE CONVERSION SOURCE DN_INTEGER TARGET DN_FLOAT
	CVTIF					; CODE_CONVERSION FLOAT TARGET FROM DN_INTEGER
	FSUB
; CODE_NUMERIC_LITERAL DN_FLOAT
	LIF	10.0
	FMUL
	SQ  1,	VAL_disp
	LD  1,	IL683_disp				; test de sortie LOOP__28
	LD  1,	LMT_IL683_disp
	CEQ
	BT	L682
	LD  1,	IL683_disp				; mise a jour compteur LOOP__28
	INC
	SD  1,	IL683_disp
	BRA	LOOP__28				; iteration suivante LOOP__28
L682:					; post loop LOOP__28
					; debut if
	LD  1,	-EXP_ofs
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	CGT
	BF	L689
	LI	69
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
					; debut if
	LD 1,	E_disp
; CODE_NUMERIC_LITERAL DN_INTEGER
	LI	0
	CLT
	BF	L691
	LI	45
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
	LD 1,	E_disp
	NEG
	SD  1,	E_disp
	BRA	L690
L691:
	LI	43
	LA  1,	-FILE_ofs
	CALL	STANDARD.TEXT_IO. ,PUT_L51
L690:					; post if
namespace	BLOCK__29
ELB 2					;    BODY ELAB
 hexa_show 'var elab EXP_STR ', $

 </pre>
