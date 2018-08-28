cd "${SRC_DIR}"

# The test just prints pass/fail messages.
python test/test.py | (! grep -i fail)
