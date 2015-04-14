# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

# Grab the right gcc/g++ from the path.
GCC=$(which gcc)
GXX=$(which g++)

# CONFIGURE
cd $SRC_DIR

# BUILD (in parallel)
eval CC=$GCC CXX=$GXX ${LIBRARY_SEARCH_VAR}=$PREFIX/lib ${PYTHON} setup.py build

# "install" to the build prefix (conda will relocate these files afterwards)
eval CC=$GCC CXX=$GXX ${LIBRARY_SEARCH_VAR}=$PREFIX/lib ${PYTHON} setup.py install --prefix=$PREFIX
