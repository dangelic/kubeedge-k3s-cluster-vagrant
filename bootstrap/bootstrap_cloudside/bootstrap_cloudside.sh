#!/bin/bash

CLOUDSIDE_IP=""

# Parse arg
while [ $# -gt 0 ]; do
  case "$1" in
    --cloudside-ip=*)
      CLOUDSIDE_IP="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument: $1"
      exit 1
      ;;
  esac
  shift
done

# Disable firewall for testing
sudo ufw disable

sudo apt-get update

# -- Setup K3s Cluster in v1.22.5

# Get installer tool for K3s and run it
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.22.5+k3s1" K3S_TOKEN="leipzig" sh -

# Make kubectl available for non-root user
sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml

# Copy K3s cluster-config "k3s.yaml" and rename it as "config" so Keadm installer can locate it without extra args
mkdir -p $HOME/.kube
sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -- Setup KubeEdge in v1.12.1

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.12.1/keadm-v1.12.1-linux-amd64.tar.gz
tar -zxvf keadm-v1.12.1-linux-amd64.tar.gz
cp keadm-v1.12.1-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Initialize Cloudcore with Keadm
keadm init --advertise-address=$CLOUDSIDE_IP --profile version=v1.12.1 --kube-config=/root/.kube/config

echo "Sleep 20..."
sleep 20

keadm gettoken > ketoken.txt
echo "*** KubeEdge token ***"
cat ketoken.txt

echo "Script: done."