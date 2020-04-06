#! /bin/bash

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

REDIS_SERVER=/usr/local/opt/redis@3.2/bin/redis-server

TMP_DIR="/tmp"

_start() {
    for ((i=0;i<6;i++));do
        dir="${TMP_DIR}/770${i}"
        mkdir -p "${dir}" 2>/dev/null
        cd ${dir} && ${REDIS_SERVER} ${SHELL_FOLDER}/redis.conf --port "770${i}" --pidfile "${dir}/redis.pid" --daemonize yes
    done
}

_stop() {
    for ((i=0;i<6;i++));do
        dir="${TMP_DIR}/770${i}" && kill `cat ${dir}/redis.pid`
    done
}

_cluster() {
    hosts=""
    for ((i=0;i<6;i++));do
        hosts="${hosts} 127.0.0.1:770${i}"
    done
    ./redis-trib.rb create --replicas 1 ${hosts}
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
cluster)
    _cluster
;;
*)
    echo "Usage: ${0} start/stop/restart"
;;
esac
