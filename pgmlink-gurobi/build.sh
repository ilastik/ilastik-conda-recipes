
CFLAGS=""
CXXFLAGS=""
LDFLAGS=""

LINKER_FLAGS="-L${PREFIX}/lib"
if [ `uname` != "Darwin" ]; then
    LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib ${LINKER_FLAGS}"
fi

if [ -d $GUROBI_ROOT_DIR ]
then
    LIBNAME=`basename $GUROBI_ROOT_DIR/lib/libgurobi*.so`
else
    echo "Error: GUROBI_ROOT_DIR needs to be set"
    exit 1
fi

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
    -DWITH_CHECKED_STL=OFF\
    -DWITH_TESTS=ON\
    -DGUROBI_INCLUDE_DIR=${GUROBI_ROOT_DIR}/include\
    -DGUROBI_LIBRARY=${GUROBI_ROOT_DIR}/lib/${LIBNAME}\
    -DGUROBI_CXX_LIBRARY=${GUROBI_ROOT_DIR}/lib/libgurobi_c++.a

make -j${CPU_COUNT}
make install

if [ `uname` == "Darwin" ]; then
    # Set install names according using @rpath, which will be configured via the post-link script.
    install_name_tool -change ${LIBNAME} @rpath/${LIBNAME} ${PREFIX}/lib/libpgmlink.dylib
    
    install_name_tool -change ${LIBNAME} @rpath/${LIBNAME} ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    
fi
