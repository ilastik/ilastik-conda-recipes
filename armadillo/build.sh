#CWD=$(cd `dirname $0` && pwd)
#source $CWD/../common-vars.sh

mkdir build
cd build
cmake .. \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

make -j${CPU_COUNT}
make install