with DIANA_NODE_ATTR_CLASS_NAMES;
use  DIANA_NODE_ATTR_CLASS_NAMES;

			--------------------
	package body	CODAGE_INTERMEDIAIRE
			--------------------
is
   
  use OP_CODE_IO;
  use CODE_DATA_TYPE_IO;
 
  DEBUG				: BOOLEAN	:= TRUE;

  INACTIVE :BOOLEAN renames TRUE;

  INT_LABEL	: LABEL_TYPE	:= 1;
  FS		: FILE_TYPE;

  LAST_LBL			: TARGET_LBL_REF;
  LAST_BRANCH			: NUM_BRANCH;
  DERNIERE_REPRISE_CALL		: TARGET_LBL_REF	:= 0;




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
    STK_OP_DELTA		: constant array( OP_CODE ) of OFFSET_VAL := (						--| TABLE DES TAILLES DE CHAQUE INSTRUCTION (CODE EXTENSION)
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
    when PKG | PKB | PRO	=> PUT( '@' );--PUT( OC, 0, UPPER_CASE );
    when others =>	raise ILLEGAL_OP_CODE;
    end case;
    PUT ( S );
            
--    TRACK_STACK ( OC );
--    EMIT_COMMENT( COMMENT ); 
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
    STK_STD_PROC_DELTA	: constant array(STD_PROC) of OFFSET_VAL := (
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
  procedure			GEN_PUSH_DATA		( CT		:CODE_DATA_TYPE;
							  COMP_UNIT_NUMBER	:SEGMENT_NUM;
							  LVL		:LEVEL_NUM;
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
  procedure			DEC_OFFSET		( I :NATURAL )
  is
  begin
    OFFSET_ACT := OFFSET_ACT - OFFSET_VAL( I );
    if OFFSET_MAX > OFFSET_ACT then
      OFFSET_MAX := OFFSET_ACT;
    end if;
  exception
    when CONSTRAINT_ERROR => raise STATIC_OFFSET_OVERFLOW;

  end	DEC_OFFSET;
	--======--



				--===--
  procedure			 ALIGN			( AL :INTEGER )
  is
    TMP	: OFFSET_VAL	:= OFFSET_ACT - AL + 1;
  begin
--    OFFSET_ACT := - TMP + TMP mod AL;
null;
  end	 ALIGN;
	--===--



				--==========--
  procedure			PERFORM_RETURN		( ENCLOSING_BLOCK_BODY :TREE )
  is
    LVBLBL		: LABEL_TYPE;
    ENCLOSING_LEVEL		: LEVEL_NUM		:= LEVEL_NUM( DI( CD_LEVEL, ENCLOSING_BLOCK_BODY ) );
  begin
    if ENCLOSING_LEVEL /= CUR_LEVEL then
      LVBLBL := NEW_LABEL;
      EMIT( LVB, LVBLBL);
      GEN_LBL_ASSIGNMENT( LVBLBL, INTEGER( CUR_LEVEL - ENCLOSING_LEVEL ) );
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

				--===========--
  function			OPERAND_TYPE_OF		( EXP_OR_TYPE_SPEC :TREE )
							return OPERAND_TYPE
  is
  begin
    if EXP_OR_TYPE_SPEC.TY in CLASS_EXP then
      declare
        EXP	: TREE	renames EXP_OR_TYPE_SPEC;
      begin
        case EXP.TY is
        when DN_FUNCTION_CALL | DN_PARENTHESIZED | DN_USED_OBJECT_ID =>
          return OPERAND_TYPE_OF( D( SM_EXP_TYPE, EXP ) );
                     
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
          return ADR_TYP;
                  
        when DN_ENUMERATION =>
          declare
            TYPE_SOURCE_NAME	: TREE		:= D( XD_SOURCE_NAME, TYPE_SPEC );
            TYPE_SYMREP	: TREE		:= D( LX_SYMREP, TYPE_SOURCE_NAME );
            NAME		: constant STRING	:= PRINT_NAME( TYPE_SYMREP );
          begin
            if NAME = "BOOLEAN" then
              return BYTE_TYP;
            elsif NAME = "CHARACTER" then
              return BYTE_TYP;
            else
              return WORD_TYP;
            end if;
          end;
                  
        when DN_INTEGER | DN_NUMERIC_LITERAL =>
          return WORD_TYP;
                  
        when others =>
          PUT_LINE( "ERREUR CODE_DATA_TYPE_OF : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE( TYPE_SPEC.TY ) );
          raise PROGRAM_ERROR;
        end case;
      end;
            
    else
      PUT_LINE ( "!!! CODE_DATA_TYPE_OF : EXP_OR_TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( EXP_OR_TYPE_SPEC.TY ) );
      raise PROGRAM_ERROR;
    end if;

  end	OPERAND_TYPE_OF;
   	--===========--



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
  function			GET_SLO			( OBJECT	:TREE )	return SLO_LOC
  is
  begin
    case OBJECT.TY is
    when DN_IN | DN_IN_OUT_ID | DN_OUT_ID =>
      return ( 0, LEVEL_NUM( DI( CD_LEVEL, OBJECT ) ), OFFSET_VAL( DI( CD_OFFSET, OBJECT ) ) );
         
    when DN_INTEGER | DN_VARIABLE_ID =>
      return ( SEGMENT_NUM( DI( CD_COMP_UNIT, OBJECT ) ), LEVEL_NUM( DI( CD_LEVEL,     OBJECT ) ), OFFSET_VAL( DI( CD_OFFSET,    OBJECT ) ) );
                  
    when others =>
      PUT_LINE ( "ERREUR GET_ULO : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE( OBJECT.TY ) );
      raise PROGRAM_ERROR;
    end case;

  end	GET_SLO;
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



			--===--
  function 		NEW_LBL			return TARGET_LBL_REF is
  begin
    if LAST_LBL = MAX_TARGET_LBLS then raise TROP_DE_REPRISES; end if;

    LAST_LBL := LAST_LBL + 1;
    return LAST_LBL;

  end	NEW_LBL;
	--===--



			--====--
  procedure		STOCK_CP		( FOR_LBL :TARGET_LBL_REF )
  is
  begin
    TARGET_ILOC( FOR_LBL ) := COMPTEUR_PROGRAMME;

    if DEBUG then
      declare
        TARGET_IMG	:constant STRING := TARGET_LBL_REF'IMAGE( FOR_LBL );
      begin
        PUT_LINE( '@' & TARGET_IMG( 2..TARGET_IMG'LAST ) );
      end;
    end if;
  end	STOCK_CP;
	--====--


			------------
  function		OPER_TYPE_OF	( VAL :INTEGER ) return OPERAND_TYPE
  is
  begin
    if VAL <= 2**7-1	then return BYTE_TYP;
    elsif VAL <= 2**15-1	then return HALF_TYP;
    elsif VAL <= 2**31-1	then return WORD_TYP;
    elsif VAL <= 2**63-1	then return LONG_TYP;
    else raise OPERAND_OVERFLOW;
    end if;
  end	OPER_TYPE_OF;
	------------



			--====--
  function		LOAD_IMM			( IMM_VAL : INTEGER )	return OPERAND_REF
  is
    I_LOC		: INSTR_LOC	:= COMPTEUR_PROGRAMME;
    OPER_TYP	: OPERAND_TYPE	:= OPER_TYPE_OF( IMM_VAL );
    IMM_OPRND	: OPERAND_REC	:= (IMM, INACTIVE, OPER_TYP, VALEUR => IMM_VAL );
  begin

    TABLE_INSTRUCTIONS( I_LOC ) := ( ARG0, LIMM, IMM_OPRND );

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

    if DEBUG then
      declare
        DEFINING_ILOC_IMG	:constant STRING		:= INSTR_LOC'IMAGE( I_LOC );
        IMM_VAL_IMG		:constant STRING		:= INTEGER'IMAGE( IMM_VAL );
      begin
        PUT_LINE( ASCII.HT & '%' & DEFINING_ILOC_IMG(2..DEFINING_ILOC_IMG'LAST) & " = li." & OPERAND_TYPE_IMAGE( OPER_TYP ) & "  " & INTEGER'IMAGE( IMM_VAL ) );
      end;
    end if;

    return OPERAND_REF( I_LOC );

  end	LOAD_IMM;
	--====--


			---------
  function		SLO_IMAGE		( SLO : SLO_LOC)	return STRING
  is
    SEG_IMG	:constant STRING	:= SEGMENT_NUM'IMAGE( SLO.SEG );
    LVL_IMG	:constant STRING	:= LEVEL_NUM'IMAGE  ( SLO.LVL );
    OFS_IMG	:constant STRING	:= OFFSET_VAL'IMAGE ( SLO.OFS );
  begin
    return '[' & SEG_IMG( 2..SEG_IMG'LAST ) & '|' & LVL_IMG & '|' & OFS_IMG & ']';

  end	SLO_IMAGE;
	---------


			--------------
  function		OPER_TYPE_FROM	( SIZ :NATURAL ) return OPERAND_TYPE
  is
  begin
   if SIZ <= 8	then return BYTE_TYP;
    elsif SIZ <= 16	then return HALF_TYP;
    elsif SIZ <= 32	then return WORD_TYP;
    elsif SIZ <= 64	then return LONG_TYP;
    else raise OPERAND_OVERFLOW;
    end if;

  end	OPER_TYPE_FROM;
	--------------


			--====--
  function		LOAD_MEM		( DEFN :TREE )			return OPERAND_REF
  is
    I_LOC		: INSTR_LOC	:= COMPTEUR_PROGRAMME;
    SLO		: SLO_LOC		:= GET_SLO( DEFN );
    SIZ		: NATURAL		:= DI( CD_IMPL_SIZE, D( SM_OBJ_TYPE, DEFN ) );
    OPER_TYP	: OPERAND_TYPE	:= OPER_TYPE_FROM( SIZ );
    MEM_REF_OPRND	: OPERAND_REC	:= ( MEM, INACTIVE, OPER_TYP, LOC => SLO, SIZ => SIZ );
  begin
    TABLE_INSTRUCTIONS( I_LOC ) := (  ARG0, LOAD, MEM_REF_OPRND  );

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

    if DEBUG then
      declare
        DEFINING_ILOC_IMG	:constant STRING		:= INSTR_LOC'IMAGE( I_LOC );
      begin
        PUT_LINE( ASCII.HT & '%' & DEFINING_ILOC_IMG( 2..DEFINING_ILOC_IMG'LAST ) & " =." & OPERAND_TYPE_IMAGE( OPER_TYP )
		& SLO_IMAGE( SLO )
	    );
      end;
    end if;

    return OPERAND_REF( I_LOC );

  end	LOAD_MEM;
	--====--


				--=--
  procedure			STORE			( DEST_DEFN	:TREE;
							  OTYPE		:OPERAND_TYPE;
							  SRC_OPER	:OPERAND_REF )
  is
    SLO		: SLO_LOC		:= GET_SLO( DEST_DEFN );
    INDIC_LVL	: LEVEL_NUM;
  begin
    if SLO.LVL = 1 then
      INDIC_LVL := SLO.LVL;
    else
      INDIC_LVL := SLO.LVL - CUR_LEVEL;
    end if;

    if DEBUG then
      declare
        OPER_IMG	:constant STRING		:= OPERAND_REF'IMAGE( SRC_OPER );
      begin
        PUT( INSTR_LOC'IMAGE( COMPTEUR_PROGRAMME ) & ASCII.HT & SLO_IMAGE( SLO )
	& " = st." & OPERAND_TYPE_IMAGE( OTYPE ) & " %" & OPER_IMG( 2..OPER_IMG'LAST ) );

        NEW_LINE;
      end;
    end if;

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

  end	STORE; 
	--=--
	

				--====--
  function			LOAD_ADR			( DEFN :TREE )	return OPERAND_REF
  is
    I_LOC		: INSTR_LOC	:= COMPTEUR_PROGRAMME;
    SLO		: SLO_LOC		:= GET_SLO( DEFN );
    MEM_REF_OPRND	: OPERAND_REC	:= ( MEM, INACTIVE, ADR_TYP, LOC => SLO, SIZ => ADDR_SIZE * 8 );
  begin
    TABLE_INSTRUCTIONS( I_LOC ) := (  ARG0, LEA, MEM_REF_OPRND  );

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

    if DEBUG then
      declare
        DEFINING_ILOC_IMG	:constant STRING		:= INSTR_LOC'IMAGE( I_LOC );
      begin
        PUT_LINE( ASCII.HT & '%' & DEFINING_ILOC_IMG( 2..DEFINING_ILOC_IMG'LAST )
		& " = la " & SLO_IMAGE( SLO )
	    );
      end;
    end if;

    return OPERAND_REF( I_LOC );

  end	LOAD_ADR;
	--====--



			--==========--
  procedure		MAKE_OPRND_PRM		( OPERAND :OPERAND_REF; DIRECTION :DIRECTION_DE_PASSAGE )
  is
  begin
    TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ) := ( GENRE		=> PRM,
					PARAMETRE		=> ( FREE, INACTIF => TRUE, OPER_TYP => UNKNOWN, NEXT_FREE => 0 )
					);
    TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ).PARAMETRE := ( GENRE => PRM, OPER_TYP => UNKNOWN, DIRECTION => DIRECTION,
					PRM_OFS => 0, PRM_SIZ => 0, INACTIF => TRUE );
    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

  end	MAKE_OPRND_PRM;
	--==========--



			--===--
  procedure		ARG1_OP			( RESULTAT :OPERAND_REF; OP: OPCI_ARG1; X1: OPERAND_REF )
  is
    TERMINE	: BOOLEAN		:= FALSE;
  begin
--     if OP /= TRSF then
-- null;
--     end if;
    if not TERMINE then
      TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ) := (	ARG1, OP,
						ARG1_X1		=> ( FREE, INACTIVE, OPER_TYP => UNKNOWN, NEXT_FREE => 0 ),
						ARG1_RESULT	=> ( FREE, INACTIVE, OPER_TYP => UNKNOWN, NEXT_FREE => 0 )
						);
      COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;
    end if;


  end	ARG1_OP;
	--===--



			--====--
  procedure		FLOT0_OP		( OP :OPCI_FLOT0; ALLOC_DESALLOC :INTEGER := 0 )
  is 
  begin

    TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ) := ( FLOT0, OP,
					DESALLOC		=> ALLOC_DESALLOC,
					UNIT => 0, PROC => 0
					);

    if DEBUG then
      PUT( INSTR_LOC'IMAGE( COMPTEUR_PROGRAMME ) & ASCII.HT & OPCI_FLOT0'IMAGE( OP ) );
      if OP /= UNLINK then PUT( ' ' & INTEGER'IMAGE( ALLOC_DESALLOC ) ); end if;
      NEW_LINE;
    end if;

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

  end	FLOT0_OP;
	--====--


			--====--
  procedure		FLOT1_OP	( OP :OPCI_FLOT1; TARGET :TARGET_LBL_REF )
  is
  begin

    if LAST_BRANCH = MAX_BRANCHS then raise TROP_IFLOTS1; end if;

    LAST_BRANCH := LAST_BRANCH + 1;
    BRANCH_ILOC( LAST_BRANCH ) := COMPTEUR_PROGRAMME;

    TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ) := (	FLOT1, OP,
					FLOT1_SAUT	=> TARGET
					);

    if DEBUG then
      declare
        TARGET_IMG	:constant STRING := TARGET_LBL_REF'IMAGE( TARGET );
      begin
        PUT_LINE( INSTR_LOC'IMAGE( COMPTEUR_PROGRAMME ) & ASCII.HT & OPCI_FLOT1'IMAGE( OP )
	      & " @" & TARGET_IMG( 2..TARGET_IMG'LAST ) );
      end;
    end if;

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

  end	FLOT1_OP;
	--====--



			--====--
  procedure		FRAME_OP		( OP :OPCI_FRAME; ALLOC :INTEGER := 0 )
  is 
  begin

    TABLE_INSTRUCTIONS( COMPTEUR_PROGRAMME ) := (	FRAME, OP,
					ALLOC		=> ALLOC
					);

    if DEBUG then
      PUT( INSTR_LOC'IMAGE( COMPTEUR_PROGRAMME ) & ASCII.HT & OPCI_FRAME'IMAGE( OP ) );
      if OP /= UNLINK then PUT( ' ' & INTEGER'IMAGE( ALLOC ) ); end if;
      NEW_LINE;
    end if;

    COMPTEUR_PROGRAMME := COMPTEUR_PROGRAMME + 1;

  end	FRAME_OP;
	--====--


end	CODAGE_INTERMEDIAIRE;
	--------------------