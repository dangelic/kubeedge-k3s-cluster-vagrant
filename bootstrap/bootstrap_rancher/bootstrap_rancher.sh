#!/bin/bash 

# Disable firewall for testing
# NOTE: A restart might be necessary
sudo ufw disable
sudo apt-get update

export RANCHER_VERSION="2.7.0" # Tested.

# Get Podman as Docker alternative
# NOTE: Podman is not officially referenced by Rancher as valid CRI.
# NOTE: Replace "docker" with "podman" in all related commands.
# NOTE: Cluster spinup by Rancher leveraging Podman is not tested in this setup!
sudo apt-get install -y podman

# Add Docker.io registry to pull Rancher image
echo "[registries.search]\nregistries = ['docker.io']" | sudo tee -a /etc/containers/containers.conf

# Modified command
sudo podman run -d --restart=unless-stopped \
   -p 80:80 -p 8080:443 \
   --privileged \
   rancher/rancher:v${RANCHER_VERSION}

# Get and install Docker as CRI
# curl -fsSL https://get.docker.com | sh
# Start Rancher in container
# # NOTE: In this Vagrant setup, port 8080 is forwarded to the host machine
# # Access in host machines' browser: "https://<external IP of Rancher Server specified in outline JSON>/dashboard"
# # NOTE: The UI takes some time to be accessible 
# sudo docker run -d --restart=unless-stopped \
#   -p 80:80 -p 8080:443 \
#   --privileged \
#   rancher/rancher:v${RANCHER_VERSION}