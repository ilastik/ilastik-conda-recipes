if [ $(echo $PREFIX | grep -q envs)$? -eq 0 ]; then
    ROOT_ENV_PREFIX="${PREFIX}/../.."
else
    ROOT_ENV_PREFIX="${PREFIX}"
fi
CPLEX_LOCATION_CACHE_FILE="${ROOT_ENV_PREFIX}/share/cplex-root-dir.path"

if [[ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" || "$CPLEX_ROOT_DIR" == "" ]]; then
    # Look for CPLEX_ROOT_DIR in the cplex-shared cache file.
    CPLEX_ROOT_DIR=`cat ${CPLEX_LOCATION_CACHE_FILE} 2> /dev/null` \
    || CPLEX_ROOT_DIR="<UNDEFINED>"
fi

if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    set +x
    echo "******************************************"
    echo "* You must define CPLEX_ROOT_DIR in your *"
    echo "* environment before building pgmlink.   *"
    echo "******************************************"
    exit 1
fi

CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/x86-64*/static_pic`
CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/x86-64*/static_pic`

LINKER_FLAGS="-L${PREFIX}/lib"
export DYLIB="dylib"
if [ `uname` != "Darwin" ]; then
    LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib ${LINKER_FLAGS}"
    export DYLIB="so"
fi

set +e
(
    set -e
    # Verify the existence of the cplex dylibs.
    ls ${CPLEX_LIB_DIR}/libcplex.${DYLIB}
    ls ${CPLEX_LIB_DIR}/libilocplex.${DYLIB}
    ls ${CONCERT_LIB_DIR}/libconcert.${DYLIB}
)
if [ $? -ne 0 ]; then
    set +x
    echo "************************************************"
    echo "* Your CPLEX installation does not include     *" 
    echo "* the necessary shared libraries.              *"
    echo "*                                              *"
    echo "* Please install the 'cplex-shared' package:   *"
    echo "*                                              *"
    echo "*     $ conda install cplex-shared             *"
    echo "*                                              *"
    echo "* (You only need to do this once per machine.) *"
    echo "************************************************"
    exit 1
fi
set -e


CFLAGS=""
CXXFLAGS=""
LDFLAGS=""

mkdir build
cd build
cmake ..\
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
    -DCMAKE_INSTALL_PREFIX=${PREFIX}\
    -DCMAKE_PREFIX_PATH=${PREFIX}\
    -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}" \
    -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
    -DBUILD_SHARED_LIBS=ON\
    -DWITH_PYTHON=ON\
    -DPYTHON_EXECUTABLE=${PYTHON} \
    -DPYTHON_LIBRARY=${PREFIX}/lib/libpython2.7.${DYLIB} \
    -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python2.7 \
    -DPYTHON_INCLUDE_DIR2=${PREFIX}/include/python2.7 \
    -DPYPGMLINK_INSTALL_DIR=${PREFIX}/lib/python2.7/site-packages \
    -DVIGRA_INCLUDE_DIR=${PREFIX}/include \
    -DVIGRA_IMPEX_LIBRARY=${PREFIX}/lib/libvigraimpex.${DYLIB} \
    -DVIGRA_NUMPY_CORE_LIBRARY=${PREFIX}/lib/python2.7/site-packages/vigra/vigranumpycore.so \
    -DWITH_CHECKED_STL=OFF\
    -DWITH_TESTS=ON\
    -DWITH_FUNKEY=OFF\
    -DWITH_DPCT=OFF\
    -DXml2_INCLUDE_DIR=${PREFIX}/include/libxml2 \
    -DCPLEX_ROOT_DIR="${CPLEX_ROOT_DIR}"

make -j${CPU_COUNT}
make install

if [ `uname` == "Darwin" ]; then
    # Set install names according using @rpath, which will be configured via the post-link script.
    install_name_tool -change ${CPLEX_LIB_DIR}/libcplex.dylib @rpath/libcplex.dylib ${PREFIX}/lib/libpgmlink.dylib
    install_name_tool -change ${CPLEX_LIB_DIR}/libilocplex.dylib @rpath/libilocplex.dylib ${PREFIX}/lib/libpgmlink.dylib
    install_name_tool -change ${CONCERT_LIB_DIR}/libconcert.dylib @rpath/libconcert.dylib ${PREFIX}/lib/libpgmlink.dylib

    install_name_tool -change ${CPLEX_LIB_DIR}/libcplex.dylib @rpath/libcplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    install_name_tool -change ${CPLEX_LIB_DIR}/libilocplex.dylib @rpath/libilocplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    install_name_tool -change ${CONCERT_LIB_DIR}/libconcert.dylib @rpath/libconcert.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
fi
