FROM ubuntu:latest

RUN apt-get update && apt-get install -y python python-pip curl
RUN pip install tornado numpy
COPY bin /opt/bin
RUN chmod +x /opt/bin/es_test_data.py

CMD ["/opt/bin/es_test_data.py", "--es_url=http://elasticsearch-master:9200"]