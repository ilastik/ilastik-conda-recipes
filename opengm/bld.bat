call "%RECIPE_DIR%\..\common-vars.bat"

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DBUILD_EXAMPLES=OFF ^
         -DBUILD_TUTORIALS=OFF ^
         -DBUILD_TESTING=OFF ^
         -DWITH_CPLEX=ON ^
         -DWITH_HDF5=ON
if errorlevel 1 exit 1
    
set CONFIGURATION=Release
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
