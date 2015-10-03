#!/bin/bash
# The ilastik.py entry point can be used directly, but this shell
# script cleans the environment to avoid a few potential errors.

# we assume that this script resides in PREFIX
export PREFIX=$(cd `dirname $0` && pwd)

# Do not use the user's previous LD_LIBRARY_PATH settings because they can cause conflicts.
# Start with an empty LD_LIBRARY_PATH
export LD_LIBRARY_PATH=""

# Similarly, clear PYTHONPATH
export PYTHONPATH=""

# Do not use the user's own QT_PLUGIN_PATH, which can cause conflicts with our QT build.
# This is especially important on KDE, which is uses its own version of QT and may conflict.
export QT_PLUGIN_PATH=${PREFIX}/plugins

# When Python is compiled with certain (buggy) versions of gcc, 
#  the Python interpreter can sometimes have memory corruption issues 
#  as it shuts down.
# On some systems, memory errors barf out a TON of debug information.
# It's scary that this problem exists, but this output is not useful for users.
# You can disable the checks by uncommenting the following line.
# export MALLOC_CHECK_=0

# Launch the ilastik entry script, and pass along any commmand line args.
${PREFIX}/bin/python ${PREFIX}/ilastik-meta/ilastik/ilastik.py "$@"
