#!/bin/bash
#--------------------------------------------------
#	IDL
#--------------------------------------------------
./a83.sh ./ ./IDL_TOOLS/diana_node_attr_class_names.ads W
./a83.sh ./ ../SRC/ada_comp/idl.ads W
./a83.sh ./ ../SRC/ada_comp/idl.adb W

./a83.sh ./ ../SRC/communs/idl-page_man.adb W
./a83.sh ./ ../SRC/communs/idl-idl_tbl.adb W
./a83.sh ./ ../SRC/communs/idl-idl_man.adb W
#--------------------------------------------------
#	PAR_PHASE
#--------------------------------------------------
./a83.sh ./ ../SRC/par_phase/grmr_tbl.ads W
./a83.sh ./ ../SRC/par_phase/grmr_ops.ads W
./a83.sh ./ ../SRC/par_phase/grmr_ops.adb W
./a83.sh ./ ../SRC/par_phase/lex.ads W
./a83.sh ./ ../SRC/par_phase/lex.adb W
# ./a83.sh ./ ../SRC/par_phase/idl-par_phase.adb W	# PB PARAMETER TYPE MISMATCH  USAGE READ_PARSE_TABLES INSTANTIATION GRMR_TBL_IO SEQUENTIAL_IO
#--------------------------------------------------
#	LIB_PHASE
#--------------------------------------------------
# ./a83.sh ./ ../SRC/ada_comp/idl-lib_phase.adb W		# PB PARAMETER TYPE MISMATCH USAGE GET INSTANTIATION INT_IO INTEGER_IO
#--------------------------------------------------
#	SEM_PHASE
#--------------------------------------------------
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase.adb W
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-aggreso.adb W	# PB SUB PAS TROUVE (la première fois pb de open sans create)
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-att_walk.adb W	# PB SUB PAS TROUVE
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-chk_stat.adb W
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-def_util.adb W
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-def_walk.adb W
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-derived.adb W
./a83.sh ./ ../SRC/sem_phase/idl-sem_phase-eval_num.adb W

#--------------------------------------------------
#	ERR_PHASE
#--------------------------------------------------
./a83.sh ./ ../SRC/ada_comp/idl-err_phase.adb W
#--------------------------------------------------
#	WRITE_LIB
#--------------------------------------------------
./a83.sh ./ ../SRC/ada_comp/idl-write_lib.adb W
#--------------------------------------------------
#	CODE_GEN
#--------------------------------------------------
./a83.sh ./ ../SRC/code_gen/emits.ads W
# ./a83.sh ./ ../SRC/code_gen/emits.adb W		# PB PARAMETER TYPE MISMATCH  USAGE PUT INSTANTIATION CODE_OP_IO ENUMERATION_IO
./a83.sh ./ ../SRC/code_gen/code_gen.ads W
./a83.sh ./ ../SRC/code_gen/code_gen.adb W


