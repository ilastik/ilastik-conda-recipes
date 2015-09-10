# Add the ilastik modules to sys.path
cat > ${PREFIX}/lib/python2.7/site-packages/ilastik-meta.pth << EOF
../../../ilastik-meta/lazyflow
../../../ilastik-meta/volumina
../../../ilastik-meta/ilastik
EOF

