with Diana;

package body CG_EXPR is

    CompUnitNr : Byte;
    Lvl : Level_Type;
    Dffs : Offset_Type;

    procedure ConditionalError(ErrorCode: Integer; Condition: Boolean) is
    begin
        if Condition then
            CloseOutputFile;
            Error(ErrorCode);
        end if;
    end ConditionalError;

    procedure GeneralInternalError is
    begin 
        ConditionalError(999, True);
    end GeneralInternalError;

    function TypeStruct(t_type:in TREE) return TREE is
		ND : NODE:= GET_NODE(T_TYPE);
    begin
        case KIND(t_type) is
            when n_access | n_array | enum_literal_s | n_integer =>                return t_type;
            when CONSTRAINED =>  return TypeStruct( nd.c_constrained.sm_type_struct);
            when TYPE_ID =>                return TypeStruct(nd.c_type_id.sm_type_spec);
            when USED_NAME_ID =>                return TypeStruct(nd.c_used_name_id.sm_defn);
            when others =>                GeneralInternalError; return NULL_TREE;
        end case;
    end TypeStruct;

    function TypeStructOfExpr(t_exp:in TREE) return TREE is
        nd: NODE;
    begin
        GET_NODE(t_exp, nd);
        case KIND(t_exp) is
            when function_call =>                return TypeStruct(nd.c_function_call.sm_exp_type);
            when used_object_id =>                return TypeStruct(nd.c_used_object_id.sm_exp_type);
            when others =>                GeneralInternalError; return NULL_TREE;
        end case;
    end TypeStructOfExpr;

    function Constrained(t_type_spec:in TREE) return Boolean is
        nd_type_spec: NODE;
    begin
        GET_NODE(t_type_spec, nd_type_spec);
        case KIND(t_type_spec) is
            when enum_literal_s =>                return True;
            when n_integer =>                return True;
            when constrained =>                return Constrained(nd_type_spec.c_constrained.sm_type_struct);
            when others =>                GeneralInternalError; return false;
        end case;
    end Constrained;

    function TypeSize(t: TREE) return Integer is
        nd: NODE;
    begin
        GET_NODE(t, nd);
        case KIND(t) is
            when n_access =>                return AddrSize;
            when n_array =>                return AddrSize + AddrSize;
            when enum_literal_s | n_integer =>                return IntegerSize;
            when type_id =>                return TypeSize(nd.c_type_id.sm_type_spec);
            when used_name_id =>                return TypeSize(nd.c_used_name_id.sm_defn);
            when others =>                GeneralInternalError; return 0;
        end case;
    end TypeSize;

    procedure LoadTypeSize(t: TREE) is
        nd: NODE;
    begin
        GET_NODE(t, nd);
        case KIND(t) is
            when constrained =>                if not Constrained(nd.c_constrained.sm_type_struct) then
                    ConditionalError(999, True);
                end if;
                LoadTypeSize(nd.c_constrained.sm_type_struct);
            when enum_literal_s | n_integer =>                Gen1NumT(aLDC, a_I, TypeSize(t));
            when others =>                GeneralInternalError;
        end case;
    end LoadTypeSize;

    function LevelOfType(t_type_spec: TREE) return Level_Type is
        nd: NODE;
    begin
        GET_NODE(t_type_spec, nd);
        case KIND(t_type_spec) is
            when n_access =>                return nd.c_access.cd_level;
            when others =>                GeneralInternalError;
        end case;
    end LevelOfType;

    function BooleanType(t_type_spec: TREE) return Boolean is
    begin
        return t_type_spec = STD_BOOLEAN;
    end BooleanType;

    function CharacterType(t_type_spec:in TREE) return Boolean is
    begin
        return t_type_spec = STD_CHARACTER;
    end CharacterType;

    function aCodeType(t_type_spec: TREE) return aCodeTypes is
        nd: NODE;
    begin
        GET_NODE(t_type_spec, nd);
        case KIND(t_type_spec) is
            when n_access =>                return a_A;
            when enum_literal_s =>                if BooleanType(t_type_spec) then
                    return a_B;
                elsif CharacterType(t_type_spec) then
                    return a_C;
                else
                    return a_I;
                end if;
            when exp_s =>                return aCodeType( HEAD(nd.c_exp_s.as_list) );
            when function_call =>                return aCodeType(nd.c_function_call.sm_exp_type);
            when n_integer | numeric_literal =>
                return a_I;
            when parenthesized =>                return aCodeType(nd.c_parenthesized.sm_exp_type);
            when used_object_id =>
                return aCodeType(nd.c_used_object_id.sm_exp_type);
            when others =>                GeneralInternalError;
        end case;
    end aCodeType;

