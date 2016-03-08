# Allow us to override PREFIX with our environment setting
sed 's/PREFIX =/PREFIX ?=/g' < Makefile > Makefile.patched
mv Makefile.patched Makefile

# Replace -L$(MITOOLBOXPATH) with -L$(PREFIX)/lib
sed 's|-L$(MITOOLBOXPATH)|-L$(PREFIX)/lib|g' < Makefile > Makefile.patched
mv Makefile.patched Makefile

# Replace -I$(MITOOLBOXPATH) with -I$(PREFIX)/include/MIToolbox
sed 's|-I$(MITOOLBOXPATH)|-I$(PREFIX)/include/MIToolbox|g' < Makefile > Makefile.patched
mv Makefile.patched Makefile

# Make sure these exist...
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

# Build and install.
PREFIX=${PREFIX} make install
