REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

cmake .. -G "%CMAKE_GENERATOR%" -DBUILD_SHARED_LIBS=1 -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DILMBASE_PACKAGE_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

REM build and install
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

move "%LIBRARY_PREFIX%\lib\*.dll" "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1
