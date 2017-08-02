#!/bin/bash

if [ `uname` == Linux ]; then
    CC=gcc
    CXX=g++
    DYLIB_EXT=so
fi

if [ `uname` == Darwin ]; then
    CC=clang
    CXX=clang++
    CMAKE=$SYS_PREFIX/bin/cmake
    DYLIB_EXT=dylib
    CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
fi

mkdir build
cd build
cmake \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DCMAKE_INSTALL_RPATH:STRING="$PREFIX/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    \
    -DVTK_WRAP_PYTHON:BOOL=OFF \
    \
    -DVTK_USE_X:BOOL=OFF \
    -DVTK_USE_OFFSCREEN:BOOL=ON \
    \
    -DVTK_WRAP_PYTHON_SIP:BOOL=OFF \
    -DVTK_USE_QT:BOOL=ON \
    -DVTK_USE_QVTK_QTOPENGL:BOOL=ON \
    \
    -DVTK_USE_SYSTEM_LIBXML2=ON \
    -DLIBXML2_INCLUDE_DIR:PATH=${PREFIX}/include/libxml2 \
    -DLIBXML2_LIBRARIES:FILEPATH=${PREFIX}/lib/libxml2.${DYLIB_EXT} \
    \
    -DVTK_USE_SYSTEM_PNG=ON \
    -DPNG_PNG_INCLUDE_DIR=${PREFIX}/include \
    -DPNG_LIBRARY=${PREFIX}/lib/libpng.${DYLIB_EXT} \
    \
    -DVTK_USE_SYSTEM_JPEG=ON \
    -DJPEG_INCLUDE_DIR=${PREFIX}/include \
    -DJPEG_LIBRARY=${PREFIX}/lib/libjpeg.${DYLIB_EXT} \
    \
    -DVTK_USE_SYSTEM_TIFF=ON \
    -DTIFF_INCLUDE_DIR=${PREFIX}/include \
    -DTIFF_LIBRARY=${PREFIX}/lib/libtiff.${DYLIB_EXT} \
    \
    -DVTK_USE_SYSTEM_ZLIB=ON \
    -DZLIB_INCLUDE_DIR=${PREFIX}/include \
    -DZLIB_LIBRARY=${PREFIX}/lib/libz.${DYLIB_EXT} \
    ..

make -j${CPU_COUNT}
make install

if [ $(uname) == Linux ]; then
    mv $PREFIX/lib/vtk-5.10/lib* $PREFIX/lib
    sed -i 's|/lib/vtk-5.10/lib|/lib/lib|g' \
        $PREFIX/lib/vtk-5.10/VTKTargets-debug.cmake
fi

if [ $(uname) == Darwin ]; then
    # The osx.py script needs access to conda_build
    CONDA_ROOT_PYTHON=`conda info --root`/bin/python
    $CONDA_ROOT_PYTHON $RECIPE_DIR/osx.py
fi
