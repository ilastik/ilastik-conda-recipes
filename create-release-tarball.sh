#!/bin/bash
set -e
CONDA_ROOT=`conda info --root`

# Remove old ilastik-release environment
conda remove -q -y --all -n ilastik-release 2> /dev/null || true

# Create new ilastik-release environment and install all ilastik dependencies to it.
conda create -y -n ilastik-release ilastik-deps-pc ilastik-deps-carving ilastik-deps-tracking ilastik-meta

# Create the tarball, and move it to the current directory.
pushd ${CONDA_ROOT}/envs
tar czf ilastik-release.tar.gz ilastik-release
popd
mv ${CONDA_ROOT}/envs/ilastik-release.tar.gz .
