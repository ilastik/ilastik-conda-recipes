REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX_LINUX%" ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DWITH_CHECKED_STL=OFF ^
         -DWITH_PYTHON=ON ^
         -DWITH_TESTS=OFF ^
         -DPYTHON_INCLUDE_DIRS="%PREFIX%\include" ^
         -DPYTHON_LIBRARIES="%PREFIX%\libs\python27.lib" ^
         -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib"
if errorlevel 1 exit 1

set CONFIGURATION=Release
cmake --build . --target pgmlink --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target pypgmlink --config %CONFIGURATION%
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1

rem FIXME: this should be corrected in the cmake configuration
move "%PREFIX%\Lib\site-packages\pgmlink\pgmlink.pyd" "%PREFIX%\Lib\site-packages\pgmlink.pyd"
rmdir "%PREFIX%\Lib\site-packages\pgmlink"
