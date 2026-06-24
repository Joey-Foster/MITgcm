#!/bin/bash

cd ../single_core/build
~/mitgcm/MITgcm/tools/genmake2 -rootdir=$HOME/mitgcm/MITgcm/ -mods=../code -of=$HOME/mitgcm/MITgcm/tools/build_options/linux_iridis6_opt_mpi.gcc.netcdf