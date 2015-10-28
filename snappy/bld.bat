REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

type snappy.vcxproj ^
    | sed -e "s@<PlatformToolset>v120_xp</PlatformToolset>@<PlatformToolset>v110</PlatformToolset>@g" ^
    > snappy.vcxproj.patched
move /Y snappy.vcxproj.patched snappy.vcxproj
if errorlevel 1 exit 1

devenv snappy.sln /build "Release|x64" /project snappy
if errorlevel 1 exit 1

copy snappy.h "%LIBRARY_INC%\"
copy x64\Release\snappy64.dll "%LIBRARY_BIN%\"
copy x64\Release\snappy64.lib "%LIBRARY_LIB%\snappy.lib"
if errorlevel 1 exit 1
