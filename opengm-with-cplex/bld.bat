REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DBUILD_PYTHON_WRAPPER=ON ^
         -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib" ^
         -DPYTHON_INCLUDE_DIR="%PREFIX%\include" ^
         -DPYTHON_INSTALL_DIR="%PREFIX%\Lib\site-packages\opengm_with_cplex" ^
         -DBUILD_EXAMPLES=OFF ^
         -DBUILD_TUTORIALS=OFF ^
         -DBUILD_TESTING=OFF ^
         -DWITH_VIGRA=ON ^
         -DWITH_BOOST=ON ^
         -DWITH_CPLEX=ON ^
         -DWITH_HDF5=ON
if errorlevel 1 exit 1

cmake --build . --target externalLibs
if errorlevel 1 exit 1

cmake . -DWITH_MAXFLOW=ON -DWITH_MAXFLOW_IBFS=ON -DWITH_QPBO=ON
if errorlevel 1 exit 1

cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
