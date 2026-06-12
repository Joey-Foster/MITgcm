#!/bin/bash

cd single_core/build
module load netcdf-c
module load netcdf-fortran
~/mitgcm/MITgcm/tools/genmake2 -rootdir=$HOME/mitgcm/MITgcm/ -mods=../code -of=$HOME/mitgcm/MITgcm/tools/build_options/linux_amd64_gfortran