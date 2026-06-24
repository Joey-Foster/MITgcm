#!/bin/bash

cd ../multi_core/build
make CLEAN && \
~/mitgcm/MITgcm/tools/genmake2 -rootdir=$HOME/mitgcm/MITgcm/ -mods=../code -mpi -of=$HOME/mitgcm/MITgcm/tools/build_options/linux_iridis6_opt_mpi.gcc.netcdf && \
make depend && \
make -j 4


