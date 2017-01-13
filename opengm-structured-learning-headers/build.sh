if [[ $(uname) == "Darwin" ]]; then
    CC=clang
    CXX=clang++
else
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++
fi

mkdir build
cd build
cmake ..\
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
	-DCMAKE_INSTALL_PREFIX=${PREFIX}\
	-DCMAKE_PREFIX_PATH=${PREFIX}\
	-DWITH_BOOST=ON\
    -DWITH_HDF5=ON\
    -DBUILD_PYTHON_WRAPPER=OFF\
    -DBUILD_TESTING=OFF\
    -DBUILD_TUTORIALS=OFF\
    -DBUILD_EXAMPLES=OFF\
    -DBUILD_COMMANDLINE=OFF

make -j${CPU_COUNT}
make install
