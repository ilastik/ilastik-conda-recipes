#
# Defines a few environment variables that simplify cross-platform (Linux/OSX) build scripts for conda packages.
# Meant to be source'd from the top of your conda build.sh scripts.
# 

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    DYLIB_EXT=dylib
else
    DYLIB_EXT=so
fi

# This variable can be used to (indirectly) read/set the contents of either 
# LD_LIBRARY_PATH or DYLD_LIBRARY_PATH, depending on your platform.
# To set as a prefix of a command (e.g. before 'make check'), use eval:
#  eval $LIBRARY_SEARCH_VAR=/path/to/lib;/another/path/to/lib make check
# To read (using modern bash indirection syntax):
#  echo ${!LIBRARY_SEACH_VAR}
if [[ `uname` == 'Darwin' ]]; then
    LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

# Typically, conda erases LD_LIBRARY_PATH before building the recipe,
# but some recipes can specifically override this behavior via the build:script_env setting in meta.yaml.
# It can be useful to allow this, but it is very dangerous.
# We give a warning about it here.
if [[ -n ${!LIBRARY_SEARCH_VAR} ]]; then
    echo "*** WARNING: You are using a non-empty value of ${LIBRARY_SEARCH_VAR}:"
    echo "*** ${LIBARY_SEARCH_VAR}=${!LIBRARY_SEARCH_VAR}"
    echo "*** This can make your build difficult to reproduce.  Make sure you know what you're doing."
fi

#
# We OVERRIDE conda's default value for MACOSX_DEPLOYMENT_TARGET, 
#  because we want to link against libc++ (not stdlibc++) for C++ libraries (like vigra)
#
export MACOSX_DEPLOYMENT_TARGET=10.7

