mkdir build
cd build

# Notes:
# 
# 1) Lemon can be optionally built with glpk to enable the LP solver.
#    We don't want to build with glpk because it isn't needed for the 
#    downstream package we're interested in: cylemon.
#    We kill these cache variables to make sure we don't use it
#    (avoid potential linker errors if cmake finds a version of glpk on our system)
#
# 2) Be sure to pass c++ and link flags on from the environment via CMAKE_CXX_...
 
echo CXX_LDFLAGS=$CXX_LDFLAGS

cmake .. \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DGLPK_LIBRARY= \
    -DGLPK_INCLUDE_DIR= \
    -DGLPK_ROOT_DIR= \

#    -DCMAKE_CXX_FLAGS="${CXXFLAGS}"
#    -DCMAKE_CXX_LINKER_FLAGS="${CXX_LDFLAGS}"

VERBOSE=1 make -j${CPU_COUNT}

# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    if [[ `uname` == 'Darwin' ]]; then
        export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib":"${DYLD_FALLBACK_LIBRARY_PATH}"
    else
        export LD_LIBRARY_PATH="$PREFIX/lib":"${LD_LIBRARY_PATH}"
    fi
    
    # Run the tests
    make -j${CPU_COUNT} check
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
