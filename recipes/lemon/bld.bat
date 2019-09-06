mkdir build
cd build

set CONFIGURATION=Release

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_POSITION_INDEPENDENT_CODE=1 ^
    -DLEMON_ENABLE_GLPK=0 ^
    -DLEMON_ENABLE_ILOG=0 ^
    -DLEMON_ENABLE_COIN=0 ^
    -DLEMON_ENABLE_SOPLEX=0 ^
    ..
if errorlevel 1 exit 1

REM BUILD
nmake check
if errorlevel 1 exit 1

REM TEST
nmake check
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
