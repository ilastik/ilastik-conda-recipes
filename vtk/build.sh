#!/bin/bash

if [ `uname` == Linux ]; then
    CC=${PREFIX}/bin/gcc
    CXX=${PREFIX}/bin/g++
    PY_LIB="libpython2.7.so"
fi

# Unfortunately, the VTK package can only be built with clang.
if [ `uname` == Darwin ]; then
    CC=/usr/bin/cc
    CXX=/usr/bin/c++
    CMAKE=$SYS_PREFIX/bin/cmake
    PY_LIB="libpython2.7.dylib"
    export DYLD_LIBRARY_PATH=$PREFIX/lib
    CXXFLAGS="-stdlib=libstdc++ $CXXFLAGS"
fi

mkdir build
cd build
cmake \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_C_FLAGS="-gdwarf-2 -gstrict-dwarf" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DCMAKE_INSTALL_RPATH:STRING="$PREFIX/lib" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,/${PREFIX}/lib -L${PREFIX}/lib" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/${PREFIX}/lib -L${PREFIX}/lib" \
    -DVTK_HAS_FEENABLEEXCEPT:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DBUILD_EXAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
    -DPYTHON_INCLUDE_PATH:PATH=${PREFIX}/include/python2.7 \
    -DPYTHON_LIBRARY:FILEPATH=${PREFIX}/lib/${PY_LIB} \
    -DVTK_USE_X:BOOL=OFF \
    -DVTK_WRAP_PYTHON:BOOL=ON \
    -DVTK_USE_OFFSCREEN:BOOL=ON \
    -DVTK_WRAP_PYTHON_SIP:BOOL=ON \
    -DSIP_EXECUTABLE:FILEPATH=${PREFIX}/bin/sip \
    -DSIP_INCLUDE_DIR:PATH=${PREFIX}/include/python2.7 \
    -DSIP_PYQT_DIR:PATH=${PREFIX}/share/sip/PyQt4 \
    -DVTK_USE_QT:BOOL=ON \
    -DVTK_USE_QVTK_QTOPENGL:BOOL=ON \
    ..

make -j${CPU_COUNT}
make install

if [ `uname` == Linux ]; then
    mv $PREFIX/lib/vtk-5.10/lib* $PREFIX/lib
    sed -i 's|/lib/vtk-5.10/lib|/lib/lib|g' \
        $PREFIX/lib/vtk-5.10/VTKTargets-debug.cmake
fi
if [ `uname` == Darwin ]; then
    $SYS_PYTHON $RECIPE_DIR/osx.py
fi
