with UNCHECKED_CONVERSION;
separate( IDL )
--|-------------------------------------------------------------------------------------------------
--|		PRINT_NOD
--|-------------------------------------------------------------------------------------------------
package body PRINT_NOD is
   
		--| POUR DETERMINER SI LA MACHINE EST LITTLE-ENDIAN OU BIG-ENDIAN

  DUMMY2			: INTEGER;
  DUMMY			: array ( 1 .. 4 ) of CHARACTER
			  := (CHARACTER'VAL( 1 ), ASCII.NUL, ASCII.NUL, ASCII.NUL);
  for DUMMY use at DUMMY2'ADDRESS;
  IS_LITTLE_ENDIAN		: constant BOOLEAN		:= (DUMMY2 = 1);
   
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PNN
--|
function  L_PNN ( NN :NODE_NAME ) return NATURAL is
  STR		: constant STRING		:= NODE_NAME'IMAGE( NN );
begin
  PUT ( STR );
  return STR'LENGTH;
end;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PINT							--| IMPRIME UN ENTIER 16 BITS
--|
function L_PINT ( I :INTEGER ) return NATURAL is
begin
  if I < 0 then									--| ENTIER NEGATIF
    if I < -32767 then								--| PAS DE VALEUR POSITIVE CORRESPONDANTE
      PUT ( "-32768" );								--| ECRIRE LA VALEUR NEGATIVE MINIMALE
      return 6;									--| 6 CARACTERES DE LONG
    else										--| CAS STANDARD DES NEGATIFS POUR LESQUELS UNE VALEUR POSITIVE CORRESPONDANTE EXISTE
      PUT ( '-' );									--| METTRE LE SIGNE
      return L_PINT ( -I ) + 1;							--| IMPRIMER LE POSITIF ET RETOURNER LA LONGUEUR (AVEC SIGNE -)
    end if;
  elsif I > 9 then									--| POSITIF ET NOMBRE A PLUS D'1 CHIFFRE
    return L_PINT ( I/10 ) + L_PINT ( I mod 10 );						--| IMPRIMER LE DIV SUIVI DU MOD EN RETOURNANT LEUR LONGUEUR TOTALE
  else										--| POSITIF A 1 SEUL CHIFFRE
    PUT ( CHARACTER'VAL ( CHARACTER'POS ( '0' ) + I ) );					--| IMPRIMER LE CHIFFRE
    return 1;
  end if;
end;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION L_PINT
--|
function L_PINT ( P :VPG_IDX ) return NATURAL is
begin return L_PINT( INTEGER( P ) ); end;

function  L_PINT ( L :LINE_IDX ) return NATURAL is
begin return L_PINT ( INTEGER( L ) ); end;

function  L_PINT ( S :POSITIVE_SHORT ) return NATURAL is
begin return L_PINT ( INTEGER( S ) ); end;

function  L_PINT ( C :SRCCOL_IDX ) return NATURAL is
begin return L_PINT ( INTEGER( C ) ); end;
--|-------------------------------------------------------------------------------------------------
--|		FUNCTION PRINT_ABS_TREE
--|
function PRINT_ABS_TREE ( T :TREE ) return INTEGER is					--| IMPRESSION D'UN POINTEUR DENOTANT UNE ANOMALIE
  SIZE		: INTEGER		:= 8;						--| LE "!?>" DE DEBUT PLUS LES DEUX . ET LE "<?!" DE FIN
begin
  PUT ( "!?>" );
  case T.PT is
  when P | L => SIZE := SIZE + L_PNN ( T.TY );
    PUT( 'P' ); SIZE := SIZE + L_PINT( T.PG );
    PUT( 'L' ); SIZE := SIZE + L_PINT( T.LN );

  when HI => SIZE := SIZE + L_PNN( T.NOTY );
    PUT( 'S' ); SIZE := SIZE + L_PINT( T.NSIZ );
    PUT( 'A' ); SIZE := SIZE + L_PINT( T.ABSS );
  when S => SIZE := SIZE + L_PINT( T.COL );
    PUT( 'P' ); SIZE := SIZE + L_PINT( T.SPG );
    PUT( 'L' ); SIZE := SIZE + L_PINT( T.SLN );
  end case;
  PUT ( "<?!" );
  return SIZE;
