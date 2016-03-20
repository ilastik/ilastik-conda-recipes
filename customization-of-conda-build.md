conda-build was originally designed under the assumption that recipes, and in particular `meta.yaml`, are more or less static -- the only occasions requiring major changes would be upgrades to new versions. We now know that this assumption is wrong. It is often necessary to create many different variants of the same package version, and this should be supported by comprehensive recipe customization options. Many ideas are currently under discussion in the conda community, but these discussions are scattered across dozens of places, very hard to keep track of and even contradictory at times. This document attempts to collect and summarize the ongoing discussions in order to help arriving at consistent decisions. IMHO, these decisions are crucial to give recipe designers well-documented customization guidelines and to implement and release required changes to conda-build *before* conda-forge gets populated.

A major design decision has already been made: conda-build supports jinja2 templating in `meta.yaml`. Since jinja2 is well designed and extremely powerful, it suggests itself as the primary means for recipe customization. In my opinion, alternative solutions should only be considered when jinja2 is clearly unsuitable.

## Source of Customization Information

Before discussing concrete customizations, I'd like to review the general question of how customization information can be passed to conda-build. Various possibilities have been tried:

**environement variables** and **command line options**: For example, the command line
```
CONDA_PY=33 conda build --numpy=1.9 foo
```
defines the Python and numpy versions to be used in the build. These variables are easily imported into `meta.yaml` by copying them to the global jinja namespace with a command like
```
jinja_env.globals.update({'PY_VER': os.environ['CONDA_PY'], 'NPY_VER': args.numpy[0] })
```
They can now be accessed in `meta.yaml` as `{{ PY_VER }}` and `{{ NPY_VER }}` respectively.

**special syntax**: It has been proposed to write
```
requirements:
  build:
    - python >=3.3
  run:
    - python x.x
```
in `meta.yaml` in order to specialize the run requirements to the Python version that was actually present during the build. However, this approach needlessly complicates parsing of `meta.yaml`. When metadata from `<ENV>/conda-meta/*.json` are imported as described below, the same can be achieved with existing jinja syntax:
```
requirements:
  build:
    - python >=3.3
  run:
    - python {{ packages['python']['version'] }}
```

**jinja configuration files**: While parsing `meta.yaml`, jinja can read variables from external files via the `import` command
```
{% import <PATH_TO_JINJA_FILE> as config %}
```
where `<PATH_TO_JINJA_FILE>` may be a string literal, variable, or query like `environ['CONDA_BUILD_CONFIG']` for an environment variable holding the file name. (For simplicity, I skip certain jinja initializations that may be necessary to make this work.) Variables defined in the jinja file are now available as attributes of the `config` variable.

Additional possibilities I have not yet seen in practice include:

**json or yaml configuration files**: They are similar to the jinja config files described above, but are passed to conda-build via the command line
```
conda build --config=/path/to/config.json  foo
```
and imported into the jinja namespace by:
```
jinja_env.globals.update({'config': json.load(json_file) })
```
(analogously for yaml files). A similar mechanism can be used to import the complete meta-information from `<ENV>/conda-meta/*.json`:
```
packages = {}
for filename in glob.glob(os.path.join(conda_meta, '*.json')):
    with open(filename) as file:
        data = json.load(file)
    packages[data['name']] = data
jinja_env.globals.update({'packages': packages })
```
For example, the jinja expression `{{ packages['python']['version'] }}` now returns the Python version in the current environment. (Since versions are probably the most frequently accessed field, one could additionally support the syntax `{{ version['python'] }}`.)

**bootstrap environments**: Here, the user creates a conda environment holding precisely the desired dependency versions/variants and tells conda-build to replicate this setup in the `_build` environment with commands like
```
conda create -n bootstrap python=3.3 numpy=1.10
conda build --bootstrap=bootstrap  foo
```
or equivalently
```
conda create -n bootstrap python=3.3 numpy=1.10
activate bootstrap
conda build --bootstrap  foo   # bootstrap from the active environment
```
This gives users full control over the `_build` environment without requiring a complicated new configuration mechanism. (Dependencies not present in the bootstrap environment are added to the `_build` environment by the usual rules.)

**public database at anaconda.org**: This idea is a bit of science fiction. Whenever a continuous integration server successfully completes a test with a particular combination of package variants, it announces this fact to a central database. Over time, the database will collect a large body of precise compatibility information that can be accessed by conda's version resolution algorithm and conda-build.

Now let's turn to actual configuration options.

## Choice of compiler

