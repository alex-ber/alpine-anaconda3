ARG ARCH=
# AlpineLinux with a glibc-2.29-r0 and python3
FROM ${ARCH}/alpine:3.12
ARG ARCH
ENV ARCH=${ARCH}

RUN set -ex && \
   echo $ARCH > /etc/ARCH

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8

#see below
#ARG GLIBC_REPO=https://github.com/$GLIBC_REPO_INFIX/alpine-pkg-glibc
ARG GLIBC_VERSION=2.32-r0

ENV PATH=${PATH}:/opt/anaconda3/bin
ARG ANACONDA_VERSION=Anaconda3-2021.05


#updating from alpine 3.8 to 3.12 as of 23.05.2021
RUN set -ex && \
    #apk -U upgrade  && \
    apk add --no-cache musl=1.1.24-r10 busybox=1.31.1-r20 alpine-baselayout=3.2.0-r7 ca-certificates-bundle \
                       ssl_client=1.31.1-r20 musl-utils=1.1.24-r10

#dbus-launch, dbus-run-session
RUN set -ex && \
    apk add --no-cache dbus=1.12.18-r0 dbus-x11=1.12.18-r0 libx11=1.6.12-r1 libxcb=1.14-r1 libxdmcp=1.1.3-r0 \
                           libxcb=1.14-r1 libx11=1.6.12-r1

#libgnome-keyring
RUN set -ex && \
   apk add --no-cache libgnome-keyring=3.12.0-r2 dbus-libs=1.12.18-r0 gnome-keyring=3.36.0-r0 \
           linux-pam=1.3.1-r4 gcr-base=3.36.0-r0 p11-kit=0.23.22-r0 glib=2.64.6-r0 pcre=8.44-r0 \
           libmount=2.35.2-r0 libblkid=2.35.2-r0 libintl=0.20.2-r0 libcap-ng=0.7.10-r1

#Git
RUN set -ex && \
   apk add --no-cache git=2.26.3-r0 expat=2.2.9-r1 pcre2=10.35-r0 && \
   #git config --global credential.helper store
   #git config --global credential.helper cache
   #see https://git-scm.com/docs/git-credential-cache
   git config --global credential.helper 'cache --timeout=3600'



#ssl, curl
#for curl-dev see https://stackoverflow.com/a/51849028/1137529
#for libffi-dev see https://stackoverflow.com/a/58396708/1137529
#for cargo see https://github.com/pyca/cryptography/issues/5776#issuecomment-775158562
RUN set -ex && \
    apk add --no-cache openssl-dev=1.1.1k-r0 musl-dev=1.1.24-r10 cyrus-sasl-dev=2.1.27-r6 \
                       linux-headers=5.4.5-r1 unixodbc-dev=2.3.7-r2 curl-dev=7.77.0-r0 libffi-dev==3.3-r2 cargo==1.44.0-r0

#https://stackoverflow.com/questions/5178416/libxml-install-error-using-pip
RUN set -ex && \
    apk add --no-cache libxml2-dev=2.9.10-r5 libxslt-dev=1.1.34-r0

#gcc, gfortran, lapack (requires ssl layer above)
#see https://stackoverflow.com/questions/11912878/gcc-error-gcc-error-trying-to-exec-cc1-execvp-no-such-file-or-directory
#see https://stackoverflow.com/a/38571314/1137529
RUN set -ex && \
    apk add --no-cache make=4.3-r0 gcc=9.3.0-r2 build-base=0.5-r2 lapack-dev=3.9.0-r2 freetype-dev=2.10.4-r0 \
                       gfortran=9.3.0-r2

#https://github.com/h5py/h5py/issues/1461#issuecomment-562871041
#https://stackoverflow.com/questions/66705108/how-to-install-hdf5-on-docker-image-with-linux-alpine-3-13
RUN set -ex && \
    apk add --no-cache hdf5-dev=1.10.6-r1


#bash+usefull utils
#curl is installed above
RUN set -ex && \
    apk --no-cache add bash=5.0.17-r0 nano=4.9.3-r0 mlocate=0.26-r7 && \
    updatedb && \
    #disable coloring for nano, see https://stackoverflow.com/a/55597765/1137529
    echo "syntax \"disabled\" \".\"" > ~/.nanorc; echo "color green \"^$\"" >> ~/.nanorc

