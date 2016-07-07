REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build
cmake .. -G "%CMAKE_GENERATOR%" ^
         -Djbig=0 ^
         -Djpeg12=0 ^
         -Dpixarlog=0 ^
         -Dold-jpeg=0 ^
         -DJPEG_INCLUDE_DIR="%LIBRARY_INC%" ^
         -DJPEG_LIBRARY="%LIBRARY_LIB%\jpeg.lib" ^
         -DLIBLZMA_INCLUDE_DIR="%LIBRARY_INC%" ^
         -DLIBLZMA_LIBRARY="%LIBRARY_LIB%\liblzma.lib" ^
         -DZLIB_INCLUDE_DIR="%LIBRARY_INC%" ^
         -DZLIB_LIBRARY="%LIBRARY_LIB%\zlib.lib" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

copy "%PREFIX%\Library\lib\tiff.lib" "%PREFIX%\Library\lib\libtiff_i.lib"
if errorlevel 1 exit 1
