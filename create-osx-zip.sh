#!/bin/bash
set -e
CONDA_ROOT=`conda info --root`

# Remove old ilastik-release environment
conda remove -q -y --all -n ilastik-release 2> /dev/null || true

# Create new ilastik-release environment and install all ilastik dependencies to it.
conda create -y -n ilastik-release ilastik-everything py2app $1

ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`
RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}-OSX

OUTPUT_DIR=`pwd`
cd ${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/ilastik
${CONDA_ROOT}/envs/ilastik-release/bin/python ${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/ilastik/setup_mac.py py2app --dist-dir $OUTPUT_DIR
cd -

mv ilastik.app ${RELEASE_NAME}.app
zip -r ${RELEASE_NAME}.zip ${RELEASE_NAME}.app
