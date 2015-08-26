call "%RECIPE_DIR%\..\common-vars.bat"

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