#install glibc (another c++ compiler, older one)
# do all in one step
RUN set -ex && \
    #Remarked by Alex \
    #apk -U upgrade && \
    #Alex added --no-cache
    apk --no-cache add libstdc++=9.3.0-r2 curl=7.77.0-r0 && \
    #Added  by Alex \
    #Alex added --no-cache
    apk --no-cache add net-tools=1.60_git20140218-r2 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    #Added by Alex \
    if [ "$ARCH" = "arm64v8" ]; then suffix='-arm64'; else suffix=''; fi && \
    #Added by Alex \
    if [ "$ARCH" = "arm64v8" ]; then infix='ljfranklin'; else infix='sgerrand'; fi && \
    GLIBC_REPO=https://github.com/$infix/alpine-pkg-glibc && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}${suffix}/${pkg}.apk -o /tmp/${pkg}.apk; done  && \
    #Alex added --no-cache
    apk --no-cache --allow-untrusted add /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib


#https://stackoverflow.com/questions/9510474/removing-pips-cache
#https://pip.pypa.io/en/stable/reference/pip_install/#caching
#pip config set global.cache-dir false doesn't work
#https://stackoverflow.com/questions/9510474/removing-pips-cache/61762308#61762308
RUN mkdir -p /root/.config/pip
RUN echo "[global]" > /root/.config/pip/pip.conf; echo "no-cache-dir = false" >> /root/.config/pip/pip.conf; echo >> /root/.config/pip/pip.conf;

##python3-dev (we need C++ header for cffi)
#RUN set -ex && \
#   apk add --no-cache make==4.3-r0 python3-dev==3.8.5-r0 py3-pip==20.1.1-r0
#
#RUN set -ex && \
#   pip install --upgrade pip==20.3.1 setuptools==51.0.0 wheel==0.36.1
#
#RUN set -ex && \
#    pip install ruamel_yaml==0.15.100
#
#RUN set -ex && \
#	#entrypoints==0.2.3 used in setup.py
#	#This version of PyYAML==5.1 works with awscli
#	#pyyaml installation from pypi
#	pip install entrypoints==0.2.3 pyyaml==5.1
#
#
#RUN set -ex && \
#	#twine
#	#https://twine.readthedocs.io/en/latest/changelog.html see 3.0.0 changelog
#	#Add Python 3.8 support
#	#see https://github.com/pypa/twine/pull/518
#	pip install twine==3.2.0 pkginfo==1.6.1 colorama==0.4.3 rfc3986==1.4.0 readme-renderer==28.0  \
#																	  requests-toolbelt==0.9.1 \
#																cffi==1.14.3 cryptography==3.1.1
#
#RUN set -ex && \
#	pip install cffi==1.14.3 cryptography==3.1.1 idna==2.10 pycparser==2.20  pyOpenSSL==19.1.0 \
#	            requests==2.24.0 tqdm==4.50.2  urllib3==1.25.11 toml==0.10.2






# install anaconda, see https://github.com/ContinuumIO/docker-images/blob/master/anaconda/alpine/Dockerfile
#RUN addgroup -S anaconda && \
#    adduser -D -u 10151 anaconda -G anaconda && \
RUN set -ex && \
    #Added by Alex \
    if [ "$ARCH" = "arm64v8" ]; then suffix='aarch64'; else suffix='x86_64'; fi && \
    wget --quiet https://repo.continuum.io/archive/$ANACONDA_VERSION-Linux-$suffix.sh -O anaconda.sh && \
    #Alex remark
    #echo "${ANACONDA_MD5}  anaconda.sh" > anaconda.md5 && \
    #if [ $(md5sum -c anaconda.md5 | awk '{print $2}') != "OK" ] ; then exit 1; fi && \
    mkdir -p /opt && \
    sh ./anaconda.sh -b -p /opt/anaconda3 && \
    #Alex remark
    #rm anaconda.sh anaconda.md5 && \
    rm anaconda.sh  && \
    #Alex fix
    #ln -s /opt/anaconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    #chown -R anaconda /opt && \
    #echo ". /opt/anaconda3/etc/profile.d/conda.sh" >> /root/.profile && \
    #echo "conda activate base" >> /root/.profile && \
    find /opt/anaconda3/ -follow -type f -name '*.a' -delete && \
    find /opt/anaconda3/ -follow -type f -name '*.js.map' -delete && \
    /opt/anaconda3/bin/conda clean -afy

