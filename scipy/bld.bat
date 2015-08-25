call "%RECIPE_DIR%\..\common-vars.bat"
call "%RECIPE_DIR%\..\common-vars-mingw.bat"

"%MAKE_PATH%\patch.exe" -p0 -i "%RECIPE_DIR%\scipy.patch"
if errorlevel 1 exit 1

rem find libgcc*.dll
FOR /F "delims=" %%i IN ('dir /b "%LIBRARY_BIN%\libgcc*.dll"') DO SET LIBGCC=%%i
set LIBGCC=%LIBGCC:.dll=%

if "%ARCH%"=="64" (
    REM rem 64-bit mingw needs emulate_c99
    python setup.py build_ext -l "%LIBGCC% libgfortran-3 emulate_c99 libgcc.a" -L "%LIBRARY_LIB%" install
    REM we must call this twice because the first call crashes in the middle
    REM (perhaps due to a timing issue or too many open files)
    REM FIXME: find abetter solution (at present, the user has to click a dialog to continue)
    python setup.py build_ext -l "%LIBGCC% libgfortran-3 emulate_c99 libgcc.a" -L "%LIBRARY_LIB%" install
) else (
    rem 32-bit mingw already contains the C99 functions. libgcc and libgfortran are
    rem automatically included by numpy/distutils on this platform.
    python setup.py build_ext -l "libgcc.a" -L "%LIBRARY_LIB%" install
)

rem Do not build with '-c mingw32' because this would use gcc for linking, leading to crashes.
rem For the same reason, never start 'devenv' in a git/msys bash shell!
rem Without this flag, mingw will only be used for Fortran sources, and gfortran 
rem is automatically found in the PATH.
