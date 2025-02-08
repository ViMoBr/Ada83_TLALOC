--	Vincent MORIN	Universite de Bretagne Occidentale	janvier 2025	Licence CC BY-SA 4.0
--	1	2	3	4	5	6	7	8	9	10	11	12


separate ( IDL )

				---------
	procedure			ERR_PHASE		( ACCES_TEXTE :STRING )
				---------
is
  FULL_LIST		: constant BOOLEAN		:= FALSE;
  IFILE			: FILE_TYPE;								--| LE FICHIER SOURCE
  LINE_COUNT		: NATURAL			:= 0;
  ERR_COUNT		: NATURAL;

begin
  OPEN_IDL_TREE_FILE ( IDL.LIB_PATH( 1..LIB_PATH_LENGTH ) & "$$$.TMP" );
  ERR_COUNT := DI( XD_ERR_COUNT, TREE_ROOT );
  if  ERR_COUNT = 0 then goto CLOSE_IDL_FILE;
  else NEW_LINE;
  end if;

  OPEN ( IFILE, IN_FILE, ACCES_TEXTE );
      
  declare
    SOURCE_LIST		: SEQ_TYPE	:= LIST ( TREE_ROOT );
    ERRORLIST		: SEQ_TYPE;
    SOURCENBR		: INTEGER		:= 0;							--| N° DE LIGNE PROVENANT DE LA LISTE
    NB_PREFIX_CHARS		: NATURAL;
    use IDL.INT_IO;
  begin
    loop
      if  IS_EMPTY( SOURCE_LIST )  then
        SOURCENBR := INTEGER'LAST;
        ERRORLIST := (TREE_NIL,TREE_NIL);
      else
        declare
          SOURCELINE	: TREE;
        begin
          POP( SOURCE_LIST, SOURCELINE );
          SOURCENBR := DI( XD_NUMBER, SOURCELINE );
          ERRORLIST := LIST( SOURCELINE );
        end;
      end if;
         
      while  LINE_COUNT < SOURCENBR  and then  not END_OF_FILE( IFILE )  loop
        LINE_COUNT := LINE_COUNT + 1;
        if  END_OF_LINE( IFILE )  then
          SKIP_LINE( IFILE );
          if  FULL_LIST  then
            NEW_LINE;
          end if;
        else
          declare
            SLINE		: STRING( 1 ..256 );							--| LA LIGNE COURANTE
            LAST		: NATURAL;								--| LONGUEUR DE LIGNE COURANTE
          begin
            GET_LINE ( IFILE, SLINE, LAST );
            if  FULL_LIST  or else  (not IS_EMPTY( ERRORLIST) and then LINE_COUNT = SOURCENBR)  then
              PUT ( LINE_COUNT, 1 );
              PUT ( ":  " );
	    NB_PREFIX_CHARS := NATURAL( TEXT_IO.COL ) -1;
              PUT_LINE ( SLINE( 1 .. LAST ) );
            end if;
          end;
        end if;
      end loop;
         
      while not IS_EMPTY( ERRORLIST ) loop
        declare
          ERROR	: TREE;
	COL	: INTEGER;
        begin
          POP( ERRORLIST, ERROR );
	COL := INTEGER( GET_SOURCE_COL( D( XD_SRCPOS, ERROR ) ) );
	for  N in 1 .. NB_PREFIX_CHARS+COL-1 loop PUT( ' ' );  end loop;
          PUT( "^ col ");
          PUT( COL, 1 );
          PUT_LINE( ": " & PRINT_NAME( D( XD_TEXT, ERROR ) ) );
        end;
      end loop;
         
      exit when SOURCENBR = INTEGER'LAST;
    end loop;
  end;
   
  CLOSE( IFILE );

<<CLOSE_IDL_FILE>>
  CLOSE_IDL_TREE_FILE;
   
 end	ERR_PHASE;
	---------

--	1	2	3	4	5	6	7	8	9	10	11	12
