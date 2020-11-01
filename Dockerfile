# AlpineLinux with a glibc-2.29-r0 and python3
FROM alpine:3.12

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

ENV PATH=${PATH}:/opt/anaconda3/bin \
    LANG=C.UTF-8

ARG GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.32-r0
ARG ANACONDA_VERSION=Anaconda3-2020.07


#updating from alpine 3.8 to 3.12 as of 01.11.2020
RUN set -ex && \
    #apk -U upgrade  && \
    apk add --no-cache musl=1.1.24-r9 busybox=1.31.1-r19 alpine-baselayout=3.2.0-r7 ca-certificates-bundle \
                       ssl_client=1.31.1-r19 musl-utils=1.1.24-r9

#bash+usefull utils
#curl is installed below
RUN set -ex && \
    apk --no-cache add bash=5.0.17-r0 nano=4.9.3-r0 mlocate=0.26-r7 && \
    updatedb

#disable coloring for nano, see https://stackoverflow.com/a/55597765/1137529
RUN echo "syntax \"disabled\" \".\"" > ~/.nanorc; echo "color green \"^$\"" >> ~/.nanorc

#ssl, curl
#for curl-dev see https://stackoverflow.com/a/51849028/1137529
#for libffi-dev see https://stackoverflow.com/a/58396708/1137529
RUN set -ex && \
    apk add --no-cache openssl-dev=1.1.1g-r0 musl-dev=1.1.24-r9 cyrus-sasl-dev=2.1.27-r6 \
                       linux-headers=5.4.5-r1 unixodbc-dev=2.3.7-r2 curl-dev=7.69.1-r1 libffi-dev==3.3-r2

#https://stackoverflow.com/questions/5178416/libxml-install-error-using-pip
RUN set -ex && \
    apk add --no-cache libxml2-dev=2.9.10-r5 libxslt-dev=1.1.34-r0

#gcc, gfortran, lapack (requires ssl layer above)
#see https://stackoverflow.com/questions/11912878/gcc-error-gcc-error-trying-to-exec-cc1-execvp-no-such-file-or-directory
#see https://stackoverflow.com/a/38571314/1137529
RUN set -ex && \
    apk add --no-cache make=4.3-r0 gcc=9.3.0-r2 build-base=0.5-r2 lapack-dev=3.9.0-r2 freetype-dev=2.10.4-r0 \
                       gfortran=9.3.0-r2

#install glibc (another c++ compiler, older one)
# do all in one step
RUN set -ex && \
    #Remarked by Alex \
    #apk -U upgrade && \
    #Alex added --no-cache
    apk --no-cache add libstdc++=9.3.0-r2 curl=7.69.1-r1 && \
    #Added  by Alex \
    #Alex added --no-cache
    apk --no-cache add net-tools=1.60_git20140218-r2 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    #Alex added --no-cache
    apk --no-cache add /tmp/*.apk && \
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

# install anaconda, see https://github.com/ContinuumIO/docker-images/blob/master/anaconda/alpine/Dockerfile
#RUN addgroup -S anaconda && \
#    adduser -D -u 10151 anaconda -G anaconda && \
RUN set -ex && \
    wget --quiet https://repo.continuum.io/archive/$ANACONDA_VERSION-Linux-x86_64.sh -O anaconda.sh && \
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
     conda uninstall pyyaml numba tornado entrypoints numpy scipy && \
     #hack to remove ruamel.yaml, because it is distutils installed project
     rm -fr /opt/anaconda3/lib/python3.8/site-packages/ruamel_yaml* && \
     #latest pip,setuptools,wheel
     pip install --upgrade pip==20.2.4 setuptools==50.3.2 wheel==0.35.1 && \
     pip install ruamel_yaml==0.15.100  && \
     conda install conda=4.9.1 python=3.8.5 && \
     #--- numpy related part ---
     #restoring numba dependencies, not available in pip (part 1)
     conda install blas=1.0 libllvm10=10.0.1 mkl-service=2.3.0 mkl_fft=1.2.0 mkl_random=1.1.1 && \
     conda clean -afy && \
     #restoring numba dependencies from pip (part 2)
     pip install numba==0.51.2 intel-openmp==2019.0 icc_rt==2019.0 \
                        llvmlite==0.34.0 mkl==2019.0 tbb==2020.3.254 && \
     #graphviz is used for pydot package
     #we want to ensure that numpy,scipy, python's anaconda version remain untouched
     pip install graphviz==0.14.2 numpy==1.16.2 scipy==1.2.1 && \

     #reinstall removed package by conda uninstall through pip (pinned versions)
     pip install pandas==0.25.3 scikit-learn==0.20.3  matplotlib==3.0.3 shub==2.10.0 nltk==3.4.5 \
                 seaborn==0.9.0 Bottleneck==1.2.1 && \

     #reinstall removed package by conda uninstall through pip (latest versions)
     #Werkzeug ast.Module signature change in Python 3.8.0a3 causes TypeError
     #https://github.com/pallets/werkzeug/issues/1551
     #" For production systems you should pin the version being used with ruamel.yaml<=0.15",
	 #see https://pypi.org/project/ruamel.yaml/ On 0.15.78  setup issue for 3.8 was fixed.
     pip install  \
                 lxml==4.6.1 beautifulsoup4==4.9.3 pyodbc==4.0.30 mock==4.0.2 pytest==6.1.1 flask==1.1.2 \
                 HiYaPyCo==0.4.16 terminado==0.9.1 nbconvert==6.0.7 keyring==21.4.0 \
                 PyWavelets==1.1.1 pytest-doctestplus==0.2.0 pytest-arraydiff==0.3 patsy==0.5.1 \
                 numexpr==2.7.1 imageio==2.9.0 h5py==2.10.0 bkcharts==0.2 astropy==4.1 Pillow==8.0.1 \
                 Werkzeug==1.0.1


RUN set -ex && \
	 #boto3
	 pip install awscli==1.18.54 boto3==1.13.4 botocore==1.16.4 colorama==0.4.1


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

RUN set -ex && \
    #already installed, just for documentatation
	pip install cffi==1.14.3 cryptography==3.1.1 idna==2.10 pycparser==2.20  pyOpenSSL==19.1.0 \
	            requests==2.24.0 tqdm==4.50.2  urllib3==1.25.11

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

WORKDIR /
#CMD ["/bin/sh"]
CMD tail -f /dev/null


#docker system prune --all
#docker rmi -f alpine-anaconda3
#docker rm -f conda3
#docker build  . -t alpine-anaconda3
#docker run --name conda3 -d alpine-anaconda3
#smoke test
#docker exec -it $(docker ps -q -n=1) pip config list
#docker exec -it $(docker ps -q -n=1) bash
#docker build --squash . -t alpine-anaconda3
#docker tag alpine-anaconda3 alexberkovich/alpine-anaconda3:0.0.3
#docker push alexberkovich/alpine-anaconda3:0.0.3
# EOF
