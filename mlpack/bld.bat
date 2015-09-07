REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

"%MSYS_PATH%\patch" -p0 -i "%RECIPE_DIR%\mlpack-win.patch"
if errorlevel 1 exit 1

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX_LINUX%" ^
         -DHDF5_C_LIBRARY="%LIBRARY_PREFIX_LINUX%/lib/hdf5.lib" ^
         -DICONV_LIBRARY="%LIBRARY_PREFIX_LINUX%/lib/iconv.lib" ^
         -DZLIB_LIBRARY=%LIBRARY_PREFIX_LINUX%/lib/zlib.lib"
if errorlevel 1 exit 1
        
set CONFIGURATION=Release
cmake --build . --target mlpack --config %CONFIGURATION%
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
