REM extend toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info

cat "%RECIPE_DIR%\common-vars-mingw.bat.in" ^
   | sed -e "s/@PKG_VERSION@/%PKG_VERSION%/g" ^
   > "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"
   
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

for /f "delims=" %%a in ('dir /b "%MINGW_PATH%\libgcc*.dll"') do @set LIBGCC=%%a
set LIBGCC=%LIBGCC:.dll=%
copy "%MINGW_PATH%\%LIBGCC%.dll" "%LIBRARY_BIN%"

copy "%MINGW_PATH%\libgfortran-3.dll" "%LIBRARY_BIN%"
if exist "%MINGW_PATH%\libwinpthread-1.dll" copy "%MINGW_PATH%\libwinpthread-1.dll" "%LIBRARY_BIN%"

copy "%MINGW_PATH%\libstdc++-6.dll" "%LIBRARY_BIN%"
copy "%MINGW_PATH%\libquadmath-0.dll" "%LIBRARY_BIN%"

rem find libgcc.a and copy it to LIBRARY_LIB (needed to get __chkstk_ms() )
for /f "delims=" %%a in ('dir /s /b "%MINGW_PATH%\..\lib\*libgcc.a" ^| find /v "\32\"') do @set LIBGCCA=%%a
copy "%LIBGCCA%" "%LIBRARY_LIB%\libgcc.a.lib"

if %ARCH%==64 (
    rem The following two gendef/lib commands are needed for 64-bit builds
    gendef "%MINGW_PATH%\%LIBGCC%.dll"
    lib /NOLOGO /MACHINE:X64 /DEF:%LIBGCC%.def /OUT:"%LIBRARY_LIB%/%LIBGCC%.lib"
    gendef "%MINGW_PATH%\libgfortran-3.dll"
    lib /NOLOGO /MACHINE:X64 /DEF:libgfortran-3.def /OUT:"%LIBRARY_LIB%/libgfortran-3.lib"
)
