#!/bin/bash

cd multi_core/build
MPI_INC_DIR="/iridisfs/i6software/openmpi/5.0.3/install_gcc14.2/"
module load netcdf-fortran
module load netcdf-c
module load openmpi/5.0.3_gcc14
~/mitgcm/MITgcm/tools/genmake2 -rootdir=$HOME/mitgcm/MITgcm/ -mods=../code -mpi -of=$HOME/mitgcm/MITgcm/tools/build_options/iridis