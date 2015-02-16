export CPLEX_DIR=/Users/chaubold/hci/code/cplex

mkdir build
cd build
cmake ..\
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7\
	-DCMAKE_INSTALL_PREFIX=${PREFIX}\
	-DCMAKE_PREFIX_PATH=${PREFIX}\
	-DBUILD_SHARED_LIBS=ON\
    -DWITH_HDF5=ON\
    -DWITH_PYTHON=ON\
    -DWITH_CHECKED_STL=OFF\
    -DWITH_TESTS=ON\
    -DCPLEX_ROOT_DIR=${CPLEX_DIR}

make -j${CPU_COUNT}
make install

if [ `uname` == Darwin ]; then
	install_name_tool -change ${CPLEX_DIR}/cplex/lib/x86-64_osx/static_pic/libcplex.dylib @loader_path/./libcplex.dylib ${PREFIX}/lib/libpgmlink.dylib
	install_name_tool -change ${CPLEX_DIR}/cplex/lib/x86-64_osx/static_pic/libilocplex.dylib @loader_path/./libilocplex.dylib ${PREFIX}/lib/libpgmlink.dylib
	install_name_tool -change ${CPLEX_DIR}/concert/lib/x86-64_osx/static_pic/libconcert.dylib @loader_path/./libconcert.dylib ${PREFIX}/lib/libpgmlink.dylib
	install_name_tool -change ${CPLEX_DIR}/cplex/lib/x86-64_osx/static_pic/libcplex.dylib @loader_path/./libcplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
	install_name_tool -change ${CPLEX_DIR}/cplex/lib/x86-64_osx/static_pic/libilocplex.dylib @loader_path/./libilocplex.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
	install_name_tool -change ${CPLEX_DIR}/concert/lib/x86-64_osx/static_pic/libconcert.dylib @loader_path/./libconcert.dylib ${PREFIX}/lib/python2.7/site-packages/pgmlink.so
else
    echo "Use chrpath here!"
fi