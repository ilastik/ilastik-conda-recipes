@echo off

if "%TERM%"=="cygwin" (
    echo Conda builds must be started from a DOS box
    exit 1
)

REM this emulates "set CL_PATH=`where cl.exe`"
FOR /F "delims=" %%i IN ('where cl.exe') DO set CL_PATH=%%i

REM check if we found Visual Studio
if "%CL_PATH%"=="" (
    echo Visual Studio must be in the PATH
    exit 1
)

echo FOUND COMPILER: "%CL_PATH%"

REM check if we have the correct compiler version
call set CL_VERSION=%%CL_PATH:Visual Studio %PKG_VERSION%=%%
if "%CL_PATH%"=="%CL_VERSION%" (
    echo Visual Studio %PKG_VERSION% required.
    exit 1
)

REM check if we have the right bitness
set CL_BITNESS=%CL_PATH:amd64=%
if "%CL_PATH%"=="%CL_BITNESS%" (
    REM 32-bit compiler
    if %ARCH%==64 (
        echo Conda requested 64-bit build, but Visual Studio is 32-bit.
        exit 1
    )
    set CMAKE_GENERATOR=Visual Studio %PKG_VERSION:.0=%
) else (
    REM 64-bit compiler
    if %ARCH%==32 (
        echo Conda requested 32-bit build, but Visual Studio is 64-bit.
        exit 1
    )
    set CMAKE_GENERATOR=Visual Studio %PKG_VERSION:.0=% Win64
)

REM install Visual Studio runtime libraries (msvcr, msvcp)
echo CMAKE GENERATOR: %CMAKE_GENERATOR%
cmake "%RECIPE_DIR%" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
