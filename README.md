===================
ilastik-build-conda
===================

[ilastik] depends on **60+ packages**.  Most of those packages are already provided for us by the [Anaconda] Python distribution.
For 20+ the packages that *aren't* provided by Anaconda, we use the recipes in this repo.

These recipes are built using the [conda-build][2] tool.
The resulting binaries are uploaded to the [ilastik binstar channel][3],
and can be installed using the [conda][1] package manager.

[1]: http://conda.pydata.org/
[2]: http://conda.pydata.org/docs/build.html
[3]: https://binstar.org/ilastik
[Anaconda]: https://store.continuum.io/cshop/anaconda
[ilastik]: http://ilastik.org

==================================
Installing ilastik for development
==================================

Here's how to install everything you need to develop ilastik.

0. Prerequisite: Install conda (via Anaconda or [Miniconda][Miniconda])
----------------------------------------------------------

[Miniconda]: http://conda.pydata.org/miniconda.html

```
# Install miniconda to the prefix of your choice, e.g. /my/miniconda

# LINUX:
$ wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
$ bash Miniconda-latest-Linux-x86_64.sh

# MAC:
$ wget https://repo.continuum.io/miniconda/Miniconda-latest-MacOSX-x86_64.sh
$ bash Miniconda-latest-MacOSX-x86_64.sh

# Activate conda
$ CONDA_ROOT=/my/miniconda
$ source ${CONDA_ROOT}/bin/activate root
```

1. Create a fresh environment, and install ilastik
--------------------------------------------------

```
CPLEX_ROOT_DIR=/path/to/cplex conda create -n ilastik-devel -c ilastik ilastik-everything
``` 

2. Run ilastik
--------------

```
${CONDA_ROOT}/envs/ilastik-devel/run_ilastik.sh --debug
```

3. (Optional) Clone ilastik git repo into your environment
----------------------------------------------------------

The installation downloaded the ilastik source, but not the git repo.
If you need to edit the ilastik python repos, 
replace the `ilastik-meta` directory with the full git repo.

```
$ rm -rf ${CONDA_ROOT}/envs/ilastik-devel/ilastik-meta
$ git clone http://github.com/ilastik/ilastik-meta ${CONDA_ROOT}/envs/ilastik-devel/ilastik-meta
$ cd ilastik-meta
$ git submodule init
$ git submodule update --recursive
$ git submodule foreach "git checkout master"
```

===========================
Generating a release binary
===========================

1. Update the version number.

  1. Edit `ilastik.__version__` (in ilastik/ilastik.py) and commit your change.
  2. Commit to `ilastik-meta` and add a matching git tag, e.g. `git tag -a 1.1.9`
  3. Update the `git_tag` in `ilastik/meta.yaml` and commit.

2. Build `ilastik-meta` package and upload to the `ilastik` binstar channel.
  
```
$ conda build ilastik-meta
$ binstar upload -u ilastik ${CONDA_ROOT}/conda-bld/linux-64/ilastik-meta*.tar.gz
```

3. Create tarball/app

   - Mac: `./create-osx-app.sh -c ilastik`
   - Linux: `./create-linux-tarball.sh -c ilastik`

====================================
How to build these packages yourself
====================================

All of the recipes in this repo should already be uploaded to the [ilastik][3] binstar channel.
The linux packages were built on CentOS 5.11, so they should be compatible with most modern distros.
The Mac packages were built with `MACOSX_DEPLOYMENT_TARGET=10.7`, so they should theoretically support OSX 10.7+.

But if, for some reason, you need to build your own binary packages from these recipes, it should be easy to do so:

```
# Prerequisite: Install conda-build and jinja2
$ source activate root
$ conda install conda-build jinja2

# Clone the ilastik build recipes
$ git clone http://github.com/ilastik/ilastik-build-conda
$ cd ilastik-build-conda

# Build a recipe, e.g:
$ conda build vigra

# Now install your newly built package, directly from your local build directory:
$ conda install --use-local -n ilastik-devel vigra
```

