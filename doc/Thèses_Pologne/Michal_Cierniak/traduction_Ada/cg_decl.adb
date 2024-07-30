package body CG_Decl is

   procedure ConditionalError(ErrorCode: Integer; Condition: Boolean) is
   begin
      if Condition then
      begin
         CG_Lib.WriteComment;
         CG_Lib.CloseOutputFile;
         CG_Lib.Error(ErrorCode);
      end;
   end;

   procedure GenerallnternalError is
   begin
      ConditionalError(999, true);
   end;

procedure CompileBoolConst(t_const_id: TREE) is
   nd_const_id : NODE;
   t_object_def : TREE;
begin
   Align(BoolAl);
   GET_NODE(t_const_id, nd_const_id);
   GET_NODE(nd_const_id.c_const_id.sm_first, nd_const_id);
   
   with nd_const_id.c_const_id loop
      cd_level    := Level;
      cd_offset   := -OffsetAct;
      cd_comp_unit := CurrCompUnitNr;
      cd_compiled := true;
      t_object_def := sm_obj_def;
   end;
   
   IncrementOffset(BoolSize);
   CompileExpression(t_object_def);
   
   with nd_const_id.c_const_id loop
      Comment := GetSymbol(lx_symrep);
      GenStore(a_B, cd_comp_unit, cd_level, cd_offset);
   end;
end CompileBoolConst;

procedure CompileCharConst(t_const_id : TREE) is
   nd_const_id : NODE;
   t_object_def : TREE;
begin
   Align(CharAl);
   GET_NODE(t_const_id, nd_const_id);
   GET_NODE(nd_const_id.c_const_id.sm_first, nd_const_id);
   
   nd_const_id.c_const_id.cd_level := Level;
   nd_const_id.c_const_id.cd_offset := -OffsetAct;
   nd_const_id.c_const_id.cd_comp_unit := CurrCompUnitNr;
   nd_const_id.c_const_id.cd_compiled := True;
   t_object_def := sm_obj_def;
   
   IncrementOffset(CharSize);
   CompileExpression(t_object_def);
   
   nd_const_id.c_const_id.Comment := GetSymbol(nd_const_id.c_const_id.lx_symrep);
   GenStore(a_C, nd_const_id.c_const_id.cd_comp_unit, nd_const_id.c_const_id.cd_level, nd_const_id.c_const_id.cd_offset);
end CompileCharConst;

procedure CompileEnumConst(t_const_id, t_type_spec: TREE);
   nd_const_id : NODE;
   t_object_def : TREE;
begin
   if BooleanType(t_type_spec) then
   begin
      CompileBoolConst(t_const_id);
      return;
   end
   elsif CharacterType(t_type_spec) then
   begin
      CompileCharConst(t_const_id);
      return;
   end;

   Align(IntegerAl);
   GET_NODE(t_const_id, nd_const_id);
   GET_NODE(nd_const_id.c_const_id.sm_first, nd_const_id);

   nd_const_id.c_const_id.cd_level    := Level;
   nd_const_id.c_const_id.cd_offset   := -OffsetAct;
   nd_const_id.c_const_id.cd_comp_unit := CurrCompUnitNr;
   nd_const_id.c_const_id.cd_compiled := true;
   t_object_def := sm_obj_def;

   IncrementOffset(IntegerSize);
   CompileExpression(t_object_def);

   nd_const_id.c_const_id.Comment := GetSymbol(lx_symrep);
   GenStore(a_I, nd_const_id.c_const_id.cd_comp_unit,
                   nd_const_id.c_const_id.cd_level,
                   nd_const_id.c_const_id.cd_offset);
end;

procedure CompileIntegerConst(t_const_id: TREE) is
   nd_const_id: NODE;
   t_object_def: TREE;
begin
   CG_Lib.Align(CG_Lib.IntegerAl);
   CG_Expr.GET_NODE(t_const_id, nd_const_id);
   CG_Expr.GET_NODE(nd_const_id.c_const_id.sm_first, nd_const_id);

   nd_const_id.c_const_id.cd_level    := CG_Lib.Level;
   nd_const_id.c_const_id.cd_offset   := -CG_Lib.OffsetAct;
   nd_const_id.c_const_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_const_id.c_const_id.cd_compiled := true;
   t_object_def := sm_obj_def;

   CG_Lib.IncrementOffset(CG_Lib.IntegerSize);
   CG_Expr.CompileExpression(t_object_def);

   nd_const_id.c_const_id.Comment := CG_Lib.GetSymbol(nd_const_id.c_const_id.lx_symrep);
   CG_Lib.GenStore(CG1.a_I, nd_const_id.c_const_id.cd_comp_unit,
                          nd_const_id.c_const_id.cd_level,
                          nd_const_id.c_const_id.cd_offset);
