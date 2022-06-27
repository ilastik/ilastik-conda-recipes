#!/usr/bin/env bash

echo "
  ------------------------------------------------------------------------------

  Please run: $CONDA_PREFIX/bin/set_ilastik_executable_in_ImageJ
    to automatically set the ilastik executable in Fiji in headless mode.

  Alternatively, you can set it in Fiji with:
    Plugins>ilastik>Configure ilastik executable location
    ${CONDA_PREFIX}/bin/ilastik

  ------------------------------------------------------------------------------ 
" >> $PREFIX/.messages.txt
