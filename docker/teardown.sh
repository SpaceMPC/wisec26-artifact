#!/bi/bash

#clean up, THIS DELETES existing docker containers be sure this is what you want to do
docker rm -f board1 > /dev/null
docker rm -f board2 > /dev/null
docker rm -f board3 > /dev/null
docker network rm mynetwork1 > /dev/null
