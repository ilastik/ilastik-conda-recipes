#!/usr/bin/env bash

# Update the executable path:
# Version 1.4.0b29
ilastik_bin=${CONDA_PREFIX}/bin/ilastik
if [ ! -e "$ilastik_bin" ]; then
  # Version 1.4.0b27
  ilastik_bin=${CONDA_PREFIX}/bin/ilastik-app
  if [ ! -e "$ilastik_bin" ]; then
    ilastik_bin=""
  fi
fi

# Indicate to Fiji where is the ilastik executable:
echo "run(\"Configure ilastik executable location\", \"executablefile=${ilastik_bin}\");" > setexecutablefile.ijm
ImageJ --ij2 --headless --console -macro setexecutablefile.ijm
rm setexecutablefile.ijm
