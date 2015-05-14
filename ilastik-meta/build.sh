git clone https://github.com/ilastik/ilastik-meta ${PREFIX}/ilastik-meta
cd ${PREFIX}/ilastik-meta
git submodule init
git submodule update --recursive

cat > ${PREFIX}/lib/python2.7/site-packages/ilastik-meta.pth << EOF
../../../ilastik-meta/lazyflow
../../../ilastik-meta/volumina
../../../ilastik-meta/ilastik
EOF

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

# Launch the ilastik entry script, and pass along any commmand line args.
\${PREFIX}/bin/python \${PREFIX}/ilastik-meta/ilastik/ilastik.py "\$@"
EOF

chmod a+x ${PREFIX}/run_ilastik.sh
