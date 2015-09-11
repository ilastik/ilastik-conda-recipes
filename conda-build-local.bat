@echo off

REM call conda such that dependencies are taken from the local channel

FOR /F "delims=" %%i IN ('conda info --root') DO set CONDA_PATH=%%i
if errorlevel 1 exit 1

call set "CONDA_LOCAL_CHANNEL=file://%CONDA_PATH:\=/%/conda-bld"
echo Using local channel: "%CONDA_LOCAL_CHANNEL%"
conda build -c "%CONDA_LOCAL_CHANNEL%" --override-channels %*
