#!/usr/bin/env bash

# Update the executable path:
# Version 1.4.0b29
ilastik_bin=${CONDA_PREFIX}/bin/ilastik

# Indicate to Fiji where is the ilastik executable:
echo "run(\"Configure ilastik executable location\", \"executablefile=${ilastik_bin}\");" > setexecutablefile.ijm
ImageJ --ij2 --headless --console -macro setexecutablefile.ijm
rm setexecutablefile.ijm
