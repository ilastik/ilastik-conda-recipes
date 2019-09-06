@if "%CONDA_ACTIVE_ENV%"=="" if NOT "%CONDA_DEFAULT_ENV%"=="" (
    set CONDA_ACTIVE_ENV=%CONDA_DEFAULT_ENV%
)

@if "%CONDA_ACTIVE_ENV%"=="" (
    echo 'ilastik-package' cannot be installed into the root environment.
    echo Use 'activate environment-name' to switch to another environment.
    exit 1
)

@rem copy the ilastik version as our package version
python fill-paceholders.py
