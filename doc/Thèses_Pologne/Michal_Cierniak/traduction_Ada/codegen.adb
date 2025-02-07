-- Body of CodeGen module

package body CodeGen is

   procedure ConditionalError(ErrorCode : Integer; Condition : Boolean) is
   begin
      if Condition then
      begin
         CG_Lib.WriteComment;  -- Assuming WriteComment is defined in CG_Lib
         CG_Lib.CloseOutputFile;  -- Assuming CloseOutputFile is defined in CG_Lib
         CG_Lib.Error(ErrorCode);  -- Assuming Error is defined in CG_Lib
      end if;
   end ConditionalError;

   procedure GeneralInternalError is
   begin
      ConditionalError(999, True);
   end GeneralInternalError;

   procedure Init is
   begin
      CG_Lib.Comment := "";
      CG_Lib.TopAct := 0;
      CG_Lib.TopMax := 0;
      CG_Lib.OffsetAct := 0;
      CG_Lib.OffsetMax := 0;
      CG_Lib.Level := 0;
      CG_Lib.GenerateCode := True;
      t_function_result := CG_Lib.NULL_TREE;  -- Assuming NULL_TREE is defined in CG_Lib
   end Init;

   procedure CompileDecl_subprogram_body(t_subprogram_body : CG_Lib.TREE) is
      nd_subprogram_body, nd_designator : CG_Lib.NODE;
      SkipLbl : CG_Lib.LabelType;
   begin
      SkipLbl := CG_Lib.NextLabel;  -- Assuming NextLabel is defined in CG_Lib
      CG_Lib.Gen1Lbl(CG1.aUJP, SkipLbl);  -- Assuming Gen1Lbl and aUJP are defined in CG1

      CG_Lib.GET_NODE(t_subprogram_body, nd_subprogram_body);
      CG_Lib.GET_NODE(nd_subprogram_body.c_subprogram_body^.as_designator, nd_designator);

      case CG_Lib.KIND(nd_subprogram_body.c_subprogram_body^.as_header) is
         when CG_Lib._function =>
            begin
               CG_Lib.GET_NODE(nd_designator.c_function_id^.sm_first, nd_designator);
               if nd_designator.c_function_id^.cd_compiled then
                  CompileFunction(t_subprogram_body, nd_designator.c_function_id^.cd_label);
               else
                  CompileFunction(t_subprogram_body, CG_Lib.NextLabel);
               end if;
            end;
         when CG_Lib._procedure =>
            begin
               CG_Lib.GET_NODE(nd_designator.c_proc_id^.sm_first, nd_designator);
               if nd_designator.c_proc_id^.cd_compiled then
                  CompileProcedure(t_subprogram_body, nd_designator.c_proc_id^.cd_label);
               else
                  CompileProcedure(t_subprogram_body, CG_Lib.NextLabel);
               end if;
            end;
         when others =>
            GeneralInternalError;
      end case;

      CG_Lib.WriteLabel(SkipLbl);  -- Assuming WriteLabel is defined in CG_Lib
   end CompileDecl_subprogram_body;


procedure CompileDecl_subprogram_decl(t_subprogram_decl : CG_Lib.TREE) is
   nd_subprogram_decl, nd_designator, nd_header, nd_param_s : CG_Lib.NODE;
   OldOffsetAct, OldOffsetMax : CG_Lib.OffsetType;
begin
   OldOffsetMax := CG_Lib.OffsetMax;
   OldOffsetAct := CG_Lib.OffsetAct;
   CG_Lib.OffsetMax := CG_Lib.FirstParamOffset;
   CG_Lib.OffsetAct := CG_Lib.FirstParamOffset;
   CG_Lib.IncrementLevel;

   CG_Lib.GET_NODE(t_subprogram_decl, nd_subprogram_decl);
   CG_Lib.GET_NODE(nd_subprogram_decl.c_subprogram_decl.as_designator, nd_designator);
   CG_Lib.GET_NODE(nd_subprogram_decl.c_subprogram_decl.as_header, nd_header);

   case CG_Lib.KIND(nd_designator) is
      when CG_Lib._proc_id =>
         begin
            CG_Lib.GET_NODE(nd_designator.c_proc_id.sm_first, nd_designator);
            nd_designator.c_proc_id.cd_label := CG_Lib.NextLabel;
            nd_designator.c_proc_id.cd_level := CG_Lib.Level;
            nd_designator.c_proc_id.cd_compiled := True;

            if not CG_Lib.GenerateCode then
            begin
               CG_Lib.GenerateCode := True;
               CG_Lib.Comment := "procedure " & CG_Lib.GetSymbol(CG1.lx_symrep);
               CG_Lib.Gen1Lbl(CG1.aRFL, nd_designator.c_proc_id.cd_label);
               CG_Lib.GenerateCode := False;
               CG_Lib.GET_NODE(nd_header.c_procedure.as_param_s, nd_param_s);
               CompileParams(nd_param_s.c_param_s.as_list);
            end
            else
            begin
               CG_Lib.GET_NODE(nd_header.c_procedure.as_param_s, nd_param_s);
               CompileParams(nd_param_s.c_param_s.as_list);
            end;

            nd_designator.c_proc_id.cd_param_size := CG_Lib.OffsetAct - CG_Lib.FirstParamOffset;
         end;

      when CG_Lib._function_id =>
         begin
            CG_Lib.GET_NODE(nd_designator.c_function_id.sm_first, nd_designator);
            nd_designator.c_function_id.cd_label := CG_Lib.NextLabel;
            nd_designator.c_function_id.cd_level := CG_Lib.Level;
            nd_designator.c_function_id.cd_compiled := True;

            if not CG_Lib.GenerateCode then
            begin
               CG_Lib.GenerateCode := True;
               CG_Lib.Comment := "function " & CG_Lib.GetSymbol(CG1.lx_symrep);
               CG_Lib.Gen1Lbl(CG1.aRFL, nd_designator.c_function_id.cd_label);
               CG_Lib.GenerateCode := False;
               CG_Lib.GET_NODE(nd_header.c_function.as_param_s, nd_param_s);
               CompileParams(nd_param_s.c_param_s.as_list);
            end
            else
            begin
               CG_Lib.GET_NODE(nd_header.c_function.as_param_s, nd_param_s);
               CompileParams(nd_param_s.c_param_s.as_list);
            end;

            nd_designator.c_function_id.cd_param_size := CG_Lib.OffsetAct - CG_Lib.FirstParamOffset;
            nd_designator.c_function_id.cd_result_size := CG_Lib.TypeSize(nd_header.c_function.as_name_void);
         end;

      when others =>
         CG_Lib.GeneralInternalError;
   end case;

   CG_Lib.DecrementLevel;
   CG_Lib.OffsetMax := OldOffsetMax;
   CG_Lib.OffsetAct := OldOffsetAct;
end CompileDecl_subprogram_decl;


procedure CompileDecl_exception(t_exception: TREE) is
   nd_exception, nd_id_s, nd_exception_id: NODE;
   CurrException: SEQ_TYPE;
   OldGenerateCode: Boolean;
begin
   OldGenerateCode := GenerateCode;
   GenerateCode := True;
   
   CG_Expr.GET_NODE(t_exception, nd_exception);
   CG_Expr.GET_NODE(nd_exception.c_exception.as_id_s, nd_id_s);
   
   CurrException := nd_id_s.c_id_s.as_list;
   
   while not CG_Lib.IS_EMPTY(CurrException) loop
      CG_Expr.GET_NODE(CG_Lib.HEAD(CurrException), nd_exception_id);
      
      nd_exception_id.c_exception_id.cd_label := CG_Lib.NextLabel;
      CG1.Gen2LblStr(CG1.aEXL, nd_exception_id.c_exception_id.cd_label, CG1.GetSymbol(nd_exception_id.c_exception_id.lx_symrep));
      
      CurrException := CG_Lib.TAIL(CurrException);
   end loop;
   
   GenerateCode := OldGenerateCode;
