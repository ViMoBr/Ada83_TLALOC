with System;
package ada_main is

   gnat_argc : Integer;
   gnat_argv : System.Address;
   gnat_envp : System.Address;

   pragma Import (C, gnat_argc);
   pragma Import (C, gnat_argv);
   pragma Import (C, gnat_envp);

   gnat_exit_status : Integer;
   pragma Import (C, gnat_exit_status);

   GNAT_Version : constant String :=
                    "GNAT Version: 3.15p  (20020523)";
   pragma Export (C, GNAT_Version, "__gnat_version");

   Ada_Main_Program_Name : constant String := "_ada_code_gen" & Ascii.NUL;
   pragma Export (C, Ada_Main_Program_Name, "__gnat_ada_main_program_name");

   procedure adafinal;
   pragma Export (C, adafinal, "adafinal");

   procedure adainit;
   pragma Export (C, adainit, "adainit");

   procedure Break_Start;
   pragma Import (C, Break_Start, "__gnat_break_start");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer;
   pragma Export (C, main, "main");

   type Version_32 is mod 2 ** 32;
   u00001 : constant Version_32 := 16#7b61865a#;
   u00002 : constant Version_32 := 16#bd8f7408#;
   u00003 : constant Version_32 := 16#612a2371#;
   u00004 : constant Version_32 := 16#6d0b25e7#;
   u00005 : constant Version_32 := 16#235ade03#;
   u00006 : constant Version_32 := 16#11b999eb#;
   u00007 : constant Version_32 := 16#a0108083#;
   u00008 : constant Version_32 := 16#6380ea48#;
   u00009 : constant Version_32 := 16#c5fbb2c4#;
   u00010 : constant Version_32 := 16#dc301c49#;
   u00011 : constant Version_32 := 16#6e13833c#;
   u00012 : constant Version_32 := 16#58c090c8#;
   u00013 : constant Version_32 := 16#4a904dde#;
   u00014 : constant Version_32 := 16#2c01a59d#;
   u00015 : constant Version_32 := 16#eb251ef2#;
   u00016 : constant Version_32 := 16#bbfe2e15#;
   u00017 : constant Version_32 := 16#aafe6ddd#;
   u00018 : constant Version_32 := 16#54c27942#;
   u00019 : constant Version_32 := 16#9f9be1af#;
   u00020 : constant Version_32 := 16#4b0fa71c#;
   u00021 : constant Version_32 := 16#63e1558c#;
   u00022 : constant Version_32 := 16#85d0fac3#;
   u00023 : constant Version_32 := 16#5c183864#;
   u00024 : constant Version_32 := 16#e1ec3288#;
   u00025 : constant Version_32 := 16#5f4efe2a#;
   u00026 : constant Version_32 := 16#7e6eaca1#;
   u00027 : constant Version_32 := 16#4b29acb2#;
   u00028 : constant Version_32 := 16#a4e49d90#;
   u00029 : constant Version_32 := 16#a8ad7391#;
   u00030 : constant Version_32 := 16#9a0b3df4#;
   u00031 : constant Version_32 := 16#2768fd3b#;
   u00032 : constant Version_32 := 16#4d4e8ee2#;
   u00033 : constant Version_32 := 16#585eb6a3#;
   u00034 : constant Version_32 := 16#a1d58874#;
   u00035 : constant Version_32 := 16#dfb04293#;
   u00036 : constant Version_32 := 16#10bf32a4#;
   u00037 : constant Version_32 := 16#4c5d7ff9#;
   u00038 : constant Version_32 := 16#7bf62c37#;
   u00039 : constant Version_32 := 16#4475095f#;
   u00040 : constant Version_32 := 16#b4c4d87b#;
   u00041 : constant Version_32 := 16#6e859da6#;
   u00042 : constant Version_32 := 16#83609014#;
   u00043 : constant Version_32 := 16#139120f0#;
   u00044 : constant Version_32 := 16#67de7468#;
   u00045 : constant Version_32 := 16#24457ec0#;
   u00046 : constant Version_32 := 16#dec8b4cc#;
   u00047 : constant Version_32 := 16#0af0a97f#;
   u00048 : constant Version_32 := 16#2707dc21#;
   u00049 : constant Version_32 := 16#cbab28f3#;
   u00050 : constant Version_32 := 16#b2e77bbf#;
   u00051 : constant Version_32 := 16#ff282f59#;
   u00052 : constant Version_32 := 16#9d5e2b8a#;
   u00053 : constant Version_32 := 16#954fba58#;
   u00054 : constant Version_32 := 16#cf0ab27e#;
   u00055 : constant Version_32 := 16#7324ea3c#;
   u00056 : constant Version_32 := 16#de189fd2#;
   u00057 : constant Version_32 := 16#41941407#;
   u00058 : constant Version_32 := 16#753e9209#;
   u00059 : constant Version_32 := 16#6bbeb40e#;
   u00060 : constant Version_32 := 16#edfd8ecc#;
   u00061 : constant Version_32 := 16#ffad3e68#;
   u00062 : constant Version_32 := 16#29e5afbc#;
   u00063 : constant Version_32 := 16#f4128bc8#;
   u00064 : constant Version_32 := 16#2eb80aec#;
   u00065 : constant Version_32 := 16#ae3d0e1f#;
   u00066 : constant Version_32 := 16#9ae01713#;
   u00067 : constant Version_32 := 16#3acc2294#;
   u00068 : constant Version_32 := 16#34ae44dc#;
   u00069 : constant Version_32 := 16#70f6a786#;
   u00070 : constant Version_32 := 16#9fa9075f#;
   u00071 : constant Version_32 := 16#a51734bc#;
   u00072 : constant Version_32 := 16#af3b7699#;
   u00073 : constant Version_32 := 16#f02ff885#;
   u00074 : constant Version_32 := 16#37b55a2d#;
   u00075 : constant Version_32 := 16#2909e352#;
   u00076 : constant Version_32 := 16#cdd17f9b#;
   u00077 : constant Version_32 := 16#2b9118f5#;
   u00078 : constant Version_32 := 16#b123a266#;
   u00079 : constant Version_32 := 16#5fde144c#;
   u00080 : constant Version_32 := 16#b976df8b#;
   u00081 : constant Version_32 := 16#9eef795c#;
   u00082 : constant Version_32 := 16#7632ebb5#;
   u00083 : constant Version_32 := 16#47a468aa#;
   u00084 : constant Version_32 := 16#9edfc99c#;
   u00085 : constant Version_32 := 16#1e439027#;
   u00086 : constant Version_32 := 16#f3d435e7#;
   u00087 : constant Version_32 := 16#4824fe2c#;
   u00088 : constant Version_32 := 16#7fc940eb#;
   u00089 : constant Version_32 := 16#23e9e737#;
   u00090 : constant Version_32 := 16#62885ae1#;
   u00091 : constant Version_32 := 16#d5a4fcdb#;
   u00092 : constant Version_32 := 16#31cde6a7#;
   u00093 : constant Version_32 := 16#728cf22e#;
   u00094 : constant Version_32 := 16#547c2f27#;
   u00095 : constant Version_32 := 16#a2a84339#;
   u00096 : constant Version_32 := 16#0d4a8bcc#;
   u00097 : constant Version_32 := 16#4e709ef2#;
   u00098 : constant Version_32 := 16#cfb745b6#;
   u00099 : constant Version_32 := 16#52d7af9a#;
   u00100 : constant Version_32 := 16#ec185bba#;
   u00101 : constant Version_32 := 16#39231fdf#;
   u00102 : constant Version_32 := 16#371c37e6#;
   u00103 : constant Version_32 := 16#38a5248d#;
   u00104 : constant Version_32 := 16#060f352a#;
   u00105 : constant Version_32 := 16#f6447ab9#;
   u00106 : constant Version_32 := 16#46d230ec#;
   u00107 : constant Version_32 := 16#a0be30a8#;
   u00108 : constant Version_32 := 16#c4504387#;
   u00109 : constant Version_32 := 16#7f70d6fb#;
   u00110 : constant Version_32 := 16#841ddc3f#;
   u00111 : constant Version_32 := 16#86556232#;
   u00112 : constant Version_32 := 16#0c033dfd#;
   u00113 : constant Version_32 := 16#350327a4#;
   u00114 : constant Version_32 := 16#6b21310c#;
   u00115 : constant Version_32 := 16#f8e2e481#;
   u00116 : constant Version_32 := 16#ba8a115e#;
   u00117 : constant Version_32 := 16#747dd46b#;
   u00118 : constant Version_32 := 16#380d61db#;
   u00119 : constant Version_32 := 16#fc8ad137#;
   u00120 : constant Version_32 := 16#2badfa82#;
   u00121 : constant Version_32 := 16#ce361249#;
   u00122 : constant Version_32 := 16#cb23eac8#;
   u00123 : constant Version_32 := 16#92356868#;
   u00124 : constant Version_32 := 16#b380ca7b#;
   u00125 : constant Version_32 := 16#4756b107#;
   u00126 : constant Version_32 := 16#c8497aaf#;
   u00127 : constant Version_32 := 16#e9918401#;
   u00128 : constant Version_32 := 16#e977c7a8#;

   pragma Export (C, u00001, "code_genB");
   pragma Export (C, u00002, "code_genS");
   pragma Export (C, u00003, "system__standard_libraryB");
   pragma Export (C, u00004, "system__standard_libraryS");
   pragma Export (C, u00005, "ada__exceptionsB");
   pragma Export (C, u00006, "ada__exceptionsS");
   pragma Export (C, u00007, "adaS");
   pragma Export (C, u00008, "gnatS");
   pragma Export (C, u00009, "gnat__heap_sort_aB");
   pragma Export (C, u00010, "gnat__heap_sort_aS");
   pragma Export (C, u00011, "systemS");
   pragma Export (C, u00012, "system__exception_tableB");
   pragma Export (C, u00013, "system__exception_tableS");
   pragma Export (C, u00014, "gnat__htableB");
   pragma Export (C, u00015, "gnat__htableS");
   pragma Export (C, u00016, "system__exceptionsS");
   pragma Export (C, u00017, "system__machine_state_operationsB");
   pragma Export (C, u00018, "system__machine_state_operationsS");
   pragma Export (C, u00019, "system__machine_codeS");
   pragma Export (C, u00020, "system__memoryB");
   pragma Export (C, u00021, "system__memoryS");
   pragma Export (C, u00022, "system__soft_linksB");
   pragma Export (C, u00023, "system__soft_linksS");
   pragma Export (C, u00024, "system__parametersB");
   pragma Export (C, u00025, "system__parametersS");
   pragma Export (C, u00026, "system__secondary_stackB");
   pragma Export (C, u00027, "system__secondary_stackS");
   pragma Export (C, u00028, "system__storage_elementsB");
   pragma Export (C, u00029, "system__storage_elementsS");
   pragma Export (C, u00030, "system__stack_checkingB");
   pragma Export (C, u00031, "system__stack_checkingS");
   pragma Export (C, u00032, "system__tracebackB");
   pragma Export (C, u00033, "system__tracebackS");
   pragma Export (C, u00034, "emitsB");
   pragma Export (C, u00035, "emitsS");
   pragma Export (C, u00036, "ada__text_ioB");
   pragma Export (C, u00037, "ada__text_ioS");
   pragma Export (C, u00038, "ada__streamsS");
   pragma Export (C, u00039, "ada__tagsB");
   pragma Export (C, u00040, "ada__tagsS");
   pragma Export (C, u00041, "interfacesS");
   pragma Export (C, u00042, "interfaces__c_streamsB");
   pragma Export (C, u00043, "interfaces__c_streamsS");
   pragma Export (C, u00044, "system__file_ioB");
   pragma Export (C, u00045, "system__file_ioS");
   pragma Export (C, u00046, "ada__finalizationB");
   pragma Export (C, u00047, "ada__finalizationS");
   pragma Export (C, u00048, "system__finalization_rootB");
   pragma Export (C, u00049, "system__finalization_rootS");
   pragma Export (C, u00050, "system__finalization_implementationB");
   pragma Export (C, u00051, "system__finalization_implementationS");
   pragma Export (C, u00052, "system__string_ops_concat_3B");
   pragma Export (C, u00053, "system__string_ops_concat_3S");
   pragma Export (C, u00054, "system__string_opsB");
   pragma Export (C, u00055, "system__string_opsS");
   pragma Export (C, u00056, "system__stream_attributesB");
   pragma Export (C, u00057, "system__stream_attributesS");
   pragma Export (C, u00058, "ada__io_exceptionsS");
   pragma Export (C, u00059, "system__unsigned_typesS");
   pragma Export (C, u00060, "system__file_control_blockS");
   pragma Export (C, u00061, "ada__finalization__list_controllerB");
   pragma Export (C, u00062, "ada__finalization__list_controllerS");
   pragma Export (C, u00063, "ada__text_io__integer_auxB");
   pragma Export (C, u00064, "ada__text_io__integer_auxS");
   pragma Export (C, u00065, "ada__text_io__generic_auxB");
   pragma Export (C, u00066, "ada__text_io__generic_auxS");
   pragma Export (C, u00067, "system__img_biuB");
   pragma Export (C, u00068, "system__img_biuS");
   pragma Export (C, u00069, "system__img_intB");
   pragma Export (C, u00070, "system__img_intS");
   pragma Export (C, u00071, "system__img_llbB");
   pragma Export (C, u00072, "system__img_llbS");
   pragma Export (C, u00073, "system__img_lliB");
   pragma Export (C, u00074, "system__img_lliS");
   pragma Export (C, u00075, "system__img_llwB");
   pragma Export (C, u00076, "system__img_llwS");
   pragma Export (C, u00077, "system__img_wiuB");
   pragma Export (C, u00078, "system__img_wiuS");
   pragma Export (C, u00079, "system__val_intB");
   pragma Export (C, u00080, "system__val_intS");
   pragma Export (C, u00081, "system__val_unsB");
   pragma Export (C, u00082, "system__val_unsS");
   pragma Export (C, u00083, "system__val_utilB");
   pragma Export (C, u00084, "system__val_utilS");
   pragma Export (C, u00085, "gnat__case_utilB");
   pragma Export (C, u00086, "gnat__case_utilS");
   pragma Export (C, u00087, "system__val_lliB");
   pragma Export (C, u00088, "system__val_lliS");
   pragma Export (C, u00089, "system__val_lluB");
   pragma Export (C, u00090, "system__val_lluS");
   pragma Export (C, u00091, "node_attr_class_namesS");
   pragma Export (C, u00092, "system__img_boolB");
   pragma Export (C, u00093, "system__img_boolS");
   pragma Export (C, u00094, "system__img_charB");
   pragma Export (C, u00095, "system__img_charS");
   pragma Export (C, u00096, "system__img_enumB");
   pragma Export (C, u00097, "system__img_enumS");
   pragma Export (C, u00098, "system__string_ops_concat_4B");
   pragma Export (C, u00099, "system__string_ops_concat_4S");
   pragma Export (C, u00100, "system__string_ops_concat_5B");
   pragma Export (C, u00101, "system__string_ops_concat_5S");
   pragma Export (C, u00102, "ada__text_io__enumeration_auxB");
   pragma Export (C, u00103, "ada__text_io__enumeration_auxS");
   pragma Export (C, u00104, "ada__charactersS");
   pragma Export (C, u00105, "ada__characters__handlingB");
   pragma Export (C, u00106, "ada__characters__handlingS");
   pragma Export (C, u00107, "ada__characters__latin_1S");
   pragma Export (C, u00108, "ada__stringsS");
   pragma Export (C, u00109, "ada__strings__mapsB");
   pragma Export (C, u00110, "ada__strings__mapsS");
   pragma Export (C, u00111, "system__bit_opsB");
   pragma Export (C, u00112, "system__bit_opsS");
   pragma Export (C, u00113, "gnat__exceptionsS");
   pragma Export (C, u00114, "ada__strings__maps__constantsS");
   pragma Export (C, u00115, "idlB");
   pragma Export (C, u00116, "idlS");
   pragma Export (C, u00117, "grmr_opsB");
   pragma Export (C, u00118, "grmr_opsS");
   pragma Export (C, u00119, "grmr_tblS");
   pragma Export (C, u00120, "system__sequential_ioB");
   pragma Export (C, u00121, "system__sequential_ioS");
   pragma Export (C, u00122, "lexB");
   pragma Export (C, u00123, "lexS");
   pragma Export (C, u00124, "text_ioS");
   pragma Export (C, u00125, "system__direct_ioB");
   pragma Export (C, u00126, "system__direct_ioS");
   pragma Export (C, u00127, "system__val_enumB");
   pragma Export (C, u00128, "system__val_enumS");

   -- BEGIN ELABORATION ORDER
   -- ada (spec)
   -- ada.characters (spec)
   -- ada.characters.handling (spec)
   -- ada.characters.latin_1 (spec)
   -- gnat (spec)
   -- gnat.case_util (spec)
   -- gnat.case_util (body)
   -- gnat.exceptions (spec)
   -- gnat.heap_sort_a (spec)
   -- gnat.heap_sort_a (body)
   -- gnat.htable (spec)
   -- gnat.htable (body)
   -- interfaces (spec)
   -- system (spec)
   -- system.bit_ops (spec)
   -- system.img_bool (spec)
   -- system.img_char (spec)
   -- system.img_enum (spec)
   -- system.img_int (spec)
   -- system.img_lli (spec)
   -- system.machine_code (spec)
   -- system.parameters (spec)
   -- system.parameters (body)
   -- interfaces.c_streams (spec)
   -- interfaces.c_streams (body)
   -- system.standard_library (spec)
   -- ada.exceptions (spec)
   -- system.exception_table (spec)
   -- system.exception_table (body)
   -- ada.io_exceptions (spec)
   -- ada.strings (spec)
   -- system.exceptions (spec)
   -- system.storage_elements (spec)
   -- system.storage_elements (body)
   -- system.machine_state_operations (spec)
   -- system.secondary_stack (spec)
   -- system.img_lli (body)
   -- system.img_int (body)
   -- system.img_enum (body)
   -- system.img_char (body)
   -- system.img_bool (body)
   -- ada.tags (spec)
   -- ada.tags (body)
   -- ada.streams (spec)
   -- system.stack_checking (spec)
   -- system.soft_links (spec)
   -- system.soft_links (body)
   -- system.stack_checking (body)
   -- system.secondary_stack (body)
   -- system.finalization_root (spec)
   -- system.finalization_root (body)
   -- system.memory (spec)
   -- system.memory (body)
   -- system.machine_state_operations (body)
   -- system.standard_library (body)
   -- system.string_ops (spec)
   -- system.string_ops (body)
   -- system.string_ops_concat_3 (spec)
   -- system.string_ops_concat_3 (body)
   -- system.string_ops_concat_4 (spec)
   -- system.string_ops_concat_4 (body)
   -- system.string_ops_concat_5 (spec)
   -- system.string_ops_concat_5 (body)
   -- system.traceback (spec)
   -- system.traceback (body)
   -- ada.exceptions (body)
   -- system.unsigned_types (spec)
   -- system.bit_ops (body)
   -- ada.strings.maps (spec)
   -- ada.strings.maps (body)
   -- ada.strings.maps.constants (spec)
   -- ada.characters.handling (body)
   -- system.img_biu (spec)
   -- system.img_biu (body)
   -- system.img_llb (spec)
   -- system.img_llb (body)
   -- system.img_llw (spec)
   -- system.img_llw (body)
   -- system.img_wiu (spec)
   -- system.img_wiu (body)
   -- system.stream_attributes (spec)
   -- system.stream_attributes (body)
   -- system.finalization_implementation (spec)
   -- system.finalization_implementation (body)
   -- ada.finalization (spec)
   -- ada.finalization (body)
   -- ada.finalization.list_controller (spec)
   -- ada.finalization.list_controller (body)
   -- system.file_control_block (spec)
   -- system.direct_io (spec)
   -- system.file_io (spec)
   -- system.file_io (body)
   -- system.direct_io (body)
   -- ada.text_io (spec)
   -- ada.text_io (body)
   -- ada.text_io.enumeration_aux (spec)
   -- ada.text_io.generic_aux (spec)
   -- ada.text_io.generic_aux (body)
   -- ada.text_io.enumeration_aux (body)
   -- ada.text_io.integer_aux (spec)
   -- system.sequential_io (spec)
   -- system.sequential_io (body)
   -- system.val_enum (spec)
   -- system.val_int (spec)
   -- system.val_lli (spec)
   -- ada.text_io.integer_aux (body)
   -- system.val_llu (spec)
   -- system.val_uns (spec)
   -- system.val_util (spec)
   -- system.val_util (body)
   -- system.val_uns (body)
   -- system.val_llu (body)
   -- system.val_lli (body)
   -- system.val_int (body)
   -- system.val_enum (body)
   -- text_io (spec)
   -- code_gen (spec)
   -- grmr_ops (spec)
   -- grmr_ops (body)
   -- grmr_tbl (spec)
   -- lex (spec)
   -- lex (body)
   -- node_attr_class_names (spec)
   -- idl (spec)
   -- idl (body)
   -- emits (spec)
   -- emits (body)
   -- code_gen (body)
   -- END ELABORATION ORDER

end ada_main;
