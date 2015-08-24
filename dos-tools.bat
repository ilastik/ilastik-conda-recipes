REM Utility library for Windows install scripts. Usage:
REM    call dos-tools.bat  :subroutine  arg1  arg2
call %*
goto :eof

REM convert backward slashes to forward slashes
REM   :to_linux_path path OUT_VAR
:to_linux_path
    FOR %%f IN (%1) DO (
      set "f=%%f"
      call set "%~2=%f:\=/%"
    )
    goto :EOF
    
REM convert forward slashes to backward slashes
REM   :to_dos_path path OUT_VAR
:to_dos_path
    FOR %%f IN (%1) DO (
      set "f=%%f"
      call set "%~2=%f:/=\%"
    )
    goto :EOF
