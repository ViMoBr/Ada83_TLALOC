package TEST_VIS_1 is


  package P2 is

    type IP2	is new INTEGER;

  end P2;


  package P3 is

    use P2;	-- gnat propagates this use into P3.IMPL

    procedure IN_P3 ( PARAM :in out IP2 );

  end P3;


end TEST_VIS_1;
