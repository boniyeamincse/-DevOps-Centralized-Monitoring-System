FROM docker.elastic.co/elasticsearch/elasticsearch:8.14.0
ENV TZ=Asia/Dhaka
# Drop in your config
COPY elk/elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
# Ensure correct ownership (image runs as elasticsearch user)
USER root
RUN chown elasticsearch:elasticsearch /usr/share/elasticsearch/config/elasticsearch.yml
USER elasticsearch
