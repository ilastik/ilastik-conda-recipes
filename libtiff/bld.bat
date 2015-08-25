call "%RECIPE_DIR%\..\common-vars.bat"

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%\include" INCLUDE_PATH
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%\lib" LIB_PATH

rem patch nmake.opt
cat nmake.opt ^
  | sed -e "s@#JPEG_SUPPORT@JPEG_SUPPORT@g" ^
        -e "s@#JPEG_INCLUDE.*@JPEG_INCLUDE = -I\"%INCLUDE_PATH%\"@g" ^
        -e "s@#JPEG_LIB.*@JPEG_LIB = \"%LIB_PATH%/jpeg.lib\"@g" ^
        -e "s@#ZIP_SUPPORT@ZIP_SUPPORT@g" ^
        -e "s@#ZLIB_INCLUDE.*@ZLIB_INCLUDE = -I\"%INCLUDE_PATH%\"@g" ^
        -e "s@#ZLIB_LIB.*@ZLIB_LIB = \"%LIB_PATH%/zlib.lib\"@g" ^
  > nmake.opt.new
move nmake.opt.new nmake.opt

REM BUILD
nmake /f Makefile.vc
if errorlevel 1 exit 1

REM INSTALL
cmake -DTIFF_INSTALL_PREFIX="%LIBRARY_PREFIX%" -P "%RECIPE_DIR%/tiff_install.cmake" 
if errorlevel 1 exit 1
