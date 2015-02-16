===================
ilastik-build-conda
===================

This repo contains recipes for building ilastik's dependencies as [conda][1] packages.

[1]: http://conda.pydata.org/

==================================
How to install ilastik using conda
==================================

0. Prerequisite: Install conda (via Anaconda or Miniconda)
----------------------------------------------------------

```
# Install miniconda to the prefix of your choice, e.g. /my/miniconda
$ wget http://repo.continuum.io/miniconda/Miniconda-3.8.3-MacOSX-x86_64.sh
$ bash Miniconda-3.8.3-MacOSX-x86_64.sh
```

1. Prepare an environment to install into
-----------------------------------------

```
# Activate the root conda env just to get us started (just to get 'conda' on our path)
$ source /my/miniconda/bin/activate root

# Create a new conda "environment" to install ilastik into (e.g. named ilastikenv)
$ conda create -n ilastikenv python=2.7

# Activate our new env
$ source activate ilastikenv
```

2. Install dependency packages
------------------------------

All pixel classification dependencies can be installed via the `ilastik-deps-pc` "metapackage".
Most dependencies will be pulled from the main anaconda package repo,
 but a custom [binstar] channel is used here for the others.

```
$ conda install --channel stuarteberg ilastik-deps-pc

# Or, to install the carving workflow, too:
$ conda install --channel stuarteberg ilastik-deps-carving
```

3. Run ilastik from your own local repository
---------------------------------------------

The dependency packages don't include the [`ilastik`][ilastik-repo]/[`lazyflow`][lazyflow-repo]/[`volumina`][volumina-repo] repos.
If you haven't already done so, clone and prepare the [ilastik-meta] repo:

```
$ git clone http://github.com/ilastik/ilastik-meta
$ cd ilastik-meta
$ git submodule init
$ git submodule update --recursive
```

[ilastik-repo]: http://github.com/ilastik/ilastik
[lazyflow-repo]: http://github.com/ilastik/lazyflow
[volumina-repo]: http://github.com/ilastik/volumina

[ilastik-meta]: http://github.com/ilastik/ilastik-meta

Now run ilastik from with your ilastik meta-repo:

```
$ cd /path/to/ilastik-meta

# Run ilastik
$ PYTHONPATH="ilastik:lazyflow:volumina" python ilastik/ilastik.py
```

======================
Building a new package
======================

The [conda documentation][2] explains in detail how to create a new package, but here's a quick summary:

[2]: http://conda.pydata.org/docs/build.html

0. Prerequisite: Install `conda-build`
--------------------------------------

```
$ source activate root
$ conda install conda-build jinja2
```

1. Add a directory to this repo, with the same name as your package.
--------------------------------------------------------------------

```
$ cd ilastik-build-conda
$ mkdir somepackage
$ cd somepackage
```

2. Create recipe files
----------------------

A complete recipe has at least 3 files:

 - `meta.yaml`
 - `build.sh` (used for both Mac and Linux)
 - `bld.bat` (used for Windows)

...additional files (such as patches) may be needed for some recipes.

Write **meta.yaml**:

```
$ cat > meta.yaml
package:
  name: somepackage
  version: 1.2.3

source:
  fn: somepackage-1.2.3.tar.bz2
  url: http://www.randompackages.org/somepackage/somepackage-1.2.3.tar.bz2
  md5: b060bb137d6bd8accf8f0c4c59d2746d

requirements:
  build:
    - zlib
    - python
  run:
    - zlib
    - python

about:
  home: http://www.somepackage.com
  license: WYSIWYG v3
```

Write **build.sh**:

```
$ cat > build.sh
# For ilastik dependencies, we include commonly needed environment variables via this shared script
CWD=$(cd `dirname $0` && pwd)
source $CWD/../common-vars.sh

# Now configure, make, and install
configure --prefix=$PREFIX --with-zlib=$PREFIX
make -j${CPU_COUNT}
make install
```

Write **build.sh**:

```
$ cat > bld.bat
mkdir build
cd build

REM Configure step
cmake -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release %SRC_DIR%

REM Build step
devenv SomePackage.sln /Build "%RELEASE_TARGET%"
if errorlevel 1 exit 1

REM Install step
devenv SomePackage.sln /Build "%RELEASE_TARGET%" /Project INSTALL
if errorlevel 1 exit 1
```

3. Build the package
--------------------

```
# Switch back to the `ilastik-build-conda` directory
$ cd ../

# Build the package
$ conda build somepackage
```

4. Upload the package to your [binstar] account.
------------------------------------------------

```
binstar upload /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2
```

[binstar]: http://binstar.org