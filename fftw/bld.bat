REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

if %ARCH%==32 (
    set CONFIGURATION="Release|Win32"
    set FFTW_BUILD_DIR=.
) else (
    set CONFIGURATION="Release|x64"
    set FFTW_BUILD_DIR=x64
)


REM Use outdated solution from
REM ftp://ftp.fftw.org/pub/fftw/fftw-3.3-libs-visual-studio-2010.zip
REM %PYTHON% "%RECIPE_DIR%/patch_fftw_win.py" .

REM cd fftw-3.3-libs

REM devenv fftw-3.3-libs.sln /upgrade
REM if errorlevel 1 exit 1

REM REM BUILD
REM devenv fftw-3.3-libs.sln /build %CONFIGURATION% /project libfftw-3.3
REM if errorlevel 1 exit 1
REM devenv fftw-3.3-libs.sln /build %CONFIGURATION% /project libfftwf-3.3
REM if errorlevel 1 exit 1

REM REM INSTALL
REM cmake -DFFTW_BUILD_DIR="%FFTW_BUILD_DIR%" -DFFTW_INSTALL_PREFIX="%LIBRARY_PREFIX%" -P "%RECIPE_DIR%/fftw_install.cmake"
REM if errorlevel 1 exit 1

REM Use hand-made cmake
copy "%RECIPE_DIR%\cmake\CMakeLists.txt" .
copy "%RECIPE_DIR%\cmake\config.h" .

mkdir build
cd build
cmake .. -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"
cmake --build . --target INSTALL --config Release
