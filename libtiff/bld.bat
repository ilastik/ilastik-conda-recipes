call "%RECIPE_DIR%\..\common-vars.bat"

rem patch nmake.opt
echo # >> nmake.opt
echo JPEG_SUPPORT = 1 >> nmake.opt
echo JPEG_INCLUDE = -I%LIBRARY_PREFIX%/include >> nmake.opt
echo JPEG_LIB = -I%LIBRARY_PREFIX%/lib/jpeg.lib >> nmake.opt
echo # >> nmake.opt
echo ZIP_SUPPORT = 1 >> nmake.opt
echo ZLIB_INCLUDE = -I%LIBRARY_PREFIX%/include >> nmake.opt
echo ZLIB_LIB = -I%LIBRARY_PREFIX%/lib/zlib.lib >> nmake.opt

REM BUILD
nmake /f Makefile.vc
if errorlevel 1 exit 1

REM INSTALL
cmake -DTIFF_INSTALL_PREFIX="%LIBRARY_PREFIX%" -P "%RECIPE_DIR%/tiff_install.cmake" 
if errorlevel 1 exit 1