Traditionally, the Python community pins every Python version to a particular compiler. However, adopting this approach in conda-forge would be a very bad idea: Programmers are usually under enormous pressure with regard to choice of compiler, and it shouldn't be the package manager that finally makes the constraints unsatisfiable. Compiler information can be stored in a file `visual-studio-11.yaml`
```
{% set name='visual-studio' %}
{% set version='11.0' %}
{% set feature='vc11' %}
{% set build_requirement='visual-studio-build 11.0  # [win]' %}
{% set run_requirement=  'visual-studio 11.0  # [win]' %}
```
and used in `meta.yaml` like this
```
{% import environ['CONDA_COMPILER_CONFIG'] as compiler %}

build:
  features:
    - {{compiler.feature}}
  msvc_compiler: {{compiler.version}}  # [win]

requirements:
  build:
    - {{compiler.build_requirement}}
  run:
    - {{compiler.run_requirement}}
```
where we assume that the environment variable `CONDA_COMPILER_CONFIG` holds the path to `visual-studio-11.yaml`. Alternatively, the configuration information can be provided in a json file whose name is passed to conda-build on the command line, or by a file that is placed at a standard location in a bootstrap environment by means of an installation command like `conda install visual-studio=11.0`.

## Customization of Dependency Versions and Features

It is often necessary to build a package against a specific set of dependency versions, possibly tracking a specific selection of features. The easiest way to achieve this is a bootstrap environment containing the desired dependencies, as described above. Alternatively, one could control build requirements via jinja variables that are imported from a configuration file. In principle, environment variables and command line switches would work as well, but they should probably be restricted to basic cases like Python and numpy (if used at all) because they don't scale to situations where many dependencies must be configured.

When features are tracked in the `_build` environment, it is also necessary to insert corresponding `features:` declarations into the present package's `meta.yaml`. An easy solution is to have conda-build create a jinja variable `track_features` that holds a list of all features that were found in the `track_features` fields of `<ENV>/conda-meta/*.json`. The list can be transfered to `meta.yaml` by means of a jinja for-loop:
```
build:
  features:
{% for feature in track_features %}
    - {{ feature }}
{% endfor %}
```
However, this ignores the features' meaning and thus doesn't allow to drop feature declarations that are irrelevant for the present package. It might therefore be preferrable to group features into categories that cover a particular installation property. At present, there seem to be four reasonable categories: compiler, Python version, BLAS variant, and SIMD acceleration (see below for the latter). Assuming that conda-build knows about the existing categories, it could analyse the `track_features` fields in `<ENV>/conda-meta/*.json` to define a jinja variable `features` that maps categories to active feature declarations (or to the empty string if the category is not tracked in the current `_build` environment). Then, `meta.yaml` might read like this:
```
build:
  features:
    - {{ features['compiler'] }}
    - {{ features['python'] }}
    - {{ features['blas'] }}
```
(for this to work, conda-build must be able to ignore empty fields in a `features` declaration.) To simplify grouping into categories, it might make sense to change the feature declaration syntax from a list into a mapping:
```
build:
  features:
    compiler: {{ features['compiler'] }}
    python:   {{ features['python'] }}
    blas:     {{ features['blas'] }}
```
If desired, conda can probably be extended to understand both syntax variants simultaneously, so that existing recipes won't break.

SIMD acceleration (such as SSE and AVX) can significantly speed up low-level libraries like openblas and fftw. Configuring for SIMD is a special case, because one can only determine at installation time if the present CPU supports it. Ideally, libraries would include code with and without acceleration in the same binary and branch to the appropriate implementation automatically at execution time. Since not all libraries are implemented this way, it would be useful to provide metapackages like `avx` that fail to install if their *pre-link* script signals that the desired SIMD implementation is unavailable. Otherwise, they define `track_features: - avx`, so that conda will prefer package variants with AVX support, and conda-build will enable compilation with acceleration. However, another difficulty arises because SIMD implementations are backwards compatible: a CPU supporting AVX2 also supports AVX. Thus, when `track_features: - avx2` is active, but a package only provides `features: - avx`, this variant should still be preferred over a variant without any acceleration. Unfortunately, this capability requires a significant enhancement of conda's feature mechanism.

## Specialization of the Run Requirements at Build Time

Suppose package foo depends on package bar and is compatible with all versions above 1.1. Then, `foo/meta.yaml` would read
```
requirements:
  build:
    - bar  >=1.1
  run:
    - bar  >=1.1
```
conda-build copies the run requirements verbatim to foo's `index.json`, but this is a problem: when bar 2.2.1 was installed in the `_build` environment, the resulting foo binary is probably incompatible with bar 1.x. Instead, the run requirement should be updated into something like `- bar  2.2*,>=2.2.1`. It has been proposed to implement this with the special syntax `- bar  x.x`, but a jinja-based solution is probably much more elegant and general. Recall that conda-build can easily extract version information from `<ENV>/conda-meta/*.json` and make it available to `meta.yaml` in a jinja expression like `{{ packages['python']['version'] }}`. To turn the version number into a compatibility constraint, one can register a jinja filter in conda-build:
```
def find_compatible(version):
    v = version.replace('-', '.').split('.')
    if len(v) > 1:
        return v[0]+'.'+v[1]+'*,>='+version
    else:
        return version
jinja_env.filters['compatible'] = find_compatible
```
that can be used in the requirements section like
```
requirements:
  build:
    - bar  >=1.1
  run:
    - bar  {{ packages['bar']['version']|compatible }}
```
More sophisticated filters that take parameters, consider optional hints in bar's `index.json` or consult the compatibility database at anaconda.org can be implemented in the same way.
