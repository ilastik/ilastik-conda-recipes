REM Add the ilastik modules to sys.path
if not exist "%PREFIX%\Lib\site-packages" mkdir "%PREFIX%\Lib\site-packages"
copy "%RECIPE_DIR%\ilastik-meta.pth.win" "%PREFIX%\Lib\site-packages\ilastik-meta.pth"
if errorlevel 1 exit 1

REM create pre-unlink.bat
type "%RECIPE_DIR%\..\check_and_delete_git_repo.bat.in" ^
   | sed -e "s$@REPO_REL_PATH@$ilastik-meta$g" ^
   > "%RECIPE_DIR%\pre-unlink.bat"

REM Checkout will be done in post-link.bat
