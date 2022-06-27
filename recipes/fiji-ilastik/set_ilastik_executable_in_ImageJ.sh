#!/usr/bin/env bash

# Indicate to Fiji where is the ilastik executable:

# # Using macro (20s)
# echo "run(\"Configure ilastik executable location\", \"executablefile=${CONDA_PREFIX}/bin/ilastik\");" > setexecutablefile.ijm
# ImageJ --ij2 --headless --console -macro setexecutablefile.ijm
# rm setexecutablefile.ijm

# Using java script (super quick)
java "${CONDA_PREFIX}/IlastikSetter.java" "${CONDA_PREFIX}/bin/ilastik"
