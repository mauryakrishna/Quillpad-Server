FROM python:2-alpine

RUN yum install python-pip
RUN pip2.7 install expat-devel && pip2.7 install cherrypy && yum install MySQL-python
RUN curl -L http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/Pyrex-0.9.9.tar.gz | tar -xvf | python setup.py
WORKDIR /usr/src/app

#RUN pip2.7 install --no-cache-dir -r requirements.txt

# copy all the files and folder to docker image
COPY . .
# decompress all the .tar.bz2
RUN find . -name '*.tar.bz2' -exec tar -xjf {} \;
RUN find . -name '*.tar.gz' -exec tar -xf {} \;

# decompress all the .zip
RUN find . -name '*.zip' -exec unzip {} \;
RUN cd Python\ Cart/python
RUN python setup.py build_ext --inplace
RUN cp QuillCCart.so ../../
RUN cd ../../

EXPOSE 8090
CMD [ "python", "startquill_cherry.py" ]
