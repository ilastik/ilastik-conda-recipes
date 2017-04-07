BIN=$PREFIX/bin
QTCONF=$BIN/qt.conf

if [ `uname` == 'Darwin' ]; then
    # Unfortunately, this package must be built with clang, not conda's gcc
    CC=/usr/bin/cc
    CXX=/usr/bin/c++

    # Leave Qt set its own flags and vars, else compilation errors
    # will occur
    for x in OSX_ARCH CFLAGS CXXFLAGS LDFLAGS
    do
	unset $x
    done

    CXXFLAGS="-stdlib=libstdc++"
    EXTRA_QT4_CONFIG_FLAGS="-cocoa -L/usr/X11/lib -I/usr/X11/include -arch x86_64"
    OPT_FLAG='-openssl -no-framework'
    
    export MACOSX_DEPLOYMENT_TARGET="10.9"
else
    EXTRA_QT4_CONFIG_FLAGS=""
    OPT_FLAG=''
fi

# pipe "yes" to stdin to accept the license.
echo "yes" | ./configure \
    --prefix=${PREFIX} \
    -opensource \
    -release \
    -fast \
    -opensource \
    -verbose \
    -optimized-qmake \
    $OPT_FLAG \
    -nomake examples \
    -nomake demos \
    -nomake docs \
    -nomake translations \
    -no-multimedia \
    -no-webkit \
    -no-audio-backend \
    -no-phonon \
    -no-phonon-backend \
    -no-sql-sqlite \
    -no-sql-sqlite2 \
    -no-sql-psql \
    -no-sql-db2 \
    -no-sql-ibase \
    -no-sql-mysql \
    -no-sql-oci \
    -no-sql-odbc \
    -no-sql-sqlite_symbian \
    -no-sql-tds \
    -no-pch \
    -no-dbus \
    -no-cups \
    -no-nis \
    -no-accessibility \
    -shared \
    -fontconfig \
    -system-zlib \
    -system-libpng \
    -system-libjpeg \
    -system-libtiff \
    -I${PREFIX}/include -I${PREFIX}/include/freetype2 \
    -L${PREFIX}/lib \
    ${EXTRA_QT4_CONFIG_FLAGS} \
##

# BUILD
make -j${CPU_COUNT}

# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    if [[ `uname` == 'Darwin' ]]; then
        export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib":"${DYLD_FALLBACK_LIBRARY_PATH}"
    else
        export LD_LIBRARY_PATH="$PREFIX/lib":"${LD_LIBRARY_PATH}"
    fi
    
    # Run the tests
    make -j${CPU_COUNT} check
)

# "install" to the build prefix (conda will relocate these files afterwards)
make install

# Make sure $BIN exists
if [ ! -d $BIN ]; then
  mkdir $BIN
fi

# Add qt.conf file to the package to make it fully relocatable
cat <<EOF >$QTCONF
[Paths]
Prefix = $PREFIX
EOF
