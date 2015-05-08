# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

if [[ `uname` == 'Darwin' ]]; then
    VIGRA_CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include" # I have no clue why this -I option is necessary on Mac.
else
    VIGRA_CXX_FLAGS="-pthread ${CXXFLAGS}"
fi

# In release mode, we use -O2 because gcc is known to miscompile certain vigra functionality at the O3 level.
# (This is probably due to inappropriate use of undefined behavior in vigra itself.)
VIGRA_CXX_FLAGS_RELEASE="-O2 -DNDEBUG ${VIGRA_CXX_FLAGS}"
VIGRA_LDFLAGS="${CXX_LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

# We like to make builds of vigra from arbitrary git commits (not always tagged).
# Include the git commit in the build version so we remember which one was used for the build.
echo "$GIT_DESCRIBE_HASH" > __conda_version__.txt 

# These extra flags for .c files enable us to build on CentOS-5.11,
# even with its default glibc headers, with gcc's special 'fixincludes' headers.
# (No 'fixincludes' necessary.)
VIGRA_IMPEX_EXTRA_C_FLAGS="-std=gnu90 -Wno-pedantic -Wno-long-long"

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
        -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DCMAKE_SHARED_LINKER_FLAGS="${VIGRA_LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${VIGRA_LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${VIGRA_CXX_FLAGS}" \
        -DCMAKE_CXX_FLAGS_RELEASE="${VIGRA_CXX_FLAGS_RELEASE}" \
        -DCMAKE_CXX_FLAGS_DEBUG="${VIGRA_CXX_FLAGS}" \
\
        -DWITH_VIGRANUMPY=TRUE \
        -DWITH_BOOST_THREAD=1 \
        -DVIGRA_IMPEX_EXTRA_C_FLAGS="${VIGRA_IMPEX_EXTRA_C_FLAGS}" \
        -DDEPENDENCY_SEARCH_PREFIX=${PREFIX} \
\
        -DFFTW3F_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3F_LIBRARY=${PREFIX}/lib/libfftw3f.${DYLIB_EXT} \
        -DFFTW3_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3_LIBRARY=${PREFIX}/lib/libfftw3.${DYLIB_EXT} \
\
        -DHDF5_CORE_LIBRARY=${PREFIX}/lib/libhdf5.${DYLIB_EXT} \
        -DHDF5_HL_LIBRARY=${PREFIX}/lib/libhdf5_hl.${DYLIB_EXT} \
        -DHDF5_INCLUDE_DIR=${PREFIX}/include \
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
        -DZLIB_INCLUDE_DIR=${PREFIX}/include \
        -DZLIB_LIBRARY=${PREFIX}/lib/libz.${DYLIB_EXT} \
\
        -DPNG_LIBRARY=${PREFIX}/lib/libpng.${DYLIB_EXT} \
        -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
\
        -DTIFF_LIBRARY=${PREFIX}/lib/libtiff.${DYLIB_EXT} \
        -DTIFF_INCLUDE_DIR=${PREFIX}/include \
\
        -DJPEG_INCLUDE_DIR=${PREFIX}/include \
        -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg.${DYLIB_EXT} \


# BUILD
make -j${CPU_COUNT}

# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    export ${LIBRARY_SEARCH_VAR}=$PREFIX/lib:${!LIBRARY_SEARCH_VAR}
    make -j${CPU_COUNT} check
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install

