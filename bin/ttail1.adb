with TEXT_IO; use TEXT_IO;
procedure TTAIL1
is

  NB_BAD	: INTEGER	:= 0;

  -- Record represente 32 bits, calque du type TREE (cf. SECV1)
  type NAMES		is ( N_VIRGIN, N_ROOT, N_LIST, N_LINE );
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

  type SEQ_B		is record
		  FIRST, NEXT	: RB;
		end record;

  -- Record ordinaire
  type RC		is record
		  X, Y	: INTEGER;
		end record;

  type SEQ_C		is record
		  FIRST, NEXT	: RC;
		end record;

  SB		: SEQ_B	:= ( FIRST=> ( P, TY=> N_ROOT, PG=> 0, LN=> 0 ),
			     NEXT=>  ( P, TY=> N_LIST, PG=> 1, LN=> 28 ) );

  SC		: SEQ_C	:= ( FIRST=> ( X=> 11, Y=> 22 ),
			     NEXT=>  ( X=> 33, Y=> 44 ) );

		---------
  function	MK_B	return RB
  is		---------
  begin
    return ( P, TY=> N_LIST, PG=> 1, LN=> 28 );
  end	MK_B;
	---------

		---------
  procedure	TEST_A	( S_PRM : SEQ_B )
  is		---------
    T	: RB	:= S_PRM.NEXT;				-- LE motif fautif d APPEND
  begin
    if  T.TY /= N_LIST  or else  T.PG /= 1  or else  T.LN /= 28  then
      PUT_LINE( "A ECHEC" );
      NB_BAD := NB_BAD + 1;
    else
      PUT_LINE( "A OK" );
    end if;
  end	TEST_A;
	---------

		---------
  procedure	TEST_C	( S_PRM : SEQ_C )
  is		---------
    T	: RC	:= S_PRM.NEXT;				-- meme motif, record ordinaire
  begin
    if  T.X /= 33  or else  T.Y /= 44  then
      PUT_LINE( "C ECHEC" );
      NB_BAD := NB_BAD + 1;
    else
      PUT_LINE( "C OK" );
    end if;
  end	TEST_C;
	---------

		---------
  procedure	TEST_F
  is		---------
    T	: RB	:= MK_B;				-- producteur @doublet : non-regression
  begin
    if  T.TY /= N_LIST  or else  T.PG /= 1  or else  T.LN /= 28  then
      PUT_LINE( "F ECHEC" );
      NB_BAD := NB_BAD + 1;
    else
      PUT_LINE( "F OK" );
    end if;
  end	TEST_F;
	---------

begin

  TEST_A( SB );
  TEST_C( SC );
  TEST_F;

  if  NB_BAD = 0  then
    PUT_LINE( "TTAIL1 OK" );
  else
    PUT_LINE( "TTAIL1 ECHEC" );
  end if;

end TTAIL1;
