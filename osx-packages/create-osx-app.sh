#!/bin/bash

##
## Usage: create-osx-app.sh [--zip] [--git-latest] [--no-solvers] [... extra install-args, e.g. --use-local or -c ilastik or --copy ...]
##

set -e

OSX_PACKAGES_DIR=$(cd `dirname $0` && pwd)

ZIP=0
if [[ $@ == *"--zip"* ]]; then
    if [[ $1 == "--zip" ]]; then
        shift
        ZIP=1
    else
        echo "Error: --zip may only be provided as the first arg." >&2
    fi
fi

USE_GIT_LATEST=0
if [[ $@ == *"--git-latest"* ]]; then
    if [[ $1 == "--git-latest" ]]; then
        USE_GIT_LATEST=1
        shift
    else
        echo "Error: --git-latest may only be provided as the first arg or after --zip." >&2
        exit 1
    fi
fi

export WITH_SOLVERS=1
if [[ $@ == *"--no-solvers"* ]]; then
    if [[ $1 == "--no-solvers" ]]; then
        export WITH_SOLVERS=0
        shift
    else
        echo "Error: --no-solvers may only be provided as the first arg or after --git-latest." >&2
        exit 1
    fi
fi

echo "Activating root conda env"
CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root

RELEASE_ENV=${CONDA_ROOT}/envs/ilastik-release

# Remove old ilastik-release environment
if [ -d ${RELEASE_ENV} ]; then
    echo "Removing old ilastik-release environment..."
    conda remove -y --all -n ilastik-release
fi

# Create new ilastik-release environment and install all ilastik dependencies to it.
echo "Creating new ilastik-release environment..."
if [[ $WITH_SOLVERS == 0 ]]; then
    conda create -q -y -n ilastik-release ilastik-everything-no-solvers py2app "$@"
    SOLVERS_SUFFIX="-no-solvers"
else    
    conda create -q -y -n ilastik-release ilastik-everything py2app "$@"
    SOLVERS_SUFFIX=""
fi

## Replace all @rpath references with @loader_path references,
## and delete the RPATHs (some of which are absolute instead of relative).
#echo "Relinking all dylibs with relative links..."
#REMOVE_RPATHS="python ${OSX_PACKAGES_DIR}/remove-rpath.py --with_loader_path"
#find $RELEASE_ENV/lib -name "*.dylib" -type f | xargs $REMOVE_RPATHS
#find $RELEASE_ENV/lib -name "*.so" -type f | xargs $REMOVE_RPATHS
#find $RELEASE_ENV/plugins -name "*.dylib" -type f | xargs $REMOVE_RPATHS

if [[ $USE_GIT_LATEST == 1 ]]; then
    # Instead of keeping the version from binstar, get the git repo
    ILASTIK_META=${CONDA_ROOT}/envs/ilastik-release/ilastik-meta
    rm -rf ${ILASTIK_META}

    echo "Cloning ilastik from latest github sources"
    git clone https://github.com/ilastik/ilastik-meta ${ILASTIK_META}
    cd ${ILASTIK_META}
    git submodule init
    git submodule update
    git submodule foreach 'git checkout master'

    echo "Compiling python sources"
    python -m compileall lazyflow volumina ilastik
    cd -
    ILASTIK_PKG_VERSION="master"
else
    # Ask conda for the package version
    ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`
fi
RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}${SOLVERS_SUFFIX}-OSX

echo "Creating ilastik.app..."
# For some reason, the app created by py2app has stability issues.
# (It might be related to the load order of multiple libgcc_s dylibs and/or libSystem.B.dylib.)
# As a workaround, we use py2app in "alias mode" and then manually copy the files we need into the app.
${RELEASE_ENV}/bin/python ${OSX_PACKAGES_DIR}/setup-alias-app.py py2app --alias --dist-dir .

echo "Writing qt.conf"
cat <<EOF > ilastik.app/Contents/Resources/qt.conf
; Qt Configuration file
[Paths]
Plugins = ilastik-env/plugins
EOF

# Remove cplex libs/symlinks (if present)
rm -f ${RELEASE_ENV}/lib/libcplex.dylib
rm -f ${RELEASE_ENV}/lib/libilocplex.dylib
rm -f ${RELEASE_ENV}/lib/libconcert.dylib

# Remove gurobi symlinks (if present)
rm -f ${RELEASE_ENV}/lib/libgurobi*.so # Yes, the extension is .so, even on Mac

echo "Moving ilastik-release environment into ilastik.app bundle..."
mv ${RELEASE_ENV} ilastik.app/Contents/ilastik-release
cd ilastik.app/Contents/Resources && ln -s ../ilastik-release/ilastik-meta/ilastik/ilastik.py
cd -

echo "Updating bundle internal paths..."
# Fix __boot__ script
sed -i '' 's|^_path_inject|#_path_inject|g' ilastik.app/Contents/Resources/__boot__.py
sed -i '' "s|${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/ilastik/||" ilastik.app/Contents/Resources/__boot__.py

# Fix Info.plist
sed -i '' "s|${CONDA_ROOT}/envs/ilastik-release|@executable_path/../ilastik-release|" ilastik.app/Contents/Info.plist

# Fix python executable link
rm ilastik.app/Contents/MacOS/python
cd ilastik.app/Contents/MacOS && ln -s ../ilastik-release/bin/python
cd -

# Fix app icon link
rm ilastik.app/Contents/Resources/appIcon.icns
cd ilastik.app/Contents/Resources && ln -s ../ilastik-release/ilastik-meta/ilastik/appIcon.icns
cd -

# Replace Resources/lib with a symlink
rm -rf ilastik.app/Contents/Resources/lib
cd ilastik.app/Contents/Resources && ln -s ../ilastik-release/lib
cd -

# Add a symlink to ilastik-meta so that lib/python2.7/site-packages/ilastik-meta.pth works correctly
cd ilastik.app/Contents/Resources && ln -s ../ilastik-release/ilastik-meta
cd -

echo "Renaming ilastik.app -> ${RELEASE_NAME}.app"
rm -rf ${RELEASE_NAME}.app
rm -f ${RELEASE_NAME}.zip
mv ilastik.app ${RELEASE_NAME}.app

if [[ $ZIP == 1 ]]; then
    echo "Zipping: ${RELEASE_NAME}.app -> ${RELEASE_NAME}.zip"
    zip -r --symlinks ${RELEASE_NAME}.zip ${RELEASE_NAME}.app
fi
