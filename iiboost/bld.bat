REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX
set ITK_CONFIG_DIR=%LIBRARY_PREFIX_LINUX%/lib/cmake/ITK-4.6

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DBUILD_PYTHON_WRAPPER=1 ^
         -DITK_DIR="%ITK_CONFIG_DIR%"
if errorlevel 1 exit 1
            
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
