set PATH=%LIBRARY_BIN%;%PATH%

REM define 'WIN32' is required for lzf compression on Win64
cat setup_build.py ^
   | sed -e "s@hdf5dll18@hdf5@g" ^
         -e "s@hdf5_hldll@hdf5_hl@g" ^
         -e "s@h5py_hdf5@hdf5@g" ^
         -e "s@h5py_hdf5_hl@hdf5_hl@g" ^
         -e "s@\('_HDF5USEDLL_', *None\)@('_HDF5USEDLL_', None), ('WIN32', 1)@g" ^
   > setup_build.py.patched
if errorlevel 1 exit 1
move setup_build.py.patched setup_build.py
if errorlevel 1 exit 1

cat h5py.egg-info/SOURCES.txt ^
   | sed -e "s@/Users/andrew/Documents/Projects/h5py/@@g" ^
   > SOURCES.txt.patched
if errorlevel 1 exit 1
move SOURCES.txt.patched h5py.egg-info/SOURCES.txt
if errorlevel 1 exit 1

python setup.py build_ext -c msvc -L "%LIBRARY_LIB%" -I "%LIBRARY_INC%"
if errorlevel 1 exit 1

python setup.py install
if errorlevel 1 exit 1
