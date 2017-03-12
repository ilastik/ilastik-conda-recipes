mkdir build && cd build
cmake ..\
        -DCMAKE_C_COMPILER="${PREFIX}/bin/gcc" \
        -DCMAKE_CXX_COMPILER="${PREFIX}/bin/g++" \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_CXX_FLAGS=-I"${PREFIX}/include" \
        -Dgoogleapis_build_samples=OFF \
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \
        -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib" \

make -j${CPU_COUNT} all

# manual install
pwd
make install
cp -r include/* ${PREFIX}/include/
cp -r lib/* ${PREFIX}/lib/
cp -r bin/* ${PREFIX}/bin/

