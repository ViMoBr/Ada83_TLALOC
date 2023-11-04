   with Text_io, IDL, CG_1, CG_Expr, CG_Param;
   use  Text_io, IDL, CG_1;
    --|----------------------------------------------------------------------------------------------
    --|	procedure Code_Gen
    procedure Code_Gen is
    
   
      --|-------------------------------------------------------------------------------------------
      --|	package Structures
      --|-------------------------------------------------------------------------------------------
       package Structures is
       
          procedure Compile_compilation_unit ( compilation_unit :Tree );
      
          procedure Compile_Procedure	( subprogram_body :TREE; start_Label :Label_Type );
          procedure Compile_Function	( subprogram_body :TREE; start_Label :Label_Type );
          procedure Perform_Return	( enclosing_Block_Body :Tree );
          procedure Compile_Subp_Block	( block, enc1osing_Proc, params :Tree; param_Size :Offset_Type;
          		  fun_Result_Offset :Offset_Type:= 0; function_Result :Tree:= Tree_VOID );
      
      --|-------------------------------------------------------------------------------------------
      end Structures;
   
   
      --|-------------------------------------------------------------------------------------------
      --|	package Declarations
      --|-------------------------------------------------------------------------------------------
       package Declarations is
       
          procedure Compile_Declaration ( Declaration :Tree );
          
      --|-------------------------------------------------------------------------------------------
      end Declarations;
   
   
     --|--------------------------------------------------------------------------------------------
     --|	Object_Decls
     --|--------------------------------------------------------------------------------------------
       package Object_Decls is
      
          procedure Compile_Object_Decl	( object_decl :Tree );
          procedure Compile_Type_Decl	( type_decl :Tree );
      
      --|-------------------------------------------------------------------------------------------
      end Object_Decls;
       package body Object_Decls is separate;
   
   
      --|-------------------------------------------------------------------------------------------
      --|	package Statements
      --|-------------------------------------------------------------------------------------------
       package Statements is
       
          procedure Compile_Statements ( stm_s, enclosing_Body :Tree );
          
      --|-------------------------------------------------------------------------------------------
      end Statements;
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	package body Structures
      --|-------------------------------------------------------------------------------------------
       package body Structures is
      
      --|-------------------------------------------------------------------------------------------
      --|	procedure Perform_Return	
          procedure Perform_Return ( enclosing_Block_Body :Tree ) is
            LVBlbl		: Label_Type;
            enclosing_Level	: Integer	:= DI ( cd_LEVEL, enclosing_Block_Body );
         begin
            if enclosing_Level /= CG_1.level then
               LVBlbl := NEXT_LABEL;
               GEN_1_L ( LVB, LVBlbl);
               GEN_LBL_ASSIGNMENT ( LVBlbl, CG_1.Level - enclosing_Level );
            end if;
            GEN_1_L ( jmp, DI ( cd_RETURN_LABEL, enclosing_Block_Body ) );		--| Saut inconditionnel à l'étiquette de sortie du bloc englobant
         end Perform_Return;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Subp_Block
          procedure Compile_Subp_Block ( block, enc1osing_Proc, params :Tree; param_Size :Offset_Type;
          		 fun_Result_Offset :Offset_Type := 0; function_Result :Tree:= Tree_VOID ) is
            Old_Top_Act	: Offset_Type	:= Top_Act;
            Old_Top_Max	: Offset_Type	:= Top_Max;
         
         --|-------------------------------------------------------------------------------------------
         --|	procedure Compile_Exception_Handlers	
             procedure Compile_Exception_Handlers ( alternative_s, enclosing_Body :Tree ) is
               alternative_seq	: Seq_Type	:= LIST ( alternative_s );
               alternative	: Tree;
               Others_Flag	: Boolean	:= false;
            
            --|----------------------------------------------------------------------------------------
            --|	procedure Compile_Handler	
                procedure Compile_Handler ( alternative :Tree ) is
                  choice_seq	: Seq_Type	:= LIST ( D ( as_CHOICE_S, alternative ) );
                  handler_Begin_Lbl	: Label_Type	:= NEXT_LABEL;
                  skip_Lbl	: Label_Type;
                  choice		: Tree;
               begin
                  while not IS_EMPTY ( choice_seq ) loop
                     POP ( choice_seq, choice );
                     if choice.ty = dn_CHOICE_OTHERS then
                        Others_Flag := true;
                        choice_seq := (Tree_NIL, Tree_NIL);
                     else
                        skip_Lbl := NEXT_LABEL;
                        declare
                           used_name_Id	: Tree	:= D( as_EXP , choice );	--| Un used_name_id de catégorie EXP
                           exception_Id	: Tree	:= D ( sm_DEFN, used_name_id );	--| Un exception_id de catégorie DEF_NAME
                           label	: Tree	:= D ( cd_LABEL, exception_Id );
                           lbl	: Label_Type;
                        begin
                           if label.ty /= dn_NUM_VAL then			--| Aucun raise n'a été vu pour cette exception
                              lbl := NEXT_LABEL;
                              DI ( cd_LABEL, exception_Id, lbl );		--| Créer un numéro étiquette pour repérer l'exception
                              GEN_2_LS ( EXL, lbl, PRINT_NAME ( D ( lx_SYMREP, used_name_Id ) ) );	--| Déclarer cette association
                           end if;
                           GEN_2_LL ( EXC, DI ( cd_LABEL, exception_Id ), skip_Lbl );
                        end;
                        if not IS_EMPTY ( choice_seq ) then
                           GEN_1_L ( jmp, handler_Begin_Lbl );
                           WRITE_LABEL ( skip_Lbl );
                        end if;
                     end if;
                  end loop;
               
                  WRITE_LABEL ( handler_Begin_Lbl );
                  Statements.COMPILE_STATEMENTS ( D ( as_STM_S, alternative ), enclosing_Body );
                  PERFORM_RETURN ( enclosing_Body );
                  if not Others_Flag then
                     WRITE_LABEL ( Skip_Lbl );
                  end if;
               end Compile_Handler;
            
            begin
               if IS_EMPTY ( alternative_seq ) then
                  GEN_0 ( EEX );
               
               else
                  while not IS_EMPTY ( alternative_seq ) loop
                     POP ( alternative_seq, alternative );
                     Compile_Handler ( alternative );
                  end loop;
               
                  if not Others_Flag then
                     GEN_0 ( EEX );
                  end if;
               end if;
            
            end Compile_Exception_Handlers;
         
         
         begin
            CG_1.top_Max := 0;
            CG_1.top_Act := 0;
            DI ( cd_level, block, Integer( Level ) );
            DI ( cd_return_label, block, Integer( NEXT_LABEL ) );
            declare
               ENT_1_Lbl	: Label_Type	:= NEXT_LABEL;
               ENT_2_Lbl	: Label_Type	:= NEXT_LABEL;
            begin
               GEN_2_IL ( ENT, 1, ENT_1_Lbl );
               GEN_2_IL ( ENT, 2, ENT_2_Lbl );
               if function_Result /= Tree_VOID then
                  if function_Result.ty = dn_ARRAY then
                     GEN_LOAD_ADDR (	DI ( cd_COMP_UNIT, function_Result ),
                        DI ( cd_LEVEL, function_Result ),
                        DI ( cd_OFFSET, function_Result )
                        );
                     GEN_0 ( DPL, A );
                     GEN_2_II ( STR, A, 0, fun_Result_Offset - CG_1.addr_Size );
                     GEN_1_I ( IND, I, 0 );
                     GEN_1_I ( alloc, -1 );
                     GEN_2_II ( STR, A, 0, fun_Result_Offset );
                  end if;
               end if;
               declare
                  item_seq	: Seq_Type	:= LIST ( D ( as_ITEM_S, block ) );
                  item		: Tree;
               begin
                  while not IS_EMPTY (item_seq ) loop
                     POP ( item_seq, item );
                     Declarations.COMPILE_DECLARATION ( item );
                  end loop;
               end;
            
               declare
                  Exc_Lbl	: Label_Type	:= NEXT_LABEL;
               begin
                  GEN_1_L ( EXH, Exc_Lbl, "Exception handler label" );
                  Statements.COMPILE_STATEMENTS ( D ( as_STM_S, block ), enc1osing_Proc );
                  WRITE_LABEL ( Label_Type( DI ( cd_RETURN_LABEL, block ) ) );
                  CG_Param.COPY_OUT_PARAMS ( params );
                  GEN_1_I ( RET, param_Size );
                  WRITE_LABEL ( Exc_Lbl );
               end;
               COMPILE_EXCEPTION_HANDLERS ( D ( as_ALTERNATIVE_S, block ), enc1osing_Proc );
               GEN_Lbl_Assignment ( ENT_1_Lbl, CG_1.offset_Max );
               GEN_Lbl_Assignment ( ENT_2_Lbl, CG_1.offset_Max + CG_1.top_Max );
            end;
            CG_1.top_Max := Old_Top_Max;
            CG_1.top_Act := Old_Top_Act;
         end Compile_Subp_Block;
      
       
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_context_elem_s
          procedure Compile_context_elem_s ( context_elem_s :Tree ) is
         -- context_elem_s	=>
         -- 	=> as_list	:CONTEXT_ELEM
         -- 	=> lx_srcpos	:Source_Position
            context_elem_seq	: Seq_Type	:= LIST ( context_elem_s );
            context_elem	: Tree;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Context_package_id
             procedure Compile_Context_package_id ( package_id :Tree ) is
               compiled	: Boolean	:= DB ( cd_COMPILED, package_id );
            begin
               if not compiled then
                  GEN_2_IS ( RFP, CG_1.cur_Comp_Unit, PRINT_NAME ( D ( lx_symrep, package_id ) ) );
                  CG_1.generate_Code := false;			--| Pas de code généré (seulement faire les opérations d'étiquetage placement etc...)
                  DB ( cd_COMPILED, package_id, true );			--| Indiquer que l'on a compilé ce package withé pour ne pas faire cela deux fois
                  declare
                     package_Spec	: Tree	:= D ( sm_SPEC, package_id );	--| Un HEADER (ici un package_spec)
                     decl_s1	: Tree	:= D ( as_decl_s1, package_Spec );	--| La liste des déclarations visibles
                     decl_seq	: Seq_Type	:= LIST ( decl_s1 );	--| La séquence d'icelles
                     decl	: Tree;
                  begin
                     while not IS_EMPTY( decl_seq ) loop			--| Tant qu'il y a des déclarations
                        POP ( decl_seq, decl );			--| En extraire une
                        Declarations.COMPILE_DECLARATION ( decl );		--| La compiler
                     end loop;
                  end;
               end if;
            end Compile_Context_Package_Id;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_with
             procedure Compile_with ( with_context_elem :Tree ) is
            -- with	=>
            -- 	=> as_name_s	:name_s
            -- 	=> as_use_pragma_s	:use_pragma_s
            -- 	=> lx_srcpos	:Source_Position
               name_s	: Tree	:= D ( as_NAME_S, with_context_elem );	--| La suite des used_name_id withés
               name_seq	: Seq_Type	:= LIST ( name_s );		--| La séquence des mêmes
               used_name_id	: Tree;
               defn		: Tree;			--| Un DEF_NAME (ici package_id ou procedure_id ou function_id)
               proc_Lbl	: Label_Type;
            begin
               while not IS_EMPTY ( name_Seq ) loop			--| Tant qu'il y a des noms withés
                  POP ( name_Seq, used_name_id );			--| En extraire un
                  defn := D ( sm_DEFN, used_name_id );			--| L'Id associé
                     
                  if defn.ty = dn_PACKAGE_ID then			--| Un package_Id
                     COMPILE_CONTEXT_PACKAGE_ID ( defn );			--| Compiler sans générer de code les déclarations visibles
                     cur_Comp_Unit := cur_Comp_Unit + 1;			--| N° d'unité suivant
                        
                  elsif defn.ty = dn_PROCEDURE_ID then			--| Un procedure_Id
                     if not DB ( cd_COMPILED, defn ) then
                        declare
                           symrep	: Tree	:= D( lx_SYMREP, defn );
                        begin
                           CG_1.generate_Code := true;			--| Il faut générer les références
                           GEN_2_IS ( RFP, 0, PRINT_NAME ( symrep ) );		--| Référence à procédure de librairie
                           proc_Lbl := NEXT_LABEL;			--| Etiquette d'entrée de la procédure référencée 
                           DI ( cd_LABEL, defn, proc_Lbl );			--| Stocker cette étiquette
                           DI ( cd_LEVEL, defn, 1 );			--| Stocker le niveau de cette procédure référencée
                           DI ( cd_PARAM_SIZE, defn, 0 );			--| Initialiser la taille du paramétrage à 0 (utile ? )
                           DB ( cd_COMPILED, defn, true );			--| Indiquer qu'on l'a déjà traitée
                           GEN_1_L ( RFL, proc_Lbl );			--| déclarer l'étiquette de référence
                        end;
                     end if;
                  end if;
               end loop;
            end Compile_with;
         
         begin
            CG_1.cur_Comp_Unit := 2;
            while not IS_EMPTY ( context_elem_seq ) loop			--| tant que la liste n'est pas vidée
               POP ( context_elem_seq, context_elem );			--| Extraire une unité de compilation
            
               Compile_Context_Elem:
               begin
                  if context_Elem.ty = dn_WITH then
                     COMPILE_WITH ( context_Elem );
                  elsif context_Elem.ty = dn_CONTEXT_PRAGMA then
                     null;
                  end if;
               end Compile_Context_elem;
            
            end loop;
            CG_1.cur_Comp_Unit := 0;
            CG_1.generate_Code := true;				--| Se remettre en génération de code
         
         end Compile_context_elem_s;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Procedure
          procedure Compile_Procedure ( subprogram_body :Tree; start_Label :Label_Type ) is
         -- subprogram_body	=>
         -- 	=> as_source_name	:SOURCE_NAME . . . . . . . . . . . . . . . . . . . . . . . 	le procedure_id
         -- 	=> as_body	:BODY . . . . . . . . . . . . . . . . . . . . . . . . . . .	le block_body
         -- 	=> as_header	:HEADER
         -- 	=> lx_srcpos	:Source_Position
            procedure_id	: Tree	:= D ( as_SOURCE_NAME, subprogram_body );
            block_body 	: Tree	:= D ( as_BODY, subprogram_body );
         -- procedure_id	=>
         -- 	=> lx_srcpos	:Source_Position
         -- 	=> lx_symrep	:symbol_rep
         -- 	=> sm_first	:DEF_NAME
         -- 	=> sm_spec	:HEADER . . . . . . . . . . . . . . . . . . . . . . . . . .	le procedure_spec
         -- 	=> sm_unit_desc	:UNIT_DESC
         -- 	=> sm_address	:EXP
         -- 	=> sm_is_inline	:BOOLEAN
         -- 	=> sm_interface	:PREDEF_NAME
         -- 	=> xd_region	:SOURCE_NAME
         -- 	=> xd_stub	:stub
         -- 	=> xd_body	:SUBUNIT_BODY
         -- 	=> cd_compiled	:BOOLEAN
         -- 	=> cd_level	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	le niveau statique
         -- 	=> cd_label	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	l'étiquette du point d'entrée
         -- 	=> cd_param_size	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	la taille du paramétrage passé
            procedure_spec	: Tree	:= D ( sm_SPEC, procedure_id );
         -- procedure_spec	=>
         -- 	=> as_param_s	:param_s . . . . . . . . . . . . . . . . . . . . . . . . .	la param_s
         -- 	=> lx_srcpos	:Source_Position
            param_s		: Tree	:= D ( as_PARAM_S, procedure_spec );
            old_Offset_Act	: Offset_Type	:= CG_1.offset_Act;		--| Mémoriser le décalage de pile avant appel de procédure
            old_Offset_Max	: Offset_Type	:= CG_1.offset_Max;
         begin
            CG_1.offset_Act := CG_1.first_Param_Offset;			--| Lieu du premier paramètre comme décalage de pile actuel
            CG_1.offset_Max := CG_1.offset_Act;			--| Et décalage maximal actuel
            INC_LEVEL;				--| Niveau statique suivant
            DI ( cd_LABEL, procedure_id, Integer( start_Label ) );		--| Stocker le n° d'étiquette d'entrée
            DI ( cd_LEVEL, procedure_id, Integer( CG_1.level ) );		--| Stocker le niveau statique actuel
            WRITE_LABEL ( start_Label );			--| L'étiquette du point d'entrée
            declare
            begin
            --  subprogram_body ::=
            --	subprogram_specification is
            --	...
               CG_Param.COMPILE_PARAMS ( LIST ( param_s ) );
               declare
                  param_size : Natural	:= offset_Act - first_Param_Offset + CG_1.relative_Result_Offset;
               begin
                  DI ( cd_PARAM_SIZE, procedure_id, param_size );
                  offset_Act := CG_1.first_Local_Var_Offset;
                  offset_Max := offset_Act;
               --  subprogram_body ::=
               --	...
               --	   [declarative_part]
               --	begin sequence_of_statements
               --	   [exception exception_handler {exception_handler}]
               --	end [designator];
                  COMPILE_SUBP_BLOCK ( block_body, block_body, param_s, param_size );
               end;
            end;
            DEC_LEVEL;
            offset_Max := old_Offset_Max;
            offset_Act := old_Offset_Act;
         end Compile_Procedure;
      --|----------------------------------------------------------------------------------------------
      --|	procedure Compile_Function
          procedure Compile_Function ( subprogram_body :Tree; start_Label: Label_Type ) is
         -- subprogram_body	=>
         -- 	=> as_source_name	:SOURCE_NAME . . . . . . . . . . . . . . . . . . . . . . . 	le function_id
         -- 	=> as_body	:BODY . . . . . . . . . . . . . . . . . . . . . . . . . . .	le block_body
         -- 	=> as_header	:HEADER
         -- 	=> lx_srcpos	:Source_Position
            function_id	: Tree	:= D ( as_SOURCE_NAME, subprogram_body );
            block_body		: Tree	:= D ( as_BODY, subprogram_body );
         -- function_id	=>
         -- 	=> lx_srcpos	:Source_Position
         -- 	=> lx_symrep	:symbol_rep
         -- 	=> sm_first	:DEF_NAME
         -- 	=> sm_spec	:HEADER . . . . . . . . . . . . . . . . . . . . . . . . . .	le function_spec
         -- 	=> sm_unit_desc	:UNIT_DESC
         -- 	=> sm_address	:EXP
         -- 	=> sm_is_inline	:BOOLEAN
         -- 	=> sm_interface	:PREDEF_NAME
         -- 	=> xd_region	:SOURCE_NAME
         -- 	=> xd_stub	:stub
         -- 	=> xd_body	:SUBUNIT_BODY
         -- 	=> cd_compiled	:BOOLEAN
         -- 	=> cd_level	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	le niveau statique
         -- 	=> cd_label	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	l'étiquette du point d'entrée
         -- 	=> cd_param_size	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	la taille du paramétrage passé
         -- 	=> cd_result_size	:Integer . . . . . . . . . . . . . . . . . . . . . . . . .	la taille du paramètre résultat
            function_spec	: Tree	:= D ( sm_SPEC, function_id );
         -- function_spec	=>
         -- 	=> as_param_s	:param_s
         -- 	=> as_name	:NAME . . . . . . . . . . . . . . . . . . . . . . . . . . .	le used_object_id de la subtype_indication résultat
         -- 	=> lx_srcpos	:Source_Position
            param_s		: Tree	:= D ( as_PARAM_S, function_spec );
            used_object_id	: Tree	:= D ( as_NAME, function_spec );
            result_Type_Spec	: Tree	:= D ( sm_EXP_TYPE, used_object_id );
            old_Offset_Act	: Offset_Type	:= CG_1.offset_Act;
            old_Offset_Max	: Offset_Type	:= CG_1.offset_Max;
            fun_Result_Offset	: Offset_Type;
         begin
            offset_Act := CG_1.first_Param_Offset;
            offset_Max := offset_Act;
            INC_LEVEL;
            DI ( cd_LABEL, function_id, Integer( start_Label ) );
            DI ( cd_LEVEL, function_id, Integer( CG_1.level ) );
            WRITE_LABEL ( start_Label );
            CG_Param.COMPILE_PARAMS ( LIST ( param_s ) );
            INC_OFFSET ( CG_1.relative_Result_Offset );
            declare
               param_size 	: Natural	:= offset_Act - first_Param_Offset;
               result_Size	: Natural	:= CG_Expr.TYPE_SIZE ( result_Type_Spec );
            begin
               DI ( cd_RESULT_SIZE, function_id, result_Size );
               INC_OFFSET ( result_Size );
               ALIGN ( stack_Al );
               DI ( cd_result_offset, block_body, offset_Act );
               fun_Result_Offset := offset_Act;
               DI ( cd_PARAM_SIZE, function_id, param_size );
               offset_Act := first_Local_Var_Offset;
               offset_Max := offset_Act;
            --  subprogram_body ::=
            --	...
            --	   [declarative_part]
            --	begin sequence_of_statements
            --	   [exception exception_handler {exception_handler}]
            --	end [designator];
               COMPILE_SUBP_BLOCK ( block_body, block_body, param_s, param_size, fun_Result_Offset, result_Type_Spec );
            end;
            DEC_LEVEL;
            offset_Max := old_Offset_Max;
            offset_Act := old_Offset_Act;
         end Compile_Function;
      --|----------------------------------------------------------------------------------------------
      --|	procedure Compile_Compilation_Unit_Package_Decl
          procedure Compile_Compilation_Unit_Package_Decl ( header :Tree ) is		--| Un HEADER (ici un package_spec pour la partie SPC)
            ENT_1_Lbl, ENT_2_Lbl, Exc_Lbl        : Label_Type;
         begin
            WRITE_LABEL ( 1 );
            ENT_1_Lbl := NEXT_LABEL;
            ENT_2_Lbl := NEXT_LABEL;
            GEN_2_IL ( ENT, 1, ENT_1_Lbl );
            GEN_2_IL ( ENT, 2, ENT_2_Lbl );
            CG_1.offset_Act := 0;
            CG_1.offset_Max := 0;
         
            declare
               decl_seq	: Seq_Type	:= LIST ( D ( as_DECL_S1, header ) );
               decl		: Tree;
            begin
               while not IS_EMPTY ( decl_seq ) loop
                  POP ( decl_seq, decl );
                  Declarations.COMPILE_DECLARATION ( decl );
               end loop;
            end;
         
            Exc_Lbl := NEXT_LABEL;
            GEN_1_L ( EXH, Exc_Lbl );
            GEN_1_I ( ret, relative_Result_Offset );
            WRITE_LABEL ( Exc_Lbl );
            GEN_0 ( EEX );
            GEN_LBL_ASSIGNMENT ( ENT_1_Lbl, offset_Max );
            GEN_LBL_ASSIGNMENT ( ENT_2_Lbl, offset_Max + top_Max );
         end Compile_Compilation_Unit_Package_Decl;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Compile_compilation_unit
          procedure Compile_compilation_unit ( compilation_unit :Tree ) is
         -- compilation_unit	=>
         -- 	=> as_context_elem_s:context_elem_s
         -- 	=> as_all_decl	:ALL_DECL
         -- 	=> as_pragma_s	:pragma_s
         -- 	=> lx_srcpos	:Source_Position
         -- 	=> xd_timestamp	:Integer
         -- 	=> xd_with_list	:trans_with
         -- 	=> xd_nbr_pages	:Integer
         -- 	=> xd_parent	:compilation_unit
         -- 	=> xd_lib_name	:symbol_rep
            context_elem_s	: Tree	:= D ( as_CONTEXT_ELEM_S, compilation_unit );
            all_decl		: Tree	:= D ( as_ALL_DECL, compilation_unit );
         --  compilation_unit ::= context_clause	  subprogram_body
         --			| package_declaration
         --			| package_body
         --			| subunit
         --  	  		| subprogram_declaration	pas de codage
         --			| generic_declaration	pas de codage
         --			| generic_instantiation	pas de codage
         -- subprogram_body	=>
         -- 	=> as_source_name	:SOURCE_NAME . . . . . . . . . . . . . . . . . . . . . . . 	le procedure_id ou le function_id
         -- 	=> as_body	:BODY
         -- 	=> as_header	:HEADER
         -- 	=> lx_srcpos	:Source_Position
         -- package_decl	=>
         -- 	=> as_source_name	:SOURCE_NAME
         -- 	=> as_header	:HEADER
         -- 	=> as_unit_kind	:UNIT_KIND
         -- 	=> lx_srcpos	:Source_Position
         -- package_body	=>
         -- 	=> as_source_name	:SOURCE_NAME
         -- 	=> as_body	:BODY
         -- 	=> lx_srcpos	:Source_Position
            source_name	: Tree	:= D ( as_SOURCE_NAME, all_decl );	--| L'id
            symrep		: Tree	:= D ( lx_SYMREP, source_name );
         
         begin
         
            Compile_all_decl:
            declare
            
                procedure Compile_subunit ( subunit :Tree ) is
               begin
                  null;
               end;
            
            begin
               CG_1.top_Act := 0;
               CG_1.top_Max := 0;
               CG_1.offset_Act := 0;
               CG_1.offset_Max := 0;
               CG_1.Level := 0;
               generate_Code := true;
               COMPILE_CONTEXT_ELEM_S ( context_elem_s );			-- Context_clause
               case all_decl.ty is
               
                  when dn_SUBPROGRAM_BODY =>
                     GEN_1_S ( PRO, PRINT_NAME ( symrep ) );
                     if source_name.ty = dn_PROCEDURE_ID then
                        COMPILE_PROCEDURE ( all_decl, 1 );
                     
                     elsif source_name.ty = dn_FUNCTION_ID then
                        COMPILE_FUNCTION ( all_decl, 1 );
                     
                     else
                        raise Program_Error;
                     end if;
               
                  when dn_PACKAGE_DECL =>
                     GEN_1_S ( PKG, PRINT_NAME ( symrep ) );
                     declare
                        package_Spec	: Tree	:= D ( as_HEADER, all_decl );
                     begin
                        COMPILE_COMPILATION_UNIT_PACKAGE_DECL ( package_Spec );
                     end;
               
                  when dn_PACKAGE_BODY =>
                     GEN_1_S ( PKB, PRINT_NAME ( symrep ) );
                     declare
                        body_Block	: Tree	:= D ( as_BODY, all_decl );
                        package_spec	: Tree	:= D ( sm_SPEC, source_name );
                     begin
                     
                        Compile_Package_Spec:
                        declare
                           decl_seq	: Seq_Type	:= LIST ( D ( as_DECL_S1, package_spec ) );
                           decl	: Tree;
                        begin
                           generate_Code := false;
                           while not IS_EMPTY ( decl_seq ) loop
                              POP ( decl_seq, decl );
                              Declarations.COMPILE_DECLARATION ( decl );
                           end loop;
                           generate_Code := true;
                        end Compile_Package_Spec;
                     
                        WRITE_LABEL ( 1 );
                        COMPILE_SUBP_BLOCK ( body_Block, body_Block, Tree_VOID, relative_Result_Offset );
                     end;
               
                  when dn_SUBUNIT =>
                     COMPILE_SUBUNIT ( all_decl );
               
                  when others =>
                     null;
               end case;
            end Compile_all_decl;
         
            GEN_0 ( QUIT );
         end Compile_compilation_unit;
      
      --|-------------------------------------------------------------------------------------------
      end Structures;
      
      
     
   
      
      --|-------------------------------------------------------------------------------------------
      --|	package body Declarations
      --|-------------------------------------------------------------------------------------------
       package body Declarations is
       
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Decl_exception
          procedure Compile_Decl_exception ( exception_decl :Tree ) is
            exception_id_seq	: SEQ_TYPE	:= LIST ( D ( as_SOURCE_NAME_S, exception_decl ) );
            old_Generate_Code	: Boolean	:= generate_Code;
            exception_id	: Tree;
         begin
            generate_Code   := true;
            while not IS_EMPTY( exception_id_seq ) loop
               POP ( exception_id_seq, exception_id );
               declare
                  lbl		: Label_Type	:= NEXT_LABEL;
               begin
                  DI ( cd_LABEL, exception_id, lbl );
                  GEN_2_LS ( EXL, lbl, PRINT_NAME ( D ( lx_SYMREP, exception_id ) ) );
               end;
            end loop;
            generate_Code := old_Generate_Code;
         end Compile_Decl_exception;
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Decl_subprog_entry_decl	
          procedure Compile_Decl_subprog_entry_decl ( subprog_entry_decl :Tree ) is
            old_Offset_Act	: offset_Type	:= CG_1.offset_Act;
            old_Offset_Max	: offset_Type	:= CG_1.offset_Max;
            source_name	: Tree	:= D ( as_SOURCE_NAME, subprog_entry_decl );
            header		: Tree	:= D ( as_HEADER, subprog_entry_decl );
         begin
            offset_Act := first_Param_Offset;
            offset_Max := offset_Act;
            INC_LEVEL;
         
            if source_name.ty in class_SUBPROG_NAME then
               declare
                  lbl	: Label_Type	:= NEXT_LABEL;
               begin
                  DI ( cd_LABEL, source_name, lbl );
                  DI ( cd_LEVEL, source_name, CG_1.level );
                  DB ( cd_COMPILED, source_name, true );
                  if not generate_Code then
                     generate_Code := true;
                     GEN_1_L ( RFL, lbl );
                     generate_Code := false;
                  end if;
                  CG_Param.COMPILE_PARAMS ( LIST ( D ( as_PARAM_S, header ) ) );
                  DI ( cd_PARAM_SIZE, source_name, offset_Act - first_Param_Offset );
               end;
            
               if source_name.ty = dn_FUNCTION_ID or source_name.ty = dn_OPERATOR_ID then
                  declare
                     used_Object_Id	: Tree	:= D ( as_NAME, header );
                     result_Type_Spec	: Tree	:= D ( sm_EXP_TYPE, used_Object_Id );
                  begin
                     DI ( cd_RESULT_SIZE, source_name, CG_Expr.TYPE_SIZE ( result_Type_Spec ) );
                  end;
               end if;
            else
               PUT_LINE ( "!!! Code_Gen.Compile_Decl_subprogram_decl : type incorrect = "
                  & Node_Name'IMAGE ( source_name.ty ) );
               raise Program_Error;
            end if;
            DEC_LEVEL;
            offset_Act := old_Offset_Act;
            offset_Max := old_Offset_Max;
         end Compile_Decl_subprog_entry_decl;
      
      -- procedure_id	=>
      -- 	=> lx_srcpos	:Source_Position
      -- 	=> lx_symrep	:symbol_rep
      -- 	=> sm_first	:DEF_NAME
      -- 	=> sm_spec	:HEADER
      -- 	=> sm_unit_desc	:UNIT_DESC
      -- 	=> sm_address	:EXP
      -- 	=> sm_is_inline	:BOOLEAN
      -- 	=> sm_interface	:PREDEF_NAME
      -- 	=> xd_region	:SOURCE_NAME
      -- 	=> xd_stub	:stub
      -- 	=> xd_body	:SUBUNIT_BODY
      -- 	=> cd_compiled	:BOOLEAN
      -- 	=> cd_level	:Integer
      -- 	=> cd_label	:Integer
      -- 	=> cd_param_size	:Integer
      --|-------------------------------------------------------------------------------------------
      --|	procedure Compile_Decl_subprogram_body	
          procedure Compile_Decl_subprogram_body ( subprogram_body :Tree ) is
         -- subprogram_body	=>
         -- 	=> as_source_name	:SOURCE_NAMEE . . . . . . . . . . . . . . . . . . . . . . .	le procedure_Id ou le function_id
         -- 	=> as_body	:BODY
         -- 	=> as_header	:HEADER
         -- 	=> lx_srcpos	:Source_Position
            skip_Lbl	: Label_Type	:= NEXT_LABEL;
            source_name	: Tree	:= D ( as_SOURCE_NAME, subprogram_body ); 
            header		: Tree	:= D ( as_HEADER, subprogram_body );
            defn		: Tree;
         begin
            GEN_1_L ( jmp, skip_Lbl );
            if header.ty = dn_FUNCTION_SPEC then
               defn := D ( sm_FIRST, source_name );
               if DB ( cd_COMPILED, defn ) then
                  Structures.COMPILE_FUNCTION ( subprogram_body, DI ( cd_LABEL, defn ) );
               else
                  Structures.COMPILE_FUNCTION ( subprogram_body, NEXT_LABEL );
               end if;
               
            elsif header.ty = dn_PROCEDURE_SPEC then
               defn := D ( sm_FIRST, source_name );
               if DB ( cd_COMPILED, defn ) then
                  Structures.COMPILE_PROCEDURE ( subprogram_body, DI ( cd_LABEL, defn ) );
               else
                  Structures.COMPILE_PROCEDURE ( subprogram_body, NEXT_LABEL );
               end if;
               
            else
               PUT_LINE ( "!!! Compile_Decl_subprogram_body : header.ty = " & Node_Name'IMAGE ( header.ty ) );
               raise Program_Error;
            end if;
            WRITE_LABEL ( skip_Lbl );
         end Compile_Decl_subprogram_body;
      --||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
      --|	procedure Compile_Declaration
          procedure Compile_Declaration ( declaration :Tree ) is
         begin
            case declaration.ty is
               when dn_CONSTANT_DECL | dn_VARIABLE_DECL =>
                  Object_Decls.COMPILE_OBJECT_DECL ( declaration );
                  
               when dn_EXCEPTION_DECL=>
                  COMPILE_DECL_EXCEPTION ( declaration );
                  
               when dn_NUMBER_DECL=>
                  null;
                  
               when dn_SUBPROG_ENTRY_DECL=>
                  COMPILE_DECL_SUBPROG_ENTRY_DECL ( declaration );
                  
               when dn_SUBPROGRAM_BODY =>
                  COMPILE_DECL_SUBPROGRAM_BODY ( declaration );
                  
               when dn_TYPE_DECL=>
                  Object_Decls.COMPILE_TYPE_DECL ( declaration );
                  
               when dn_PACKAGE_DECL =>
                  null;
                  
               when dn_PACKAGE_BODY =>
                  null;
                  
               when dn_RENAMES_OBJ_DECL =>
                  null;
                  
               when dn_RENAMES_EXC_DECL =>
                  null;
                  
               when dn_TASK_DECL =>
                  null;
                  
               when dn_TASK_BODY =>
                  null;
               when dn_LENGTH_ENUM_REP =>
                  null;
                  
               when others =>
                  PUT_LINE ( "!!! Compile_Declaration : Type de declaration non traite" );
                  raise Program_Error;
            end case;
         end Compile_Declaration;
         
      --|-------------------------------------------------------------------------------------------
      end Declarations;
   
   
   
   
   
   
   
   
   
   
   
      --|-------------------------------------------------------------------------------------------
      --|	package Statements
       package body Statements is
      
      
         --|----------------------------------------------------------------------------------------
         --|	function Number_Of_Dimensions
          function Number_Of_Dimensions ( exp :Tree ) return Natural is
         begin
            if exp.ty in class_CONSTRAINED then
               return NUMBER_OF_DIMENSIONS ( D ( sm_BASE_TYPE, exp ) );
            
            elsif exp.ty = dn_FUNCTION_CALL or exp.ty = dn_USED_OBJECT_ID then
               return NUMBER_OF_DIMENSIONS ( D ( sm_EXP_TYPE, exp ) );
            
            elsif exp.ty = dn_ARRAY then
               return DI ( cd_DIMENSIONS, exp );
            
            else
               PUT_LINE ( "!!! Number_of_dimensions type expression illicite" );
               raise Program_Error;
            end if;
         end Number_Of_Dimensions;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Assign
          procedure Compile_Stm_Assign ( assign :Tree ) is
            name	: Tree	:= D ( as_NAME, assign );      
            exp	: Tree	:= D ( as_EXP, assign );
         
             procedure Store_Val ( type_spec :Tree ) is
            begin
               case type_spec.ty is
                  when dn_ACCESS =>
                     GEN_0 ( STO, A );
                  
                  when dn_ENUMERATION =>
                     declare
                        type_source_name: Tree	:= D ( xd_SOURCE_NAME, type_spec );
                        type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
                        name	: constant String	:= PRINT_NAME ( type_symrep );
                     begin
                        if name = "BOOLEAN" then
                           GEN_0 ( STO, B );
                        elsif name = "CHARACTER" then
                           GEN_0 ( STO, C );
                        else
                           GEN_0 ( STO, I );
                        end if;
                     end;
                  
                  when dn_INTEGER =>
                     GEN_0 ( STO, I );
               
                  when dn_UNIVERSAL_INTEGER =>
                     declare
                        comp_unit	: Comp_Unit_Nbr	:= DI ( cd_COMP_UNIT, type_spec );
                        level	: Level_Type	:= DI ( cd_LEVEL, type_spec );
                        ofs	: Integer	:= DI ( cd_OFFSET, type_spec );
                     begin
                        GEN_LOAD_ADDR ( comp_unit, level, ofs );
                        GEN_CSP ( CVB );
                        GEN_0 ( STO, I );
                     end;
               
                  when others =>
                     PUT_LINE ( "!!! store_val type_spec.ty illicite " & Node_Name'IMAGE ( type_spec.ty ) );
                     raise Program_Error;
               end case;
            end Store_Val;
         
         begin
            case name.ty is
               when dn_ALL =>
               
                  Compile_Assign_All:
                  declare
                     name_all	: Tree	renames name;
                  begin
                     CG_Expr.LOAD_ADDRESS ( D ( as_NAME, name_all ) );
                     CG_Expr.COMPILE_EXPRESSION ( exp );
                     STORE_VAL ( D ( sm_EXP_TYPE, name_all ) );
                  end Compile_Assign_all;
            
            
               when dn_INDEXED =>
               
                  Compile_Assign_indexed:
                  declare
                     name_indexed	: Tree	renames name;
                  begin
                     CG_Expr.LOAD_ADDRESS_INDEXED ( name_indexed );
                     CG_Expr.COMPILE_EXPRESSION ( exp );
                     STORE_VAL ( D ( sm_EXP_TYPE, name_indexed ) );
                  end Compile_Assign_indexed;
            
            
               when dn_USED_OBJECT_ID =>
               
                  Compile_Assign_used_object_id:
                  declare
                     name_used_object_id	: Tree	renames name;
                     type_spec	: Tree	:= D ( sm_EXP_TYPE, name_used_object_id );
                     CompUnitNr	: Comp_Unit_Nbr;
                     Lvl	: Level_Type;
                     Offs	: Offset_Type;
                  begin
                     case type_spec.ty is
                        when dn_ACCESS =>
                           CG_Expr.COMPILE_EXPRESSION ( exp );
                           CG_Expr.GET_CLO ( D ( sm_DEFN, name_used_object_id ), CompUnitNr, Lvl, Offs );
                           GEN_STORE ( A, CompUnitNr, Lvl, Offs);
                     
                        when dn_ARRAY =>
                           CG_Expr.LOAD_OBJECT_ADDRESS( D ( sm_DEFN, name_used_object_id ) );
                           if exp.ty = dn_USED_OBJECT_ID then
                              CG_Expr.LOAD_OBJECT_ADDRESS ( exp );
                              GEN_1_I ( const, I, NUMBER_OF_DIMENSIONS ( type_Spec ) );
                              Gen_CSP ( CYA );
                           
                           else
                              CG_Expr.COMPILE_EXPRESSION ( exp );
                              GEN_1_I ( const, I, NUMBER_OF_DIMENSIONS ( type_Spec ) );
                              GEN_CSP ( PUA );
                           end if;
                     
                        when dn_ENUMERATION =>
                           CG_Expr.COMPILE_EXPRESSION ( exp );
                           CG_Expr.GET_CLO ( D ( sm_DEFN, name_used_object_id ), CompUnitNr, Lvl, Offs);
                           declare
                              type_source_name	: Tree	:= D ( xd_SOURCE_NAME, type_spec );
                              type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
                              name		: constant String	:= PRINT_NAME ( type_symrep );
                           begin
                              if name = "BOOLEAN" then
                                 GEN_STORE ( B, CompUnitNr, Lvl, Offs );
                              elsif name = "CHARACTER" then
                                 GEN_STORE ( C, CompUnitNr, Lvl, Offs );
                              else
                                 GEN_STORE ( I, CompUnitNr, Lvl, Offs );
                              end if;
                           end;
                        
                        when dn_INTEGER | dn_UNIVERSAL_INTEGER =>
                           CG_Expr.COMPILE_EXPRESSION ( exp );
                           if type_Spec.ty = dn_UNIVERSAL_INTEGER then
                              CG_Expr.GET_CLO ( type_Spec, CompUnitNr, Lvl, Offs);
                              CG_1.GEN_LOAD_ADDR ( CompUnitNr, Lvl, Offs );
                              GEN_CSP ( CVB );
                           end if;
                           CG_Expr.GET_CLO ( D ( sm_DEFN, name_used_object_id ), CompUnitNr, Lvl, Offs);
                           GEN_STORE ( I, CompUnitNr, Lvl, Offs);
                     
                        when others =>
                           PUT_LINE ( "!!! compile_assign_used_object_id type_spec.ty illicite " & Node_Name'IMAGE ( type_spec.ty ) );
                           raise Program_Error;
                     end case;
                  end Compile_Assign_used_object_id;
            
               
               when others =>
                  PUT_LINE ( "!!! Compile_stm_assign name.ty illicite : " & Node_Name'IMAGE ( name.ty ) );
                  raise Program_Error;
            end case;
         end Compile_Stm_Assign;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_block	
          procedure Compile_Stm_block ( stm, enclosing_Body :Tree ) is
            after_Block_Lbl	: Label_Type	:= NEXT_LABEL;
            proc_Lbl	: Label_Type	:= NEXT_LABEL;
         begin
            GEN_2_II ( MST, 0, 0 );
            GEN_2_IL ( call, CG_1.relative_Result_Offset, proc_Lbl );
            GEN_1_L ( jmp, after_Block_Lbl );
            WRITE_LABEL ( proc_Lbl);
            declare
               old_Offset_Act	: Offset_Type	:= CG_1.offset_Act;
               old_Offset_Max	: Offset_Type	:= CG_1.offset_Max;
            begin
               CG_1.offset_Act := first_Local_Var_Offset;
               CG_1.offset_Max := first_Local_Var_Offset;
               INC_LEVEL;
               Structures.COMPILE_SUBP_BLOCK ( stm, enclosing_Body, Tree_NIL, relative_Result_Offset );
               DEC_LEVEL;
               CG_1.offset_Act := old_Offset_Act;
               CG_1.offset_Max := old_Offset_Max;
            end;
            WRITE_LABEL ( after_Block_Lbl );
         end Compile_Stm_block;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_exit	
          procedure Compile_Stm_exit ( stm :Tree ) is
            LVB_lbl, Skip_Lbl  : Label_Type;
            exp		: Tree	:= D ( as_EXP, stm );
            loop_stm	: Tree	:= D ( sm_STM, stm );
            after_loop_Lbl	: Label_Type	:= DI ( cd_AFTER_LOOP, loop_stm );
         begin
            if exp = Tree_VOID then				--| exit sans when
               declare
                  loop_Level	: Level_Type	:= DI ( cd_LEVEL, loop_stm );
               begin
                  if loop_Level /= CG_1.level then
                     LVB_lbl := NEXT_LABEL;
                     GEN_1_L ( LVB, LVB_lbl );
                     GEN_LBL_ASSIGNMENT ( LVB_lbl, CG_1.level - loop_Level );
                  end if;
                  GEN_1_L ( jmp, after_loop_Lbl );
               end;
            else
               CG_Expr.COMPILE_EXPRESSION ( exp );
               declare
                  loop_Level	: Level_Type	:= DI ( cd_LEVEL, loop_stm );
               begin
                  if loop_Level /= CG_1.level then
                     Skip_Lbl := NEXT_LABEL;
                     GEN_1_L ( jmpf, Skip_Lbl );
                     LVB_lbl  := NEXT_LABEL;
                     GEN_1_L ( LVB, LVB_lbl );
                     GEN_LBL_ASSIGNMENT ( LVB_lbl, CG_1.level - loop_Level );
                     GEN_1_L ( jmp, after_loop_Lbl );
                     WRITE_LABEL ( Skip_Lbl );
                  else
                     GEN_1_L ( jmpt, after_loop_Lbl );
                  end if;
               end;
            end if;
         end Compile_Stm_exit;
      
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_If	
          procedure Compile_Stm_If ( stm, enclosing_Body :Tree ) is
            After_If_Lbl	: Label_Type	:= NEXT_LABEL;
            cond_Clause_Seq	: Seq_Type	:= LIST ( D ( as_TEST_CLAUSE_ELEM_S, stm ) );
            cond_Clause	: Tree;
         begin
            while not IS_EMPTY ( cond_Clause_seq ) loop
               POP ( cond_Clause_Seq, cond_Clause );
               
               Compile_Cond_Clause :
               declare
                  exp	: Tree	:= D ( as_EXP, cond_clause );
                  stm_s	: Tree	:= D ( as_STM_S, cond_clause );
                  next_Clause_Lbl	: Label_Type;
               begin
                  if exp /= Tree_VOID then
                     CG_Expr.COMPILE_EXPRESSION ( exp );
                     next_Clause_Lbl := NEXT_LABEL;
                     GEN_1_L ( jmpf, next_Clause_Lbl );
                  end if;
               
                  COMPILE_STATEMENTS ( stm_s, enclosing_Body );
               
                  if exp /= Tree_VOID then
                     GEN_1_L ( jmp, After_If_Lbl );
                     WRITE_LABEL ( next_Clause_Lbl );
                  end if;
               end Compile_Cond_Clause;
            
            end loop;
            WRITE_LABEL ( After_If_Lbl );
         end Compile_Stm_If;
       
      
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Procedure_Call	
          procedure Compile_Stm_Procedure_Call ( stm :Tree ) is
            exp_s		: Tree	:= D ( sm_NORMALIZED_PARAM_S, stm );
            used_Name_Id	: Tree	:= D ( as_NAME, stm );
            uNI_proc_Id	: Tree	:= D ( sm_DEFN, used_Name_Id );
            proc_Id		: Tree	:= D ( sm_FIRST, uNI_proc_Id );
            proc_Spec	: Tree	:= D ( sm_SPEC, proc_Id );
            --|-------------------------------------------------------------------------------------
            --|	procedure Load_Actual_Params	
             procedure Load_Actual_Params ( param_s, exp_s :Tree ) is
               formal_param_Seq	: Seq_Type	:= LIST ( param_s );
               formal_param	: Tree;
               actual_param_Seq	: Seq_Type	:= LIST ( exp_s );
               actual_param	: Tree;
               formal_id_seq	: Seq_Type;
               formal_id	: Tree;
               --|----------------------------------------------------------------------------------
               --|	procedure Load_Object	
                procedure Load_Object ( t :Tree ) is
               begin
                  case t.ty is
                     when dn_USED_NAME_ID =>
                        declare
                           type_Id	: Tree	:= D ( sm_DEFN, t );
                           type_Spec	: Tree	:= D ( sm_TYPE_SPEC, type_Id );
                        begin
                           case type_Spec.ty is
                              when dn_INTEGER | dn_UNIVERSAL_INTEGER =>
                                 GEN_1_I ( IND, I, 0 );
                                 if type_Spec.ty = dn_UNIVERSAL_INTEGER then
                                    GEN_CSP ( CVB );
                                 end if;
                              when others =>
                                 PUT_LINE ( "!!! load_Object : type_Spec.ty illicite" & Node_Name'IMAGE ( type_Spec.ty ) );
                                 raise Program_Error;
                           end case;
                        end;
                     when others =>
                        PUT_LINE ( "!!! load_Object : t.ty illicite" & Node_Name'IMAGE ( t.ty ) );
                        raise Program_Error;
                  end case;
               end Load_Object;
            
            begin
               while not IS_EMPTY ( formal_param_Seq ) loop
                  POP ( formal_param_Seq, formal_param );
                  formal_id_seq := LIST ( D ( as_SOURCE_NAME_S, formal_param ) );
                  case formal_param.ty is
                     when dn_IN =>
                        while not IS_EMPTY ( formal_id_seq ) loop
                           POP ( formal_id_seq, formal_id );
                           POP ( actual_param_Seq, actual_param );
                           CG_Expr.COMPILE_EXPRESSION ( actual_param );
                        end loop;
                  
                     when dn_OUT | dn_IN_OUT =>
                        while not IS_EMPTY ( formal_id_seq ) loop
                           POP ( formal_id_seq, formal_id );
                           POP ( actual_param_Seq, actual_param );
                           CG_Expr.LOAD_OBJECT_ADDRESS ( actual_param );
                           GEN_0 ( DPL, A );
                           LOAD_OBJECT ( D ( as_NAME, formal_param ) );
                        end loop;
                     
                     when others =>
                        PUT_LINE ( "!!! load_actual_param formal_param.ty illicite" & Node_Name'IMAGE ( formal_param.ty ) );
                        raise Program_Error;
                  end case;
               end loop;
            
            end Load_Actual_Params;
         
         begin
            GEN_2_II ( MST, 0, CG_1.level - DI ( cd_LEVEL, proc_Id ) +1 );
            LOAD_ACTUAL_PARAMS ( D (as_PARAM_S, proc_Spec ), exp_s);
            GEN_2_IL ( call, DI (cd_PARAM_SIZE, proc_Id ), DI ( cd_LABEL, proc_Id ) );
         end Compile_Stm_Procedure_Call;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_raise	
          procedure Compile_Stm_raise ( stm :Tree ) is
            name	: Tree	:= D (as_NAME, stm );
         begin
            if name = Tree_VOID then
               Gen_0 ( RAI );
            else
               declare
                  exception_Id	: Tree	:= D ( sm_DEFN, name );
                  lbl	: Label_Type;
               begin
                  if D ( cd_LABEL, exception_Id ).ty /= dn_NUM_VAL then		--| S'il n'y a pas eu de raise vers l'exception concernée
                     lbl := NEXT_LABEL;
                     DI ( cd_LABEL, exception_Id, lbl );			--| Créer un numéro étiquette pour repérer l'exception
                     GEN_2_LS ( EXL, lbl, PRINT_NAME ( D ( lx_SYMREP, name ) ) );	--| Déclarer cette association
                  end if;
                  GEN_1_L ( RAI, DI ( cd_LABEL, exception_Id ) );
               end;
            end if;
         end Compile_Stm_raise;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_return	
          procedure Compile_Stm_return ( return_stm, enclosing_Body :Tree ) is
            exp	: Tree	:= D ( as_EXP, return_stm );
         begin
            if exp /= Tree_VOID then
               store_Function_Result:
               declare
                  enclosing_Level	: Integer	:= DI ( cd_LEVEL, enclosing_Body );
                  result_Offset	: Integer	:= DI ( cd_RESULT_OFFSET, enclosing_Body );
                  expr_Type	: Tree	:= CG_Expr.TYPE_SPEC_OF_EXPR ( exp );
               begin
                  case expr_Type.ty is
                     when dn_ARRAY =>
                        GEN_2_II ( LDA, CG_1.level - enclosing_Level, result_Offset );
                        CG_Expr.COMPILE_EXPRESSION ( exp );
                        GEN_1_I ( const, I, NUMBER_OF_DIMENSIONS ( exp ) );
                        GEN_CSP ( PUA );
                     
                     when dn_ENUM_LITERAL_S =>
                        CG_Expr.COMPILE_EXPRESSION ( exp );
                        GEN_2_II ( STR, CG_Expr.CODE_TYPE_OF ( exp ), CG_1.level - enclosing_Level, result_Offset );
                     
                     when dn_INTEGER =>
                        CG_Expr.COMPILE_EXPRESSION ( exp );
                        GEN_2_II ( STR, I, CG_1.level - enclosing_Level, result_Offset );
                     
                     when others =>
                        PUT_LINE ( "compile_stm_return type illicite" & Node_Name'IMAGE ( expr_Type.ty ) );
                        raise Program_Error;
                  end case;
               end Store_Function_Result;
            end if;
            Structures.PERFORM_RETURN ( enclosing_Body );
         end Compile_Stm_return;
         
         
          procedure Compile_Statement ( stm, enclosing_Body :Tree );
          
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Labeled	
          procedure Compile_Stm_Labeled ( stm, enclosing_Body :Tree ) is
            Start_Lbl	: Label_Type	:= NEXT_LABEL;
            label_Id_Seq	: Seq_Type	:= LIST ( D ( as_SOURCE_NAME_S, stm ) );
            label_Id	: Tree;
         begin
            while not IS_EMPTY ( label_Id_Seq ) loop
               POP ( label_Id_Seq, label_Id );
            end loop;
            DI ( cd_LABEL, label_Id, start_Lbl );
            COMPILE_STATEMENT ( D ( as_STM, stm ), enclosing_Body );
         end Compile_Stm_Labeled;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Loop	
          procedure Compile_Stm_Loop ( stm_Loop, enclosing_Body :Tree ) is
            before_Loop_Lbl	: Label_Type	:= NEXT_LABEL;
            after_Loop_Lbl	: Label_Type	:= NEXT_LABEL;
            loop_Stm_s	: Tree	:= D ( as_STM_S, stm_Loop );
         
             procedure Load_Dscrt_Range ( dscrt_range :Tree ) is	--| Il y a des erreurs là dedans à mon avis
            
                procedure Load_Type_Bounds ( type_spec :Tree ) is
                  type_source_name	: Tree	:= D ( xd_SOURCE_NAME, type_spec );
                  type_symrep	: Tree	:= D ( lx_SYMREP, type_source_name );
                  name	: constant String	:= PRINT_NAME ( type_symrep );
               begin
                  if name = "BOOLEAN" then
                     GEN_1_I ( const, I, 0 );
                     GEN_1_I ( const, I, 1 );
                  elsif name = "CHARACTER" then
                     GEN_1_I ( const, I, 0 );
                     GEN_1_I ( const, I, 127 );
                  else
                     GEN_1_I ( const, I, 0);
                     GEN_1_I ( const, I, DI ( cd_LAST, type_Spec ) );
                  end if;
               end Load_Type_Bounds;
            
            begin
               if dscrt_range.ty = dn_DISCRETE_SUBTYPE then
                  declare
                     subtype_Indication	: Tree	:= D ( as_SUBTYPE_INDICATION, dscrt_range );
                     constraint	: Tree	:= D ( as_CONSTRAINT, subtype_Indication );
                     type_name	: Tree	:= D ( as_NAME, subtype_Indication );
                  begin
                     if constraint = Tree_VOID then
                        null;
                     else
                        null;
                     end if;
                     --LOAD_TYPE_BOUNDS (nd.c_constrained^.sm_base_type);
                  end;
               elsif dscrt_range.ty = dn_RANGE then
                  CG_Expr.COMPILE_EXPRESSION ( D ( as_EXP1, dscrt_range ) );
                  CG_Expr.COMPILE_EXPRESSION ( D ( as_EXP2, dscrt_range ) );
               elsif dscrt_range.ty = dn_RANGE_ATTRIBUTE then
                  null;
               end if;
            end Load_Dscrt_Range;
         
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Loop_For_Reverse	
             procedure Compile_Stm_Loop_For_Reverse ( stm :Tree; inc_dec, test :Op_Code ) is
               counter, temp	: Integer;
               old_Offset_Act	: Offset_Type	:= CG_1.offset_Act;
               iteration_id	: Tree	:= D ( as_SOURCE_NAME, stm );
               aCT		: Code_Type	:= CG_Expr.CODE_TYPE_OF ( D ( sm_OBJ_TYPE,iteration_id ) );
            begin
               case aCT is
                  when B =>
                     ALIGN ( Bool_Al );
                     counter := -CG_1.offset_Act;
                     INC_OFFSET ( Bool_Size);
                     ALIGN ( Bool_Al);
                     temp := -CG_1.offset_Act;
                     INC_OFFSET ( Bool_Size );
                  when C =>
                     ALIGN ( Char_Al );
                     counter := -CG_1.offset_Act;
                     INC_OFFSET ( Char_Size );
                     ALIGN ( Char_Al);
                     Temp := -CG_1.offset_Act;
                     INC_OFFSET ( Char_Size );
                  when I =>
                     ALIGN ( intg_Al );
                     Counter := -CG_1.offset_Act;			--| Emplacement du compteur de boucle
                     INC_OFFSET ( intg_Size );			--| Une place pour un entier
                     ALIGN ( intg_Al );
                     temp := -CG_1.offset_Act;			--| Emplacement de la limite de comptage
                     INC_OFFSET ( intg_Size );
                  when A =>
                     PUT_LINE ( "!!! compile_stm_loop_reverse aCT illicite " & Code_Type'IMAGE ( aCT ) );
                     raise Program_Error;
               end case;
            
               DI ( cd_LEVEL, iteration_id, CG_1.Level );
               DI ( cd_OFFSET, iteration_id, counter );
               LOAD_DSCRT_RANGE ( D ( as_DISCRETE_RANGE, stm ) );
               GEN_2_II ( STR, aCT, 0, Temp );
               WRITE_LABEL ( before_Loop_Lbl );
               GEN_2_II ( STR, aCT, 0, Counter );
               GEN_2_II ( LOD, aCT, 0, Counter );
               GEN_2_II ( LOD, aCT, 0, Temp );
               GEN_0    ( test, aCT );
               GEN_1_L ( jmpf, after_Loop_Lbl );
               COMPILE_STATEMENTS ( loop_Stm_s, enclosing_Body );
               GEN_2_II ( LOD, aCT, 0, Counter );
               GEN_1_I  ( inc_dec, aCT, 1 );
               GEN_1_L  ( jmp, before_Loop_Lbl );
               CG_1.offset_Act := old_Offset_Act;
            end Compile_Stm_Loop_For_Reverse;
            
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Loop_While	
             procedure Compile_Stm_Loop_While ( stm_while :Tree ) is
            begin
               WRITE_LABEL ( before_Loop_Lbl );
               CG_Expr.COMPILE_EXPRESSION ( D ( as_EXP, stm_while ) );
               GEN_1_L ( jmpf, after_Loop_Lbl );
               COMPILE_STATEMENTS ( loop_Stm_s, enclosing_Body );
               GEN_1_L ( jmp, before_Loop_Lbl );
            end Compile_Stm_Loop_While;
         
         begin
            DI ( cd_AFTER_LOOP, stm_Loop, after_Loop_Lbl );			--| Placer l'étiquette post boucle dans le stm_loop
            DI ( cd_LEVEL, stm_Loop, CG_1.level );			--| Placer le niveau actuel également
         
            declare
               iteration	: Tree	:= D ( as_ITERATION, stm_Loop );	--| Prendre le schéma itératif
            begin
               if iteration = Tree_VOID then			--| S'il n'y en a pas (loop instructions end loop)
                  WRITE_LABEL ( before_Loop_Lbl );			--| Ecrire l'étiquette de début de boucle
                  COMPILE_STATEMENTS ( loop_Stm_s, enclosing_Body );		--| Compiler les instructions
                  GEN_1_L ( jmp, before_Loop_Lbl );			--| Ecrire le saut de retour de bas de boucle
               else	--| Il y a un schéma itératif
                  case iteration.ty is
                     when dn_FOR =>				--| Boucle for ... in ... loop
                        COMPILE_STM_LOOP_FOR_REVERSE ( iteration, inc, le );
                     when dn_REVERSE =>				--| Boucle for ... in reverse ... loop
                        COMPILE_STM_LOOP_FOR_REVERSE ( iteration, dec, ge );
                     when dn_WHILE =>				--| Boucle while ... loop
                        COMPILE_STM_LOOP_WHILE ( iteration );
                     when others =>
                        PUT_LINE ( "!!! compile_stm_loop, as_iteration illicite " & Node_Name'IMAGE ( iteration.ty ) );
                        raise Program_Error;
                  end case;
               end if;
            end;
            WRITE_LABEL ( after_Loop_Lbl );			--| Ecrire l'étiquette post boucle
         end Compile_Stm_Loop;
         --|----------------------------------------------------------------------------------------
         --|	procedure Compile_Stm_Labeled	
          procedure Compile_Statement ( stm, enclosing_Body :Tree ) is
         begin
            case Stm.ty is
               when dn_ASSIGN =>
                  COMPILE_STM_ASSIGN ( stm );
                     
               when dn_BLOCK =>
                  COMPILE_STM_BLOCK ( stm, enclosing_Body );
                     
               when dn_EXIT =>
                  COMPILE_STM_EXIT ( Stm );
                     
               when dn_IF =>
                  COMPILE_STM_IF ( stm, enclosing_Body );
                     
               when dn_LOOP =>
                  COMPILE_STM_LOOP ( stm, enclosing_Body );
                     
               when dn_LABELED =>
                  COMPILE_STM_LABELED ( stm, enclosing_Body );
                     
               when dn_PROCEDURE_CALL =>
                  COMPILE_STM_PROCEDURE_CALL ( stm );
                     
               when dn_RAISE =>
                  COMPILE_STM_RAISE ( stm );
                     
               when dn_RETURN =>
                  COMPILE_STM_RETURN ( stm, enclosing_Body );
                     
               when dn_NULL_STM =>
                  null;
               when dn_ABORT =>
                  null;
               when dn_ACCEPT =>
                  null;
               when dn_CASE =>
                  null;
               when dn_CODE =>
                  null;
               when dn_COND_ENTRY =>
                  null;
               when dn_DELAY =>
                  null;
               when dn_ENTRY_CALL =>
                  null;
               when dn_GOTO =>
                  null;
               when dn_NAMED =>	--| ?
                  null;
               when dn_PRAGMA =>
                  null;
               when dn_SELECTIVE_WAIT =>
                  null;
               when dn_TIMED_ENTRY =>
                  null;
                     
               when others =>
                  PUT_LINE ( "!!! compile_stm instruction illicite" );
                  raise Program_Error;
            end case;
            CG_1.Top_Act := 0;
         end compile_statement;
         --|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
         --|	procedure Compile_Statements
          procedure Compile_Statements ( stm_s, enclosing_Body :Tree ) is
            stm_seq	: Seq_Type	:= LIST ( stm_s );
            stm	: Tree;
         begin
            while not IS_EMPTY ( stm_seq ) loop
               POP ( stm_seq, stm );
               COMPILE_STATEMENT ( stm, enclosing_Body );
            
            end loop;
         end;
         
      --|-------------------------------------------------------------------------------------------
      end Statements;
      
      
      
      
      
   begin
      OPEN_IDL_TREE_FILE ( "$$$.tmp" );
      
      Compile_root:
       declare
         user_Root		: Tree	:= D ( xd_USER_ROOT, Tree_Root );
      -- user_root	=>
      -- 	=> xd_sourcename	:txtrep
      -- 	=> xd_grammar	:void
      -- 	=> xd_statelist	:void
      -- 	=> xd_structure	:compilation . . . . . . . . . . . . . . . . . . . . . . . 	la compilation
      -- 	=> xd_timestamp	:Integer
      -- 	=> spare_3	:void
         compilation	: Tree	:= D ( xd_STRUCTURE, user_root );
      -- compilation	=>
      -- 	=> as_compltn_unit_s:compltn_unit_s . . . . . . . . . . . . . . . . . . . . . 	la liste des unités de compilation
      -- 	=> lx_srcpos	:Source_Position
         compltn_unit_s	: Tree	:= D ( as_COMPLTN_UNIT_S, Compilation );
      -- compltn_unit_s	=>
      -- 	=> as_list	:compilation_unit
      -- 	=> lx_srcpos	:Source_Position
         compltn_unit_seq	: Seq_Type	:= LIST ( compltn_unit_s );
         compilation_unit	: Tree;
      begin
         while not IS_EMPTY ( compltn_unit_seq ) loop			--| tant qu'il y a des unités de compilation
            POP ( compltn_unit_seq, compilation_unit );			--| Extraire une unité de compilation
            CG_1.OPEN_OUTPUT_FILE ( GET_LIB_PREFIX & PRINT_NAME ( D ( xd_LIB_NAME, compilation_unit ) ) );
            Structures.COMPILE_COMPILATION_UNIT ( compilation_unit );			--| Générer le code pour celle-ci
            CG_1.CLOSE_OUTPUT_FILE;
         end loop;
      end Compile_root;
      
      CLOSE_IDL_TREE_FILE;
   end Code_Gen;