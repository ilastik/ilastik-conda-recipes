mkdir build
cd build

BLAS_STRING=""
if [ `uname` != "Darwin" ]; then
	BLAS_STRING="-DBLAS_LIBRARY=${PREFIX}/lib/libopenblas.so -DOpenBLAS_LIBRARY=${PREFIX}/lib/libopenblas.so -DLAPACK_LIBRARY=${PREFIX}/lib/libopenblas.so"
fi

cmake .. \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ${BLAS_STRING}

make -j${CPU_COUNT}
make install
