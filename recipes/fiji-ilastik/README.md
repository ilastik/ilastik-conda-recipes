# fiji-ilastik

This allows to get the plugin [ilastik4ij](https://github.com/ilastik/ilastik4ij) into Fiji.

To install (and build) it requires channels:

- ilastik-forge
- pytorch
- conda-forge
- bioconda

Once installed, there are 2 binaries in the ``${CONDA_PREFIX}/bin`` directory: `ImageJ` which simply launch Fiji (with the Ilastik4ij plugin) and `ImageJ_withIlastik` which will first set the executable path of Ilastik in Fiji and then run Fiji (with the Ilastik4ij plugin).
