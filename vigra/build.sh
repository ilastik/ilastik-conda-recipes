#!/bin/bash
EXTRA_CMAKE_ARGS=""
if [[ `uname` == 'Darwin' ]];
then
    EXTRA_CMAKE_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}"
    export LDFLAGS="-undefined dynamic_lookup ${LDFLAGS}"
else
    export CXXFLAGS="-pthread ${CXXFLAGS}"
fi

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DCMAKE_CXX_LINK_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXX_FLAGS}" \
\
        -DCMAKE_BUILD_TYPE=Release \
\
        -DTEST_VIGRANUMPY=1 \
\
        -DAUTOEXEC_TESTS=0 \
\
        -DDEPENDENCY_SEARCH_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DWITH_LEMON=1 \
        -DLEMON_LIBRARY=${PREFIX}/lib/libemon${SHLIB_EXT} \
\

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
            make -j${CPU_COUNT} ctest
        fi
    fi
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
