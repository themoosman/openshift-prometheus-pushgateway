FROM ubi:latest

ENV PG_VERSION 1.0.0

USER root

RUN yum -y update; yum clean all && \
  curl -L -o /tmp/pg.tar.gz https://github.com/prometheus/pushgateway/releases/download/v$PG_VERSION/pushgateway-$PG_VERSION.linux-amd64.tar.gz && \
  tar -xvf /tmp/pg.tar.gz --directory /tmp && \
  mkdir -p  /opt/app-root/src/ && \
  mv /tmp/pushgateway-$PG_VERSION.linux-amd64/* /opt/app-root/src/ && \
  rm -rf /tmp/pg.tar.gz && \
  rm -rf /tmp/pushgateway-* && \
  chmod 755 /opt/app-root/src/pushgateway && \
  rm -rf /var/cache/yum/* && \
  rm -rf /var/lib/yum/*

EXPOSE 9091

CMD /opt/app-root/src/pushgateway
