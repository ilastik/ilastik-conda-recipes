# Always write to the root prefix, even if a different env is active.
if [ $(echo $PREFIX | grep -q envs)$? -eq 0 ]; then
    ROOT_ENV_PREFIX="${PREFIX}/../.."
else
    ROOT_ENV_PREFIX="${PREFIX}"
fi
CPLEX_LOCATION_CACHE_FILE="${ROOT_ENV_PREFIX}/share/cplex-root-dir.path"


if [ "$CPLEX_ROOT_DIR" == "" ]; then 
    CPLEX_ROOT_DIR="<UNDEFINED>"
fi

if [ "$CPLEX_ROOT_DIR" != "<UNDEFINED>" ]; then
    # If the environment-provided CPLEX_ROOT_DIR doesn't match the 
    #  cache-provided value, (over)write the cache file.
    SAVED_CPLEX_ROOT_DIR=`cat ${CPLEX_LOCATION_CACHE_FILE} 2> /dev/null` \
    || SAVED_CPLEX_ROOT_DIR="<UNDEFINED>"
    if [ "$SAVED_CPLEX_ROOT_DIR" != "$CPLEX_ROOT_DIR" ]; then
	echo "${CPLEX_ROOT_DIR}" > ${CPLEX_LOCATION_CACHE_FILE}
    fi
fi 

if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    # If we've installed at least once on this machine, 
    # then we can get CPLEX_ROOT_DIR from our the cache file.
    CPLEX_ROOT_DIR=`cat ${CPLEX_LOCATION_CACHE_FILE} 2> /dev/null` \
    || CPLEX_ROOT_DIR="<UNDEFINED>"
fi

if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    set +x
    echo "******************************************************"
    echo "* You must define CPLEX_ROOT_DIR in your environment *"
    echo "* before using cplex-shared for the first time.      *"
    echo "******************************************************"
    exit 1
fi

CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/x86-64*/static_pic`
CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/x86-64*/static_pic`

# Check for write permissions in the CPLEX dir (we need to write to it).
(
    set -e
    touch $CPLEX_LIB_DIR/testpermissions.empty.txt
    rm $CPLEX_LIB_DIR/testpermissions.empty.txt
    touch $CONCERT_LIB_DIR/testpermissions.empty.txt
    rm $CONCERT_LIB_DIR/testpermissions.empty.txt
)

if [ $? -ne 0 ]; then
    set +x
    echo "************************************************************"
    echo "* Could not create cplex-shared libraries.                 *"
    echo "* CPLEX_ROOT_DIR is not writable.                          *"
    echo "* Check the location and/or permissions of CPLEX_ROOT_DIR: *"
    echo "* ${CPLEX_ROOT_DIR}                                        *"
    echo "************************************************************"
    exit 1
fi

set -x
# Create a shared library from each static library.
if [ `uname` == "Darwin" ]; then
    EXISTING_SHARED_OBJECT=`ls ${CPLEX_LIB_DIR}/libilocplex.dylib` \
    || EXISTING_SHARED_OBJECT="NOT_PRESENT"
    if [ "$EXISTING_SHARED_OBJECT" == "NOT_PRESENT" ]; then
        ${PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CPLEX_LIB_DIR}/libcplex.a     -Wl,-noall_load -o ${CPLEX_LIB_DIR}/libcplex.dylib
        ${PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CONCERT_LIB_DIR}/libconcert.a -Wl,-noall_load -o ${CONCERT_LIB_DIR}/libconcert.dylib
        ${PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CPLEX_LIB_DIR}/libilocplex.a  -Wl,-noall_load \
            -L${CPLEX_LIB_DIR} -L${CONCERT_LIB_DIR} -lcplex -lconcert -o ${CPLEX_LIB_DIR}/libilocplex.dylib
    fi
else
    EXISTING_SHARED_OBJECT=`ls ${CPLEX_LIB_DIR}/libilocplex.so` \
    || EXISTING_SHARED_OBJECT="NOT_PRESENT"
    if [ "$EXISTING_SHARED_OBJECT" == "NOT_PRESENT" ]; then
    ${PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CPLEX_LIB_DIR}/libcplex.a     -Wl,-no-whole-archive -o ${CPLEX_LIB_DIR}/libcplex.so
    ${PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CONCERT_LIB_DIR}/libconcert.a -Wl,-no-whole-archive -o ${CONCERT_LIB_DIR}/libconcert.so
    ${PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CPLEX_LIB_DIR}/libilocplex.a  -Wl,-no-whole-archive -o ${CPLEX_LIB_DIR}/libilocplex.so
    fi
fi

# Now symlink the cplex libraries into the lib directory
(
    mkdir -p ${PREFIX}/lib
    if [ $(uname) == "Darwin" ]; then
            cd ${PREFIX}/lib
	        ln -f -s ${CPLEX_LIB_DIR}/libcplex.dylib
            ln -f -s ${CONCERT_LIB_DIR}/libconcert.dylib
            ln -f -s ${CPLEX_LIB_DIR}/libilocplex.dylib
	else
	        cd ${PREFIX}/lib
	        ln -f -s ${CPLEX_LIB_DIR}/libcplex.so
	        ln -f -s ${CONCERT_LIB_DIR}/libconcert.so
	        ln -f -s ${CPLEX_LIB_DIR}/libilocplex.so
	fi
)
