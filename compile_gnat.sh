#!/bin/bash

  set -x
  cd /home/vmo/Documents/ada83_git/ada-83-compiler-tools/build

  ADA_COMP_SRCS="-aI../src/ada_comp -aI../src/communs -aI../src/par_phase -aI../src/sem_phase -aI../src/code_gen -aI../src/pretty -I../bin/idl_tools"

  gnatmake $ADA_COMP_SRCS -D ./ -v -g -gnat83  $2
