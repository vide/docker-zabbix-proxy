#!/bin/bash

# Default to "run" if none was provided
if [ -z "$MONIT_CMD" ]; then
    MONIT_CMD="run"
fi

if [ -z "$ZABBIX_SERVER" ]; then
    echo "ERROR: missing -z or --zabbix-server option"
    usage
    exit 1
else
    sed -i "s/ZABBIX_SERVER/$ZABBIX_SERVER/g" /etc/zabbix/zabbix_proxy.conf
fi

if [ -z "$ZABBIX_HOSTNAME" ]; then
    echo "ERROR: missing -s or --host option"
    usage
    exit 1
else
    sed -i "s/ZABBIX_HOSTNAME/$ZABBIX_HOSTNAME/g" /etc/zabbix/zabbix_proxy.conf
fi

# We either use the default or what was passed in
sed -i "s/ZABBIX_PORT/$ZABBIX_PORT/g" /etc/zabbix/zabbix_proxy.conf

# Start Zabbix proxy with monit
# https://github.com/berngp/docker-zabbix/blob/master/scripts/entrypoint.sh
_cmd="/usr/bin/monit -d 10 -Ic /etc/monit/monitrc"
_shell="/bin/bash"

case "$MONIT_CMD" in
  run)
    echo "Running Monit... "
    exec /usr/bin/monit -d 10 -Ic /etc/monit/monitrc
    ;;
  stop)
    $_cmd stop all
    RETVAL=$?
    ;;
  restart)
    $_cmd restart all
    RETVAL=$?
    ;;
  shell)
    $_shell
    RETVAL=$?
    ;;
  status)
    $_cmd status all
    RETVAL=$?
    ;;
  summary)
    $_cmd summary
    RETVAL=$?
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart|shell|status|summary}"
    RETVAL=1
esac
