REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

set SRC_DIR=%CD%

REM build the utility module for the error dialog work-around
mkdir build_no_error_box
cd build_no_error_box
echo building utility module 'no_error_box.pyd'
cmake "%RECIPE_DIR%\no_error_box" ^
      -G "%CMAKE_GENERATOR%" ^
      -DPYTHON_INC="%PREFIX%\include" ^
      -DPYTHON_LIB="%PREFIX%\libs\python27.lib" ^
      -DINSTALL_DIR="%SRC_DIR%"
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
cd ..

REM insert the utility module in setup.py
cat setup.py | sed -e "s@import subprocess@import subprocess, no_error_box@" > setup-no-error-box.py
if errorlevel 1 exit 1

REM patch
"%MSYS_PATH%\patch.exe" -p0 -i "%RECIPE_DIR%\scipy.patch"
if errorlevel 1 exit 1

rem find libgcc*.dll
FOR /F "delims=" %%i IN ('dir /b "%LIBRARY_BIN%\libgcc*.dll"') DO SET LIBGCC=%%i
set LIBGCC=%LIBGCC:.dll=%

if "%ARCH%"=="64" (
    REM rem 64-bit mingw needs various additional libraries
    REM FIXME: newer mingw might already incluse these
    
    REM The first setup call crashes in the middle (perhaps due to
    REM out-of-memory) and shows a dialog box that must be closed manually.
    REM The utility module 'no_error_box' supresses the dialog.
    REM FIXME: replace 'no_error_box' work-around with a real solution.
    python setup-no-error-box.py build_ext -l "%LIBGCC% libgfortran-3 emulate_c99 libgcc.a" -L "%LIBRARY_LIB%" install
    REM Call setup again to finish the work after the above crash.
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
