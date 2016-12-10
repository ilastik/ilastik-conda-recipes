# See discussion of "Python install line standard", here:
# https://github.com/conda-forge/staged-recipes/issues/528
#
# Another discussion here:
# https://groups.google.com/a/continuum.io/d/msg/conda/yqQiOnLD4iM/QAWYHU-6BwAJ
#
${PYTHON} setup.py build_ext
${PYTHON} setup.py install --single-version-externally-managed --root=/
