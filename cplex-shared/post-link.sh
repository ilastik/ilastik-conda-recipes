set -e
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

# Apparently conda sets these varibles to 'None', which can cause 
# problems if we run a second instance of conda here.
unset CONDA_NPY
unset CONDA_PY

# If necessary, create a shared library from each static library.
# Note: To avoid installing gcc into the user's environment every time this is created,
#       we don't include gcc as a run dependency.
#       Instead, we create a temporary environment right here and install gcc into it.
if [ $(uname) == "Darwin" ]; then
    EXISTING_SHARED_OBJECT=`ls ${CPLEX_LIB_DIR}/libilocplex.dylib` \
    || EXISTING_SHARED_OBJECT="NOT_PRESENT"
    if [ "$EXISTING_SHARED_OBJECT" == "NOT_PRESENT" ]; then

        # This is slightly dangerous, but apparently conda doesn't want
        # to recursively call itself if we don't remove the locks.
        conda clean --lock

        # Install gcc to a temporary environment
        conda remove -y --all -n _cplex_shared_gcc_throwaway 2> /dev/null || true
        conda create -y -n _cplex_shared_gcc_throwaway gcc=4.8.5
        GCC_ENV_PREFIX=$(conda info --root)/envs/_cplex_shared_gcc_throwaway

        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CPLEX_LIB_DIR}/libcplex.a     -Wl,-noall_load -o ${CPLEX_LIB_DIR}/libcplex.dylib
        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CONCERT_LIB_DIR}/libconcert.a -Wl,-noall_load -o ${CONCERT_LIB_DIR}/libconcert.dylib
        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-all_load ${CPLEX_LIB_DIR}/libilocplex.a  -Wl,-noall_load \
            -L${CPLEX_LIB_DIR} -L${CONCERT_LIB_DIR} -lcplex -lconcert -o ${CPLEX_LIB_DIR}/libilocplex.dylib
        
        # Fix abs links to libgcc_s -> Use @rpath
        # Note: Even though no LC_RPATH command exists within these dylibs,
        # The Mac loader searches the RPATH for *all* dylibs in the loader dependency chain.
        # Hence, as long as libopengm.dylib (or whatever) has an LC_RPATH, then we can use @rpath here.
        install_name_tool -change ${GCC_ENV_PREFIX}/lib/libgcc_s.1.dylib @rpath/libgcc_s.1.dylib ${CPLEX_LIB_DIR}/libcplex.dylib
        install_name_tool -change ${GCC_ENV_PREFIX}/lib/libgcc_s.1.dylib @rpath/libgcc_s.1.dylib ${CONCERT_LIB_DIR}/libconcert.dylib
        install_name_tool -change ${GCC_ENV_PREFIX}/lib/libgcc_s.1.dylib @rpath/libgcc_s.1.dylib ${CPLEX_LIB_DIR}/libilocplex.dylib
                        
        conda remove -y --all -n _cplex_shared_gcc_throwaway
    fi
else
    EXISTING_SHARED_OBJECT=`ls ${CPLEX_LIB_DIR}/libilocplex.so` \
    || EXISTING_SHARED_OBJECT="NOT_PRESENT"
    if [ "$EXISTING_SHARED_OBJECT" == "NOT_PRESENT" ]; then

        # This is slightly dangerous, but apparently conda doesn't want
        # to recursively call itself if we don't remove the locks.
        conda clean --lock
        
        # Install gcc to a temporary environment
        conda remove -y --all -n _cplex_shared_gcc_throwaway 2> /dev/null || true
        conda create -y -n _cplex_shared_gcc_throwaway gcc=4.8.5
        GCC_ENV_PREFIX=$(conda info --root)/envs/_cplex_shared_gcc_throwaway

        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CPLEX_LIB_DIR}/libcplex.a     -Wl,-no-whole-archive -o ${CPLEX_LIB_DIR}/libcplex.so
        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CONCERT_LIB_DIR}/libconcert.a -Wl,-no-whole-archive -o ${CONCERT_LIB_DIR}/libconcert.so
        ${GCC_ENV_PREFIX}/bin/g++ -fpic -shared -Wl,-whole-archive ${CPLEX_LIB_DIR}/libilocplex.a  -Wl,-no-whole-archive -o ${CPLEX_LIB_DIR}/libilocplex.so
    
        conda remove -y --all -n _cplex_shared_gcc_throwaway
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
