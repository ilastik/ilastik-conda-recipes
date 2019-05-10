"%PYTHON%" setup.py build_ext
if errorlevel 1 exit 1
"%PYTHON%" setup.py install --single-version-externally-managed --root=/
if errorlevel 1 exit 1
