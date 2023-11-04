   with Text_io;
   use  Text_io;
   --|----------------------------------------------------------------------------------------------
   --|	CG_1
   --|----------------------------------------------------------------------------------------------
    package CG_1 is
   
      max_Label	: constant	:= 30_000;
      max_Offset	: constant	:= 10_000;
      max_Level	: constant	:= 200;
   
      subtype Label_Type	is Natural range 0..max_Label;
      subtype Offset_Type	is Integer range -max_Offset..max_Offset;
      subtype Level_Type	is Natural range 0..max_Level;
   
      addr_Size	: constant	:= 4;
      addr_Al	: constant	:= 2;
      bool_Size	: constant	:= 1;
      bool_Al	: constant	:= 1;
      char_Size	: constant	:= 1;
      char_Al	: constant	:= 1;
      intg_Size	: constant	:= 2;
      intg_Al	: constant	:= 2;
      stack_Al	: constant	:= 2;
      array_Al	: constant	:= 2;
      record_Al	: constant	:= 2;
   
      first_Param_Offset	: constant	:= 10;
      first_Local_Var_Offset	: constant	:= 0;
      relative_Result_Offset	: constant	:= 2;
      comments_On	: Boolean	:= true;
   
      type Op_Code	is (
      ABO,   ABSV,  ACA,   ACC,   ACT,  add,   alloc, band,  CHR,
      trap,  CSTA,  CSTI,  CSTS,  call, dec,   div,   DPL,   EAC,
      EEX,   ENT,   eq,    ETD,   ETE,  ETK,   ETR,   EXC,   EXH,
      EXL,   EXP,   jmpf,  FRE,   ge,   GET,   gt,    inc,   IND,
      IXA,   LAO,   LCA,   LDA,   const,LDO,   le,    lt,    LOD,
      LVB,   MODU,  MOV,   MST,   MUL,  MVV,   neg,   neq,   bnot,
      bor,   PKB,   PKG,   PRO,   PUT,  QUIT,  RAI,   remn,  ret,
      RFL,   RFP,   SRO,   STO,   STR,  sub,   swap,  jmpt,  jmp,
      bxor,  XJP
      );
      
       package Op_Code_io	is new Enumeration_io ( Op_Code );
   
      type Code_Type is ( A, B, C, I );
      
       package Code_Type_io	is new Enumeration_io ( Code_Type );
   
      type Std_Proc	is (
      AR1, AR2, CLB, CLN, CNT, CVB, CYA, LBD, LEN, PUA, TRM
      );
   
      subtype Comp_Unit_Nbr	is Natural range 0..255;
   
      cur_Comp_Unit		: Comp_Unit_Nbr;
      generate_Code		: Boolean	:= true;
      level		: Level_Type;
   
      offset_Act		: Offset_Type;
      offset_Max		: Offset_Type;
      top_Act		: Offset_Type;
      top_Max		: Offset_Type;
      
       procedure Open_Output_File	( file_Name :String );
       procedure Close_Output_File;
       procedure Write_Label	( lbl :Label_Type );
       procedure Gen_Lbl_Assignment	( lbl :Label_Type; n :Natural );
       procedure Gen_0	( oc :Op_Code; comment :String := "" );
       procedure Gen_0	( oc :Op_Code; ct :Code_Type; comment :String := "" );
       procedure Gen_1_b	( oc :Op_Code; b :Boolean; comment :String := "" );
       procedure Gen_1_c	( oc :Op_Code; c :Character; comment :String := "" );
       procedure Gen_1_l	( oc :Op_Code; lbl :Label_Type; comment :String := "" );
       procedure Gen_1_i	( oc :Op_Code; i :Integer; comment :String := "" );
       procedure Gen_1_i	( oc :Op_Code; ct :Code_Type; i :Integer; comment :String := "" );
       procedure Gen_1_s	( oc :Op_Code; s :String; comment :String := "" );
       procedure Gen_2_ll	( oc :Op_Code; num, lbl :Label_Type; comment :String := "" );
       procedure Gen_2_ls	( oc :Op_Code; lbl :Label_Type; s :String; comment :String := "" );
       procedure Gen_2_il	( oc :Op_Code; i :Integer; lbl :Label_Type; comment :String := "" );
       procedure Gen_2_ii	( oc :Op_Code; ia, ib :Integer; comment :String := "" );
       procedure Gen_2_ii	( oc :Op_Code; ct :Code_Type; ia, ib :Integer; comment :String := "" );
       procedure Gen_2_is	( oc :Op_Code; i :Integer; s :String; comment :String := "" );
       procedure Gen_CSP	( p :Std_Proc; comment :String := "" );
       procedure Gen_Load_Addr	( comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" );
       procedure Gen_Load	( ct :Code_Type; comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" );
       procedure Gen_Store	( ct :Code_Type; comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" );
   
       function  Next_Label			return Label_Type;
       procedure Inc_Level;
       procedure Dec_Level;
       procedure Inc_Offset	( i :Integer );
       procedure Align	( al :Integer );
       
       
      Illegal_Op_Code, Static_Level_Overflow, Static_Level_Underflow, Static_Offset_Overflow	: Exception;
       
   --|----------------------------------------------------------------------------------------------
   end CG_1;