end CompileDecl_exception;


procedure CompileDeclaration(Declaration: TREE) is
begin
   case KIND(Declaration) is
      when _constant =>
         CompileDecl_constant(Declaration);
      when _exception =>
         CompileDecl_exception(Declaration);
      when _number =>
         null;
      when _subprogram_decl =>
         CompileDecl_subprogram_decl(Declaration);
      when _subprogram_body =>
         CompileDecl_subprogram_body(Declaration);
      when _type =>
         CompileDecl_type(Declaration);
      when _var =>
         CompileDecl_var(Declaration);
      when others =>
         ConditionalError(999, True);
   end case;
end CompileDeclaration;


procedure CompileDeclarations(Declarations: TREE) is
   nd_item_s: NODE;
   CurrDeclaration: SEQ_TYPE;
begin
   CG_Expr.GET_NODE(Declarations, nd_item_s);
   CurrDeclaration := nd_item_s.c_item_s.as_list;
   
   while not CG_Lib.IS_EMPTY(CurrDeclaration) loop
      CompileDeclaration(CG_Lib.HEAD(CurrDeclaration));
      CurrDeclaration := CG_Lib.TAIL(CurrDeclaration);
   end loop;
end CompileDeclarations;


procedure InitializeFunctionResult is
   nd: CG_Expr.NODE;
begin
   CG_Expr.GET_NODE(t_function_result, nd);
   
   if CG_Lib.KIND(t_function_result) = CG_Lib._array then
      declare
         c_array := nd.c_array;
      begin
         CG_Lib.GenLoadAddr(c_array.cd_comp_unit, c_array.cd_level, c_array.cd_offset);
         CG_Lib.GenOT(CG1.aDPL, CG1.a_A);
         CG_Lib.Gen2NumNumT(CG1.aSTR, CG1.a_A, 0, fun_result_offset - CG_Lib.AddrSize);
         CG_Lib.Gen1NumT(CG1.aIND, CG1.a_I, 0);
         CG_Lib.Gen1Num(CG1.aALO, -1);
         Comment := "result array";
         CG_Lib.Gen2NumNumT(CG1.aSTR, CG1.a_A, 0, fun_result_offset);
      end;
   end if;
   
   t_function_result := CG_Lib.NULL_TREE;
end InitializeFunctionResult;


procedure CompileSubpBlock(Block, EnclosingProc, Params: TREE; ParamSize: OffsetType) is
   ExcLbl, ENT1Lbl, ENT2Lbl: LabelType;
   OldTopAct, OldTopMax: OffsetType;
   nd_block: CG_Expr.NODE;
begin
   OldTopMax := CG_Lib.TopMax;
   OldTopAct := CG_Lib.TopAct;
   CG_Lib.TopMax := 0;
   CG_Lib.TopAct := 0;

   CG_Expr.GET_NODE(Block, nd_block);

   nd_block.c_block.cd_level := CG_Lib.Level;
   nd_block.c_block.cd_return_label := CG_Lib.NextLabel;

   ENT1Lbl := CG_Lib.NextLabel;
   ENT2Lbl := CG_Lib.NextLabel;
   CG_Lib.Gen2NumLbl(CG1.aENT, 1, ENT1Lbl);
   CG_Lib.Gen2NumLbl(CG1.aENT, 2, ENT2Lbl);

   if t_function_result /= CG_Lib.NULL_TREE then
      InitializeFunctionResult;

   CompileDeclarations(nd_block.c_block.as_item_s);

   ExcLbl := CG_Lib.NextLabel;
   Comment := "begin";
   CG_Lib.Gen1Lbl(CG1.aEH, ExcLbl);
   CompileStatements(nd_block.c_block.as_stm_s, EnclosingProc);

   Comment := "copy out";
   CG_Lib.WriteLabel(nd_block.c_block.cd_return_label);
   CopyOutParams(Params);
   CG_Lib.Gen1Num(CG1.aRET, ParamSize);
   CG_Lib.WriteLabel(ExcLbl);

   CompileExceptionHandlers(nd_block.c_block.as_alternative_s, EnclosingProc);

   CG_Lib.GenLabelAssignment(ENT1Lbl, CG_Lib.OffsetMax);
   CG_Lib.GenLabelAssignment(ENT2Lbl, CG_Lib.OffsetMax + CG_Lib.TopMax);

   CG_Lib.TopMax := OldTopMax;
   CG_Lib.TopAct := OldTopAct;
end CompileSubpBlock;


procedure CompileProcedure(t_subprogram_body: TREE; StartLabel: LabelType) is
   nd_subprogram_body, nd_proc_id, nd_procedure, nd_param_s, Nd: CG_Expr.NODE;
   OldOffsetAct, OldOffsetMax: OffsetType;
begin
   OldOffsetMax := CG_Lib.OffsetMax;
   OldOffsetAct := CG_Lib.OffsetAct;
   CG_Lib.OffsetMax := CG_Lib.FirstParamOffset;
   CG_Lib.OffsetAct := CG_Lib.FirstParamOffset;
   CG_Lib.IncrementLevel;

   CG_Expr.GET_NODE(t_subprogram_body, nd_subprogram_body);
   CG_Expr.GET_NODE(nd_subprogram_body.c_subprogram_body.as_designator, nd_proc_id);

   nd_proc_id.c_proc_id.cd_label := StartLabel;
   nd_proc_id.c_proc_id.cd_level := CG_Lib.Level;

   CG_Expr.PUT_NODE(nd_subprogram_body.c_subprogram_body.as_designator, nd_proc_id);
   Comment := "procedure " & CG_Lib.GetSymbol(nd_proc_id.c_proc_id.lx_symrep);
   CG_Lib.WriteLabel(StartLabel);

   CG_Expr.GET_NODE(nd_proc_id.c_proc_id.sm_spec, nd_procedure);
   CG_Expr.GET_NODE(nd_procedure.c_procedure.as_param_s, nd_param_s);

   CompileParams(nd_param_s.c_param_s.as_list);
   nd_proc_id.c_proc_id.cd_param_size := CG_Lib.OffsetAct - CG_Lib.FirstParamOffset + CG_Lib.RelativeResultOffset;

   CG_Lib.OffsetMax := CG_Lib.FirstLocalVarOffset;
   CG_Lib.OffsetAct := CG_Lib.FirstLocalVarOffset;

   CompileSubpBlock(
      nd_subprogram_body.c_subprogram_body.as_block_stub,
      nd_subprogram_body.c_subprogram_body.as_block_stub,
      nd_procedure.c_procedure.as_param_s,
      nd_proc_id.c_proc_id.cd_param_size
   );

   CG_Lib.DecrementLevel;
   CG_Lib.OffsetMax := OldOffsetMax;
   CG_Lib.OffsetAct := OldOffsetAct;
   Comment := "end " & CG_Lib.GetSymbol(nd_proc_id.c_proc_id.lx_symrep);
end CompileProcedure;


procedure CompileFunction(t_subprogram_body: TREE; StartLabel: LabelType) is
   nd_subprogram_body, nd_function_id,
   nd_function, nd_param_s,
   nd_block, Nd: CG_Expr.NODE;
   OldOffsetAct, OldOffsetMax: OffsetType;
