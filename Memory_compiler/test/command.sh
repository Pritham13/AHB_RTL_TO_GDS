#!/bin/bash

export OPENRAM_HOME="~/OpenRAM/compiler"
export OPENRAM_TECH="~/OpenRAM/technology"
export PDK_ROOT="$HOME/gf/pdk"
export PYTHONPATH=$OPENRAM_HOME
python3 $OPENRAM_HOME/../sram_compiler.py SRAM_32x128_1rw-cfg.py
