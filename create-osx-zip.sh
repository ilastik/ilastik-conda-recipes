#!/bin/bash

##
## Usage: create-osx-zip.sh [--use-local] [-c binstar_channel]
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
conda create -q -y -n ilastik-release ilastik-everything py2app $1

# Ask conda for the package version
ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`
RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}-OSX

# Create the app bundle
echo "Creating ilastik.app..."
OUTPUT_DIR=`pwd`
cd ${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/ilastik
${CONDA_ROOT}/envs/ilastik-release/bin/python ${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/ilastik/setup_mac.py py2app --dist-dir $OUTPUT_DIR
cd -

echo "Zipping: ${RELEASE_NAME}.app -> ${RELEASE_NAME}.zip"
mv ilastik.app ${RELEASE_NAME}.app
zip -r ${RELEASE_NAME}.zip ${RELEASE_NAME}.app