Now run ilastik from with your ilastik meta-repo:

```
$ cd /path/to/ilastik-meta

# Run ilastik
$ PYTHONPATH="ilastik:lazyflow:volumina" python ilastik/ilastik.py
```

==============================
Appendix: Writing a new recipe
==============================

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
conda install binstar
binstar upload /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2
```

[binstar]: http://binstar.org

==========================
Appendix: Compiler details
==========================

**When writing your own recipes, use gcc provided by conda.**

Instead of using your system compiler, all of our C++ packages use the `gcc` package provided by conda
itself (or our own variation of it).  On Mac, using gcc is critical because some packages require a
modern (C++11) version of `libstdc++`.  On Linux, using conda's gcc-4.8 is an easy way to get C++11
support on old OSes, such as our CentOS 5.11 build VM.

To use the gcc package, add these requirements to your `meta.yaml` file:

```
requirements:
  build:
    - gcc 4.8.2.99 # [linux]
    - gcc 4.8.2 # [osx]
  run:
    - libgcc
```

And in `build.sh`, make sure you use the right `gcc` executable.  For example:

```
export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

# conda provides default values of these on Mac OS X,
# but we don't want them when building with gcc
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""

./configure --prefix=${PREFIX} ...etc...
make
make install

# Or, for cmake-based packages:
mkdir build
cd build
cmake .. \
    -DCMAKE_C_COMPILER=${PREFIX}/bin/gcc \
    -DCMAKE_CXX_COMPILER=${PREFIX}/bin/g++ \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ...etc...

make
make install
```

==========================
Appendix: Linux VM Details
==========================

The Anaconda distribution is built on a CentOS 5.11 VM.  To build the ilastik stack on that OS, you'll need to install the following:
 
- `cmake`, `git`, `conda`, `gcc`
- VTK dependencies: 
  * OpenGL: `yum install mesa-libGL-devel`
  * X11: `yum groupinstall "X Software Development"`
- Recommended: VirtualBox Guest additions
  1. Register external package repository "rpmforge"
    * http://wiki.centos.org/AdditionalResources/Repositories/RPMForge#head-5aabf02717d5b6b12d47edbc5811404998926a1b
  2. Install package `dkms`
  3. In VBox menu, select `Devices` > `Insert Guest Additions CD`
  4. From disk image, install Guest Additions from command line


==================
Appendix: TODO/TBD
==================

- General

 - [x] In cases where we provide an alternative build of a package that Continuum already provides, we need to 
   make sure our special channel takes priority over the `defaults` channel used by conda.
   (**Edit:** Ideally, we could just use a custom "build string", but due to conda/conda#918, that doesn't work.
   Instead, we just use a deliberately strange version number in our custom packages, e.g. `version: 5.10.1.99`.)

 - [ ] It would be nice if we built "debug" versions of important packages (e.g. Python, vigra, Qt) 
   and attached them to the `[debug]` conda-build "feature".

 - [ ] The final binaries produced via `create-Linux-tarball.sh` and `create-osx-app.sh` are quite large.
   They could be reduced by excluding unecessary dylibs and stripping the remaining dylibs.
   Also, directories like `include`, etc. should be excluded.


- Mac

 - [ ] For unknown reasons, the `py2app` module does not work "out-of-the-box" for this conda build.
   (The resulting app crashes frequently.) It probably has something to do with our new dependency on `gcc-4.8` and `libgcc`.
   The current version of `create-osx-app.sh` uses a hacky workaround for this issue.
   It would be nice if we could figure out what the real issue is.

- Windows

 - [ ] So far, this repo includes no package build scripts for Windows.

 - [ ] Generate a final binary package from the built dependencies

 - [ ] Should we attempt to track different versions of the MSVC++ std library via a conda "feature"?

