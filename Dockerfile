FROM python:2-alpine

USER root
WORKDIR /usr/local/quilpad-server

# below run staement is just for installing mysqldb for python
RUN set -ex \
  && apk add --update --no-cache --virtual .build-deps \
  gcc \
  make \
  libc-dev \
  musl-dev \
  linux-headers \
  pcre-dev \
  python-dev \
  && apk add --no-cache mariadb-dev \
  && sed '/st_mysql_options options;/a unsigned int reconnect;' /usr/include/mysql/mysql.h -i.bkp \
  && pip install --no-cache-dir MySQL-python==1.2.3rc1 \
  && runDeps="$( \
  scanelf --needed --nobanner --recursive /venv \
  | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
  | sort -u \
  | xargs -r apk info --installed \
  | sort -u \
  )" \
  && apk add --virtual .python-rundeps $runDeps
#  && apk del .build-deps

RUN apk add --no-cache py-pip && \
  apk add --no-cache curl && \
  apk add --no-cache expat-dev && \
  pip install cherrypy && \
  curl -L http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/Pyrex-0.9.9.tar.gz -o Pyrex-0.9.9.tar.gz && \
  tar -xvf Pyrex-0.9.9.tar.gz  && \
  cd Pyrex-0.9.9 && \
  python setup.py install && \
  rm -rf Pyrex-0.9.9.tar.gz && \
  apk del curl py-pip

# copy all the files and folder to docker image
COPY . .

# decompress all the .tar.bz2, .tar.gz and .zip
RUN find . -name '*.tar.bz2' -exec tar -xjf {} \; -exec rm -rf {} \; && \
  find . -name '*.tar.gz' -exec tar -xf {} \; -exec rm -rf {} \; && \
  find . -name '*.zip' -exec unzip {} \; -exec rm -rf {} \;

RUN cd Python\ Cart/python && \
  python setup.py build_ext --inplace && \
  cp QuillCCart.so ../../ && \
  cd ../../

RUN mkdir logs && cd logs && touch quill.log
EXPOSE 8090

CMD [ "python", "startquill_cherry.py" ]
