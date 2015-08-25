REM Utility library for Windows install scripts. Usage:
REM    call dos-tools.bat  :subroutine  arg1  arg2
call %*
goto :eof

REM convert backward slashes to forward slashes
REM   :to_linux_path path OUT_VAR
:to_linux_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:\=/%"
    goto :EOF
    
REM convert forward slashes to backward slashes
REM   :to_dos_path path OUT_VAR
:to_dos_path
    set _TMP_PATH=%~1
    call set "%~2=%_TMP_PATH:/=\%"
    goto :EOF
