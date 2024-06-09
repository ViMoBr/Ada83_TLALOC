#!/bin/bash

  set -x
  cd ./build

ADACOMP_SRCS="-aI../SRC/gen_code_gen"

gnatmake $ADACOMP_SRCS -a -D ./ -o ../EXE/gen_code_gen -v -g -gnat83 -aO./ ../SRC/gen_code_gen/gen_code_gen.adb
