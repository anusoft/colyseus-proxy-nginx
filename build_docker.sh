#!/bin/bash
printf -v date '%(%Y%m%d-%H%M)T\n' -1 
DOCKER_TAG=colyseus-nginx-lb:$date

# docker build -q -t $DOCKER_TAG . >docker_hash.txt
docker build -t $DOCKER_TAG .
echo "$DOCKER_TAG">docker_tag.txt
echo "Build done $DOCKER_TAG"