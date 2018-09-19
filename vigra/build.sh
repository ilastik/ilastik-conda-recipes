# Conda automatically sets these with the -arch x86_64 flag, 
#  which is not recognized by cmake.
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export CC=clang
    export CXX=clang++
    VIGRA_CXX_FLAGS="-std=c++11 -stdlib=libc++ -I${PREFIX}/include" # I have no clue why this -I option is necessary on Mac.
    DYLIB_EXT=dylib
else
    export CC=gcc
    export CXX=g++
    VIGRA_CXX_FLAGS="-std=c++11 -pthread ${CXXFLAGS}"
    # enable compilation without CXX abi to stay compatible with gcc < 5 built packages
    if [[ ${DO_NOT_BUILD_WITH_CXX11_ABI} == '1' ]]; then
        VIGRA_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 ${VIGRA_CXX_FLAGS}"
    fi
    DYLIB_EXT=so
fi

PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
PY_ABIFLAGS=$(python -c "import sys; print('' if sys.version_info.major == 2 else sys.abiflags)")
PY_ABI=${PY_VER}${PY_ABIFLAGS}

# In release mode, we use -O2 because gcc is known to miscompile certain vigra functionality at the O3 level.
# (This is probably due to inappropriate use of undefined behavior in vigra itself.)
VIGRA_CXX_FLAGS_RELEASE="-O2 -DNDEBUG ${VIGRA_CXX_FLAGS}"
VIGRA_LDFLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"


# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_C_COMPILER=${CC} \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="10.9" \
\
        -DCMAKE_SHARED_LINKER_FLAGS="${VIGRA_LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${VIGRA_LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${VIGRA_CXX_FLAGS}" \
        -DCMAKE_CXX_FLAGS_RELEASE="${VIGRA_CXX_FLAGS_RELEASE}" \
        -DCMAKE_CXX_FLAGS_DEBUG="${VIGRA_CXX_FLAGS}" \
\
        -DWITH_VIGRANUMPY=TRUE \
        -DWITH_BOOST_THREAD=1 \
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
        -DBoost_PYTHON_LIBRARY=${PREFIX}/lib/libboost_python.${DYLIB_EXT} \
        -DBoost_PYTHON_LIBRARY_RELEASE=${PREFIX}/lib/libboost_python.${DYLIB_EXT} \
        -DBoost_PYTHON_LIBRARY_DEBUG=${PREFIX}/lib/libboost_python.${DYLIB_EXT} \
\
        -DWITH_LEMON=ON \
        -DLEMON_DIR=${PREFIX}/share/lemon/cmake \
        -DLEMON_INCLUDE_DIR=${PREFIX}/include \
        -DLEMON_LIBRARY=${PREFIX}/lib/libemon.${DYLIB_EXT} \
\
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_ABI}.${DYLIB_EXT} \
        -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_ABI} \
        -DPYTHON_NUMPY_INCLUDE_DIR=${SP_DIR}/numpy/core/include \
        -DPYTHON_SPHINX=${PREFIX}/bin/sphinx-build \
\
        -DVIGRANUMPY_LIBRARIES="${PREFIX}/lib/libpython${PY_ABI}.${DYLIB_EXT};${PREFIX}/lib/libboost_python.${DYLIB_EXT};${PREFIX}/lib/libboost_thread.${DYLIB_EXT};${PREFIX}/lib/libboost_system.${DYLIB_EXT}" \
        -DVIGRANUMPY_INSTALL_DIR=${SP_DIR} \
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
if [[ `uname` == 'Darwin' ]]; then
    make -j${CPU_COUNT} 2> >(python "${RECIPE_DIR}"/../build-utils/filter-macos-linker-warnings.py)
else
    make -j${CPU_COUNT}
fi

# TEST (before install)
(
    set -e
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    if [[ `uname` == 'Darwin' ]]; then
        export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib":"${DYLD_FALLBACK_LIBRARY_PATH}"
    else
        export LD_LIBRARY_PATH="$PREFIX/lib":"${LD_LIBRARY_PATH}"
    fi
    
    # Run the tests
    if [[ -z "$VIGRA_SKIP_TESTS" || "$VIGRA_SKIP_TESTS" == "0" ]]; then
        if [[ `uname` == "Darwin" ]]; then
            # pasted from conda-forge/vigra-feedstock:
            # Can't run tests due to a bug in the clang compiler provided with XCode.
            # For more details see here ( https://llvm.org/bugs/show_bug.cgi?id=21083 ).
            # Also, these tests are very intensive, which makes them challenging to run in CI.
            make -j${CPU_COUNT} check_python 2> >(python "${RECIPE_DIR}"/../build-utils/filter-macos-linker-warnings.py)
        else
            make -j${CPU_COUNT} check
        fi
    fi
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
