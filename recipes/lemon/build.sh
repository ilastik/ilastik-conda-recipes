# Notes:
# 
# 1) Lemon can be optionally built with glpk to enable the LP solver.
#    We don't want to build with glpk because it isn't needed for the 
#    downstream package we're interested in: vigra.
#    We kill these cache variables to make sure we don't use it
#    (avoid potential linker errors if cmake finds a version of glpk on our system)
#
# 2) As of XCode 7, the clang-based assembler seems to have trouble with some source 
#    files in the lemon/tools directory.  We don't need the tools, so we simply don't build them.
#    
#    The errors look like this:
#        /var/tmp//ccuWS4ad.s:29837:2: error: ambiguous instructions require an explicit suffix (could be 'filds', or 'fildl')
#            fild    -10(%rsp)
#            ^
#
#    For more information, see https://gcc.gnu.org/bugzilla/show_bug.cgi?format=multiple&id=66509


if [[ `uname` == 'Darwin' ]]; then
    LEMON_CXX_FLAGS="${CXXFLAGS}"
    # Pursuant to Item 2 above, replace the tools/CMakeLists.txt with an empty file.
    echo "" > tools/CMakeLists.txt
else
    LEMON_CXX_FLAGS="${CXXFLAGS}"
fi

mkdir build
cd build

echo CXX_LDFLAGS=$CXX_LDFLAGS

cmake .. \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DGLPK_LIBRARY= \
    -DGLPK_INCLUDE_DIR= \
    -DGLPK_ROOT_DIR= \
    -DCMAKE_CXX_FLAGS="${LEMON_CXX_FLAGS}" \
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
