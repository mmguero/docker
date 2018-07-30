#!/bin/bash

IMAGE_NAME=pcloud-desktop
SYNC_DIR=$HOME/pcloud
RUN_DIR=$HOME/.pcloud
CONFIG_DIR=$HOME/.config/pCloud

mkdir -p $SYNC_DIR $RUN_DIR $CONFIG_DIR

DOCKPORT=$(shuf -i25000-59000 -n1)
CID=$(docker run -p $DOCKPORT:22 -t -d --device /dev/fuse --cap-add SYS_PTRACE --cap-add NET_ADMIN --cap-add SYS_RESOURCE --cap-add IPC_LOCK --cap-add SYS_ADMIN -v $HOME/tmp:/data:rw,Z -v $SYNC_DIR:/home/dockerx/pcloud:rw,Z -v $RUN_DIR:/home/dockerx/.pcloud:rw,Z -v $CONFIG_DIR:/home/dockerx/.config/pCloud:rw,Z -v $HOME/.bash_functions:/etc/bash.bash_functions:ro,Z -v $HOME/.bash_aliases:/etc/bash.bash_aliases:ro,Z -v $HOME/.bashrc:/etc/bash.bashrc:ro,Z -v $HOME/.gitconfig:/etc/gitconfig:ro,Z -v $HOME/.ssh/id_rsa_edb_service:/etc/ssh/id_rsa_edb_service:ro,Z -v $HOME/.ssh/id_rsa_edb_service.pub:/etc/ssh/id_rsa_edb_service.pub:ro,Z $IMAGE_NAME)
IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $CID)
echo "Waiting a few moment for $CID to come up..."
while ! nc -z $IP 22; do
  sleep 1
done
sleep 1
docker logs $CID
echo "Container $CID at $IP"
ssh -p 22 root@$IP "passwd && passwd dockerx"
ssh-copy-id -i $HOME/.ssh/id_rsa.pub -p 22 dockerx@$IP

