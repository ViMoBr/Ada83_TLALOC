pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~code_gen.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~code_gen.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E078 : Short_Integer; pragma Import (Ada, E078, "system__os_lib_E");
   E017 : Short_Integer; pragma Import (Ada, E017, "ada__exceptions_E");
   E013 : Short_Integer; pragma Import (Ada, E013, "system__soft_links_E");
   E011 : Short_Integer; pragma Import (Ada, E011, "system__exception_table_E");
   E044 : Short_Integer; pragma Import (Ada, E044, "ada__containers_E");
   E073 : Short_Integer; pragma Import (Ada, E073, "ada__io_exceptions_E");
   E026 : Short_Integer; pragma Import (Ada, E026, "ada__numerics_E");
   E008 : Short_Integer; pragma Import (Ada, E008, "ada__strings_E");
   E062 : Short_Integer; pragma Import (Ada, E062, "ada__strings__maps_E");
   E065 : Short_Integer; pragma Import (Ada, E065, "ada__strings__maps__constants_E");
   E049 : Short_Integer; pragma Import (Ada, E049, "interfaces__c_E");
   E020 : Short_Integer; pragma Import (Ada, E020, "system__exceptions_E");
   E087 : Short_Integer; pragma Import (Ada, E087, "system__object_reader_E");
   E056 : Short_Integer; pragma Import (Ada, E056, "system__dwarf_lines_E");
   E101 : Short_Integer; pragma Import (Ada, E101, "system__soft_links__initialize_E");
   E043 : Short_Integer; pragma Import (Ada, E043, "system__traceback__symbolic_E");
   E025 : Short_Integer; pragma Import (Ada, E025, "system__img_int_E");
   E068 : Short_Integer; pragma Import (Ada, E068, "system__img_uns_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "ada__strings__utf_encoding_E");
   E113 : Short_Integer; pragma Import (Ada, E113, "ada__tags_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__strings__text_buffers_E");
   E124 : Short_Integer; pragma Import (Ada, E124, "ada__streams_E");
   E136 : Short_Integer; pragma Import (Ada, E136, "system__file_control_block_E");
   E135 : Short_Integer; pragma Import (Ada, E135, "system__finalization_root_E");
   E133 : Short_Integer; pragma Import (Ada, E133, "ada__finalization_E");
   E132 : Short_Integer; pragma Import (Ada, E132, "system__file_io_E");
   E122 : Short_Integer; pragma Import (Ada, E122, "ada__text_io_E");
   E181 : Short_Integer; pragma Import (Ada, E181, "system__direct_io_E");
   E172 : Short_Integer; pragma Import (Ada, E172, "system__sequential_io_E");
   E156 : Short_Integer; pragma Import (Ada, E156, "system__img_llli_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "system__img_lli_E");
   E168 : Short_Integer; pragma Import (Ada, E168, "grmr_ops_E");
   E174 : Short_Integer; pragma Import (Ada, E174, "lex_E");
   E166 : Short_Integer; pragma Import (Ada, E166, "idl_E");
   E120 : Short_Integer; pragma Import (Ada, E120, "emits_E");
   E002 : Short_Integer; pragma Import (Ada, E002, "code_gen_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E172 := E172 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "system__sequential_io__finalize_spec");
      begin
         F1;
      end;
      E181 := E181 - 1;
      declare
         procedure F2;
         pragma Import (Ada, F2, "system__direct_io__finalize_spec");
      begin
         F2;
      end;
      E122 := E122 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "ada__text_io__finalize_spec");
      begin
         F3;
      end;
      declare
         procedure F4;
         pragma Import (Ada, F4, "system__file_io__finalize_body");
      begin
         E132 := E132 - 1;
         F4;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (Ada, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;
   pragma Favor_Top_Level (No_Param_Proc);

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      Ada.Exceptions'Elab_Spec;
      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E011 := E011 + 1;
      Ada.Containers'Elab_Spec;
      E044 := E044 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E073 := E073 + 1;
      Ada.Numerics'Elab_Spec;
      E026 := E026 + 1;
      Ada.Strings'Elab_Spec;
      E008 := E008 + 1;
      Ada.Strings.Maps'Elab_Spec;
      E062 := E062 + 1;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E065 := E065 + 1;
      Interfaces.C'Elab_Spec;
      E049 := E049 + 1;
      System.Exceptions'Elab_Spec;
      E020 := E020 + 1;
      System.Object_Reader'Elab_Spec;
      E087 := E087 + 1;
      System.Dwarf_Lines'Elab_Spec;
      System.Os_Lib'Elab_Body;
      E078 := E078 + 1;
      System.Soft_Links.Initialize'Elab_Body;
      E101 := E101 + 1;
      E013 := E013 + 1;
      System.Traceback.Symbolic'Elab_Body;
      E043 := E043 + 1;
      System.Img_Int'Elab_Spec;
      E025 := E025 + 1;
      E017 := E017 + 1;
      System.Img_Uns'Elab_Spec;
      E068 := E068 + 1;
      E056 := E056 + 1;
      Ada.Strings.Utf_Encoding'Elab_Spec;
      E105 := E105 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E113 := E113 + 1;
      Ada.Strings.Text_Buffers'Elab_Spec;
      E006 := E006 + 1;
      Ada.Streams'Elab_Spec;
      E124 := E124 + 1;
      System.File_Control_Block'Elab_Spec;
      E136 := E136 + 1;
      System.Finalization_Root'Elab_Spec;
      E135 := E135 + 1;
      Ada.Finalization'Elab_Spec;
      E133 := E133 + 1;
      System.File_Io'Elab_Body;
      E132 := E132 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E122 := E122 + 1;
      System.Direct_Io'Elab_Spec;
      E181 := E181 + 1;
      System.Sequential_Io'Elab_Spec;
      E172 := E172 + 1;
      System.Img_Llli'Elab_Spec;
      E156 := E156 + 1;
      System.Img_Lli'Elab_Spec;
      E153 := E153 + 1;
      GRMR_OPS'ELAB_BODY;
      E168 := E168 + 1;
      LEX'ELAB_BODY;
      E174 := E174 + 1;
      IDL'ELAB_BODY;
      E166 := E166 + 1;
      EMITS'ELAB_SPEC;
      E120 := E120 + 1;
      E002 := E002 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_code_gen");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      if gnat_argc = 0 then
         gnat_argc := argc;
         gnat_argv := argv;
      end if;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   ./diana_node_attr_class_names.o
   --   ./grmr_ops.o
   --   ./grmr_tbl.o
   --   ./lex.o
   --   ./idl.o
   --   ./emits.o
   --   ./code_gen.o
   --   -L./
   --   -L../EXE/IDL_TOOLS/
   --   -L/home/vmo/Documents/ada83_git/ada-83-compiler-tools/build/
   --   -L../EXE/
   --   -L/usr/lib/gcc/x86_64-linux-gnu/13/adalib/
   --   -shared
   --   -lgnat-13
   --   -ldl
--  END Object file/option list   

end ada_main;
