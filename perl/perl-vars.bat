@echo off

REM Shortcut for calls to the utility library. Usage:
REM    %DOS_TOOLS%  :subroutine  arg1  arg2  ...
set DOS_TOOLS=call "%~dp0dos-tools.bat"

REM find ActiveState Perl in the PATH
REM * condition: ap-user-guide in the same directory
REM   FIXME: this condition might not be sufficiently portable
REM * MSYS\bin\perl.exe does not work
set PERL_PATH=
FOR /F "delims=" %%i IN ('where perl.exe') DO %DOS_TOOLS% :find_active_perl %%i PERL_PATH
if "%PERL_PATH%"=="" (
    echo ActiveState Perl must be in the PATH
    exit 1
)

REM status output
echo ActiveState Perl:   PERL_PATH=%PERL_PATH%
