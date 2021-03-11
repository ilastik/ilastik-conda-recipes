rem Configure the following environment variables to run this packaging script
rem INNOCC: path to ISCC.exe (verified with INNO 6)
rem MINICONDA: path to miniconda installation root

conda create -y -n release -c ilastik-forge -c conda-forge -c defaults ilastik-dependencies-binary ilastik-exe ilastik-package
if errorlevel 1 exit 1

"%INNOCC%" %MINICONDA%\envs\release\package\ilastik.iss
if errorlevel 1 exit 1
