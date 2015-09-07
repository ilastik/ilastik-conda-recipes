REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

REM The git hash is prefixed with 'g' for some stupid reason.
git checkout %GIT_DESCRIBE_HASH:~1% 
if errorlevel 1 exit 1
git submodule update --recursive
if errorlevel 1 exit 1

if not exist tmp mkdir tmp
copy "%RECIPE_DIR%\read-version.py" tmp

REM Verify that the git tag and the python version match (a common error).
%DOS_TOOLS% :capture_output "python tmp\read-version.py ilastik/ilastik/__init__.py" ILASTIK_CODE_VERSION

if not "%ILASTIK_CODE_VERSION%"=="%PKG_VERSION%" ( 
    echo ********************************************************************************
    echo ilastik-meta package version does not match __version_info__ in ilastik/__init__.py
    echo ilastik-meta version:      %PKG_VERSION%
    echo ilastik.__version_info__:  %ILASTIK_CODE_VERSION%
    echo ********************************************************************************
    exit 1
)

REM Create .pyc files
python -m compileall lazyflow volumina ilastik
if errorlevel 1 exit 1

REM Add the ilastik modules to sys.path
copy "%RECIPE_DIR%\ilastik-meta.pth.win" "%PREFIX%\Lib\site-packages\ilastik-meta.pth"
if errorlevel 1 exit 1

REM Install the ilastik modules
xcopy /S lazyflow "%PREFIX%\ilastik-meta\lazyflow\"
if errorlevel 1 exit 1
xcopy /S volumina "%PREFIX%\ilastik-meta\volumina\"
if errorlevel 1 exit 1
xcopy /S ilastik "%PREFIX%\ilastik-meta\ilastik\"
if errorlevel 1 exit 1
copy Readme* "%PREFIX%\ilastik-meta\"
if errorlevel 1 exit 1
copy "%RECIPE_DIR%\run-ilastik.bat" "%PREFIX%\"
if errorlevel 1 exit 1
