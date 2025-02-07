with TEXT_IO; use TEXT_IO;

package body CG1 is

	OUTFILE  : TEXT_IO.FILE_TYPE;
	INTLABEL : LABEL_TYPE := 1;
	CDX      : array (ACODEINSTRUCTIONS) of INTEGER;
	PDX      : array (ACODESTANDARDPROCS) of INTEGER;

	procedure INTWRITECOMMENT (T : POSITIVE_COUNT; COMMENT : STRING := "" ) is
	begin
		if GENERATECODE then
			if COMMENT /= "" then
				SET_COL ( OUTFILE, COL ( OUTFILE ) + T );
				PUT ( OUTFILE, "- " );
				PUT ( OUTFILE, COMMENT );
			end if;
			NEW_LINE ( OUTFILE );
		end if;
	end INTWRITECOMMENT;

	procedure WRITECOMMENT ( COMMENT : STRING ) is
	begin
		INTWRITECOMMENT (1, COMMENT);
	end WRITECOMMENT;

	procedure CONDITIONALERROR (ERRORNUMBER : INTEGER; ERRORCONDITION : BOOLEAN; COMMENT : STRING := "") is
	begin
		if ERRORCONDITION then
			WRITECOMMENT ( COMMENT );
			TEXT_IO.CLOSE (OUTFILE);
			ERROR (ERRORNUMBER);
		end if;
	end CONDITIONALERROR;

	procedure INITCDX is
	begin
		CDX (AABO) := -4; CDX (AABS) := 0;  CDX (AACA) := -2;
		CDX (AACC) := -4; CDX (AACT) := 0;  CDX (AADD) := -4;
		CDX (AALO) := 4;  CDX (AAND) := -4; CDX (ACHR) := 0;
		CDX (ACSP) := 0;  CDX (ACSTA) := 0; CDX (ACSTI) := 0;
		CDX (ACSTS) := 0; CDX (ACUP) := 0;  CDX (ADEC) := 0;
		CDX (ADIV) := -4; CDX (ADPL) := 4;  CDX (AEAC) := 0;
		CDX (AEEX) := 0;  CDX (AENT) := 0;  CDX (AEQU) := -4;
		CDX (AETD) := 0;  CDX (AETE) := 0;  CDX (AETK) := 0;
		CDX (AETR) := 0;  CDX (AEXC) := 0;  CDX (AEXH) := 0;
		CDX (AEXL) := 0;  CDX (AEXP) := -4; CDX (AFJP) := 0;
		CDX (AFRE) := -4; CDX (AGEQ) := -4; CDX (AGET) := 0;
		CDX (AGRE) := -4; CDX (AINC) := 0;  CDX (AIND) := 0;
		CDX (AIXA) := -4; CDX (ALAO) := 4;  CDX (ALCA) := 4;
		CDX (ALDA) := 4;  CDX (ALDC) := 4;  CDX (ALDO) := 4;
		CDX (ALEQ) := -4; CDX (ALES) := -4; CDX (ALOD) := 4;
		CDX (ALVB) := 0;  CDX (AMOD) := -4; CDX (AMOV) := -8;
		CDX (AMST) := 0;  CDX (AMUL) := -4; CDX (AMVV) := -12;
		CDX (ANEG) := 0;  CDX (ANEQ) := -4; CDX (ANOT) := 0;
		CDX (AORR) := -4; CDX (APKB) := 0;  CDX (APKG) := 0;
		CDX (APRO) := 0;  CDX (APUT) := 0;  CDX (AQ) := 0;
		CDX (ARAI) := 0;  CDX (AREM) := -4; CDX (ARET) := 0;
		CDX (ARFL) := 0;  CDX (ARFP) := 0;  CDX (ASRO) := -4;
		CDX (ASTO) := -8; CDX (ASTR) := -8; CDX (ASUB) := -4;
		CDX (ASWP) := 0;  CDX (ATJP) := 0;  CDX (AUJP) := 0;
		CDX (AXOR) := -4; CDX (AXJP) := -4;
	end INITCDX;

	procedure INITPDX is
	begin
		PDX (AAR1) :=  0;
		PDX (AAR2) := -4;
		PDX (ACLB) :=  0;
		PDX (ACLN) := -8;
		PDX (ACNT) := -8;
		PDX (ACVB) := -4;
		PDX (ACYA) := -12;
		PDX (ALEN) :=  0;
		PDX (ALBD) := -4;
		PDX (APUA) := -16;
		PDX (ATRM) :=  0;
	end INITPDX;

	procedure OPENOUTPUTFILE (FILENAME : STRING) is
	begin
		TEXT_IO.CREATE (OUTFILE, TEXT_IO.OUT_FILE, FILENAME);
	end OPENOUTPUTFILE;

	procedure CLOSEOUTPUTFILE is
	begin
		TEXT_IO.CLOSE (OUTFILE);
	end CLOSEOUTPUTFILE;

	function NEXTLABEL return LABEL_TYPE is
	begin
		CONDITIONALERROR (5004, INTLABEL >= MAXLABEL);
		INTLABEL := INTLABEL + 1;
		return INTLABEL;
	end NEXTLABEL;


	procedure WRITEACODETYPE (ACT : ACODETYPES) is
	begin
		case ACT is
			when A_A => PUT (OUTFILE, 'A');
			when A_B => PUT (OUTFILE, 'B');
			when A_C => PUT (OUTFILE, 'C');
			when A_I => PUT (OUTFILE, 'I');
		end case;
	end WRITEACODETYPE;

	function OPCODE_IMAGE ( ACI : ACODEINSTRUCTIONS ) return STRING is
		IM	 : constant STRING	:= ACODEINSTRUCTIONS'IMAGE ( ACI );
	begin return IM ( IM'FIRST + 1 .. IM'LAST );
	end OPCODE_IMAGE;

	function OPTYPE_IMAGE ( ACT : ACODETYPES ) return STRING is
		IM	 : constant STRING	:= ACODETYPES'IMAGE ( ACT );
	begin return IM ( IM'FIRST + 2 .. IM'LAST );
	end OPTYPE_IMAGE;

	procedure WRITELABEL (LBL : LABEL_TYPE) is
	begin
		TEXT_IO.PUT (OUTFILE, "L" & INTEGER'IMAGE (LBL) & ":");
		INTWRITECOMMENT (27);
	end WRITELABEL;

	procedure GENLABELASSIGNMENT (LBL : LABEL_TYPE; N : INTEGER) is
	begin
		TEXT_IO.PUT ( OUTFILE, "L" & INTEGER'IMAGE (LBL) & " = " & INTEGER'IMAGE (N) & ";");
		INTWRITECOMMENT (15);
	end GENLABELASSIGNMENT;

	procedure TRACK_DATA_STACK ( ACI : ACODEINSTRUCTIONS ) is
	begin
		TOPACT := TOPACT + CDX (ACI);
		if TOPACT > TOPMAX then
			TOPMAX := TOPACT;
		end if;
	end TRACK_DATA_STACK;

	procedure GENO ( ACI : ACODEINSTRUCTIONS ) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN0'FIRST .. OPGEN0'LAST => PUT (OUTFILE, OPCODE_IMAGE (ACI));
			when others => CONDITIONALERROR (8, TRUE);
		end case;
	end GENO;

	procedure GENOT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN0T'FIRST .. OPGEN0T'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & "." & OPTYPE_IMAGE ( ACT ) );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
	end GENOT;

	procedure GEN1T (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; V : VALUE) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN1T'FIRST .. OPGEN1T'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI)  & "." & OPTYPE_IMAGE ( ACT )  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     

		case ACT is
			when A_B => if V.BOO_VAL then PUT (OUTFILE, "B   true" ); else PUT (OUTFILE, "B   false" ); end if;
			when A_C =>
				if CHARACTER'POS ( V.CHR_VAL ) = 127 then
					PUT ( OUTFILE, "C   #127" );
				elsif V.CHR_VAL < ' ' then
					PUT ( OUTFILE, "C   #" & CHARACTER'IMAGE (V.CHR_VAL) );
				else
					PUT ( OUTFILE, "C     " &  V.CHR_VAL );
				end if;
			when A_I => PUT ( OUTFILE, 'I' & INTEGER'IMAGE ( V.INT_VAL ) );
			when others => CONDITIONALERROR (8, TRUE);
		end case;
		INTWRITECOMMENT (22);
	end GEN1T;

	procedure GEN1LBL (ACI : ACODEINSTRUCTIONS; L : LABEL_TYPE) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN1LBL'FIRST .. OPGEN1LBL'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & " L" & INTEGER'IMAGE (L) );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN1LBL;

	procedure GEN1NUM (ACI : ACODEINSTRUCTIONS; N : INTEGER) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );

		case ACI is
			when OPGEN1NUM'FIRST .. OPGEN1NUM'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & " " & INTEGER'IMAGE (N) );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (22);
	end GEN1NUM;

	procedure GEN1NUMT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; Q : INTEGER) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN1NUMT'FIRST .. OPGEN1NUMT'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI)  & "." & OPTYPE_IMAGE ( ACT ) & " " & INTEGER'IMAGE (Q)  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (22);
	end GEN1NUMT;

	procedure GEN1STR (ACI : ACODEINSTRUCTIONS; S : STRING) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN1STR'FIRST .. OPGEN1STR'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI)  & " " & S  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN1STR;

	procedure GEN2LBLLBL (ACI : ACODEINSTRUCTIONS; L1, L2 : LABEL_TYPE) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2LBLLBL'FIRST .. OPGEN2LBLLBL'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI)  & " L" & INTEGER'IMAGE (L1) & " L" & INTEGER'IMAGE (L2)  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (1);
	end GEN2LBLLBL;

	procedure GEN2LBLSTR (ACI : ACODEINSTRUCTIONS; L : LABEL_TYPE; S : STRING) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2LBLSTR'FIRST .. OPGEN2LBLSTR'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI)  & " L" & INTEGER'IMAGE (L) & " " & S  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN2LBLSTR;

	procedure GEN2NUMLBL (ACI : ACODEINSTRUCTIONS; N : INTEGER; L : LABEL_TYPE) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2NUMLBL'FIRST .. OPGEN2NUMLBL'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & ' ' & INTEGER'IMAGE (N) & " L" & INTEGER'IMAGE (L) );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (8);
	end GEN2NUMLBL;

	procedure GEN2NUMNUM (ACI : ACODEINSTRUCTIONS; P, Q : INTEGER) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2NUMNUM'FIRST .. OPGEN2NUMNUM'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & " " & INTEGER'IMAGE (P) & ", " & INTEGER'IMAGE (Q)  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN2NUMNUM;

	procedure GEN2NUMNUMT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; P, Q : INTEGER) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2NUMNUMT'FIRST .. OPGEN2NUMNUMT'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & "." & OPTYPE_IMAGE ( ACT ) & " " & INTEGER'IMAGE (P) & " " & INTEGER'IMAGE (Q)  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN2NUMNUMT;

	procedure GEN2NUMSTR (ACI : ACODEINSTRUCTIONS; N : INTEGER; S : STRING) is
	begin
		if not GENERATECODE then return; end if;
		TRACK_DATA_STACK ( ACI );
		case ACI is
			when OPGEN2NUMSTR'FIRST .. OPGEN2NUMSTR'LAST => 
				PUT (OUTFILE, OPCODE_IMAGE (ACI) & " " & INTEGER'IMAGE (N) & " " & S  );
			when others => CONDITIONALERROR (8, TRUE);
		end case;     
		INTWRITECOMMENT (15);
	end GEN2NUMSTR;

	procedure GENCSP (P : ACODESTANDARDPROCS) is
	begin
		if not GENERATECODE then return; end if;
		TEXT_IO.PUT_LINE (OUTFILE, "CSP" & " " & ACODESTANDARDPROCS'IMAGE (P));
		TOPACT := TOPACT + PDX (P);
		if TOPACT > TOPMAX then
			TOPMAX := TOPACT;
		end if;
	end GENCSP;

	procedure GENLOADADDR (COMPUNITNR : INTEGER; LVL : LEVEL_TYPE; OFFS : INTEGER) is
	begin
		GEN2NUMNUM ( ALDA, COMPUNITNR, LVL );
		GEN1NUM ( AALO, OFFS );
	end GENLOADADDR;

	procedure GENLOAD (ACT : ACODETYPES; COMPUNITNR : INTEGER; LVL : LEVEL_TYPE; OFFS : INTEGER) is
	begin
		GENLOADADDR (COMPUNITNR, LVL, OFFS);
		GENOT (ALOD, ACT);
	end GENLOAD;

	procedure GENSTORE (ACT : ACODETYPES; COMPUNITNR : INTEGER; LVL : LEVEL_TYPE; OFFS : INTEGER) is
	begin
		GENLOADADDR (COMPUNITNR, LVL, OFFS);
		GENOT (ASTO, ACT);
	end GENSTORE;

	procedure INCREMENTLEVEL is
	begin
		CONDITIONALERROR (5005, LEVEL >= MAXLEVEL);
		LEVEL := LEVEL + 1;
	end INCREMENTLEVEL;

	procedure DECREMENTLEVEL is
	begin
		CONDITIONALERROR (9, LEVEL <= 0);
		LEVEL := LEVEL - 1;
	end DECREMENTLEVEL;

	procedure INCREMENTOFFSET (V : INTEGER) is
	begin
		CONDITIONALERROR (5005, OFFSETACT + V >= MAXOFFSET);
		OFFSETACT := OFFSETACT + V;
		if OFFSETACT > OFFSETMAX then OFFSETMAX := OFFSETACT; end if;
	end INCREMENTOFFSET;

	procedure ALIGN (AL : INTEGER) is
		TEMP : INTEGER;
	begin
		TEMP       := OFFSETACT + AL - 1;
		OFFSETACT := TEMP - TEMP mod AL;
		if OFFSETACT > OFFSETMAX then
			OFFSETMAX := OFFSETACT;
		end if;
	end ALIGN;

begin
	INITCDX;
	INITPDX;
	INTLABEL := 0;
	LEVEL := 0;
	TOPMAX := 0;
	TOPACT := 0;
end CG1;
