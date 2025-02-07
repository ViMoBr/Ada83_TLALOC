unit CodeGen;
{Main procedure of the code generator.}
interface
uses CG1,
CG_Expr,
CG_Dec1,
CG_Lib,
CG_Param,
Diana,
Private;
{Genarate a-code for compi1ation referenced by 'Root'.
The code is written to a file 'FileName'. }
procedure CodeGenerator(Root: TREE; FileName: String);
{-------------------------------------------------------------}
implementation
procedure CodeGenerator(Root: TREE; FileName: String);
const
VerNr = '0.1';
{DIANA node numbers:}
PKG_STANDARD = 6;
var
UnitName                          :   String;
CurrCompUnit                  :   SEQ_TYPE;
Nd                                      :   NODE;
t_function_result         :   TREE;
fun_result_offset         :   OffsetType;
procedure ConditionalError(ErrorCode:integer; Condition: Boolean);
begin {ConditionalError}
if Condition then
begin
WriteComment;
CloseOutputFile;
Error(ErrorCode);
end;
end; {ConditionalError}
procedure GeneralInternalError;
begin {GeneralInternalError}
ConditionalError(999, true);
end; {GeneralInternalError}
procedure 1nit;
begin
Comment       := '';
TopAct         := 0;
TopMax         := 0;
OffsetAct   := 0;
OffsetMax   := 0;
Level    := 0;
GenerateCode := true;
t_function_result := NULL_TREE;
end; {lnit}
{-------------------------------------------------------------}
{Forward declarations:}
procedure CompileExceptionHandlers(Alternative_s, EnclosingProc: TREE);
forward;
procedure CompileFunction(t_subprogram_body: TREE; StartLabel: LabelType);
forward;
procedure CompileProcedure(t_subprogram_body: TREE; StartLabel: LabelType);
forward;
procedure CompileStatement(Stm, EnclosingProc: TREE);
forward;
procedure CompileStatements(Stm_s, EnclosingProc: TREE);
forward;
procedure CompileSubpBlock(Block, EnclosingProc, Params: TREE;
ParamSize: OffsetType);
forward;
{-------------------------------------------------------------}
{Routines for compiling declarations:}
procedure CompileDecl_subprogram_body(t_subprogram_body: TREE);
var
nd_subprogram_body, nd_designator : NODE;
SkipLbl                         : LabelType;
begin {CompileDecl_subprogram_body}
SkipLbl := NextLabel;
Gen1Lbl(aUJP, SkipLbl);
GET_NODE(t_subprogram_body, nd_subprogram_body);
GET_NODE(nd_subprogram_body.c_subprogram_body^.as_designator, nd_designato^
case KIND(nd_subprogram_body.c_subprogram_body^.as_header) of
_function :
begin
GET_NODE(nd_designator.c_function_id^.sm_first, nd_designator);
with nd_designator.c_function_id^ do
if cd_compiled then
CompileFunction(t_subprogram_body, cd_1abe1)
else
CompileFunction(t_subprogram_body, NextLabel);
end;
_procedure :
begin
GET_NODE(nd_designator.c_proc_id^.sm_first, nd_designator);
with nd_designator.c_proc_id^ do
if cd_compiled then
CompileProcedure(t_subprogram_body, cd_label)
else
CompileProcedure(t_subprogram_body, NextLabel);
end;
else
GeneralInternalError;
end;
WriteLabel(SkipLbl);
end; {CompileDecl_subprogram_body}
procedure CompileDecl_subprogram_decl(t_subprogram_decl: TREE);
var
nd_subprogram_decl, nd_designator,
nd_header, nd_param_s                            : NODE;
OldOffsetAct, OldOffsetMax       : OffsetType;
begin {CompileDecl_subprogram_decl}
OldOffsetMax := OffsetMax;
OldOffsetAct := OffsetAct;
OffsetMax   := FirstParamOffset;
OffsetAct   := FirstParamOffset;
IncrementLevel;
GET_NODE(t_subprogram_decl, nd_subprogram_decl);
with nd_subprogram_ded.c_subprogram_ded^ do
begin
GET_NODE(as_designator, nd_designator);
GET_NODE(as_header, nd_header);
end;
case KlND(nd_subprogram_decl.c_subprogram_decl^.as_designator) of
_proc_id :
begin
with nd_designator.c_proc_id do
begin
cd_label   := NextLabel;
cd_level   := Level;
cd_compiled := true;
if not GenerateCode then
begin
GenerateCode := true;
Comment := 'procedure ' + GetSymbol(lx_symrep);
Gen1Lb1(aRFL, cd_label);
GenerateCode := false;
GET_NODE(nd_header.c_procedure^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s^ .as_list);
end
else
begin
GET_NODE(nd_header.c_procedure^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s^.as_list);
end;
cd_param_size := OffsetAct - FirstParamOffset;
end;
end;
_function_id :
begin
with nd_designator.c_function_id^ do
begin
cd_label   := NextLabel;
cd_level   := Level;
cd_compiled := true;
if not GenerateCode then
begin
GenerateCode := true;
Comment := 'function ' + GetSymbol(lx_symrep);
Gen1Lbl(aRFL, cd_label);
GenerateCode := false;
GET_NODE(nd_header.c_function^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s^ .as_list);
end
else
begin
GET_NODE(nd_header.c_function^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s ^.as_list);
end;
cd_param_size := OffsetAct - FirstParamOffset;
cd_result_size := TypeSize(nd_header.c_function' '.as_name_void);
end;
end;
else
GeneralInternalError;
end;
DecrementLevel;
OffsetMax := OldOffsetMax;
OffsetAct := OldOffsetAct;
end; {CompileDecl_subprogram_decl}
procedure CompileDecl_exception(t_exception: TREE);
var
nd_exception, nd_id_s,
nd_exception_id      : NODE;
CurrException        : SEQ_TYPE;
OldGenerateCode      : Boolean;
begin {CompileDecl_exception}
OldGenerateCode := GenerateCode;
GenerateCode   := true;
GET_NODE(t_exception, nd_exception);
GET_NODE(nd_exception.c_exception^.as_id_s, nd_id_s);
CurrException := nd_id_s.c_id_s^.as_list;
while not IS_EMPTY(CurrException) do
begin
GET_NODE(HEAD(CurrException), nd_exception_id);
with nd_exception_id.c_exception_id^ do
begin
cd_label := NextLabel;
Gen2LblStr(aEXL, cd_label, GetSymbol(lx_symrep));
end;
CurrException := TAIL(CurrException);
end;
GenerateCode := OldGenerateCode;
end; {CompileDecl_exception}



procedure CompileDeclaration(Declaration: TREE);
begin {CompileDeclaration}
case KIND(Declaration) of
_constant      : CompileDecl_constant(Declaration);
_exception      : CompileDecl_exception(Declaration);
_number        : ; {do nothing}
_subprogram_decl : CompileDecl_subprogram_decl(Declaration);
_subprogram_body : CompileDecl_subprogram_body(Declaration);
_type                        : CompileDecl_type(Declaration);
_var                          : CompileDecl_var(Declaration);
else
ConditionalError(999, true);
end;
end; {CompileDeclaration}
procedure CompileDeclarations(Declarations: TREE);
var
nd_item_s      : NODE;
CurrDeclaration : SEQ_TYPE;
begin {CompileDeclarations}
GET_NODE(Declarations, nd_item_s>;
CurrDeclaration := nd_item_s.c_item_s^.as_list;
while not IS_EMPTY(CurrDeclaration) do
begin
CompileDeclaration(HEAD(CurrDeclaration));
CurrDeclaration := TAIL(CurrDeclaration);
end;
end; {CompileDeclarations}
{-------------------------------------------------------------}
{Routines for compiling subprogram bodies declarations:}
procedure InitializeFunctionResult;
var
nd : NODE;
begin {lnitializeFunctionResult}
GET_NODE(t_function_result, nd);
case KIND(t_function_result) of
_array :
begin
with Nd.c_array^ do
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
GenOT(aDPL, a_A);
Gen2NumNumT(aSTR, a_A, 0, fun_result_offset - AddrSize);
Gen1NumT(alND, a_I, 0);
Gen1Num(aALO, ^1);
Comment := 'resu1t array';
Gen2NumNumT(aSTR, a_A, 0, fun_result_offset);
end;
end;
t_function_result := NULL_TREE;
end; {lnitializeFunctionResu1t}



procedure Compi1eSubpB1ock(B1ock, Enc1osingProc, Params: TREE; ParamSize:
OffsetType);
var
ExcLb1,
ENT1Lbl, ENT2Lb1    : Labe1Type;
O1dTopAct, O1dTopMax : OffsetType;
nd_b1ock                          : NODE;
begin {CompileSubpBlock}
OldTopMax   := TopMax;
OldTopAct   := TopAct;
TopMax      := 0;
TopAct      := 0;
GET_NODE(Block, nd_block);
with nd_block.c_block do
begin
cd_level       := Level;
cd_return_label := NextLabel;
end;
ENT1Lbl := NextLabel;
ENT2Lbl := NextLabel;
Gen2NumLbl(aENT, 1, ENT1Lb1);
Gen2NumLb1(aENT, 2, ENT2Lbl);
if t_function_result <> NULL_TREE then
InitializeFunctionResult;
CompileDeclarations(nd_block.c_block^.as_item_s);
ExcLbl := NextLabel;
Comment := 'begin';
Gen1Lb1(aE)(H, ExcLbl);
CompileStatements(nd_block.c_block^.as_stm_s, Enc1osingProc);
Comment := 'copy out';
WriteLabel(nd_block.c_block^.cd_return_label);
CopyOutParams(Params);
Gen1Num(aRET, ParamSize);
WriteLabel(ExcLbl);
with nd_block.c_block^ do
CompileExceptionHandlers(as_alternative_s, EnclosingProc);
GenLabelAssignment(ENT1Lb1, OffsetMax);
GenLabe1Assignment(ENT2Lb1, OffsetMax + TopMax);
TopMax   := OldTopMax;
TopAct   := OldTopAct;
end; {CompileSubpBlock}
{-------------------------------------------------------------}
procedure CompileProcedure(t_subprogram_body: TREE; StartLabel: LabelType);
var
nd_subprogram_body,
nd_proc_id,
nd_procedure, nd_param_s,
Nd                                                  : NODE;
OldOffsetAct, OldOffsetMax : OffsetType;
begin {CompileProcedure}
OldOffsetMax := OffsetMax;
OldOffsetAct := OffsetAct;
OffsetMax   := FirstParamOffset;
OffsetAct   := FirstParamOffset;
IncrementLevel;
GET_NODE(t_subprogram_body, nd_subprogram_body);
GET_NODE(nd_subprogram_body.c_subprogram_body^.as_designator, nd_proc_id);
with nd_proc_id.c_proc_id^ do
begin
cd_label := StartLabel;
cd_level := Level;
end;
PUT_NODE(nd_subprogram_body.c_subprogram_body^.as_designator, nd_proc_id);
Comment :^ 'procedure ' + GetSymbol(nd_proc_id.c_proc_id^.lx_symrep);
WriteLabel(StartLabel);
GET_NODE(nd_proc_id.c_proc_id^.sm_spec, nd_procedure);
GET_NODE(nd_procedure.c_procedure^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s^.as_list);
nd_proc_id.c_proc_id^.cd_param_size := OffsetAct ^ FirstParamOffset +
RelativeResultOffset;
OffsetMax   := FirstLocalVarOffset;
OffsetAct   := FirstLocalVarOffset;
with nd_subprogram_body.c_subprogram_body do
CompileSubpBlock(as_block_stub, as_block_stub,
nd_procedure.c_procedure^.as_param_s,
nd_proc_id.c_proc_id^.cd_param_size);
DecrementLevel;
OffsetMax := OldOffsetMax;
OffsetAct := OldOffsetAct;
Comment :^ 'end ' + GetSymbol(nd_proc_id.c_proc_id^ .lx_symrep);
end; {CompileProcedure}
procedure CompileFunction(t_subprogram_body: TREE; StartLabel: LabelType);
var
nd_subprogram_body, nd_function_id,
nd_function, nd_param_s,
nd_block, Nd                                                  : NODE;
OldOffsetAct, OldOffsetMax                      : OffsetType;
begin {CompileFunction}
OldOffsetMax := OffsetMax;
OldOffsetAct := OffsetAct;
OffsetMax   := FirstParamOffset;
OffsetAct   := FirstParamOffset;
IncrementLevel;
GET_NODE(t_subprogram_body, nd_subprogram_body);
GET_NODE(nd_subprogram_body.c_subprogram_body^.as_designator, nd_function_
with nd_function_id.c_function_id^ do
begin
cd_label := StartLabel;
cd_level := Level;
Comment := 'function ' + GetSymbol(lx_symrep);
WriteLabel(StartLabel);
GET_NODE(sm_spec, nd_function);
end;
GET_NODE(nd_function.c_function^.as_param_s, nd_param_s);
CompileParams(nd_param_s.c_param_s^.as_list);
IncrementOffset(RelativeResultOffset);
with nd_function_id.c_function_id^ do
begin
cd_param_size := OffsetAct - FirstParamOffset;
cd_result_size := TypeSize(nd_function.c_function^.as_name_void);
IncrementOffset(cd_result_size);
end;
Align(StackAl);
GET_NODE(nd_subprogram_body.c_subprogram_body^.as_block_stub, nd_block);
nd_block.c_block ^.cd_result_offset := OffsetAct;
fun_result_pffset := OffsetAct;
t_function_result := TypeStruct(nd_function.c_function^.as_name_void);
OffsetMax   := FirstLocalVarOffset;
OffsetAct   := FirstLocalVarOffset;
with nd_subprogram_body.c_subprogram_body^ do
CompileSubpBlock(as_block_stub, as_block_stub,
nd_function.c_function^.as_param_s,
nd_function_id.c_function_id^.cd_param_size);
DecrementLevel;
OffsetMax := OldOffsetMax;
OffsetAct := OldOffsetAct;
Comment := 'end ' + GetSymbol(nd_function_id.c_function_id^.lx_symrep);
end; {CompileFunction}
{Routines for compiling statements:}
function NumberOfDimensions(t: TREE): Byte;
var
nd : NODE;
begin {NumberOfDimensions}
GET_NODE(t, nd);
case KIND(t) of
_array :
NumberOfDimensions := nd.c_array^.cd_dimensions;
_constrained :
NumberOfDimensions :=
NumberOfDimensions(nd.c_constrained^.sm_type_struct);
_function_call :
NumberOfDimensions :=
NumberOfDimensions(nd.c_function_call^.sm_exp_type);
_used_object_id :
NumberOfDimensions :=
NumberOfDimensions(nd.c_used_object_id^.sm_exp_type);
else
GeneralInternalError;
end;
end; {NumberOfDimensions}
procedure StoreVal(t_type: TREE);
var
nd : NODE;
begin {StoreVal}
case KIND(t_type) of
_access:
GenOT(aSTO, a_A);
_enum_literal_s:
if BooleanType(t_type) then
GenOT(aSTO, a_B)
else if CharacterType(t_type) then
GenOT(-STO, a_C)
else
GenOT(aSTO, a_I);
_integer:
begin
if t_type <> STD_INTE-ER then
begin
GET_NODE(t_type, nd);
with nd.c_integer^ do
begin
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
GenCSP(aCVB);
end;
end;
GenOT(aSTO, a_l)
end;
else
GeneralInternalError;
end;
end; {StoreVal}
procedure CompileAssign_all(t_name, t_exp: TREE);
var
nd, nd_all, nd_exp : NODE;
CompUnitNr                                        : Byte;
Lvl                                                      : LevelType;
Offs                                                    : OffsetType;
begin {CompileAssign_all}
GET_NODE(t_name, nd_all);
LoadAddress(nd_all.c_all^.as_name);
Comment := ':=';
WriteComment;
CompileExpression(t_exp);
StoreVal(nd_all.c_all^.sm_exp_type);
end; {CompileAssign_all}
procedure CompileAssign_indexed(t_name, t_exp: TREE);
var
nd, nd_indexed, nd_exp : NODE;
CompUnitNr                                        : Byte;
Lvl                                                      : LevelType;
Offs                                                    : OffsetType;
begin {CompileAssign_indexed}
GET_NODE(t_name, nd_indexed);
LoadAddress_indexed(t_name);
Comment := ':=';
WriteComment;
CompileExpression(t_exp);
StoreVal(nd_indexed.c_indexed^.sm_exp_type);
end; {CompileAssign_indexed}
procedure CompileAssign_used_object_id(t_name, t_exp: TREE);
var
nd, nd_used_object_id, nd_exp : NODE;
CompUnitNr                                        : Byte;
Lvl                                                      : LevelType;
Offs                                                    : OffsetType;
begin {CompileAssign_used_object_id}
GET_NODE(t_name, nd_used_object_id);
case KIND(nd_used_object_id.c_used_object_id^.sm_exp_type) of
_access :
begin
CompileExpression(t_exp);
with nd_used_object_id.c_used_object_id do
begin
GetCLO(sm_defn, CompUnitNr, Lvl, Offs);
Comment := GetSymbol(lx_symrep);
end;
GenStore(a_A, CompUnitNr, Lvl, Offs);
end;
_array :
begin
LoadObjectAddress(nd_used_object_id.c_used_object_id^.sm_defn);
if KIND(t_exp) = _used_object_id then
begin
LoadObjectAddress(t_exp);
Comment := '^ of dimensions';
with nd_used_object_id.c_used_object_id^ do
Gen1NumT(aLDC, a_I, NumberOfDimensions(sm_exp_type));
GenCSP(aCYA);
end
else
begin
CompileExpression(t_exp);
Comment := '^ of dimensions';
with nd_used_object_id.c_used_object_id^ do
Gen1NumT(aLDC, a_I, NumberOfDimensions(sm_exp_type));
GenCSP(aPUA);
end;
end;
_enum_1itera1_s :
begin
CompileExpression(t_exp);
with nd_used_object_id.c_used_object_id^ do
begin
GetCLO(sm_defn, CompUnitNr, Lvl, Offs);
Comment :^ GetSymbol(lx_symrep);
if BooleanType(sm_exp_type) then
GenStore(a_B, CompUnitNr, Lvl, Offs)
else if CharacterType(sm_exp_type) then
GenStore(a_C, CompUnitNr, Lvl, Offs)
else
GenStore(a_I, CompUnitNr, Lvl, Offs);
end;
end;
_integer :
begin
CompileExpression(t_exp);
with nd_used_object_id.c_used_object_id^ do
begin
if sm_exp_type <> STD_INTEGER then
begin
GetCLO(sm_exp_type, CompUnitNr, Lvl, Offs);
GenLoadAddr(CompUnitNr, Lvl, Offs);
GenCSP(aCVB);
end;
GetCLO(sm_defn, CompUnitNr, Lvl, Offs);
Comment := GetSymbol(lx_symrep);
end;
GenStore(a_I, CompUnitNr, Lvl, Offs);
end;
else
GenerallnternalError;
end;
end; {CompileAssign_used_object_id}
procedure CompileStm_Assign(Stm: TREE);
var
nd_assign : NODE;
begin {CompileStm_Assign}
Comment := 'assign';
WriteComment;
GET_NODE(Stm, nd_assign);
with nd_assign.c_assign^ do
case KIND(as_name) of
_-ll :
CompileAssign_all(as_name, as_exp);
_indexed :
CompileAssign_indexed(as_name, as_exp);
_used_object_id :
CompileAssign_used_object_id(as_name, as_exp);
else
GenerallnternalError;
end;
end; {CompileStm_Assign}
procedure CompileStm_block(Stm, EnclosingProc: TREE);
var
nd_block      : NODE;
CurrCondClause : SEQ_TYPE;
ProcLbl,
AfterBlockLbl  : LabelType;
OldOffsetAct,
OldOffsetMax  : OffsetType;
begin {CompileStm_block}
AfterBlockLbl :- NextLabel;
ProcLbl      := NextLabel;
Gen2NumNum(aMST, 0, 0);
Gen2NumLbl(aCUP, RelativeResultOffset, ProcLbl);
Gen1Lbl(aUJP, AfterBlockLbl);
WriteLabel(ProcLbl);
OldOffsetAct := OffsetAct;
OldOffsetMax := OffsetMax;
OffsetAct   := FirstLocalVarOffset;
OffsetMax   := FirstLocalVarOffset;
IncrementLevel;
CompileSubpBlock(stm, EnclosingProc, NULL_TREE, RelativeResultOffset);
DecrementLevel;
OffsetAct := OldOffsetAct;
OffsetMax := OldOffsetMax;
GET_NODE(Stm, nd_block);
WriteLabel(AfterBlockLbl);
end; {CompileStm_block}
procedure CompileStm_exit(Stm: TREE);
var
nd_exit, nd_loop : NODE;
LVBlbl, SkipLbl  : LabelType;
begin {CompileStm_exit}
GET_NODE(Stm, nd_exit);
GET_NODE(nd_exit.c_exit^.sm_stm, nd_loop);
if nd_exit.c_exit^.as_exp_void = NULL_TREE then
begin
Comment := 'exit';
if nd_loop.c_loop^.cd_level <> Level then
begin
LVBlbl := NextLabel;
Gen1Lbl(aLVB, LVBlbl);
GenLabelAssignment(LVBlbl, Level - nd_loop.c_loop .cd_level);
end;
GenlLbl(aUJP, nd_loop.c_loop^.cd_after_loop_label);
end
else
begin
CompileExpression(nd_exit.c_exit^.as_exp_void);
Comment := 'exit';
if nd_loop.c_loop^.cd_level <> Level then
begin
SkipLbl := NextLabel;
Gen1Lbl(aFJP, SkipLbl);
LVBlbl  := NextLabel;
Gen1Lb1(aLVB, LVB1b1);
GenLabe1Assignment(LVB1bl, Level - nd_loop.c_loop^ .cd_level);
GenlLbl(aUJP, nd_loop.c_loop .cd_after_loop_label);
WriteLabel(SkipLbl);
end
else
Gen1Lb1(aTJP, nd_loop.c_loop^.cd_after_loop_label)
end;
end; {CompileStm_exit}
procedure CompileCondClause( t_cond_clause, EnclosingProc: TREE;
AfterlfLbl: LabelType);
var
nd_cond_clause : NODE;
t_^xp_void    ^ TREE;
NextClauseLbl  : LabelType;
begin {CompileCondClause}
GET_NODE(t_cond_clause, nd_cond_clause);
t_exp_void := nd_cond_clause.c_cond_clause^.as_exp_void;
if t_exp_void <> NULL_TREE then
begin
CompileExpression(t_exp_void);
NextClauseLbl := NextLabel;
Gen1Lbl(aFJP, NextClauseLbl);
end;
CompileStatements(nd_cond_clause.c_cond_clause^.as_stm_s, EnclosingProc);
if t_exp_void <> NULL_TREE then
begin
Gen1Lb1(aUJP, AfterlfLbl);
WriteLabel(NextClauseLbl);
end;
end; {CompileCondClause}
procedure CompileStm_If(Stm, EnclosingProc: TREE);
var
nd_if        : NODE;
CurrCondClause : SEQ_TYPE;
AfterlfLbl    : LabelType;
begin {CompileStm_If}
AfterlfLbl := NextLabel;
GET_NODE(Stm, nd_if);
CurrCondClause := nd_if.c_if^.as_list;
while not IS_EMPTY(CurrCondClause) do
begin
CompileCondClause(HEAD(CurrCondClause), EnclosingProc, AfterIfLbl);
CurrCondClause := TAIL(CurrCondClause);
end;
Comment := 'end if';
WriteLabel(AfterIfLbl);
end; {CompileStm_If}
procedure LoadTypeBounds(t_type_struct: TREE);
var
nd : NODE;
begin {LoadTypeBounds}
GET_NODE(t_type_struct, nd);
case KIND(t_type_struct) of
_enum_literal_s :
begin
if BooleanType(t_type_struct) then
begin
Gen1NumT(aLDC, a_I, 0);
Gen1NumT(aLDC, a_I, 1);
end
else if CharacterType(t_type_struct) then
begin
Gen1NumT(aLDC, a_I, 0);
Gen1NumT(aLDC, a_I, 127);
end
e1se
begin
Gen1NumT(aLDC, a_I, 0);
Gen1NumT(aLDC, a_I, nd.c_enum_literal_s^.cd_last);
end;
end;
else
GeneralInternalError;
end;
end; {LoadTypeBounds}
procedure LoadDscrtRange(t_dscrt_range: TREE);
var
nd : NODE;
begin {LoadDscrtRange}
GET_NODE(t_dscrt_range, nd);
case KIND(t_dscrt_range) of
_constrained :
LoadTypeBounds(nd.c_constrained^.sm_base_type);
_range :
begin
CompileExpression(nd.c_range^.as_expl);
CompileExpression(nd.c_range^.as_exp2);
end;
else
GenerallnternalError;
end;
end; {LoadDscrtRange}
procedure CompileStm_loop(Stm, EnclosingProc: TREE);
var
nd_loop                      : NODE;
CurrCondClause   : SEQ_TYPE;
BeforeLoopLbl,
AfterLoopLbl     : LabelType;
procedure CompileStm_loop_for(t_for: TREE);
var
nd_for, nd, nd_iteration_id : NODE;
Counter, Temp,
OldOffsetAct                                : OffsetType;
aCT                                                  : aCodeTypes;
begin {CompileStm_loop_for}
OldOffsetAct := OffsetAct;
GET_NODE(t_for, nd_for);
GET_NODE(nd_for.c_for^.as_id, nd_iteration_id);
Comment := 'for';
WriteComment;
aCT := aCodeType(nd_iteration_id.c_iteration_id^.sm_obj_type);
case aCT of
a_B :
begin
Align(BoolAl);
Counter := -OffsetAct;
IncrementOffset(BoolSize);
Align(BoolAl);
Temp := -OffsetAct;
IncrementOffset(BoolSize);
end;
a_C :
begin
Align(CharAl);
Counter := -OffsetAct;
IncrementOffset(CharSize);
Align(CharAl);
Temp := -OffsetAct;
IncrementOffset(CharSize);
end;
a_I :
begin
Align(IntegerAI);
Counter := -OffsetAct;
IncrementOffset(IntegerSize);
Align(IntegerAl);
Temp := -OffsetAct;
IncrementOffset(IntegerSize);
end;
else
GeneralInternalError;
end;
with nd_iteration_id.c_iteration_id^ do
begin
cd_level  := Level;
cd_offset := Counter;
end;
LoadDscrtRange(nd_for.c_for^.as_dscrt_range);
Gen2NumNumT(aSTR, aCT, 0, Temp);
WriteLabel(BeforeLoopLbl);
Gen2NumNumT(aSTR, aCT, 0, Counter);
Gen2NumNumT(aLOD, aCT, 0, Counter);
Gen2NumNumT(aLOD, aCT, 0, Temp);
GenOT(aLEQ, aCT);
Gen1Lbl(aFJP, AfterLoopLbl);
CompileStatements(nd_loop.c_loop^.as_stm_s, EnclosingProc);
Gen2NumNumT(aLOD, aCT, 0, Counter);
Gen1NumT(aINC, aCT, 1);
Gen1Lbl(aUJP, BeforeLoopLbl);
OffsetAct := OldOffsetAct;
end; {CompileStm_loop_for}
procedure CompileStm_loop_reverse(t_reverse: TREE);
var
nd_reverse, nd, nd_iteration_id : NODE;
Counter, Temp,
OldOffsetAct                                        : OffsetType;
aCT                                                          : aCodeTypes;
begin {CompileStm_loop_reverse}
OldOffsetAct := OffsetAct;
GET_NODE(t_reverse, nd_reverse);
GET_NODE(nd_reverse.c_reverse^.as_id, nd_iteration_id);
Comment := 'for';
WriteComment;
aCT := aCodeType(nd_iteration_id.c_iteration_id^.sm_obj_type);
case aCT of
a_B :
begin
Align(BoolAl);
Counter := -OffsetAct;
IncrementOffset(BoolSize);
Align(BoolAl);
Temp := -OffsetAct;
IncrementOffset(BoolSize);
end;
a_C :
begin
Align(CharAl);
Counter := -OffsetAct;
IncrementOffset(CharSize);
Align(CharAl);
Temp := -OffsetAct;
IncrementOffset(CharSize);
end;
a_l :
begin
Align(lntegerAl);
Counter := -OffsetAct;
1ncrementOffset(IntegerSize);
Align(IntegerAl);
Temp := -OffsetAct;
IncrementOffset(IntegerSize);
end;
else
GeneralInternalError;
end;
with nd_iteration_id.c_iteration_id^ do
begin
cd_level  := Level;
cd_offset := Counter;
end;
LoadDscrtRange(nd_reverse.c_reverse^.as_dscrt_range);
Gen2NumNumT(aSTR, aCT, 0, Counter);
Gen2NumNumT(aSTR, aCT, 0, Temp);
WriteLabel(BeforeLoopLbl);
Gen2NumNumT(aLOD, aCT, 0, Counter);
Gen2NumNumT(aLOD, aCT, 0, Temp);
GenOT(aGEQ, aCT);
Gen1Lbl(aFJP, AfterLoopLbl);
CompileStatements(nd_loop.c_loop^.as_stm_s, EnclosingProc);
Gen2NumNumT(aLOD, aCT, 0, Counter);
Gen1NumT(aINC, aCT, 1);
Gen2NumNumT(aSTR, aCT, 0, Counter);
Gen1Lb1(aUJP, BeforeLoopLb1);
OffsetAct := OldOffsetAct;
end; {CompileStm_loop_reverse}
procedure CompileStm_loop_while(t_while: TREE);
var
nd_while : NODE;
begin {CompileStm_loop_while}
Comment := 'while';
WriteLabel(BeforeLoopLbl);
GET_NODE(t_while, nd_while);
CompileExpression(nd_while.c_while .as_exp);
Gen1Lbl(aFJP, AfterLoopLbl);
CompileStatements(nd_loop.c_loop^.as_stm_s, EnclosingProc);
Gen1Lbl(aUJP, BeforeLoopLbl^
end; {CompileStm_loop_while}
begin {CompileStm_loop}
BeforeLoopLbl := NextLabel;
AfterLoopLbl := NextLabel;
GET_NODE(Stm, nd_loop);
with nd_loop.c_loop^ do
begin
cd_after_loop_label := AfterLoopLbl;
cd_level                         := Level;
end;
PUT_NODE(Stm, nd_loop);
with nd_loop.c_loop^ do
if as_iteration = NULL_TREE then
begin
Comment := 'loop';
WriteLabel(BeforeLoopLbl);
CompileStatements(as_stm_s, EnclosingProc);
Gen1Lb1(aUJP, BeforeLoopLb1)
end
else
case KIND(as_iteration) of
_for    : CompileStm_loop_for(as_iteration);
_reverse : CompileStm_loop_reverse(as_iteration);
_while  : CompileStm_loop_while(as_iteration);
else
GenerallnternalError;
end;
Comment := 'end loop';
WriteLabel(AfterLoopLbl);
end; {CompileStm_loop}
procedure CompileStm_named_stm(Stm, EnclosingProc: TREE);
var
nd_named_stm,
nd_named_stm_id  : NODE;
CurrCondClause   : SEQ_TYPE;
StartLbl        : LabelType;
begin {CompileStm_named_stm}
StartLbl := NextLabel;
GET_NODE(Stm, nd_named_stm);
GET_NODE(nd_named_stm.c_named_stm^.as_id, nd_named_stm_id);
with nd_named_stm_id.c_named_stm_id^ do
begin
cd_label := StartLbl;
Comment := GetSymbol(lx_symrep);
end;
WriteComment;
CompileStatement(nd_named_stm.c_named_stm^.as_stm, EnclosingProc);
end; {CompileStm_named_stm}
procedure LoadObject(t: TREE);
var
nd, nd_type_id : NODE;
begin {LoadObject}
GET_NODE(t, nd);
case KIND(t) of
_used_name_id :
begin
GET_NODE(nd.c_used_name_id^.sm_defn, nd_type_id);
case KIND(nd_type_id.c_type_id^.sm_type_spec) of
_integer :
begin
GenlNumT(alND, a_I, 0);
if nd_type_id.c_type_id^.sm_type_spec <> STD_INTEGER then
; ^C-P CVB^
end;
else
GeneralIntemalError;
end;
end;
else
GeneralInternalError;
end;
end; {LoadObject}
procedure LoadActualParams(t_form_par_s, t_act_par_s: TREE);
var
nd_exp_s, nd_param_s, nd_id_s, nd : NODE;
CurrAct, CurrForm, CurrFormld    : SEO_TYPE;
begin {LoadActualParams}
GET_NODE(t_act_par_s, nd_exp_s);
CurrAct := nd_exp_s.c_exp_s^.as_list;
GET_NODE(t_form_par_s, nd_param_s);
CurrForm := nd_param_s.c_param_s^.as_list;
while not IS_EMPTY(CurrForm) do
begin
GET_NODE(HEAD(CurrForm), nd);
case KIND(HEAD(CurrForm)) of
_in :
begin
GET_NODE(nd.c_in^.as_id_s, nd_id_s);
CurrFormId := nd_id_s.c_id_s^.as_list;
while not IS_EMPTY(CurrFormId) do
begin
CompileExpression(HEAD(CurrAct));
CurrAct   := TAIL(CurrAct);
CurrFormId := TAIL(CurrFormId);
end;
end;
_in_out :
begin
GET_N-DE(nd.c_in_out^.as_id_s, nd_id_s);
CurrFormld := nd_id_s.c_id_s .as_list;
while not IS_EMPTY(CurrFormId) do
begin
LoadObjectAddress(HEAD(CurrAct));
GenOT(aDPL, a_A);
LoadObject(nd.c_in_out^.as_name);
CurrAct   := TAIL^CurrAct^;
CurrFormld := TAIL(CurrFormld);
end;
end;
_out :
begin
GET_NODE(nd.c_out^.as_id_s, nd_id_s);
CurrFormId := nd_id_s.c_id_s^.as_list;
while not IS_EMPTY(CurrFormId) do
begin
LoadObjectAddress(HEAD(CurrAct));
GenOT(aDPL, a_A);
LoadObject(nd.c_out^.as_name);
CurrAct   := TAIL(CurrAct);
CurrFormId := TAIL(CurrFormId);
end;
end;
else
GenerallnternalError;
end;
CurrForm := TAIL(CurrForm);
end;
end; {LoadActualParams}
procedure CompileStm_procedure_call(Stm: TREE);
var
nd_procedure_call, nd_used_name_id,
nd_proc_id, nd_exp_s, nd_procedure  : NODE;
t_exp_s                                                           : TREE;
begin {CompileStm_procedure_call}
GET_NODE(Stm, nd_procedure_call);
with nd_procedure_call.c_procedure_call^ do
begin
GET_NODE(sm_normalized_param_s, nd_exp_s);
^-^^^-^ :- sm_normalized_param_s;
GET_NODE(as_name, nd_used_name_id);
end;
GET_NODE(nd_used_name_id.c_used_name_id^.sm_defn, nd_proc_id);
GET_NODE(nd_proc_id.c_proc_id^.sm_first, nd_proc_id);
GET_NODE(nd_proc_id.c_proc_id^.sm_spec, nd_procedure);
Gen2NumNum(aMST, 0, Succ(Level - nd_proc_id.c_proc_id^.cd_level));
LoadActualParams(nd_procedure.c_procedure^.as_param_s, t_exp_s);
with nd_proc_id.c_proc_id do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumLbl(aCUP, cd_param_size, cd_label);
end;
end; {CompileStm_procedure_call}
procedure CompileStm_raise(Stm: TREE);
var
nd_raise, nd_used_name_id, nd_exception_id : NODE;
^^^^                                                                       ^ TREE;
begin {CompileStm_raise}
GET_NODE(Stm, nd_raise);
if nd_raise.c_raise^.as_name_void = NULL_TREE then
GenO(aRAI)
else
begin
GET_NODE(nd_raise.c_raise^.as_name_void, nd_used_name_id);
GET_NODE(nd_used_name_id.c_used_name_id^.sm_defn , nd_exception_id);
with nd_exception_id.c_exception_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen1Lbl(aRAI, cd_1abe1);
end;
end;
end; {Compi1eStm_raise}
procedure PerformReturn(EnclosingProc: TREE);
var
nd_block : NODE;
LVBlbl  : LabelType;
begin {PerformReturn}
GET_NODE(EnclosingProc, nd_block);
with nd_block.c_block^ do
begin
if cd_level <> Level then
begin
LVBlbl := NextLabel;
Gen1Lbl(aLVB, LVBlbl);
GenLabelAssignment(LVBlbl, Level - cd_level);
end;
Gen1Lbl(aUJP, cd_return_label);
end;
end; {PerformReturn}
procedure StoreFunctionResult(t_block, t_exp: TREE);
var
nd_block : NODE;
LVBlbl                           : LabelType;
begin {StoreFunctionResult}
GET_NODE(t_block, nd_block);
case KIND(TypeStructOfExpr(t_exp)) of
_array :
begin
with nd_block.c_block^ do
Gen2NumNum(aLDA, Level - cd_level, cd_result_offset);
CompileExpression(t_exp);
Gen1NumT(aLDC, a_I, NumberOfDimensions(t_exp));
Comment := 'return va1ue';
GenCSP(aPUA);
end;
_enum_1iteral_s :
begin
CompileExpression(t_exp);
Comment := 'return value';
with nd_block.c_block^ do
Gen2NumNumT(aSTR, aCodeType(t_exp),
Level - cd_level, cd_result_offset);
end;
_integer :
begin
CompileExpression(t_exp);
Comment := 'return value';
with nd_block.c_block^ do
Gen2NumNumT(aSTR, a_I, Level - cd_level, cd_result_offset);
end;
else
GenerallnternalError;
end;
end; {StoreFunctionResult}
procedure CompileStm_return(Stm, EnclosingProc: TREE);
var
nd_return : NODE;
begin {CompileStm_return}
GET_NODE(Stm, nd_return);
with nd_return.c_return^ do
if as_exp_void <> NULL_TREE then
StoreFunctionResult(EnclosingProc, as_exp_void);
Comment := 'return';
PerformReturn(EnclosingProc);
end; {CompileStm_return}
procedure CompileStatement(Stm, EnclosingProc: TREE);
var
nd_stm : NODE;
begin {CompileStatement}
GET_NODE(Stm, nd_stm);
case KIND(Stm) of
_abort        : ;
_accept       : ;
_assign       : CompileStm_assign(Stm);
_block        : CompileStm_block(Stm, EnclosingProc);
_case                      : ;
_code                      : ;
_cond_entry : ;
_delay : ;
_entry_call    : ;
_exit                      : CompileStm_exit(Stm);
_goto                      : ;
_if                          : CompileStm_if(Stm, EnclosingProc);
_labeled      : ;
_loop                      : CompileStm_loop(Stm, EnclosingProc);
_named_stm     : CompileStm_named_stm(Stm, EnclosingProc)^
_null_stm     :
begin
Comment := 'null';
WriteComment;
end;
_pragma       : ;
_procedure_call : CompileStm_procedure_call(Stm);
_raise        : CompileStm_raise(Stm);
_return       : CompileStm_return(Stm, EnclosingProc);
_select       : ;
_timed_entry   : ;
else
GeneralInternalError;
end;
TopAct := 0;
end; {CompileStatement}
procedure CompileStatements(Stm_s, EnclosingProc: TREE);
var
Nd, nd_stm_s : NODE;
CurrStatement : SEO_TYPE;
begin {CompileStatements}
GET_NODE(Stm_s, nd_stm_s);
CurrStatement := nd_stm_s.c_stm_s^.as_list;
while not IS_EMPTY(CurrStatement) do
begin
CompileStatement(HEAD(CurrStatement), EnclosingProc);
CurrStatement :^ TAIL(CurrStatement);
end;
end; {CompileStatements}
{--------------------------------------------^----------------}
{Routines for compiling exceptions:}
procedure CompileExceptionHandlers(Alternative_s, EnclosingProc: TREE);
var
nd_alternative_s : NODE;
CurrHandler     : SEQ_TYPE;
NxtHandlerLbl   : LabelType;
OthersFlag      : Boolean;
procedure CompileHandler(t_alternative: TREE);
var
nd_alternative, nd_used_name_id,
nd_choice_s, nd_exception_id    : NODE;
HandlerBeginLbl, SkipLbl       : LabelType;
CurrChoice                                              : SEQ_TYPE;
begin {CompileHandler}
HandlerBeginLbl := NextLabel;
GET_NODE(t_alternative, nd_alternative);
GET_NODE(nd_alternative.c_alternative^.as_choice_s, nd_choice_s);
CurrChoice := nd_choice_s.c_choice_s^.as_l^ist;
while not IS_EMPTY(CurrChoice) do
if KIND(HEAD(CurrChoice)) = _others then
begin
OthersFlag := true;
CurrChoice := GET_EMPTY;
end
else
begin
GET_NODE(HEAD(CurrChoice), nd_used_name_id);
with nd_used_name_id.c_used_name_id^ do
begin
GET_NODE(sm_defn, nd_exception_id);
Comment := GetSymbol(lx_symrep^;
end;
SkipLbl := NextLabel;
Gen2LblLbl(aE)(C, nd_exception_id.c_exception_id^.cd_label, SkipLbl);
CurrChoice := TAIL(CurrChoice^;
if not IS_EMPTY(CurrChoice) then
begin
Gen1Lbl(aUJP, HandlerBeginLbl);
WriteLabel(SkipLbl);
end;
end;
WriteLabel(HandlerBeginLbl);
CompileStatements(nd_alternative.c_alternative^.as_stm_s, EnclosingProc);
PerformReturn(EnclosingProc);
if not OthersFlag then
WriteLabel(SkipLbl);
end; {CompileHandler}
begin {CompileExceptionHandlers}
OthersFlag := false;
GET_NODE(Alternative_s, nd_alternative_s);
CurrHandler := nd_alternative_s.c_alternative_s^.as_list;
if IS_EMPTY(CurrHandler) then
begin
GenO(aEEX);
exit;
end;
while not IS_EMPTY(CurrHandler) do
begin
CompileHandler(HEAD(CurrHandler));
CurrHandler := TAIL(CurrHandIer);
end;
if not OthersFlag then
-enO(aEEX);
end; {CompileExceptionHandlers}
{---------------^---------------------------------------------}
{Routines for compiling context:}
procedure CompileContext_package_id(t_package_id: TREE);
var
CurrDeclaration     : SEQ_TYPE;
nd_package_id,
nd_package_spec, nd_decl_s      : NODE;
begin {CompileContext_package_id}
GET_NODE(t_package_id, nd_package_id);
if not nd_package_id.c_package_id .cd_compiled then
begin
with nd_package_id.c_package_id^ do
begin
Gen2NumStr(aRFP, CurrCompUnitNr, GetSymbol(lx_symrep));
GenerateCode := false;
end;
nd_package_id.c_package_id^.cd_compiled := true;
GET_NODE(nd_package_id.c_package_id^.sm_spec, nd_package_spec);
GET_NODE(nd_package_spec.c_package_spec ^.as_decl_s1, nd_decl_s);
CurrDeclaration := nd_decl_s.c_decl_s^.as_list;
while not 1S_EMPTY(CurrDeclaration)^do
begin
CompileDeclaration(HEAD(CurrDeclaration));
CurrDeclaration := TAIL(CurrDeclaration);
end;
end;
end; {CompileContext_package_id}


procedure CompileWithClause(t_with: TREE);
var
CurrLibUnit, CurrDeclaration     : SEQ_TYPE;
nd_with, nd_used_name_id, nd_defn,
nd_package_spec, nd_ded_s      : NODE;
ProcLbl                                                      : LabelType;
begin {CompileWithClausel
GET_NODE(t_with, nd_with);
CurrLibUnit := nd_with.c_with^.as_list;
while not IS_EMPTY(CurrLibUnit) do
begin
GET_NODE(HEAD(CurrLibUnit), nd_used_name_id);
GenerateCode := true;
GET_NODE(nd_used_name_id.c_used_name_id^.sm_defn, nd_defn);
case KIND(nd_used_name_id.c_used_name_id^.sm_defn) of
_package_id :
begin
CompileContext_package_id(nd_used_name_id.c_used_name_id^.sm_defn);
inc(CurrCompUnitNr);
end;
_proc_id :
if not nd_defn.c_proc_id^.cd_compiled then
begin
with nd_used_name_id.c_used_name_id^ do
begin
Gen2NumStr(aRFP, 0, GetSymbol(lx_symrep));
end;
ProcLbl := NextLabel;
with nd_defn.c_proc_id^ do
begin
cd_label     := ProcLbl;
cd_level     := 1;
cd_param_size := 0; {only parameterless library procedures allowe
cd_compiled  := true;
Comment := 'procedure ' + GetSymbol(lx_symrep);
end;
PUT_NODE(nd_used_name_id.c_used_name_id^.sm_defn, nd_defn);
Gen1Lbl(aRFL, ProcLbl^;
GenerateCode := false;
end;
else
GeneralInternalError;
end;
CurrLibUnit := TAlL(CurrLibUnit);
end;
end; {CompileWithClause}

procedure CompileContext(Context: TREE);
var
CurrContext : SEQ_TYPE;
Nd        : NODE;
begin {CompileContext}
{package STANDARD}
CurrCompUnitNr := 1;
CompileContext_package_id(PKG_STANDARD);
{packages enumarated in with clause}
GenerateCode := false;
GET_NODE(Context, Nd);
if not IS_EMPTY(Nd.c_context^.as_list) then
begin
CurrCompUnitNr := 2;
CompileWithClause(HEAD(Nd.c_context^ .as_list));
end;
CurrCompUnitNr := 0;
GenerateCode  := true;
end; {CompileContext}
{-------------------------------------------------------------}
{Routines for compiling compilation units:}
procedure CompileCompUnit_PackageDecl(t_package_decl: TREE);
var
nd_package_decl, nd_package_spec,
nd_decl_sl                                                : NODE;
ENTlLbl, ENT2Lbl, ExcLbl        : LabelType;
CurrDeclaration                                      : SEQ_TYPE;
begin {CompileCompUnit_PackageDecl}
WriteLabel(1);
ENTlLbl := NextLabel;
ENT2Lbl := NextLabel;
Gen2NumLbl(aENT, 1, ENT1Lb1);
Gen2NumLb1(aENT, 2, ENT2Lb1);
OffsetAct := 0;
OffsetMax := 0;
GET_NODE(t_package_decl, nd_package_decl);
GET_NODE(nd_package_decl.c_package_decl^.as_package_def, nd_package_spec);
GET_NODE(nd_package_spec.c_package_spec^.as_decl_s1, nd_decl_s1);
CurrDec1aration := nd_dec1_s1.c_decl_s^.as_l^ist;
while not IS_EMPTY(CurrDeclaration) do
begin
CompileDeclaration(HEAD(CurrDeclaration));
CurrDeclaration := TAIL(CurrDeclaration);
end;
ExcLbl := NextLabel;
Gen1Lbl(aEXH, ExcLbl);
Gen1Num(aRET, RelativeResultOffset);
WriteLabel(E^cLbl);
GenO(aEEX);
GenLabelAssignment(ENT1Lbl, OffsetMax);
GenLabelAssignment(ENT2Lbl, OffsetMax + TopMax);
end; {CompileCompUnit_PackageDed}
procedure CompilePackageSpec(t_package_spec: TREE);
var
nd_package_spec, nd_ded_s : NODE;
CurrDeclaration                                      : SEO_TYPE;
begin {CompilePackageSpec}
GenerateCode := false;
GET_NODE(t_package_spec, nd_package_spec);
GET_NODE(nd_package_spec.c_package_spec^.as_decl_s1, nd_decl_s);
CurrDeclaration := nd_ded_s.c_decl_s^.as_list;
while not IS_EMPTY(CurrDedaration) do
begin
CompileDeclaration(HEAD(CurrDeclaration));
CurrDeclaration := TAIL(CurrDeclaration);
end;
GenerateCode := true;
end; {CompilePackageSpec}
procedure CompileCompUnit(CompUnit: TREE);
var
nd_comp_unit, nd_unit_body,
nd_unit_id                                    : NODE;
begin
ConditionalError(4007, KIND(CompUnit) <> _comp_unit);
GET_NODE(CompUnit, nd_comp_unit);
GET_NODE(nd_comp_unit.c_comp_unit^.as_unit_body, nd_unit_body);
Init;
case KIND(nd_comp_unit.c_comp_unit^.as_unit_body) of
_subprogram_body :
begin
GET_NODE(nd_unit_body.c_subprogram_body^.as_designator, nd_unit_id);
UnitName := GetSymbol(nd_unit_id.c_proc_id^.lx_symrep);
WriteLn('Generating code for procedure ', UnitName);
Gen1Str(aPRO, UnitName);
CompileContext(nd_comp_unit.c_comp_unit^.as_context);
CompileProcedure(nd_comp_unit.c_comp_unit^.as_unit_body, 1);
end;
_package_body :
begin
GET_NODE(nd_unit_body.c_package_body^.as_id, nd_unit_id);
with nd_unit_id.c_package_id^ do
begin
UnitName := GetSymbol(lx_symrep);
WriteLn('Generating code for package body ', UnitName);
Gen1Str(aPKB, UnitName);
CompilePackageSpec(sm_spec);
end;
CompileContext(nd_comp_unit.c_comp_unit^.as_context);
WriteLabel(1);
with nd_unit_body.c_package_body^ do
Compi1eSubpBlock(as_block_stub, as_block_stub, NULL_TREE,
RelativeResultOffset
end;
_package_ded :
begin
GET_NODE(nd_unit_body.c_package_decl^.as_id, nd_unit_id);
UnitName := GetSymbol(nd_unit_id.c_package_id^.^x_symrep);
WriteLn('Generating code for package ', UnitName);
Gen1Str(aPKG, UnitName);
CompileContext(nd_comp_unit.c_comp_unit^.as_context);
CompileCompUnit_PackageDecl(nd_comp_unit.c_comp_unit^.as_unit_body);
end;
else
ConditionalError(4008, true);
end;
GenO(aQ);
end; {CompileCompUnit}
begin {CodeGenerator}
OpenOutputFile(FileName);
Comment := 'Ada Code Generator, version ' + VerNr;
WriteComment;
WriteComment;
ConditionalError(4001, Root = NULL_TREE);
ConditionalError(5, KIND(Root) <> _compilation);
GET_NODE(Root, Nd);
CurrCompUnit := Nd.c_compilation^.as_list;
while not 1S_EMPTY(CurrCompUnit) do
begin
CompileCompUnit(HEAD(CurrCompUnit));
CurrCompUnit := TAIL(CurrCompUnit);
WriteComment;
end;
Comment := 'End of compilation';
WriteComment;
CloseOutputFile;
end; {CodeGenerator}
begin {CodeGen}
end. {CodeGen}









unit CG_Lib;
{Constants, types and routines used by all code generator units.}
{Remove this comment to obtain error numbers only.}
{^DEFINE FullErrorMessages}
interface
const
MaxLabel       = 30000;
MaxOffset     = 10000;
MaxLevel       = 200;
type
LabelType =   O..MaxLabel;
OffsetType -   -MaxOffset..MaxOffset;
LevelType =   O..MaxLevel;
{----------------------------------------------------}
{Return a string with leading and trailing white space removed}
function Trim(S : string) : string;
{Report error and halt.
Classification of error numbers:
1.. 999 - interna1 compi1er errors,
4000..4999 - errors in externa1 DIANA fi1es,
5000. .5999 - imp1ementation restrictions.}
procedure Error(ErrorNumber: integer);
implementation
{Return a string with leading and trailing white space removed}
function Trim(S : string) : string;
var
i : Byte;
begin
while (Length(S) > 0) and (S[Length(S)] <= ' ') do
Dec(S[0]);
i := 1;
while (i <= Length(S)) and (S[i] <= ' ') do
inc(i);
Delete(S, 1, Pred(i));
Trim := S;
end; {Trim}
{----------------------------------------------------}
procedure Error(ErrorNumber: integer);
^egin
Write('Error ^', ErrorNumber, ' - ');
{^IFDEF Fu11ErrorMessages}
if ErrorNumber < 1000 then
begin                        {lnternal error}
case ErrorNumber of
2   : WriteLn('Filename not defined');
3   : WriteLn('Node does not exist');
4   : WriteLn('Symbol not defined');
5   : WriteLn('Main node is not ^compilation^');
7   : WriteLnCFile does not exist');
8   : WriteLn('Illegal A-code instruction');
9   : WriteLn('Negative level');
10  : WriteLn('Error while opening output file');
else WriteLn('Internal error');
end;
Halt(1);
end
else if (ErrorNumber > 4000)  and (ErrorNumber < 5000) then
begin                        {lllegal DIANA format}
case ErrorNumber of
4001 : WriteLn('Missing ^compi1ation^ node');
4002 : WriteLn('Not a node definition');
4003 : WriteLn('Not a valid node number');
4004 : WriteLn('Invalid kind of node');
4005 : WriteLn('Invalid attribute value');
4006 : WriteLn('Invalid attribute name');
4007 : WriteLn('Not a ^comp_unit^ node');
4008 : WriteLn('Bad compilation unit');
else WriteLn('Illegal DIANA format');
end;
Halt(2);
end
else if ErrorNumber < 6000 then
begin                        {Implementation restrictions}
case ErrorNumber of
5001 : WriteLn('Too many source fi1es');
5002 : WriteLn('Out of symbol space');
5003 : WriteLn('Too big node number');
5004 : WriteLn('Too big A-code label');
5005 : WriteLn('Too big static 1eve1');
else WriteLn('Implementation restrictions');
end;
Halt(3);
end
else
Halt(4);
{^ELSE}
WriteLn;
Halt(1);
{^ENDIF}
end; {Error}
end. {CG_Lib}










unit CG_Expr;
{^outines for compiling expressions, loading parameters, and
some additional routines for DIANA trees.}
interface
-ses CG1,
CG_Lib,
Diana,
Private;
const
{DIANA node numbers:}
STD_BOOLEAN  = 13;
STD_INTEGER  = 19;
STD_CHA^ACTER = 32;
{Load actua1 parameters. Used b-th for functions and orocedures.}
procedure LoadParams(t_normalized_param_s: TREE);
{-------------------------------------------------------------}
{Compile expression 't_expr'.}
procedure CompileExpression(t_expr: TREE);
{-------------------------------------------------------------}
{Routines determining a-code type}
function BooleanType(t_type_spec: TREE): Boolean;
function CharacterType(t_type_spec: TREE): Boolean;
function aCodeType(t_type_spec: TREE): aCodeTypes;
{-------------------------------------------------------------}
procedure LoadAddress_indexed(t_indexed: TREE);
procedure LoadObjectAddress(t_object: TREE);
^  procedure LoadAddress(t_object: TREE);
{-------------------------------------------------------------}
function TypeStruct(t_type: TREE): TREE;
function TypeStructOfExpr(t_exp: TREE): TREE;
function Constrained(t_type_spec: TREE): Boolean;
function TypeSize(t: TREE): integer;
procedure LoadTypeSize(t: TREE);
function LevelOfType(t_type_spec: TREE): LevelType;
procedure GetCLO( t: TREE; var CompUnitNr: Byte;
var Lvl: LevelType; var Offs: OffsetType);
i^plementation
^^r
CompUnitNr   :   Byte;
Lvl                  :   LevelType;
Dffs                :   OffsetType;
begin {Expr_function_call_used_name_id}
GET_NODE(t_function_call^, nd_function_call);
GET_NODE(nd_function_call.c_function_call^.as_name, nd_used_name_id);
GET_NODE(nd_used_name_id.c_used_name_id^.sm_defn, nd_function_id);
with nd_function_id.c_function_id^ do
Gen2NumNum(aMST, cd_result_size, Succ(Level - cd_level));
LoadParams(nd_function_call.c_function_call^.sm_normalized_param_s);
with nd_function_id.c_function_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumLbl(aCUP, cd_param_size, cd_label);
end;
with nd_function_call.c_function_call^ do
case KIND(sm_exp_type) of
_integer :
if sm_exp_type <> STD_INTEGER then
begin
GetCLO(sm_exp_type, CompUnitNr, Lvl, Offs);
GenLoadAddr(CompUnitNr, Lvl, Offs);
GenCSP(aCVB);
end;
end;
end; {Expr_function_call_used_name_id}



procedure Expr_function_call(t_function_call: TREE);
var
nd_function_call : NODE;
begin {Expr_function_call}
GET_NODE(t_function_call, nd_function_call);
case KIND(nd_function_call.c_function_call^.as_name) of
_used_bltn_op : Expr_used_bltn_op(t_function_call);
_used_name_id : Expr_function_call_used_name_id(t_function_call);
else
GenerallnternalError;
end;
end; {Expr_function_call}



procedure Expr_indexed(t_indexed: TREE);
var
nd_indexed : NODE;
begin {Expr_indexed}
GET_NODE(t_indexed, nd_indexed);
LoadAddress_indexed(t_indexed);
case KIND(nd_indexed.c_indexed^.sm_exp_type) of
_access:
Gen1NumT(aIND, a_A, 0);
_enum_1iteral_s,
_integer:
Gen1NumT(aIND, a_I, 0)
else
GeneralInternalError;
end;
end; {Expr_indexed}



procedure Expr_used_object_id_def_char(t_def_char: TREE);
var
nd_def_char : NODE;
begin {Expr_used_object_id_def_char}
GET_NODE(t_def_char, nd_def_char);
Gen1NumT(aLDC, a_I, nd_def_char.c_def_char^.sm_rep);
end; {Expr_used_object_id_def_char}
procedure Expr_used_object_id_enum_id(t_enum_id: TREE);
var
nd_enum_id : NODE;
begin {Expr_used_object_id_enum_id}
GET_NODE(t_enum_id, nd_enum_id);
Gen1NumT(aLDC, a_I, nd_enum_id.c_enum_id . sm_rep);
end; {Expr_used_object_id_enum_id}
procedure Expr_used_object_id_in_id(t_in_id: TREE);
var
nd_in_id : NODE;
begin {Expr_used_object_id_in_id}
GET_NODE(t_in_id, nd_in_id);
with nd_in_id.c_in_id^ do
begin
case KIND(sm_obj_type) of
_access :
GenLoad(a_A, 0, cd_1eve1, cd_offset);
_array :
begin
GenLoadAddr(0, cd_level, cd_offset);
Gen1Num(aGET, AddrSize + AddrSize);
end;
_enum_1iteral_s :
if BooleanType(sm_obj_type) then
GenLoad(a_B, 0, cd_level, cd_offset)
else if CharacterType(sm_obj_type) then
GenLoad(a_C, 0, cd_level, cd_offset)
else
GenLoad(a_I, 0, cd_level, cd_offset);
_integer :
GenLoad(a_I, 0, cd_level, cd_offset);
else
GenerallnternalError;
end;
end;
end; {Expr_used_object_id_in_id}
procedure Expr_used_object_id_in_out_id(t_in_out_id: TREE);
var
nd_in_out_id : NODE;
begin {Expr_used_object_id_in_out_id}
GET_NODE(t_in_out_id, nd_in_out_id);
with nd_in_out_id.c_in_out_id^ do
begin
case KIND(sm_obj_type) of
_access :
GenLoad(a_A, 0, cd_level, cd_val_offset);
_array :
begin
GenLoadAddr(0, cd_level, cd_val_offset);
Gen1Num(aGET, AddrSize + AddrSize);
end;
_enum_1itera1_s :
if Boo1eanType(sm_obj_type) then
GenLoad(a_B, 0, cd_1eve1, cd_val_offset)
e1se if CharacterType(sm_obj_type) then
GenLoad(a_C, 0, cd_level, cd_val_offset)
else
GenLoad(a_I, 0, cd_level, cd_val_offset);
_integer :
GenLoad(a_I, 0, cd_level, cd_val_offset);
else
GenerallnternalError;
end;
end;
end; {Expr_used_object_id_in_out_id}
procedure Expr_used_object_id_out_id(t_out_id: TREE);
var
nd_out_id : NODE;
begin {Expr_used_object_id_out_id}
GET_NODE(t_out_id, nd_out_id);
with nd_out_id.c_out_id^ do
begin
case KIND(sm_obj_type) of
_access :
GenLoad(a_A, 0, cd_level, cd_val_offset);
_array :
begin
GenLoadAddr(0, cd_level, cd_val_offset);
Gen1Num(aGET, AddrSize + AddrSize);
end;
_enum_literal_s :
if BooleanType(sm_obj_type) then
GenLoad(a_B, 0, cd_1evel, cd_val_offset)
e1se if CharacterType(sm_obj_type) then
GenLoad(a_C, 0, cd_level, cd_val_offset)
else
GenLoad(a_I, 0, cd_level, cd_val_offset);
_integer :
GenLoad(a_I, 0, cd_level, cd_val_offset);
else
GenerallnternalError;
end;
end;
end; {Expr_used_object_id_out_id}
procedure Expr_used_object_id_iteration_id(t_iteration_id: TREE);
var
nd_iteration_id : NODE;
begin {Expr_used_object_id_iteration_id}
GET_NODE(t_iteration_id, nd_iteration_id);
with nd_iteration_id.c_iteration_id^ do
begin
case KIND(sm_obj_type) of
_enum_literal_s :
if BooleanType(sm_obj_type) then
GenLoad(a_B, 0, cd_level, cd_offset)
else if CharacterType(sm_obj_type) then
GenLoad(a_C, 0, cd_level, cd_offset)
else
GenLoad(a_I, 0, cd_level, cd_offset);
_integer :
GenLoad(a_I, 0, cd_level, cd_offset);
else
GeneralInternalError;
end;
end;
end; {Expr_used_object_id_iteration_id}
procedure Expr_used_object_id_const_id(t_const_id: TREE);
var
nd_const_id : NODE;
begin {Expr_used_object_id_const_id}
GET_NODE(t_const_id, nd_const_id);        ^
with nd_const_id.c_const_id^ do
begin
case KIND(sm_obj_type) of
_access :
GenLoad(a_A, cd_comp_unit, cd_level, cd_offset);
_array :
begin
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
Gen1Num(aGET, AddrSize + AddrSize);
end;
_enum_literal_s :
if BooleanType(sm_obj_type) then
GenLoad(a_B, cd_comp_unit, cd_level, cd_offset)
else if CharacterType(sm_obj_type) then
GenLoad(a_C, cd_comp_unit, cd_level, cd_offset)
else
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset);
_integer :
^ if sm_obj_type = STD_INTEGER then
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset)
else
begin
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset);
GetCLO(sm_obj_type, CompUnitNr, Lvl, Offs);
GenLoadAddr(CompUnitNr, Lvl, Offs);
GenCSP(aCVB);
end;
else
GeneralInternalError;
end;
end;
end; {Expr_used_object_id_const_id}
procedure Expr_used_object_id_var_id(t_var_id: TREE);
var
nd_var_id : NODE;
begin {Expr_used_object_id_var_id}
GET_NODE(t_var_id, nd_var_id^;
with nd_var_id.c_var_id^ do
begin
case KIND(sm_obj_type) of
_access :
GenLoad(a_A, cd_comp_unit, cd_level, cd_offset);
_array :
begin
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
Gen1Num(aGET, AddrSize + AddrSize);
end;
_enum_literal_s :
if BooleanType(sm_obj_type) then
GenLoad(a_B, cd_comp_unit, cd_level, cd_offset)
else if CharacterType(sm_obj_type) then
GenLoad(a_C, cd_comp_unit, cd_level, cd_offset)
else
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset);
_integer :
if sm_obj_type = STD_INTEGER then
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset)
else
begin
GenLoad(a_I, cd_comp_unit, cd_level, cd_offset);
GetCLO(sm_obj_type, CompUnitNr, Lvl, Offs);
GenLoadAddr(CompUnitNr, Lvl, Offs);
-enC-P(aCVB);
end;
else
GeneralInternalError;
end;
end;
end; {Expr_used_object_id_var_id}
procedure Expr_used_object_id(t_used_object_id: TREE);
var
nd_used_object_id : NODE;
TempVal                       : Value;
begin {Expr_used_object_id}
GET_NODE(t_used_object_id, nd_used_object_id);
with nd_used_object_id.c_used_object_id^ do
begin
TempVal := nd_used_object_id.c_used_object_id^.sm_value;
Comment := GetSymbol(lx_symrep);
end;
case TempVal.v_type of
bool_value :
Gen1T(aLDC, a_B, TempVal);
char_value :
Gen1T(aLDC, a_C, TempVal);
int_value :
GenlT(aLDC, a_I, TempVal);
no_value :
with nd_used_object_id.c_used_object_id^ do
case KIND(sm_defn^ of
_const_id :
Expr_used_object_id_const_id(sm_defn);
_def_char :
Expr_used_object_id_def_char(sm_defn);
_enum_id :
Expr_used_object_id_enum_id(sm_defn);
_in_id :
Expr_used_object_id_in_id(sm_defn);
_in_out_id :
Expr_used_object_id_in_out_id(sm_defn);
_iteration_id :
Expr_used_object_id_iteration_id(sm_defn);
_out_id :
Expr_used_object_id_out_id(sm_defn);
_var_id :
Expr_used_object_id_var_id(sm_defn);
else
GeneralInternalError;
end;
else
GeneralInternalError;
end;
end; {Expr_used_object_id}
procedure CompileExpression(t_expr: TREE);
var
nd : NODE;
begin {CompileExpression}
GET_NODE(t_expr, nd);
case KIND(t_expr) of
_allocator :
Expr_allocator(t_expr);
_binary :
Expr_binary(t_expr);
_function_call  :
Expr_function_call(t_expr);
_indexed :
Expr_indexed(t_expr);
_numeric_literal :
Gen1T(aLDC, a_I, nd.c_numeric_literal^ .sm_value);
_parenthesized :
CompileExpression(nd.c_parenthesized ^.as_exp);
_used_object_id :
Expr_used_object_id(t_expr);
else
GeneralInternalError;
end;
end; {CompileExpression}
end. {CG_Expr}










procedure ConditionalError(ErrorCode:integer; Condition: Boolean);
begin {ConditionalError}
if Condition then
begin
WriteComment;
CloseOutputFile;
Error(ErrorCode);
end;
end; {ConditionalError}
procedure GenerallnternalError;
begin {GeneralInternalError}
ConditionalError(999, true);
end; {GeneralInternalError}
{--^^^-^^^^^-^^^^^^^^^^^^^^^^^-^-^^^-^-^^^-^^^^^^^^^^^-^-^-^^-}



function TypeStruct(t_type: TREE): TREE;
var
nd : NODE;
begin {TypeStruct}
GET_NODE(t_type, nd);
case KIND(t_type) of
_access,
^arr-y,
_enum_literal_s,
_integer :
TypeStruct := t_type;
_constrained :
TypeStruct := TypeStruct(nd.c_constrained .sm_type_struct);
_type_id :
TypeStruct := TypeStruct(nd.c_type_id^.sm_type_spec);
_used_name_id :
TypeStruct := TypeStruct(nd.c_used_name_id^.sm_defn);
else
GeneralInternalError;
end;
end; {TypeStruct}



function TypeStructOfExpr(t_exp: TREE): TREE;
var
nd : NODE;
begin {TypeStructOfExpr}
GET_NODE(t_exp, nd);
case KIND(t_exp) of
_function_call :
TypeStructOfExpr := TypeStruct(nd.c_function_call^.sm_exp_type);
_used_object_id :
TypeStructOfExpr := TypeStruct(nd.c_used_object_id^.sm_exp_type);
else
GeneralInternalError;
end;
end; {TypeStructOfExpr}



function Constrained(t_type_spec: TREE): Boolean;
var
nd_type_spec : NODE;
begin {Constrained}
GET_NODE(t_type_spec, nd_type_spec);
case KIND(t_type_spec) of
_enum_literal_s :
Constrained := true;
_integer :
Constrained := true;
_constrained :
if Constrained(nd_type_spec.c_constrained^.sm_type_struct) then
Constrained := true
else
GeneralInternalError;
else
GeneralInternalError;
end;
end; {Constrained}



{Return size of the type (in bytes). Size must be known at compile time.}
function TypeSize(t: TREE): integer;
var
nd : NODE;
begin {TypeSize}
GET_NODE(t, nd);
case KIND(t) of
_access :
TypeSize := AddrSize;
_array :
TypeSize := AddrSize + AddrSize;
_enum_literal_s,
_integer :
TypeSize := IntegerSize;
_type_id :
TypeSize := TypeSize(nd.c_type_id^.sm_type_spec);
_used_name_id :
TypeSize := TypeSize(nd.c_used_name_id^ .sm_defn);
else
GeneralInternalError;
end;
end; {TypeSize}



procedure LoadTypeSize(t: TREE);
var
nd : NODE;
begin {LoadTypeSize}
GET_NODE(t, nd);
case KIND(t) of
_constrained :
with nd.c_constrained^ do
begin
ConditionalError(999, not Constrained(sm_type_struct));
LoadTypeSize(sm_type_struct);
end;
_enum_literal_s,
_integer :
Gen1NumT(aLDC, a_I, TypeSize(t));
else
GeneralInternalError;
end;
end; {LoadTypeSize}



function LevelOfType(t_type_spec: TREE): LevelType;
var
nd : NODE;
begin {LevelOfType}
GET_NODE(t_type_spec, nd);
case KIND(t_type_spec) of
_access : LevelOfType := nd.c_access .cd_level;
else
GeneralInternalError;
end;
end; {LevelOfType}



function BooleanType(t_type_spec: TREE): Boolean;
begin {BooleanType}
BooleanType := t_type_spec = STD_BOOLEAN;
end; {BooleanType}
function CharacterType(t_type_spec: TREE): Boolean;
begin {CharacterType}
CharacterType := t_type_spec = STD_CHARACTER;
end; {CharacterType}
function aCodeType(t_type_spec: TREE): aCodeTypes;
var
nd : NODE;
begin {aCodeType}
GET_NODE(t_type_spec, nd);
case KIND(t_type_spec) of
_access :
aCodeType := a_A;
_enum_literal_s :
if BooleanType(t_type_spec) then
aCodeType := a_B
else if CharacterType(t_type_spec) then
aCodeType := a_C
else
aCodeType := a_I;
_exp_s :
aCodeType := aCodeType(HEAD(nd.c_exp_s^.as_list));
_function_call :
aCodeType := aCodeType(nd.c_function_call^.sm_exp_type);
_integer,
_numeric_literal :
aCodeType := a_I;
_parenthesized :
aCodeType := aCodeType(nd.c_parenthesized^ .sm_exp_type);
_used_object_id :
aCodeType := aCodeType(nd.c_used_object_id^.sm_exp_type);
else
GeneralInternalError;
end;
end; {aCodeType}



procedure LoadAddress_indexed(t_indexed: TREE);
var
nd_indexed, nd_exp_s : NODE;
procedure Index(Expr: SEQ_TYPE);
begin {lndex}
if not IS_EMPTY(Expr) then
begin
CompileExpression(HEAD(Expr));
Expr := TAIL(Expr);
if IS_EMPTY(Expr) then
GenCSP(aAR2)
else
begin
GenCSP(aAR1);
Gen1NumT(aDEC, a_A, 3^IntegerSize);
Index(Expr);
GenOT(aADD, a_I);
end;
end;
end; {lndex}
begin {LoadAddress_indexed}
GET_NODE(t_indexed, nd_indexed);
with nd_indexed.c_indexed^ do
begin
LoadObjectAddress(as_name);
GenOT(aDPL, a_A);
Gen1NumT(alND, a_A, 0);
GenOT(aSWP, a_A);
Gen1NumT(alND, a_A, -AddrSize);
Gen1NumT(aDEC, a_A, IntegerSize);
GET_NODE(as_exp_s, nd_exp_s);
Index(nd_exp_s.c_exp_s^.as_Iist);
Gen1Num(aI)(A, 1);
end;
end; {LoadAddress_indexed}



{Load address. The address is the value of 't_object'.}
procedure LoadAddress(t_object: TREE);
var
nd : NODE;
begin {LoadAddress}
GET_NODE(t_object, nd);
case KIND(t_object) of
_indexed :
LoadAddress_indexed(t_object);
_in_id :
with nd.c_in_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenLoad(a_A, 0, cd_level, cd_offset);
end;
_in_out_id :
with nd.c_in_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenLoad(a_A, 0, cd_level, cd_val_offset);
end;
_out_id :
with nd.c_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenLoad(a_A, 0, cd_level, cd_val_offset);
end;
_var_id :
with nd.c_var_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenLoad(a_A, cd_comp_unit, cd_level, cd_offset);
end;
_used_object_id :
LoadAddress(nd.c_used_object_id ^.sm_defn);
else
GenerallnternalError;
end;
end; {LoadAddress}



{Load address of the object 't_object'.}
procedure LoadObjectAddress(t_object: TREE);
var
nd : NODE;
begin {LoadObjectAddress}
GET_NODE(t_object, nd);
case KIND(t_object) of
_indexed :
LoadAddress_indexed(t_object);
with nd.c_in_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumNum(aLDA, Level - cd_level, cd_offset);
end;
_in_out_id :
with nd.c_in_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumNum(aLDA, Level - cd_level, cd_val_offset);
end;
_put_id :
with nd.c_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumNum(aLDA, Level - cd_level, cd_val_offset);
end;
_var_id :
with nd.c_var_id do
begin
Comment := GetSymbol(lx_symrep);
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
end;
_used_object_id :
LoadObjectAddress(nd.c_used_object_id^.sm_defn);
else
GeneralInternalError;
end;
end; {LoadObjectAddress}



{Get compilation unit number, level, and offset of an object referenced
by 't'.}
procedure GetCLO( t: TREE; var CompUnitNr: Byte;
var Lvl: LevelType; var Offs: OffsetType);
var
nd : NODE;
begin {GetCLO}
GET_NODE(t, nd);
case KIND(t) of
_in_id :
with nd.c_in_id^ do
begin
CompUnitNr := 0;
Lvl      := cd_level;
Offs      := cd_offset;
end;
_in_put_id :
with nd.c_in_out_id^ do
begin
CompUnitNr := 0;
Lvl      := cd_level;
Offs      := cd_val_offset;
end;
_out_id :
with nd.c_out_id^ do
begin
CompUnitNr := 0;
Lvl       := cd_level;
Offs      := cd_val_offset;
end;
_integer :
with nd.c_integer^ do
begin
CompUnitNr := cd_comp_unit;
Lvl      := cd_level;
Offs     := cd_offset;
end;
_var_id :
with nd.c_var_id^ do
begin
CompUnitNr := cd_comp_unit;
Lvl       := cd_level;
Offs      := cd_offset;
end;
else
GeneralInternalError;
end;
end; {GetCLO}



{Routines for compiling expressions:}
procedure LoadParams(t_normalized_param_s: TREE);
var
nd_exp_s                              : NODE;
CurrParam                            : SEO_TYPE;
begin {LoadParams}
GET_NODE(t_normalized_param_s, nd_exp_s);
CurrParam := nd_exp_s.c_exp_s^.as_list;
^hile not IS_EMPTY(CurrParam) do
begin
CompileExpression(HEAD(CurrParam));
CurrParam := TAIL(CurrParam);
end;
end; {LoadParams}



procedure Expr_used_bltn_op(t_function_call: TREE);
var
nd_function_call,
nd_used_bltn_op     : NODE;
aCT                                    : aCodeTypes;
begin {Expr_used_bltn_op}
GET_NODE(t_function_call, nd_function_call);
with nd_function_call.c_function_call^ do
begin
GET_NODE(as_name, nd_used_bltn_op);
LoadParams(sm_normalized_param_s);
aCT := aCodeType(sm_normalized_param_s);
end;
case nd_used_bltn_op.c_used_bltn_op^.sm_operator of
op_and       : GenO (aAND);
op_div       : GenOT(aDIV, aCT);
op_eg        : GenOT(aEQU, aCT);
op_exp       : GenOT(aE)(P, aCT);
op_ge        : GenOT(aGEQ, aCT);
op_gt        : GenOT(aGRE, aCT);
op_le        : GenOT(aLEQ, aCT);
op_lt        : GenOT(aLES, aCT);
op_minus      : GenOT(aSUB, aCT);
op_mod       : GenOT(aMOD, aCT);
op_mult      : GenOT(aMUL, aCT);
op_ne        : GenOT(aNEQ, aCT);
op_not       : GenO (aNOT);
op_or        : GenO (aORR);
op_plus      : GenOT(aADD, aCT);
op_rem       : GenOT(aREM, aCT);
op_unary_minus :
begin
Gen1NumT(aLDC, aCT, 0);
GenOT(aSWP, aCT);
GenOT(aSUB, aCT);
end;
op_unary_plus : ;
op_xor       : GenO (aXOR);
else
GenerallnternalError;
end;
end; {Expr_used_bltn_op}
procedure Expr_allocator(t_allocator: TREE);
var
nd_allocator : NODE;
begin {Expr_allocator}
GET_NODE(t_allocator, nd_allocator);
with nd_allocator.c_allocator do
begin
LoadTypeSize(as_exp_constrained);
Gen1Num(aALO, Level - LevelOfType(sm_exp_type));
end;
end; {Expr_allocator}
procedure Expr_binary(t_binary: TREE);
var
nd_binary : NODE;
Lbl^1, Lbl2 : LabelType;
TempVal   : Value;
begin {Expr_binary}
Lbl1 := NextLabe1;
Lbl2 := NextLabel;
GET_NODE(t_binary, nd_binary);
with nd_binary.c_binary^ do
begin
CompileExpression(as_exp1);
case as_binary_op of
AND_THEN :
Gen1Lb1(aFJP, Lb11);
OR_ELSE :
Gen1Lbl(aTJP, Lbl1);
end;
CompileExpression(as_exp2);
Gen1Lb1(aUJP, Lbl2);
WriteLabel(Lbl1);
TempVal.boo_val := as_binary_op = OR_ELSE;
Gen1T(aLDC, a_B, TempVal);
WriteLabel(Lbl^2);
end;
end; {Expr_binary}



procedure Expr_function_call_used_name_id(t_function_call: TREE);
var
nd_function_call, nd_used_name_id,
nd_function_id                                          : NODE;










unit CG_Decl;
{Routines for compiling constant, type, and variable declarations.}
interface
^ses CG_Lib,
CG^,
CG_Expr,
Private,
Diana;
{-------------------------------------------------------------}
procedure Compi1eDed_constant(t_constant: TREE);
procedure CompileDecl_type(t_type: TREE);
procedure CompileDecl_var(Variable: TREE);
implementation
^ar
DimensionsNr       : Byte;
procedure ConditionalError(ErrorCode:integer; Condition: Boolean);
^egin {ConditionalError}
if Condition then
begin
WriteComment;
CloseOutputFile;
Error(ErrorCode);
end;
end; {ConditionalError}
^rocedure GenerallnternalError;
^egin {GenerallnternalError}
ConditionalError(999, true);
^d; {GeneralInternalError}
^------------------------------------------------------------}
{^outines for compiling constant declarations:}
^rocedure CompileBoolConst(t_const_id: TREE);
^ar
nd_const_id : NODE;
t_object_def : TREE;
begin {CompileBoolConst}
Align(BoolAl);
GET_NODE(t_const_id, nd_const_id);
GET_NODE(nd_const_id.c_const_id ^.sm_first, nd_const_id);
^ith nd_const_id,c_const_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;

!!!!!



IncrementOffset(IntegerSize);
GET_NODE(nd_array.c_array^.as_dscrt_range_s, nd_dscrt_range_s);
I)imensionsNr := 0;
CompileType_Array_Dimension( nd_dscrt_range_s.c_dscrt_range_s^.as_list,
nd_array.c_array^.as_constrained);
GenStore(a_I, CurrCompUnitNr, Level, nd_array.c_array^.cd_offset);
nd_array.c_array^.cd_dimensions := DimensionsNr;
PUT_NODE(nd_type.c_type^.as_type_spec, nd_array);
end; {CompileType_array}




^rocedure CompileType_enum_literal_s(t_type: TREE);
var
nd_enum_literal_s, nd_type : NODE;
Curr                                                  : SEQ_TYPE;
i                                                         : integer;
begin {CompileType_enum_literal_s}
GET_NODE(t_type, nd_type);
GET_NODE(nd_type.c_type^.as_type_spec, nd_enum_literal_s);
^ith nd_enum_literal_s.c_enum_literal_s do
begin
Curr := as_list;
i   := -1;
while not IS_EMPTY(Curr) do
begin
inc(i);
Curr := TAIL(Curr);
end;
cd_last := i;
end;
end; {CompileType_enum_literal_s}



procedure CompileType_integer(t_type: TREE);
^ar
nd_integer, nd_type, nd_type_id,
nd_range                                                       : NODE;
lower, upper                                              : OffsetType;
begin {CompileType_integer}
^ET_NODE(t_type, nd_type);
GET_NODE(nd_type.c_type^.as_type_spec, nd_integer);
^ET_NODE(nd_type.c_type^.as_id, nd_type_id);
GET_NODE(nd_integer.c_integer^.as_range, nd_range);
Comment := 'integer ' + GetSymbol(nd_type_id.c_type_id^.lx_symrep);
^riteComment;
^lign(IntegerAI);
lower := -OffsetAct;
IncrementOffset(IntegerSize);
Align(IntegerAl);
upper := -OffsetAct;
IncrementOffset(IntegerSize);
^ith nd_integer.c_integer^ do
begin
cd_offset   := lower;
cd_Ievel    := Level;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
end;
with nd_range.c_range^ do
begin
CompileExpression(as_exp1);
GenStore(a_I, CurrCompUnitNr, Level, lower);
CompileExpression(as_exp2);
GenStore(a_l, CurrCompUnitNr, Level, upper);
end;
PHT_NODE(nd_type.c_type^.as_type_spec, nd_integer);
^nd; {CompileType_integer}



^rocedure CompileDecl_type(t_type: TREE);
var
nd_type : NODE;
begin {CompileDecl_type}
if CurrCompUnitNr = 1 then
exit;   {package STANDARD}
GET_NODE(t_type, nd_type);
case KIND(nd_type.c_type^.as_type_spec) of
_access       : CompiIeType_access(t_type);
_array        : Compi1eType_array(t_type);
_enum_Iitera1_s : CompiIeType_enum_Iiteral_s(t_type);
_integer      : CompileType_integer(t_type);
else
GenerallnternaIError;
end;
end; {CompiIeDecI_type}
end. {CG_DecI}





end;
IncrementOffset(BoolSize);
CompileExpression(t_object_def);
with nd_const_id,c_const_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_B, cd_comp_unit, cd_level, cd_offset);
end;
end; {CompileBoolConst}

procedure CompileCharConst(t_const_id: TREE);
^ar
nd_const_id : NODE;
t_object_def : TREE;
begin {CompileCharConst}
Align(CharAl);
GET_NODE(t_const_id, nd_const_id);
GET_NODE(nd_const_id.c_const_id^.sm_first, nd_const_id);
^ith nd_const_id,c_const_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_pbject_def := sm_obj_def;
end;
IncrementOffset(CharSize);
CompileExpression(t_object_def);
^ith nd_const_id,c_const_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_C, cd_comp_unit, cd_level, cd_offset);
end;
^d; {CompileCharConst}
procedure CompileEnumConst(t_const_id, t_type_spec: TREE);
^-r
nd_const_id : NODE;
t_object_def : TREE;
^egin {CompileEnumConst}
if BooleanType(t_type_spec) then
begin
CompileBoolConst(t_const_id);
exit;
end
else if CharacterType(t_type_spec) then
begin
CompileCharConst(t_const_id);
exit;
end;
Align(IntegerAl);
GET_NODE(t_const_id, nd_const_id);
GET_NODE(nd_const_id.c_const_id^.sm_first, nd_const_id);
^ith nd_const_id,c_const_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit :- CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;
IncrementOffset(IntegerSize);
CompileExpression(t_object_def);
with nd_const_id,c_const_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_I, cd_comp_unit, cd_level, cd_offset);
end;
end; {CompileEnumConst}
procedure CompilelntegerConst(t_const_id: TREE);
^ar
nd_const_id : NODE;
t_object_def : TREE;
begin {CompileConst}
Align(IntegerAl);
GET_NODE(t_const_id, nd_const_id);
GET_NODE(nd_const_id.c_const_id^.sm_first, nd_const_id);
^ith nd_const_id.c_const_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;
IncrementOffset(lntegerSize);
CompileExpression(t_object_def);
^ith nd_const_id.c_const_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_I, cd_comp_unit, cd_level, cd_offset);
end;
e^d; {CompilelntegerConst}
proced-re CompileConst(t_const_id, t_type_spec: TREE);
^egin {CompileConst}
case KIND(t_type_spec) of
_enum_literal_s :
CompileEnumConst(t_const_id, t_type_spec);
_integer :
CompileIntegerConst(t_const_id);
else
GeneralInternalError;
end;
^nd; {CompileConst}
^rocedure CompileDecl_constant(t_constant: TREE);
var
nd_constant, nd_id_s : NODE;
CurrConst                           : SEQ_TYPE;
begin {CompileDecl_var}
GET_NODE(t_constant, nd_constant);
GET_NODE(nd_constant.c_constant^.as_id_s, nd_id_s);
CurrConst := nd_id_s.c_id_s^.as_list;
while not IS_EMPTY^CurrConst) do
begin
CompileConst(HEAD(CurrConst), nd_constant.c_constant^.as_type_spec);
CurrConst := TAIL(CurrConst);
end;
end; {CompileDecl_constant}
{---------------------------------------------^---------------}
{Routines for compiling variable declarations:}
^rocedure CompileAccessVar(t_var_id, t_type_spec: TREE);
var
nd_var_id, nd_access, nd_allocator : NODE;
ValuePtr, DescrPtr : OffsetType;
begin {CompileAccessVar}
GET_NODE(t_var_id, nd_var_id);
GET_NODE(t_type_spec, nd_access);
with nd_var_id.c_var_id^ do
begin
Align(AddrAl);
cd_offset := -OffsetAct;
IncrementOffset(AddrSize);
cd_level    := Level;
cd_comp_unit := CurrCompUnitNr;
if sm_obj_def = NULL_TREE then
begin
Comment := 'null';
Gen1NumT(aLDC, a_A, NULL);
end
else
begin
GET_NODE(sm_obj_def, nd_allocator);
LoadTypeSize(nd_allocator.c_allocator^.as_exp_constrained);
Gen1Num(aALO, Leve1 - LevelOfType(sm_obj_type));
end;
Comment := GetSymbol(lx_symrep);
GenStore(a_A, CurrCompUnitNr, Level, cd_offset);
end;
^nd; {CompileAccessVar}
proce-ure CompileArrayVar(t_var_id, t_type_spec: TREE);
var
nd_var_id, nd_array : NODE;
Val^uePtr, DescrPtr : OffsetType;
begin {CompileArrayVar}
Align(AddrAl);
ValuePtr := -OffsetAct;
GET_NODE(t_var_id, nd_var_id);
^ith nd_var_id.c_var_id^ do
begin
cd_level    := Level;
cd_offset   := ValuePtr;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
end;
PUT_NODE(t_var_id, nd_var_id);
IncrementOffset(AddrSize);
^lign(AddrAl);
I)escrPtr := -OffsetAct;
1ncrementOffset(AddrSize);
GET_NODE(t_type_spec, nd_array);
if nd_array.c_array^.cd_compiled then
begin
Comment := 'array type descriptor';
with nd_array.c_array^ do
GenLoadAddr(cd_comp_unit, cd_level, cd_offset);
GenOT(aDPL, a_A>;
GenStore(a_A, CurrCompUnitNr, Level, DescrPtr);
Gen1NumT(alND, a_I, 0);
Gen1Num(aALO, 0);
Comment := 'array va1ue pointer';
GenStore(a_A, CurrCompUnitNr, Level, ValuePtr);
end
else
begin
GeneralInternalError;
end;
end; {CompileArrayVar}
procedure CompileBoolVar(t_var_id, t_type_spec: TREE);
var
nd_var_id   : NODE;
t_object_def : TREE;
begin {CompileBoolVar}
Align(BoolAl);
GET_NODE(t_var_id, nd_var_id);
with nd_var_id,c_var_id^ do
begin
cd_level    := Level;
cd_offset   := ^OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;
PUT_NODE(t_var_id, nd_var_id);
IncrementOffset(BoolSize);
if t_object_def <> NULL_TREE then
begin
CompileExpression(t_object_def);
with nd_var_id.c_var_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_B, cd_comp_unit, cd_level, cd_offset);
end;
end;
end; {CompileBoolVar}
procedure CompileCharVar(t_var_id, t_type_spec: TREE);
var
nd_var_id   ^ N-DE;
t_object_def : TREE;
begin {CompileCharVar}
Align(CharAl);
SET_NODE(t_var_id, nd_var_id);
^ith nd_var_id,c_var_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;
PUT_NODE(t_var_id, nd_var_id);
IncrementOffset(CharSize);
if t_object_def <> NULL_TREE then
begin
CompileExpression(t_object_def);
with nd_var_id.c_var_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_C, cd_comp_unit, cd_level, cd_offset);
end;
end;
end; {CompileCharVar}
^ocedure CompileEnumVar(t_var_id, t_type_spec: TREE);
^ar
nd_var_id   : NODE;
t_object_def : TREE;
b^gin {CompileEnumVar}
if BooleanType(t_type_spec) then
begin
CompileBoolVar(t_var_id, t_type_spec);
exit;
end
else if CharacterType(t_type_spec) then
begin
CompileCharVar(t_var_id, t_type_spec);
exit;
end;
Align(IntegerAl);
GET_NODE(t_var_id, nd_var_id);
^ith nd_var_id,c_var_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_obj_def;
end;
IncrementOffset(IntegerSize);
if t_object_def <> NULL_TREE then
begin
CompileExpression(t_object_def);
with nd_var_id.c_var_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_I, cd_comp_unit, cd_level, cd_offset);
end;
end;
^nd; {CompileEnumVar}
procedure CompilelntegerVar(t_var_id, t_type_spec: TREE);
var
nd_var_id   : NODE;
t_pbject_def : TREE;
^egin {CompileVar}
Align(IntegerAl);
GET_NODE(t_var_id, nd_var_id);
^ith nd_var_id,c_var_id^ do
begin
cd_level    := Level;
cd_offset   := -OffsetAct;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;
t_object_def := sm_pbj_def;
end;
PUT_NODE(t_var_id, nd_var_id);
IncrementOffset(IntegerSize);
if t_object_def <> NULL_TREE then
begin
CompileExpression(t_object_def);
with nd_var_id.c_var_id^ do
begin
Comment := GetSymbol(lx_symrep);
GenStore(a_I, cd_comp_unit, cd_level, cd_pffset);
end;
end;
^nd; {CompilelntegerVar}
^rocedure CompileVar(t_var_id, t_type_spec: TREE);
^egin {CompileVar}
case KIND(t_type_spec) of
_access :
CompileAccessVar(t_var_id, t_type_spec);
_array :
CompileArrayVar(t_var_id, t_type_spec);
_enum_literal_s :
CompileEnumVar(t_var_id, t_type_spec);
_integer :
CompilelntegerVar(t_var_id, t_type_spec);
else
GenerallnternalError;
end;
end; {CompileVar}
procedure CompileDecl_var(Variable: TREE);
^ar
nd_var, nd_id_s : NODE;
CurrVar        : SE-_TYPE;
begin {CompileDecl_var}
GET_NODE(Variable, nd_var);
SET_NODE(nd_var.c_var^.as_id_s, nd_id_s);
CurrV-r := nd_id_s.c_id_s^.as_list;
^hile not IS_EMPTY(CurrVar) do
begin
with nd_var.c_var^ do
CompileVar(HEAD(CurrVar), as_type_spec);
CurrVar := TAIL(CurrVar);
end;
end; {CompileDecl_var}
{-------------------------------------------------------------}
{^outines for compiling type declarations:}
^rocedure CompileType_access(t_type: TREE);
var
nd_type, nd_type_id, nd_access : NODE;
begin {CompileType_access}
^ET_NODE(t_type, nd_type);
^ET_NODE(nd_type.c_type ^.as_id, nd_type_id);
^ET_NODE(nd_type.c_type^.as_type_spec, nd_access);
^ith nd_access.c_access^ do
begin
cd_constrained := Constrained(as_constrained);
if cd_constrained then
begin
cd_level := Level;
Align(IntegerAI);
cd_offset := OffsetAct;
IncrementOffset(IntegerSize);
LoadTypeSize(as_constrained);
Comment := 'type ' + GetSymbol(nd_type_id.c_type_id^.lx_symrep);
GenStore(a_I, 0, Level, cd_offset)^;
end;
end;
^nd; {CompileType_access}
^rocedure CompileType_Array_Dimension( Dim: SEQ_TYPE; ElType: TREE);
var
idxfac, first, last : OffsetType;
nd_dscrt_range     : NODE;
^egin {CompileType_Array_Dimension}
inc(DimensionsNr);
^lign(IntegerAl);
idxfac := -OffsetAct;
1ncrementOffset(IntegerSize);
^lign(IntegerAl);
first := -OffsetAct;
IncrementOffset(IntegerSize);
Align(IntegerAl);
last := -OffsetAct;
IncrementOffset(IntegerSize);
if IS_EMPTY(TAIL(Dim)) then
begin
LoadTypeSize(ElType);
GenOT(aDPL, a_I);
Comment := 'element size';
GenStore(a_I, 0, Level, idxfac);
end
else
begin
CompileType_Array_Dimension(TAIL(Dim), ElType);
GenOT(aDPL, a_I);
Comment := 'ID)(FAC';
GenStore(a_I, 0, Level, idxfac);
end;
GET_NODE(HEAD(Dim), nd_dscrt_range);
case KIND(HEAD(Dim)) of
_range :
begin
CompileExpression(nd_dscrt_range.c_range^.as_exp1);
Comment := 'FIRST';
GenStore(a_I, CurrCompUnitNr, Level, first);
CompileExpression(nd_dscrt_range.c_range^.as_exp2);
Comment := 'LAST';
GenStore(a_I, 0, Level, last);
GenLoadAddr(0, Level, first);
GenCSP(aLEN);
GenOT(aMUL, a_I);
end;
else
GeneralInternalError;
end;
end; {CompileType_Array_Dimension}
^rocedure CompileType_array(t_type: TREE);
^ar
nd_array, nd_type, nd_type_id,
nd_dscrt_range_s                                 : NODE;
^egin {CompileType_Array}
GET_NODE(t_type, nd_type);
^ET_NODE(nd_type.c_type^.as_type_spec, nd_array);
GET_NODE(nd_type.c_type ^.as_id, nd_type_id);
Comment := 'array ' + GetSymbol(nd_type_id.c_type_id^.lx_symrep);
^riteComment;
^lign(IntegerAl);
^ith nd_array.c_array^ do
begin
cd_offset   := -OffsetAct;
cd_level    := Level;
cd_comp_unit := CurrCompUnitNr;
cd_compiled := true;