begin
   OldOffsetMax := CG_Lib.OffsetMax;
   OldOffsetAct := CG_Lib.OffsetAct;
   CG_Lib.OffsetMax := CG_Lib.FirstParamOffset;
   CG_Lib.OffsetAct := CG_Lib.FirstParamOffset;
   CG_Lib.IncrementLevel;

   CG_Expr.GET_NODE(t_subprogram_body, nd_subprogram_body);
   CG_Expr.GET_NODE(nd_subprogram_body.c_subprogram_body.as_designator, nd_function_id);

   nd_function_id.c_function_id.cd_label := StartLabel;
   nd_function_id.c_function_id.cd_level := CG_Lib.Level;
   Comment := "function " & CG_Lib.GetSymbol(nd_function_id.c_function_id.lx_symrep);
   CG_Lib.WriteLabel(StartLabel);
   CG_Expr.GET_NODE(nd_function_id.c_function_id.sm_spec, nd_function);

   CG_Expr.GET_NODE(nd_function.c_function.as_param_s, nd_param_s);
   CompileParams(nd_param_s.c_param_s.as_list);
   CG_Lib.IncrementOffset(CG_Lib.RelativeResultOffset);

   nd_function_id.c_function_id.cd_param_size := CG_Lib.OffsetAct - CG_Lib.FirstParamOffset;
   nd_function_id.c_function_id.cd_result_size := CG_Lib.TypeSize(nd_function.c_function.as_name_void);
   CG_Lib.IncrementOffset(nd_function_id.c_function_id.cd_result_size);

   CG_Lib.Align(CG_Lib.StackAl);

   CG_Expr.GET_NODE(nd_subprogram_body.c_subprogram_body.as_block_stub, nd_block);
   nd_block.c_block.cd_result_offset := CG_Lib.OffsetAct;
   fun_result_offset := CG_Lib.OffsetAct;
   t_function_result := CG_Lib.TypeStruct(nd_function.c_function.as_name_void);

   CG_Lib.OffsetMax := CG_Lib.FirstLocalVarOffset;
   CG_Lib.OffsetAct := CG_Lib.FirstLocalVarOffset;

   CompileSubpBlock(
      nd_subprogram_body.c_subprogram_body.as_block_stub,
      nd_subprogram_body.c_subprogram_body.as_block_stub,
      nd_function.c_function.as_param_s,
      nd_function_id.c_function_id.cd_param_size
   );

   CG_Lib.DecrementLevel;
   CG_Lib.OffsetMax := OldOffsetMax;
   CG_Lib.OffsetAct := OldOffsetAct;
   Comment := "end " & CG_Lib.GetSymbol(nd_function_id.c_function_id.lx_symrep);
end CompileFunction;


function NumberOfDimensions(t: TREE) return Byte is
   nd: CG_Expr.NODE;
begin
   CG_Expr.GET_NODE(t, nd);

   case CG_Lib.KIND(t) is
      when CG1._array =>
         return nd.c_array.cd_dimensions;

      when CG1._constrained =>
         return NumberOfDimensions(nd.c_constrained.sm_type_struct);

      when CG1._function_call =>
         return NumberOfDimensions(nd.c_function_call.sm_exp_type);

      when CG1._used_object_id =>
         return NumberOfDimensions(nd.c_used_object_id.sm_exp_type);

      when others =>
         CG_Lib.GeneralInternalError;
         return 0; -- To satisfy function return type
   end case;
end NumberOfDimensions;


procedure StoreVal(t_type: TREE) is
   nd: CG_Expr.NODE;
begin
   case CG_Lib.KIND(t_type) is
      when CG1._access =>
         CG_Lib.GenOT(CG1.aSTO, CG1.a_A);

      when CG1._enum_literal_s =>
         if CG_Lib.BooleanType(t_type) then
            CG_Lib.GenOT(CG1.aSTO, CG1.a_B);
         elsif CG_Lib.CharacterType(t_type) then
            CG_Lib.GenOT(CG1.aSTO, CG1.a_C);
         else
            CG_Lib.GenOT(CG1.aSTO, CG1.a_I);
         end if;

      when CG1._integer =>
         if t_type /= CG1.STD_INTEGER then
            CG_Expr.GET_NODE(t_type, nd);
            CG_Lib.GenLoadAddr(nd.c_integer.cd_comp_unit,
                               nd.c_integer.cd_level,
                               nd.c_integer.cd_offset);
            CG_Lib.GenCSP(CG1.aCVB);
         end if;
         CG_Lib.GenOT(CG1.aSTO, CG1.a_I);

      when others =>
         CG_Lib.GeneralInternalError;
   end case;
end StoreVal;


procedure CompileAssign_all(t_name, t_exp: TREE) is
   nd, nd_all, nd_exp: CG_Expr.NODE;
   CompUnitNr: Integer;  -- Assuming Byte is Integer in Ada
   Lvl: CG_Lib.LevelType;
   Offs: CG_Lib.OffsetType;
begin
   CG_Expr.GET_NODE(t_name, nd_all);
   CG_Expr.LoadAddress(nd_all.c_all.as_name);
   CG_Lib.Comment := ":=";
   CG_Lib.WriteComment;
   CG_Expr.CompileExpression(t_exp);
   StoreVal(nd_all.c_all.sm_exp_type);
end CompileAssign_all;


procedure CompileAssign_indexed(t_name, t_exp: TREE) is
   nd, nd_indexed, nd_exp: CG_Expr.NODE;
   CompUnitNr: Integer;  -- Assuming Byte is Integer in Ada
   Lvl: CG_Lib.LevelType;
   Offs: CG_Lib.OffsetType;
begin
   CG_Expr.GET_NODE(t_name, nd_indexed);
   CG_Expr.LoadAddress_indexed(t_name);
   CG_Lib.Comment := ":=";
   CG_Lib.WriteComment;
   CG_Expr.CompileExpression(t_exp);
   StoreVal(nd_indexed.c_indexed.sm_exp_type);
end CompileAssign_indexed;


procedure CompileAssign_used_object_id(t_name, t_exp: TREE) is
   nd, nd_used_object_id, nd_exp: NODE;
   CompUnitNr: Integer;  -- Assuming Byte is Integer in Ada
   Lvl: CG_Lib.LevelType;
   Offs: CG_Lib.OffsetType;
