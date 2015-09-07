REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "%CMAKE_GENERATOR%" ^
        -DBUILD_SHARED_LIBS:BOOL=ON ^
        -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
        -DHDF5_BUILD_HL_LIB:BOOL=ON ^
        -DBUILD_SHARED_LIBS:BOOL=ON ^
        -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON ^
        -DZLIB_INCLUDE_DIR:PATH="%LIBRARY_INC%" ^
        -DZLIB_LIBRARY:FILEPATH="%LIBRARY_LIB%/zlib.lib"  ^
        -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

REM BUILD
cmake --build . --target hdf5 --config %CONFIGURATION%
cmake --build . --target hdf5_hl --config %CONFIGURATION%
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config %CONFIGURATION%
if errorlevel 1 exit 1
