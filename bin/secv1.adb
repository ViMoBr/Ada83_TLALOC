with TEXT_IO; use TEXT_IO;
procedure SECV1
is

  -- Etage A : record ordinaire
  type RA		is record
		  X, Y	: INTEGER;
		end record;
  type TA		is array( 0 .. 127 ) of RA;
  type PA		is access TA;
  CA		: constant RA	:= ( X=> 11, Y=> 22 );
  VA		: PA		:= new TA;

  -- Etage B/C : record represente 32 bits, calque du type TREE
  type NAMES		is ( N_VIRGIN, N_AA, N_BB, N_CC );
  type PG_T		is range 0 .. 16#7FFF#;	for PG_T'SIZE use 15;
  type LN_T		is range 0 .. 127;		for LN_T'SIZE use 7;
  type PT_T		is ( P, S, L, HI );

  type RB( PT : PT_T := P )	is record
			  case PT is
			  when P | S | L | HI =>
			    TY	: NAMES;
			    PG	: PG_T;
			    LN	: LN_T;
			  end case;
			end record;
				for RB'SIZE use 32;
				for RB use record at mod 4;
					PT	at 0 range 0..1;
					LN	at 0 range 2..8;
					PG	at 0 range 9..23;
					TY	at 0 range 24..31;
				end record;

  type TB		is array( 0 .. 127 ) of RB;
  type PB		is access TB;

  CB		: constant RB	:= ( P, TY=> N_VIRGIN, PG=> 0, LN=> 0 );
  VB		: PB		:= new TB;
  VC		: PB		:= new TB;

  NB_BAD_A	: INTEGER	:= 0;
  NB_BAD_B	: INTEGER	:= 0;
  NB_BAD_C	: INTEGER	:= 0;

begin

  -- Etage A
  VA.all := ( others=> CA );
  for I in 0 .. 127 loop
    if  VA.all( I ).X /= 11  or else  VA.all( I ).Y /= 22  then
      NB_BAD_A := NB_BAD_A + 1;
    end if;
  end loop;

  -- Etage B : constante de niveau declaratif
  VB.all := ( others=> CB );
  for I in 0 .. 127 loop
    if  VB.all( I ).TY /= N_VIRGIN  or else  VB.all( I ).PG /= 0
	or else  VB.all( I ).LN /= 0
    then
      NB_BAD_B := NB_BAD_B + 1;
    end if;
  end loop;

  -- Etage C : valeur construite sur place
  declare
    LOCB	: RB	:= ( P, TY=> N_VIRGIN, PG=> 0, LN=> 0 );
  begin
    VC.all := ( others=> LOCB );
  end;
  for I in 0 .. 127 loop
    if  VC.all( I ).TY /= N_VIRGIN  or else  VC.all( I ).PG /= 0
	or else  VC.all( I ).LN /= 0
    then
      NB_BAD_C := NB_BAD_C + 1;
    end if;
  end loop;

  PUT_LINE( "A:" & INTEGER'IMAGE( NB_BAD_A )
	& " B:" & INTEGER'IMAGE( NB_BAD_B )
	& " C:" & INTEGER'IMAGE( NB_BAD_C ) );

  if  NB_BAD_A = 0  and then  NB_BAD_B = 0  and then  NB_BAD_C = 0  then
    PUT_LINE( "SECV1 OK" );
  else
    PUT_LINE( "SECV1 ECHEC" );
  end if;

end SECV1;
