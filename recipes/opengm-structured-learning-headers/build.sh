mkdir build
cd build

EXTRA_CMAKE_ARGS=""
if [[ `uname` == 'Linux' ]];
then
    # Should probably better fix the findHDF5, but for not, the current
    # zlib package on cf does not have a `libz.so`
    EXTRA_CMAKE_ARGS="-DHDF5_Z_LIBRARY=${PEFIX}/lib/libz.so.1"
fi

cmake ..\
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_PREFIX_PATH=${PREFIX} \
	-DWITH_BOOST=ON \
    -DWITH_HDF5=ON \
    -DBUILD_PYTHON_WRAPPER=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_TUTORIALS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_COMMANDLINE=OFF \
    ${EXTRA_CMAKE_ARGS} \


make -j${CPU_COUNT}
make install
