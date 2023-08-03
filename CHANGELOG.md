# Changelog
All notable changes to this project will be documented in this file.


## Unreleased


##[0.3.4] - 04/08/2023
### Added
- OS level packages for working with images:  jpeg-dev libjpeg libjpeg-turbo libjpeg-turbo-dev
- Explicit OS package maturin.It is required for pyo3, that is required for successful built of cryptography module. 
See https://pyo3.rs/v0.19.2/getting_started
("failed to get `pyo3` as a dependency of package `cryptography-rust v0.1.0")

### Changed
- Upgrade pyyaml==6.0.1 (major version update).
- Upgrade awscli==1.29.17 boto3==1.28.17 botocore==1.31.17 colorama==0.4.3 s3transfer==0.6.1 (major versionhs upgrade).
- Upgrade pip==23.2.1 setuptools==68.0.0 (major versions update).
- Upgrade SQLAlchemy from 1.4.11 to 1.4.31  (minour version update).  
- Upgrade pg8000 from 1.19.3 to 1.29.4 (major update).
- Upgrade cryptography from 3.4.7 to 41.0.3.
- Upgrade pyparsing==2.4.7 to 3.1.1.
- Upgrade docutils from 0.15.2 to 0.16.
- Upgrade invoke from 1.4.1 to 1.7.3.
- Upgrade six from 1.15.0 to 1.16.0.
- Upgrade zip from 3.6.2 to zipp==3.16.2.

### Dropped
- Dropped OS support of dbus-launch, dbus-run-session, keyring (breaking change) 
- Dropped version of OS packages Dockerfile-python.


##[0.3.3] - 31/05/2021
See detail description of the 0.3.x series here 
https://medium.com/geekculture/docker-container-with-python-for-arm64-amd64-779c3e90d293


### Added
- OS-level package `openblas-dev`. Needed from built from source of `scipy` in `alpine-python3` dockers  
(both for `AMD64` and for `ARM64`). Not needed for Anaconda-based images, but added theire anyway for unifromity. 
See `Failed to install scipy in alpine-python dockerfile for AMR64v8` 
https://github.com/alex-ber/alpine-anaconda3/issues/3

### Changed
- Fixed `CMD` entry for all docker images. See https://github.com/alex-ber/alpine-anaconda3/issues/4


##[0.3.2] - 29/05/2021

Mutli-arch Docker-image for amd64 and arm64v8 is created.

Quote:
"If you want to use ARM targets to reduce your bill, such as Raspberry Pis and AWS A1 instances, 
or even keep using your old i386 servers, deploying everywhere can become a tricky problem 
as you need to build your software for these platforms" 

https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/


**Important note:** Only `--platform linux/arm64 alexberkovich/alpine-python3:0.3.2` works on AWS A1 instance.

**Important note:** Slim version of arm64 is in in beta-version and can be removed without prior notice. 

### Major added
- Mutli-arch Docker-image for `amd64` and `arm64v8` is created.
- Python-based version is added. It doesn't include Anaconda, close to slim version. Has variants for 
`amd64` and `arm64v8`. 
- `pg8000` version 1.19.3. It is `PostgreSQL` driver that complies with `DB-API 2.0` (`SqlAlchemy`).

### Major changed
- `Anaconda` version to Anaconda3-2021.05 (from Anaconda3-2020.07).
This means, that many installed packaged was also changed. New packages was also added.
- `Python` version changed to 3.8.8 (from 3.8.5).
- On `ARM64` we don't have `numpy+mkl`, but `numby+openblas`. `mkl` and variant's are inavailable on `ARM64`.
- `SQLAlchemy` version changed to 1.4.11 (from 1.3.3).  

### Changed
- `cryptography` version changed to 3.4.7 (from 3.1.1)
- `pyOpenSSL`version changed to 20.0.1 (from 19.1.0)
- `cffi`version changed to 1.14.5 (from cffi==1.14.3)
- `tqdm`version changed to 4.59.0 (from 4.50.2)
- `conda` version changed to 4.10.1 (from 4.9.2)
- `sip` version changed to 4.19.25 from (4.19.13).
- `curl-dev` (OS-level package) version changed to 7.77.0-r0 (from curl-dev=7.69.1-r3).
- `curl`(OS-level package) version changed to 7.77.0-r0 (from curl=7.69.1-r3).
- `openssl-dev` (OS-level package) version changed to 1.1.1k-r0 (from openssl-dev=1.1.1i-r0).
- `libx11`(OS-level package) version changed to 1.6.12-r1 (from 1.6.12-r0).
- `ssl_client` (OS-level package) version changed to 1.31.1-r20 (from 1.31.1-r19).
- `git` (OS-level package) changed to 2.26.3-r0 (from 2.26.2-r0).
- `busybox`(OS-level package) version changed to 1.31.1-r20 (from 1.31.1-r19). 

- In `Dockerfile-slim` for `AMD64` the following package will remain (in addition):
`blas`, `libllvm10`, `icc-rt`, `intel-openmp`, `Cython`, `pycurl`.


