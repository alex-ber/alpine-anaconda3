# AlpineLinux with a glibc-2.29-r0 and python3
FROM alpine:3.8

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1


RUN set -ex && \
    apk add --no-cache apr-dev=1.6.3-r1 make=4.2.1-r2 openssl-dev=1.0.2t-r0 gcc=6.4.0-r9 musl-dev=1.1.19-r11 && \
    #see https://stackoverflow.com/questions/11912878/gcc-error-gcc-error-trying-to-exec-cc1-execvp-no-such-file-or-directory
    apk add --no-cache build-base=0.5-r1 && \
    apk add --no-cache cyrus-sasl-dev=2.1.26-r14 linux-headers=4.4.6-r2 unixodbc-dev=2.3.5-r0 && \
    #see https://stackoverflow.com/a/38571314/1137529
    apk add --no-cache lapack-dev=3.8.0-r0 freetype-dev=2.9.1-r1 && \
    apk add --no-cache gfortran=6.4.0-r9



ENV \
    PATH=${PATH}:/opt/anaconda3/bin \
    GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc \
    GLIBC_VERSION=2.29-r0 \
    LANG=C.UTF-8 \
    ANACONDA_VERSION=Anaconda3-2019.03

# do all in one step
RUN set -ex && \
    #Remarked by Alex \
    #apk -U upgrade && \
    #Alex added --no-cache
    #ca-certificates bash
    apk --no-cache add libstdc++=6.4.0-r9 curl=7.61.1-r3 ca-certificates=20190108-r0 bash=4.4.19-r1 && \
    #Added  by Alex \
    #Alex added --no-cache
    apk --no-cache add net-tools=1.60_git20140218-r2 nano=2.9.8-r0 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    #Alex added --no-cache
    apk --no-cache add /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib
    #Alex fix
    #mkdir /opt


#Alex
#disable coloring for nano, see https://stackoverflow.com/a/55597765/1137529
RUN echo "syntax \"disabled\" \".\"" > ~/.nanorc; echo "color green \"^$\"" >> ~/.nanorc

#work-arround for nano
#Odd caret/cursor behavior in nano within SSH session,
#see https://github.com/Microsoft/WSL/issues/1436#issuecomment-480570997
ENV TERM eterm-color


#https://stackoverflow.com/questions/9510474/removing-pips-cache
#https://pip.pypa.io/en/stable/reference/pip_install/#caching
RUN mkdir -p /root/.config/pip
RUN echo "[global]" > /root/.config/pip/pip.conf; echo "no-cache-dir = false" >> /root/.config/pip/pip.conf; echo >> /root/.config/pip/pip.conf;

# install anaconda, see https://github.com/ContinuumIO/docker-images/blob/master/anaconda/alpine/Dockerfile
#RUN addgroup -S anaconda && \
#    adduser -D -u 10151 anaconda -G anaconda && \
RUN set -ex && \
    wget --quiet https://repo.continuum.io/archive/$ANACONDA_VERSION-Linux-x86_64.sh -O anaconda.sh && \
    #echo "${ANACONDA_MD5}  anaconda.sh" > anaconda.md5 && \
    #if [ $(md5sum -c anaconda.md5 | awk '{print $2}') != "OK" ] ; then exit 1; fi && \
    mkdir -p /opt && \
    #Alex fix sh changed to bash
    bash ./anaconda.sh -b -p /opt/anaconda3 && \
    #Alex remark
    #rm anaconda.sh anaconda.md5 && \
    rm anaconda.sh

RUN set -ex && \
    #Alex fix
    #ln -s /opt/anaconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    #chown -R anaconda /opt && \
    #echo ". /opt/anaconda3/etc/profile.d/conda.sh" >> /root/.profile && \
    #echo "conda activate base" >> /root/.profile && \
    find /opt/anaconda3/ -follow -type f -name '*.a' -delete && \
    find /opt/anaconda3/ -follow -type f -name '*.js.map' -delete && \
    /opt/anaconda3/bin/conda clean -afy
    #/opt/anaconda3/bin/conda clean -iltp


RUN set -ex && \
    #latest pip,setuptools,wheel
    pip install --upgrade pip==19.3 setuptools==41.4.0 wheel==0.33.6 && \
#graphviz is used for pydot package, it actyally resintalls half of anaconda
#we want to ensure that numpy,scipy, python's &anaconda version remain untouched
#(everthing else is some esoteric anaconda's stuff)
     conda install graphviz=2.38.0 numpy=1.16.2 scipy=1.2.1 python=3.7.1 conda=4.6.14 && \
     pip install --upgrade pip==19.3 setuptools==41.4.0 wheel==0.33.6 && \
#we will install jupyter from pypi, these are it's depenedencies, there is conflict
#entrypoint will be installed below
     conda uninstall llvmlite tornado entrypoints && \
     pip install --upgrade llvmlite==0.26.0 tornado==5.1.1 jupyter==1.0.0 ipython==6.5 pip==19.3 setuptools==41.4.0 wheel==0.33.6 && \
     python3 -m pip install ipykernel==4.6.1 && \
     ipython kernelspec install-self && \
     ipython3 kernelspec install-self && \
#ensure exact python & conda version that was tested
     conda install python=3.7.1 conda=4.6.14 && \
     find /opt/anaconda3/ -follow -type f -name '*.a' -delete && \
     find /opt/anaconda3/ -follow -type f -name '*.js.map' -delete && \
     conda clean -afy && \
#entrypoints used in setup.py
#This version of PyYAML works with awscli
#pyyaml installation from pypi added together with latest pip,setuptools,wheel
     pip install --upgrade entrypoints==0.2.3 pyyaml==5.1 pip==19.3 setuptools==41.4.0 wheel==0.33.6

#
RUN set -ex && \
    ln -s /opt/anaconda3/bin/python /usr/bin/python && \
    ln -s /opt/anaconda3/bin/python3 /usr/bin/python3 && \
    ln -s /opt/anaconda3/bin/python3.7 /usr/bin/python3.7 && \
    ln -s /opt/anaconda3/bin/pip /usr/bin/pip && \
    ln -s /opt/anaconda3/bin/pip3 /usr/bin/pip3 && \
    ln -s /opt/anaconda3/bin/pip3.7 /usr/bin/pip3.7



#Cleanup
RUN set -ex && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
WORKDIR /
#RUN apk del glibc-i18n make gcc musl-dev build-base gfortran
RUN rm -rf /var/cache/apk/*

#CMD ["python3"]
CMD ["/bin/sh"]
#CMD tail -f /dev/null


#docker rmi -f alpine-anaconda3
#docker rm -f conda3
#docker build --squash . -t alpine-anaconda3
#docker run --name conda3 -d alpine-anaconda3
#smoke test
#docker exec -it $(docker ps -q -n=1) pip config list
#docker exec -it $(docker ps -q -n=1) bash
#docker tag alpine-anaconda3 alexberkovich/alpine-anaconda3:0.0.1
#docker push alexberkovich/alpine-anaconda3
# EOF
