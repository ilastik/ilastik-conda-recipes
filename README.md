ilastik-build-conda
===================

[ilastik] depends on **110+ packages**.  Most of those packages are already provided for us by the [Anaconda] Python distribution.
For some of the 20+ the packages that *aren't* provided by Anaconda, we use the recipes in this repo.
See also our [ilastik-publish-packages repo](https://github.com/ilastik/ilastik-publish-packages), especially the `ilastik-recipe-specs.yaml` for a complete list of packages we build ourselves.

These recipes are built using the [conda-build][2] tool.
The resulting binaries are uploaded to the [ilastik anaconda channel][3],
and can be installed using the [conda][1] package manager.

[1]: http://conda.pydata.org/
[2]: http://conda.pydata.org/docs/build.html
[3]: https://anaconda.org/ilastik
[Anaconda]: https://store.continuum.io/cshop/anaconda
[ilastik]: http://ilastik.org

Contents
--------

- [Installing ilastik for development](#installing)
- [Generating a release binary](#generating)
- [How to build these packages yourself](#howtobuild)
- [Appendix: Writing a new recipe](#writing)
- [Appendix: Compiler details](#compiler)
- [Appendix: Linux VM Details](#linuxvm)
- [Appendix: TODO/TBD](#todo)


<a name="installing"></a>
Installing ilastik for development
==================================

**Preamble:** Depending on what you are trying to do, you may not need to follow any of these steps.  The ilastik binary is shipped with a complete conda environment, `.py` files, etc.  For many purposes, simply downloading the binary and editing the (python) source code by hand may suffice.  However, these instructions can give you a more complete developer setup, suitable e.g. for C++ development. 

Here's how to install everything you need to develop ilastik.

### 0. Prerequisite: Install [Miniconda]

[Miniconda]: http://conda.pydata.org/miniconda.html

```bash
# Install miniconda to the prefix of your choice, e.g. /my/miniconda

# LINUX:
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# MAC:
wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh

# Activate conda
CONDA_ROOT=`conda info --root`
source ${CONDA_ROOT}/bin/activate root
```


**NOTE:**

When using `conda`, make sure you are not using any of python's site-specific or user-specific customization features.  In particular, make sure the following environment variables are **not** defined in your terminal:

- `PYTHONPATH`
- `PYTHONUSERSITE`
- `PYTHONUSERBASE`

Also, make sure there are no python-related directories in `~/.local/`.


### 1. Create a fresh environment, and install ilastik

Some ilastik workflows require commercial solvers, for which one must purchase or obtain an academic license.
If you don't have CPLEX and Gurobi on your machine, you can install everything else with this command:


```bash
conda create -n ilastik-devel ilastik-dependencies-no-solvers -c ilastik-forge -c conda-forge
```

If you have both CPLEX and Gurobi on your machine, you can install the full ilastik development 
setup, including full support for tracking and multicut.

First, define these environment variables:

```bash
export CPLEX_ROOT_DIR=/path/to/ibm/ILOG/CPLEX_Studio1251
export GUROBI_ROOT_DIR=/path/to/gurobi650/linux64
```

Now you can install the `ilastik-dependencies` package:

```bash
conda create -n ilastik-devel ilastik-dependencies -c ilastik-forge -c conda-forge
```

**Note:** To be really sure that you're getting the right version of `ilastik-dependencies`, you can require a specific version and build of the package with `PKGNAME=VERSION=BUILD` syntax:

```bash
conda create -n ilastik-devel ilastik-dependencies=1.2.0=6 -c ilastik-forge -c conda-forge
```


If you only have one of CPLEX or Gurobi, and you're seeking to develop for a workflow that requires it, you must install some dependencies of that workflow individually.  For example, to install tracking with CPLEX, but not Gurobi:

```bash
conda create  -n ilastik-devel ilastik-dependencies-no-solvers -c ilastik-forge -c conda-forge
conda install -n ilastik-devel multi-hypotheses-tracking-with-cplex -c ilastik-forge -c conda-forge
```

For example, to install multicut with Gurobi support:

```bash
conda create  -n ilastik-devel ilastik-dependencies-no-solvers -c ilastik-forge -c conda-forge
conda install -n ilastik-devel nifty-with-gurobi -c ilastik-forge -c conda-forge
```

### 2. Run ilastik

```bash
${CONDA_ROOT}/envs/ilastik-devel/run_ilastik.sh --debug
```

### 3. (Optional) Clone ilastik git repo

So far, our environment contains the ilastik source, but not the git repos.
If you need to edit the ilastik python code,
replace the `ilastik-meta` directory with the full git repo.

**Note:** This will remove both `ilastik-meta` and `ilastik-dependencies`, but all of the other dependencies in your environment will remain.

```bash
CONDA_ROOT=`conda info --root`
DEV_PREFIX=${CONDA_ROOT}/envs/ilastik-devel
conda remove -n ilastik-devel ilastik-meta

# Re-install ilastik-meta.pth
cat > ${DEV_PREFIX}/lib/python3.6/site-packages/ilastik-meta.pth << EOF
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

2. Double-check your conda configuration (`.condarc`).  You should allow access to the `ilastik-forge`, `conda-forge`,
   and `defaults` channels, but nothing else:

        $ cat ~/.condarc
        channels:
        - ilastik-forge
        - conda-forge
        - defaults

3. Build `ilastik-meta` and `ilastik-dependencies` packages, and upload to the `ilastik-forge` anaconda channel.

        WITH_SOLVERS=1 conda build ilastik-meta ilastik-dependencies
        anaconda upload -u ilastik-forge ${CONDA_ROOT}/conda-bld/linux-64/ilastik-meta*.tar.bz2
        anaconda upload -u ilastik-forge ${CONDA_ROOT}/conda-bld/linux-64/ilastik-dependencies*.tar.bz2

**Troubleshooting Tip:** If the `ilastik-meta` tag has been relocated since you last built the `ilastik-meta` package, you should probably clear conda's git cache for that repo, to ensure you have the new tags: `rm -rf $(conda info --root)/conda-bld/git_cache/github.com/ilastik/ilastik-meta`

4. (Optional) Install to a local environment and test

        conda create -n test-env ilastik-dependencies=1.2.3a4 -c ilastik-forge -c conda-forge
        cd ${CONDA_ROOT}/envs/test-env
        ./run_ilastik.sh

5. Create tarball/app

   **Linux:**

           
            $ grep Usage ./create-tarball.sh
            ## Usage: create-tarball.sh [--skip-tar] [--git-latest] [--no-solvers] [--include-tests] [... extra install-args, e.g. --use-local or -c ilastik-forge -c conda-forge ...]
            
            $ ./create-tarball.sh -c ilastik-forge -c conda-forge

   **Mac:**
       
            $ grep Usage ./osx-packages/create-osx-app.sh
            ## Usage: create-osx-app.sh [--compress] [--git-latest] [--no-solvers] [--include-tests] [... extra install-args, e.g. --use-local or -c ilastik-forge -c conda-forge or --copy ...]
            
            $ ./osx-packages/create-osx-app.sh --compress -c ilastik-forge -c conda-forge

   If any options are used in the **Linux** or **Mac** binary creation scripts above, they must be passed in this order:

    - `--skip-tar`: (Linux only) Create the `ilastik-release` environment, but don't compress it into a .tar.bz2 file.
    - `--compress`: (Mac only) After creating the `.app` bundle, compress it into a `.tar.bz2` file.  
    - `--git-latest`: Use the latest `master` branch of `ilastik`, `lazyflow`, and `volumina` instead of the most recent tag. (Don't use for official releases.)
    - `--no-solvers`: Skip commercial solver dependencies (will used `ilastik-dependencies-no-solvers` instead of `ilastik-dependencies`)
    - `--use-local`: Tells conda to use your custom builds of each package, if available.
    - `-c ilastik-forge`: Tells conda to use packages from the ilastik-forge channel (in case it's missing from `~/.condarc`).


   **Windows:**
            
            ## create new environment for packaging and activate it
            $ conda create -n ilastik-release ilastik-dependencies -c ilastik-forge -c conda-forge
            $ activate ilastik-release

            ## install exe and preconfigured installer generation script
            $ conda install ilastik-exe ilastik-package -c ilastik-forge -c conda-forge
            
            ## build the installer using Inno setup

            ## ACTION REQUIRED: open the file ${YOUR_CONDA_ENV_PATH}/package/ilastik.iss in Inno Setup 
            ## and build the installer.

            ## delete environment
            $ activate root
            $ conda env remove -n ilastik-release

<a name="howtobuild"></a>
How to build these packages yourself
====================================

**Note**: see https://github.com/ilastik/ilastik-publish-packages for an automated way of building all packages required by ilastik

**Warning**: the description below is outdated

All of the recipes in this repo should already be uploaded to the [ilastik][3] anaconda channel.
The linux packages were built on CentOS 5.11, so they should be compatible with most modern distros.
The Mac packages were built with `MACOSX_DEPLOYMENT_TARGET=10.7`, so they should theoretically support OSX 10.7+.

But if, for some reason, you need to build your own binary packages from these recipes, it should be easy to do so:

```bash
# Prerequisite: Install conda-build
source activate root
conda install conda-build

# Clone the ilastik build recipes
git clone http://github.com/ilastik/ilastik-build-conda
cd ilastik-build-conda

# Build a recipe, e.g:
conda build --numpy=1.11 vigra

# Now install your newly built package, directly from your local build directory:
conda install --use-local -n ilastik-devel vigra
```

Now run ilastik from with your `ilastik-meta` repo:

```bash
cd /path/to/ilastik-meta

# Run ilastik
PYTHONPATH="ilastik:lazyflow:volumina" python ilastik/ilastik.py
```

As mentioned above, some packages require CPLEX and Gurobi.  To build those packages, you must define some environment variables first:

```bash
# Configure environment for building with solvers active
export WITH_SOLVERS=1
export CPLEX_ROOT_DIR=/path/to/ibm/ILOG/CPLEX_Studio1251
export GUROBI_ROOT_DIR=/path/to/gurobi650/linux64

# Build some recipes that depend on solvers
conda build ilastik-dependencies
```

<a name="writing"></a>
Appendix: Writing a new recipe
==============================

The [conda documentation][2] explains in detail how to create a new package, but here's a quick summary:

[2]: http://conda.pydata.org/docs/build.html

### 0. Prerequisite: Install `conda-build`

```bash
source activate root
conda install conda-build
```

### 1. Create recipe files

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

furthermore, since conda-build 3, it is possible to supply a config file to specify dependency versions for build and run configurations:

 - `conda_build_config.yaml`

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

build:
  number: 0
  string: py{{CONDA_PY}}np{{CONDA_NPY}}_{{PKG_BUILDNUM}}_h{{PKG_HASH}}_g{{GIT_FULL_HASH[:7]}}


requirements:
  build:
    - zlib
    - python {{ python }}  # jinja2 variable defined in conda_build_config.yaml
  run:
    - zlib
    - python

about:
  home: http://www.somepackage.com
  license: WYSIWYG v3
```

for most our package we use a non-standard build string `py{{CONDA_PY}}np{{CONDA_NPY}}_{{PKG_BUILDNUM}}_h{{PKG_HASH}}_g{{GIT_FULL_HASH[:7]}}` to give the resulting package file name just a little more info that might help debugging issues.

Write **conda_build_config.yaml**:

Contents of `conda_build_config.yaml` are used to calculate the `PKG_HASH`.

```yaml
$ cat > conda_build_config.yaml

# defining jinja variables that can be used in meta.yaml:
# these variables don't have to be the same as the package name,
# but we like to keep it that way
# see usage of this variable in meta.yaml in the build requirements
python:
  - 3.6

# the pin_run_as_build is used to configure how dependency versions at run
# time should relate to versions specified at build time
# variables here _have_ to be the package names!
pin_run_as_build:
  # in this case, python will be required to be 3.6.x, or in other words
  # >=3.6.0,<3.7
  python: x.x
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

### 2. Build the package

```bash
# Switch back to the `ilastik-build-conda` directory
$ cd ../

# Build the package
$ conda build somepackage
```

### 3. Upload the package to your [anaconda] channel.

```bash
conda install anaconda-client

# Upload to your personal channel:
anaconda upload /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2

# Or to ilastik's anaconda channel:
anaconda upload -u ilastik /my/miniconda/conda-bld/osx-64/somepackage-1.2.3-0.tar.bz2
```

[anaconda]: http://anaconda.org

<a name="compiler"></a>
Appendix: Compiler details
==========================

**When writing your own recipes, use gcc provided by conda.**

Instead of using your system compiler, all of our C++ packages use the `gcc` package provided by conda
itself (or our own variation of it).  On Mac, we use LLVM's clang instead to get C++11 features.  On Linux, using conda's gcc-4.8 is an easy way to get C++11 support on old OSes, such as our CentOS 5.11 build VM.

To use the gcc package, add these requirements to your `meta.yaml` file:

```yaml
requirements:
  build:
    - gcc 4.8.5 # [linux]
  run:
    - libgcc # [linux]
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

 - [x] So far, this repo includes no package build scripts for Windows.

 - [ ] Generate a final binary package from the built dependencies

 - [ ] Should we attempt to track different versions of the MSVC++ std library via a conda "feature"?

