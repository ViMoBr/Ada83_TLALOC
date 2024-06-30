with CG_Lib;
with CG_Private;
with CG1;
with Diana;
with CG_Expr;

package CG_Decl is

   procedure CompileDecl_constant(t_constant: TREE);
   procedure CompileDecl_type(t_type: TREE);
   procedure CompileDecl_var(Variable: TREE);

private

   DimensionsNr : Byte;

   procedure ConditionalError(ErrorCode: Integer; Condition: Boolean);
   procedure GenerallnternalError;
   procedure CompileBoolConst(t_const_id: TREE);
   procedure CompileCharConst(t_const_id: TREE);
   procedure CompileEnumConst(t_const_id, t_type_spec: TREE);
   procedure CompileIntegerConst(t_const_id: TREE);
   procedure CompileConst(t_const_id, t_type_spec: TREE);
   procedure CompileAccessVar(t_var_id, t_type_spec: TREE);
   procedure CompileArrayVar(t_var_id, t_type_spec: TREE);
   procedure CompileBoolVar(t_var_id, t_type_spec: TREE);
   procedure CompileCharVar(t_var_id, t_type_spec: TREE);
   procedure CompileEnumVar(t_var_id, t_type_spec: TREE);
   procedure CompileIntegerVar(t_var_id, t_type_spec: TREE);
   procedure CompileVar(t_var_id, t_type_spec: TREE);
   procedure CompileType_access(t_type: TREE);
   procedure CompileType_Array_Dimension(Dim: SEQ_TYPE; ElType: TREE);
   procedure CompileType_array(t_type: TREE);
   procedure CompileType_enum_literal_s(t_type: TREE);
   procedure CompileType_integer(t_type: TREE);
   procedure CompileDecl_type(t_type: TREE);

end CG_Decl;

