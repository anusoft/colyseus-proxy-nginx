#!/bin/bash

DOCKER_TAG=$(<docker_tag.txt)

docker stop nginx-lb && docker rm nginx-lb
docker run --name nginx-lb -p 8888:8888 --env-file local-docker.env $DOCKER_TAG