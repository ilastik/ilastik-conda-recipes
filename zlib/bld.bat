call "%RECIPE_DIR%\..\common-vars.bat"

rem patch CMakeLists.txt
echo # >> CMakeLists.txt
echo # workaround for cmake bug #0011240 (see http://public.kitware.com/Bug/view.php?id=11240) >> CMakeLists.txt
echo if(WIN32 AND CMAKE_GENERATOR MATCHES Win64) >> CMakeLists.txt
echo    set_target_properties(zlibstatic PROPERTIES STATIC_LIBRARY_FLAGS "/machine:x64") >> CMakeLists.txt
echo endif() >> CMakeLists.txt

mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" -DBUILD_SHARED_LIBS=0 -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target zlib --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
