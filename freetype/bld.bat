call "%RECIPE_DIR%\..\common-vars.bat"

cd builds\win32\vc2010

devenv freetype.sln /upgrade
if errorlevel 1 exit 1

if %ARCH%==32 (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
    REM Switch to x64 build 
    REM FIXME: the RE is very simplistic -- check for side effects
    cat freetype.sln | sed -e "s@Win32@x64@g" > freetype.sln.patched
    if errorlevel 1 exit 1
    move freetype.sln.patched freetype.sln
    if errorlevel 1 exit 1
    cat freetype.vcxproj | sed -e "s@Win32@x64@g" > freetype.vcxproj.patched
    if errorlevel 1 exit 1
    move freetype.vcxproj.patched freetype.vcxproj
    if errorlevel 1 exit 1
)

devenv freetype.sln /build "Release Multithreaded|%PLATFORM%" /project freetype
if errorlevel 1 exit 1

cd ..\..\..
xcopy /S include "%LIBRARY_INC%\"
if errorlevel 1 exit 1
copy objs\win32\vc2010\freetype2411MT.lib "%LIBRARY_LIB%\freetype.lib"
if errorlevel 1 exit 1
