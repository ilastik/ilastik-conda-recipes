# Verify that the git tag and the python version match (a common error).
ILASTIK_CODE_VERSION=`${PREFIX}/bin/python -c "import ilastik; print ilastik.__version__"`
ILASTIK_PKG_VERSION=`conda list -n _build | grep ilastik-meta | python -c "import sys; print sys.stdin.read().split()[1]"`

if [[ $ILASTIK_CODE_VERSION != $ILASTIK_PKG_VERSION ]]; then
    set +x
    echo "********************************************************************************"
    echo "ilastik-meta pkg (git) version does not match __version__ in ilastik/__init__.py"
    echo "ilastik-meta version: ${ILASTIK_PKG_VERSION}"
    echo "ilastik.__version__:  ${ILASTIK_CODE_VERSION}"
    echo "********************************************************************************"
    exit 1;
fi

# Copy the ilastik version as our package version
echo $ILASTIK_PKG_VERSION > __conda_version__.txt