begin
   CG_Expr.GET_NODE(t_name, nd_used_object_id);
   
   case CG_Expr.KIND(nd_used_object_id.c_used_object_id.sm_exp_type) is
      when CG_Expr._access =>
         begin
            CG_Expr.CompileExpression(t_exp);
            GetCLO(nd_used_object_id.c_used_object_id.sm_defn, CompUnitNr, Lvl, Offs);
            CG_Lib.Comment := CG_Lib.GetSymbol(nd_used_object_id.c_used_object_id.lx_symrep);
            CG_Expr.GenStore(CG1.a_A, CompUnitNr, Lvl, Offs);
         end;
      
      when CG_Expr._array =>
         begin
            CG_Expr.LoadObjectAddress(nd_used_object_id.c_used_object_id.sm_defn);
            
            if CG_Expr.KIND(t_exp) = CG_Expr._used_object_id then
            begin
               CG_Expr.LoadObjectAddress(t_exp);
               CG_Lib.Comment := '# of dimensions';
               CG_Expr.Gen1NumT(CG1.aLDC, CG1.a_I, NumberOfDimensions(nd_used_object_id.c_used_object_id.sm_exp_type));
               CG_Expr.GenCSP(CG1.aCYA);
            end
            else
            begin
               CG_Expr.CompileExpression(t_exp);
               CG_Lib.Comment := '# of dimensions';
               CG_Expr.Gen1NumT(CG1.aLDC, CG1.a_I, NumberOfDimensions(nd_used_object_id.c_used_object_id.sm_exp_type));
               CG_Expr.GenCSP(CG1.aPUA);
            end;
         end;
      
      when CG_Expr._enum_literal_s =>
         begin
            CG_Expr.CompileExpression(t_exp);
            GetCLO(nd_used_object_id.c_used_object_id.sm_defn, CompUnitNr, Lvl, Offs);
            CG_Lib.Comment := CG_Lib.GetSymbol(nd_used_object_id.c_used_object_id.lx_symrep);
            
            if CG_Expr.BooleanType(nd_used_object_id.c_used_object_id.sm_exp_type) then
               CG_Expr.GenStore(CG1.a_B, CompUnitNr, Lvl, Offs);
            elsif CG_Expr.CharacterType(nd_used_object_id.c_used_object_id.sm_exp_type) then
               CG_Expr.GenStore(CG1.a_C, CompUnitNr, Lvl, Offs);
            else
               CG_Expr.GenStore(CG1.a_I, CompUnitNr, Lvl, Offs);
         end;
      
      when CG_Expr._integer =>
         begin
            CG_Expr.CompileExpression(t_exp);
            if nd_used_object_id.c_used_object_id.sm_exp_type /= CG_Lib.STD_INTEGER then
            begin
               GetCLO(nd_used_object_id.c_used_object_id.sm_exp_type, CompUnitNr, Lvl, Offs);
               CG_Expr.GenLoadAddr(CompUnitNr, Lvl, Offs);
               CG_Expr.GenCSP(CG1.aCVB);
            end;
            
            GetCLO(nd_used_object_id.c_used_object_id.sm_defn, CompUnitNr, Lvl, Offs);
            CG_Lib.Comment := CG_Lib.GetSymbol(nd_used_object_id.c_used_object_id.lx_symrep);
            CG_Expr.GenStore(CG1.a_I, CompUnitNr, Lvl, Offs);
         end;
      
      when others =>
         GeneralInternalError;
   end;
end CompileAssign_used_object_id;


procedure CompileStm_Assign(Stm: TREE) is
   nd_assign: NODE;
begin
   CG_Lib.Comment := "assign";
   WriteComment;
   CG_Expr.GET_NODE(Stm, nd_assign);
   
   case CG_Expr.KIND(nd_assign.c_assign.as_name) is
      when CG_Expr._all =>
         CG_Expr.CompileAssign_all(nd_assign.c_assign.as_name, nd_assign.c_assign.as_exp);
      
      when CG_Expr._indexed =>
         CG_Expr.CompileAssign_indexed(nd_assign.c_assign.as_name, nd_assign.c_assign.as_exp);
      
      when CG_Expr._used_object_id =>
         CG_Expr.CompileAssign_used_object_id(nd_assign.c_assign.as_name, nd_assign.c_assign.as_exp);
      
      when others =>
         GeneralInternalError;
   end case;
end CompileStm_Assign;


procedure CompileStm_block(Stm, EnclosingProc: TREE) is
   nd_block: NODE;
   CurrCondClause: SEQ_TYPE;
   ProcLbl, AfterBlockLbl: LabelType;
   OldOffsetAct, OldOffsetMax: OffsetType;
begin
   AfterBlockLbl := NextLabel;
   ProcLbl := NextLabel;
   CG_Lib.Gen2NumNum(aMST, 0, 0);
   CG_Lib.Gen2NumLbl(aCUP, RelativeResultOffset, ProcLbl);
   CG_Lib.Gen1Lbl(aUJP, AfterBlockLbl);
   WriteLabel(ProcLbl);
   
   OldOffsetAct := OffsetAct;
   OldOffsetMax := OffsetMax;
   OffsetAct := FirstLocalVarOffset;
   OffsetMax := FirstLocalVarOffset;
   IncrementLevel;
   
   CG_Expr.CompileSubpBlock(Stm, EnclosingProc, CG_Lib.NULL_TREE, RelativeResultOffset);
   
   DecrementLevel;
   OffsetAct := OldOffsetAct;
   OffsetMax := OldOffsetMax;
   
   CG_Expr.GET_NODE(Stm, nd_block);
   WriteLabel(AfterBlockLbl);
end CompileStm_block;


procedure CompileStm_exit(Stm: TREE) is
   nd_exit, nd_loop: NODE;
   LVBlbl, SkipLbl: LabelType;
begin
   CG_Expr.GET_NODE(Stm, nd_exit);
   CG_Expr.GET_NODE(nd_exit.c_exit^.sm_stm, nd_loop);
   
   if nd_exit.c_exit^.as_exp_void = CG_Lib.NULL_TREE then
   begin
      Comment := "exit";
      if nd_loop.c_loop^.cd_level /= Level then
      begin
         LVBlbl := NextLabel;
         CG_Lib.Gen1Lbl(aLVB, LVBlbl);
         CG_Lib.GenLabelAssignment(LVBlbl, Level - nd_loop.c_loop^.cd_level);
      end;
      CG_Lib.Gen1Lbl(aUJP, nd_loop.c_loop^.cd_after_loop_label);
   end
   else
   begin
      CG_Expr.CompileExpression(nd_exit.c_exit^.as_exp_void);
      Comment := "exit";
      if nd_loop.c_loop^.cd_level /= Level then
      begin
         SkipLbl := NextLabel;
         CG_Lib.Gen1Lbl(aFJP, SkipLbl);
         LVBlbl := NextLabel;
         CG_Lib.Gen1Lbl(aLVB, LVBlbl);
         CG_Lib.GenLabelAssignment(LVBlbl, Level - nd_loop.c_loop^.cd_level);
         CG_Lib.Gen1Lbl(aUJP, nd_loop.c_loop^.cd_after_loop_label);
         WriteLabel(SkipLbl);
      end
      else
      begin
         CG_Lib.Gen1Lbl(aTJP, nd_loop.c_loop^.cd_after_loop_label);
      end;
   end;
end CompileStm_exit;


procedure CompileCondClause(t_cond_clause, EnclosingProc: TREE; AfterlfLbl: LabelType) is
   nd_cond_clause: NODE;
   t_exp_void: TREE;
   NextClauseLbl: LabelType;
begin
   CG_Expr.GET_NODE(t_cond_clause, nd_cond_clause);
   t_exp_void := nd_cond_clause.c_cond_clause^.as_exp_void;
   
   if t_exp_void /= CG_Lib.NULL_TREE then
   begin
      CG_Expr.CompileExpression(t_exp_void);
      NextClauseLbl := NextLabel;
      CG_Lib.Gen1Lbl(aFJP, NextClauseLbl);
   end;
   
   CompileStatements(nd_cond_clause.c_cond_clause^.as_stm_s, EnclosingProc);
   
   if t_exp_void /= CG_Lib.NULL_TREE then
   begin
      CG_Lib.Gen1Lbl(aUJP, AfterlfLbl);
      CG_Lib.WriteLabel(NextClauseLbl);
   end;
end;


procedure CompileStm_If(Stm, EnclosingProc: TREE) is
   nd_if: NODE;
   CurrCondClause: SEQ_TYPE;
   AfterIfLbl: LabelType;
begin
   AfterIfLbl := NextLabel;
   CG_Expr.GET_NODE(Stm, nd_if);
   CurrCondClause := nd_if.c_if^.as_list;
   
   while not IS_EMPTY(CurrCondClause) loop
      CompileCondClause(HEAD(CurrCondClause), EnclosingProc, AfterIfLbl);
      CurrCondClause := TAIL(CurrCondClause);
   end loop;
   
   CG_Lib.Comment := 'end if';
   CG_Lib.WriteLabel(AfterIfLbl);
end;


procedure LoadTypeBounds(t_type_struct: TREE) is
   nd: NODE;
