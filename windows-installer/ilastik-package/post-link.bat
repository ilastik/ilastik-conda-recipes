if "%CONDA_ACTIVE_ENV%"=="" if NOT "%CONDA_DEFAULT_ENV%"=="" (
    set CONDA_ACTIVE_ENV=%CONDA_DEFAULT_ENV%
)

if "%CONDA_ACTIVE_ENV%"=="" (
    echo 'ilastik-package' cannot be installed into the root environment.
    echo Use 'activate environment-name' to switch to another environment.
    exit 1
)

if not exist tmp mkdir tmp
copy "%RECIPE_DIR%\read-version.py" tmp

python tmp\read-version.py "%PREFIX%\ilastik-meta\ilastik\ilastik\__init__.py" > tmp\version.txt
set /p ILASTIK_PKG_VERSION=<tmp\version.txt
echo "Building package for version %ILASTIK_PKG_VERSION%"

cd "%PREFIX%\package"

REM copy the ilastik version as our package version
cat ilastik.iss.in ^
    | sed -e "s/@VERSION@/%ILASTIK_PKG_VERSION%/g" ^
    > ilastik.iss