### Added
- `Cython` version 0.29.13.

- OS-level package `hdf5-dev`. Needed from built from source of `h5py` (current built uses 
binarys (wheel) both for `AMD64` and for `ARM64`).

- OS-Level package `cargo`. It contains Rust compiler. Required by `cryptography` (current built uses 
binarys (wheel) both for `AMD64` and for `ARM64`).

- `Dockerfile-slim` for `ARM64` is created. 

###Documentation

* `alexberkovich/alpine-anaconda3:0.3.2` is manifest file that aggregates 
`alexberkovich/alpine-anaconda3:0.3.2-amd64` and `alexberkovich/alpine-anaconda3:0.3.2-arm64v8`. 
Two last one are regular tagged images (built for specific CPU architecture).

* `alexberkovich/alpine-anaconda3:0.3.2-slim` is manifest file that aggregates 
`alexberkovich/alpine-anaconda3:0.3.2-slim-amd64` and `alexberkovich/alpine-anaconda3:0.3.2-slim-arm64v8`. 
Two last one are slim tagged images (built for specific CPU architecture).

* `alexberkovich/alpine-python3:0.3.2` is manifest file that aggregates 
`alexberkovich/alpine-python3:0.3.2-amd64` and `alexberkovich/alpine-python3:0.3.2-arm64v8`. 
Two last one are Python-based (without Anaconda) tagged images (built for specific CPU architecture).

* `alexberkovich/alpine-anaconda3:latest` is the same as `alexberkovich/alpine-anaconda3:0.3.2` 
(will change after new version will be released).

* `alexberkovich/alpine-anaconda3:latest-slim` is the same as`alexberkovich/alpine-anaconda3:0.3.2-slim`
 (will change after new version will be released).

* `alexberkovich/alpine-python3:latest` is the same as `alexberkovich/alpine-python3:0.3.2` 
(will change after new version will be released).


##[0.2.1] - 2021-01-22
### Changed
Changing version of: 

- scipy==1.2.1 change to scipy==1.5.4
- matplotlib==3.0.3 change to matplotlib==3.1.3

These are minimal version bumping that works on Windows.
See 
https://github.com/scipy/scipy/issues/12656
https://github.com/microsoft/PTVS/issues/5863 

### Added 

- pydot==1.4.1



