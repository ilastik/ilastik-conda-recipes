file(INSTALL libtiff/tiff.h libtiff/tiffconf.h libtiff/tiffio.h libtiff/tiffiop.h libtiff/tiffvers.h DESTINATION ${TIFF_INSTALL_PREFIX}/include)
file(INSTALL libtiff/libtiff.dll DESTINATION ${TIFF_INSTALL_PREFIX}/bin)
file(INSTALL libtiff/libtiff_i.lib libtiff/libtiff.lib DESTINATION ${TIFF_INSTALL_PREFIX}/lib)