end CompileIntegerConst;

   procedure CompileConst(t_const_id, t_type_spec: TREE) is
   begin
      case CG_Lib.KIND(t_type_spec) is
         when CG_Lib._enum_literal_s =>
            CompileEnumConst(t_const_id, t_type_spec);
         when CG_Lib._integer =>
            CompileIntegerConst(t_const_id);
         when others =>
            GenerallnternalError;
      end case;
   end CompileConst;

procedure CompileDecl_constant(t_constant: TREE) is
   nd_constant, nd_id_s: NODE;
   CurrConst: SEQ_TYPE;
begin
   CG_Expr.GET_NODE(t_constant, nd_constant);
   CG_Expr.GET_NODE(nd_constant.c_constant.as_id_s, nd_id_s);
   CurrConst := nd_id_s.c_id_s.as_list;
   
   while not CG_Expr.IS_EMPTY(CurrConst) loop
      CompileConst(HEAD(CurrConst), nd_constant.c_constant.as_type_spec);
      CurrConst := CG_Expr.TAIL(CurrConst);
   end loop;
end CompileDecl_constant;


procedure CompileAccessVar(t_var_id, t_type_spec: TREE) is
   nd_var_id, nd_access, nd_allocator: NODE;
   ValuePtr, DescrPtr: OffsetType;
begin
   CG_Lib.GET_NODE(t_var_id, nd_var_id);
   CG_Lib.GET_NODE(t_type_spec, nd_access);
   
   with nd_var_id.c_var_id loop
      CG_Lib.Align(CG_Lib.AddrAl);
      cd_offset := -CG_Lib.OffsetAct;
      CG_Lib.IncrementOffset(CG_Lib.AddrSize);
      cd_level := CG_Lib.Level;
      cd_comp_unit := CG_Lib.CurrCompUnitNr;
      
      if sm_obj_def = NULL_TREE then
      begin
         Comment := 'null';
         CG_Lib.Gen1NumT(CG1.aLDC, CG1.a_A, NULL);
      else
         CG_Lib.GET_NODE(sm_obj_def, nd_allocator);
         CG_Lib.LoadTypeSize(nd_allocator.c_allocator.as_exp_constrained);
         CG_Lib.Gen1Num(CG1.aALO, CG_Lib.Level - CG_Lib.LevelOfType(sm_obj_type));
      end if;
      
      Comment := CG_Lib.GetSymbol(CG1.lx_symrep);
      CG_Lib.GenStore(CG1.a_A, CG_Lib.CurrCompUnitNr, CG_Lib.Level, cd_offset);
   end loop;
end CompileAccessVar;


procedure CompileArrayVar(t_var_id, t_type_spec: TREE) is
   nd_var_id, nd_array: NODE;
   ValuePtr, DescrPtr: OffsetType;
begin
   CG_Lib.Align(CG_Lib.AddrAl);
   ValuePtr := -CG_Lib.OffsetAct;
   CG_Lib.GET_NODE(t_var_id, nd_var_id);
   
   nd_var_id.c_var_id.cd_level := CG_Lib.Level;
   nd_var_id.c_var_id.cd_offset := ValuePtr;
   nd_var_id.c_var_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_var_id.c_var_id.cd_compiled := true;
   
   CG_Lib.PUT_NODE(t_var_id, nd_var_id);
   CG_Lib.IncrementOffset(CG_Lib.AddrSize);
   CG_Lib.Align(CG_Lib.AddrAl);
   DescrPtr := -CG_Lib.OffsetAct;
   CG_Lib.IncrementOffset(CG_Lib.AddrSize);
   
   CG_Lib.GET_NODE(t_type_spec, nd_array);
   
   if nd_array.c_array.cd_compiled then
   begin
      CG_Lib.Comment := 'array type descriptor';
      CG_Lib.GenLoadAddr(nd_array.c_array.cd_comp_unit, nd_array.c_array.cd_level, nd_array.c_array.cd_offset);
      CG_Lib.GenOT(CG1.aDPL, CG1.a_A);
      CG_Lib.GenStore(CG1.a_A, CG_Lib.CurrCompUnitNr, CG_Lib.Level, DescrPtr);
      CG_Lib.Gen1NumT(CG1.aIND, CG1.a_I, 0);
      CG_Lib.Gen1Num(CG1.aALO, 0);
      CG_Lib.Comment := 'array value pointer';
      CG_Lib.GenStore(CG1.a_A, CG_Lib.CurrCompUnitNr, CG_Lib.Level, ValuePtr);
   else
      CG_Lib.GeneralInternalError;
   end;
