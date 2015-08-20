call "%RECIPE_DIR%\..\common-vars.bat"

mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" -DBUILD_SHARED_LIBS=0 -DZLIB_INCLUDE_DIR=%LIBRARY_INC% -DZLIB_LIBRARY=%LIBRARY_LIB%/zlib.lib -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target png15 --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
