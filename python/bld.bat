cd PCbuild

if %ARCH%==32 (
    set PYTHON_BITNESS=Win32
    set PYTHON_EXE=.\python.exe
) else (
    set PYTHON_BITNESS=x64
    set PYTHON_EXE=.\amd64\python.exe
)

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
devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project bz2
if errorlevel 1 exit 1

REM patch distutils for Visual Studio 2012
"%PYTHON_EXE%" "%RECIPE_DIR%/patch_python.py" ../Lib/distutils/msvc9compiler.py ../Lib/distutils/cygwinccompiler.py
