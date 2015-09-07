REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

set QTDIR=%PREFIX%\Qt4
set PATH=%LIBRARY_BIN%;%PATH%
set QMAKESPEC=%QTDIR%\mkspecs\win32-msvc%VISUAL_STUDIO_YEAR%

%DOS_TOOLS% :to_linux_path "%PREFIX%" PREFIX_LINUX
%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX
set PYTHON_PREFIX_SLASH=%PREFIX:\=\\%

REM vtk expects qt-tools in standard location
if not exist "%QTDIR%\bin" mkdir "%QTDIR%\bin"
copy "%LIBRARY_BIN%\moc.exe" "%QTDIR%\bin\"
copy "%LIBRARY_BIN%\uic.exe" "%QTDIR%\bin\"
copy "%LIBRARY_BIN%\rcc.exe" "%QTDIR%\bin\"

REM Notes:
REM  * HDF5 is needed for vtkNetCDF
REM  * --prefix=%PYTHON_PREFIX_SLASH% needs double-backslashes to work
cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DBUILD_EXAMPLES:BOOL=OFF ^
         -DBUILD_TESTING:BOOL=OFF ^
         -DBUILD_SHARED_LIBS:BOOL=ON ^
         -DVTK_USE_CHARTS:BOOL=ON ^
         -DVTK_USE_GEOVIS:BOOL=ON ^
         -DVTK_USE_INFOVIS:BOOL=ON ^
         -DVTK_USE_QT:BOOL=ON ^
         -DVTK_USE_QVTK_QTOPENGL:BOOL=ON ^
         -DVTK_USE_RENDERING:BOOL=ON ^
         -DVTK_USE_SYSTEM_FREETYPE:BOOL=ON ^
         -DVTK_USE_SYSTEM_HDF5:BOOL=ON ^
         -DVTK_USE_SYSTEM_JPEG:BOOL=ON ^
         -DVTK_USE_SYSTEM_PNG:BOOL=ON ^
         -DVTK_USE_SYSTEM_TIFF:BOOL=ON ^
         -DTIFF_LIBRARY:FILEPATH="%LIBRARY_PREFIX_LINUX%/lib/libtiff_i.lib" ^
         -DVTK_USE_SYSTEM_ZLIB:BOOL=ON ^
         -DVTK_WRAP_PYTHON:BOOL=ON ^
         -DVTK_WRAP_PYTHON_SIP:BOOL=ON ^
         -DVTK_USE_TK:BOOL=OFF ^
         -DVTK_WRAP_TCL:BOOL=OFF ^
         -DNETCDF_ENABLE_NETCDF4:BOOL=OFF ^
         -DHDF5_hdf5_LIBRARY:FILEPATH="%LIBRARY_PREFIX_LINUX%/lib/hdf5.lib" ^
         -DHDF5_hdf5_hl_LIBRARY:FILEPATH="%LIBRARY_PREFIX_LINUX%/lib/hdf5_hl.lib" ^
         -DVTK_INSTALL_QT_PLUGIN_DIR:STRING="%PREFIX_LINUX%/Qt4/plugins/designer" ^
         -DPYTHON_INCLUDE_DIR:PATH="%PREFIX_LINUX%/include" ^
         -DPYTHON_LIBRARY:FILEPATH="%PREFIX_LINUX%/libs/python27.lib" ^
         -DVTK_PYTHON_SETUP_ARGS:STRING=--prefix=%PYTHON_PREFIX_SLASH% ^
         -DSIP_INCLUDE_DIR:PATH="%PREFIX_LINUX%/include" ^
         -DSIP_PYQT_DIR:PATH="%PREFIX_LINUX%/sip-sources"
if errorlevel 1 exit 1
    
cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1
    
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
