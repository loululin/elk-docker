#!/bin/bash
docker pull docker.elastic.co/elasticsearch/elasticsearch:$ELK_VERSION
docker pull docker.elastic.co/logstash/logstash:$ELK_VERSION
docker pull docker.elastic.co/kibana/kibana:$ELK_VERSION
docker pull docker.elastic.co/beats/filebeat:$ELK_VERSION