begin
   CG_Expr.GET_NODE(t_type_struct, nd);
   
   case CG_Lib.KIND(t_type_struct) is
      when CG_Lib._enum_literal_s =>
         if BooleanType(t_type_struct) then
            begin
               CG_Lib.Gen1NumT(aLDC, a_I, 0);
               CG_Lib.Gen1NumT(aLDC, a_I, 1);
            end;
         elsif CharacterType(t_type_struct) then
            begin
               CG_Lib.Gen1NumT(aLDC, a_I, 0);
               CG_Lib.Gen1NumT(aLDC, a_I, 127);
            end;
         else
            begin
               CG_Lib.Gen1NumT(aLDC, a_I, 0);
               CG_Lib.Gen1NumT(aLDC, a_I, nd.c_enum_literal_s^.cd_last);
            end;
         
      when others =>
         GeneralInternalError;
   end case;
end;


procedure LoadDscrtRange(t_dscrt_range: TREE) is
   nd: NODE;
begin
   CG_Expr.GET_NODE(t_dscrt_range, nd);
   
   case CG_Lib.KIND(t_dscrt_range) is
      when CG_Lib._constrained =>
         LoadTypeBounds(nd.c_constrained.sm_base_type);
      
      when CG_Lib._range =>
         begin
            CompileExpression(nd.c_range.as_expl);
            CompileExpression(nd.c_range.as_exp2);
         end;
      
      when others =>
         GeneralInternalError;
   end case;
end;


procedure CompileStm_loop(Stm, EnclosingProc: TREE) is
   nd_loop: NODE;
   CurrCondClause: SEQ_TYPE;
   BeforeLoopLbl, AfterLoopLbl: LabelType;

procedure CompileStm_loop_for(t_for: TREE) is
   nd_for, nd_iteration_id, nd: NODE;
   Counter, Temp, OldOffsetAct: OffsetType;
   aCT: aCodeTypes;
begin
   OldOffsetAct := OffsetAct;
   GET_NODE(t_for, nd_for);
   nd_iteration_id := nd_for.c_for.as_id;
   Comment := 'for';
   WriteComment;
   aCT := aCodeTypes(nd_iteration_id.sm_obj_type);
   
   case aCT is
      when a_B =>
         begin
            Align(BoolAl);
            Counter := -OffsetAct;
            IncrementOffset(BoolSize);
            Align(BoolAl);
            Temp := -OffsetAct;
            IncrementOffset(BoolSize);
         end;
      
      when a_C =>
         begin
            Align(CharAl);
            Counter := -OffsetAct;
            IncrementOffset(CharSize);
            Align(CharAl);
            Temp := -OffsetAct;
            IncrementOffset(CharSize);
         end;
      
      when a_I =>
         begin
            Align(IntegerAl);
            Counter := -OffsetAct;
            IncrementOffset(IntegerSize);
            Align(IntegerAl);
            Temp := -OffsetAct;
            IncrementOffset(IntegerSize);
         end;
      
      others =>
         GeneralInternalError;
   end case;
   
   nd_iteration_id.c_iteration_id.cd_level := Level;
   nd_iteration_id.c_iteration_id.cd_offset := Counter;
   
   LoadDscrtRange(nd_for.c_for.as_dscrt_range);
   Gen2NumNumT(aSTR, aCT, 0, Temp);
   WriteLabel(BeforeLoopLbl);
   Gen2NumNumT(aSTR, aCT, 0, Counter);
   Gen2NumNumT(aLOD, aCT, 0, Counter);
   Gen2NumNumT(aLOD, aCT, 0, Temp);
   GenOT(aLEQ, aCT);
   Gen1Lbl(aFJP, AfterLoopLbl);
   CompileStatements(nd_loop.c_loop.as_stm_s, EnclosingProc);
   Gen2NumNumT(aLOD, aCT, 0, Counter);
   Gen1NumT(aINC, aCT, 1);
   Gen1Lbl(aUJP, BeforeLoopLbl);
   OffsetAct := OldOffsetAct;
end CompileStm_loop_for;

procedure CompileStm_loop_reverse(t_reverse: TREE) is
   nd_reverse, nd_iteration_id, nd: NODE;
   Counter, Temp, OldOffsetAct: OffsetType;
   aCT: aCodeTypes;
begin
   OldOffsetAct := OffsetAct;
   GET_NODE(t_reverse, nd_reverse);
   nd_iteration_id := nd_reverse.c_reverse.as_id;
   Comment := 'for';
   WriteComment;
   aCT := aCodeTypes(nd_iteration_id.sm_obj_type);
   
   case aCT is
      when a_B =>
         begin
            Align(BoolAl);
            Counter := -OffsetAct;
            IncrementOffset(BoolSize);
            Align(BoolAl);
            Temp := -OffsetAct;
            IncrementOffset(BoolSize);
         end;
      
      when a_C =>
         begin
            Align(CharAl);
            Counter := -OffsetAct;
            IncrementOffset(CharSize);
            Align(CharAl);
            Temp := -OffsetAct;
            IncrementOffset(CharSize);
         end;
      
      when a_I =>
         begin
            Align(IntegerAl);
            Counter := -OffsetAct;
            IncrementOffset(IntegerSize);
            Align(IntegerAl);
            Temp := -OffsetAct;
            IncrementOffset(IntegerSize);
         end;
      
      others =>
         GeneralInternalError;
   end case;
   
   nd_iteration_id.c_iteration_id.cd_level := Level;
   nd_iteration_id.c_iteration_id.cd_offset := Counter;
   
   LoadDscrtRange(nd_reverse.c_reverse.as_dscrt_range);
   Gen2NumNumT(aSTR, aCT, 0, Counter);
   Gen2NumNumT(aSTR, aCT, 0, Temp);
   WriteLabel(BeforeLoopLbl);
   Gen2NumNumT(aLOD, aCT, 0, Counter);
   Gen2NumNumT(aLOD, aCT, 0, Temp);
   GenOT(aGEQ, aCT);
   Gen1Lbl(aFJP, AfterLoopLbl);
   CompileStatements(nd_loop.c_loop.as_stm_s, EnclosingProc);
   Gen2NumNumT(aLOD, aCT, 0, Counter);
   Gen1NumT(aINC, aCT, 1);
   Gen2NumNumT(aSTR, aCT, 0, Counter);
   Gen1Lbl(aUJP, BeforeLoopLbl);
   OffsetAct := OldOffsetAct;
end CompileStm_loop_reverse;

   procedure CompileStm_loop_while(t_while: TREE) is
      nd_while: NODE;
   begin
      Comment := 'while';
      WriteLabel(BeforeLoopLbl);
      GET_NODE(t_while, nd_while);
      CompileExpression(nd_while.c_while.as_exp);
      Gen1Lbl(aFJP, AfterLoopLbl);
      CompileStatements(nd_loop.c_loop.as_stm_s, EnclosingProc);
      Gen1Lbl(aUJP, BeforeLoopLbl);
   end CompileStm_loop_while;

begin
   BeforeLoopLbl := NextLabel;
   AfterLoopLbl := NextLabel;
   GET_NODE(Stm, nd_loop);
   
   with nd_loop.c_loop do
   begin
      cd_after_loop_label := AfterLoopLbl;
      cd_level := Level;
   end;
   
   PUT_NODE(Stm, nd_loop);
   
   if as_iteration = NULL_TREE then
   begin
      Comment := 'loop';
      WriteLabel(BeforeLoopLbl);
      CompileStatements(as_stm_s, EnclosingProc);
      Gen1Lbl(aUJP, BeforeLoopLbl);
   end
   else
   begin
      case KIND(as_iteration) is
         when _for =>
            CompileStm_loop_for(as_iteration);
         
         when _reverse =>
            CompileStm_loop_reverse(as_iteration);
         
         when _while =>
            CompileStm_loop_while(as_iteration);
         
         others =>
            GeneralInternalError;
      end case;
   end;
   
   Comment := 'end loop';
   WriteLabel(AfterLoopLbl);
