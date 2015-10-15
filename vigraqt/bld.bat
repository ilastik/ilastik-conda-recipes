REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

%DOS_TOOLS% :to_linux_path "%RECIPE_DIR%/patch_vigraqt.py" PATCH_FILE
%DOS_TOOLS% :to_linux_path "%CD%" CWD
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" DEPENDENCY_PATH
%DOS_TOOLS% :to_linux_path "%PREFIX%" PREFIX_PATH

python "%PATCH_FILE%" "%CWD%" "%DEPENDENCY_PATH%"
if errorlevel 1 exit 1

cd src\vigraqt
qmake INSTALLBASE="%DEPENDENCY_PATH%"
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1

cd ..\sip
sip -c . -b VigraQt.sbf -x VendorID -t WS_WIN -t Qt_4_8_6 -x PyQt_Accessibility -x PyQt_OpenSSL -x Py_v3 -I "%PREFIX_PATH%/sip-sources" vigraqtmod.sip
if errorlevel 1 exit 1

set SITE_PACKAGES=%SP_DIR:\=\\\\%
cat "%RECIPE_DIR%\Makefile.in" ^
   | sed -e "s$@PREFIX@$%PREFIX_PATH%$g" ^
   | sed -e "s$@SITE_PACKAGES@$%SITE_PACKAGES%$g" ^
   > Makefile
nmake
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
