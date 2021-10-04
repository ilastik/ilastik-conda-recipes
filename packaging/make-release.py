from pathlib import Path
from typing import List, Dict, Optional
import click
import json
import logging
import os
import platform
import re
import shutil
import subprocess


logger = logging.getLogger("make-release")

CONDA_DEFAULT_OPTIONS = ["--yes", "--override-channels", "--strict-channel-priority"]

OS: str = platform.system().lower()

# FIXME: cudatoolkit should in principle be moved to either ilastik-dependencies or parametrized
# for now this allows for quicker adjustments of releases...
ILASTIK_PACKAGES = {
    "common": {
        "linux": ["ilastik-dependencies-binary", "tiktorch", "pytorch", "inferno"],
        "darwin": ["ilastik-dependencies-binary", "tiktorch", "py2app", "inferno", "pytorch"],
        "windows": ["ilastik-dependencies-binary", "tiktorch", "pytorch", "inferno", "ilastik-exe", "ilastik-package"],
    },
    "cpu": {
        "linux": ["cpuonly"],
        "darwin": ["cpuonly"],
        "windows": ["cpuonly"],
    },
    "gpu": {
        "linux": ["cudatoolkit>=11.0"],
        "windows": ["cudatoolkit>=11.0"],
    },
}


OS_SUFFIX = {
    "linux": "Linux",
    "darwin": "OSX",
    "windows": "win64",
}

DEFAULT_CHANNELS = ["ilastik-forge", "pytorch", "conda-forge"]


STRIP_PATHS = {
    "common": [Path("ilastik-meta/ilastik/tests")],
    "linux": [Path("include"), Path("qml"), Path("share/doc")],
    "darwin": [Path("include"), Path("qml"), Path("share/doc")],
    "windows": [],  # stripping on windows via installer builder
}

ISS = None
if OS == "windows":
    ISS = os.environ["INNOCC"]
    assert Path(ISS).exists()


class CondaEnv:
    @staticmethod
    def conda_info():
        return json.loads(subprocess.check_output(["conda", "info", "-e", "--json"]))

    def __init__(self, env_name: str, variant: str):
        self._name = env_name
        self._variant = variant
        self._packages_list = ILASTIK_PACKAGES["common"][OS] + ILASTIK_PACKAGES[variant][OS]
        self._is_valid = False

        self._create(channels=DEFAULT_CHANNELS, packages=self._packages_list)
        self._strip()

    @property
    def name(self):
        return self._name

    @property
    def variant(self):
        return self._variant

    @classmethod
    def envs(cls) -> List[Path]:
        return [Path(x) for x in json.loads(subprocess.check_output(["conda", "env", "list", "--json"]))["envs"]]

    @property
    def path(self) -> Path:
        return Path(self.conda_info()["envs_dirs"][0]) / self.name

    def _strip(self):
        logger.info("Stripping release")
        for p in STRIP_PATHS["common"] + STRIP_PATHS[OS]:
            try:
                current = self.path / p
                logger.info(f"removing {current}")
                shutil.rmtree(current)
            except Exception as e:
                logger.warning(f"Encountered error removing {current}: {e}")

    def _create(self, channels: List[str], packages: List[str]) -> None:
        logger.info(f"creating environment {self.name} with channels: {channels} and packages {packages}")
        if self.path.exists():
            subprocess.check_call(["conda", "env", "remove", "--name", self.name])
            if self.path.exists():
                try:
                    self.path.unlink()
                except PermissionError:
                    if OS == "windows":
                        logger.warning(f"Could not remove {self.path} - might be some windows issue.")
                    else:
                        raise

        chans = []
        for channel in channels:
            chans += ["--channel", channel]
        subprocess.check_call(
            [
                "conda",
                "create",
                "--name",
                self.name,
                *CONDA_DEFAULT_OPTIONS,
                *chans,
                *packages,
            ]
        )
        self._is_valid = True
        logger.info("created environment successfully")

    def package_info(self, package_name: str) -> Dict[str, str]:
        package_list = json.loads(subprocess.check_output(["conda", "list", "--name", self.name, "--json"]))
        package_info = [x for x in package_list if x["name"] == package_name]
        assert (
            len(package_info) == 1
        ), f"Could not find unique package info for {package_name}; found {len(package_info)}."
        return package_info[0]

    @property
    def is_valid(self):
        return self._is_valid


