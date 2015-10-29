REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

"%MSYS_PATH%\patch.exe" -p0 -i "%RECIPE_DIR%\patch_protobuf.patch"

mkdir cmake\build
cd cmake\build

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -Dprotobuf_BUILD_TESTS=OFF ^
         -Dprotobuf_BUILD_SHARED_LIBS=ON ^
         -Dprotobuf_MSVC_STATIC_RUNTIME=OFF ^
         -Dprotobuf_WITH_ZLIB=ON
if errorlevel 1 exit 1

cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1

REM INSTALL
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

cd ..\..\python
python setup.py install
