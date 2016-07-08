if [ `uname` == "Darwin" ]; then
    DYLIB=dylib
else
    DYLIB=so
fi

# Remove the symlinks we made
cd ${PREFIX}/lib
rm -f ${PREFIX}/libcplex.dylib
rm -f ${PREFIX}/libconcert.dylib
rm -f ${PREFIX}/libilocplex.dylib
