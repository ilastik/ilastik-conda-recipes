if [ `uname` == "Darwin" ]; then
    DYLIB=dylib
else
    DYLIB=so
fi

# Remove the symlinks we made
cd ${PREFIX}/lib
rm -f ${CPLEX_LIB_DIR}/libcplex.dylib
rm -f ${CONCERT_LIB_DIR}/libconcert.dylib
rm -f ${CPLEX_LIB_DIR}/libilocplex.dylib
