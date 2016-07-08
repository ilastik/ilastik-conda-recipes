if [ `uname` == "Darwin" ]; then
    DYLIB=dylib
else
    DYLIB=so
fi

# Remove the symlinks we made
rm -f ${PREFIX}/lib/libcplex.dylib
rm -f ${PREFIX}/lib/libconcert.dylib
rm -f ${PREFIX}/lib/libilocplex.dylib