end CompileArrayVar;


procedure CompileBoolVar(t_var_id, t_type_spec: TREE) is
   nd_var_id: NODE;
   t_object_def: TREE;
begin
   CG_Lib.Align(CG_Lib.BoolAl);
   CG_Expr.GET_NODE(t_var_id, nd_var_id);
   
   nd_var_id.c_var_id.cd_level := CG_Lib.Level;
   nd_var_id.c_var_id.cd_offset := -CG_Lib.OffsetAct;
   nd_var_id.c_var_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_var_id.c_var_id.cd_compiled := True;
   t_object_def := nd_var_id.c_var_id.sm_obj_def;
   
   CG_Expr.PUT_NODE(t_var_id, nd_var_id);
   CG_Lib.IncrementOffset(CG_Lib.BoolSize);
   
   if t_object_def /= CG_Lib.NULL_TREE then
   begin
      CG_Expr.CompileExpression(t_object_def);
      CG_Lib.Comment := CG_Lib.GetSymbol(nd_var_id.c_var_id.lx_symrep);
      CG_Lib.GenStore(CG1.a_B, nd_var_id.c_var_id.cd_comp_unit, nd_var_id.c_var_id.cd_level, nd_var_id.c_var_id.cd_offset);
   end;
end CompileBoolVar;

procedure CompileCharVar(t_var_id, t_type_spec: TREE) is
   nd_var_id: NODE;
   t_object_def: TREE;
begin
   CG_Lib.Align(CG_Lib.CharAl);
   CG_Expr.SET_NODE(t_var_id, nd_var_id);
   
   nd_var_id.c_var_id.cd_level := CG_Lib.Level;
   nd_var_id.c_var_id.cd_offset := -CG_Lib.OffsetAct;
   nd_var_id.c_var_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_var_id.c_var_id.cd_compiled := True;
   t_object_def := nd_var_id.c_var_id.sm_obj_def;
   
   CG_Expr.PUT_NODE(t_var_id, nd_var_id);
   CG_Lib.IncrementOffset(CG_Lib.CharSize);
   
   if t_object_def /= CG_Lib.NULL_TREE then
   begin
      CG_Expr.CompileExpression(t_object_def);
      CG_Lib.Comment := CG_Lib.GetSymbol(nd_var_id.c_var_id.lx_symrep);
      CG_Lib.GenStore(CG1.a_C, nd_var_id.c_var_id.cd_comp_unit, nd_var_id.c_var_id.cd_level, nd_var_id.c_var_id.cd_offset);
   end;
end CompileCharVar;

procedure CompileEnumVar(t_var_id, t_type_spec: TREE) is
   nd_var_id: NODE;
   t_object_def: TREE;
begin
   if BooleanType(t_type_spec) then
   begin
      CompileBoolVar(t_var_id, t_type_spec);
      return;
   end
   elsif CharacterType(t_type_spec) then
   begin
      CompileCharVar(t_var_id, t_type_spec);
      return;
   end;
   
   CG_Lib.Align(CG_Lib.IntegerAl);
   CG_Expr.GET_NODE(t_var_id, nd_var_id);
   
   nd_var_id.c_var_id.cd_level := CG_Lib.Level;
   nd_var_id.c_var_id.cd_offset := -CG_Lib.OffsetAct;
   nd_var_id.c_var_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_var_id.c_var_id.cd_compiled := True;
   t_object_def := nd_var_id.c_var_id.sm_obj_def;
   
   CG_Lib.IncrementOffset(CG_Lib.IntegerSize);
   
   if t_object_def /= CG_Lib.NULL_TREE then
   begin
      CG_Expr.CompileExpression(t_object_def);
      CG_Lib.Comment := CG_Lib.GetSymbol(nd_var_id.c_var_id.lx_symrep);
      CG_Lib.GenStore(CG1.a_I, nd_var_id.c_var_id.cd_comp_unit,
                      nd_var_id.c_var_id.cd_level,
                      nd_var_id.c_var_id.cd_offset);
   end;
end CompileEnumVar;

procedure CompileIntegerVar(t_var_id, t_type_spec: TREE) is
   nd_var_id: CG_Expr.NODE;
   t_object_def: TREE;
