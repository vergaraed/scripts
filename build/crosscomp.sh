#!/bin/zsh

######
######  Cross Compile Environment Variables
######

INSTALL_PATH=$PREFIX
TARGET=$TARGET_ARCH     #x86_64-linux
USE_NEWLIB=0
LINUX_ARCH=x86_64
CONFIGURATION_OPTIONS="--disable-multilib --disable-nls" # --disable-threads --disable-shared
PARALLEL_MAKE=-j4
BINUTILS_VERSION=binutils-2.25

export LD_LIBRARY_PATH=newglibc:$LD_LIBRARY_PATH


##
## usr/local/opt/gcc@11/bin/gcc-11:
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
##
##
##
##
GCC_VERSION=gcc-11.2.0
#GCC_VERSION=gcc-4.9.2


LINUX_KERNEL_VERSION=linux-3.17.2

# libsigsegv -> ../Cellar/libsigsegv/2.14
# cmake -> ../Cellar/cmake/3.22.2
# gmp -> ../Cellar/gmp/6.2.1_1
# isl -> ../Cellar/isl/0.24
# isl@0.23 -> ../Cellar/isl/0.24
# libmpc -> ../Cellar/libmpc/1.2.1
# zstd -> ../Cellar/zstd/1.5.2
# pzstd -> ../Cellar/zstd/1.5.2
# gcc -> ../Cellar/gcc/11.2.0_3


##
##
##
##
GLIBC_VERSION=glibc-2.20

MPFR_VERSION=mpfr-3.1.2

##
## /usr/local/lib/libgmp.10.dylib:
##	/usr/local/lib/libgmp.10.dylib (compatibility version 15.0.0, current version 15.1.0)
##  /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
##
##  /usr/local/opt/gmp/include
##  /usr/local/opt/gmp/lib
##  gmp -> ../Cellar/gmp/6.2.1_1
##
GMP_VERSION=gmp-6.2.1_1
#GMP_VERSION=gmp-6.0.0a

MPC_VERSION=mpc-1.0.2

## otool -vL /usr/local/lib/libisl.dylib
## /usr/local/opt/isl/lib/libisl.23.dylib
## 	/usr/local/opt/isl/lib/libisl.23.dylib (compatibility version 25.0.0, current version 25.0.0)
##  /usr/local/opt/gmp/lib/libgmp.10.dylib (compatibility version 15.0.0, current version 15.1.0)
##  /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1311.0.0)
##
## /usr/local/opt/isl/lib
## /usr/local/opt/isl/include
## isl -> ../Cellar/isl/0.24
##
ISL_VERSION=isl-0.24
#ISL_VERSION=isl-0.12.2

CLOOG_VERSION=cloog-0.18.1
export PATH=$INSTALL_PATH/bin:$PATH
