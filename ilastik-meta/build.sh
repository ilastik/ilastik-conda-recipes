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

# The ilastik.py entry point can be used directly, but this shell
# script cleans the environment to avoid a few potential errors.
cat > ${PREFIX}/run_ilastik.sh << EOF
#!/bin/bash

# we assume that this script resides in PREFIX
export PREFIX=\$(cd \`dirname \$0\` && pwd)

# Do not use the user's previous LD_LIBRARY_PATH settings because they can cause conflicts.
# Start with an empty LD_LIBRARY_PATH
export LD_LIBRARY_PATH=""

# Similarly, clear PYTHONPATH
export PYTHONPATH=""

# Do not use the user's own QT_PLUGIN_PATH, which can cause conflicts with our QT build.
# This is especially important on KDE, which is uses its own version of QT and may conflict.
export QT_PLUGIN_PATH=\${PREFIX}/plugins

# For some reason, the Python interpreter can sometimes 
#  have memory corruption issues as it shuts down.
# On some systems, memory errors barf out a TON of debug information.
# It's scary that this problem exists, but this output is not useful for users.
# Disable the checks.
export MALLOC_CHECK_=0

# fontconf determines the default paths for configuration files during compile time
# make sure to update these to match the local system
export FONTCONFIG_PATH=\${PREFIX}/etc/fonts/
export FONTCONFIG_FILE=\${PREFIX}/etc/fonts/fonts.conf

# Launch the ilastik entry script, and pass along any commmand line args.
\${PREFIX}/bin/python \${PREFIX}/ilastik-meta/ilastik/ilastik.py "\$@"
EOF

chmod a+x ${PREFIX}/run_ilastik.sh
