#!/usr/bin/env bash

#check if rootless docker; change docker command based on this
if docker info 2>/dev/null | grep -q "rootless"; then
    IS_ROOTLESS=true
    DOCKER=docker
else
    IS_ROOTLESS=false
    DOCKER="sudo docker"
fi

if [ "$IS_ROOTLESS" = false ]; then
    echo "CAUTION: Rootful Docker detected."
    echo "This script will require elevated permissions (sudo) to manage containers."
    read -p "Do you wish to proceed? (y/n): " confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled by user."
        exit 1
    fi
fi


#Spin up Docker containers
bash create.sh

NUMBER_OF_EXECUTIONS=1


#### APF #####

echo ""
echo "Executing APF with NO noise, and NO direct"
echo ""
#APF no noise; no direct
NUMBER_OF_PARTIES=2
OUTPUT_DIRECTORY=data/no-direct/
PROGRAM=apf

#grab the IP address of the Host board
BOARD1_IP=$($DOCKER inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' board1)

#execute these in the docker containers
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000" --with-verbose-printing True --protocols hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000" --with-verbose-printing True --protocols semi2k,spdz2k

echo ""
echo "Executing APF with NO noise, and WITH direct"
echo ""
#APF no noise; with direct
NUMBER_OF_PARTIES=2
OUTPUT_DIRECTORY=data/with-direct/
PROGRAM=apf

#execute these in the docker containers
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols semi2k,spdz2k

echo ""
echo "Executing APF with noise, and NO direct"
echo ""
#APF with noise; no direct
NUMBER_OF_PARTIES=2
OUTPUT_DIRECTORY=data/no-direct/
PROGRAM=apf_with_noise

#execute these in the docker containers
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000" --with-verbose-printing True --protocols hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000" --with-verbose-printing True --protocols semi2k,spdz2k

echo ""
echo "Executing APF with noise, and WITH direct"
echo ""
#APF with noise; with direct
NUMBER_OF_PARTIES=2
OUTPUT_DIRECTORY=data/with-direct/
PROGRAM=apf_with_noise

#execute these in the docker containers
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols semi2k,spdz2k

#### QP #####

echo ""
echo "Executing QP with NO direct"
echo ""
#QP no direct
NUMBER_OF_PARTIES=3
OUTPUT_DIRECTORY=data/no-direct/
PROGRAM=qp3

$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000" --with-verbose-printing True --protocols atlas,replicated-field,shamir,malicious-rep-field,ps-rep-field,sy-rep-field,sy-shamir,malicious-shamir,hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000" --with-verbose-printing True --protocols replicated-ring,brain,malicious-rep-ring,ps-rep-ring,sy-rep-ring,spdz2k

echo ""
echo "Executing QP with WITH direct"
echo ""
#QP with direct
NUMBER_OF_PARTIES=3
OUTPUT_DIRECTORY=data/with-direct/
PROGRAM=qp3

$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols atlas,replicated-field,shamir,malicious-rep-field,ps-rep-field,sy-rep-field,sy-shamir,malicious-shamir,hemi,semi,soho,temi,mascot
$DOCKER exec --workdir=/home/ubuntu/utils/ board1 python3 execute.py -n $NUMBER_OF_EXECUTIONS -N $NUMBER_OF_PARTIES -o $OUTPUT_DIRECTORY -M /home/ubuntu/MP-SPDZ $PROGRAM -U ubuntu -I $BOARD1_IP -Fc "-R 154" -Fe "--batch-size 1000 --direct" --with-verbose-printing True --protocols replicated-ring,brain,malicious-rep-ring,ps-rep-ring,sy-rep-ring,spdz2k


echo "Copying data to ${OUTPUT_DIRECTORY}..."
$DOCKER cp board1:/home/ubuntu/utils/$OUTPUT_DIRECTORY ./ > /dev/null

echo "Stopping Docker Containers..."
bash teardown.sh
echo "Docker Containers Stopped..."