begin
   CG_Lib.Align(CG_Lib.IntegerAl);
   CG_Expr.GET_NODE(t_var_id, nd_var_id);
   
   nd_var_id.c_var_id.cd_level := CG_Lib.Level;
   nd_var_id.c_var_id.cd_offset := -CG_Lib.OffsetAct;
   nd_var_id.c_var_id.cd_comp_unit := CG_Lib.CurrCompUnitNr;
   nd_var_id.c_var_id.cd_compiled := True;
   t_object_def := nd_var_id.c_var_id.sm_obj_def;
   
   CG_Lib.PUT_NODE(t_var_id, nd_var_id);
   CG_Lib.IncrementOffset(CG_Lib.IntegerSize);
   
   if t_object_def /= CG_Lib.NULL_TREE then
   begin
      CG_Expr.CompileExpression(t_object_def);
      CG_Lib.Comment := CG_Lib.GetSymbol(nd_var_id.c_var_id.lx_symrep);
      CG_Lib.GenStore(CG1.a_I, nd_var_id.c_var_id.cd_comp_unit,
                      nd_var_id.c_var_id.cd_level,
                      nd_var_id.c_var_id.cd_offset);
   end;
end CompileIntegerVar;

   procedure CompileVar(t_var_id, t_type_spec: TREE) is
   begin
      case CG_Lib.KIND(t_type_spec) is
         when CG_Lib._access =>
            CompileAccessVar(t_var_id, t_type_spec);
         when CG_Lib._array =>
            CompileArrayVar(t_var_id, t_type_spec);
         when CG_Lib._enum_literal_s =>
            CompileEnumVar(t_var_id, t_type_spec);
         when CG_Lib._integer =>
            CompileIntegerVar(t_var_id, t_type_spec);
         when others =>
            GenerallnternalError;
      end case;
   end CompileVar;


procedure CompileDecl_var(Variable: TREE) is
   nd_var, nd_id_s: NODE;
   CurrVar: SEQ_TYPE;
begin
   GET_NODE(Variable, nd_var);
   SET_NODE(nd_var.c_var.as_id_s, nd_id_s);
   CurrVar := nd_id_s.c_id_s.as_list;
   
   while not IS_EMPTY(CurrVar) loop
      CompileVar(HEAD(CurrVar), nd_var.c_var.as_type_spec);
      CurrVar := TAIL(CurrVar);
   end loop;
end CompileDecl_var;

procedure CompileType_access(t_type : TREE) is
   nd_type, nd_type_id, nd_access : NODE;
begin
   GET_NODE(t_type, nd_type);
   nd_type_id := nd_type.c_type.as_id;
   nd_access := nd_type.c_type.as_type_spec;

   case KIND(nd_access.c_access) is
      when _constrained =>
         if Constrained(nd_access.c_access.as_constrained) then
            nd_access.c_access.cd_level := Level;
            Align(IntegerAI);
            nd_access.c_access.cd_offset := OffsetAct;
            IncrementOffset(IntegerSize);
            LoadTypeSize(nd_access.c_access.as_constrained);
            Comment := "type " & GetSymbol(nd_type_id.c_type_id.lx_symrep);
            GenStore(a_I, 0, Level, nd_access.c_access.cd_offset);
         end if;

      when others =>
         GeneralInternalError;
   end case;
end CompileType_access;


procedure CompileType_Array_Dimension(Dim : SEQ_TYPE; ElType : TREE) is
   idxfac, first, last : OffsetType;
   nd_dscrt_range : NODE;
begin
   DimensionsNr := DimensionsNr + 1;
   Align(IntegerAl);
   idxfac := -OffsetAct;
   IncrementOffset(IntegerSize);
   Align(IntegerAl);
   first := -OffsetAct;
   IncrementOffset(IntegerSize);
   Align(IntegerAl);
   last := -OffsetAct;
   IncrementOffset(IntegerSize);

   if IS_EMPTY(TAIL(Dim)) then
      LoadTypeSize(ElType);
      GenOT(aDPL, a_I);
      Comment := "element size";
      GenStore(a_I, 0, Level, idxfac);
   else
      CompileType_Array_Dimension(TAIL(Dim), ElType);
      GenOT(aDPL, a_I);
      Comment := "IDXFAC";
      GenStore(a_I, 0, Level, idxfac);
   end if;

   GET_NODE(HEAD(Dim), nd_dscrt_range);

   case KIND(HEAD(Dim)) is
      when _range =>
         CompileExpression(nd_dscrt_range.c_range.as_exp1);
         Comment := "FIRST";
         GenStore(a_I, CurrCompUnitNr, Level, first);
         CompileExpression(nd_dscrt_range.c_range.as_exp2);
         Comment := "LAST";
         GenStore(a_I, 0, Level, last);
         GenLoadAddr(0, Level, first);
         GenCSP(aLEN);
         GenOT(aMUL, a_I);

      when others =>
         GeneralInternalError;
   end case;
