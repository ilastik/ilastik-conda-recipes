if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    set +x
    echo "******************************************"
    echo "* You must define CPLEX_ROOT_DIR in your *"
    echo "* environment before building pgmlink.   *"
    echo "******************************************"
    exit 1
fi

mkdir build
cd build
cmake ..\
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
	-DCMAKE_INSTALL_PREFIX=${PREFIX}\
	-DCMAKE_PREFIX_PATH=${PREFIX}\
    -DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS}\ -Wl,-rpath,${PREFIX}/lib\ -L${PREFIX}/lib \
    -DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS}\ -Wl,-rpath,${PREFIX}/lib\ -L${PREFIX}/lib \
	-DBUILD_SHARED_LIBS=ON\
    -DWITH_PYTHON=ON\
    -DWITH_CHECKED_STL=OFF\
    -DWITH_TESTS=ON\
    -DCPLEX_ROOT_DIR="${CPLEX_ROOT_DIR}"

make -j${CPU_COUNT}
make install
