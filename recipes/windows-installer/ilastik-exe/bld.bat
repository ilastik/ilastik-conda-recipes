REM build ilastik.exe
mkdir build
cd build

set CONFIGURATION=Release

cmake "%RECIPE_DIR%\ilastik_launch" ^
        -G "NMake Makefiles" ^
        -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
        -DCMAKE_INSTALL_PREFIX="%PREFIX%"
if errorlevel 1 exit 1

nmake ilastik
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

copy "%RECIPE_DIR%\run-ilastik.bat" "%PREFIX%\"
if errorlevel 1 exit 1
