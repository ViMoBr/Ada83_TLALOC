   with CG_1;
   use  CG_1;
   --|----------------------------------------------------------------------------------------------
   --|	CG_Param
   --|----------------------------------------------------------------------------------------------
    Package body CG_Param is
   
      --|-------------------------------------------------------------------------------------------
      --|	function Allocate_Space_For_Type
       function Allocate_Space_For_Type ( type_spec :Tree ) return Offset_Type is
      begin
         case type_spec.ty is
            when dn_ACCESS =>
               INC_OFFSET ( addr_Size );
               ALIGN ( addr_Al );
            when dn_ARRAY =>
               INC_OFFSET ( addr_Size );
               ALIGN ( addr_Al );
               INC_OFFSET ( addr_Size );
               ALIGN ( addr_Al );
            when dn_ENUM_LITERAL_S | dn_INTEGER =>
               INC_OFFSET ( intg_Size );
               ALIGN ( intg_Al );
            when others =>
               raise Program_Error;
         end case;
         return offset_Act;
      end Allocate_Space_For_Type;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Params_in
       procedure Compile_Params_in ( seq_src_name :Seq_Type ) is
         src_name_s :Seq_Type	:= seq_src_name;
      begin
         if not IS_EMPTY ( src_name_s ) then
            declare
               src_name	: Tree;
            begin
               POP ( src_name_s, src_name );
               COMPILE_PARAMS_IN ( src_name_s );
               DI( cd_OFFSET, src_name, ALLOCATE_SPACE_FOR_TYPE ( D ( sm_obj_type, src_name ) ) );
               DI ( cd_LEVEL, src_name, Level );
            end;
         end if;
      end Compile_Params_in;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Params_in_out
       procedure Compile_Params_in_out ( seq_src_name :Seq_Type ) is
         src_name_s	: Seq_Type	:= seq_src_name;
      begin
         if not IS_EMPTY ( src_name_s ) then
            declare
               src_name	: Tree;
            begin
               POP ( src_name_s, src_name );
               COMPILE_PARAMS_IN_OUT ( src_name_s );
               DI ( cd_VAL_OFFSET, src_name, ALLOCATE_SPACE_FOR_TYPE ( D ( sm_obj_type, src_name ) ) );
               INC_OFFSET ( addr_Size );
               ALIGN ( addr_Al );
               DI( cd_ADDR_OFFSET, src_name, offset_Act );
               DI ( cd_LEVEL, src_name, level );
            end;
         end if;
      end Compile_Params_in_out;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Compile_Params
       procedure Compile_Params ( param_s :Seq_Type ) is
         param_seq	: Seq_Type	:= param_s;			--| Recopie car modifié
      begin
         null;
         if not IS_EMPTY ( param_seq ) then
            declare
               param	: Tree;
            begin
               POP ( param_seq, param );
               COMPILE_PARAMS ( param_seq );			--| Continuer sur le reste de la liste
               case param.ty is
                  when dn_IN =>
                     COMPILE_PARAMS_IN ( LIST ( D ( as_SOURCE_NAME_S, param ) ) );
                  when dn_IN_OUT | dn_OUT =>
                     COMPILE_PARAMS_IN_OUT ( LIST ( D ( as_SOURCE_NAME_S, param ) ) );
                  when others =>
                     raise Program_Error;
               end case;
            end;
         end if;
      end Compile_Params;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Copy_Out_Params
       procedure Copy_Out_Params ( param_s :Tree ) is
         param_seq		: Seq_Type;
         param		: Tree;
         --|----------------------------------------------------------------------------------------
         --|	procedure Copy_Out
          procedure Copy_Out ( type_spec :Tree; offset :Integer ) is
         begin
            case type_spec.ty is
               when dn_ACCESS =>
                  Gen_2_ii ( LOD, A, 0, offset );
                  Gen_0 ( STO, A );
               when dn_FLOAT =>
                  null;
               when dn_FIXED =>
                  null;
               when dn_RECORD =>
                  null;
               when dn_CONSTRAINED_ARRAY =>
                  null;
               when dn_CONSTRAINED_RECORD =>
                  null;
               when dn_CONSTRAINED_ACCESS =>
                  null;
               when dn_TASK_SPEC =>
                  null;
               when dn_PRIVATE =>
                  null;
               when dn_L_PRIVATE =>
                  null;
               when dn_INCOMPLETE =>
                  null;
               when dn_UNIVERSAL_REAL =>
                  null;
               when dn_UNIVERSAL_FIXED =>
                  null;
               when dn_UNIVERSAL_INTEGER =>
                  null;
               when dn_ARRAY =>
                  null;	--| il va bien falloir le faire
                  
               when dn_ENUMERATION =>
                  declare
                     type_source_name	: Tree	:= D ( xd_SOURCE_NAME, type_spec );
                     type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
                     name	: constant String	:= PRINT_NAME ( type_symrep );
                  begin
                     if name = "BOOLEAN" then
                        GEN_2_II ( LOD, B, 0, offset );
                        GEN_0 ( STO, B );
                     elsif name = "CHARACTER" then
                        GEN_2_II ( LOD, C, 0, offset );
                        GEN_0 ( STO, C );
                     else
                        GEN_2_II ( LOD, I, 0, offset );
                        GEN_0 ( STO, I );
                     end if;
                  end;
                  
               when dn_INTEGER =>
                  Gen_2_ii ( LOD, I, 0, offset );
                  Gen_0 ( STO, I );
            
               when others =>
                  raise Program_Error;
            end case;
         end Copy_Out;
      
      
      begin
         if param_s /= Tree_VOID then
            param_seq := LIST ( param_s );
         
            while not IS_EMPTY ( param_seq ) loop
               POP ( param_seq, param );			--| Extraire un élément de paramétrage
               if param.ty = dn_IN_OUT or param.ty = dn_OUT then		--| Il concerne un paramétrage entrée sortie ou sortie
                  declare
                     src_name_seq	: Seq_Type	:= LIST ( D ( as_SOURCE_NAME_S, param ) );		--| Passer sur la liste as_source_name_s des source_name du param
                  begin
                     while not IS_EMPTY ( src_name_seq ) loop		--| Tant qu'il y a des noms dans le paramétrage
                        declare
                           src_Name	: Tree;
                        begin
                           POP ( src_name_seq, src_Name );			--| Extraire un nom
                           Gen_2_ii ( LOD, A, 0, DI ( cd_ADDR_OFFSET, src_Name ) );	--| Générer un chargement d'adresse
                           COPY_OUT (	type_spec	=> D ( sm_OBJ_TYPE, src_Name ),	--| Faire la copie pour le type spécifié
                              	offset	=> DI ( cd_VAL_OFFSET, src_Name )	--| Au décalage donné
                              	);
                        end;
                     end loop;
                     param_seq.first := src_name_seq.next;			--| Repartir sur la suite de la param_s
                  end;
                  
               elsif param.ty = dn_IN then			--| Pas de copie en retour d'un paramétrage entrée
                  null;
                  
               else					--| Un noeud pas paramétrage
                  raise Program_Error;				--| Indiquer l'erreur
               end if;
            end loop;
         
         end if;
      end Copy_Out_Params;
   --|----------------------------------------------------------------------------------------------
   end CG_Param;
