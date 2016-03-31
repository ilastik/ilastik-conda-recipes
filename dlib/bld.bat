REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

set CONFIGURATION=Release
set PATH=%PATH%;%LIBRARY_PREFIX%\bin

echo on
cmake ..\dlib -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

REM BUILD
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
