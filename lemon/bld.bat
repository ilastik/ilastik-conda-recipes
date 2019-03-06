mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "NMake Makefiles" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" 
REM -DGLPK_LIBRARY="" -DGLPK_INCLUDE_DIR="" -DGLPK_ROOT_DIR=""
if errorlevel 1 exit 1
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1