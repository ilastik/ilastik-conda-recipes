@echo off

REM call conda such that dependencies are taken from the local channel
FOR /F "delims=" %%i IN ('conda info --root') DO set CONDA_PATH=%%i
if "%CONDA_PATH%"=="" (
    echo Error: conda not found
    exit /B 0
)

call set "CONDA_LOCAL_CHANNEL=file://%CONDA_PATH:\=/%/conda-bld"
echo Using local channel: "%CONDA_LOCAL_CHANNEL%"

call :%*
goto :eof

:build
    cmd /C conda build -c "%CONDA_LOCAL_CHANNEL%" --override-channels %*
    goto :eof

:install
    cmd /C conda install -c "%CONDA_LOCAL_CHANNEL%" --override-channels %*
    goto :eof

:create
    cmd /C conda create -c "%CONDA_LOCAL_CHANNEL%" --override-channels %*
    goto :eof

:index
    cmd /C conda index "%CONDA_PATH%\conda-bld\win-64"
    goto :eof
