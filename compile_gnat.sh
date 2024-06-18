#!/bin/bash

  set -x
  cd $1/build

  ADA_COMP_SRCS="-aI../SRC/ada_comp -aI../SRC/communs -aI../SRC/par_phase -aI../SRC/sem_phase -aI../SRC/code_gen -aI../SRC/pretty -I../EXE/IDL_TOOLS"
  pwd
  gnatmake $ADA_COMP_SRCS -D ./ -v -g -gnat83 -aO../EXE $2
