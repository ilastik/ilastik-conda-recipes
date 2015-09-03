call "%RECIPE_DIR%\..\common-vars-mingw.bat"

REM MSYS\bin must not be in the PATH (conflicts with ActiveState perl.exe)
%DOS_TOOLS% :remove_from_PATH "%MSYS_PATH%"

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

REM %LIBRARY_BIN% contains nasm (needed for openssl)
set PATH=%PATH%;%LIBRARY_BIN%

REM build expects external sources in the "externals" directory
xcopy /S "%PREFIX%\externals" externals\
if errorlevel 1 exit 1

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

"%PYTHON_EXE%" "%RECIPE_DIR%/patch_python_externals.py"
if errorlevel 1 exit 1

devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project bz2
if errorlevel 1 exit 1

devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _ssl
if errorlevel 1 exit 1

devenv PCbuild.sln /build "Release|%PYTHON_BITNESS%" /project _sqlite3
if errorlevel 1 exit 1

REM patch distutils for Visual Studio 2012
"%PYTHON_EXE%" "%RECIPE_DIR%/patch_python.py" ../Lib/distutils/msvc9compiler.py ../Lib/distutils/cygwinccompiler.py
if errorlevel 1 exit 1

REM install directly into %PREFIX% (Conda convention on Windows)
cmake -DPYTHON_BIN="%PYTHON_BIN%" -DPYTHON_INSTALL_PREFIX="%PREFIX%" -P "%RECIPE_DIR%/python_install.cmake" 
if errorlevel 1 exit 1
