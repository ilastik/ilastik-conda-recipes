./configure --prefix=$PREFIX
make
make tests
make install

# Avoid confusion with the standard patchelf utility.
mv ${PREFIX}/bin/patchelf ${PREFIX}/bin/patchelf-bigfile
