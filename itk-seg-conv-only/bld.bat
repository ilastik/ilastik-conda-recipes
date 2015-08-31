set SRC_DIR=%CD%

call "%RECIPE_DIR%\..\common-vars.bat"

REM lift the ITK path length restriction to 200
cat CMakeLists.txt ^
   | sed -e "s@n GREATER 50@n GREATER 200@g" ^
   > CMakeLists.txt.patched
if errorlevel 1 exit 1
move CMakeLists.txt.patched CMakeLists.txt
if errorlevel 1 exit 1

mkdir build
cd build

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" LIBRARY_PREFIX_LINUX

cmake .. -G "%CMAKE_GENERATOR%" ^
         -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX_LINUX%" ^
         -DBUILD_SHARED_LIBS:BOOL=ON ^
         -DBUILD_TESTING:BOOL=OFF ^
         -DITK_BUILD_DEFAULT_MODULES=0 ^
         -DBUILD_EXAMPLES=0 ^
         -DITKGroup_Core=1 ^
         -DITKGroup_Segmentation=1 ^
         -DModule_ITKConvolution=1 ^
         -DModule_ITKEigen=1 ^
         -DITK_USE_SYSTEM_HDF5=ON ^
         -DHDF5_C_LIBRARY:FILEPATH="%LIBRARY_PREFIX_LINUX%/lib/hdf5.lib" ^
         -DHDF5_DIR:PATH="%LIBRARY_PREFIX_LINUX%/cmake/hdf5" ^
         -DITK_USE_SYSTEM_PNG=ON ^
         -DPNG_LIBRARY="%LIBRARY_PREFIX_LINUX%/lib/libpng15.lib" ^
         -DITK_USE_SYSTEM_JPEG=ON ^
         -DJPEG_LIBRARY="%LIBRARY_PREFIX_LINUX%/lib/jpeg.lib" ^
         -DITK_USE_SYSTEM_TIFF=ON ^
         -DTIFF_LIBRARY:FILEPATH="%LIBRARY_PREFIX_LINUX%/lib/libtiff_i.lib" ^
         -DITK_USE_SYSTEM_ZLIB=ON ^
         -DZLIB_LIBRARY="%LIBRARY_PREFIX_LINUX%/lib/zlib.lib"
if errorlevel 1 exit 1

REM work-around for a Visual Studio bug: 
REM MSBuild.exe seems to garble long relative paths to source files.
REM Therefore, we replace long relative paths in vcxproj-files with 
REM absolute paths. Under some conditions, cmake seems to do this
REM automatically (if the absolute path is shorter?), but not here. 
REM FIXME: improve fix for long relative paths in MSBuild
set RE=..\..\..\..\..\..\..\..\\
set RE=%RE:\=\\%
set RE=%RE:.=\.%
echo RE:"%RE%"
set REPLACE=%SRC_DIR:\=\\\\%
echo REPLACE:"%REPLACE%"
set PATCH_FILE=Modules\ThirdParty\GDCM\src\gdcm\Source\DataStructureAndEncodingDefinition\gdcmDSED.vcxproj
cat "%PATCH_FILE%" ^
   | sed -e "s@\"%RE%Modules@\"%REPLACE%\\\\Modules@g" ^
   > "%PATCH_FILE%.patched"
move "%PATCH_FILE%.patched" "%PATCH_FILE%"
set PATCH_FILE=Modules\ThirdParty\GDCM\src\gdcm\Source\MediaStorageAndFileFormat\gdcmMSFF.vcxproj
cat "%PATCH_FILE%" ^
   | sed -e "s@\"%RE%Modules@\"%REPLACE%\\\\Modules@g" ^
   > "%PATCH_FILE%.patched"
move "%PATCH_FILE%.patched" "%PATCH_FILE%"

REM build and install   
cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1
