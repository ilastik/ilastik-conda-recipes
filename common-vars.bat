@echo off

if "%TERM%"=="cygwin" (
    echo Conda builds must be started from a DOS box
    exit 1
)

REM this emulates "set CL_PATH=`where cl.exe`"
FOR /F "delims=" %%i IN ('where cl.exe') DO set VISUAL_STUDIO_PATH=%%i

REM check if we found Visual Studio
if "%VISUAL_STUDIO_PATH%"=="" (
    echo Visual Studio must be in the PATH
    exit 1
)

REM find compiler version
set VISUAL_STUDIO_VERSION=%VISUAL_STUDIO_PATH:*Visual Studio =%
set _TMP_SUFFIX=%VISUAL_STUDIO_VERSION:*\=%
call set VISUAL_STUDIO_VERSION=%%VISUAL_STUDIO_VERSION:\%_TMP_SUFFIX%=%%

REM find compiler bitness
if "%VISUAL_STUDIO_PATH%"=="%VISUAL_STUDIO_PATH:amd64=%" (
    set VISUAL_STUDIO_ARCH=32
) else (
    set VISUAL_STUDIO_ARCH=64
)

if NOT %ARCH%==%VISUAL_STUDIO_ARCH% (
    echo Conda requested %ARCH%-bit build, but Visual Studio is %VISUAL_STUDIO_ARCH%-bit.
    exit 1
)

call set _TMP_SUFFIX=%%VISUAL_STUDIO_PATH:*%VISUAL_STUDIO_VERSION%\VC=%%
call set VISUAL_STUDIO_VCVARSALL=%%VISUAL_STUDIO_PATH:%_TMP_SUFFIX%=\VCVARSALL.BAT%%

echo COMPILER:  VISUAL_STUDIO_PATH="%VISUAL_STUDIO_PATH%"
echo VCVARSALL: VISUAL_STUDIO_VCVARSALL="%VISUAL_STUDIO_VCVARSALL%"
echo VERSION:   VISUAL_STUDIO_VERSION=%VISUAL_STUDIO_VERSION%
echo BITNESS:   VISUAL_STUDIO_ARCH=%VISUAL_STUDIO_ARCH%
