#!/usr/bin/env python
    
import os
import subprocess
import sys


def main(*argv):
    argv = list(argv)

    test = os.path.join(os.environ["SRC_DIR"], "test_spams.py")

    return(subprocess.check_call(["python", test] + argv[1:],
                                 stdin=sys.stdin,
                                 stdout=sys.stdout,
                                 stderr=sys.stderr))

if __name__ == "__main__":
    sys.exit(main(*sys.argv))
