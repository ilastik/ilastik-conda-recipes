#!/bin/bash

# Hints:
# http://boost.2283326.n4.nabble.com/how-to-build-boost-with-bzip2-in-non-standard-location-td2661155.html
# http://www.gentoo.org/proj/en/base/amd64/howtos/?part=1&chap=3
# http://www.boost.org/doc/libs/1_55_0/doc/html/bbv2/reference.html

# Hints for OSX:
# http://stackoverflow.com/questions/20108407/how-do-i-compile-boost-for-os-x-64b-platforms-with-stdlibc

# Build dependencies:
# - bzip2-devel

# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

if [ `uname` == Darwin ]; then
    B2ARGS="toolset=darwin"
    echo "using darwin : : ${PREFIX}/bin/g++" > user-config.jam
    DY_EXT=dylib
else
    B2ARGS="toolset=gcc"
    DY_EXT=so
fi

# For some reason, ${PY_VER} is incorrect, so we need to deduce the version on our own.
PY_MAJOR_MINOR=$(python -c "import sys; sys.stdout.write('{}.{}'.format(sys.version_info.major, sys.version_info.minor))")
echo "using python : ${PY_MAJOR_MINOR} : ${PYTHON} : ${PREFIX}/include/python${PY_MAJOR_MINOR} : ${PREFIX}/lib ;" >> user-config.jam

# FIXME: These paths have 'm' character on the end, which boost seems not to expect.
#        (Adding 'm' to the user-config line above seems to make no difference.)
#        For now, we just add these symlinks to fix the issue.
cd ${PREFIX}/include && ln -s python${PY_MAJOR_MINOR}m python${PY_MAJOR_MINOR} && cd -
cd ${PREFIX}/lib && ln -s libpython${PY_MAJOR_MINOR}m.${DY_EXT} libpython${PY_MAJOR_MINOR}.${DY_EXT} && cd -

mkdir -vp ${PREFIX}/bin;

./bootstrap.sh \
  --with-libraries=date_time,filesystem,python,regex,serialization,system,test,thread,program_options,chrono,atomic,random \
  --with-python=${PYTHON} \
  --with-python-version=${PY_MAJOR_MINOR} \
  --with-python-root=${PREFIX} \
  --prefix=${PREFIX}

# In the commands below, we want to include linkflags=blabla and 
# cxxflags=blabla, but only if there are actual values for 
# linkflags and cxxflags.  Otherwisde, omit those settings entirely.
LINK_ARG=""
if [ "${CXX_LDFLAGS}" != "" ]; then
    LINK_ARG=linkflags=
fi

echo "LINK_ARG=$LINK_ARG"

CXX_ARG=""
if [ "${CXXFLAGS}" != "" ]; then
    CXX_ARG=cxxflags=
fi


# Create with --layout=tagged to create libraries named with -mt convention
./b2 \
  --layout=tagged \
  -j ${CPU_COUNT} \
  -sNO_BZIP2=1 \
  variant=release \
  threading=multi \
  ${B2ARGS} \
  ${CXX_ARG}"${CXXFLAGS}" \
  ${LINK_ARG}"${CXX_LDFLAGS}" \
  install
  
# Add symlinks in case some dependencies expect non-tagged names.
cd ${PREFIX}/lib
for f in libboost_*-mt*; do
    echo $f
    f_without_mt=${f/-mt/}
    ln -s $f $f_without_mt
done

# Omitted these options from above commands:  
#  -sZLIB_INCLUDE=${PREFIX}/include \
#  -sZLIB_SOURCE=${zlib_SRC_DIR} \