procedure LoadAddress_indexed(t_indexed:in TREE) is
    nd_indexed, nd_exp_s: NODE;

    procedure Index(Expr: SEQ_TYPE) is
    begin
        if not IS_EMPTY(Expr) then
            CompileExpression(HEAD(Expr));
            Expr := TAIL(Expr);
            if IS_EMPTY(Expr) then
                GenCSP(aAR2);
            else
                GenCSP(aAR1);
                Gen1NumT(aDEC, a_A, IntegerSize);
                Index(Expr);
					GenOT (aADD, a_I);
					end if;
        end if;
    end Index;

begin
    GET_NODE(t_indexed, nd_indexed);
        LoadObjectAddress( nd_indexed.C_INDEXED.as_name);
        GenOT(aDPL, a_A);
        Gen1NumT(aInd, a_A, 0);
        GenOT(aSWP, a_A);
        Gen1NumT(aInd, a_A, -AddrSize);
        Gen1NumT(aDEC, a_A, IntegerSize);
        GET_NODE( nd_indexed.C_INDEXED.as_exp_s, nd_indexed.C_INDEXED.nd_exp_s);
        Index( nd_exp_s.c_exp_s.AS_LIST );
        Gen1Num(AIXA, 1);
end LoadAddress_indexed;

procedure LoadAddress(t_object:in TREE) is
    nd: NODE;
begin
    GET_NODE(t_object, nd);
    case KIND(t_object) is
        when indexed =>            LoadAddress_indexed(t_object);
        when in_id =>
                Comment := GetSymbol(nd.c_in_id.lx_symrep);
                GenLoad(a_A, 0, nd.c_in_id.cd_level, nd.c_in_id.cd_offset);
        when in_out_id =>
                Comment := GetSymbol(nd.c_in_out_id.lx_symrep);
                GenLoad(a_A, 0, nd.c_in_out_id.cd_level, nd.c_in_out_id.cd_val_offset);
        when out_id =>
                 Comment := GetSymbol( nd.C_OUT_ID.lx_symrep);
                GenLoad(a_A, 0, nd.c_out_id.cd_level, nd.c_out_id.cd_val_offset);
        when var_id =>
                Comment := GetSymbol(nd.C_VAR_ID.lx_symrep);
                GenLoad(a_A, nd.C_VAR_ID.cd_comp_unit, nd.C_VAR_ID.cd_level, nd.C_VAR_ID.cd_offset);
         when used_object_id =>            LoadAddress(nd.c_used_object_id.sm_defn);
        when others =>            GeneralInternalError;
    end case;
end LoadAddress;

procedure LoadObjectAddress(t_object:in TREE) is
    nd: NODE;