end CompileStm_loop;

begin
    BeforeLoopLbl := NextLabel;
    AfterLoopLbl := NextLabel;
    
    GET_NODE(Stm, nd_loop);
    
    nd_loop.c_loop.cd_after_loop_label := AfterLoopLbl;
    nd_loop.c_loop.cd_level := Level;
    
    PUT_NODE(Stm, nd_loop);
    
    if nd_loop.c_loop.as_iteration = NULL_TREE then
    begin
        Comment := 'loop';
        WriteLabel(BeforeLoopLbl);
        CompileStatements(nd_loop.c_loop.as_stm_s, EnclosingProc);
        Gen1Lbl(aUJP, BeforeLoopLbl);
    end
    else
    begin
        case KIND(nd_loop.c_loop.as_iteration) is
            _for =>
                CompileStm_loop_for(nd_loop.c_loop.as_iteration),
            _reverse =>
                CompileStm_loop_reverse(nd_loop.c_loop.as_iteration),
            _while =>
                CompileStm_loop_while(nd_loop.c_loop.as_iteration),
            others =>
                GeneralInternalError; -- Handle unexpected iteration type
        end case;
    end;
    
    Comment := 'end loop';
    WriteLabel(AfterLoopLbl);
end CompileStm_loop;


procedure CompileStm_named_stm(Stm, EnclosingProc: TREE) is
    nd_named_stm, nd_named_stm_id: NODE;
    StartLbl: LabelType;
begin
    StartLbl := NextLabel;
    
    GET_NODE(Stm, nd_named_stm);
    GET_NODE(nd_named_stm.c_named_stm.as_id, nd_named_stm_id);
    
    nd_named_stm_id.c_named_stm_id.cd_label := StartLbl;
    Comment := GetSymbol(nd_named_stm_id.c_named_stm_id.lx_symrep);
    
    WriteComment;
    CompileStatement(nd_named_stm.c_named_stm.as_stm, EnclosingProc);
end CompileStm_named_stm;


procedure LoadObject(t: TREE) is
    nd, nd_type_id: NODE;
begin
    GET_NODE(t, nd);
    
    case KIND(t) is
        when _used_name_id =>
            GET_NODE(nd.c_used_name_id.sm_defn, nd_type_id);
            
            case KIND(nd_type_id.c_type_id.sm_type_spec) is
                when _integer =>
                    Gen1NumT(aLND, a_I, 0);
                    
                    if nd_type_id.c_type_id.sm_type_spec /= STD_INTEGER then
                        null; -- Handle additional logic if needed
                    end if;
                    
                when others =>
                    GeneralInternalError;
            end case;
            
        when others =>
            GeneralInternalError;
    end case;
end LoadObject;


procedure LoadActualParams(t_form_par_s, t_act_par_s: TREE) is
    nd_exp_s, nd_param_s, nd_id_s, nd: NODE;
    CurrAct, CurrForm, CurrFormId, CurrFormld: SEQ_TYPE;
begin
    GET_NODE(t_act_par_s, nd_exp_s);
    CurrAct := nd_exp_s.c_exp_s.as_list;
    
    GET_NODE(t_form_par_s, nd_param_s);
    CurrForm := nd_param_s.c_param_s.as_list;
    
    while not IS_EMPTY(CurrForm) loop
        GET_NODE(HEAD(CurrForm), nd);
        
        case KIND(HEAD(CurrForm)) is
            when _in =>
                GET_NODE(nd.c_in.as_id_s, nd_id_s);
                CurrFormId := nd_id_s.c_id_s.as_list;
                
                while not IS_EMPTY(CurrFormId) loop
                    CompileExpression(HEAD(CurrAct));
                    CurrAct := TAIL(CurrAct);
                    CurrFormId := TAIL(CurrFormId);
                end loop;
                
            when _in_out =>
                GET_NODE(nd.c_in_out.as_id_s, nd_id_s);
                CurrFormld := nd_id_s.c_id_s.as_list;
                
                while not IS_EMPTY(CurrFormld) loop
                    LoadObjectAddress(HEAD(CurrAct));
                    GenOT(aDPL, a_A);
                    LoadObject(nd.c_in_out.as_name);
                    CurrAct := TAIL(CurrAct);
                    CurrFormld := TAIL(CurrFormld);
                end loop;
                
            when _out =>
                GET_NODE(nd.c_out.as_id_s, nd_id_s);
                CurrFormId := nd_id_s.c_id_s.as_list;
                
                while not IS_EMPTY(CurrFormId) loop
                    LoadObjectAddress(HEAD(CurrAct));
                    GenOT(aDPL, a_A);
                    LoadObject(nd.c_out.as_name);
                    CurrAct := TAIL(CurrAct);
                    CurrFormId := TAIL(CurrFormId);
                end loop;
                
            when others =>
                GeneralInternalError;
        end case;
        
        CurrForm := TAIL(CurrForm);
    end loop;
end LoadActualParams;


procedure CompileStm_procedure_call(Stm: TREE) is
    nd_procedure_call, nd_used_name_id, nd_proc_id, nd_exp_s, nd_procedure: NODE;
    t_exp_s: TREE;
begin
    GET_NODE(Stm, nd_procedure_call);
    
    GET_NODE( nd_procedure_call.c_procedure_call.sm_normalized_param_s , nd_exp_s);
    t_exp_s := nd_procedure_call.c_procedure_call.sm_normalized_param_s;
    GET_NODE( nd_procedure_call.c_procedure_call.as_name , nd_used_name_id);
    
    GET_NODE( nd_used_name_id.c_used_name_id.sm_defn, nd_proc_id);
    GET_NODE( nd_proc_id.c_proc_id.sm_first , nd_proc_id);
    GET_NODE(nd_proc_id.c_proc_id.sm_spec, nd_procedure);
    
    Gen2NumNum(aMST, 0, Succ(Level - nd_proc_id.c_proc_id.cd_level));

    LoadActualParams(nd_procedure.c_procedure.as_param_s, t_exp_s);
    
    Comment := GetSymbol(lx_symrep);
    Gen2NumLbl(aCUP, cd_param_size, cd_label);
end CompileStm_procedure_call;


procedure CompileStm_raise(Stm: TREE) is
    nd_raise, nd_used_name_id, nd_exception_id: NODE;
begin
    GET_NODE(Stm, nd_raise);
    
    if nd_raise.c_raise.as_name_void = NULL_TREE then
    begin
        GenO(aRAI);
    end
    else
    begin
        GET_NODE(nd_raise.c_raise.as_name_void, nd_used_name_id);
        GET_NODE(nd_used_name_id.c_used_name_id.sm_defn, nd_exception_id);
        
        Comment := GetSymbol(nd_exception_id.c_exception_id.lx_symrep);
        Gen1Lbl(aRAI, nd_exception_id.c_exception_id.cd_label);
    end;
end CompileStm_raise;


procedure PerformReturn(EnclosingProc: TREE) is
    nd_block: NODE;
    LVBlbl: LabelType;
begin
    GET_NODE(EnclosingProc, nd_block);
    
    if nd_block.c_block.cd_level /= Level then
    begin
        LVBlbl := NextLabel;
        Gen1Lbl(aLVB, LVBlbl);
        GenLabelAssignment(LVBlbl, Level - nd_block.c_block.cd_level);
    end;
    
   Gen1Lbl(aUJP, nd_block.c_block.cd_return_label);
