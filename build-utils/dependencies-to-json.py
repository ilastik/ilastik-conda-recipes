from __future__ import print_function
import os
import sys
import json
import argparse

import conda.api
import conda.install
import conda.cli.common
from conda.cli.main_list import list_packages
from conda.resolve import Resolve, NoPackagesFound

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--name', '-n')
    parser.add_argument('--prefix', '-p')
    parser.add_argument('--output', '-o')
    args = parser.parse_args()

    # Find the env prefix
    prefix = conda.cli.common.get_prefix(args)

    # Get all package strings as 'name-version-build'
    installed = conda.install.linked(prefix)
    exitcode, packages = list_packages(prefix, installed, regex=None, format='canonical', show_channel_urls=False)

    # If present, remove channel prefix (e.g. from 'ilastik::boost=1.55.0=5')
    packages = map( lambda p: p.split('::')[-1], packages )

    # Replace last two '-' with '='
    packages = map(lambda p: p[::-1].replace('-', '=', 2)[::-1], packages)

    # Load dependencies into a dict
    index = conda.api.get_index()
    r = Resolve(index)
    
    json_data = {}
    for package in packages:
        try:
            versions = r.get_pkgs(conda.cli.common.arg2spec(package))
        except NoPackagesFound:
            print("Skipping " + package)
        else:
            for pkg in sorted(versions):
                json_data[pkg.name] = []
                for dep in pkg.info['depends']:
                    json_data[pkg.name].append(dep.split(' ')[0])

    # Write the dict as json
    env_name = args.name or os.path.split(prefix)[-1]
    output_filepath = args.output or (env_name + '.json')
    with open(output_filepath, 'w') as output_file:
        json.dump(json_data, output_file, sort_keys=True, indent=4, separators=(',', ': '))

if __name__ == "__main__":
    sys.exit( main() )
    