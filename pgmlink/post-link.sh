if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    set +x
    echo "******************************************"
    echo "* You must define CPLEX_ROOT_DIR in your *"
    echo "* environment before installing pgmlink. *"
    echo "******************************************"
    exit 1
fi

CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/*/static_pic`
CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/*/static_pic`

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
    patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/.' ${PREFIX}/lib/libpgmlink.so
    patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/../..' ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    set +x
fi