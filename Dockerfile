FROM ubuntu:20.04

RUN apt-get update && apt-get install -y fail2ban nginx iptables

RUN rm -rf /etc/fail2ban/jail.d/* /etc/fail2ban/filter.d/*
RUN mkdir /var/run/fail2ban

COPY entrypoint.sh /entrypoint.sh
COPY etc /etc

ENTRYPOINT ["/entrypoint.sh"]