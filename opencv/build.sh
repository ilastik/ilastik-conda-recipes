# some hacks to get build working

# no sense building troublesome gui module
# (no flags available so no cmakefile = no build)
rm -rf ./modules/highgui # objective c dependency
rm -rf ./modules/superres # could probably fix

# CONFIGURE
mkdir build
cd build
cmake ..\
        -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
        -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DWITH_OPENMP=ON \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
        -DCMAKE_CXX_FLAGS=-I${PREFIX}/include \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \

# BUILD
make -j${CPU_COUNT}

# "install" to the build prefix (conda will relocate these files afterwards)
make install
