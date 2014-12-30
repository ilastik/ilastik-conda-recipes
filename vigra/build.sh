# On Mac, vigra still supports old versions of stdlibc++, which doesn't have std::thread.
# Vigra can be configured to use boost::thread instead.
if [[ `uname` == 'Darwin' ]]; then
    DEFAULT_VIGRA_WITH_BOOST_THREAD=1
else
    DEFAULT_VIGRA_WITH_BOOST_THREAD=0
fi

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

VIGRA_THREAD_SETTING="-DWITH_BOOST_THREAD=${VIGRA_WITH_BOOST_THREAD}"
VIGRA_LDFLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        ${VIGRA_THREAD_SETTING} \
\
        -DWITH_VIGRANUMPY=TRUE \
        -DDEPENDENCY_SEARCH_PREFIX=${PREFIX} \
\
        -DBoost_INCLUDE_DIR=${PREFIX}/include \
        -DBoost_LIBRARY_DIRS=${PREFIX}/lib \
        -DBoost_PYTHON_LIBRARY=${PREFIX}/lib/libboost_python-mt.${DYLIB_EXT} \
        -DBoost_PYTHON_LIBRARY_RELEASE=${PREFIX}/lib/libboost_python-mt.${DYLIB_EXT} \
        -DBoost_PYTHON_LIBRARY_DEBUG=${PREFIX}/lib/libboost_python-mt.${DYLIB_EXT} \
\
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_INCLUDE_PATH=${PREFIX}/include \
        -DPYTHON_LIBRARIES=${PREFIX}/lib/libpython.2.7.${DYLIB_EXT} \
        -DPYTHON_NUMPY_INCLUDE_DIR=${PREFIX}/lib/python2.7/site-packages/numpy/core/include \
        -DPYTHON_SPHINX=${PREFIX}/bin/sphinx-build \
\
        -DVIGRANUMPY_LIBRARIES="${PREFIX}/lib/libpython2.7.${DYLIB_EXT};${PREFIX}/lib/libboost_python.${DYLIB_EXT};${PREFIX}/lib/libboost_thread.${DYLIB_EXT};${PREFIX}/lib/libboost_system.${DYLIB_EXT}" \
        -DVIGRANUMPY_INSTALL_DIR=${PREFIX}/lib/python2.7/site-packages \
\
        -DPNG_LIBRARY=${PREFIX}/lib/libpng.${DYLIB_EXT} \
        -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
\
        -DTIFF_LIBRARY=${PREFIX}/lib/libtiff.${DYLIB_EXT} \
        -DTIFF_INCLUDE_DIR=${PREFIX}/include \
\
        -DJPEG_INCLUDE_DIR=${PREFIX}/include \
        -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg.${DYLIB_EXT} \
\
        -DHDF5_CORE_LIBRARY=${PREFIX}/lib/libhdf5.${DYLIB_EXT} \
        -DHDF5_HL_LIBRARY=${PREFIX}/lib/libhdf5_hl.${DYLIB_EXT} \
        -DHDF5_INCLUDE_DIR=${PREFIX}/include \
\
        -DZLIB_INCLUDE_DIR=${PREFIX}/include \
        -DZLIB_LIBRARY=${PREFIX}/lib/libz.${DYLIB_EXT} \
\
        -DFFTW3F_INCLUDE_DIR="" \
        -DFFTW3F_LIBRARY="" \
        -DFFTW3_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3_LIBRARY=${PREFIX}/lib/libfftw3.${DYLIB_EXT} \
\
        -DCMAKE_CXX_FLAGS_RELEASE=-O2\ -DNDEBUG \
        -DCMAKE_CXX_LINK_FLAGS="${VIGRA_LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${VIGRA_LDFLAGS}" \

#        -DCMAKE_CXX_FLAGS=-pthread\ ${CXX_FLAGS} \
#        -DCMAKE_CXX_FLAGS_DEBUG="${CXX_FLAGS}"

# BUILD (in parallel)
make -j${CPU_COUNT}

# TEST (before install)
# (Since conda hasn't performed its link step yet, we must help the tests locate their dependencies via LD_LIBRARY_PATH)
if [[ `uname` == 'Darwin' ]]; then
    DYLD_LIBRARY_PATH=$PREFIX/lib make check
else
    LD_LIBRARY_PATH=$PREFIX/lib make check
fi

# "install" to the build prefix (conda will relocate these files afterwards)
make install
