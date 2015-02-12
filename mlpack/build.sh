mkdir build
cd build
cmake .. -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 -DCMAKE_INSTALL_PREFIX=${PREFIX} -DLIBXML2_INCLUDE_DIR=${PREFIX}/include/libxml2
make -j${CPU_COUNT}
make install