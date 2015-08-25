call "%RECIPE_DIR%\..\common-vars.bat"

patch -p0 -i "%RECIPE_DIR%\patch_numpy.patch"
if errorlevel 1 exit 1

rem the dependency path must have forward slashes
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" DEPENDENCY_PREFIX
cat "%RECIPE_DIR%/site.cfg.in" | sed -e "s@${DEPENDENCY_PREFIX}@%DEPENDENCY_PREFIX%@g" > site.cfg
if errorlevel 1 exit 1

python setup.py build -c msvc install
if errorlevel 1 exit 1
