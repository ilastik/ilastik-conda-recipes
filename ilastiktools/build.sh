# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

export CXXFLAGS=""
export CFLAGS=""
export LDFLAGS=""

mkdir build
cd build
cmake ..\
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DPYTHON_LIBRARY=${PREFIX}/lib/libpython3.5m.${DYLIB_EXT} \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python3.5m \
    -DVIGRA_INCLUDE_DIR=${PREFIX}/include \
    -DVIGRA_IMPEX_LIBRARY=${PREFIX}/lib/libvigraimpex.${DYLIB_EXT} \
    -DVIGRA_NUMPY_CORE_LIBRARY=${PREFIX}/lib/python3.5/site-packages/vigra/vigranumpycore.so \
    -DWITH_OPENMP=ON \
##

make -j${CPU_COUNT}
make install
