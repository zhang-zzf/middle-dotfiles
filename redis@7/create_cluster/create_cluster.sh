#!/bin/bash
# auth zzf.zhang
# ./create_cluster


workdir=$(cd $(dirname $0); pwd)

rm -f redis_nodes.txt

while :;do
    cd ${workdir}
    echo "dirname: ${workdir}"
    read -p "Enter the NodeIp: " ip
    if [ "${ip}" == "" ]; then
        break
    fi
    read -p "Enter the instance num[default 4]: " num
    num=${num:-4}
    read -p "Enter the start port[default 7000]: " startPort
    startPort=${startPort:-7000}
    read -p "Enter the username for ssh @${ip}[default admin]: " username
    username=${username:-admin}
    # scp bin to remote node
    scp -r redis_7.0.5_64 ${username}@${ip}:
    ssh ${username}@${ip} "pkill redis-server; \
        sleep 3s; \
        cd ~; \
        rm -r redis_cluster; mkdir -p redis_cluster; \
        mv redis_7.0.5_64 redis_cluster/bin; \
        "
    # 创建目录
    rm -r ${ip}; mkdir ${ip}
    cd ${ip}
    # for
    ((num=${num}-1))
    for i in $(seq 0 ${num}); do
        # 数字加法
        ((port=${startPort}+${i}))
        mkdir ${port}
        cp ${workdir}/redis.conf ${port}
        sed -i "1s/6379/${port}/" ${port}/redis.conf
        scp -r ${port} ${username}@${ip}:~/redis_cluster/
        ssh ${username}@${ip} "cd ~/redis_cluster/${port}; \
            ~/redis_cluster/bin/redis-server redis.conf \
            "
        instances="${instances} ${ip}:${port}"
        echo "- redis://${ip}:${port}" >> ${workdir}/redis_nodes.txt
    done
done
echo "Redis instances: ${instances}"
echo "Now create redis_cluster"
${workdir}/redis_7.0.5_64/redis-cli --cluster create ${instances}
