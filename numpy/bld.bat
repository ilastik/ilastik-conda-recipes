call "%RECIPE_DIR%\..\common-vars.bat"

patch -p0 -i "%RECIPE_DIR%\patch_numpy.patch"
if errorlevel 1 exit 1

rem the install path must have forward slashes
set DEPENDENCY_PREFIX=%LIBRARY_PREFIX%
setlocal enabledelayedexpansion
FOR %%f IN (%DEPENDENCY_PREFIX%) DO (
  set "f=%%f"
  set "DEPENDENCY_PREFIX=!f:\=/!"
)
cat "%RECIPE_DIR%/site.cfg.in" | sed -e "s@${DEPENDENCY_PREFIX}@%DEPENDENCY_PREFIX%@g" > site.cfg
if errorlevel 1 exit 1

python setup.py build -c msvc install
if errorlevel 1 exit 1
