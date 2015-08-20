call "%RECIPE_DIR%\..\common-vars.bat"

if %ARCH%==64 (
    REM bootstrap.bat wants a 32-bit compiler
    call "%VISUAL_STUDIO_VCVARSALL%" x86
)

call .\bootstrap.bat

if %ARCH%==64 (
    call "%VISUAL_STUDIO_VCVARSALL%" amd64
)

set BOOST_TOOLSET=msvc-%VISUAL_STUDIO_VERSION%
echo BOOST TOOLSET: %BOOST_TOOLSET%

set BOOST_OPTIONS=--layout=system --with-python --with-serialization --with-system --with-filesystem --with-test --with-timer --with-thread --with-random --with-date_time --with-chrono --with-program_options  variant=release threading=multi link=shared toolset=%BOOST_TOOLSET% address-model=%ARCH%

REM compile
.\b2 %BOOST_OPTIONS%

REM install
.\b2 --prefix="%LIBRARY_PREFIX%" %BOOST_OPTIONS% install
move "%LIBRARY_PREFIX%\lib\boost*.dll" "%LIBRARY_PREFIX%\bin"
