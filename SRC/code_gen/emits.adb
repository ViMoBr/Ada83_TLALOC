with DIANA_NODE_ATTR_CLASS_NAMES;
use  DIANA_NODE_ATTR_CLASS_NAMES;

						-----
		package body			EMITS
						-----
is
   
  use OP_CODE_IO;
  use CODE_DATA_TYPE_IO;
   
      
  INT_LABEL	: LABEL_TYPE	:= 1;
  FS		: FILE_TYPE;



				--============--
  procedure			OPEN_OUTPUT_FILE		( FILE_NAME :STRING )
  is
  begin
    CREATE ( FS, OUT_FILE, FILE_NAME & ".COD" );
    SET_OUTPUT ( FS );										--| CODAGE SUR SORTIE STANDARD
    INT_LABEL := 1;

  end	OPEN_OUTPUT_FILE;
	--============--



				--=============--
  procedure			CLOSE_OUTPUT_FILE
  is
  begin
    SET_OUTPUT ( STANDARD_OUTPUT );
    CLOSE ( FS );

  end	CLOSE_OUTPUT_FILE;
	--=============--



  package INT_IO	is new INTEGER_IO ( INTEGER ); use INT_IO;
  package LBL_IO	is new INTEGER_IO ( LABEL_TYPE ); use LBL_IO;



				--=======--
  procedure			WRITE_LABEL		( LBL :LABEL_TYPE; COMMENT :STRING := "" )
  is
  begin
    PUT ( "$ " );  PUT ( LBL,1 );
      
    if COMMENTS_ON and COMMENT /= "" then
       PUT ( ASCII.HT & ASCII.HT & ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    end if;
    NEW_LINE;

  end	WRITE_LABEL;
	--=======--



				--==============--
  procedure			GEN_LBL_ASSIGNMENT		( LBL :LABEL_TYPE; N :NATURAL )
  is
  begin
    PUT ( "$ " );  PUT ( LBL, 1 );  PUT ( " = " );  PUT ( N, 1 );
    NEW_LINE;

  end	GEN_LBL_ASSIGNMENT;
	--==============--



				--=======--
  procedure			TRACK_STACK		( OC :OP_CODE )
  is
    STK_OP_DELTA		: constant array( OP_CODE ) of OFFSET_TYPE := (						--| TABLE DES TAILLES DE CHAQUE INSTRUCTION (CODE EXTENSION)
		ABO  => -4,	ABSV =>  0,	ACA  => -2,	ACC  => -4,	ACT  =>  0,
		ADD  => -4,	ALO  => +4,	BAND => -4,	CHR  =>  0,	TRAP =>  0,
		CSTA =>  0,	CSTI =>  0,	CSTS =>  0,	CALL =>  0,	DEC  =>  0,
		DIV  => -4,	DPL  => +4,	EAC  =>  0,	EEX  =>  0,	ENT  =>  0,
		EQ   => -4,	ETD  =>  0,	ETE  =>  0,	ETK  =>  0,	ETR  =>  0,
		EXC  =>  0,	EXH  =>  0,	EXL  =>  0,	EXP  => -4,	JMPF =>  0,
		FRE  => -4,	GE   => -4,	GET  =>  0,	GT   => -4,	INC  =>  0,
		IND  =>  0,	IXA  => -4,	PGA  => +4,	LCA  => +4,	PLA  => +4,
		LDC  => +4,	PGD  => +4,	LE   => -4,	LT   => -4,	PLD  => +4,
		LVB  =>  0,	MODU => -4,	MOV  => -8,	MST  =>  0,	MUL  => -4,
		MVV  =>-12,	NEG  =>  0,	NEQ  => -4,	BNOT =>  0,	BOR  => -4,
		PKB  =>  0,	PKG  =>  0,	PRO  =>  0,	PUT  =>  0,	QUIT =>  0,
		RAI  =>  0,	REMN => -4,	RET  =>  0,	RFL  =>  0,	RFP  =>  0,
		SGD  => -4,	STO  => -8,	SLD  => -4,	SUB  => -4,	SWP  =>  0,
		JMPT => -4,	JMP  =>  0,	BXOR => -4,	XJP  => -4
			);
  begin
    TOP_ACT := TOP_ACT + STK_OP_DELTA( OC );
    if TOP_MAX < TOP_ACT then TOP_MAX := TOP_ACT; end if;

  end	TRACK_STACK;
	--=======--



				--========--
  procedure			EMIT_COMMENT		( COMMENT :STRING )
  is
  begin
    if COMMENTS_ON and COMMENT /= "" then
      PUT( ASCII.HT & ASCII.HT & "-- " & COMMENT );
    end if;

  end	EMIT_COMMENT;
	--========--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  COMMENT	:STRING  := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case  OC is
    when  BAND | BOR | BNOT | BXOR
	| EEX  | RAI		=> PUT( ASCII.HT );  PUT( OC, 0, LOWER_CASE );
    when QUIT			=> PUT( "  " );      PUT( OC, 0, UPPER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  CT	:CODE_DATA_TYPE;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    PUT( ASCII.HT );
    case OC is
    when  ADD    | SUB  | MUL | DIV
	| MODU | REMN | EXP
	| EQ   | NEQ 
	| GE   | GT   | LE  | LT
	| DPL  | SWP  | STO		=> PUT( OC, 0, LOWER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT( '.' );  PUT( CT, 0, LOWER_CASE );
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--


				------
  procedure			GEN_OC			( OC      :OP_CODE;
							  COMMENT :STRING := "" )
  is
  begin
    case OC is
    when LDC	=> PUT( ASCII.HT );  PUT( OC, 0, LOWER_CASE );
    when others	=> raise ILLEGAL_OP_CODE;
    end case;
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	GEN_OC;
	------


				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  B	:BOOLEAN;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    GEN_OC( OC );  PUT( ".B" & ASCII.HT & BOOLEAN'IMAGE( B ) );
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  C	:CHARACTER;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    GEN_OC( OC );  PUT( ".C" & ASCII.HT & "'" & CHARACTER'IMAGE( C ) & "'" );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  LBL	:LABEL_TYPE;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when JMPT | JMPF | JMP | LVB	=> PUT( OC, 0, LOWER_CASE );  PUT( ASCII.HT & "$ " );
    when EXH  | RFL			=> PUT( OC, 0, UPPER_CASE );  PUT( ASCII.HT & "$ " );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT        ( LBL, 1 );
    TRACK_STACK( OC );
            
    if COMMENTS_ON and COMMENT /= "" then
      if OC = EXH or OC = RFL then
        PUT ( ASCII.HT );
      end if;
      PUT ( ASCII.HT & ASCII.HT & "-- " & COMMENT ); 
    end if;
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  I	:INTEGER;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    PUT( ASCII.HT );
    case OC is
    when RAI		=> PUT( OC, 0, LOWER_CASE );  PUT( ASCII.HT & "# " );
    when  ALO | GET | IXA
	| MST | PUT | RET	=> PUT( OC, 0, LOWER_CASE );  PUT( ASCII.HT );
    when others		=> raise ILLEGAL_OP_CODE;
    end case;
    PUT( I, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  CT	:CODE_DATA_TYPE;
							  I	:INTEGER;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when DEC | INC | IND | LDC	=> PUT( OC, 0, LOWER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT( '.' );  PUT( CT, 0, LOWER_CASE );  PUT( ASCII.HT );  PUT( I, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  S	:STRING;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when PKG | PKB | PRO	=> PUT( OC, 0, UPPER_CASE );
    when others =>	raise ILLEGAL_OP_CODE;
    end case;
    PUT ( ASCII.HT & S );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;
  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	 :OP_CODE;
							  NUM, LBL :LABEL_TYPE;
							  COMMENT	 :STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when EXC	=> PUT( OC, 0, LOWER_CASE );
		   PUT( ASCII.HT & "# " );  PUT( NUM, 1 ); 
		   PUT( ASCII.HT & "$ " );  PUT( LBL, 1 );
                  
    when others	=> raise ILLEGAL_OP_CODE;
    end case;

    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  LBL	:LABEL_TYPE;
							  S	:STRING;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when EXL	=> PUT( OC, 0, UPPER_CASE );
		   PUT( ASCII.HT & "# " );  PUT( LBL, 1 );  PUT( ASCII.HT & S );     
    when others	=> raise ILLEGAL_OP_CODE;
    end case;
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  I	:INTEGER;
							  LBL	:LABEL_TYPE;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when CALL		=> PUT( OC, 0, LOWER_CASE );  PUT( I, 7 );
    when ENT		=> PUT( "  " );  PUT( OC, 0, UPPER_CASE );  PUT( I, 3 );
    when others		=> raise ILLEGAL_OP_CODE;
    end case;
    PUT( ASCII.HT & "$ " );  PUT( LBL, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  IA, IB	:INTEGER;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    PUT( ASCII.HT );
    case OC is
    when PLA | PGA | MST =>
      PUT( OC, 0, LOWER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT( ASCII.HT );
    PUT( IA, 1 ); 
    PUT( ASCII.HT );
    PUT( IB, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  CT	:CODE_DATA_TYPE;
							  IA, IB	:INTEGER;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when PGD | PLD | SGD | SLD =>
      PUT( OC, 0, LOWER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT( '.' );
    PUT( CT, 0, LOWER_CASE );
    PUT( ASCII.HT );
    PUT( IA, 1 ); 
    PUT( ASCII.HT );
    PUT( IB, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( OC	:OP_CODE;
							  I	:INTEGER;
							  S	:STRING;
							  COMMENT	:STRING := "" )
  is
  begin
    if not GENERATE_CODE then return; end if;

    case OC is
    when RFP =>
      PUT( "  " );
      PUT( OC, 0, UPPER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT( I, 9 ); 
    PUT( ASCII.HT & S ); 
            
    TRACK_STACK ( OC );
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--==--
  procedure			 EMIT			( P	:STD_PROC;
							  COMMENT	:STRING := "" )
  is
    STK_STD_PROC_DELTA	: constant array(STD_PROC) of OFFSET_TYPE := (
			AR1 =>  0,	AR2 => -4,	CLB =>   0,	CLN => -8,
			CNT => -8,	CVB => -4,	CYA => -12,	LBD => 0,	
			LEN => -4,	PUA => -16,	TRM =>  0
			);
  begin
    if not GENERATE_CODE then return; end if;

    PUT( ASCII.HT );
    PUT( TRAP, 0, LOWER_CASE );
    PUT( ASCII.HT & STD_PROC'IMAGE ( P ) );
            
    TOP_ACT := TOP_ACT + STK_STD_PROC_DELTA( P );
    if TOP_MAX < TOP_ACT then
      TOP_MAX := TOP_ACT;
    end if;
    EMIT_COMMENT( COMMENT ); 
    NEW_LINE;

  end	 EMIT;
	--==--



				--=========--
  procedure			GEN_PUSH_ADDR		( COMP_UNIT_NUMBER	:COMP_UNIT_NBR;
							  LVL		:LEVEL_TYPE;
							  OFFSET		:INTEGER;
							  COMMENT		:STRING := "" )
  is
  begin
    if LVL = 0 then
      EMIT( PGA, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );
    else
      EMIT( PLA, INTEGER(CUR_LEVEL - LVL), OFFSET, COMMENT );
    end if;

  end	GEN_PUSH_ADDR;
	--=========--



				--=========--
  procedure			GEN_PUSH_DATA		( CT		:CODE_DATA_TYPE;
							  COMP_UNIT_NUMBER	:COMP_UNIT_NBR;
							  LVL		:LEVEL_TYPE;
							  OFFSET		:INTEGER;
							  COMMENT		:STRING := "" )
  is
  begin
    if LVL = 0 then
      EMIT( PGD, CT, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );
    else
      EMIT( PLD, CT, INTEGER(CUR_LEVEL - LVL), OFFSET, COMMENT );
    end if;

  end	GEN_PUSH_DATA;
	--=========--



				--=====--
  procedure			GEN_STORE			( CT		:CODE_DATA_TYPE;
							  COMP_UNIT_NUMBER	:COMP_UNIT_NBR;
							  LVL		:LEVEL_TYPE;
							  OFFSET		:INTEGER;
							  COMMENT		:STRING := "" )
  is
  begin
    if LVL = 0 then
      EMIT( SGD, CT, INTEGER ( COMP_UNIT_NUMBER ), OFFSET, COMMENT );
    else
      EMIT( SLD, CT, INTEGER ( CUR_LEVEL - LVL ), OFFSET, COMMENT );
    end if;

  end	GEN_STORE; 
	--=====--



				--====--
  function			NEW_LABEL			return LABEL_TYPE
  is
  begin
    INT_LABEL := INT_LABEL + 1;
    return INT_LABEL;

  end	NEW_LABEL;
	--====--



				--=====--
  procedure			INC_LEVEL
  is
  begin
    CUR_LEVEL := CUR_LEVEL + 1;
  exception
    when CONSTRAINT_ERROR => raise STATIC_LEVEL_OVERFLOW;

  end	INC_LEVEL;
	--=====--



				--=====--
  procedure			DEC_LEVEL
  is
  begin
    CUR_LEVEL := CUR_LEVEL - 1;
  exception
    when CONSTRAINT_ERROR => raise STATIC_LEVEL_UNDERFLOW;

  end	DEC_LEVEL;
	--=====--

				--======--
  procedure			INC_OFFSET		( I :INTEGER )
  is
  begin
    OFFSET_ACT := OFFSET_ACT + OFFSET_TYPE( I );
    if OFFSET_MAX < OFFSET_ACT then
      OFFSET_MAX := OFFSET_ACT;
    end if;
  exception
    when CONSTRAINT_ERROR => raise STATIC_OFFSET_OVERFLOW;

  end	INC_OFFSET;
	--======--



				--===--
  procedure			 ALIGN			( AL :INTEGER )
  is
    TMP	: OFFSET_TYPE	:= OFFSET_ACT + AL - 1;
  begin
    OFFSET_ACT := TMP - TMP mod AL;

  end	 ALIGN;
	--===--



				--==========--
  procedure			PERFORM_RETURN		( ENCLOSING_BLOCK_BODY :TREE )
  is
    LVBLBL		: LABEL_TYPE;
    ENCLOSING_LEVEL		: INTEGER		:= DI( CD_LEVEL, ENCLOSING_BLOCK_BODY );
  begin
    if ENCLOSING_LEVEL /= EMITS.CUR_LEVEL then
      LVBLBL := NEW_LABEL;
      EMIT( LVB, LVBLBL);
      GEN_LBL_ASSIGNMENT( LVBLBL, EMITS.CUR_LEVEL - ENCLOSING_LEVEL );
    end if;
    EMIT( JMP, LABEL_TYPE( DI( CD_RETURN_LABEL, ENCLOSING_BLOCK_BODY ) ) );

  end	PERFORM_RETURN;
	--==========--



				--=====--
  function			TYPE_SIZE			( TYPE_SPEC :TREE )
							return NATURAL
  is
  begin
    case TYPE_SPEC.TY is
    when DN_ACCESS			=> return ADDR_SIZE;
    when DN_CONSTRAINED_ARRAY		=> return 2 * ADDR_SIZE;
    when DN_ENUMERATION | DN_INTEGER	=> return INTG_SIZE;
    when others =>
      PUT_LINE( "ERREUR TYPE_SIZE : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	TYPE_SIZE;
	--=====--



				--=============--
  function			CODE_DATA_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )
							return CODE_DATA_TYPE
  is
  begin
    if EXP_OR_TYPE_SPEC.TY in CLASS_EXP then
      declare
        EXP	: TREE	renames EXP_OR_TYPE_SPEC;
      begin
        case EXP.TY is
        when DN_FUNCTION_CALL | DN_PARENTHESIZED | DN_USED_OBJECT_ID =>
          return CODE_DATA_TYPE_OF( D( SM_EXP_TYPE, EXP ) );
                     
        when others =>
          PUT_LINE( "ERREUR CODE_DATA_TYPE_OF : EXP.TY ILLICITE " & NODE_NAME'IMAGE( EXP.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end;
            
    elsif EXP_OR_TYPE_SPEC.TY in CLASS_TYPE_SPEC then
      declare
        TYPE_SPEC	: TREE	renames EXP_OR_TYPE_SPEC;
      begin
        case TYPE_SPEC.TY is
        when DN_ACCESS =>
          return A;
                  
        when DN_ENUMERATION =>
          declare
            TYPE_SOURCE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
            TYPE_SYMREP	: TREE		:= D( LX_SYMREP, TYPE_SOURCE_NAME );
            NAME		: constant STRING	:= PRINT_NAME( TYPE_SYMREP );
          begin
            if NAME = "BOOLEAN" then
              return B;
            elsif NAME = "CHARACTER" then
              return C;
            else
              return I;
            end if;
          end;
                  
        when DN_INTEGER | DN_NUMERIC_LITERAL =>
          return I;
                  
        when others =>
          PUT_LINE( "ERREUR CODE_DATA_TYPE_OF : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end;
            
    else
      PUT_LINE ( "!!! CODE_DATA_TYPE_OF : EXP_OR_TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( EXP_OR_TYPE_SPEC.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	CODE_DATA_TYPE_OF;
   	--=============--



				--================--
  function			NUMBER_OF_DIMENSIONS	( EXP :TREE )
							return NATURAL
  is
  begin
    if EXP.TY in CLASS_CONSTRAINED then
      return NUMBER_OF_DIMENSIONS( D( SM_BASE_TYPE, EXP ) );
            
    elsif EXP.TY = DN_FUNCTION_CALL or EXP.TY = DN_USED_OBJECT_ID then
      return NUMBER_OF_DIMENSIONS( D( SM_EXP_TYPE, EXP ) );
            
    elsif EXP.TY = DN_ARRAY then
      return DI( CD_DIMENSIONS, EXP );
            
    else
      PUT_LINE( "ERREUR NUMBER_OF_DIMENSIONS : TYPE EXPRESSION ILLICITE" & NODE_NAME'IMAGE( EXP.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	NUMBER_OF_DIMENSIONS;
	--================--



				--===--
  procedure			GET_ULO			( OBJECT	  :TREE;
							  COMP_UNIT :out COMP_UNIT_NBR;
							  LVL	  :out LEVEL_TYPE;
							  OFS	  :out OFFSET_TYPE )
  is
  begin
    case OBJECT.TY is
    when DN_IN =>
      COMP_UNIT := 0;
      LVL       := DI( CD_LEVEL,  OBJECT );
      OFS       := DI( CD_OFFSET, OBJECT );
         
    when DN_IN_OUT_ID | DN_OUT_ID =>
      COMP_UNIT := 0;
      LVL       := DI( CD_LEVEL,      OBJECT );
      OFS       := DI( CD_VAL_OFFSET, OBJECT );
         
    when DN_INTEGER =>
      COMP_UNIT := DI( CD_COMP_UNIT, OBJECT );
      LVL       := DI( CD_LEVEL,     OBJECT );
      OFS       := DI( CD_OFFSET,    OBJECT );
         
    when DN_VARIABLE_ID =>
      COMP_UNIT := DI( CD_COMP_UNIT, OBJECT );
      LVL       := DI( CD_LEVEL,     OBJECT );
      OFS       := DI( CD_OFFSET,    OBJECT );
         
    when others =>
      PUT_LINE ( "ERREUR GET_ULO : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE( OBJECT.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	GET_ULO;
	--===--



				--=======--
  function			CONSTRAINED		( TYPE_SPEC :TREE )
							return BOOLEAN
  is
  begin
    return not ( TYPE_SPEC.TY in CLASS_UNCONSTRAINED );

  end	CONSTRAINED;
	--=======--



				--==========--
  procedure			LOAD_TYPE_SIZE		( TYPE_SPEC :TREE )
  is
  begin
    if CONSTRAINED( TYPE_SPEC ) then
      EMIT( LDC, I, TYPE_SIZE( TYPE_SPEC ), "LOAD TYPE SIZE" );
    else
      PUT_LINE( "ERREUR LOAD_TYPE_SIZE : TYPE_SPEC NON CONTRAINT" );
      raise PROGRAM_ERROR;
    end if;

  end	LOAD_TYPE_SIZE;
	--==========--



	-----
end	EMITS;
	-----