##[0.2.0] - 2020-12-17
* https://github.com/pypa/pip/issues/8368#issuecomment-743984123
* Automation of uninstalling packaging via PythonPackageSyncTool
[https://github.com/alex-ber/PythonPackageSyncTool] .

### Changed
- alexberkovich/alpine-anaconda3:0.2.0
```
pip install graphviz==0.14.2 numpy==1.16.2 scipy==1.2.1 && \ 
```
was spltied into 2 lines

```
pip install graphviz==0.14.2 numpy==1.16.2 && \
pip install scipy==1.2.1 && \
```
It is forwad-compatibility fix. It also optimizes building docker image now.
See discussion here https://github.com/pypa/pip/issues/8368#issuecomment-743980139

- alexberkovich/alpine-anaconda3:0.2.0-slim
is now not use precomputed rm.txt for packages to be removed, but it uses my
python_package_sync_tool https://github.com/alex-ber/PythonPackageSyncTool
to calculate them on-the-fly. 


##[0.1.1] - 2020-12-12
### Documantation
- https://medium.com/@alex-ber/using-gnome-keyring-in-docker-container-2c8a56a894f7	Using GNOME Keyring in Docker Container
- Some remarks was added.

### Changed
- musl* version changed from 1.1.24-r9 to 1.1.24-r10
- curl* version changed from 7.69.1-r1 to 7.69.1-r3
- openssl-dev version changed from 11.1.1g-r0to 1.1.1i-r0
- update versions to awscli==1.18.184 boto3==1.16.24 botocore==1.19.24
- update versions to pip==20.3.1 setuptools==51.0.0 wheel==0.36.1
- update versions toml from 0.10.1 to 0.10.2
- update versions conda
- sip now is reintalled (using conda, pypi doesn't contain latest version)
- section "already installed, just for documentatation" is extended
- alexberkovich/alpine-anaconda3:0.1.1 is compressed now.
   
### Added
- alexberkovich/alpine-anaconda3:0.1.1-slim is added that have only C-extension related packages (and very few more).
- alexberkovich/alpine-anaconda3:0.1.1-slim is compressed.
- rm.txt file- what packages should be uninstalled to get slim version
- Dockerfile-slim - for alexberkovich/alpine-anaconda3:0.1.1-slim.
 

## [0.1.0] - 2020-11-17
### Changed
#### Fixing potential security risk.
- Change Git not to store credential as plain text, but to keep them in memory for 1 hour
 see https://git-scm.com/docs/git-credential-cache
 
`git config --global credential.helper 'cache --timeout=3600'`

## [0.0.5] - 2020-11-16
### Changed
- Version number in this file and last tag. It should be 0.0.x and not 0.x.
- Added support for /etc/enter_init.sh where you can provide hooks for initilializing keyring,
like this:

```bash
#!/usr/bin/env bash

set -e

echo '1234' | keyring set system username
```

## [0.0.4] - 2020-11-08
### Added
- `libgnome-keyring` for secure storing credentials.
For more details, read https://medium.com/@alex-ber/using-gnome-keyring-in-docker-container-2c8a56a894f7

- `Git` configured to use `libgnome-keyring`.

- Script `/etc/enter_keyring.sh` is intented to be used as entrypoint. 

It will "inject" script to initialize D-Bus session and unlock Gnome Keyring before Python is called.

This will enable to use Python's keyring package. 
For more details, read https://medium.com/@alex-ber/using-gnome-keyring-in-docker-container-2c8a56a894f7	 
 
- Helper script `/etc/unlock_keyring.sh` that will unlock Gnome Keyring Daemon.

It is intended to be used from the bash shell. It can be used together with `/etc/enter_keyring.sh` 
as entrypoint or as stand-alone script. If it is called without any parameters, it will start
new D-Bus session, unlock Gnome Keyring and open new bash session.

Optionally, you can supply specific command to be invoked in such D-Bus session. In this case,
no extra bash session will be created.

Note: When using together with `/etc/enter_keyring.sh` as entrypoint you will share the same D-Bus session.
You can read/write the same secrets from your Python and from the Bash.      

See https://keyring.readthedocs.io/en/latest/#using-keyring-on-headless-linux-systems
for more details.

Note: This script is not part of `cmd`/`entrypoint` or build phase.

- Helper script `/etc/unlock_keyring` is intended to be used together with `/etc/enter_keyring.sh` 
as entrypoint. You will join the same D-Bus session that was opened in the process with Python.

- Helper script `fix.sh` that will convert all *.sh script from Windows format to Linux.


- boto3 

- python-dotenv

- bidict

- fabric

- pytest extra

- Twine 

- SQLAlchemy & Hive

- keyring_check.py for sanity check.


### Changed
- Bash+nano+locate instalation is refactored and moved to another place.

- We had scikit-learn==0.20.3 and joblib inside scikit-learn. This was changed to  scikit-learn==0.22 and joblib==0.14.1.
See https://github.com/alex-ber/alpine-anaconda3/issues/1

https://github.com/scikit-learn/scikit-learn/issues/15800

https://stackoverflow.com/questions/58700384/how-to-fix-typeerror-an-integer-is-required-got-type-bytes-error-when-tryin

https://github.com/apache/spark/blob/v2.4.5/python/pyspark/cloudpickle.py#L78-L93 (patch)

PySpark https://issues.apache.org/jira/browse/SPARK-29536

### Rejected
For nltk_data see https://github.com/alex-ber/alpine-anaconda3/issues/2
 

## [0.0.3] - 2020-11-01
### Changed
- Upgrading to Alipne Linux 3.12.
- Upgrading to bash 5
- Adding locate.
- Some more OS-level packages was added to enable installation of libxml, *curl, *ssl.
- Upgrading to Python 3.8.5.

- Pandas 0.24.2 doesn't support Python 3.8. Python 1.x removes many features. 0.25.3 was released in 10.2019, seems ok,
see https://pandas.pydata.org/docs/whatsnew/v0.25.3.html
So, we're using last version in 0.x branch.

- ruamel_yaml was upgraded to 0.15.100 (latest is 0.16.12)

  Quote: " For production systems you should pin the version being used with ruamel.yaml<=0.15",
  see https://pypi.org/project/ruamel.yaml/ On 0.15.78  setup issue for 3.8 was fixed.
  
  
- cffi was upgraded to the latest 1.14.3.

    v1.12.2 "Added temporary workaround to compile on CPython 3.8.0a2."
    v1.12.3 has "More 3.8 fixes".
    See https://cffi.readthedocs.io/en/latest/whatsnew.html#older-versions  

- lxml was upgraded to 4.6.1.

    v4.3.6 "rebulit...to support Python 3.8". 4.4.0 "Support for Python 3.4 was removed".
    See https://lxml.de/4.6/changes-4.6.1.html
    

- h5py was upgraded to 2.9.0.

    Prefer custom HDF5 over pkg-config/fallback paths when building/installing
    (GH946, GH947 by Lars Viklund) - fails to install in dockercontainer.
    See https://docs.h5py.org/en/stable/whatsnew/2.9.html
 

- numba+llvmlite
    
    See https://github.com/numba/llvmlite/issues/531
 
    and https://github.com/numba/llvmlite/issues/621
    
    There are some issues of reinstalling them with Python 3.8. It is recommended to use llvmlite 0.34.0
    for this, that what I did. 




## [0.0.2] - 2019-10-23
### Changed
- Added soft-link to conda3.


## [0.0.1] - 2019-10-17
### Changed
- Initial release with anaconda3.
 