RUN set -ex && \
     #PyYaml is a distutils installed project, pip can't remove it, it will be reinstalled below.
     #we will install jupyter from pypi, these are it's depenedencies, there is conflict.
     #numba & tornado will be installed below.
     #numba is MMVL compuler for numpy, also used in jupyter.
     #tornado is used in jupyter.
     #entrypoint will be installed below (it is a distutils installed project).
     #numpy & scipy will be installed below (with graphviz).
	 #sip will ne install below
     conda uninstall pyyaml numba tornado entrypoints numpy scipy sip && \
     #hack to remove ruamel.yaml, because it is distutils installed project
     rm -fr /opt/anaconda3/lib/python3.8/site-packages/ruamel_yaml* && \
     #latest pip,setuptools,wheel
     pip install --upgrade pip==20.3.1 setuptools==51.0.0 wheel==0.36.1 && \
     pip install ruamel_yaml==0.15.100  && \
     if [ "$ARCH" = "arm64v8" ]; then conda install _openmp_mutex=5.1; fi && \
     conda install conda=4.10.1 python=3.8.8 && \
     #pandas has compilling issues with higher versions of Cython
     pip install Cython==0.29.13 && \
     #--- numpy related part ---
     #restoring numba dependencies, not available in pip (part 1) \
     if [ "$ARCH" = "arm64v8" ]; then insuffix=''; else insuffix='mkl-service=2.3.0 mkl_fft=1.2.0 mkl_random=1.1.1'; fi && \
     conda install blas=1.0 libllvm10=10.0.1 ${insuffix} sip=4.19.25 && \
     #On Arm64 Installation of llvmlite through pip is not supported,
     #see http://llvmlite.pydata.org/en/latest/admin-guide/install.html#using-pip
     #using conda in such case
     #restoring numba dependencies from pip (part 2)
     if [ "$ARCH" = "arm64v8" ]; then conda install llvmlite=0.36.0 ; fi && \
     conda clean -afy && \
     if [ "$ARCH" = "arm64v8" ]; \
              then insuffix=''; else \
              insuffix='mkl==2021.2.0 mkl_fft==1.2.0 mkl_random==1.1.1 intel-openmp==2021.2 \
                        mkl-service==2.3.0 tbb==2021.2.0'; fi && \
     pip install llvmlite==0.36.0 sip==4.19.25 ${insuffix} numpy==1.16.2 && \
     pip install numba==0.53.1 && \

     #graphviz is used for pydot package
     #we want to ensure numpy,scipy versions
	 #Bumping scipy version up to the version that also work on Windows.
	 #see https://github.com/scipy/scipy/issues/12656
     pip install graphviz==0.14.2 pydot==1.4.1 numpy==1.16.2 pyparsing==2.4.7 && \
     pip install scipy==1.5.4 && \

     #reinstall removed package by conda uninstall through pip (pinned versions)
     #we have scikit-learn==0.20.3 and joblib inside scikit-learn=
     #see https://github.com/scikit-learn/scikit-learn/issues/15800
     #https://stackoverflow.com/questions/58700384/how-to-fix-typeerror-an-integer-is-required-got-type-bytes-error-when-tryin
     #https://github.com/apache/spark/blob/v2.4.5/python/pyspark/cloudpickle.py#L78-L93 (patch)
     ##PySpark https://issues.apache.org/jira/browse/SPARK-29536
     #This is minimal matplotlib==3.1.3 version that also works on Windows
     #https://github.com/microsoft/PTVS/issues/5863

     pip install pandas==0.25.3 scikit-learn==0.22 joblib==0.14.1 matplotlib==3.1.3 shub==2.10.0 nltk==3.4.5 \
                 seaborn==0.9.0 Bottleneck==1.2.1 retrying==1.3.3  pyyaml==5.1 && \

     #reinstall removed package by conda uninstall through pip (latest versions)
     #Werkzeug ast.Module signature change in Python 3.8.0a3 causes TypeError
     #https://github.com/pallets/werkzeug/issues/1551
     #" For production systems you should pin the version being used with ruamel.yaml<=0.15",
	 #see https://pypi.org/project/ruamel.yaml/ On 0.15.78  setup issue for 3.8 was fixed.
     pip install  \
                 lxml==4.6.1 beautifulsoup4==4.9.3 pyodbc==4.0.30 mock==4.0.2 pytest==6.1.2 flask==1.1.2 \
                 HiYaPyCo==0.4.16 Jinja2==2.11.2 terminado==0.9.1 nbconvert==6.0.7 keyring==21.4.0 \
                 PyWavelets==1.1.1 pytest-doctestplus==0.2.0 pytest-arraydiff==0.3 patsy==0.5.1 \
                 numexpr==2.7.1 imageio==2.9.0 h5py==2.10.0 bkcharts==0.2 astropy==4.1 Pillow==8.0.1 \
                 Werkzeug==1.0.1

