#!/bin/bash
# 
# If our version of libstdc++.so (installed from conda) is older than the one on the user's OS, then we must not use our version.
# This script inspects the symbols in our version and the system version and decides which one is newer.
# If the system's libstdc++.so is newer than ours, it deletes ours.
#
# This script uses the following external environment variables:
#
# - PREFIX
#       The conda environment to inspect.
#
# - LIB_SEARCH_DIRS
#       Optional. A space-delimited list of directories to search for the system's libstdc++.so file.
#
# - PKG_NAME
#       Optional. The name of the package that provided conda's libstdc++.so file.
#

# The list of directories we check for system libs
LIB_SEARCH_DIRS="$LIB_SEARCH_DIRS /lib"     # CentOS
LIB_SEARCH_DIRS="$LIB_SEARCH_DIRS /usr/lib" # CentOS
LIB_SEARCH_DIRS="$LIB_SEARCH_DIRS /lib/x86_64-linux-gnu"     # Ubuntu
LIB_SEARCH_DIRS="$LIB_SEARCH_DIRS /usr/lib/x86_64-linux-gnu" # Ubuntu

parse_libstdcxx_version() {
    LIBSTDCXX_SO=$1
    
    # This command reads all the GLIBCXX symbol versions from libstdc++.so and finds the max version.
    # (There are ways to do this with 'strings' or 'readelf' instead of 'grep',
    # but 'grep' is more likely to be installed on an arbitrary linux machine.)
    LIBSTDCXX_VERSION=$(grep -ao 'GLIBCXX_[0-9][0-9]\?\.[0-9][0-9]\?\(\.[0-9][0-9]\?\)\?' $LIBSTDCXX_SO \
                        | cut -b 9- \
                        | sort -t'.' -n -k3) 
    echo $LIBSTDCXX_VERSION
}

detect_newer_system_libstdcxx()
{
	for LIB_DIR in $LIB_SEARCH_DIRS; do
	    CONDA_LIBSTDCXX="${PREFIX}"/lib/libstdc++.so.6
        if [ -e "${CONDA_LIBSTDCXX}" ]; then
    	    CONDA_LIBSTDCXX_VERSION=$(parse_libstdcxx_version "${CONDA_LIBSTDCXX}")
        else
            # Conda's libstdc++ wasn't installed or has already been removed.
            return 1 # False
        fi

		if [ -e ${LIB_DIR}/libstdc++.so.6 ]; then
            SYSTEM_LIBSTDCXX_VERSION=$(parse_libstdcxx_version ${LIB_DIR}/libstdc++.so.6)
		
		    echo "Found system libstdc++ version: ${SYSTEM_LIBSTDCXX_VERSION}"
		    echo "Found conda  libstdc++ version: ${CONDA_LIBSTDCXX_VERSION}"
		
		    # The 'not' here looks backwards, but remember that in bash, '0' means TRUE
		    if python -c \
	            "import sys; sys.exit(not '$CONDA_LIBSTDCXX_VERSION'.split('.') < '$SYSTEM_LIBSTDCXX_VERSION'.split('.'))";
		    then
                PKG_NAME=${PKG_NAME-libgcc}
		        echo "This system has a newer version of libstdc++.so than the one in the ${PKG_NAME} package."
		        return 0 # True
		    fi
		fi
	done

	return 1 # False
}

#
# If the given LIB_NAME can be found in a system directory, then 
# replace conda's version (and links to it) with symlinks to
# the system's version.
#
# Precondition: The current directory must be $PREFIX/lib
#
replace_lib_with_syslib_link()
{
    LIB_NAME=$1

    for LIB_DIR in $LIB_SEARCH_DIRS; do
        #echo "Checking ${LIB_DIR}/${LIB_NAME}".so
        if [ ! -z "$(ls ${LIB_DIR}/${LIB_NAME}.* 2> /dev/null)" ]; then
            #echo "Replacing ${LIB_NAME}..."

            # Replace all .so files in the package
            for f in $(ls ${LIB_NAME}.so*); do
                echo "Removing $(pwd)/$f" && rm $f
                if [ -e $LIB_DIR/$f ]; then
                    echo "Adding link to $LIB_DIR/$f"
                    ln -s -f $LIB_DIR/$f
                    
                    # Make sure the generic lib<X>.so is definitely present if we haven't made it yet. 
                    if [ -z "$(ls ${LIB_DIR}/${LIB_NAME}.so 2> /dev/null)" ]; then
                        ln -s -f $LIB_DIR/$f ${LIB_NAME}.so
                    fi
                fi
            done

            # Replace .a files, too
            for f in $(ls ${LIB_NAME}.a 2> /dev/null); do
                echo "Removing $(pwd)/$f" && rm $f
                if [ -e $LIB_DIR/$f ]; then
                    echo "Adding link to $LIB_DIR/$f"
                    ln -s -f $LIB_DIR/$f
                    
                    # Make sure the generic lib<X>.a is definitely present if we haven't made it yet. 
                    if [ -z "$(ls ${LIB_DIR}/${LIB_NAME}.a 2> /dev/null)" ]; then
                        ln -s -f $LIB_DIR/$f ${LIB_NAME}.so
                    fi
                fi
            done
        fi
    done
}

main()
{
    if [ "$#" -ne 0 ] || [ -z "$PREFIX" ]; then
        1>&2 echo "Usage: PREFIX=/path/to/conda-environment $0"
        1>&2 echo "Description: Removes libstdc++ (and related) files from a conda environment "
        1>&2 echo "             if a newer version of libstdc++ exists on the system."
        1>&2 echo "             Reads the PREFIX environment variable to locate the conda files."
        
        if [ -z "$PREFIX" ]; then
            1>&2 echo "**"
            1>&2 echo "** Error: PREFIX environment variable is empty. **"
            1>&2 echo "**"
                fi
        exit 1
    fi
    
	if detect_newer_system_libstdcxx; then
	    echo "Replacing outdated libstdc++ files..."
	    # There is a way to do this by parsing $PREFIX/conda-meta/libgcc*.json,
	    # but that's overly complicated, and gets more complicated if we also want
	    # to do this in the gcc package, since it has more libs and it's not clear
	    # if those others can be safely removed.
	    #
	    # So let's just hard-code the paths to remove.
        (
            set -e
            cd "$PREFIX"/lib
            replace_lib_with_syslib_link libgcc_s
            replace_lib_with_syslib_link libgomp
            replace_lib_with_syslib_link libquadmath
            replace_lib_with_syslib_link libstdc++
            replace_lib_with_syslib_link libgfortran
        )
	fi
}

main "$@"
