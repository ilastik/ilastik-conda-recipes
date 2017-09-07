REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
         -DVIGRA_INCLUDE_DIR="%LIBRARY_PREFIX%/include" ^
         -DWITH_OPENMP=ON ^
         -DPYTHON_INCLUDE_DIRS="%PREFIX%\include" ^
         -DPYTHON_LIBRARIES="%PREFIX%\libs\python27.lib" ^
         -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib"
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
