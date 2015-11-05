# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

BUILD_DIR=${BUILD_DIR-build}

CONFIGURE_ONLY=0
if [[ $1 != "" ]]; then
    if [[ $1 == "--configure-only" ]]; then
        CONFIGURE_ONLY=1
    else
        echo "Unknown argument: $1"
        exit 1
    fi
fi

# CONFIGURE
mkdir -p "${BUILD_DIR}" # Using -p here is convenient for calling this script outside of conda.
cd "${BUILD_DIR}"
cmake ..\
        -DCMAKE_C_COMPILER="${PREFIX}/bin/gcc" \
        -DCMAKE_CXX_COMPILER="${PREFIX}/bin/g++" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_FLAGS=-I"${PREFIX}/include" \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DBoost_LIBRARY_DIR="${PREFIX}/lib" \
        -DBoost_INCLUDE_DIR="${PREFIX}/include" \
        -DPYTHON_EXECUTABLE="${PYTHON}" \
        -DPYTHON_LIBRARY="${PREFIX}/lib/libpython2.7.${DYLIB_EXT}" \
        -DPYTHON_INCLUDE_DIR="${PREFIX}/include/python2.7" \
        -DLIBDVID_WRAP_PYTHON=1 \
##

if [[ $CONFIGURE_ONLY == 0 ]]; then
    # BUILD
    make -j${CPU_COUNT}

    # "install" to the build prefix (conda will relocate these files afterwards)
    make install
    
    # For debug builds, this symlink can be useful...
    #cd ${PREFIX}/lib && ln -s libdvidcpp-g.${DYLIB_EXT} libdvidcpp.${DYLIB_EXT} && cd -
fi
