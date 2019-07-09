ilastik-conda-recipes
=====================

[ilastik] depends on **110+ packages**.  Most of those packages are already provided for us by the [conda-forge] [channel][cf-channel].
For some of the 20+ the packages that *aren't* provided by Anaconda, we use the recipes in this repo.
See also our [publish-conda-stack repo][pcs],
especially the `ilastik-recipe-specs.yaml` for a complete list of packages we build ourselves.

These recipes are built using the [conda-build][2] tool.
The resulting binaries are uploaded to the [`ilastik-forge` anaconda channel][3],
and can be installed using the [conda][1] package manager.

[1]: https://conda.io
[2]: https://conda.io/projects/conda-build
[3]: https://anaconda.org/ilastik-forge
[conda-forge]: https://conda-forge.org/
[cf-channel]: https://anaconda.org/conda-forge/repo
[ilastik]: http://ilastik.org
[pcs]: https://github.com/ilastik/publish-conda-stack

Contents
--------

- [Generating a release binary](#generating)
- [How to build these packages yourself](#howtobuild)
- [Appendix: Writing a new recipe](#writing)
- [Appendix: Compiler details](#compiler)
- [Appendix: Linux Build Container](#linuxcontainer)
- [Appendix: TODO/TBD](#todo)


if you are looking for instructions on how to set-up an ilastik development environment, please check-out our [contributing guidelines](https://github.com/ilastik/ilastik/blob/master/CONTRIBUTING.md) in the ilastik main repo.

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

        WITH_SOLVERS=1 conda build recipes/ilastik-meta recipes/ilastik-dependencies
        anaconda upload -u ilastik-forge ${CONDA_BASE}/conda-bld/linux-64/ilastik-meta*.tar.bz2
        anaconda upload -u ilastik-forge ${CONDA_BASE}/conda-bld/linux-64/ilastik-dependencies*.tar.bz2

**Troubleshooting Tip:** If the `ilastik-meta` tag has been relocated since you last built the `ilastik-meta` package, you should probably clear conda's git cache for that repo, to ensure you have the new tags: `rm -rf $(conda info --base)/conda-bld/git_cache/github.com/ilastik/ilastik-meta`

4. (Optional) Install to a local environment and test

        conda create -n test-env ilastik-dependencies=1.2.3a4 -c ilastik-forge -c conda-forge
        cd ${CONDA_BASE}/envs/test-env
        ./run_ilastik.sh

5. Create tarball/app

   **Linux:**

           
            $ grep Usage ./create-tarball.sh
            ## Usage: create-tarball.sh [--skip-tar] [--git-latest] [--no-solvers] [--include-tests] [... extra install-args, e.g. --use-local or -c ilastik-forge -c conda-forge ...]
            
            $ ./create-tarball.sh -c ilastik-forge -c conda-forge

   **Mac:**
       
            $ grep Usage recipes/osx-packages/create-osx-app.sh
            ## Usage: create-osx-app.sh [--compress] [--git-latest] [--no-solvers] [--include-tests] [... extra install-args, e.g. --use-local or -c ilastik-forge -c conda-forge or --copy ...]
            
            $ recipes/osx-packages/create-osx-app.sh --compress -c ilastik-forge -c conda-forge

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
            $ activate base
            $ conda env remove -n ilastik-release

<a name="howtobuild"></a>
How to build these packages yourself
====================================

Unless you are editing the source code of these packages, there should be no need to build these packages yourself.
All of the recipes in this repo are already uploaded to the [`ilastik-forge`][3] anaconda channel.
The linux packages were built on CentOS-6, so they should be compatible with most modern distros.
The Mac packages were built with `MACOSX_DEPLOYMENT_TARGET=10.9`, so they should theoretically support OSX 10.9+.

Without publish-conda-stack
---------------------------

If, for some reason, you do need to build your own binary packages from these recipes, it should be easy to do so.
The recommended procedure for building these packages is to use the [`publish-conda-stack`][publish-conda-stack] tool.
But here are the steps to follow if you aren't using that tool:

[publish-conda-stack]: https://github.com/ilastik/publish-conda-stack


```bash
# Prerequisite: Install conda-build
source activate base
conda install conda-build

# Clone the ilastik build recipes
git clone http://github.com/ilastik/ilastik-conda-recipes
cd ilastik-conda-recipes

# Build a recipe, and use our global version pinnings
conda build -m ilastik-pins.yaml recipes/vigra

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
conda build recipes/ilastik-dependencies
```

With publish-conda-stack
------------------------

As mentioned above, [`publish-conda-stack`][pcs] is a convenient tool for building a set of conda recipes and uploading them to your own channel.

Basically, list your recipes in a "specs" file, along with shared configuration settings (e.g. source channels, destination channel, and your master build config file), and then use `publish-conda-stack` to download, build, and upload one or more of your recipes.

See the [`publish-conda-stack`][pcs] docs for details.  Example usage:


```bash
source activate base
conda install -c ilastik-forge -c conda-forge conda-build publish-conda-stack

cd ilastik-conda-recipes

# on Linux and Windows:
publish-conda-stack ilastik-recipe-specs.yaml

# on Mac:
MACOSX_DEPLOYMENT_TARGET=10.9 publish-conda-stack ilastik-recipe-specs.yaml
```

The `publish-conda-stack` script parses the packages from `ilastik-recipe-specs.yaml`, and for each package checks whether that version is already available on the `ilastik-forge` channel. If that is not the case, it will build the package and upload it to `ilastik-forge`. By default, the script **assumes you have both solvers** and wants to build all packages. If you do not have CPLEX or Gurobi, comment out the sections near the end that have `cplex` or `gurobi` in their name, as well as the `ilastik-dependencies` package as described below.

If you want to change which packages are built, _e.g._ to build **without solvers** edit the ilastik-recipe-specs.yaml file. There, you can comment or change the sections specific to respective packages.
It is a YAML file with the following format:


<a name="writing"></a>
Appendix: Writing a new recipe
==============================

The [conda documentation][2] explains in detail how to create a new package, but here's a quick summary:

[2]: http://conda.pydata.org/docs/build.html

### 0. Prerequisite: Install `conda-build`

```bash
source activate base
conda install conda-build
```

### 1. Create recipe files

Add a directory to this repo:

```bash
cd ilastik-conda-recipes
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
# Switch back to the `ilastik-conda-recipes` directory
$ cd ../

# Build the package
$ conda build recipes/somepackage
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

**When writing your own recipes, use gcc/clang provided by conda.**

Instead of using your system compiler, all of our C++ packages use the compiler packages provided by the Anaconda distribution.

To use the gcc package, add these requirements to your `meta.yaml` file:

```yaml
requirements:
  build:
    - cmake
    - {{ compiler("cxx") }}
  host:
    - foo
  run:
    - foo
```

And in `build.sh`, you can rely on the `${CXX}` environment variable as the compiler executable.
Do NOT hard-code your build scripts to use `gcc` or `clang`.  As long as you don't change `CC` or `CXX`,
cmake should detect the correct compiler to use.


<a name="linuxcontainer"></a>
Appendix: Linux Build Container
===============================

The `conda-forge` distribution is built using a CentOS-6 docker container, named [`linux-anvil-comp7`][linux-anvil-comp7].
If we also build our packages in that container, then they will be binary-compatible with the conda-forge packages,
and therefore compatible with most modern linux distros.

[linux-anvil-comp7]: https://github.com/conda-forge/docker-images

These commands will get you started:

```
# Launch the container.
docker run -it \
    --name my-build-container \
    -e HOST_USER_NAME=${USERNAME} \
    -e HOST_USER_ID=${UID} \
    -e HOST_GROUP_NAME="$(id -g -n ${USERNAME} || echo ${USERNAME})" \
    -e HOST_GROUP_ID=$(id -g ${USERNAME}) \
    condaforge/linux-anvil-comp7

# BTW, Those extra environment variables are used by the
# linux-anvil startup scripts to enable a convenience:
# The file permissions used by the container will be
# compatible with your host machine, too.

# Download build scripts
conda install -c ilastik-forge publish-conda-stack
git clone https://github.com/ilastik/ilastik-conda-recipes

# Build a recipe
cd ilastik-conda-recipes
publish-conda-stack ilastik-recipe-specs.yaml vigra
```


<a name="todo"></a>
Appendix: TODO/TBD
==================

- General

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

