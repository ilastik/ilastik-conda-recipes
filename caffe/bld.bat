REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

"%MSYS_PATH%\patch" -p0 -i "%RECIPE_DIR%\patch_caffe.patch"
if errorlevel 1 exit 1

mkdir build
cd build

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
         -DUSE_OPENCV=0 ^
         -DUSE_LMDB=0 ^
         -DUSE_LEVELDB=0 ^
         -DGFLAGS_LIBRARY_RELEASE="%LIBRARY_LIB%\gflags.lib" ^
         -DGFLAGS_LIBRARY_DEBUG="%LIBRARY_LIB%\gflags.lib" ^
         -DGLOG_LIBRARY_RELEASE="%LIBRARY_LIB%\glog.lib" ^
         -DGLOG_LIBRARY_DEBUG="%LIBRARY_LIB%\glog.lib" ^
         -DBLAS=Open ^
         -DOpenBLAS_LIB="%LIBRARY_LIB%\libopenblas.lib" ^
         -DOpenBLAS_INCLUDE_DIR="%LIBRARY_INC%" ^
         -DPYTHON_EXECUTABLE="%PREFIX%\python.exe" ^
         -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib"
if errorlevel 1 exit 1

REM For unknown reasons, undesired log output finds its way
REM into CMakeCache.txt => remove to make the build work.
cat CMakeCache.txt ^
    | sed -e "s@   Creating library a.lib and object a.exp@@" ^
          -e "s@2.1(2.0)@@" ^
    > CMakeCache.txt.patched
move CMakeCache.txt.patched CMakeCache.txt
if errorlevel 1 exit 1

cmake --build . --target caffe --config Release
if errorlevel 1 exit 1

cmake --build . --target pycaffe --config Release
if errorlevel 1 exit 1

REM INSTALL
xcopy /S lib\Release\*.lib "%LIBRARY_LIB%\"
xcopy /S bin\Release\*.dll "%LIBRARY_BIN%\"
xcopy /S bin\Release\*.exe "%LIBRARY_BIN%\"
xcopy /S bin\Release\*.pyd "%SP_DIR%\caffe\"
xcopy include\caffe\proto\caffe_pb2.py "%SP_DIR%\caffe\proto\"
xcopy __init__.py "%SP_DIR%\caffe\proto\"

cd ..
xcopy /S include\caffe "%LIBRARY_INC%\caffe\"
xcopy /S python\caffe "%SP_DIR%\caffe\"
del /Q /F "%SP_DIR%\caffe\*.cpp"
if errorlevel 1 exit 1
