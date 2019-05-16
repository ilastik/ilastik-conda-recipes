#!/bin/bash

##
## Usage: create-tarball.sh [--skip-tar] [--git-latest] [--no-solvers] [--include-tests] [... extra install-args, e.g. --use-local or -c ilastik-forge ...]
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

INCLUDE_TESTS=0
if [[ $@ == *"--include-tests"* ]]; then
    if [[ $1 == "--include-tests" ]]; then
        INCLUDE_TESTS=1
        shift
    else
        echo "Error: --include-tests may only be provided as the first arg (or after --no-solvers)." >&2
        exit 1
    fi
fi


CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root

RANDOM_STRING="szfndbgckhxkaygjxbpxkbcuwzweapsyayblnqsadneekswtavrfhcgzquyemufyiprbfbcaiahnnssdssobksqqycmqgyvhpnnktprkpujobkjutbzqqujpbdzyaeeg"
RELEASE_ENV_NAME="${RANDOM_STRING}"
RELEASE_ENV="${CONDA_ROOT}/envs/${RELEASE_ENV_NAME}"


# Remove old ${RELEASE_ENV_NAME} environment
if [ -d ${RELEASE_ENV} ]; then
    echo "Removing old ${RELEASE_ENV_NAME} environment..."
    conda remove -y --all -n ${RELEASE_ENV_NAME}
fi

function latest_build()
{
    VERSION_AND_BUILD=$(conda search -f $@ \
                        | tail -n1 \
                        | python -c 'import sys; print("=".join(sys.stdin.read().split()[:2]))')
    echo "$VERSION_AND_BUILD"
}

# Create new ${RELEASE_ENV_NAME} environment and install all ilastik dependencies to it.
if [[ $WITH_SOLVERS == 0 ]]; then
    EVERYTHING_PKG=$(latest_build ilastik-dependencies-no-solvers "$@")
    SOLVERS_SUFFIX="-no-solvers"
else    
    EVERYTHING_PKG=$(latest_build ilastik-dependencies "$@")
    SOLVERS_SUFFIX=""
fi

echo "Creating new ${RELEASE_ENV_NAME} environment using ${EVERYTHING_PKG}"
echo "environment location: ${RELEASE_ENV}"
conda create -q -y -n ${RELEASE_ENV_NAME} ${EVERYTHING_PKG} ilastik-install --override-channels "$@" -c kdominik

if [[ $USE_GIT_LATEST == 1 ]]; then
    # Instead of keeping the version from binstar, get the git repo
    ILASTIK_META=${CONDA_ROOT}/envs/${RELEASE_ENV_NAME}/ilastik-meta
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
    ILASTIK_PKG_VERSION=`conda list -n ${RELEASE_ENV_NAME} | grep ilastik-meta | python -c "import sys; print(sys.stdin.read().split()[1])"`
fi

RELEASE_NAME=ilastik-${ILASTIK_PKG_VERSION}${SOLVERS_SUFFIX}-`uname`


# Remove cplex libs/symlinks (if present)
rm -f ${RELEASE_ENV}/lib/libcplex.so
rm -f ${RELEASE_ENV}/lib/libilocplex.so
rm -f ${RELEASE_ENV}/lib/libconcert.so


# Remove gurobi symlinks (if present)
rm -f ${RELEASE_ENV}/lib/libgurobi*.so

if [[ $INCLUDE_TESTS == 1 ]]; then
    echo "Including ilastik tests in release (larger release size)."
else
    echo "Removing ilastik tests from source folders"
    ILASTIK_META=${RELEASE_ENV}/ilastik-meta
    rm -rf ${ILASTIK_META}/*/tests/*
    echo "test-files removed"
fi

echo "{\"previous_prefix\": \"${RELEASE_ENV}\"}" > ${RELEASE_ENV}/.prefix_previous

if [[ $SKIP_TAR == 1 ]]; then
    echo "Skipping tarball creation."
    echo "Release env created in ${RELEASE_ENV}"
else
    # Create the tarball, and move it to the current directory.
    echo "Creating ${RELEASE_NAME}.tar.bz2"
    DEST_DIR=`pwd`
    cd ${CONDA_ROOT}/envs/
    mv ${RELEASE_ENV_NAME} ${RELEASE_NAME}
    tar -cjf $DEST_DIR/${RELEASE_NAME}.tar.bz2 ${RELEASE_NAME}
    mv ${RELEASE_NAME} ${RELEASE_ENV_NAME}
    cd -
fi
