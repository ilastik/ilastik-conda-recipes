set PATH=%LIBRARY_BIN%;%PATH%

"%PYTHON%" setup.py install
if errorlevel 1 exit 1
