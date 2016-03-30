from __future__ import print_function

import re
import subprocess
import collections
from itertools import groupby

def print_rpaths(dylib_path):
    """
    Print all rpaths in the given dylib, as found in 
    the file's LC_RPATH commands, detected via "otool -l"
    """
    for rpath in get_rpaths(dylib_path):
        print(rpath)

def get_rpaths(dylib_path):
    """
    Detect all LC_RPATH load commands in the given dylib 
    and return a list of the rpaths stored in them.
    """
    load_cmds = get_load_commands(dylib_path)
    rpath_cmds = filter(lambda cmd: cmd.name == 'LC_RPATH', load_cmds)
    path_re = re.compile('path (?P<rpath>.*) \(.*\)')

    rpaths = []
    for cmd in rpath_cmds:
        for line in cmd.lines:
            match = path_re.search(line)
            if match:
                rpaths.append(match.group('rpath'))
    return rpaths

LoadCommand = collections.namedtuple("LoadCommand", "index name lines")
def get_load_commands(path):
    """
    Parse the output of "otool -l" into a list of LoadCommand tuples.
    """
    lines = subprocess.check_output(['otool', '-l', path])
                      .decode('utf-8')
                      .splitlines()

    current_cmd = [-1]
    def get_current_cmd(line):
        if line.startswith('Load command'):
            current_cmd[0] += 1
        return current_cmd[0]

    cmds = []
    for cmd_index, cmd_lines in groupby(lines, get_current_cmd):
        if cmd_index < 0:
            continue
        cmd_lines = list(cmd_lines)
        cmd_name = cmd_lines[1].split()[1]
        cmds.append( LoadCommand(cmd_index, cmd_name, cmd_lines) )
    return cmds

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: {} <dylib>\n".format(sys.argv[0]))
        sys.exit(1)
    sys.exit(print_rpaths(sys.argv[1]))
