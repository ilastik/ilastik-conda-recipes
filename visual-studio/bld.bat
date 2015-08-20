@echo off

call "%RECIPE_DIR%\..\common-vars.bat"

REM check if we have the correct compiler version
if NOT "%VISUAL_STUDIO_VERSION%"=="%PKG_VERSION%" (
    echo Visual Studio %PKG_VERSION% required.
    exit 1
)

if %ARCH%==32 (
    set CMAKE_GENERATOR=Visual Studio %PKG_VERSION:.0=%
) else (
    set CMAKE_GENERATOR=Visual Studio %PKG_VERSION:.0=% Win64
)

REM install Visual Studio runtime libraries (msvcr, msvcp)
echo CMAKE GENERATOR: %CMAKE_GENERATOR%
cmake "%RECIPE_DIR%" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
