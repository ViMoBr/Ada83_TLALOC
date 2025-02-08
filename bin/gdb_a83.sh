#!/bin/bash
set -x

cd $(dirname $0)

gdb ada_comp
