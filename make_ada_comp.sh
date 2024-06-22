#!/bin/bash

  set -x

  cd /home/vmo/Documents/ada83_git/ada-83-compiler-tools/EXE
  ./gen_code_gen

  cd /home/vmo/Documents/ada83_git/ada-83-compiler-tools/build

  ADA_COMP_SRCS="-aI../SRC/ada_comp -aI../SRC/communs -aI../SRC/par_phase -aI../SRC/sem_phase -aI../SRC/code_gen -aI../SRC/pretty -I../EXE/IDL_TOOLS"

  gnatmake $ADA_COMP_SRCS -a -D ./ -o ../EXE/ada_comp -v -g -gnat83 -aO./ ../SRC/ada_comp/ada_comp.adb