#extras
RUN set -ex && \
	 #boto3
	 pip install awscli==1.18.184 boto3==1.16.24 botocore==1.19.24 colorama==0.4.3 && \
	 pip install python-dotenv==0.15.0 && \
	 pip install bidict==0.21.2 && \

	 #fabric & pyOpenSSL
	 pip install fabric==2.5.0 invoke==1.4.1 paramiko==2.7.2 PyNaCl==1.3.0  bcrypt==3.2.0 \
	             cffi==1.14.5 cryptography==3.4.7 pycparser==2.20 PyNaCl==1.3.0 six==1.15.0 \
				 pyOpenSSL==20.0.1 && \

	 #pytest extra
	 pip install pytest==6.1.2 mock==4.0.2 pytest-assume==2.3.3 pytest-mock==3.3.1 \
	             attrs==20.2.0 py==1.9.0 PyYAML==5.1 toml==0.10.2 pluggy==0.13.1 packaging==20.4 iniconfig==1.1.1 \
	             pyparsing==2.4.7 requests==2.24.0 tqdm==4.59.0 && \

	 #twine
     #https://twine.readthedocs.io/en/latest/changelog.html see 3.0.0 changelog
     #Add Python 3.8 support
     #see https://github.com/pypa/twine/pull/518
     pip install twine==3.2.0 pkginfo==1.6.1 colorama==0.4.3 rfc3986==1.4.0 readme-renderer==28.0  \
                                                                          requests-toolbelt==0.9.1  && \
     #SQLAlchemy & Hive & Postgress
	 pip install SQLAlchemy==1.4.11 thrift==0.13.0 thrift-sasl==0.4.2 sasl==0.2.1 PyHive==0.6.2 pg8000==1.19.3 \
	             pure-sasl==0.6.2 pure-transport==0.2.0 future==0.18.2



#nltk-data
#RUN set -ex && python -m nltk.downloader -d /usr/share/nltk_data all


RUN set -ex && \
     #reinstall jupyter, tornado and ipython
     #IPython 6.5 broken with python 3.8
     #https://github.com/ipython/ipython/issues/12558
     pip install tornado==5.1.1 jupyter==1.0.0 ipython==7.18.1  && \
     pip install ipykernel==4.6.1  && \
     ipython kernelspec install-self  && \

     #entrypoints==0.2.3 used in setup.py
     #This version of PyYAML==5.1 works with awscli
     #pyyaml installation from pypi
     pip install entrypoints==0.2.3 pyyaml==5.1

