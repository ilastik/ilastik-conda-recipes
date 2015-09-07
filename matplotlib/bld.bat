REM load toolset info
set TOOLSET_INFO_DIR=%PREFIX%\toolset-info
call "%TOOLSET_INFO_DIR%\common-vars.bat"

set PATH=%LIBRARY_BIN%;%PATH%

cat setupext.py ^
   | sed -e "s@'z'@'zlib'@g" ^
         -e "s@'png'@'libpng15'@g" ^
   > setupext.py.patched
move setupext.py.patched setupext.py

REM older versions needed this as well:
REM         -e "s@def +add_base_flags\(module\):@def add_base_flags(module):\n    module.extra_compile_args.append('/EHsc')@g" ^

%DOS_TOOLS% :to_linux_path "%LIBRARY_PREFIX%" DEPENDENCY_PATH

cat setup.cfg.template ^
   | sed -e "s@#basedirlist.*@basedirlist = %DEPENDENCY_PATH%@g" ^
   > setup.cfg

python setup.py build
if errorlevel 1 exit 1

python setup.py install
if errorlevel 1 exit 1
