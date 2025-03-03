pragma Warnings (Off);
pragma Ada_95;
with System;
with System.Parameters;
with System.Secondary_Stack;
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
                    "GNAT Version: 13.3.0" & ASCII.NUL;
   pragma Export (C, GNAT_Version, "__gnat_version");

   GNAT_Version_Address : constant System.Address := GNAT_Version'Address;
   pragma Export (C, GNAT_Version_Address, "__gnat_version_address");

   Ada_Main_Program_Name : constant String := "_ada_test_json" & ASCII.NUL;
   pragma Export (C, Ada_Main_Program_Name, "__gnat_ada_main_program_name");

   procedure adainit;
   pragma Export (C, adainit, "adainit");

   procedure adafinal;
   pragma Export (C, adafinal, "adafinal");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer;
   pragma Export (C, main, "main");

   type Version_32 is mod 2 ** 32;
   u00001 : constant Version_32 := 16#e1c2f536#;
   pragma Export (C, u00001, "test_jsonB");
   u00002 : constant Version_32 := 16#7320ff5f#;
   pragma Export (C, u00002, "system__standard_libraryB");
   u00003 : constant Version_32 := 16#50630821#;
   pragma Export (C, u00003, "system__standard_libraryS");
   u00004 : constant Version_32 := 16#a201b8c5#;
   pragma Export (C, u00004, "ada__strings__text_buffersB");
   u00005 : constant Version_32 := 16#a7cfd09b#;
   pragma Export (C, u00005, "ada__strings__text_buffersS");
   u00006 : constant Version_32 := 16#76789da1#;
   pragma Export (C, u00006, "adaS");
   u00007 : constant Version_32 := 16#e6d4fa36#;
   pragma Export (C, u00007, "ada__stringsS");
   u00008 : constant Version_32 := 16#426dafb8#;
   pragma Export (C, u00008, "systemS");
   u00009 : constant Version_32 := 16#c71e6c8a#;
   pragma Export (C, u00009, "system__exception_tableB");
   u00010 : constant Version_32 := 16#cf46d9a1#;
   pragma Export (C, u00010, "system__exception_tableS");
   u00011 : constant Version_32 := 16#fd5f5f4c#;
   pragma Export (C, u00011, "system__soft_linksB");
   u00012 : constant Version_32 := 16#f45d276f#;
   pragma Export (C, u00012, "system__soft_linksS");
   u00013 : constant Version_32 := 16#1f6b878b#;
   pragma Export (C, u00013, "system__secondary_stackB");
   u00014 : constant Version_32 := 16#a182043b#;
   pragma Export (C, u00014, "system__secondary_stackS");
   u00015 : constant Version_32 := 16#e9d77c55#;
   pragma Export (C, u00015, "ada__exceptionsB");
   u00016 : constant Version_32 := 16#d5d83a81#;
   pragma Export (C, u00016, "ada__exceptionsS");
   u00017 : constant Version_32 := 16#0740df23#;
   pragma Export (C, u00017, "ada__exceptions__last_chance_handlerB");
   u00018 : constant Version_32 := 16#6dc27684#;
   pragma Export (C, u00018, "ada__exceptions__last_chance_handlerS");
   u00019 : constant Version_32 := 16#ca878138#;
   pragma Export (C, u00019, "system__concat_2B");
   u00020 : constant Version_32 := 16#f796dc4f#;
   pragma Export (C, u00020, "system__concat_2S");
   u00021 : constant Version_32 := 16#752a67ed#;
   pragma Export (C, u00021, "system__concat_3B");
   u00022 : constant Version_32 := 16#c817b61a#;
   pragma Export (C, u00022, "system__concat_3S");
   u00023 : constant Version_32 := 16#63bad2e6#;
   pragma Export (C, u00023, "system__concat_9B");
   u00024 : constant Version_32 := 16#168267d3#;
   pragma Export (C, u00024, "system__concat_9S");
   u00025 : constant Version_32 := 16#70c8108a#;
   pragma Export (C, u00025, "system__exceptionsS");
   u00026 : constant Version_32 := 16#69416224#;
   pragma Export (C, u00026, "system__exceptions__machineB");
   u00027 : constant Version_32 := 16#8bdfdbe3#;
   pragma Export (C, u00027, "system__exceptions__machineS");
   u00028 : constant Version_32 := 16#7706238d#;
   pragma Export (C, u00028, "system__exceptions_debugB");
   u00029 : constant Version_32 := 16#7263f7eb#;
   pragma Export (C, u00029, "system__exceptions_debugS");
   u00030 : constant Version_32 := 16#32ee70d0#;
   pragma Export (C, u00030, "system__img_intS");
   u00031 : constant Version_32 := 16#f2c63a02#;
   pragma Export (C, u00031, "ada__numericsS");
   u00032 : constant Version_32 := 16#174f5472#;
   pragma Export (C, u00032, "ada__numerics__big_numbersS");
   u00033 : constant Version_32 := 16#b847d0e1#;
   pragma Export (C, u00033, "system__unsigned_typesS");
   u00034 : constant Version_32 := 16#5e8f37b6#;
   pragma Export (C, u00034, "system__val_intS");
   u00035 : constant Version_32 := 16#48912782#;
   pragma Export (C, u00035, "system__val_unsS");
   u00036 : constant Version_32 := 16#96e09402#;
   pragma Export (C, u00036, "system__val_utilB");
   u00037 : constant Version_32 := 16#71a87b35#;
   pragma Export (C, u00037, "system__val_utilS");
   u00038 : constant Version_32 := 16#b98923bf#;
   pragma Export (C, u00038, "system__case_utilB");
   u00039 : constant Version_32 := 16#8d7e78ed#;
   pragma Export (C, u00039, "system__case_utilS");
   u00040 : constant Version_32 := 16#8d029d03#;
   pragma Export (C, u00040, "system__wid_unsS");
   u00041 : constant Version_32 := 16#2a95d23d#;
   pragma Export (C, u00041, "system__storage_elementsB");
   u00042 : constant Version_32 := 16#e939c75c#;
   pragma Export (C, u00042, "system__storage_elementsS");
   u00043 : constant Version_32 := 16#5c7d9c20#;
   pragma Export (C, u00043, "system__tracebackB");
   u00044 : constant Version_32 := 16#c4f75b05#;
   pragma Export (C, u00044, "system__tracebackS");
   u00045 : constant Version_32 := 16#5f6b6486#;
   pragma Export (C, u00045, "system__traceback_entriesB");
   u00046 : constant Version_32 := 16#8a711034#;
   pragma Export (C, u00046, "system__traceback_entriesS");
   u00047 : constant Version_32 := 16#b5f8ae26#;
   pragma Export (C, u00047, "system__traceback__symbolicB");
   u00048 : constant Version_32 := 16#d9e66ad1#;
   pragma Export (C, u00048, "system__traceback__symbolicS");
   u00049 : constant Version_32 := 16#179d7d28#;
   pragma Export (C, u00049, "ada__containersS");
   u00050 : constant Version_32 := 16#701f9d88#;
   pragma Export (C, u00050, "ada__exceptions__tracebackB");
   u00051 : constant Version_32 := 16#eb07882c#;
   pragma Export (C, u00051, "ada__exceptions__tracebackS");
   u00052 : constant Version_32 := 16#15f799c2#;
   pragma Export (C, u00052, "interfacesS");
   u00053 : constant Version_32 := 16#545fe66d#;
   pragma Export (C, u00053, "interfaces__cB");
   u00054 : constant Version_32 := 16#56944f47#;
   pragma Export (C, u00054, "interfaces__cS");
   u00055 : constant Version_32 := 16#49b0e1bc#;
   pragma Export (C, u00055, "system__parametersB");
   u00056 : constant Version_32 := 16#5d54152a#;
   pragma Export (C, u00056, "system__parametersS");
   u00057 : constant Version_32 := 16#6ef2c461#;
   pragma Export (C, u00057, "system__bounded_stringsB");
   u00058 : constant Version_32 := 16#35908ea1#;
   pragma Export (C, u00058, "system__bounded_stringsS");
   u00059 : constant Version_32 := 16#d75287d2#;
   pragma Export (C, u00059, "system__crtlS");
   u00060 : constant Version_32 := 16#9f199b4a#;
   pragma Export (C, u00060, "system__dwarf_linesB");
   u00061 : constant Version_32 := 16#a5cb9aae#;
   pragma Export (C, u00061, "system__dwarf_linesS");
   u00062 : constant Version_32 := 16#5b4659fa#;
   pragma Export (C, u00062, "ada__charactersS");
   u00063 : constant Version_32 := 16#f70a517e#;
   pragma Export (C, u00063, "ada__characters__handlingB");
   u00064 : constant Version_32 := 16#ea6baced#;
   pragma Export (C, u00064, "ada__characters__handlingS");
   u00065 : constant Version_32 := 16#cde9ea2d#;
   pragma Export (C, u00065, "ada__characters__latin_1S");
   u00066 : constant Version_32 := 16#16f45e54#;
   pragma Export (C, u00066, "ada__strings__mapsB");
   u00067 : constant Version_32 := 16#9df1863a#;
   pragma Export (C, u00067, "ada__strings__mapsS");
   u00068 : constant Version_32 := 16#96b40646#;
   pragma Export (C, u00068, "system__bit_opsB");
   u00069 : constant Version_32 := 16#8f9e0384#;
   pragma Export (C, u00069, "system__bit_opsS");
   u00070 : constant Version_32 := 16#4642cba6#;
   pragma Export (C, u00070, "ada__strings__maps__constantsS");
   u00071 : constant Version_32 := 16#a0d3d22b#;
   pragma Export (C, u00071, "system__address_imageB");
   u00072 : constant Version_32 := 16#e3813282#;
   pragma Export (C, u00072, "system__address_imageS");
   u00073 : constant Version_32 := 16#cdf7317a#;
   pragma Export (C, u00073, "system__img_unsS");
   u00074 : constant Version_32 := 16#20ec7aa3#;
   pragma Export (C, u00074, "system__ioB");
   u00075 : constant Version_32 := 16#dc2f58f7#;
   pragma Export (C, u00075, "system__ioS");
   u00076 : constant Version_32 := 16#754b4bb8#;
   pragma Export (C, u00076, "system__mmapB");
   u00077 : constant Version_32 := 16#7a46ab42#;
   pragma Export (C, u00077, "system__mmapS");
   u00078 : constant Version_32 := 16#367911c4#;
   pragma Export (C, u00078, "ada__io_exceptionsS");
   u00079 : constant Version_32 := 16#2c102252#;
   pragma Export (C, u00079, "system__mmap__os_interfaceB");
   u00080 : constant Version_32 := 16#c66fda6c#;
   pragma Export (C, u00080, "system__mmap__os_interfaceS");
   u00081 : constant Version_32 := 16#cfabc1c9#;
   pragma Export (C, u00081, "system__mmap__unixS");
   u00082 : constant Version_32 := 16#55f58db9#;
   pragma Export (C, u00082, "system__os_libB");
   u00083 : constant Version_32 := 16#49939eef#;
   pragma Export (C, u00083, "system__os_libS");
   u00084 : constant Version_32 := 16#6e5d049a#;
   pragma Export (C, u00084, "system__atomic_operations__test_and_setB");
   u00085 : constant Version_32 := 16#57acee8e#;
   pragma Export (C, u00085, "system__atomic_operations__test_and_setS");
   u00086 : constant Version_32 := 16#850ed59d#;
   pragma Export (C, u00086, "system__atomic_operationsS");
   u00087 : constant Version_32 := 16#29cc6115#;
   pragma Export (C, u00087, "system__atomic_primitivesB");
   u00088 : constant Version_32 := 16#0524e799#;
   pragma Export (C, u00088, "system__atomic_primitivesS");
   u00089 : constant Version_32 := 16#256dbbe5#;
   pragma Export (C, u00089, "system__stringsB");
   u00090 : constant Version_32 := 16#d9efafa0#;
   pragma Export (C, u00090, "system__stringsS");
   u00091 : constant Version_32 := 16#2fdbc40e#;
   pragma Export (C, u00091, "system__object_readerB");
   u00092 : constant Version_32 := 16#55f4bbb3#;
   pragma Export (C, u00092, "system__object_readerS");
   u00093 : constant Version_32 := 16#d7e08022#;
   pragma Export (C, u00093, "system__val_lliS");
   u00094 : constant Version_32 := 16#6a5ef568#;
   pragma Export (C, u00094, "system__val_lluS");
   u00095 : constant Version_32 := 16#bad10b33#;
   pragma Export (C, u00095, "system__exception_tracesB");
   u00096 : constant Version_32 := 16#aef5c6de#;
   pragma Export (C, u00096, "system__exception_tracesS");
   u00097 : constant Version_32 := 16#fd158a37#;
   pragma Export (C, u00097, "system__wch_conB");
   u00098 : constant Version_32 := 16#9b6e8cdb#;
   pragma Export (C, u00098, "system__wch_conS");
   u00099 : constant Version_32 := 16#5c289972#;
   pragma Export (C, u00099, "system__wch_stwB");
   u00100 : constant Version_32 := 16#b67fa0da#;
   pragma Export (C, u00100, "system__wch_stwS");
   u00101 : constant Version_32 := 16#f8305de6#;
   pragma Export (C, u00101, "system__wch_cnvB");
   u00102 : constant Version_32 := 16#9dae46ab#;
   pragma Export (C, u00102, "system__wch_cnvS");
   u00103 : constant Version_32 := 16#e538de43#;
   pragma Export (C, u00103, "system__wch_jisB");
   u00104 : constant Version_32 := 16#28192481#;
   pragma Export (C, u00104, "system__wch_jisS");
   u00105 : constant Version_32 := 16#0286ce9f#;
   pragma Export (C, u00105, "system__soft_links__initializeB");
   u00106 : constant Version_32 := 16#2ed17187#;
   pragma Export (C, u00106, "system__soft_links__initializeS");
   u00107 : constant Version_32 := 16#8599b27b#;
   pragma Export (C, u00107, "system__stack_checkingB");
   u00108 : constant Version_32 := 16#e2b806a2#;
   pragma Export (C, u00108, "system__stack_checkingS");
   u00109 : constant Version_32 := 16#8b7604c4#;
   pragma Export (C, u00109, "ada__strings__utf_encodingB");
   u00110 : constant Version_32 := 16#4d0e0994#;
   pragma Export (C, u00110, "ada__strings__utf_encodingS");
   u00111 : constant Version_32 := 16#bb780f45#;
   pragma Export (C, u00111, "ada__strings__utf_encoding__stringsB");
   u00112 : constant Version_32 := 16#b85ff4b6#;
   pragma Export (C, u00112, "ada__strings__utf_encoding__stringsS");
   u00113 : constant Version_32 := 16#d1d1ed0b#;
   pragma Export (C, u00113, "ada__strings__utf_encoding__wide_stringsB");
   u00114 : constant Version_32 := 16#5678478f#;
   pragma Export (C, u00114, "ada__strings__utf_encoding__wide_stringsS");
   u00115 : constant Version_32 := 16#c2b98963#;
   pragma Export (C, u00115, "ada__strings__utf_encoding__wide_wide_stringsB");
   u00116 : constant Version_32 := 16#d7af3358#;
   pragma Export (C, u00116, "ada__strings__utf_encoding__wide_wide_stringsS");
   u00117 : constant Version_32 := 16#f38d604a#;
   pragma Export (C, u00117, "ada__tagsB");
   u00118 : constant Version_32 := 16#4d1deaec#;
   pragma Export (C, u00118, "ada__tagsS");
   u00119 : constant Version_32 := 16#3548d972#;
   pragma Export (C, u00119, "system__htableB");
   u00120 : constant Version_32 := 16#c3b4f753#;
   pragma Export (C, u00120, "system__htableS");
   u00121 : constant Version_32 := 16#1f1abe38#;
   pragma Export (C, u00121, "system__string_hashB");
   u00122 : constant Version_32 := 16#64f1772c#;
   pragma Export (C, u00122, "system__string_hashS");
   u00123 : constant Version_32 := 16#bc341642#;
   pragma Export (C, u00123, "jsonB");
   u00124 : constant Version_32 := 16#0a78ee36#;
   pragma Export (C, u00124, "jsonS");
   u00125 : constant Version_32 := 16#67eb6d5a#;
   pragma Export (C, u00125, "ada__text_ioB");
   u00126 : constant Version_32 := 16#3cf1122b#;
   pragma Export (C, u00126, "ada__text_ioS");
   u00127 : constant Version_32 := 16#b4f41810#;
   pragma Export (C, u00127, "ada__streamsB");
   u00128 : constant Version_32 := 16#67e31212#;
   pragma Export (C, u00128, "ada__streamsS");
   u00129 : constant Version_32 := 16#abd3c34b#;
   pragma Export (C, u00129, "system__put_imagesB");
   u00130 : constant Version_32 := 16#5ec3a8a7#;
   pragma Export (C, u00130, "system__put_imagesS");
   u00131 : constant Version_32 := 16#22b9eb9f#;
   pragma Export (C, u00131, "ada__strings__text_buffers__utilsB");
   u00132 : constant Version_32 := 16#89062ac3#;
   pragma Export (C, u00132, "ada__strings__text_buffers__utilsS");
   u00133 : constant Version_32 := 16#73d2d764#;
   pragma Export (C, u00133, "interfaces__c_streamsB");
   u00134 : constant Version_32 := 16#7acc80b4#;
   pragma Export (C, u00134, "interfaces__c_streamsS");
   u00135 : constant Version_32 := 16#eb35f7c9#;
   pragma Export (C, u00135, "system__file_ioB");
   u00136 : constant Version_32 := 16#3ecf6aed#;
   pragma Export (C, u00136, "system__file_ioS");
   u00137 : constant Version_32 := 16#86c56e5a#;
   pragma Export (C, u00137, "ada__finalizationS");
   u00138 : constant Version_32 := 16#95817ed8#;
   pragma Export (C, u00138, "system__finalization_rootB");
   u00139 : constant Version_32 := 16#0d9fdc28#;
   pragma Export (C, u00139, "system__finalization_rootS");
   u00140 : constant Version_32 := 16#e09c58a9#;
   pragma Export (C, u00140, "system__file_control_blockS");
   u00141 : constant Version_32 := 16#44bc8f6a#;
   pragma Export (C, u00141, "ada__text_io__generic_auxB");
   u00142 : constant Version_32 := 16#ba6faca0#;
   pragma Export (C, u00142, "ada__text_io__generic_auxS");
   u00143 : constant Version_32 := 16#bcc987d2#;
   pragma Export (C, u00143, "system__concat_4B");
   u00144 : constant Version_32 := 16#7195f086#;
   pragma Export (C, u00144, "system__concat_4S");
   u00145 : constant Version_32 := 16#ebb39bbb#;
   pragma Export (C, u00145, "system__concat_5B");
   u00146 : constant Version_32 := 16#02f47e63#;
   pragma Export (C, u00146, "system__concat_5S");
   u00147 : constant Version_32 := 16#02cecc7b#;
   pragma Export (C, u00147, "system__concat_6B");
   u00148 : constant Version_32 := 16#c03f5eb0#;
   pragma Export (C, u00148, "system__concat_6S");
   u00149 : constant Version_32 := 16#aca86823#;
   pragma Export (C, u00149, "system__direct_ioB");
   u00150 : constant Version_32 := 16#bd484f56#;
   pragma Export (C, u00150, "system__direct_ioS");
   u00151 : constant Version_32 := 16#a76d79d9#;
   pragma Export (C, u00151, "system__fat_lfltS");
   u00152 : constant Version_32 := 16#f1d549fe#;
   pragma Export (C, u00152, "system__img_fltS");
   u00153 : constant Version_32 := 16#815f70d4#;
   pragma Export (C, u00153, "system__fat_fltS");
   u00154 : constant Version_32 := 16#1b28662b#;
   pragma Export (C, u00154, "system__float_controlB");
   u00155 : constant Version_32 := 16#a291ec84#;
   pragma Export (C, u00155, "system__float_controlS");
   u00156 : constant Version_32 := 16#4f0058da#;
   pragma Export (C, u00156, "system__img_utilB");
   u00157 : constant Version_32 := 16#35740b01#;
   pragma Export (C, u00157, "system__img_utilS");
   u00158 : constant Version_32 := 16#e7771600#;
   pragma Export (C, u00158, "system__powten_fltS");
   u00159 : constant Version_32 := 16#2a9b675e#;
   pragma Export (C, u00159, "system__img_lfltS");
   u00160 : constant Version_32 := 16#585f81ee#;
   pragma Export (C, u00160, "system__img_lluS");
   u00161 : constant Version_32 := 16#ad0ace1a#;
   pragma Export (C, u00161, "system__wid_lluS");
   u00162 : constant Version_32 := 16#ee65fd70#;
   pragma Export (C, u00162, "system__powten_lfltS");
   u00163 : constant Version_32 := 16#614b4032#;
   pragma Export (C, u00163, "system__img_llfS");
   u00164 : constant Version_32 := 16#ddbdd733#;
   pragma Export (C, u00164, "system__fat_llfS");
   u00165 : constant Version_32 := 16#d9f447fb#;
   pragma Export (C, u00165, "system__powten_llfS");
   u00166 : constant Version_32 := 16#95f8767f#;
   pragma Export (C, u00166, "system__val_fltS");
   u00167 : constant Version_32 := 16#e77d8041#;
   pragma Export (C, u00167, "system__exn_fltS");
   u00168 : constant Version_32 := 16#7054388e#;
   pragma Export (C, u00168, "system__val_lfltS");
   u00169 : constant Version_32 := 16#593c6198#;
   pragma Export (C, u00169, "system__exn_lfltS");
   u00170 : constant Version_32 := 16#d0838ac3#;
   pragma Export (C, u00170, "system__val_llfS");
   u00171 : constant Version_32 := 16#7492a1e8#;
   pragma Export (C, u00171, "system__exn_llfS");
   u00172 : constant Version_32 := 16#7d9ea9cb#;
   pragma Export (C, u00172, "text_ioS");
   u00173 : constant Version_32 := 16#d22fc2e4#;
   pragma Export (C, u00173, "system__memoryB");
   u00174 : constant Version_32 := 16#19e99d68#;
   pragma Export (C, u00174, "system__memoryS");

   --  BEGIN ELABORATION ORDER
   --  ada%s
   --  ada.characters%s
   --  ada.characters.latin_1%s
   --  interfaces%s
   --  system%s
   --  system.atomic_operations%s
   --  system.float_control%s
   --  system.float_control%b
   --  system.io%s
   --  system.io%b
   --  system.parameters%s
   --  system.parameters%b
   --  system.crtl%s
   --  interfaces.c_streams%s
   --  interfaces.c_streams%b
   --  system.powten_flt%s
   --  system.powten_lflt%s
   --  system.powten_llf%s
   --  system.storage_elements%s
   --  system.storage_elements%b
   --  system.stack_checking%s
   --  system.stack_checking%b
   --  system.string_hash%s
   --  system.string_hash%b
   --  system.htable%s
   --  system.htable%b
   --  system.strings%s
   --  system.strings%b
   --  system.traceback_entries%s
   --  system.traceback_entries%b
   --  system.unsigned_types%s
   --  system.wch_con%s
   --  system.wch_con%b
   --  system.wch_jis%s
   --  system.wch_jis%b
   --  system.wch_cnv%s
   --  system.wch_cnv%b
   --  system.concat_2%s
   --  system.concat_2%b
   --  system.concat_3%s
   --  system.concat_3%b
   --  system.concat_4%s
   --  system.concat_4%b
   --  system.concat_5%s
   --  system.concat_5%b
   --  system.concat_6%s
   --  system.concat_6%b
   --  system.concat_9%s
   --  system.concat_9%b
   --  system.exn_flt%s
   --  system.exn_lflt%s
   --  system.exn_llf%s
   --  system.traceback%s
   --  system.traceback%b
   --  ada.characters.handling%s
   --  system.atomic_operations.test_and_set%s
   --  system.case_util%s
   --  system.os_lib%s
   --  system.secondary_stack%s
   --  system.standard_library%s
   --  ada.exceptions%s
   --  system.exceptions_debug%s
   --  system.exceptions_debug%b
   --  system.soft_links%s
   --  system.val_llu%s
   --  system.val_lli%s
   --  system.val_uns%s
   --  system.val_int%s
   --  system.val_util%s
   --  system.val_util%b
   --  system.wch_stw%s
   --  system.wch_stw%b
   --  ada.exceptions.last_chance_handler%s
   --  ada.exceptions.last_chance_handler%b
   --  ada.exceptions.traceback%s
   --  ada.exceptions.traceback%b
   --  system.address_image%s
   --  system.address_image%b
   --  system.bit_ops%s
   --  system.bit_ops%b
   --  system.bounded_strings%s
   --  system.bounded_strings%b
   --  system.case_util%b
   --  system.exception_table%s
   --  system.exception_table%b
   --  ada.containers%s
   --  ada.io_exceptions%s
   --  ada.numerics%s
   --  ada.numerics.big_numbers%s
   --  ada.strings%s
   --  ada.strings.maps%s
   --  ada.strings.maps%b
   --  ada.strings.maps.constants%s
   --  interfaces.c%s
   --  interfaces.c%b
   --  system.atomic_primitives%s
   --  system.atomic_primitives%b
   --  system.exceptions%s
   --  system.exceptions.machine%s
   --  system.exceptions.machine%b
   --  ada.characters.handling%b
   --  system.atomic_operations.test_and_set%b
   --  system.exception_traces%s
   --  system.exception_traces%b
   --  system.memory%s
   --  system.memory%b
   --  system.mmap%s
   --  system.mmap.os_interface%s
   --  system.mmap%b
   --  system.mmap.unix%s
   --  system.mmap.os_interface%b
   --  system.object_reader%s
   --  system.object_reader%b
   --  system.dwarf_lines%s
   --  system.os_lib%b
   --  system.secondary_stack%b
   --  system.soft_links.initialize%s
   --  system.soft_links.initialize%b
   --  system.soft_links%b
   --  system.standard_library%b
   --  system.traceback.symbolic%s
   --  system.traceback.symbolic%b
   --  system.wid_uns%s
   --  system.img_int%s
   --  ada.exceptions%b
   --  system.img_uns%s
   --  system.dwarf_lines%b
   --  ada.strings.utf_encoding%s
   --  ada.strings.utf_encoding%b
   --  ada.strings.utf_encoding.strings%s
   --  ada.strings.utf_encoding.strings%b
   --  ada.strings.utf_encoding.wide_strings%s
   --  ada.strings.utf_encoding.wide_strings%b
   --  ada.strings.utf_encoding.wide_wide_strings%s
   --  ada.strings.utf_encoding.wide_wide_strings%b
   --  ada.tags%s
   --  ada.tags%b
   --  ada.strings.text_buffers%s
   --  ada.strings.text_buffers%b
   --  ada.strings.text_buffers.utils%s
   --  ada.strings.text_buffers.utils%b
   --  system.fat_flt%s
   --  system.fat_lflt%s
   --  system.fat_llf%s
   --  system.put_images%s
   --  system.put_images%b
   --  ada.streams%s
   --  ada.streams%b
   --  system.file_control_block%s
   --  system.finalization_root%s
   --  system.finalization_root%b
   --  ada.finalization%s
   --  system.file_io%s
   --  system.file_io%b
   --  system.val_flt%s
   --  system.val_lflt%s
   --  system.val_llf%s
   --  ada.text_io%s
   --  ada.text_io%b
   --  ada.text_io.generic_aux%s
   --  ada.text_io.generic_aux%b
   --  system.direct_io%s
   --  system.direct_io%b
   --  system.img_util%s
   --  system.img_util%b
   --  system.img_flt%s
   --  system.wid_llu%s
   --  system.img_llu%s
   --  system.img_lflt%s
   --  system.img_llf%s
   --  text_io%s
   --  json%s
   --  json%b
   --  test_json%b
   --  END ELABORATION ORDER

end ada_main;
