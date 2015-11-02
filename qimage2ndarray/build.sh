if [[ ${NPY_VER} == '' ]]; then
    set +x
    1>&2 echo "*************************************************************************************"
    1>&2 echo "Error: No numpy version specified."
    1>&2 echo "       Please use --numpy=X.Y when invoking conda-build."
    1>&2 echo "       For example:"
    1>&2 echo
    1>&2 echo "           conda build --python=2.7 --numpy=1.9 ${PKG_NAME}"
    1>&2 echo
    1>&2 echo "*************************************************************************************"
    exit 1
fi

#!/bin/bash

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

$PYTHON setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