unit C-1;
{Constants, types and routines for memory allocation and generating single
A-code instructions.}
interface
uses
CG_Lib,
Private;
const
AddrSize         = 4;
AddrAl              = 2;
BoolSize         = 1;
BoolAl              = 1;
CharSize         = 1;
CharA1              = 1;
IntegerSize  = 2;
IntegerAl       = 2;
StackAl            = 2;
ArrayAl           = 2;
RecordAl         = 2;
FirstParamOffset    = 10;
FirstLocalVarOffset = 0;
RelativeResultOffset = 2;
NULL = 0;
type
aCodelnstructions = (
aABO,     aABS,     aACA,     aACC,     aACT,     aADD,     aALO,     aAND,     aCHR,
aCSP,     aCSTA,   aCSTI,   aCSTS,   aCUP,     aDEC,     aDIV,     aDPL,     aEAC,
aEEX,     aENT,     aEQU,     aETD,     aETE,     aETK,     aETR,     aE)(C,     aEXH,
aEXL,     aE)(P,     aFJP,     aFRE,     aGEQ,     aGET,     aGRE,     alNC,     alND,
al)(A,     aLAO,     aLCA,     aLDA,     aLDC,     aLDO,     aLEQ,     aLES,     aLOD,
aLVB,     aMOD,     aMOV,     aMST,     aMUL,     aMVV,     aNEG,     aNEO,     aNOT,
aORR,     aPKB,     aPKG,     aPRO,     aPUT,     --,          aRAI,     aREM,     aRET,
aRFL,     aRFP,     aSRO,     aSTO,     aSTR,     aSUB,     aSWP,     aTJP,     aUJP,
a)(OR,     aXJP
);
aCodeTypes =   (
a_A,       {Address}
a_B,        {Boolean}
a_C,       {Character}
a_l        {lnteger}
^;
aCodeStandardProcs = (
aAR1,  aAR2,  aCLB,  aCLN,  aCNT,  aCVB,  aCYA,  aLBD,  aLEN,  aPUA,
aTRM
^;
var
GenerateCode       : Boo1ean;  {if FALSE ignore procedures generating
A-code instructions}
Comment                               : String;     {Comment to be printed}
CurrCompUnitNr      : Byte;       {Current compi1ation unit number}
TopAct := TopAct + PD)([P];
if TopAct > TopMax then
TopMax := TopAct;
Write(OutFile, ' CSP      ');
case P of
aAR1 : Write(OutFile, 'AR1');
aAR2 : Write(OutFile, 'AR2');
aCLB : Write(OutFile, 'CLB');
aCLN : Write(OutFile, 'CLN');
aCNT : Write(OutFile, 'CNT');
aCVB : Write(OutFile, 'CVB');
aCYA : Write(OutFile, 'CYA');
aLBD : Write(OutFile, 'LBD');
aLEN : Write(OutFile, 'LEN');
aPUA : Write(OutFile, 'PUA');
aTRM : Write(OutFile, 'TRM');
else ConditionalError(8, true);
end;
IntWriteComment(20);
end;
end; {GenCSP}
{If 'Lvl' eguals 0 (i.e. it is memory allocated for global objects of
'package' or 'package body' compilation unit) generate instruction
LA- otherwise - LDA.}
procedure GenLoadAddr( CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
begin {GenLoadAddr}
if Lvl = 0 then
Gen2NumNum(aLAO, CompUnitNr, Offs)   {Global}
else
Gen2NumNum(aLDA, Level - Lvl, Offs);      {Local}
end; {GenLoadAddr}
procedure GenLoad( aCT: aCodeTypes; CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
begin {GenStore}
if Lvl - 0 then
Gen2NumNumT(aLDO, aCT, CompUnitNr, Offs)     {Global}
else
Gen2NumNumT(aLOD, aCT, Level - Lvl, Offs);       {Local}
end; {GenLoad}
procedure GenStore( aCT: aCodeTypes; CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
begin {GenStore}
if Lvl = 0 then
Gen2NumNumT(aSRO, aCT, CompUnitNr, Offs)     {Global}
else
Gen2NumNumT(aSTR, aCT, Level - Lvl, Offs);       {Local}
end; {GenStore}
{-------------------------------------------------------------}
{Routines for memory allocation:}
procedure IncrementOffset(V: integer);
begin
ConditionalError(5005, OffsetAct + V >= MaxOffset);
inc(OffsetAct, V);
if OffsetAct > OffsetMax then
OffsetMax := OffsetAct;
end; {lncrementOffset}
{Align 'OffsetAct' according to the alignment 'al'.}
procedure Align(al: integer);
var
Temp: integer;
begin {Align}
Temp       := Pred(OffsetAct + al);
OffsetAct := Temp - Temp mod al;
if OffsetAct > OffsetMax then
OffsetMax := OffsetAct;
end; {Align}
procedure IncrementLevel;
begin
ConditionalError(5005, Level >= MaxLevel);
inc(Level);
end; {IncrementLevel}
procedure DecrementLevel;
begin
ConditionalError(9, Level <= 0);
dec(Level);
end; {DecrementLevel}
begin {CG1}
IntLabel := 1;
InitCD)(;
InitPD)(;
end. {CG1}
Level                                    : LevelType;   {Current level}
OffsetAct, OffsetMax,
TopAct, TopMax      : OffsetType;
{--------------------^----------------------------------------}
{Function generating labels:}
function NextLabel: LabelType;
{----^^^^^^^^^^^^^^^--^--^^-----^---^---^^---^-^^--^-------^}
{Routines writing directly to output file:}
procedure OpenOutputFile(FileName: String);
procedure CloseOutputFile;
procedure WriteComment;
procedure WriteLabel(Lbl: LabelType);
procedure GenLabelAssignment(Lbl: LabelType; N: integer);
procedure GenO(aCI: aCodelnstructions);
procedure GenOT(aCI: aCodelnstructions; aCT: aCodeTypes);
procedure Gen1T(aCI: aCodelnstructions; aCT: aCodeTypes; v: Value);
procedure Gen1Lb1(aCI: aCodelnstructions; L: LabelType);
procedure Gen1Num(aCI: aCodelnstructions; N: integer);
procedure Gen1NumT(aCI: aCodelnstructions; aCT: aCodeTypes; 0: integer);
procedure Gen1Str(aCI: aCodelnstructions; S: String);
procedure Gen2LblLbl(aCI: aCodelnstructions; L1, L2: LabelType);
procedure Gen2LblStr(aCI: aCodelnstructions; L: LabelType; S: String);
procedure Gen2NumLbl(aCI: aCodelnstructions; N: integer; L: LabelType);
procedure Gen2NumNum(aCI: aCodelnstructions; P, Q: integer);
procedure Gen2NumNumT(aCI: aCodelnstructions; aCT: aCodeTypes; P, O: integer)
procedure Gen2NumStr(aCI: aCodelnstructions; N: integer; S: String);
procedure GenCSP(P: aCodeStandardProcs);
procedure GenLoadAddr( CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
procedure GenLoad( aCT: aCodeTypes; CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
procedure GenStore( aCT: aCodeTypes; CompUnitNr: Byte;
Lvl: LevelType; Offs: integer);
{----^^-^^-^-^-^^^-^---^^-^^^-^^--^--^^--^^^-^---^^---^^----}
procedure IncrementLevel;
procedure DecrementLevel;
procedure IncrementOffset(V: integer);
procedure Align(al: integer);
{-------------------------------------------------------------}
implementation
var
OutFile                               : Text;       {File with generated A-code}
IntLabel                             : LabelTyoe;   {Last label generated by 'NextLabel'}
CDX                                        : array[aCodelnstructions] of Shortlnt; {Effect of
A-code instructions on stack}
^  PD)(                                        : array[aCodeStandardProcs] of Shortlnt; {Effect of
standard procedures on stack}
{-------------------------------------------------------------}
procedure ConditionalError(ErrorNumber: integer; ErrorCondition: Boolean);
begin
if ErrorCondition then
begin
WriteComment;
Close(OutFile);
Error(ErrorNumber);
end;
end; {ConditionalError}
procedure InitCD)(;
begin
CD)([aABO] :- -4; CD)([aAB-]  :-  0;  CD)([aACA] := -2;
CD)([aACC] :^ -4; CD)([aACT] :=  0;  CD)([aADD] := -4;
CD)([aALO]  :=  4;  CD)([aAND]  := -4;  CD)([aCHR] :=  0;
CD)([aC-P] :^  0;  CD)([aCSTA] :=  0; CD)([aC-TI] :^  0;
CD)([aCSTS] := 0; CD)([aCUP] := 0; CD)([aDEC] := 0;
CD)([aDIV]  := -4;  CD)([aDPL]  :=  4;  CD)([aEAC]  :=  0;
CD)([aEE)(] := 0; CD)([aENT] :- 0; CD)([aE-U] := -4;
CD)([aETD] := 0; CD)([aETE] := 0; CD)([aETK] := 0;
CD)([aETR] :-  0; CD)([aE)(C] :=  0;  CD)([aE)(H] :=  0;
CD)([aE)(L] := 0; CD)([aE)(P] := -4; CD)([aFJP] :^ 0;
CD)([aFRE] := -4; CD)([a-E-] := ^4;  CD)([a-ET] :=  0;
CD)([aGRE]  := -4;  CD)([aINC]  :=  0;  CD)([aIND]  :=  0;
CD)([aI)(A] := -4; CD)([aLAO] := 4; CD)([aLCA] := 4;
CD)([aLDA] := 4; CD)([aLDC] := 4; CD)([aLDO] := 4;
CD)([aLE-] := -4;  CD)([aLES]  := -4;  CD)([aLOD]  :=  4;
CD)([aLVB] := 0; CD)([aMOD] := -4; CD)([aMOV] := -8;
CD)([aMST] := 0; CD)([aMUL] := -4; CD)([aMVV] := -12;
CD)([^NE-] :=  0; CD)([aNE-]  := -4;  CD)([aNOT] :-  0;
CD)([aORR] := -4; CD)([aPKB] := 0; CD)([aPKG] := 0;
CD)([aPRO] := 0; CD)([aPUT] := 0; CD)([aO] := 0;
CD)([aRAI]  :=  0;  CD)([aREM]  := -4;  CD)([aRET]  :=  0;
CD)([aRFL]  :=  0;  CD)([aRFP] :=  0;  CD)([aSRO] :^ -4;
CD)([aSTO] := -8; CD)([aSTR] := -4; CD)([aSUB] := -4;
CD)([aSWP]  :=  0;  CD)([aTJP]  := -4;  CD)([aUJP]  :=  0;
CD)([a)(JP]  :=  0;  CD)([a)(OR] := -4;
end; {InitCD)(}
^ procedure InitPD)(;
^ begin
^  PD)([aAR1] :=  0;     PD)([aAR2]   :=     -4;  PD)([aCLB] :=  0;
PD)([aCLN] := -8;     PD)([aCNT]   :=     -8;  PD)([aCVB] := -4;
^  PD)([aCYA] := -12;     PD)([aLEN]   :=       0;  PD)([aLBD] := -4;
PD)([aPUA] := -16;     PD)([aTRM]   :=       0;
end; {lnitPD)(}
{---^^----^^^-^-^^^^^-^-^^^^-^-^^^^---^^^--^-^^^-^----^^^----^}
{Function generating distinct labels.}
function NextLabel: LabelType;
begin
ConditionalError(5004, 1ntLabel >= MaxLabel);
inc(IntLabel);
^extLabel := IntLabel;
end; {NextLabel}
{--^-----^^-^^-^^^^^^^^^^^^^-^^^^^^^-^^---^^^^^^^^^---^^^-^}
{Routines writing directly to output file.}
procedure OpenOutputFile(FileName: String);
begin {OpenOutputFile}
Assign(OutFile, FileName);
{^I-}
Re^rite(OutFile);
{^I+}
ConditionalError(10, IOResu1t <> 0);
end; {OpenOutputFile}
procedure CloseOutputFile;
begin {CloseOutputFile}
Close(OutFile);
end; {CloseOutputFile}
{Internal procedure for writing comments. If the variable 'Comment' is empty
just writes new line otherwise prints out the variable
preceded by 't' spaces and two adjacent hyphens and clears it.}
procedure IntWriteComment(t: Byte);
begin {IntWriteComment}
if GenerateCode then
begin
if Comment <> '' then
begin
WriteLn(OutFile, '- ': t + 3, Comment);
Comment := '';
end
else
WriteLn(OutFile);
end;
end; {IntWriteComment}
{Procedure writing comment stored in variable 'Comment'.}
procedure WriteComment;
begin {WriteComment}
IntWriteComment(0);
end; {WriteComment}
{Procedure for writing type of A-code instruction, i.e. one of the following
letters: A, B, C, I.}
procedure WriteACodeType(aCT: aCodeTypes);
begin {WriteACodeType}
case aCT of
a_A : Write(OutFile, 'A');
a_B : Write(OutFile, 'B');
^    a_C : Write(OutFile, 'C');
^    a_I : Write(OutFile, 'I');
^    else ConditionalError(8, true);
end;
end; {WriteACodeType}
{Procedure writing label and comment.}
procedure WriteLabel(Lbl: LabelType);
^ begin
^rite(OutFile, 'L', Lbl: 6);
IntWriteComment(27);
end; {WriteLabel}
procedure GenLabelAssignment(Lbl: LabelType; N: integer);
begin
^rite(OutFile, 'L', Lbl: 6, '=': 5, N: 7);
IntWriteComment(15);
end; {GenLabelAssignment}
{Adjust 'TopAct' and 'TopMax' if reguired, according to the worst possible
effe-t of the instruction 'aCI' on stack.}
procedure Mes(aCI: aCodeInstructions);
begin {Mes}
TopAct := TopAct + CD)([aCI];
if TopAct > TopMax then
TopMax := TopAct;
end; {Mes}
{Generate parameterless untyped instruction.}
procedure GenO(aCI: aCodeInstructions);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aAND : Write(OutFiIe, ' AND');
aEE)( : Write(OutFile, ' EE)(');
aNOT : Write(OutFile, ' NOT');
aORR : Write(OutFile, ' ORR');
aRAI : Write(OutFile, ' RAI');
a)(OR : Write(OutFile, ' )(OR');
a- : Write(OutFile, ' - ');
else ConditionalError(8, true);
end;
IntWriteComment(30);
end;
^ end; {GenO}
{Generate parameterless typed instruction.}
procedure GenOT(aCI: aCodeInstructions; aCT: aCodeTypes);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aADD : Write(OutFile,   '   ADD');
aDIV : Write(OutFile,   '   DIV');
aDPL : Write(OutFile,   '   DPL');
aE)(P : Write(OutFile,   '   E^P');
aEQU : Write(OutFile,   '   EQU');
aGEQ : Write(OutFile,   '   GEQ');
aGRE : Write(OutFile,   '   GRE');
aLEQ : Write(OutFile,   '   LEQ');
aLES : Write(OutFile,   '   LES');
aMOD : Write(OutFile,   '   MOD');
aMUL : Write(OutFile,   '   MUL');
aNEQ : Write(OutFile,   '   NEQ');
aREM : Write(OutFile,   '   REM');
aSTO : Write(OutFile,   '   STO');
aSUB : Write(OutFile,   '   SUB');
aSWP : Writ-(OutFile^   '   SWP');
else ConditionalError(8,   true);
end;
WriteACodeType(aCT);
IntWriteComment(15);
end;
end; {GenOT}
{Generate typed instruction with one parameter.}
procedure Gen1T(aCI: aCodelnstructions; aCT: aCodeTypes; v: Value);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aLDC : Write(OutFile, ' LDC');
else ConditionalError(8, true);
end;
case aCT of
a_B : Write(OutFile, 'B', v.boo_val: 7);
a_C :
if v.chr_val = ^127 then
Write(OutFi1e, 'C', '^127': 7)
e1se if v.chr_va1 < ' ' then
Write(OutFi1e, 'C', '^': 5, ord(v.chr_val))
else
Write(OutFile, 'C', '''': 6, v.chr_val, '''');
a_I : Write(OutFile, 'I', v.int_val: 7^;
else ConditionalError(8, true);
end;
IntWriteComment(22);
end;
end; {Gen1T}
procedure Gen1Lbl(aCI: aCodeInstructions; L: LabelType);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aE)(H : Write(OutFile, ' E)(H');
aFJP : Write(OutFile, ' FJP');
aLVB : Write(OutFile, ' LVB');
aRAI : Write(OutFile, ' RAI');
aRFL : Write(OutFile, ' RFL');
aTJP : Write(OutFile, ' TJP');
aUJP : Write(OutFile, ' UJP');
else ConditionalError(8, true);
end;
Write(OutFile, 'L': 8, L: 7);
IntWriteComment(15);
end;
end; {Gen1Lbl}
procedure Gen1Num(aCI: aCodelnstructions; N: integer);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aALO : Write(OutFi1e, ' ALO');
aGET : Write(OutFile, ' GET');
al)(A : Write(OutFile, ' I)(A');
aMST : Write(OutFile, ' MST');
aPUT : Write(OutFile, ' PUT');
aRET : Write(OutFile, ' RET');
else ConditionalError(8, true);
end;
Write(OutFile, N: 8);
IntWriteComment(22);
end;
end; {Gen1Num}
proced-re Gen1NumT(aCI: aCodelnstructions; aCT: aCodeTypes; -: integer);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aDEC : Write(OutFile, ' DEC');
aINC : Write(OutFile, ' INC');
aIND : Write(OutFile, ' 1ND');
aLDC : Write(OutFile, ' LDC');
else ConditionalError(8, true);
end;
WriteACodeType(aCT);
Write(OutFile, Q: 7);
IntWriteComment(22);
end;
end; {Gen1NumT}
procedure Gen1Str(aCI: aCodelnstructions; S: String);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aPKB : Write(OutFile, ' PKB');
aPKG : Write(OutFile, ' PKG');
aPRO : Write(OutFile, ' PRO');
else ConditionalError(8, true);
end;
Write(OutFile, '': 7, S);
IntWriteComment(15);
end;
end; {Gen1Str}
procedure Gen2LblLbl(aCI: aCodelnstructions; L1, L2: LabelType);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aE)(C : Write(OutFile, ' E)(C');
else ConditionalError(8, true);
end;
Write(OutFile, 'L': 8, L1: 7, 'L': 7, L2: 7);
IntWriteComment(1);
end;
end; {Gen2Lb1Lbl}
procedure Gen2Lb1Str(aCI: aCodelnstructions; L: LabelType; S: String);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aE)(L : Write(OutFile, ' E)(L');
else ConditionalError(8, true);
end;
Write(OutFile, 'L': 8, L: 7, '': 6, S);
IntWriteComment(15);
end;
end; {Gen2Lb1Str}
procedure Gen2NumLb1(aCI: aCodelnstructions; N: integer; L: Labe1Type);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aCUP : Write(OutFi1e, ' CUP');
aENT : Write(OutFi1e, ' ENT');
e1se ConditionalError(8, true);
end;
^rite(OutFile, N: 8, 'L': 7, L: 7);
IntWriteComment(8);
end;
end; {Gen2NumLbl}
procedure Gen2NumNum(aCI: aCodelnstructions; P, -: integer);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aLDA : Write(OutFile, ' LDA');
aLAO : Write(OutFile, ' LAO');
aMST : Write(OutFile, ' MST');
else ConditionalError(8, true);
end;
Write(OutFile, P: 8, Q: 7);
IntWriteComment(15);
end;
end; {Gen2NumNum}
proce-ure Gen2NumNumT(aCI: aCodelnstructions; aCT: aCodeTypes; P, Q: integer);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aLDO : Write(OutFile, ' LDO');
aLOD : Write(OutFile, ' LOD');
aSRO : Write(OutFile, ' SRO');
aSTR : Write(OutFile, ' STR');
else ConditionalError(8, true);
end;
WriteACodeType(aCT);
Write(OutFile, P: 7, Q: 7);
IntWriteComment(15);
^  end;
end; {Gen2NumNumT}
procedure Gen2NumStr(aCI: aCodelnstructions; N: integer; S: String);
begin
if GenerateCode then
begin
Mes(aCI);
case aCI of
aRFP : Write(OutFi1e, ' RFP');
else ConditionalError(8, true);
end;
Write(OutFile, N: 8, '': 6, S);
IntWriteComment(15);
end;
end; {Gen2NumStr}
procedure GenCSP(P: aCodeStandardProcs);
begin {GenCSP}
if GenerateCode then
begin









unit CG_Param;
{Routines fo compiling parameters declaration and for generating code
for copying out parameters of modes 'in out' and 'out'.}
interface
uses
C-1,
CG_Expr,
CG_Lib,
Diana,
Private;
{Routine for compiling parameters declarations.}
procedure CompileParams(CurrParam : SEQ_TYPE);
{Routine generating code for copying out parameters of modes 'in out' ^ 'out'
procedure CopyOutParams(t_param_s: TREE);
{-------------------------------------------------------------}
implementation
procedure ConditionalError(ErrorCode:integer; Condition: Boolean);
begin {ConditionalError}
if Condition then
begin
CloseOutputFile;
Error(ErrorCode);
end;
end; {ConditionalError}
procedure GenerallnternalError;
begin {GenerallnternalError}
ConditionalError(999, true);
end; {GenerallnternalError}
{-------------------------------------------------------------}
{Allocate space for parameter of specified type}
function AllocateSpaceForType(t_type_spec: TREE): OffsetType;
begin {AllocateSpaceForType}
case KIND(t_type_spec) of
_access :
begin
IncrementOffset(AddrSize);
Align(AddrAl);
AllocateSpaceForType := OffsetAct;
end;
_array :
begin
IncrementOffset(AddrSize);
Align(AddrAl);
IncrementOffset(AddrSize);
Align(AddrAl);
AllocateSpaceForType := OffsetAct;
end;
_enum_literal_s,
_integer :
begin
IncrementOffset(IntegerSize);
Align(IntegerAl);
AllocateSpaceForType := OffsetAct;
end;
else
GeneralInternalError;
end;
end; {AllocateSpaceForType}
procedure CompileParams_in(CurrParam : SEO_TYPE);
var
nd_in, nd_id_s, nd_in_id : NODE;
begin {CompileParams_in}
if IS_EMPTY(CurrParam) then
exit;
CompileParams_in(TAIL(CurrParam));
GET_NODE(HEAD^CurrParam), nd_in_id);
with nd_in_id.c_in_id^ do
begin
cd_offset := AllocateSpaceForType(sm_obj_type);
cd_level  := Level;
end;
end; {CompileParams_in}
procedure CompileParams_in_out(CurrParam : SEQ_TYPE);
var
nd_in_out, nd_id_s, nd_in_out_id : NODE;
begin {CompileParams_in_out}
if IS_EMPTY(CurrParam)^ then
exit;
CompileParams_in_out(TAIL(CurrParam));
GET_NODE(HEAD^(CurrParam), nd_in_out_id);
with nd_in_out_id.c_in_out_id^ do
begin
cd_val_offset := AllocateSpaceForType(sm_obj_type);
IncrementOffset(AddrSize);
Align(AddrAl);
cd_addr_offset := OffsetAct;
cd_level     := Level;
end;
end; {CompileParams_in_out}
procedure CompileParams_out(CurrParam : SEQ_TYPE);
var
nd_out, nd_id_s, nd_out_id : NODE;
begin {CompileParams_out}
if IS_EMPTY(CurrParam) then
exit;
CompileParams_put(TAlL(CurrParam));
GET_NODE(HEAD^CurrParam), nd_out_id);
with nd_out_id.c_out_id^ do
begin
cd_val_offset := AllocateSpaceForType(sm_obj_type);
IncrementOffset(AddrSize);
Align(AddrAl);
cd_addr_offset := OffsetAct;
cd_level     := Level;
end;
end; {CompileParams_out}
procedure CompileParams(CurrParam : SEQ_TYPE);
var
nd, nd_id_s : NODE;
begin {CompileParams}
if IS_EMPTY(CurrParam) then
exit;
CompileParams(TAIL(CurrParam));
GET_NODE(HEAD(CurrParam), nd);
case KIND(HEAD(CurrParam)) of
_in :
begin
GET_NODE(nd.c_in^.as_id_s, nd_id_s);
CompileParams_in(nd_id_s.c_id_s^.as_list);
end;
_in_out :
begin
GET_NODE(nd.c_in_out^.as_id_s, nd_id_s);
CompileParams_in_put(nd_id_s.c_id_s".as_list);
end;
_put :
begin
GET_NODE(nd.c_out^.as_id_s, nd_id_s);
CompileParams_put(nd_id_s.c_id_s ^.as_list);
end;
else
GenerallnternalError;
end;
end; {CompileParams}
{-------------------------------------------------------------}
procedure CopyOutParams(t_param_s: TREE);
var
nd_param_s, nd_curr_param : NODE;
CurrParam                                  : SEO_TYPE;
t_curr_param                            : TREE;
procedure CopyOut(t_type_spec: TREE; Offset: OffsetType);
begin {CopyOut}
case KIND(t_type_spec) of
_access :
begin
Gen2NumNumT(aLOD, a_A, 0, Offset);
GenOT(aSTO, a_A);
end;
_array : ; {do nothing}
_enum_literal_s :
if BooleanType(t_type_spec) then
begin
Gen2NumNumT(aLOD, a_B, 0, Offset);
-enOT(a-TO, a_B);
end
else if CharacterType(t_type_spec) then
begin
Gen2NumNumT(aLOD, a_C, 0, Offset);
GenOT(aSTO, a_C);
end
else
begin
Gen2NumNumT(aLOD, a_I, 0, Offset);
GenOT(aSTO, a_I);
end;
_integer :
begin
Gen2NumNumT(aLOD, a_I, 0, Offset);
GenOT(aSTO, a_I);
end;
else
GeneralInternalError;
end;
end; {CopyOut}
procedure CopyOutParams_in_out;
var
nd_id_s, nd_in_out_id : NODE;
CurrParam                          : SEQ_TYPE;
begin {CopyOutParams_in_out}
GET_NODE(nd_curr_param.c_in_out^.as_id_s, nd_id_s);
CurrParam := nd_id_s.c_id_s^.as_list;
while not IS_EMPTY^CurrParam) do
begin
GET_NODE(HEAD(CurrParam), nd_in_out_id);
with nd_in_out_id.c_in_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumNumT(aLOD, a_A, 0, cd_addr_offset);
CopyOut(sm_obj_type, cd_val_offset);
end;
CurrParam := TAIL(CurrParam);
end;
end; {CopyOutParams_in_out}
procedure CopyOutParams_out;
var
nd_id_s, nd_out_id : NODE;
CurrParam        : SEQ_TYPE;
begin {CopyOutParams_out}
GET_NODE(nd_curr_param.c_out^.as_id_s, nd_id_s);
CurrParam := nd_id_s.c_id_s^.as_Iist;
while not IS_EMPTY^CurrParam) do
begin^
GET_NODE(HEAD(CurrParam), nd_out_id);
with nd_out_id.c_out_id^ do
begin
Comment := GetSymbol(lx_symrep);
Gen2NumNumT(aLOD, a_A, 0, cd_addr_offset);
CopyOut(sm_obj_type, cd_val_offset);
end;
CurrParam := TAIL(CurrParam);
end;
end; {CopyOutParams_out}
begin {CopyOutParams}
if t_param_s = NULL_TREE then
exit;
GET_NODE(t_param_s, nd_param_s);
CurrParam := nd_param_s.c_param_s^.as_list;
while not IS_EMPTY(CurrParam) do
begin
t_curr_param := HEAD(CurrParam);
GET_NODE(t_curr_param, nd_curr_param);
case KIND(t_curr_param) of
_in    : ; {in mode - do nothing}
_in_out : CopyOutParams_in_out;
_out   : CopyOutParams_out;
else
GeneralInternalError;
end;
CurrParam := TAIL(CurrParam);
end;
end; {CopyOutParams}
end. {CG_Param}










unit Diana;
{Unit containing DIANA definitions.
Definition of data structures are followed by subroutines performing
basic operations.}
interface
uses
CG_Lib,
Private;
const
NULL_TREE = 0;
type TREE       = Word;
SE-_TYPE    = ^SE-^TYPE_REC;
SEQ_TYPE_REC = record
elem : TREE;
next : SEO_TYPE;
end;
NODE_NAME = (
_abort,                           _accept,                        _access,                        _address,
_aggregate,       _alignment,                   _all,                              _allocator,
_alternative,      _alternative_s,           _argument_id,               _array,
_assign,                         _assoc,                           _attr_id,                      _attribute,
_attribute_call,   _binary,                         _block,                          _bo^,
_case,                            _choice_s,                     _code,                            _comp_id,
_comp_rep,        _comp_rep_s,                 _comp_unit,                   _compilation,
_cond_clause,      _cond_entry,                 _const_id,                    _constant,
_constrained,      _context,                       _conversion,                 _decl_s,
_def_char,        _def_op,                        _deferred_constant, _delay,
_derived,                       _dscrmt_aggregate,  _dscrmt_id,                   _dscrmt_var,
_dscrmt_var_s,     _dscrt_range_s,           _entry,                          _entry_call,
_entry_id,        _enum_id,                       _enum_literal_s,   _exception,
_exception_id,     _e^it,                            _e^p_s,                          _fixed,
_float,                           _for,                              _formal_dscrt,             _formal_fixed,
_formal_float,     _formal_integer,         _function,                    _function_call,
_function_id,      _generic,                       _generic_assoc_s,  _generic_id,
_generic_param_s,  _goto,                            _id_s,                            _if,
_in,                                ^i^^id,                          -^^-^^^                          _in_out,
_in_out_id,       _index,                          _indexed,                      _inner_record,
_instatiation,     _integer,                       _item_s,                        _iteration_id,
_l_private,       _label_id,                     _labeled,                       _loop,
_l_private_type_id, _membership,                 _name_s,                        _named,
_named_stm,       _named_stm_id,             _no_default,                 _not_in,
_null_access,      _null_comp,                   _null_stm,                     _number,
_number_id,       _numeric_literal,       _others,                        _out,
_out_id,                        _package_body,             _package_ded,             _package_id,
_package_spec,     _param_assoc_s,           _param_s,                      _parenthesized,
_pragma,                        _pragma_id,                   _pragma_s,                    _private,
_private_type_id,  _proc_id,                       _procedure,                   _procedure_call,
_gualified,       _raise,                          _range,                          _record,
_record_rep,       _rename,                        _retum,                        _reverse,
_select,                         _select_clause,           _select_clause_s,  _selected,
_simple_rep,       _slice,                          _stm_s,                          _string_literal,
_stub,                            _subprogram_body,       _subprogram_decl,  _subtype,
r_l_private_type_id    = record
lx_symrep                              : symbol_rep;
sm_type_spec                        : TREE;
end;
r_label_id                            = record
lx_symrep                              : symbol_rep;
sm_stm                                    : TREE;
end;
r_labeled                              = record
as_id_s                                  : TREE;
as_stm                                    : TREE;
end;
r_loop                                    = record
as_iteration                        : TREE;
as_stm_s                                : TREE;
cd_level                                : LevelType;
cd_after_loop_label    : LabelType;
end;
r_membership                        = record
as_exp                                    : TREE;
as_membership_op       : TREE;
as_type_range                      : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_name_s                                = record
as_list                                  : SEQ_TYPE;
-nd;
r_named                                  = record
as_choice_s                          : TREE;
as_exp                                    : TREE;
end;
r_named_stm                          = record
as_id                                      : TREE;
as_stm                                    : TREE;
^nd;
r_named_stm_id        = record
lx_symrep                              : symbol_rep;
sm_stm                                    : TREE;
cd_label                                : LabelType;
end;
r_no_default                        = record
end;
r_not_in                                = record
end;
r_null_access                      = record
sm_exp_type     : TREE;
sm_value       : value;
end;
r_null_comp                          = record
end;
r_null_stm                            = record
end;
r_number                                = record
as_id_s                                  : TREE;
as_exp                                    : TREE;
end;
r_number_id                          = record
1x_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_init_exp                          : TREE;
-nd;
r_numeric_literal     = record
1x_numrep                              : number_rep;
sm_exp_type                          : TREE;
sm_yalue                                : value;
end;
r_others                                = record
end;
r_out                                      = record
as_exp_yoid                          : TREE;
as_id_s                                  : TREE;
as_name                                  : TREE;
end;
r_out_id                                = record
lx_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_first                                : TREE;
cd_level                                : LevelType;
cd_addr_offset        : OffsetType;
cd_val_offset                      : OffsetType;
end;
r_package_body        = record
as_id                                      : TREE;
as_block_stub                      : TREE;
end;
r_package_decl        = record
as_id                                      : TREE;
as_package_def        : TREE;
end;
r_package_id                        = record
lx_symrep                              : symbol_rep;
sm_spec                                  : TREE;
sm_body                                  : TREE;
sm_address                            : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
cd_compiled                          : Boolean;
-nd;
r_package_spec        = record
as_decl_s1                            : TREE;
as_dec1_s2                            : TREE;
end;
r_param_assoc_s       = record
as_1ist                                  : SEQ_TYPE;
end;
r_param_s                              = record
as_list                                  : SEQ_TYPE;
end;
r_parenthesized       = record
as_exp                                    : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_pragma                                = record
as_id                                      : TREE;
as_param_assoc_s      : TREE;
end;
r_pragma_id                          = record
as_list                                  : SEQ_TYPE;
lx_symrep                              : symbol_rep;
end;
r_pragma_s                            = record
as_list                                  : SEQ_TYPE;
end;
r_private                              = record
sm_discriminants       : TREE;
end;
r_private_type_id     = record
lx_symrep                              : symbol_rep;
sm_type_spec                        : TREE;
end;
r_proc_id                              ^ record
lx_symrep                              : symbol_rep;
sm_spec                                  : TREE;
sm_body                                  : TREE;
sm_location                          : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
cd_label                                : LabelType;
cd_level                                : LevelType;
cd_param_size                      : OffsetType;
cd_compiled                          : Boolean;
end;
r_procedure                          = record
as_param_s                            : TREE;
end;
r_procedure_call      = record
as_name                                  : TREE;
as_param_assoc_s      : TREE;
sm_normalized_param_s  : TREE;
end;
r_gualified                          = record
as_name                                  : TREE;
as_exp                                    : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_raise                                  = record
as_name_void                        : TREE;
end;
r_range                                  = record
as_expl                                  : TREE;
as_exp2                                  : TREE;
sm_base_type                        : TREE;
end;
r_record                                = record
as_list                                  : SEO_TYPE;
sm_packing                            : Boolean;
sm_discriminants      : TREE;
sm_size                                  : TREE;
sm_record_spec        : TREE;
end;
r_record_rep                        = record
as_alignment                        : TREE;
as_name                                  : TREE;
as_comp_rep_s                      : TREE;
end;
r_rename                                = record
as_name                                  : TREE;
end;
r_return                                = record
as_exp_void                          : TREE;
end;
r_reverse                              = record
as_id                                      : TREE;
as_dscrt_range        : TREE;
^nd;
r_select                                = record
as_stm_s                                : TREE;
as_select_clause_s     : TREE;
end;
r_select_clause       = record
as_exp_void                          : TREE;
as_stm_s                                : TREE;
end;
r_select_dause_s     = record
as_list                                  : SEQ_TYPE;
end;
r_selected                            = record
as_name                                  : TREE;
as_designator_char     : TREE;
sm_exp_type                          : TREE;
end;
r_simple_rep                        = record
as_name                                  : TREE;
as_exp                                    : TREE;
end;
r_slice                                  = record
as_name                                  : TREE;
as_dscrt_range        : TREE;
sm_exp_type                          : TREE;
sm_constraint                      : TREE;
end;
r_stm_s                                  = record
as_list                                  : SE-_TYPE;
end;
r_string_literal      = record
1x_symrep                              : symbol_rep;
sm_exp_type                          : TREE;
sm_constraint                      : TREE;
sm_value                                : value;
end;
r_stub                                    = record
end;
r_subprogram_body     = record
as_designator        : TREE;
as_header                              : TREE;
as_block_stub                      : TREE;
end;
r_subprogram_decl     = record
as_designator                      : TREE;
as_header                              : TREE;
as_subprogram_def      : TREE;
end;
r_subtype                              = record
as_constrained        : TREE;
as_id                                      : TREE;
end;
r_subtype_id                        = record
lx_symrep                              : symbol_rep;
sm_type_spec                        : TREE;
end;
r_subunit                              = record
as_name                                  : TREE;
as_subunit_body       : TREE;
end;
r_task_body                          = record
as_id                                      : TREE;
as_block_stub                      : TREE;
end;
r_task_body_id        = record
1x_symrep                              : symbol_rep;
sm_type_spec                        : TREE;
sm_body                                  : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
end;
r_task_decl                          = record
as_id                                      : TREE;
as_task_def                          : TREE;
end;
r_task_spec                          = record
as_decl_s                              : TREE;
sm_body                                  : TREE;
sm_address                            : TREE;
sm_storage_size       : TREE;
end;
r_terminate                          = record
end;
r_timed_entry                      = record
as_stm_sl                              : TREE;
as_stm_s2                              : TREE;
end;
r_type                                    = record
as_id                                      : TREE;
as_dscrmt_var_s       : TREE;
as_type_spec                        : TREE;
end;
r_type_id                              = record
1x_symrep                              : symbol_rep;
sm_type_spec                        : TREE;
sm_first                                : TREE;
end;
r_universal_fixed     ^ record
end;
r_universal_integer    = record
end;
r_universal_real      = record
end;
r_use                                      = record
as_list                                  : SEQ_TYPE;
end;
r_used_bltn_id        = record
1x_symrep                              : symbol_rep;
sm_operator                          : operator;
end;
r_used_bltn_op        = record
1x_symrep                              : symbol_rep;
sm_operator                          : operator;
end;
r_used_char                          = record
1x_symrep                              : symbol_rep;
sm_defn                                  : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_used_name_id        = record
1x_symrep                              : symbol_rep;
sm_defn                                  : TREE;
end;
r_used_object_id      = record
1x_symrep                              : symbol_rep;
sm_defn                                  : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_used_op                              = record
lx_symrep                              : symbol_rep;
sm_defn                                  : TREE;
end;
r_var                                      = record
as_id_s                                  : TREE;
as_type_spec                        : TREE;
as_object_def                      : TREE;
end;
r_var_id                                = record
1x_symrep                              : symbol_rep;
sm_address                            : TREE;
sm_obj_type                          : TREE;
sm_obj_def                            : TREE;
cd_comp_unit                        : Byte;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
cd_compiled                          : Boolean;
end;
r_variant                              = record
as_choice_s                          : TREE;
as_record                              : TREE;
end;
r_variant_part        = record
as_name                                  : TREE;
as_variant_s                        : TREE;
end;
r_variant_s                          = record
as_list                                  : SEQ_TYPE;
end;
r_void                                    = record
end;
r_while                                  = record
as_exp                                    : TREE;
end;
r_with                                    = record
as_list                                  : SEQ_TYPE;
end;
NODE    = record
1x_srcpos   :   source_position;
case kind   :   NODE_NAME of
_abort                          :    (   c_abort                          : r_abort                        );
_accept                        :    (   c_accept                        :   ^r_accept                      );
_access                        :   (   c_access                        :   ^r_access                      );
_address                      :   (   c_address                      :   ^r_address                    );
_aggregate                  :    (   c_aggregate                  :  r_aggregate                );
_alignment                  :   (   c_alignment                  :  r_alignment                );
_all                               :    (   c_all                               :   ^r^all                            );
_allocator                  :    (   c_allocator                  :  r_allocator                );
_alternative              :    (   c_alternative              :   ^r_alternative            );
_alternative_s          :    (   c_alternative_s          :   ^r_alternative_s        );
_argument_id              :    (   c_argument_id              :   ^r_argument_id            );
_array                          :   (   c_array                          :   ^r_array                        );
_assign                        :    (  c_assign                        :   ^r_assign                      );
_assoc                          :   (   c_assoc                          :  r_assoc                        );
_attr_id                      :   (   c_attr_id                      :   ^r_attr_id                    );
_attribute                  :   (   c_attribute                  :  r_attribute                );
_attribute_call         :   (  c_attribute_call         :   ^r_attribute_call  );
_binary                        :    ( c_binary                        :   ^r_binary                      );
_block                          :    ( c_block                          :   ^r_block                        );
_box                              :    ( c_box                              :   ^r_box                            );
_case                            :    ( c_case                            :   ^r_case                          );
_choice_s                    :   ( c_choice_s                    :   ^r_choice_s                  );
_code                            :    ( c_code                            :   ^r_code                          );
_comp_id                      :    ( c_comp_id                      :   ^r_comp_id                    );
_comp_rep                    :    ( c_comp_rep                    :   ^r_comp_rep                  );
_comp_rep_s                :    ( c_comp_rep_s                :   ^r_comp_rep_s              );
_comp_unit                  :    ( c_comp_unit                  :   ^r_comp_unit                );
_compilation               :    ( c_compilation              :   ^r_compilation            );
_cond_clause              :   ( c_cond_dause              :   ^r_cond_dause            );
_cond_entry                :   ( c_cond_entry                :   ^r_cond_entry              );
_const_id                    :   ( c_const_id                    :   ^r_const_id                  );
_constant                    :    ( c_constant                    :   ^r_constant                  );
_constrained              :   ( c_constrained               :   ^r_constrained            );
_context                      :    ( c_context                      :  r_context                    );
_conversion                :   ( c_conversion                :   ^r_conversion              );
_decl_s                        :    ( c_ded_s                        :   ^r_ded_s                      );
_def_char                    :    ( c_def_char                    :   ^r_def_char                  );
_def_op                        :   ( c_def_op                        :   ^r_def_op                      );
_deferred_constant :    ( c_deferred_constant :   ^r_deferred_constant);
_delay                          :    ( c_delay                          :   ^r_delay                        );
_derived                      :    ( c_derived                      :   ^r_derived                    );
_dscrmt_aggregate :   ( c_dscrmt_aggregate :   ^r_dscrmt_aggregate );
_dscrmt_id                  :   ( c_dscrmt_id                  :   ^r_dscrmt_id                );
_dscrmt_var                 :    ( c_dscrmt_var                :   ^r_dscrmt_var               );
_dscrmt_var_s            :    ( c_dscrmt_var_s            :   ^r_dscrmt_var_s          );
_dscrt_range_s          :    ( c_dscrt_range_s          :   ^r_dscrt_range_s        );
_entry                          :    ( c_entry                          :   ^r_entry                        );
_entry_call                 :    ( c_entry_call                 :   ^r_entry_call               );
_entry_id                    :   ( c_entry_id                    :   ^r_entry_id                  );
_enum_id                      :    ( c_enum_id                      :   ^r_enum_id                    );
_enum_literal_s        :    ( c_enum_literal_s        :  r_enum_literal_s      );
_exception                  :   ( c_exception                  :   ^r_exception                );
_exception_id            :    ( c_exception_id            :   ^r_exception_id           );
_exit                            :    ( c_exit                            :   ^r_exit                          );
_exp_s                          :    ( c_exp_s                          :   ^r_exp_s                        );
_fixed                          :    ( c_fixed                          :   ^r_fixed                        );
_float                          :    ( c_float                          :   ^r_float                        );
_for                              :    ( c_for                              :   ^r_for                            );
_formal_dscrt            :    ( c_formal_discrete      :   ^r_formal_dscrt           );
_formal_fixed            :   ( c_formal_fixed            :   ^r_formal_fixed           );
_formal_float            :    ( c_formal_float             :   ^r_formal_float           );
_formal_integer         :   ( c_formal_integer         :   ^r_formal_integer       );
_function                    :    ( c_function                    :   ^r_function                  );
_function_call           :    ( c_function_call           :   ^r_function_call         );
_function_id              :    ( c_function_id              :   ^r_function_id            );
_generic                      :    ( c_generic                      :   ^r_generic                    );
_generic_assoc_s  :    ( c_generic_assoc_s       :   ^r_generic_assoc_s );
_generic_id                :   ( c_generic_id                :   ^r_generic_id              );
_generic_param_s  :    ( c_generic_param_s      :   ^r_generic_param_s );
_goto                            :   ( c_goto                            :   ^r_goto                          );
_id_s                            :   ( c_id_s                            :   ^r_id_s                          );
_if                                :   ( c_if                                :   ^r_if                              );
_in                                :    (   c_in                                :   ^r_in                              );
_in_id                          :    (   c_in_id                          :   ^r_in_id                        );
_i^_c^p                          :    (   c_in_op                          :   ^r_in_op                        );
_in_out                        :    (   c_in_out                        :   ^r_in_out                      );
_in_out_id                  :    (   c_in_out_id                  :   ^r_in_out_id                );
_index                          :    (   c_index                          :   ^r_index                        );
_indexed                      :    (   c_indexed                      :   ^r_indexed                    );
_inner_record            :    (   c_inner_record            :   ^r_inner_record           );
_instatiation            :    (   c_instatiation            :   ^r_instatiation           );
_integer                      :    (   c_integer                      :   ^r_integer                    );
_item_s                        :    (   c_item_s                        :   ^r_item_s                      );
_iteration_id            :    (   c_iteration_id            :   ^r_iteration_id           );
_l_private                  :    (   c_l_private                  :   ^r_l_private                );
_label_id                    :    (   c_label_id                    :   ^r_label_id                  );
_labeled                      :    (   c_labeled                      :   ^r_labeled                    );
_loop                            :    (   c_loop                            :   ^r_loop                          );
_l_private_type_id :    (   c_l_private_type_id :   ^r_l_private_type_id);
_membership                :    (   c_membership                :   ^r_membership              );
_name_s                        :    (   c_name_s                        :   ^r_name_s                      );
_named                          :   (   c_named                          :   ^r_named                        );
_named_stm                  :    (   c_named_stm                  :   ^r_named_stm                );
_named_stm_id            :    (   c_named_stm_id            :   ^r_named_stm_id           );
_no_default                :    (   c_no_default                :   ^r_no_default               );
_not_in                        :    (   c_not_in                        :   ^r_not_in                      );
_null_access              :    (   c_null_access              :   ^r_null_access            );
_null_comp                  :    (   c_null_comp                  :  r_null_comp                );
_null_stm                    :   (   c_null_stm                    :   ^r_null_stm                  );
_number                        :    (   c_number                        :   ^r_number                      );
_number_id                  :    (   c_number_id                  :   ^r_number_id                );
_numeric_literal       :    (   c_numeric_literal       :   ^r_numeric_literal  );
_others                        :    (   c_others                        :   ^r_others                      );
_out                              :   (   c_out                              :   ^r_out                            );
_out_id                        :    (   c_out_id                        :   ^r_out_id                      );
_package_body            :   (   c_package_body            :   ^r_package_body          );
_package_decl             :   (   c_package_decl             :   ^r_package_decl           );
_package_id                :    (   c_package_id                :   ^r_package_id              );
_package_spec             :    (   c_package_spec             :   ^r_package_spec           );
_param_assoc_s          :    (   c_param_assoc_s          :   ^r_param_assoc_s        );
_param_s                      :    (   c_param_s                      :   ^r_param_s                    );
_parenthesized           :    (   c_parenthesized           :   ^r_parenthesized        );
_pragma                        :    (   c_pragma                        :   ^r_pragma                      );
_pragma_id                  :    (   c_pragma_id                  :   ^r_pragma_id                );
_pragma_s                    :    (   c_pragma_s                    :   ^r_pragma_s                  );
_private                      :   (   c_private                      :   ^r_private                    );
_private_type_id  :    (   c_private_type_id       :   ^r_private_type_id  );
_proc_id                      :   (   c_proc_id                      :   ^r_proc_id                    );
_procedure                  :    (   c_procedure                  :  r_procedure                );
_procedure_call         :    (   c_procedure_call         :   ^r_procedure_call       );
_gualified                  :    (   c_gualified                  :   ^r_gualified                );
_raise                          :    (   c_raise                          :   ^r_raise                        );
_range                          :    (   c_range                          :   ^r_range                        );
_record                        :   (   c_record                        :   ^r_record                      );
_record_rep                :    (   c_record_rep                :   ^r_record_rep               );
_rename                        :    (   c_rename                        :   "r_rename                      );
_return                        :   (   c_return                        :   ^r_return                      );
_reverse                      :   (  c_reverse                      :   ^r_reverse                    );
_select                        :    (   c_select                        :   ^r_select                      );
_select_dause          :    (   c_select_clause          :   ^r_select_dause        );
_select_clause_s       :    (   c_select_dause_s       :   ^r_select_clause_s     );
_selected                    :    (   c_selected                    :   ^r_selected                  );
_simple_rep                :   (   c_simple_rep                :   ^r_simple_rep              );
_slice                          :    (   c_slice                          :   ^r_slice                        );
_stm_s                          :   (   c_stm_s                          :   ^r_stm_s                        );
_string_literal         :   (   c_string_literal         :   ^r_string_literal       );
_stub                            :    (   c_stub                            :   ^r_stub                          );
_subprogram_body       :    (   c_subprogram_body       :   ^r_subprogram_body     );
_subprogram_decl       :   (   c_subprogram_ded       :   ^r_subprogram_decl     );
_subtype                      :   (   c_subtype                      :   ^r_subtype                    );
_subtype_id                :   (   c_subtype_id                :   ^r_subtype_id              );
_subunit                      :   (  c_subunit                      :   ^r_subunit                    );
_task_body                  :    (   c_task_body                  :   ^r_task_body                );
_task_body_id             :    (   c_task_body_id            :   ^r_task_body_id           );
_task_decl                   :    (   c_task_decl                   :   ^r_task_decl                 );
_task_spec                  :    (   c_task_spec                  :   ^r_task_spec                );
_terminate                  :   (   c_terminated                :   ^r_terminate                );
_timed_entry              :   (   c_timed_entry              :   ^r_timed_entry            );
_type                            .   (   c_type                            :   ^-type                          );
_type_id                      :    (   c_type_id                      :   ^r_type_id                    );
_universal_fixed       :    (   c_universal_fixed       :   ^r_universal_fixed     );
_universal_integer   :   (   c_universal_integer   :   ^r_universal_integer);
_universal_real         :    (   c_universal_real         :   ^r_universal_real       );
_use                              :   (   c_use                              :   ^r_use                            );
_used_bltn_id            :    (   c_used_bltn_id            :   ^r_used_bltn_id          );
_used_bltn_op             :    (   c_used_bltn_op            :   ^r_used_bltn_op           );
_used_char                  :    (   c_used_char                   :   ^r_used_char                );
_used_name_id             :   (   c_used_name_id            :   ^ r_used_name_id           );
_used_object_id         :    (   c_used_object_id        :   ^r_used_object_id       );
_used_op                      :    (   c_used_op                      :   ^r_used_op                    );
_var                              :   (  c_var                              :   ^r_var                            );
_var_id                        :    (   c_var_id                        :   ^r_var_id                      );
_variant                      :    (   c_variant                      :   ^r_variant                    );
_variant_part            :    (   c_variant_part             :   ^r_variant_part           );
_variant_s                  :    (   c_variant_s                  :   ^r_variant_s                );
_void                            :    (   c_void                            :   ^r_void                          );
_while                          :    (   c_while                          :   ^r_while                        );
_with                            :   (   c_with                            :   ^r_with                          )
end;
{Basic DIANA operations.}
{Get node name.}
function KIND           (t: TREE): NODE_NAME;
{Routines for accessing nodes.}
procedure GET_NODE (t: TREE; var Nd: NODE);
procedure PUT_NODE (t: TREE; var Nd: NODE);
{Routines for list operations.}
f-nction GET_EMPTY   :   SE-_TYPE;
function HEAD             (l: SEQ_TYPE): TREE;
_subtype_id,                 _subunit,                       _task_body,                   _task_body_id,
_task_decl,                   _task_spec,                   _terminate,                   _timed_entry,
_type,                            _type_id,                      _universal_fixed,       _universal_intege
_universal_real,   _use,                              _used_bltn_id,             _used_bltn_op,
_used_char,                   _used_name_id,             _used_object_id,         _used_op,
_var,                               _var_id,                         _variant,                       _variant_part,
_variant_s,                   _void,                            _while,                           _with
^;
r_abort                        = record
as_name_s                              : TREE;
end;
r_accept                      = record
as_name                                  : TREE;
as_param_s                            : TREE;
as_stm_s                                : TREE;
end;
r_access                      = record
as_constrained        : TREE;
sm_size                                  : TREE;
sm_storage_size       : TREE;
sm_controlled                      : Boolean;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
cd_constrained        : Boolean;
end;
r_address        = record
as_name                                  : TREE;
as_exp                                    : TREE;
end;
r_aggregate      = record
as_list                                  : SEQ_TYPE;
sm_exp_type                          : TREE;
sm_constraint                      : TREE;
sm_normalized_comp_s   : TREE;
sm_value                                : value;
end;
r_alignment      = record
as_pragma_s                          : TREE;
as_exp_void                          : TREE;
end;
r_all                            = record
as_name                                  : TREE;
sm_exp_type                          : TREE;
end;
r_allocator      = record
as_exp_constrained     : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_alternative     = record
as_choice_s                          : TREE;
as_stm_s                                : TREE;
end;
function    TAIL             (1:   SE-^TYPE): SE-_TYPE;
function     IS_EMPTY     (1:   SEQ_TYPE): Boolean;
function     IN-^ERT         (l:   SE-_TYPE; t: TREE): SE-_TYPE;
function    APPEND         (1:   SEO_TYPE; t: TREE): SEQ_TYPE;
implementation
const
MaxNodeNumber = 2000;     {Max: 7280}
var
NodeArray    : array [1..MaxNodeNumber] of NODE;
NumberOfNodes : TREE;
procedure ConditionalError(ErrorNumber: integer; ErrorCondition: Boolean);
begin
if ErrorCondition then
Error(ErrorNumber);
end; {ConditionalError}
{TREE procedures ^ functions}
function KIND (t: TREE): NODE_NAME;
begin
ConditionalError(3, t > NumberOfNodes);
K1ND := NodeArray[t].kind;
end; {^IND]
procedure GET_NODE(t: TREE; var Nd: NODE);
begin
ConditionalError(3, t > NumberOfNodes);
Nd := NodeArray[t];
end; {GET_NODE}
procedure PUT_NODE(t: TREE; var Nd: NODE);
begin
ConditionalError(5003, t > MaxNodeNumber);
if t > NumberOfNodes then
NumberOfNodes := t;
NodeArray[t] := Nd;
end; {PUT_NODE}
{SEO_TYPE functions}
function GET_EMPTY : SEQ_TYPE;
begin
GET_EMPTY := nil;
end; {GET_EMPTY}
function HEAD (1 : SEQ_TYPE) : TREE;
begin
HEAD := l^.elem;
end; {HEAD}
functi-n TAIL (1 . SE-_TYPE) : SE-_TYPE;
begin
TAIL := l^.next;
end; {TAIL}
function IS_EMPTY (1 : SEQ_TYPE) : Boolean;
begin
IS_EMPTY := l = nil;
end; {IS_EMPTY}
function INSERT (1 : SEQ_TYPE; t : TREE) : SEO_TYPE;
var ptr  : SEO_TYPE;
found : Boolean;
begin
new (ptr);
ptr^.elem := t;
ptr^.next := l;
INSERT := ptr;
end; {INSERT}
function APPEND(l : SEQ_TYPE; t : TREE) : SEQ_TYPE;
begin
if l = nil then
APPEND := INSERT( 1 , t)
else
begin
APPEND := 1;
while l^.next <> nil do
l := l^.next;
l^.next := INSERT(nil, t);
end;
end; {APPEND}
begin {Diana}
NumberOfNodes := 0;
end. {Diana}
r_alternative_s   = record
as_list                                  : SE-_TYPE;
end;
r_and_then       = record
end;
r_argument_id     = record
1x_symrep                              : symbol_rep;
end;
r_array                        = record
as_dscrt_range_s      : TREE;
as_constrained        : TREE;
sm_size                                  : TREE;
sm_packing                            : Boolean;
cd_comp_unit                        : Byte;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
cd_dimensions                      : Byte;
cd_compiled                          : Boolean;
end;
r_assign                      = record
as_name                                  : TREE;
as_exp                                    : TREE;
end;
r_assoc                        = record
as_designator                      : TREE;
as_actual                               : TREE;
end;
r_attr_id        = record
1x_symrep                              : symbol_rep;
end;
r_attribute      = record
as_id                                      : TREE;
as_name                                  : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_attribute_call  = record
as_exp                                    : TREE;
as_name                                  : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
end;
r_binary                      = record
as_expl                                  : TREE;
as_binary_op                        : binary_op;
as_exp2                                  : TREE;
sm_exp_type                          : TREE;
sm_va1ue                                : va1ue;
end;
r_block                                  = record
as_item_s                              : TREE;
as_stm_s                                : TREE;
as_alternative_s      : TREE;
cd_level                                : LevelType;
cd_return_label       : LabelType;
cd_result_offset      : OffsetType;
end;
r_box                                      = record
end;
r_case                                    = record
as_alternative_s       : TREE;
as_exp                                    : TREE;
end;
r_choice_s                            = record
as_list                                  : SEQ_TYPE;
end;
r_code                                    = record
as_name                                  : TREE;
as_exp                                    : TREE;
end;
r_comp_id                              ^ record
lx_symrep                              : symbol_rep;
sm_init_exp                          : TREE;
sm_obj_type                          : TREE;
sm_comp_spec                        : TREE;
end;
r_comp_rep                            ^ record
as_name                                  : TREE;
as_exp                                    : TREE;
as_range                                : TREE;
end;
r_comp_rep_s                        = record
as_list                                  : SEQ_TYPE;
end;
r_comp_unit                          = record
as_pragma_s                          : TREE;
as_context                            : TREE;
as_unit_body                        : TREE;
end;
r_compilation                      = record
as_list                                  : SEQ_TYPE;
end;
r_cond_clause                      = record
as_exp_void                          : TREE;
as_stm_s                                : TREE;
end;
r_cond_entry                        = record
as_stm_sl                              : TREE;
as_stm_s2                              : TREE;
end;
r_const_id                            = record
lx_symrep                              : symbol_rep;
sm_address                            : TREE;
sm_obj_type                          : TREE;
sm_obj_def                            : TREE;
sm_first                                : TREE;
cd_comp_unit                        : Byte;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
cd_compiled                          : Boolean;
end;
r_constant                            = record
as_id_s                                  : TREE;
as_type_spec                        : TREE;
as_object_def                      : TREE;
end;
r_constrained                      ^ record
as_name                                  : TREE;
as_constraint                      : TREE;
cd_impl_size                        : byte;
cd_allignment                      : byte;
sm_type_struct        : TREE;
sm_base_type                        : TREE;
sm_constraint                      : TREE;
end;
r_context                              ^ record
as_list                                  : SEQ_TYPE;
end;
r_conversion                        = record
as_name                                  : TREE;
as_exp                                    : TREE;
sm_exp^type                          : TREE;
sm_value                                : value;
end;
r_decl_s                                = record
as_list                                  : SEO_TYPE;
end;
r_def_char                            = record
lx_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_pos                                    : Integer;
sm_rep                                    : Integer;
end;
r_def_op                                = record
lx_symrep                              : symbol_rep;
sm_spec                                  : TREE;
sm_body                                  : TREE;
sm_location                          : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
end;
r_deferred_constant    = record
as_id_s                                  : TREE;
as_name                                  : TREE;
end;
r_delay                                  = record
as_exp                                    : TREE;
end;
r_derived                              = record
as_constrained        : TREE;
cd_impl_size                        : byte;
sm_actual_delta       : real;
sm_packing                            : Boolean;
sm_controlled                      : Boolean;
sm_size                                  : TREE;
sm_storage_size       : TREE;
end;
r_dscrmt_aggregate     = record
as_list                                  : SEQ_TYPE;
sm_normalized_comp_s   : TREE;
end;
r_dscrmt_id                          = record
1x_symrep                              : symbol_rep;
sm_pbj_type                          : TREE;
sm_init_exp                          : TREE;
sm_first                                : TREE;
sm_comp_spec                        : TREE;
end;
r_dscrmt_var                        = record
as_id_s                                  : TREE;
as_name                                  : TREE;
as_object_def                      : TREE;
end;
r_dscrmt_var_s        = record
as_list                                  : SEQ_TYPE;
end;
r_dscrt_range_s       = record
as_list                                  : SEQ_TYPE;
end;
r_entry                                  = record
as_dscrt_range_void    : TREE;
as_param_s                            : TREE;
end;
r_entry_call                        = record
as_name                                  : TREE;
as_param_assoc_s       : TREE;
sm_normalized_param_s  : TREE;
end;
r_entry_id                            = record
1x_symrep                              : symbol_rep;
sm_spec                                  : TREE;
sm_address                            : TREE;
end;
r_enum_id                              = record
1x_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_pos                                    : Integer;
sm_rep                                    : Integer;
end;
r_enum_literal_s      = record
as_list                                  : SEQ_TYPE;
cd_impl_size                        : byte;
cd_allignment                      : byte;
sm_size                                  : TREE;
cd_last                                  : integer;
end;
r_exception                          = record
as_id_s                                  : TREE;
as_exception_def      : TREE;
end;
r_exception_id        = record
1x_symrep                              : symbol_rep;
sm_exception_def      : TREE;
cd_label                                : LabelType;
end;
r_exit                                    = record
as_name_void                        : TREE;
as-^exp_void                          : TREE;
sm_stm                                    : TREE;
end;
^-^^^-^                                  ^ record
as_list                                  : SEQ_TYPE;
end;
r_fixed                                  = record
as_exp                                    : TREE;
as_range_void                      : TREE;
cd_impl_size                        : byte;
sm_size                                  : TREE;
sm_actual_delta        : real;
sm_bits                                  : Byte;
sm_base_type                        : TREE;
end;
r_float                                  = record
as_exp                                    : TREE;
as_range_void                      : TREE;
cd_allignment                      : byte;
sm_size                                  : TREE;
sm_type_struct        : TREE;
sm_base_type                        : TREE;
end;
r_for                                      = record
as_id                                      : TREE;
as_dscrt_range        : TREE;
end;
r_formal_dscrt        = record
end;
r_formal_fixed        = record
end;
r_formal_float        = record
end;
r_formal_integer      = record
end;
r_function                            = record
as_name_void                        : TREE;
as_param_s                            : TREE;
end;
r_function_call       = record
as_name                                  : TREE;
as_param_assoc_s      : TREE;
sm_exp_type                          : TREE;
sm_value                                : value;
sm_normalized_param_s  : TREE;
1x_prefix                              : Boolean;
end;
r_function_id                      = record
1x_symrep                              : symbol_rep;
sm_spec                                  : TREE;
sm_body                                  : TREE;
sm_location                          : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
cd_label                                : LabelType;
cd_level                                : LevelType;
cd_param_size                      : OffsetType;
cd_result_size        : OffsetType;
cd_compiled                          : Boolean;
end;
r_generic                              = record
as_id                                      : TREE;
as_generic_param_s     : TREE;
as_generic_header      : TREE;
end;
r_generic_assoc_s     = record
as_list                                  : SEQ_TYPE;
end;
r_generic_id                        = record
1x_symrep                              : symbol_rep;
sm_generic_param_s     : TREE;
sm_spec                                  : TREE;
sm_body                                  : TREE;
sm_stub                                  : TREE;
sm_first                                : TREE;
end;
r_generic_param_s     - record
as_list                                  : SEO_TYPE;
end;
r_goto                                    = record
as_name                                  : TREE;
end;
r_id_s                                    = record
as_list                                  : SEO_TYPE;
end;
r_if                                        = record
as_list                                  : SEO_TYPE;
end;
r_in                                        = record
as_exp_void                          : TREE;
as_id_s                                  : TREE;
as_name                                  : TREE;
lx_default                            : Boolean;
end;

^-^^^^^                                  - record
lx_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_init_exp                          : TREE;
sm_first                                : TREE;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
end;

r_in_op                                  = record
end;

r_in_out                                = record
as_exp_void                          : TREE;
as_id_s                                  : TREE;
as_name                                  : TREE;
end;

r_in_out_id                          = record
1x_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
sm_first                                : TREE;
cd_level                                : LevelType;
cd_addr_offset        : OffsetType;
cd_val_offset                      : OffsetType;
end;

r_index                                  = record
as_name                                  : TREE;
end;
r_indexed                              = record
as_name                                  : TREE;
as_exp_s                                : TREE;
sm_exp_type                          : TREE;
end;

r_inner_record        = record
as_list                                  : SEQ_TYPE;
end;
r_instatiation        = record
as_name                                  : TREE;
as_generic_assoc_s    : TREE;
sm_decl_s                              : TREE;
end;

r_integer                              = record
as_range                                : TREE;
cd_impl_size                        : byte;
sm_size                                  : TREE;
sm_type_struct        : TREE;
sm_base_type                        : TREE;
cd_comp_unit                        : Byte;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
cd_compiled                          : Boolean;
end;
r_item_s                                = record
as_list                                  : SEQ_TYPE;
end;

r_iteration_id        = record
lx_symrep                              : symbol_rep;
sm_obj_type                          : TREE;
cd_level                                : LevelType;
cd_offset                              : OffsetType;
end;
r_l_private                          = record
sm_discriminants      : TREE;
end;










unit ExtDiana;
{Unit for reading external form of DIANA.}
interface
uses CG_Lib,
Diana,
Private;
const
{FIag for debugging purposes. If TRUE each DIANA node read from the file
is printed together with line number.}
PrintDianaNodes : Boolean = false;
{Read DIANA tree from the file 'FileName'. If the tree contains
node 'compilation' assign it to 'Root'.}
procedure BuildDianaTree(FileName: String; var Root: TREE);
{------------------------------------------------------}
implementation
procedure BuildDianaTree(FileName: String; var Root: TREE);
const
LineLen     = 90;    {Max. line length}
Charslnldent = [ '0'..'9', 'A'..'-', 'a'..'z', '_' ];   {Characters allowed
in identifiers}
var
KindOfNode,
Line      : String[LineLen];  {Current line}
LineNr     : Word;                           {Current line number}
InFile     : Text;                           {lnput file}
L                      : Longint;
NodeNr     : Word;                           {Number of current node}
BegPos, i,
Position   : Byte;                           {Current character in line}
TempValue  : Value;
procedure ConditionalError(ErrorNumber: integer; ErrorCondition: Boolean);
begin
if ErrorCondition then
begin
Close(InFile);
Writeln;
WriteLn('Error in file: ', FileName, ' line: ', LineNr);
Error(ErrorNumber);
end;
end; {ConditionalError}
procedure InvalidAttributeValue;
begin {InvalidAttributeValue}
ConditionalError(4005, true);
end; {lnvalidAttributeValue}
{Read next input line skipping empty lines and comments.}
procedure ReadLine;
begin
Nd.kind := _assoc;
new(Nd.c_assoc);
with Nd.c_assoc^ do
begin
ReadNodePtr;
as_designator := NdPtr;
ReadAttribute;
ReadNodePtr;
as_actual := NdPtr;
end;
end
else
InvalidKindOfNode;
'B' :
if KindOfNode = 'BINARY' then
begin
Nd.kind := _binary;
new(Nd.c_binary);
with Nd.c_binary^ do
begin
ReadNodePtr;
as_expl := NdPtr;
ReadAttribute;
ReadBinaryOp(as_binary_op);
ReadAttribute;
ReadNodePtr;
as_exp2 := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadValue(sm_value);
end;
end
else if KindOfNode = 'BLOCK' then
begin
Nd.kind := _block;
new(Nd.c_block);
with Nd.c_block^ do
begin
ReadNodePtr;
as_item_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_stm_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_alternative_s := NdPtr;
end;
end
else
InvalidKindOfNode;
'C' :
if KindOfNode = 'CHOICE_S' then
begin
Nd.kind := _choice_s;
new(Nd.c_choice_s);
Nd.c_choice_s^.as_list := ReadList;
end
else if KindOfNode ^ 'COMPILATION' then
begin
Nd.kind := _compilation;
new(Nd.c_compilation);
Nd.c_compilation^.as_list := ReadList;
Root := NodeNr;
end
else if KindOfNode = 'COMP_UNIT' then
begin
Nd.kind := _comp_unit;
new(Nd.c_comp_unit);
with Nd.c_comp_unit^ do
begin
ReadNodePtr;
as_context := NdPtr;
ReadAttribute;
ReadNodePtr;
as_unit_body := NdPtr;
ReadAttribute;
ReadNodePtr;
as_pragma_s := NdPtr;
end;
end
else if KindOfNode = 'COND_CLAUSE' then
begin
Nd.kind := _cond_dause;
new(Nd.c_cond_dause);
with Nd.c_cond_clause^ do
begin
ReadNodePtr;
as_exp_void := NdPtr;
ReadAttribute;
ReadNodePtr;
as_stm_s := NdPtr;
end;
end
else if KindOfNode = 'CONSTANT' then
begin
Nd.kind := _constant;
new(Nd.c_constant);
with Nd.c_constant^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_type_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
as_object_def := NdPtr;
end;
end
else if KindOfNode ^ 'CONST_ID' then
begin
Nd.kind := _const_id;
new(Nd.c_const_id);
with Nd.c_const_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_address := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_obj_def  := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
cd_compiled := false;
end;
end
else if KindOfNode = 'CONSTRAINED' then
begin
Nd.kind := _constrained;
new(Nd.c_constrained);
with Nd.c_constrained^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_constraint := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_type_struct := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_base_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_constraint := NdPtr;
end;
end
else if KindOfNode = 'CONTEXT' then
begin
Nd.kind := _context;
new(Nd.c_context);
Nd.c_context^.as_list := ReadList;
end
else
InvalidKindOfNode;
'D' :
if KindOfNode = 'DECL_S' then
begin
Nd.kind := _decl_s;
new(Nd.c_decl_s);
Nd.c_decl_s^.as_list := ReadList;
end
else if KindOfNode = 'DEF_CHAR' then
begin
Nd.kind := _def_char;
new(Nd.c_def_char);
with Nd.c_def_char^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
Readlnteger(sm_pos);
ReadAttribute;
Readlnteger(sm_rep);
end;
end
else if KindOfNode = 'DSCRMT_VAR_S' then
begin
Nd.kind := _dscrmt_var_s;
new(Nd.c_dscrmt_var_s);
Nd.c_dscrmt_var_s^.as_list := ReadList;
end
else if KindOfNode = 'DSCRT_RANGE_S' then
begin
Nd.kind := _dscrt_range_s;
new(Nd.c_dscrt_range_s);
Nd.c_dscrt_range_s^.as_list := ReadList;
end
else
InvalidKindOfNode;
'E' :
if KindOfNode = 'ENUM_ID' then
begin
Nd.kind := _enum_id;
new(Nd.c_enum_id);
with Nd.c_enum_id^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadInteger(sm_pos);
ReadAttribute;
ReadInteger(sm_rep);
end;
end
else if KindOfNode = 'ENUM_LITERAL_S' then
begin
Nd.kind := _enum_literal_s;
new(Nd.c_enum_literal_s);
with Nd.c_enum_literal_s^ do
begin
as_list := ReadList;
ReadAttribute;
ReadNodePtr;
sm_size := NdPtr;
end;
end
else if Kin-OfN--e = 'EXCEPTION' then
begin
Nd.kind := _exception;
new(Nd.c_exception);
with Nd.c_exception^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exception_def := NdPtr;
end;
end
else if Kin-OfNode = 'EXCEPTION_ID' then
begin
Nd.kind := _exception_id;
new(Nd.c_exception_id);
with Nd.c_exception_id^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_exception_def := NdPtr;
end;
end
else if KindOfNode = 'E)(IT' then
begin
Nd.kind := _exit;
new(Nd.c_exit>;
with Nd.c_exit^ do
begin
ReadNodePtr;
as_name_void := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp_void := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_stm := NdPtr;
end;
end
else if KindOfNode = 'EXP_S' then
begin
Nd.kind :- _exp_s;
new(Nd.c_exp_s);
Nd.c_exp_s^.as_list := ReadList;
end
else
InvalidKindOfNode;
'F' .
if KindOfNode = 'FOR' then
begin
Nd.kind := _for;
new(Nd.c_for);
with Nd.c_for^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_dscrt_range := NdPtr;
end;
end
else if KindOfNode = 'FUNCTION' then
begin
Nd.kind := _function;
new(Nd.c_function);
with Nd.c_function^ do
begin
ReadNodePtr;
as_param_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_name_void := NdPtr;
end;
end
else if KindOfNode = 'FUNCTION_CALL' then
begin
Nd.kind := _function_call;
new(Nd.c_function_call);
with Nd.c_function_call^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_param_assoc_s := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadValue(sm_value);
ReadAttribute;
ReadNodePtr;
sm_normalized_param_s := NdPtr;
ReadAttribute;
ReadValue(TempValue);
1x_prefix := TempValue.boo_val;
end;
end
else if KindOfNode = 'FUNCTION_ID' then
begin
Nd.kind := _function_id;
new(Nd.c_function_id);
with Nd.c_function_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_body := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_location := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_stub := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
cd_compiled := false;
end;
end
else
InvalidKindOfNode;
'G' :
if KindOfNode = " then
begin
end
else
InvalidKindOfNode;
'I' :
if KindOfNode = 'ID_S' then
begin
Nd.kind := _id_s;
new(Nd.c_id_s);
Nd.c_id_s^.as_list := ReadList;
end
else if KindOfNode = 'IF' then
begin
Nd.kind := _if;
new(Nd.c_if);
Nd.c_if^.as_list := ReadList;
end
else if KindOfNode = 'IN' then
begin
Nd.kind := _in;
new(Nd.c_in);
with Nd.c_in^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp_void := NdPtr;
ReadAttribute;
ReadValue(TempValue);
1x_default := TempValue.boo_val;
end;
end
else if KindOfNode = 'IN_ID' then
begin
Nd.kind := _in_id;
new(Nd.c_in_id);
with Nd.c_in_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_init_exp := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
end;
end
else if KindOfNode = 'IN_OUT' then
begin
Nd.kind := _in_out;
new(Nd.c_in_out);
with Nd.c_in_out do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp_void := NdPtr;
end;
end
else if KindOfNode = 'IN_OUT_ID' then
begin
Nd.kind := _in_out_id;
new(Nd.c_in_out_id>;
with Nd.c_in_out_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
end;
end
else if KindOfNode = 'INDE)(ED' then
begin
Nd.kind := _indexed;
new(Nd.c_indexed);
with Nd.c_indexed^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp_s := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
end;
end
else if KindOfNode = 'INTEGER' then
begin
Nd.kind := _integer;
new(Nd.c_integer);
with Nd.c_integer do
begin
ReadNodePtr;
as_range := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_size := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_type_struct := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_base_type := NdPtr;
end;
end
else if KindOfNode = 'ITEM_S' then
begin
Nd.kind := _item_s;
new(Nd.c_item_s);
Nd.c_item_s ^.as_list := ReadList;
end
else if KindOfNode = 'ITERATION_ID' then
begin
Nd.kind := _iteration_id;
new(Nd.c_iteration_id);
with Nd.c_iteration_id^ do
begin
Ix_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
end;
end
else
InvalidKindOfNode;
'L' :
if KindOfNode = 'LOOP' then
begin
Nd.kind :^ _loop;
new(Nd.c_loop);
with Nd.c_loop^ do
begin
ReadNodePtr;
as_iteration := NdPtr;
ReadAttribute;
ReadNodePtr;
as_stm_s := NdPtr;
end;
end
else
InvaIidKindOfNode;
'M' :
if KindOfNode = " then
begin
end
else
InvalidKindOfNode;
'N' :
if KindOfNode = 'NAMED_STM' then
begin
Nd.kind :^ _named_stm;
new(Nd.c_named_stm);
with Nd.c_named_stm^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_stm := NdPtr;
end;
end
else if KindOfNode = 'NAMED_STM_ID' then
begin
Nd.kind := _named_stm_id;
new(Nd.c_named_stm_id);
with Nd.c_named_stm_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_stm := NdPtr;
end;
end
else if KindOfNode = 'NULL_STM' then
begin
Nd.kind := _null_stm;
end
while not eof(InFile) do
begin
ReadLn(InFile, Line);
inc(LineNr);
Line := Trim(Line);
if Length(Line) > 0 then
if (Line[1] <> '^^) and (Line[2] <> '^') then
exit;
end;
end; {ReadLine}
procedure ReadLonglnt(var L : Longlnt; var Position: Byte);
var sign : Longlnt;
begin
L := 0;
if Line[Position] = '-' then
begin
sign := -1;
inc(Position);
end
else
sign := 1;
whi1e (Position <= Length(Line)) and (Line[Position] in ['0'..'9']) do
begin
L := 10 ^ L + ord(Line[Position]) - ord('0');
inc(Position);
end;
L := sign ^ L;
end; {ReadLonglnt}
{Read attributes of the current node and create it.}
procedure ReadNode;
type
AttributeType = (Ix, as, sm, no_attribute);
SetOfChars   = set of Char;
var
AttributeName, S : string;
AType                        : AttributeType;
NdPtr                        : TREE;
Nd                              : NODE;
Fi1eName       : FileNameType;
L1, L2                      : Longlnt;
procedure SkipChars(CharsToSkip: SetOfChars);
begin
whi1e (Line[1] in CharsToSkip) and (Length(Line) > 0) do
De1ete(Line, 1, 1);
end; {SkipChars}
{Read attribute into 'AttributeNAme'.}
procedure ReadAttribute;
var
Position : Byte;
begin
ReadLine;
else if KindOfNode = 'NUMBER' then
begin
Nd.kind := _number;
new(Nd.c_number);
with Nd.c_number^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp := NdPtr;
end;
end
else if KindOfNode = 'NUMBER_ID' then
begin
Nd.kind := _number_id;
new(Nd.c_number_id);
with Nd.c_number_id^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_init_exp := NdPtr;
end;
end
else if KindOfNode = 'NUMERIC_LITERAL' then
begin
Nd.kind := _numeric_literal;
new(Nd.c_numeric_literal);
with Nd.c_numeric_literal^ do
begin
lx_numrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadValue(sm_value);
end;
end
else
InvalidKindOfNode;
'O' :
if KindOfNode = 'OTHERS' then
begin
Nd.kind := _others;
end
else if KindOfNode = 'OUT' then
begin
Nd.kind := _out;
new(Nd.c_out);
with Nd.c_out^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp_void := NdPtr;
end;
end
else if KindOfNode = 'OUT_ID' then
begin
Nd.kind := _out_id;
new(Nd.c_out_id);
with Nd.c_out_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
end;
end
else
InvalidKindOfNode;
'P' :
if KindOfNode = 'PACKAGE_BODY' then
begin
Nd.kind := _package_body;
new(Nd.c_package_body);
with Nd.c_package_body^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_block_stub := NdPtr;
end;
end
else if KindOfNode = 'PACKAGE_DECL' then
begin
Nd.kind := _package_decl;
new(Nd.c_package_decl);
with Nd.c_package_decl^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_package_def := NdPtr;
end;
end
else if KindOfNode = 'PACKAGE_ID' then
begin
Nd.kind := _package_id;
new(Nd.c_package_id);
with Nd.c_package_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_body := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_address := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_stub := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
cd_compiled := false;
end;
end
else if Kind-fN-de ^ 'PACKA-E_SPEC' then
begin
Nd.kind := _package_spec;
new(Nd.c_package_spec);
with Nd.c_package_spec^ do
begin
ReadNodePtr;
as_decl_sl := NdPtr;
ReadAttribute;
ReadNodePtr;
as_dec1_s2 := NdPtr;
end;
end
e1se if KindOfNode = 'PARAM_ASSOC_S' then
begin
Nd.kind := _param_assoc_s;
new(Nd.c_param_assoc_s);
Nd.c_param_assoc_s^.as_list := ReadList;
end
else if KindOfNode = 'PARAM_S' then
begin
Nd.kind := _param_s;
new(Nd.c_param_s);
Nd.c_param_s^.as_list := ReadList;
end
else if KindOfNode = 'PARENTHESI-ED' then
begin
Nd.kind := _parenthesized;
new(Nd.c_parenthesized);
with Nd.c_parenthesized^ do
begin
ReadNodePtr;
as_exp := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadValue(sm_value);
end;
end
else if KindOfNode = 'PRAGMA_S' then
begin
Nd.kind := _pragma_s;
new(Nd.c_pragma_s);
Nd.c_pragma_s^.as_list := ReadList;
end
else if KindOfNode = 'PROC_lD' then
begin
Nd.kind := _proc_id;
new(Nd.c_proc_id);
with Nd.c_proc_id^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_body := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_location := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_stub := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
cd_compiled := false;
end;
end
else if KindOfNode = 'PROCEDURE' then
begin
Nd.kind := _procedure;
new(Nd.c_procedure);
ReadNodePtr;
Nd.c_procedure^.as_param_s := NdPtr;
end
else if KindOfNode = 'PROCEDURE_CALL' then
begin
Nd.kind := _procedure_call;
new(Nd.c_procedure_call);
with Nd.c_procedure_call^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_param_assoc_s := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_normalized_param_s := NdPtr;
end;
end
else
InvalidKindOfNode;
'O' :
if KindOfNode = '' then
begin
end
else
InvalidKindOfNode;
'R^ :
if KindOfNode = 'RAISE' then
begin
Nd.kind := _raise;
new(Nd.c_raise);
with Nd.c_raise^ do
begin
ReadNodePtr;
as_name_void := NdPtr;
end;
end
else if KindOfNode = 'RANGE' then
begin
Nd.kind := _range;
new(Nd.c_range);
with Nd.c_range^ do
begin
ReadNodePtr;
as_expl :^ NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp2 := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_base_type := NdPtr;
end;
end
else if KindOfNode = 'RETURN' then
begin
Nd.kind := _return;
new(Nd.c_return);
with Nd.c_return^ do
begin
ReadNodePtr;
as_exp_void := NdPtr;
end;
end
else if KindOfNode = 'REVERSE' then
begin
Nd.kind := _reverse;
new(Nd.c_reverse);
with Nd.c_reverse^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_dscrt_range := NdPtr;
end;
end
else
InvalidKindOfNode;
'S' :
if KindOfNode = 'STM_S' then
begin
Nd.kind := _stm_s;
new(Nd.c_stm_s);
Nd.c_stm_s^.as_list := ReadList;
end
else if KindOfNode = 'SUBPROGRAM_BODY' then
begin
Nd.kind := _subprogram_body;
new(Nd.c_subprogram_body);
with Nd.c_subprogram_body^ do
begin
ReadNodePtr;
as_designator := NdPtr;
ReadAttribute;
ReadNodePtr;
as_header := NdPtr;
ReadAttribute;
ReadNodePtr;
as_block_stub := NdPtr;
end;
end
else if KindOfNode = 'SUBPROGRAM_DECL' then
begin
Nd.kind := _subprogram_ded;
new(Nd.c_subprogram_decl);
with Nd.c_subprogram_ded^ do
begin
ReadNodePtr;
as_designator := NdPtr;
ReadAttribute;
ReadNodePtr;
as_header := NdPtr;
ReadAttribute;
ReadNodePtr;
as_subprogram_def := NdPtr;
end;
end
else
InvalidKindOfNode;
'T' :
if KindOfNode = 'TYPE' th-n
begin
Nd.kind := _type;
new(Nd.c_type);
with Nd.c_type^ do
begin
ReadNodePtr;
as_id := NdPtr;
ReadAttribute;
ReadNodePtr;
as_dscrmt_var_s := NdPtr;
ReadAttribute^
ReadNodePtr;
as_type_spec := NdPtr;
end;
end
else if KindOfNode = 'TYPE_ID' then
begin
Nd.kind := _type_id;
new(Nd.c_type_id);
with Nd.c_type_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_type_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_first := NdPtr;
end;
end
else
InvalidKindOfNode;
'U' :
if KindOfNode = 'UNIVERSAL_INTEGER' then
begin
Nd.kind := _universal_integer;
end
else if KindOfNode = 'USE' then
begin
Nd.kind := _use;
new(Nd.c_use);
Nd.c_use^.as_list := ReadList;
end
else if KindOfNode = 'USED_BLTN_OP' then
begin
Nd.kind := _used_bltn_op;
new(Nd.c_used_bltn_op);
with Nd.c_used_bltn_op^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadOperator(sm_operator);
end;
end
else if KindOfNode = 'USED_NAME_ID' then
begin
Nd.kind := _used_name_id;
new(Nd.c_used_name_id);
with Nd.c_used_name_id^ do
begin
Ix_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_defn := NdPtr;
end;
end
else if KindOfNode = 'USED_OBJECT_ID' then
begin
Nd.kind := _used_object_id;
new(Nd.c_used_object_id);
with Nd.c_used_object_id^ do
begin
1x_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_defn := NdPtr;
ReadAttribute;
ReadValue(sm_value);
end;
end
else
InvalidKindOfNode;
'V' :
if KindOfNode = 'VAR' then
begin
Nd.kind := _var;
new(Nd.c_var);
with Nd.c_var^ do
begin
ReadNodePtr;
as_id_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_type_spec := NdPtr;
ReadAttribute;
ReadNodePtr;
as_object_def := NdPtr;
end;
end
else if KindOfNode = 'VAR_ID' then
begin
Nd.kind := _var_id;
new(Nd.c_var_id);
with Nd.c_var_id^ do
begin
lx_symrep := ReadSymRep;
ReadAttribute;
ReadNodePtr;
sm_obj_type :^ NdPtr;
ReadAttribute;
ReadNodePtr;
sm_address := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_obj_def := NdPtr;
cd_compiled := false;
end;
end
else
InvalidKindOfNode;
'W' :
if KindOfNode = 'WHILE' then
begin
Nd.kind := _while;
new(Nd.c_while);
with Nd.c_while^ do
begin
ReadNodePtr;
as_exp := NdPtr;
end;
end
else if KindOfNode = 'WITH' then
begin
Nd.kind := _with;
new(Nd.c_with);
Nd.c_with^.as_list := ReadList;
end
else
InvalidKindOfNode;
else
InvalidKindOfNode;
end;
PUT_NODE(NodeNr, Nd);
end; {ReadNode}
begin {BuiIdDianaTree}
LineNr := 0;
WriteLnCReading from fiIe: ', FiIeName);
Assign(InFiIe, FiIeName);
{^I^}
Reset(InFiIe);
{^I+}
if IOResuIt <> 0 then
Error(7);
whiIe not Eof(InFiIe) do
begin
{Read next Iine and convert it to upper case.}
ReadLine;
for i := 1 to Length(Line) do
Line[i] := UpCase(Line[i]);
if not Eof(InFile) then
begin
{For debugging purposes.}
if PrintDianaNodes then
WriteLn(LineNr:5, ' ', Line);
{Read current node number.}
ConditionalError(4002, Line[1] <> 'D');  {Must be node definition}
Position := 2;
ReadLongInt(L, Position);
NodeNr := Word(L);
Conditiona1Error(4003, NodeNr <= 0);
{Skip blanks and colon.}
while (Position <= Length(Line)) and (Line[Position] in [' ', ':']) do
inc(Position);
{Read node name into 'KindOfNode'.}
BegPos := Position;
while (Position <= Length(Line)) and (Line[Position] in ['A' ..'-', '_']
inc(Position);
KindOfNode[0] := chr(Position - BegPos);
Move(Line[BegPos], KindOfNode[1], Position - BegPos);
{Read attributes (if any) and create node.}
ReadNode;
end; {if}
end; {while}
Close(InFile);
end; {BuildDianaTree}
end. {ExtDiana}
case Line[1] of
'L', '1'  : AType := 1x;
'A', 'a'  : AType := as;
'S', 's'  : AType := sm;
']'  :
begin
AType := no_attribute;
exit;
end;
else
ConditionalError(4006, true);
end;
Position := 4;
while (Line[Position] in Charslnldent) and (Position < Length(Line)) do
inc(Position);
AttributeName[0] := Chr(Position - 4);
Move(Line[4], AttributeName[1], Position - 4);
Delete(Line, 1, Position);
end; {ReadAttribute}
{Read node pointer into 'NdPtr'.}
procedure ReadNodePtr;
begin
SkipChars([' ']);
if Line[1] in ['V'..'v'] then
begin                                                            {'void'}
NdPtr := NULL_TREE;
De1ete(Line, 1^, 4);
end
e1se
begin
Conditiona1Error(4005, Line[1] <> 'D');
Position := 2;
ReadLonglnt(L, Position);
ConditionalError(4005, Line[Position] <> ' ');
NdPtr := Word(L);
Delete(Line, 1, Position);
end;
end; {ReadNodePtr}
procedure Readlnteger(var i: integer);
begin
SkipChars([' ']);
ConditionalError(4005, not (Line[1] in [ '0'..'9']));
Position :^ 1;
ReadLonglnt(L, Position);
i := Integer(L);
Delete(Line, 1, Position);
end; {Readlnteger}
function ReadList : SEQ_TYPE;
var List, Temp : SEQ_TYPE;
begin
SkipChars([' ']);
Conditiona1Error(4005, Line[1] <> '<');
Delete(Line, 1, 1);
List := GET_EMPTY;
SkipChars([' ']);
while Line[1] <> '>' do
begin
ReadNodePtr;
new(Temp);
List     := APPEND(List, NdPtr);
SkipChars([' ']);
if Length(Line) = 0 then
begin
ReadLine;
SkipChars([' ']);
end;
end;
ReadList := List;
end; {ReadList}
procedure ReadBinaryOp( var b_op : binary_op);
begin
SkipChars([' ']);
case Line[1] of
'A', 'a' : b_op := AND_THEN;
'O', 'o' : b_op := OR_ELSE;
else
InvalidAttributeValue;
end;
end; {ReadBinaryOp}
procedure ReadValue( var v : value);
begin
SkipChars([' ']);
with v do
case Line[1] of
'V' : v_type := no_value;
'^' :
begin
v_type  := char_value;
Position := 2;
ReadLonglnt(L, Position);
chr_val := Chr(L);
Delete(Line, 1, Position);
end;
'F' :
begin
v_type := bool_value;
boo_val := false;
end;
'T' :
begin
v_type := bool_value;
boo_val := true;
end;
'I' :
begin
v_type  := int_value;
Position := 2;
ReadLonglnt(L, Position);
int_val := Integer(L);
Delete(Line, 1, Position);
end;
else
1nvalidAttributeValue;
end;
end; {ReadValue}
function ReadSymRep : symbol_rep;
var
i : Byte;
begin
SkipChars([' ']);
ConditionalError(4005, Line[1] <> '^');
i := 2;
whi1e (i < Length(Line)) and (Line[i] <> '^') do
begin
Line[i] := UpCase(Line[i]);
inc(i);
end;
Conditiona1Error(4005, i >= Length(Line));
Move(Line[2], S[1], i-2);
S[0] := chr(i-2);
ReadSymRep := PutSymbo1(S);
end; {ReadSymRep}
procedure ReadOperator(var op: Operator);
var
S: String;
i : Byte;
begin {ReadOperator}
i := 1;
whi1e (i < Length(Line)) and (Line[i] in Charslnldent) do
begin
Line[i] := UpCase(Line[i]);
inc(i);
end;
ConditionalError(4005, i >= Length(Line));
Move(Line[1], S[1], i-1);
S[0] := chr(i-1);
case S[1] of
'A' :
if S = 'ABS' then
op := op_abs
else if S = 'AND' then
op := op_and
e1se
Inva1idAttributeVa1ue;
'C' :
if S = 'CAT' then
op := op_cat
else
InvalidAttributeValue;
'D' :
if - = 'DIV' then
op := op_div
else
InvalidAttributeValue;
'E' :
if - = 'EQ' then
op := op_eg
else if S = 'E)(P' then
op := op_exp
else
InvalidAttributeValue;
'G' :
if S = 'GE' then
op := op_ge
else if S = 'GT' then
op := op_gt
else
InvalidAttributeValue;
'L' :
if S = 'LE' then
op := op_le
else if - = 'LT' then
op := op_lt
else
InvalidAttributeValue;
'M' :
if S = 'MINUS' then
op := op_minus
else if S = 'MOD' then
op := op_mod
else if S = 'MULT' then
op := op_mult
else
InvalidAttributeValue;
'N' :
if S = 'NE' then
op := op_ne
else if S = 'NOT' then
op := op_not
else
InvalidAttributeValue;
'O' :
if S = 'OR' then
op := op_or
else
InvalidAttributeValue;
'P' :
if S = 'PLUS' then
op := op_plus
else
InvalidAttributeValue;
'^' :
if S= 'REM' then
op := op_rem
else
InvalidAttributeValue;
'U' :
if - = 'UNARY_MINUS' then
op := op_unary_minus
else if S = 'UNARY_PLUS' then                       ^
op := op_unary_plus
else
InvalidAttributeValue;
')(' :
if - = ')(OR' then
op := op_plus
else
InvalidAttributeValue;
else
InvalidAttributeValue;
end;
end; {ReadOperator}
procedure InvalidKindOfNode;
begin
ConditionalError(4004, true);
end; {lnvalidKindOfNode}
begin
Nd. lx_srcpos.fi le_nr := 0;
ReadAttribute;
if AType = 1x then
if AttributeName = 'SRCPOS' then
begin
SkipChars([' ']);
ConditionalError(4005, Line[1] <> '^');
Delete(Line, 1, 1);
Fi1eName := '';
while (Line[1] <> '^') and (Length(Line) > 0) do
begin
ConditionalError(4005, Length(FileName) >= MaxFileNameLen);
FileName := FileName + Line[1];
Delete(Line, 1, 1);
end;
Conditiona1Error(4005, Line[1] <> '^');
Delete(Line, 1, 1);
SkipChars([' ']);
Position := 1;
ReadLonglnt(L1, Position);
De1ete(Line, 1, Position);
SkipChars([' ']);
Position := 1;
ReadLongInt(L2, Position);
with Nd.lx_srcpos do
begin
file_nr := FileNameNumber(FileName);
col_nr := Byte(L2);
line_nr := Word(L1);
end;
Delete(Line, 1, Position);
SkipChars([' ']);
if Line[1] <> ']' then
ReadAttribute;
end;
case KindOfNode[1] of
'A' :
if KindOfNode = 'ACCESS' then
begin
Nd.kind := _access;
new(Nd.c_access);
with Nd.c_access^ do
begin
ReadNodePtr;
as_constrained := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_size := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_storage_size := NdPtr;
ReadAttribute;
ReadValue(TempValue);
sm_controlled := TempValue.boo_val;
end;
end
else if KindOfNode = 'ALL' then
begin
Nd.kind := _all;
new(Nd.c_all);
with Nd.c_all^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
end;
end
else if KindOfNode = 'ALLOCATOR' then
begin
Nd.kind := _allocator;
new(Nd.c_allocator);
with Nd.c_allocator^ do
begin
ReadNodePtr;
as_exp_constrained := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_exp_type := NdPtr;
ReadAttribute;
ReadValue(sm_value);
end;
end
else if KindOfNode = 'ALTERNATIVE' then
begin
Nd.kind := _alternative;
new(Nd.c_alternative);
with Nd.c_alternative^ do
begin
ReadNodePtr;
as_choice_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_stm_s := NdPtr;
end;
end
else if KindOfNode = 'ALTERNATIVE_S' then
begin
Nd.kind := _alternative_s;
new(Nd.c_alternative_s);
Nd.c_alternative_s^.as_list := ReadList;
end
else if KindOfNode = 'ARRAY' then
begin
Nd.kind := _array;
new(Nd.c_array);
with Nd.c_array^ do
begin
ReadNodePtr;
as_dscrt_range_s := NdPtr;
ReadAttribute;
ReadNodePtr;
as_constrained := NdPtr;
ReadAttribute;
ReadNodePtr;
sm_size := NdPtr;
ReadAttribute;
ReadValue(TempValue);
sm_packing := TempValue.boo_val;
cd_compiled := false;
end;
end
else if KindOfNode = 'ASSIGN' then
begin
Nd.kind := _assign;
new(Nd.c_assign);
with Nd.c_assign^ do
begin
ReadNodePtr;
as_name := NdPtr;
ReadAttribute;
ReadNodePtr;
as_exp := NdPtr;
end;
end
else if KindOfNode = 'ASSOC' then
begin










unit Private;
{DIANA private types definitions}
interface
uses
CG_Lib;
const
MaxFileNr = 10;
MaxFi1eNameLen = 80;
Symbo1sBufferLen = 10000;
type
Fi1eNrType     = Byte;
FileNameType   = string [MaxFileNameLen];
source_position -
record
file_nr : FileNrType;
col_nr : Byte;
line_nr : Word;
end;
symbol_rep = Word;
number_rep = symbol_rep;
value_types = (
no_value,                      string_value,      bool_value,       int_value,
char_value
^;
value     =
record
case v_type : value_types of
no_value    : ();
string_value : (str_val  : symbol_rep);
bool_value  : (boo_val : Boo^ean);
int_yalue   : (int_val : integer);
char_value  : (chr_val  : char);
end;
binary_op = ( AND_THEN, OR_ELSE );
operator  = (
op_and,                          op_or,                            op_xor,                          op_eo^,
op^ne,                            ^p-^lt,                            ^-l^^                            ^^-^t,
op_ge,                            op_plus,                        op_minus,                      op_cat,
op_unary_plus,     op_unary_minus,    op_abs,                          op_not,
op_mult,                        op_div,                          op_mod,                          op_rem,
op_exp
^;
{Return number of the file name 'Name'.}
function FileNameNumber(Name: FileNameType): FileNrType;
{Return name of the file identified by number 'Nr'.}
function FileName(Nr: Byte): FileNameType;
{Return internal representation of the string 's'.}
function PutSymbol(s: string): symbol_rep;
{Return string represented by 'sym'.}
function GetSymbol(sym: symbol_rep): string;
{------------------------------------------------------}
implementation
var
FileNames                        : array [l..MaxFileNr] of FileNameType;   {Buffer for
storing file names}
NumberOfFileNames   : Byte;      {Current number of stored file names}
SymbolsBuffer      : array [1..Symbo1sBufferLen] of char;   {Buffer for
storing strings}
SymbolsBufferFillPtr : Word;       {Points to the first unused character in
'SymbolsBuffer'}
{------------------------^-----------------------------}
procedure ConditionalError(ErrorNumber: integer; ErrorCondition: Boolean);
begin
if ErrorCondition then
Error(ErrorNumber);
end; {ConditionalError}
{Search pattern 'Match' in 'Buffer'. 'MatLength' and 'BufLength' are
pattern and buffer lengths, respectively.}
function Search(var Buffer; BufLength : Word;
var Match; MatLength : Word) : Word;
const
NotFoundFlag = ^FFFF;
type
CharArray   = array [1. .65535] of char;
CharArrayPtr = ^CharArray;
var
Buf, Mat : CharArrayPtr;
i, j    : Word;
FirstCh : Char;
OK     : Boolean;
begin {Search}
if (MatLength <- BufLength) and (MatLength > 0) then
begin
Buf := -Buffer;
Mat := -Match;
FirstCh := Mat^[1];
for i := 1 to BufLength ^ MatLength + 1 do
if Buf^[i] = FirstCh then
begin
OK := true;
j :^ -;
while OK and (j <= MatLength) do
begin
OK := Buf^[i+j-1] = Mat^[j];
inc(j);
end;
if OK then
begin
Search := i - 1; {}
exit
end;
end;
end;
Search := NotFoundF1ag
end; {Search}
function Fi1eNameNumber(Name: Fi1eNameType): Fi1eNrType;
var
n : Byte;
begin
ConditionalError(5001, NumberOfFileNames >= MaxFileNr);
n := 1;
while n <= NumberOfFileNames do
begin
if Name = FileNames [n] then
begin
FileNameNumber := n;
Exit;
end;
inc(n);
end;
FileNames [n]    := Name;
NumberOfFileNames := n;
FileNameNumber   := n;
end; {FileNameNumber}
function FileName(Nr: Byte): FileNameType;
begin
ConditionalError(2, Nr > NumberOfFileNames);
FileName := FileNames [Nr];
end; {FileName}
{------------------------------------------------------}
function PutSymbol(s: string): symbol_rep;
var
i : Word;
begin
s := ' ' + Trim(s) + ' ';
ConditionalError(5002, SymbolsBufferFillPtr > SymbolsBufferLen - Length(s))
i := Search(SymbolsBuffer, SymbolsBufferFillPtr, s[1], Length(s));
if i = ^FFFF then
begin        {not found}
Move(s[2], SymbolsBuffer[Succ(SymbolsBufferFillPtr)], Pred(Length(s)));
PutSymbol := Succ(SymbolsBufferFillPtr);
inc(SymbolsBufferFillPtr, Pred(Length(s)));
end
else
PutSymbol := i + 2;
end; {PutSymbol}
function GetSymbol(sym: symbol_rep): string;
var i : Word;
j : Byte;
s : string;
begin
i := sym;
j := 0;
ConditionalError(4, i > SymbolsBufferFillPtr);
while SymbolsBuffer [i] <> ' ' do
begin
inc(j);
s[j] := SymbolsBuffer [i];
inc(i);
end;
s[0]     := Chr(j);
GetSymbol := s;
end; {PutSymbol}
{------------------------------------------------------}
begin {Private}
NumberOfFileNames   := 0;
SymbolsBufferFillPtr := 1;
SymbolsBuffer [1]   := ' ';
end. {Private}
l^ ^-a_CG^P^
program ^daCodeGenerator;
{This is the main program of the llPS^^da code generator.}
{Written by ^. Cierniak.
Compiler used: Turbo Pascal 5.5
Last changes made on ^lune 12. 1^9().
The complete program consists of following units:
^da_CG, CG1, CG_I)ecl, CG_Ex^pr, CG_Lib, CG_Param, CodeGen,
Diana, Ex^tl)iana, and Private.
}
uses
CodeGen,
Diana,
Ex^tBiana;
var
FileName : String;
^oot    : TREE;
begin {^daCodeGenerator}
Poot := NULL_TREE;
WriteLn;
WriteLn('^^^^^^^^^^^^^^^^ ^da Code Generator ^^^^^^^^^^^^^^^^');
if ParamCount < 1 then
begin      {No parameter specified}
Write('Enter file name: ');
ReadLn(FileName);
end
else
FileName := ParamStr(l);
{Read I)lAN^ representation of package ST^Nl)^RI).}
BuildBianaTree('C:ST^NI)^RI).1}N', Root);
{Read Bl^NA representation of the current compilation.}
BuildI)ianaTree(FileName + '.l)N', Root);
{and generate ^-code for the current compilation.}
CodeGenerator(Root, FileName +  '.^C');
WriteLn('^^^^^^^^^^^^^^ End of Compilation ^^^^^^^^^^^^^^^');
end. {AdaCodeGenerator}