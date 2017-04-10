#!/bin/bash

#
# This is a post-link script for the scipy package, to work around
# a problem with how those binaries are built.
# For details, see:
# https://github.com/ContinuumIO/anaconda-issues/issues/899
#

if [ $(uname) != "Darwin" ];
then
  # Nothing to do
  exit 0
fi

if [ -z "$PREFIX" ];
then
  1>&2 echo "PREFIX is undefined! Exiting."
  exit 1
fi


for f_dylib in $(find ${PREFIX}/lib/python2.7/site-packages/scipy -type f -name "*.so");
do
  if otool -L $f_dylib | grep --quiet '/usr/local/lib/libgcc_s.1.dylib';
  then
    cmd="install_name_tool -change /usr/local/lib/libgcc_s.1.dylib /usr/lib/libSystem.B.dylib $f_dylib"
    echo $cmd
    $cmd
  fi
done
