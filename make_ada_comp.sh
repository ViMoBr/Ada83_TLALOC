#!/bin/bash

set -x

cd $(dirname $0)/build

# cd /home/vmo/Documents/ada83_git/ada-83-compiler-tools/build

  ADA_COMP_SRCS="-aI../src/ada_comp -aI../src/communs -aI../src/par_phase -aI../src/sem_phase -aI../src/expander -aI../src/pretty -I../bin/idl_tools"

  gnatmake $ADA_COMP_SRCS -D ./ -o ../bin/ada_comp -v -g -f -gnat83 -aO./ ../src/ada_comp/ada_comp.adb
