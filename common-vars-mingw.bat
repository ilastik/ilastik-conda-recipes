echo off

REM this emulates "set CL_PATH=`where cl.exe`"
FOR /F "delims=" %%i IN ('where gfortran.exe') DO set MINGW_PATH=%%i
set MINGW_PATH=%MINGW_PATH:\gfortran.exe=%

REM check if we found Visual Studio
if "%MINGW_PATH%"=="" (
    echo MinGW must be in the PATH
    exit 1
)

FOR /F "delims=" %%i IN ('gcc.exe -dumpversion') DO set MINGW_VERSION=%%i

FOR /F "delims=" %%i IN ('where x86_64-w64-mingw32-gcc.exe') DO set MINGW64=%%i

REM find compiler bitness
if "%MINGW64%"=="" (
    set MINGW_ARCH=32
) else (
    set MINGW_ARCH=64
)

if NOT %ARCH%==%MINGW_ARCH% (
    echo Conda requested %ARCH%-bit build, but MinGW is %MINGW_ARCH%-bit.
    exit 1
)

FOR /F "delims=" %%i IN ('where make.exe') DO set MAKE_PATH=%%i
if "%MAKE_PATH%"=="" (
    echo 'make' must be in the PATH
    exit 1
)

echo MINGW:   MINGW_PATH="%MINGW_PATH%"
echo VERSION: MINGW_VERSION=%MINGW_VERSION%
echo BITNESS: MINGW_ARCH=%MINGW_ARCH%
echo MAKE:    MAKE_PATH="%MAKE_PATH%"
