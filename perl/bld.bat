REM extend toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
copy "%RECIPE_DIR%\perl-vars.bat" "%TOOLSET_INFO_DIR%\"

call "%TOOLSET_INFO_DIR%\perl-vars.bat"
