REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

REM Copy the ilastik version as our package version
conda list -n _build | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]" > __conda_version__.txt
%DOS_TOOLS% :capture_output "cat __conda_version__.txt" ILASTIK_PKG_VERSION

if not exist "%PREFIX%\package" mkdir "%PREFIX%\package"
cat "%RECIPE_DIR%\ilastik.iss.in" ^
    | sed -e "s/@VERSION@/%ILASTIK_PKG_VERSION%/g" ^
    > "%PREFIX%\package\ilastik.iss"
copy "%RECIPE_DIR%\ilastik-icon.ico" "%PREFIX%\package"
copy "%RECIPE_DIR%\ilastik-installer-small.bmp" "%PREFIX%\package"
copy "%RECIPE_DIR%\ilastik-installer.bmp" "%PREFIX%\package"
copy "%RECIPE_DIR%\..\LICENSE.txt" "%PREFIX%"

REM append compiler version to package version
echo %ILASTIK_PKG_VERSION%.vc%VISUALSTUDIOVERSION:.0=% > __conda_version__.txt
