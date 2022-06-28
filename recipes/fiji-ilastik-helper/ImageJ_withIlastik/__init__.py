import subprocess
import sys
from pathlib import Path
import os
import platform


def main():
    java_file = Path(__file__).parent / "IlastikSetter.java"
    if platform.system() == "Windows":
        ilastik_exe = Path(os.getenv("CONDA_PREFIX")) / "Scripts" / "ilastik.exe"
    else:
        ilastik_exe = Path(os.getenv("CONDA_PREFIX")) / "bin" / "ilastik"

    subprocess.check_call(["java", str(java_file), str(ilastik_exe)])
    subprocess.run(["ImageJ"] + sys.argv[1::])


if __name__ == '__main__':
    main()
