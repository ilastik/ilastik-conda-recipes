from __future__ import print_function
import os
import sys
import json
import logging
import argparse
import collections

import conda.api
import conda.install
import conda.cli.common
from conda.cli.main_list import list_packages
from conda.resolve import Resolve, NoPackagesFound
from conda.toposort import toposort


def dependencies_for_env( prefix ):
    """
    Return an OrderedDict of all packages in the packages in the
    given environment and each one's list of dependencies.
    The returned items are in toposort order. 
    """
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
    
    deps_dict = {}
    for package in packages:
        try:
            versions = r.get_pkgs(conda.cli.common.arg2spec(package))
        except NoPackagesFound:
            print("Skipping " + package, file=sys.stderr)
        else:
            for pkg in sorted(versions):
                deps_dict[pkg.name] = []
                for dep in pkg.info['depends']:
                    deps_dict[pkg.name].append(dep.split(' ')[0])

    # If a package's dependencies have been updated recently on the server,
    # there may be entries in the deps list that aren't actually present in our environment.
    # In that case, we just omit that dependency.
    for pkg_name, deps in deps_dict.items():
        to_remove = []
        for dep in deps:
            if dep not in deps_dict:
                to_remove.append(dep)
        for dep in to_remove:
            deps_dict[pkg_name].remove( dep )

    # Convenience: Return dict with keys in topologically sorted order
    sorted_keys = toposort( deps_dict )
    #print('\n'.join(sorted_keys))

    deps_dict = collections.OrderedDict( map(lambda k: (k, deps_dict[k]), sorted_keys ) )
    return deps_dict


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--name', '-n')
    parser.add_argument('--prefix', '-p')
    parser.add_argument('--output', '-o')
    parser.add_argument('--keys-only', '-k', action='store_true')
    parser.add_argument('--format', '-f', choices=['json', 'delimited'], default='json')
    args = parser.parse_args()

    prefix = conda.cli.common.get_prefix(args)

    if not os.path.exists(prefix):
        sys.stderr.write("Error: No such environment: {}\n".format(prefix))
        sys.exit(1)

    # If writing to stdout, make sure the logs are silent
    if not args.output:
        for name in ['stdoutlog', 'fetch', 'progress', 'dotupdate']:
            logging.getLogger(name).setLevel(logging.WARN)
    
    deps_dict = dependencies_for_env( prefix )

    if args.keys_only:
        json_data = deps_dict.keys()
    else:
        json_data = deps_dict

    if args.format == 'json':
        output_text = json.dumps(json_data, sort_keys=True, indent=4, separators=(',', ': '))
    else:
        if isinstance(json_data, list):
            output_text = '\n'.join(json_data)
        else:
            output_text = ''
            longest_keylen = max(map(len, json_data.keys()))
            for k,v in json_data.items():
                output_text += k + ' '*(longest_keylen-len(k)+1) + ' '.join(v) + '\n'

    # Write the dict as json
    env_name = args.name or os.path.split(prefix)[-1]
    if args.output:
        with open(args.output, 'w') as output_file:
            output_file.write( output_text )
    else:
        sys.stdout.write( output_text )


if __name__ == "__main__":
    #sys.argv += ['-p', '/miniforge/envs/ilastik-clang-py3qt5-minimal']
    #sys.argv += ['-o', 'ilastik-clang-py3qt5-minimal.json']
    sys.exit( main() )
    