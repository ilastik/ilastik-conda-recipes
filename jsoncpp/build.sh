# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
        -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_CXX_FLAGS="-fPIC" \
        -DBUILD_SHARED_LIBS=1 \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DPYTHON_EXECUTABLE=${PYTHON} \

# BUILD
make -j${CPU_COUNT}


# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    export ${LIBRARY_SEARCH_VAR}=$PREFIX/lib:${!LIBRARY_SEARCH_VAR}
    make jsoncpp_check
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
