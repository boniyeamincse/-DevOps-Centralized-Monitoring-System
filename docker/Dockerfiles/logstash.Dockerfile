FROM docker.elastic.co/logstash/logstash:8.14.0
ENV TZ=Asia/Dhaka
# Pipeline config
COPY elk/logstash/pipelines.conf /usr/share/logstash/pipeline/logstash.conf
