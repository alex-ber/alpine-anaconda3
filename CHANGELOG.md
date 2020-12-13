# Changelog
All notable changes to this project will be documented in this file.

##[0.2.0] - TBD
* https://github.com/pypa/pip/issues/8368#issuecomment-743984123
* Start to work on autuomation of uninstalling packaging. Pending finishing changes in PythonPackageSyncTool
[https://github.com/alex-ber/PythonPackageSyncTool] .


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
 


