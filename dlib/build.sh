mkdir build
cd build

DYLIB_EXT=so
if [[ `uname` == "Darwin" ]]; then
    if [ ! -d /usr/X11/include ]; then
        echo "You must install X11 on your machine before building dlib." && exit 1    
    fi

    DYLIB_EXT=dylib
    
    # On Mac, x11 files are found in /usr/X11
    X11_OPTIONS="-Dx11_path=/usr/X11/include -Dxlib=/usr/X11/lib/libX11.dylib -Dxlib_path=/usr/X11/include/X11/"
fi

# Note: At the moment, the dlib CMakeLists.txt only supports creating a static library.
cmake ../dlib \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DPNG_LIBRARY=${PREFIX}/lib/libpng.${DYLIB_EXT} \
    -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
    -DJPEG_INCLUDE_DIR=${PREFIX}/include \
    -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg.${DYLIB_EXT} \
    ${X11_OPTIONS} \
##

make -j${CPU_COUNT}
make install
