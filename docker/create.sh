#!/usr/bin/env bash

# CAUTION script will automatically raise permissions. Do not call this script directly.

if docker info 2>/dev/null | grep -q "rootless"; then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

#clean up first, THIS DELETES existing docker containers be sure this is what you want to do
$DOCKER rm -f board1 &> /dev/null
$DOCKER rm -f board2 &> /dev/null
$DOCKER rm -f board3 &> /dev/null
$DOCKER network rm mynetwork1 &> /dev/null

#set up the network
echo "Creating network..."
$DOCKER network create --driver bridge mynetwork1 &> /dev/null

#spin up the three containers
echo "Starting Docker Containers..."
$DOCKER run --net=mynetwork1 -dit --cpuset-cpus 0 --name=board1 spacerpo > /dev/null
echo "Board 1 Started..."
$DOCKER run --net=mynetwork1 -dit --cpuset-cpus 1 --name=board2 spacerpo > /dev/null
echo "Board 2 Started..."
$DOCKER run --net=mynetwork1 -dit --cpuset-cpus 2 --name=board3 spacerpo > /dev/null
echo "Board 3 Started..."

BOARD1_IP=$($DOCKER inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board1)
BOARD2_IP=$($DOCKER inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board2)
BOARD3_IP=$($DOCKER inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board3)

#remove any old keys
rm -rf keys

#make the keys directory then create keys material
echo "Creating ssh key material..."
mkdir keys
ssh-keygen -t rsa -N "" -f keys/id_rsa.board1 > /dev/null
#ssh-keygen -t rsa -N "" -f keys/id_rsa.board2 > /dev/null
#ssh-keygen -t rsa -N "" -f keys/id_rsa.board3 > /dev/null

#copy ssh keys to the servers and set up the config files
echo "Copying keys to the containers..."
$DOCKER cp keys/id_rsa.board1 board1:/home/ubuntu/.ssh/ > /dev/null
$DOCKER cp keys/id_rsa.board1.pub board1:/home/ubuntu/.ssh/ > /dev/null
$DOCKER exec board1 sudo chmod 600 /home/ubuntu/.ssh/id_rsa.board1
$DOCKER exec board1 sudo chmod 644 /home/ubuntu/.ssh/id_rsa.board1.pub

#setting up config file on board1
echo "Setting up the ssh config file on Board 1..."
execution_script1="Host brother2\n    HostName ${BOARD2_IP}\n    AddKeysToAgent yes\n    IdentityFile /home/ubuntu/.ssh/id_rsa.board1\n    StrictHostKeyChecking no"
execution_script2="Host brother3\n    HostName ${BOARD3_IP}\n    AddKeysToAgent yes\n    IdentityFile /home/ubuntu/.ssh/id_rsa.board1\n    StrictHostKeyChecking no"
touch /tmp/temp-spdz
echo -e $execution_script1 > /tmp/temp-spdz
echo -e $execution_script2 >> /tmp/temp-spdz
$DOCKER cp /tmp/temp-spdz board1:/home/ubuntu/.ssh/config > /dev/null
rm /tmp/temp-spdz

#set up public keys on board2 and board3
echo "Adding Authorized Keys to Board 2..."
$DOCKER cp keys/id_rsa.board1.pub board2:/home/ubuntu/.ssh/authorized_keys > /dev/null
$DOCKER exec board2 sudo chmod 644 /home/ubuntu/.ssh/authorized_keys
echo "Adding Authorized Keys to Board 3..."
$DOCKER cp keys/id_rsa.board1.pub board3:/home/ubuntu/.ssh/authorized_keys > /dev/null
$DOCKER exec board3 sudo chmod 644 /home/ubuntu/.ssh/authorized_keys

echo "Updating Permissions..."
#change the .ssh to be owned by the ubuntu user
$DOCKER exec board1 sudo chown ubuntu -R /home/ubuntu/.ssh
$DOCKER exec board2 sudo chown ubuntu -R /home/ubuntu/.ssh
$DOCKER exec board3 sudo chown ubuntu -R /home/ubuntu/.ssh
#change the .ssh file to have 700 permissions
$DOCKER exec board1 sudo chmod 700 /home/ubuntu/.ssh
$DOCKER exec board2 sudo chmod 700 /home/ubuntu/.ssh
$DOCKER exec board3 sudo chmod 700 /home/ubuntu/.ssh
#change the authorized keys file to have 600 permissions
$DOCKER exec board2 sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
$DOCKER exec board3 sudo chmod 600 /home/ubuntu/.ssh/authorized_keys

echo "Copying over utils and programs"
#copy over the necessary run scripts (TODO change to pull in from github)
$DOCKER cp utils/ board1:/home/ubuntu/ > /dev/null
$DOCKER cp Programs/ board1:/home/ubuntu/MP-SPDZ/ > /dev/null

echo "Copying over Player Data..."
#copy over Player-Data P0->1, P1->2, P2->3
$DOCKER cp Player-Data/Input-P0-0 board1:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
$DOCKER cp Player-Data/Input-P1-0 board2:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
$DOCKER cp Player-Data/Input-P2-0 board3:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
