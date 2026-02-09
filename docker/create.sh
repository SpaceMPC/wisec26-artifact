#!/bin/bash

#clean up first, THIS DELETES existing docker containers be sure this is what you want to do
sudo docker rm -f board1 &> /dev/null
sudo docker rm -f board2 &> /dev/null
sudo docker rm -f board3 &> /dev/null
sudo docker network rm mynetwork1 &> /dev/null

#set up the network
echo "Creating network..."
sudo docker network create --driver bridge mynetwork1 &> /dev/null

#spin up the three containers
echo "Starting Docker Containers..."
sudo docker run --net=mynetwork1 -dit --cpuset-cpus 0 --name=board1 spacerpo > /dev/null
echo "Board 1 Started..."
sudo docker run --net=mynetwork1 -dit --cpuset-cpus 1 --name=board2 spacerpo > /dev/null
echo "Board 2 Started..."
sudo docker run --net=mynetwork1 -dit --cpuset-cpus 2 --name=board3 spacerpo > /dev/null
echo "Board 3 Started..."

BOARD1_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board1)
BOARD2_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board2)
BOARD3_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board3)

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
sudo docker cp keys/id_rsa.board1 board1:/home/ubuntu/.ssh/ > /dev/null
sudo docker cp keys/id_rsa.board1.pub board1:/home/ubuntu/.ssh/ > /dev/null
sudo docker exec board1 sudo chmod 600 /home/ubuntu/.ssh/id_rsa.board1
sudo docker exec board1 sudo chmod 644 /home/ubuntu/.ssh/id_rsa.board1.pub
#docker cp keys/id_rsa.board2 board2:/home/ubuntu/.ssh/ > /dev/null
#docker cp keys/id_rsa.board2.pub board2:/home/ubuntu/.ssh/ > /dev/null
#docker cp keys/id_rsa.board3 board3:/home/ubuntu/.ssh/ > /dev/null
#docker cp keys/id_rsa.board3.pub board3:/home/ubuntu/.ssh/ > /dev/null

#setting up config file on board1
echo "Setting up the ssh config file on Board 1..."
execution_script1="Host brother2\n    HostName ${BOARD2_IP}\n    AddKeysToAgent yes\n    IdentityFile /home/ubuntu/.ssh/id_rsa.board1\n    StrictHostKeyChecking no"
execution_script2="Host brother3\n    HostName ${BOARD3_IP}\n    AddKeysToAgent yes\n    IdentityFile /home/ubuntu/.ssh/id_rsa.board1\n    StrictHostKeyChecking no"
touch /tmp/temp-spdz
echo -e $execution_script1 > /tmp/temp-spdz
echo -e $execution_script2 >> /tmp/temp-spdz
sudo docker cp /tmp/temp-spdz board1:/home/ubuntu/.ssh/config > /dev/null
rm /tmp/temp-spdz

#set up public keys on board2 and board3
echo "Adding Authorized Keys to Board 2..."
sudo docker cp keys/id_rsa.board1.pub board2:/home/ubuntu/.ssh/authorized_keys > /dev/null
sudo docker exec board2 sudo chmod 644 /home/ubuntu/.ssh/authorized_keys
echo "Adding Authorized Keys to Board 3..."
sudo docker cp keys/id_rsa.board1.pub board3:/home/ubuntu/.ssh/authorized_keys > /dev/null
sudo docker exec board3 sudo chmod 644 /home/ubuntu/.ssh/authorized_keys

echo "Updating Permissions..."
#change the .ssh to be owned by the ubuntu user
sudo docker exec board1 sudo chown ubuntu -R /home/ubuntu/.ssh
sudo docker exec board2 sudo chown ubuntu -R /home/ubuntu/.ssh
sudo docker exec board3 sudo chown ubuntu -R /home/ubuntu/.ssh
#change the .ssh file to have 700 permissions
sudo docker exec board1 sudo chmod 700 /home/ubuntu/.ssh
sudo docker exec board2 sudo chmod 700 /home/ubuntu/.ssh
sudo docker exec board3 sudo chmod 700 /home/ubuntu/.ssh
#change the authorized keys file to have 600 permissions
sudo docker exec board2 sudo chmod 600 /home/ubuntu/.ssh/authorized_keys
sudo docker exec board3 sudo chmod 600 /home/ubuntu/.ssh/authorized_keys

echo "Copying over utils and programs"
#copy over the necessary run scripts (TODO change to pull in from github)
sudo docker cp utils/ board1:/home/ubuntu/ > /dev/null
sudo docker cp Programs/ board1:/home/ubuntu/MP-SPDZ/ > /dev/null

echo "Copying over Player Data..."
#copy over Player-Data P0->1, P1->2, P2->3
#docker exec board1 mkdir /home/ubuntu/MP-SPDZ/Player-Data/
sudo docker cp Player-Data/Input-P0-0 board1:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
#docker exec board2 mkdir /home/ubuntu/MP-SPDZ/Player-Data/
sudo docker cp Player-Data/Input-P1-0 board2:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
#docker exec board3 mkdir /home/ubuntu/MP-SPDZ/Player-Data/
sudo docker cp Player-Data/Input-P2-0 board3:/home/ubuntu/MP-SPDZ/Player-Data/ > /dev/null