#already installed, just for documentatation
RUN set -ex && \
	pip install ruamel_yaml==0.15.100  && \
	conda install sip=4.19.25   && \
	if [ "$ARCH" = "arm64v8" ]; then conda install _openmp_mutex=5.1; fi && \
    conda install conda=4.10.1 python=3.8.8 && \
    pip install Cython==0.29.23 && \
    #--- numpy related part ---
    #restoring numba dependencies, not available in pip (part 1) \
    if [ "$ARCH" = "arm64v8" ]; then insuffix=''; else insuffix='mkl-service=2.3.0 mkl_fft=1.2.0 mkl_random=1.1.1'; fi && \
    conda install blas=1.0 libllvm10=10.0.1 ${insuffix} sip=4.19.25 && \
    #On Arm64 Installation of llvmlite through pip is not supported,
    #see http://llvmlite.pydata.org/en/latest/admin-guide/install.html#using-pip
    #using conda in such case
    #restoring numba dependencies from pip (part 2)
    if [ "$ARCH" = "arm64v8" ]; then conda install llvmlite=0.36.0 ; fi && \
    conda clean -afy && \
    if [ "$ARCH" = "arm64v8" ]; \
             then insuffix=''; else \
             insuffix='mkl==2021.2.0 mkl_fft==1.2.0 mkl_random==1.1.1 intel-openmp==2021.2 \
                       mkl-service==2.3.0 tbb==2021.2.0'; fi && \
    pip install numba==0.53.1 llvmlite==0.36.0 sip==4.19.25 ${insuffix} numpy==1.16.2 && \

	#entrypoints==0.2.3 used in setup.py
	#This version of PyYAML==5.1 works with awscliconfig.yml
	#pyyaml installation from pypi
	pip install entrypoints==0.2.3 pyyaml==5.1 && \
	#twine
	#https://twine.readthedocs.io/en/latest/changelog.html see 3.0.0 changelog
	#Add Python 3.8 support
	#see https://github.com/pypa/twine/pull/518
	pip install twine==3.2.0 pkginfo==1.6.1 colorama==0.4.3 rfc3986==1.4.0 readme-renderer==28.0  \
                                            webencodings==0.5.1 bleach==3.2.1 requests-toolbelt==0.9.1 \
											packaging==20.4 pyparsing==2.4.7 \
															cffi==1.14.5 cryptography==3.4.7 && \
	#pin pyOpenSSL==20.0.1 requests==2.24.0 tqdm==4.59.0
	pip install cffi==1.14.5 cryptography==3.4.7 idna==2.10 pycparser==2.20  pyOpenSSL==20.0.1 \
	            requests==2.24.0 chardet==3.0.4 tqdm==4.59.0  urllib3==1.25.11 toml==0.10.2



RUN set -ex && pip freeze > /etc/installed.txt


RUN set -ex && \
    ln -s /opt/anaconda3/bin/python /usr/bin/python && \
    ln -s /opt/anaconda3/bin/python3 /usr/bin/python3 && \
    ln -s /opt/anaconda3/bin/python3.8 /usr/bin/python3.8 && \
    ln -s /opt/anaconda3/bin/pip /usr/bin/pip && \
    ln -s /opt/anaconda3/bin/pip3 /usr/bin/pip3 && \
    ln -s /opt/anaconda3/bin/pip3.8 /usr/bin/pip3.8 && \
    ln -s /opt/anaconda3/bin/conda /opt/anaconda3/bin/conda3


