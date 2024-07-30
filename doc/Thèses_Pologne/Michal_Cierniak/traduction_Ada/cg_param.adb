with CG_Lib; use CG_Lib;
with CG_Private; use CG_Private;
with CG1; use CG1;
with CG_Expr; use CG_Expr;

package body CG_Param is

   procedure ConditionalError(ErrorCode : Integer; Condition : Boolean) is
   begin
      if Condition then
      begin
         CloseOutputFile;
         Error(ErrorCode);
      end if;
   end ConditionalError;

   procedure GeneralInternalError is
   begin
      ConditionalError(999, True);
   end GeneralInternalError;

   function AllocateSpaceForType(t_type_spec : TREE) return OffsetType is
   begin
      case KIND(t_type_spec) is
         when _access =>
            begin
               IncrementOffset(AddrSize);
               Align(AddrAl);
               return OffsetAct;
            end;

         when _array =>
            begin
               IncrementOffset(AddrSize);
               Align(AddrAl);
               IncrementOffset(AddrSize);
               Align(AddrAl);
               return OffsetAct;
            end;

         when _enum_literal_s | _integer =>
            begin
               IncrementOffset(IntegerSize);
               Align(IntegerAl);
               return OffsetAct;
            end;

         others =>
            GeneralInternalError;
            return OffsetAct; -- Dummy return to satisfy function return type
      end case;
   end AllocateSpaceForType;

   procedure CompileParams_in(CurrParam : SEO_TYPE) is
      nd_in, nd_id_s, nd_in_id : NODE;
   begin
      if IS_EMPTY(CurrParam) then
         return;
      end if;

      CompileParams_in(TAIL(CurrParam));
      GET_NODE(HEAD(CurrParam), nd_in_id);
      with nd_in_id.c_in_id do
      begin
         cd_offset := AllocateSpaceForType(sm_obj_type);
         cd_level  := Level;
      end;
   end CompileParams_in;

   procedure CompileParams_in_out(CurrParam : SEQ_TYPE) is
      nd_in_out, nd_id_s, nd_in_out_id : NODE;
   begin
      if IS_EMPTY(CurrParam) then
         return;
      end if;

      CompileParams_in_out(TAIL(CurrParam));
      GET_NODE(HEAD(CurrParam), nd_in_out_id);
      with nd_in_out_id.c_in_out_id do
      begin
         cd_val_offset := AllocateSpaceForType(sm_obj_type);
         IncrementOffset(AddrSize);
         Align(AddrAl);
         cd_addr_offset := OffsetAct;
         cd_level       := Level;
      end;
   end CompileParams_in_out;

   procedure CompileParams_out(CurrParam : SEQ_TYPE) is
      nd_out, nd_id_s, nd_out_id : NODE;
   begin
      if IS_EMPTY(CurrParam) then
         return;
      end if;

      CompileParams_put(TAIL(CurrParam));
      GET_NODE(HEAD(CurrParam), nd_out_id);
      with nd_out_id.c_out_id do
      begin
         cd_val_offset := AllocateSpaceForType(sm_obj_type);
         IncrementOffset(AddrSize);
         Align(AddrAl);
         cd_addr_offset := OffsetAct;
         cd_level       := Level;
      end;
   end CompileParams_out;

   procedure CompileParams(CurrParam : SEQ_TYPE) is
      nd, nd_id_s : NODE;
   begin
      if IS_EMPTY(CurrParam) then
         return;
      end if;

      CompileParams(TAIL(CurrParam));
      GET_NODE(HEAD(CurrParam), nd);

      case KIND(HEAD(CurrParam)) is
         when _in =>
            begin
               GET_NODE(nd.c_in.as_id_s, nd_id_s);
               CompileParams_in(nd_id_s.c_id_s.as_list);
            end;

         when _in_out =>
            begin
               GET_NODE(nd.c_in_out.as_id_s, nd_id_s);
               CompileParams_in_out(nd_id_s.c_id_s.as_list);
            end;

         when _put =>
            begin
               GET_NODE(nd.c_out.as_id_s, nd_id_s);
               CompileParams_out(nd_id_s.c_id_s.as_list);
            end;

         others =>
            GeneralInternalError;
      end case;
   end CompileParams;

   procedure CopyOutParams(t_param_s : TREE) is
      nd_param_s, nd_curr_param : NODE;
      CurrParam                   : SEO_TYPE;
      t_curr_param                : TREE;

      procedure CopyOut(t_type_spec : TREE; Offset : OffsetType) is
      begin
         case KIND(t_type_spec) is
            when _access =>
               begin
                  Gen2NumNumT(aLOD, a_A, 0, Offset);
                  GenOT(aSTO, a_A);
               end;

            when _array =>
               null; -- Placeholder for array handling, currently not implemented in Pascal code

            when _enum_literal_s =>
               if BooleanType(t_type_spec) then
                  begin
                     Gen2NumNumT(aLOD, a_B, 0, Offset);
                     GenOT(aSTO, a_B);
                  end;
               elsif CharacterType(t_type_spec) then
                  begin
                     Gen2NumNumT(aLOD, a_C, 0, Offset);
                     GenOT(aSTO, a_C);
                  end;
               else
                  begin
                     Gen2NumNumT(aLOD, a_I, 0, Offset);
                     GenOT(aSTO, a_I);
                  end;

            when _integer =>
               begin
                  Gen2NumNumT(aLOD, a_I, 0, Offset);
                  GenOT(aSTO, a_I);
               end;

            others =>
               GeneralInternalError;
         end case;
      end CopyOut;

      procedure CopyOutParams_in_out is
         nd_id_s, nd_in_out_id : NODE;
         CurrParam              : SEQ_TYPE;
      begin
         GET_NODE(nd_curr_param.c_in_out.as_id_s, nd_id_s);
         CurrParam := nd_id_s.c_id_s.as_list;

         while not IS_EMPTY(CurrParam) loop
            GET_NODE(HEAD(CurrParam), nd_in_out_id);

            with nd_in_out_id.c_in_out_id do
            begin
               Comment := GetSymbol(lx_symrep);
               Gen2NumNumT(aLOD, a_A, 0, cd_addr_offset);
               CopyOut(sm_obj_type, cd_val_offset);
            end;

            CurrParam := TAIL(CurrParam);
         end loop;
      end CopyOutParams_in_out;

      procedure CopyOutParams_out is
         nd_id_s, nd_out_id : NODE;
         CurrParam           : SEQ_TYPE;
      begin
         GET_NODE(nd_curr_param.c_out.as_id_s, nd_id_s);
         CurrParam := nd_id_s.c_id_s.as_list;

         while not IS_EMPTY(CurrParam) loop
            GET_NODE(HEAD(CurrParam), nd_out_id);

            with nd_out_id.c_out_id do
            begin
               Comment := GetSymbol(lx_symrep);
               Gen2NumNumT(aLOD, a_A, 0, cd_addr_offset);
               CopyOut(sm_obj_type, cd_val_offset);
            end;

            CurrParam := TAIL(CurrParam);
         end loop;
      end CopyOutParams_out;

   begin
      if t_param_s = NULL_TREE then
         return;

      GET_NODE(t_param_s, nd_param_s);
      CurrParam := nd_param_s.c_param_s.as_list;

      while not IS_EMPTY(CurrParam) loop
         t_curr_param := HEAD(CurrParam);
         GET_NODE(t_curr_param, nd_curr_param);

         case KIND(t_curr_param) is
            when _in    => null; -- Placeholder for handling _in parameters, currently not implemented
            when _in_out => CopyOutParams_in_out;
            when _out   => CopyOutParams_out;
            others      => GeneralInternalError;
         end case;

         CurrParam := TAIL(CurrParam);
      end loop;
   end CopyOutParams;

end CG_Param;
