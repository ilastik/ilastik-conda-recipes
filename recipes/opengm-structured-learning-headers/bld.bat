mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DWITH_BOOST=ON -DWITH_HDF5=ON ^
    -DBUILD_PYTHON_WRAPPER=OFF ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_TUTORIALS=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_COMMANDLINE=OFF

if errorlevel 1 exit 1
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1