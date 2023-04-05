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

# -- Setup MQTT-Client
# Note: Keadm 1.13.0 installs MQTT by default but it does not seem to connect. A prior install will fixes this
sudo add-apt-repository -y ppa:mosquitto-dev/mosquitto-ppa
sudo apt install -y mosquitto mosquitto-clients
mosquitto --version

# -- Setup KubeEdge in v1.13.0

# Get Keadm as installer tool for KubeEdge
wget https://github.com/kubeedge/kubeedge/releases/download/v1.13.0/keadm-v1.13.0-linux-amd64.tar.gz
tar -zxvf keadm-v1.13.0-linux-amd64.tar.gz
cp keadm-v1.13.0-linux-amd64/keadm/keadm /usr/local/bin/keadm

# Join Edge-Node in K3s-Cluster
# Note: containerd is leveraged as CRI instead of Docker by modifying the default installation 
keadm join --cloudcore-ipport=$CLOUDSIDE_IP:10000 --token=$KE_TOKEN --kubeedge-version=v1.13.0 --remote-runtime-endpoint=unix:///var/run/containerd/containerd.sock --runtimetype=remote --cgroupdriver=cgroupfs

# -- Configure Edgecore to connect to MQTT-Client on Cloudside
# Note: Configs for Edgecore are stored in /etc/kubeedge/config/edgecore.yaml => restart service to apply
sed -i "s/mqttServerExternal: .*/mqttServerExternal: tcp:\/\/$CLOUDSIDE_IP:1883/g; s/mqttServerInternal: .*/mqttServerInternal: tcp:\/\/$CLOUDSIDE_IP:1883/g" /etc/kubeedge/config/edgecore.yaml
sudo systemctl restart edgecore

-- Enable edge-to-edge (to cloud) communication via MQTT-Client
# Subscribe to the communication topic and run a background script to store data published to this topic
# TODO: Refactor - store data in a DB.
OUTPUT_FILE=demo-message-storage.txt
nohup mosquitto_sub -h 10.21.0.101 -t edge-to-edge  >> "$OUTPUT_FILE" 2>&1 &

echo "\nScript: done."
