#!/bin/bash

export OPENRAM_HOME="/home/zero/OpenRAM/compiler"
export OPENRAM_TECH="/home/zero/OpenRAM/technology"
export OPENRAM="/home/zero/OpenRAM"
export PDK_ROOT="$HOME/gf/pdk"
export PYTHONPATH=$OPENRAM_HOME
python3 ~/OpenRAM/sram_compiler.py SRAM_32x128_1r-cfg.py
