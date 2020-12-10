#!/bin/bash
ELK_VERSION=$1
docker pull docker.elastic.co/elasticsearch/elasticsearch:$ELK_VERSION
docker pull docker.elastic.co/logstash/logstash:$ELK_VERSION
docker pull docker.elastic.co/kibana/kibana:$ELK_VERSION
docker pull docker.elastic.co/beats/filebeat:$ELK_VERSION
docker pull bitnami/elasticsearch-curator:latest
