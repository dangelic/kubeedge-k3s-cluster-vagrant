#!/bin/bash 

# Disable firewall for testing
# NOTE: A restart might be necessary
sudo ufw disable

# Get and install Docker as CRI
# QUESTION: Is Podman possible?
curl -fsSL https://get.docker.com | sh

export RANCHER_VERSION="2.7.0" # Tested.

# Start Rancher in container

# NOTE: In this Vagrant setup, port 8080 is forwarded to the host machine
# Access in host machines' browser: "https://<external IP of Rancher Server specified in outline JSON>/dashboard"
# NOTE: The UI takes some time to be accessible 
sudo docker run -d --restart=unless-stopped \
  -p 80:80 -p 8080:443 \
  --privileged \
  rancher/rancher:v${RANCHER_VERSION}