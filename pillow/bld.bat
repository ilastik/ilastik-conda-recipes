call "%RECIPE_DIR%\..\common-vars.bat"

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%\include" INCLUDE_PATH
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%\lib" LIB_PATH

cat setup.py ^
  | sed -e "s@JPEG_ROOT = None@JPEG_ROOT = \"%LIB_PATH%\", \"%INCLUDE_PATH%\"@g" ^
        -e "s@ZLIB_ROOT = None@ZLIB_ROOT = \"%LIB_PATH%\", \"%INCLUDE_PATH%\"@g" ^
        -e "s@TIFF_ROOT = None@TIFF_ROOT = \"%LIB_PATH%\", \"%INCLUDE_PATH%\"@g" ^
        -e "s@FREETYPE_ROOT = None@FREETYPE_ROOT = \"%LIB_PATH%\", \"%INCLUDE_PATH%\"@g" ^
  > setup.py.patched
if errorlevel 1 exit 1
move setup.py.patched setup.py
if errorlevel 1 exit 1

python setup.py build_ext -c msvc
if errorlevel 1 exit 1
python setup.py install
if errorlevel 1 exit 1
