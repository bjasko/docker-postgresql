#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

VOLUME_BASE=/data/postgresql
S_HOST=F18-DB
S_DEV=wlan0
S_DOMAIN=bring.out.ba
S_HOST_IP=192.168.46.21
S_DNS_HOST_IP=192.168.46.254


sudo ip addr show | grep $S_HOST_IP || 
sudo ip addr add $S_HOST_IP/24 dev $S_DEV

docker rm -f $S_HOST.$S_DOMAIN

     
docker run -d \
     -v $VOLUME_BASE/$S_HOST.$S_DOMAIN/lib:/var/lib/postgresql \
     -v $VOLUME_BASE/$S_HOST.$S_DOMAIN/etc:/etc/postgresql \
     -v $VOLUME_BASE/$S_HOST.$S_DOMAIN/log:/var/log/postgresql \
     -p $S_HOST_IP:5432:5432  \
     -v /tmp/syslogdev/log:/dev/log \
     --name $S_HOST.$S_DOMAIN \
     --hostname $S_HOST.$S_DOMAIN  \
     --dns $S_DNS_HOST_IP \
     bout-postgresl