class IlastikRelease:
    def __init__(self, release_env: CondaEnv, release_dir=Path):
        assert release_env.is_valid
        self._release_env = release_env

        self._imeta_version = self._release_env.package_info("ilastik-meta")["version"]
        # ilastik-${ILASTIK_PKG_VERSION}${SOLVERS_SUFFIX}${TIKTORCH_SUFFIX}-`uname`
        # FIXME: hardcoded variant!
        self._release_suffix = f"{self._imeta_version}-{OS_SUFFIX[OS]}"
        self._release_variant_suffix = "" if release_env.variant == "cpu" else f"-{release_env.variant}"
        self._release_name = f"ilastik-{self._release_suffix}{self._release_variant_suffix}"

        self._release_dir = release_dir
        self._release_path: Optional[Path] = None

        self._prepare_package()
        self._package()

    @property
    def release_path(self):
        return self._release_path

    def _prepare_package(self) -> None:
        logger.info("preparing package")
        if OS == "windows":
            self._prepare_windows()
        elif OS == "linux":
            self._prepare_linux()
        elif OS == "darwin":
            self._prepare_darwin()
        else:
            raise NotImplementedError(f"Not implemented for OS {OS}")

    def _prepare_windows(self) -> None:
        iss_in = self._release_env.path / "package" / "ilastik.iss.in"
        iss_out = iss_in.parent / "ilastik.iss"

        iss_out.write_text(re.sub("@VERSION@", self._imeta_version, iss_in.read_text()))

    def _prepare_darwin(self) -> None:
        pass

    def _prepare_linux(self) -> None:
        pass

    def _package(self) -> None:
        logger.info("packaging")
        if OS == "windows":
            self._package_windows()
        elif OS == "linux":
            self._package_linux()
        elif OS == "darwin":
            self._package_darwin()
        else:
            raise NotImplementedError(f"Not implemented for OS {OS}")

    def _package_windows(self) -> None:
        iss_path = self._release_env.path / "package" / "ilastik.iss"
        subprocess.check_call([ISS, f"/O{self._release_dir}", str(iss_path)])
        self._release_path = self._release_dir / f"{self._release_name}.exe"

    def _package_linux(self) -> None:
        package_cmd = Path(__file__).parent / "linux" / "create-tarball.sh"
        subprocess.check_call([package_cmd, self._release_name, self._release_dir])
        self._release_path = self._release_dir / f"{self._release_name}.tar.bz2"

    def _package_darwin(self) -> None:
        package_cmd = Path(__file__).parent / "osx" / "create-osx-app.sh"
        subprocess.check_call([package_cmd, self._release_name, self._release_dir])
        self._release_path = self._release_dir / f"{self._release_name}.tar.bz2"


@click.command()
@click.option("-v", "--verbose", is_flag=True, help="Enables verbose mode")
@click.option(
    "--output-dir",
    default="./",
    type=click.Path(
        exists=True,
        file_okay=False,
        dir_okay=True,
        writable=True,
        resolve_path=True,
        path_type=Path,
    ),
    help="Output directory for package, default pwd.",
)
@click.option(
    "--variant",
    type=click.Choice(["cpu", "gpu"]),
    required=True,
    help="Build binary with cpu-only pytorch, or with cuda (large binary). gpu not available on osx",
)
def main(verbose: bool, output_dir: Path, variant: str):
    if OS == "darwin" and variant == "gpu":
        raise ValueError("gpu builds not available on osx")

    level = verbose and logging.DEBUG or logging.INFO
    logging.basicConfig()
    logger.setLevel(level)
    ilastik_env = CondaEnv(env_name="ilastik-release", variant=variant)
    ilastik_release = IlastikRelease(ilastik_env, output_dir)
    assert ilastik_release.release_path.exists()
    logger.info(f"created ilastik package at: {ilastik_release.release_path}.")


if __name__ == "__main__":
    main()
