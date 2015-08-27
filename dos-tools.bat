REM Utility library for Windows install scripts. Usage:
REM    call dos-tools.bat  :subroutine  arg1  arg2
call %*
goto :eof

REM convert backward slashes to forward slashes
REM   :to_linux_path "path" OUT_VAR
:to_linux_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:\=/%"
    if "%_TMP_PATH%"=="" set %~2=
    goto :EOF
    
REM convert forward slashes to backward slashes
REM   :to_dos_path "path" OUT_VAR
:to_dos_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:/=\%"
    if "%_TMP_PATH%"=="" set %~2=
    goto :EOF
    
REM capture the output of a command (like backticks in sh)
REM   :capture_output "command" OUT_VAR
:capture_output
    set %~2=
    FOR /F "delims=" %%i IN ('%~1') DO set %~2=%%i
    goto :EOF

REM check if the given path contains "msysinfo"
REM   :find_msys_make "path\make.exe" OUT_VAR
:find_msys_make
    set _TMP_PATH=%~1
    call set "_TMP_PATH=%_TMP_PATH:\make.exe=%"
    if exist "%_TMP_PATH%\msysinfo" set %~2=%_TMP_PATH%
    goto :eof
