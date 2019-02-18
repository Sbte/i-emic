#!/bin/bash                                                                                               
rm -rf CMakeCache.txt
rm -rf CMakeFiles

module load cmake
module load mkl
MKL_LIBS="mkl_intel_lp64;mkl_intel_thread;mkl_core;pthread;iomp5"

cmake \
  -D CMAKE_INSTALL_PREFIX:PATH=${HOME}/trilinos/11.14 \
  -D CMAKE_BUILD_TYPE=Release \
  -D BUILD_SHARED_LIBS:BOOL=ON \
\
  -D TPL_ENABLE_MPI:BOOL=ON \
  -D TPL_ENABLE_MKL:BOOL=ON \
  -D TPL_ENABLE_BLAS:BOOL=ON \
  -D TPL_ENABLE_LAPACK:BOOL=ON \
  -D TPL_ENABLE_Pthread:BOOL=ON \
  -D TPL_ENABLE_HWLOC:BOOL=ON \
\
  -D TPL_ENABLE_HDF5:BOOL=ON \
  -D HDF5_INCLUDE_DIRS:PATH="${EBROOTHDF5}/include" \
  -D HDF5_LIBRARY_DIRS:PATH="${EBROOTHDF5}/lib" \
\
  -D TPL_MPI_LIBRARIES:STRING=${MKL_LIBS} \
  -D TPL_MKL_LIBRARIES=${MKL_LIBS} \
  -D TPL_BLAS_LIBRARIES:STRING=${MKL_LIBS} \
  -D TPL_LAPACK_LIBRARIES:STRING=${MKL_LIBS} \
  -D TPL_MKL_INCLUDE_DIRS=${MKLROOT}/include \
\
  -D TPL_ENABLE_METIS:BOOL=ON \
  -D METIS_INCLUDE_DIRS:PATH="${EBROOTPARMETIS}/include" \
  -D METIS_LIBRARY_DIRS:PATH="${EBROOTPARMETIS}/lib" \
  -D TPL_ENABLE_ParMETIS:BOOL=ON \
  -D ParMETIS_INCLUDE_DIRS:PATH="${EBROOTPARMETIS}/include" \
  -D ParMETIS_LIBRARY_DIRS:PATH="${EBROOTPARMETIS}/lib" \
\
  -D CMAKE_C_COMPILER:STRING="mpiicc" \
  -D CMAKE_CXX_COMPILER:STRING="mpiicpc" \
  -D CMAKE_Fortran_COMPILER:STRING="mpiifort" \
  -D CMAKE_CXX_FLAGS:STRING="-O3 -g -fopenmp -DMPICH_SKIP_MPICXX" \
\
  -D Trilinos_ENABLE_Export_Makefiles:BOOL=ON \
\
  -D Trilinos_ENABLE_ML:BOOL=ON \
  -D Trilinos_ENABLE_Teuchos:BOOL=ON \
  -D Trilinos_ENABLE_Belos:BOOL=ON \
  -D Trilinos_ENABLE_Epetra:BOOL=ON \
  -D Trilinos_ENABLE_Ifpack:BOOL=ON \
  -D Trilinos_ENABLE_Amesos:BOOL=ON \
  -D Trilinos_ENABLE_Anasazi:BOOL=ON \
  -D Trilinos_ENABLE_OpenMP:BOOL=OFF \
../
