if not exist "%PREFIX%\package" mkdir "%PREFIX%\package"

copy "%RECIPE_DIR%\ilastik.iss.in" "%PREFIX%\package"
copy "%RECIPE_DIR%\ilastik-icon.ico" "%PREFIX%\package"
copy "%RECIPE_DIR%\ilastik-installer-*.bmp" "%PREFIX%\package"
copy "%RECIPE_DIR%\LICENSE.txt" "%PREFIX%"
