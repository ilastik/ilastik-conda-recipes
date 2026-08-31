#!/bin/bash
# The ilastik.py entry point can be used directly, but this shell
# script cleans the environment to avoid a few potential errors.

# we assume that this script resides in PREFIX
export PREFIX=$(dirname "$(readlink -f $0)")

# Do not use the user's previous LD_LIBRARY_PATH settings because they can cause conflicts.
# Start with an empty LD_LIBRARY_PATH
if [[ $LD_LIBRARY_PATH != "" ]]; then
    1>&2 echo "Warning: Ignoring your non-empty LD_LIBRARY_PATH"
fi
export LD_LIBRARY_PATH=""

USE_VENDOR_GL=0
if [[ "${1:-}" == "--vendor-gl" ]]; then
    USE_VENDOR_GL=1
    shift
fi

if (( USE_VENDOR_GL )); then
    export LD_LIBRARY_PATH="${SCRIPT_DIR}/lib-vendor-gl"
    echo "Using bundled vendor OpenGL libraries" >&2
fi

# Similarly, clear PYTHONPATH and PYTHONHOME
if [[ $PYTHONPATH != "" ]] || [[ $PYTHONHOME != "" ]]; then
    1>&2 echo "Warning: Ignoring your non-empty PYTHONPATH/PYTHONHOME"
fi    
export PYTHONPATH=""
export PYTHONHOME="${PREFIX}"

# Similarly, disable user-site configuration
export PYTHONNOUSERSITE=1

# Do not use the user's own QT_PLUGIN_PATH, which can cause conflicts with our QT build.
# This is especially important on KDE, which is uses its own version of QT and may conflict.
# Similarly, clear PYTHONPATH and PYTHONHOME
if [[ $QT_PLUGIN_PATH != "" ]]; then
    1>&2 echo "Warning: Ignoring your non-empty QT_PLUGIN_PATH"
fi    
export QT_PLUGIN_PATH="${PREFIX}/plugins"

# As of Qt5, the XKB config root needs to be configured to make keyboard input possible on linux.
export QT_XKB_CONFIG_ROOT="${PREFIX}/lib"

# When Python is compiled with certain (buggy) versions of gcc, 
#  the Python interpreter can sometimes have memory corruption issues 
#  as it shuts down.
# On some systems, memory errors barf out a TON of debug information.
# It's scary that this problem exists, but this output is not useful for users.
# You can disable the checks by uncommenting the following line.
# export MALLOC_CHECK_=0

# fontconfig determines the default paths for configuration files during compile time.
# Make sure to update these to match the local system
export FONTCONFIG_PATH="${PREFIX}/etc/fonts/"
export FONTCONFIG_FILE="${PREFIX}/etc/fonts/fonts.conf"

# link to LICENSE files in release
export ILASTIK_LICENSE_3RD_PARTY_PATH="${PREFIX}/THIRDPARTY_LICENSES.txt"
export ILASTIK_LICENSE_PATH="${PREFIX}/LICENSE.txt"

# Launch the ilastik entry script, and pass along any commmand line args.
"${PREFIX}/bin/python" "${PREFIX}/bin/ilastik" "$@"
