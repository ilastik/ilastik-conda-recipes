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

# Or, if you only need headless mode (no GUI dependencies), use this:
$ conda install --channel stuarteberg ilastik-deps-pc-headless
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

Write **bld.bat**:

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

========
TODO/TBD
========

- So far, this repo includes no package build scripts for Windows.

- Mac: At the moment, we can't use `py2app` to package ilastik if we built it with conda.  
  It has something to do with the fact that we have a top-level package named `ilastik` 
  and a conflicting top-level script named `ilastik.py`.  If we rename or move the script, 
  then we can use py2app.  (It isn't clear why this issue doesn't appear in our old setup.)

- Linux: We need to extract the final packaging steps `ilastik-build-Linux` and adapt them 
  to work with the builds generated in this repo.

- Ditto for Windows, once we have build scripts for the individual packages.

- Packages built *outside* of conda (i.e. CPLEX) must be "manually" linked via `install_name_tool`
  or `chrpath`, etc. during the build or post-build step.  We are still exploring the "right" way to do this.

- Not all Tracking Workflow dependencies are supported yet, even on Mac/Linux.

- Apparently, the VTK package provided by Continuum (Anaconda) was not built with PyQt support.  
  We'll have to build our own VTK package, and pass 
  `-DVTK_USE_QT:BOOL=ON -DSIP_EXECUTABLE:FILEPATH=$PREFIX/bin/sip -DSIP_INCLUDE_DIR:PATH=$PREFIX/include/python2.7 -DSIP_PYQT_DIR:PATH=$PREFIX/share/sip/PyQt4` 
  to the `cmake` step.

- In cases where we provide an alternative build of a package that Continuum already provides, we need to 
  make sure our special channel takes priority over the `defaults` channel used by conda.  It isn't immediately 
  obvious how this is supposed to be achieved in conda. 

- It would be nice if we built "debug" versions of important packages (e.g. Python, vigra, Qt) 
  and attached them to the `[debug]` conda-build "feature".

- Mac: `conda` doesn't resolve the general issue of ABI incompatibility between `libc++` and `libstdc++`. (Continuum just uses `libstdc++` everywhere, apparently.) 
  Should we attempt to create a new "feature" that tracks this linker setting?

- Windows: Similar to the above issue on Mac, should we attempt to track different versions of 
  the MSVC++ std library via a conda "feature" as well?

- So far, the `meta.yaml` files for `ilastik-deps-pc`, etc. do not list explicit version requirements for 
  each dependency (e.g. `boost ==1.55`, or `vigra ==g14de6ac`).  We should fix that, and this repo should be 
  tagged with the ilastik version number every time we make a release.  This repo will become the official record 
  of which dependency versions were used in each release (via the `meta.yaml` files).

- The ilastik, lazyflow, and volumina repos themselves are not included as dependencies in this build repository.
  How should we deal with them?

- Instead of uploading packages to our own [binstar] channels individually, we should create a shared account for 
  ilastik on binstar, to be used by all ilastik maintainers.
