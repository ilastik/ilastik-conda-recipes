@REM Utility library for Windows install scripts. Usage:
@REM    call dos-tools.bat  :subroutine  arg1  arg2
set _SELF=%~f0
echo %_SELF%
call %*
goto :eof

@REM convert backward slashes to forward slashes
@REM   :to_linux_path "path" OUT_VAR
:to_linux_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:\=/%"
    if "%_TMP_PATH%"=="" set %~2=
    goto :EOF
    
@REM convert forward slashes to backward slashes
@REM   :to_dos_path "path" OUT_VAR
:to_dos_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:/=\%"
    if "%_TMP_PATH%"=="" set %~2=
    goto :EOF
    
@REM capture the output of a command (like backticks in sh)
@REM   :capture_output "command" OUT_VAR
:capture_output
    set %~2=
    FOR /F "delims=" %%i IN ('%~1') DO set %~2=%%i
    goto :EOF

@REM check if the given path contains "msysinfo"
@REM   :find_msys_make "path\make.exe" OUT_VAR
:find_msys_make
    set _TMP_PATH=%~1
    call set "_TMP_PATH=%_TMP_PATH:\make.exe=%"
    if exist "%_TMP_PATH%\msysinfo" set %~2=%_TMP_PATH%
    goto :eof

@REM remove a path form the PATH variable
@REM    :remove_from_PATH  "path"
:remove_from_PATH
    call :remove_from_PATH_impl %1 > "%temp%\_tmp_path.bat"
    call "%temp%\_tmp_path.bat"
    del "%temp%\_tmp_path.bat"
    goto :eof

@REM helper function for remove_from_PATH 
@REM (creates a command that sets the desired PATH)
:remove_from_PATH_impl
    @echo off
    SETLOCAL ENABLEDELAYEDEXPANSION 
    
    @REM  ~f = remove quotes, full path
    set _TMP_PATH=%~f1

    @REM convert path to a list of quote-delimited strings, separated by spaces
    set _OLD_PATH="%PATH:;=" "%"
    set _NEW_PATH=

    @REM iterate through those path elements
    for %%i in (%_OLD_PATH%) do (
        @REM is this element NOT the one we want to remove?
        if /i NOT "%%~fi"=="%_TMP_PATH%" (
            set _NEW_PATH=!_NEW_PATH!%%~i;
        )
    )
    @REM remove trailing ; (adding ; in each iteration is necessary to keep 
    @REM the empty path in the PATH)
    set _NEW_PATH=%_NEW_PATH:~0,-1%
    echo set PATH=!_NEW_PATH!
    goto :eof
