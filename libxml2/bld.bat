REM FIXME: msys\bin must not be in the PATH here (conflicts with MSVC link.exe)

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
