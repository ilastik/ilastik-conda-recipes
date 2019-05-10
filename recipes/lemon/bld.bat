mkdir build
cd build

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release --target ALL_BUILD
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
