REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

REM uncomment to compile Python bindings
REM cmake .. -G "%CMAKE_GENERATOR%" ^
         REM -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         REM -DBUILD_PYTHON_WRAPPER=ON ^
         REM -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib" ^
         REM -DPYTHON_INCLUDE_DIR="%PREFIX%\include" ^
         REM -DBUILD_EXAMPLES=OFF ^
         REM -DBUILD_TUTORIALS=OFF ^
         REM -DBUILD_TESTING=OFF ^
         REM -DWITH_BOOST=ON ^
         REM -DWITH_CPLEX=ON ^
         REM -DWITH_HDF5=ON
cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DBUILD_EXAMPLES=OFF ^
         -DBUILD_TUTORIALS=OFF ^
         -DBUILD_TESTING=OFF ^
         -DWITH_BOOST=ON ^
         -DWITH_CPLEX=ON ^
         -DWITH_HDF5=ON
if errorlevel 1 exit 1

set CONFIGURATION=Release
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
