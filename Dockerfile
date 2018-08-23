FROM rhel7-rhel-minimal:latest

ENV PG_VERSION 0.5.2

USER root

RUN microdnf install tar gzip --enablerepo=rhel-7-server-rpms && \
  microdnf update; microdnf clean all && \
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
