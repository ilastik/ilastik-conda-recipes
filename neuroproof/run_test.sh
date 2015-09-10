# TEST (before install)
# (Since conda hasn't performed its link step yet, we must 
#  help the tests locate their dependencies via LD_LIBRARY_PATH)
if [[ `uname` == 'Darwin' ]]; then
    export DYLD_FALLBACK_LIBRARY_PATH="$PREFIX/lib":"${DYLD_FALLBACK_LIBRARY_PATH}"
else
    export LD_LIBRARY_PATH="$PREFIX/lib":"${LD_LIBRARY_PATH}"
fi

export PYTHONPATH="${SRC_DIR}/lib"
make test
