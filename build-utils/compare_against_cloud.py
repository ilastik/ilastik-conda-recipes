"""
Compare the versions of your recipes to the package versions in the cloud.
Example usage:

    # Must use root conda env.
    $ source activate root

    $ cd ilastik-build-conda
    
    # For each package, find the latest version in any available channel
    $ python build-utils/compare_against_cloud.py */meta.yaml
    
    # For each package, find the latest version in the given channel if it exists,
    # otherwise the latest in any available channel
    $ python build-utils/compare_against_cloud.py --channel=ilastik */meta.yaml
"""
from __future__ import print_function
import sys
import os
import argparse
import subprocess
import json
from collections import namedtuple

from conda.resolve import VersionOrder
from conda_build.metadata import MetaData

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--channel', required=False,
                        help='If provided, the "latest" cloud version is taken from this channel, if present.')
    parser.add_argument('meta_yaml_paths', nargs='+')
    args = parser.parse_args()

    print_unequal(args.meta_yaml_paths, preferred_channel=args.channel)

def print_unequal(meta_yaml_paths, preferred_channel=None):
    """
    For given list of paths to recipe meta.yaml files, read the recipe versions 
    and compare them with the 'latest' version found in the cloud.
    
    If the recipe version of a package doesn't match the latest cloud version, print the mismatch.
    """
    for meta_yaml_path in meta_yaml_paths:
        package_name, recipe_version, recipe_build_number = read_recipe_name_version_build(meta_yaml_path)
        latest_channel, latest_version, latest_build_number = get_latest_build(package_name, preferred_channel)
        if latest_channel is None:
            print( "{}: Recipe is at {}={}, but latest is NOT FOUND."
                  .format(package_name, recipe_version, recipe_build_number) )
        elif (latest_version, latest_build_number) != (recipe_version, recipe_build_number):
            print( "{}: Recipe is at {}={}, but latest is {}={}"
                  .format( package_name, recipe_version, recipe_build_number, latest_version, latest_build_number ) )

def read_recipe_name_version_build(meta_yaml_path):
    """
    Read the given metadata file and return (package_name, version, build_number)
    
    meta_yaml_path: May be a path to a meta.yaml file or it's parent recipe directory.
    """
    # Provide these default values, otherwise conda-build will
    # choke on jinja templates that reference them.
    # This will be fixed when they finally merge conda-build PR#662 and PR#666
    if "CONDA_NPY" not in os.environ:
        os.environ["CONDA_NPY"] = '19'
    if "CONDA_PY" not in os.environ:
        os.environ["CONDA_PY"] = '27'
    os.environ["GIT_FULL_HASH"] = "9999999"

    if os.path.isdir(meta_yaml_path):    
        recipe_dir = meta_yaml_path
    else:
        recipe_dir = os.path.split(meta_yaml_path)[0]

    metadata = MetaData(recipe_dir)
    return (metadata.name(), metadata.version(), metadata.build_number())

BuildInfo = namedtuple('BuildInfo', 'channel version build_number')
def get_latest_build(package_name, preferred_channel=None):
    """
    Find the latest build of the given package and return a BuildInfo tuple.
    If the package can't be found in the cloud, None is returned in all fields. 
    
    package_name: The package to search for
    preferred_channel: If provided, the 'latest' version will always be chosen from this channel, if possible.
    """
    # Convert to unicode
    preferred_channel = preferred_channel and unicode(preferred_channel)
    
    # Search the cloud
    package_info = conda_search(package_name)
    if package_name not in package_info:
        return BuildInfo(None, None, None) # Not found
    
    latest = None
    for file_details in package_info[package_name]:
        channel = file_details["channel"]
        version = file_details["version"]
        build_number = file_details['build_number']
        
        if latest is None:
            # First found is latest by default
            latest = BuildInfo(channel, file_details["version"], build_number)
            continue
        
        better = False
        
        # Channel is better
        better |= ( preferred_channel is not None
                    and ( channel == preferred_channel and latest.channel != preferred_channel ) )
        
        # Channel is same, but version is better
        better |= ( (preferred_channel is None or channel == latest.channel)
                    and VersionOrder(version) > VersionOrder(latest.version) )
        
        # Channel and version are the same, but build_number is better
        better |= ( (preferred_channel is None or channel == latest.channel)
                    and VersionOrder(version) == VersionOrder(latest.version)
                    and build_number > latest.build_number)

        if better:
            latest = BuildInfo(channel, file_details["version"], build_number)
    
    return latest

def conda_search(package_name):
    """
    Call 'conda search --json' and return the parsed data.
    """
    bin_conda = sys.prefix + '/bin/conda'
    json_output = subprocess.check_output([bin_conda, 'search', '--json', package_name])
    return json.loads(json_output)
    
if __name__ == "__main__":
    # DEBUG
    # os.chdir('/Users/bergs/Documents/workspace/ilastik-build-conda')
    # sys.argv += "--channel=ilastik boost/meta.yaml".split()    

    main()
