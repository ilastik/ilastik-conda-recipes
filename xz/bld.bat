REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

set PATH=%MSYS_PATH%;%PATH%

"%MSYS_PATH%\patch.exe" -p0 -i "%RECIPE_DIR%\xz.patch"

rem set install path (must have forward slashes)
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" INSTALL_PREFIX
echo Installing into "%INSTALL_PREFIX%"

rem build
sh configure --prefix="%INSTALL_PREFIX%"
if errorlevel 1 exit 1

make
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1

gendef "%LIBRARY_BIN%\liblzma-5.dll"
lib /NOLOGO /MACHINE:X64 /DEF:liblzma-5.def /OUT:"%LIBRARY_LIB%\liblzma.lib"

del "%LIBRARY_LIB%\liblzma.a" "%LIBRARY_LIB%\liblzma.dll.a" "%LIBRARY_LIB%\liblzma.la" "%LIBRARY_LIB%\liblzma.exp"
