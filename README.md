This is Alpine Linux based Python 3.8 installation.
It contains GLIBS, C++ compiler, Fortrant compiler, lapack, openSSL, ODBC driver, libgnome-keyring,
ssl, curl, bash, git etc.

It is based on Alipne Linux 3.12 (and not 3.8 as previous version). 

Note: Some more OS-level packages was added to enable installation of libxml, *curl, *ssl, *keyring. 
See notes in the Dockerfile.

Note: many packages contain not latest versions, but one that are closed to previous release.
This is done to easier adoption of Python 3.8 (this is major change).
Of course, you're free to update to the latest version of the packages that you are interesting in.

It is based on Anaconda3 with the following tweaks:

* Pandas 0.24.2 doesn't support Python 3.8. Python 1.x removes many features. 0.25.3 was released in 10.2019, seems ok,
see https://pandas.pydata.org/docs/whatsnew/v0.25.3.html
So, we're using last version in 0.x branch.

* graphviz is installed (it's installation changes many packages). It enable further installation of PyDot from PyPi 
(if required). 

* Jupyter, ipython is installed from PyPi. jupyter-client,jupyter-core,prompt-toolkit are in non-standard combination 
to enable correct work of Jupyter from PyCharm Community edition 2018.2. 

* llvmlite, tornado, entrypoints,  are re-installed from PyPi and not from conda. This enable easier package 
installation from Pypi.

* pyyaml version changed to easier installation of other third-parties.

* ruamel_yaml was upgraded to 0.15.100 (latest is 0.16.12)

  Quote: " For production systems you should pin the version being used with ruamel.yaml<=0.15",
  see https://pypi.org/project/ruamel.yaml/ On 0.15.78  setup issue for 3.8 was fixed.
  
  
* cffi was upgraded to the latest 1.14.3.

    v1.12.2 "Added temporary workaround to compile on CPython 3.8.0a2."
    v1.12.3 has "More 3.8 fixes".
    See https://cffi.readthedocs.io/en/latest/whatsnew.html#older-versions  

* lxml was upgraded to 4.6.1.

    v4.3.6 "rebulit...to support Python 3.8". 4.4.0 "Support for Python 3.4 was removed".
    See https://lxml.de/4.6/changes-4.6.1.html
    

* h5py was upgraded to 2.9.0.

    Prefer custom HDF5 over pkg-config/fallback paths when building/installing
    (GH946, GH947 by Lars Viklund) - fails to install in dockercontainer.
    See https://docs.h5py.org/en/stable/whatsnew/2.9.html
 

* numba+llvmlite
    
    See https://github.com/numba/llvmlite/issues/531
 
    and https://github.com/numba/llvmlite/issues/621
    
    There are some issues of reinstalling them with Python 3.8. It is recommended to use llvmlite 0.34.0
    for this, that what I did. 


There are also some extra packages, see dockerfiles extras section.
If you need nlt_data see https://github.com/alex-ber/alpine-anaconda3/issues/2


You can extends this docker image and simply add

FROM alexberkovich/alpine-anaconda3:latest

COPY conf/requirements.txt etc/requirements.txt

RUN pip install -r  etc/requirements.txt


