mkdir build
cd build

set CONFIGURATION=Release
set PATH=%PATH%;%LIBRARY_PREFIX%\bin

cmake .. -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
    -DTEST_VIGRANUMPY=1 ^
    -DAUTOEXEC_TESTS=0 ^
    -DCMAKE_CXX_FLAGS="-DH5_BUILT_AS_DYNAMIC_LIB /EHsc -DFFTW_DLL -DBOOST_ALL_NO_LIB" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DWITH_LEMON=1 ^
    -DPYTHON_EXECUTABLE="%PYTHON%" ^
    -DBUILD_SHARED_LIBS=1
if errorlevel 1 exit 1

REM BUILD
nmake check
if errorlevel 1 exit 1

REM TEST
ctest -V
if errorlevel 1 exit 1

nmake check_python
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

rem REM TEST
rem cmake --build . --target test_impex --config %CONFIGURATION%
rem if errorlevel 1 exit 1
rem cmake --build . --target test_hdf5impex --config %CONFIGURATION%
rem if errorlevel 1 exit 1
rem cmake --build . --target test_fourier --config %CONFIGURATION%
rem if errorlevel 1 exit 1
rem cmake --build . --target vigranumpytest --config %CONFIGURATION%
rem if errorlevel 1 exit 1

rem REM INSTALL
rem cmake --build . --target INSTALL --config %CONFIGURATION%
rem if errorlevel 1 exit 1