REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

gendef "%PREFIX%\python27.dll"
dlltool --dllname "%PREFIX%\python27.dll" --def python27.def --output-lib "%PREFIX%\libs\libpython27.a"

python setup.py install
