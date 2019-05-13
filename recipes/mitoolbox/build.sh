# Allow us to override PREFIX with our environment setting
sed 's/PREFIX =/PREFIX ?=/g' < Makefile > Makefile.patched
mv Makefile.patched Makefile

# Make sure these exist...
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

# Build and install.
PREFIX=${PREFIX} make install
