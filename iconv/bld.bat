call "%RECIPE_DIR%\..\common-vars-mingw.bat"

set PATH=%MSYS_PATH%;%MINGW_PATH%;%PATH%

if "%ARCH%"=="64" set PLATFORM=/MACHINE:X64

sh configure

make
if errorlevel 1 exit 1

copy include\iconv.h "%LIBRARY_INC%"
if errorlevel 1 exit 1
copy lib\.libs\libiconv-2.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1
gendef "lib\.libs\libiconv-2.dll"
if errorlevel 1 exit 1
lib /NOLOGO %PLATFORM% /DEF:libiconv-2.def /OUT:"%LIBRARY_LIB%\iconv.lib"
if errorlevel 1 exit 1
