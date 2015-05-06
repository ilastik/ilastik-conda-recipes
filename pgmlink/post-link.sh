if [ "$CPLEX_ROOT_DIR" == "<UNDEFINED>" ]; then
    set +x
    echo "******************************************"
    echo "* You must define CPLEX_ROOT_DIR in your *"
    echo "* environment before installing pgmlink. *"
    echo "******************************************"
    exit 1
fi

if [ `uname` == Darwin ]; then
    set -x
    install_name_tool -change ${CPLEX_ROOT_DIR}/cplex/lib/x86-64_osx/static_pic/libcplex.dylib @loader_path/./libcplex.dylib ${PREFIX}/lib/libpgmlink.dylib
    install_name_tool -change ${CPLEX_ROOT_DIR}/cplex/lib/x86-64_osx/static_pic/libilocplex.dylib @loader_path/./libilocplex.dylib ${PREFIX}/lib/libpgmlink.dylib
    install_name_tool -change ${CPLEX_ROOT_DIR}/concert/lib/x86-64_osx/static_pic/libconcert.dylib @loader_path/./libconcert.dylib ${PREFIX}/lib/libpgmlink.dylib
    install_name_tool -change ${CPLEX_ROOT_DIR}/cplex/lib/x86-64_osx/static_pic/libcplex.dylib @loader_path/./libcplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    install_name_tool -change ${CPLEX_ROOT_DIR}/cplex/lib/x86-64_osx/static_pic/libilocplex.dylib @loader_path/./libilocplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
    install_name_tool -change ${CPLEX_ROOT_DIR}/concert/lib/x86-64_osx/static_pic/libconcert.dylib @loader_path/./libconcert.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
else
    CPLEX_LIB_DIR=`echo $CPLEX_ROOT_DIR/cplex/lib/*/static_pic`
    CONCERT_LIB_DIR=`echo $CPLEX_ROOT_DIR/concert/lib/*/static_pic`
    set -x
    patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/.' ${PREFIX}/lib/libpgmlink.so
    patchelf --set-rpath $CONCERT_LIB_DIR:$CPLEX_LIB_DIR:'$ORIGIN/../..' ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
fi
