#!/usr/bin/env bash

echo "
  ------------------------------------------------------------------------------

  Please run: bash $CONDA_PREFIX/pkgs/fiji-ilastik-1.8.2-0/info/recipe/set_ilastik_executable_in_ImageJ.sh
    to automatically set the ilastik executable in Fiji in headless mode.

  Alternatively, you can set it in Fiji with:
    Plugins>ilastik>Configure ilastik executable location
    ${CONDA_PREFIX}/bin/ilastik

  ------------------------------------------------------------------------------ 
" >> $PREFIX/.messages.txt
