#!/bin/bash
set -e

export MALLOC_CHECK_=0

cd ${PREFIX}/ilastik-meta/volumina/tests
nosetests .

cd ${PREFIX}/ilastik-meta/lazyflow/tests
nosetests --ignore-files testInterpolatedFeatures.py .

cd ${PREFIX}/ilastik-meta/ilastik/tests
./run_each_unit_test.sh
