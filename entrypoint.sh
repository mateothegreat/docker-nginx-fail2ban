#!/bin/sh

fail2ban-server -b
nginx -g "daemon off;"

tail -f /var/log/fail2ban.log