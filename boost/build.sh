#!/bin/bash

# Hints:
# http://boost.2283326.n4.nabble.com/how-to-build-boost-with-bzip2-in-non-standard-location-td2661155.html
# http://www.gentoo.org/proj/en/base/amd64/howtos/?part=1&chap=3
# http://www.boost.org/doc/libs/1_56_0/doc/html/bbv2/reference.html

# Hints for OSX:
# http://stackoverflow.com/questions/20108407/how-do-i-compile-boost-for-os-x-64b-platforms-with-stdlibc

# Build dependencies:
# - bzip2-devel

# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

if [ `uname` == Darwin ]; then
    B2ARGS="toolset=clang"
else
    B2ARGS="toolset=gcc"
fi

mkdir -vp ${PREFIX}/bin;

./bootstrap.sh \
  --with-libraries=date_time,filesystem,python,regex,serialization,system,test,thread,program_options,chrono,atomic,random \
  --with-python=${PYTHON} \
  --prefix=${PREFIX}

LINK_ARG=""
if [ "${CXX_LDFLAGS}" != "" ]; then
    LINK_ARG=linkflags=
fi

echo "LINK_ARG=$LINK_ARG"

# First, with --layout=tagged to create libraries named with -mt convention
./b2 \
  --layout=tagged \
  -j ${CPU_COUNT} \
  -sNO_BZIP2=1 \
  ${B2ARGS} \
  cxxflags="${CXXFLAGS}" \
  ${LINK_ARG}"${CXX_LDFLAGS}" \
  install

# Second, without --layout=tagged, to create libraries without -mt names
# If all upstream libraries could be fixed to depend on the tagged name, we could eliminate this redundancy
./b2 \
  -j ${CPU_COUNT} \
  -sNO_BZIP2=1 \
  ${B2ARGS} \
  cxxflags="${CXXFLAGS}" \
  ${LINK_ARG}"${CXX_LDFLAGS}" \
  install

# Omitted these options from above commands:  
#  -sZLIB_INCLUDE=${PREFIX}/include \
#  -sZLIB_SOURCE=${zlib_SRC_DIR} \
