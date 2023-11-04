   with Text_io;
   use  Text_io;
   --|----------------------------------------------------------------------------------------------
   --|	CG_Expr
   --|----------------------------------------------------------------------------------------------
    package body CG_Expr is
   
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	function Type_Spec_Of_Expr
       function Type_Spec_Of_Expr ( exp :Tree ) return Tree is
      begin
         case exp.ty is
            when dn_FUNCTION_CALL | dn_USED_OBJECT_ID=>
               return D ( sm_EXP_TYPE, exp );
            when others =>
               PUT_LINE ( "!!! Type_Struct_Of_Expr : exp.ty illicite " & Node_Name'IMAGE ( exp.ty ) );
               raise Program_Error;
         end case;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	function Constrained
       function Constrained ( type_spec :Tree ) return Boolean is
      begin
         return not ( type_Spec.ty in class_UNCONSTRAINED );
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	function Type_Size
       function Type_Size ( type_Spec :Tree ) return Natural is
      begin
         case type_Spec.ty is
            when dn_ACCESS =>
               return addr_Size;
            when dn_CONSTRAINED_ARRAY =>
               return 2* addr_Size;
            when dn_ENUMERATION | dn_INTEGER =>
               return Intg_Size;
            when others =>
               PUT_LINE ( "!!! Type_Size : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
               raise Program_Error;
         end case;
      end;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Load_Type_Size
       procedure Load_Type_Size ( type_Spec :Tree ) is
      begin
         if CONSTRAINED ( type_Spec ) then
            GEN_1_I ( const, I, TYPE_SIZE ( type_Spec ), "Load type size" );
         else
            PUT_LINE ( "!!! Load_Type_Size : type_Spec non contraint " );
            raise Program_Error;
         end if;
      end Load_Type_Size;
      --|-------------------------------------------------------------------------------------------
      --|	function Level_Of_Type
       function Level_Of_Type ( type_spec :Tree ) return Level_Type is
      begin
         if type_Spec.ty = dn_ACCESS then
            return DI ( cd_LEVEL, type_Spec );
         else
            PUT_LINE ( "!!! Exp_Indexed : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
            raise Program_Error;
         end if;
      end Level_Of_Type;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	function Code_Type_Of
       function Code_Type_Of ( exp_or_type_spec :Tree ) return Code_Type is
      begin
         if exp_or_type_spec.ty in class_EXP then
            declare
               exp	: Tree	renames exp_or_type_spec;
            begin
               case exp.ty is
                  when dn_FUNCTION_CALL | dn_PARENTHESIZED | dn_USED_OBJECT_ID =>
                     return CODE_TYPE_OF ( D ( sm_EXP_TYPE, exp ) );
                     
                  when others =>
                     PUT_LINE ( "!!! Code_Type_Of : exp.ty illicite " & Node_Name'IMAGE ( exp.ty ) );
                     raise Program_Error;
               end case;
            end;
            
         elsif exp_or_type_spec.ty in class_TYPE_SPEC then
            declare
               type_spec	: Tree	renames exp_or_type_spec;
            begin
               case type_spec.ty is
                  when dn_ACCESS =>
                     return A;
                  
                  when dn_ENUMERATION =>
                     declare
                        type_source_name	: Tree	:= D ( xd_SOURCE_NAME, type_spec );
                        type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
                        name	: constant String	:= PRINT_NAME ( type_symrep );
                     begin
                        if name = "BOOLEAN" then
                           return B;
                        elsif name = "CHARACTER" then
                           return C;
                        else
                           return I;
                        end if;
                     end;
                  
                  when dn_INTEGER | dn_NUMERIC_LITERAL =>
                     return I;
                  
                  when others =>
                     PUT_LINE ( "!!! Code_Type_Of : type_spec.ty illicite " & Node_Name'IMAGE ( type_spec.ty ) );
                     raise Program_Error;
               end case;
            end;
            
         else
            PUT_LINE ( "!!! Code_Type_Of : exp_or_type_spec.ty illicite " & Node_Name'IMAGE ( exp_or_type_spec.ty ) );
            raise Program_Error;
         end if;
      end Code_Type_Of;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Load_Address_indexed
       procedure Load_Address_Indexed ( indexed :Tree ) is
      
          procedure Index ( exp_seq :SEQ_TYPE ) is
            exp_s	: Seq_Type	:= exp_seq;
            exp	: Tree;
         begin
            POP ( exp_s, exp );
            COMPILE_EXPRESSION ( exp );
            if IS_EMPTY ( exp_s ) then
               GEN_CSP ( AR2, "Compute address for last (fast) index" );
            else
               GEN_CSP ( AR1, "Compute address for intermediate index" );
               GEN_1_I ( dec, A, 3*intg_Size, "Lower descriptor pointer to next index triplet" );
               INDEX ( exp_s );
               GEN_0 ( add, I, "Add index offset to address from previous indices" );
            end if;
         end Index;
      
      begin
         LOAD_OBJECT_ADDRESS ( D ( as_NAME, indexed ) );
         GEN_0 ( DPL, A, "Duplicate array object address" );
         GEN_1_I ( ind, A, 0, "Indexed load from array object address" );
         GEN_0 ( swap, A, "Array object address on stack top again" );
         GEN_1_I ( ind, A, -addr_Size, "Indexed load of array descriptor address (from array object address - pointer size)" );
         GEN_1_I ( dec, A, intg_Size, "Lower address by integer size" );
         declare
            exp_seq	: Seq_Type	:= LIST ( D ( as_EXP_S, indexed ) );
         begin
            if not IS_EMPTY ( exp_seq ) then
               INDEX ( exp_seq );
            end if;
         end;
         GEN_1_I ( IXA, 1 );
      end Load_Address_indexed;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Load_Address
       procedure Load_Address ( object :Tree ) is
      begin
         case object.ty is
            when dn_VARIABLE_ID =>				--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; VC_NAME
               GEN_LOAD ( A, DI (cd_COMP_UNIT, object ), DI ( cd_LEVEL, object ), DI ( cd_OFFSET, object ) );
         
            when dn_IN_ID =>				--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; PARAM_NAME
               GEN_LOAD ( A, 0,  DI ( cd_LEVEL, object ), DI ( cd_OFFSET, object ) );
         
            when dn_IN_OUT_ID | dn_OUT_ID =>			--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; PARAM_NAME ; PARAM_IO_O
               GEN_LOAD ( A, 0, DI ( cd_LEVEL, object ), DI ( cd_VAL_OFFSET, object ) );
         
            when dn_INDEXED =>				--| De classe EXP ; NAME ; NAME_EXP
               LOAD_ADDRESS_INDEXED ( object );
         
            when dn_USED_OBJECT_ID =>				--| De classe EXP ; NAME ; DESIGNATOR ; USED_OBJECT
               LOAD_ADDRESS ( D ( sm_DEFN, object ) );
            when others =>
               PUT_LINE ( "!!! Load_Address : object.ty illicite " & Node_Name'IMAGE ( object.ty ) );
               raise Program_Error;
         end case;
      end Load_Address;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Load_Object_Address
       procedure Load_Object_Address ( object :Tree ) is
      begin
         case object.ty is
            when dn_VARIABLE_ID =>				--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; VC_NAME
               GEN_LOAD_ADDR( DI (cd_COMP_UNIT, object ), DI ( cd_LEVEL, object ), DI ( cd_OFFSET, object ),
                  "Push the variable object address" );
         
            when dn_IN_ID =>				--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; PARAM_NAME
               GEN_2_II ( LDA, CG_1.level - DI ( cd_LEVEL, object ), DI ( cd_OFFSET, object ),
                  "Push the IN object address" );
         
            when dn_IN_OUT_ID | dn_OUT_ID =>			--| De classe OBJECT_NAME ; INIT_OBJECT_NAME ; PARAM_NAME ; PARAM_IO_O
               GEN_2_II ( LDA, CG_1.level -  DI ( cd_LEVEL, object ), DI ( cd_VAL_OFFSET, object ),
                  "Push the IN_OUT/OUT object address" );
         
            when dn_INDEXED =>				--| De classe EXP ; NAME ; NAME_EXP
               LOAD_ADDRESS_INDEXED ( object );
         
            when dn_USED_OBJECT_ID =>				--| De classe EXP ; NAME ; DESIGNATOR ; USED_OBJECT
               LOAD_OBJECT_ADDRESS ( D ( sm_DEFN, object ) );
         
            when others =>
               PUT_LINE ( "!!! Load_Object_Address : object.ty illicite " & Node_Name'IMAGE ( object.ty ) );
               raise Program_Error;
         end case;
      end Load_Object_Address;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Get_CLO
       procedure Get_CLO ( object :Tree; comp_Unit :out Comp_Unit_Nbr; lvl :out Level_Type; ofs :out Offset_Type ) is
      begin
         case object.ty is
            when dn_IN =>
               comp_Unit := 0;
               lvl := DI ( cd_LEVEL, object );
               ofs := DI ( cd_OFFSET, object );
         
            when dn_IN_OUT_ID | dn_OUT_ID =>
               comp_Unit := 0;
               lvl := DI ( cd_LEVEL, object );
               ofs := DI ( cd_VAL_OFFSET, object );
         
            when dn_INTEGER =>
               comp_Unit := DI (cd_COMP_UNIT, object );
               lvl      := DI ( cd_LEVEL, object );
               ofs     := DI ( cd_OFFSET, object );
         
            when dn_VARIABLE_ID =>
               comp_Unit := DI (cd_COMP_UNIT, object );
               lvl       := DI ( cd_LEVEL, object );
               ofs      := DI ( cd_OFFSET, object );
         
            when others =>
               PUT_LINE ( "!!! Get_CLO : object.ty illicite " & Node_Name'IMAGE ( object.ty ) );
               raise Program_Error;
         end case;
      end Get_CLO;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Load_Params
       procedure Load_Params ( normalized_param_s :Tree ) is
         normalized_param_seq	: Seq_Type	:= LIST ( normalized_param_s );
         normalized_param	: Tree;
      begin
         while not IS_EMPTY ( normalized_param_seq ) loop
            POP ( normalized_param_seq, normalized_param );
            COMPILE_EXPRESSION ( normalized_param );
         end loop;
      end Load_Params;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Used_Op
       procedure Used_Op ( function_call :Tree ) is
         operator_id	: Tree	:= D ( as_NAME, function_call );
         op_String		: constant String	:= PRINT_NAME ( D (lx_SYMREP, operator_id ) );
         normalized_param_s	: Tree	:= D ( sm_NORMALIZED_PARAM_S, function_call );
         normalized_param_seq	: Seq_Type	:= LIST ( normalized_param_s );
         normalized_param	: Tree;
         CT		: Code_Type;
      begin
         LOAD_PARAMS ( normalized_param_s );
         POP ( normalized_param_seq, normalized_param );
         CT := CODE_TYPE_OF ( normalized_param );
         if op_String = """AND""" then
            GEN_0 ( band );
            
         elsif op_String = """OR""" then
            GEN_0 ( bor );
            
         elsif op_String = """XOR""" then
            GEN_0 ( bxor );
            
         elsif op_String = """=""" then
            GEN_0 ( eq );
            
         elsif op_String = """/=""" then
            GEN_0 ( neq );
            
         elsif op_String = """<""" then
            GEN_0 ( lt );
            
         elsif op_String = """<=""" then
            GEN_0 ( le );
            
         elsif op_String = """>""" then
            GEN_0 ( gt );
            
         elsif op_String = """>=""" then
            GEN_0 ( ge );
         
         elsif op_String = """+""" then
            GEN_0 ( add, CT );
            
         elsif op_String = """-""" then
            if IS_EMPTY ( normalized_param_seq ) then
               GEN_0 ( neg, CT );
            else
               GEN_0 ( sub, CT );
            end if;
            
         elsif op_String = """&""" then
            GEN_0 ( band );
            
         elsif op_String = """/""" then
            GEN_0 ( div, CT );
            
         elsif op_String = """*""" then
            GEN_0 ( mul, CT );
            
         elsif op_String = """MOD""" then
            GEN_0 ( modu, CT );
            
         elsif op_String = """REM""" then
            GEN_0 ( remn, CT );
            
         elsif op_String = """**""" then
            GEN_0 ( exp, CT );
            
         elsif op_String = """ABS""" then
            GEN_0 ( absv, CT );
            
         elsif op_String = """NOT""" then
            GEN_0 ( bnot );
            
         end if;
      end Used_Op;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Allocator
       procedure Allocator ( type_Spec :Tree ) is
      begin
         LOAD_TYPE_SIZE ( type_Spec );
         GEN_1_I ( alloc, CG_1.level - LEVEL_OF_TYPE ( type_Spec ), "Allocate memory for given type size" );
      end Allocator;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Short_Circuit
       procedure Short_Circuit ( short :Tree ) is
         Lbl_1	: Label_Type	:= NEXT_LABEL;
         Lbl_2	: Label_Type	:= NEXT_LABEL;
      begin
         COMPILE_EXPRESSION ( D ( as_EXP1, short ) );
      
         if short.ty = dn_AND_THEN then
            GEN_1_L ( jmpf, Lbl_1, "Short circuit and_then if first expression false" );
         elsif short.ty = dn_OR_ELSE then
            GEN_1_L ( jmpt, Lbl_1, "Short circuit or_else if first expression true" );
         end if;
      
         COMPILE_EXPRESSION ( D ( as_EXP2, short ) );
         GEN_1_L ( jmp, Lbl_2, "Leave short circuit with second expression result" );
         WRITE_LABEL ( Lbl_1 );
         GEN_1_B ( const, (short.ty = dn_OR_ELSE),
            "Push constant true if or_else short circuit, false otherwise" );
         WRITE_LABEL ( Lbl_2 );
      end Short_Circuit;
   
      --|-------------------------------------------------------------------------------------------
      --|	procedure Exp_Function_Call
       procedure Exp_Function_Call ( function_call :Tree ) is
         name	: Tree	:= D ( as_NAME, function_call );
      begin
         case name.ty is
            when dn_USED_OP =>
               USED_OP ( function_call );
               
            when dn_USED_NAME_ID =>
               Exp_function_Call_Used_Name_Id:
               declare
                  function_id	: Tree	:= D ( sm_DEFN, name );
                  result_Size	: Natural	:= DI ( cd_RESULT_SIZE, function_id );
                  function_level	: Natural	:= DI ( cd_LEVEL, function_id );
                  param_Size	: Natural	:= DI (cd_PARAM_SIZE, function_id );
                  function_Label	: Natural	:= DI (cd_LABEL, function_id );
               begin
                  GEN_2_II ( MST, result_Size, CG_1.level - function_level +1 );
                  LOAD_PARAMS ( D ( sm_NORMALIZED_PARAM_S, function_call ) );
                  GEN_2_IL ( call, param_Size, function_Label,
                     "Calling function " & PRINT_NAME ( D ( lx_SYMREP, function_Id ) ) );
                  declare
                     exp_Type_Spec	: Tree	:= D ( sm_EXP_TYPE, function_call );
                     comp_Unit	: Comp_Unit_Nbr;
                     lvl	: Level_Type;
                     ofs	: Offset_Type;
                  begin
                     if exp_Type_Spec.ty = dn_INTEGER then
                        GET_CLO ( exp_Type_Spec, comp_Unit, lvl, ofs );
                        GEN_LOAD_ADDR ( comp_Unit, Lvl, ofs, "Push address of integer result" );
                        GEN_CSP ( CVB, "Check the integer bounds" );					--| Vérifier les bornes
                     end if;
                  end;
               end Exp_function_Call_Used_Name_Id;
               
            when others =>
               PUT_LINE ( "!!! Exp_Function_Call : name.ty illicite " & Node_Name'IMAGE ( name.ty ) );
               raise Program_Error;
         end case;
      end Exp_Function_Call;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Exp_Indexed
       procedure Exp_Indexed ( indexed :Tree ) is
         exp_Type_Spec	: Tree	:= D ( sm_EXP_TYPE, indexed );
      begin
         LOAD_ADDRESS_INDEXED ( indexed );
         case exp_Type_Spec.ty is
            when dn_ACCESS =>
               GEN_1_I ( ind, A, 0, "Push the address from the pointer" );
               
            when dn_ENUMERATION | dn_INTEGER =>
               GEN_1_I ( ind, I, 0, "Push the enumerated/integer value from pointer" );
               
            when others =>
               PUT_LINE ( "!!! Exp_Indexed : exp_Type_Spec.ty illicite " & Node_Name'IMAGE ( exp_Type_Spec.ty ) );
               raise Program_Error;
         end case;
      end Exp_Indexed;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Name_Character_Id
       procedure Name_Character_Id ( character_id :Tree ) is
      begin
         GEN_1_I ( const, I, DI ( sm_REP, character_id ),
            "Push the " & PRINT_NAME ( D ( lx_SYMREP, character_id ) ) & " character value" );
      end Name_Character_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Name_Enumeration_Id
       procedure Name_Enumeration_Id ( enumeration_id :Tree ) is
      begin
         GEN_1_I ( const, I, DI ( sm_REP, enumeration_id ),
            "Push the " & PRINT_NAME ( D ( lx_SYMREP, enumeration_id ) ) & " constant enumerated value" );
      end Name_Enumeration_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure BCI_Load
       procedure BCI_Load ( type_Spec :Tree; comp_unit :Comp_Unit_Nbr; lvl :Level_Type; ofs :Offset_Type; comment :String := "" ) is
         type_source_name	: Tree	:= D ( xd_SOURCE_NAME, type_spec );
         type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
         name		: constant String	:= PRINT_NAME ( type_symrep );
      begin
         if name = "BOOLEAN" then
            GEN_LOAD ( B, comp_unit, lvl, ofs, comment );
         elsif name = "CHARACTER" then
            GEN_LOAD ( C, comp_unit, lvl, ofs, comment );
         else
            GEN_LOAD ( I, comp_unit, lvl, ofs, comment );
         end if;
      end;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Name_In_Id
       procedure Name_In_Id ( in_id :Tree ) is
         type_Spec	: Tree	:= D ( sm_OBJ_TYPE, in_id );
         lvl	: Level_Type	:= DI ( cd_LEVEL, in_id );
         ofs	: Offset_Type	:= DI ( cd_OFFSET, in_id );
      begin
         case type_Spec.ty is
            when dn_ACCESS =>
               GEN_LOAD ( A, 0, lvl, ofs, "Push the IN access pointer" );
         
            when dn_CONSTRAINED_ARRAY =>
               GEN_LOAD_ADDR ( 0, lvl, ofs, "Push the IN array fat pointer address" );
               GEN_1_I ( GET, 2*addr_Size, "Push the array fat pointer (descriptor address and array data address)" );
               
            when dn_ENUMERATION =>
               BCI_LOAD ( type_Spec, 0, lvl, ofs, "Push the IN enumeration value" );
         
            when dn_INTEGER =>
               GEN_LOAD ( I, 0, lvl, ofs, "Push the IN integer value" );
                  
            when others =>
               PUT_LINE ( "!!! Name_Iteration_Id : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
               raise Program_Error;
         end case;
      end Name_In_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure IO_O_Id
       procedure IO_O_Id ( io_o_id :Tree ) is
         type_Spec	: Tree	:= D ( sm_OBJ_TYPE, io_o_id );
         lvl	: Level_Type	:= DI ( cd_LEVEL, io_o_id );
         val_Ofs	: Offset_Type	:= DI ( cd_VAL_OFFSET, io_o_id );
      begin
         case type_Spec.ty is
            when dn_ACCESS =>
               GEN_LOAD ( A, 0, lvl, val_Ofs, "Push the IN_OUT/OUT access pointer" );
         
            when dn_CONSTRAINED_ARRAY =>
               GEN_LOAD_ADDR ( 0, lvl, val_Ofs, "Push the IN_OUT/OUT array fat pointer address" );
               GEN_1_I ( GET, 2*addr_Size, "Push the array fat pointer (descriptor address and array data address)" );
         
            when dn_ENUMERATION =>
               BCI_LOAD ( type_Spec, 0, lvl, val_Ofs, "Push the IN_OUT/OUT enumeration offset" );
         
            when dn_INTEGER =>
               GEN_LOAD ( I, 0, lvl, val_Ofs, "Push the IN_OUT/OUT integer offset" );
                  
            when others =>
               PUT_LINE ( "!!! Name_Iteration_Id : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
               raise Program_Error;
         end case;
      end IO_O_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Name_Iteration_Id
       procedure Name_Iteration_Id ( iteration_id :Tree ) is
         type_Spec	: Tree	:= D ( sm_OBJ_TYPE, iteration_id );
         lvl	: Level_Type	:= DI ( cd_LEVEL, iteration_id );
         ofs	: Offset_Type	:= DI ( cd_OFFSET, iteration_id );
      begin
         case type_Spec.ty is
            when dn_ENUMERATION =>
               BCI_LOAD ( type_Spec, 0, lvl, ofs, "Push the enumerated iteration counter" );
               
            when dn_INTEGER =>
               GEN_LOAD ( I, 0, lvl, ofs, "Push the integer iteration counter" );
                  
            when others =>
               PUT_LINE ( "!!! Name_Iteration_Id : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
               raise Program_Error;
         end case;
      end Name_Iteration_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure VCName_Id
       procedure VCName_Id ( variable_id :Tree ) is
         type_Spec	: Tree	:= D ( sm_OBJ_TYPE, variable_id );
         comp_unit	: Comp_Unit_Nbr	:= DI ( cd_COMP_UNIT, variable_id );
         lvl	: Level_Type	:= DI ( cd_LEVEL, variable_id );
         ofs	: Offset_Type	:= DI ( cd_OFFSET, variable_id );
      begin
         case type_Spec.ty is
            when dn_ACCESS =>
               GEN_LOAD ( A, comp_unit, lvl, ofs, "Load the pointer" );
         
            when dn_CONSTRAINED_ARRAY =>
               GEN_LOAD_ADDR ( comp_unit, lvl, ofs, "Push the address for loading" );
               GEN_1_I ( GET, 2*addr_Size, "Load 2 pointers (descriptor address and array data address)" );
         
            when dn_ENUMERATION =>
               BCI_LOAD ( type_Spec, comp_unit, lvl, ofs );
         
            when dn_INTEGER =>
               GEN_LOAD ( I, comp_unit, lvl, ofs, "Push the integer" );
               GET_CLO ( type_spec, comp_unit, lvl, ofs );
               GEN_LOAD_ADDR ( comp_unit, lvl, ofs, "Push address of integer type bounds" );
               GEN_CSP ( CVB, "Check for bounds" );
         
            when others =>
               PUT_LINE ( "!!! Name_Variable_Id : type_Spec.ty illicite " & Node_Name'IMAGE ( type_Spec.ty ) );
               raise Program_Error;
         end case;
      end VCName_Id;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Exp_Used_Object_Id
       procedure Exp_Used_Object_Id ( used_object_id :Tree ) is
         value	: Tree	:= D ( sm_VALUE, used_object_id );
      begin
         case value.ty is
            when class_BOOLEAN =>
               GEN_1_B ( const, DB ( sm_VALUE, used_object_id ), "Push the boolean constant value" );
            -- when dn_CHARACTER =>
               -- GEN_1_C ( const, C, DI ( sm_VALUE, used_object_id ) );
               
            when dn_NUM_VAL =>
               GEN_1_I ( const, I, DI ( sm_VALUE, used_object_id ), "Push the integer constant value" );
               
            when dn_VOID =>				--| Objet sans valeur constante
               declare
                  name	: Tree	:= D ( sm_DEFN, used_object_id );
               begin
                  case name.ty is
                     when dn_CONSTANT_ID | dn_VARIABLE_ID =>
                        VCNAME_ID ( name );
                        
                     when dn_CHARACTER_ID =>
                        NAME_CHARACTER_ID ( name );
                        
                     when dn_ENUMERATION_ID =>
                        NAME_ENUMERATION_ID ( name );
                        
                     when dn_IN_ID =>
                        NAME_IN_ID ( name );
                        
                     when dn_IN_OUT_ID | dn_OUT_ID =>
                        IO_O_ID ( name );
                        
                     when dn_ITERATION_ID =>
                        NAME_ITERATION_ID ( name );
                        
                     when others =>
                        raise Program_Error;
                  end case;
               end;
            when others =>
               raise Program_Error;
         end case;
      end Exp_Used_Object_Id;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Exp_Used_Object_Id
       procedure Compile_Expression ( exp :Tree ) is
      begin
         case exp.ty is
            when dn_QUALIFIED_ALLOCATOR | dn_SUBTYPE_ALLOCATOR =>
               ALLOCATOR ( D ( sm_EXP_TYPE, exp ) );
               
            when dn_AND_THEN | dn_OR_ELSE =>
               SHORT_CIRCUIT ( exp );
               
            when dn_FUNCTION_CALL =>
               EXP_FUNCTION_CALL ( exp );
               
            when dn_INDEXED =>
               EXP_INDEXED ( exp );
               
            when dn_NUMERIC_LITERAL =>
               GEN_1_I ( const, I, DI ( sm_VALUE, exp ) );
               
            when dn_PARENTHESIZED =>
               COMPILE_EXPRESSION ( D ( as_EXP, exp ) );
               
            when dn_USED_OBJECT_ID =>
               EXP_USED_OBJECT_ID ( exp );
               
            when others =>
               PUT_LINE ( "!!! Compile_Expression : exp.ty illicite " & Node_Name'IMAGE ( exp.ty ) );
            -- dn_USED_OP
            -- dn_USED_NAME_ID
            -- dn_USED_CHAR
            -- dn_SLICE
            -- dn_SELECTED
            -- dn_ALL
            -- dn_ATTRIBUTE
            -- dn_AGGREGATE
            -- dn_SHORT_CIRCUIT
            -- dn_RANGE_MEMBERSHIP
            -- dn_TYPE_MEMBERSHIP
            -- dn_STRING_LITERAL
            -- dn_NULL_ACCESS
            -- dn_CONVERSION
            -- dn_QUALIFIED
            -- dn_QUALIFIED_OPERATOR
            -- dn_SUBTYPE_ALLOCATOR
            
               raise Program_Error;
         end case;
      end Compile_Expression;
   
   --|----------------------------------------------------------------------------------------------
   end CG_Expr;
