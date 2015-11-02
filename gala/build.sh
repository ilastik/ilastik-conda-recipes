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

python setup.py install
