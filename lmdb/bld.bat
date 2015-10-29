REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"
set PATH=%MSYS_PATH%;%PATH%

cd liblmdb

make -j4
if errorlevel 1 exit 1

copy lmdb.h "%LIBRARY_INC%\"
copy liblmdb.a "%LIBRARY_LIB%\liblmdb.lib"