end CompileType_Array_Dimension;

procedure CompileType_array(t_type : TREE) is
   nd_array, nd_type, nd_type_id, nd_dscrt_range_s : NODE;
begin
   GET_NODE(t_type, nd_type);
   GET_NODE(nd_type.c_type.as_type_spec, nd_array);
   GET_NODE(nd_type.c_type.as_id, nd_type_id);

   Comment := "array " & GetSymbol(nd_type_id.c_type_id.lx_symrep);
   WriteComment;
   Align(IntegerAl);

   nd_array.c_array.cd_offset := -OffsetAct;
   nd_array.c_array.cd_level := Level;
   nd_array.c_array.cd_comp_unit := CurrCompUnitNr;
   nd_array.c_array.cd_compiled := True;

   IncrementOffset(IntegerSize);
   GET_NODE(nd_array.c_array.as_dscrt_range_s, nd_dscrt_range_s);
   DimensionsNr := 0;

   CompileType_Array_Dimension(nd_dscrt_range_s.c_dscrt_range_s.as_list,
                               nd_array.c_array.as_constrained);

   GenStore(a_I, CurrCompUnitNr, Level, nd_array.c_array.cd_offset);
   nd_array.c_array.cd_dimensions := DimensionsNr;
   PUT_NODE(nd_type.c_type.as_type_spec, nd_array);
end CompileType_array;

procedure CompileType_enum_literal_s(t_type : TREE) is
   nd_enum_literal_s, nd_type : NODE;
   Curr : SEQ_TYPE;
   i : Integer;
begin
   GET_NODE(t_type, nd_type);
   GET_NODE(nd_type.c_type.as_type_spec, nd_enum_literal_s);

   Curr := nd_enum_literal_s.c_enum_literal_s.as_list;
   i := -1;
   while not IS_EMPTY(Curr) loop
      i := i + 1;
      Curr := TAIL(Curr);
   end loop;

   nd_enum_literal_s.c_enum_literal_s.cd_last := i;
end CompileType_enum_literal_s;

procedure CompileType_integer(t_type : TREE) is
   nd_integer, nd_type, nd_type_id, nd_range : NODE;
   lower, upper : OffsetType;
begin
   GET_NODE(t_type, nd_type);
   GET_NODE(nd_type.c_type.as_type_spec, nd_integer);
   GET_NODE(nd_type.c_type.as_id, nd_type_id);
   GET_NODE(nd_integer.c_integer.as_range, nd_range);

   Comment := "integer " & GetSymbol(nd_type_id.c_type_id.lx_symrep);
   WriteComment;

   Align(IntegerAI);
   lower := -OffsetAct;
   IncrementOffset(IntegerSize);

   Align(IntegerAl);
   upper := -OffsetAct;
   IncrementOffset(IntegerSize);

   nd_integer.c_integer.cd_offset := lower;
   nd_integer.c_integer.cd_level := Level;
   nd_integer.c_integer.cd_comp_unit := CurrCompUnitNr;
   nd_integer.c_integer.cd_compiled := True;

   CompileExpression(nd_range.c_range.as_exp1);
   GenStore(a_I, CurrCompUnitNr, Level, lower);

   CompileExpression(nd_range.c_range.as_exp2);
   GenStore(a_l, CurrCompUnitNr, Level, upper);

   PUT_NODE(nd_type.c_type.as_type_spec, nd_integer);
end CompileType_integer;


procedure CompileDecl_type(t_type : TREE) is
   nd_type : NODE;
begin
   if CurrCompUnitNr = 1 then
      return; -- Exit early if current compilation unit number is 1
   end if;

   GET_NODE(t_type, nd_type);

   case KIND(nd_type.c_type.as_type_spec) is
      when _access =>
         CompileType_access(t_type);
      when _array =>
         CompileType_array(t_type);
      when _enum_literal_s =>
         CompileType_enum_literal_s(t_type);
      when _integer =>
         CompileType_integer(t_type);
      when others =>
         GeneralInternalError; -- Handle other cases (if any) as internal errors
   end case;
end CompileDecl_type;

end CG_Decl;
