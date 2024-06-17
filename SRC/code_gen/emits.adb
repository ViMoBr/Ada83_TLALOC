with DIANA_NODE_ATTR_CLASS_NAMES;
use  DIANA_NODE_ATTR_CLASS_NAMES;

						-----
		package body			EMITS
						-----
is
   
  use OP_CODE_IO;
  use CODE_TYPE_IO;
   
      
  INT_LABEL	: LABEL_TYPE	:= 1;
  FS		: FILE_TYPE;
  CDX		: constant array(OP_CODE) of OFFSET_TYPE := (						--| TABLE DES TAILLES DE CHAQUE INSTRUCTION (CODE EXTENSION)
			-4,  0, -2, -4,  0, -4,  4, -4,  0,
			 0,  0,  0,  0,  0,  0, -4,  4,  0,
			 0,  0, -4,  0,  0,  0,  0,  0,  0,
			 0, -4,  0, -4, -4,  0, -4,  0,  0,
			-4,  4,  4,  4,  4,  4, -4, -4,  4,
			 0, -4, -8,  0, -4,-12,  0, -4,  0,
			-4,  0,  0,  0,  0,  0,  0, -4,  0,
			 0,  0, -4, -8, -4, -4,  0, -4,  0,
			 0, -4
			);
  PDX		: constant array(STD_PROC) of OFFSET_TYPE := (
			0, -4, 0, -8, -8, -4, -12, 0, -4, -16, 0
			);

		----------------
  procedure	OPEN_OUTPUT_FILE		( FILE_NAME :STRING )
  is		----------------
  begin
    CREATE ( FS, OUT_FILE, FILE_NAME & ".COD" );
    SET_OUTPUT ( FS );										--| CODAGE SUR SORTIE STANDARD
    INT_LABEL := 1;

  end OPEN_OUTPUT_FILE;

		-----------------
  procedure	CLOSE_OUTPUT_FILE
  is		-----------------
  begin
    SET_OUTPUT ( STANDARD_OUTPUT );
    CLOSE ( FS );
  end CLOSE_OUTPUT_FILE;
      
  package INT_IO	is new INTEGER_IO ( INTEGER ); use INT_IO;
  package LBL_IO	is new INTEGER_IO ( LABEL_TYPE ); use LBL_IO;


		-----------
  procedure	WRITE_LABEL		( LBL :LABEL_TYPE; COMMENT :STRING := "" )
  is		-----------
  begin
    PUT ( "$ " );  PUT ( LBL,1 );									--| LABEL IMPRIME SUR 6 CARACTERES
      
    if COMMENTS_ON and COMMENT /= "" then
       PUT ( ASCII.HT & ASCII.HT & ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    end if;
    NEW_LINE;
  end WRITE_LABEL;

		------------------
  procedure	GEN_LBL_ASSIGNMENT		( LBL :LABEL_TYPE; N :NATURAL )
  is		------------------
  begin
    PUT ( "$ " );  PUT ( LBL, 1 );  PUT ( " = " );  PUT ( N, 1 );
    NEW_LINE;
  end GEN_LBL_ASSIGNMENT;

		-----------
  procedure	TRACK_STACK		( OC :OP_CODE )
  is		-----------
  begin
    TOP_ACT := TOP_ACT + CDX( OC );
    if TOP_MAX < TOP_ACT then TOP_MAX := TOP_ACT; end if;
  end TRACK_STACK;

		------------
  procedure	EMIT_COMMENT		( COMMENT :STRING )						--| ESSENTIELLEMENT POUR INDIQUER LES PARTIES RESTANT A FAIRE
  is		------------
  begin
    if COMMENTS_ON and COMMENT /= "" then
      PUT ( ASCII.HT & ASCII.HT & "--| " & COMMENT );
    end if;
  end EMIT_COMMENT;

		----
  procedure	EMIT			( OC :OP_CODE; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case  OC is
    when  BAND | BOR | BNOT | BXOR
	| EEX  | RAI		=> PUT ( ASCII.HT );  PUT ( OC, 0, LOWER_CASE );
    when QUIT			=> PUT ( "  " );  PUT ( OC, 0, UPPER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; CT :CODE_TYPE; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    PUT ( ASCII.HT );
    case OC is
    when  ADD  | SUB  | MUL | DIV
	| MODU | REMN | EXP
	| EQ   | NEQ 
	| GE   | GT   | LE  | LT
	| DPL  | SWP  | STO		=> PUT ( OC, 0, LOWER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT ( '.' );  PUT ( CT, 0, LOWER_CASE );
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;


  procedure GEN_OC ( OC :OP_CODE; COMMENT :STRING := "" ) is
  begin
    case OC is
    when LDC	=> PUT ( ASCII.HT );  PUT ( OC, 0, LOWER_CASE );
    when others	=> raise ILLEGAL_OP_CODE;
    end case;
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end GEN_OC;

		----
  procedure	EMIT		( OC :OP_CODE; B :BOOLEAN; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    GEN_OC ( OC );  PUT ( ".B" & ASCII.HT & BOOLEAN'IMAGE ( B ) );
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; C :CHARACTER; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    GEN_OC ( OC );  PUT ( ".C" & ASCII.HT & "'" & CHARACTER'IMAGE ( C ) & "'" );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end;

		----
  procedure	EMIT		( OC :OP_CODE; LBL :LABEL_TYPE; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when JMPT | JMPF | JMP | LVB	=> PUT ( OC, 0, LOWER_CASE );  PUT ( ASCII.HT & "$ " );
    when EXH  | RFL		=> PUT ( OC, 0, UPPER_CASE );  PUT ( ASCII.HT & "$ " );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT ( LBL, 1 );
    TRACK_STACK ( OC );
            
    if COMMENTS_ON and COMMENT /= "" then
      if OC = EXH or OC = RFL then
        PUT ( ASCII.HT );
      end if;
      PUT ( ASCII.HT & ASCII.HT & "--| " & COMMENT ); 
    end if;
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; I :INTEGER; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    PUT ( ASCII.HT );
    case OC is
    when RAI		=> PUT ( OC, 0, LOWER_CASE );  PUT ( ASCII.HT & "# " );
    when  ALO | GET | IXA
	| MST | PUT | RET	=> PUT ( OC, 0, LOWER_CASE );  PUT ( ASCII.HT );
    when others		=> raise ILLEGAL_OP_CODE;
    end case;
    PUT ( I, 1 );
            
    TRACK_STACK ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; CT :CODE_TYPE; I :INTEGER; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when DEC | INC | IND | LDC	=> PUT ( OC, 0, LOWER_CASE );
    when others			=> raise ILLEGAL_OP_CODE;
    end case;
    PUT ( '.' );  PUT ( CT, 0, LOWER_CASE );  PUT ( ASCII.HT );  PUT ( I, 1 );
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; S :STRING; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when PKG | PKB | PRO	=> PUT ( OC, 0, UPPER_CASE );
    when others =>	raise ILLEGAL_OP_CODE;
    end case;
    PUT ( ASCII.HT & S );
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( OC :OP_CODE; NUM, LBL :LABEL_TYPE; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when EXC	=> PUT ( OC, 0, LOWER_CASE );
		   PUT ( ASCII.HT & "# " );  PUT ( NUM, 1 ); 
		   PUT ( ASCII.HT & "$ " );  PUT ( LBL, 1 );
                  
    when others	=> raise ILLEGAL_OP_CODE;
    end case;

    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT	( OC :OP_CODE; LBL :LABEL_TYPE; S :STRING; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when EXL	=> PUT ( OC, 0, UPPER_CASE );
		   PUT ( ASCII.HT & "# " );  PUT ( LBL, 1 );  PUT ( ASCII.HT & S );     
    when others	=> raise ILLEGAL_OP_CODE;
    end case;
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end;

		----
  procedure	EMIT	( OC :OP_CODE; I :INTEGER; LBL :LABEL_TYPE; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when CALL		=> PUT ( OC, 0, LOWER_CASE );  PUT ( I, 7 );
    when ENT		=> PUT ( "  " );  PUT ( OC, 0, UPPER_CASE );  PUT ( I, 3 );
    when others		=> raise ILLEGAL_OP_CODE;
    end case;
    PUT ( ASCII.HT & "$ " );  PUT ( LBL, 1 );
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT ( OC :OP_CODE; IA, IB :INTEGER; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    PUT ( ASCII.HT );
    case OC is
    when LDA | LAO | MST =>
      PUT ( OC, 0, LOWER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT ( ASCII.HT );
    PUT ( IA, 1 ); 
    PUT ( ASCII.HT );
    PUT ( IB, 1 );
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT	( OC :OP_CODE; CT :CODE_TYPE; IA, IB :INTEGER; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when LDO | LOD | SRO | STR =>
      PUT ( OC, 0, LOWER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT ( '.' );
    PUT ( CT, 0, LOWER_CASE );
    PUT ( ASCII.HT );
    PUT ( IA, 1 ); 
    PUT ( ASCII.HT );
    PUT ( IB, 1 );
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT ( OC :OP_CODE; I :INTEGER; S :STRING; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    case OC is
    when RFP =>
      PUT ( "  " );
      PUT ( OC, 0, UPPER_CASE );
    when others =>
      raise ILLEGAL_OP_CODE;
    end case;
    PUT ( I, 9 ); 
    PUT ( ASCII.HT & S ); 
            
    TRACK_STACK  ( OC );
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		----
  procedure	EMIT		( P :STD_PROC; COMMENT :STRING := "" )
  is		----
  begin
    if not GENERATE_CODE then return; end if;
    PUT ( ASCII.HT );
    PUT ( TRAP, 0, LOWER_CASE );
    PUT ( ASCII.HT & STD_PROC'IMAGE ( P ) );
            
    TOP_ACT := TOP_ACT + PDX( P );
    if TOP_MAX < TOP_ACT then
      TOP_MAX := TOP_ACT;
    end if;
    EMIT_COMMENT ( COMMENT ); 
    NEW_LINE;
  end EMIT;

		-------------
  procedure	GEN_LOAD_ADDR	( COMP_UNIT_NUMBER :COMP_UNIT_NBR;
				  LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" )
  is		-------------
  begin
    if LVL = 0 then										--| NIVEAU 0 (UNITES DE PREMIER NIVEAU)
      EMIT ( LAO, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );					--| LAO GLOBAL POUR L UNITE AVEC LE DECALAGE REQUIS
    else											--| NIVEAUX DE PROFONDEUR NON NULLE
      EMIT ( LDA, INTEGER(LEVEL - LVL), OFFSET, COMMENT );						--| CHARGEMENT AU NIVEAU REQUIS AVEC SUIVI DES LIENS STATIQUES ET DECALAGE
    end if;
  end GEN_LOAD_ADDR;

		--------
  procedure	GEN_LOAD		( CT :CODE_TYPE; COMP_UNIT_NUMBER :COMP_UNIT_NBR;
				  LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" )
  is		--------
  begin
    if LVL = 0 then
      EMIT ( LDO, CT, INTEGER(COMP_UNIT_NUMBER), OFFSET, COMMENT );
    else
      EMIT ( LOD, CT, INTEGER(LEVEL - LVL), OFFSET, COMMENT );
    end if;
  end;
--|#################################################################################################
--|
--|	PROCEDURE GEN_STORE
--|
procedure GEN_STORE ( CT :CODE_TYPE; COMP_UNIT_NUMBER :COMP_UNIT_NBR; LVL :LEVEL_TYPE; OFFSET :INTEGER; COMMENT :STRING := "" ) is
begin
  if LVL = 0 then					--| POUR LE NIVEAU 0
    EMIT ( SRO, CT, INTEGER ( COMP_UNIT_NUMBER ), OFFSET, COMMENT );		--| STOCKAGE GLOBAL POUR UNE UNITE DE PREMIER NIVEAU AU DECALAGE REQUIS
  else					--| PPOUR LES AUTRES NIVEAUX
    EMIT ( STR, CT, INTEGER ( LEVEL - LVL ), OFFSET, COMMENT );		--| STOCKAGE AU NIVEAU REQUIS AVEC SUIVI DES LIENS STATIQUES ET DECALAGE
  end if;
end; 
--|#################################################################################################
--|
--|	FUNCTION NEXT_LABEL
--|
function NEXT_LABEL return LABEL_TYPE is
begin
  INT_LABEL := INT_LABEL + 1;
  return INT_LABEL;
end;
--|#################################################################################################
--|
procedure INC_LEVEL is
begin
  LEVEL := LEVEL + 1;
exception
  when CONSTRAINT_ERROR => raise STATIC_LEVEL_OVERFLOW;
end;
--|#################################################################################################
--|
procedure DEC_LEVEL is
begin
  LEVEL := LEVEL - 1;
exception
  when CONSTRAINT_ERROR => raise STATIC_LEVEL_UNDERFLOW;
end;
--|#################################################################################################
--|
procedure INC_OFFSET ( I :INTEGER ) is
begin
  OFFSET_ACT := OFFSET_ACT + OFFSET_TYPE ( I );			--| AUGMENTER LE DECALAGE
  if OFFSET_MAX < OFFSET_ACT then				--| SI LE DECALAGE MAX EST AU DESSOUS DU DECALAGE ACTUEL
    OFFSET_MAX := OFFSET_ACT;				--| METTRE A JOUR LE DECALAGE MAX
  end if;
exception
  when CONSTRAINT_ERROR => raise STATIC_OFFSET_OVERFLOW;
end;
--|#################################################################################################
--|
--|	PROCEDURE ALIGN
--|
procedure ALIGN ( AL :INTEGER ) is
  TMP	: OFFSET_TYPE	:= OFFSET_ACT + AL - 1;
begin
  OFFSET_ACT := TMP - TMP mod AL;
end;
--|#################################################################################################
--|
--|	PROCEDURE PERFORM_RETURN	
--|
procedure PERFORM_RETURN ( ENCLOSING_BLOCK_BODY :TREE ) is
  LVBLBL	: LABEL_TYPE;
  ENCLOSING_LEVEL	: INTEGER	:= DI ( CD_LEVEL, ENCLOSING_BLOCK_BODY );	--| NIVEAU IMBRICATION STATIQUE DU BLOC ENGLOBANT
begin
  if ENCLOSING_LEVEL /= EMITS.LEVEL then			--| SI LE NIVEAU D IMBRICATION 
    LVBLBL := NEXT_LABEL;
    EMIT ( LVB, LVBLBL);				--| EMETTRE UN LEAVE BLOCK AVEC ETIQUETTE VERS LA DIFFERENCE DE NIVEAU
    GEN_LBL_ASSIGNMENT ( LVBLBL, EMITS.LEVEL - ENCLOSING_LEVEL );		--| DONNER LA VALEUR DIFFERENCE DE NIVEAU A CETTE ETIQUETTE
  end if;
  EMIT ( JMP, LABEL_TYPE( DI ( CD_RETURN_LABEL, ENCLOSING_BLOCK_BODY ) ) );		--| SAUT INCONDITIONNEL À L'ETIQUETTE DE SORTIE DU BLOC ENGLOBANT
end PERFORM_RETURN;
--|#################################################################################################
--|
--|	FUNCTION TYPE_SIZE
--|
function TYPE_SIZE ( TYPE_SPEC :TREE ) return NATURAL is
begin
  case TYPE_SPEC.TY is
  when DN_ACCESS =>
    return ADDR_SIZE;
  when DN_CONSTRAINED_ARRAY =>
    return 2* ADDR_SIZE;
  when DN_ENUMERATION | DN_INTEGER =>
    return INTG_SIZE;
  when others =>
    PUT_LINE ( "!!! TYPE_SIZE : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
    raise PROGRAM_ERROR;
  end case;
end;
--|#################################################################################################
--|
--|	FUNCTION CODE_TYPE_OF
--|
function CODE_TYPE_OF ( EXP_OR_TYPE_SPEC :TREE ) return CODE_TYPE is
begin
  if EXP_OR_TYPE_SPEC.TY in CLASS_EXP then
    declare
      EXP	: TREE	renames EXP_OR_TYPE_SPEC;
    begin
      case EXP.TY is
      when DN_FUNCTION_CALL | DN_PARENTHESIZED | DN_USED_OBJECT_ID =>
        return CODE_TYPE_OF ( D ( SM_EXP_TYPE, EXP ) );
                     
      when others =>
        PUT_LINE ( "!!! CODE_TYPE_OF : EXP.TY ILLICITE " & NODE_NAME'IMAGE ( EXP.TY ) );
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
          TYPE_SOURCE_NAME	: TREE	:= D ( XD_SOURCE_NAME, TYPE_SPEC );
          TYPE_SYMREP	: TREE	:= D ( LX_SYMREP, TYPE_SOURCE_NAME );
          NAME	: constant STRING	:= PRINT_NAME ( TYPE_SYMREP );
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
        PUT_LINE ( "!!! CODE_TYPE_OF : TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( TYPE_SPEC.TY ) );
        raise PROGRAM_ERROR;
      end case;
    end;
            
  else
    PUT_LINE ( "!!! CODE_TYPE_OF : EXP_OR_TYPE_SPEC.TY ILLICITE " & NODE_NAME'IMAGE ( EXP_OR_TYPE_SPEC.TY ) );
    raise PROGRAM_ERROR;
  end if;
end CODE_TYPE_OF;
   
--|#################################################################################################
--|
--|	FUNCTION NUMBER_OF_DIMENSIONS
--|
function NUMBER_OF_DIMENSIONS ( EXP :TREE ) return NATURAL is
begin
  if EXP.TY in CLASS_CONSTRAINED then
    return NUMBER_OF_DIMENSIONS ( D ( SM_BASE_TYPE, EXP ) );
            
  elsif EXP.TY = DN_FUNCTION_CALL or EXP.TY = DN_USED_OBJECT_ID then
    return NUMBER_OF_DIMENSIONS ( D ( SM_EXP_TYPE, EXP ) );
            
  elsif EXP.TY = DN_ARRAY then
    return DI ( CD_DIMENSIONS, EXP );
            
  else
    PUT_LINE ( "!!! NUMBER_OF_DIMENSIONS : TYPE EXPRESSION ILLICITE" & NODE_NAME'IMAGE ( EXP.TY ) );
    raise PROGRAM_ERROR;
  end if;
end NUMBER_OF_DIMENSIONS;
--|#################################################################################################
--|
--|	PROCEDURE GET_CLO
--|
procedure GET_CLO ( OBJECT :TREE; COMP_UNIT :out COMP_UNIT_NBR; LVL :out LEVEL_TYPE; OFS :out OFFSET_TYPE ) is
begin
  case OBJECT.TY is
  when DN_IN =>
    COMP_UNIT := 0;
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  when DN_IN_OUT_ID | DN_OUT_ID =>
    COMP_UNIT := 0;
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_VAL_OFFSET, OBJECT );
         
  when DN_INTEGER =>
    COMP_UNIT := DI ( CD_COMP_UNIT, OBJECT );
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  when DN_VARIABLE_ID =>
    COMP_UNIT := DI ( CD_COMP_UNIT, OBJECT );
    LVL       := DI ( CD_LEVEL, OBJECT );
    OFS       := DI ( CD_OFFSET, OBJECT );
         
  when others =>
    PUT_LINE ( "!!! GET_CLO : OBJECT.TY ILLICITE " & NODE_NAME'IMAGE ( OBJECT.TY ) );
    raise PROGRAM_ERROR;
  end case;
end GET_CLO;
--|#################################################################################################
--|
--|	FUNCTION CONSTRAINED
--|
function CONSTRAINED ( TYPE_SPEC :TREE ) return BOOLEAN is
begin
  return not ( TYPE_SPEC.TY in CLASS_UNCONSTRAINED );
end;
--|#################################################################################################
--|
--|	PROCEDURE LOAD_TYPE_SIZE
--|
procedure LOAD_TYPE_SIZE ( TYPE_SPEC :TREE ) is
begin
  if CONSTRAINED ( TYPE_SPEC ) then
    EMIT ( LDC, I, TYPE_SIZE ( TYPE_SPEC ), "LOAD TYPE SIZE" );
  else
    PUT_LINE ( "!!! LOAD_TYPE_SIZE : TYPE_SPEC NON CONTRAINT" );
    raise PROGRAM_ERROR;
  end if;
end LOAD_TYPE_SIZE;
--|-------------------------------------------------------------------------------------------------
end EMITS;
