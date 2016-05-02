===================
ilastik-build-conda
===================

[ilastik] depends on **60+ packages**.  Most of those packages are already provided for us by the [Anaconda] Python distribution.
For 20+ the packages that *aren't* provided by Anaconda, we use the recipes in this repo.

These recipes are built using the [conda-build][2] tool.
The resulting binaries are uploaded to the [ilastik anaconda channel][3],
and can be installed using the [conda][1] package manager.

[1]: http://conda.pydata.org/
[2]: http://conda.pydata.org/docs/build.html
[3]: https://anaconda.org/ilastik
[Anaconda]: https://store.continuum.io/cshop/anaconda
[ilastik]: http://ilastik.org

========
Contents
========

- [Installing ilastik for development](#installing)
- [Generating a release binary](#generating)
- [How to build these packages yourself](#howtobuild)
- [Appendix: Writing a new recipe](#writing)
- [Appendix: Compiler details](#compiler)
- [Appendix: Linux VM Details](#linuxvm)
- [Appendix: TODO/TBD](#todo)


<a name="installing"></a>
==================================
Installing ilastik for development
==================================

Here's how to install everything you need to develop ilastik.

0. Prerequisite: Install [Miniconda]
------------------------------------

[Miniconda]: http://conda.pydata.org/miniconda.html

```bash
# Install miniconda to the prefix of your choice, e.g. /my/miniconda

# LINUX:
wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
bash Miniconda-latest-Linux-x86_64.sh

# MAC:
wget https://repo.continuum.io/miniconda/Miniconda-latest-MacOSX-x86_64.sh
bash Miniconda-latest-MacOSX-x86_64.sh

# Activate conda
CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root
```

1. Create a fresh environment, and install ilastik
--------------------------------------------------

To install everything but tracking, this command is enough:

```bash
conda create -n ilastik-devel -c ilastik ilastik-everything-but-tracking
``` 

If you have CPLEX on your machine, you can install the full ilastik development 
setup, including tracking.  First, install `cplex-shared` to any (temporary) environment:

```
CPLEX_ROOT_DIR=/path/to/cplex conda create -n throw-away -c ilastik cplex-shared
conda remove --all -n throw-away
```

That command generated the necessary cplex `.so` files in-place (if necessary), 
and also recorded the value of `CPLEX_ROOT_DIR` to your root directory.

Now you can install everything, including tracking:

```bash
conda create -n ilastik-devel -c ilastik ilastik-everything
```

2. Run ilastik
--------------

```bash
${CONDA_ROOT}/envs/ilastik-devel/run_ilastik.sh --debug
```

3. (Optional) Clone ilastik git repo
------------------------------------

So far, our environment contains the ilastik source, but not the git repos.
If you need to edit the ilastik python code,
replace the `ilastik-meta` directory with the full git repo.

```bash
CONDA_ROOT=`conda info --root`
DEV_PREFIX=${CONDA_ROOT}/envs/ilastik-devel
conda remove -n ilastik-devel ilastik-meta

# Re-install ilastik-meta.pth
cat > ${DEV_PREFIX}/lib/python2.7/site-packages/ilastik-meta.pth << EOF
../../../ilastik-meta/lazyflow
../../../ilastik-meta/volumina
../../../ilastik-meta/ilastik
EOF

# Option 1: clone a fresh copy of ilastik-meta
git clone http://github.com/ilastik/ilastik-meta ${DEV_PREFIX}/ilastik-meta
cd ${DEV_PREFIX}/ilastik-meta
git submodule update --init --recursive
git submodule foreach "git checkout master"

# Option 2: Symlink to a pre-existing working copy, if you have one.
cd ${DEV_PREFIX} && ln -s /path/to/ilastik-meta
```

<a name="generating"></a>
===========================
Generating a release binary
===========================

1. (Prerequisite) Update the version number.

  1. Edit `ilastik.__version_info__` (in `ilastik/__init__.py`) and commit your change.
  2. Commit to `ilastik-meta` and add a matching git tag:

          cd ${DEV_PREFIX}/ilastik-meta
          git commit -m "Alpha Release 1.2.3a4" ilastik lazyflow volumina
          git push origin master
          git tag -m "Alpha Release" -a 1.2.3a4
          git push --tags origin

  3. Update the `git_tag` in `ilastik-build-conda/ilastik-meta/meta.yaml` and commit.

2. Double-check your conda configuration (`.condarc`).  You should allow access to the `ilastik`
   channel and `defaults`, but nothing else:

        $ cat ~/.condarc
        channels:
        - ilastik
        - defaults

3. Build `ilastik-meta` and `ilastik-everything` packages, and upload to the `ilastik` anaconda channel.

        conda build ilastik-meta ilastik-everything
        anaconda upload -u ilastik ${CONDA_ROOT}/conda-bld/linux-64/ilastik-meta*.tar.bz2
        anaconda upload -u ilastik ${CONDA_ROOT}/conda-bld/linux-64/ilastik-everything*.tar.bz2

4. (Optional) Install to a local environment and test

        conda create -n test-env -c ilastik ilastik-everything=1.2.3a4
        cd ${CONDA_ROOT}/envs/test-env
        ./run_ilastik.sh

5. Create tarball/app

   **Linux:**

           
            $ grep Usage ./create-tarball.sh
            ## Usage: create-tarball.sh [--git-latest] [--no-tracking] [... extra install-args, e.g. --use-local or -c ilastik ...]
            
            $ ./create-tarball.sh -c ilastik

   **Mac:**
       
            $ grep Usage ./osx-packages/create-osx-app.sh
            ## Usage: create-osx-app.sh [--zip] [--git-latest] [--no-tracking] [... extra install-args, e.g. --use-local or -c ilastik ...]
            
            $ ./osx-packages/create-osx-app.sh --zip -c ilastik

  If any options are used, they must be passed in this order:

    - `--zip`: (Mac only) After creating the `.app` bundle, compress it into a `.zip` file.  
    - `--git-latest`: Use the latest `master` branch of `ilastik`, `lazyflow`, and `volumina` instead of the most recent tag. (Don't use for official releases.)
    - `--no-tracking`: Omit tracking-specific dependencies
    - `--use-local`: Tells conda to use your custom builds of each package, if available.
    - `-c ilastik`: Tells conda to use packages from the ilastik channel (in case it's missing from `~/.condarc`).

<a name="howtobuild"></a>
====================================
How to build these packages yourself
====================================

All of the recipes in this repo should already be uploaded to the [ilastik][3] anaconda channel.
The linux packages were built on CentOS 5.11, so they should be compatible with most modern distros.
The Mac packages were built with `MACOSX_DEPLOYMENT_TARGET=10.7`, so they should theoretically support OSX 10.7+.

But if, for some reason, you need to build your own binary packages from these recipes, it should be easy to do so:

```bash
# Prerequisite: Install conda-build and jinja2
source activate root
conda install conda-build jinja2

# Clone the ilastik build recipes
git clone http://github.com/ilastik/ilastik-build-conda
cd ilastik-build-conda

# Build a recipe, e.g:
conda build vigra

# Now install your newly built package, directly from your local build directory:
conda install --use-local -n ilastik-devel vigra
```

Now run ilastik from with your ilastik meta-repo:

```bash
cd /path/to/ilastik-meta

# Run ilastik
PYTHONPATH="ilastik:lazyflow:volumina" python ilastik/ilastik.py
```

<a name="writing"></a>
==============================
Appendix: Writing a new recipe
==============================

The [conda documentation][2] explains in detail how to create a new package, but here's a quick summary:

[2]: http://conda.pydata.org/docs/build.html

0. Prerequisite: Install `conda-build`
--------------------------------------

```bash
source activate root
conda install conda-build jinja2
```

1. Create recipe files
----------------------

Add a directory to this repo:

```bash
cd ilastik-build-conda
mkdir somepackage
cd somepackage
```

A complete recipe has at least 3 files:

 - `meta.yaml`
 - `build.sh` (used for both Mac and Linux)
 - `bld.bat` (used for Windows)

...additional files (such as patches) may be needed for some recipes.

Write **meta.yaml**:

```yaml
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
# configure, make, and install
configure --prefix=$PREFIX --with-zlib=$PREFIX
make -j${CPU_COUNT}
make install
```

Write **bld.bat**:

```bat
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

2. Build the package
--------------------

```bash
# Switch back to the `ilastik-build-conda` directory
$ cd ../

# Build the package
$ conda build somepackage
```

3. Upload the package to your [anaconda] channel.
------------------------------------------------

```bash
conda install anaconda-client

# Upload to your personal channel:
anaconda upload /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2

# Or to ilastik's anaconda channel:
anaconda upload -u ilastik /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2
```

[anaconda]: http://anaconda.org

<a name="compiler"></a>
==========================
Appendix: Compiler details
==========================

**When writing your own recipes, use gcc provided by conda.**

Instead of using your system compiler, all of our C++ packages use the `gcc` package provided by conda
itself (or our own variation of it).  On Mac, using gcc is critical because some packages require a
modern (C++11) version of `libstdc++`.  On Linux, using conda's gcc-4.8 is an easy way to get C++11
support on old OSes, such as our CentOS 5.11 build VM.

To use the gcc package, add these requirements to your `meta.yaml` file:

```yaml
requirements:
  build:
    - gcc 4.8.5 # [linux]
    - gcc 4.8.5 # [osx]
  run:
    - libgcc
```

And in `build.sh`, make sure you use the right `gcc` executable.  For example:

```bash
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

<a name="linuxvm"></a>
==========================
Appendix: Linux VM Details
==========================

The Anaconda distribution is built on a CentOS 5.11 VM.
To build the ilastik stack on that OS, you'll need to install the following:
 
- `cmake`, `git`, `conda`, `gcc`
- VTK dependencies: 
  * OpenGL: `yum install mesa-libGL-devel`
  * X11: `yum groupinstall "X Software Development"`
- CPLEX (optional)
- Recommended: VirtualBox Guest additions
  1. Register external package repository "rpmforge"
    * http://wiki.centos.org/AdditionalResources/Repositories/RPMForge#head-5aabf02717d5b6b12d47edbc5811404998926a1b
  2. Install package `dkms`
  3. In VBox menu, select `Devices` > `Insert Guest Additions CD`
  4. From disk image, install Guest Additions from command line


<a name="todo"></a>
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

