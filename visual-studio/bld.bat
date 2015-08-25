@echo off

call "%RECIPE_DIR%\..\common-vars.bat"

REM check if we have the correct compiler version
if NOT "%VISUAL_STUDIO_VERSION%"=="%PKG_VERSION%" (
    echo Visual Studio %PKG_VERSION% required.
    exit 1
)

REM install Visual Studio runtime libraries (msvcr, msvcp)
cmake "%RECIPE_DIR%" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config Release
move "%LIBRARY_PREFIX%\bin\msvc*.dll" "%PREFIX%"
if errorlevel 1 exit 1
