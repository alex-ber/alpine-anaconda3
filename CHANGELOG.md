# Changelog
All notable changes to this project will be documented in this file.

## [0.3] - 2020-11-11
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




## [0.2] - 2019-10-23
### Changed
- Added soft-link to conda3.


## [0.1] - 2019-10-17
### Changed
- Initial release with anaconda3.
 


