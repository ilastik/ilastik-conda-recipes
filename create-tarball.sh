#!/bin/bash

##
## Usage: create-tarball.sh [--git-latest] [--no-tracking] [... extra install-args, e.g. --use-local or -c ilastik ...]
##

set -e

USE_GIT_LATEST=0
if [[ $@ == *"--git-latest"* ]]; then
    if [[ $1 == "--git-latest" ]]; then
        USE_GIT_LATEST=1
       shift
    else
        echo "Error: --git-latest may only be provided as the first arg." >&2
        exit 1
    fi
fi

OMIT_TRACKING=0
if [[ $@ == *"--no-tracking"* ]]; then
    if [[ $1 == "--no-tracking" ]]; then
        OMIT_TRACKING=1
        shift
    else
        echo "Error: --no-tracking may only be provided as the first arg after --git-latest." >&2
        exit 1
    fi
fi

CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root

# Remove old ilastik-release environment
if [ -d ${CONDA_ROOT}/envs/ilastik-release ]; then
    echo "Removing old ilastik-release environment..."
    conda remove -y --all -n ilastik-release
fi

# Create new ilastik-release environment and install all ilastik dependencies to it.
echo "Creating new ilastik-release environment..."
if [[ $OMIT_TRACKING == 1 ]]; then
    conda create -q -y -n ilastik-release ilastik-everything-but-tracking "$@"
    TRACKING_SUFFIX="-no-tracking"
else    
    conda create -q -y -n ilastik-release ilastik-everything "$@"
    TRACKING_SUFFIX=""
fi

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

RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}${TRACKING_SUFFIX}-`uname`

# Remove cplex libs/symlinks (if present)
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libcplex.so
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libilocplex.so
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libconcert.so

# Create the tarball, and move it to the current directory.
echo "Creating ${RELEASE_NAME}.tar.gz"
DEST_DIR=`pwd`
cd ${CONDA_ROOT}/envs/
mv ilastik-release ${RELEASE_NAME}
tar czf $DEST_DIR/${RELEASE_NAME}.tar.gz ${RELEASE_NAME}
mv ${RELEASE_NAME} ilastik-release
cd -
