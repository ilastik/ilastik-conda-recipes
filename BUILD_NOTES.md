# Build notes for ilastik-1.2.1

## New Dependencies

- `mamutexport 0.2.1`
- `requests 2.13.0`
  - Technically, `requests` is still an *optional* dependency in lazyflow (for `TiledVolume` data, such as CATMAID tiles),
    but it's a trivial dependency to carry, so I added it to `ilastik-versions`


## Updated verisons

- `freetype 2.5.5`
- `h5py 2.7`
- `hdf5 1.8.17`
- `jpeg 9b`
- `libpng 1.6.27`
- `numpy 1.12.1`
- `pandas 0.19.2`
- `pillow: 4.1.0`
- `scikit-image 0.12.3`
- `scikit-learn 0.18.1`
- `scipy 0.19.0`
- `xz: 5.2.2`

Non-windows dependencies (used by tracking and/or multicut):

- `dpct 1.2`
- `hytra 1.1.3`
- `multi-hypotheses-tracking-with-cplex 1.1.3.post1` (now requires hdf5)
- `multi-hypotheses-tracking-with-gurobi 1.1.3.post1` (now requires hdf5, also uses gurobi 7)
- `nifty 0.3b1.post119`
- `nifty-with-gurobi 0.3b1.post119`
- Gurobi 7


## New recipe

- `matplotlib`
  - The latest versions of the standard matplotlib package don't support Qt4.
  - We now use a modified version of the conda-forge matplotlib recipe (version 2.0.0)


## New builds

### Important:

- `vigra 1.11.0.post222`

### Incidental:

We didn't necessarily require an updated version of these packages,
but we had to at least rebuild them due to updates to their dependencies:

- `ilastikrag 0.1.post12`
- `iiboost 0.2.post5` (due to new `libpng`)
- `opengm 2.3.7.post29` (due to new `hdf5`)
- `qimage2ndarray 1.6` (now pure-python!)
- `qt` (due to new `libpng`)


## Optional updates

- `ilastiktools 0.2.post1` (not necessary; just adds py3 support)


## Other Notes:

- `iiboost`
  - Recipe no longer lives in `ilastik-build-conda`.
    Instead, it lives in the `iiboost` repo itself.
    Furthermore, for now, we use a custom fork: https://github.com/stuarteberg/iiboost

- `hdf5`
  - Prior to 1.8.17, anaconda's `hdf5` build did not enable thread-safety for the C++ API.
    (While not strictly necessary for ilastik, it's nice to have for ilastik devs who also write C++ code for their other projects.)
    Note: This change forced upstream recipe changes in `vigra` and `itk-seg-conv-only`.


- `opengm`
  - I was unable to reproduce my previous opengm build.  After some trial-and-error, I settled on the following changes to the recipe:
    - I use https://github.com/ilastik/opengm, branch `ilastik-build`.
    - Since opengm only requires vigra headers, I added a new package (`vigra-headers-only`) to simplify the build, and make it easier to maintain a pinned and reproducible version of that package.

- `libpng`
  - Note that many packages in our stack pin their libpng dependency precisely.
    Upgrading `libpng` forced upgrades/rebuilds throughout the stack.
    The following recipes of ours also needed to be updated: `iiboost`, `vigra`, `matplotlib`, `itk-seg-conv-only`

- `qt`
  - Recipe now works on conda-build 2.x.  Also, added a patch to work on macOS Sierra.

- `vtk`
  - On mac, fixed post-build macho-binary linking script to work properly with conda-build 2.x

- `scipy`
  - On Mac, we now build our own scipy package to work around [an issue with the default package](https://github.com/ContinuumIO/anaconda-issues/issues/899).

- On Linux and Mac, we no longer build `pgmlink`, `armadillo`, `dlib`, `mlpack`, `opengm-structured-learning-headers`.
  (They aren't needed in the new `hytra`-based tracking pipeline.)

- On Mac, explicitly set `MACOSX_DEPLOYMENT_TARGET=10.9` in some recipes.

- Various recipes were upgraded for compatibility with `conda-build` 2.x.
  Notably, the test step in some cases needed modification.
  (Fortunately, the error message from `conda-build` in such cases is quite clear.)


### Reminders:

- We still use a deliberately old `tifffile` (0.4.post2).  See [ilastik#1338](https://github.com/ilastik/ilastik/issues/1338) for details.
- We haven't upgraded to CPLEX 12.7 yet because that requires switching to `clang` on the Mac.  ilastik-1.2.1 was built against CPLEX 12.5.1, but that should be compatible with 12.6, too.

### Recipes to ignore:

(These new recipes are for FlyEM-only dependencies.)

- `jansson`
- `google-api-cpp-client`
- `dvid`
