#! /bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

REDIS_SERVER=/usr/local/opt/redis@3.2/bin/redis-server

_start() {
    ${REDIS_SERVER} ${SHELL_FOLDER}/redis.conf --pidfile /tmp/redis_master.pid --port 6379
    ${REDIS_SERVER} ${SHELL_FOLDER}/redis.conf --pidfile /tmp/redis_slave1.pid --port 7379 --slaveof 127.0.0.1 6379
    ${REDIS_SERVER} ${SHELL_FOLDER}/redis.conf --pidfile /tmp/redis_slave2.pid --port 8379 --slaveof 127.0.0.1 6379
}

_stop() {
    kill `cat /tmp/redis_master.pid`
    kill `cat /tmp/redis_slave1.pid`
    kill `cat /tmp/redis_slave2.pid`
}

case "$1" in
start)
    echo "starting redis database..."
    shift;_start
;;
stop)
    echo "stopping redis database..."
    _stop
;;
restart)
    _stop && _start
;;
*)
    echo "Usage: ${0} start/stop/restart"
;;
esac
