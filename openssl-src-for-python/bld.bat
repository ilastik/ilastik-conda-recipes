set VERSION=%PKG_VERSION:post.=%

if NOT EXIST "%PREFIX%\externals" mkdir "%PREFIX%\externals"
if errorlevel 1 exit 1
xcopy /S * "%PREFIX%\externals\openssl-%VERSION%\"
if errorlevel 1 exit 1
del "%PREFIX%\externals\openssl-%VERSION%\bld.bat"
if errorlevel 1 exit 1
