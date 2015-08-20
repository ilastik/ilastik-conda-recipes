call "%RECIPE_DIR%\..\common-vars-mingw.bat"

set PATH=%MAKE_PATH%;%PATH%

rem disable AVX so that the binaries can run on older processors
rem set NO_AFFINITY=1 to enable multithreaded execution
make -j6 NO_AVX=1 FC="%MINGW_PATH%\gfortran.exe" BINARY=%ARCH% NO_AFFINITY=1
make PREFIX="%LIBRARY_PREFIX%" install

rem install required shared libraries in their proper places
move "%LIBRARY_PREFIX%\lib\libopenblas.dll" "%LIBRARY_PREFIX%\bin"

rem copy the DLL export library under various names
rem (this also overwrites the static library libopenblas.lib which
rem  doesn't work anyway due to unresolved symbols)
copy exports\libopenblas.lib "%LIBRARY_PREFIX%\lib\blas.lib"
copy exports\libopenblas.lib "%LIBRARY_PREFIX%\lib\lapack.lib"
copy exports\libopenblas.lib "%LIBRARY_PREFIX%\lib\libopenblas.lib"
