## alpine-anaconda3


This is Alpine Linux based Python 3.7 installation.
It contains GLIBS, C++ compiler, Fortrant compiler, openSSL, ODBC driver, etc.

It is based on Anaconda3 with the following tweaks:

* graphviz is installed (it's installation changes many packages). It enable further installation of PyDot from PyPi 
(if required). 

* Jupyter, ipython is installed from PyPi. jupyter-client,jupyter-core,prompt-toolkit are in non-standard combination 
to enable correct work of Jupyter from PyCharm Community edition 2018.2. 

* llvmlite, tornado, entrypoints,  are re-installed from PyPi and not from conda. This enable easier package 
installation from Pypi.

* pyyaml version changed to easier installation of other third-parties.





You can extends this docker image and simply add

FROM alexberkovich/alpine-anaconda3:latest

COPY conf/requirements.txt etc/requirements.txt

RUN pip install -r  etc/requirements.txt


