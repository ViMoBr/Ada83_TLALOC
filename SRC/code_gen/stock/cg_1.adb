   --|----------------------------------------------------------------------------------------------
   --|	CG_1
   --|----------------------------------------------------------------------------------------------
    package body CG_1 is
   
      use Op_Code_io;
      use Code_Type_io;
   
      
      int_Label	: Label_Type	:= 1;
      fs	: File_Type;
      CDX	: constant array(Op_Code) of Offset_Type := (
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
      PDX	: constant array(Std_Proc) of Offset_Type := (
      		0, -4, 0, -8, -8, -4, -12, 0, -4, -16, 0
      		);
      
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Open_Output_File ( file_Name :String ) is
      begin
         CREATE ( fs, out_file, file_Name & ".cod" );
         int_Label := 1;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Close_Output_File is
      begin
         CLOSE ( fs );
      end;
      
       package Int_io	is new Integer_io ( Integer ); use Int_io;
      
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Write_Label ( lbl :Label_Type ) is
      begin
         PUT ( fs, "$ " );
         PUT ( fs, lbl,1 );				--| Label imprimé sur 6 caractères
         NEW_LINE ( fs );
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_Lbl_Assignment ( lbl :Label_Type; n :Natural ) is
      begin
         PUT ( fs, "$ " );
         PUT ( fs, lbl, 1 );				--| Label imprimé sur 6 caractères
         PUT ( fs, " = " );				--| Affectation
         Int_io.PUT ( fs, n, 1 );				--| Imprimer la valeur affectée sur 7 caractères
         NEW_LINE ( fs );
      end;
     --|--------------------------------------------------------------------------------------------
     --| 
       procedure Measure ( oc :Op_Code ) is
      begin
         top_Act := top_Act + CDX( oc );
         if top_Max < top_Act then
            top_Max := top_Act;
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_0 ( oc :Op_Code; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when band | EEX | bnot | bor | RAI | bxor =>
                  PUT ( fs, Ascii.HT );
                  PUT ( fs, oc, 0, lower_Case );
               when QUIT =>
                  PUT ( fs, "  " );
                  PUT ( fs, oc, 0, upper_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_0 ( oc :Op_Code; ct :Code_Type; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when add | div | dpl | exp | eq | ge | gt | le |
                    lt | modu | mul | neq | remn | sto | sub | swap =>
                  PUT ( fs, oc, 0, lower_case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, '.' );
            PUT ( fs, ct, 0, lower_Case );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
     --|--------------------------------------------------------------------------------------------
     --| 
       procedure Gen_1T_oc ( oc :Op_Code; comment :String := "" ) is
      begin
         case oc is
            when const =>
               MEASURE ( const );
               PUT ( fs, Ascii.HT );
               PUT ( fs, oc, 0, lower_Case );
            
               if comments_On and comment /= "" then
                  PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
               end if;
               NEW_LINE ( fs );
            when others =>
               raise Illegal_Op_Code;
         end case;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_b ( oc :Op_Code; b :Boolean; comment :String := "" ) is
      begin
         if generate_Code then
            GEN_1T_OC ( oc );
            PUT ( fs, ".b" & Ascii.HT & Boolean'IMAGE ( b ) );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_c ( oc :Op_Code; c :Character; comment :String := "" ) is
      begin
         if generate_Code then
            GEN_1T_OC ( oc );
            PUT ( fs, ".c" & Ascii.HT & "'" & Character'IMAGE ( c ) & "'" );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
     --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_l ( oc :Op_Code; lbl :Label_Type; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when jmpf | LVB | jmpt | jmp =>
                  PUT ( fs, Ascii.HT );
                  PUT ( fs, oc, 0, lower_Case );
                  PUT ( fs, Ascii.HT & "$ " );
               when RAI =>
                  PUT ( fs, Ascii.HT );
                  PUT ( fs, oc, 0, lower_Case );
                  PUT ( fs, Ascii.HT & "# " );
               when EXH | RFL =>
                  PUT ( fs, "  " );
                  PUT ( fs, oc, 0, upper_Case );
                  PUT ( fs, Ascii.HT & "$ " );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, lbl, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_i ( oc :Op_Code; i :Integer; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when alloc | GET | IXA | MST | PUT | ret =>
                  PUT ( fs, oc, 0, lower_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, AScii.HT );
            PUT ( fs, i, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_i ( oc :Op_Code; ct :Code_Type; i :Integer; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when dec | inc | ind | const =>
                  PUT ( fs, oc, 0, lower_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, '.' );
            PUT ( fs, ct, 0, lower_Case );
            PUT ( fs, Ascii.HT );
            PUT ( fs, i, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_1_s ( oc :Op_Code; s :String; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when PKG | PKB | PRO =>
                  PUT ( fs, "  " );
                  PUT ( fs, oc, 0, upper_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, Ascii.HT  & s );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_ll ( oc :Op_Code; num, lbl :Label_Type; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when EXC =>
                  PUT ( fs, oc, 0, lower_Case );
                  PUT ( fs, Ascii.HT & "# " );
                  PUT ( fs, num, 1 ); 
                  PUT ( fs, Ascii.HT & "$ " );
                  PUT ( fs, lbl, 1 );
                  
                  if comments_On and comment /= "" then
                     PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
                  end if;
                  NEW_LINE ( fs );
               when others =>
                  raise Illegal_Op_Code;
            end case;
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_ls ( oc :Op_Code; lbl :Label_Type; s :String; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when EXL =>
                  PUT ( fs, oc, 0, upper_Case );
                  PUT ( fs, Ascii.HT & "# " );
                  PUT ( fs, lbl, 1 ); 
                  PUT_LINE ( fs, Ascii.HT & s );
                  
                  if comments_On and comment /= "" then
                     PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
                  end if;
                  NEW_LINE ( fs );
                  
               when others =>
                  raise Illegal_Op_Code;
            end case;
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_il ( oc :Op_Code; i :Integer; lbl :Label_Type; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when call =>
                  PUT ( fs, Ascii.HT );
                  PUT ( fs, oc, 0, lower_case );
                  PUT ( fs, i, 7 );
               when ENT =>
                  PUT ( fs, "  " );
                  PUT ( fs, oc, 0, upper_Case );
                  PUT ( fs, i, 3 );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            
            PUT ( fs, Ascii.HT & "$ " );
            PUT ( fs, lbl, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_ii ( oc :Op_Code; ia, ib :Integer; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when lda | lao | mst =>
                  PUT ( fs, oc, 0, lower_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, Ascii.HT );
            PUT ( fs, ia, 1 ); 
            PUT ( fs, Ascii.HT );
            PUT ( fs, ib, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_ii ( oc :Op_Code; ct :Code_Type; ia, ib :Integer; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            PUT ( fs, Ascii.HT );
            case oc is
               when LDO | LOD | SRO | STR =>
                  PUT ( fs, oc, 0, lower_case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, '.' );
            PUT ( fs, ct, 0, lower_Case );
            PUT ( fs, Ascii.HT );
            PUT ( fs, ia, 1 ); 
            PUT ( fs, Ascii.HT );
            PUT ( fs, ib, 1 );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_2_is ( oc :Op_Code; i :Integer; s :String; comment :String := "" ) is
      begin
         if generate_Code then
            MEASURE ( oc );
            case oc is
               when RFP =>
                  PUT ( fs, "  " );
                  PUT ( fs, oc, 0, upper_Case );
               when others =>
                  raise Illegal_Op_Code;
            end case;
            PUT ( fs, i, 9 ); 
            PUT ( fs, Ascii.HT & s ); 
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_CSP ( p :Std_Proc; comment :String := "" ) is
      begin
         if generate_Code then
            top_Act := top_Act + PDX( p );
            if top_Max < top_Act then
               top_Max := top_Act;
            end if;
            PUT ( fs, Ascii.HT );
            PUT ( fs, trap, 0, lower_Case );
            PUT ( fs, Ascii.HT & Std_Proc'IMAGE ( p ) );
            
            if comments_On and comment /= "" then
               PUT ( fs, Ascii.HT & Ascii.HT & "--| " & comment ); 
            end if;
            NEW_LINE ( fs );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_Load_Addr ( comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" ) is
      begin
         if lvl = 0 then
            GEN_2_II ( LAO, Integer(comp_Unit_Number), offset, comment );
         else
            GEN_2_II ( LDA, Integer(level - lvl), offset, comment );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_Load ( ct :Code_Type; comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" ) is
      begin
         if lvl = 0 then
            GEN_2_II ( LDO, ct, Integer(comp_Unit_Number), offset, comment );
         else
            GEN_2_II ( LOD, ct, Integer(level - lvl), offset, comment );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Gen_Store ( ct :Code_Type; comp_Unit_Number :Comp_Unit_Nbr; lvl :Level_Type; Offset :Integer; comment :String := "" ) is
      begin
         if lvl = 0 then
            GEN_2_II ( SRO, ct, Integer(comp_Unit_Number), offset, comment );
         else
            GEN_2_II ( STR, ct, Integer(level - lvl), offset, comment );
         end if;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       function Next_Label return Label_Type is
      begin
         int_Label := int_Label + 1;
         return int_Label;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Inc_Level is
      begin
         level := level + 1;
          exception
            when Constraint_Error => raise Static_Level_Overflow;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Dec_Level is
      begin
         level := level - 1;
          exception
            when Constraint_Error => raise Static_Level_Underflow;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Inc_Offset ( i :Integer ) is
      begin
         offset_Act := offset_Act + Offset_Type( i );
         if offset_Max < offset_Act then
            offset_Max := offset_Act;
         end if;
          exception
            when Constraint_Error => raise Static_Offset_Overflow;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|
       procedure Align ( al :Integer ) is
         tmp	: Offset_Type	:= offset_Act + al - 1;
      begin
         offset_Act := tmp - tmp mod al;
      end;
       
   --|----------------------------------------------------------------------------------------------
   end CG_1;