python setup.py build_ext -I "%PREFIX%\Lib\site-packages\numpy\core\include"
if errorlevel 1 exit 1

python setup.py install
if errorlevel 1 exit 1
