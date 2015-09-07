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

%PYTHON% "%RECIPE_DIR%/patch_fftw_win.py" .

cd fftw-3.3-libs

devenv fftw-3.3-libs.sln /upgrade
if errorlevel 1 exit 1

REM BUILD
devenv fftw-3.3-libs.sln /build %CONFIGURATION% /project libfftw-3.3
if errorlevel 1 exit 1
devenv fftw-3.3-libs.sln /build %CONFIGURATION% /project libfftwf-3.3
if errorlevel 1 exit 1

REM INSTALL
cmake -DFFTW_BUILD_DIR="%FFTW_BUILD_DIR%" -DFFTW_INSTALL_PREFIX="%LIBRARY_PREFIX%" -P "%RECIPE_DIR%/fftw_install.cmake" 
if errorlevel 1 exit 1
