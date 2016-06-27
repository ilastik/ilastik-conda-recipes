These recipe files can build multiple variants of this package.
The variant built depends on some environment variables, as described here.

DEFAULT
-------
By default, OpenGM is built without any external library support:

    $ conda build --numpy=1.9 opengm

`WITH_EXTERNAL_LIBS`
--------------------
Some OpenGM functionality requires external libraries: qpbo, blossom5, and planarity.
OpenGM comes with scripts to download those libraries (and patch them as needed).
To enable those dependencies in your build, use the `WITH_EXTERNAL_LIBS` environment variable:

    $ WITH_EXTERNAL_LIBS=1 conda build --numpy=1.9 opengm

When that option is used, the external libs are downloaded (via `make externalLibs`)
and `-DWITH_QPBO=ON -DWITH_PLANARITY=ON -DWITH_BLOSSOM5=ON` is added to the opengm cmake configuration. 

**NOTE:** At the time of this writing, the package name/version/build-string are
          *not* changed in any way to indicate that the external libraries were used!

`WITH_CPLEX`
------------
If you have CPLEX enabled, use the `WITH_CPLEX` environment variable.
If necessary, also provide `CPLEX_ROOT_DIR`.

For example:

    $ CPLEX_ROOT_DIR='/Users/bergs/Applications/IBM/ILOG/CPLEX_Studio1251' WITH_CPLEX=1 conda build --numpy=1.9 opengm

**NOTE:** The package name is CHANGED from `opengm` to `opengm-with-cplex`.
          Furthermore, the name of the python package is also changed:
    
    >>> import opengm_with_cplex

BOTH
----
You may combine `WITH_EXTERNAL_LIBS=1` and `WITH_CPLEX=1` in a single build.
