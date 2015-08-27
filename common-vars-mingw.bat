@echo off

REM Shortcut for calls to the utility library. Usage:
REM    %DOS_TOOLS%  :subroutine  arg1  arg2  ...
set DOS_TOOLS=call "%~dp0dos-tools.bat"

REM find mingw in the PATH
%DOS_TOOLS%  :capture_output  "where gfortran.exe"  MINGW_PATH
if "%MINGW_PATH%"=="" (
    echo MinGW\bin must be in the PATH
    exit 1
)
set MINGW_PATH=%MINGW_PATH:\gfortran.exe=%

REM find compiler version
%DOS_TOOLS%  :capture_output  "gcc.exe -dumpversion"  MINGW_VERSION

REM find compiler bitness
%DOS_TOOLS%  :capture_output  "where x86_64-w64-mingw32-gcc.exe"  MINGW64
if "%MINGW64%"=="" (
    set MINGW_ARCH=32
) else (
    set MINGW_ARCH=64
)

if NOT "%ARCH%"=="%MINGW_ARCH%" (
    echo Conda requested %ARCH%-bit build, but MinGW is %MINGW_ARCH%-bit.
    exit 1
)

REM find proper MSYS make 
REM * condition: msysinfo in the same directory
REM   FIXME: this condition might not be sufficiently portable
REM * 'make' from conda's unxutils doesn't work
set MAKE_PATH=
FOR /F "delims=" %%i IN ('where make.exe') DO %DOS_TOOLS% :find_msys_make %%i MAKE_PATH
if "%MAKE_PATH%"=="" (
    echo MSYS 'make' must be in the PATH
    exit 1
)

REM status output
echo MINGW:   MINGW_PATH="%MINGW_PATH%"
echo VERSION: MINGW_VERSION=%MINGW_VERSION%
echo BITNESS: MINGW_ARCH=%MINGW_ARCH%
echo MAKE:    MAKE_PATH="%MAKE_PATH%"