end;
--|-------------------------------------------------------------------------------------------------
--|		PROCEDURE PUT_LONG_DIGIT
--|
procedure PUT_LONG_DIGIT ( I :INTEGER ) is						--| ENTIER A 4 CHIFFRES AVEC ZEROS NON SIGNIFICATIFS
  DUMMY: INTEGER;
begin
  if I < 1000 then
    PUT ( '0' );
    if I < 100 then
      PUT ( '0' );
      if I < 10 then
        PUT ( '0' );
       end if;
    end if;
  end if;
  DUMMY := L_PINT ( I );
end;
   
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE PRINT_TREE
--|
procedure PRINT_TREE ( T :TREE ) is
  DUMMY		: INTEGER;
begin
  DUMMY := L_PRINT_TREE( T );
end;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION L_PRINT_TREE
--|
function L_PRINT_TREE ( T :TREE ) return NATURAL is

  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION TRAITE_SOURCELINE
  --|
  function TRAITE_SOURCELINE return NATURAL is						--| CAS DU NOEUD S (SOURCE_LINE)
  begin
    if T.SPG > PAGE_MAN.HIGH_VPG then							--| LE CHAMP PG EST HORS DU FICHIER ARBRE (ANORMAL)
      return PRINT_ABS_TREE( T );							--| IMPRIMER COMME <?!
    end if;
               
    declare
      NB_CARS	: NATURAL;
      SLPTR	: TREE		:= (P, TY=> DN_SOURCELINE, PG=> T.SPG, LN=> T.SLN);	--| FABRIQUER UN POINTEUR DE SOURCELINE NORMAL AVEC LE POINTEUR SOURCE_POSITION
      SLNOD	: TREE		:= D( XD_NUMBER, SLPTR );				--| XD_NUMBER UN ENTIER
    begin
      NB_CARS := L_PRINT_TREE( SLPTR );							--| FAIRE IMPRIMER LE NOEUD LIGNE SOURCE (PG=LIGNE ET LN=COL)
      PUT( '(' );									--| ON SUIT AVEC LE CONTENU
      if SLNOD.NOTY = DN_NUM_VAL then							--| UNE VALEUR NUMERIQUE ENTIERE (16 BITS)
        NB_CARS := NB_CARS + L_PINT( SLNOD.ABSS );					--| FAIRE IMPRIMER LA VALEUR 16 BITS (NUM LIGNE)
      else									--| ANOMALIE
        NB_CARS := NB_CARS + PRINT_ABS_TREE( SLNOD );					--| AU FORMAT $$TY.PG.LN$$ POUR INFORMATION
      end if;
      PUT( ',' );
      NB_CARS := NB_CARS + L_PINT( T.COL );
      PUT( ')' );
      return NB_CARS + 3;								--| LES NOMBRES PLUS (,)
    end;
  end;
  --|-----------------------------------------------------------------------------------------------
  --|		FUNCTION TRAITE_NUM_VAL
  --|
  function TRAITE_NUM_VAL return NATURAL is
  begin
    if T.PT = HI then								--| VALEUR COURTE 16 BITS
      if T.NSIZ = 1 then								--| VALEUR NEGATIVE
        return L_PINT( INTEGER( -T.ABSS - 1 ) );						--| IMPRIMER
      else									--| VALEUR POSITIVE
        PUT ( '+' );								--| PREFIXER PAR LE SIGNE
        return L_PINT( T.ABSS ) + 1;							--| IMPRIMER ET DONNER LA TAILLE AVEC LE SIGNE EN PLUS
      end if;
               
    elsif T.PT = P then								--| POINTEUR VERS BLOC GRAND ENTIER
      if not (T.PG in 1.. PAGE_MAN.HIGH_VPG) then						--| ANOMALIE SUR L ADRESSE DE PAGE
        return PRINT_ABS_TREE( T );
      end if;
              
      declare									--| UN VRAI DN_NUM_VAL
        ENTETE		: TREE		:= DABS( 0, T );				--| ENTETE CONTENANT LE NOMBRE DE DIGITS
        type DOUBLET	is array( 1..2 ) of SHORT;
        function TO_DOUBLET	is new UNCHECKED_CONVERSION( TREE, DOUBLET );
        DD		: DOUBLET		:= TO_DOUBLET( DABS( 1, T ) );		--| PREMIERE PAIRE DE DIGITS BASE 10000
        NB_CARS		: INTEGER		:= 0;
      begin

