git clone https://github.com/ilastik/ilastik-meta ${PREFIX}/ilastik-meta
cd ${PREFIX}/ilastik-meta
git checkout ${GIT_DESCRIBE_HASH:1} # The git hash is prefixed with 'g' for some stupid reason.
git submodule init
git submodule update --recursive

# Verify that the git tag and the python version match (a common error).
# This line finds the __version_info__ variable in __init__.py, then strips any comments from it.
VERSION_INFO_LINE=`grep --no-filename "__version_info__.*="  ${PREFIX}/ilastik-meta/ilastik/ilastik/__init__.py | sed 's|#.*$||'`
ILASTIK_CODE_VERSION=`python -c "$VERSION_INFO_LINE; print '.'.join(map(str, __version_info__))"`
ILASTIK_PKG_VERSION=$PKG_VERSION

if [[ $ILASTIK_CODE_VERSION != $ILASTIK_PKG_VERSION ]]; then
    set +x
    echo "********************************************************************************"
    echo "ilastik-meta pkg (git) version does not match __version__ in ilastik/__init__.py"
    echo "ilastik-meta version: ${ILASTIK_PKG_VERSION}"
    echo "ilastik.__version__:  ${ILASTIK_CODE_VERSION}"
    echo "********************************************************************************"
    exit 1;
fi


# Remove the git repo files.
rm -rf .git

# Create .pyc files
python -m compileall lazyflow volumina ilastik

# Add the ilastik modules to sys.path
cat > ${PREFIX}/lib/python2.7/site-packages/ilastik-meta.pth << EOF
../../../ilastik-meta/lazyflow
../../../ilastik-meta/volumina
../../../ilastik-meta/ilastik
EOF