begin
    GET_NODE(t_object, nd);
    case KIND(t_object) is
        when indexed =>
            LoadAddress_indexed(t_object);
        when in_id =>
                Comment := GetSymbol( nd.C_IN_ID.lx_symrep);
                Gen2NumNum(aLDA, Level - nd.C_IN_ID.cd_level, nd.C_IN_ID.cd_offset);
         when in_out_id =>
                Comment := GetSymbol( nd.C_IN_OUT_ID.lx_symrep);
                Gen2NumNum(aLDA, Level - nd.C_IN_OUT_ID.CD_LEVEL, nd.C_IN_OUT_ID.cd_val_offset);
         when out_id =>
                 Comment := GetSymbol( nd.C_OUT_ID.lx_symrep);
                Gen2NumNum(aLDA, Level - nd.C_OUT_ID.CD_LEVEL, nd.C_OUT_ID.CD_VAL_OFFSET);
        when var_id =>
                Comment := GetSymbol( nd.C_VAR_ID.lx_symrep);
                GenLoadAddr( nd.C_VAR_ID.cd_comp_unit, nd.C_VAR_ID.cd_level, nd.C_VAR_ID.cd_offset);
         when used_object_id =>
            LoadObjectAddress(nd.c_used_object_id.sm_defn);
        when others =>
            GeneralInternalError;
    end case;
end LoadObjectAddress;

procedure GetCLO(t:in TREE; CompUnitNr: in out Byte; Lvl: in out Level_Type; Offs: in out OFFSET_TYPE) is
    nd: NODE;
begin
    GET_NODE(t, nd);
    case KIND(t) is
        when in_id =>
                CompUnitNr := 0;
                Lvl := nd.C_IN_ID.cd_level;
                Offs := nd.C_IN_ID.cd_offset;
        when in_out_id =>
                CompUnitNr := 0;
                Lvl := nd.C_IN_OUT_ID.cd_level;
                Offs := nd.C_IN_OUT_ID.cd_val_offset;
         when out_id =>
                CompUnitNr := 0;
                Lvl := nd.C_OUT_ID.cd_level;
                Offs := nd.C_OUT_ID.cd_val_offset;
         when integer =>
                CompUnitNr := cd_comp_unit;
                Lvl := nd.C_INTEGER.cd_level;
                Offs := nd.C_INTEGER.cd_offset;
        when var_id =>
                CompUnitNr := nd.C_VAR_ID.cd_comp_unit;
                Lvl := nd.C_VAR_ID.cd_level;
                Offs := nd.C_VAR_ID.cd_offset;
        when others =>
            GeneralInternalError;
    end case;
end GetCLO;

procedure LoadParams(t_normalized_param_s: TREE) is
    nd_exp_s: NODE;
    CurrParam: SEQ_TYPE;
begin
    GET_NODE(t_normalized_param_s, nd_exp_s);
    CurrParam := nd_exp_s.c_exp_s.as_list;
    while not IS_EMPTY(CurrParam) loop
        CompileExpression(HEAD(CurrParam));
        CurrParam := TAIL(CurrParam);
    end loop;
end LoadParams;

procedure Expr_used_bltn_op(t_function_call: TREE) is
    nd_function_call, nd_used_bltn_op: NODE;
    aCT: aCodeTypes;
begin
    GET_NODE(t_function_call, nd_function_call);
        GET_NODE( nd_function_call.C_FUNCTION_CALL.as_name, nd_used_bltn_op);
        LoadParams( nd_function_call.C_FUNCTION_CALL.sm_normalized_param_s);
        aCT := aCodeType( nd_function_call.C_FUNCTION_CALL.sm_normalized_param_s);

    case nd_used_bltn_op.C_USED_BLTN_OP.sm_operator is
        when op_and =>
            GenO(aAND);
        when op_div =>
            GenOT(aDIV, aCT);
        when op_eg =>
            GenOT(aEQU, aCT);
        when op_exp =>
            GenOT(aE, aCT);
        when op_ge =>
            GenOT(aGEQ, aCT);
        when op_gt =>
            GenOT(aGRE, aCT);
        when op_le =>
            GenOT(aLEQ, aCT);
        when op_lt =>
            GenOT(aLES, aCT);
        when op_minus =>
            GenOT(aSUB, aCT);
        when op_mod =>
            GenOT(aMOD, aCT);
        when op_mult =>
            GenOT(aMUL, aCT);
        when op_ne =>
            GenOT(aNEQ, aCT);
        when op_not =>
            GenO(aNOT);
        when op_or =>
            GenO(aORR);
        when op_plus =>
            GenOT(aADD, aCT);
        when op_rem =>
            GenOT(aREM, aCT);
        when op_unary_minus =>
                Gen1NumT(aLDC, aCT, 0);
                GenOT(aSWP, aCT);
                GenOT(aSUB, aCT);
        when op_unary_plus =>
            null;
        when op_xor =>
            GenO(aXOR);
        when others =>
            GeneralInternalError;
    end case;
