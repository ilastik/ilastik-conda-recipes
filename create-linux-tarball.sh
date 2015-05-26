#!/bin/bash

##
## Usage: create-linux-tarball.sh [--use-local] [-c binstar_channel]
##

set -e
CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root

# Remove old ilastik-release environment
if [ -d ${CONDA_ROOT}/envs/ilastik-release ]; then
    echo "Removing old ilastik-release environment..."
    conda remove -y --all -n ilastik-release
fi

# Create new ilastik-release environment and install all ilastik dependencies to it.
echo "Creating new ilastik-release environment..."
conda create -q -y -n ilastik-release ilastik-everything $1 $2 $3

# Ask conda for the package version
ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`
RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}-Linux

# Create the tarball, and move it to the current directory.
echo "Creating ${RELEASE_NAME}.tar.gz"
DEST_DIR=`pwd`
cd ${CONDA_ROOT}/envs/
mv ilastik-release ${RELEASE_NAME}
tar czf $DEST_DIR/${RELEASE_NAME}.tar.gz ${RELEASE_NAME}
mv ${RELEASE_NAME} ilastik-release
cd -
