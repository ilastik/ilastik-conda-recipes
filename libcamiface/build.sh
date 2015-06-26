
mkdir build
cd build

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

cmake .. \
  -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
  -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
##

make
make install
