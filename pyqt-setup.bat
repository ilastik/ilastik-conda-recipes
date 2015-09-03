set PREFIX=C:\Users\ukoethe\Miniconda\envs\_build_placehold_placehold_placehold_placehold_p
set QTDIR=%PREFIX%\Qt4
set PATH=%PREFIX%\Library\bin;%PATH%
set PYTHON=%PREFIX%\python.exe
set QMAKESPEC=%QTDIR%\mkspecs\win32-msvc2012
call dos-tools.bat :to_linux_path "%PREFIX%\sip-sources" SIP_SOURCES_PATH
cd \Users\ukoethe\Miniconda\conda-bld\work\PyQt-win-gpl-4.11.3
