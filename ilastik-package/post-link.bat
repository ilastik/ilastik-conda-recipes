if "%CONDA_ACTIVE_ENV%"=="" if NOT "%CONDA_DEFAULT_ENV%"=="" (
    set CONDA_ACTIVE_ENV=%CONDA_DEFAULT_ENV%
)

if "%CONDA_ACTIVE_ENV%"=="" (
    echo 'ilastik-package' cannot be installed into the root environment.
    echo Use 'activate environment-name' to switch to another environment.
    exit 1
)

REM check if ilastik is consistent (sets ILASTIK_PKG_VERSION if so)
call "%PREFIX%\toolset-info\ilastik-version-check.bat"

cd "%PREFIX%\package"

REM copy the ilastik version as our package version
cat ilastik.iss.in ^
    | sed -e "s/@VERSION@/%ILASTIK_PKG_VERSION%/g" ^
    > ilastik.iss
