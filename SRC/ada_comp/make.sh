#!/bin/bash

gnatmake -g -gnat83 -I../../EXE/IDL_TOOLS -I../communs/ -I../par_phase -I../sem_phase -I../code_gen -I../pretty ada_comp.adb
rm *.ali
rm *.o
mv ada_comp ../../EXE
