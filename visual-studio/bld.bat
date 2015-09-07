@echo on

REM create toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
if not exist "%TOOLSET_INFO_DIR%" mkdir "%TOOLSET_INFO_DIR%"

cat "%RECIPE_DIR%\common-vars.bat.in" ^
   | sed -e "s/@PKG_VERSION@/%PKG_VERSION%/g" ^
   > "%TOOLSET_INFO_DIR%\common-vars.bat"
   
cat "%RECIPE_DIR%\config.yaml.in" ^
   | sed -e "s/@PKG_VERSION@/%PKG_VERSION%/g" ^
         -e "s/@PKG_SHORT@/vc%PKG_VERSION:.0=%/g" ^
   > "%TOOLSET_INFO_DIR%\config.yaml"
   
copy "%RECIPE_DIR%\dos-tools.bat" "%TOOLSET_INFO_DIR%\"
   
call "%TOOLSET_INFO_DIR%\common-vars.bat"

REM install Visual Studio runtime libraries (msvcr, msvcp)
cmake "%RECIPE_DIR%" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
copy "%LIBRARY_PREFIX%\bin\msvc*.dll" "%PREFIX%"
if errorlevel 1 exit 1
