call "%RECIPE_DIR%\..\common-vars.bat"

mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" -DBUILD_SHARED_LIBS=0 -DNASM=%LIBRARY_BIN%/nasm.exe -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target simd --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target jpeg --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target jpeg-static --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