end Expr_used_bltn_op;

procedure Expr_allocator(t_allocator: TREE) is
    nd_allocator: NODE;
begin
    GET_NODE(t_allocator, nd_allocator);
        LoadTypeSize( nd_allocator.C_ALLOCATOR.as_exp_constrained);
        Gen1Num(aALO, Level - LevelOfType( nd_allocator.C_ALLOCATOR.sm_exp_type));
end Expr_allocator;

procedure Expr_binary(t_binary: TREE) is
    nd_binary: NODE;
    Lbl1, Lbl2: LabelType;
    TempVal: Value;
begin
    Lbl1 := NextLabel;
    Lbl2 := NextLabel;
    GET_NODE(t_binary, nd_binary);
        CompileExpression( nd_binary.C_BINARY.as_exp1);
        case nd_binary.C_BINARY.as_binary_op is
            when AND_THEN =>
                Gen1Lb1(aFJP, Lbl1);
            when OR_ELSE =>
                Gen1Lbl(aTJP, Lbl1);
        when others =>
            GeneralInternalError;
        end case;
        CompileExpression( nd_binary.C_BINARY.as_exp2);
        Gen1Lbl(aUJP, Lbl2);
        WriteLabel(Lbl1);
        TempVal.boo_val := nd_binary.C_BINARY.as_binary_op = OR_ELSE;
        Gen1T(aLDC, a_B, TempVal);
        WriteLabel(Lbl2);
end Expr_binary;

procedure Expr_function_call_used_name_id(t_function_call: TREE) is
    nd_function_call, nd_used_name_id, nd_function_id: NODE;
begin
    GET_NODE(t_function_call, nd_function_call);
    GET_NODE(nd_function_call.c_function_call.as_name, nd_used_name_id);
    GET_NODE(nd_used_name_id.c_used_name_id.sm_defn, nd_function_id);
         Gen2NumNum(aMST, nd_function_id.C_FUNCTION_ID.cd_result_size, Succ(Level - nd_function_id.C_FUNCTION_ID.cd_level));
        LoadParams(nd_function_call.c_function_call.sm_normalized_param_s);
        Comment := GetSymbol( nd_function_id.C_FUNCTION_ID.lx_symrep);
        Gen2NumLbl(aCUP, nd_function_id.C_FUNCTION_ID.cd_param_size, nd_function_id.C_FUNCTION_ID.cd_label);

    case KIND(nd_function_call.c_function_call.sm_exp_type) is
        when integer =>
            if nd_function_call.c_function_call.sm_exp_type /= STD_INTEGER then
                declare
                    CompUnitNr: Byte;
                    Lvl: Level_Type;
                    Offs: Offset_Type;
                begin
                    GetCLO(nd_function_call.c_function_call.sm_exp_type, CompUnitNr, Lvl, Offs);
                    GenLoadAddr(CompUnitNr, Lvl, Offs);
                    GenCSP(aCVB);
					end;
					end if;
        when others =>
            GeneralInternalError;
    end case;
end Expr_function_call_used_name_id;

procedure Expr_function_call(t_function_call: TREE) is
    nd_function_call: NODE;