--        IF DD(1) >= 10000 THEN							--| 10000 EST AJOUTE AU PREMIER POUR NB NEGATIF
        if ENTETE.ABSS = 1 then							--| ABSS 1 POUR NB NEGATIF
          PUT( '-' ); 								--| CHIFFRE NEGATIF
        else
          PUT( '+' );								--| DE 0 A 9_999 : CHIFFRE POSITIF
        end if;
        for I in 1 .. ENTETE.NSIZ loop
          DD := TO_DOUBLET( DABS( I, T ) );						--| PAIRE DE DIGITS
          PUT_LONG_DIGIT( INTEGER( DD(1) mod 10_000 ) );					--| SECOND DIGIT 10_000 AIRE
          PUT( '_' );
          PUT_LONG_DIGIT( INTEGER( DD(2) mod 10_000 ) );					--| PREMIER DIGIT 10_000 AIRE (MOD POUR LE PREMIER
          if I /= ENTETE.NSIZ then
            if (I mod 8) = 1 then
              NEW_LINE;
            end if;
            PUT( '_' );
          end if;
          NB_CARS := NB_CARS + 10;
        end loop;
        return NB_CARS;
      end;
    end if;
    return 0;
  end;
       
begin
  case T.PT is

  when S =>									--| POSITION SOURCE
    return TRAITE_SOURCELINE;

  when HI =>									--| TREE REPRESENTANT UN ENTIER 16 BITS STRICTEMENT NEGATIF OU UNE POSITION SOURCE
    if T.NOTY = DN_NUM_VAL then							--| VALEUR ENTIERE COURTE
      return TRAITE_NUM_VAL;
    else
      declare
        NAM	: constant STRING		:= NODE_NAME'IMAGE( T.NOTY );			--| CHAINE DU TYPE DE NOEUD
      begin
        PUT ( '(' & NAM & ')' );							--| IMPRIMER LE NOM DU TYPE DE NOEUD
        return NAM'LENGTH + 2;							--| AJOUTER SA LONGUEUR
      end;
    end if;  

  when P =>									--| 
    if T.TY = DN_NUM_VAL then								--| VALEUR ENTIERE LONGUE
      return TRAITE_NUM_VAL;
    end if;  
      
    declare
      NB_CARS	: INTEGER;
    begin										--| PAS UNE VALEUR ENTIERE
      declare
        NAM	: constant STRING	:= NODE_NAME'IMAGE( T.TY );				--| CHAINE DU TYPE DE NOEUD
      begin
        PUT( '[' & NAM );								--| IMPRIMER LE NOM DU TYPE DE NOEUD
        NB_CARS := NAM'LENGTH + 1;							--| AJOUTER SA LONGUEUR
      end;
               
      PUT( ",P" );
      NB_CARS := NB_CARS + L_PINT( T.PG );						--| PAGE OU BLOC DU POINTEUR
      PUT( ",L" );
      NB_CARS := NB_CARS + L_PINT( T.LN ) + 5;						--| LIGNE DU POINTEUR ET AJOUTER LES TAILLES
      PUT( "]" );
               
      if T.PG = 0 then								--| CAS INHABITUEL AU RELOC ?
        return NB_CARS;								--| ARRETER ICI
      end if;
               
      if T.TY = DN_TXTREP then							--| CAS PARTICULIER D'UN TXTREP
        PUT( ' ' );
        if T.PG > PAGE_MAN.HIGH_VPG then						--| HORS BORNES (!)
          PUT ( "!?TXT?!" );
          NB_CARS := NB_CARS + 7;							--| TAILLE NOM PLUS UN' ' ET SIX $
          return NB_CARS;
        end if;
                  
        declare
          NAM	: constant STRING		:= PRINT_NAME( T );
        begin
          PUT( NAM );
          NB_CARS := NB_CARS + 1 + NAM'LENGTH;
        end;
      end if;
      return NB_CARS;
    end;

  when L => null;
  end case;
  return 0;
end L_PRINT_TREE;
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		PROCEDURE PRINT_NODE
--|
procedure PRINT_NODE ( T :TREE; INDENT :NATURAL := 0 ) is
       
  --|-----------------------------------------------------------------------------------------------
  --|		 PROCEDURE PRINT_SUB
  --|
  procedure PRINT_SUB ( T :TREE; IND :NATURAL ) is
    A_SIZ		: ATTR_NBR	:= N_SPEC( T.TY ).NS_SIZE;
    N_SIZ		: ATTR_NBR	:= A_SIZ;
    A_SUB		: INTEGER		:= N_SPEC( T.TY ).NS_FIRST_A;
    TR		: TREE;
    SQ		: SEQ_TYPE;
    --|---------------------------------------------------------------------------------------------
    --|		PROCEDURE PRINT_SUB_TREE
    --|
    procedure PRINT_SUB_TREE ( T :TREE ) is
    begin
      PRINT_TREE( T );
      if T.PT = P and then (T.TY = DN_SYMBOL_REP and T.PG > 0) then
        PUT( PRINT_NAME( T ) );
      end if;
    end PRINT_SUB_TREE;
            
  begin
    if T.TY = DN_HASH then
      TR := DABS( 0, T );
      N_SIZ := TR.NSIZ;
    end if;
         
    for I in 1 .. N_SIZ loop
            
      for J in 1 .. IND loop
        PUT( ' ' );
      end loop;
      PUT( "  " );
            
      if T.TY = DN_HASH then
        PUT( '-' );
      else
        PUT( ATTR_IMAGE ( A_SPEC( A_SUB ).ATTR ) );
      end if;
            
      if (A_SPEC( A_SUB ).IS_LIST = FALSE) or else T.TY = DN_HASH then
        PUT( ": " );
        PRINT_SUB_TREE( DABS( I, T ) );
      else
        SQ.FIRST := DABS( I, T );
        SQ.NEXT := TREE_NIL;
               
        if SQ.FIRST = TREE_NIL then
          PUT( ": < >" );
        elsif SQ.FIRST.TY /= DN_LIST then
          PUT( ": < " );
          PRINT_SUB_TREE( SQ.FIRST );
          PUT( " >" );
        else
          PUT_LINE( ":" );
          for I in 1 .. IND loop
            PUT( ' ' );
          end loop;
          PUT( "   < " );
          loop
            PRINT_SUB_TREE( HEAD( SQ ) );
            SQ := TAIL(SQ);
            exit when SQ.FIRST = TREE_NIL;
            PUT_LINE( "," );
            for I in 1 .. IND loop
              PUT( ' ' );
            end loop;
            PUT( "     " );
          end loop;
          PUT( " >" );
        end if;
               
      end if;
      NEW_LINE;
      A_SUB := A_SUB + 1;
    end loop;
         
  end PRINT_SUB;
         
begin
  PRINT_TREE( T );
  NEW_LINE;
  if T.PT = S then
    PRINT_SUB(  (P, PG=> T.SPG, TY=> DN_SOURCELINE, LN=> T.SLN ),  INDENT );
  elsif T.PT = P then
    PRINT_SUB( T, INDENT );
  end if;
  NEW_LINE;
end PRINT_NODE;
--|-------------------------------------------------------------------------------------------------
end PRINT_NOD;
