# Use the official Logstash image as a base
FROM logstash:8.10.2

# Copy the pipeline configuration file
COPY ../../elk/logstash/pipelines.conf /usr/share/logstash/pipeline/logstash.conf

# Expose the Logstash ports
EXPOSE 5044 9600
