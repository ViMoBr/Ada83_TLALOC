with CG_LIB, CG_PRIVATE;
use CG_LIB, CG_PRIVATE;

package CG1 is

  ADDRSIZE             : constant Integer := 4;
  ADDRAL               : constant Integer := 2;
  BOOLSIZE             : constant Integer := 1;
  BOOLAL               : constant Integer := 1;
  CHARSIZE             : constant Integer := 1;
  CHARAL               : constant Integer := 1;
  INTEGERSIZE          : constant Integer := 2;
  INTEGERAL            : constant Integer := 2;
  STACKAL              : constant Integer := 2;
  ARRAYAL              : constant Integer := 2;
  RECORDAL             : constant Integer := 2;
  FIRSTPARAMOFFSET     : constant Integer := 10;
  FIRSTLOCALVAROFFSET  : constant Integer := 0;
  RELATIVERESULTOFFSET : constant Integer := 2;
  NIL                  : constant Integer := 0;

  type ACODEINSTRUCTIONS is
   (ANOT, AAND, AORR, AXOR, AQ, AEEX, ARAI, ATJP, AFJP, AUJP, ALVB, ARFL, AEXH, AADD, ASUB, AMUL, ADIV, AMOD, AREM,
    AEXP, AEQU, ANEQ, AGRE, AGEQ, ALES, ALEQ, ADPL, ASWP, ASTO, ALDC, ADEC, AINC, AIND, AALO, AGET, AIXA, APUT, ARET,
    AMST, ALDA, ALAO, APKG, APKB, APRO, AEXC, AEXL, ACUP, AENT, ALDO, ALOD, ASRO, ASTR, ARFP, ACSP,
AABO, AABS, AACA,
    AACC, AACT, ACHR, ACSTA, ACSTI, ACSTS, AEAC, AETD, AETE, AETK, AETR, AFRE, ALCA, AMOV, AMVV, ANEG, AXJP);
  subtype OPGEN0 is ACODEINSTRUCTIONS range ANOT .. ARAI;
  subtype OPGEN1LBL is ACODEINSTRUCTIONS range ARAI .. AEXH;

  subtype OPGEN0T is ACODEINSTRUCTIONS range AADD .. ASTO;
  subtype OPGEN1T is ACODEINSTRUCTIONS range ALDC .. ALDC;
  subtype OPGEN1NUMT is ACODEINSTRUCTIONS range ALDC .. AIND;
  subtype OPGEN1NUM is ACODEINSTRUCTIONS range AALO .. AMST;
  subtype OPGEN2NUMNUM is ACODEINSTRUCTIONS range AMST .. ALAO;
  subtype OPGEN1STR is ACODEINSTRUCTIONS range APKG .. APRO;
  subtype OPGEN2LBLLBL is ACODEINSTRUCTIONS range AEXC .. AEXC;
  subtype OPGEN2LBLSTR is ACODEINSTRUCTIONS range AEXL .. AEXL;
  subtype OPGEN2NUMLBL is ACODEINSTRUCTIONS range ACUP .. AENT;
  subtype OPGEN2NUMNUMT is ACODEINSTRUCTIONS range ALDO .. ASTR;
  subtype OPGEN2NUMSTR is ACODEINSTRUCTIONS range ARFP .. ARFP;

  type ACODETYPES is (A_A, A_B, A_C, A_I);

  type ACODESTANDARDPROCS is (AAR1, AAR2, ACLB, ACLN, ACNT, ACVB, ACYA, ALBD, ALEN, APUA, ATRM);

  GENERATECODE   : Boolean     := False;
  CURRCOMPUNITNR : Integer     := 0;
  LEVEL          : LEVEL_TYPE  := 0;
  OFFSETACT      : OFFSET_TYPE := 0;
  OFFSETMAX      : OFFSET_TYPE := 0;
  TOPACT         : OFFSET_TYPE := 0;
  TOPMAX         : OFFSET_TYPE := 0;

  function NEXTLABEL return LABEL_TYPE;

  procedure OPENOUTPUTFILE (FILENAME : String);
  procedure CLOSEOUTPUTFILE;
  procedure WRITECOMMENT (COMMENT : String);
  procedure WRITELABEL (LBL : LABEL_TYPE);
  procedure GENLABELASSIGNMENT (LBL : LABEL_TYPE; N : Integer);
  procedure GENO (ACI : ACODEINSTRUCTIONS);
  procedure GENOT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES);
  procedure GEN1T (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; V : VALUE);
  procedure GEN1LBL (ACI : ACODEINSTRUCTIONS; L : LABEL_TYPE);
  procedure GEN1NUM (ACI : ACODEINSTRUCTIONS; N : Integer);
  procedure GEN1NUMT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; Q : Integer);
  procedure GEN1STR (ACI : ACODEINSTRUCTIONS; S : String);
  procedure GEN2LBLLBL (ACI : ACODEINSTRUCTIONS; L1, L2 : LABEL_TYPE);
  procedure GEN2LBLSTR (ACI : ACODEINSTRUCTIONS; L : LABEL_TYPE; S : String);
  procedure GEN2NUMLBL (ACI : ACODEINSTRUCTIONS; N : Integer; L : LABEL_TYPE);
  procedure GEN2NUMNUM (ACI : ACODEINSTRUCTIONS; P, Q : Integer);
  procedure GEN2NUMNUMT (ACI : ACODEINSTRUCTIONS; ACT : ACODETYPES; P, Q : Integer);
  procedure GEN2NUMSTR (ACI : ACODEINSTRUCTIONS; N : Integer; S : String);
  procedure GENCSP (P : ACODESTANDARDPROCS);
  procedure GENLOADADDR (COMPUNITNR : Integer; LVL : LEVEL_TYPE; OFFS : Integer);
  procedure GENLOAD (ACT : ACODETYPES; COMPUNITNR : Integer; LVL : LEVEL_TYPE; OFFS : Integer);
  procedure GENSTORE (ACT : ACODETYPES; COMPUNITNR : Integer; LVL : LEVEL_TYPE; OFFS : Integer);
  procedure INCREMENTLEVEL;
  procedure DECREMENTLEVEL;
  procedure INCREMENTOFFSET (V : Integer);
  procedure ALIGN (AL : Integer);

end CG1;
