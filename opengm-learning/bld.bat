REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars-mingw.bat"

set PATH=%MSYS_PATH%;%PATH%

mkdir build

if NOT DEFINED HEADER_ONLY set HEADER_ONLY=0
if NOT DEFINED WITH_CPLEX  set WITH_CPLEX=0

if NOT "%HEADER_ONLY%"=="0" (

    echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    echo Building header-only version of opengm.
    echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cd build
    cmake .. -G "%CMAKE_GENERATOR%" ^
             -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
             -DBUILD_EXAMPLES=OFF ^
             -DBUILD_TUTORIALS=OFF ^
             -DBUILD_TESTING=OFF
    if errorlevel 1 exit 1

) else (

    if "%WITH_CPLEX%"=="0" (
        echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        echo Building library version of opengm without CPLEX.
        echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ) else (
        echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        echo Building library version of opengm with CPLEX.
        echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    )

    cd build
    cmake .. -G "%CMAKE_GENERATOR%" ^
             -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
             -DBUILD_PYTHON_WRAPPER=ON ^
             -DPYTHON_LIBRARY="%PREFIX%\libs\python27.lib" ^
             -DPYTHON_INCLUDE_DIR="%PREFIX%\include" ^
             -DBUILD_EXAMPLES=OFF ^
             -DBUILD_TUTORIALS=OFF ^
             -DBUILD_TESTING=OFF ^
             -DWITH_BOOST=ON ^
             -DWITH_CPLEX=%WITH_CPLEX% ^
             -DWITH_VIGRA=ON ^
             -DWITH_HDF5=ON
    if errorlevel 1 exit 1

    cmake --build . --target externalLibs
    if errorlevel 1 exit 1

    cmake . -DWITH_MAXFLOW=ON -DWITH_MAXFLOW_IBFS=ON -DWITH_QPBO=ON
    if errorlevel 1 exit 1
)

cmake --build . --target ALL_BUILD --config Release
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

if NOT "%WITH_CPLEX%"=="0" (
    echo renaming "opengm" into "opengm_with_cplex"
    cd "%PREFIX%\Lib\site-packages"
    rename opengm opengm_with_cplex
    cd opengm_with_cplex

    FOR /F "delims=" %%i IN ('dir /S /B *.py') DO (
        cat "%%i" | sed ^
            -e "s|import opengm[:space]*$|import opengm_with_cplex|g" ^
            -e "s|from opengm import|from opengm_with_cplex import|g" > "%%i.patched"
        if errorlevel 1 exit 1
        move "%%i.patched" "%%i"
        if errorlevel 1 exit 1
    )
)
