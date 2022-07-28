#!/usr/bin/env bash

# Copy the plugin in the good directory:
outdir="$PREFIX/share/plugins/"
mkdir -p "$outdir"
cp *.jar "$outdir/"

# Create another ImageJ binary which will set the path of Ilastik before launching:
mkdir -p "${PREFIX}/bin/"
mkdir -p "${PREFIX}/share/"
cp "${RECIPE_DIR}/ImageJ-ilastik" "${PREFIX}/bin/ImageJ-ilastik"
cp "${RECIPE_DIR}/IlastikSetter.java" "${PREFIX}/share/IlastikSetter.java"

chmod a+x "${PREFIX}/bin/ImageJ-ilastik"
