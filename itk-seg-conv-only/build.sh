if [[ $(uname) == Darwin ]]; then
    DYLIB_EXT=dylib
    CC=clang
    CXX=clang++
    CXXFLAGS='-stdlib=libc++'
else
    DYLIB_EXT=so
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++
fi

ITK_LDFLAGS="${CXX_LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

mkdir build
cd build
cmake .. \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="10.9" \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_SHARED_LINKER_FLAGS="${ITK_LDFLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${ITK_LDFLAGS}" \
    -DCMAKE_CXX_FLAGS="-I${PREFIX}/include ${CXXFLAGS}" \
    -DCMAKE_C_FLAGS=-I${PREFIX}/include \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DITK_BUILD_DEFAULT_MODULES=0 \
    -DBUILD_EXAMPLES=0 \
    -DITKGroup_Core=1 \
    -DITKGroup_Segmentation=1 \
    -DModule_ITKConvolution=1 \
    -DModule_ITKEigen=1 \
    -DPYTHON_EXECUTABLE=${PREFIX}/bin/python \
    -DBUILD_TESTING=ON \
    \
    -DITK_USE_SYSTEM_HDF5=ON \
    -DHDF5_C_LIBRARY=${PREFIX}/lib/libhdf5.${DYLIB_EXT} \
    -DHDF5_DIR=${PREFIX}/share/cmake/hdf5 \
    \
    -DITK_USE_SYSTEM_PNG=ON \
    -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
    -DPNG_LIBRARY=${PREFIX}/lib/libpng.${DYLIB_EXT} \
    \
    -DITK_USE_SYSTEM_JPEG=ON \
    -DJPEG_INCLUDE_DIR=${PREFIX}/include \
    -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg.${DYLIB_EXT} \
    \
    -DITK_USE_SYSTEM_TIFF=ON \
    -DTIFF_INCLUDE_DIR=${PREFIX}/include \
    -DTIFF_LIBRARY=${PREFIX}/lib/libtiff.${DYLIB_EXT} \
    \
    -DITK_USE_SYSTEM_ZLIB=ON \
    -DZLIB_INCLUDE_DIR=${PREFIX}/include \
    -DZLIB_LIBRARY=${PREFIX}/lib/libz.${DYLIB_EXT} \
##

# BUILD
make -j${CPU_COUNT}

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
    make -j${CPU_COUNT} test
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install
    