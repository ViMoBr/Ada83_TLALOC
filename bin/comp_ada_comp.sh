#!/bin/bash
./a83.sh ./ ./_standrd.ads w
./a83.sh ./ ./system.ads w
./a83.sh ./ ./calendar.ads w
./a83.sh ./ ./unchecked_deallocation.ads w
./a83.sh ./ ./unchecked_conversion.ads w
./a83.sh ./ ./io_exceptions.ads w
./a83.sh ./ ./text_io.ads w
./a83.sh ./ ./text_io.adb w
./a83.sh ./ ./sequential_io.ads w
./a83.sh ./ ./direct_io.ads w
#--------------------------------------------------
#	IDL
#--------------------------------------------------
./a83.sh ./ ./idl_tools/diana_node_attr_class_names.ads w
./a83.sh ./ ../src/ada_comp/idl.ads w
./a83.sh ./ ../src/ada_comp/idl.adb w

./a83.sh ./ ../src/communs/idl-page_man.adb w
./a83.sh ./ ../src/communs/idl-idl_tbl.adb w
./a83.sh ./ ../src/communs/idl-idl_man.adb w
#--------------------------------------------------
#	PAR_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/par_phase/grmr_tbl.ads w
./a83.sh ./ ../src/par_phase/grmr_ops.ads w
./a83.sh ./ ../src/par_phase/grmr_ops.adb w
./a83.sh ./ ../src/par_phase/lex.ads w
./a83.sh ./ ../src/par_phase/lex.adb w
./a83.sh ./ ../src/par_phase/idl-par_phase.adb w
#--------------------------------------------------
#	LIB_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-lib_phase.adb w
#--------------------------------------------------
#	SEM_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/sem_phase/idl-sem_phase.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-aggreso.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-att_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-chk_stat.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-derived.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-eval_num.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-exp_type.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-expreso.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_pre.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_with.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-gen_subs.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-hom_unit.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-instant.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-make_nod.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-newsnam.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-nod_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pra_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pre_fcns.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-red_subp.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-rep_clau.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-req_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-sem_glob.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-set_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-stm_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-uarith.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-univ_ops.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-vis_util.adb w
#--------------------------------------------------
#	ERR_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-err_phase.adb w
#--------------------------------------------------
#	WRITE_LIB
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-write_lib.adb w
#--------------------------------------------------
#	CODE_GEN
#--------------------------------------------------
./a83.sh ./ ../src/code_gen/codage_intermediaire.ads w
./a83.sh ./ ../src/code_gen/codage_intermediaire.adb w
./a83.sh ./ ../src/code_gen/code_gen.ads w
./a83.sh ./ ../src/code_gen/code_gen.adb w
./a83.sh ./ ../src/code_gen/code_gen-structures.adb w
./a83.sh ./ ../src/code_gen/code_gen-declarations.adb w
./a83.sh ./ ../src/code_gen/code_gen-instructions.adb w
./a83.sh ./ ../src/code_gen/code_gen-expressions.adb w
#--------------------------------------------------
#	ADA_COMP
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/ada_comp.ads w
./a83.sh ./ ../src/ada_comp/ada_comp.adb w

