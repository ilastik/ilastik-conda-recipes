#!/bin/bash
set -e
CONDA_ROOT=`conda info --root`

# Remove old ilastik-release environment
conda remove -q -y --all -n ilastik-release 2> /dev/null || true

# Create new ilastik-release environment and install all ilastik dependencies to it.
conda create -y -n ilastik-release ilastik-everything

# Delete the git repo history -- it's huge and users don't need it
rm -rf ${CONDA_ROOT}/envs/ilastik-release/ilastik-meta/.git

ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`
RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}-Linux

# Create the tarball, and move it to the current directory.
# Note: the --transform option below only works on Linux.
tar czf ${RELEASE_NAME}.tar.gz \
    --transform "s|${CONDA_ROOT:1}/envs/ilastik-release|${RELEASE_NAME}|" \
    ${CONDA_ROOT}/envs/ilastik-release
