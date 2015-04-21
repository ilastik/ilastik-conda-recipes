# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_CXX_FLAGS=-fPIC \
        -DCMAKE_SHARED_LINKER_FLAGS=-L${PREFIX}/lib \
        -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DLIBDVID_WRAP_PYTHON=1 \

# BUILD
make -j${CPU_COUNT}

# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    export ${LIBRARY_SEARCH_VAR}=$PREFIX/lib:${!LIBRARY_SEARCH_VAR}
    export PYTHONPATH=${SRC_DIR}/python
    make test
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
