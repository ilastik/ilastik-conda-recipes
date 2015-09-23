@echo off

REM ask conda for the installed version of ilastik-meta
set ILASTIK_PKG_VERSION=
FOR /F "delims=" %%i IN ('conda list -n "%CONDA_DEFAULT_ENV%" ^| grep ilastik-meta ^| awk "{ print $2; }" ') DO set ILASTIK_PKG_VERSION=%%i
if errorlevel 1 (
    echo ilastik-meta not found by 'conda list -n "%CONDA_DEFAULT_ENV%"'.
    exit 1
)
if "%ILASTIK_PKG_VERSION%"=="" (
    echo ilastik-meta not found by 'conda list -n "%CONDA_DEFAULT_ENV%"'.
    exit 1
)

REM ask ilastik which version it actually is
set ILASTIK_CODE_VERSION=
FOR /F "delims=" %%i IN ('python -c "import ilastik; print ilastik.__version__" ') DO set ILASTIK_CODE_VERSION=%%i
if errorlevel 1  (
    echo Python cannot 'import ilastik'
    exit 1
)
if "%ILASTIK_CODE_VERSION%"=="" (
    echo Python cannot 'import ilastik'
    exit 1
)

REM Verify that the two versions match (a common error that occurs
REM when ilastik was updated outside of conda's control)
if not "%ILASTIK_CODE_VERSION%"=="%ILASTIK_PKG_VERSION%" ( 
    echo ********************************************************************************
    echo ilastik-meta package version does not match __version_info__ in ilastik/__init__.py
    echo ilastik-meta version:      %ILASTIK_PKG_VERSION%
    echo ilastik.__version_info__:  %ILASTIK_CODE_VERSION%
    echo ********************************************************************************
    exit 1
)

echo found ilastik version: %ILASTIK_PKG_VERSION%
