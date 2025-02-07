#!/bin/bash

gnatmake -g -gnat83 -I../communs/ -I../communs_tools/ idl_tools.adb
rm *.ali
rm *.o
mv idl_tools ../../bin/idl_tools
