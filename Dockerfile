FROM python:2-alpine

USER root
WORKDIR /usr/local/quilpad-server

RUN apk update && \
  apk add py-pip && \
  apk add curl && \
  apk add expat-dev && \
  pip install cherrypy && \
  curl -L http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/Pyrex-0.9.9.tar.gz -o Pyrex-0.9.9 && \
  tar -xvf Pyrex-0.9.9  && \
  python Pyrex-0.9.9/setup.py

# below run staement is just for installing mysqldb for python
RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
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
    && apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps

# copy all the files and folder to docker image
COPY . .

# decompress all the .tar.bz2, .tar.gz and .zip
RUN find . -name '*.tar.bz2' -exec tar -xjf {} \; && rm -rf - && \
  find . -name '*.tar.gz' -exec tar -xf {} \; && rm -rf - && \
  find . -name '*.zip' -exec unzip {} \;

RUN cd Python\ Cart/python && \
  python setup.py build_ext --inplace && \
  cp QuillCCart.so ../../ && \
  cd ../../

EXPOSE 8090

CMD [ "python", "startquill_cherry.py" ]
