call "%RECIPE_DIR%\..\common-vars.bat"

REM Copy the ilastik version as our package version
conda list -n _build | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]" > __conda_version__.txt
%DOS_TOOLS% :capture_output "cat __conda_version__.txt" ILASTIK_PKG_VERSION

REM Verify that the git tag and the python version match (a common error).
copy "%RECIPE_DIR%\read-version.py" .
%DOS_TOOLS% :capture_output "python read-version.py" ILASTIK_CODE_VERSION

if not "%ILASTIK_CODE_VERSION%"=="%ILASTIK_PKG_VERSION%" ( 
    echo ********************************************************************************
    echo ilastik-meta package version does not match __version_info__ in ilastik/__init__.py
    echo ilastik-meta version:      %ILASTIK_PKG_VERSION%
    echo ilastik.__version_info__:  %ILASTIK_CODE_VERSION%
    echo ********************************************************************************
    exit 1
)

REM append compiler version to package version
echo %ILASTIK_PKG_VERSION%.vc%VISUALSTUDIOVERSION:.0=% > __conda_version__.txt
