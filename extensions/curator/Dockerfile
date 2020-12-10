FROM bitnami/elasticsearch-curator:latest

MAINTAINER loulvlin loululin@163.com

USER root

RUN bash -c 'mkdir -p /usr/share/curator/config'

RUN bash -c 'mkdir -p /opt/elasticsearch-curator/logs'

ADD config/  /usr/share/curator/config/

RUN install_packages cron && \
    echo \
        '* * * * *' \
        root \
        LC_ALL=C.UTF-8 LANG=C.UTF-8 \
        /opt/bitnami/python/bin/curator \
        --config=/usr/share/curator/config/curator.yml \
        /usr/share/curator/config/delete_log_files_curator.yml \
        '>/proc/1/fd/1' '2>/proc/1/fd/2' \
        >>/etc/crontab

ENTRYPOINT ["cron"]
CMD ["-f", "-L8"]
