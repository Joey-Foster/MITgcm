#!/bin/bash

cd build
make CLEAN && \
~/mitgcm/MITgcm/tools/genmake2 -rootdir=$HOME/mitgcm/MITgcm/ -mods=../code -devel -of=$HOME/mitgcm/MITgcm/tools/build_options/linux_iridis6_opt_mpi.gcc.netcdf && \
make depend && \
make -j 8 2> makeerr.out && \
grep -A 4 -Ei 'temp_integrate|average|K_matrix|Kg_related_functions|coord_transform|g0_functions|gbar|bathy_homog*' makeerr.out
