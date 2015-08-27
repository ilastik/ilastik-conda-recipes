call "%RECIPE_DIR%\..\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX_LINUX%" ^
         -DVIGRA_INCLUDE_DIR="%LIBRARY_PREFIX_LINUX%/include" ^
         -DWITH_OPENMP=ON            
if errorlevel 1 exit 1
   
set CONFIGURATION=Release
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
