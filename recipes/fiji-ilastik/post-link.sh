#!/usr/bin/env bash
echo "
  ------------------------------------------------------------------------------
  Please use ImageJ_withIlastik to be sure that the ilastik path is set.
  Alternatively, you can set it in Fiji with:
    Plugins>ilastik>Configure ilastik executable location
    ${CONDA_PREFIX}/bin/ilastik
  ------------------------------------------------------------------------------ 
" >> "$PREFIX"/.messages.txt
