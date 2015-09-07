REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

cmake cmake "%RECIPE_DIR%/src" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
cmake --build . --target emulate_c99 --config Release
cmake --build . --target INSTALL --config Release
