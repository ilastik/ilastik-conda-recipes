call "%RECIPE_DIR%\..\common-vars.bat"

REM the source code for arc_look_up_test is missing
cat test\CMakeLists.txt ^
   | sed -e "s@arc_look_up_test@#arc_look_up_test@g" ^
   > test\CMakeLists.txt.patched
if errorlevel 1 exit 1
move test\CMakeLists.txt.patched test\CMakeLists.txt
if errorlevel 1 exit 1

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%"
if errorlevel 1 exit 1
    
set CONFIGURATION=Release
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
