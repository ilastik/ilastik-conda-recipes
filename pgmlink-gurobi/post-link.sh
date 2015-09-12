if [ ! -d $GUROBI_ROOT_DIR ]
then
    echo "Error: GUROBI_ROOT_DIR needs to be set"
    exit 1
fi

if [ `uname` == Darwin ]; then
    set -x
    install_name_tool -add_rpath ${GUROBI_ROOT_DIR}/lib "${PREFIX}/lib/libpgmlink.dylib"
    
    install_name_tool -add_rpath ${GUROBI_ROOT_DIR}/lib  "${PREFIX}/lib/python3.5/site-packages/pgmlink.so"
    set +x
else
    set -x
    ${PREFIX}/bin/patchelf --set-rpath ${GUROBI_ROOT_DIR}/lib:'$ORIGIN/.' ${PREFIX}/lib/libpgmlink.so
    ${PREFIX}/bin/patchelf --set-rpath ${GUROBI_ROOT_DIR}/lib:'$ORIGIN/../..' ${PREFIX}/lib/python3.5/site-packages/pgmlink.so
    set +x
fi
