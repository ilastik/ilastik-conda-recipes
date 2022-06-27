#! /bin/bash

# Copy the plugin in the good directory:
outdir=$PREFIX/share/plugins/
mkdir -p $outdir
cp *.jar $outdir/

# Copy the java script:
cp "${RECIPE_DIR}/IlastikSetter.java" "${PREFIX}/IlastikSetter.java"
