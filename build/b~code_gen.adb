pragma Source_File_Name (ada_main, Spec_File_Name => "b~code_gen.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~code_gen.adb");

package body ada_main is

   procedure Do_Finalize;
   pragma Import (C, Do_Finalize, "system__standard_library__adafinal");

   procedure adainit is
      E006 : Boolean; pragma Import (Ada, E006, "ada__exceptions_E");
      E013 : Boolean; pragma Import (Ada, E013, "system__exception_table_E");
      E058 : Boolean; pragma Import (Ada, E058, "ada__io_exceptions_E");
      E108 : Boolean; pragma Import (Ada, E108, "ada__strings_E");
      E016 : Boolean; pragma Import (Ada, E016, "system__exceptions_E");
      E027 : Boolean; pragma Import (Ada, E027, "system__secondary_stack_E");
      E040 : Boolean; pragma Import (Ada, E040, "ada__tags_E");
      E038 : Boolean; pragma Import (Ada, E038, "ada__streams_E");
      E023 : Boolean; pragma Import (Ada, E023, "system__soft_links_E");
      E049 : Boolean; pragma Import (Ada, E049, "system__finalization_root_E");
      E110 : Boolean; pragma Import (Ada, E110, "ada__strings__maps_E");
      E114 : Boolean; pragma Import (Ada, E114, "ada__strings__maps__constants_E");
      E051 : Boolean; pragma Import (Ada, E051, "system__finalization_implementation_E");
      E047 : Boolean; pragma Import (Ada, E047, "ada__finalization_E");
      E062 : Boolean; pragma Import (Ada, E062, "ada__finalization__list_controller_E");
      E060 : Boolean; pragma Import (Ada, E060, "system__file_control_block_E");
      E126 : Boolean; pragma Import (Ada, E126, "system__direct_io_E");
      E045 : Boolean; pragma Import (Ada, E045, "system__file_io_E");
      E037 : Boolean; pragma Import (Ada, E037, "ada__text_io_E");
      E121 : Boolean; pragma Import (Ada, E121, "system__sequential_io_E");
      E002 : Boolean; pragma Import (Ada, E002, "code_gen_E");
      E118 : Boolean; pragma Import (Ada, E118, "grmr_ops_E");
      E123 : Boolean; pragma Import (Ada, E123, "lex_E");
      E116 : Boolean; pragma Import (Ada, E116, "idl_E");
      E035 : Boolean; pragma Import (Ada, E035, "emits_E");

      Restrictions : constant String :=
        "nnvvnnnvnnvnnvvvvvvnvvvnvnnvnnnvnvvnnnnnnvvvvnnnvvnn";

      procedure Set_Globals
        (Main_Priority            : Integer;
         Time_Slice_Value         : Integer;
         WC_Encoding              : Character;
         Locking_Policy           : Character;
         Queuing_Policy           : Character;
         Task_Dispatching_Policy  : Character;
         Restrictions             : System.Address;
         Unreserve_All_Interrupts : Integer;
         Exception_Tracebacks     : Integer;
         Zero_Cost_Exceptions     : Integer);
      pragma Import (C, Set_Globals, "__gnat_set_globals");

      procedure Install_Handler;
      pragma Import (C, Install_Handler, "__gnat_install_handler");

      Handler_Installed : Integer;
      pragma Import (C, Handler_Installed, "__gnat_handler_installed");
   begin
      Set_Globals
        (Main_Priority            => -1,
         Time_Slice_Value         => -1,
         WC_Encoding              => 'b',
         Locking_Policy           => ' ',
         Queuing_Policy           => ' ',
         Task_Dispatching_Policy  => ' ',
         Restrictions             => Restrictions'Address,
         Unreserve_All_Interrupts => 0,
         Exception_Tracebacks     => 0,
         Zero_Cost_Exceptions     => 0);

      if Handler_Installed = 0 then
        Install_Handler;
      end if;
      if not E006 then
         Ada.Exceptions'Elab_Spec;
      end if;
      if not E013 then
         System.Exception_Table'Elab_Body;
         E013 := True;
      end if;
      if not E058 then
         Ada.Io_Exceptions'Elab_Spec;
         E058 := True;
      end if;
      if not E108 then
         Ada.Strings'Elab_Spec;
         E108 := True;
      end if;
      if not E016 then
         System.Exceptions'Elab_Spec;
         E016 := True;
      end if;
      if not E040 then
         Ada.Tags'Elab_Spec;
      end if;
      if not E040 then
         Ada.Tags'Elab_Body;
         E040 := True;
      end if;
      if not E038 then
         Ada.Streams'Elab_Spec;
         E038 := True;
      end if;
      if not E023 then
         System.Soft_Links'Elab_Body;
         E023 := True;
      end if;
      if not E027 then
         System.Secondary_Stack'Elab_Body;
         E027 := True;
      end if;
      if not E049 then
         System.Finalization_Root'Elab_Spec;
      end if;
      E049 := True;
      if not E006 then
         Ada.Exceptions'Elab_Body;
         E006 := True;
      end if;
      if not E110 then
         Ada.Strings.Maps'Elab_Spec;
      end if;
      E110 := True;
      if not E114 then
         Ada.Strings.Maps.Constants'Elab_Spec;
         E114 := True;
      end if;
      if not E051 then
         System.Finalization_Implementation'Elab_Spec;
      end if;
      if not E051 then
         System.Finalization_Implementation'Elab_Body;
         E051 := True;
      end if;
      if not E047 then
         Ada.Finalization'Elab_Spec;
      end if;
      E047 := True;
      if not E062 then
         Ada.Finalization.List_Controller'Elab_Spec;
      end if;
      E062 := True;
      if not E060 then
         System.File_Control_Block'Elab_Spec;
         E060 := True;
      end if;
      if not E126 then
         System.Direct_Io'Elab_Spec;
      end if;
      if not E045 then
         System.File_Io'Elab_Body;
         E045 := True;
      end if;
      E126 := True;
      if not E037 then
         Ada.Text_Io'Elab_Spec;
      end if;
      if not E037 then
         Ada.Text_Io'Elab_Body;
         E037 := True;
      end if;
      if not E121 then
         System.Sequential_Io'Elab_Spec;
      end if;
      E121 := True;
      if not E118 then
         GRMR_OPS'ELAB_BODY;
         E118 := True;
      end if;
      if not E123 then
         LEX'ELAB_BODY;
         E123 := True;
      end if;
      if not E116 then
         IDL'ELAB_BODY;
         E116 := True;
      end if;
      if not E035 then
         EMITS'ELAB_SPEC;
      end if;
      E035 := True;
      E002 := True;
   end adainit;

   procedure adafinal is
   begin
      Do_Finalize;
   end adafinal;

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure initialize;
      pragma Import (C, initialize, "__gnat_initialize");

      procedure finalize;
      pragma Import (C, finalize, "__gnat_finalize");


      procedure Ada_Main_Program;
      pragma Import (Ada, Ada_Main_Program, "_ada_code_gen");

      Ensure_Reference : System.Address := Ada_Main_Program_Name'Address;

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize;
      adainit;
      Break_Start;
      Ada_Main_Program;
      Do_Finalize;
      Finalize;
      return (gnat_exit_status);
   end;

-- BEGIN Object file/option list
   --   ./grmr_ops.o
   --   ./grmr_tbl.o
   --   ./lex.o
   --   ./node_attr_class_names.o
   --   ./idl.o
   --   ./emits.o
   --   ./code_gen.o
   --   -L./
   --   -L/home/vincent/Documents/ada_2/Ada83_Compiler/Diana/build/
   --   -L/home/vincent/gnat/lib/gcc-lib/i686-pc-linux-gnu/2.8.1/adalib/
   --   -static
   --   -lgnat
-- END Object file/option list   

end ada_main;
