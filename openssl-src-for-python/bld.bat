if NOT EXIST "%PREFIX%\externals" mkdir "%PREFIX%\externals"
if errorlevel 1 exit 1
xcopy /S * "%PREFIX%\externals\openssl-%PKG_VERSION%\"
if errorlevel 1 exit 1
del "%PREFIX%\externals\openssl-%PKG_VERSION%\bld.bat"
if errorlevel 1 exit 1
