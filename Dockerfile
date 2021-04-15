FROM python:2-alpine

USER root
WORKDIR /usr/local/quilpad-server

RUN apk update && \
  apk add py-pip && \
  apk add curl && \
  apk add expat-dev py3-cherrypy py-mysqldb && \
  curl -L http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/Pyrex-0.9.9.tar.gz | tar -xvf -  && \
  python Pyrex-0.9.9/setup.py && 

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
