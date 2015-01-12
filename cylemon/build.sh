# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

if [[ `uname` == 'Darwin' ]]; then
    # OpenMP is not supported by default on Mac.
    python setup.py --no-extra-includes build build_ext -I${PREFIX}/include -L${PREFIX}/lib --no-openmp
else
    python setup.py --no-extra-includes build build_ext -I${PREFIX}/include -L${PREFIX}/lib
fi

python setup.py install

# We like to make builds of cylemon from arbitrary git commits (not always tagged).
# Include the git commit in the build version so we remember which one was used for the build.
echo "$GIT_DESCRIBE_HASH" > __conda_version__.txt 
