if [[ ${NPY_VER} == '' ]]; then
    set +x
    1>&2 echo "*************************************************************************************"
    1>&2 echo "Error: No numpy version specified."
    1>&2 echo "       Please use --numpy=X.Y when invoking conda-build."
    1>&2 echo "       For example:"
    1>&2 echo
    1>&2 echo "           conda build --python=2.7 --numpy=1.9 ${PKG_NAME}"
    1>&2 echo
    1>&2 echo "*************************************************************************************"
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
	-DWITH_BOOST=ON\
    -DWITH_HDF5=ON\
    -DBUILD_PYTHON_WRAPPER=ON\
    -DBUILD_TESTING=OFF\
    -DBUILD_EXAMPLES=OFF\
    -DBUILD_COMMANDLINE=OFF

make -j${CPU_COUNT}
make install