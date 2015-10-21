REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

if not exist "%PREFIX%\Library\src" mkdir "%PREFIX%\Library\src"
cd "%PREFIX%\Library\src"

git clone https://github.com/ukoethe/vigra
if errorlevel 1 exit 1

cd vigra
git checkout master
if errorlevel 1 exit 1

if not exist build mkdir build
cd build

cmake .. -G "%CMAKE_GENERATOR%" ^
    -DDEPENDENCY_SEARCH_PREFIX="%PREFIX%\Library" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library"
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
