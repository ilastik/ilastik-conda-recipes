cd "%PREFIX%"

git clone https://github.com/ilastik/ilastik-meta
if errorlevel 1 exit 1

cd ilastik-meta

git submodule update --init --recursive
if errorlevel 1 exit 1
git submodule foreach "git checkout master"
if errorlevel 1 exit 1
