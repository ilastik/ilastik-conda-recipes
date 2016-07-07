mkdir build
cd build

LINKER_FLAGS="-L${PREFIX}/lib"
export DYLIB="dylib"
if [ `uname` != "Darwin" ]; then
    LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib ${LINKER_FLAGS}"
    export DYLIB="so"
fi

cmake .. \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DPYTHON_LIBRARY=${PREFIX}/lib/libpython2.7.${DYLIB} \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python2.7 \
    -DWITH_LOG=OFF

make -j${CPU_COUNT}
make install