# Conda automatically sets these with the -arch x86_64 flag, 
#  which is not recognized by cmake.
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

if [[ `uname` == 'Darwin' ]]; then
    VIGRA_CXX_FLAGS="-std=c++11 -stdlib=libc++ -I${PREFIX}/include" # I have no clue why this -I option is necessary on Mac.
else
    VIGRA_CXX_FLAGS="-std=c++11 -pthread ${CXXFLAGS}"
fi

# In release mode, we use -O2 because gcc is known to miscompile certain vigra functionality at the O3 level.
# (This is probably due to inappropriate use of undefined behavior in vigra itself.)
VIGRA_CXX_FLAGS_RELEASE="-O2 -DNDEBUG ${VIGRA_CXX_FLAGS}"
VIGRA_LDFLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"


# CONFIGURE
mkdir build
cd build
cmake ..\
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
        -DFFTW3F_LIBRARY=${PREFIX}/lib/libfftw3f${SHLIB_EXT} \
        -DFFTW3_INCLUDE_DIR=${PREFIX}/include \
        -DFFTW3_LIBRARY=${PREFIX}/lib/libfftw3${SHLIB_EXT} \
\
        -DHDF5_CORE_LIBRARY=${PREFIX}/lib/libhdf5${SHLIB_EXT} \
        -DHDF5_HL_LIBRARY=${PREFIX}/lib/libhdf5_hl${SHLIB_EXT} \
        -DHDF5_INCLUDE_DIR=${PREFIX}/include \
\
        -DBoost_INCLUDE_DIR=${PREFIX}/include \
        -DBoost_LIBRARY_DIRS=${PREFIX}/lib \
        -DBoost_PYTHON_LIBRARY=${PREFIX}/lib/libboost_python${CONDA_PY}${SHLIB_EXT} \
\
        -DWITH_LEMON=ON \
        -DLEMON_DIR=${PREFIX}/share/lemon/cmake \
        -DLEMON_INCLUDE_DIR=${PREFIX}/include \
        -DLEMON_LIBRARY=${PREFIX}/lib/libemon${SHLIB_EXT} \
\
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${CONDA_PY}${SHLIB_EXT} \
        -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${CONDA_PY} \
        -DPYTHON_NUMPY_INCLUDE_DIR=${SP_DIR}/numpy/core/include \
        -DPYTHON_SPHINX=${PREFIX}/bin/sphinx-build \
\
        -DVIGRANUMPY_LIBRARIES="${PREFIX}/lib/libpython${CONDA_PY}${SHLIB_EXT};${PREFIX}/lib/libboost_python${CONDA_PY}${SHLIB_EXT};${PREFIX}/lib/libboost_thread${SHLIB_EXT};${PREFIX}/lib/libboost_system${SHLIB_EXT}" \
        -DVIGRANUMPY_INSTALL_DIR=${SP_DIR} \
\
        -DZLIB_INCLUDE_DIR=${PREFIX}/include \
        -DZLIB_LIBRARY=${PREFIX}/lib/libz${SHLIB_EXT} \
\
        -DPNG_LIBRARY=${PREFIX}/lib/libpng${SHLIB_EXT} \
        -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
\
        -DTIFF_LIBRARY=${PREFIX}/lib/libtiff${SHLIB_EXT} \
        -DTIFF_INCLUDE_DIR=${PREFIX}/include \
\
        -DJPEG_INCLUDE_DIR=${PREFIX}/include \
        -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg${SHLIB_EXT} \

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
