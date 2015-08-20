call "%RECIPE_DIR%\..\common-vars-mingw.bat"

REM check if we have the correct compiler version
if NOT "%MINGW_VERSION%"=="%PKG_VERSION%" (
    echo MinGW %PKG_VERSION% required.
    exit 1
)

for /f "delims=" %%a in ('dir /b "%MINGW_PATH%\libgcc*.dll"') do @set LIBGCC=%%a
set LIBGCC=%LIBGCC:.dll=%
copy "%MINGW_PATH%\%LIBGCC%.dll" "%LIBRARY_BIN%"

copy "%MINGW_PATH%\libgfortran-3.dll" "%LIBRARY_BIN%"
if exist "%MINGW_PATH%\libwinpthread-1.dll" copy "%MINGW_PATH%\libwinpthread-1.dll" "%LIBRARY_BIN%"

copy "%MINGW_PATH%\libstdc++-6.dll" "%LIBRARY_BIN%"
copy "%MINGW_PATH%\libquadmath-0.dll" "%LIBRARY_BIN%"

if %ARCH%==64 (
    rem The following two gendef/lib commands are not necessary for 32-bit builds
    rem because suitable link libs libgcc.dll.a and libgfortran.dll.a 
    rem are already in the mingw distribution and just need to be copied.
    rem This will be done automatically by suitably patched numpy/distutils.
    
    gendef "%MINGW_PATH%\%LIBGCC%.dll"
    lib /NOLOGO /MACHINE:X64 /DEF:%LIBGCC%.def /OUT:"%LIBRARY_LIB%/%LIBGCC%.lib"
    gendef "%MINGW_PATH%\libgfortran-3.dll"
    lib /NOLOGO /MACHINE:X64 /DEF:libgfortran-3.def /OUT:"%LIBRARY_LIB%/libgfortran-3.lib"
)
