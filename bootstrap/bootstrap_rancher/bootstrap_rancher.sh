#!/bin/bash 

curl -fsSL https://get.docker.com | sh

export RANCHER_VERSION="2.7.0"

sudo docker run -d --restart=unless-stopped \
  -p 80:80 -p 8080:443 \
  --privileged \
  rancher/rancher:v${RANCHER_VERSION}