#!/usr/bin/env bash

# Copy the plugin in the good directory:
outdir="$PREFIX/share/plugins/"
mkdir -p "$outdir"
cp *.jar "$outdir/"

# Create another ImageJ binary which will set the path of Ilastik before launching:
mkdir -p "${PREFIX}/bin/"
cp "${RECIPE_DIR}/ImageJ_withIlastik" "${PREFIX}/bin/ImageJ_withIlastik"
cp "${RECIPE_DIR}/IlastikSetter.java" "${PREFIX}/IlastikSetter.java"

chmod a+x "${PREFIX}/bin/ImageJ_withIlastik"
