#!/usr/bin/env bash

# Version 1.4.0b29
ilastik_bin=${CONDA_PREFIX}/bin/ilastik
if [ ! -e "$ilastik_bin" ]; then
  # Version 1.4.0b27
  ilastik_bin=${CONDA_PREFIX}/bin/ilastik-app
  if [ ! -e "$ilastik_bin" ]; then
    ilastik_bin=""
  fi
fi

if [ -n "$ilastik_bin" ]; then
  echo "
  ------------------------------------------------------------------------------

  Please run: bash $CONDA_PREFIX/pkgs/fiji-ilastik-1.8.2-0/info/recipe/set_ilastik_executable_in_ImageJ.sh
    to automatically set the ilastik executable in Fiji in headless mode.

  Alternatively, you can set it in Fiji with:
    Plugins>ilastik>Configure ilastik executable location
    ${CONDA_PREFIX}/bin/ilastik

  ------------------------------------------------------------------------------ 
" >> $PREFIX/.messages.txt
else
  echo "
  ------------------------------------------------------------------------------

  Please find the executable of ilastik (probably in ${CONDA_PREFIX}/bin/)
  and then set it in Fiji with:
    Plugins>ilastik>Configure ilastik executable location

  ------------------------------------------------------------------------------ 
" >> $PREFIX/.messages.txt
fi
