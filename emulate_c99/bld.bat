call "%RECIPE_DIR%\..\common-vars.bat"

cmake cmake "%RECIPE_DIR%/src" -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
cmake --build . --target emulate_c99 --config Release
cmake --build . --target INSTALL --config Release
