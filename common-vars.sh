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

#
# We OVERRIDE conda's default value for MACOSX_DEPLOYMENT_TARGET, 
#  because we want to link against libc++ (not stdlibc++) for C++ libraries (like vigra)
#
export MACOSX_DEPLOYMENT_TARGET=10.7

if [[ `uname` == 'Darwin' ]]; then
    CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++"
    CXX_LDFLAGS="${LDFLAGS} -stdlib=libc++"
else
    CXXFLAGS="${CXXFLAGS} -std=c++11"
    CXX_LDFLAGS="${LDFLAGS}"
fi

