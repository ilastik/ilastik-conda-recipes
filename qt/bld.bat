call "%RECIPE_DIR%\..\common-vars.bat"

cat src/gui/image/qjpeghandler.pri | sed -e "s@win32: *LIBS += libjpeg.lib@win32:          LIBS += jpeg.lib@g" > out.patch
if errorlevel 1 exit 1
move out.patch src/gui/image/qjpeghandler.pri
if errorlevel 1 exit 1

cat src/gui/image/qpnghandler.pri | sed -e "s@win32: *LIBS += libpng.lib@win32:          LIBS += libpng15.lib@g" > out.patch
if errorlevel 1 exit 1
move out.patch src/gui/image/qpnghandler.pri
if errorlevel 1 exit 1

cat src/gui/image/qtiffhandler.pri | sed -e "s@win32: *LIBS += libtiff.lib@win32:          LIBS += libtiff_i.lib@g" > out.patch
if errorlevel 1 exit 1
move out.patch src/gui/image/qtiffhandler.pri
if errorlevel 1 exit 1

cat src/3rdparty/zlib_dependency.pri | sed -e "s@LIBS += zdll.lib@LIBS += zlib.lib@g" > out.patch
if errorlevel 1 exit 1
move out.patch src/3rdparty/zlib_dependency.pri
if errorlevel 1 exit 1

cat src/tools/bootstrap/bootstrap.pri | sed -e "s@LIBS += zdll.lib@LIBS += zlib.lib@g" > out.patch
if errorlevel 1 exit 1
move out.patch src/tools/bootstrap/bootstrap.pri
if errorlevel 1 exit 1

REM seems to be fixed in release 4.8.6
REM if %VISUAL_STUDIO_VERSION%==11.0 (
    REM patch -p0 -i "%RECIPE_DIR%\patches\qt_hashset_bug.patch"
REM )

set QTDIR=%CD%
set QT_PREFIX=%PREFIX%\Qt4
set PATH=%QTDIR%\bin;%LIBRARY_BIN%;%PATH%

rem configure
rem
rem Options "--prefix" and "-optimized-qmake" are not available on Windows!
rem -no-webkit should be removed when Spyder is to be built
rem
echo yes | configure -opensource -platform win32-msvc%VISUAL_STUDIO_YEAR% -I "%LIBRARY_INC%" -L "%LIBRARY_LIB%" -mp -nomake examples -nomake demos -nomake docs -nomake translations -no-multimedia -no-webkit -no-audio-backend -no-phonon -no-phonon-backend -no-sql-sqlite -no-sql-sqlite2 -no-sql-psql -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-tds -no-dbus -no-cups -no-nis -no-qt3support -release -shared -no-accessibility -system-zlib -system-libpng -system-libjpeg -system-libtiff
if errorlevel 1 exit 1

rem build
nmake
if errorlevel 1 exit 1

rem install (src and tools directory are needed by PyQt)
nmake clean
FOR %%i IN (imports include lib mkspecs phrasebooks plugins src qmake tools) DO xcopy /S %%i "%QT_PREFIX%\%%i\"
if errorlevel 1 exit 1

xcopy /S bin "%LIBRARY_BIN%\"
if errorlevel 1 exit 1

REM qt.conf contains the relative path between qmake and <qtroot>
REM to make the Qt installation relocatable
echo [Paths] > "%LIBRARY_BIN%\qt.conf"
echo Prefix = ..\\..\\Qt4 >> "%LIBRARY_BIN%\\qt.conf"
if errorlevel 1 exit 1
