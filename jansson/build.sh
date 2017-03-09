# This package is intended for FlyEM's NeuTu tool, which doesn't need a shared lib
./configure --enable-shared=no --with-pic --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
