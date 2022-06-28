import subprocess
import sys
from pathlib import Path
import os


def main():
    java_file = Path(__file__).parent / "IlastikSetter.java"
    ilastik_exe = Path(os.getenv("CONDA_PREFIX")) / "bin" / "ilastik"
    subprocess.check_call(["java", str(java_file), str(ilastik_exe)])
    subprocess.run(["ImageJ"] + sys.argv[1::])


if __name__ == '__main__':
    main()