end PerformReturn;


procedure StoreFunctionResult(t_block, t_exp: TREE) is
    nd_block: NODE;
    LVBlbl: LabelType;
begin
    GET_NODE(t_block, nd_block);
    
    case KIND(TypeStructOfExpr(t_exp)) is
        _array:
            begin
                Gen2NumNum(aLDA, Level - nd_block.c_block.cd_level, nd_block.c_block.cd_result_offset);
                CompileExpression(t_exp);
                Gen1NumT(aLDC, a_I, NumberOfDimensions(t_exp));
                Comment := 'return value';
                GenCSP(aPUA);
            end;
            
        _enum_literal_s:
            begin
                CompileExpression(t_exp);
                Comment := 'return value';
                Gen2NumNumT(aSTR, aCodeType(t_exp), Level - nd_block.c_block.cd_level, nd_block.c_block.cd_result_offset);
            end;
            
        _integer:
            begin
                CompileExpression(t_exp);
                Comment := 'return value';
                Gen2NumNumT(aSTR, a_I, Level - nd_block.c_block.cd_level, nd_block.c_block.cd_result_offset);
            end;
            
        else
            GeneralInternalError;
    end case;
end StoreFunctionResult;


procedure CompileStm_return(Stm, EnclosingProc: TREE) is
    nd_return: NODE;
begin
    GET_NODE(Stm, nd_return);
    
    if nd_return.c_return.as_exp_void /= NULL_TREE then
        StoreFunctionResult(EnclosingProc, nd_return.c_return.as_exp_void);
    
    Comment := 'return';
    PerformReturn(EnclosingProc);
end CompileStm_return;


procedure CompileStatement(Stm, EnclosingProc: TREE) is
    nd_stm: NODE;
begin
    GET_NODE(Stm, nd_stm);
    
    case KIND(Stm) is
        when _abort =>
            null; -- No action needed for _abort
        
        when _accept =>
            null; -- No action needed for _accept
        
        when _assign =>
            CompileStm_assign(Stm);
        
        when _block =>
            CompileStm_block(Stm, EnclosingProc);
        
        when _case =>
            null; -- No action needed for _case
        
        when _code =>
            null; -- No action needed for _code
        
        when _cond_entry =>
            null; -- No action needed for _cond_entry
        
        when _delay =>
            null; -- No action needed for _delay
        
        when _entry_call =>
            null; -- No action needed for _entry_call
        
        when _exit =>
            CompileStm_exit(Stm);
        
        when _goto =>
            null; -- No action needed for _goto
        
        when _if =>
            CompileStm_if(Stm, EnclosingProc);
        
        when _labeled =>
            null; -- No action needed for _labeled
        
        when _loop =>
            CompileStm_loop(Stm, EnclosingProc);
        
        when _named_stm =>
            CompileStm_named_stm(Stm, EnclosingProc);
        
        when _null_stm =>
            Comment := "null";
            WriteComment;
        
        when _pragma =>
            null; -- No action needed for _pragma
        
        when _procedure_call =>
            CompileStm_procedure_call(Stm);
        
        when _raise =>
            CompileStm_raise(Stm);
        
        when _return =>
            CompileStm_return(Stm, EnclosingProc);
        
        when _select =>
            null; -- No action needed for _select
        
        when _timed_entry =>
            null; -- No action needed for _timed_entry
        
        when others =>
            GeneralInternalError;
    end case;
    
    TopAct := 0;
end CompileStatement;


procedure CompileStatements(Stm_s, EnclosingProc: TREE) is
    nd_stm_s: NODE;
    CurrStatement: SEO_TYPE;
begin
    GET_NODE(Stm_s, nd_stm_s);
    CurrStatement := nd_stm_s.c_stm_s.as_list;
    
    while not IS_EMPTY(CurrStatement) loop
        CompileStatement(HEAD(CurrStatement), EnclosingProc);
        CurrStatement := TAIL(CurrStatement);
    end loop;
end CompileStatements;


procedure CompileExceptionHandlers(Alternative_s, EnclosingProc: TREE) is
    nd_alternative_s: NODE;
    CurrHandler: SEQ_TYPE;
    NxtHandlerLbl: LabelType;
    OthersFlag: Boolean := False;
    
    procedure CompileHandler(t_alternative: TREE) is
        nd_alternative, nd_used_name_id, nd_choice_s, nd_exception_id: NODE;
        HandlerBeginLbl, SkipLbl: LabelType;
        CurrChoice: SEQ_TYPE;
    begin
        HandlerBeginLbl := NextLabel;
        GET_NODE(t_alternative, nd_alternative);
        GET_NODE(nd_alternative.c_alternative.as_choice_s, nd_choice_s);
        CurrChoice := nd_choice_s.c_choice_s.as_list;
        
        while not IS_EMPTY(CurrChoice) loop
            if KIND(HEAD(CurrChoice)) = _others then
                OthersFlag := True;
                CurrChoice := GET_EMPTY;
            else
                GET_NODE(HEAD(CurrChoice), nd_used_name_id);
                GET_NODE(nd_used_name_id.c_used_name_id.sm_defn, nd_exception_id);
                Comment := GetSymbol(lx_symrep);
                SkipLbl := NextLabel;
                Gen2LblLbl(aE)(C, nd_exception_id.c_exception_id.cd_label, SkipLbl);
                CurrChoice := TAIL(CurrChoice);
                
                if not IS_EMPTY(CurrChoice) then
                    Gen1Lbl(aUJP, HandlerBeginLbl);
                    WriteLabel(SkipLbl);
                end if;
            end if;
        end loop;
        
        WriteLabel(HandlerBeginLbl);
        CompileStatements(nd_alternative.c_alternative.as_stm_s, EnclosingProc);
        PerformReturn(EnclosingProc);
        
        if not OthersFlag then
            WriteLabel(SkipLbl);
        end if;
    end CompileHandler;
    
begin
    OthersFlag := False;
    GET_NODE(Alternative_s, nd_alternative_s);
    CurrHandler := nd_alternative_s.c_alternative_s.as_list;
    
    if IS_EMPTY(CurrHandler) then
        GenO(aEEX);
        return;
    end if;
    
    while not IS_EMPTY(CurrHandler) loop
        CompileHandler(HEAD(CurrHandler));
        CurrHandler := TAIL(CurrHandler);
    end loop;
    
    if not OthersFlag then
        GenO(aEEX);
    end if;
end CompileExceptionHandlers;


procedure CompileContext_package_id(t_package_id: TREE) is
    CurrDeclaration: SEQ_TYPE;
    nd_package_id, nd_package_spec, nd_decl_s: NODE;
begin
    GET_NODE(t_package_id, nd_package_id);
    
    if not nd_package_id.c_package_id.cd_compiled then
    begin
        Gen2NumStr(aRFP, CurrCompUnitNr, GetSymbol(nd_package_id.c_package_id.lx_symrep));
        GenerateCode := False;
        
        nd_package_id.c_package_id.cd_compiled := True;
        GET_NODE(nd_package_id.c_package_id.sm_spec, nd_package_spec);
        GET_NODE(nd_package_spec.c_package_spec.as_decl_s1, nd_decl_s);
        
        CurrDeclaration := nd_decl_s.c_decl_s.as_list;
        
        while not IS_EMPTY(CurrDeclaration) loop
            CompileDeclaration(HEAD(CurrDeclaration));
            CurrDeclaration := TAIL(CurrDeclaration);
        end loop;
    end;
end CompileContext_package_id;


