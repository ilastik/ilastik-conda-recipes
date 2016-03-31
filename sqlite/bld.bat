REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

if "%ARCH%"=="64" (
    set MACHINE=/MACHINE:X64
) else (
    set MACHINE=/MACHINE:X86
    )

cl /EHsc /O2 /c sqlite3.c
if errorlevel 1 exit 1
lib /OUT:sqlite3.lib /LTCG %MACHINE% /NOLOGO sqlite3.obj
if errorlevel 1 exit 1

copy sqlite3.h %LIBRARY_INC%\sqlite3.h
copy sqlite3.lib %LIBRARY_LIB%\sqlite3.lib
if errorlevel 1 exit 1
