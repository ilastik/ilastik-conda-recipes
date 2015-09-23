REM install consistency checker
copy "%RECIPE_DIR%\ilastik-version-check.bat" "%PREFIX%\toolset-info\ilastik-version-check.bat"

REM check if ilastik is consistent (sets ILASTIK_PKG_VERSION if so)
call "%PREFIX%\toolset-info\ilastik-version-check.bat"

REM prepend ilastik version to given package version (= toolset suffix)
echo %ILASTIK_PKG_VERSION%%PKG_VERSION% > __conda_version__.txt
