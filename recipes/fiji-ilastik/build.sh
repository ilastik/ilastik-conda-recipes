#! /bin/bash

# Copy the plugin in the good directory:
outdir=$PREFIX/share/plugins/
mkdir -p $outdir
cp *.jar $outdir/

# Copy the java script:
cp "${RECIPE_DIR}/IlastikSetter.java" "${PREFIX}/IlastikSetter.java"

# Copy the bash script in bin:
mkdir -p "${PREFIX}/bin/"
cp "${RECIPE_DIR}/set_ilastik_executable_in_ImageJ.sh" "${PREFIX}/bin/set_ilastik_executable_in_ImageJ"
chmod a+x "${PREFIX}/bin/set_ilastik_executable_in_ImageJ"