#Cleanup
RUN set -ex && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
#RUN apk del glibc-i18n make gcc musl-dev build-base gfortran
RUN rm -rf /var/cache/apk/*

COPY enter_keyring.sh /etc/enter_keyring.sh
COPY reuse_keyring.sh /etc/reuse_keyring.sh
COPY unlock_keyring.sh /etc/unlock_keyring.sh
COPY rest_keyring.sh /etc/rest_keyring.sh


WORKDIR /
#CMD ["/bin/sh"]
CMD tail -f /dev/null


##docker system prune --all
#docker rmi -f alpine-anaconda3-amd64 alpine-anaconda3-arm64v8
#docker rm -f conda3-amd64 conda3-amd64-arm64v8
#docker build . -t alpine-anaconda3-amd64 --build-arg ARCH=amd64
#docker build . -t alpine-anaconda3-arm64v8 --build-arg ARCH=arm64v8
#docker run --name conda3-amd64 -d alpine-anaconda3-amd64
#docker run --name conda3-arm64v8 -d alpine-anaconda3-arm64v8
#smoke test
#docker exec -it $(docker ps -q -n=1) pip config list
#docker exec -it $(docker ps -q -n=1) bash
##docker build --squash . -t alpine-anaconda3-amd64 --build-arg ARCH=amd64
##docker build --squash . -t alpine-anaconda3-arm64v8 --build-arg ARCH=arm64v8


#see https://github.com/fabioz/PyDev.Debugger
#docker run --env-file .env.docker --name conda3 -p 54717:54717/tcp -v //C/dev/work/:/opt/project -v //C/Program\ Files/JetBrains/PyCharm\ 2020.1.4/plugins/python/helpers:/opt/.pycharm_helpers -d alpine-anaconda3
##docker exec -it $(docker ps -q -n=1) dbus-run-session bash
#python /opt/.pycharm_helpers/pydev/pydevconsole.py --mode=server --port=54717 #run
#python -u /opt/.pycharm_helpers/pydev/pydevd.py --cmd-line --multiprocess --qt-support=auto --port 54717 --file /opt/project/alpine-anaconda3/keyring_check.py #debug
#runfile('/opt/project/alpine-anaconda3/keyring_check.py', wdir='/opt/project/alpine-anaconda3')


#docker tag alpine-anaconda3-arm64v8 alexberkovich/alpine-anaconda3:0.3.1-arm64v8
#docker tag alpine-anaconda3-amd64 alexberkovich/alpine-anaconda3:0.3.1-amd64

#docker export $(docker ps -q -n=1) | docker import - alpine-anaconda3-amd64-e
#docker run --name conda3-amd64-e -d alpine-anaconda3-amd64-e bash
#populate from docker inspect -f "{{ .Config.Env }}" alpine-anaconda3-amd64
#based on https://docs.docker.com/engine/reference/commandline/commit/
# docker commit --change "CMD /bin/sh"  --change "ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/anaconda3/bin \
#    ARCH=amd64 \
#    PYTHONUNBUFFERED=1 \
#    LANG=C.UTF-8" \
#    $(docker ps -q -n=1) alpine-anaconda3-amd64-ef

#docker export $(docker ps -q -n=1) | docker import - alpine-anaconda3-arm64v8-e
#docker run --name conda3-arm64v8-e -d alpine-anaconda3-arm64v8-e bash
#populate from docker inspect -f "{{ .Config.Env }}" alpine-anaconda3-arm64v8
#based on https://docs.docker.com/engine/reference/commandline/commit/
# docker commit --change "CMD /bin/sh" --change "ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/anaconda3/bin \
#    ARCH=arm64v8 \
#    PYTHONUNBUFFERED=1 \
#    LANG=C.UTF-8" \
#    $(docker ps -q -n=1) alpine-anaconda3-arm64v8-ef


#docker tag alpine-anaconda3-arm64v8-ef alexberkovich/alpine-anaconda3:0.3.2-arm64v8
#docker tag alpine-anaconda3-amd64-ef alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker push alexberkovich/alpine-anaconda3:0.3.2-arm64v8
#docker push alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker manifest create alexberkovich/alpine-anaconda3:0.3.2 --amend alexberkovich/alpine-anaconda3:0.3.2-arm64v8 --amend alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker manifest annotate --arch arm64 --variant v8 alexberkovich/alpine-anaconda3:0.3.2 alexberkovich/alpine-anaconda3:0.3.2-arm64v8
#docker manifest annotate --arch amd64 alexberkovich/alpine-anaconda3:0.3.2 alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker manifest push --purge alexberkovich/alpine-anaconda3:0.3.2

#docker manifest create alexberkovich/alpine-anaconda3:latest --amend alexberkovich/alpine-anaconda3:0.3.2-arm64v8 --amend alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker manifest annotate --arch arm64 --variant v8 alexberkovich/alpine-anaconda3:latest alexberkovich/alpine-anaconda3:0.3.2-arm64v8
#docker manifest annotate --arch amd64 alexberkovich/alpine-anaconda3:latest alexberkovich/alpine-anaconda3:0.3.2-amd64
#docker manifest push --purge alexberkovich/alpine-anaconda3:latest
# EOF