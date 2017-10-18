REM build ilastik.exe
mkdir build
cd build

cmake "%RECIPE_DIR%\ilastik_launch" ^
        -G "%CMAKE_GENERATOR%" ^
        -DCMAKE_INSTALL_PREFIX="%PREFIX%"
if errorlevel 1 exit 1

cmake --build . --target ilastik --config Release
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

copy "%RECIPE_DIR%\run-ilastik.bat" "%PREFIX%\"
if errorlevel 1 exit 1
