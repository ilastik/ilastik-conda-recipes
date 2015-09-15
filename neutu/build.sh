if [ `uname` == 'Darwin' ]; then
    # Unfortunately, this package must be built with clang, not conda's gcc
    CC=/usr/bin/cc
    CXX=/usr/bin/c++
fi

if [ `uname` == 'Darwin' ]; then
    QMAKE_SPEC_PATH=${PREFIX}/mkspecs/macx-g++
else
    QMAKE_SPEC_PATH=${PREFIX}/mkspecs/linux-g++-64
fi

bash build.sh ${PREFIX}/bin/qmake ${QMAKE_SPEC_PATH} -e flyem

# Install to conda environment
if [ `uname` == 'Darwin' ]; then
    mv neurolabi/build/neuTube.app ${PREFIX}/bin/
else
    mv neurolabi/build/neuTube ${PREFIX}/bin/
fi
