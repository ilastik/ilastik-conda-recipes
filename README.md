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

#### Notes on using the tracking package:
Tracking requires CPLEX, and it looks for these libraries using the environment variable `CPLEX_ROOT_DIR`. Point it to the root of your CPLEX installation when using the tracking workflow in ilastik, or when building the `pgmlink` conda package yourself.

2.b. (Optional) Build your own packages
--------------------------------------

(Most users can skip this step.  It's an alternative to step 2 above.)

If your version of `GLIBC` is too old, you might not be able to use the binary ilastik packages 
from the `stuarteberg` binstar channel.  Instead, you can try building those dependencies your self.
The recipes for ilastik and its dependencies can be found in the [`ilastik-build-conda` repository][ilastik-build-conda].

[ilastik-build-conda]: http://github.com/ilastik/ilastik-build-conda

```
# Prerequisite: Install conda-build
$ source activate root
$ conda install conda-build jinja2

# Clone the ilastik build recipes
$ git clone http://github.com/ilastik/ilastik-build-conda
$ cd ilastik-build-conda

# Start with a fresh environment.
$ conda create -n ilastikdev python=2.7
$ conda build ilastik-deps-pc

# Now install your newly built binaries, directly from your local build directory into the environment and activate it:
$ conda install --use-local -n ilastikdev ilastik-deps-pc
$ source activate ilastikdev
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

- General

 - [ ] Not all Tracking Workflow dependencies are supported yet, even on Mac/Linux.

 - [ ] How do we handle external libraries (like CPLEX)?

 - [ ] Apparently, the VTK package provided by Continuum (Anaconda) was not built with PyQt support.  
   We'll have to build our own VTK package, and pass 
   `-DVTK_USE_QT:BOOL=ON -DSIP_EXECUTABLE:FILEPATH=$PREFIX/bin/sip -DSIP_INCLUDE_DIR:PATH=$PREFIX/include/python2.7 -DSIP_PYQT_DIR:PATH=$PREFIX/share/sip/PyQt4` 
   to the `cmake` step.

 - [ ] In cases where we provide an alternative build of a package that Continuum already provides, we need to 
   make sure our special channel takes priority over the `defaults` channel used by conda.  It isn't immediately 
   obvious how this is supposed to be achieved in conda. (**Edit:** Which packages does this refer to?  VTK?) 

 - [ ] So far, the `meta.yaml` files for `ilastik-deps-pc`, etc. do not list explicit version requirements for 
   each dependency (e.g. `boost ==1.55`, or `vigra ==g14de6ac`).  We should fix that, and this repo should be 
   tagged with the ilastik version number every time we make a release.  This repo will become the official record 
   of which dependency versions were used in each release (via the `meta.yaml` files).

 - [ ] The ilastik, lazyflow, and volumina repos themselves are not included as dependencies in this build repository.
   How should we deal with them?

 - [ ] Instead of uploading packages to our own [binstar] channels individually, we should create a shared account for 
   ilastik on binstar, to be used by all ilastik maintainers.

 - [ ] It would be nice if we built "debug" versions of important packages (e.g. Python, vigra, Qt) 
   and attached them to the `[debug]` conda-build "feature".

- Linux

 - [ ] We need to extract the final packaging steps `ilastik-build-Linux` and adapt them 
   to work with the builds generated in this repo.

- Mac

 - [ ] At the moment, we can't use `py2app` to package ilastik if we built it with conda.  
   It has something to do with the fact that we have a top-level package named `ilastik` 
   and a conflicting top-level script named `ilastik.py`.  If we rename or move the script, 
   then we can use py2app.  (It isn't clear why this issue doesn't appear in our old setup.)

 - [ ] `conda` doesn't resolve the general issue of ABI incompatibility between `libc++` and `libstdc++`. 
   (Continuum just uses `libstdc++` everywhere, apparently.) 
   Should we attempt to create a new "feature" that tracks this linker setting?
   (**Edit:** This shouldn't be an issue: we should use only `libstdc++`, and conda's gcc binary whereever possible.)

- Windows

 - [ ] So far, this repo includes no package build scripts for Windows.

 - [ ] Generate a final binary package from the built dependencies

 - [ ] Similar to the above issue on Mac, should we attempt to track different versions of 
   the MSVC++ std library via a conda "feature" as well?