begin
    GET_NODE(t_function_call, nd_function_call);
    case KIND(nd_function_call.c_function_call.as_name) is
        when used_bltn_op =>
            Expr_used_bltn_op(t_function_call);
        when used_name_id =>
            Expr_function_call_used_name_id(t_function_call);
        when others =>
            GeneralInternalError;
    end case;
end Expr_function_call;

procedure Expr_indexed(t_indexed: TREE) is
    nd_indexed: NODE;
begin
    GET_NODE(t_indexed, nd_indexed);
    LoadAddress_indexed(t_indexed);
    case KIND(nd_indexed.c_indexed.sm_exp_type) is
        when n_access =>
            Gen1NumT(aIND, a_A, 0);
        when enum_literal_s | integer =>
            Gen1NumT(aIND, a_I, 0);
        when others =>
            GeneralInternalError;
    end case;
end Expr_indexed;

procedure Expr_used_object_id_def_char(t_def_char: TREE) is
    nd_def_char: NODE;
begin
    GET_NODE(t_def_char, nd_def_char);
    Gen1NumT(aLDC, a_I, nd_def_char.c_def_char.sm_rep);
end Expr_used_object_id_def_char;

procedure Expr_used_object_id_enum_id(t_enum_id: TREE) is
    nd_enum_id: NODE;
begin
    GET_NODE(t_enum_id, nd_enum_id);
    Gen1NumT(aLDC, a_I, nd_enum_id.c_enum_id.sm_rep);
end Expr_used_object_id_enum_id;

procedure Expr_used_object_id_in_out_id(t_in_out_id: TREE) is
    nd_in_out_id: NODE;
begin
    GET_NODE(t_in_out_id, nd_in_out_id);
        case KIND(sm_obj_type) is
            when n_access =>
                GenLoad(a_A, 0, nd_in_out_id.C_IN_OUT_ID.CD_LEVEL, nd_in_out_id.C_IN_OUT_ID.cd_val_offset);
            when n_array =>
                     GenLoadAddr(0, nd_in_out_id.C_IN_OUT_ID.cd_level, nd_in_out_id.C_IN_OUT_ID.cd_val_offset);
                    Gen1Num(aGET, AddrSize + AddrSize);
            when enum_literal_s =>
                if BooleanType( nd_in_out_id.C_IN_OUT_ID.sm_obj_type) then
                    GenLoad( a_B, 0, nd_in_out_id.C_IN_OUT_ID.cd_level, nd_in_out_id.C_IN_OUT_ID.CD_VAL_OFFSET );
                elsif CharacterType( nd_in_out_id.C_IN_OUT_ID.sm_obj_type) then
                    GenLoad( a_C, 0, nd_in_out_id.C_IN_OUT_ID.cd_level, nd_in_out_id.C_IN_OUT_ID.CD_VAL_OFFSET );
                else
					GenLoad ( a_I, 0, nd_in_out_id.C_IN_OUT_ID.cd_level, nd_in_out_id.C_IN_OUT_ID.CD_VAL_OFFSET );
					end if;
            when integer =>
                GenLoad( a_I, 0, nd_in_out_id.C_IN_OUT_ID.cd_level, nd_in_out_id.C_IN_OUT_ID.CD_VAL_OFFSET );
            when others =>
                GeneralInternalError;
        end case;
end Expr_used_object_id_in_out_id;

procedure Expr_used_object_id_out_id(t_out_id: TREE) is
    nd_out_id: NODE;
