#!/bin/bash

CLOUDSIDE_IP=""
KE_TOKEN=""

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --cloudside-ip=*)
      CLOUDSIDE_IP="${1#*=}"
      ;;
    --ke-token=*)
      KE_TOKEN="${1#*=}"
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

# -- Install containerd as CRI for Edgeside

export VERSION_CONTAINERD=1.4.3
wget https://github.com/containerd/containerd/releases/download/v${VERSION_CONTAINERD}/cri-containerd-cni-${VERSION_CONTAINERD}-linux-amd64.tar.gz
wget https://github.com/containerd/containerd/releases/download/v${VERSION_CONTAINERD}/cri-containerd-cni-${VERSION_CONTAINERD}-linux-amd64.tar.gz.sha256sum
sha256sum --check cri-containerd-cni-${VERSION_CONTAINERD}-linux-amd64.tar.gz.sha256sum
sudo tar --no-overwrite-dir -C / -xzf cri-containerd-cni-${VERSION_CONTAINERD}-linux-amd64.tar.gz
sudo systemctl daemon-reload
sudo systemctl start containerd
# Add default config for further settings
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# -- Setup KubeEdge in v1.12.1

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.12.1/keadm-v1.12.1-linux-amd64.tar.gz
tar -zxvf keadm-v1.12.1-linux-amd64.tar.gz
cp keadm-v1.12.1-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Join Edge-Node in K3s-Cluster
# Note: containerd is leveraged as CRI instead of Docker by modifying the default installation 
keadm join --cloudcore-ipport=$CLOUDSIDE_IP:10000 --token=$KE_TOKEN --kubeedge-version=v1.12.1 --remote-runtime-endpoint=unix:///var/run/containerd/containerd.sock --runtimetype=remote --cgroupdriver=cgroupfs 

keadm join --cloudcore-ipport=10.1.10.86:10000 --token=20f5364bb250a55cac6f3e753acda6e5a6a621d1eac9f5971f4ee7ebd4f6d427.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2ODA0NDEyMzd9.kephrR_M931q1EOEdWkaTZoSizpx1tguTuHYQLgaPcA --kubeedge-version=v1.12.1 --remote-runtime-endpoint=unix:///var/run/containerd/containerd.sock --runtimetype=remote --cgroupdriver=cgroupfs 
