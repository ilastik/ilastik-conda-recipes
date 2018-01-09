#!/bin/bash

##
## Usage: create-tarball.sh [--skip-tar] [--git-latest] [--no-solvers] [... extra install-args, e.g. --use-local or -c ilastik ...]
##

set -e

SKIP_TAR=0
if [[ $@ == *"--skip-tar"* ]]; then
    if [[ $1 == "--skip-tar" ]]; then
        SKIP_TAR=1
       shift
    else
        echo "Error: --skip-tar may only be provided as the first arg." >&2
        exit 1
    fi
fi

USE_GIT_LATEST=0
if [[ $@ == *"--git-latest"* ]]; then
    if [[ $1 == "--git-latest" ]]; then
        USE_GIT_LATEST=1
       shift
    else
        echo "Error: --git-latest may only be provided as the first arg (or after --skip-tar)." >&2
        exit 1
    fi
fi

export WITH_SOLVERS=1
if [[ $@ == *"--no-solvers"* ]]; then
    if [[ $1 == "--no-solvers" ]]; then
        export WITH_SOLVERS=0
        shift
    else
        echo "Error: --no-solvers may only be provided as the first arg (or after --git-latest)." >&2
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

function latest_build()
{
    VERSION_AND_BUILD=$(conda search -f $@ \
                        | tail -n1 \
                        | python -c 'import sys; print("=".join(sys.stdin.read().split()[:2]))')
    echo "$1=$VERSION_AND_BUILD"
}

# Create new ilastik-release environment and install all ilastik dependencies to it.
if [[ $WITH_SOLVERS == 0 ]]; then
    EVERYTHING_PKG=$(latest_build ilastik-dependencies-no-solvers "$@")
    SOLVERS_SUFFIX="-no-solvers"
else    
    EVERYTHING_PKG=$(latest_build ilastik-dependencies "$@")
    SOLVERS_SUFFIX=""
fi

echo "Creating new ilastik-release environment using ${EVERYTHING_PKG}"
conda create -q -y -n ilastik-release ${EVERYTHING_PKG} "$@"

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
    ILASTIK_PKG_VERSION=`conda list -n ilastik-release | grep ilastik-meta | python -c "import sys; print(sys.stdin.read().split()[1])"`
fi

RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}${SOLVERS_SUFFIX}-`uname`

# Remove cplex libs/symlinks (if present)
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libcplex.so
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libilocplex.so
rm -f ${CONDA_ROOT}/envs/ilastik-release/lib/libconcert.so

# Remove gurobi symlinks (if present)
rm -f ${RELEASE_ENV}/lib/libgurobi*.so

if [[ $SKIP_TAR == 1 ]]; then
    echo "Skipping tarball creation."
    echo "Release env created in ${CONDA_ROOT}/envs/ilastik-release"
else
    # Create the tarball, and move it to the current directory.
    echo "Creating ${RELEASE_NAME}.tar.bz2"
    DEST_DIR=`pwd`
    cd ${CONDA_ROOT}/envs/
    mv ilastik-release ${RELEASE_NAME}
    tar -cjf $DEST_DIR/${RELEASE_NAME}.tar.bz2 ${RELEASE_NAME}
    mv ${RELEASE_NAME} ilastik-release
    cd -
fi
