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

export CXXFLAGS=""
export CFLAGS=""
export LDFLAGS=""

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

mkdir build
cd build
cmake ..\
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DPYTHON_LIBRARY=${PREFIX}/lib/libpython2.7.${DYLIB_EXT} \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python2.7 \
    -DVIGRA_INCLUDE_DIR=${PREFIX}/include \
    -DVIGRA_IMPEX_LIBRARY=${PREFIX}/lib/libvigraimpex.${DYLIB_EXT} \
    -DVIGRA_NUMPY_CORE_LIBRARY=${PREFIX}/lib/python2.7/site-packages/vigra/vigranumpycore.so \
    -DWITH_OPENMP=ON \
##

make -j${CPU_COUNT}
make install
