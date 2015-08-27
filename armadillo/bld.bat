call "%RECIPE_DIR%\..\common-vars.bat"

REM FIXME: don't hardcode this path
C:\msys\bin\patch -p0 -i "%RECIPE_DIR%\armadillo-win.patch"
if errorlevel 1 exit 1

mkdir build
cd build

if "%ARCH%"=="64" set ARMA_USE_64BIT_WORD=-DARMA_64BIT_WORD=1

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_UNIX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_UNIX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX_UNIX%" ^
         -DOpenBLAS_NAMES=libopenblas ^
         -DHDF5_C_LIBRARY="%LIBRARY_PREFIX_UNIX%/lib/hdf5.lib" ^
         %ARMA_USE_64BIT_WORD%
if errorlevel 1 exit 1
         
set CONFIGURATION=Release
cmake --build . --target ALL_BUILD --config %CONFIGURATION%
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
