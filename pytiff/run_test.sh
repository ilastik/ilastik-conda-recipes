# The tests require the 'hypothesis' package, and we don't have a conda package for that
pip install hypothesis

# Normally the developers build in-place and then test in-place,
# But we want to test the package as it was installed to the environment.
# Therefore, we first install the test files to site-packages to mimic
# the structure of the pytiff repo, then run the tests from there.
#
mkdir ${SP_DIR}/pytiff/test
cp ${SRC_DIR}/pytiff/test/test_tiff.py ${SP_DIR}/pytiff/test/test_tiff.py
cp -r ${SRC_DIR}/test_data ${SP_DIR}/

# Now run the test
cd ${SP_DIR}
${PREFIX}/bin/pytest ${SP_DIR}/pytiff/test/test_tiff.py
