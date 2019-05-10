if [ `uname` == "Darwin" ]; then
    DYLIB=dylib
else
    DYLIB=so
fi

# Remove the symlinks we made
rm -f ${PREFIX}/lib/libcplex.${DYLIB}
rm -f ${PREFIX}/lib/libconcert.${DYLIB}
rm -f ${PREFIX}/lib/libilocplex.${DYLIB}
