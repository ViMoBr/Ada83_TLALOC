#!/bin/bash

gnatmake -g -gnat83 -I../../bin/idl_tools/ -I../communs/ -I../par_phase lalr_tools.adb
rm *.ali
rm *.o
mv lalr_tools ../../bin/lalr_tools
