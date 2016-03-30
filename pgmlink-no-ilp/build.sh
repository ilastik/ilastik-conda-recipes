CFLAGS=""
CXXFLAGS=""
LDFLAGS=""

mkdir build
cd build
cmake ..\
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
    -DCMAKE_INSTALL_PREFIX=${PREFIX}\
    -DCMAKE_PREFIX_PATH=${PREFIX}\
    -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
    -DBUILD_SHARED_LIBS=ON\
    -DWITH_PYTHON=ON\
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DPYTHON_LIBRARY=${PREFIX}/lib/libpython2.7.${DYLIB} \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python2.7 \
    -DPYTHON_INCLUDE_DIR2=${PREFIX}/include/python2.7 \
    -DPYPGMLINK_INSTALL_DIR=${PREFIX}/lib/python2.7/site-packages \
    -DVIGRA_INCLUDE_DIR=${PREFIX}/include \
    -DVIGRA_IMPEX_LIBRARY=${PREFIX}/lib/libvigraimpex.${DYLIB} \
    -DVIGRA_NUMPY_CORE_LIBRARY=${PREFIX}/lib/python2.7/site-packages/vigra/vigranumpycore.so \
    -DWITH_CHECKED_STL=OFF\
    -DWITH_TESTS=ON\
    -DXml2_INCLUDE_DIR=${PREFIX}/include/libxml2 \
    -DWITH_DPCT=ON \
    -DSUFFIX=-no-ilp-solver

make -j${CPU_COUNT}
make install