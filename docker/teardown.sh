#!/usr/bin/env bash

# CAUTION script will automatically raise permissions. Do not call this script directly.

if docker info 2>/dev/null | grep -q "rootless"; then
    DOCKER=docker
else
    DOCKER="sudo docker"
fi

#clean up, THIS DELETES existing docker containers be sure this is what you want to do
$DOCKER rm -f board1 > /dev/null
$DOCKER rm -f board2 > /dev/null
$DOCKER rm -f board3 > /dev/null
$DOCKER network rm mynetwork1 > /dev/null
