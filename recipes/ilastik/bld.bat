REM The git hash is prefixed with 'g' for some stupid reason.
git checkout %GIT_DESCRIBE_HASH:~1%
if errorlevel 1 exit 1
git submodule update --recursive
if errorlevel 1 exit 1

if not exist tmp mkdir tmp
copy "%RECIPE_DIR%\read-version.py" tmp

REM Verify that the git tag and the python version match (a common error).
python tmp\read-version.py "ilastik/ilastik/__init__.py" > tmp\version.txt
set /p ILASTIK_CODE_VERSION=<tmp\version.txt

if not "%ILASTIK_CODE_VERSION%"=="%PKG_VERSION%" (
    echo ********************************************************************************
    echo ilastik tagged version does not match __version_info__ in ilastik/__init__.py
    echo ilastik tag version:      %PKG_VERSION%
    echo ilastik.__version_info__:  %ILASTIK_CODE_VERSION%
    echo ********************************************************************************
    exit 1
)

REM Create .pyc files
python -m compileall ilastik
rem if errorlevel 1 exit 1

REM Add the ilastik modules to sys.path
copy "%RECIPE_DIR%\ilastik.pth.win" "%PREFIX%\Lib\site-packages\ilastik.pth"
if errorlevel 1 exit 1

REM Install the ilastik modules
xcopy /S ilastik "%PREFIX%\ilastik\ilastik\"
if errorlevel 1 exit 1
copy Readme* "%PREFIX%\ilastik-meta\"
if errorlevel 1 exit 1
