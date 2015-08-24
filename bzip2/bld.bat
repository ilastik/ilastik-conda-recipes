if NOT EXIST "%PREFIX%\externals" mkdir "%PREFIX%\externals"
if errorlevel 1 exit 1
xcopy /S * "%PREFIX%\externals\bzip2-%PKG_VERSION%\"
if errorlevel 1 exit 1
del "%PREFIX%\externals\bzip2-%PKG_VERSION%\bld.bat"
if errorlevel 1 exit 1
