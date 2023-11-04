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
