REM configure
if %ARCH%==32 (
    set PYTHON_BITNESS=Win32
    set PYTHON_BIN=.
    set PYTHON_EXE=.\python.exe
) else (
    set PYTHON_BITNESS=x64
    set PYTHON_BIN=./amd64
    set PYTHON_EXE=.\amd64\python.exe
)

REM build directory is predetermined by Python distro
cd PCbuild

REM upgrade sln-file to current compiler version
devenv PCbuild.sln /upgrade
if errorlevel 1 exit 1

REM compile Python and built-in packages
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project Python
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _ctypes
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _elementtree
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _multiprocessing
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _socket
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project pyexpat
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project select
if errorlevel 1 exit 1
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project unicodedata
if errorlevel 1 exit 1
REM bz2 source is not included in the Python tar ball, skip it for now
REM FIXME: provide a recipe for bz2
REM devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project bz2
REM if errorlevel 1 exit 1

REM patch distutils for Visual Studio 2012
"%PYTHON_EXE%" "%RECIPE_DIR%/patch_python.py" ../Lib/distutils/msvc9compiler.py ../Lib/distutils/cygwinccompiler.py
if errorlevel 1 exit 1

REM install directly into %PREFIX% (Conda convention on Windows)
cmake -DPYTHON_BIN="%PYTHON_BIN%" -DPYTHON_INSTALL_PREFIX="%PREFIX%" -P "%RECIPE_DIR%/python_install.cmake" 
if errorlevel 1 exit 1
