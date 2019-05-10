# This "test" just checks for the existence of the shared libraries craeted in the post-link step.
CPLEX_LOCATION_CACHE_FILE="$(conda info --root)/share/cplex-root-dir.path"
CPLEX_ROOT_DIR=`cat ${CPLEX_LOCATION_CACHE_FILE}`
CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/x86-64*/static_pic`
CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/x86-64*/static_pic`

if [ `uname` == "Darwin" ]; then
    ls ${CPLEX_LIB_DIR}/libcplex.dylib
    ls ${CPLEX_LIB_DIR}/libilocplex.dylib
    ls ${CONCERT_LIB_DIR}/libconcert.dylib
else
    ls ${CPLEX_LIB_DIR}/libcplex.so
    ls ${CPLEX_LIB_DIR}/libilocplex.so
    ls ${CONCERT_LIB_DIR}/libconcert.so
fi
