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
    echo "* environment before installing pgmlink. *"
    echo "******************************************"
    exit 1
fi

CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/x86-64*/static_pic`
CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/x86-64*/static_pic`

if [ `uname` == Darwin ]; then
    set -x
    install_name_tool -add_rpath ${CPLEX_LIB_DIR} "${PREFIX}/lib/libpgmlink.dylib"
    install_name_tool -add_rpath ${CONCERT_LIB_DIR} "${PREFIX}/lib/libpgmlink.dylib"
    install_name_tool -add_rpath @loader_path/./ "${PREFIX}/lib/libpgmlink.dylib"

    install_name_tool -add_rpath ${CPLEX_LIB_DIR}  "${PREFIX}/lib/python2.7/site-packages/pgmlink.so"
    install_name_tool -add_rpath ${CONCERT_LIB_DIR} "${PREFIX}/lib/python2.7/site-packages/pgmlink.so"
    install_name_tool -add_rpath @loader_path/../.. "${PREFIX}/lib/python2.7/site-packages/pgmlink.so"
    set +x
else
    set -x
    ${PREFIX}/bin/patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/.' ${PREFIX}/lib/libpgmlink.so
    ${PREFIX}/bin/patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/../..' ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    set +x
fi
