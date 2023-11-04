#!/bin/bash

gnatmake -g -gnat83 -I../../EXE/IDL_TOOLS/ -I../communs/ -I../par_phase lalr_tools.adb
rm *.ali
rm *.o
mv lalr_tools ../../EXE/LALR_TOOLS
