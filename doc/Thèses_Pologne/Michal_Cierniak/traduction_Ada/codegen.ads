-- Specification of CodeGen module

with CG_Lib;
with cg_Private;
with CG1;
with Diana;
with CG_Expr;
with CG_Decl;
with CG_Param;

package CodeGen is

   procedure CodeGenerator(Root : CG_Lib.TREE; FileName : String);

private

   VerNr : constant String := "0.1";

   PKG_STANDARD : constant := 6;

   UnitName : String(1 .. 255);
   CurrCompUnit : CG_Lib.SEQ_TYPE;
   Nd : CG_Lib.NODE;
   t_function_result : CG_Lib.TREE;
   fun_result_offset : CG_Lib.OffsetType;

   procedure ConditionalError(ErrorCode : Integer; Condition : Boolean);
   procedure GeneralInternalError;
   procedure Init;
   procedure CompileExceptionHandlers(Alternative_s, EnclosingProc : CG_Lib.TREE);
   procedure CompileFunction(t_subprogram_body : CG_Lib.TREE; StartLabel : CG_Lib.LabelType);
   procedure CompileProcedure(t_subprogram_body : CG_Lib.TREE; StartLabel : CG_Lib.LabelType);
   procedure CompileStatement(Stm, EnclosingProc : CG_Lib.TREE);
   procedure CompileStatements(Stm_s, EnclosingProc : CG_Lib.TREE);
   procedure CompileSubpBlock(Block, EnclosingProc, Params : CG_Lib.TREE; ParamSize : CG_Lib.OffsetType);
   procedure CompileDecl_subprogram_body(t_subprogram_body : CG_Lib.TREE);

end CodeGen;
