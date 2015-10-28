REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir cmake\build
cd cmake\build

cmake .. -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -Dprotobuf_BUILD_TESTS=OFF
if errorlevel 1 exit 1

cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
