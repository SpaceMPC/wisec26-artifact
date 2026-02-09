#!/bin/bash

#Spin up Docker containers
bash create.sh

NUMBER_OF_PARTIES=2
NUMBER_OF_EXECUTIONS=1
OUTPUT_DIRECTORY=test/
PROGRAM=apf

#grab the IP address of the Host board
BOARD1_IP=$(sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board1)

#execute these in the docker containers
sudo docker exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000" --with-verbose-printing True --protocols hemi,semi,soho,temi,mascot
sudo docker exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 192" -Fe "--batch-size 1000" --with-verbose-printing True --protocols semi2k
sudo docker exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000" --with-verbose-printing True --protocols spdz2k

NUMBER_OF_PARTIES=3
NUMBER_OF_EXECUTIONS=1
OUTPUT_DIRECTORY=test/
PROGRAM=qp3

sudo docker exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000" --with-verbose-printing True --protocols atlas,replicated-field,shamir,malicious-rep-field,ps-rep-field,sy-rep-field,sy-shamir,malicious-shamir,hemi,semi,soho,temi,mascot
sudo docker exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 192" -Fe "--batch-size 1000" --with-verbose-printing True --protocols replicated-ring,brain,malicious-rep-ring,ps-rep-ring,sy-rep-ring,semi2k,spdz2k


echo "Copying data to ${OUTPUT_DIRECTORY}..."
sudo docker cp board1:/home/ubuntu/utils/$OUTPUT_DIRECTORY ./ > /dev/null

echo "Stopping Docker Containers..."
sudo bash teardown.sh
echo "Docker Containers Stopped..."


