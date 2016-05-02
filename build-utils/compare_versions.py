"""
Compare the package version listings two conda yaml files.
Two yaml formats are supported:
 - environment listings, i.e. conda env export --file=env.yml
 - meta.yaml files (in which case we use the list of 'run' dependencies.
"""
from __future__ import print_function
import yaml
from collections import namedtuple, OrderedDict
from itertools import starmap

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--ignore-build-strings", action='store_true')
    parser.add_argument("left")
    parser.add_argument("right")
    args = parser.parse_args()
    
    side_by_side_specs = get_side_by_side_specs(args.left, args.right, args.ignore_build_strings)
    print_differences( side_by_side_specs )

def get_side_by_side_specs(left_path, right_path, ignore_build_strings=False):
    """
    Return a dict of {name : [left_spec, right_spec]} for all packages 
    mentioned in either the left or right file.
    
    If a package is present in the left file and not in the right,
    then it's spec entry will be None for the left entry.
    (And same for right-vs-left.)
    """
    with open(left_path, 'r') as left_file:
        left_specs = get_specs( yaml.load(left_file), ignore_build_strings )
    
    with open(right_path, 'r') as right_file:
        right_specs = get_specs( yaml.load(right_file), ignore_build_strings )

    all_names = set( left_specs.keys() + right_specs.keys() )
    all_specs = { name : [None, None] for name in all_names }
    for name, left_spec in left_specs.items():
        all_specs[name][0] = left_spec
    
    for name, right_spec in right_specs.items():
        all_specs[name][1] = right_spec

    return all_specs
    
def print_differences(side_by_side_specs):
    """
    Print a line for each package in which the left spec differs from the right spec.
    
    differing_specs: A dict of { name: (left_spec, right_spec) }
                     where left_spec or right_spec might be None
    """
    for name, (left_spec, right_spec) in side_by_side_specs.items():
        if left_spec == right_spec:
            continue
        left_repr = right_repr = "<MISSING>"
        if left_spec:
            left_repr = '-'.join(filter(None, left_spec[1:]))
        if right_spec:
            right_repr = '-'.join(filter(None, right_spec[1:]))

        print("{}: {} != {}".format( name, left_repr, right_repr ))        

VersionSpec = namedtuple('VersionSpec', 'name version build_string')
def get_specs(yaml_data, ignore_build_strings=False):
    """
    Return a dict of { name : VersionSpec } for the packages listed in the given yaml data.
    We support two types of yaml docs:
    - meta.yaml (we look at requirements/run)
    - environment export files (we look at dependencies)
    """
    if 'requirements' in yaml_data:
        # meta.yaml format
        if 'run' not in yaml_data['requirements']:
            raise Exception("Package metadata does not contain 'run' requirements")
        specs = map(str.split, yaml_data['requirements']['run'])

    elif 'dependencies' in yaml_data:
        # environment export format
        specs = map( lambda s: s.split('='),
                     yaml_data['dependencies'] )
    else:
        raise Exception("Unsupported yaml format.")

    spec_list = starmap( lambda name, version='', string='': VersionSpec(name, version, string),
                         specs )

    if ignore_build_strings:
        spec_list = starmap( lambda name, version, string: VersionSpec(name, version, ''),
                             spec_list )

    spec_dict = { s.name : s for s in spec_list }
    return spec_dict

if __name__ == "__main__":
    main()
