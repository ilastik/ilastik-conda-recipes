#!/bin/bash

set -e

ImageJ --ij2 --headless --console --run test_ilastik.groovy 'ilastik_project="2dcellsdemo.ilp",input_image="2d_cells_apoptotic_1channel.png",output_h5="2d_cells_apoptotic_1channel_Probabilities.h5"'
echo PASS
