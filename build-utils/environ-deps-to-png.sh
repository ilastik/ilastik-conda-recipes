#/bin/bash

##
## Visualize the dependency graph of a conda environment as a PNG image using GraphViz.
## 
## Note: To use this script, you need:
##       - GraphViz, with 'dot' and 'neato' on your PATH
##       - pydot available in the currently active conda environment
##
## Note: At the time of this writing, the 'graphviz' package is broken on OS X,
##       but an improved recipe is *almost* ready for acceptance in conda-forge.
##       In the meantime, you'll need to install graphviz from my channel:
##
##         $ conda create -n foo -c stuarteberg graphviz
##         $ conda install -n foo pydot
##         $ source activate foo
##         $ ./environ-deps-to-png.sh some-env
##         $ firefox some-env-dot.png
##         $ firefox some-env-neato.png

set -e
if [[ $# < 1 ]]; then
    1>&2 echo "Usage: $0 <env-name> [env-prefix]"
    exit 1
fi

ENV_NAME=$1
DEFAULT_PREFIX="$(conda info --root)/envs/${ENV_NAME}"

ENV_PREFIX=${2-${DEFAULT_PREFIX}}

# Dependencies must be computed in the *root* conda environment,
# becuase that's the only environment that can use 'import conda'
$(conda info --root)/bin/python dependencies-to-json.py -p ${ENV_PREFIX} -o ${ENV_NAME}.json

# The dot-file is generated with the currently active conda environment,
# which must have pydot installed to it
python json-graph-to-dot.py -o ${ENV_NAME}.dot ${ENV_NAME}.json

# Call the 'dot' and 'neato' commands to give two alternative layouts of the dependencies
dot -Tpng -o ${ENV_NAME}-dot.png ${ENV_NAME}.dot
neato -Goverlap=0 -Tpng -o ${ENV_NAME}-neato.png ${ENV_NAME}.dot
