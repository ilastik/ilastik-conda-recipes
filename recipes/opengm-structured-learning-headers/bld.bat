mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DWITH_BOOST=ON -DWITH_HDF5=ON ^
    -DBUILD_PYTHON_WRAPPER=OFF ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_TUTORIALS=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_COMMANDLINE=OFF

if errorlevel 1 exit 1
nmake all
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
