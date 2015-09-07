cd MS_Win32

devenv Ann.sln /upgrade
if errorlevel 1 exit 1

if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
    REM patch to support x64 build platform
    cat Ann.sln ^
       | sed -e "s@Win32@x64@g" ^
       > Ann.sln.patched
    if errorlevel 1 exit 1
    move Ann.sln.patched Ann.sln
    
    cat dll\dll.vcxproj ^
       | sed -e "s@Win32@x64@g" ^
             -e "s@<TargetMachine>MachineX86</TargetMachine>@@g" ^
       > dll\dll.vcxproj.patched
    if errorlevel 1 exit 1
    move dll\dll.vcxproj.patched dll\dll.vcxproj
)

devenv Ann.sln /build "Release|%PLATFORM%" /project dll
if errorlevel 1 exit 1

copy bin\ANN.dll "%LIBRARY_BIN%\"
if errorlevel 1 exit 1
copy dll\Release\ANN.lib "%LIBRARY_LIB%\"
if errorlevel 1 exit 1
cd ../include
xcopy /S ANN "%LIBRARY_INC%\ANN\"
if errorlevel 1 exit 1
