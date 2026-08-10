#!/bin/bash

cd build
make CLEAN && \
~/Documents/MITgcm/tools/genmake2 -rootdir=$HOME/Documents/MITgcm/ -mods=../code -of=$HOME/Documents/MITgcm/tools/build_options/linux_amd64_gfortran 
