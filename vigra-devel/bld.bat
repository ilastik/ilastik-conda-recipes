REM create pre-unlink.bat
type "%RECIPE_DIR%\..\check_and_delete_git_repo.bat.in" ^
   | sed -e "s$@REPO_REL_PATH@$Library\\\\src\\\\vigra$g" ^
   > "%RECIPE_DIR%\pre-unlink.bat"

REM Checkout will be done in post-link.bat
