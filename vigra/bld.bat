call "%RECIPE_DIR%\..\common-vars.bat"

mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1

REM TEST
cmake --build . --target test_impex --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
