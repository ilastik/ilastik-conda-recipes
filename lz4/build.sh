# Get commonly needed env vars
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

# BUILD (lz4 checks the PREFIX env variable)
PREFIX=${PREFIX} make -j${CPU_COUNT}

# TEST (before install)
(
    # (Since conda hasn't performed its link step yet, we must 
    #  help the tests locate their dependencies via LD_LIBRARY_PATH)
    export ${LIBRARY_SEARCH_VAR}=$PREFIX/lib:${!LIBRARY_SEARCH_VAR}

    # FIXME: Look, this test takes WAAAYYY too long, and it apparently 
    #        isn't safe to run it on multiple cores with make -j{CPU_COUNT}
    #        I'm commenting it out for now.
    #make test
)

PREFIX=${PREFIX} make install
