if [ $(echo $PREFIX | grep -q envs)$? -eq 0 ]; then
    ROOT_ENV_PREFIX="${PREFIX}/../.."
else
    ROOT_ENV_PREFIX="${PREFIX}"
fi
GUROBI_LOCATION_CACHE_FILE="${ROOT_ENV_PREFIX}/share/gurobi-root-dir.path"


if [ "$GUROBI_ROOT_DIR" == "" ]; then 
    GUROBI_ROOT_DIR="<UNDEFINED>"
fi


if [ "$GUROBI_ROOT_DIR" != "<UNDEFINED>" ]; then
    # If the environment-provided GUROBI_ROOT_DIR doesn't match the 
    #  cache-provided value, (over)write the cache file.
    SAVED_GUROBI_ROOT_DIR=`cat ${GUROBI_LOCATION_CACHE_FILE} 2> /dev/null` \
    || SAVED_GUROBI_ROOT_DIR="<UNDEFINED>"
    if [ "$SAVED_GUROBI_ROOT_DIR" != "$GUROBI_ROOT_DIR" ]; then
    echo "${GUROBI_ROOT_DIR}" > ${GUROBI_LOCATION_CACHE_FILE}
    fi
fi 

if [ "$GUROBI_ROOT_DIR" == "<UNDEFINED>" ]; then
    # Get GUROBI_ROOT_DIR from our the cache file.
    GUROBI_ROOT_DIR=`cat ${GUROBI_LOCATION_CACHE_FILE} 2> /dev/null` \
    || GUROBI_ROOT_DIR="<UNDEFINED>"
fi

# Remove the symlinks we made post-link.sh
cd ${PREFIX}/lib
for f in $(ls ${GUROBI_ROOT_DIR}/lib/*.so); do
    rm -f ${PREFIX}/lib/$(basename ${f})
done
