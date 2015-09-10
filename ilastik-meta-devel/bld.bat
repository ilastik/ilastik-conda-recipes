REM Add the ilastik modules to sys.path
if not exist "%PREFIX%\Lib\site-packages" mkdir "%PREFIX%\Lib\site-packages"
copy "%RECIPE_DIR%\ilastik-meta.pth.win" "%PREFIX%\Lib\site-packages\ilastik-meta.pth"
if errorlevel 1 exit 1

REM Checkout will be done in post-link.bat