begin
    GET_NODE(t_out_id, nd_out_id);
        case KIND( nd_out_id.C_OUT_ID.sm_obj_type) is
            when n_access =>
                GenLoad(a_A, 0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
            when n_array =>
                begin
                    GenLoadAddr(0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
                    Gen1Num(aGET, AddrSize + AddrSize);
                end;
            when enum_literal_s =>
                if BooleanType( nd_out_id.C_OUT_ID.sm_obj_type) then
                    GenLoad(a_B, 0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
                elsif CharacterType( nd_out_id.C_OUT_ID.sm_obj_type) then
                    GenLoad(a_C, 0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
                else
					GenLoad (a_I, 0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
					end if;
            when n_integer =>
                GenLoad(a_I, 0, nd_out_id.C_OUT_ID.cd_level, nd_out_id.C_OUT_ID.cd_val_offset);
            when OTHERS =>
                GeneralInternalError;
        end case;
end Expr_used_object_id_out_id;

procedure Expr_used_object_id_iteration_id(t_iteration_id: TREE) is
    nd_iteration_id: NODE;
begin
    GET_NODE(t_iteration_id, nd_iteration_id);
        case KIND( nd_iteration_id.C_ITERATION_ID.sm_obj_type) is
            when enum_literal_s =>
                if BooleanType( nd_iteration_id.C_ITERATION_ID.sm_obj_type) then
                    GenLoad(a_B, 0, nd_iteration_id.C_ITERATION_ID.cd_level, nd_iteration_id.C_ITERATION_ID.cd_offset);
                elsif CharacterType( nd_iteration_id.C_ITERATION_ID.sm_obj_type) then
                    GenLoad(a_C, 0, nd_iteration_id.C_ITERATION_ID.cd_level, nd_iteration_id.C_ITERATION_ID.cd_offset);
                else
					GenLoad (a_I, 0, nd_iteration_id.C_ITERATION_ID.cd_level, nd_iteration_id.C_ITERATION_ID.cd_offset);
					end if;
            when n_integer =>
                GenLoad(a_I, 0, nd_iteration_id.C_ITERATION_ID.cd_level, nd_iteration_id.C_ITERATION_ID.cd_offset);
            when others =>
                GeneralInternalError;
        end case;
end Expr_used_object_id_iteration_id;

procedure Expr_used_object_id_const_id(t_const_id: TREE) is
    nd_const_id: NODE;
begin
    GET_NODE(t_const_id, nd_const_id);
         case KIND( nd_const_id.C_CONST_ID.sm_obj_type) is
            when n_access =>
                GenLoad(a_A, nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
            when n_array =>
                    GenLoadAddr(nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
                    Gen1Num(aGET, AddrSize + AddrSize);
            when enum_literal_s =>
                if BooleanType( nd_const_id.C_CONST_ID.sm_obj_type) then
                    GenLoad(a_B, nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
                elsif CharacterType( nd_const_id.C_CONST_ID.sm_obj_type) then
                    GenLoad(a_C, nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
                else
							GenLoad (a_I, nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
							end if;
            when n_integer =>
                if sm_obj_type = STD_INTEGER then
                    GenLoad(a_I, nd_const_id.C_CONST_ID.CD_COMP_UNIT, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
                else
                    GenLoad(a_I, nd_const_id.C_CONST_ID.cd_comp_unit, nd_const_id.C_CONST_ID.cd_level, nd_const_id.C_CONST_ID.cd_offset);
                    declare
                        CompUnitNr: Byte;
                        Lvl: Level_Type;
                        Offs: Offset_Type;
                    begin
                        GetCLO( nd_const_id.C_CONST_ID.sm_obj_type, CompUnitNr, Lvl, Offs);
                        GenLoadAddr(CompUnitNr, Lvl, Offs);
                        GenCSP(aCVB);
                    end;
                end if;
            when others =>
                GeneralInternalError;
        end case;
end Expr_used_object_id_const_id;

procedure Expr_used_object_id_var_id(t_var_id: TREE) is
    nd_var_id: NODE;
begin
    GET_NODE(t_var_id, nd_var_id);
        case KIND( nd_var_id.C_VAR_ID.SM_OBJ_TYPE ) is
            when n_access =>
                GenLoad(a_A, nd_var_id.C_VAR_ID.cd_comp_unit, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.CD_OFFSET );
            when n_array =>
                    GenLoadAddr( nd_var_id.C_VAR_ID.cd_comp_unit, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.CD_OFFSET );
                    Gen1Num(aGET, AddrSize + AddrSize);
            when enum_literal_s =>
                if BooleanType( nd_var_id.C_VAR_ID.sm_obj_type) then
                    GenLoad(a_B, nd_var_id.C_VAR_ID.CD_COMP_UNIT, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.cd_offset);
                elsif CharacterType( nd_var_id.C_VAR_ID.sm_obj_type) then
                    GenLoad(a_C, nd_var_id.C_VAR_ID.CD_COMP_UNIT, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.cd_offset);
                else
					GenLoad (a_I, nd_var_id.C_VAR_ID.cd_comp_unit, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.cd_offset);
					end if;
            when n_integer =>
                if sm_obj_type = STD_INTEGER then
                    GenLoad(a_I, nd_var_id.C_VAR_ID.cd_comp_unit, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.cd_offset);
                else
                    GenLoad(a_I, nd_var_id.C_VAR_ID.cd_comp_unit, nd_var_id.C_VAR_ID.cd_level, nd_var_id.C_VAR_ID.cd_offset);
                    declare
                        CompUnitNr: Byte;
                        Lvl: Level_Type;
                        Offs: Offset_Type;
                    begin
                        GetCLO(sm_obj_type, CompUnitNr, Lvl, Offs);
                        GenLoadAddr(CompUnitNr, Lvl, Offs);
                        GenCSP(aCVB);
                    end;
                end if;
            when others =>
                GeneralInternalError;
        end case;
end Expr_used_object_id_var_id;

procedure Expr_used_object_id (t_used_object_id : Tree) is
   nd_used_object_id : Node;
   TempVal : Value;
begin
   GET_NODE (t_used_object_id, nd_used_object_id);
   TempVal := nd_used_object_id.c_used_object_id.sm_value;
   Comment := GetSymbol (lx_symrep);

   case TempVal.v_type is
      when bool_value =>
         Gen1T (aLDC, a_B, TempVal);
      when char_value =>
         Gen1T (aLDC, a_C, TempVal);
      when int_value =>
         Gen1T (aLDC, a_I, TempVal);
      when no_value =>
             case KIND( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN ) is
              when CONST_ID =>                  Expr_used_object_id_const_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when DEF_CHAR =>                  Expr_used_object_id_def_char ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when ENUM_ID =>                  Expr_used_object_id_enum_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when IN_ID =>                  Expr_used_object_id_in_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when IN_OUT_ID =>                  Expr_used_object_id_in_out_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when ITERATION_ID =>                  Expr_used_object_id_iteration_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when OUT_ID =>                  Expr_used_object_id_out_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
              when VAR_ID =>                  Expr_used_object_id_var_id ( nd_used_object_id.C_USED_OBJECT_ID.SM_DEFN );
               when others =>
                  GeneralInternalError;
            end case;
       when others =>
         GeneralInternalError;
   end case;
end Expr_used_object_id;

procedure CompileExpression(t_expr:in TREE) is
nd : NODE;

begin
  GET_NODE(t_expr, nd);
  case KIND(t_expr) is
  when ALLOCATOR => Expr_allocator(t_expr);
  when BINARY => Expr_binary(t_expr);
  when FUNCTION_CALL  => Expr_function_call(t_expr);
  when INDEXED => Expr_indexed(t_expr);
  when NUMERIC_LITERAL =>Gen1T(aLDC, a_I, nd.C_NUMERIC_LITERAL.sm_value);
  when PARENTHESIZED => CompileExpression(nd.C_PARENTHESIZED.as_exp);
  when USED_OBJECT_ID => Expr_used_object_id(t_expr);
  when others => GeneralInternalError;
  end case;
end CompileExpression;


end CG_Expr;
