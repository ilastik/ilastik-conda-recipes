call "%RECIPE_DIR%\..\common-vars.bat"

REM FIXME: pyqt needs mt.exe (manifest tool) -- add an explicit dependency
REM (on my machine, it resides in "c:\Program Files (x86)\Windows Kits\8.0\bin\x64")

set QTDIR=%PREFIX%\Qt4
set PATH=%LIBRARY_BIN%;%PATH%
set QMAKESPEC=%QTDIR%\mkspecs\win32-msvc%VISUAL_STUDIO_YEAR%

%DOS_TOOLS% :to_linux_path "%PREFIX%\sip-sources" SIP_SOURCES_PATH

REM note: newer PyQt uses configure-ng.py instead of configure.py
python configure-ng.py --confirm-license --sipdir="%SIP_SOURCES_PATH%"
if errorlevel 1 exit 1

REM sip hard-codes the location of moc.exe
mkdir "%QTDIR%\bin"
copy "%LIBRARY_BIN%\moc.exe" "%QTDIR%\bin\"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
