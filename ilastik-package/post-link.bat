REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

cd "%PREFIX%\package"

if "%CONDA_DEFAULT_ENV%"=="" (
    echo 'ilastik-package' cannot be installed into the root environment.
    echo Use 'activate <environment-name>' to switch to another environment.
    exit 1
)

REM Copy the ilastik version as our package version
%DOS_TOOLS% :capture_output "python read-version.py" ILASTIK_CODE_VERSION

if "%ILASTIK_CODE_VERSION%"=="" (
    echo ilastik-meta not found by 'conda list -n %CONDA_DEFAULT_ENV%'.
    echo Use 'conda install ilastik-everything' to install ilastik.
    exit 1
)

cat ilastik.iss.in ^
    | sed -e "s/@VERSION@/%ILASTIK_CODE_VERSION%/g" ^
    > ilastik.iss
