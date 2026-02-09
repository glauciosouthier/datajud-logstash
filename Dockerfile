FROM docker.elastic.co/logstash/logstash:7.12.1

#VOLUME ./pipeline/:/usr/share/logstash/pipeline/
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
COPY ./pipeline/*.conf /usr/share/logstash/pipeline/
COPY ./config/*.yml /usr/share/logstash/config/

RUN echo "......."
VOLUME /mnt/sda1/DESENV/PROJETOS/DATAJUD/ /tmp/
ADD ./create-index.sh /
ARG INDEX=datajudtest

ENV OLD_USER="$USER"
USER root
RUN chmod 777 /create-index.sh
USER $OLD_USER
RUN /create-index.sh "http://71elasearch03.cjf.local:9200/${INDEX}"

