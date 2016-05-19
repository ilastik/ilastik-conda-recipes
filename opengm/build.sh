
if [[ "$WITH_CPLEX" == "" ]]; then
    CPLEX_ARGS=""
    LINKER_FLAGS=""
else
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
	    echo "* environment before building opengm.   *"
	    echo "******************************************"
	    exit 1
	fi

    CPLEX_BIN_DIR=`echo $CPLEX_ROOT_DIR/cplex/bin/x86-64*`
    CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/x86-64*/static_pic`
    CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/x86-64*/static_pic`
        
    if [ `uname` == "Darwin" ]; then
        export DYLIB="dylib"
    else
        export DYLIB="so"
    fi
	
    #LINKER_FLAGS="-L${PREFIX}/lib -L${CPLEX_LIB_DIR} -L${CONCERT_LIB_DIR}"
    #if [ `uname` != "Darwin" ]; then
    #    LINKER_FLAGS="-Wl,-rpath-link,${PREFIX}/lib ${LINKER_FLAGS}"
    #fi

    CPLEX_LIBRARY=${CPLEX_LIB_DIR}/libcplex.${DYLIB}
	CPLEX_ILOCPLEX_LIBRARY=${CPLEX_LIB_DIR}/libilocplex.${DYLIB}
	CPLEX_CONCERT_LIBRARY=${CONCERT_LIB_DIR}/libconcert.${DYLIB}
	
	set +e
	(
	    set -e
	    # Verify the existence of the cplex dylibs.
	    ls ${CPLEX_LIBRARY}
	    ls ${CPLEX_ILOCPLEX_LIBRARY}
	    ls ${CPLEX_CONCERT_LIBRARY}
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

    echo "Building with CPLEX from: ${CPLEX_ROOT_DIR}"
    
    CPLEX_ARGS="-DWITH_CPLEX=ON -DCPLEX_ROOT_DIR=${CPLEX_ROOT_DIR}"
    
    # For some reason, CMake can't find these cache variables on even though we give it CPLEX_ROOT_DIR
    # So here we provide the library paths explicitly
	CPLEX_ARGS="${CPLEX_ARGS} -DCPLEX_LIBRARY=${CPLEX_LIBRARY}"
	CPLEX_ARGS="${CPLEX_ARGS} -DCPLEX_ILOCPLEX_LIBRARY=${CPLEX_ILOCPLEX_LIBRARY}"
	CPLEX_ARGS="${CPLEX_ARGS} -DCPLEX_CONCERT_LIBRARY=${CPLEX_CONCERT_LIBRARY}"
    CPLEX_ARGS="${CPLEX_ARGS} -DCPLEX_BIN_DIR=${CPLEX_CONCERT_LIBRARY}"
fi

mkdir build
cd build
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

cmake .. \
        -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
        -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS}" \
        -DCMAKE_CXX_FLAGS_DEBUG="${CXXFLAGS}" \
\
        -DBUILD_PYTHON_WRAPPER=ON \
        -DBUILD_TESTING=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_COMMANDLINE=OFF \
\
        -DWITH_VIGRA=ON \
        -DWITH_BOOST=ON \
        -DWITH_HDF5=ON \
\
        ${CPLEX_ARGS} \
##

make -j${CPU_COUNT}
make install
