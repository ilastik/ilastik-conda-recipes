REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

@REM msys\bin must not be in the PATH here (conflicts with MSVC link.exe)
%DOS_TOOLS% :remove_from_PATH "%MSYS_PATH%"

cd win32
cscript configure.js compiler=msvc ^
                     prefix="%LIBRARY_PREFIX%" ^
                     include="%LIBRARY_INC%" ^
                     lib="%LIBRARY_LIB%" ^
                     debug=no
if errorlevel 1 exit 1

nmake /f Makefile.msvc
if errorlevel 1 exit 1

nmake /f Makefile.msvc install
if errorlevel 1 exit 1