procedure CompileWithClause(t_with: TREE) is
    CurrLibUnit, CurrDeclaration: SEQ_TYPE;
    nd_with, nd_used_name_id, nd_defn, nd_package_spec, nd_ded_s: NODE;
    ProcLbl: LabelType;
begin
    GET_NODE(t_with, nd_with);
    CurrLibUnit := nd_with.c_with.as_list;
    
    while not IS_EMPTY(CurrLibUnit) loop
        GET_NODE(HEAD(CurrLibUnit), nd_used_name_id);
        GenerateCode := True;
        GET_NODE(nd_used_name_id.c_used_name_id.sm_defn, nd_defn);
        
        case KIND(nd_used_name_id.c_used_name_id.sm_defn) is
            when _package_id =>
                CompileContext_package_id(nd_used_name_id.c_used_name_id.sm_defn);
                CurrCompUnitNr := CurrCompUnitNr + 1;
                
            when _proc_id =>
                if not nd_defn.c_proc_id.cd_compiled then
                begin
                    Gen2NumStr(aRFP, 0, GetSymbol(lx_symrep));
                    
                    ProcLbl := NextLabel;
                    nd_defn.c_proc_id.cd_label := ProcLbl;
                    nd_defn.c_proc_id.cd_level := 1;
                    nd_defn.c_proc_id.cd_param_size := 0;
                    nd_defn.c_proc_id.cd_compiled := True;
                    nd_defn.c_proc_id.Comment := "procedure " & GetSymbol(lx_symrep);
                    
                    PUT_NODE(nd_used_name_id.c_used_name_id.sm_defn, nd_defn);
                    Gen1Lbl(aRFL, ProcLbl);
                    GenerateCode := False;
                end;
                
            when others =>
                GeneralInternalError;
        end case;
        
        CurrLibUnit := TAIL(CurrLibUnit);
    end loop;
end CompileWithClause;


procedure CompileContext(Context: TREE) is
    CurrContext: SEQ_TYPE;
    Nd: NODE;
begin
    CurrCompUnitNr := 1;
    CompileContext_package_id(PKG_STANDARD);
    
    GenerateCode := False;
    GET_NODE(Context, Nd);
    
    if not IS_EMPTY(Nd.c_context.as_list) then
    begin
        CurrCompUnitNr := 2;
        CompileWithClause(HEAD(Nd.c_context.as_list));
    end;
    
    CurrCompUnitNr := 0;
    GenerateCode := True;
end CompileContext;


procedure CompileCompUnit_PackageDecl(t_package_decl: TREE) is
    nd_package_decl, nd_package_spec, nd_decl_s1: NODE;
    ENT1Lbl, ENT2Lbl, ExcLbl: LabelType;
    CurrDeclaration: SEQ_TYPE;
begin
    WriteLabel(1);
    ENT1Lbl := NextLabel;
    ENT2Lbl := NextLabel;
    Gen2NumLbl(aENT, 1, ENT1Lbl);
    Gen2NumLbl(aENT, 2, ENT2Lbl);
    OffsetAct := 0;
    OffsetMax := 0;

    GET_NODE(t_package_decl, nd_package_decl);
    GET_NODE(nd_package_decl.c_package_decl.as_package_def, nd_package_spec);
    GET_NODE(nd_package_spec.c_package_spec.as_decl_s1, nd_decl_s1);
    
    CurrDeclaration := nd_decl_s1.c_decl_s.as_list;
    
    while not IS_EMPTY(CurrDeclaration) loop
        CompileDeclaration(HEAD(CurrDeclaration));
        CurrDeclaration := TAIL(CurrDeclaration);
    end loop;
    
    ExcLbl := NextLabel;
    Gen1Lbl(aEXH, ExcLbl);
    Gen1Num(aRET, RelativeResultOffset);
    
    WriteLabel(ExcLbl);
    GenO(aEEX);
    
    GenLabelAssignment(ENT1Lbl, OffsetMax);
    GenLabelAssignment(ENT2Lbl, OffsetMax + TopMax);
end CompileCompUnit_PackageDecl;


procedure CompilePackageSpec(t_package_spec: TREE) is
    nd_package_spec, nd_decl_s : NODE;
    CurrDeclaration : SEQ_TYPE;
begin
    GenerateCode := false;
    
    GET_NODE(t_package_spec, nd_package_spec);
    GET_NODE(nd_package_spec.c_package_spec.as_decl_s1, nd_decl_s);
    CurrDeclaration := nd_decl_s.c_decl_s.as_list;
    
    while not IS_EMPTY(CurrDeclaration) loop
        CompileDeclaration(HEAD(CurrDeclaration));
        CurrDeclaration := TAIL(CurrDeclaration);
    end loop;
    
    GenerateCode := true;
end CompilePackageSpec;


procedure CompileCompUnit(CompUnit: TREE) is
    nd_comp_unit, nd_unit_body, nd_unit_id: NODE;
begin
    ConditionalError(4007, KIND(CompUnit) /= _comp_unit);
    
    GET_NODE(CompUnit, nd_comp_unit);
    GET_NODE(nd_comp_unit.c_comp_unit.as_unit_body, nd_unit_body);
    
    Init;
    
    case KIND(nd_unit_body) is
        when _subprogram_body =>
            GET_NODE(nd_unit_body.c_subprogram_body.as_designator, nd_unit_id);
            UnitName := GetSymbol(nd_unit_id.c_proc_id.lx_symrep);
            WriteLn('Generating code for procedure ', UnitName);
            Gen1Str(aPRO, UnitName);
            CompileContext(nd_comp_unit.c_comp_unit.as_context);
            CompileProcedure(nd_comp_unit.c_comp_unit.as_unit_body, 1);
            
        when _package_body =>
            GET_NODE(nd_unit_body.c_package_body.as_id, nd_unit_id);
            UnitName := GetSymbol(nd_unit_id.c_package_id.lx_symrep);
            WriteLn('Generating code for package body ', UnitName);
            Gen1Str(aPKB, UnitName);
            CompilePackageSpec(nd_comp_unit.c_comp_unit.as_spec);
            CompileContext(nd_comp_unit.c_comp_unit.as_context);
            WriteLabel(1);
            CompileSubpBlock(nd_unit_body.c_package_body.as_block_stub,
                             nd_unit_body.c_package_body.as_block_stub,
                             NULL_TREE,
                             RelativeResultOffset);
            
        when _package_decl =>
            GET_NODE(nd_unit_body.c_package_decl.as_id, nd_unit_id);
            UnitName := GetSymbol(nd_unit_id.c_package_id.lx_symrep);
            WriteLn('Generating code for package ', UnitName);
            Gen1Str(aPKG, UnitName);
            CompileContext(nd_comp_unit.c_comp_unit.as_context);
            CompileCompUnit_PackageDecl(nd_comp_unit.c_comp_unit.as_unit_body);
            
        others =>
            ConditionalError(4008, true);
    end case;
    
    GenO(aQ);
end CompileCompUnit;


procedure CodeGenerator(Root: TREE; FileName: String) is
begin
    OpenOutputFile(FileName);
    Comment := "Ada Code Generator, version " & VerNr;
    WriteComment;
    WriteComment;
    
    ConditionalError(4001, Root = NULL_TREE);
    ConditionalError(5, KIND(Root) /= _compilation);
    
    GET_NODE(Root, Nd);
    CurrCompUnit := Nd.c_compilation.as_list;
    
    while not IS_EMPTY(CurrCompUnit) loop
        CompileCompUnit(HEAD(CurrCompUnit));
        CurrCompUnit := TAIL(CurrCompUnit);
        WriteComment;
    end loop;
    
    Comment := "End of compilation";
    WriteComment;
    CloseOutputFile;
end CodeGenerator;


end CodeGen;
