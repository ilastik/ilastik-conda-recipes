mkdir build
cd build

set CONFIGURATION=Release
set PATH=%PATH%;%LIBRARY_PREFIX%\bin

cmake .. -G "%CMAKE_GENERATOR%" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DCMAKE_CXX_FLAGS="-DH5_BUILT_AS_DYNAMIC_LIB /EHsc -DFFTW_DLL -DBOOST_ALL_NO_LIB" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -DWITH_LEMON=1 -DPYTHON_EXECUTABLE="%PYTHON%" -DBUILD_SHARED_LIBS=1
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1

REM TEST
cmake --build . --target test_impex --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target test_hdf5impex --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target test_fourier --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target vigranumpytest --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1